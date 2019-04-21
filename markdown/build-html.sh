#!/bin/bash -e

BASEDIR=$(dirname $0)

for FILE in $BASEDIR/*.md; do
	BASENAME=$(basename $FILE)
	if [[ $BASENAME == 'template.md' ]]; then
		continue
	fi
	OUTNAME=${BASENAME%.md}.html
	OUTPATH=$BASEDIR/../$OUTNAME
	if [[ -e $OUTPATH && $OUTPATH -nt $FILE ]]; then
		continue
	fi
	echo "$BASENAME -> $OUTNAME"
	TEMP=$(tempfile --dir=$BASEDIR --mode=0644 --suffix=.tmp)
	markdown $FILE > $TEMP
	diff -ud --color=always $OUTPATH $TEMP || true
	mv $TEMP $OUTPATH
done

printf "\033[0;32mDONE\033[0m\n"
