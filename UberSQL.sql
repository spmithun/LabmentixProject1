Create database IF NOT EXISTS LabmentixProject1;
USE LabmentixProject1;


CREATE TABLE UberRides_raw (
  Request_id INT,
  Pickup_point VARCHAR(20),
  Driver_id VARCHAR(10),
  Status VARCHAR(30),
  Request_timestamp VARCHAR(30),
  Request_Time VARCHAR(10),
  Request_Date VARCHAR(15),
  Request_Day VARCHAR(15),
  Request_Time_of_the_day VARCHAR(30),
  Drop_timestamp VARCHAR(30),
  Drop_Time VARCHAR(10),
  Drop_Date VARCHAR(15),
  Drop_Day VARCHAR(15)
);

SELECT * FROM uberrides_raw LIMIT 10;
SELECT COUNT(*) AS total_rows FROM UberRides_raw;



CREATE TABLE UberRides (
  Request_id INT NULL,
  Pickup_point VARCHAR(20) NULL,
  Driver_id VARCHAR(10) NULL,
  Status VARCHAR(30) NULL,
  Request_timestamp DATETIME NULL,
  Request_Time TIME NULL,
  Request_Date DATE NULL,
  Request_Day VARCHAR(15) NULL,
  Request_Time_of_the_day VARCHAR(30) NULL,
  Drop_timestamp DATETIME NULL,
  Drop_Time TIME NULL,
  Drop_Date DATE NULL,
  Drop_Day VARCHAR(15) NULL
);


INSERT INTO UberRides (
  Request_id,
  Pickup_point,
  Driver_id,
  Status,
  Request_timestamp,
  Request_Time,
  Request_Date,
  Request_Day,
  Request_Time_of_the_day,
  Drop_timestamp,
  Drop_Time,
  Drop_Date,
  Drop_Day
)
SELECT
  Request_id,
  Pickup_point,
  Driver_id,
  Status,
  NULLIF(Request_timestamp, ''),
  NULLIF(Request_Time, ''),
  NULLIF(Request_Date, ''),
  Request_Day,
  Request_Time_of_the_day,
  NULLIF(Drop_timestamp, ''),
  NULLIF(Drop_Time, ''),
  NULLIF(Drop_Date, ''),
  Drop_Day
FROM UberRides_raw;


SELECT * FROM uberrides LIMIT 10;
SELECT COUNT(*) AS total_rows FROM UberRides;



-- GENERAL OVERVIEW INSIGHTS
-- 1. Total Requests and Status-wise Request Count
SELECT 
  COUNT(*) AS total_requests,
  SUM(Status = 'Trip Completed') AS trip_completed,
  SUM(Status = 'Cancelled') AS cancelled,
  SUM(Status = 'No Cars Available') AS no_cars_available
FROM UberRides;

-- 2. Requests by Pickup Point
SELECT Pickup_point, COUNT(*) AS count 
FROM UberRides 
GROUP BY Pickup_point;

-- 3. Time of Day Demand Split
SELECT Request_Time_of_the_day, COUNT(*) AS count
FROM UberRides
GROUP BY Request_Time_of_the_day;

-- 4. Day wise Comparison
SELECT Request_Day, COUNT(*) AS count
FROM UberRides
GROUP BY Request_Day;

-- 5. Cancellation Rate
SELECT ROUND(100 * SUM(Status = 'Cancelled') / COUNT(*), 2) AS cancellation_rate_percent 
FROM UberRides;

-- 6. Completion Rate
SELECT ROUND(100 * SUM(Status = 'Trip Completed') / COUNT(*), 2) AS completion_rate_percent 
FROM UberRides;

-- 7. No Cars Rate
SELECT ROUND(100 * SUM(Status = 'No Cars Available') / COUNT(*), 2) AS no_car_rate_percent 
FROM UberRides;



-- TIME OF DAY INSIGHTS
-- 8. Most Problematic Time Slot (Highest unmet demand)
SELECT Request_Time_of_the_day,
       SUM(Status IN ('Cancelled', 'No Cars Available')) AS total_failed,
       SUM(Status = 'Trip Completed') AS total_completed,
  ROUND(100 * SUM(Status = 'Trip Completed') / COUNT(*), 2) AS completion_rate_percent,
  ROUND(100 * SUM(Status IN ('Cancelled', 'No Cars Available')) / COUNT(*), 2) AS failed_rate_percent
FROM UberRides
GROUP BY Request_Time_of_the_day
ORDER BY total_failed DESC;


-- 9. Ride Status Metrics by Time of Day
SELECT 
  Request_Time_of_the_day,
  COUNT(*) AS total_requests,
  SUM(Status = 'Trip Completed') AS total_completed,
  SUM(Status = 'Cancelled') AS total_cancelled,
  SUM(Status = 'No Cars Available') AS total_no_cars,
  ROUND(100 * SUM(Status = 'Trip Completed') / COUNT(*), 2) AS completion_rate_percent,
  ROUND(100 * SUM(Status = 'Cancelled') / COUNT(*), 2) AS cancellation_rate_percent,
  ROUND(100 * SUM(Status = 'No Cars Available') / COUNT(*), 2) AS no_cars_rate_percent
