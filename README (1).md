# Wafer Yield Intelligence

**Yield analysis, forecasting and an AI assistant for a semiconductor fab.**
A consulting-style portfolio project built in Microsoft Fabric, delivered in Agile (Scrum) sprints and tracked in Jira.

> The client (Nexora Semiconductor) and the dataset are fictional/synthetic and used for learning purposes.

## Problem statement
Average wafer yield is about 46% and swings from 31% to 69% between lots with no clear explanation. Yield engineers need to:
1. understand what drives the yield loss,
2. predict low-yield wafers early enough to intervene, and
3. get answers from the data quickly, in plain English.

Full project brief: [`docs/Semiconductor_Yield_Consulting_Project_Brief.pdf`](docs/Semiconductor_Yield_Consulting_Project_Brief.pdf)

## Data
1,250 wafers, 50 lots (25 wafers each), 28 columns, 1 Jan to 19 Feb 2023.
Product types: CPU, GPU, FPGA, ASIC, Memory. Technology nodes: 7nm to 28nm.
Columns cover tools, process settings, inline metrology, defects, electrical tests and the target `yield`.

## Tech stack
| Layer | Tool |
|---|---|
| Storage | Microsoft Fabric Lakehouse (raw and clean tables) |
| Cleaning, EDA, ML | Fabric Notebooks (Python: pandas, scipy, scikit-learn, LightGBM) |
| SQL | Lakehouse SQL analytics endpoint (views) |
| Dashboard | Power BI (semantic model and report) |
| AI assistant | Claude, with a tested prompt library |
| Project management | Jira (Scrum, 3 sprints x 2 days) |

## Repository structure
```
notebooks/   Python notebooks (data foundation, root cause, ML)
sql/         SQL views for the dashboard
data/        Source dataset (synthetic)
dashboard/   Power BI files and screenshots
prompts/     AI copilot prompts and test set
docs/        Project brief, findings, deck
```

## Project plan
| Sprint | Goal |
|---|---|
| Sprint 1 - Data Foundation | Clean, load and understand the data; SQL views; root-cause analysis |
| Sprint 2 - Dashboard and ML | Power BI dashboard; Early-Warning and Diagnostic models |
| Sprint 3 - AI and Delivery | AI yield copilot; recommendations; executive deck |

## Definition of Done
- Notebook runs top to bottom without errors
- Findings written in plain English
- Work saved to this repository
- Jira card updated with a result comment

## Data-quality findings so far
- No missing values and no duplicate wafers; 25 wafers in every lot
- 251 of 1,250 wafers (20.1%) have yield below 0.30 (assumed low-yield threshold, to confirm with client)
- Tools, product, node and date are the same for all wafers in a lot, so those factors have only 50 independent observations (confounded with lot effects)
- 7nm and 10nm average 0.59 yield versus 0.34 for 14-28nm, which is unusual and raised as a client question
- defect_count and defect_density are nearly the same information (correlation 0.96)

## Modelling principle
Two models, to avoid data leakage:
- **Early-Warning model:** tool, product, node and process settings only (available before final test)
- **Diagnostic model:** adds metrology and electrical tests to explain why a wafer failed

## Status
- [x] Sprint 0: repo, Jira backlog, Fabric Lakehouse
- [ ] Sprint 1: data foundation and root-cause analysis (in progress)
- [ ] Sprint 2: dashboard and ML
- [ ] Sprint 3: AI copilot and delivery
