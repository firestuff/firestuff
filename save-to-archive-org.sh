#!/bin/bash -e

TMPPATH=$(mktemp --directory)

pushd $TMPPATH > /dev/null

URLS=$(wget --spider --recursive --no-verbose https://firestuff.org/ 2>&1 | grep URL: | sed 's/.*URL: *//; s/ .*//')

for URL in $URLS; do
	wget -O /dev/null --no-verbose https://web.archive.org/save/$URL
done

popd > /dev/null

rm --recursive --force $TMPPATH
