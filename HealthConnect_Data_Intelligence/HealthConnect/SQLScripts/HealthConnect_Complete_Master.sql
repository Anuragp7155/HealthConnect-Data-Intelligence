/*
====================================================================
HEALTHCONNECT DATA INTELLIGENCE - COMPLETE MASTER SCRIPT
====================================================================

FINAL PIPELINE:
    CSV
      -> RAW ingestion procedures
      -> RAW master
      -> CLEANSED master
      -> REFINED SCD Type 1 procedures
      -> REFINED master + Pipeline_Log
      -> KPI reporting views

Execution order:
    01. Database creation
    02. RAW layer tables
    03. RAW ingestion procedures + RAW master
    04. CLEANSED layer tables
    05. RAW -> CLEANSED procedures + master
    06. REFINED layer tables
    07. CLEANSED -> REFINED procedures
    08. Pipeline log
    09. REFINED master procedure
    10. END-TO-END master pipeline
    11. KPI/reporting views
    12. Testing and validation

NOTE:
    This consolidated script uses the current project inbound path:
    D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\

    Test EXEC statements are commented out so the script creates the
    complete implementation without unexpectedly running the pipeline.
====================================================================
*/

/* ================================================================
   01. DATABASE CREATION
================================================================ */

IF DB_ID('dev_HealthConnect_raw') IS NULL
    CREATE DATABASE dev_HealthConnect_raw;
GO

IF DB_ID('dev_HealthConnect_Cleansed') IS NULL
    CREATE DATABASE dev_HealthConnect_Cleansed;
GO

IF DB_ID('dev_HealthConnect_refined') IS NULL
    CREATE DATABASE dev_HealthConnect_refined;
GO

/* ================================================================
   02. RAW LAYER TABLES
================================================================ */

USE dev_HealthConnect_raw;
GO

IF OBJECT_ID('dbo.raw_patients','U') IS NULL
CREATE TABLE dbo.raw_patients (
    patient_id INT NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender CHAR(1) NULL,
    date_of_birth DATE NOT NULL,
    state_code CHAR(2) NULL,
    city VARCHAR(50) NULL,
    phone VARCHAR(15) NULL,
    CONSTRAINT CK_raw_patients_gender CHECK (gender IN ('M','F','O'))
);
GO

IF OBJECT_ID('dbo.raw_providers','U') IS NULL
CREATE TABLE dbo.raw_providers (
    provider_id INT NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialty VARCHAR(50) NULL,
    npi VARCHAR(20) NULL UNIQUE
);
GO

IF OBJECT_ID('dbo.raw_payers','U') IS NULL
CREATE TABLE dbo.raw_payers (
    payer_id INT NOT NULL PRIMARY KEY,
    payer_name VARCHAR(100) NOT NULL
);
GO

IF OBJECT_ID('dbo.raw_encounters','U') IS NULL
CREATE TABLE dbo.raw_encounters (
    encounter_id INT NOT NULL PRIMARY KEY,
    patient_id INT NOT NULL,
    provider_id INT NOT NULL,
    encounter_type VARCHAR(10) NULL,
    encounter_start DATETIME NULL,
    encounter_end DATETIME NULL,
    height_cm INT NULL,
    weight_kg FLOAT NULL,
    systolic_bp INT NULL,
    diastolic_bp INT NULL,
    CONSTRAINT CK_raw_encounters_type CHECK (encounter_type IN ('OPD','ER','IPD'))
);
GO

IF OBJECT_ID('dbo.raw_diagnoses','U') IS NULL
CREATE TABLE dbo.raw_diagnoses (
    diagnosis_id INT NOT NULL PRIMARY KEY,
    encounter_id INT NOT NULL,
    diagnosis_description VARCHAR(100) NULL,
    is_primary BIT NULL
);
GO

IF OBJECT_ID('dbo.raw_procedures','U') IS NULL
CREATE TABLE dbo.raw_procedures (
    procedure_id INT NOT NULL PRIMARY KEY,
    encounter_id INT NOT NULL,
    procedure_description VARCHAR(100) NULL
);
GO

IF OBJECT_ID('dbo.raw_medications','U') IS NULL
CREATE TABLE dbo.raw_medications (
    medication_id INT NOT NULL PRIMARY KEY,
    encounter_id INT NOT NULL,
    drug_name VARCHAR(50) NULL,
    route VARCHAR(20) NULL,
    dose VARCHAR(20) NULL,
    frequency VARCHAR(10) NULL,
    days_supply INT NULL
);
GO

IF OBJECT_ID('dbo.raw_claims','U') IS NULL
CREATE TABLE dbo.raw_claims (
    claim_id INT NOT NULL PRIMARY KEY,
    encounter_id INT NOT NULL,
    payer_id INT NOT NULL,
    admit_date DATE NULL,
    discharge_date DATE NULL,
    total_billed_amount FLOAT NULL,
    total_allowed_amount FLOAT NULL,
    total_paid_amount FLOAT NULL,
    claim_status VARCHAR(20) NULL,
    CONSTRAINT CK_raw_claims_status CHECK (claim_status IN ('PENDING','APPROVED','REJECTED','PAID'))
);
GO

/* ================================================================
   03. RAW INGESTION PROCEDURES
================================================================ */

USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Patients
    @FileName NVARCHAR(500), @DatabaseName SYSNAME, @SchemaName SYSNAME, @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'TRUNCATE TABLE ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';
        BULK INSERT ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName,'''','''''') + N'''
        WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''0x0a'', TABLOCK, CODEPAGE=''65001'');';
    EXEC sys.sp_executesql @SQL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Providers
    @FileName NVARCHAR(500), @DatabaseName SYSNAME, @SchemaName SYSNAME, @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'TRUNCATE TABLE ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';
        BULK INSERT ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName,'''','''''') + N'''
        WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''0x0a'', TABLOCK, CODEPAGE=''65001'');';
    EXEC sys.sp_executesql @SQL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Payers
    @FileName NVARCHAR(500), @DatabaseName SYSNAME, @SchemaName SYSNAME, @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'TRUNCATE TABLE ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';
        BULK INSERT ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName,'''','''''') + N'''
        WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''0x0a'', TABLOCK, CODEPAGE=''65001'');';
    EXEC sys.sp_executesql @SQL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Encounters
    @FileName NVARCHAR(500), @DatabaseName SYSNAME, @SchemaName SYSNAME, @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'TRUNCATE TABLE ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';
        BULK INSERT ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName,'''','''''') + N'''
        WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''0x0a'', TABLOCK, CODEPAGE=''65001'');';
    EXEC sys.sp_executesql @SQL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Diagnoses
    @FileName NVARCHAR(500), @DatabaseName SYSNAME, @SchemaName SYSNAME, @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'
        CREATE TABLE #diagnoses_stage
        (diagnosis_id VARCHAR(50), encounter_id VARCHAR(50), diagnosis_description VARCHAR(100), is_primary VARCHAR(50));
        BULK INSERT #diagnoses_stage
        FROM ''' + REPLACE(@FileName,'''','''''') + N'''
        WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''0x0a'', TABLOCK, CODEPAGE=''65001'');
        TRUNCATE TABLE ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';
        INSERT INTO ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'
        (diagnosis_id, encounter_id, diagnosis_description, is_primary)
        SELECT TRY_CONVERT(INT,diagnosis_id), TRY_CONVERT(INT,encounter_id), diagnosis_description,
               CASE WHEN LTRIM(RTRIM(REPLACE(is_primary,CHAR(13),'''')))=''1'' THEN 1
                    WHEN LTRIM(RTRIM(REPLACE(is_primary,CHAR(13),'''')))=''0'' THEN 0 END
        FROM #diagnoses_stage;';
    EXEC sys.sp_executesql @SQL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Procedures
    @FileName NVARCHAR(500), @DatabaseName SYSNAME, @SchemaName SYSNAME, @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'TRUNCATE TABLE ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';
        BULK INSERT ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName,'''','''''') + N'''
        WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''0x0a'', TABLOCK, CODEPAGE=''65001'');';
    EXEC sys.sp_executesql @SQL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Medications
    @FileName NVARCHAR(500), @DatabaseName SYSNAME, @SchemaName SYSNAME, @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'TRUNCATE TABLE ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';
        BULK INSERT ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName,'''','''''') + N'''
        WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''0x0a'', TABLOCK, CODEPAGE=''65001'');';
    EXEC sys.sp_executesql @SQL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Claims
    @FileName NVARCHAR(500), @DatabaseName SYSNAME, @SchemaName SYSNAME, @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'TRUNCATE TABLE ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';
        BULK INSERT ' + QUOTENAME(@DatabaseName) + N'.' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName,'''','''''') + N'''
        WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''0x0a'', TABLOCK, CODEPAGE=''65001'');';
    EXEC sys.sp_executesql @SQL;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Master_Raw_Load
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DatabaseName SYSNAME='dev_HealthConnect_raw', @SchemaName SYSNAME='dbo', @FileName NVARCHAR(500);
    DECLARE @BasePath NVARCHAR(500)='D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\';

    SET @FileName=@BasePath+'patients_20260923.csv.csv'; EXEC dbo.usp_Load_Raw_Patients @FileName=@FileName,@DatabaseName=@DatabaseName,@SchemaName=@SchemaName,@TableName='raw_patients';
    SET @FileName=@BasePath+'providers_20260923.csv.csv'; EXEC dbo.usp_Load_Raw_Providers @FileName=@FileName,@DatabaseName=@DatabaseName,@SchemaName=@SchemaName,@TableName='raw_providers';
    SET @FileName=@BasePath+'payers_20260923.csv.csv'; EXEC dbo.usp_Load_Raw_Payers @FileName=@FileName,@DatabaseName=@DatabaseName,@SchemaName=@SchemaName,@TableName='raw_payers';
    SET @FileName=@BasePath+'encounters_20260923.csv.csv'; EXEC dbo.usp_Load_Raw_Encounters @FileName=@FileName,@DatabaseName=@DatabaseName,@SchemaName=@SchemaName,@TableName='raw_encounters';
    SET @FileName=@BasePath+'diagnoses_20260923.csv.csv'; EXEC dbo.usp_Load_Raw_Diagnoses @FileName=@FileName,@DatabaseName=@DatabaseName,@SchemaName=@SchemaName,@TableName='raw_diagnoses';
    SET @FileName=@BasePath+'procedures_20260923.csv.csv'; EXEC dbo.usp_Load_Raw_Procedures @FileName=@FileName,@DatabaseName=@DatabaseName,@SchemaName=@SchemaName,@TableName='raw_procedures';
    SET @FileName=@BasePath+'medications_20260923.csv.csv'; EXEC dbo.usp_Load_Raw_Medications @FileName=@FileName,@DatabaseName=@DatabaseName,@SchemaName=@SchemaName,@TableName='raw_medications';
    SET @FileName=@BasePath+'claims_20260923.csv.csv'; EXEC dbo.usp_Load_Raw_Claims @FileName=@FileName,@DatabaseName=@DatabaseName,@SchemaName=@SchemaName,@TableName='raw_claims';
END;
GO

-- Execute manually after confirming the CSV path and SQL Server file access:
-- EXEC dbo.usp_Master_Raw_Load;

/* ================================================================
   04. CLEANSED LAYER TABLES
================================================================ */

USE dev_HealthConnect_Cleansed;
GO

IF OBJECT_ID('dbo.cleansed_patients','U') IS NULL CREATE TABLE dbo.cleansed_patients (
 patient_id INT, first_name VARCHAR(50), last_name VARCHAR(50), gender CHAR(1), date_of_birth DATE,
 state_code CHAR(2), city VARCHAR(50), phone VARCHAR(15), load_date DATE);
GO
IF OBJECT_ID('dbo.cleansed_providers','U') IS NULL CREATE TABLE dbo.cleansed_providers (
 provider_id INT, first_name VARCHAR(50), last_name VARCHAR(50), specialty VARCHAR(50), npi VARCHAR(20), load_date DATE);
GO
IF OBJECT_ID('dbo.cleansed_payers','U') IS NULL CREATE TABLE dbo.cleansed_payers (
 payer_id INT, payer_name VARCHAR(100), load_date DATE);
GO
IF OBJECT_ID('dbo.cleansed_encounters','U') IS NULL CREATE TABLE dbo.cleansed_encounters (
 encounter_id INT, patient_id INT, provider_id INT, encounter_type VARCHAR(10), encounter_start DATETIME,
 encounter_end DATETIME, height_cm INT, weight_kg FLOAT, systolic_bp INT, diastolic_bp INT, load_date DATE);
GO
IF OBJECT_ID('dbo.cleansed_diagnoses','U') IS NULL CREATE TABLE dbo.cleansed_diagnoses (
 diagnosis_id INT, encounter_id INT, diagnosis_description VARCHAR(100), is_primary VARCHAR(10), load_date DATE);
GO
IF OBJECT_ID('dbo.cleansed_procedures','U') IS NULL CREATE TABLE dbo.cleansed_procedures (
 procedure_id INT, encounter_id INT, procedure_description VARCHAR(100), load_date DATE);
