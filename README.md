# HealthConnect Data Intelligence

A SQL Server-based healthcare data warehouse and analytics project that processes healthcare data through **RAW → CLEANSED → REFINED** layers and provides reporting through **11 KPI views**.

---

## 📌 Project Overview

**HealthConnect Data Intelligence** is a healthcare data warehouse project designed to consolidate healthcare data from multiple CSV source files into a structured SQL Server environment.

The project implements an end-to-end data pipeline:

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
```

The project demonstrates:

- Data ingestion
- Data cleansing
- Data transformation
- Stored procedures
- Dynamic SQL
- SCD Type 1
- Master procedure orchestration
- Pipeline logging
- Data validation
- KPI reporting
- Automated scheduling

---

# 🏗️ Project Architecture

```text
                         CSV SOURCE FILES
                               │
                               ▼
                  ┌─────────────────────────┐
                  │     RAW INGESTION       │
                  │       PROCEDURES        │
                  └────────────┬────────────┘
                               │
                               ▼
                     ┌─────────────────┐
                     │    RAW LAYER    │
                     │                 │
                     │ raw_patients    │
                     │ raw_providers   │
                     │ raw_payers      │
                     │ raw_encounters  │
                     │ raw_diagnoses   │
                     │ raw_procedures  │
                     │ raw_medications │
                     │ raw_claims      │
                     └────────┬────────┘
                              │
                              ▼
                 ┌──────────────────────────┐
                 │   RAW → CLEANSED         │
                 │      PROCEDURES          │
                 └────────────┬─────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  CLEANSED LAYER  │
                    │                  │
                    │ Standardization  │
                    │ Trimming         │
                    │ Uppercase        │
                    │ Load Date        │
                    └────────┬─────────┘
                             │
                             ▼
                 ┌──────────────────────────┐
                 │ CLEANSED → REFINED       │
                 │      PROCEDURES          │
                 │                          │
                 │       SCD TYPE 1         │
                 └────────────┬─────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   REFINED LAYER  │
                    │                  │
                    │ Reporting Data   │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │   11 KPI VIEWS   │
                    └────────┬─────────┘
                             │
                             ▼
                         REPORTING
```

---

# 📂 Data Sources

The project processes eight healthcare datasets:

1. Patients
2. Providers
3. Payers
4. Encounters
5. Diagnoses
6. Procedures
7. Medications
8. Claims

---

# 🗄️ Database Architecture

## 1️⃣ RAW Layer

Database:

```text
dev_HealthConnect_raw
```

The RAW layer stores data loaded from source CSV files with minimal transformation.

### RAW Tables

```text
raw_patients
raw_providers
raw_payers
raw_encounters
raw_diagnoses
raw_procedures
raw_medications
raw_claims
```

---

## 2️⃣ CLEANSED Layer

Database:

```text
dev_HealthConnect_Cleansed
```

The CLEANSED layer standardizes the RAW data.

### Transformations include:

- Removing leading/trailing spaces
- Converting text values to uppercase
- Standardizing values
- Converting specific fields
- Adding `load_date`

### CLEANSED Tables

```text
cleansed_patients
cleansed_providers
cleansed_payers
cleansed_encounters
cleansed_diagnoses
cleansed_procedures
cleansed_medications
cleansed_claims
```

---

## 3️⃣ REFINED Layer

Database:

```text
dev_HealthConnect_refined
```

The REFINED layer contains the final data used for reporting and KPI analysis.

### REFINED Tables

```text
refined_patients
refined_providers
refined_payers
refined_encounters
refined_diagnoses
refined_procedures
refined_medications
refined_claims
```

---

# 🔄 SCD Type 1

The **CLEANSED → REFINED** process uses **Slowly Changing Dimension Type 1**.

SCD Type 1 means that when an existing record changes, the old value is overwritten.

### Logic

```text
                 CLEANSED
                    │
                    ▼
             Does record exist?
                /          \
              NO            YES
              │              │
              ▼              ▼
           INSERT       Has data changed?
                          /          \
                        NO            YES
                        │              │
                        ▼              ▼
                    NO ACTION       UPDATE
