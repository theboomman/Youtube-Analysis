# Youtube-Analysis
System Setup Steps
![Diagram](https://github.com/user-attachments/assets/d696a805-edb0-4356-8bd3-a77aa62660b6)
Fig. 3 List of JSON files of 10 countries

The horizontal data pipeline diagram visually represents the end-to-end workflow of this YouTube trending video analysis project using AWS and Snowflake. Each component in the pipeline plays a specific role in processing, transforming, and analyzing the data:

Data Sources:
The pipeline begins with raw CSV and JSON files downloaded from Kaggle, containing YouTube trending video data across various countries and categories from 2020 to 2024.

AWS Cloud Storage (S3):
These raw datasets are uploaded to an Amazon S3 bucket named self-learning-project. S3 acts as a centralized, scalable storage layer that facilitates secure access for downstream services.

AWS Glue Data Catalog & Crawler:
AWS Glue scans the data in S3, infers the schema of both CSV and JSON files, and catalogs them for easier querying. This automation eliminates manual metadata handling and prepares the data for seamless integration.

Snowflake Data Lake:
Snowflake accesses the structured data via external tables. It performs data integration (e.g., joining trending videos with category information) and data cleaning, removing duplicates, fixing missing values, and parsing metadata. The result is a refined dataset ready for analytics.

Data Analysis & Insights:
Finally, SQL queries are executed in Snowflake to generate actionable insights, such as identifying top-performing video categories, analyzing regional trends, and making strategic recommendations like selecting the gaming category for a new YouTube channel.
This pipeline ensures a robust, scalable, and efficient approach to large-scale video data analysis.
