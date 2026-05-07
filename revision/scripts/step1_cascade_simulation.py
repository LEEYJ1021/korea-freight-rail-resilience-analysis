"""
step1_cascade_simulation.py
===========================
Motter-Lai cascade failure simulation for the Korean Freight Rail Network (N=53).

Output
------
revision_ress/data/cascade_betweenness.csv
revision_ress/data/cascade_closeness.csv
revision_ress/data/cascade_degree.csv
revision_ress/data/cascade_eigenvector.csv

Each CSV has four columns:
  node            : station name
  seed            : random seed for the network realization
  centrality      : centrality value for this measure
  cascade_impact  : fraction of nodes failed after cascade  [0, 1]

Usage
-----
  python revision_ress/scripts/step1_cascade_simulation.py

Dependencies
------------
  networkx >= 2.8, numpy, pandas, scipy
"""

import warnings
import networkx as nx
import numpy as np
import pandas as pd
from scipy.stats import pearsonr, spearmanr

warnings.filterwarnings("ignore")

# ---------------------------------------------------------------------------
# 0.  Configuration
# ---------------------------------------------------------------------------
OUTPUT_DIR = "revision_ress/data"
ALPHA      = 0.50          # Motter-Lai tolerance parameter
SEEDS      = [42, 137, 256, 512, 1024, 2048, 4096, 8192]
LOAD_FLOOR = 0.003         # minimum initial load to prevent division-by-zero
MAX_ITER   = 40            # maximum cascade propagation iterations

# ---------------------------------------------------------------------------
# 1.  Station data  (paper Table 7 + Appendix)
# ---------------------------------------------------------------------------
STATION_NAMES = [
    "JecheonYard",      "BusanNewPort",     "Donghae",          "Obong",
    "Goedong",          "Yeongju",          "Dongsan",          "ShingwangyangPort",
    "Dodam",            "Busanjin",         "Cheoram",          "Hwangdeung",
    "Sapgyo",           "Ssangryong",       "Gwangyang",        "Suncheon",
    "DaejeonYard",      "Uiwang",           "Cheongju",         "Onsan",
    "Heungguksa",       "Okgye",            "Taegum",           "Deokso",
    "Gunsan",           "Gacheon",          "Incheon",          "Masan",
    "Yakmok",           "Ipseokri",         "Naju",             "Jeokryang",
    "Ganchi",           "Paldang",          "Doan",             "Mokpo",
    "Eumseong",         "Munsu",            "BugangCargo",      "Seokhang",
    "Shindong",         "Gaya",             "Jecheon",          "Gyeongju",
    "Heukseokri",       "Seokpo",           "Sillyewon",        "Taehwagang",
    "Iksan",            "Mureung",          "Susaek",           "Gwangwoondae",
    "Cheonan",
]
N = len(STATION_NAMES)  # 53

# Betweenness centrality from paper (Table 7)
BETWEENNESS = [
    0.513, 0.278, 0.185, 0.183, 0.166, 0.086, 0.141, 0.108, 0.061, 0.070,
    0.038, 0.079, 0.074, 0.038, 0.039, 0.046, 0.000, 0.039, 0.042, 0.006,
    0.038, 0.000, 0.014, 0.045, 0.009, 0.000, 0.000, 0.000, 0.026, 0.000,
    0.000, 0.038, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000,
    0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000,
    0.000, 0.000, 0.000,
]

# Degree centrality from paper (Table 7)
DEGREE_CENT = [
    0.327, 0.173, 0.192, 0.231, 0.173, 0.096, 0.058, 0.077, 0.154, 0.096,
    0.096, 0.058, 0.038, 0.058, 0.058, 0.038, 0.077, 0.077, 0.038, 0.077,
    0.038, 0.038, 0.077, 0.058, 0.038, 0.038, 0.038, 0.019, 0.038, 0.115,
    0.019, 0.038, 0.038, 0.019, 0.019, 0.019, 0.019, 0.019, 0.038, 0.019,
    0.019, 0.019, 0.019, 0.019, 0.019, 0.019, 0.019, 0.019, 0.019, 0.019,
    0.077, 0.058, 0.038,
]

BTW_LOOKUP = dict(zip(STATION_NAMES, BETWEENNESS))
DEG_LOOKUP = dict(zip(STATION_NAMES, DEGREE_CENT))

# ---------------------------------------------------------------------------
# 2.  Target degree sequence  (sum = 2 × 86 edges = 172)
# ---------------------------------------------------------------------------
np.random.seed(2025)

TARGET_DEG = [max(1, round(d * (N - 1))) for d in DEGREE_CENT]
diff = 172 - sum(TARGET_DEG)
for i in range(abs(diff)):
    if diff > 0:
        TARGET_DEG[i % N] += 1
    else:
        TARGET_DEG[i % N] = max(1, TARGET_DEG[i % N] - 1)

assert sum(TARGET_DEG) == 172, f"Degree sum {sum(TARGET_DEG)} ≠ 172"

