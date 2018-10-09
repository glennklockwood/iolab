#!/usr/bin/env bash
#SBATCH -J single-ost
#SBATCH -N 128
#SBATCH -C knl
#SBATCH --qos=regular
#SBATCH -t 8:00:00
#xxxxxx --qos=debug
#xxxxxx -t 30:00
#SBATCH -A nstaff

datasize=$((64*1024*1024*1024)) # total size of file dump
ppn=16
blocksize=8388608
transfersize=8388608

# SCRATCH should point to a directory with an explicit stripe offset to ensure
# we can bottleneck a single OST
TEST_DIR="$SCRATCH/one_stripe"
mkdir -p "$TEST_DIR"
lfs setstripe -i 1 -c 1 "$TEST_DIR"
echo "Striping for TEST_DIR=$TEST_DIR"
lfs getstripe "$TEST_DIR"

for numnodes in 128 64 32 16 8 4 2 1; do
# for numnodes in 128 64; do
    segmentcount=$(($datasize / $numnodes / $ppn / $blocksize))
    srun -N $numnodes -n $(($numnodes * $ppn)) $HOME/sc18_pio/bin/ior \
        -s $segmentcount \
        -b $blocksize \
        -t $transfersize \
        -o ${TEST_DIR}/tempFile \
        -O filePerProc=1 \
        -f posix.ior > fpp_${numnodes}.out
    srun -N $numnodes -n $(($numnodes * $ppn)) $HOME/sc18_pio/bin/ior \
        -s $segmentcount \
        -b $blocksize \
        -t $transfersize \
        -o ${TEST_DIR}/tempFile \
        -O filePerProc=0 \
        -f posix.ior > shared_${numnodes}.out
done

rmdir "$TEST_DIR"
