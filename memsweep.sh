#!/bin/bash
EXECUTABLE="memsweep"
if [ ! -e $EXECUTABLE ] ; then
	echo "Compiling memsweep.c"
	cc -O -o memsweep.c -lm
fi

echo "Running memsweep benchmark"
if [ "$SYSTEMROOT" = "C:\Windows" ] ; then
	./memsweep.exe
else
	./memsweep.c
fi
