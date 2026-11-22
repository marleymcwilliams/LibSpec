"""Metamorphic tests of the pilot's collectors, pilot/collect.py and pilot/to_lean.py, which
scripts/check.sh runs. A metric states a score, a confidence or a claim about the work, and no
fact a Raw holds (lean/JSG/Pilot/Core.lean). So adding one, or listing the same facts in another
order, must leave every manuscript's and challenge's record in collect.py's output as it was,
and the Raw to_lean.py writes from them. The output's source block records what was read, so it
may change. The relations:
1. Adding or changing a metric: a confidence line or badge in a README or a docs page, a score
   in a challenge's JSON, another review status in lean/formalization.yaml, and a README's own
   claim to be reviewed, verified or checked for novelty. Each is added where the miniature has
   none, except the review status, which the miniature states and the test changes.
2. Reordering the input: CONTENTS.md's families and the manuscripts in each, a docs page's and
   a withdrawal notice's links, the keys of every JSON file, every directory listing, and the
   order files are fetched in. Nothing either script writes may change.
3. Through to_lean.py: fields added to the collected data, and its manuscripts and challenges
   reordered.
In a README, relation 1 holds in two parts. Where collect.py can read the README with a metric
in it, the metric changes no record: below the heading line, and as a section of its own
anywhere but between a withdrawal notice's heading and its links. Where it can't, collect.py
stops: it exits non-zero, names the README and writes nothing. That's anything above the
heading, such as a confidence line or badge, a blank line, a byte-order mark or an HTML comment;
anything else on the heading line, such as a badge, a link or a link to a PDF beside the README
before the title's link, or a badge after it; and a section of its own between a withdrawal
notice's heading and its links. collect.py's HEADING and readme_facts state the rule.
One relation is narrower than that, since the whole relation fails (#130's "Decisions for me"):
a manuscript's challenges, reordered, give the same Raw only up to their order. The grade reads
them as a set (Raw.formal and Raw.axiomsOk, in Core.lean), though the report's words give their
reasons in that order (whyWords, in Words.lean). collect.py writes them sorted.
The tests run both scripts' main() on a release in miniature, built below, with only the
fetching replaced: GitHub's answers, and, to change the order files are fetched in,
collect.py's prefetch. Nothing is fetched, and nothing from a release runs. Run them with
`python3 -B`, so that importing the scripts leaves no bytecode.
"""
import copy
import hashlib
import importlib
import io
import json
import os
import re
import shutil
import sys
import tempfile
import urllib.error
from types import SimpleNamespace

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "pilot"))
import collect  # noqa: E402
import to_lean  # noqa: E402

failed = False
MISSING = object()


def short(x):
    s = "nothing" if x is MISSING else ascii(x)
    return s if len(s) <= 110 else s[:107] + "..."


def difference(got, want, path=()):
    """Where got first differs from want, in a line."""
    if isinstance(got, dict) and isinstance(want, dict):
        for k in [*want, *(k for k in got if k not in want)]:
            if got.get(k, MISSING) != want.get(k, MISSING):
                return difference(got.get(k, MISSING), want.get(k, MISSING), path + (str(k),))
    elif isinstance(got, list) and isinstance(want, list):
        i = next((i for i, (g, w) in enumerate(zip(got, want)) if g != w), min(len(got), len(want)))
        return difference(got[i] if i < len(got) else MISSING,
                          want[i] if i < len(want) else MISSING, path + (f"[{i}]",))
    elif isinstance(got, str) and isinstance(want, str) and "\n" in got + want:
        g, w = got.split("\n"), want.split("\n")
        i = next(i for i in range(max(len(g), len(w))) if g[i:i + 1] != w[i:i + 1])
        return difference(g[i] if i < len(g) else MISSING, w[i] if i < len(w) else MISSING,
                          path + (f"line {i + 1}",))
    return f"{' > '.join(path) or 'the output'}: expected {short(want)}, got {short(got)}"


def check(label, compute):
    """The relation holds when compute() gives two equal values: what the changed input gives,
    and what the unchanged one does. A stop is a failure too."""
    global failed
    try:
        got, want = compute()
        problem = None if got == want else difference(got, want)
    except (Exception, SystemExit) as e:
        problem = f"stopped: {type(e).__name__}: {short(str(e))}"
    if problem is None:
        print(f"ok: {label}")
    else:
        print(f"FAIL: {label}: {problem}")
        failed = True


