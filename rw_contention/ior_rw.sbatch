#!/usr/bin/env bash
#
#  This test compares the performance of a write-only workload and read-only
#  workload with a read+write concurrent workload.
#
#SBATCH -N 64
#SBATCH -C knl
#SBATCH -t 15:00

NUM_NODES=64
FULL_PCT=50
SEGMENTS=512

BINARY=/global/u2/g/glock/src/git/ior/src/ior

READ_TEST_DIR="ior_readtest_${SLURM_JOBID}"
WRITE_TEST_DIR="ior_writetest_${SLURM_JOBID}"

mkdir -p "$READ_TEST_DIR"
mkdir -p "$WRITE_TEST_DIR"

# Create files for our read-only test
srun -N $((NUM_NODES/2)) -n $((NUM_NODES/2*16)) $BINARY -a POSIX -t 1m -b 1m -s ${SEGMENTS} -F -C -e -w -k -M "${FULL_PCT}%" -o "${READ_TEST_DIR}/testFile" > create_${SLURM_JOBID}.out

# Launch both read-only and write-only jobs that overlap with each other
srun -N $((NUM_NODES/2)) -n $((NUM_NODES/2*16)) --share $BINARY -a POSIX -t 1m -b 1m -s ${SEGMENTS} -F -C -e -w -M "${FULL_PCT}%" -o "${WRITE_TEST_DIR}/testFile" > write_overlap_${SLURM_JOBID}.out &
srun -N $((NUM_NODES/2)) -n $((NUM_NODES/2*16)) --share $BINARY -a POSIX -t 1m -b 1m -s ${SEGMENTS} -F -C -e -r -M "${FULL_PCT}%" -o "${READ_TEST_DIR}/testFile" > read_overlap_${SLURM_JOBID}.out &

# Wait until the contending read+write workloads complete
wait

# Test the exclusive read and exlusive write performance
srun -N $((NUM_NODES/2)) -n $((NUM_NODES*16)) --share $BINARY -a POSIX -t 1m -b 1m -s ${SEGMENTS} -F -C -e -M "${FULL_PCT}%" -o "${READ_TEST_DIR}/testFile" > rw_full_${SLURM_JOBID}.out

# Clean up
rm -rvf "$READ_TEST_DIR" "$WRITE_TEST_DIR"
