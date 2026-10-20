#!/usr/bin/env bash
set -euo pipefail
python -m scripts.train data.seed=${1:-0} logging.run_dir="runs/local_${1:-0}"

