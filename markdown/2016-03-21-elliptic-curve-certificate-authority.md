<!--# set var="title" value="Elliptic Curve Certificate Authority" -->
<!--# set var="date" value="2016-03-21" -->

<!--# include file="include/top.html" -->

Notes from setting up a two-level (root and intermediate) CA using EC certs, combined from two decent sets of instructions [here](https://jamielinux.com/docs/openssl-certificate-authority/introduction.html) and [here](https://wiki.openssl.org/index.php/Command_Line_Elliptic_Curve_Operations). This is the CliffsNotes version; see those two docs for more detail. XXXX is used as a placeholder here; search for it and replace.

### Create directory structure

    mkdir ca
    cd ca
    mkdir -p {root,intermediate}/{certs,crl,csr,newcerts,private}
    mkdir -p {client,server}/{certs,csr,pfx,private}
    touch {root,intermediate}/database
    echo 1000 | tee {root,intermediate}/{serial,crlnumber}
    chmod 700 {root,intermediate,client,server}/private
    Create openssl.cnf
    cat > openssl.cnf <<'END'
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
    private_key       = $dir/private/root.key.pem
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
    private_key       = $dir/private/intermediate.key.pem
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
    END

### Create a root key

    openssl ecparam -name secp384r1 -genkey | openssl ec -aes-256-cbc -out root/private/root.key.pem
    # Create strong root key password
    chmod 400 root/private/root.key.pem

### Create a self-signed root cert

    openssl req -config openssl.cnf -key root/private/root.key.pem -new -extensions ext_root -out root/certs/root.cert.pem -x509 -subj '/C=US/ST=California/O=XXXX/OU=XXXX Certificate Authority/CN=XXXX Root CA' -days 7300
    # Enter root key password
    chmod 444 root/certs/root.cert.pem

### Verify root cert

    openssl x509 -noout -text -in root/certs/root.cert.pem

Check:

* Expiration date (20 years in future)
* Signature algorithm (ecdsa-with-SHA256)
* Public key size (384 bit)
* CA:TRUE

### Create an intermediate key

    openssl ecparam -name secp384r1 -genkey | openssl ec -aes-256-cbc -out intermediate/private/intermediate.key.pem
    # Create strong intermediate key password
    chmod 400 intermediate/private/intermediate.key.pem

### Create an intermediate certificate signing request (CSR)

    openssl req -config openssl.cnf -new -key intermediate/private/intermediate.key.pem -out intermediate/csr/intermediate.csr.pem  -subj '/C=US/ST=California/O=XXXX/OU=XXXX Certificate Authority/CN=XXXX Intermediate'
    # Enter intermediate key password

### Sign intermediate cert with root key

    openssl ca -config openssl.cnf -name ca_root -extensions ext_intermediate -notext -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem
    # Enter root key password
    chmod 444 intermediate/certs/intermediate.cert.pem

### Verify intermediate cert

    openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem
    openssl verify -CAfile root/certs/root.cert.pem intermediate/certs/intermediate.cert.pem

Check:

* Expiration date (10 years in future)
* Signature algorithm (ecdsa-with-SHA256)
* Public key size (384 bit)
* CA:TRUE
* OK

### Create a chain certificate file

    cat intermediate/certs/intermediate.cert.pem root/certs/root.cert.pem > intermediate/certs/chain.cert.pem
    chmod 444 intermediate/certs/chain.cert.pem

### Create a client key

You can substitute “server” for “client” for a server cert.

    openssl ecparam -name secp384r1 -genkey | openssl ec -aes-256-cbc -out client/private/test1.key.pem
    # Create client key password
    chmod 400 client/private/test1.key.pem

### Create a client certificate signing request (CSR)

    openssl req -config openssl.cnf -new -key client/private/test1.key.pem -out client/csr/test1.csr.pem  -subj '/C=US/ST=California/O=XXXX/OU=XXXX Test/CN=XXXX Test 1'

### Sign client cert with intermediate key

    openssl ca -config openssl.cnf -extensions ext_client -notext -in client/csr/test1.csr.pem -out client/certs/test1.cert.pem
    # Enter intermediate key password
    chmod 444 client/certs/test1.cert.pem

### Verify client cert

    openssl x509 -noout -text -in client/certs/test1.cert.pem
    openssl verify -CAfile intermediate/certs/chain.cert.pem client/certs/test1.cert.pem

Check:

* Expiration date (1 year in future)
* Signature algorithm (ecdsa-with-SHA256)
* Public key size (384 bit)
* CA:FALSE
* OK

### Create a PKCS#12 bundle for the client

This is an easy(er) way to get all the necessary keys & certs to the client in one package.

    openssl pkcs12 -export -out client/pfx/test1.pfx -inkey client/private/test1.key.pem -in client/certs/test1.cert.pem -certfile intermediate/certs/chain.cert.pem
    # Enter both the client key password, and a new password for the export; you'll need to give the latter to the client

### Generate a certificate revocation list (CRL)

Initially empty. You can also do this for your root CA.

    openssl ca -config openssl.cnf -gencrl -out intermediate/crl/intermediate.crl.pem

### Verify certificate revocation list

    openssl crl -in intermediate/crl/intermediate.crl.pem -noout -text

Check:

* Expiration date (30 days in future)
* Signature algorithm (ecdsa-with-SHA256)

### Revoke a certificate

Only do this if you need to. Find the certificate:

    cat intermediate/database
    # You'll need the hex-formatted serial number, in the third field.
    # Substitute serial number for YYYY below.

Revoke it:

    openssl ca -config openssl.cnf -revoke intermediate/newcerts/YYYY.pem
    # Enter intermediate key password

Generate a new CRL file:

    openssl ca -config openssl.cnf -gencrl -out intermediate/crl/intermediate.crl.pem
    # Enter intermediate key password

<!--# include file="include/bottom.html" -->
