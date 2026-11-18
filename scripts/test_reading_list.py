"""Tests of pilot/reading_list.py's rules, which scripts/test-pilot-shard.sh runs: imports followed
from the challenge file alone, depth as the fewest imports, declarations found after attributes
and modifiers but never in a comment, names given in full as far as `namespace` shows them,
theorems counted and axioms listed, and the packages outside the release sorted by root. They use
synthetic Lean text in a temporary folder, and need no network and no release. Run them with
`python3 -B`, so that importing the script leaves no bytecode.
"""
import json
import os
import shutil
import sys
import tempfile

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "pilot"))
import reading_list as rl  # noqa: E402

failed = False


def check(label, got, want):
    global failed
    if got == want:
        print(f"ok: {label}")
    else:
        print(f"FAIL: {label}: expected {want!r}, got {got!r}")
        failed = True


def write(root, rel, text):
    path = os.path.join(root, *rel.split("/"))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


check("header_imports is imports.py's, not a copy", rl.header_imports.__module__, "imports")

# A release in miniature. X's challenge file imports A and C. A reaches D in one more import, and
# C only in three, through B and E, so a search that went deep first would put D too far down. D
# imports A again. X's solution imports Extra and a package Qux, which the list mustn't see.
TREE = {
    "ComparatorChallenges/X.lean": "import OAI.A\nimport OAI.C\nimport Mathlib.Topology.Basic\n"
                                   "theorem x_main : True := trivial\n",
    "OAI/A.lean": "import OAI.D\nimport Batteries.Data.List\ndef a := 1\n",
    "OAI/C.lean": "import OAI.B\nimport Std.Data.HashMap\nimport PNT.Main\nimport ProofWidgets.Foo\n"
                  "axiom c_ax : False\n",
    "OAI/B.lean": "import OAI.E\nimport Lean.Elab\ndef b := 1\n",
    "OAI/E.lean": "import OAI.D\n",
    "OAI/D.lean": "import OAI.A\nimport Zzz.Thing\nimport Init.Prelude\nimport Lake.Util\n",
    "OAI/Sol.lean": "import ComparatorChallenges.X\nimport OAI.Extra\nimport Qux.Bar\n",
    "OAI/Extra.lean": "import Mathlib\ndef extra := 1\n",
}
CATALOGUE = {"source": {"commit": rl.COMMIT, "license": "Apache-2.0"},
             "challenges": [{"name": "X", "solutionModule": "OAI.Sol", "family": "001"}],
             "manuscripts": [{"title": "A paper", "challenges": ["X"]},
                             {"title": "Another paper", "challenges": ["Y"]}]}
MANIFEST = {"packages": [{"name": "mathlib"}, {"name": "batteries"}, {"name": "proofwidgets"}]}
RELEASE_MANIFEST = {"packages": [
    {"name": "mathlib", "url": "https://example.org/mathlib", "rev": "m1"},
    {"name": "PNT", "url": "https://example.org/pnt", "rev": "abc123"}]}