```

### Example

Before:

```text
patient_id | city
-----------|--------
101        | NAGPUR
```

New CLEANSED data:

```text
patient_id | city
-----------|--------
101        | PUNE
```

SCD Type 1 updates the REFINED table:

```text
patient_id | city
-----------|--------
101        | PUNE
```

The old value `NAGPUR` is not retained.

### SCD Type 1 is implemented in:

```text
07.REFINED PROCEDURES.sql
```

---

# ⚙️ Stored Procedures

Stored procedures are used to perform the data loading and transformation operations.

They make the pipeline reusable and easier to automate.

---

## RAW Ingestion Procedures

The project contains separate procedures for each source.

```text
usp_Load_Raw_Patients
usp_Load_Raw_Providers
usp_Load_Raw_Payers
usp_Load_Raw_Encounters
usp_Load_Raw_Diagnoses
usp_Load_Raw_Procedures
usp_Load_Raw_Medications
usp_Load_Raw_Claims
```

### Purpose

These procedures:

1. Receive the CSV file path
2. Receive database/schema/table parameters
3. Truncate the target RAW table
4. Perform `BULK INSERT`
5. Load the CSV data into the RAW layer

Example:

```text
patients.csv
     ↓
usp_Load_Raw_Patients
     ↓
raw_patients
```

---

# 🔄 RAW → CLEANSED Procedures

The project contains procedures for loading each CLEANSED table.

```text
usp_Load_Cleansed_Patients
usp_Load_Cleansed_Providers
usp_Load_Cleansed_Payers
usp_Load_Cleansed_Encounters
usp_Load_Cleansed_Diagnoses
usp_Load_Cleansed_Procedures
usp_Load_Cleansed_Medications
usp_Load_Cleansed_Claims
```

### Purpose

These procedures:

- Read from RAW
- Trim values
- Convert text to uppercase
- Standardize values
- Add `load_date`
- Load the CLEANSED tables

Example:

```text
raw_patients
     ↓
usp_Load_Cleansed_Patients
     ↓
cleansed_patients
```

---

# 🔄 CLEANSED → REFINED Procedures

The project contains:

```text
usp_Load_Refined_Patients
usp_Load_Refined_Providers
usp_Load_Refined_Payers
usp_Load_Refined_Encounters
usp_Load_Refined_Diagnoses
usp_Load_Refined_Procedures
usp_Load_Refined_Medications
usp_Load_Refined_Claims
```

### Purpose

These procedures implement **SCD Type 1**.

They:

- Insert new records
- Update changed records
- Ignore unchanged records
- Update `last_updated_date` when changes occur

Example:

```text
cleansed_patients
       ↓
usp_Load_Refined_Patients
       ↓
refined_patients
```

---

# 🎛️ Master Procedures

Master procedures act as **orchestrators**.

Instead of manually executing every individual procedure, a master procedure calls the required child procedures.

### Pipeline structure

```text
RAW Child Procedures
        ↓
RAW Master Procedure
        ↓
RAW → CLEANSED Child Procedures
        ↓
CLEANSED Master Procedure
        ↓
CLEANSED → REFINED Child Procedures
        ↓
REFINED Master Procedure
        ↓
Pipeline Log
        ↓
