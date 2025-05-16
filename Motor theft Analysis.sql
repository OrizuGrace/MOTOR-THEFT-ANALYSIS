select *  from stolen_vehicles
-- Data Cleaning
SELECT COUNT(*) AS MissingVehicleType
FROM stolen_vehicles
WHERE vehicle_type IS NULL;

SELECT COUNT(*) AS MissingVehicleDesc
FROM stolen_vehicles
WHERE vehicle_desc IS NULL;

UPDATE t1
SET vehicle_desc = t2.vehicle_desc
FROM stolen_vehicles t1
JOIN stolen_vehicles t2 
    ON t1.make_id = t2.make_id
    AND t1.vehicle_type = t2.vehicle_type
WHERE t1.vehicle_desc IS NULL 
AND t2.vehicle_desc IS NOT NULL;


UPDATE t1
SET vehicle_type = t2.vehicle_type
FROM stolen_vehicles t1
JOIN stolen_vehicles t2 
    ON t1.make_id = t2.make_id
    AND t1.vehicle_desc = t2.vehicle_desc
WHERE t1.vehicle_type IS NULL 
AND t2.vehicle_type IS NOT NULL;

UPDATE stolen_vehicles
SET vehicle_type = 'Under Investigation'
WHERE vehicle_type IS NULL;

UPDATE stolen_vehicles
SET make_id = '0'
WHERE make_id IS NULL;

UPDATE stolen_vehicles
SET model_year = '0'
WHERE model_year IS NULL;

UPDATE stolen_vehicles
SET vehicle_desc = 'Under Investigation'
WHERE vehicle_desc IS NULL;

UPDATE stolen_vehicles
SET Color = 'Pending'
WHERE Color IS NULL;


--Checking for Duplicates
SELECT vehicle_id, COUNT(*) 
FROM Stolen_Vehicle 
GROUP BY vehicle_id
HAVING COUNT(*) > 1

--Modifying date column
ALTER TABLE stolen_vehicles
ALTER COLUMN date_stolen DATE;

--standardizing date
UPDATE stolen_vehicles
SET date_stolen = CONVERT(date, date_stolen, 120);

--TRIM
UPDATE stolen_vehicles
SET color = TRIM(color),
    vehicle_type = TRIM(vehicle_type),
    vehicle_desc = TRIM(vehicle_desc)
WHERE color IS NOT NULL OR vehicle_type IS NOT NULL OR vehicle_desc IS NOT NULL;

--checking for null values
SELECT COUNT(*)
FROM Stolen_Vehicle
WHERE vehicle_desc IS NULL
or Vehicle_type IS NULL;

--QUERYING FOR INSIGHTS
-- Geospatial insights

--1.what type of vehicles are being stolen, and their total?
SELECT vehicle_type,
COUNT(*) AS total_stolen     
FROM stolen_vehicle    
GROUP BY vehicle_type
ORDER BY total_stolen DESC;

-- 2.What are the Most & Least Stolen Vehicle Types by location?
--why are these cars the most stolen in this areas?
--what kind of enviroments would require certain kind of
--location Tasman, marlborough, west coast,  doesnt have any record of stolen car, due to lower population and density

--The most stolen vehicle by region
WITH RankedVehicles AS (
    SELECT 
        region, 
        vehicle_type, 
        COUNT(*) AS total_stolen,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY COUNT(*) DESC) AS rank_no
    FROM Stolen_Vehicle
    JOIN Location_Details ON Stolen_Vehicle.location_id = Location_Details.location_id
    GROUP BY region, vehicle_type
)
SELECT region, vehicle_type, total_stolen
FROM RankedVehicles
WHERE rank_no = 1;

-- The least stolen vehicle by region
WITH RankedVehicles AS (
    SELECT 
        region, 
        vehicle_type, 
        COUNT(*) AS total_stolen,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY COUNT(*) ASC) AS rank_no
    FROM Stolen_Vehicle
    JOIN Location_Details ON Stolen_Vehicle.location_id = Location_Details.location_id
    GROUP BY region, vehicle_type
)
SELECT region, vehicle_type, total_stolen
FROM RankedVehicles
WHERE rank_no = 1;


