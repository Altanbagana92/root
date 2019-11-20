  
#Performing dd disk benchmarks:

prefix=$(date +%H_%d)
start=$(date +%s)

while [ "$(($start + 300))" -ge "$(date +%s)" ]
do
   dd bs=4k count=100000 if=/dev/zero of=test conv=fdatasync >>"$prefix"_dd_values 2>&1 
done

other_start=$(date +%s)

while [ "$(($other_start + 300))" -ge "$(date +%s)" ]
do
   fio --name=randwrite --ioengine=libaio --iodepth=1 --rw=randrw --direct=0 --size=10MB >>"$prefix"_fio_values 2>&1
done