#!/usr/bin/env bash
#SBATCH -N 8
#SBATCH -n 128
#SBATCH -C haswell
#SBATCH -t 4:00:00

datasize=$((256*1024*1024)) # this is per-process

for segmentcount in 64 256 1024 4096; do
    blocksize=$(($datasize / $segmentcount))
    transfersize=$blocksize
    srun -N 8 -n $((8*16)) -C haswell $HOME/sc18_pio/bin/ior \
        -s $segmentcount \
        -b $blocksize \
        -t $transfersize \
        -o $SCRATCH/tempFile.hdf5 \
        -f hdf5.ior | tee unaligned_${transfersize}.out
    srun -N 8 -n $((8*16)) -C haswell $HOME/sc18_pio/bin/ior \
        -s $segmentcount \
        -b $blocksize \
        -t $transfersize \
        -O setAlignment=1M \
        -o $SCRATCH/tempFile.hdf5 \
        -f hdf5.ior | tee aligned_${transfersize}.out
done