GO
IF OBJECT_ID('dbo.cleansed_medications','U') IS NULL CREATE TABLE dbo.cleansed_medications (
 medication_id INT, encounter_id INT, drug_name VARCHAR(50), route VARCHAR(20), dose VARCHAR(20), frequency VARCHAR(10), days_supply INT, load_date DATE);
GO
IF OBJECT_ID('dbo.cleansed_claims','U') IS NULL CREATE TABLE dbo.cleansed_claims (
 claim_id INT, encounter_id INT, payer_id INT, admit_date DATE, discharge_date DATE, total_billed_amount FLOAT,
 total_allowed_amount FLOAT, total_paid_amount FLOAT, claim_status VARCHAR(20), load_date DATE);
GO

/* ================================================================
   05. RAW -> CLEANSED PROCEDURES
================================================================ */

USE dev_HealthConnect_Cleansed;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Patients @DatabaseName SYSNAME,@SchemaName SYSNAME AS
BEGIN SET NOCOUNT ON; DECLARE @SQL NVARCHAR(MAX)=N'TRUNCATE TABLE dbo.cleansed_patients; INSERT INTO dbo.cleansed_patients (patient_id,first_name,last_name,gender,date_of_birth,state_code,city,phone,load_date) SELECT patient_id,UPPER(LTRIM(RTRIM(first_name))),UPPER(LTRIM(RTRIM(last_name))),UPPER(LTRIM(RTRIM(gender))),date_of_birth,UPPER(LTRIM(RTRIM(state_code))),UPPER(LTRIM(RTRIM(city))),LTRIM(RTRIM(phone)),CAST(GETDATE() AS DATE) FROM '+QUOTENAME(@DatabaseName)+N'.'+QUOTENAME(@SchemaName)+N'.raw_patients;'; EXEC sys.sp_executesql @SQL; END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Providers @DatabaseName SYSNAME,@SchemaName SYSNAME AS
BEGIN SET NOCOUNT ON; DECLARE @SQL NVARCHAR(MAX)=N'TRUNCATE TABLE dbo.cleansed_providers; INSERT INTO dbo.cleansed_providers (provider_id,first_name,last_name,specialty,npi,load_date) SELECT provider_id,UPPER(LTRIM(RTRIM(first_name))),UPPER(LTRIM(RTRIM(last_name))),UPPER(LTRIM(RTRIM(specialty))),LTRIM(RTRIM(npi)),CAST(GETDATE() AS DATE) FROM '+QUOTENAME(@DatabaseName)+N'.'+QUOTENAME(@SchemaName)+N'.raw_providers;'; EXEC sys.sp_executesql @SQL; END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Payers @DatabaseName SYSNAME,@SchemaName SYSNAME AS
BEGIN SET NOCOUNT ON; DECLARE @SQL NVARCHAR(MAX)=N'TRUNCATE TABLE dbo.cleansed_payers; INSERT INTO dbo.cleansed_payers (payer_id,payer_name,load_date) SELECT payer_id,UPPER(LTRIM(RTRIM(payer_name))),CAST(GETDATE() AS DATE) FROM '+QUOTENAME(@DatabaseName)+N'.'+QUOTENAME(@SchemaName)+N'.raw_payers;'; EXEC sys.sp_executesql @SQL; END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Encounters @DatabaseName SYSNAME,@SchemaName SYSNAME AS
BEGIN SET NOCOUNT ON; DECLARE @SQL NVARCHAR(MAX)=N'TRUNCATE TABLE dbo.cleansed_encounters; INSERT INTO dbo.cleansed_encounters (encounter_id,patient_id,provider_id,encounter_type,encounter_start,encounter_end,height_cm,weight_kg,systolic_bp,diastolic_bp,load_date) SELECT encounter_id,patient_id,provider_id,UPPER(LTRIM(RTRIM(encounter_type))),encounter_start,encounter_end,height_cm,weight_kg,systolic_bp,diastolic_bp,CAST(GETDATE() AS DATE) FROM '+QUOTENAME(@DatabaseName)+N'.'+QUOTENAME(@SchemaName)+N'.raw_encounters;'; EXEC sys.sp_executesql @SQL; END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Diagnoses @DatabaseName SYSNAME,@SchemaName SYSNAME AS
BEGIN SET NOCOUNT ON; DECLARE @SQL NVARCHAR(MAX)=N'TRUNCATE TABLE dbo.cleansed_diagnoses; INSERT INTO dbo.cleansed_diagnoses (diagnosis_id,encounter_id,diagnosis_description,is_primary,load_date) SELECT diagnosis_id,encounter_id,UPPER(LTRIM(RTRIM(diagnosis_description))),CASE WHEN is_primary=1 THEN ''TRUE'' WHEN is_primary=0 THEN ''FALSE'' END,CAST(GETDATE() AS DATE) FROM '+QUOTENAME(@DatabaseName)+N'.'+QUOTENAME(@SchemaName)+N'.raw_diagnoses;'; EXEC sys.sp_executesql @SQL; END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Procedures @DatabaseName SYSNAME,@SchemaName SYSNAME AS
BEGIN SET NOCOUNT ON; DECLARE @SQL NVARCHAR(MAX)=N'TRUNCATE TABLE dbo.cleansed_procedures; INSERT INTO dbo.cleansed_procedures (procedure_id,encounter_id,procedure_description,load_date) SELECT procedure_id,encounter_id,UPPER(LTRIM(RTRIM(procedure_description))),CAST(GETDATE() AS DATE) FROM '+QUOTENAME(@DatabaseName)+N'.'+QUOTENAME(@SchemaName)+N'.raw_procedures;'; EXEC sys.sp_executesql @SQL; END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Medications @DatabaseName SYSNAME,@SchemaName SYSNAME AS
BEGIN SET NOCOUNT ON; DECLARE @SQL NVARCHAR(MAX)=N'TRUNCATE TABLE dbo.cleansed_medications; INSERT INTO dbo.cleansed_medications (medication_id,encounter_id,drug_name,route,dose,frequency,days_supply,load_date) SELECT medication_id,encounter_id,UPPER(LTRIM(RTRIM(drug_name))),UPPER(LTRIM(RTRIM(route))),UPPER(LTRIM(RTRIM(dose))),UPPER(LTRIM(RTRIM(frequency))),days_supply,CAST(GETDATE() AS DATE) FROM '+QUOTENAME(@DatabaseName)+N'.'+QUOTENAME(@SchemaName)+N'.raw_medications;'; EXEC sys.sp_executesql @SQL; END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Load_Cleansed_Claims @DatabaseName SYSNAME,@SchemaName SYSNAME AS
BEGIN SET NOCOUNT ON; DECLARE @SQL NVARCHAR(MAX)=N'TRUNCATE TABLE dbo.cleansed_claims; INSERT INTO dbo.cleansed_claims (claim_id,encounter_id,payer_id,admit_date,discharge_date,total_billed_amount,total_allowed_amount,total_paid_amount,claim_status,load_date) SELECT claim_id,encounter_id,payer_id,admit_date,discharge_date,total_billed_amount,total_allowed_amount,total_paid_amount,UPPER(LTRIM(RTRIM(claim_status))),CAST(GETDATE() AS DATE) FROM '+QUOTENAME(@DatabaseName)+N'.'+QUOTENAME(@SchemaName)+N'.raw_claims;'; EXEC sys.sp_executesql @SQL; END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Master_Raw_To_Cleansed
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @DatabaseName SYSNAME='dev_HealthConnect_raw', @SchemaName SYSNAME='dbo';
 EXEC dbo.usp_Load_Cleansed_Patients @DatabaseName,@SchemaName;
 EXEC dbo.usp_Load_Cleansed_Providers @DatabaseName,@SchemaName;
 EXEC dbo.usp_Load_Cleansed_Payers @DatabaseName,@SchemaName;
 EXEC dbo.usp_Load_Cleansed_Encounters @DatabaseName,@SchemaName;
 EXEC dbo.usp_Load_Cleansed_Diagnoses @DatabaseName,@SchemaName;
 EXEC dbo.usp_Load_Cleansed_Procedures @DatabaseName,@SchemaName;
 EXEC dbo.usp_Load_Cleansed_Medications @DatabaseName,@SchemaName;
 EXEC dbo.usp_Load_Cleansed_Claims @DatabaseName,@SchemaName;
