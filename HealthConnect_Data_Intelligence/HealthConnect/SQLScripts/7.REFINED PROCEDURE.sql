USE dev_HealthConnect_refined;
GO


/*
   1. PATIENTS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Refined_Patients
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    UPDATE T
    SET
        T.first_name = S.first_name,
        T.last_name = S.last_name,
        T.gender = S.gender,
        T.date_of_birth = S.date_of_birth,
        T.state_code = S.state_code,
        T.city = S.city,
        T.phone = S.phone,
        T.load_date = S.load_date,
        T.last_updated_date = GETDATE()
    FROM dbo.refined_patients T
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_patients S
        ON T.patient_id = S.patient_id
    WHERE
        ISNULL(T.first_name, '''') <> ISNULL(S.first_name, '''')
        OR ISNULL(T.last_name, '''') <> ISNULL(S.last_name, '''')
        OR ISNULL(T.gender, '''') <> ISNULL(S.gender, '''')
        OR ISNULL(T.date_of_birth, ''19000101'') <> ISNULL(S.date_of_birth, ''19000101'')
        OR ISNULL(T.state_code, '''') <> ISNULL(S.state_code, '''')
        OR ISNULL(T.city, '''') <> ISNULL(S.city, '''')
        OR ISNULL(T.phone, '''') <> ISNULL(S.phone, '''');

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
        S.patient_id,
        S.first_name,
        S.last_name,
        S.gender,
        S.date_of_birth,
        S.state_code,
        S.city,
        S.phone,
        S.load_date,
        GETDATE()
    FROM ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_patients S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.refined_patients T
        WHERE T.patient_id = S.patient_id
    );';

    EXEC sp_executesql @SQL;
END;
GO


/* 
   2. PROVIDERS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Refined_Providers
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    UPDATE T
    SET
        T.first_name = S.first_name,
        T.last_name = S.last_name,
        T.specialty = S.specialty,
        T.npi = S.npi,
        T.load_date = S.load_date,
        T.last_updated_date = GETDATE()
    FROM dbo.refined_providers T
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_providers S
        ON T.provider_id = S.provider_id
    WHERE
        ISNULL(T.first_name, '''') <> ISNULL(S.first_name, '''')
        OR ISNULL(T.last_name, '''') <> ISNULL(S.last_name, '''')
        OR ISNULL(T.specialty, '''') <> ISNULL(S.specialty, '''')
        OR ISNULL(T.npi, '''') <> ISNULL(S.npi, '''');

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
        S.provider_id,
        S.first_name,
        S.last_name,
        S.specialty,
        S.npi,
        S.load_date,
        GETDATE()
    FROM ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_providers S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.refined_providers T
        WHERE T.provider_id = S.provider_id
    );';

    EXEC sp_executesql @SQL;
END;
GO


/*
   3. PAYERS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Refined_Payers
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    UPDATE T
    SET
        T.payer_name = S.payer_name,
        T.load_date = S.load_date,
        T.last_updated_date = GETDATE()
    FROM dbo.refined_payers T
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_payers S
        ON T.payer_id = S.payer_id
    WHERE
        ISNULL(T.payer_name, '''') <> ISNULL(S.payer_name, '''');

    INSERT INTO dbo.refined_payers
    (
        payer_id,
        payer_name,
        load_date,
        last_updated_date
    )
    SELECT
        S.payer_id,
        S.payer_name,
        S.load_date,
        GETDATE()
    FROM ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_payers S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.refined_payers T
        WHERE T.payer_id = S.payer_id
    );';

    EXEC sp_executesql @SQL;
END;
GO


/*
   4. ENCOUNTERS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Refined_Encounters
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    UPDATE T
    SET
        T.patient_id = S.patient_id,
        T.provider_id = S.provider_id,
        T.encounter_type = S.encounter_type,
        T.encounter_start = S.encounter_start,
        T.encounter_end = S.encounter_end,
        T.height_cm = S.height_cm,
        T.weight_kg = S.weight_kg,
        T.systolic_bp = S.systolic_bp,
        T.diastolic_bp = S.diastolic_bp,
        T.load_date = S.load_date,
        T.last_updated_date = GETDATE()
    FROM dbo.refined_encounters T
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_encounters S
        ON T.encounter_id = S.encounter_id
    WHERE
        ISNULL(T.patient_id, -1) <> ISNULL(S.patient_id, -1)
        OR ISNULL(T.provider_id, -1) <> ISNULL(S.provider_id, -1)
        OR ISNULL(T.encounter_type, '''') <> ISNULL(S.encounter_type, '''')
        OR ISNULL(T.encounter_start, ''19000101'') <> ISNULL(S.encounter_start, ''19000101'')
        OR ISNULL(T.encounter_end, ''19000101'') <> ISNULL(S.encounter_end, ''19000101'')
        OR ISNULL(T.height_cm, -1) <> ISNULL(S.height_cm, -1)
        OR ISNULL(T.weight_kg, -1) <> ISNULL(S.weight_kg, -1)
        OR ISNULL(T.systolic_bp, -1) <> ISNULL(S.systolic_bp, -1)
        OR ISNULL(T.diastolic_bp, -1) <> ISNULL(S.diastolic_bp, -1);

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
        S.encounter_id,
        S.patient_id,
        S.provider_id,
        S.encounter_type,
        S.encounter_start,
        S.encounter_end,
        S.height_cm,
        S.weight_kg,
        S.systolic_bp,
        S.diastolic_bp,
        S.load_date,
        GETDATE()
    FROM ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_encounters S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.refined_encounters T
        WHERE T.encounter_id = S.encounter_id
    );';

    EXEC sp_executesql @SQL;
END;
GO


/*
   5. DIAGNOSES
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Refined_Diagnoses
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    UPDATE T
    SET
        T.encounter_id = S.encounter_id,
        T.diagnosis_description = S.diagnosis_description,
        T.is_primary = S.is_primary,
        T.load_date = S.load_date,
        T.last_updated_date = GETDATE()
    FROM dbo.refined_diagnoses T
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_diagnoses S
        ON T.diagnosis_id = S.diagnosis_id
    WHERE
        ISNULL(T.encounter_id, -1) <> ISNULL(S.encounter_id, -1)
        OR ISNULL(T.diagnosis_description, '''') <> ISNULL(S.diagnosis_description, '''')
        OR ISNULL(T.is_primary, '''') <> ISNULL(S.is_primary, '''');

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
        S.diagnosis_id,
        S.encounter_id,
        S.diagnosis_description,
        S.is_primary,
        S.load_date,
        GETDATE()
    FROM ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_diagnoses S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.refined_diagnoses T
        WHERE T.diagnosis_id = S.diagnosis_id
    );';

    EXEC sp_executesql @SQL;
END;
GO


/*
   6. PROCEDURES
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Refined_Procedures
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    UPDATE T
    SET
        T.encounter_id = S.encounter_id,
        T.procedure_description = S.procedure_description,
        T.load_date = S.load_date,
        T.last_updated_date = GETDATE()
    FROM dbo.refined_procedures T
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_procedures S
        ON T.procedure_id = S.procedure_id
    WHERE
        ISNULL(T.encounter_id, -1) <> ISNULL(S.encounter_id, -1)
        OR ISNULL(T.procedure_description, '''') <> ISNULL(S.procedure_description, '''');

    INSERT INTO dbo.refined_procedures
    (
        procedure_id,
        encounter_id,
        procedure_description,
        load_date,
        last_updated_date
    )
    SELECT
        S.procedure_id,
        S.encounter_id,
        S.procedure_description,
        S.load_date,
        GETDATE()
    FROM ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_procedures S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.refined_procedures T
        WHERE T.procedure_id = S.procedure_id
    );';

    EXEC sp_executesql @SQL;
END;
GO


/*
   7. MEDICATIONS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Refined_Medications
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    UPDATE T
    SET
        T.encounter_id = S.encounter_id,
        T.drug_name = S.drug_name,
        T.route = S.route,
        T.dose = S.dose,
        T.frequency = S.frequency,
        T.days_supply = S.days_supply,
        T.load_date = S.load_date,
        T.last_updated_date = GETDATE()
    FROM dbo.refined_medications T
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_medications S
        ON T.medication_id = S.medication_id
    WHERE
        ISNULL(T.encounter_id, -1) <> ISNULL(S.encounter_id, -1)
        OR ISNULL(T.drug_name, '''') <> ISNULL(S.drug_name, '''')
        OR ISNULL(T.route, '''') <> ISNULL(S.route, '''')
        OR ISNULL(T.dose, '''') <> ISNULL(S.dose, '''')
        OR ISNULL(T.frequency, '''') <> ISNULL(S.frequency, '''')
        OR ISNULL(T.days_supply, -1) <> ISNULL(S.days_supply, -1);

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
        S.medication_id,
        S.encounter_id,
        S.drug_name,
        S.route,
        S.dose,
        S.frequency,
        S.days_supply,
        S.load_date,
        GETDATE()
    FROM ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_medications S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.refined_medications T
        WHERE T.medication_id = S.medication_id
    );';

    EXEC sp_executesql @SQL;
END;
GO


/* 
   8. CLAIMS
 */

