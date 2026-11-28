"""
Uncertainty-aware lift Q′: placeholder carriers (intervals) with absorbing ⊥.
Spec: SCp2 §4 (carriers, guards, receipts).
"""
from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Tuple, Optional

@dataclass
class Interval:
    lo: float
    hi: float
    BOT = None  # sentinel for ⊥

    def is_bottom(self) -> bool:
        return self.lo is None or self.hi is None

    @staticmethod
    def bottom():
        return Interval(Interval.BOT, Interval.BOT)

    def plus(self, other: "Interval") -> "Interval":
        if self.is_bottom() or other.is_bottom():
            return Interval.bottom()
        return Interval(self.lo + other.lo, self.hi + other.hi)

    def join(self, other: "Interval") -> "Interval":
        if self.is_bottom() or other.is_bottom():
            return Interval.bottom()
        return Interval(max(self.lo, other.lo), max(self.hi, other.hi))

@dataclass
class QPrime:
    intervals: Dict[str, Interval]

    def guard_no_bottom(self) -> bool:
        return all(not iv.is_bottom() for iv in self.intervals.values())