END;
GO

-- Execute manually after RAW load has succeeded:
-- EXEC dbo.usp_Master_Raw_To_Cleansed;

/* ================================================================
   06. REFINED LAYER TABLES
================================================================ */

USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('dbo.refined_patients','U') IS NULL CREATE TABLE dbo.refined_patients (
 patient_id INT PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50), gender CHAR(1), date_of_birth DATE,
 state_code CHAR(2), city VARCHAR(50), phone VARCHAR(15), load_date DATE, last_updated_date DATE);
GO
IF OBJECT_ID('dbo.refined_providers','U') IS NULL CREATE TABLE dbo.refined_providers (
 provider_id INT PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50), specialty VARCHAR(50), npi VARCHAR(20), load_date DATE, last_updated_date DATE);
GO
IF OBJECT_ID('dbo.refined_payers','U') IS NULL CREATE TABLE dbo.refined_payers (
 payer_id INT PRIMARY KEY, payer_name VARCHAR(100), load_date DATE, last_updated_date DATE);
GO
IF OBJECT_ID('dbo.refined_encounters','U') IS NULL CREATE TABLE dbo.refined_encounters (
 encounter_id INT PRIMARY KEY, patient_id INT, provider_id INT, encounter_type VARCHAR(10), encounter_start DATETIME,
 encounter_end DATETIME, height_cm INT, weight_kg FLOAT, systolic_bp INT, diastolic_bp INT, load_date DATE, last_updated_date DATE);
GO
IF OBJECT_ID('dbo.refined_diagnoses','U') IS NULL CREATE TABLE dbo.refined_diagnoses (
 diagnosis_id INT PRIMARY KEY, encounter_id INT, diagnosis_description VARCHAR(100), is_primary VARCHAR(10), load_date DATE, last_updated_date DATE);
GO
IF OBJECT_ID('dbo.refined_procedures','U') IS NULL CREATE TABLE dbo.refined_procedures (
 procedure_id INT PRIMARY KEY, encounter_id INT, procedure_description VARCHAR(100), load_date DATE, last_updated_date DATE);
GO
IF OBJECT_ID('dbo.refined_medications','U') IS NULL CREATE TABLE dbo.refined_medications (
 medication_id INT PRIMARY KEY, encounter_id INT, drug_name VARCHAR(50), route VARCHAR(20), dose VARCHAR(20), frequency VARCHAR(10), days_supply INT, load_date DATE, last_updated_date DATE);
GO
IF OBJECT_ID('dbo.refined_claims','U') IS NULL CREATE TABLE dbo.refined_claims (
 claim_id INT PRIMARY KEY, encounter_id INT, payer_id INT, admit_date DATE, discharge_date DATE, total_billed_amount FLOAT,
 total_allowed_amount FLOAT, total_paid_amount FLOAT, claim_status VARCHAR(20), load_date DATE, last_updated_date DATE);
GO



*/

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


/* =========================================================
   5. DIAGNOSES
   ========================================================= */

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


/* ================================================================
   08. PIPELINE LOG TABLE
================================================================ */

USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('dbo.Pipeline_Log','U') IS NULL
CREATE TABLE dbo.Pipeline_Log
(
    Log_ID INT IDENTITY(1,1) PRIMARY KEY,
    Run_ID UNIQUEIDENTIFIER,
    Procedure_Name VARCHAR(200),
    Start_Time DATETIME,
    End_Time DATETIME,
    Status VARCHAR(20),
    Rows_Processed INT,
    Error_Message VARCHAR(MAX)
);
GO

-------------------------

*/

-- Replace the Master Procedure


USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Master_Cleansed_To_Refined
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DatabaseName SYSNAME = 'dev_HealthConnect_Cleansed';
    DECLARE @SchemaName SYSNAME = 'dbo';

    DECLARE @RunID UNIQUEIDENTIFIER = NEWID();

    DECLARE @StartTime DATETIME;
    DECLARE @EndTime DATETIME;
    DECLARE @RowsProcessed INT;
    DECLARE @ErrorMessage VARCHAR(MAX);


    /*
       1. PATIENTS
     */

    SET @StartTime = GETDATE();

    BEGIN TRY

        SELECT @RowsProcessed = COUNT(*)
        FROM dev_HealthConnect_Cleansed.dbo.cleansed_patients;

        EXEC dbo.usp_Load_Refined_Patients
            @DatabaseName = @DatabaseName,
            @SchemaName = @SchemaName;

        SET @EndTime = GETDATE();

        INSERT INTO dbo.Pipeline_Log
        (
            Run_ID,
            Procedure_Name,
            Start_Time,
            End_Time,
            Status,
            Rows_Processed,
            Error_Message
        )
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Patients',
            @StartTime,
            @EndTime,
            'SUCCESS',
            @RowsProcessed,
            NULL
        );

    END TRY

    BEGIN CATCH

        SET @EndTime = GETDATE();
        SET @ErrorMessage = ERROR_MESSAGE();

        INSERT INTO dbo.Pipeline_Log
        (
            Run_ID,
            Procedure_Name,
            Start_Time,
            End_Time,
            Status,
            Rows_Processed,
            Error_Message
        )
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Patients',
            @StartTime,
            @EndTime,
            'FAILED',
            0,
            @ErrorMessage
        );

    END CATCH;


    /*
       2. PROVIDERS
    */

    SET @StartTime = GETDATE();

    BEGIN TRY

        SELECT @RowsProcessed = COUNT(*)
        FROM dev_HealthConnect_Cleansed.dbo.cleansed_providers;

        EXEC dbo.usp_Load_Refined_Providers
            @DatabaseName = @DatabaseName,
            @SchemaName = @SchemaName;

        SET @EndTime = GETDATE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Providers',
            @StartTime,
            @EndTime,
            'SUCCESS',
            @RowsProcessed,
            NULL
        );

    END TRY

    BEGIN CATCH

        SET @EndTime = GETDATE();
        SET @ErrorMessage = ERROR_MESSAGE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Providers',
            @StartTime,
            @EndTime,
            'FAILED',
            0,
            @ErrorMessage
        );

    END CATCH;


    /*
       3. PAYERS
    */

    SET @StartTime = GETDATE();

    BEGIN TRY

        SELECT @RowsProcessed = COUNT(*)
        FROM dev_HealthConnect_Cleansed.dbo.cleansed_payers;

        EXEC dbo.usp_Load_Refined_Payers
            @DatabaseName = @DatabaseName,
            @SchemaName = @SchemaName;

        SET @EndTime = GETDATE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Payers',
            @StartTime,
            @EndTime,
            'SUCCESS',
            @RowsProcessed,
            NULL
        );

    END TRY

    BEGIN CATCH

        SET @EndTime = GETDATE();
        SET @ErrorMessage = ERROR_MESSAGE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Payers',
            @StartTime,
            @EndTime,
            'FAILED',
            0,
            @ErrorMessage
        );

    END CATCH;


    /*
       4. ENCOUNTERS
     */

    SET @StartTime = GETDATE();

    BEGIN TRY

        SELECT @RowsProcessed = COUNT(*)
        FROM dev_HealthConnect_Cleansed.dbo.cleansed_encounters;

        EXEC dbo.usp_Load_Refined_Encounters
            @DatabaseName = @DatabaseName,
            @SchemaName = @SchemaName;

        SET @EndTime = GETDATE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Encounters',
            @StartTime,
            @EndTime,
            'SUCCESS',
            @RowsProcessed,
            NULL
        );

    END TRY

    BEGIN CATCH

        SET @EndTime = GETDATE();
        SET @ErrorMessage = ERROR_MESSAGE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Encounters',
            @StartTime,
            @EndTime,
            'FAILED',
            0,
            @ErrorMessage
        );

    END CATCH;


    /* =====================================================
       5. DIAGNOSES
       ===================================================== */

    SET @StartTime = GETDATE();

    BEGIN TRY

        SELECT @RowsProcessed = COUNT(*)
        FROM dev_HealthConnect_Cleansed.dbo.cleansed_diagnoses;

        EXEC dbo.usp_Load_Refined_Diagnoses
            @DatabaseName = @DatabaseName,
            @SchemaName = @SchemaName;

        SET @EndTime = GETDATE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Diagnoses',
            @StartTime,
            @EndTime,
            'SUCCESS',
            @RowsProcessed,
            NULL
        );

    END TRY

    BEGIN CATCH

        SET @EndTime = GETDATE();
        SET @ErrorMessage = ERROR_MESSAGE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Diagnoses',
            @StartTime,
            @EndTime,
            'FAILED',
            0,
            @ErrorMessage
        );

    END CATCH;


    /*
       6. PROCEDURES
     */

    SET @StartTime = GETDATE();

    BEGIN TRY

        SELECT @RowsProcessed = COUNT(*)
        FROM dev_HealthConnect_Cleansed.dbo.cleansed_procedures;

        EXEC dbo.usp_Load_Refined_Procedures
            @DatabaseName = @DatabaseName,
            @SchemaName = @SchemaName;

        SET @EndTime = GETDATE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Procedures',
            @StartTime,
            @EndTime,
            'SUCCESS',
            @RowsProcessed,
            NULL
        );

    END TRY

    BEGIN CATCH

        SET @EndTime = GETDATE();
        SET @ErrorMessage = ERROR_MESSAGE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Procedures',
            @StartTime,
            @EndTime,
            'FAILED',
            0,
            @ErrorMessage
        );

    END CATCH;


    /*
       7. MEDICATIONS
      */

    SET @StartTime = GETDATE();

    BEGIN TRY

        SELECT @RowsProcessed = COUNT(*)
        FROM dev_HealthConnect_Cleansed.dbo.cleansed_medications;

        EXEC dbo.usp_Load_Refined_Medications
            @DatabaseName = @DatabaseName,
            @SchemaName = @SchemaName;

        SET @EndTime = GETDATE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Medications',
            @StartTime,
            @EndTime,
            'SUCCESS',
            @RowsProcessed,
            NULL
        );

    END TRY

    BEGIN CATCH

        SET @EndTime = GETDATE();
        SET @ErrorMessage = ERROR_MESSAGE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Medications',
            @StartTime,
            @EndTime,
            'FAILED',
            0,
            @ErrorMessage
        );

    END CATCH;


    /*
       8. CLAIMS
    */

    SET @StartTime = GETDATE();

    BEGIN TRY

        SELECT @RowsProcessed = COUNT(*)
        FROM dev_HealthConnect_Cleansed.dbo.cleansed_claims;

        EXEC dbo.usp_Load_Refined_Claims
            @DatabaseName = @DatabaseName,
            @SchemaName = @SchemaName;

        SET @EndTime = GETDATE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Claims',
            @StartTime,
            @EndTime,
            'SUCCESS',
            @RowsProcessed,
            NULL
        );

    END TRY

    BEGIN CATCH

        SET @EndTime = GETDATE();
        SET @ErrorMessage = ERROR_MESSAGE();

        INSERT INTO dbo.Pipeline_Log
        VALUES
        (
            @RunID,
            'usp_Load_Refined_Claims',
            @StartTime,
            @EndTime,
            'FAILED',
            0,
            @ErrorMessage
        );

    END CATCH;

END;
GO

-- TESTING: run manually after the procedures are created.
-- EXEC dbo.usp_Master_Cleansed_To_Refined;
-- SELECT Log_ID, Run_ID, Procedure_Name, Start_Time, End_Time, Status, Rows_Processed, Error_Message
-- FROM dbo.Pipeline_Log
-- ORDER BY Log_ID;


