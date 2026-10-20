from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, List
import jax.numpy as jnp

FrontierHandler = Callable[[], None]

@dataclass
class FrontierState:
    mode: str = "INSIDE_STRATUM"
    t_last_cross: int = 0
    n_cross: int = 0
    t_freeze_start: int = -1
    t: int = 0

@dataclass
class FrontierManager:
    r_tube: float
    tau_min: int
    phi_funcs: List[Callable[[jnp.ndarray], float]]
    on_freeze: List[FrontierHandler] = field(default_factory=list)
    on_unfreeze: List[FrontierHandler] = field(default_factory=list)
    state: FrontierState = field(default_factory=FrontierState)

    def register_freeze_handler(self, h: FrontierHandler) -> None:
        self.on_freeze.append(h)

    def register_unfreeze_handler(self, h: FrontierHandler) -> None:
        self.on_unfreeze.append(h)

    def update(self, x_t: jnp.ndarray, x_prev: jnp.ndarray) -> None:
        self.state.t += 1
        signs_now = jnp.array([jnp.sign(f(x_t)) for f in self.phi_funcs])
        signs_prev = jnp.array([jnp.sign(f(x_prev)) for f in self.phi_funcs])
        tube_flags = jnp.array([jnp.abs(f(x_t)) <= self.r_tube for f in self.phi_funcs])

        entering = bool(jnp.any(tube_flags)) and self.state.mode == "INSIDE_STRATUM"
        crossing = bool(jnp.any(signs_now * signs_prev < 0.0))

        if entering:
            self.state.mode = "ENTERING_TUBE"
            self.state.t_freeze_start = self.state.t
            for h in self.on_freeze: h()

        if crossing:
            self.state.mode = "CROSSING_FRONTIER"
            self.state.n_cross += 1
            self.state.t_last_cross = self.state.t

        if (not bool(jnp.any(tube_flags))) and self.state.mode in {"ENTERING_TUBE","CROSSING_FRONTIER"}:
            self.state.mode = "EXITING_TUBE"
            for h in self.on_unfreeze: h()
            self.state.mode = "INSIDE_STRATUM"

    def dwell_ok(self) -> bool:
        return self.state.n_cross <= max(1, self.state.t // max(1, self.tau_min))

    def freeze_time_ratio(self) -> float:
        if self.state.t_freeze_start < 0: return 0.0
        return (self.state.t - self.state.t_freeze_start) / max(1, self.tau_min)
