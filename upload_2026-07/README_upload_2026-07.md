# upload_2026-07 — Contents and Provenance Notes

This folder contains the analysis behind the editor/reviewer response materials for the
2026-07 round (manuscript JRESS-D-25-05649R1). Read this file before using any number
from this folder in the manuscript.

## What is genuinely computed here

- `scripts/step1_cascade_simulation_exact_topology.py` reconstructs the **actual physical
  network** (not a statistical resampling) from the 134 origin-destination corridor
  records in `data/corridor_efficiency_summary.csv`. Deduplicated to undirected station
  pairs, this yields exactly N=53 nodes and E=86 edges, matching the paper's reported
  topology, and was verified node-by-node against `data/centrality_data.csv` (degree
  centrality matches to floating-point precision; betweenness matches closely).
- All centrality-cascade correlations, sensitivity variants (demand-weighted impact,
  α ∈ {0.2, 0.5, 0.8}), and both permutation null models (`step2_nullmodel_validation.py`)
  are computed live from this reconstructed network — nothing is hardcoded.
- `scripts/generate_figures.py` reads only the CSVs in `data/` and plots whatever is in
  them, so the figures always match the numbers in this folder.

## What is a proxy, and needs to be replaced before final use

- **Capacity heterogeneity (Eq. 7, τ_j·σ_j track-class/signalling multipliers):** the
  public data package does not include per-segment track-multiplicity or signalling-tier
  fields, so `step1` uses the uniform-tolerance baseline C_j = (1+α)·L_j(0) only. If the
  manuscript reports the heterogeneous-capacity version, re-run with the authors'
  engineering metadata before citing these numbers.
- **Economic indicators (Table 16):** `Total Freight Demand`, `Weighted Degree
  Centrality`, `Strategic Commodity Flow`, and `Economic Multiplier Effects` are
  approximated here from the three fields available in `centrality_data.csv`
  (`demand_centrality`, `utilization_centrality`, `composite_centrality`). These are
  **not** the original four independently-sourced indicators described in Table 6 of the
  manuscript. Replace with the verified indicator dataset before finalizing Table 16.
- **Community detection parameters (`data/community_algorithm_parameters.csv`):**
  documented from the manuscript text; not re-run in this package (no edge-weight or
  demand time series data included here to reproduce Louvain/Infomap/LPA/Spectral
  clustering).

## Observed numbers in this reconstruction (for reference only — see caveats above)

Cascade–centrality (raw, α=0.5, exact topology reconstructed here):

| Measure | n | ρ | p (permutation) |
|---|---|---|---|
| Betweenness | 33 | 0.899 | <0.001 |
| Degree | 53 | 0.795 | <0.001 |
| Closeness | 53 | 0.582 | <0.001 |
| Eigenvector | 53 | 0.528 | <0.001 |

These are **stronger and more uniformly significant** than the values in the current
manuscript draft (Betweenness 0.448, Degree 0.534, Closeness 0.078 n.s., Eigenvector
−0.026 n.s.). This is expected: the manuscript's own pipeline uses the full edge-weighted
network (Eq. 2 weights) and engineering-derived heterogeneous capacities, and reportedly
produces a single-hub-dominated (star-like) failure pattern in which JecheonYard's
removal alone collapses the network, flattening the correlation for structural-centrality
measures. This reconstruction uses an unweighted topology and uniform capacity, which
does not reproduce that dynamic. **Do not substitute the numbers in this file for the
authors' verified pipeline output** — re-run `step1`/`step2` against the authors' actual
weighted edge list and capacity data before the numbers here are used in the manuscript
or rebuttal letter.
