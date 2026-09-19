"""Report figure: the dose the anchor applies without stating it, next to its own predictor.

Adding the raw difference of means at coefficient 1 makes the dose ||d|| divided by the residual
norm of the layer. If that ratio rises in the same layers as A_lin, part of the anchor's reported
correlation is the dose tracking the predictor. Reads what the two notebooks wrote to results/, so
the figure is reproducible without re-running either of them.

    uv run python scripts/fig_dose_confound.py
"""
import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import spearmanr

ROOT = Path(__file__).resolve().parents[1]
anchor = json.loads((ROOT / "results/07_anchor.json").read_text())
sources = json.loads((ROOT / "results/08_direction_sources.json").read_text())

# Only the families with signal: the two floor families have no rank order in A_lin to correlate.
FAMILIES = ["pronoun", "temperature", "size", "daynight"]
resnorm = np.array(sources["resnorm"])
layers = np.arange(len(resnorm))

fig, axes = plt.subplots(2, 4, figsize=(13, 4.6), sharex=True, sharey="row")
for col, fam in enumerate(FAMILIES):
    alin = np.array(anchor["alin"][fam])
    dose = np.array(anchor["dnorm"][fam]) / resnorm
    rho = spearmanr(alin, dose).statistic
    top, bottom = axes[0, col], axes[1, col]
    top.plot(layers, alin, "o-", lw=2, ms=4, color="C0")
    bottom.plot(layers, dose, "s-", lw=2, ms=4, color="C3")
    top.set_title(f"{fam}    $\\rho(A_{{lin}},\\ \\mathrm{{dose}}) = {rho:+.2f}$", fontsize=10)
    bottom.set_xlabel("layer")
    bottom.set_xticks(range(0, 12, 2))
    for ax in (top, bottom):
        ax.grid(alpha=.25)
axes[0, 0].set_ylabel("$A_{lin}$")
axes[1, 0].set_ylabel("implicit dose\n$\\|d\\|$ / residual norm")
axes[0, 0].set_ylim(-0.05, 1.05)
fig.suptitle("The anchor's implicit dose at coefficient 1, against its predictor, per layer", fontsize=11)
fig.tight_layout()
fig.savefig(ROOT / "report/figures/dose_confound.pdf", bbox_inches="tight")
print("wrote report/figures/dose_confound.pdf")
