USE dev_HealthConnect_raw;


TRUNCATE TABLE dbo.raw_patients;
BULK INSERT dbo.raw_patients
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\patients_20260923.csv.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);


TRUNCATE TABLE dbo.raw_providers;

BULK INSERT dbo.raw_providers
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\providers_20260923.csv.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);



TRUNCATE TABLE dbo.raw_payers;

BULK INSERT dbo.raw_payers
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\payers_20260923.csv.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);



TRUNCATE TABLE dbo.raw_encounters;

BULK INSERT dbo.raw_encounters
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\encounters_20260923.csv.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);



TRUNCATE TABLE dbo.raw_diagnoses;

BULK INSERT dbo.raw_diagnoses
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\diagnoses_20260923.csv.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);





TRUNCATE TABLE dbo.raw_procedures;

BULK INSERT dbo.raw_procedures
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\procedures_20260923.csv.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);



TRUNCATE TABLE dbo.raw_medications;

BULK INSERT dbo.raw_medications
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\medications_20260923.csv.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);



TRUNCATE TABLE dbo.raw_claims;

BULK INSERT dbo.raw_claims
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\claims_20260923.csv.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);




CREATE TABLE #diagnoses_stage
(
    diagnosis_id VARCHAR(50),
    encounter_id VARCHAR(50),
    diagnosis_description VARCHAR(100),
    is_primary VARCHAR(50)
);


BULK INSERT #diagnoses_stage
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\diagnoses_20260923.csv.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);

SELECT *
FROM #diagnoses_stage;

DROP TABLE IF EXISTS dbo.raw_diagnoses;
CREATE TABLE dbo.raw_diagnoses
(
    diagnosis_id INT PRIMARY KEY,
    encounter_id INT NOT NULL,
    diagnosis_description VARCHAR(100),
    is_primary BIT
);

BULK INSERT dbo.raw_diagnoses
FROM 'D:\Oracle\IntelliBI (SQL)\Project\HealthConnect_Data_Intelligence\HealthConnect\InboundFiles\diagnoses_20260923.csv.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'
);




--------

TRUNCATE TABLE dbo.raw_diagnoses;

INSERT INTO dbo.raw_diagnoses
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
    TRY_CONVERT(BIT, is_primary)
FROM #diagnoses_stage;

SELECT COUNT(*) AS total_rows
FROM dbo.raw_diagnoses;


SELECT TOP 20 *
FROM dbo.raw_diagnoses;

SELECT TOP 20 *
FROM dbo.raw_diagnoses;

------
TRUNCATE TABLE dbo.raw_diagnoses;

INSERT INTO dbo.raw_diagnoses
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
        WHEN LTRIM(RTRIM(REPLACE(is_primary, CHAR(13), ''))) = '1' THEN 1
        WHEN LTRIM(RTRIM(REPLACE(is_primary, CHAR(13), ''))) = '0' THEN 0
        ELSE NULL
    END
FROM #diagnoses_stage;


SELECT TOP 20 *
FROM dbo.raw_diagnoses;


SELECT DISTINCT
    is_primary,
    '[' + is_primary + ']' AS visible_value,
    LEN(is_primary) AS value_length,
    DATALENGTH(is_primary) AS byte_length
FROM #diagnoses_stage;

----real--diagonisis

TRUNCATE TABLE dbo.raw_diagnoses;

INSERT INTO dbo.raw_diagnoses
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
        WHEN LTRIM(RTRIM(REPLACE(is_primary, CHAR(13), ''))) = '1'
            THEN 1
        WHEN LTRIM(RTRIM(REPLACE(is_primary, CHAR(13), ''))) = '0'
            THEN 0
        ELSE NULL
    END
FROM #diagnoses_stage;


SELECT TOP 20 *
FROM dbo.raw_diagnoses;

SELECT COUNT(*) AS null_is_primary
FROM dbo.raw_diagnoses
WHERE is_primary IS NULL;