def same(xs):
    return list(xs)


def backwards(xs):
    return list(xs)[::-1]


# A release in miniature. Families 001 and 002 have docs pages, and 003 has none. 002's page
# links an earlier version of Delta, so its challenges count for the listed Delta (docsLinks).
# Beta's folder holds parentheses, as one in the release does. Three manuscripts are withdrawn,
# and CONTENTS.md doesn't list them: Kuga's notice links Weil, and Hodge's links both, so a
# notice has two links. Alpha and Delta have earlier versions. The Orphan challenge and a docs
# page's link to a missing folder are unlinked. As at the pin, each README's heading links its
# title to a PDF beside it, and each notice ends with a section that links its own archived PDF.
COMMIT = collect.COMMIT
ALPHA = "Alpha-sums-of-squares-October-7-2026"
ALPHA_EARLIER = "Alpha-sums-of-squares-September-24-2026"
BETA = "Beta-bounds-in-CAT(0)-spaces-September-23-2026"
GAMMA = "Gamma-reconstruction-October-5-2026"
DELTA = "Delta-conjecture-October-6-2026"
DELTA_EARLIER = "Delta-conjecture-September-23-2026"
EPSILON = "Epsilon-is-irrational-September-24-2026"
WEIL = "Weil-classes-on-eightfolds-September-18-2026"
KUGA = "Kuga-Satake-for-K3-surfaces-October-3-2026"
HODGE = "Hodge-for-products-of-K3-surfaces-October-4-2026"
DRAFT = "Zeta-draft-notes-May-5-2026"
TITLES = {ALPHA: "Sums of squares", ALPHA_EARLIER: "Sums of squares",
          BETA: "Bounds in CAT(0) spaces", GAMMA: "Reconstruction from K-theory",
          DELTA: "The Delta conjecture", DELTA_EARLIER: "The Delta conjecture",
          EPSILON: "Epsilon is irrational", WEIL: "Weil classes on eightfolds",
          KUGA: "Kuga-Satake for K3 surfaces", HODGE: "Hodge for products of K3 surfaces"}
FAMILIES = [("001", "Sums and bounds", [ALPHA, BETA]), ("002", "Reconstruction", [GAMMA, DELTA]),
            ("003", "Irrationality", [EPSILON])]
DOCS = {"001": ([ALPHA, BETA, DRAFT], ["AlphaMain", "BetaMain"]),
        "002": ([GAMMA, DELTA_EARLIER], ["GammaMain", "DeltaMain"])}
NOTICES = {WEIL: [], KUGA: [WEIL], HODGE: [WEIL, KUGA]}
THREE = ["propext", "Quot.sound", "Classical.choice"]
CONFIGS = {"AlphaMain": ("OAI.Alpha.Main", ["OAI.Alpha.main"], THREE),
           "BetaMain": ("OAI.Beta.Main", ["OAI.Beta.main", "OAI.Beta.sharp"], THREE),
           "GammaMain": ("OAI.Gamma.Main", ["OAI.Gamma.main"], THREE + ["Lean.ofReduceBool"]),
           "DeltaMain": ("OAI.Delta.Main", ["OAI.Delta.main"], THREE),
           "OrphanMain": ("OAI.Orphan.Main", ["OAI.Orphan.main"], THREE)}
# Our trusted results, as pilot/shard_results.py writes them. Orphan has none.
RESULTS = {"trusted": True, "runs": [{"run": 1, "url": "https://example.org/runs/1"}],
           "results": {"AlphaMain": "accepted", "BetaMain": "outOfMemory",
                       "GammaMain": "accepted", "DeltaMain": "rejected"}}


