#!/bin/bash -e

BS=100M
COUNT=3

# Testing write
# We write 8 times 250 MB of null characters and write them to seq_write.
# After that we flush the cache and stop measuring
# WRITE=$(dd if=/dev/zero of=seq_write bs=$BS count=$COUNT conv=fdatasync 2>&1 | tail -n 1 | 
# cut -d " " -f 8-9 | sed s/,/./g | awk '{if($2 ~ /GB/){printf "%d000000\n", $1 * 1000}else{printf "%d000000\n", $1}}')

sync

# Testing read
# We read from our 2GB file in blocks of 250 so we are not bottlencked by memory
# We flush at the end so the system can optimize during write, but the result is
# only measured after everything is written to disk
READ=$(dd if=seq_write of=/dev/null bs=$BS count=$COUNT 2>&1 | tail -n 1 | 
cut -d " " -f 8-9 | sed s/,/./g | awk '{if($2 ~ /GB/){printf "%d000000\n", $1 * 1000}else{printf "%d000000\n", $1}}')

rm seq_write

echo "$READ" | awk '{printf $2 "\n"}'