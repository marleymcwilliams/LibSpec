"""
Governance triggers T1–T3:
- T1 Statistical over-coupling: if kappa_fim_norm > B_saf → raise
- T2 Energetic risk: if pr_margin_eps < eps_min → rollback
- T3 Drift pressure: if dro_eta_star persistently high → expand rho_t
"""
from __future__ import annotations
import os, time, mlflow

B_SAF = float(os.getenv("JSG_BSAF", "2.0"))
EPS_MIN = float(os.getenv("JSG_EPS_MIN", "0.05"))
ETA_HIGH = float(os.getenv("JSG_ETA_HIGH", "5.0"))
WINDOW = int(os.getenv("JSG_TRIGGER_WINDOW", "5"))

def read_metric(name: str, n: int = WINDOW):
    client = mlflow.tracking.MlflowClient()
    run_id = mlflow.active_run().info.run_id if mlflow.active_run() else None
    if not run_id: return []
    hist = client.get_metric_history(run_id, name)
    return [m.value for m in hist[-n:]]

def main(poll_seconds: int = 30):
    while True:
        kappa = read_metric("kappa_fim_norm")
        pr = read_metric("pr_margin_eps")
        eta = read_metric("dro_eta_star")
        if kappa and max(kappa) > B_SAF:
            print("[T1] Over-coupling detected → suggest increasing Hopf penalty / reducing gains.")
        if pr and min(pr) < EPS_MIN:
            print("[T2] PR margin low → revert gains to last safe checkpoint.")
        if eta and all(v > ETA_HIGH for v in eta):
            print("[T3] Sustained drift → increase ρ_t.")
        time.sleep(poll_seconds)

if __name__ == "__main__":
    main()