CREATE OR ALTER PROCEDURE dbo.usp_Load_Refined_Claims
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    UPDATE T
    SET
        T.encounter_id = S.encounter_id,
        T.payer_id = S.payer_id,
        T.admit_date = S.admit_date,
        T.discharge_date = S.discharge_date,
        T.total_billed_amount = S.total_billed_amount,
        T.total_allowed_amount = S.total_allowed_amount,
        T.total_paid_amount = S.total_paid_amount,
        T.claim_status = S.claim_status,
        T.load_date = S.load_date,
        T.last_updated_date = GETDATE()
    FROM dbo.refined_claims T
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_claims S
        ON T.claim_id = S.claim_id
    WHERE
        ISNULL(T.encounter_id, -1) <> ISNULL(S.encounter_id, -1)
        OR ISNULL(T.payer_id, -1) <> ISNULL(S.payer_id, -1)
        OR ISNULL(T.admit_date, ''19000101'') <> ISNULL(S.admit_date, ''19000101'')
        OR ISNULL(T.discharge_date, ''19000101'') <> ISNULL(S.discharge_date, ''19000101'')
        OR ISNULL(T.total_billed_amount, 0) <> ISNULL(S.total_billed_amount, 0)
        OR ISNULL(T.total_allowed_amount, 0) <> ISNULL(S.total_allowed_amount, 0)
        OR ISNULL(T.total_paid_amount, 0) <> ISNULL(S.total_paid_amount, 0)
        OR ISNULL(T.claim_status, '''') <> ISNULL(S.claim_status, '''');

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
        S.claim_id,
        S.encounter_id,
        S.payer_id,
        S.admit_date,
        S.discharge_date,
        S.total_billed_amount,
        S.total_allowed_amount,
        S.total_paid_amount,
        S.claim_status,
        S.load_date,
        GETDATE()
    FROM ' + QUOTENAME(@DatabaseName) + N'.' +
        QUOTENAME(@SchemaName) + N'.cleansed_claims S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.refined_claims T
        WHERE T.claim_id = S.claim_id
    );';

    EXEC sp_executesql @SQL;
