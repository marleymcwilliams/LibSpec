"""Reading lists for the challenges of Phase 8's step 4 (guide/ROADMAP.md): route B of the
reviewer's scope plan of 2026-11-14, which Marley approved on 2026-11-18.

usage: python3 pilot/reading_list.py LEAN_DIR DATA MANIFEST > pilot/data/reading-lists.json
       python3 pilot/reading_list.py --report pilot/data/reading-lists.json \\
           > pilot/reports/reading-lists.md

LEAN_DIR and DATA are as in pilot/imports.py: the release's lean/ directory at the pinned
commit, checked out as files only, and the collector's output (pilot/data/catalogue.json). The
checkout is imports.py's, with the release's package manifest added:

    git init -q math && cd math
    git sparse-checkout set --no-cone '/lean/**/*.lean' '/lean/lake-manifest.json'
    git fetch --depth 1 --filter=blob:none https://github.com/openai/math COMMIT
    git checkout -q FETCH_HEAD

MANIFEST is LibSpec's own lean/lake-manifest.json, which lists Mathlib and the packages it
requires.

For each challenge, it starts at the challenge file, ComparatorChallenges.<Name>, and follows
that file's imports alone, not its solution's, within the release, at any depth. Each file it
reaches gets its depth, the fewest imports from the challenge file, which is depth 0, and what
it declares, found by pattern in its text. The modules it imports from outside the release are
sorted by their root: Lean's own, Mathlib's (a package in MANIFEST, ignoring case), or another
package, named with its URL and rev from the release's lean/lake-manifest.json. It reads the
release's files as text, with imports.py's header_imports and regular expressions, and never
runs, imports or builds anything from the release.

The list is where a reviewer starts, never a check. Text can't see instances found by type-class
search, notation, macros or opened names, and it can't tell which of a file's declarations a
statement really uses. Nothing reads the list: not the collector, not lean/JSG/Pilot/, not the
gate. Route A, the exact list from Comparator's export, comes later.

The second form renders the report from the JSON. If the report would pass 1 MB, it lists the
files past depth 2 by name only, and the JSON keeps every file's declarations.
"""
import html
import json
import os
import re
import sys
from collections import deque

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from imports import COMMIT, header_imports  # noqa: E402

REPOSITORY = "https://github.com/openai/math"
# Phase 8's step 4 in guide/ROADMAP.md: the challenges of the seven manuscripts the review
# protocol is piloted on.
CHALLENGES = ["Catalan", "JointDickman", "DeligneDrinfeld", "BogomolovPopInjectivity",
              "SubexponentialSAT", "LocalSmoothing", "BallPacking", "BallPackingNecessity"]
LEAN_ROOTS = ("Init", "Std", "Lean", "Lake")
REPORT_LIMIT = 1_000_000  # bytes
FULL_DEPTH = 2  # past REPORT_LIMIT, files deeper than this are listed by name only
JSON_PATH = "pilot/data/reading-lists.json"

DEFINITIONS = ("def", "abbrev", "opaque", "irreducible_def")
TYPES = ("structure", "class", "inductive")
NOTATION = ("notation", "notation3", "infix", "infixl", "infixr", "prefix", "postfix",
            "macro", "macro_rules", "syntax", "elab", "elab_rules")
COUNTED = ("theorem", "lemma")
SCOPES = ("namespace", "section", "end", "mutual")
GROUPS = [("Definitions", "definition", "definitions", DEFINITIONS),
          ("Types", "type", "types", TYPES),
          ("Instances", "instance", "instances", ("instance",)),
          ("Notation and macros", "notation or macro", "notations and macros", NOTATION)]

KEYWORD = re.compile(r"(%s)(?![\w'!?.])" % "|".join(sorted(
    DEFINITIONS + TYPES + NOTATION + COUNTED + SCOPES + ("instance", "axiom"),
    key=len, reverse=True)))
MODIFIER = re.compile(r"(?:private|protected|noncomputable|partial|unsafe|nonrec|public|meta"
                      r"|scoped|local)(?:\[[^\]]*\])?\s+")
