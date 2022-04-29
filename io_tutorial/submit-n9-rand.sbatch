#!/usr/bin/env bash
#SBATCH -N 4
#SBATCH -n 64
#SBATCH -C gpu
#SBATCH --qos debug
#SBATCH -t 30:00
#SBATCH -A nstaff_g

# IOR="$HOME/src/git/ior/install.cori/bin/ior"
IOR="$HOME/src/iopup/src/ior/bin.muller/ior"

SEGMENTS=64

cd $SCRATCH

srun $IOR -z -t 4k -b 1m -s $SEGMENTS -F 2>&1 | tee ${SLURM_SUBMIT_DIR}/randio.1
srun $IOR -z -t 4k -b 1m -s $SEGMENTS -F -C 2>&1 | tee ${SLURM_SUBMIT_DIR}/randio.2
srun $IOR -z -t 4k -b 1m -s $SEGMENTS -F -C -e 2>&1 | tee ${SLURM_SUBMIT_DIR}/randio.3
srun $IOR -z -t 4k -b 1m -s $SEGMENTS -F -C -e --posix.odirect 2>&1 | tee ${SLURM_SUBMIT_DIR}/randio.4