FROM UberRides
GROUP BY Request_Time_of_the_day
ORDER BY FIELD(Request_Time_of_the_day, 
  'Late Night', 'MidNight Hours', 'Early Morning', 'Morning', 
  'Late Morning', 'Afternoon', 'Evening', 'Night');

-- 10. Peak Unfulfilled Time Period (Cancellations)
SELECT Request_Time_of_the_day, COUNT(*) AS cancelled
FROM UberRides
WHERE Status = 'Cancelled'
GROUP BY Request_Time_of_the_day
ORDER BY cancelled DESC;

-- 11. Time Slot with Highest No Cars Available
SELECT Request_Time_of_the_day, COUNT(*) AS no_cars
FROM UberRides
WHERE Status = 'No Cars Available'
GROUP BY Request_Time_of_the_day
ORDER BY no_cars DESC;

-- 12. Driver Availability Issue Indicator
SELECT Request_Time_of_the_day,
       ROUND(100 * SUM(Status = 'No Cars Available') / COUNT(*), 2) AS driver_availability_issue_percent
FROM UberRides
GROUP BY Request_Time_of_the_day
ORDER BY driver_availability_issue_percent DESC;

-- 13. Average Trip Duration by Time of Day
SELECT Request_Time_of_the_day,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, Request_timestamp, Drop_timestamp)), 2) AS avg_duration_min
FROM UberRides
WHERE Status = 'Trip Completed'
GROUP BY Request_Time_of_the_day
ORDER BY FIELD(Request_Time_of_the_day,
  'Late Night', 'MidNight Hours', 'Early Morning', 'Morning', 
  'Late Morning', 'Afternoon', 'Evening', 'Night');


SELECT 
  Pickup_point,
  Request_Time_of_the_day,
  
  ROUND(100.0 * 
    (SUM(Status = 'No Cars Available') + SUM(Status = 'Cancelled')) / COUNT(*), 2
  ) AS `No Cars Available+Cancelled (%)`,
  
  ROUND(100.0 * 
    SUM(Status = 'Trip Completed') / COUNT(*), 2
  ) AS `Trip Completed (%)`
  
  FROM UberRides


GROUP BY Pickup_point, Request_Time_of_the_day
ORDER BY Pickup_point, FIELD(Request_Time_of_the_day,
  'Late Night', 'MidNight Hours', 'Early Morning', 'Morning Rush', 
  'Late Morning', 'Afternoon', 'Evening Rush', 'Night');



-- DAY BASED INSIGHTS
-- 14. Completion Rate by Day of Week
SELECT Request_Day,
       ROUND(100 * SUM(Status = 'Trip Completed') / COUNT(*), 2) AS completion_rate_percent
FROM UberRides
GROUP BY Request_Day
ORDER BY FIELD(Request_Day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday');

-- 15. Daily Ride Request Summary
SELECT 
  Request_Day,
  COUNT(*) AS total_requests,
  SUM(Status = 'Trip Completed') AS total_completed,
  SUM(Status = 'Cancelled') AS total_cancelled,
  SUM(Status = 'No Cars Available') AS total_no_cars,
  ROUND(100 * SUM(Status = 'Trip Completed') / COUNT(*), 2) AS completion_rate_percent,
  ROUND(100 * SUM(Status = 'Cancelled') / COUNT(*), 2) AS cancellation_rate_percent,
  ROUND(100 * SUM(Status = 'No Cars Available') / COUNT(*), 2) AS no_cars_rate_percent
FROM UberRides
GROUP BY Request_Day
ORDER BY Request_Day;



-- PICKUP POINT BASED INSIGHTS
-- 16. Completion Rate by Pickup Point
SELECT Pickup_point,
       ROUND(100 * SUM(Status = 'Trip Completed') / COUNT(*), 2) AS completion_rate_percent
FROM UberRides
GROUP BY Pickup_point;

-- 17. Total Unfulfilled Demand Count by Pickup Point
SELECT Pickup_point, COUNT(*) AS total_unfulfilled
FROM UberRides
WHERE Status IN ('Cancelled', 'No Cars Available')
GROUP BY Pickup_point
ORDER BY total_unfulfilled DESC;

-- 19. Pickup Point and Time Slot Demand Matrix
SELECT Pickup_point, Request_Time_of_the_day, COUNT(*) AS total_requests
FROM UberRides
GROUP BY Pickup_point, Request_Time_of_the_day
ORDER BY Pickup_point, FIELD(Request_Time_of_the_day,
  'Late Night', 'MidNight Hours', 'Early Morning', 'Morning Rush', 
  'Late Morning', 'Afternoon', 'Evening Rush', 'Night');

-- 20. Pickup Point and Day Slot Demand Matrix
SELECT 
  Pickup_point,
  Request_Day,
  COUNT(*) AS total_requests,
  SUM(Status = 'Trip Completed') AS total_completed,
  SUM(Status = 'Cancelled') AS total_cancelled,
  SUM(Status = 'No Cars Available') AS total_no_cars,
  ROUND(100 * SUM(Status = 'Trip Completed') / COUNT(*), 2) AS completion_rate_percent,
  ROUND(100 * SUM(Status = 'Cancelled') / COUNT(*), 2) AS cancellation_rate_percent,
  ROUND(100 * SUM(Status = 'No Cars Available') / COUNT(*), 2) AS no_car_rate_percent
FROM UberRides
GROUP BY Pickup_point, Request_Day
ORDER BY Pickup_point, FIELD(Request_Day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday');



-- DRIVER-RELATED INSIGHTS


-- 22. Top 10 Active Drivers
SELECT Driver_id, COUNT(*) AS completed_trips
FROM UberRides
WHERE Status = 'Trip Completed' AND Driver_id IS NOT NULL
GROUP BY Driver_id
ORDER BY completed_trips DESC
LIMIT 10;

-- 23. Drivers with Most Cancellations
SELECT Driver_id, COUNT(*) AS cancellations
FROM UberRides
WHERE Status = 'Cancelled' AND Driver_id IS NOT NULL
GROUP BY Driver_id
ORDER BY cancellations DESC
LIMIT 10;

-- 24. Driver-wise Average Trip Duration
SELECT Driver_id,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, Request_timestamp, Drop_timestamp)), 2) AS avg_duration_min
FROM UberRides
WHERE Status = 'Trip Completed'
GROUP BY Driver_id
ORDER BY avg_duration_min DESC
LIMIT 10;

