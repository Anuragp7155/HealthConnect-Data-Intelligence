-- Testing & Validation


USE dev_HealthConnect_raw;

SELECT 'raw_patients' AS Table_Name, COUNT(*) AS Row_Count FROM dbo.raw_patients
UNION ALL
SELECT 'raw_providers', COUNT(*) FROM dbo.raw_providers
UNION ALL
SELECT 'raw_payers', COUNT(*) FROM dbo.raw_payers
UNION ALL
SELECT 'raw_encounters', COUNT(*) FROM dbo.raw_encounters
UNION ALL
SELECT 'raw_diagnoses', COUNT(*) FROM dbo.raw_diagnoses
UNION ALL
SELECT 'raw_procedures', COUNT(*) FROM dbo.raw_procedures
UNION ALL
SELECT 'raw_medications', COUNT(*) FROM dbo.raw_medications
UNION ALL
SELECT 'raw_claims', COUNT(*) FROM dbo.raw_claims;




USE dev_HealthConnect_Cleansed;


SELECT 'cleansed_patients' AS Table_Name, COUNT(*) AS Row_Count FROM dbo.cleansed_patients
UNION ALL
SELECT 'cleansed_providers', COUNT(*) FROM dbo.cleansed_providers
UNION ALL
SELECT 'cleansed_payers', COUNT(*) FROM dbo.cleansed_payers
UNION ALL
SELECT 'cleansed_encounters', COUNT(*) FROM dbo.cleansed_encounters
UNION ALL
SELECT 'cleansed_diagnoses', COUNT(*) FROM dbo.cleansed_diagnoses
UNION ALL
SELECT 'cleansed_procedures', COUNT(*) FROM dbo.cleansed_procedures
UNION ALL
SELECT 'cleansed_medications', COUNT(*) FROM dbo.cleansed_medications
UNION ALL
SELECT 'cleansed_claims', COUNT(*) FROM dbo.cleansed_claims;



USE dev_HealthConnect_refined;

SELECT 'refined_patients' AS Table_Name, COUNT(*) AS Row_Count FROM dbo.refined_patients
UNION ALL
SELECT 'refined_providers', COUNT(*) FROM dbo.refined_providers
UNION ALL
SELECT 'refined_payers', COUNT(*) FROM dbo.refined_payers
UNION ALL
SELECT 'refined_encounters', COUNT(*) FROM dbo.refined_encounters
UNION ALL
SELECT 'refined_diagnoses', COUNT(*) FROM dbo.refined_diagnoses
UNION ALL
SELECT 'refined_procedures', COUNT(*) FROM dbo.refined_procedures
UNION ALL
SELECT 'refined_medications', COUNT(*) FROM dbo.refined_medications
UNION ALL
SELECT 'refined_claims', COUNT(*) FROM dbo.refined_claims;





--- Test 2 — Data Quality Validation

USE dev_HealthConnect_refined;

SELECT 'Patients' AS Table_Name, patient_id, COUNT(*) AS Duplicate_Count
FROM dbo.refined_patients
GROUP BY patient_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Providers', provider_id, COUNT(*)
FROM dbo.refined_providers
GROUP BY provider_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Payers', payer_id, COUNT(*)
FROM dbo.refined_payers
GROUP BY payer_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Encounters', encounter_id, COUNT(*)
FROM dbo.refined_encounters
GROUP BY encounter_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'Claims', claim_id, COUNT(*)
FROM dbo.refined_claims
GROUP BY claim_id
HAVING COUNT(*) > 1;


SELECT
    SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS Null_Patient_ID,
    SUM(CASE WHEN first_name IS NULL THEN 1 ELSE 0 END) AS Null_First_Name,
    SUM(CASE WHEN last_name IS NULL THEN 1 ELSE 0 END) AS Null_Last_Name
FROM dbo.refined_patients;



SELECT
    SUM(CASE WHEN claim_id IS NULL THEN 1 ELSE 0 END) AS Null_Claim_ID,
    SUM(CASE WHEN encounter_id IS NULL THEN 1 ELSE 0 END) AS Null_Encounter_ID,
    SUM(CASE WHEN payer_id IS NULL THEN 1 ELSE 0 END) AS Null_Payer_ID,
    SUM(CASE WHEN total_paid_amount IS NULL THEN 1 ELSE 0 END) AS Null_Paid_Amount
FROM dbo.refined_claims;


SELECT COUNT(*) AS Orphan_Claims
FROM dbo.refined_claims C
LEFT JOIN dbo.refined_encounters E
    ON C.encounter_id = E.encounter_id
WHERE E.encounter_id IS NULL;

SELECT COUNT(*) AS Orphan_Encounters
FROM dbo.refined_encounters E
LEFT JOIN dbo.refined_patients P
    ON E.patient_id = P.patient_id
WHERE P.patient_id IS NULL;

SELECT COUNT(*) AS Orphan_Payer_References
FROM dbo.refined_claims C
LEFT JOIN dbo.refined_payers P
    ON C.payer_id = P.payer_id
WHERE P.payer_id IS NULL;

SELECT COUNT(*) AS Orphan_Payer_References
FROM dbo.refined_claims C
LEFT JOIN dbo.refined_payers P
    ON C.payer_id = P.payer_id
WHERE P.payer_id IS NULL;


-- Test - KPI VALIDATION 

USE dev_HealthConnect_refined;



/* KPI 01 - Yearly Claim Trend */
SELECT *
FROM dbo.vw_KPI01_Yearly_Claim_Trend
ORDER BY Claim_Year;


/* KPI 02 - Payer Claims */
SELECT *
FROM dbo.vw_KPI02_Payer_Claims
ORDER BY Total_Paid_Claim_Amount DESC;


/* KPI 03 - Claim Amount by Period */
SELECT *
FROM dbo.vw_KPI03_Claim_Amount_Period;


/* KPI 04 - Provider Patient Engagement */
SELECT *
FROM dbo.vw_KPI04_Provider_Patient_Engagement
ORDER BY Engagement_Rank, Visit_Year;


/* KPI 05 - Diagnosis Claim Cost */
SELECT *
FROM dbo.vw_KPI05_Diagnosis_Claim_Cost
ORDER BY Total_Paid_Claim_Amount DESC;


/* KPI 06 - Yearly Visit & Claim Cost */
SELECT *
FROM dbo.vw_KPI06_Yearly_Visit_Claim_Cost
ORDER BY Visit_Year;


/* KPI 07 - Gender Claim Analysis */
SELECT *
FROM dbo.vw_KPI07_Gender_Claim_Analysis
ORDER BY gender;


/* KPI 08 - Most Prescribed Medications */
SELECT TOP 10 *
FROM dbo.vw_KPI08_Most_Prescribed_Medications
ORDER BY Prescription_Count DESC;


/* KPI 09 - Age Group Claims */
SELECT *
FROM dbo.vw_KPI09_Age_Group_Claims;


/* KPI 10 - Inpatient Stay YoY */
SELECT *
FROM dbo.vw_KPI10_Inpatient_Stay_YoY
ORDER BY Stay_Year;


/* KPI 11 - Paid Claim YoY */
SELECT *
FROM dbo.vw_KPI11_Paid_Claim_YoY
ORDER BY Claim_Year;



---------

USE dev_HealthConnect_refined;


EXEC dbo.usp_Master_Cleansed_To_Refined;


SELECT TOP 10 *
FROM dbo.Pipeline_Log
ORDER BY Log_ID DESC;