# ---------------------------------------------------------------------------
# 3.  Network construction
# ---------------------------------------------------------------------------
def build_network(seed: int) -> nx.Graph:
    """
    Configuration-model network with self-loops removed, isolated nodes
    attached to JecheonYard, and connectivity guaranteed.
    """
    G = nx.Graph(nx.configuration_model(TARGET_DEG, seed=seed))
    G.remove_edges_from(nx.selfloop_edges(G))
    G = nx.relabel_nodes(G, {i: STATION_NAMES[i] for i in range(N)})

    for node in list(G.nodes()):
        if G.degree(node) == 0:
            G.add_edge(node, STATION_NAMES[0])  # connect to JecheonYard

    comps = list(nx.connected_components(G))
    while len(comps) > 1:
        G.add_edge(list(comps[0])[0], list(comps[1])[0])
        comps = list(nx.connected_components(G))

    return G

# ---------------------------------------------------------------------------
# 4.  Motter-Lai hybrid cascade simulation
# ---------------------------------------------------------------------------
def motter_lai_cascade(G: nx.Graph, failed_node: str, alpha: float) -> float:
    """
    Simulate cascading failure after the initial failure of `failed_node`.

    Load  L_i  = max(betweenness_paper[i], LOAD_FLOOR)
    Capacity C_i = (1 + alpha) * L_i   (fixed at t = 0)

    Propagation:
      1. Remove failed_node; redistribute its load to surviving neighbours.
      2. Repeat: nodes whose redistributed load exceeds capacity fail.
      3. Repeat: nodes isolated from the LCC fail.

    Returns
    -------
    float
        Fraction of all N nodes that are non-functional at cascade end.
    """
    init_loads = {n: max(BTW_LOOKUP.get(n, 0.0), LOAD_FLOOR) for n in G.nodes()}
    capacities = {n: (1.0 + alpha) * v for n, v in init_loads.items()}
    cur_loads  = dict(init_loads)

    failed  = {failed_node}
    G_live  = G.copy()
    G_live.remove_node(failed_node)

    # Initial load redistribution
    nbrs = list(G.neighbors(failed_node))
    if nbrs:
        share = init_loads[failed_node] / len(nbrs)
        for nb in nbrs:
            cur_loads[nb] = cur_loads.get(nb, LOAD_FLOOR) + share

    for _ in range(MAX_ITER):
        new_fail = set()

        # (A) Capacity overload
        for n in G_live.nodes():
            if cur_loads.get(n, 0.0) > capacities.get(n, float("inf")):
                new_fail.add(n)

        # (B) LCC isolation
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

    return len(failed) / N

# ---------------------------------------------------------------------------
# 5.  Run simulation across all seeds and nodes
# ---------------------------------------------------------------------------
records = []
for seed in SEEDS:
    G = build_network(seed)
    print(
        f"seed={seed:5d} | nodes={G.number_of_nodes()} "
        f"| edges={G.number_of_edges()} "
        f"| connected={nx.is_connected(G)}"
    )

    closeness   = nx.closeness_centrality(G)
    try:
        eigenvector = nx.eigenvector_centrality(G, max_iter=2000)
    except nx.PowerIterationFailedConvergence:
        eigenvector = nx.eigenvector_centrality_numpy(G)

    for node in G.nodes():
        impact = motter_lai_cascade(G, node, alpha=ALPHA)
        records.append(
            {
                "node":          node,
                "seed":          seed,
                "Betweenness":   BTW_LOOKUP.get(node, 0.0),
                "Degree":        DEG_LOOKUP.get(node, 0.0),
                "Closeness":     closeness[node],
                "Eigenvector":   eigenvector[node],
                "cascade_impact": impact,
            }
        )

df = pd.DataFrame(records)
print(f"\nTotal records: {len(df)}")
print(df["cascade_impact"].describe().round(4))

# ---------------------------------------------------------------------------
# 6.  Correlation summary
# ---------------------------------------------------------------------------
print("\n=== Pearson r and Spearman ρ (centrality → cascade_impact) ===")
for measure in ["Betweenness", "Degree", "Closeness", "Eigenvector"]:
    r,   _ = pearsonr(df[measure], df["cascade_impact"])
    rho, _ = spearmanr(df[measure], df["cascade_impact"])
    print(f"  {measure:15s}: r = {r:.3f}  ρ = {rho:.3f}")

# ---------------------------------------------------------------------------
# 7.  Save CSVs
# ---------------------------------------------------------------------------
import os
os.makedirs(OUTPUT_DIR, exist_ok=True)

for measure in ["Betweenness", "Degree", "Closeness", "Eigenvector"]:
    out = df[["node", "seed", measure, "cascade_impact"]].copy()
    out.columns = ["node", "seed", "centrality", "cascade_impact"]
    path = os.path.join(OUTPUT_DIR, f"cascade_{measure.lower()}.csv")
    out.to_csv(path, index=False)
    r, _ = pearsonr(out["centrality"], out["cascade_impact"])
    print(
        f"Saved {path}  "
        f"(n={len(out)}, r={r:.3f}, "
        f"centrality=[{out.centrality.min():.3f}, {out.centrality.max():.3f}])"
    )

print("\n✅  Step 1 complete — 4 CSVs written to", OUTPUT_DIR)
