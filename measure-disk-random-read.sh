#!/bin/bash -e

# https://www.binarylane.com.au/support/solutions/articles/1000055889-how-to-benchmark-disk-i-o

# first write, then read -- otherwise read creates a 4G file to read which takes very long
# random write
WRITE=$(fio --thread --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --runtime=7 --readwrite=randwrite --minimal --size=4G | cut -d ";" -f 49)

# random read
READ=$(fio --thread --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --runtime=7 --readwrite=randread --minimal --size=4G | cut -d ";" -f 8)

rm test

echo "$READ" | awk '{printf $1"\n"}'
echo "$WRITE" | awk '{printf $1"\n"}'
