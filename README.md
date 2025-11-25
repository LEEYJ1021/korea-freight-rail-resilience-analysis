-----
# The Efficiency-Vulnerability Paradox: Network Analysis of Freight Rail Resilience, Economic Synergy, and Governance Mismatches in South Korea

This repository contains the **full replication package (data, code, and results)** for the study titled:
**"The Efficiency-Vulnerability Paradox: Network Analysis of Freight Rail Resilience, Economic Synergy, and Governance Mismatches in South Korea."**

---

## Abstract
This study empirically investigates the efficiency–vulnerability paradox in South Korea's freight rail network by integrating network attack simulations, cascading failure modeling, and community detection. The network's scale-free topology confirms acute vulnerability to targeted attacks, with systemic fragmentation occurring at a critical threshold of only 12–15% node removal based on composite centrality, compared to 35–40% for random failures. Node centrality exhibits a strong, significant correlation with cascading failure impact (ρ=0.834–0.861), while economic importance is significantly associated with resilience metrics (r=0.789–0.873). Structurally, the network exhibits a significant rich-club structure among major hubs (k≥5, φ_norm>1, p<0.05), enhancing routing efficiency but concentrating systemic risk. Community detection reveals a moderate modular structure (Q=0.414), which facilitates localized disruption containment. Crucially, a spatial mismatch analysis demonstrates that 34.2% of functional economic communities misalign with administrative boundaries, revealing a fundamental governance mismatch. The findings advocate for a "Strategic Resilience Engineering" framework focused on (1) protecting critical hubs, (2) building strategic redundancy in the rich-club core, and (3) implementing cross-jurisdictional governance mechanisms aligned with functional economic geography rather than administrative borders.

---

## Keywords
Transportation Resilience; Freight Railway Networks; Network Vulnerability; Cascading Failures; Spatial Mismatch; South Korea Rail Policy and Governance

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
├── requirements.txt
├── LICENSE
└── README.md
````

-----

## Requirements and Installation

### 1\. Clone the Repository

```bash
git clone [https://github.com/](https://github.com/)[YourUsername]/korea-freight-rail-resilience-analysis.git
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

-----

## Data Source, Permissions & Licensing

| Dataset | Provider / Source | Acquisition Date | Access Rights / Notes | License / Terms |
| :--- | :--- | :--- | :--- | :--- |
| **Freight Timetables, Segment Frequencies, Tariffs, Stations, Volume Data** | Korea Railroad Corporation (Korail) internal reports and public disclosures | 2024-07 | Redistribution permitted for academic replication | Korail data reuse policy (contact Korail for extended rights) |
| **Geographic Coordinates & Station Locations** | OpenRailwayMap / KR railway GIS layers | 2024-08 | Open access for research / attribution required | OpenRailwayMap Terms |
| **Functional Community Boundaries & Administrative Maps** | Korean National Spatial Data Infrastructure (NSDI) | 2024-09 | Public domain (offered for research) | NSDI data license (CC-BY or NC depending on dataset; see metadata in `results/H1-H5_preliminary_analysis/dataset_metadata.json`) |
| **Interactive Map Tiles** | OpenStreetMap tiles via CartoDB Positron | On-the-fly | Free for non-commercial use per provider terms | OSM Tile Usage Policy, CartoDB Terms |

> **Note:** When reproducing the interactive maps, ensure compliance with the tile provider’s usage policy (CartoDB/OSM) and cite OpenRailwayMap/Korail for the base datasets.

-----

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

  * Preliminary data pipeline: `1_preliminary_analysis_pipeline.py` (see code block labeled “\#\#(2) 2단계 예비 분석 파이프라인\#\#”).
  * Enhanced hypothesis testing: `3_enhanced_hypothesis_analysis.py` (mirrored in the notebook segment for H1–H5).
  * H6–H8 composite analysis: core logic contained in the final notebook cell “\#\#H6, H7, H8\#\#”.

-----

## Description of Key Outputs & Notebook Mapping

| Output File | Hypothesis / Step | Origin Cell / Script | Reproduction Script |
| :--- | :--- | :--- | :--- |
| `final_missing_data_analysis.png` | Data completeness | `plot_final_missing_analysis()` (Notebook cell “comprehensive\_missing\_data\_handling”) | N/A (inside notebook) |
| `final_data_analysis_updated.png` | Final summary dashboard | `visualize_final_data()` (cell “FINAL DATA COLUMN & CONTENT ANALYSIS”) | N/A |
| `H1_attack_analysis.png` | H1 – Network attack comparison | `PublicationVisualizer._create_H1_attack_analysis_plot()` | `results/H1-H5_enhanced_analysis/academic_research_report.txt` references results / script `3_enhanced_hypothesis_analysis.py` |
| `H2_correlation_analysis.png` | H2 – Centrality vs impact | `_create_H2_correlation_analysis_plot()` | `3_enhanced_hypothesis_analysis.py` |
| `H3_economic_resilience.png` | H3 – Economic resilience scatter | `_create_H3_economic_resilience_plot()` | Same as above |
| `H4_tradeoff_analysis.png` | H4 – Efficiency/resilience bars | `_create_H4_tradeoff_analysis_plot()` | Same script |
| `H5_community_structure.png` | H5 – Community metrics | `_create_H5_community_structure_plot()` | Same |
| `H6_regional_resilience_detailed.png` | H6 – Regional resilience | Final H6/H8 cell’s plotting block | Inline script under cell “\#\#H6, H7, H8\#\#”, replicable via standalone `h6_h7_h8_analysis.py` if created |
| `H7_rich_club_detailed.png` | H7 – Rich-club coefficient | H7 plotting block (same cell) | Inline – see “H7: Rich-Club Visualization” section |
| `H8_community_sizes.png` | H8 – Community sizes | H8 community size chart block | Inline – final cell |
| `H8_network_improved.png` | H8 – Static community map | H8 static network visualization block | Inline – final cell |
| `H8_communities_enhanced_no_overlap.html` | H8 – Interactive community map | H8 interactive map creation block | Inline (Folium map generation in final cell) |
| `H8_station_density_heatmap.html` | H8 – Heatmap | H8 heatmap block | Same |

### Results Folder Scripts

The `results/H1-H5_enhanced_analysis/` folder contains:

  * `enhanced_analysis_results.json` (mirrors summary dict from `EnhancedRailwayAnalysis._save_enhanced_results()`).
  * `academic_research_report.txt` (human-readable narrative from `_save_academic_report()`).

For replicating visual outputs, re-run the `PublicationVisualizer.create_individual_plots()` methods after `EnhancedRailwayAnalysis.run_enhanced_analysis()`.

-----

## Governance & Policy Implications

  * The study supports **“Strategic Resilience Engineering”**: prioritize targeted redundancy, enhance governance coordination across mismatched jurisdictions, and focus risk mitigation on rich-club hubs.
  * Spatial mismatch (34.2% misaligned economic communities) reinforces the need to align administrative policies with functional freight flows.

-----

## License

This project is distributed under the **MIT License**.

See the `LICENSE` file for full terms.

-----

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
git remote add origin [https://github.com/](https://github.com/)[YourUsername]/korea-freight-rail-resilience-analysis.git
git push -u origin main
```