KPI Reporting
```

This makes the pipeline easier to execute and automate.

---

# 📝 Pipeline Logging

The project uses a logging table:

```text
dbo.Pipeline_Log
```

### Columns

```text
Log_ID
Run_ID
Procedure_Name
Start_Time
End_Time
Status
Rows_Processed
Error_Message
```

### Example

```text
Procedure_Name              Status
------------------------------------------------
usp_Load_Refined_Patients   SUCCESS
usp_Load_Refined_Providers  SUCCESS
usp_Load_Refined_Payers     SUCCESS
usp_Load_Refined_Claims     SUCCESS
```

If a procedure fails:

```text
Status        = FAILED
Error_Message = <SQL error>
```

This allows pipeline execution to be monitored and troubleshooting to be performed.

---

# 📊 KPI / Reporting Layer

The project contains **11 KPI reporting views**.

---

## KPI 01 — Yearly Claim Trend

View:

```text
vw_KPI01_Yearly_Claim_Trend
```

Provides:

- Claim year
- Total claims
- Total claim amount
- Average paid claim amount

---

## KPI 02 — Payer Claims

View:

```text
vw_KPI02_Payer_Claims
```

Provides:

- Insurance payer
- Total claims
- Total paid claim amount

---

## KPI 03 — Current vs Previous Periods

View:

```text
vw_KPI03_Current_Previous_Periods
```

Provides:

- YTD
- QTD
- MTD
- WTD

comparisons between current and previous periods.

---

## KPI 04 — Provider Patient Engagement

View:

```text
vw_KPI04_Provider_Patient_Engagement
```

Analyzes provider visit activity and engagement over the reporting period.

---

## KPI 05 — Diagnosis Claim Cost

View:

```text
vw_KPI05_Diagnosis_Claim_Cost
```

Analyzes claim cost by diagnosis.

---

## KPI 06 — Yearly Visit Claim Cost

View:

```text
vw_KPI06_Yearly_Visit_Claim_Cost
```

Provides yearly:

- Visit counts
- Claim amounts
- Average claim cost

---

## KPI 07 — Gender Claim Analysis

View:

```text
vw_KPI07_Gender_Claim_Analysis
```

Analyzes claim activity and claim amounts by gender.

---

## KPI 08 — Most Prescribed Medications

View:

```text
vw_KPI08_Most_Prescribed_Medications
```

Ranks medications based on prescription frequency.

---

## KPI 09 — Age Group Claims

View:

```text
vw_KPI09_Age_Group_Claims
```

Analyzes claims across different age groups.

---

## KPI 10 — Inpatient Stay YoY

View:

```text
vw_KPI10_Inpatient_Stay_YoY
```

Analyzes year-over-year changes in average inpatient stay duration.

---

## KPI 11 — Paid Claim YoY

View:

```text
vw_KPI11_Paid_Claim_YoY
```

Analyzes:

- Total paid claim amount
- Previous year amount
- Amount change
- YoY growth percentage

---

# 👁️ Complete KPI View List

```text
vw_KPI01_Yearly_Claim_Trend
vw_KPI02_Payer_Claims
vw_KPI03_Current_Previous_Periods
vw_KPI04_Provider_Patient_Engagement
vw_KPI05_Diagnosis_Claim_Cost
vw_KPI06_Yearly_Visit_Claim_Cost
vw_KPI07_Gender_Claim_Analysis
vw_KPI08_Most_Prescribed_Medications
vw_KPI09_Age_Group_Claims
vw_KPI10_Inpatient_Stay_YoY
vw_KPI11_Paid_Claim_YoY
```

---

# 📁 Project Structure

```text
HealthConnect_Data_Intelligence/
│
├── HealthConnect/
│   │
│   ├── InboundFiles/
│   │   ├── patients_*.csv
│   │   ├── providers_*.csv
│   │   ├── payers_*.csv
│   │   ├── encounters_*.csv
│   │   ├── diagnoses_*.csv
│   │   ├── procedures_*.csv
│   │   ├── medications_*.csv
│   │   └── claims_*.csv
│   │
│   └── HealthConnect_Daily_Pipeline.bat
│
├── SQLScripts/
│   │
│   ├── 01.CREATE DATABASE.sql
│   ├── 02.BULK INSERT.sql
│   ├── 03.CLEANSED TABLE.sql
│   ├── 04.RAW LAYER INGESTION PROCEDURES.sql
│   ├── 05.RAW TO CLEANSED PROCEDURES.sql
│   ├── 06.REFINED TABLES.sql
│   ├── 07.REFINED PROCEDURES.sql
│   ├── 08.MASTER PROCEDURE.sql
│   ├── 09.LOG TABLE.sql
│   ├── 10.KPI OUTPUT.sql
│   ├── 11.TESTING & VALIDATION.sql
│   └── 12.HEALTHCONNECT_COMPLETE_MASTER.sql
│
├── Reports/
│   └── HealthConnect_KPI_Report.docx
│
└── README.md
```

---

# 📄 SQL File Responsibilities

| File | Purpose |
|---|---|
| `01.CREATE DATABASE.sql` | Creates RAW, CLEANSED and REFINED databases |
| `02.BULK INSERT.sql` | Loads CSV data into RAW tables |
| `03.CLEANSED TABLE.sql` | Creates CLEANSED layer tables |
| `04.RAW LAYER INGESTION PROCEDURES.sql` | Creates RAW loading procedures |
| `05.RAW TO CLEANSED PROCEDURES.sql` | Creates RAW → CLEANSED procedures |
| `06.REFINED TABLES.sql` | Creates REFINED layer tables |
| `07.REFINED PROCEDURES.sql` | Implements SCD Type 1 |
| `08.MASTER PROCEDURE.sql` | Orchestrates the pipeline |
| `09.LOG TABLE.sql` | Creates pipeline execution logging |
| `10.KPI OUTPUT.sql` | Creates 11 KPI reporting views |
| `11.TESTING & VALIDATION.sql` | Performs data and pipeline validation |
| `12.HEALTHCONNECT_COMPLETE_MASTER.sql` | Consolidated deployment script |

---

# 🛠️ Technologies Used

- **Microsoft SQL Server**
- **T-SQL**
- **SQL Server Management Studio (SSMS)**
- **Stored Procedures**
- **Dynamic SQL**
- **BULK INSERT**
- **SCD Type 1**
- **SQL Views**
- **CSV**
- **Windows Task Scheduler**
- **SQLCMD**

---

# ▶️ How to Run the Project

## Step 1 — Create Databases

Run:

```text
01.CREATE DATABASE.sql
```

This creates:

```text
dev_HealthConnect_raw
dev_HealthConnect_Cleansed
dev_HealthConnect_refined
```

---

## Step 2 — Create RAW Tables

Create the RAW layer tables.

---

## Step 3 — Place CSV Files

Place all eight CSV files inside:

```text
HealthConnect/InboundFiles/
```

---

## Step 4 — Create RAW Ingestion Procedures

Run:

```text
04.RAW LAYER INGESTION PROCEDURES.sql
```

---

## Step 5 — Create RAW → CLEANSED Procedures

Run:

```text
05.RAW TO CLEANSED PROCEDURES.sql
```

---

## Step 6 — Create REFINED Tables

Run:

```text
06.REFINED TABLES.sql
```

---

## Step 7 — Create REFINED Procedures

Run:

```text
07.REFINED PROCEDURES.sql
```

This creates the SCD Type 1 processing logic.

---

## Step 8 — Create Pipeline Log

Run:

```text
09.LOG TABLE.sql
```

---

## Step 9 — Create Master Procedures

Run:

```text
08.MASTER PROCEDURE.sql
```

---

## Step 10 — Create KPI Views

Run:

```text
10.KPI OUTPUT.sql
```

---

## Step 11 — Run Validation

Run:

```text
11.TESTING & VALIDATION.sql
```

---

# 🚀 Complete Deployment

The complete consolidated SQL implementation is available in:

```text
12.HEALTHCONNECT_COMPLETE_MASTER.sql
```

This contains the complete project implementation in execution order.

---

# ⏰ Pipeline Scheduling

The pipeline can be automated using Windows Task Scheduler.

```text
Windows Task Scheduler
        ↓
