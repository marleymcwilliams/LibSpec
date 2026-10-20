#!/usr/bin/env bash
#SBATCH -J jsg-train
#SBATCH -p {{partition}}
#SBATCH --cpus-per-task={{cpus}}
#SBATCH --gpus-per-task={{gpus}}
#SBATCH --mem={{mem}}G
#SBATCH --time={{time}}
#SBATCH --requeue
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH --array=0-15

set -euo pipefail
module purge || true
module load cuda/12.2 || true

source ~/.bashrc
conda activate jsg

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

python -m scripts.train \
  data.seed=${SLURM_ARRAY_TASK_ID} \
  logging.run_dir="runs/${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}"

