--- CLEANSED → REFINED layer
USE dev_HealthConnect_refined;

CREATE TABLE dbo.refined_patients
(
    patient_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    date_of_birth DATE,
    state_code CHAR(2),
    city VARCHAR(50),
    phone VARCHAR(15),
    load_date DATE,
    last_updated_date DATE
);


-- INSERT new records
INSERT INTO dbo.refined_patients
(
    patient_id,
    first_name,
    last_name,
    gender,
    date_of_birth,
    state_code,
    city,
    phone,
    load_date,
    last_updated_date
)
SELECT
    c.patient_id,
    c.first_name,
    c.last_name,
    c.gender,
    c.date_of_birth,
    c.state_code,
    c.city,
    c.phone,
    c.load_date,
    c.load_date
FROM dev_HealthConnect_cleansed.dbo.cleansed_patients c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.refined_patients r
    WHERE r.patient_id = c.patient_id
);

select top 20 * from dbo.refined_patients

---update existing records only when something changed---
UPDATE r
SET
    r.first_name = c.first_name,
    r.last_name = c.last_name,
    r.gender = c.gender,
    r.date_of_birth = c.date_of_birth,
    r.state_code = c.state_code,
    r.city = c.city,
    r.phone = c.phone,
    r.last_updated_date = CAST(GETDATE() AS DATE)
FROM dbo.refined_patients r
INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_patients c
    ON r.patient_id = c.patient_id
WHERE
       ISNULL(r.first_name, '') <> ISNULL(c.first_name, '')
    OR ISNULL(r.last_name, '') <> ISNULL(c.last_name, '')
    OR ISNULL(r.gender, '') <> ISNULL(c.gender, '')
    OR ISNULL(r.date_of_birth, '1900-01-01') <> ISNULL(c.date_of_birth, '1900-01-01')
    OR ISNULL(r.state_code, '') <> ISNULL(c.state_code, '')
    OR ISNULL(r.city, '') <> ISNULL(c.city, '')
    OR ISNULL(r.phone, '') <> ISNULL(c.phone, '');



-----


CREATE TABLE dbo.refined_providers
(
    provider_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialty VARCHAR(50),
    npi VARCHAR(20),
    load_date DATE,
    last_updated_date DATE
);

INSERT INTO dbo.refined_providers
(
    provider_id,
    first_name,
    last_name,
    specialty,
    npi,
    load_date,
    last_updated_date
)
SELECT
    c.provider_id,
    c.first_name,
    c.last_name,
    c.specialty,
    c.npi,
    c.load_date,
    c.load_date
FROM dev_HealthConnect_cleansed.dbo.cleansed_providers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.refined_providers r
    WHERE r.provider_id = c.provider_id
);

UPDATE r
SET
    r.first_name = c.first_name,
    r.last_name = c.last_name,
    r.specialty = c.specialty,
    r.npi = c.npi,
    r.last_updated_date = CAST(GETDATE() AS DATE)
FROM dbo.refined_providers r
JOIN dev_HealthConnect_cleansed.dbo.cleansed_providers c
    ON r.provider_id = c.provider_id
WHERE
       ISNULL(r.first_name, '') <> ISNULL(c.first_name, '')
    OR ISNULL(r.last_name, '') <> ISNULL(c.last_name, '')
    OR ISNULL(r.specialty, '') <> ISNULL(c.specialty, '')
    OR ISNULL(r.npi, '') <> ISNULL(c.npi, '');



------

CREATE TABLE dbo.refined_payers
(
    payer_id INT,
    payer_name VARCHAR(100),
    load_date DATE,
    last_updated_date DATE
);



INSERT INTO dbo.refined_payers
(
    payer_id,
    payer_name,
    load_date,
    last_updated_date
)
SELECT
    c.payer_id,
    c.payer_name,
    c.load_date,
    c.load_date
FROM dev_HealthConnect_cleansed.dbo.cleansed_payers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.refined_payers r
    WHERE r.payer_id = c.payer_id
);


UPDATE r
SET
    r.payer_name = c.payer_name,
    r.last_updated_date = CAST(GETDATE() AS DATE)
FROM dbo.refined_payers r
JOIN dev_HealthConnect_cleansed.dbo.cleansed_payers c
    ON r.payer_id = c.payer_id
WHERE ISNULL(r.payer_name, '') <> ISNULL(c.payer_name, '');


---

CREATE TABLE dbo.refined_encounters
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
    load_date DATE,
    last_updated_date DATE
);

INSERT INTO dbo.refined_encounters
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
    load_date,
    last_updated_date
)
SELECT
    c.encounter_id,
    c.patient_id,
    c.provider_id,
    c.encounter_type,
    c.encounter_start,
    c.encounter_end,
    c.height_cm,
    c.weight_kg,
    c.systolic_bp,
    c.diastolic_bp,
    c.load_date,
    c.load_date
