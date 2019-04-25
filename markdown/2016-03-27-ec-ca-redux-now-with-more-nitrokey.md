<!--# set var="title" value="EC CA redux: now with more Nitrokey" -->
<!--# set var="date" value="2016-03-27" -->

<!--# include file="include/top.html" -->

This is a revisit on my doc on [how to set up an EC CA](2016-03-21-elliptic-curve-certificate-authority.html). In this version, we’re using the [Nitrokey HSM](https://shop.nitrokey.com/shop/product/nitrokey-hsm-7) for key generation, storage, and operations. You’ll need two Nitrokey HSMs. You can get away with one, but there’s not a lot of point to splitting root and intermediate certs if you then keep them on the same device. You’ll also need a [system set up](2016-03-26-nitrokey-hsm-ec-setup.html) to talk to the Nitrokey, which is a bit tricky.

If you do this right, you can set up a CA where the keys never touched computer that you’re using to host the CA; they only ever reside protected in the Nitrokey.

You have a choice between making the keys unexportable, or supporting a [backup scheme](https://github.com/OpenSC/OpenSC/wiki/SmartCardHSM#using-key-backup-and-restore). Choose wisely, because you can’t change later. If you’re choosing the former, make sure you can answer “what is my plan if the Nitrokey breaks?”.

There’s one material difference from the other instructions: the Nitrokey HSM only supports up to 320-bit EC keys, so we can’t use P-384 (secp384r1) as we did in the other instructions. We’ll be using P-256 (prime256v1) instead.

XXXX is still our placeholder of choice.

## Create directory structure

    mkdir ca
    cd ca
    mkdir -p {root,intermediate}/{certs,crl,csr,newcerts}
    mkdir -p {client,server}/{certs,csr,pfx,private}
    touch {root,intermediate}/database
    echo 1000 | tee {root,intermediate}/{serial,crlnumber}
    chmod 700 {client,server}/private

## Create openssl.cnf

    cat > openssl.cnf <<'END'
    openssl_conf = openssl_init
    [ openssl_init ]
    engines = engines
    [ ca ]
    default_ca = ca_intermediate
    [ ca_root ]
    dir               = root
    certs             = $dir/certs
    crl_dir           = $dir/crl
    new_certs_dir     = $dir/newcerts
    database          = $dir/database
    serial            = $dir/serial
    crlnumber         = $dir/crlnumber
    private_key       = label_root
    certificate       = $dir/certs/root.cert.pem
    crl               = $dir/crl/root.crl.pem
    crl_extensions    = ext_crl
    default_md        = sha256
    name_opt          = ca_default
    cert_opt          = ca_default
    default_crl_days  = 30
    default_days      = 3650
    preserve          = no
    policy            = policy_strict
    [ ca_intermediate ]
    dir               = intermediate
    certs             = $dir/certs
    crl_dir           = $dir/crl
    new_certs_dir     = $dir/newcerts
    database          = $dir/database
    serial            = $dir/serial
    crlnumber         = $dir/crlnumber
    private_key       = label_intermediate
    certificate       = $dir/certs/intermediate.cert.pem
    crl               = $dir/crl/intermediate.crl.pem
    crl_extensions    = ext_crl
    default_md        = sha256
    name_opt          = ca_default
    cert_opt          = ca_default
    default_crl_days  = 30
    default_days      = 375
    preserve          = no
    policy            = policy_loose
    [ policy_strict ]
    countryName             = match
    stateOrProvinceName     = match
    organizationName        = match
    organizationalUnitName  = optional
    commonName              = supplied
    emailAddress            = optional
    [ policy_loose ]
    countryName             = optional
    stateOrProvinceName     = optional
    localityName            = optional
    organizationName        = optional
    organizationalUnitName  = optional
    commonName              = supplied
    emailAddress            = optional
    [ req ]
    default_bits        = 2048
    string_mask         = utf8only
    default_md          = sha256
    distinguished_name  = req_distinguished_name
    [ req_distinguished_name ]
    countryName                     = Country Name (2 letter code)
    stateOrProvinceName             = State or Province Name
    localityName                    = Locality Name
    0.organizationName              = Organization Name
    organizationalUnitName          = Organizational Unit Name
    commonName                      = Common Name
    emailAddress                    = Email Address
    [ ext_root ]
    subjectKeyIdentifier    = hash
    authorityKeyIdentifier  = keyid:always, issuer
    basicConstraints        = critical, CA:true
    keyUsage                = critical, digitalSignature, cRLSign, keyCertSign
    [ ext_intermediate ]
    subjectKeyIdentifier    = hash
    authorityKeyIdentifier  = keyid:always, issuer
    basicConstraints        = critical, CA:true, pathlen:0
    keyUsage                = critical, digitalSignature, cRLSign, keyCertSign
    [ ext_client ]
    basicConstraints        = CA:FALSE
    nsCertType              = client, email
    nsComment               = "OpenSSL Generated Client Certificate"
    subjectKeyIdentifier    = hash
    authorityKeyIdentifier  = keyid, issuer
    keyUsage                = critical, nonRepudiation, digitalSignature, keyEncipherment
    extendedKeyUsage        = clientAuth, emailProtection
    [ ext_server ]
    basicConstraints        = CA:FALSE
    nsCertType              = server
    nsComment               = "OpenSSL Generated Server Certificate"
    subjectKeyIdentifier    = hash
    authorityKeyIdentifier  = keyid, issuer:always
    keyUsage                = critical, digitalSignature, keyEncipherment
    extendedKeyUsage        = serverAuth
    [ ext_crl ]
    authorityKeyIdentifier  = keyid:always
    [ ext_ocsp ]
    basicConstraints        = CA:FALSE
    subjectKeyIdentifier    = hash
    authorityKeyIdentifier  = keyid, issuer
    keyUsage                = critical, digitalSignature
    extendedKeyUsage        = critical, OCSPSigning
    [ engines ]
    pkcs11 = engine_pkcs11
    [ engine_pkcs11 ]
    engine_id     = pkcs11
    dynamic_path  = /usr/lib/arm-linux-gnueabihf/openssl-1.0.0/engines/libpkcs11.so
    MODULE_PATH   = /usr/local/lib/pkcs11/opensc-pkcs11.so
    init          = 0
    END
    
## Tell future commands to use your new conf file

    export OPENSSL_CONF=openssl.cnf

## Create a root key

Insert your root HSM.

    /usr/local/bin/pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --login --keypairgen --key-type EC:prime256v1 --label root
    # Enter PIN

## Create a self-signed root cert

    openssl req -engine pkcs11 -keyform engine -key label_root -new -extensions ext_root -out root/certs/root.cert.pem -x509 -subj '/C=US/ST=California/O=XXXX/OU=XXXX Certificate Authority/CN=XXXX Root CA' -days 7300
    # Enter PIN
    chmod 444 root/certs/root.cert.pem

## Verify root cert

    openssl x509 -noout -text -in root/certs/root.cert.pem

Check:

* Expiration date (20 years in future)
* Signature algorithm (ecdsa-with-SHA256)
* Public key size (256 bit)
* CA:TRUE

## Import root cert onto HSM

    openssl x509 -in root/certs/root.cert.pem -out root/certs/root.cert.der -outform der
    /usr/local/bin/pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --login --write-object root/certs/root.cert.der --type cert --label root
    # Enter PIN

## Create an intermediate key

Insert your intermediate HSM

    /usr/local/bin/pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --login --keypairgen --key-type EC:prime256v1 --label intermediate
    # Enter PIN

## Create an intermediate certificate signing request (CSR)

    openssl req -engine pkcs11 -keyform engine -new -key label_intermediate -out intermediate/csr/intermediate.csr.pem  -subj '/C=US/ST=California/O=XXXX/OU=XXXX Certificate Authority/CN=XXXX Intermediate'
    # Enter PIN

## Sign intermediate cert with root key

Insert your root HSM

    openssl ca -engine pkcs11 -keyform engine -name ca_root -extensions ext_intermediate -notext -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem
    # Enter PIN
    chmod 444 intermediate/certs/intermediate.cert.pem

## Verify intermediate cert

    openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem
    openssl verify -CAfile root/certs/root.cert.pem intermediate/certs/intermediate.cert.pem

Check:

* Expiration date (10 years in future)
* Signature algorithm (ecdsa-with-SHA256)
* Public key size (256 bit)
* CA:TRUE
* OK

## Import root & intermediate certs onto HSM

Insert your intermediate HSM

    openssl x509 -in intermediate/certs/intermediate.cert.pem -out intermediate/certs/intermediate.cert.der -outform der
    /usr/local/bin/pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --login --write-object root/certs/root.cert.der --type cert --label root
    # Enter PIN
    /usr/local/bin/pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --login --write-object intermediate/certs/intermediate.cert.der --type cert --label intermediate
    # Enter PIN

## Create a chain certificate file

    cat intermediate/certs/intermediate.cert.pem root/certs/root.cert.pem > intermediate/certs/chain.cert.pem
    chmod 444 intermediate/certs/chain.cert.pem

## CA setup done!

Take your root HSM, if you have a separate one, and lock it in a safe somewhere; you won’t need it for regular use.

The following steps are examples of how to use your new CA.

## Create a client key

You can substitute “server” for “client” for a server cert.

    openssl ecparam -name secp384r1 -genkey | openssl ec -aes-256-cbc -out client/private/test1.key.pem
    # Create client key password
    chmod 400 client/private/test1.key.pem

## Create a client certificate signing request (CSR)

    openssl req -new -key client/private/test1.key.pem -out client/csr/test1.csr.pem  -subj '/C=US/ST=California/O=XXXX/OU=XXXX Test/CN=XXXX Test 1'

## Sign client cert with intermediate key

    openssl ca -engine pkcs11 -keyform engine -extensions ext_client -notext -in client/csr/test1.csr.pem -out client/certs/test1.cert.pem
    # Enter PIN
    chmod 444 client/certs/test1.cert.pem

## Verify client cert

    openssl x509 -noout -text -in client/certs/test1.cert.pem
    openssl verify -CAfile intermediate/certs/chain.cert.pem client/certs/test1.cert.pem

Check:

* Expiration date (1 year in future)
* Signature algorithm (ecdsa-with-SHA256)
* Public key size (384 bit)
* CA:FALSE
* OK

## Create a PKCS#12 bundle for the client

This is an easy(er) way to get all the necessary keys & certs to the client in one package.

    openssl pkcs12 -export -out client/pfx/test1.pfx -inkey client/private/test1.key.pem -in client/certs/test1.cert.pem -certfile intermediate/certs/chain.cert.pem
    # Enter both the client key password, and a new password for the export; you'll need to give the latter to the client

## Generate a certificate revocation list (CRL)

Initially empty. You can also do this for your root CA (with its HSM inserted).

    openssl ca -engine pkcs11 -keyform engine -gencrl -out intermediate/crl/intermediate.crl.pem

## Verify certificate revocation list

    openssl crl -in intermediate/crl/intermediate.crl.pem -noout -text

Check:

* Expiration date (30 days in future)
* Signature algorithm (ecdsa-with-SHA256)

## Revoke a certificate

Only do this if you need to. Find the certificate:

    cat intermediate/database
    # You'll need the hex-formatted serial number, in the third field.
    # Substitute serial number for YYYY below.

Revoke it:

    openssl ca -engine pkcs11 -keyform engine -revoke intermediate/newcerts/YYYY.pem
    # Enter PIN

Generate a new CRL file:

    openssl ca -engine pkcs11 -keyform engine -gencrl -out intermediate/crl/intermediate.crl.pem
    # Enter PIN

<!--# include file="include/bottom.html" -->
