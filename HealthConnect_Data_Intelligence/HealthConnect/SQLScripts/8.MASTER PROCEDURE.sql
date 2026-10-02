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


    /*
       5. DIAGNOSES
     */

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

---RUNNING THE MASTER PROCEDURE 

EXEC dbo.usp_Master_Cleansed_To_Refined;



SELECT
    Log_ID,
    Run_ID,
    Procedure_Name,
    Start_Time,
    End_Time,
    Status,
    Rows_Processed,
    Error_Message
FROM dbo.Pipeline_Log
ORDER BY Log_ID;