FROM dev_HealthConnect_cleansed.dbo.cleansed_encounters c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.refined_encounters r
    WHERE r.encounter_id = c.encounter_id
);

UPDATE r
SET
    r.patient_id = c.patient_id,
    r.provider_id = c.provider_id,
    r.encounter_type = c.encounter_type,
    r.encounter_start = c.encounter_start,
    r.encounter_end = c.encounter_end,
    r.height_cm = c.height_cm,
    r.weight_kg = c.weight_kg,
    r.systolic_bp = c.systolic_bp,
    r.diastolic_bp = c.diastolic_bp,
    r.last_updated_date = CAST(GETDATE() AS DATE)
FROM dbo.refined_encounters r
JOIN dev_HealthConnect_cleansed.dbo.cleansed_encounters c
    ON r.encounter_id = c.encounter_id
WHERE
       ISNULL(r.patient_id, -1) <> ISNULL(c.patient_id, -1)
    OR ISNULL(r.provider_id, -1) <> ISNULL(c.provider_id, -1)
    OR ISNULL(r.encounter_type, '') <> ISNULL(c.encounter_type, '')
    OR ISNULL(r.encounter_start, '1900-01-01') <> ISNULL(c.encounter_start, '1900-01-01')
    OR ISNULL(r.encounter_end, '1900-01-01') <> ISNULL(c.encounter_end, '1900-01-01')
    OR ISNULL(r.height_cm, -1) <> ISNULL(c.height_cm, -1)
    OR ISNULL(r.weight_kg, -1) <> ISNULL(c.weight_kg, -1)
    OR ISNULL(r.systolic_bp, -1) <> ISNULL(c.systolic_bp, -1)
    OR ISNULL(r.diastolic_bp, -1) <> ISNULL(c.diastolic_bp, -1);


    CREATE TABLE dbo.refined_diagnoses
(
    diagnosis_id INT,
    encounter_id INT,
    diagnosis_description VARCHAR(100),
    is_primary VARCHAR(10),
    load_date DATE,
    last_updated_date DATE
);

INSERT INTO dbo.refined_diagnoses
(
    diagnosis_id,
    encounter_id,
    diagnosis_description,
    is_primary,
    load_date,
    last_updated_date
)
SELECT
    c.diagnosis_id,
    c.encounter_id,
    c.diagnosis_description,
    c.is_primary,
    c.load_date,
    c.load_date
FROM dev_HealthConnect_cleansed.dbo.cleansed_diagnoses c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.refined_diagnoses r
    WHERE r.diagnosis_id = c.diagnosis_id
);


UPDATE r
SET
    r.encounter_id = c.encounter_id,
    r.diagnosis_description = c.diagnosis_description,
    r.is_primary = c.is_primary,
    r.last_updated_date = CAST(GETDATE() AS DATE)
FROM dbo.refined_diagnoses r
JOIN dev_HealthConnect_cleansed.dbo.cleansed_diagnoses c
    ON r.diagnosis_id = c.diagnosis_id
WHERE
       ISNULL(r.encounter_id, -1) <> ISNULL(c.encounter_id, -1)
    OR ISNULL(r.diagnosis_description, '') <> ISNULL(c.diagnosis_description, '')
    OR ISNULL(r.is_primary, '') <> ISNULL(c.is_primary, '');

----------

CREATE TABLE dbo.refined_procedures
(
    procedure_id INT,
    encounter_id INT,
    procedure_description VARCHAR(100),
    load_date DATE,
    last_updated_date DATE
);


INSERT INTO dbo.refined_procedures
(
    procedure_id,
    encounter_id,
    procedure_description,
    load_date,
    last_updated_date
)
SELECT
    c.procedure_id,
    c.encounter_id,
    c.procedure_description,
    c.load_date,
    c.load_date
FROM dev_HealthConnect_cleansed.dbo.cleansed_procedures c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.refined_procedures r
    WHERE r.procedure_id = c.procedure_id
);



UPDATE r
SET
    r.encounter_id = c.encounter_id,
    r.procedure_description = c.procedure_description,
    r.last_updated_date = CAST(GETDATE() AS DATE)
FROM dbo.refined_procedures r
JOIN dev_HealthConnect_cleansed.dbo.cleansed_procedures c
    ON r.procedure_id = c.procedure_id
WHERE
       ISNULL(r.encounter_id, -1) <> ISNULL(c.encounter_id, -1)
    OR ISNULL(r.procedure_description, '') <> ISNULL(c.procedure_description, '');



    --------


    CREATE TABLE dbo.refined_medications
(
    medication_id INT,
    encounter_id INT,
    drug_name VARCHAR(50),
    route VARCHAR(20),
    dose VARCHAR(20),
    frequency VARCHAR(10),
    days_supply INT,
    load_date DATE,
    last_updated_date DATE
);


