from __future__ import annotations
from dataclasses import dataclass
from typing import Callable

@dataclass
class LipschitzFunctor:
    """
    Compositional semantics: ensure transforms do not blow up coupling.
    Given a seminorm ‖·‖, require ‖F(x)-F(y)‖ ≤ L ‖x - y‖.
    """
    map_fn: Callable
    L: float  # certified Lipschitz constant in FIM norm

    def __call__(self, x):
        return self.map_fn(x)

    def compose(self, other: "LipschitzFunctor") -> "LipschitzFunctor":
        return LipschitzFunctor(lambda x: self.map_fn(other.map_fn(x)), L=self.L * other.L)