tmp = tempfile.mkdtemp()
try:
    lean = os.path.join(tmp, "lean")
    for rel, text in TREE.items():
        write(lean, rel, text)
    write(lean, "lake-manifest.json", json.dumps(RELEASE_MANIFEST))
    data = rl.build(lean, CATALOGUE, MANIFEST, names=["X"])
    c = data["challenges"][0]
    depth = {f["module"]: f["depth"] for f in c["files"]}

    check("imports are followed from the challenge file alone",
          sorted(depth), ["ComparatorChallenges.X", "OAI.A", "OAI.B", "OAI.C", "OAI.D", "OAI.E"])
    check("a module only the solution imports isn't listed", "OAI.Extra" in data["files"], False)
    check("depth is the fewest imports, and the cycle through A ends",
          depth, {"ComparatorChallenges.X": 0, "OAI.A": 1, "OAI.C": 1, "OAI.B": 2, "OAI.D": 2,
                  "OAI.E": 3})
    check("files are listed by depth, then name", [f["module"] for f in c["files"]],
          ["ComparatorChallenges.X", "OAI.A", "OAI.C", "OAI.B", "OAI.D", "OAI.E"])
    check("the count includes the challenge file", c["fileCount"], 6)
    check("each file's path is under lean/", data["files"]["OAI.A"]["path"], "lean/OAI/A.lean")
    check("the manuscripts come from the catalogue", c["manuscripts"], ["A paper"])
    check("Lean's own roots", c["outside"]["lean"], ["Init", "Lake", "Lean", "Std"])
    check("Mathlib's roots match the manifest's packages, ignoring case",
          c["outside"]["mathlib"], ["Batteries", "Mathlib", "ProofWidgets"])
    check("other roots are named from the release's manifest, or alone",
          c["outside"]["other"],
          [{"root": "PNT", "package": "PNT", "url": "https://example.org/pnt", "rev": "abc123"},
           {"root": "Zzz", "package": None, "url": None, "rev": None}])
    check("a package only the solution imports isn't named",
          any(p["root"] == "Qux" for p in c["outside"]["other"]), False)
    check("an axiom in the closure is listed for its challenge",
          c["axioms"], [{"module": "OAI.C", "name": "c_ax", "line": 5}])
    check("the source names the license and the release's manifest",
          (data["source"]["license"], data["releaseManifest"]),
          ("Apache-2.0", "lean/lake-manifest.json"))

    again = rl.build(lean, CATALOGUE, MANIFEST, names=["X"])
    check("a second build gives the same JSON",
          json.dumps(again, indent=1, ensure_ascii=False) == json.dumps(data, indent=1, ensure_ascii=False),
          True)
    full = rl.render(data)
    check("a second render gives the same report", rl.render(again) == full, True)
    check("the report's first line names the generator and its input",
          full.split("\n")[0].startswith("*Generated by `python3 pilot/reading_list.py --report "
                                         "pilot/data/reading-lists.json`"), True)
    check("under the limit, every file past the challenge file has its own block",
          full.count("<details>"), 5)
    small = rl.render(data, limit=1)
    check("past the limit, files past depth 2 are listed by name only",
          (small.count("<details>"), "- `OAI.E`" in small, "by name only" in small), (4, True, True))

    os.remove(os.path.join(lean, "lake-manifest.json"))
    bare = rl.build(lean, CATALOGUE, MANIFEST, names=["X"])
    check("without the release's manifest, the package is named alone",
          (bare["releaseManifest"], bare["challenges"][0]["outside"]["other"][0]),
          (None, {"root": "PNT", "package": None, "url": None, "rev": None}))
    check("and the report says the manifest wasn't in the checkout",
          "wasn't in the checkout" in rl.render(bare), True)

    try:
        rl.build(lean, CATALOGUE, MANIFEST, names=["X", "Missing"])
        check("a challenge not in the catalogue stops it", "no stop", "stop")
    except SystemExit:
        check("a challenge not in the catalogue stops it", "stop", "stop")
finally:
    shutil.rmtree(tmp)

