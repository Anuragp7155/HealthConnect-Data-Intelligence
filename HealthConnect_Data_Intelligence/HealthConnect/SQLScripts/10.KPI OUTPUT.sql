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