END;
GO



--RUNNING PROCEDURE


EXEC dbo.usp_Load_Refined_Patients
    @DatabaseName = 'dev_HealthConnect_Cleansed',
    @SchemaName = 'dbo';

EXEC dbo.usp_Load_Refined_Providers
    @DatabaseName = 'dev_HealthConnect_Cleansed',
    @SchemaName = 'dbo';

EXEC dbo.usp_Load_Refined_Payers
    @DatabaseName = 'dev_HealthConnect_Cleansed',
    @SchemaName = 'dbo';

EXEC dbo.usp_Load_Refined_Encounters
    @DatabaseName = 'dev_HealthConnect_Cleansed',
    @SchemaName = 'dbo';

EXEC dbo.usp_Load_Refined_Diagnoses
    @DatabaseName = 'dev_HealthConnect_Cleansed',
    @SchemaName = 'dbo';

EXEC dbo.usp_Load_Refined_Procedures
    @DatabaseName = 'dev_HealthConnect_Cleansed',
    @SchemaName = 'dbo';

EXEC dbo.usp_Load_Refined_Medications
    @DatabaseName = 'dev_HealthConnect_Cleansed',
    @SchemaName = 'dbo';

EXEC dbo.usp_Load_Refined_Claims
    @DatabaseName = 'dev_HealthConnect_Cleansed',
    @SchemaName = 'dbo';