PREFIX_IN = re.compile(r"(?:open|set_option)\s.*?\sin\s+")  # `open X in`, before a declaration
NAME = r"(?:«[^»]*»|[^\s:(\[{⦃«,])+"
NAME_AT = re.compile(r"\s*(" + NAME + ")")
INSTANCE_NAME = re.compile(r"\s*(?:\(\s*priority\s*:=[^)]*\)\s*)?(" + NAME + ")?")
NAMED = re.compile(r"\(\s*name\s*:=\s*(" + NAME + r")\s*\)")
CLASS_KIND = re.compile(r"\s+(?:inductive|abbrev)(?=\s)")
COMMENT_OR_STRING = re.compile(r"--|/-|\"|'\\?\"'")
BLOCK = re.compile(r"/-|-/")
STRING_END = re.compile(r'\\.|"', re.S)


def code_only(text):
    """The text with its comments, block comments and doc comments taken out, and its line
    breaks kept, so that line numbers stay. Block comments nest, as in Lean."""
    out, i, n = [], 0, len(text)
    while i < n:
        m = COMMENT_OR_STRING.search(text, i)
        if not m:
            out.append(text[i:])
            break
        out.append(text[i:m.start()])
        tok, k = m.group(), m.end()
        if tok == "--":
            k = text.find("\n", k)
            k = n if k < 0 else k
            out.append(" ")
        elif tok == "/-":
            depth = 1
            while depth:
                b = BLOCK.search(text, k)
                if not b:
                    k = n
                    break
                depth += 1 if b.group() == "/-" else -1
                k = b.end()
            out.append(" " + "\n" * text.count("\n", m.start(), k))
        elif tok == '"':
            while True:
                s = STRING_END.search(text, k)
                if not s:
                    k = n
                    break
                k = s.end()
                if s.group() == '"':
                    break
            out.append(text[m.start():k])
        else:  # the character literal '"' or '\"', which mustn't open a string
            out.append(tok)
        i = k
    return "".join(out)


def close_bracket(s, depth):
    """What follows the `]` that brings depth to 0, or ("", depth) if this line doesn't."""
    i, n = 0, len(s)
    while i < n:
        c = s[i]
        if c == '"':
            m = STRING_END.search(s, i + 1)
            while m and m.group() != '"':
                m = STRING_END.search(s, m.end())
            i = m.end() if m else n
            continue
        depth += {"[": 1, "]": -1}.get(c, 0)
        i += 1
        if not depth:
            return s[i:].strip(), 0
    return "", depth


def strip_prefix(s):
    """A line with its attributes, modifiers and any `open … in` taken off the front. Returns
    the rest, the depth of an attribute that goes on to the next line, and the modifiers."""
    mods = []
    while True:
        if s.startswith("@["):
            s, depth = close_bracket(s[2:], 1)
            if depth:
                return "", depth, mods
            continue
        m = MODIFIER.match(s)
        if m:
            mods.append(s[:m.end()].strip())
            s = s[m.end():]
            continue
        m = PREFIX_IN.match(s)
        if m:
            s = s[m.end():]
            continue
        return s, 0, mods


def qualify(namespace, name):
    """A declared name, given in full as far as the text shows: with its namespaces, unless it
    starts at _root_."""
    if not name:
        return None
    name = name.rstrip(".")  # `def f.{u}` names f
    if name.startswith("_root_."):
        return name[len("_root_."):]
    return ".".join(namespace + [name])


def brief(s, width=160):
    s = " ".join(s.split())
    return s if len(s) <= width else s[:width - 1] + "…"


