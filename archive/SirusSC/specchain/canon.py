"""
canon/v1: UTF-8 JSON, sorted keys, no whitespace, minimal decimals.
Spec: SCp1 A5.4.1; SCp5 N0 (BLAKE3 + proof_surface) and canon/v1 encoding.
"""
from __future__ import annotations

import json
from decimal import Decimal, getcontext
from json import encoder as json_encoder
from typing import Any

getcontext().prec = 50


def _format_number(value: float | int | Decimal) -> str:
    """Return the minimal decimal representation for canon/v1."""
    if isinstance(value, bool):
        raise TypeError("Boolean values must be encoded as true/false before canon")
    if isinstance(value, int):
        return str(value)
    dec = value if isinstance(value, Decimal) else Decimal(str(value))
    if not dec.is_finite():
        raise ValueError("Out of range float values are not JSON compliant")
    if dec == 0:
        return "0"
    dec = dec.normalize()
    text = format(dec, "f")
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    if text == "-0":
        text = "0"
    return text


def _canonical(obj: Any) -> Any:
    if obj is None or isinstance(obj, (str, bool)):
        return obj
    if isinstance(obj, (int, float, Decimal)):
        return obj
    if isinstance(obj, list):
        return [_canonical(v) for v in obj]
    if isinstance(obj, dict):
        return {k: _canonical(obj[k]) for k in sorted(obj.keys())}
    raise TypeError(f"Unsupported type in canon/v1: {type(obj)}")


class CanonEncoder(json.JSONEncoder):
    def __init__(self, *args, **kwargs):
        kwargs.setdefault("ensure_ascii", False)
        kwargs.setdefault("allow_nan", False)
        super().__init__(*args, **kwargs)

    def iterencode(self, o, _one_shot=False):
        markers = {} if self.check_circular else None
        string_encoder = (
            json_encoder.encode_basestring_ascii if self.ensure_ascii else json_encoder.encode_basestring
        )

        def floatstr(value, allow_nan=self.allow_nan):
            if isinstance(value, bool):
                raise TypeError("Boolean encountered in float serializer")
            dec = value if isinstance(value, Decimal) else Decimal(str(value))
            if not dec.is_finite():
                if not allow_nan:
                    raise ValueError("Out of range float values are not JSON compliant")
                return str(value)
            return _format_number(dec)

        _iterencode = json_encoder._make_iterencode(
            markers,
            self.default,
            string_encoder,
            self.indent,
            floatstr,
            self.key_separator,
            self.item_separator,
            self.sort_keys,
            self.skipkeys,
            self.allow_nan,
        )
        return _iterencode(o, 0)


def dumps_canon_v1(obj: Any) -> bytes:
    canonical = _canonical(obj)
    payload = json.dumps(
        canonical,
        cls=CanonEncoder,
        separators=(",", ":"),
        ensure_ascii=False,
    )
    return payload.encode("utf-8")
