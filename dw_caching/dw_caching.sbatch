#!/usr/bin/env bash
#SBATCH -N 2
#SBATCH -n 128
#SBATCH -C knl
#SBATCH -t 30:00
#SBATCH --qos debug
#DW jobdw pfs=/global/cscratch1/sd/glock capacity=80GB access_mode=striped pool=wlm_pool type=cache

IOR=$SLURM_SUBMIT_DIR/ior
IOR_OPTS="-a POSIX -t 1M -b 1M -s 256 -e -C -k"

PFS_FILE="$SCRATCH/testdir/lustre.testfile"
CACHE_FILE="$DW_JOB_STRIPED_CACHE/testdir/dw.testfile"

# Note: we assume $SCRATCH is predefined on the computing system

srun -N 2 -n 128 $IOR -o "$PFS_FILE" -w $IOR_OPTS > pfs_write.out 2>&1
echo "[$(date)] Write test to parallel file system: $(grep ^Max pfs_write.out)"

echo "[$(date)] Write test to parallel file system created this file:"
stat "$PFS_FILE"

srun -N 2 -n 128 $IOR -o "$PFS_FILE" -r $IOR_OPTS > pfs_read.out 2>&1
echo "[$(date)] Read test from parallel file system: $(grep ^Max pfs_read.out)"

echo "============================================================"

srun -N 2 -n 128 $IOR -o "$CACHE_FILE" -w $IOR_OPTS > dw_write.out 2>&1
echo "[$(date)] Write test to caching instance: $(grep ^Max dw_write.out)"

echo "[$(date)] Write test to caching instance created this file (on PFS):"
stat "$(dirname $PFS_FILE)/$(basename $CACHE_FILE)"

echo "[$(date)] Write test to caching instance created this file (on caching instance):"
stat "$CACHE_FILE"

srun -N 2 -n 128 $IOR -o "$CACHE_FILE" -r $IOR_OPTS > dw_read.out 2>&1
echo "[$(date)] Read test from caching instance: $(grep ^Max dw_read.out)"