def declarations(text):
    """What a file's text declares, found by pattern on the lines that start a declaration,
    after any attributes and modifiers. Theorems and lemmas are counted, not listed, and
    axioms are listed apart."""
    found, axioms, counts = [], [], {"theorem": 0, "lemma": 0}
    # One scope per name component, as Lean counts them: `namespace A.B` opens two, and
    # `end A.B` closes two, whether they were opened together or one at a time.
    scopes = []  # (namespace, section or mutual; the component)
    attribute = 0  # the depth of an attribute's brackets that an earlier line left open
    for no, line in enumerate(code_only(text).split("\n"), 1):
        s = line.strip()
        if attribute:
            s, attribute = close_bracket(s, attribute)
            if attribute:
                continue
        s, attribute, mods = strip_prefix(s)
        m = KEYWORD.match(s)
        if attribute or not m:
            continue
        kw, rest = m.group(1), s[m.end():]
        word = rest.split()[0] if rest.split() else ""
        namespace = [part for kind, part in scopes if kind == "namespace"]
        if kw in ("namespace", "section"):
            scopes += [(kw, part) for part in (word.split(".") if word else [""])]
        elif kw == "mutual":
            scopes.append((kw, ""))
        elif kw == "end":
            ended = min(len(word.split(".")) if word else 1, len(scopes))
            del scopes[len(scopes) - ended:]
        elif kw in COUNTED:
            counts[kw] += 1
        elif kw == "instance":
            named = INSTANCE_NAME.match(rest)
            found.append({"kind": kw, "name": qualify(namespace, named.group(1)), "line": no})
        elif kw in NOTATION:
            named = NAMED.search(rest)
            found.append({"kind": kw, "name": qualify(namespace, named and named.group(1)),
                          "line": no, "text": brief(" ".join(mods + [s]))})
        else:
            if kw == "class":
                rest = CLASS_KIND.sub("", rest, count=1)
            named = NAME_AT.match(rest)
            entry = {"kind": kw, "name": qualify(namespace, named and named.group(1)), "line": no}
            (axioms if kw == "axiom" else found).append(entry)
    return {"declarations": found, "axioms": axioms,
            "theorems": counts["theorem"], "lemmas": counts["lemma"]}


def release_modules(lean_dir):
    """The release's own modules, each with its file, named as pilot/imports.py names them."""
    out = {}
    for root, _, files in os.walk(lean_dir):
        for f in files:
            if not f.endswith(".lean"):
                continue
            path = os.path.join(root, f)
            rel = os.path.relpath(path, lean_dir)
            mod = rel[:-5].replace(os.sep, ".")
            if mod.startswith(".lake") or mod == "lakefile":
                continue
            out[mod] = (path, "lean/" + rel.replace(os.sep, "/"))
    return out


def closure(start, imports_of, release):
    """The release's modules that start imports, at any depth, start included, each with its
    depth: the fewest imports from start, which is depth 0."""
    depth, todo = {start: 0}, deque([start])
    while todo:
        x = todo.popleft()
        for i in imports_of(x):
            if i in release and i not in depth:
                depth[i] = depth[x] + 1
                todo.append(i)
    return depth


