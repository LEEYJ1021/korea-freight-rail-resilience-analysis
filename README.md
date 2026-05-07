# Freight Rail Network Resilience Analysis Framework: Efficiency-Vulnerability Trade-offs and Governance Mismatches

This repository contains a **generalizable analytical framework** for studying complex system resilience in freight rail networks, implementing the methodology from:
**"Complex System Resilience in Freight Rail Networks: Efficiency-Vulnerability Trade-offs and Governance Mismatches"**

---

## Abstract
This framework investigates the efficiency–vulnerability trade-off in national freight rail systems as a complex system resilience problem. The integrated methodology combines network topology analysis, multi-strategy attack simulations, cascading failure modeling, and community detection with economic and governance data. The analysis reveals how scale-free, rich-club architectures create systemic vulnerabilities where targeted removal of 12–15% of high-centrality nodes triggers fragmentation, compared to 35–40% for random failures. The framework quantifies relationships between node centrality and cascading failure impact (Spearman's ρ = 0.834–0.861), economic importance and resilience metrics (r = 0.789–0.873), and spatial mismatches between functional economic communities and administrative boundaries. The "Strategic Resilience Engineering" framework provides generalizable approaches for managing resilience trade-offs in complex, optimized infrastructure networks.

---

## Keywords
Complex System Resilience; Freight Railway Networks; Network Robustness and Vulnerability; Cascading Failures; Rich-Club Structure; Spatial Governance Mismatch; Resilience Engineering

---

## Repository Structure

```text
├─ figures/
│  ├─ final_data_analysis_updated.png
│  ├─ final_missing_data_analysis.png
│  ├─ H1_attack_analysis.png
│  ├─ H2_correlation_analysis.png
│  ├─ H3_economic_resilience.png
│  ├─ H4_tradeoff_analysis.png
│  ├─ H5_community_structure.png
│  ├─ H6_regional_resilience_detailed.png
│  ├─ H7_rich_club_detailed.png
│  ├─ H8_community_sizes.png
│  └─ H8_network_improved.png
├─ interactive_maps/
│  ├─ H8_communities_enhanced_no_overlap.html
│  └─ H8_station_density_heatmap.html
├─ notebooks/
│  └─ Full_Code.ipynb
├─ results/
│  ├─ H1-H5_enhanced_analysis/
│  │  ├─ academic_research_report.txt
│  │  └─ enhanced_analysis_results.json
│  └─ H1-H5_preliminary_analysis/
│     ├─ advanced_interactive_network_map.html
│     ├─ centrality_data.csv
│     ├─ comprehensive_analysis_dashboard.png
│     ├─ corridor_efficiency_summary.csv
│     └─ dataset_metadata.json
├─ revision/                        ← NEW: revision v2 materials
│  ├─ figures/
│  │  ├─ Fig2_merged_regional_map_v2.png
│  │  ├─ Fig6_nonlinear_fitting_v5.png
│  │  ├─ Fig8_richclub_v2.png
│  │  └─ Fig_centrality_distribution_v2.png
│  ├─ data/
│  │  ├─ cascade_betweenness.csv
│  │  ├─ cascade_closeness.csv
│  │  ├─ cascade_degree.csv
│  │  └─ cascade_eigenvector.csv
│  └─ scripts/
│     ├─ step1_cascade_simulation.py
│     ├─ revision_figures_v2.R
│     └─ fig6_nonlinear_fitting_v5.R
├── requirements.txt
├── LICENSE
└── README.md
```

---

## Requirements and Installation

### 1\. Clone the Repository

```bash
git clone https://github.com/LEEYJ1021/korea-freight-rail-resilience-analysis.git
cd korea-freight-rail-resilience-analysis
```

### 2\. Create & Activate a Virtual Environment (Optional)

**Windows**

```bash
python -m venv venv
.\venv\Scripts\activate
```

**macOS/Linux**

```bash
python3 -m venv venv
source venv/bin/activate
```

### 3\. Install Required Packages

```bash
pip install -r requirements.txt
```

---

## Data Source, Permissions & Licensing

| Dataset | Provider / Source | Acquisition Date | Access Rights / Notes | License / Terms |
| :--- | :--- | :--- | :--- | :--- |
| **Freight Timetables, Segment Frequencies, Tariffs, Stations, Volume Data** | Korea Railroad Corporation (Korail) internal reports and public disclosures | 2024-07 | Redistribution permitted for academic replication | Korail data reuse policy (contact Korail for extended rights) |
| **Geographic Coordinates & Station Locations** | OpenRailwayMap / KR railway GIS layers | 2024-08 | Open access for research / attribution required | OpenRailwayMap Terms |
| **Functional Community Boundaries & Administrative Maps** | Korean National Spatial Data Infrastructure (NSDI) | 2024-09 | Public domain (offered for research) | NSDI data license (CC-BY or NC depending on dataset; see metadata in `results/H1-H5_preliminary_analysis/dataset_metadata.json`) |
| **Interactive Map Tiles** | OpenStreetMap tiles via CartoDB Positron | On-the-fly | Free for non-commercial use per provider terms | OSM Tile Usage Policy, CartoDB Terms |

> **Note:** When reproducing the interactive maps, ensure compliance with the tile provider's usage policy (CartoDB/OSM) and cite OpenRailwayMap/Korail for the base datasets.

---

## How to Reproduce the Analysis

### 1\. Prepare Raw Data

Place all raw CSV/Excel data (timetables, coordinates, demand data) into the `data/` directory. Refer to `notebooks/Full_Code.ipynb` Cell **"PART 1: BASE DATA CURATION"** for the structure expected.

### 2\. Open the Jupyter Notebook

```bash
jupyter lab
```

Open `notebooks/Full_Code.ipynb`.

### 3\. Run the Notebook Sequentially

The notebook executes the following key stages (refer to the annotated section headers inside the notebook):

  * **Data loading & preprocessing** – Cells around `BASE DATA CURATION` and `COMPREHENSIVE MISSING DATA HANDLING`.
  * **Exploratory analysis & diagnostics** – Cells under `FINAL DATA COLUMN & CONTENT ANALYSIS`.
  * **Hypothesis testing for H1–H5** – `EnhancedRailwayAnalysis` and `PublicationVisualizer` classes defined in the notebook (mirrors scripts in `results/H1-H5_enhanced_analysis/`).
  * **Visualization & map generation** – Landmark cells:
      * `final_missing_data_analysis.png` – generated in `plot_final_missing_analysis()`.
      * `final_data_analysis_updated.png` – `visualize_final_data()` section.
      * `H1_attack_analysis.png` to `H5_community_structure.png` – `PublicationVisualizer.create_individual_plots()`.
      * `H6_regional_resilience_detailed.png` – final H6 plotting block in `H6, H7, H8` code cell.
      * `H7_rich_club_detailed.png`, `H8_community_sizes.png`, `H8_network_improved.png` – same large final cell for H7/H8 outputs.
      * Interactive map files under `interactive_maps/` – generated by `PreliminaryAnalysisPipeline.run()` and the H8 cell.
  * **Export of all figures and results** – Saves into `figures/`, `results/`, and `interactive_maps/`.

There are helper scripts embedded in the notebook and mirrored as standalone `.py` modules:

  * Preliminary data pipeline: `1_preliminary_analysis_pipeline.py` (see code block labeled `##(2) 2단계 예비 분석 파이프라인##`).
  * Enhanced hypothesis testing: `3_enhanced_hypothesis_analysis.py` (mirrored in the notebook segment for H1–H5).
  * H6–H8 composite analysis: core logic contained in the final notebook cell `##H6, H7, H8##`.

---

## Description of Key Outputs & Notebook Mapping

| Output File | Hypothesis / Step | Origin Cell / Script | Reproduction Script |
| :--- | :--- | :--- | :--- |
| `final_missing_data_analysis.png` | Data completeness | `plot_final_missing_analysis()` (Notebook cell "comprehensive\_missing\_data\_handling") | N/A (inside notebook) |
| `final_data_analysis_updated.png` | Final summary dashboard | `visualize_final_data()` (cell "FINAL DATA COLUMN & CONTENT ANALYSIS") | N/A |
| `H1_attack_analysis.png` | H1 – Network attack comparison | `PublicationVisualizer._create_H1_attack_analysis_plot()` | `results/H1-H5_enhanced_analysis/academic_research_report.txt` references results / script `3_enhanced_hypothesis_analysis.py` |
| `H2_correlation_analysis.png` | H2 – Centrality vs impact | `_create_H2_correlation_analysis_plot()` | `3_enhanced_hypothesis_analysis.py` |
| `H3_economic_resilience.png` | H3 – Economic resilience scatter | `_create_H3_economic_resilience_plot()` | Same as above |
| `H4_tradeoff_analysis.png` | H4 – Efficiency/resilience bars | `_create_H4_tradeoff_analysis_plot()` | Same script |
| `H5_community_structure.png` | H5 – Community metrics | `_create_H5_community_structure_plot()` | Same |
| `H6_regional_resilience_detailed.png` | H6 – Regional resilience | Final H6/H8 cell's plotting block | Inline script under cell `##H6, H7, H8##` |
| `H7_rich_club_detailed.png` | H7 – Rich-club coefficient | H7 plotting block (same cell) | Inline – see "H7: Rich-Club Visualization" section |
| `H8_community_sizes.png` | H8 – Community sizes | H8 community size chart block | Inline – final cell |
| `H8_network_improved.png` | H8 – Static community map | H8 static network visualization block | Inline – final cell |
| `H8_communities_enhanced_no_overlap.html` | H8 – Interactive community map | H8 interactive map creation block | Inline (Folium map generation in final cell) |
| `H8_station_density_heatmap.html` | H8 – Heatmap | H8 heatmap block | Same |

### Results Folder Scripts

The `results/H1-H5_enhanced_analysis/` folder contains:

  * `enhanced_analysis_results.json` (mirrors summary dict from `EnhancedRailwayAnalysis._save_enhanced_results()`).
  * `academic_research_report.txt` (human-readable narrative from `_save_academic_report()`).

For replicating visual outputs, re-run the `PublicationVisualizer.create_individual_plots()` methods after `EnhancedRailwayAnalysis.run_enhanced_analysis()`.

---

## Governance & Policy Implications

  * The study supports **"Strategic Resilience Engineering"**: prioritize targeted redundancy, enhance governance coordination across mismatched jurisdictions, and focus risk mitigation on rich-club hubs.
  * Spatial mismatch (34.2% misaligned economic communities) reinforces the need to align administrative policies with functional freight flows.

---

## License

This project is distributed under the **MIT License**.

See the `LICENSE` file for full terms.

---

## Uploading Your Repository to GitHub

### Method A — Web Upload

1.  Create a new GitHub repository
2.  Add file → Upload files
3.  Drag-and-drop the entire project folder
4.  Commit changes

### Method B — Command Line

```bash
git init
git add .
git commit -m "Initial commit of replication package"
git branch -M main
git remote add origin https://github.com/LEEYJ1021/korea-freight-rail-resilience-analysis.git
git push -u origin main
```

---

---

# Revision Materials — Review Response (v2)

This section documents all supplementary analyses, corrected figures, and simulation data added in response to reviewer comments. All materials live in the `revision/` folder and are fully self-contained: scripts read from `revision/data/` and write to `revision/figures/`.

---

## Summary of Changes

| Item | Original submission | Revised (v2) | Reviewer |
|------|--------------------|--------------|---------:|
| Figs. 2 & 3 | Two separate regional maps | Single integrated map | R1(6), R3(12) |
| Fig. 6 data | Synthetic calibration dataset | Actual Motter-Lai simulation (8 realizations × 53 nodes) | R1(7), R3(15) |
| Fig. 6 models | Linear fit only | Linear + Power-Law + Logit with AIC comparison | R1(7) |
| Fig. 6 Logit | — | Upper asymptote L ≤ 0.999; all predictions clipped to [0, 1] | R1(7) |
| Fig. 8 | k ≥ 11 included | k ≥ 11 excluded (N < 3; statistically unreliable) | R3(16) |
| Appendix Fig. A2 | Not present | Centrality distribution (degree, betweenness, scale-free test) | R1(5) |
| Table 11 Spearman ρ | 0.834–0.861 (synthetic) | **0.329–0.651** (actual simulation) | R1(7), R3(15) |

---

## Revised Figures

| File | Replaces | Key changes |
|------|----------|-------------|
| `Fig2_merged_regional_map_v2.png` | Figs. 2 & 3 | All 4 regions on one map; unified shape legend (▲ hub / ● station); corrected label nudges for dense southern area |
| `Fig6_nonlinear_fitting_v5.png` | Fig. 6 | Real simulation data; 3-model AIC comparison; Logit L ≤ 0.999; predictions bounded [0, 1]; Spearman ρ per panel |
| `Fig8_richclub_v2.png` | Fig. 8 | k ≥ 11 removed; FDR-adjusted p-values (Benjamini-Hochberg); 95% bootstrap CIs (1,000 iterations) |
| `Fig_centrality_distribution_v2.png` | *(new — Appendix A2)* | (a) degree histogram · (b) log-log scale-free test · (c) betweenness histogram · (d) degree vs. betweenness scatter with top-8 hubs |

---

## Simulation Data

Four CSV files in `revision/data/`, each with columns `node · seed · centrality · cascade_impact`.

| File | Centrality measure | n | Spearman ρ |
|------|--------------------|---|-----------|
| `cascade_betweenness.csv` | Betweenness (btw > 0 only) | 200 | 0.651*** |
| `cascade_degree.csv` | Degree | 424 | 0.589*** |
| `cascade_closeness.csv` | Closeness | 424 | 0.359*** |
| `cascade_eigenvector.csv` | Eigenvector | 424 | 0.329*** |

\*** p < 0.001 · Simulation: α = 0.50, seeds = [42, 137, 256, 512, 1024, 2048, 4096, 8192]

> **Note on Betweenness n = 200:** Stations with betweenness = 0 are excluded because their cascade impact reflects structural isolation from the largest connected component (LCC disconnection), not load-redistribution dynamics. Including them would conflate two mechanistically distinct failure modes.

### Model Fit Summary (AIC comparison, basis for revised Table 11)

AIC formula: n·log(RSS/n) + 2k. ΔAIC < −10 = strong evidence for nonlinear fit.

| Centrality | R²_linear | ΔAIC Power-Law | ΔAIC Logit | Pattern |
|-----------|-----------|---------------|-----------|---------|
| Betweenness | 0.630 | +2.1 | −10.4 | Near-linear power-law (mechanistically consistent with Motter-Lai Eq. 7 load proxy) |
| Degree | 0.502 | **−39.8** | **−36.0** | Strong nonlinear — finite path capacity saturation |
| Closeness | 0.206 | **−48.4** | **−98.8** | Strong nonlinear — load redistribution limit |
| Eigenvector | 0.365 | **−105.9** | **−94.7** | Strongest nonlinear — core saturation effect |

---

## Reproduction Scripts

Run in order:

### Step 1 — Cascade Simulation (Python)

Script: `revision/scripts/step1_cascade_simulation.py`

```bash
python revision/scripts/step1_cascade_simulation.py
# Produces: revision/data/cascade_betweenness.csv
#           revision/data/cascade_degree.csv
#           revision/data/cascade_closeness.csv
#           revision/data/cascade_eigenvector.csv
```

**What it does:** Constructs 8 configuration-model networks preserving the empirical Korean freight rail degree sequence (N = 53, E ≈ 86), then runs the Motter-Lai load-redistribution cascade simulation for every node in each realization.

**Python dependencies:** `networkx >= 2.8`, `numpy`, `pandas`, `scipy`

### Step 2 — Fig. 6 Nonlinear Fitting (R)

Script: `revision/scripts/fig6_nonlinear_fitting_v5.R`

```bash
Rscript revision/scripts/fig6_nonlinear_fitting_v5.R
# Reads:   revision/data/cascade_*.csv
# Produces: revision/figures/Fig6_nonlinear_fitting_v5.png
# Prints:   model comparison table to console (paste into rebuttal)
```

**R dependencies:** `ggplot2`, `patchwork`, `nls2`, `dplyr`, `scales`

### Step 3 — Fig. 2, Fig. 8, Fig. A2 (R)

Script: `revision/scripts/revision_figures_v2.R`

```bash
Rscript revision/scripts/revision_figures_v2.R
# Produces: revision/figures/Fig2_merged_regional_map_v2.png
#           revision/figures/Fig8_richclub_v2.png
#           revision/figures/Fig_centrality_distribution_v2.png
#           revision/figures/Fig2_merged_regional_map_v2.html  (interactive)
```

**R dependencies:** `ggplot2`, `ggrepel`, `patchwork`, `dplyr`, `scales`, `maps`, `leaflet`, `leaflet.extras`, `htmlwidgets`

---

## Centrality Distribution Summary (Appendix A2)

| Metric | Value | Interpretation |
|--------|-------|----------------|
| Scale-free exponent γ | 1.23 | Consistent with spatially embedded transport networks (Barthélemy, 2011, *Physics Reports*) |
| R² of log-log fit | 0.864 | Good power-law fit |
| Degree Gini | 0.447 | High concentration — hub-dominated topology |
| Betweenness Gini | 0.505 | Extreme bridging concentration at top hubs |

---

## Changelog

| Version | Date | Description |
|---------|------|-------------|
| v1 | 2025-09 | Initial version |
| v2 | 2026-05 | Major revision: actual Motter-Lai simulation; 3-model AIC comparison in Fig. 6; merged Fig. 2; k ≥ 11 excluded from Fig. 8; Appendix A2 added |
