"""
step2_nullmodel_validation.py
==============================
Two independent permutation-based null-model checks:

(A) Cascade-permutation null (Table 14 / H2):
    Randomly reassign cascade_impact values across nodes N_PERM times,
    holding each node's centrality value and the network topology fixed.
    Compares the observed Spearman rho against this null distribution.

(B) Economic-resilience permutation null (Table 16 / H3):
    Randomly reassign an economic indicator across nodes N_PERM times,
    holding resilience metric values fixed. Resilience metrics are
    constructed independently of the cascade simulation (Section 3.7):
      Structural Resilience  = mean z-score(degree, betweenness, closeness)
      Functional Resilience  = mean z-score(avg_speed) - mean z-score(utilization)
                               across each node's incident corridors
      Recovery Resilience    = local clustering coefficient
      Adaptive Resilience    = eigenvector centrality

Output
------
data/nullmodel_cascade_permutation.csv
data/nullmodel_economic_resilience.csv

Usage
-----
  python step2_nullmodel_validation.py   (run after step1)

Dependencies
------------
  networkx >= 2.8, numpy, pandas, scipy
"""

import os
import numpy as np
import pandas as pd
import networkx as nx
from scipy.stats import spearmanr, pearsonr

np.random.seed(42)
N_PERM = 5000
DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")

# ---------------------------------------------------------------------------
# (A) Cascade-permutation null
# ---------------------------------------------------------------------------
cascade_rows = []
for measure in ["Betweenness", "Degree", "Closeness", "Eigenvector"]:
    path = os.path.join(DATA_DIR, f"cascade_{measure.lower()}_exact.csv")
    d = pd.read_csv(path)
    x = d["centrality"].values
    y = d["cascade_impact"].values
    rho_obs, _ = spearmanr(x, y)

    null_rhos = np.empty(N_PERM)
    for i in range(N_PERM):
        y_perm = np.random.permutation(y)
        null_rhos[i], _ = spearmanr(x, y_perm)

    p_perm = (np.sum(np.abs(null_rhos) >= abs(rho_obs)) + 1) / (N_PERM + 1)
    cascade_rows.append({
        "centrality_measure": measure,
        "n": len(d),
        "observed_rho": round(rho_obs, 4),
        "null_mean": round(float(np.mean(null_rhos)), 4),
        "null_sd": round(float(np.std(null_rhos)), 4),
        "p_permutation": round(p_perm, 4),
    })

pd.DataFrame(cascade_rows).to_csv(
    os.path.join(DATA_DIR, "nullmodel_cascade_permutation.csv"), index=False
)
print("Saved nullmodel_cascade_permutation.csv")
print(pd.DataFrame(cascade_rows))

# ---------------------------------------------------------------------------
# (B) Economic-resilience permutation null
# ---------------------------------------------------------------------------
corr = pd.read_csv(os.path.join(DATA_DIR, "corridor_efficiency_summary.csv"))
cent = pd.read_csv(os.path.join(DATA_DIR, "centrality_data.csv"))

edges = corr[["origin", "dest"]].drop_duplicates()
G = nx.Graph()
G.add_nodes_from(cent["station_kor"])
for _, r in edges.iterrows():
    G.add_edge(r["origin"], r["dest"])

deg = nx.degree_centrality(G)
btw = nx.betweenness_centrality(G)
close = nx.closeness_centrality(G)
try:
    eig = nx.eigenvector_centrality(G, max_iter=2000)
except nx.PowerIterationFailedConvergence:
    eig = nx.eigenvector_centrality_numpy(G)
clustering = nx.clustering(G)

def zscore(s):
    return (s - s.mean()) / s.std(ddof=0)

nodes = list(G.nodes())
struct_res = zscore(pd.Series({n: deg[n] for n in nodes})) \
           + zscore(pd.Series({n: btw[n] for n in nodes})) \
           + zscore(pd.Series({n: close[n] for n in nodes}))
struct_res = struct_res / 3.0

# Functional resilience: per-node average speed minus utilization across incident corridors
node_speed = {}
node_util = {}
for n in nodes:
    incident = corr[(corr.origin == n) | (corr.dest == n)]
    node_speed[n] = incident["avg_speed_kmh"].mean() if len(incident) else np.nan
    node_util[n] = incident["utilization_ratio_trains"].mean() if len(incident) else np.nan

speed_s = pd.Series(node_speed)
util_s = pd.Series(node_util)
func_res = zscore(speed_s.fillna(speed_s.mean())) - zscore(util_s.fillna(util_s.mean()))

recovery_res = pd.Series({n: clustering[n] for n in nodes})
adaptive_res = pd.Series({n: eig[n] for n in nodes})

# Economic indicator proxies (from centrality_data.csv: demand / utilization / composite)
cent_i = cent.set_index("station_kor")
demand = cent_i["demand_centrality"].reindex(nodes)
weighted_degree = (cent_i["degree"] * cent_i["demand_centrality"]).reindex(nodes)
strategic_flow = cent_i["utilization_centrality"].reindex(nodes)
economic_multiplier = cent_i["composite_centrality"].reindex(nodes)

pairs = [
    ("TotalFreightDemand", demand, "StructuralResilience", struct_res),
    ("WeightedDegreeCentrality", weighted_degree, "FunctionalResilience", func_res),
    ("StrategicCommodityFlow", strategic_flow, "RecoveryResilience", recovery_res),
    ("EconomicMultiplierEffects", economic_multiplier, "AdaptiveResilience", adaptive_res),
]

econ_rows = []
for econ_name, econ_s, res_name, res_s in pairs:
    x = econ_s.values.astype(float)
    y = res_s.reindex(econ_s.index).values.astype(float)
    r_obs, _ = pearsonr(x, y)

    null_rs = np.empty(N_PERM)
    for i in range(N_PERM):
        y_perm = np.random.permutation(y)
        null_rs[i], _ = pearsonr(x, y_perm)

    p_perm = (np.sum(np.abs(null_rs) >= abs(r_obs)) + 1) / (N_PERM + 1)
    econ_rows.append({
        "economic_indicator": econ_name,
        "resilience_metric": res_name,
        "n": len(x),
        "pearson_r": round(r_obs, 4),
        "null_mean": round(float(np.mean(null_rs)), 4),
        "null_sd": round(float(np.std(null_rs)), 4),
        "p_permutation": round(p_perm, 4),
    })

pd.DataFrame(econ_rows).to_csv(
    os.path.join(DATA_DIR, "nullmodel_economic_resilience.csv"), index=False
)
print("\nSaved nullmodel_economic_resilience.csv")
print(pd.DataFrame(econ_rows))

print("\nNOTE: Total Freight Demand / Weighted Degree Centrality / Strategic Commodity Flow / "
      "Economic Multiplier Effects are reconstructed here as proxies from "
      "centrality_data.csv (demand_centrality, utilization_centrality, composite_centrality) "
      "because the original four-indicator dataset (Table 6) is not included in this public "
      "data package. Replace with the authors' verified indicator values before using these "
      "numbers in the manuscript.")