/* ================================================================
   09A. END-TO-END HEALTHCONNECT MASTER
================================================================ */

USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Master_HealthConnect_Pipeline
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dev_HealthConnect_raw.dbo.usp_Master_Raw_Load;

    EXEC dev_HealthConnect_Cleansed.dbo.usp_Master_Raw_To_Cleansed;

    EXEC dbo.usp_Master_Cleansed_To_Refined;
END;
GO

-- Execute manually only after verifying the inbound CSV path:
-- EXEC dbo.usp_Master_HealthConnect_Pipeline;

/* ================================================================
   10. KPI / REPORTING VIEWS
================================================================ */

----------------------------

*/

USE dev_HealthConnect_refined;

  
CREATE OR ALTER VIEW dbo.vw_KPI01_Yearly_Claim_Trend
AS
SELECT
    YEAR(admit_date) AS Claim_Year,

    COUNT(claim_id) AS Total_Claims,

    SUM(total_billed_amount) AS Total_Claim_Amount,

    AVG(total_paid_amount) AS Average_Claim_Amount_Paid

FROM dbo.refined_claims

WHERE admit_date IS NOT NULL

GROUP BY YEAR(admit_date);



SELECT *
FROM dbo.vw_KPI01_Yearly_Claim_Trend
ORDER BY Claim_Year;



------2. What is the total claim amount paid and total number of claims processed by each insurance payer?


CREATE OR ALTER VIEW dbo.vw_KPI02_Payer_Claims
AS
SELECT
    P.payer_id,
    P.payer_name,

    COUNT(C.claim_id) AS Total_Claims,

    SUM(C.total_paid_amount) AS Total_Paid_Claim_Amount

FROM dbo.refined_claims C
INNER JOIN dbo.refined_payers P
    ON C.payer_id = P.payer_id

GROUP BY
    P.payer_id,
    P.payer_name;



SELECT *
FROM dbo.vw_KPI02_Payer_Claims
ORDER BY Total_Paid_Claim_Amount DESC;


-- 3.What is the Total claim amount for the Current and Previous Year’s Year to Date (YTD), Quarter To Date(QTD), Month To Date (MTD) and Week To Date(WTD)?


CREATE OR ALTER VIEW dbo.vw_KPI03_Current_Previous_Periods
AS

WITH MaxDate AS
(
    SELECT MAX(admit_date) AS AsOfDate
    FROM dbo.refined_claims
),

PeriodDates AS
(
    SELECT
        AsOfDate,

        -- Current Year
        DATEFROMPARTS(YEAR(AsOfDate), 1, 1) AS Current_YTD_Start,

        -- Current Quarter
        DATEADD(
            QUARTER,
            DATEDIFF(QUARTER, 0, AsOfDate),
            0
        ) AS Current_QTD_Start,

        -- Current Month
        DATEFROMPARTS(
            YEAR(AsOfDate),
            MONTH(AsOfDate),
            1
        ) AS Current_MTD_Start,

        -- Current Week - Monday
        DATEADD(
            DAY,
            -(DATEDIFF(DAY, '19000101', AsOfDate) % 7),
            AsOfDate
        ) AS Current_WTD_Start
    FROM MaxDate
)

SELECT
    'Current Year' AS Period_Type,

    SUM(
        CASE
            WHEN C.admit_date >= P.Current_YTD_Start
            THEN C.total_billed_amount
            ELSE 0
        END
    ) AS YTD_Total_Claim_Amount,

    SUM(
        CASE
            WHEN C.admit_date >= P.Current_QTD_Start
            THEN C.total_billed_amount
            ELSE 0
        END
    ) AS QTD_Total_Claim_Amount,

    SUM(
        CASE
            WHEN C.admit_date >= P.Current_MTD_Start
            THEN C.total_billed_amount
            ELSE 0
        END
    ) AS MTD_Total_Claim_Amount,

    SUM(
        CASE
            WHEN C.admit_date >= P.Current_WTD_Start
            THEN C.total_billed_amount
            ELSE 0
        END
    ) AS WTD_Total_Claim_Amount

FROM dbo.refined_claims C
CROSS JOIN PeriodDates P

WHERE YEAR(C.admit_date) = YEAR(P.AsOfDate)

UNION ALL

SELECT
    'Previous Year' AS Period_Type,

    SUM(
        CASE
            WHEN C.admit_date >= DATEADD(YEAR, -1, P.Current_YTD_Start)
             AND C.admit_date <= DATEADD(YEAR, -1, P.AsOfDate)
            THEN C.total_billed_amount
            ELSE 0
        END
    ) AS YTD_Total_Claim_Amount,

    SUM(
        CASE
            WHEN C.admit_date >= DATEADD(YEAR, -1, P.Current_QTD_Start)
             AND C.admit_date <= DATEADD(YEAR, -1, P.AsOfDate)
            THEN C.total_billed_amount
            ELSE 0
        END
    ) AS QTD_Total_Claim_Amount,

    SUM(
        CASE
            WHEN C.admit_date >= DATEADD(YEAR, -1, P.Current_MTD_Start)
             AND C.admit_date <= DATEADD(YEAR, -1, P.AsOfDate)
            THEN C.total_billed_amount
            ELSE 0
        END
    ) AS MTD_Total_Claim_Amount,

    SUM(
        CASE
            WHEN C.admit_date >= DATEADD(YEAR, -1, P.Current_WTD_Start)
             AND C.admit_date <= DATEADD(YEAR, -1, P.AsOfDate)
            THEN C.total_billed_amount
            ELSE 0
        END
    ) AS WTD_Total_Claim_Amount

FROM dbo.refined_claims C
CROSS JOIN PeriodDates P

WHERE YEAR(C.admit_date) = YEAR(P.AsOfDate) - 1;



SELECT *
FROM dbo.vw_KPI03_Current_Previous_Periods;


--- 4.Which healthcare providers have shown the highest patient engagement count over the last five years, based on the total number
--  of patient visits handled each year.




CREATE OR ALTER VIEW dbo.vw_KPI04_Provider_Patient_Engagement
AS

