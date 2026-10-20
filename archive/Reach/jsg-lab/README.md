# jsg-lab

A cluster-ready lab implementing **Joint Strategic Geometry** with JAX, Hydra, SLURM, DVC, Snakemake, and MLflow.

## Quickstart

```bash
mamba env create -f env/environment.yml
conda activate jsg
pre-commit install
dvc init
```

### Local run

```bash
python -m scripts.prepare_data
python -m scripts.train
python -m scripts.eval
```

### SLURM

```bash
sbatch --array=0-15 scripts/jobs/train.slurm
```

### Reproducibility

* Environments: `env/environment.yml` (+ `conda-lock.yml`)
* Data & artifacts: DVC (`dvc.yaml`)
* Workflow: Snakemake (`Snakefile`)
* Experiment tracking: MLflow via `jsg.io.logging.RunLogger`

### Governance Triggers
Run a lightweight monitor that watches MLflow and prints recommended actions:
```bash
export MLFLOW_TRACKING_URI="file:./mlruns"
python -m scripts.triggers
```

### Multiprocessing Utility (example integration)

Hydra-driven, env-safe bulk updater:

```bash
export JSG_API_KEY="***"
python -m tools.mproc_portfolio_updater base_url="https://..." csv_path="data/ebooks.csv" nproc=8
```

### Job Research Pipeline (JobMemes)

Integrates debate-driven Deep Research, condensed briefs, and cover letters.

- Prereqs: set `GEMINI_API_KEY` in your environment; ensure `google-generativeai` is installed.
- CSVs (created on demand):
  - Listings: `data/jobmemes/listings.csv`
  - Master: `data/jobmemes/master.csv`
  - Junk: `data/jobmemes/junk.csv`
- Prompts live at `assets/prompts.json` (edit to taste).

Flow:
- Step 2 — Score/filter listings into Master/Junk:
  `python -m apps.jobmemes.pipeline.step_02_filter_and_score`
- Step 3 — Research, condense, generate cover letters (no browser required):
  `python -m apps.jobmemes.pipeline.step_03_generate_content`

Outputs: Master CSV with filled columns `Deep Research`, `Condensed Research`, `Cover Letter`. Add `Debate Transcript` to persist transcripts.
