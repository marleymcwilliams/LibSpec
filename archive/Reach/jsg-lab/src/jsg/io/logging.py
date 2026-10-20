from __future__ import annotations
import os, json, time
from typing import Any, Dict, Optional
import mlflow


def _flatten(prefix: str, obj: Any, out: Dict[str, float]) -> None:
    """Collect scalar numbers from nested dicts/lists into flat metric names.
    Uses underscore to join keys, e.g., frontier_n_cross.
    """
    if isinstance(obj, dict):
        for k, v in obj.items():
            key = f"{prefix}_{k}" if prefix else str(k)
            _flatten(key, v, out)
    elif isinstance(obj, (list, tuple)):
        # export indexed scalars only
        for i, v in enumerate(obj):
            key = f"{prefix}_{i}" if prefix else str(i)
            _flatten(key, v, out)
    else:
        if isinstance(obj, (int, float)):
            out[prefix] = float(obj)


class RunLogger:
    def __init__(self, cfg, run_dir: str):
        self.cfg = cfg
        self.run_dir = run_dir
        os.makedirs(run_dir, exist_ok=True)
        self.path = os.path.join(run_dir, cfg.logging.jsonl_name)
        self._fh = open(self.path, "a", buffering=1)

        self._mlf = None
        if cfg.logging.mlflow.enabled:
            mlflow.set_tracking_uri(cfg.logging.mlflow.tracking_uri)
            self._mlf = mlflow.start_run(run_name=os.path.basename(run_dir))
            mlflow.log_params({k: v for k, v in cfg.items() if not isinstance(v, dict)})

    def write_header(self, header: Dict[str, Any]) -> None:
        self._fh.write(json.dumps({"type": "header", "ts": time.time(), "theory": header}) + "\n")

    def window(self, payload: Dict[str, Any]) -> None:
        payload = {"type": "window", "ts": time.time(), **payload}
        self._fh.write(json.dumps(payload) + "\n")
        if self._mlf:
            flat: Dict[str, float] = {}
            _flatten("", payload, flat)
            for k, v in flat.items():
                try:
                    mlflow.log_metric(k, v)
                except Exception:
                    # ignore metric names that MLflow refuses
                    pass

    def event(self, payload: Dict[str, Any]) -> None:
        self._fh.write(json.dumps({"type": "event", "ts": time.time(), **payload}) + "\n")

    def close(self) -> None:
        self._fh.close()
        if self._mlf:
            mlflow.end_run()
