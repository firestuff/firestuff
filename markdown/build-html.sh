#!/bin/bash -e

BASEDIR=$(dirname $0)

for FILE in $BASEDIR/*.md; do
	BASENAME=$(basename $FILE)
	OUTNAME=${BASENAME%.md}.html
	echo "$BASENAME -> $OUTNAME"
	TEMP=$(tempfile --dir=$BASEDIR --mode=0644 --suffix=.tmp)
	markdown $FILE > $TEMP
	diff -ud --color=always $BASEDIR/../$OUTNAME $TEMP || true
	mv $TEMP $BASEDIR/../$OUTNAME
done

printf "\033[0;32mDONE\033[0m\n"
