/*
HEALTHCONNECT DATA INTELLIGENCE
RAW LAYER INGESTION STORED PROCEDURES

Purpose:
    Parameterized stored procedures for loading each CSV source
    into the HealthConnect RAW layer.

Flow:
    CSV -> RAW Child Procedures -> RAW Master Procedure

Required by project specification:
    - Procedure for each CSV source
    - Parameters for filename, database, schema and table
    - Master procedure to execute all RAW load procedures

IMPORTANT:
    Update @BasePath / file names if the inbound file location changes.

*/

USE dev_HealthConnect_raw;



/*
   1. PATIENTS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Patients
    @FileName NVARCHAR(500),
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        TRUNCATE TABLE '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N';

        BULK INSERT '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName, '''', '''''') + N'''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            TABLOCK,
            CODEPAGE = ''65001''
        );';

    EXEC sys.sp_executesql @SQL;
END;



/*
   2. PROVIDERS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Providers
    @FileName NVARCHAR(500),
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        TRUNCATE TABLE '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N';

        BULK INSERT '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName, '''', '''''') + N'''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            TABLOCK,
            CODEPAGE = ''65001''
        );';

    EXEC sys.sp_executesql @SQL;
END;



/*
   3. PAYERS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Payers
    @FileName NVARCHAR(500),
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        TRUNCATE TABLE '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N';

        BULK INSERT '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName, '''', '''''') + N'''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            TABLOCK,
            CODEPAGE = ''65001''
        );';

    EXEC sys.sp_executesql @SQL;
END;



/*
   4. ENCOUNTERS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Encounters
    @FileName NVARCHAR(500),
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        TRUNCATE TABLE '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N';

        BULK INSERT '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName, '''', '''''') + N'''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            TABLOCK,
            CODEPAGE = ''65001''
        );';

    EXEC sys.sp_executesql @SQL;
END;



/*
   5. DIAGNOSES

The diagnoses source previously contained carriage-return/invisible
characters in is_primary. Therefore it is loaded into a staging
table and cleaned before insertion into RAW.
 */

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Diagnoses
    @FileName NVARCHAR(500),
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        CREATE TABLE #diagnoses_stage
        (
            diagnosis_id VARCHAR(50),
            encounter_id VARCHAR(50),
            diagnosis_description VARCHAR(100),
            is_primary VARCHAR(50)
        );

        BULK INSERT #diagnoses_stage
        FROM ''' + REPLACE(@FileName, '''', '''''') + N'''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            TABLOCK,
            CODEPAGE = ''65001''
        );

        TRUNCATE TABLE '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N';

        INSERT INTO '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N'
        (
            diagnosis_id,
            encounter_id,
            diagnosis_description,
            is_primary
        )
        SELECT
            TRY_CONVERT(INT, diagnosis_id),
            TRY_CONVERT(INT, encounter_id),
            diagnosis_description,
            CASE
                WHEN LTRIM(RTRIM(REPLACE(is_primary, CHAR(13), ''''))) = ''1''
                    THEN 1
                WHEN LTRIM(RTRIM(REPLACE(is_primary, CHAR(13), ''''))) = ''0''
                    THEN 0
                ELSE NULL
            END
        FROM #diagnoses_stage;';

    EXEC sys.sp_executesql @SQL;
END;



/*
   6. PROCEDURES
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Procedures
    @FileName NVARCHAR(500),
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        TRUNCATE TABLE '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N';

        BULK INSERT '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName, '''', '''''') + N'''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            TABLOCK,
            CODEPAGE = ''65001''
        );';

    EXEC sys.sp_executesql @SQL;
END;



/*
   7. MEDICATIONS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Medications
    @FileName NVARCHAR(500),
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        TRUNCATE TABLE '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N';

        BULK INSERT '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName, '''', '''''') + N'''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            TABLOCK,
            CODEPAGE = ''65001''
        );';

    EXEC sys.sp_executesql @SQL;
END;



/*
   8. CLAIMS
*/

CREATE OR ALTER PROCEDURE dbo.usp_Load_Raw_Claims
    @FileName NVARCHAR(500),
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        TRUNCATE TABLE '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N';

        BULK INSERT '
        + QUOTENAME(@DatabaseName) + N'.'
        + QUOTENAME(@SchemaName) + N'.'
        + QUOTENAME(@TableName) + N'
        FROM ''' + REPLACE(@FileName, '''', '''''') + N'''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            TABLOCK,
            CODEPAGE = ''65001''
        );';

    EXEC sys.sp_executesql @SQL;
END;



/*
   9. MASTER RAW LOAD
 */


USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Master_Raw_Load
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DatabaseName SYSNAME = 'dev_HealthConnect_raw';
    DECLARE @SchemaName SYSNAME = 'dbo';
    DECLARE @FileName NVARCHAR(500);

    DECLARE @BasePath NVARCHAR(500) =
        'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\';


    SET @FileName = @BasePath + 'patients_20260923.csv.csv';

    EXEC dbo.usp_Load_Raw_Patients
        @FileName = @FileName,
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName,
        @TableName = 'raw_patients';


    SET @FileName = @BasePath + 'providers_20260923.csv.csv';

    EXEC dbo.usp_Load_Raw_Providers
        @FileName = @FileName,
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName,
        @TableName = 'raw_providers';


    SET @FileName = @BasePath + 'payers_20260923.csv.csv';

    EXEC dbo.usp_Load_Raw_Payers
        @FileName = @FileName,
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName,
        @TableName = 'raw_payers';


    SET @FileName = @BasePath + 'encounters_20260923.csv.csv';

    EXEC dbo.usp_Load_Raw_Encounters
        @FileName = @FileName,
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName,
        @TableName = 'raw_encounters';


    SET @FileName = @BasePath + 'diagnoses_20260923.csv.csv';

    EXEC dbo.usp_Load_Raw_Diagnoses
        @FileName = @FileName,
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName,
        @TableName = 'raw_diagnoses';


    SET @FileName = @BasePath + 'procedures_20260923.csv.csv';

    EXEC dbo.usp_Load_Raw_Procedures
        @FileName = @FileName,
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName,
        @TableName = 'raw_procedures';


    SET @FileName = @BasePath + 'medications_20260923.csv.csv';

    EXEC dbo.usp_Load_Raw_Medications
        @FileName = @FileName,
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName,
        @TableName = 'raw_medications';


    SET @FileName = @BasePath + 'claims_20260923.csv.csv';

    EXEC dbo.usp_Load_Raw_Claims
        @FileName = @FileName,
        @DatabaseName = @DatabaseName,
        @SchemaName = @SchemaName,
        @TableName = 'raw_claims';

END;



/*
   10. TEST
*/

-- Run only after verifying the file paths:
-- EXEC dbo.usp_Master_Raw_Load;

exec dbo.usp_Master_Raw_Load

-- Verify RAW row counts:
SELECT 'raw_patients' AS Table_Name, COUNT(*) AS Row_Count FROM dbo.raw_patients
UNION ALL SELECT 'raw_providers', COUNT(*) FROM dbo.raw_providers
UNION ALL SELECT 'raw_payers', COUNT(*) FROM dbo.raw_payers
UNION ALL SELECT 'raw_encounters', COUNT(*) FROM dbo.raw_encounters
UNION ALL SELECT 'raw_diagnoses', COUNT(*) FROM dbo.raw_diagnoses
UNION ALL SELECT 'raw_procedures', COUNT(*) FROM dbo.raw_procedures
UNION ALL SELECT 'raw_medications', COUNT(*) FROM dbo.raw_medications
UNION ALL SELECT 'raw_claims', COUNT(*) FROM dbo.raw_claims;
