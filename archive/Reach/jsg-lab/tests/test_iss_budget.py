from jsg.iss.budget import ISSBudget


class Cfg:  # minimal shim
    class calculus:
        C0 = 0.25


def test_iss_budget_log():
    iss = ISSBudget(Cfg)
    out = iss.log_window(0, margin=0.1, gaps={}, n_cross=0, tau_min=10)
    assert "t_over_tau_min" in out