-- 25. Combined Driver Performance Summary
SELECT 
  Driver_id,
  COUNT(*) AS total_assigned_trips,
  SUM(Status = 'Trip Completed') AS total_completed,
  SUM(Status = 'Cancelled') AS total_cancelled,
  ROUND(100 * SUM(Status = 'Trip Completed') / COUNT(*), 2) AS completion_rate_percent,
  ROUND(100 * SUM(Status = 'Cancelled') / COUNT(*), 2) AS cancellation_rate_percent,
  ROUND(AVG(CASE 
             WHEN Status = 'Trip Completed' 
             THEN TIMESTAMPDIFF(MINUTE, Request_timestamp, Drop_timestamp)
           END), 2) AS avg_trip_duration_min
FROM UberRides
WHERE Driver_id IS NOT NULL
GROUP BY Driver_id
ORDER BY total_assigned_trips DESC;

--  Summary of total, completed, and cancelled requests per driver
WITH DriverStats AS (
  SELECT 
    Driver_id,
    COUNT(*) AS total_requests,
    SUM(Status = 'Trip Completed') AS total_completed,
    SUM(Status = 'Cancelled') AS total_cancelled
  FROM UberRides
  WHERE Driver_id IS NOT NULL
  GROUP BY Driver_id
),
CancelCounts AS (
  SELECT 
    Driver_id,
    Pickup_point,
    COUNT(*) AS cancel_count
  FROM UberRides
  WHERE Status = 'Cancelled' AND Driver_id IS NOT NULL
  GROUP BY Driver_id, Pickup_point
),
MostCancelledPickup AS (
  SELECT Driver_id, Pickup_point
  FROM (
    SELECT 
      Driver_id,
      Pickup_point,
      ROW_NUMBER() OVER (PARTITION BY Driver_id ORDER BY COUNT(*) DESC) AS rn
    FROM UberRides
    WHERE Status = 'Cancelled' AND Driver_id IS NOT NULL
    GROUP BY Driver_id, Pickup_point
  ) ranked
  WHERE rn = 1
),
CancelBreakdown AS (
  SELECT
    Driver_id,
    SUM(CASE WHEN Pickup_point = 'Airport' THEN 1 ELSE 0 END) AS Airport_Cancellations,
    SUM(CASE WHEN Pickup_point = 'City' THEN 1 ELSE 0 END) AS City_Cancellations
  FROM UberRides
  WHERE Status = 'Cancelled' AND Driver_id IS NOT NULL
  GROUP BY Driver_id
)
SELECT 
  ds.Driver_id,
  ds.total_requests,
  ds.total_completed,
  ds.total_cancelled,
  ROUND(100 * ds.total_completed / ds.total_requests, 2) AS completion_rate_percent,
  mcp.Pickup_point AS Most_Cancelled_Pickup,
  cb.Airport_Cancellations,
  cb.City_Cancellations
FROM DriverStats ds
LEFT JOIN MostCancelledPickup mcp ON ds.Driver_id = mcp.Driver_id
LEFT JOIN CancelBreakdown cb ON ds.Driver_id = cb.Driver_id
ORDER BY ds.total_requests DESC;