def release(families=same, within=same, docs=same, notice=same, keys=same, readme=None,
            page=None, config=None, review="unchecked"):
    """The miniature's files by path. families, within, docs, notice and keys each order one kind
    of list; readme and page edit each README and docs page; config adds fields to each
    challenge's JSON; review is lean/formalization.yaml's status."""
    files = {}
    lines = ["# Contents", ""]
    for number, name, folders in families(FAMILIES):
        lines += [f"**{number}. {name}**", ""]
        lines += [f"- [{TITLES[f]}](preprints/{f}/)" for f in within(folders)] + [""]
    files["CONTENTS.md"] = "\n".join(lines)
    files["lean/formalization.yaml"] = f"name: OAI\nreview:\n  status: {review}\n"
    for fam, (folders, names) in DOCS.items():
        links = ", ".join(f"[{TITLES.get(f, 'notes')}](../../preprints/{f}/)"
                          for f in docs(folders))
        rows = [f"| `{c}` | [{c}.lean](../ComparatorChallenges/{c}.lean) |" for c in docs(names)]
        text = (f"# Family {fam}\n\nThis page covers {links}.\n\n## Scope\n\nEach challenge "
                "states its paper's top-line claim.\n\n## Comparator links\n\n"
                "| Challenge | Statement |\n| --- | --- |\n" + "\n".join(rows) + "\n")
        files[f"lean/docs/{fam}.md"] = page(text) if page else text
    for name, (module, theorems, axioms) in CONFIGS.items():
        cfg = {"solution_module": module, "theorem_names": theorems, "permitted_axioms": axioms,
               **(config or {})}
        files[f"lean/ComparatorChallenges/{name}.json"] = json.dumps(dict(keys(cfg.items())),
                                                                     indent=2)
        files[f"lean/ComparatorChallenges/{name}.lean"] = f"theorem {name}_main : True := trivial\n"
    for f, title in TITLES.items():
        if f in NOTICES:
            links = " and ".join(f"[{TITLES[x]}](https://github.com/openai/math/tree/{COMMIT}/"
                                 f"preprints/{x}/)" for x in notice(NOTICES[f]))
            body = ("**Withdrawn on October 6, 2026.** The authors withdraw it" +
                    (f": its proof rests on {links}." if links else "."))
            text = (f"# [Withdrawal notice: {title}](paper.pdf)\n\n{body}\n\n"
                    f"## Archived manuscript\n\n[Pre-withdrawal PDF](https://github.com/openai/"
                    f"math/blob/{COMMIT}/preprints/{f}/paper.pdf)\n")
        else:
            text = f"# [{title}](paper.pdf)\n\nWe prove it.\n\n## Abstract\n\nIn full.\n"
        files[f"preprints/{f}/README.md"] = readme(f, text) if readme else text
    return files


RAW = f"https://raw.githubusercontent.com/openai/math/{COMMIT}/"
TREES = "https://api.github.com/repos/openai/math/git/trees/"


class GitHub:
    """GitHub as collect.py reads it, serving the miniature: each file at the pinned commit, and
    each directory through the tree API. listing orders a directory's entries, and keys orders
    each object's keys. Any other address is refused, so nothing is fetched."""

    def __init__(self, files, listing=same, keys=same):
        self.files, self.listing, self.keys = files, listing, keys
        self.children = {"": set()}
        for path in files:
            parts = path.split("/")
            for i in range(1, len(parts) + 1):
                self.children["/".join(parts[:i - 1])].add("/".join(parts[:i]))
                if i < len(parts):
                    self.children.setdefault("/".join(parts[:i]), set())
        self.sha = {d: hashlib.sha1(d.encode()).hexdigest() for d in self.children}
        self.sha[""] = COMMIT
        self.dir = {sha: d for d, sha in self.sha.items()}

    def tree(self, d):
        entries = []
        for child in sorted(self.children[d]):
            sub = child in self.children
            sha = self.sha[child] if sub else hashlib.sha1(self.files[child].encode()).hexdigest()
            entries.append(dict(self.keys({"path": child.rsplit("/", 1)[-1],
                                           "mode": "040000" if sub else "100644",
                                           "type": "tree" if sub else "blob", "sha": sha}.items())))
        return dict(self.keys({"sha": self.sha[d], "tree": self.listing(entries),
                               "truncated": False}.items()))

    def urlopen(self, url, timeout=None):
        if url.startswith(RAW) and url[len(RAW):] in self.files:
            return io.BytesIO(self.files[url[len(RAW):]].encode())
        if url.startswith(TREES) and url[len(TREES):] in self.dir:
            return io.BytesIO(json.dumps(self.tree(self.dir[url[len(TREES):]])).encode())
        if not url.startswith((RAW, TREES)):
            raise AssertionError(f"the tests fetch nothing, but collect.py asked for {url}")
        raise urllib.error.HTTPError(url, 404, "Not Found", {}, None)


