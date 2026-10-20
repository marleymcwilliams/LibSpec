import pathlib

MAPPINGS = {
    "â€œ": "``",
    "â€": "''",  # sometimes appears split; blanket handled below
    "â€": "''",
    "â€": "''",
    "â€": "''",
    "â€˜": "`",
    "â€™": "'",
    "â€“": "--",
    "â€”": "---",
    # UTF-8 mojibake for common accented letters
    "Ã¶": "\\\"o",  # o-umlaut
    "Ã¤": "\\\"a",  # a-umlaut
    "Ã¼": "\\\"u",  # u-umlaut
    "Ã–": "\\\"O",  # O-umlaut
    "Ã„": "\\\"A",  # A-umlaut
    "Ãœ": "\\\"U",  # U-umlaut
    "ÃŸ": "\\ss{}", # ß
    "Ã©": "\\'e",  # é
    "Ã¨": "\\`e",  # è
    "Ã¡": "\\'a",  # á
    "Ã­": "\\'i",  # í
    "Ã³": "\\'o",  # ó
    "Ãº": "\\'u",  # ú
    "Ã±": "\\~n",  # ñ
    "Ã´": "o",      # Itô -> Ito (safe in code/comments)
    "Â§": "Section~",  # broken section sign
    # Relational operators mojibake
    "â‰¥": ">=",
    "â‰¤": "<=",
    "â‰»": ">>",
    "â‰ˆ": "\\approx",
    "â‰¼": "<=",
    # Greek letters mojibake
    "Îµ": "epsilon",
    "Î·": "eta",
    "Î±": "alpha",
    "Î´": "delta",
    "Î ": "\\Pi",
    # Odd broken sequence seen in comments
    "A��?�A�": "<=",
    "âˆƒ": "exists",
    "Â°": " deg",
    "âŠ—": "otimes",
    "âŠ-": "otimes",
    "âŠ™": "\\odot",
    "âŠ�": "\\odot",
    "âŠŽ": "\\uplus",
    "Â·": " * ",
    "â†’": "->",
    "â†": "->",
}

def sanitize_text(s: str) -> str:
    # Apply string mappings
    for k, v in MAPPINGS.items():
        s = s.replace(k, v)
    # Replace stray cp1252 right double quotes pattern variants
    s = s.replace("\u201c", "``").replace("\u201d", "''")
    s = s.replace("\u2018", "`").replace("\u2019", "'")
    s = s.replace("\u2013", "--").replace("\u2014", "---")
    # Remove control chars except \t, \n, \r
    s = ''.join(ch for ch in s if (ord(ch) in (9, 10, 13)) or ord(ch) >= 32)
    # Remove U+009D explicitly if any slipped through
    s = s.replace("\u009d", "")
    # Fix escaped star sequences incorrectly written as \*
    s = s.replace("\\*", "*")
    # Specific known phrases
    s = s.replace("freeze on crossing, reproject after'' rule",
                  "``freeze on crossing, reproject after'' rule")
    s = s.replace("SchoutenNijenhuis", "Schouten--Nijenhuis")
    return s

def main():
    base = pathlib.Path(__file__).resolve().parents[1] / 'papers' / 'part1' / 'sections'
    for tex in base.glob('*.tex'):
        txt = tex.read_text(encoding='utf-8', errors='ignore')
        new = sanitize_text(txt)
        if new != txt:
            tex.write_text(new, encoding='utf-8')
            print(f"sanitized {tex}")
        else:
            print(f"ok {tex}")

if __name__ == '__main__':
    main()
