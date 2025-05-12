SNOWFLAKE QUERY: 


CREATE WAREHOUSE weather_ware_hu;                              # Create warehouse                                        
USE WAREHOUSE weather_ware_hu;                                 # Select and activate the warehouse 

CREATE DATABASE weather_base_dt;                               # Create database
USE DATABASE weather_base_dt;                                  # Switch to use the database

CREATE SCHEMA weather_schema;                                     # Create a schema

CREATE STORAGE INTEGRATION s3_weather                         # Create a storage integration object for external S3 access
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE  
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::111122223333:role/fake-placeholder-role'
STORAGE_ALLOWED_LOCATIONS = ('s3://weatherdatapro/');            # Allow access only to `s3://weatherdatapro/` bucket

DESC INTEGRATION s3_weather;                                # Describe the details and security credentials of `s3_weather` 

ALTER STORAGE INTEGRATION s3_weather                        # Update the integration to use the correct IAM role
SET STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::333614442655:role/snowflake_s3access';  # set the real iam role arn

CREATE STAGE weather_stage                                  # Create an external stage
STORAGE_INTEGRATION = s3_weather                            # Link the stage to integration 
URL = 's3://weatherdatapro/'
FILE_FORMAT = (TYPE = JSON);

LIST @weather_stage;                                       # List all files available in the S3 stage
                              
USE SCHEMA weather_sch;

CREATE OR REPLACE TABLE weather_data (                    # Create or replace a table named `weather_data` with weather-related columns
    location_name STRING,
    "localtime" TIMESTAMP_NTZ,
    inserted_copy_time TIMESTAMP_NTZ,
    original_temp_c FLOAT,
    original_humidity FLOAT,
    dewpoint_c FLOAT,
    condition_text STRING,
    pressure_mb FLOAT,
    country STRING,
    cloud FLOAT,
    feelslike_f FLOAT,
    uv_index FLOAT,
    condition_icon STRING,
    wind_degree FLOAT,
    visibility_miles FLOAT,
    gust_mph FLOAT,
    wind_dir STRING,
    gust_kph FLOAT,
    condition_code STRING,
    windchill_f FLOAT,
    pressure_in FLOAT,
    region STRING,
    feelslike_c FLOAT,
    is_day BOOLEAN,
    latitude FLOAT,
    temp_c FLOAT,
    temp_f FLOAT,
    windchill_c FLOAT,
    wind_kph FLOAT,
    wind_mph FLOAT,
    heatindex_f FLOAT,
    precip_mm FLOAT,
    longitude FLOAT,
    timezone STRING,
    heatindex_c FLOAT,
    visibility_km FLOAT,
    dewpoint_f FLOAT,
    precip_in FLOAT
);

CREATE OR REPLACE PIPE weather_pipe                         # Create or replace a Snowpipe
AUTO_INGEST = TRUE
AS
COPY INTO weather_data                                      # Define COPY INTO command to load data into `weather_data` table
FROM @weather_stage                                         # Source from 'weather_stage'
FILE_FORMAT = (TYPE = 'JSON')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;                    # Match JSON keys to table columns case-insensitively


ALTER PIPE WEATHER_PIPE SET PIPE_EXECUTION_PAUSED=true;     # Pause the Snowpipe temporarily


GRANT OWNERSHIP ON PIPE weather_pipe TO ROLE SYSADMIN;      # Grant ownership of the pipe to SYSADMIN role


ALTER PIPE weather_pipe REFRESH;                            # Manually refresh the pipe to recognize existing files in S3 stage


CREATE OR REPLACE FILE FORMAT weather_json                  # Create or replace a named file format 
TYPE = 'JSON'
STRIP_NULL_VALUES = TRUE                                    # Remove null values from JSON objects on load
IGNORE_UTF8_ERRORS = TRUE;                                  # Ignore invalid UTF-8 characters during load


COPY INTO weather_data                                      # Manually load data into `weather_data` table (outside of Snowpipe)
FROM @weather_stage
FILE_FORMAT = (FORMAT_NAME = 'weather_json')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

SELECT * FROM weather_data;                                 # Query all records from `weather_data` table to verify load
