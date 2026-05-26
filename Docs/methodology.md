# Methodology

## Project Focus
This project analyzes the 2026 Tamil Nadu Assembly Election using only official Election Commission of India (ECI) data. The analysis focuses on two storytelling themes:

1. Geographic Story  
2. Flip Story

The goal was to identify and communicate major electoral shifts through clear, newsroom-style storytelling without political interpretation or prediction.

---

## Tools Used
- PostgreSQL (SQL)
- Power BI
- Excel / CSV
- GitHub

---

## Data Preparation
- Standardized 2021 and 2026 election datasets
- Mapped constituencies into six regions:
  - Chennai Metro
  - North
  - Central
  - Kongu
  - Delta
  - South
- Extracted constituency winners for both years

---

## Geographic Story Methodology
The geographic analysis compared regional seat distribution between 2021 and 2026.

### Steps:
- Aggregated seats won by party across all six regions
- Calculated regional seat changes between elections
- Identified regions with major gains, losses, and disruptions
- Built region-wise comparison visuals and simplified political maps

The focus was on showing how Tamil Nadu’s political map changed regionally rather than statewide alone.

---

## Flip Story Methodology
The flip story analyzed constituencies where the winning party changed between 2021 and 2026.

### Steps:
- Compared constituency winners across both elections
- Identified flipped constituencies
- Classified flips by previous and new winning party
- Visualized seat movement using Sankey diagrams

This helped highlight structural political shifts across the state.

---


## Neutrality
This project avoids:
- Political commentary
- Predicting future elections
- Explaining voter behavior

The analysis only describes observable patterns in official election data.

---


## Reproducibility
All analysis steps, SQL queries, and dashboard transformations are reproducible through the files included in the GitHub repository.