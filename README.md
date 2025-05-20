# Weather-Data-API 🌦️

This project collects real-time weather data from OpenWeather API, stores it in AWS DynamoDB and S3, and ingests it into Snowflake using Snowpipe.

## 🔧 Technologies Used
- AWS Lambda
- Amazon S3
- DynamoDB
- Snowflake
- Python
- SQL

## 📊 Architecture

   ![Architecture Diagram](architecture.jpeg)
## 📁 Files


🔁 Step-by-Step Process

🌦 OpenWeather API

Provides weather data.

🔗 EventBridge

Detects when new data is available and triggers the flow.

🧠 Lambda (1st)

Fetches and processes the weather data.

🪣 S3 + 📘 DynamoDB

Data is saved in S3 for storage and in DynamoDB for structured access.

📊 DynamoDB Stream → Lambda (2nd)

When DynamoDB is updated, it triggers another Lambda function.

📥 Lambda (2nd) → S3

This Lambda stores transformed data into S3 again.

🔑 IAM + Integration Gears

Provides secure access between S3 and Snowflake using roles.

📩 SQS

Notifies Snowflake when new data is in S3.

📤 External Stage + Snowpipe

Snowflake reads the file from S3 via the external stage, and Snowpipe loads it automatically.

❄️ SnowflakeDB

Data is stored in a Snowflake database.

📈 Power BI

Uses Snowflake data to create dashboards and visual reports


- `lambda_function.py`: Python Lambda code to fetch weather data
- `weather_pipeline_queries.sql`: Data ingestion & transformation queries
- `Taskpowerbi.pbix`: Power BI dashboard file for visualizing weather data
