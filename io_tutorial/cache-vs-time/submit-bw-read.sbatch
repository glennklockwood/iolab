#!/usr/bin/env bash
#SBATCH -J elbencho
#SBATCH -C gpu
#SBATCH -t 30:00
#SBATCH --qos debug
#SBATCH --gpus-per-task 0
#SBATCH -A nstaff
#SBATCH -N 4
#SBATCH --tasks-per-node 1
#SBATCH --cpus-per-task 64
#SBATCH -A nstaff_g

ELBENCHO="$HOME/src/elbencho-testing/src/elbencho/bin.perlmutter/elbencho"

OUTPUT_DIR="/pscratch/sd/g/glock"

# Build elbencho compatible list of hostnames
HOSTNAMES=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | tr "\n" ",")

# Start service on all nodes
srun $ELBENCHO --service --foreground &

sleep 5

threads=64
output_f="bw-read.$(printf "%02d" $threads)threads.$SLURM_JOBID"
$ELBENCHO --hosts "$HOSTNAMES" \
          --threads $threads \
          --files 1 --size 8g --block 128k \
          --read \
          --dirsharing \
          --resfile ${output_f}.out \
          --csvfile ${output_f}.csv \
          --livecsv ${output_f}.live.csv \
          --liveint 250 \
          --nolive \
          "${OUTPUT_DIR}"

# Quit services
$ELBENCHO --quit --hosts "$HOSTNAMES"
