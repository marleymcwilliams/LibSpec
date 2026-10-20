from specchain.canon import dumps_canon_v1
def test_canon_basic():
    obj = {"b": 2, "a": 1.0, "c": [3, 2, 1]}
    b = dumps_canon_v1(obj)
    assert b == b'{"a":1,"b":2,"c":[3,2,1]}'
