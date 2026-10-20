from __future__ import annotations
from pydantic import BaseModel


class Constants(BaseModel):
    tau_min: int
    C0: float
    theta_min: float
    kappa_max: float


class Hypotheses(BaseModel):
    H1_smooth_gamma: bool = True
    H2_stratified_G: bool = True
    H3_defect_per_crossing: bool = True


class TheoryRegistry(BaseModel):
    C: Constants
    H: Hypotheses

    @classmethod
    def from_cfg(cls, cfg) -> "TheoryRegistry":
        return cls(
            C=Constants(
                tau_min=cfg.calculus.tau_min,
                C0=cfg.calculus.C0,
                theta_min=cfg.calculus.theta_min,
                kappa_max=cfg.calculus.kappa_max,
            ),
            H=Hypotheses(),
        )

