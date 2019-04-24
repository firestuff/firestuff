#!/bin/bash -e

TMPPATH=$(mktemp --directory)
pushd $TMPPATH > /dev/null

URLS=$(wget --spider --recursive --no-verbose https://firestuff.org/ 2>&1 | grep URL: | sed 's/.*URL: *//; s/ .*//')

popd > /dev/null
rm --recursive --force $TMPPATH

for URL in $URLS; do
	wget -O /dev/null --no-verbose https://web.archive.org/save/$URL
done

SCRIPTBASE=$(dirname $0)

for MD in $SCRIPTBASE/markdown/2*.md; do
	FILENAME=$(basename $MD)
	wget -O /dev/null --no-verbose https://web.archive.org/save/https://firestuff.org/markdown/$FILENAME
done
