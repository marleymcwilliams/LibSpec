#!/usr/bin/env python3
"""
Generate a compact, non-redundant Agent Context pack covering Parts 1 and 2.

Outputs: jsg/AGENT_CONTEXT.md

Content:
 - Shared Tenets (single source of truth)
 - Symbol Registry (parsed from Tenets)
 - Label conventions and cross-ref macros
 - Section maps (label -> title) for Part 1 (*1) and Part 2 (*2)

This is meant to be fed to an agent to maximize rigor while avoiding redundancy.
"""
from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PAPERS = ROOT / "papers"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _parse_braced_args(s: str, start: int, n: int) -> tuple[list[str], int]:
    """Parse n braced arguments from s starting at index start (at '{'). Returns (args, new_index)."""
    args = []
    i = start
    for _ in range(n):
        # skip whitespace
        while i < len(s) and s[i].isspace():
            i += 1
        if i >= len(s) or s[i] != '{':
            return [], i
        i += 1
        depth = 1
        buf = []
        while i < len(s) and depth > 0:
            ch = s[i]
            if ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
                if depth == 0:
                    i += 1
                    break
            buf.append(ch)
            i += 1
        args.append(''.join(buf))
    return args, i


def parse_symbol_registry(tenets_tex: str) -> list[tuple[str, str, str]]:
    rows: list[tuple[str, str, str]] = []
    m = re.search(r"\\begin\{SymbolRegistry\}(.*?)\\end\{SymbolRegistry\}", tenets_tex, re.S)
    if not m:
        return rows
    block = m.group(1)
    i = 0
    while True:
        j = block.find("\\symrow", i)
        if j == -1:
            break
        k = j + len("\\symrow")
        args, k2 = _parse_braced_args(block, k, 3)
        if len(args) == 3:
            code, symbols, meaning = args
            # Cleanup: remove constlabel macros and squash spaces/newlines
            symbols = re.sub(r"\\constlabel\{[^}]*\}", "", symbols)
            meaning = re.sub(r"\\constlabel\{[^}]*\}", "", meaning)
            rows.append((code.strip(), " ".join(symbols.split()), " ".join(meaning.split())))
            i = k2
        else:
            i = k + 1
    return rows


def parse_sections(part_dir: Path, suffix: str) -> list[tuple[str, str]]:
    sections_dir = part_dir / "sections"
    items: list[tuple[str, str]] = []
    if not sections_dir.exists():
        return items
    for p in sorted(sections_dir.glob("*.tex")):
        text = read(p)
        m = re.search(r"^\\section\{([^}]*)\}\\label\{([^}]*)\}", text, re.M)
        if m:
            title = m.group(1).strip()
            label = m.group(2).strip()
            if label.endswith(suffix):
                items.append((label, title))
    return items


def parse_constsym_map() -> dict[str, str]:
    """Parse constsym* definitions to map keys -> LaTeX symbol bodies.
    Prefer macros.tex over jsg_common fallbacks.
    """
    paths = [
        PAPERS / "common" / "macros.tex",
        PAPERS / "common" / "jsg_common.tex",
    ]
    m: dict[str, str] = {}
    for p in paths:
        if not p.exists():
            continue
        text = read(p)
        for key, body in re.findall(r"\\(?:new|provide)command\{\\constsym([A-Za-z]+)\}\{([^}]*)\}", text):
            m[key] = body
    return m


def _strip_const_bs(s: str) -> str:
    s = s.strip()
    return s[1:] if s.startswith("\\") else s


def main() -> int:
    tenets = read(PAPERS / "common" / "tenets.tex")
    symrows = parse_symbol_registry(tenets)
    part1 = PAPERS / "part1"
    part2 = PAPERS / "part2"
    sec1 = parse_sections(part1, "1")
    sec2 = parse_sections(part2, "2")

    out = []
    out.append("# JSG Agent Context Pack\n")
    out.append("This pack composes the minimal shared context needed by an agent to reason across Parts 1 and 2 without duplication.\n")

    out.append("\n## Shared Tenets (single source)\n")
    out.append("The following are included once and apply to all parts.\n")
    # Inline the H1--H6 block from Tenets for quick reference
    m = re.search(r"\\begin\{standbox\}\[Standing Hypotheses.*?\](.*?)\\end\{standbox\}", tenets, re.S)
    if m:
        tenets_block = m.group(1)
        constmap = parse_constsym_map()
        # Replace \constref{key} with its symbol body and strip \constlabel{...}
        def _repl_constref(match: re.Match) -> str:
            raw = match.group(1)
            key = _strip_const_bs(raw)
            return constmap.get(key, key)
        tenets_block = re.sub(r"\\constref\{([^}]*)\}", _repl_constref, tenets_block)
        tenets_block = re.sub(r"\\constlabel\{[^}]*\}", "", tenets_block)
        # Strip leading TeX markup for basic readability (keep semantics)
        tenets_md = re.sub(r"^\\begin\{enumerate}.*$", "", tenets_block, flags=re.M)
        tenets_md = re.sub(r"^\\end\{enumerate}.*$", "", tenets_md, flags=re.M)
        tenets_md = tenets_md.replace("\\item", "-")
        out.append(tenets_md.strip() + "\n")
    else:
        out.append("(Tenets block could not be parsed; see papers/common/tenets.tex)\n")

    out.append("\n## Symbol Registry (Standing Constants)\n")
    if symrows:
        out.append("Code | Symbols | Meaning\n")
        out.append("--- | --- | ---\n")
        for code, symbols, meaning in symrows:
            out.append(f"{code} | {symbols} | {meaning}\n")
    else:
        out.append("(Symbol registry not parsed; see papers/common/tenets.tex)\n")

    out.append("\n## Label Conventions\n")
    out.append("- Part 1 labels: `*1` suffix (e.g., `sec:calc1`)\n")
    out.append("- Part 2 labels: `*2` suffix (e.g., `sec:calc2`)\n")
    out.append("- Cross-part references: use `\\xref{sec:...}` to keep PDFs portable\n")

    out.append("\n## Sections (Part 1)\n")
    for label, title in sec1:
        out.append(f"- `{label}`: {title}\n")

    out.append("\n## Sections (Part 2)\n")
    for label, title in sec2:
        out.append(f"- `{label}`: {title}\n")

    out_path = ROOT / "AGENT_CONTEXT.md"
    out_path.write_text("".join(out), encoding="utf-8")
    print(f"Wrote {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