INSERT INTO dbo.refined_medications
(
    medication_id,
    encounter_id,
    drug_name,
    route,
    dose,
    frequency,
    days_supply,
    load_date,
    last_updated_date
)
SELECT
    c.medication_id,
    c.encounter_id,
    c.drug_name,
    c.route,
    c.dose,
    c.frequency,
    c.days_supply,
    c.load_date,
    c.load_date
FROM dev_HealthConnect_cleansed.dbo.cleansed_medications c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.refined_medications r
    WHERE r.medication_id = c.medication_id
);


UPDATE r
SET
    r.encounter_id = c.encounter_id,
    r.drug_name = c.drug_name,
    r.route = c.route,
    r.dose = c.dose,
    r.frequency = c.frequency,
    r.days_supply = c.days_supply,
    r.last_updated_date = CAST(GETDATE() AS DATE)
FROM dbo.refined_medications r
JOIN dev_HealthConnect_cleansed.dbo.cleansed_medications c
    ON r.medication_id = c.medication_id
WHERE
       ISNULL(r.encounter_id, -1) <> ISNULL(c.encounter_id, -1)
    OR ISNULL(r.drug_name, '') <> ISNULL(c.drug_name, '')
    OR ISNULL(r.route, '') <> ISNULL(c.route, '')
    OR ISNULL(r.dose, '') <> ISNULL(c.dose, '')
    OR ISNULL(r.frequency, '') <> ISNULL(c.frequency, '')
    OR ISNULL(r.days_supply, -1) <> ISNULL(c.days_supply, -1);



-------------------

CREATE TABLE dbo.refined_claims
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
    load_date DATE,
    last_updated_date DATE
);



INSERT INTO dbo.refined_claims
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
    load_date,
    last_updated_date
)
SELECT
    c.claim_id,
    c.encounter_id,
    c.payer_id,
    c.admit_date,
    c.discharge_date,
    c.total_billed_amount,
    c.total_allowed_amount,
    c.total_paid_amount,
    c.claim_status,
    c.load_date,
    c.load_date
FROM dev_HealthConnect_cleansed.dbo.cleansed_claims c
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.refined_claims r
    WHERE r.claim_id = c.claim_id
);

UPDATE r
SET
    r.encounter_id = c.encounter_id,
    r.payer_id = c.payer_id,
    r.admit_date = c.admit_date,
    r.discharge_date = c.discharge_date,
    r.total_billed_amount = c.total_billed_amount,
    r.total_allowed_amount = c.total_allowed_amount,
    r.total_paid_amount = c.total_paid_amount,
    r.claim_status = c.claim_status,
    r.last_updated_date = CAST(GETDATE() AS DATE)
FROM dbo.refined_claims r
JOIN dev_HealthConnect_cleansed.dbo.cleansed_claims c
    ON r.claim_id = c.claim_id
WHERE
       ISNULL(r.encounter_id, -1) <> ISNULL(c.encounter_id, -1)
    OR ISNULL(r.payer_id, -1) <> ISNULL(c.payer_id, -1)
    OR ISNULL(r.admit_date, '1900-01-01') <> ISNULL(c.admit_date, '1900-01-01')
    OR ISNULL(r.discharge_date, '1900-01-01') <> ISNULL(c.discharge_date, '1900-01-01')
    OR ISNULL(r.total_billed_amount, 0) <> ISNULL(c.total_billed_amount, 0)
    OR ISNULL(r.total_allowed_amount, 0) <> ISNULL(c.total_allowed_amount, 0)
    OR ISNULL(r.total_paid_amount, 0) <> ISNULL(c.total_paid_amount, 0)
    OR ISNULL(r.claim_status, '') <> ISNULL(c.claim_status, '');


    ------------

    ---check---

SELECT 'refined_patients' AS table_name, COUNT(*) AS row_count
FROM dbo.refined_patients

UNION ALL
SELECT 'refined_providers', COUNT(*)
FROM dbo.refined_providers

UNION ALL
SELECT 'refined_payers', COUNT(*)
FROM dbo.refined_payers

UNION ALL
SELECT 'refined_encounters', COUNT(*)
FROM dbo.refined_encounters

UNION ALL
SELECT 'refined_diagnoses', COUNT(*)
FROM dbo.refined_diagnoses

UNION ALL
SELECT 'refined_procedures', COUNT(*)
FROM dbo.refined_procedures

UNION ALL
SELECT 'refined_medications', COUNT(*)
FROM dbo.refined_medications

UNION ALL
SELECT 'refined_claims', COUNT(*)
FROM dbo.refined_claims;



SELECT TOP 10 *
FROM dbo.refined_patients;

SELECT TOP 10 *
FROM dbo.refined_claims;


