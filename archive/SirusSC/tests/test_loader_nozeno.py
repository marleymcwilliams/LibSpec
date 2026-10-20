import pytest

try:
    import blake3  # type: ignore
except ImportError:  # pragma: no cover
    blake3 = None

from specchain.loader.loader import (
    LoaderConfig,
    LoaderState,
    guard_CBF,
    guard_DRO,
    guard_EF,
    guard_OMEGA,
    guard_PR,
    run_pipeline,
)
from specchain.algebra.q import Q, Axes

pytestmark = pytest.mark.skipif(blake3 is None, reason="requires blake3 for hashing")


def test_no_zeno_window():
    axes = Axes(("energy",), ("risk",))
    state = LoaderState(q=Q.zero(axes), dwell=3)
    cfg = LoaderConfig(Tmax=3, delta_quantum=0.1)
    run_pipeline([guard_EF, guard_DRO, guard_PR, guard_CBF, guard_OMEGA], [{}, {}, {}, {}, {}], state, cfg)
    assert any(r.get("predicate_id") == "NO_ZENO_WINDOW" for r in state.receipts)
