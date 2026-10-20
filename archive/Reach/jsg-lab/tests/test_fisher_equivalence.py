from jsg.stats.fisher import FisherContext


class Cfg:
    class data:
        whitening_policy = "transported"


def test_fisher_snapshot_keys():
    fc = FisherContext(Cfg())
    s = fc.snapshot()
    assert set(["epsilon", "r", "chi", "policy"]) <= set(s.keys())