WITH ProviderVisits AS
(
    SELECT
        E.provider_id,
        P.first_name,
        P.last_name,
        YEAR(E.encounter_start) AS Visit_Year,
        COUNT(*) AS Total_Visits
    FROM dbo.refined_encounters E
    INNER JOIN dbo.refined_providers P
        ON E.provider_id = P.provider_id
    WHERE YEAR(E.encounter_start) >=
          YEAR((SELECT MAX(encounter_start)
                FROM dbo.refined_encounters)) - 4
    GROUP BY
        E.provider_id,
        P.first_name,
        P.last_name,
        YEAR(E.encounter_start)
),
RankedProviders AS
(
    SELECT
        *,
        SUM(Total_Visits) OVER
        (
            PARTITION BY provider_id
        ) AS Five_Year_Total_Visits
    FROM ProviderVisits
)
SELECT
    DENSE_RANK() OVER
    (
        ORDER BY Five_Year_Total_Visits DESC
    ) AS Engagement_Rank,

    provider_id,
    first_name,
    last_name,
    Visit_Year,
    Total_Visits,
    Five_Year_Total_Visits

FROM RankedProviders;





SELECT *
FROM dbo.vw_KPI04_Provider_Patient_Engagement
ORDER BY Engagement_Rank, Visit_Year;


--- 5. Which diagnoses contribute most to total healthcare claim costs?


CREATE OR ALTER VIEW dbo.vw_KPI05_Diagnosis_Claim_Cost
AS

SELECT
    D.diagnosis_id,
    D.diagnosis_description,
    COUNT(DISTINCT C.claim_id) AS Total_Claims,
    SUM(C.total_paid_amount) AS Total_Paid_Claim_Amount
FROM dbo.refined_diagnoses D
INNER JOIN dbo.refined_claims C
    ON D.encounter_id = C.encounter_id
GROUP BY
    D.diagnosis_id,
    D.diagnosis_description;


SELECT *
FROM dbo.vw_KPI05_Diagnosis_Claim_Cost
ORDER BY Total_Paid_Claim_Amount DESC;


--- 6. What is the total number of patient visits, total claim cost, and average cost per patient visit per year?



CREATE OR ALTER VIEW dbo.vw_KPI06_Yearly_Visit_Claim_Cost
AS

SELECT
    YEAR(E.encounter_start) AS Visit_Year,

    COUNT(DISTINCT E.encounter_id) AS Total_Patient_Visits,

    SUM(C.total_paid_amount) AS Total_Claim_Cost,

    CAST(
        SUM(C.total_paid_amount) * 1.0
        / NULLIF(COUNT(DISTINCT E.encounter_id), 0)
        AS DECIMAL(18,2)
    ) AS Average_Cost_Per_Visit

FROM dbo.refined_encounters E

INNER JOIN dbo.refined_claims C
    ON E.encounter_id = C.encounter_id

WHERE E.encounter_start IS NOT NULL

GROUP BY
    YEAR(E.encounter_start);


SELECT *
FROM dbo.vw_KPI06_Yearly_Visit_Claim_Cost
ORDER BY Visit_Year;




--- 7. What are the total claim amount, total number of claims, and average claim amount by patient gender?


CREATE OR ALTER VIEW dbo.vw_KPI07_Gender_Claim_Analysis
AS
SELECT
    P.gender,
    COUNT(DISTINCT C.claim_id) AS Total_Claims,
    SUM(C.total_paid_amount) AS Total_Claim_Amount,
    CAST(
        AVG(CAST(C.total_paid_amount AS DECIMAL(18,2)))
        AS DECIMAL(18,2)
    ) AS Average_Claim_Amount
FROM dbo.refined_patients P
INNER JOIN dbo.refined_encounters E
    ON P.patient_id = E.patient_id
INNER JOIN dbo.refined_claims C
    ON E.encounter_id = C.encounter_id
GROUP BY
    P.gender;


SELECT *
FROM dbo.vw_KPI07_Gender_Claim_Analysis
ORDER BY gender;


--- 8. Which medications are prescribed most frequently across all patient visits?


CREATE OR ALTER VIEW dbo.vw_KPI08_Most_Prescribed_Medications
AS
SELECT
    drug_name,
    COUNT(*) AS Prescription_Count
FROM dbo.refined_medications
WHERE drug_name IS NOT NULL
GROUP BY
    drug_name;


 SELECT *
FROM dbo.vw_KPI08_Most_Prescribed_Medications
ORDER BY Prescription_Count DESC;



--- 9. What is age group wise TotalClaimAmount and TotalClaim.


CREATE OR ALTER VIEW dbo.vw_KPI09_Age_Group_Claims
AS
WITH PatientAge AS
(
    SELECT
        P.patient_id,
        C.claim_id,
        C.total_paid_amount,
        DATEDIFF(YEAR, P.date_of_birth, C.admit_date)
        - CASE
            WHEN DATEADD(
                YEAR,
                DATEDIFF(YEAR, P.date_of_birth, C.admit_date),
                P.date_of_birth
              ) > C.admit_date
            THEN 1
            ELSE 0
          END AS Age
    FROM dbo.refined_patients P
    JOIN dbo.refined_encounters E
        ON P.patient_id = E.patient_id
    JOIN dbo.refined_claims C
        ON E.encounter_id = C.encounter_id
    WHERE P.date_of_birth IS NOT NULL
      AND C.admit_date IS NOT NULL
)
SELECT
    CASE
        WHEN Age < 18 THEN '0-17'
        WHEN Age <= 30 THEN '18-30'
        WHEN Age <= 45 THEN '31-45'
        WHEN Age <= 60 THEN '46-60'
        ELSE '61+'
    END AS Age_Group,

    COUNT(DISTINCT claim_id) AS Total_Claims,
    SUM(total_paid_amount) AS Total_Claim_Amount

FROM PatientAge
GROUP BY
    CASE
        WHEN Age < 18 THEN '0-17'
        WHEN Age <= 30 THEN '18-30'
        WHEN Age <= 45 THEN '31-45'
        WHEN Age <= 60 THEN '46-60'
        ELSE '61+'
    END;



SELECT *
FROM dbo.vw_KPI09_Age_Group_Claims;




--- 10. How has the average inpatient stay duration (from admission to discharge) varied year over year, and what is the percentage
--- increase or decrease compared to the previous year?




CREATE OR ALTER VIEW dbo.vw_KPI10_Inpatient_Stay_YoY
AS
WITH YearlyStay AS
(
    SELECT
        YEAR(encounter_start) AS Stay_Year,
        AVG(
            DATEDIFF(
                DAY,
                encounter_start,
                encounter_end
            ) * 1.0
        ) AS Avg_Stay_Days
    FROM dbo.refined_encounters
    WHERE encounter_type = 'IPD'
      AND encounter_start IS NOT NULL
      AND encounter_end IS NOT NULL
    GROUP BY YEAR(encounter_start)
),
WithPrevious AS
(
    SELECT
        Stay_Year,
        Avg_Stay_Days,
        LAG(Avg_Stay_Days) OVER (
            ORDER BY Stay_Year
        ) AS Previous_Year_Avg_Stay
    FROM YearlyStay
)
SELECT
    Stay_Year,
    CAST(Avg_Stay_Days AS DECIMAL(10,2)) AS Average_Stay_Days,
    CAST(Previous_Year_Avg_Stay AS DECIMAL(10,2)) AS Previous_Year_Avg_Stay,
    CAST(
        (Avg_Stay_Days - Previous_Year_Avg_Stay)
        * 100.0
        / NULLIF(Previous_Year_Avg_Stay, 0)
        AS DECIMAL(10,2)
    ) AS YoY_Percentage_Change
