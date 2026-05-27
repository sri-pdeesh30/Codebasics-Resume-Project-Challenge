VIDEO WALTHROUGH LINK - https://drive.google.com/file/d/1qdiB6Qu4HvKvLyzaZ4fTypouJ3VTeG0-/view?usp=sharing

# DECODING THE 2026 TAMIL NADU ASSEMBLEY ELECTION  
*A storytelling-first data analysis project for AtliQ Media*

## Overview
This project analyzes the 2026 Tamil Nadu Assembly Election using only publicly available Election Commission of India (ECI) data.

The analysis focuses on two core stories:

- **The Geographic Story** — how political control shifted across Tamil Nadu’s six major regions between 2021 and 2026.
- **The Vote Share Story** — how party vote shares changed regionally, with special focus on the emergence of TVK and the redistribution of votes.

The goal of the project is not prediction or political commentary, but clear, neutral, data-driven storytelling for a media audience.

---

# Tech Stack

- **Database:** PostgreSQL  
- **Querying & Analysis:** SQL  
- **Visualization & Dashboarding:** Power BI  
- **Presentation:** Microsoft PowerPoint  

---

# Stories Covered

## 1. Geographic Story
Analyzes how seat distribution changed across Tamil Nadu’s six electoral regions:

- Chennai Metro
- North
- Central
- Kongu
- Delta
- South

Focus Areas:
- Regional seat gains and losses
- Breakdown of statewide dominance
- Region-wise political fragmentation

---

## 2. Vote Share Story
Analyzes vote-share movement between 2021 and 2026.

Focus Areas:
- Region-wise vote share shifts
- Emergence of TVK
- Comparative changes in DMK and AIADMK vote share
- Possible patterns of vote redistribution

---

# Data Sources

All data used in this project comes from public election datasets.

Primary Sources:
- Election Commission of India (ECI)
- ECI Statistical Reports
- Tamil Nadu Chief Electoral Officer
- Codebasics Starter Pack CSVs

No exit polls, opinion polls, news articles, or social media data were used.

---

# Reproducibility Guide

## Step 1 — Create PostgreSQL Database

Create a PostgreSQL database.

Example:

```sql
CREATE DATABASE tn_election_analysis;
```

---

## Step 2 — Import Data

Run:

```sql
sql/election_data_ingestion.sql
```

This script:
- Creates required tables
- Imports CSV datasets
- Cleans and structures election data

Make sure the CSV file paths inside the script are updated correctly for your local machine.

---

## Step 3 — Run Analytical Queries

Run:

```sql
sql/SQL_Analytics.sql
```

This file contains all analytical queries used for:
- Regional seat analysis
- Vote-share analysis
- Regional aggregations
- Story-specific metrics

---

## Step 4 — Open Power BI Dashboard

Open the Power BI template/dashboard file.

Then:
1. Reconnect the dashboard to your PostgreSQL database
2. Refresh the data model
3. Verify visuals and filters

---

## Step 5 — Review Presentation Deck

Open the PowerPoint presentation deck.

This deck contains:
- Final narrative structure
- Story framing
- Editorial recommendations
- Data limitations

---

# Methodology

The project follows a storytelling-first analytical workflow:

1. Data ingestion into PostgreSQL
2. Constituency-level aggregation
3. Region mapping using constituency master data
4. Comparative analysis between 2021 and 2026
5. Visualization in Power BI
6. Editorial narrative construction in PowerPoint

The analysis intentionally avoids:
- Predictive modeling
- Opinion-based conclusions
- Causal political claims

---

# Key Principles

- Neutral and non-partisan
- Fully reproducible
- Public-data only
- Storytelling-focused
- Region-first analysis

---

# Data Limitations

- Electoral patterns do not directly prove voter transfer.
- Regional classifications are analytical groupings and may simplify constituency-level variation.
- Statewide averages may not capture local political complexities.

---

# Submission Components

This repository contains:
- SQL scripts
- Power BI dashboard templates
- Presentation deck
- Documentation
- Reproducible workflow

---

# Acknowledgements

This project was created as part of the Resume Project Challenge by Codebasics for the fictional media organization AtliQ Media.

Official References:
- https://results.eci.gov.in/ResultAcGenMay2026/Index.htm
- https://eci.gov.in/statistical-reports
- https://elections.tn.gov.in/