def run(module, argv):
    """A script's main() with these arguments: what it writes, as bytes. It's kept in written
    too, so that what a script wrote before it stopped is known."""
    global written
    out = io.TextIOWrapper(io.BytesIO(), encoding="utf-8", newline="\n")
    saved = sys.stdout, sys.argv
    sys.stdout, sys.argv = out, [module.__name__ + ".py", *argv]
    try:
        module.main()
    finally:
        out.flush()
        written = out.buffer.getvalue()
        sys.stdout, sys.argv = saved
    return written


def collected(files, mode, results=None, listing=same, keys=same, fetching=None):
    """collect.py's output on the miniature, from a fresh module, so nothing is cached yet.
    fetching, if given, replaces prefetch, which fetches files ahead of reading them."""
    importlib.reload(collect)
    github = GitHub(files, listing, keys)
    collect.urllib = SimpleNamespace(request=SimpleNamespace(urlopen=github.urlopen),
                                     error=urllib.error)
    if fetching:
        prefetch = collect.prefetch
        collect.prefetch = lambda paths: fetching(prefetch, list(paths))
    return run(collect, MODES[mode] + ["--comparator", results or RESULTS_FILE])


def lean(data, results=None):
    """What to_lean.py writes from collected data, given as bytes."""
    with open(DATA_FILE, "wb") as f:
        f.write(data)
    return run(to_lean, [DATA_FILE, "--comparator", results or RESULTS_FILE]).decode()


def records(out):
    """collect.py's output without its source block."""
    d = json.loads(out)
    del d["source"]
    return d


MODES = {"with --all": ["--all"],
         "by family": ["001", "002", "--folder", WEIL, "--folder", KUGA, "--folder", HODGE]}
LEAN_STRING = r'"(?:[^"\\]|\\.)*"'


def per_manuscript(text, raw=lambda r: r):
    """to_lean.py's output, split: each manuscript's title, family, Raw, links and docs link, by
    folder, and the rest of the file. raw rewrites each Raw before it's compared."""
    blocks = {}

    def take(m):
        blocks[m.group(1)] = m.group(2)
        return f"def {m.group(1)}: per manuscript\n\n"

    rest = re.sub(r"^def (folders|titles|families|raws|links|docsLinks) : [^\n]* :=\n  (.*?)\n\n",
                  take, text, flags=re.M | re.S)
    folders = [json.loads(s) for s in re.findall(LEAN_STRING, blocks["folders"])]
    titles = [json.loads(s) for s in re.findall(LEAN_STRING, blocks["titles"])]
    families = [None if s == "none" else json.loads(s[5:])
                for s in re.findall(r"none|some " + LEAN_STRING, blocks["families"])]
    raws = re.findall(r"\{ withdrawnOn := .*?depsRead := \w+ \}", blocks["raws"], re.S)
    links = json.loads(blocks["links"])
    pairs = re.findall(rf"\(({LEAN_STRING}), ({LEAN_STRING})\)", blocks.get("docsLinks", ""))
    docs_links = {json.loads(a): json.loads(b) for a, b in pairs}
    assert len(folders) == len(titles) == len(families) == len(raws) == len(links), "unparsed"
    return {"manuscripts": {f: {"title": t, "family": fam, "Raw": raw(r),
                                "links": [folders[i] for i in ls], "docsLink": docs_links.get(f)}
                            for f, t, fam, r, ls in zip(folders, titles, families, raws, links)},
            "rest": rest}


def facts_unordered(raw):
    """A Raw with its challenges' facts sorted."""
    m = re.search(r"challenges := \[(.*)\],\n", raw, re.S)
    facts = sorted(re.findall(r"⟨[^⟩]*⟩", m.group(1)))
    return raw[:m.start(1)] + ", ".join(facts) + raw[m.end(1):]


def reversed_keys(x):
    """A JSON value with every object's keys in reverse order."""
    if isinstance(x, dict):
        return {k: reversed_keys(v) for k, v in reversed(list(x.items()))}
    if isinstance(x, list):
        return [reversed_keys(v) for v in x]
    return x


def as_data(d):
    return json.dumps(d, indent=1, ensure_ascii=False).encode()


