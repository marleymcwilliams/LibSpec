import pytest
from specchain.digest import b3_json

pytestmark = pytest.mark.skipif(True, reason="blake3 not installed in this environment")

def test_b3_json():
    h = b3_json({"a":1})
    assert isinstance(h, str) and len(h) == 64
