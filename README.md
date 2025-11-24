# The Efficiency–Vulnerability Paradox: Network Analysis of Freight Rail Resilience, Economic Synergy, and Governance Mismatches in South Korea

This repository contains the **full replication package (data, code, and results)** for the study titled:

**"The Efficiency-Vulnerability Paradox: Network Analysis of Freight Rail Resilience, Economic Synergy, and Governance Mismatches in South Korea."**

---

## Abstract

This study analyzes the efficiency–vulnerability paradox in South Korea's freight rail network using network attack simulations, cascading failure modeling, and community detection. The scale-free network demonstrates acute vulnerability to targeted attacks, with systemic fragmentation occurring at a critical threshold of only 12–15% node removal based on composite centrality. Node centrality strongly correlates with cascading failure impact (ρ=0.834–0.861), and economic importance shows a significant association with resilience (r=0.789–0.873). The network exhibits a significant rich-club structure among major hubs (k≥5, φ_norm>1, p<0.05), enhancing efficiency while concentrating risk. Moderate modularity (Q=0.414) enables localized disruption containment, yet resilience varies regionally. Crucially, 34.2% of functional economic communities misalign with administrative boundaries, revealing a spatial governance mismatch. Findings advocate for "Strategic Resilience Engineering" focused on protecting critical hubs, building strategic redundancy, and implementing cross-jurisdictional governance aligned with functional economic geography.

---

## Keywords

Transportation Resilience; Freight Railway Networks; Network Vulnerability; Cascading Failures; Spatial Mismatch; South Korea Rail Policy and Governance

---

## Repository Structure

```
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
```

---

## Requirements and Installation

### 1. Clone the Repository

```bash
git clone https://github.com/[YourUsername]/korea-freight-rail-resilience-analysis.git
cd korea-freight-rail-resilience-analysis
```

### 2. Create & Activate a Virtual Environment (Optional)

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

### 3. Install Required Packages

```bash
pip install -r requirements.txt
```

---

## How to Reproduce the Analysis

### 1. Prepare Raw Data

Place all raw CSV/Excel data (timetables, coordinates, demand data) into the `data/` directory.

### 2. Open the Jupyter Notebook

```bash
jupyter lab
```

Open:
`notebooks/Full_Code.ipynb`

### 3. Run the Notebook Sequentially

The notebook performs:

1. **Data loading & preprocessing**
2. **Exploratory analysis**
3. **Hypothesis testing for H1–H8** (network attacks, cascading failures, modularity, rich club, spatial mismatch)
4. **Visualization & map generation**
5. **Export of all figures and results**

Outputs appear in the `results/` folder.

---

## Description of Key Outputs

| File / Folder                             | Hypothesis | Description                                                |
| ----------------------------------------- | ---------- | ---------------------------------------------------------- |
| `final_missing_data_analysis.png`         | –          | Missing-data visualization before/after interpolation      |
| `final_data_analysis_updated.png`         | –          | Summary dashboard of cleaned data                          |
| `H1-H5_enhanced_analysis/`                | H1–H5      | Detailed statistical results + plots                       |
| `H6_regional_resilience_detailed.png`     | H6         | Resilience comparison across administrative regions        |
| `H7_rich_club_detailed.png`               | H7         | Rich-club coefficient φ(k) plot                            |
| `H8_network_improved.png`                 | H8         | Map of economic communities                                |
| `H8_community_sizes.png`                  | H8         | Bar chart of community sizes                               |
| `H8_communities_enhanced_no_overlap.html` | H8         | Interactive map of functional vs administrative boundaries |
| `H8_station_density_heatmap.html`         | H8         | Interactive heatmap of station density                     |

---

## License

This project is distributed under the **MIT License**.
See the `LICENSE` file for full terms.

---

## Uploading Your Repository to GitHub

### **Method A — Web Upload**

1. Create a new GitHub repository
2. **Add file → Upload files**
3. Drag-and-drop the entire project folder
4. Commit changes

### **Method B — Command Line**

```bash
git init
git add .
git commit -m "Initial commit of replication package"
git branch -M main
git remote add origin https://github.com/[YourUsername]/korea-freight-rail-resilience-analysis.git
git push -u origin main
```

---
