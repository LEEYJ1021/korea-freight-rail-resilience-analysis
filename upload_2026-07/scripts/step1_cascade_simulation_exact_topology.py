"""
step1_cascade_simulation_exact_topology.py
===========================================
Motter-Lai cascade failure simulation on the EXACT physical KORAIL freight
rail topology (N=53, E=86), reconstructed from real origin-destination
corridor data rather than from a configuration-model resampling of the
degree sequence.

Why this differs from the earlier revision/step1_cascade_simulation.py:
  - That script built 8 configuration-model networks that only preserve
    the empirical DEGREE SEQUENCE (statistical reconstruction).
  - This script builds the ACTUAL network from the 134 origin-destination
    corridor records in corridor_efficiency_summary.csv, deduplicated to
    86 unique undirected physical segments connecting 53 stations -
    matching the paper's reported N=53, E=86 exactly.

Output
------
data/cascade_betweenness_exact.csv
data/cascade_degree_exact.csv
data/cascade_closeness_exact.csv
data/cascade_eigenvector_exact.csv
data/cascade_sensitivity_specifications.csv   (raw vs demand-weighted impact; alpha in {0.2,0.5,0.8})

Usage
-----
  python step1_cascade_simulation_exact_topology.py

Dependencies
------------
  networkx >= 2.8, numpy, pandas, scipy
"""

import os
import warnings
import numpy as np
import pandas as pd
import networkx as nx
from scipy.stats import spearmanr

warnings.filterwarnings("ignore")

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
MAX_ITER = 40
LOAD_FLOOR = 1e-4

# ---------------------------------------------------------------------------
# 1. Build the exact physical topology
# ---------------------------------------------------------------------------
corr = pd.read_csv(os.path.join(DATA_DIR, "corridor_efficiency_summary.csv"))
cent = pd.read_csv(os.path.join(DATA_DIR, "centrality_data.csv"))

edges = corr[["origin", "dest"]].drop_duplicates()

G = nx.Graph()
G.add_nodes_from(cent["station_kor"])
for _, r in edges.iterrows():
    G.add_edge(r["origin"], r["dest"])

assert G.number_of_nodes() == 53, f"N={G.number_of_nodes()} (expected 53)"
assert G.number_of_edges() == 86, f"E={G.number_of_edges()} (expected 86)"
assert nx.is_connected(G), "Reconstructed network is not connected"

print(f"Reconstructed exact topology: N={G.number_of_nodes()}, E={G.number_of_edges()}, "
      f"connected={nx.is_connected(G)}")

# ---------------------------------------------------------------------------
# 2. Centrality measures on the exact topology
# ---------------------------------------------------------------------------
degree_c = nx.degree_centrality(G)
btw_c    = nx.betweenness_centrality(G)
close_c  = nx.closeness_centrality(G)
try:
    eig_c = nx.eigenvector_centrality(G, max_iter=2000)
except nx.PowerIterationFailedConvergence:
    eig_c = nx.eigenvector_centrality_numpy(G)

demand_lookup = cent.set_index("station_kor")["demand_centrality"].to_dict()
station_name  = cent.set_index("station_kor")["station_eng"].to_dict()

# ---------------------------------------------------------------------------
# 3. Motter-Lai cascade simulation (single realization, exact topology)
#    Load proxy: betweenness centrality (paper Eq. 7 rationale)
#    Capacity:   C_j = (1+alpha) * L_j(0)   [baseline uniform-tolerance form;
#                heterogeneous track/signalling multipliers require
#                per-segment engineering metadata not available in this
#                public data package and are therefore NOT applied here -
#                see note in accompanying README]
# ---------------------------------------------------------------------------
def motter_lai_cascade(G, failed_node, alpha, weighted=False):
    init_loads = {}
    for n in G.nodes():
        base = max(btw_c[n], LOAD_FLOOR)
        init_loads[n] = base
    capacities = {n: (1.0 + alpha) * v for n, v in init_loads.items()}
    cur_loads = dict(init_loads)

    failed = {failed_node}
    G_live = G.copy()
    G_live.remove_node(failed_node)

    nbrs = list(G.neighbors(failed_node))
    if nbrs:
        share = init_loads[failed_node] / len(nbrs)
        for nb in nbrs:
            cur_loads[nb] = cur_loads.get(nb, LOAD_FLOOR) + share

    for _ in range(MAX_ITER):
        new_fail = set()
        for n in G_live.nodes():
            if cur_loads.get(n, 0.0) > capacities.get(n, float("inf")):
                new_fail.add(n)
        if G_live.number_of_nodes() > 1:
            comps = sorted(nx.connected_components(G_live), key=len, reverse=True)
            for comp in comps[1:]:
                new_fail.update(comp)
        new_fail -= failed
        if not new_fail:
            break
        for n in new_fail:
            failed.add(n)
            alive_nbrs = [nb for nb in G_live.neighbors(n) if nb not in failed]
            if alive_nbrs and n in cur_loads:
                share = cur_loads[n] / len(alive_nbrs)
                for nb in alive_nbrs:
                    cur_loads[nb] = cur_loads.get(nb, LOAD_FLOOR) + share
            if n in G_live:
                G_live.remove_node(n)

    if not weighted:
        return len(failed) / G.number_of_nodes()
    else:
        total_demand = sum(demand_lookup.get(n, 0.0) for n in G.nodes())
        failed_demand = sum(demand_lookup.get(n, 0.0) for n in failed)
        return failed_demand / total_demand if total_demand > 0 else np.nan