def build(lean_dir, catalogue, manifest, names=CHALLENGES):
    """The reading lists, as the JSON that the report is rendered from."""
    by_name = {c["name"]: c for c in catalogue["challenges"]}
    missing = [n for n in names if n not in by_name]
    if missing:
        sys.exit(f"reading_list.py: not in the catalogue: {', '.join(missing)}")
    if catalogue["source"]["commit"] != COMMIT:
        sys.exit(f"reading_list.py: the catalogue is for {catalogue['source']['commit']}, "
                 f"not the pin {COMMIT}")
    release = release_modules(lean_dir)
    texts = {}

    def text_of(mod):
        if mod not in texts:
            texts[mod] = open(release[mod][0], encoding="utf-8", errors="replace").read()
        return texts[mod]

    def imports_of(mod):
        return header_imports(text_of(mod))

    release_manifest = os.path.join(lean_dir, "lake-manifest.json")
    have_manifest = os.path.isfile(release_manifest)
    packages = {}
    if have_manifest:
        for p in json.load(open(release_manifest, encoding="utf-8"))["packages"]:
            packages[p["name"].lower()] = p
    mathlib = sorted((p["name"] for p in manifest["packages"]), key=lambda x: (x.lower(), x))
    mathlib_lower = {p.lower() for p in mathlib}

    challenges, files = [], {}
    for name in names:
        start = f"ComparatorChallenges.{name}"
        if start not in release:
            sys.exit(f"reading_list.py: {start} isn't in the checkout")
        depth = closure(start, imports_of, release)
        roots = sorted({i.split(".")[0] for m in depth for i in imports_of(m) if i not in release})
        outside = {"lean": [], "mathlib": [], "other": []}
        for r in roots:
            if r in LEAN_ROOTS:
                outside["lean"].append(r)
            elif r.lower() in mathlib_lower:
                outside["mathlib"].append(r)
            else:
                p = packages.get(r.lower(), {})
                outside["other"].append({"root": r, "package": p.get("name"),
                                         "url": p.get("url"), "rev": p.get("rev")})
        for m in depth:
            if m not in files:
                files[m] = {"path": release[m][1], **declarations(text_of(m))}
        order = sorted(depth, key=lambda m: (depth[m], m))
        challenges.append({
            "name": name, "module": start, "path": release[start][1],
            "manuscripts": sorted(m["title"] for m in catalogue["manuscripts"]
                                  if name in m["challenges"]),
            "fileCount": len(depth),
            "files": [{"module": m, "depth": depth[m]} for m in order],
            "outside": outside,
            "axioms": [{"module": m, "name": a["name"], "line": a["line"]}
                       for m in order for a in files[m]["axioms"]],
        })

    read = "as text: the .lean files under lean/ that these challenge files import, at any depth"
    return {
        "source": {"repository": REPOSITORY, "commit": COMMIT,
                   "license": catalogue["source"]["license"],
                   "read": read + (", and lean/lake-manifest.json" if have_manifest else "")},
        "generatedBy": "pilot/reading_list.py",
        "note": "Where a reviewer starts, never a check: text can't see instances found by "
                "type-class search, notation, macros or opened names, and it can't tell which "
                "of a file's declarations a statement really uses. Nothing reads this list.",
        "leanRoots": sorted(LEAN_ROOTS),
        "mathlibPackages": mathlib,
        "releaseManifest": "lean/lake-manifest.json" if have_manifest else None,
        "challenges": challenges,
        "files": {m: files[m] for m in sorted(files)},
    }


# The report.

def code(s):
    """s as inline code, fenced so that any backtick in it stays inside."""
    run = max((len(r) for r in re.findall(r"`+", s)), default=0)
    pad = " " if s.startswith("`") or s.endswith("`") else ""
    return "`" * (run + 1) + pad + s + pad + "`" * (run + 1)


def code_html(s):
    """s in an HTML code element, with every character Markdown would read as markup
    written as an entity, so that text from the release can't format, link or close it."""
    s = html.escape(s, quote=True)
    for c in "*_[]`|\\~$#!":
        s = s.replace(c, f"&#{ord(c)};")
    return f"<code>{s}</code>"


def plural(n, one, many):
    return f"{n:,} {one if n == 1 else many}"


def blob(path):
    """The file at the pinned commit, on GitHub."""
    return f"{REPOSITORY}/blob/{COMMIT}/{path}"


def counted(f):
    """A file's theorems and lemmas, as a phrase, or "" if it has none."""
    return " and ".join(plural(f[k], one, many) for k, one, many in
                        (("theorems", "theorem", "theorems"), ("lemmas", "lemma", "lemmas"))
                        if f[k])


def counts_phrase(f):
    parts = []
    for _, one, many, kinds in GROUPS:
        n = sum(1 for d in f["declarations"] if d["kind"] in kinds)
        if n:
            parts.append(plural(n, one, many))
    if f["axioms"]:
        parts.append(plural(len(f["axioms"]), "axiom", "axioms"))
    if counted(f):
        parts.append(counted(f))
    return ", ".join(parts) if parts else "nothing found"


