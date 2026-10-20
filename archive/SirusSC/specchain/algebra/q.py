"""
Acceptance algebra Q with per-axis identities and absorbing bottoms.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Tuple

NEG_INF = float("-inf")


@dataclass(frozen=True)
class Axes:
    S: Tuple[str, ...]
    M: Tuple[str, ...]

    def all(self) -> Tuple[str, ...]:
        return self.S + self.M


@dataclass
class Q:
    axes: Axes
    q: Dict[str, float | str]

    BOTTOM = "\u22a5"

    @classmethod
    def zero(cls, axes: Axes) -> "Q":
        values: Dict[str, float | str] = {
            **{i: 0.0 for i in axes.S},
            **{j: NEG_INF for j in axes.M},
        }
        return cls(axes, values)

    def copy(self) -> "Q":
        return Q(self.axes, dict(self.q))

    def is_bottom(self, axis: str) -> bool:
        return self.q.get(axis) == self.BOTTOM

    def hetero_join(self, other: "Q") -> "Q":
        """Combine horizontally: sum S axes, take max on M axes; bottom absorbs."""
        assert self.axes == other.axes
        out: Dict[str, float | str] = {}
        for axis in self.axes.S:
            if self.is_bottom(axis) or other.is_bottom(axis):
                out[axis] = self.BOTTOM
            else:
                out[axis] = float(self.q.get(axis, 0.0)) + float(other.q.get(axis, 0.0))
        for axis in self.axes.M:
            if self.is_bottom(axis) or other.is_bottom(axis):
                out[axis] = self.BOTTOM
            else:
                out[axis] = max(
                    float(self.q.get(axis, NEG_INF)),
                    float(other.q.get(axis, NEG_INF)),
                )
        return Q(self.axes, out)

    def sequential(self, other: "Q") -> "Q":
        """Combine vertically: sum on both axis families; bottom absorbs."""
        assert self.axes == other.axes
        out: Dict[str, float | str] = {}
        for axis in self.axes.all():
            if self.is_bottom(axis) or other.is_bottom(axis):
                out[axis] = self.BOTTOM
                continue
            a = self.q.get(axis)
            b = other.q.get(axis)
            if axis in self.axes.M:
                a_val = NEG_INF if a is None else float(a)
                b_val = NEG_INF if b is None else float(b)
                if a_val == NEG_INF and b_val == NEG_INF:
                    out[axis] = NEG_INF
                elif a_val == NEG_INF:
                    out[axis] = b_val
                elif b_val == NEG_INF:
                    out[axis] = a_val
                else:
                    out[axis] = a_val + b_val
            else:
                out[axis] = float(a if a is not None else 0.0) + float(b if b is not None else 0.0)
        return Q(self.axes, out)

    def leq(self, other: "Q") -> bool:
        """Axis-wise comparison with bottom absorbing (bottom <= x)."""
        assert self.axes == other.axes
        for axis in self.axes.all():
            a = self.q[axis]
            b = other.q[axis]
            if a == self.BOTTOM:
                continue
            if b == self.BOTTOM:
                return False
            if float(a) > float(b):
                return False
        return True