# ---------------------------------------------------------------------------
# 4. Primary specification: raw cascade impact, alpha = 0.5
# ---------------------------------------------------------------------------
records = []
for node in G.nodes():
    impact_raw = motter_lai_cascade(G, node, alpha=0.5, weighted=False)
    impact_dw  = motter_lai_cascade(G, node, alpha=0.5, weighted=True)
    records.append({
        "node": station_name.get(node, node),
        "Betweenness": btw_c[node],
        "Degree": degree_c[node],
        "Closeness": close_c[node],
        "Eigenvector": eig_c[node],
        "cascade_impact_raw": impact_raw,
        "cascade_impact_demand_weighted": impact_dw,
    })

df = pd.DataFrame(records)

print("\n=== Primary specification (raw, alpha=0.5), n =", len(df), "===")
for measure in ["Betweenness", "Degree", "Closeness", "Eigenvector"]:
    x = df[measure]
    if measure == "Betweenness":
        mask = x > 0
        rho, p = spearmanr(x[mask], df["cascade_impact_raw"][mask])
        print(f"  {measure:12s}: rho={rho:.3f}  p={p:.4f}  n={mask.sum()}")
    else:
        rho, p = spearmanr(x, df["cascade_impact_raw"])
        print(f"  {measure:12s}: rho={rho:.3f}  p={p:.4f}  n={len(df)}")

# ---------------------------------------------------------------------------
# 5. Sensitivity: demand-weighted impact and alpha in {0.2, 0.5, 0.8}
# ---------------------------------------------------------------------------
sens_rows = []
for alpha in [0.2, 0.5, 0.8]:
    impacts_raw, impacts_dw = [], []
    for node in G.nodes():
        impacts_raw.append(motter_lai_cascade(G, node, alpha=alpha, weighted=False))
        impacts_dw.append(motter_lai_cascade(G, node, alpha=alpha, weighted=True))
    tmp = pd.DataFrame({
        "node": [station_name.get(n, n) for n in G.nodes()],
        "Betweenness": [btw_c[n] for n in G.nodes()],
        "Degree": [degree_c[n] for n in G.nodes()],
        "Closeness": [close_c[n] for n in G.nodes()],
        "Eigenvector": [eig_c[n] for n in G.nodes()],
        "cascade_impact_raw": impacts_raw,
        "cascade_impact_demand_weighted": impacts_dw,
    })
    for measure in ["Betweenness", "Degree", "Closeness", "Eigenvector"]:
        for impact_col, spec_label in [("cascade_impact_raw", "raw"),
                                        ("cascade_impact_demand_weighted", "demand_weighted")]:
            x = tmp[measure]
            y = tmp[impact_col]
            if measure == "Betweenness":
                mask = x > 0
                rho, p = spearmanr(x[mask], y[mask])
                n_eff = int(mask.sum())
            else:
                rho, p = spearmanr(x, y)
                n_eff = len(tmp)
            sens_rows.append({
                "alpha": alpha,
                "specification": spec_label,
                "centrality_measure": measure,
                "n": n_eff,
                "spearman_rho": round(rho, 4),
                "p_value": round(p, 4),
            })

sens_df = pd.DataFrame(sens_rows)

# ---------------------------------------------------------------------------
# 6. Save outputs
# ---------------------------------------------------------------------------
os.makedirs(DATA_DIR, exist_ok=True)
for measure in ["Betweenness", "Degree", "Closeness", "Eigenvector"]:
    out = df[["node", measure, "cascade_impact_raw"]].copy()
    out.columns = ["node", "centrality", "cascade_impact"]
    if measure == "Betweenness":
        out = out[out["centrality"] > 0].reset_index(drop=True)
    path = os.path.join(DATA_DIR, f"cascade_{measure.lower()}_exact.csv")
    out.to_csv(path, index=False)
    print(f"Saved {path} (n={len(out)})")

sens_path = os.path.join(DATA_DIR, "cascade_sensitivity_specifications.csv")
sens_df.to_csv(sens_path, index=False)
print(f"Saved {sens_path}")

print("\nDone. This script computes correlations directly from the reconstructed "
      "exact-topology network; no values are hardcoded.")
