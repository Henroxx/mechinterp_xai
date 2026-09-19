# mechinterp_xai

**Applied Mechanistic Interpretability Methods** — university project for the XAI module
(M.Sc., Fachhochschule Südwestfalen). The report is
[`report/main.pdf`](report/main.pdf); the tag `v1.0-submission` is the state it describes.

Several mechanistic interpretability methods applied to open-source language models:
activation patching, steering vectors, linear probes and sparse autoencoders. The project is
deliberately method-critical — the recurring question is not what a method shows, but what
it would still show if the setting behind it were chosen differently.

## What came out

A training-free measure, the logit lens read as accuracy per layer, predicts which concepts
can be steered. A trained probe cannot, because it saturates: for two of six concept families
it reads 1.00 in every one of the twelve layers, so it has no variance left to rank them with.
Perfectly readable is not the same as steerable.

The anchor paper this reproduces never states a dose. It adds the raw difference of means, whose
norm runs from 0.5 to 58 across the concepts and layers measured here, so its numbers compare
concepts at unequal doses. Read at an equal side-effect budget instead, its ranking mostly
survives — one adjacent swap — but the perfect correlation was partly bought with the dose. Where
a direction comes from then matters less than which layer it is added at and how much of it: at
layer 10 the difference of means, the probe weight and a sparse-autoencoder decoder row land
within 0.03 of each other, and on one concept a random direction of the same norm beats all
three.

## Structure

- `notebooks/` — eight notebooks with stored outputs, readable without running anything.
  `01`–`06` are the exploration (orientation, patching, steering, probing, a second model,
  sparse autoencoders), `07` and `08` are the main experiment.
- `results/` — the JSON files the report's tables and figures are drawn from
- `report/` — Typst source, bibliography and figures
- `scripts/` — environment smoke test, MPS-vs-CPU numerical check, the figure script for `07`/`08`
- `docs/agentcontext/` — project state and long-term notes
- `CLAUDE.md` — the rules this project was worked under, including the use of AI

## Setup

Models come from the Hugging Face cache, not from this repo; Gemma-2-2B requires accepting
its license on Hugging Face first.

```sh
uv sync
uv run python scripts/smoke_test.py
uv run jupyter lab
```

Runs locally on Apple Silicon (MPS verified against CPU, see `scripts/verify_mps.py`).
Seed 0 throughout; library versions are pinned in `uv.lock`.
