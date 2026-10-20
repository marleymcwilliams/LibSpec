.PHONY: all build test test-accept lint docs clean release agent-context lint-consts lint-consts-fix

TEXI = papers/part1/JSG_I_skeleton.tex
TEXIA = papers/part1/JSG_I_A.tex
TEXIB = papers/part1/JSG_I_B.tex
TEXA = papers/part2/JSG_II_A.tex
TEXB = papers/part2/JSG_II_B.tex
TEX3A = papers/part3/JSG_III_A.tex
TEX3B = papers/part3/JSG_III_B.tex
OUT  = build

all: build

build:
	python jsg/tools/generate_wrappers.py --part part1
	python jsg/tools/generate_wrappers.py --part part2
	python jsg/tools/generate_wrappers.py --part part3
	mkdir -p $(OUT)
	latexmk -r latexmkrc -output-directory=$(OUT) $(TEXI)
	latexmk -r latexmkrc -output-directory=$(OUT) $(TEXIA)
	latexmk -r latexmkrc -output-directory=$(OUT) $(TEXIB)
	latexmk -r latexmkrc -output-directory=$(OUT) $(TEXA)
	latexmk -r latexmkrc -output-directory=$(OUT) $(TEXB)
	latexmk -r latexmkrc -output-directory=$(OUT) $(TEX3A)
	latexmk -r latexmkrc -output-directory=$(OUT) $(TEX3B)

.PHONY: merge
merge:
	python jsg/tools/build_composed.py
	mkdir -p $(OUT)
	latexmk -r latexmkrc -output-directory=$(OUT) papers/merge/JSG_MERGE_1into2.tex
	latexmk -r latexmkrc -output-directory=$(OUT) papers/merge/JSG_MERGE_2into3.tex

.PHONY: merge-status
merge-status:
	python jsg/tools/merge_status.py --md

.PHONY: topic
topic:
	@if [ -z "$(KEY)" ]; then echo "Usage: make topic KEY=<intro|calc|stoch|closure|entropy|control|kernels|adv_structures|stats|benchmarks|runbook|deploy|governance|related|conclusion|appendix|alignment>"; exit 2; fi
	python jsg/tools/build_topic.py --key $(KEY)
	mkdir -p $(OUT)
	latexmk -r latexmkrc -output-directory=$(OUT) papers/merge/TOPIC_$(shell echo $(KEY) | tr a-z A-Z).tex

test:
	python -m tools.validate_registries
	codespell --ignore-words-list="teh,hte" --skip="build,artifacts" .
	python jsg/tools/lint_consts.py
	python -m tools.check_acceptance --root artifacts

test-accept:
	python -m tools.check_acceptance --require frontier-ledger pr-witness dro-kkt automata-evidence

docs:
	mkdocs build -f docs/mkdocs.yml

lint:
	codespell --ignore-words-list="teh,hte" --skip="build,artifacts" .
	python jsg/tools/lint_consts.py

lint-consts:
	python jsg/tools/lint_consts.py

lint-consts-fix:
	python jsg/tools/lint_consts.py --fix

clean:
	latexmk -C -r latexmkrc -output-directory=$(OUT)

release: build test-accept
	@echo "Tag + create a GitHub release with PDFs + artifact snapshots"

agent-context:
	python jsg/tools/agent_context.py
