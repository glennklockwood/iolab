#!/usr/bin/env bash
#SBATCH -N 4
#SBATCH -n 64
#SBATCH -C gpu
#SBATCH --qos debug
#SBATCH -t 30:00
#SBATCH -A nstaff_g

# IOR="$HOME/src/git/ior/install.cori/bin/ior"
IOR="$HOME/src/iopup/src/ior/bin.muller/ior"

SEGMENTS=256

srun $IOR -t 1m -b 1m -s $SEGMENTS 2>&1 | tee tutorial.1
srun $IOR -t 1m -b 1m -s $SEGMENTS -F 2>&1 | tee tutorial.2
srun $IOR -t 1m -b 1m -s $SEGMENTS -F -C 2>&1 | tee tutorial.3
srun $IOR -t 1m -b 1m -s $SEGMENTS -F -C -e 2>&1 | tee tutorial.4

srun $IOR -t 1m -b 1m -s $SEGMENTS -F -e --posix.odirect 2>&1 | tee tutorial.5

srun $IOR -t 1m -b 1m -s $SEGMENTS -C -e 2>&1 | tee tutorial.6

lfs setstripe -c 4 .
srun $IOR -t 1m -b 1m -s $SEGMENTS -C -e 2>&1 | tee tutorial.7
