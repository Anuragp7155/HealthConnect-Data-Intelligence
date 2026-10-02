--log table

USE dev_HealthConnect_refined;


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

select * from dbo.Pipeline_Log

