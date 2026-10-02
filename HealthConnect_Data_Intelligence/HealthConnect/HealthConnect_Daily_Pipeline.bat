@echo off

sqlcmd -S localhost\SQLEXPRESS -E -C -d dev_HealthConnect_refined -Q "EXEC dbo.usp_Master_Cleansed_To_Refined;" -b

if %ERRORLEVEL% EQU 0 (
    echo Pipeline completed successfully.
) else (
    echo Pipeline failed.
)

exit /b %ERRORLEVEL%