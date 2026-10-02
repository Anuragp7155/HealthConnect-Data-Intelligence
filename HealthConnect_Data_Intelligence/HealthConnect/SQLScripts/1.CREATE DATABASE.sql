CREATE DATABASE dev_HealthConnect_raw;

CREATE DATABASE dev_HealthConnect_cleansed;

CREATE DATABASE dev_HealthConnect_refined;

/*
USE dev_HealthConnect_refined;

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'refined_dw') EXEC('CREATE SCHEMA refined_dw');
*/