--3. What is the Average Age of Vehicles before being stolen?
SELECT 
    vehicle_type, 
    AVG(YEAR(date_stolen) - model_year) AS avg_vehicle_age_at_theft
FROM Stolen_Vehicle
GROUP BY vehicle_type
ORDER BY avg_vehicle_age_at_theft DESC;

--4. What region is the most and the least affected by the vehicle theft?
WITH RegionCounts AS (SELECT region,
COUNT(*) AS total_stolen,     
ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS most_rank,
ROW_NUMBER() OVER (ORDER BY COUNT(*) ASC) AS least_rank         
FROM Stolen_Vehicle
JOIN Location_Details ON Stolen_Vehicle.location_id = Location_Details.location_id
GROUP BY region        
)
SELECT region, total_stolen, 'Most Affected' AS category
FROM RegionCounts
WHERE most_rank = 1        
   
UNION ALL

SELECT region, total_stolen, 'Least Affected' AS category
FROM RegionCounts
WHERE least_rank = 1;

--calculate through percentile based categorization to know the least, most and moderate affected regions
WITH RegionCounts AS ( SELECT region,
COUNT(*) AS total_stolen    
FROM Stolen_Vehicle         
JOIN Location_Details ON Stolen_Vehicle.location_id = Location_Details.location_id        
GROUP BY region    
),    
RankedRegions AS (    
SELECT region, total_stolen,
NTILE(3) OVER (ORDER BY total_stolen DESC) AS region_category
FROM RegionCounts     
)
SELECT region, total_stolen,
CASE 
WHEN region_category = 1 THEN 'Most Affected'     
WHEN region_category = 2 THEN 'Moderately Affected'            
ELSE 'Least Affected'       
END AS category    
FROM RankedRegions
ORDER BY total_stolen DESC;     
        

--TIME SERIES

--1. Number of Stolen Vehicles by Day of the Week?
SELECT DATENAME(WEEKDAY, date_stolen) AS stolen_day,
COUNT(*) AS total_stolen    
FROM stolen_vehicle    
GROUP BY DATENAME(WEEKDAY, date_stolen)
ORDER BY total_stolen DESC;

--is vehicle theft increasing or decreasing over time?
SELECT YEAR(date_stolen) AS year, COUNT(*) AS total_stolen
FROM Stolen_Vehicle
GROUP BY YEAR(date_stolen)
ORDER BY year;

-- what is the most stolen Vehicle brand?
SELECT TOP 10 make_name,
COUNT(*) AS theft_count     
FROM stolen_vehicle   
JOIN make_details ON Stolen_Vehicle.make_id = Make_Details.make_id
GROUP BY make_name
ORDER BY theft_count DESC;

--what month has the highest theft 
SELECT YEAR(date_stolen) AS year, 
       MONTH(date_stolen) AS month, 
       COUNT(*) AS total_stolen
FROM Stolen_Vehicle
GROUP BY YEAR(date_stolen), MONTH(date_stolen)
ORDER BY total_stolen DESC;

--what kind of cars were stolen in march?
SELECT vehicle_type, COUNT(*) AS total_stolen
FROM Stolen_Vehicle
WHERE MONTH(date_stolen) = 3
GROUP BY vehicle_type
ORDER BY total_stolen DESC;

--Region with the most affected vehicle theft in each month
WITH Rankedregion AS (
    SELECT 
        MONTH(date_stolen) AS theft_month, 
       region, 
        COUNT(*) AS total_stolen,
        RANK() OVER (PARTITION BY MONTH(date_stolen) ORDER BY COUNT(*) DESC) AS rnk
    FROM Stolen_Vehicle S
    JOIN Location_Details L ON S.location_id = L.location_id
    GROUP BY MONTH(date_stolen), region
)
SELECT theft_month, region, total_stolen
FROM Rankedregion
WHERE rnk = 1
ORDER BY theft_month;



