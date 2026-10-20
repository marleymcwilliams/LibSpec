from jsg.dro.soft_transport import DRO


class Cfg:
    pass


def test_dro_snapshot_fields():
    dro = DRO(Cfg())
    snap = dro.snapshot()
    assert set(["eta_star", "rho_t", "drift"]) <= set(snap.keys())

