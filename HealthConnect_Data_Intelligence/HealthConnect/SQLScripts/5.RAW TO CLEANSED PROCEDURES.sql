USE dev_HealthConnect_Cleansed;
GO

/*
   RAW -> CLEANSED PROCEDURES
*/


/*
   1. PATIENTS
 */

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Patients
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
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
        FROM ' + QUOTENAME(@DatabaseName) + N'.'
                  + QUOTENAME(@SchemaName) + N'.raw_patients;
    ';

    EXEC sys.sp_executesql @SQL;
END;



/* 
   2. PROVIDERS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Providers
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
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
        FROM ' + QUOTENAME(@DatabaseName) + N'.'
                  + QUOTENAME(@SchemaName) + N'.raw_providers;
    ';

    EXEC sys.sp_executesql @SQL;
END;
GO


/*
   3. PAYERS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Payers
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
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
        FROM ' + QUOTENAME(@DatabaseName) + N'.'
                  + QUOTENAME(@SchemaName) + N'.raw_payers;
    ';

    EXEC sys.sp_executesql @SQL;
END;



/*
   4. ENCOUNTERS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Encounters
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
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
        FROM ' + QUOTENAME(@DatabaseName) + N'.'
                  + QUOTENAME(@SchemaName) + N'.raw_encounters;
    ';

    EXEC sys.sp_executesql @SQL;
END;



/*
   5. DIAGNOSES
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Diagnoses
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
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
                WHEN is_primary = 1 THEN ''TRUE''
                WHEN is_primary = 0 THEN ''FALSE''
            END,
            CAST(GETDATE() AS DATE)
        FROM ' + QUOTENAME(@DatabaseName) + N'.'
                  + QUOTENAME(@SchemaName) + N'.raw_diagnoses;
    ';

    EXEC sys.sp_executesql @SQL;
END;



/*
   6. PROCEDURES
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Procedures
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
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
        FROM ' + QUOTENAME(@DatabaseName) + N'.'
                  + QUOTENAME(@SchemaName) + N'.raw_procedures;
    ';

    EXEC sys.sp_executesql @SQL;
END;



/*
   7. MEDICATIONS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Medications
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
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
        FROM ' + QUOTENAME(@DatabaseName) + N'.'
                  + QUOTENAME(@SchemaName) + N'.raw_medications;
    ';

    EXEC sys.sp_executesql @SQL;
END;



/*
   8. CLAIMS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Claims
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
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
        FROM ' + QUOTENAME(@DatabaseName) + N'.'
                  + QUOTENAME(@SchemaName) + N'.raw_claims;
    ';

    EXEC sys.sp_executesql @SQL;
END;



/* 
   9. MASTER RAW -> CLEANSED
*/

CREATE OR ALTER PROCEDURE dbo.usp_Master_Raw_To_Cleansed
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DatabaseName SYSNAME = 'dev_HealthConnect_raw';
    DECLARE @SchemaName SYSNAME = 'dbo';


    EXEC dbo.usp_Load_Cleansed_Patients
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName;


    EXEC dbo.usp_Load_Cleansed_Providers
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName;


    EXEC dbo.usp_Load_Cleansed_Payers
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName;


    EXEC dbo.usp_Load_Cleansed_Encounters
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName;


    EXEC dbo.usp_Load_Cleansed_Diagnoses
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName;


    EXEC dbo.usp_Load_Cleansed_Procedures
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName;


    EXEC dbo.usp_Load_Cleansed_Medications
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName;


    EXEC dbo.usp_Load_Cleansed_Claims
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName;

END;


EXEC dbo.usp_Master_Raw_To_Cleansed;


--VERIFY---

SELECT 'Patients' AS Table_Name, COUNT(*) AS Row_Count
FROM dbo.cleansed_patients

UNION ALL

SELECT 'Providers', COUNT(*)
FROM dbo.cleansed_providers

UNION ALL

SELECT 'Payers', COUNT(*)
FROM dbo.cleansed_payers

UNION ALL

SELECT 'Encounters', COUNT(*)
FROM dbo.cleansed_encounters

UNION ALL

SELECT 'Diagnoses', COUNT(*)
FROM dbo.cleansed_diagnoses

UNION ALL

SELECT 'Procedures', COUNT(*)
FROM dbo.cleansed_procedures

UNION ALL

SELECT 'Medications', COUNT(*)
FROM dbo.cleansed_medications

UNION ALL

SELECT 'Claims', COUNT(*)
FROM dbo.cleansed_claims;