HealthConnect_Daily_Pipeline.bat
        ↓
SQLCMD
        ↓
Master Stored Procedure
        ↓
RAW
        ↓
CLEANSED
        ↓
REFINED
        ↓
Pipeline_Log
        ↓
KPI Views
```

The batch file executes the SQL Server master procedure using `sqlcmd`.

---

# 🧪 Testing & Validation

The project includes validation for:

### Data Validation

- Row counts
- Duplicate records
- NULL values
- Orphan records
- Data consistency

### Pipeline Validation

- Procedure execution
- SUCCESS / FAILED status
- Rows processed
- Error messages
- Execution time

### KPI Validation

- KPI view outputs
- Aggregations
- Year-over-year calculations
- Reporting results

---

# 📈 Project Outcomes

This project demonstrates an end-to-end SQL Server healthcare data pipeline with:

- Layered data warehouse architecture
- CSV data ingestion
- Data cleansing
- Data transformation
- Parameterized stored procedures
- Dynamic SQL
- SCD Type 1 implementation
- Master procedure orchestration
- Pipeline logging
- Automated scheduling
- 11 KPI reporting views
- Data quality validation

---

# 🎯 Learning Objectives

This project provides practical experience in:

```text
SQL Server
T-SQL
Data Warehousing
ETL / ELT
Stored Procedures
Dynamic SQL
SCD Type 1
Data Cleaning
Data Transformation
Data Validation
KPI Development
SQL Reporting
Pipeline Automation
```

---

# 👤 Author

## Anurag Patil

**Data Analyst | SQL | Python | Power BI**

### Skills

```text
SQL
T-SQL
Python
Pandas
NumPy
Matplotlib
Power BI
MySQL
PostgreSQL
Data Cleaning
Data Analysis
Data Visualization
Data Warehousing
ETL / Data Pipelines
```

---

# 📌 Project Purpose

This project was developed as a practical implementation of a healthcare data warehouse pipeline, demonstrating how raw healthcare data can be ingested, cleansed, transformed, maintained using SCD Type 1, validated, logged, and exposed through KPI reporting views.

---

## ⭐ Key Concept

```text
TABLES
   ↓
Store Data

STORED PROCEDURES
   ↓
Process / Transform / Load Data

MASTER PROCEDURES
   ↓
Orchestrate the Pipeline

PIPELINE LOG
   ↓
Track Execution

VIEWS
   ↓
Provide Reporting / KPI Results
```

**HealthConnect Data Intelligence — End-to-End Healthcare Data Warehouse & Analytics Pipeline.**
