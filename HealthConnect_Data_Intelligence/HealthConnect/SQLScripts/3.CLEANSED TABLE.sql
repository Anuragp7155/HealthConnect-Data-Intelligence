USE dev_HealthConnect_cleansed;

CREATE TABLE dbo.cleansed_patients
(
    patient_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    date_of_birth DATE,
    state_code CHAR(2),
    city VARCHAR(50),
    phone VARCHAR(15),
    load_date DATE
);




TRUNCATE TABLE dbo.cleansed_patients;

INSERT INTO dbo.cleansed_patients
(
    patient_id,
    first_name,
    last_name,
    gender,
    date_of_birth,
    state_code,
    city,
    phone,
    load_date
)


SELECT
    patient_id,
    UPPER(LTRIM(RTRIM(first_name))),
    UPPER(LTRIM(RTRIM(last_name))),
    UPPER(LTRIM(RTRIM(gender))),
    date_of_birth,
    UPPER(LTRIM(RTRIM(state_code))),
    UPPER(LTRIM(RTRIM(city))),
    LTRIM(RTRIM(phone)),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_patients;

/*
select * from dbo.cleansed_patients

SELECT *
FROM dbo.cleansed_patients
WHERE patient_id IS NULL;
*/



CREATE TABLE dbo.cleansed_providers
(
    provider_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialty VARCHAR(50),
    npi VARCHAR(20),
    load_date DATE
);


TRUNCATE TABLE dbo.cleansed_providers;

INSERT INTO dbo.cleansed_providers
(
    provider_id,
    first_name,
    last_name,
    specialty,
    npi,
    load_date
)
SELECT
    provider_id,
    UPPER(LTRIM(RTRIM(first_name))),
    UPPER(LTRIM(RTRIM(last_name))),
    UPPER(LTRIM(RTRIM(specialty))),
    LTRIM(RTRIM(npi)),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_providers;

/*
SELECT TOP 20 *
FROM dbo.cleansed_providers;

SELECT *
FROM dbo.cleansed_providers
WHERE provider_id IS NULL;
*/

CREATE TABLE dbo.cleansed_payers
(
    payer_id INT,
    payer_name VARCHAR(100),
    load_date DATE
);

TRUNCATE TABLE dbo.cleansed_payers;

INSERT INTO dbo.cleansed_payers
(
    payer_id,
    payer_name,
    load_date
)
SELECT
    payer_id,
    UPPER(LTRIM(RTRIM(payer_name))),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_payers;

--------



CREATE TABLE dbo.cleansed_encounters
(
    encounter_id INT,
    patient_id INT,
    provider_id INT,
    encounter_type VARCHAR(10),
    encounter_start DATETIME,
    encounter_end DATETIME,
    height_cm INT,
    weight_kg FLOAT,
    systolic_bp INT,
    diastolic_bp INT,
    load_date DATE
);

TRUNCATE TABLE dbo.cleansed_encounters;

INSERT INTO dbo.cleansed_encounters
(
    encounter_id,
    patient_id,
    provider_id,
    encounter_type,
    encounter_start,
    encounter_end,
    height_cm,
    weight_kg,
    systolic_bp,
    diastolic_bp,
    load_date
)
SELECT
    encounter_id,
    patient_id,
    provider_id,
    UPPER(LTRIM(RTRIM(encounter_type))),
    encounter_start,
    encounter_end,
    height_cm,
    weight_kg,
    systolic_bp,
    diastolic_bp,
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_encounters;


----

CREATE TABLE dbo.cleansed_diagnoses
(
    diagnosis_id INT,
    encounter_id INT,
    diagnosis_description VARCHAR(100),
    is_primary VARCHAR(10),
    load_date DATE
);

TRUNCATE TABLE dbo.cleansed_diagnoses;

INSERT INTO dbo.cleansed_diagnoses
(
    diagnosis_id,
    encounter_id,
    diagnosis_description,
    is_primary,
    load_date
)
SELECT
    diagnosis_id,
    encounter_id,
    UPPER(LTRIM(RTRIM(diagnosis_description))),
    CASE
        WHEN is_primary = 1 THEN 'TRUE'
        WHEN is_primary = 0 THEN 'FALSE'
    END,
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_diagnoses;

--------

CREATE TABLE dbo.cleansed_procedures
(
    procedure_id INT,
    encounter_id INT,
    procedure_description VARCHAR(100),
    load_date DATE
);

TRUNCATE TABLE dbo.cleansed_procedures;

INSERT INTO dbo.cleansed_procedures
(
    procedure_id,
    encounter_id,
    procedure_description,
    load_date
)
SELECT
    procedure_id,
    encounter_id,
    UPPER(LTRIM(RTRIM(procedure_description))),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_procedures;



-------------------

CREATE TABLE dbo.cleansed_medications
(
    medication_id INT,
    encounter_id INT,
    drug_name VARCHAR(50),
    route VARCHAR(20),
    dose VARCHAR(20),
    frequency VARCHAR(10),
    days_supply INT,
    load_date DATE
);

TRUNCATE TABLE dbo.cleansed_medications;

INSERT INTO dbo.cleansed_medications
(
    medication_id,
    encounter_id,
    drug_name,
    route,
    dose,
    frequency,
    days_supply,
    load_date
)
SELECT
    medication_id,
    encounter_id,
    UPPER(LTRIM(RTRIM(drug_name))),
    UPPER(LTRIM(RTRIM(route))),
    UPPER(LTRIM(RTRIM(dose))),
    UPPER(LTRIM(RTRIM(frequency))),
    days_supply,
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_medications;

select top 20 * from dbo.cleansed_medications


---------------------------------


CREATE TABLE dbo.cleansed_claims
(
    claim_id INT,
    encounter_id INT,
    payer_id INT,
    admit_date DATE,
    discharge_date DATE,
    total_billed_amount FLOAT,
    total_allowed_amount FLOAT,
    total_paid_amount FLOAT,
    claim_status VARCHAR(20),
    load_date DATE
);

TRUNCATE TABLE dbo.cleansed_claims;

INSERT INTO dbo.cleansed_claims
(
    claim_id,
    encounter_id,
    payer_id,
    admit_date,
    discharge_date,
    total_billed_amount,
    total_allowed_amount,
    total_paid_amount,
    claim_status,
    load_date
)
SELECT
    claim_id,
    encounter_id,
    payer_id,
    admit_date,
    discharge_date,
    total_billed_amount,
    total_allowed_amount,
    total_paid_amount,
    UPPER(LTRIM(RTRIM(claim_status))),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_claims;






---------check------

SELECT 'cleansed_patients' AS table_name,
       COUNT(*) AS row_count
FROM dbo.cleansed_patients

UNION ALL

SELECT 'cleansed_providers',
       COUNT(*)
FROM dbo.cleansed_providers

UNION ALL

SELECT 'cleansed_payers',
       COUNT(*)
FROM dbo.cleansed_payers

UNION ALL

SELECT 'cleansed_encounters',
       COUNT(*)
FROM dbo.cleansed_encounters

UNION ALL

SELECT 'cleansed_diagnoses',
       COUNT(*)
FROM dbo.cleansed_diagnoses

UNION ALL

SELECT 'cleansed_procedures',
       COUNT(*)
FROM dbo.cleansed_procedures

UNION ALL

SELECT 'cleansed_medications',
       COUNT(*)
FROM dbo.cleansed_medications

UNION ALL

SELECT 'cleansed_claims',
       COUNT(*)
FROM dbo.cleansed_claims;
