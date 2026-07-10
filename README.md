# mechinterp_xai

Applied Mechanistic Interpretability Methods — university project for the XAI module
(M.Sc., Fachhochschule Südwestfalen).

Hands-on exploration of mechanistic interpretability techniques on open-source LLMs:
applying methods like activation patching, steering vectors and probing, analyzing model
behavior (e.g. side effects of model steering), and documenting the findings in a paper.
Deliberately exploratory — several methods, several questions, a critical look at how
reliable the methods themselves are.

## Structure

- `context/` — project state and long-term notes (project index, details, chronology)
- `scripts/` — runnable scripts (environment smoke test, MPS-vs-CPU numerical verification)
- `report/` — the paper (Typst)

## Setup

Models: Gemma-2-2B (base + it) as the main subject, GPT-2 small for ground-truth circuit
experiments. Weights live in the Hugging Face cache, not in this repo (Gemma requires
accepting the license on Hugging Face).

```sh
python3.13 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python scripts/smoke_test.py
```

Runs locally on Apple Silicon (MPS verified against CPU, see `scripts/verify_mps.py`).
