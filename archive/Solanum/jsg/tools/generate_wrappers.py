#!/usr/bin/env python3
"""
Generate A/B TeX wrappers for a part from a JSON manifest.

Usage:
  python -m tools.generate_wrappers --part part1

Manifest schema (jsg/papers/<part>/manifest.json):
{
  "roman": "I",
  "title": "JSG Part I",
  "author": "JSG Authors",
  "wrappers": {
    "A": {"title_suffix": "(A)", "include": ["calc1", ...]},
    "B": {"title_suffix": "(B)", "include": ["control1", ...]}
  }
}
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import os
from string import Template


TEMPLATE = Template(r"""\documentclass[11pt]{article}
\usepackage[margin=1in]{geometry}
\input{../common/jsg_common.tex}
\input{../common/macros.tex}
\input{../common/xref.tex}
\addbibresource{../common/refs.bib}

\title{$title $suffix}
\author{$author}
\date{\today}

\begin{document}
\maketitle

% Wrapper identifier for conditional text in modules
\newcommand{\JSGWrap}{$wrap}

% Shared tenets and registries (un-numbered)
\input{../common/tenets.tex}

% Sections (generated from manifest)
$sections

\nocite{*}
\printbibliography
\end{document}
""")


def render_wrapper(title: str, author: str, suffix: str, wrapper_key: str, includes: list[str]) -> str:
    def to_input(name: str) -> str:
        if ("/" in name) or ("\\" in name) or name.endswith(".tex"):
            path = name
        else:
            path = f"sections/{name}.tex"
        return f"\\input{{{path}}}"
    sections = "\n".join(to_input(name) for name in includes)
    # Provide wrapper key to TeX as a simple token (A/B)
    tex = TEMPLATE.substitute(title=title, author=author, suffix=suffix, sections=sections, wrap=wrapper_key)
    return tex


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--part", default="part1", help="papers/<part> directory (e.g., part1, part2, part3)")
    ap.add_argument("--include", help="Comma-separated module names to compose a custom wrapper within a single part (e.g., calc1,entropy1)")
    ap.add_argument("--compose", help="Comma-separated cross-part modules (e.g., part1:calc1,part2:ctrl2)")
    ap.add_argument("--title", help="Custom title for composed wrapper")
    ap.add_argument("--out", help="Output TeX filename for composed wrapper")
    args = ap.parse_args()

    papers_root = Path(__file__).resolve().parents[1] / "papers"
    part_dir = papers_root / args.part

    # Cross-part composition: no manifest required
    if args.compose:
        specs = [s.strip() for s in args.compose.split(',') if s.strip()]
        includes: list[str] = []
        for spec in specs:
            if ':' in spec:
                part_name, mod = spec.split(':', 1)
            else:
                part_name, mod = args.part, spec
            src = papers_root / part_name / 'sections' / f"{mod}.tex"
            if not src.exists():
                print(f"Missing module: {src}")
                return 2
            includes.append(str(src))
        # Determine output path
        out_path = Path(args.out) if args.out else (papers_root / 'composed' / 'JSG_COMPOSED.tex')
        out_path.parent.mkdir(parents=True, exist_ok=True)
        # Compute relative include paths from output location (TeX prefers / separators)
        rel_includes = []
        for abspath in includes:
            rel = os.path.relpath(Path(abspath).resolve(), out_path.parent.resolve())
            rel_includes.append(rel.replace('\\', '/'))
        custom_title = args.title or "JSG Composed"
        tex = render_wrapper(custom_title, "JSG Authors", "(Composed)", "C", rel_includes)
        out_path.write_text(tex, encoding="utf-8")
        print(f"Wrote {out_path}")
        return 0

    # Manifest-driven generation (per-part)
    manifest_path = part_dir / "manifest.json"
    if not manifest_path.exists():
        print(f"Manifest not found: {manifest_path}")
        return 1
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

    roman = manifest.get("roman", "I")
    title = manifest.get("title", f"JSG Part {roman}")
    author = manifest.get("author", "JSG Authors")
    wrappers = manifest.get("wrappers", {})

    # If --include is provided, generate a custom wrapper and exit
    if args.include:
        includes = [s.strip() for s in args.include.split(',') if s.strip()]
        custom_title = args.title or f"{title} (Custom)"
        out_path = Path(args.out) if args.out else part_dir / f"JSG_{roman}_CUSTOM.tex"
        tex = render_wrapper(custom_title, author, "(Custom)", "C", includes)
        out_path.write_text(tex, encoding="utf-8")
        print(f"Wrote {out_path}")
        return 0

    for key, cfg in wrappers.items():
        suffix = cfg.get("title_suffix", f"({key})")
        includes = cfg.get("include", [])
        tex = render_wrapper(title, author, suffix, key, includes)
        out = part_dir / f"JSG_{roman}_{key}.tex"
        out.write_text(tex, encoding="utf-8")
        print(f"Wrote {out}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
