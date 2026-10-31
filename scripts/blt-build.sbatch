#!/usr/bin/env bash
# A sample SLURM job for BLT: a plain `lake build` of LibSpec's own Lean, on a compute node.
#SBATCH --job-name=libspec-build
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --output=%x-%j.log
#
# Submit it from LibSpec's root on BLT's login node: `sbatch scripts/blt-build.sbatch`.
# The login node only submits; the build runs on the compute node SLURM picks.
#
# LibSpec's own, trusted code only: never openai/math or any other untrusted code (CLAUDE.md).
#
# --mem is the job's memory on its node, and SLURM stops the job past it. Raise it along with
# --cpus-per-task, since more threads build more modules at once. There's no --time: BLT has no
# time limit for now.
#
# The log, libspec-build-<job id>.log, goes in the directory the job is submitted from, which
# SLURM can always open: it doesn't create directories, and a fresh clone has no lean/.lake/.
# .gitignore ignores it there; keep its pattern in step with --job-name.
set -euo pipefail

[ -n "${SLURM_JOB_ID:-}" ] || { echo "submit this with sbatch; it doesn't run on the login node"; exit 1; }
cd "$SLURM_SUBMIT_DIR"
[ -f lean/lakefile.toml ] || { echo "submit this from LibSpec's root: no lean/lakefile.toml in $PWD"; exit 1; }

# Lean's thread pool takes its size from LEAN_NUM_THREADS, so the build uses the cores the job
# asked for, not every core on the node.
export LEAN_NUM_THREADS="${SLURM_CPUS_PER_TASK:?ask for cores with --cpus-per-task}"
# Lean lives in the home directory on Mayo, where elan installs it.
export PATH="${ELAN_HOME:-$HOME/.elan}/bin:$PATH"
command -v lake > /dev/null || { echo "no lake on PATH: install elan in your home directory on Mayo"; exit 1; }

cd lean
echo "node: $(hostname), cores: $LEAN_NUM_THREADS, memory: ${SLURM_MEM_PER_NODE:-?} MB"
lean --version
# The compute nodes reach the internet, so Mathlib's prebuilt outputs come from its cache.
lake exe cache get
lake build