# The tests.
tmp = tempfile.mkdtemp()
try:
    DATA_FILE = os.path.join(tmp, "data.json")
    RESULTS_FILE = os.path.join(tmp, "results.json")
    with open(RESULTS_FILE, "w", encoding="utf-8") as f:
        json.dump(RESULTS, f, indent=1)
    BASE = release()
    base = {mode: collected(BASE, mode) for mode in MODES}
    base_lean = {mode: lean(out) for mode, out in base.items()}

    def summary(out):
        d = json.loads(out)
        ms = d["manuscripts"]
        return {"graded": [m["folder"] for m in ms],
                "withdrawn": [m["folder"] for m in ms if m["withdrawnOn"]],
                "challenges": {m["folder"]: m["challenges"] for m in ms if m["challenges"]},
                "noticeLinks": {m["folder"]: m["noticeLinks"] for m in ms if m["noticeLinks"]},
                "docsLinks": {m["folder"]: m["docsLinks"] for m in ms if "docsLinks" in m},
                "earlier": [(e["folder"], e["listedAs"]) for e in d.get("earlierVersions", [])],
                "unlinked": d.get("unlinked")}

    check("the miniature has what the relations need: withdrawn manuscripts, a notice with two "
          "links, earlier versions, a docs link to one, and unlinked challenges and folders",
          lambda: (summary(base["with --all"]),
                   {"graded": sorted([ALPHA, BETA, GAMMA, DELTA, EPSILON, WEIL, KUGA, HODGE]),
                    "withdrawn": sorted([WEIL, KUGA, HODGE]),
                    "challenges": {ALPHA: ["AlphaMain", "BetaMain"],
                                   BETA: ["AlphaMain", "BetaMain"],
                                   DELTA: ["DeltaMain", "GammaMain"],
                                   GAMMA: ["DeltaMain", "GammaMain"]},
                    "noticeLinks": {HODGE: [KUGA, WEIL], KUGA: [WEIL]},
                    "docsLinks": {DELTA: DELTA_EARLIER},
                    "earlier": [(ALPHA_EARLIER, [ALPHA]), (DELTA_EARLIER, [DELTA])],
                    "unlinked": {"challenges": ["OrphanMain"], "docsFolders": [DRAFT]}}))

    # 1. Adding or changing a metric.
    def no_record_changes(files, also=None):
        """Each mode's records, source aside, and what to_lean.py writes, from these files."""
        assert files != BASE, "the metric isn't in the input"
        got, want = {}, {}
        for mode in MODES:
            out = collected(files, mode)
            got[mode] = {"records": records(out), "Lean": lean(out)}
            want[mode] = {"records": records(base[mode]), "Lean": base_lean[mode]}
            if also:
                got[mode]["source"], want[mode]["source"] = also(out)
        return got, want

    LINE = "Confidence: 97%. Independently reviewed, verified, and checked for novelty."
    BADGE = ("[![confidence 97%](https://img.shields.io/badge/confidence-97%25-brightgreen)]"
             "(https://example.org/reviews/1)")
    SECTION = "## Review\n\nReviewed and verified, with a confidence of 97%. Novelty: checked."

    def readmes(edit, which=lambda f: True):
        return release(readme=lambda f, text: edit(text) if which(f) else text)

    def at_end(extra):
        return lambda text: text + "\n" + extra + "\n"

    def below_heading(extra):
        return lambda text: text.replace("\n", "\n\n" + extra + "\n", 1)

    def on_heading(extra):
        return lambda text: text.replace("\n", " " + extra + "\n", 1)

    check("a confidence line at the end of every README changes no record and no Raw",
          lambda: no_record_changes(readmes(at_end(LINE))))
    check("a confidence badge at the end of every README changes no record and no Raw",
          lambda: no_record_changes(readmes(at_end(BADGE))))
    check("a review section of its own at the end of every README changes no record and no Raw",
          lambda: no_record_changes(readmes(at_end(SECTION))))
    check("a claim to be reviewed, verified and checked for novelty, just below every README's "
          "heading and so inside each withdrawal notice, changes no record and no Raw",
          lambda: no_record_changes(readmes(below_heading(LINE))))
    check("a confidence badge just below every README's heading changes no record and no Raw",
          lambda: no_record_changes(readmes(below_heading(BADGE))))
    check("a review section of its own just below the heading of every README without a "
          "withdrawal notice changes no record and no Raw",
          lambda: no_record_changes(readmes(below_heading(SECTION), lambda f: f not in NOTICES)))
    check("a confidence line above every docs page's heading, a badge below it and a row in its "
          "table change no record and no Raw",
          lambda: no_record_changes(release(page=lambda text: LINE + "\n\n" + below_heading(BADGE)(
              text.replace("| --- | --- |\n", "| --- | --- |\n| Confidence | 97% |\n")))))
    check("a score, a confidence and verified and reviewed fields in every challenge's JSON "
          "change no record and no Raw",
          lambda: no_record_changes(release(config={"score": 0.97, "confidence": "high",
                                                    "verified": True, "reviewed": True})))
    check("another review status in lean/formalization.yaml changes the source block alone",
          lambda: no_record_changes(release(review="verified"), also=lambda out: (
              json.loads(out)["source"]["formalizationReview"], "verified")))

    # Where collect.py can't read a README with a metric in it, it stops. Each placement is tried
    # in each README that each mode reads and that it fits, one README at a time.
    README_PATH = re.compile(r"preprints/([^/]+)/README\.md")
    read_in = {mode: [m.group(1) for p in json.loads(base[mode])["source"]["read"]
                      for m in [README_PATH.fullmatch(p)] if m] for mode in MODES}

    def stops(edit, which=lambda f: True):
        """In each mode, for each README it reads that which picks, with that README alone edited:
        whether collect.py exits non-zero, whether its message names the README, and what it
        wrote."""
        got, want = {}, {}
        for mode in MODES:
            for f in filter(which, read_in[mode]):
                files = readmes(edit, lambda g: g == f)
                assert files != BASE, "the README wasn't changed"
                path = f"preprints/{f}/README.md"
                try:
                    collected(files, mode)
                    got[f"{mode}: {path}"] = "it didn't stop"
                except SystemExit as e:
                    status = 0 if e.code is None else e.code if isinstance(e.code, int) else 1
                    got[f"{mode}: {path}"] = {"exits non-zero": status != 0,
                                              "names the README": path in str(e.code),
                                              "writes": written}
                want[f"{mode}: {path}"] = {"exits non-zero": True, "names the README": True,
                                           "writes": b""}
        assert want, "no README was tried"
        return got, want

    COMMENT = "<!-- Reviewed and verified. Confidence: 97%. -->"
    LINK = "[Confidence: 97%](https://example.org/reviews/1)"
    REPORT = "[Referee report: accept](report.pdf)"

    def above(extra):
        return lambda text: extra + "\n\n" + text

    def before_title(extra):
        return lambda text: text.replace("# [", "# " + extra + " [", 1)

    check("a confidence line above any README's heading makes collect.py stop, name the README "
          "and write nothing", lambda: stops(above(LINE)))
    check("a confidence badge above any README's heading makes collect.py stop, name the README "
          "and write nothing", lambda: stops(above(BADGE)))
    check("a confidence badge on any README's heading line, before the title's link, makes "
          "collect.py stop, name the README and write nothing", lambda: stops(before_title(BADGE)))
    check("a confidence link on any README's heading line, before the title's link, makes "
          "collect.py stop, name the README and write nothing", lambda: stops(before_title(LINK)))
    check("a link to a PDF beside the README, on any README's heading line just before the "
          "title's link, makes collect.py stop, name the README and write nothing",
          lambda: stops(before_title(REPORT)))
    check("a confidence badge on any README's heading line, after the title's link, makes "
          "collect.py stop, name the README and write nothing", lambda: stops(on_heading(BADGE)))
    check("a byte-order mark before any README's heading makes collect.py stop, name the README "
          "and write nothing", lambda: stops(lambda text: "\ufeff" + text))
    check("a blank line before any README's heading makes collect.py stop, name the README and "
          "write nothing", lambda: stops(lambda text: "\n" + text))
    check("an HTML comment before any README's heading makes collect.py stop, name the README "
          "and write nothing", lambda: stops(lambda text: COMMENT + "\n" + text))
    check("a review section of its own between a withdrawal notice's heading and its links makes "
          "collect.py stop, name the README and write nothing",
          lambda: stops(below_heading(SECTION), lambda f: NOTICES.get(f)))

    # 2. Reordering the input.
    def nothing_changes(files=None, results=None, **how):
        """Each mode's output, and what to_lean.py writes from it, byte for byte."""
        got, want = {}, {}
        for mode in MODES:
            out = collected(files or BASE, mode, results, **how)
            got[mode] = {"collect.py": out.decode(), "to_lean.py": lean(out, results)}
            want[mode] = {"collect.py": base[mode].decode(), "to_lean.py": base_lean[mode]}
        return got, want

    def reordered(**how):
        files = release(**how)
        assert files != BASE, "nothing was reordered"
        return files

    check("CONTENTS.md's families in reverse order change nothing either script writes",
          lambda: nothing_changes(reordered(families=backwards)))
    check("each family's manuscripts in reverse order in CONTENTS.md change nothing either "
          "script writes", lambda: nothing_changes(reordered(within=backwards)))
    check("each docs page's links to papers and challenges in reverse order change nothing "
          "either script writes", lambda: nothing_changes(reordered(docs=backwards)))
    check("each withdrawal notice's links in reverse order change nothing either script writes",
          lambda: nothing_changes(reordered(notice=backwards)))
    check("each challenge JSON's keys in reverse order change nothing either script writes",
          lambda: nothing_changes(reordered(keys=backwards)))
    check("the tree API's keys in reverse order change nothing either script writes",
          lambda: nothing_changes(keys=backwards))
    check("every directory listing in reverse order changes nothing either script writes",
          lambda: nothing_changes(listing=backwards))
    BACKWARDS_RESULTS = os.path.join(tmp, "results-backwards.json")
    with open(BACKWARDS_RESULTS, "w", encoding="utf-8") as f:
        json.dump(reversed_keys(RESULTS), f, indent=1)
    check("the results file's keys in reverse order change nothing either script writes",
          lambda: nothing_changes(results=BACKWARDS_RESULTS))
    check("the collected data's keys in reverse order change nothing to_lean.py writes",
          lambda: ({m: lean(as_data(reversed_keys(json.loads(base[m])))) for m in MODES},
                   base_lean))

    batches = []

    def none_ahead(prefetch, paths):
        batches.append(len(paths))

    def ahead_backwards(prefetch, paths):
        batches.append(len(paths))
        prefetch(paths[::-1])

    def fetched_differently(fetching):
        batches.clear()
        got, want = nothing_changes(fetching=fetching)
        assert max(batches) > 1, "nothing was fetched in another order"
        return got, want

    check("each file fetched only when it's read, none ahead, changes nothing either script "
          "writes", lambda: fetched_differently(none_ahead))
    check("files fetched ahead in reverse order change nothing either script writes",
          lambda: fetched_differently(ahead_backwards))

    # 3. Through to_lean.py.
    def with_fields(d):
        d = copy.deepcopy(d)
        d["metrics"] = {"confidence": 0.97}
        d["source"]["confidence"] = "high"
        for m in d["manuscripts"]:
            m.update(reviewed=True, noveltyChecked=True, fidelityBy="A. Referee", depsRead=True,
                     confidence=0.97, verified=True)
        for c in d["challenges"]:
            c.update(score=0.97, reviewed=True, verified=True)
        return d

    def manuscripts_backwards(d):
        d = copy.deepcopy(d)
        d["manuscripts"].reverse()
        return d

    def challenges_backwards(d):
        d = copy.deepcopy(d)
        d["challenges"].reverse()
        return d

    def each_manuscripts_challenges_backwards(d):
        d = copy.deepcopy(d)
        for m in d["manuscripts"]:
            m["challenges"].reverse()
        return d

    data = {mode: json.loads(out) for mode, out in base.items()}
    check("fields added to the collected data, a manuscript's own reviewed, noveltyChecked, "
          "fidelityBy and depsRead among them, change nothing to_lean.py writes",
          lambda: ({m: lean(as_data(with_fields(data[m]))) for m in MODES}, base_lean))
    check("the collected manuscripts in reverse order give each the same title, family, Raw, "
          "links and docs link",
          lambda: ({m: per_manuscript(lean(as_data(manuscripts_backwards(data[m]))))
                    for m in MODES},
                   {m: per_manuscript(base_lean[m]) for m in MODES}))
    check("the collected challenges in reverse order change nothing to_lean.py writes",
          lambda: ({m: lean(as_data(challenges_backwards(data[m]))) for m in MODES}, base_lean))
    check("each manuscript's challenges in reverse order give the same Raw, up to the order of "
          "its challenges, which the grade reads as a set (Core.lean's Raw.formal and "
          "Raw.axiomsOk)",
          lambda: ({m: per_manuscript(lean(as_data(each_manuscripts_challenges_backwards(data[m]))),
                                      facts_unordered) for m in MODES},
                   {m: per_manuscript(base_lean[m], facts_unordered) for m in MODES}))
finally:
    shutil.rmtree(tmp)

print("test_collect.py: " + ("FAILED" if failed else "passed"))
sys.exit(1 if failed else 0)