def declaration_lines(f):
    """A file's declarations, a bullet per kind."""
    out = []
    for label, _, _, kinds in GROUPS:
        items = []
        for d in f["declarations"]:
            if d["kind"] not in kinds:
                continue
            if d["kind"] in NOTATION:
                items.append(f"line {d['line']}" + (f", {code(d['name'])}" if d["name"] else "")
                             + f": {code_html(d['text'])}")
            elif d["name"] is None:
                items.append(f"{'anonymous ' if d['kind'] == 'instance' else 'unnamed '}"
                             f"{d['kind']} at line {d['line']}")
            elif d["kind"] in ("def", "instance"):
                items.append(code(d["name"]))
            else:
                items.append(f"{code(d['name'])} ({d['kind']})")
        if items:
            out.append(f"- **{label}:** " + ("; " if kinds == NOTATION else ", ").join(items))
    if f["axioms"]:
        out.append("- **Axioms:** " + ", ".join(
            f"{code(a['name'] or 'unnamed')} (line {a['line']})" for a in f["axioms"]))
    if not out:
        out.append("- Nothing found: no definitions, types, instances, notation, macros or "
                   "axioms in its text.")
    if counted(f):
        out.append(f"- **Theorems and lemmas:** {counted(f)}, counted, not listed.")
    return out


def outside_lines(c, have_manifest):
    o = c["outside"]
    if not o["other"]:
        out = ["**Packages outside the checkout that aren't Mathlib's:** none."]
    else:
        named = []
        for p in o["other"]:
            if p["package"]:
                named.append(f"{code(p['root'])}, from the package {code(p['package'])} at "
                             f"{code(p['url'] or 'no URL')}, rev {code(p['rev'] or 'none')}")
            elif have_manifest:
                named.append(f"{code(p['root'])}, which names no package in the release's "
                             f"`lean/lake-manifest.json`")
            else:
                named.append(f"{code(p['root'])}, the package alone, since the release's "
                             f"`lean/lake-manifest.json` wasn't in the checkout")
        out = ["**Packages outside the checkout that aren't Mathlib's:** " + "; ".join(named)
               + ". Their definitions aren't listed here; read them in the package."]
    also = []
    if o["mathlib"]:
        also.append("from Mathlib's packages, " + ", ".join(code(r) for r in o["mathlib"]))
    if o["lean"]:
        also.append("from Lean's own, " + ", ".join(code(r) for r in o["lean"]))
    if also:
        out += ["", "**Also imported, and not listed:** " + "; ".join(also) + "."]
    return out