FROM WithPrevious;


SELECT *
FROM dbo.vw_KPI10_Inpatient_Stay_YoY
ORDER BY Stay_Year;



--- 11. How much have total paid claim amount changed compared to the previous year, and what is the year-over-year percentage growth in insurance claim payments


CREATE OR ALTER VIEW dbo.vw_KPI11_Paid_Claim_YoY
AS
WITH YearlyClaims AS
(
    SELECT
        YEAR(admit_date) AS Claim_Year,
        SUM(total_paid_amount) AS Total_Paid_Amount
    FROM dbo.refined_claims
    WHERE admit_date IS NOT NULL
    GROUP BY YEAR(admit_date)
)
SELECT
    Claim_Year,
    Total_Paid_Amount,

    LAG(Total_Paid_Amount) OVER
    (
        ORDER BY Claim_Year
    ) AS Previous_Year_Amount,

    Total_Paid_Amount
        - LAG(Total_Paid_Amount) OVER
          (
              ORDER BY Claim_Year
          ) AS Amount_Change,

    CAST(
        (
            Total_Paid_Amount
            - LAG(Total_Paid_Amount) OVER
              (
                  ORDER BY Claim_Year
              )
        ) * 100.0
        / NULLIF(
            LAG(Total_Paid_Amount) OVER
            (
                ORDER BY Claim_Year
            ), 0
        )
        AS DECIMAL(10,2)
    ) AS YoY_Growth_Percentage

FROM YearlyClaims;


SELECT *
FROM dbo.vw_KPI11_Paid_Claim_YoY
ORDER BY Claim_Year;


/* ================================================================
   11. TESTING & VALIDATION
================================================================ */

-- RAW row counts
-- USE dev_HealthConnect_raw;
-- SELECT 'raw_patients' AS Table_Name, COUNT(*) AS Row_Count FROM dbo.raw_patients
-- UNION ALL SELECT 'raw_providers',COUNT(*) FROM dbo.raw_providers
-- UNION ALL SELECT 'raw_payers',COUNT(*) FROM dbo.raw_payers
-- UNION ALL SELECT 'raw_encounters',COUNT(*) FROM dbo.raw_encounters
-- UNION ALL SELECT 'raw_diagnoses',COUNT(*) FROM dbo.raw_diagnoses
-- UNION ALL SELECT 'raw_procedures',COUNT(*) FROM dbo.raw_procedures
-- UNION ALL SELECT 'raw_medications',COUNT(*) FROM dbo.raw_medications
-- UNION ALL SELECT 'raw_claims',COUNT(*) FROM dbo.raw_claims;

-- CLEANSED row counts
-- USE dev_HealthConnect_Cleansed;
-- SELECT 'cleansed_patients' AS Table_Name, COUNT(*) AS Row_Count FROM dbo.cleansed_patients
-- UNION ALL SELECT 'cleansed_providers',COUNT(*) FROM dbo.cleansed_providers
-- UNION ALL SELECT 'cleansed_payers',COUNT(*) FROM dbo.cleansed_payers
-- UNION ALL SELECT 'cleansed_encounters',COUNT(*) FROM dbo.cleansed_encounters
-- UNION ALL SELECT 'cleansed_diagnoses',COUNT(*) FROM dbo.cleansed_diagnoses
-- UNION ALL SELECT 'cleansed_procedures',COUNT(*) FROM dbo.cleansed_procedures
-- UNION ALL SELECT 'cleansed_medications',COUNT(*) FROM dbo.cleansed_medications
-- UNION ALL SELECT 'cleansed_claims',COUNT(*) FROM dbo.cleansed_claims;

-- REFINED row counts
-- USE dev_HealthConnect_refined;
-- SELECT 'refined_patients' AS Table_Name, COUNT(*) AS Row_Count FROM dbo.refined_patients
-- UNION ALL SELECT 'refined_providers',COUNT(*) FROM dbo.refined_providers
-- UNION ALL SELECT 'refined_payers',COUNT(*) FROM dbo.refined_payers
-- UNION ALL SELECT 'refined_encounters',COUNT(*) FROM dbo.refined_encounters
-- UNION ALL SELECT 'refined_diagnoses',COUNT(*) FROM dbo.refined_diagnoses
-- UNION ALL SELECT 'refined_procedures',COUNT(*) FROM dbo.refined_procedures
-- UNION ALL SELECT 'refined_medications',COUNT(*) FROM dbo.refined_medications
-- UNION ALL SELECT 'refined_claims',COUNT(*) FROM dbo.refined_claims;

-- Pipeline log
-- USE dev_HealthConnect_refined;
-- SELECT TOP 20 * FROM dbo.Pipeline_Log ORDER BY Log_ID DESC;

-- KPI validation
-- SELECT * FROM dbo.vw_KPI01_Yearly_Claim_Trend ORDER BY Claim_Year;
-- SELECT * FROM dbo.vw_KPI02_Payer_Claims ORDER BY Total_Paid_Claim_Amount DESC;
-- SELECT * FROM dbo.vw_KPI03_Current_Previous_Periods;
-- SELECT * FROM dbo.vw_KPI04_Provider_Patient_Engagement ORDER BY Engagement_Rank,Visit_Year;
-- SELECT * FROM dbo.vw_KPI05_Diagnosis_Claim_Cost ORDER BY Total_Paid_Claim_Amount DESC;
-- SELECT * FROM dbo.vw_KPI06_Yearly_Visit_Claim_Cost ORDER BY Visit_Year;
-- SELECT * FROM dbo.vw_KPI07_Gender_Claim_Analysis ORDER BY gender;
-- SELECT TOP 10 * FROM dbo.vw_KPI08_Most_Prescribed_Medications ORDER BY Prescription_Count DESC;
-- SELECT * FROM dbo.vw_KPI09_Age_Group_Claims;
-- SELECT * FROM dbo.vw_KPI10_Inpatient_Stay_YoY ORDER BY Stay_Year;
-- SELECT * FROM dbo.vw_KPI11_Paid_Claim_YoY ORDER BY Claim_Year;

/*
END OF HEALTHCONNECT COMPLETE MASTER SCRIPT
*/
