# HealthConnect Data Intelligence

A SQL Server-based healthcare data warehouse and analytics project that processes healthcare data through **RAW → CLEANSED → REFINED** layers and provides reporting through **11 KPI views**.

## Project Overview

The pipeline consolidates healthcare data from CSV source files into a structured SQL Server data warehouse.

```text
CSV Files
   ↓
RAW Layer
   ↓
CLEANSED Layer
   ↓
REFINED Layer
   ↓
KPI / Reporting Views
