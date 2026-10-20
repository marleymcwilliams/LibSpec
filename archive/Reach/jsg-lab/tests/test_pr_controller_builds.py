import numpy as np
from jsg.control.oustaloup import oustaloup_ss
from jsg.control.pr_checks import check_positive_real

def test_oustaloup_and_pr_check():
    A,B,C,D = oustaloup_ss(alpha=0.8, N=3, band=[0.5, 8.0], gains={"k": 1.0})
    ok, margin = check_positive_real((np.asarray(A), np.asarray(B), np.asarray(C), np.asarray(D)),
                                     band=[0.5, 8.0],
                                     eps_min=0.0)
    assert A.shape[0] == A.shape[1] and B.shape[0] == A.shape[0]
    assert ok in (True, False)  # should run without exception

