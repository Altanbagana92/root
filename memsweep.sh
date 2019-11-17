#!/bin/bash
EXECUTABLE="memsweep"
if [ ! -e $EXECUTABLE ] ; then
	#echo "Compiling memsweep.c"
	cc -O -o memsweep memsweep.c -lm
fi

if [ "$SYSTEMROOT" = "C:\Windows" ] ; then
	./memsweep.exe
else
	./memsweep
fi
date '+%s'
