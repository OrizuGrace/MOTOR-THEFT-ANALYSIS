# MOTOR-THEFT-ANALYSIS

# 1. Introduction 
Vehicle theft is a critical issue affecting various regions. This project aims to analyze vehicle 
theft patterns using a structured dataset containing stolen vehicle records, make details, and 
location details. The insights derived from this analysis will support law enforcement agencies, 
policymakers, and the general public in understanding trends and improving preventive 
measures. 
# 2. Data Overview 
The dataset consists of three tables: 
● Stolen Vehicle Table: Contains information on stolen vehicles, including vehicle type, 
color, location ID, make ID, model year, vehicle description, and date stolen. 
● Make Details Table: Provides information on vehicle brands, including make ID, make 
name, and make type. 
● Location Details Table: Includes region, population, location ID, country, and population 
density. 
# 3. Data Cleaning and Processing 
Data cleaning was performed using SQL to ensure accuracy and consistency before 
visualization in Excel. Key steps included: 
● Handling Missing Values: Checked for and removed or imputed missing data. 
● Data Type Corrections: Ensured correct data types for date, numerical, and categorical 
fields. 
● Joins and Relationships: Merged the tables using location ID and make ID for 
comprehensive analysis. 
● Feature Engineering: Extracted year and month from the date stolen column for trend 
analysis. 
# 4. Data Analysis and Key Insights 
Several SQL queries were executed to derive insights: 
● Most Stolen Vehicle Brands: Identified the top vehicle brands stolen using a COUNT 
query. 
● Theft Trends by Year and Month: Grouped theft occurrences by year and month to 
identify seasonality. 
● Thefts by Location & Population Density: Analyzed theft distribution across regions 
with different population densities. 
● Thefts by Day of the Week: Determined which days had the highest theft occurrences. 
● Moving Average for Theft Trends: Implemented a 7-month moving average to 
smoothen trends and forecast patterns. 
# 5. Dashboard Design in Excel 
To create a dynamic dashboard in Excel, the following steps were taken: 
● Data Import: SQL views were imported into Excel using Power Query. 
● Pivot Tables and Charts: Created pivot tables for theft trends, vehicle brands, and 
geographic distribution. 
● KPIs: Calculated key metrics such as total thefts, highest-risk locations, and most stolen 
brands. 
● Slicers for Interactivity: Enabled filtering by year, location, and vehicle type. 
● Conditional Formatting: Highlighted critical trends dynamically. 
# 6. Key Findings & Recommendations 
● Urban Areas Have Higher Thefts: Regions with higher population density recorded 
more theft cases. 
● Increase in Thefts Over Time: A rise in thefts was observed from 2021 to 2022, 
suggesting the need for increased security measures. 
● Weekend Thefts Are Common: The highest number of thefts occurred on weekends, 
indicating targeted criminal activities. 
● Certain Vehicle Brands Are More Targeted: Specific brands were stolen more 
frequently, possibly due to ease of resale or lack of security features. 
# 7. Conclusion 
This project successfully analyzed vehicle theft trends and visualized them in an interactive 
Excel dashboard. The insights can be leveraged to improve theft prevention strategies, enhance 
law enforcement patrol planning, and inform the public about high-risk areas.