TEXT = '''import Mathlib
/-! A module doc: def hidden0 := 1 -/
namespace A

@[simp] private noncomputable def foo : Nat := 1
@[reducible]
protected abbrev bar := 2
opaque baz : Nat
irreducible_def qux : Nat := 3
structure S where
  x : Nat
class C (α : Type) where
class inductive CI
inductive I | a | b
instance instFoo : Inhabited S := ⟨⟨0⟩⟩
noncomputable instance (priority := 100) : Inhabited I := ⟨.a⟩
@[simp, norm_cast
  ] theorem t1 : True := trivial
@[reducible,
  instance 100,
  simp]
def fooInst : Inhabited Nat := ⟨0⟩
lemma l1 : True := trivial
private theorem t2 : True := trivial
axiom ax : False
scoped notation "‖" x "‖" => x
local infix:65 " +++ " => Nat.add
infixl:65 " ++l " => Nat.add
infixr:65 " ++r " => Nat.add
prefix:max "√√" => Nat.succ
postfix:max "!!" => Nat.succ
syntax (name := mySyntax) "mysyntax" : term
macro "mymacro" : term => `(1)
macro_rules | `(mymacro) => `(2)
elab "myelab" : term => pure (Lean.mkNatLit 1)
notation3 "∑∑" => 0
elab_rules : term | `(myelab) => pure (Lean.mkNatLit 2)
open Nat in def withOpen := 1
-- def hidden1 := 1
/- def hidden2 := 1 -/
/-- A doc comment.
def hidden3 := 1
-/
/- nested /- def hidden4 := 1 -/ def hidden5 := 1 -/
def afterString := "/- not a comment, -- nor this"
def afterChar := '"'
/-
def hidden6 := 1
-/
def afterEscapedChar := '\\"'
/-
def hidden7 := 1
-/
def visible := 1

namespace B
def inB := 1
namespace C.D
def inCD := 1
end C.D
def backInB := 1
end B
section Sec
def inSection := 1
end Sec
def _root_.Top := 1
end A
namespace P.Q
def inPQ := 1
end Q
def inP := 1
end P
namespace M
namespace N
def inMN := 1
end M.N
def outside := 1
'''
lines = TEXT.split("\n")
d = rl.declarations(TEXT)
kinds = {}
for x in d["declarations"]:
    kinds.setdefault(x["kind"], []).append(x["name"])

check("definitions are found after attributes and modifiers, with their namespaces", kinds["def"],
      ["A.foo", "A.fooInst", "A.withOpen", "A.afterString", "A.afterChar", "A.afterEscapedChar",
       "A.visible", "A.B.inB",
       "A.B.C.D.inCD", "A.B.backInB", "A.inSection", "Top", "P.Q.inPQ", "P.inP", "M.N.inMN",
       "outside"])
check("abbrev, opaque and irreducible_def are definitions",
      (kinds["abbrev"], kinds["opaque"], kinds["irreducible_def"]), (["A.bar"], ["A.baz"], ["A.qux"]))
check("structures, classes, class inductives and inductives are types",
      (kinds["structure"], kinds["class"], kinds["inductive"]), (["A.S"], ["A.C", "A.CI"], ["A.I"]))
check("a named instance, and an anonymous one by its line",
      [(x["name"], x["line"]) for x in d["declarations"] if x["kind"] == "instance"],
      [("A.instFoo", lines.index("instance instFoo : Inhabited S := ⟨⟨0⟩⟩") + 1),
       (None, lines.index("noncomputable instance (priority := 100) : Inhabited I := ⟨.a⟩") + 1)])
check("each kind of notation and macro is found",
      sorted(k for k in kinds if k in rl.NOTATION), sorted(rl.NOTATION))
check("a notation's name is given in full, and its text keeps its scope",
      ([x["name"] for x in d["declarations"] if x["kind"] == "syntax"],
       [x["text"] for x in d["declarations"] if x["kind"] == "notation"]),
      (["A.mySyntax"], ['scoped notation "‖" x "‖" => x']))
check("nothing is found in a comment, a block comment or a doc comment",
      [x for x in d["declarations"] if x["name"] and "hidden" in x["name"]], [])
check("theorems and lemmas are counted, an attribute over two lines included",
      (d["theorems"], d["lemmas"]), (2, 1))
check("theorems and lemmas aren't listed",
      [x for x in d["declarations"] if x["kind"] in ("theorem", "lemma")], [])
check("an axiom is listed apart",
      (d["axioms"], [x for x in d["declarations"] if x["kind"] == "axiom"]),
      ([{"kind": "axiom", "name": "A.ax", "line": lines.index("axiom ax : False") + 1}], []))
check("comments keep line numbers", rl.code_only(TEXT).count("\n"), TEXT.count("\n"))

print("test_reading_list.py: " + ("FAILED" if failed else "passed"))
sys.exit(1 if failed else 0)
