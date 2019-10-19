#!/usr/bin/env bash
#SBATCH -J full-fs
#SBATCH -N 512
#SBATCH -C knl
# BATCH --qos=regular
# BATCH -t 8:00:00
#SBATCH --qos=debug
#SBATCH -t 30:00
#SBATCH -A nstaff
#SBATCH --mail-type=end,fail
#SBATCH --mail-user=glock@lbl.gov

ppn=16
# blocksize=8388608
# transfersize=8388608
blocksize=1048576
transfersize=1048576

IOR="$HOME/src/git/ior/test/ior-3.3.0+dev/src/ior"

# SCRATCH should point to a directory with an explicit stripe offset to ensure
# we can bottleneck a single OST
TEST_DIR="$SCRATCH/one_stripe"
mkdir -p "$TEST_DIR"
lfs setstripe -c 1 "$TEST_DIR"
lfs getstripe "$TEST_DIR"

for numnodes in 512 256 128 64 32 16 8 4 2 1; do
    segmentcount=512
    srun -N $numnodes -n $(($numnodes * $ppn)) "${IOR}" \
        -s $segmentcount \
        -b $blocksize \
        -t $transfersize \
        -o ${TEST_DIR}/tempFile \
        -O filePerProc=1 \
        -f posix.ior > fpp_${numnodes}.out
done

rmdir "$TEST_DIR"
