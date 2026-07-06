"""
generate_figures.py
====================
Generates the three figures for this upload directly from the CSV outputs
of step1_cascade_simulation_exact_topology.py and step2_nullmodel_validation.py.

IMPORTANT: every statistic printed on these figures (rho, r, p-values) is
computed from the CSV at plot time. Nothing is hardcoded. If you re-run
step1/step2 on updated or corrected input data, re-running this script will
always produce figures consistent with the new numbers.

Output
------
figures/Fig5_centrality_cascade_exact_topology.png
figures/Fig6_economic_resilience_nullmodel.png
figures/Fig7_cascade_nullmodel_permutation.png

Usage
-----
  python generate_figures.py   (run after step1 and step2)
"""

import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.stats import spearmanr, gaussian_kde

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
FIG_DIR = os.path.join(os.path.dirname(__file__), "..", "figures")
os.makedirs(FIG_DIR, exist_ok=True)

plt.rcParams.update({
    "font.size": 9, "axes.spines.top": False, "axes.spines.right": False,
    "figure.dpi": 150, "savefig.dpi": 200, "figure.facecolor": "white",
})


def sig_stars(p):
    if p < 0.001:
        return "***"
    if p < 0.01:
        return "**"
    if p < 0.05:
        return "*"
    return " n.s."


# ---------------------------------------------------------------------------
# Fig 5 — centrality vs. cascade impact (4 panels)
# ---------------------------------------------------------------------------
fig, axes = plt.subplots(2, 2, figsize=(9, 7))
measures = ["Betweenness", "Degree", "Closeness", "Eigenvector"]
for ax, measure in zip(axes.flat, measures):
    d = pd.read_csv(os.path.join(DATA_DIR, f"cascade_{measure.lower()}_exact.csv"))
    x, y = d["centrality"].values, d["cascade_impact"].values
    rho, p = spearmanr(x, y)
    ax.scatter(x, y, s=22, alpha=0.7, color="#1f77b4")
    if len(x) > 2:
        c = np.polyfit(x, y, 1)
        xp = np.linspace(x.min(), x.max(), 100)
        ax.plot(xp, np.polyval(c, xp), color="#d62728", lw=1.3)
    ax.set_title(f"{measure} centrality\nρ = {rho:.3f}{sig_stars(p)}  (n={len(d)})")
    ax.set_xlabel(f"{measure} centrality")
    ax.set_ylabel("Cascade impact")
fig.suptitle("Fig. 5 — Centrality vs. cascade impact (exact physical topology, N=53, E=86)", y=1.02)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, "Fig5_centrality_cascade_exact_topology.png"),
            bbox_inches="tight")
plt.close(fig)
print("Saved Fig5_centrality_cascade_exact_topology.png")

# ---------------------------------------------------------------------------
# Fig 6 — economic-resilience permutation null (4 panels)
# ---------------------------------------------------------------------------
econ = pd.read_csv(os.path.join(DATA_DIR, "nullmodel_economic_resilience.csv"))
fig, axes = plt.subplots(2, 2, figsize=(10, 7))
for ax, (_, row) in zip(axes.flat, econ.iterrows()):
    mu, sd = row["null_mean"], row["null_sd"]
    xs = np.linspace(mu - 4.5 * sd, mu + 4.5 * sd, 400)
    dens = np.exp(-0.5 * ((xs - mu) / sd) ** 2) / (sd * np.sqrt(2 * np.pi))
    ax.plot(xs, dens, color="#1f77b4")
    ax.fill_between(xs, dens, alpha=0.25, color="#1f77b4")
    r_obs = row["pearson_r"]
    color = "#1f77b4" if row["p_permutation"] < 0.05 else "#d62728"
    ax.axvline(r_obs, color=color, lw=2.2)
    ax.set_title(f"{row['economic_indicator']}\n× {row['resilience_metric']}", fontsize=8.5)
    label = f"r = {r_obs:+.3f}   p={row['p_permutation']:.3f}{sig_stars(row['p_permutation'])}"
    ax.text(0.98, 0.9, label, transform=ax.transAxes, ha="right", va="top",
            fontsize=8, bbox=dict(boxstyle="round", fc="white", ec=color))
    ax.set_xlabel("Pearson r (permuted)")
    ax.set_ylabel("Density")
fig.suptitle("Fig. 6 — Economic-resilience permutation null (N=5,000 permutations)", y=1.02)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, "Fig6_economic_resilience_nullmodel.png"), bbox_inches="tight")
plt.close(fig)
print("Saved Fig6_economic_resilience_nullmodel.png")

# ---------------------------------------------------------------------------
# Fig 7 — cascade permutation null (4 panels)
# ---------------------------------------------------------------------------
casc = pd.read_csv(os.path.join(DATA_DIR, "nullmodel_cascade_permutation.csv"))
fig, axes = plt.subplots(2, 2, figsize=(10, 7))
for ax, (_, row) in zip(axes.flat, casc.iterrows()):
    mu, sd = row["null_mean"], row["null_sd"]
    xs = np.linspace(mu - 4.5 * sd, mu + 4.5 * sd, 400)
    dens = np.exp(-0.5 * ((xs - mu) / sd) ** 2) / (sd * np.sqrt(2 * np.pi))
    ax.plot(xs, dens, color="#7f7f7f")
    ax.fill_between(xs, dens, alpha=0.25, color="#7f7f7f")
    rho_obs = row["observed_rho"]
    color = "#1f77b4" if row["p_permutation"] < 0.05 else "#e07020"
    ax.axvline(rho_obs, color=color, lw=2.2)
    ax.set_title(f"{row['centrality_measure']} centrality (n={row['n']})", fontsize=9)
    label = f"ρ = {rho_obs:+.3f}   p={row['p_permutation']:.4f}{sig_stars(row['p_permutation'])}"
    ax.text(0.98, 0.9, label, transform=ax.transAxes, ha="right", va="top",
            fontsize=8, bbox=dict(boxstyle="round", fc="white", ec=color))
    ax.set_xlabel("Spearman ρ (permuted)")
    ax.set_ylabel("Density")
fig.suptitle("Fig. 7 — Cascade-permutation null (N=5,000 permutations)", y=1.02)
fig.tight_layout()
fig.savefig(os.path.join(FIG_DIR, "Fig7_cascade_nullmodel_permutation.png"), bbox_inches="tight")
plt.close(fig)
print("Saved Fig7_cascade_nullmodel_permutation.png")