def report(data, names_only_past=None):
    files, src = data["files"], data["source"]
    have_manifest = data["releaseManifest"] is not None
    out = [
        f"*Generated by `python3 pilot/reading_list.py --report {JSON_PATH}`, from "
        f"[{JSON_PATH}](../data/reading-lists.json). Don't edit it by hand.*",
        "",
        "# Reading lists for Phase 8's challenges",
        "",
        f"openai/math at `{src['commit'][:7]}`, read as text. For each challenge of Phase 8's "
        "step 4 ([ROADMAP.md](../../guide/ROADMAP.md)): its challenge file and the release's "
        "own files that it imports, at any depth, and what each of them declares.",
        "",
        "**It's where a reviewer starts, never a check.** Text can't see instances found by "
        "type-class search, notation, macros or opened names, and it can't tell which of a "
        "file's declarations the statement really uses. So a reviewer still follows names by "
        "eye, and reads any package named below that's outside the checkout "
        "([REVIEW_PROTOCOL.md](../../guide/REVIEW_PROTOCOL.md), \"What to read\").",
        "",
        "**Nothing reads it:** not the collector, not `lean/JSG/Pilot/`, not the gate. It "
        "changes no evidence, and no report the gate produces. Route A, the exact list from "
        "Comparator's export, comes later, on the next trusted run that touches these "
        "challenges.",
        "",
        "**How to read it.** A file's depth is the fewest imports from the challenge file, "
        "which is depth 0. A declaration's name is given in full as far as the text's "
        "`namespace` lines show it. Theorems and lemmas are counted, not listed. Each file "
        "links to the release at the pinned commit.",
    ]
    if names_only_past is not None:
        out += ["", f"**Files past depth {names_only_past} are listed by name only,** so that "
                "this report stays under 1 MB. Their declarations are in "
                f"[{JSON_PATH}](../data/reading-lists.json)."]
    out += ["", "| Challenge | The release's files | Packages outside the checkout, not "
            "Mathlib's | Axioms found |", "|---|---:|---|---:|"]
    for c in data["challenges"]:
        other = ", ".join(code(p["root"]) for p in c["outside"]["other"]) or "none"
        out.append(f"| [{c['name']}](#{c['name'].lower()}) | {c['fileCount']:,} | {other} | "
                   f"{len(c['axioms'])} |")

    for c in data["challenges"]:
        by_depth = {}
        for f in c["files"]:
            by_depth.setdefault(f["depth"], []).append(f["module"])
        label = "Manuscript" if len(c["manuscripts"]) == 1 else "Manuscripts"
        if c["fileCount"] == 1:
            count = ("**The release's files:** 1, the challenge file alone. It imports none of "
                     "the release's other files.")
        else:
            count = (f"**The release's files:** {c['fileCount']:,}, the challenge file included ("
                     + ", ".join(f"{plural(len(ms), 'file', 'files')} at depth {d}"
                                 for d, ms in sorted(by_depth.items())) + ").")
        out += ["", f"## {c['name']}", "",
                f"**{label}:** " + "; ".join(f'"{t}"' for t in c["manuscripts"]) + ".", "",
                count, ""]
        out += outside_lines(c, have_manifest)
        out += [""]
        if c["axioms"]:
            out.append("**Axioms:** " + "; ".join(
                f"{code(a['name'] or 'unnamed')}, in {code(a['module'])} (line {a['line']})"
                for a in c["axioms"]) + ". A statement that rests on one says less than it "
                "seems.")
        else:
            out.append("**Axioms:** none found in these files' text.")
        f0 = files[c["module"]]
        out += ["", "### The challenge file", "",
                f"[{c['path']}]({blob(c['path'])}): {counts_phrase(f0)}.", ""]
        out += declaration_lines(f0)
        for d, mods in sorted(by_depth.items()):
            if d == 0:
                continue
            out += ["", f"### Depth {d}", ""]
            if names_only_past is not None and d > names_only_past:
                out += [f"{plural(len(mods), 'file', 'files')}, by name only:", ""]
                out += [f"- {code(m)}" for m in mods]
                continue
            for m in mods:
                f = files[m]
                out += ["<details>",
                        f"<summary>{code_html(m)}: {html.escape(counts_phrase(f))}</summary>", "",
                        f"[{f['path']}]({blob(f['path'])})", ""]
                out += declaration_lines(f)
                out += ["", "</details>", ""]
            if out[-1] == "":
                out.pop()
    return "\n".join(out) + "\n"


def render(data, limit=REPORT_LIMIT):
    """The report, in full if it stays within limit bytes, else with the files past depth
    FULL_DEPTH by name only."""
    full = report(data)
    if len(full.encode("utf-8")) <= limit:
        return full
    return report(data, names_only_past=FULL_DEPTH)


def main(argv):
    if len(argv) == 3 and argv[1] == "--report":
        out = render(json.load(open(argv[2], encoding="utf-8")))
    elif len(argv) == 4 and not argv[1].startswith("-"):
        lean_dir = os.path.abspath(argv[1])
        if os.name == "nt":
            lean_dir = "\\\\?\\" + lean_dir  # some of the release's paths pass Windows' limit
        catalogue = json.load(open(argv[2], encoding="utf-8"))
        manifest = json.load(open(argv[3], encoding="utf-8"))
        out = json.dumps(build(lean_dir, catalogue, manifest), indent=1, ensure_ascii=False) + "\n"
    else:
        sys.exit(__doc__)
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")
    sys.stdout.write(out)


if __name__ == "__main__":
    main(sys.argv)