--do theft spike on weekends or weekday?
SELECT 
    CASE 
        WHEN DATEPART(WEEKDAY, date_stolen) IN (1, 7) THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS day_type,
    COUNT(*) AS total_stolen
FROM Stolen_Vehicle
GROUP BY 
    CASE 
        WHEN DATEPART(WEEKDAY, date_stolen) IN (1, 7) THEN 'Weekend' 
        ELSE 'Weekday' 
    END
ORDER BY total_stolen DESC;

-- Using moving average, what would be the future of the theft trend?

SELECT 
    DATEPART(YEAR, date_stolen) AS theft_year,
    DATEPART(MONTH, date_stolen) AS theft_month,
    COUNT(*) AS monthly_thefts,
    AVG(COUNT(*)) OVER (
        ORDER BY DATEPART(YEAR, date_stolen), DATEPART(MONTH, date_stolen)
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7_months
FROM stolen_vehicle
GROUP BY DATEPART(YEAR, date_stolen), DATEPART(MONTH, date_stolen)
ORDER BY theft_year, theft_month;


-- 1. Compare Theft Rates by Make Type
SELECT 
    make_type, 
    COUNT(*) AS total_stolen
FROM Make_Details
GROUP BY make_type
ORDER BY total_stolen DESC;

--Are Certain Car Types Targeted in Certain Months?
--Theft Patterns for Luxury vs. Standard Cars by Month
SELECT 
    MONTH(date_stolen) AS theft_month, 
    M.make_type, 
    COUNT(*) AS total_stolen
FROM Stolen_Vehicle S
JOIN Make_Details M ON S.make_id = M.make_id
GROUP BY MONTH(date_stolen), M.make_type
ORDER BY theft_month, total_stolen DESC;

--Government
--1. Crime Trends for Law Enforcement Planning
SELECT 
    YEAR(date_stolen) AS theft_year, 
    MONTH(date_stolen) AS theft_month, 
    COUNT(*) AS total_stolen
FROM Stolen_Vehicle
GROUP BY YEAR(date_stolen), MONTH(date_stolen)
ORDER BY theft_year, theft_month

CREATE VIEW Stolen_Vehicle_View AS
SELECT
    sv.vehicle_id,
    -- Handle ModelYear (using 0 or -1 as placeholder)
    CASE
        WHEN sv.model_year = 0 THEN NULL  -- Replace 0 with NULL or another value if needed
        ELSE sv.model_year
    END AS ModelYear,
    
    -- Handle MakeID (using 0 as placeholder)
    CASE
        WHEN sv.make_id = 0 THEN NULL  -- Replace 0 with NULL or another value if needed
        ELSE sv.make_id
    END AS MakeID,

    sv.vehicle_desc,
    sv.Color,
    sv.vehicle_type,
	sv.date_stolen,
    ld.region,
    ld.country,
    ld.population,
	ld.density,
	md.make_type,
    md.make_name -- Assuming `make_details` table has a column MakeName
FROM
    stolen_vehicles sv
LEFT JOIN
    location_details ld ON sv.location_id = ld.location_id
LEFT JOIN
    make_details md ON sv.make_id = md.make_id;

select * from Stolen_Vehicle_View

CREATE VIEW Stolen_Vehicle_View AS
SELECT
    sv.vehicle_id,
    ISNULL(sv.model_year, 1900) AS ModelYear,  -- Replace NULL ModelYear with 1900
    ISNULL(sv.make_id, -1) AS MakeID,          -- Replace NULL MakeID with -1
    sv.vehicle_desc,
    sv.color,
    sv.vehicle_type,
    sv.date_stolen,
    ld.region,
    ld.country,
    ld.population,
    ld.density,
    ISNULL(md.make_type, 'Unknown') AS Make_Type,   -- Replace NULL Make_Type with "Unknown"
    ISNULL(md.make_name, 'Unknown') AS Make_Name    -- Replace NULL Make_Name with "Unknown"
FROM
    stolen_vehicles sv
LEFT JOIN
    location_details ld ON sv.location_id = ld.location_id
LEFT JOIN
    make_details md ON sv.make_id = md.make_id;

