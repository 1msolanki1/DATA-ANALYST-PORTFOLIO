USE `Human Resources`; 
SELECT * FROM `Human Resources`;

-- Rename id column to emp_id
ALTER TABLE `Human Resources`
CHANGE COLUMN id emp_id VARCHAR(20)NULL;

-- Check data types of all columns
DESCRIBE `Human Resources`;

-- Change birthdate values to date
SELECT birthdate FROM `Human Resources`;
SET sql_safe_updates=0;
UPDATE  `Human Resources`
SET birthdate = CASE
  WHEN birthdate LIKE "%/%" THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
  WHEN birthdate LIKE "%-%" THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
  ELSE NULL
END;

-- Change birthdate column datatype
ALTER TABLE `Human Resources`
MODIFY COLUMN birthdate DATE;

-- Convert hire_date values to date
UPDATE  `Human Resources`
SET hire_date = CASE
  WHEN hire_date LIKE "%/%" THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
  WHEN hire_date LIKE "%-%" THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
  ELSE NULL
END;

SELECT hire_date FROM `Human Resources`;

-- Change hire_date column data type
ALTER TABLE `Human Resources`
MODIFY COLUMN hire_date DATE;

-- Convert termdate values to date and remove time
UPDATE `Human Resources`
SET termdate = date(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' ';

SELECT termdate FROM `Human Resources`;

-- Convert termdate column to date
ALTER TABLE `Human Resources`
MODIFY COLUMN termdate DATE;

-- Add age column
ALTER TABLE `Human Resources` ADD COLUMN age INT;
UPDATE `Human Resources`
SET age = timestampdiff(YEAR,birthdate,CURDATE());

SELECT birthdate,age FROM `Human Resources`;

SELECT 
min(age)AS youngest,
max(age) AS oldest
FROM `Human Resources`;

SELECT count(*) FROM `Human Resources` WHERE age <18;

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count
FROM `Human Resources`
WHERE age >= 18
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS count
FROM `Human Resources`
WHERE age >= 18
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT 
  MIN(age) AS youngest,
  MAX(age) AS oldest
FROM `Human Resources`
WHERE age >= 18 ;

SELECT FLOOR(age/10)*10 AS age_group, COUNT(*) AS count
FROM `Human Resources`
WHERE age >= 18
GROUP BY FLOOR(age/10)*10;

SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+' 
  END AS age_group, 
  COUNT(*) AS count
FROM 
  `Human Resources`
WHERE 
  age >= 18
GROUP BY age_group
ORDER BY age_group;

SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+' 
  END AS age_group, gender,
  COUNT(*) AS count
FROM 
  `Human Resources`
WHERE 
  age >= 18
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) as count
FROM  `Human Resources`
WHERE age >= 18
GROUP BY location;


-- 5. What is the average length of employment for employees who have been terminated?
SELECT ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) AS avg_length_of_employment
FROM `Human Resources`
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE() AND age >= 18;

SELECT ROUND(AVG(DATEDIFF(termdate, hire_date)),0)/365 AS avg_length_of_employment
FROM `Human Resources`
WHERE termdate <= CURDATE() AND age >= 18;

-- 6. How does the gender distribution vary across departments?
SELECT department, gender, COUNT(*) as count
FROM `Human Resources`
WHERE age >= 18
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) as count
FROM `Human Resources`
WHERE age >= 18
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT department, COUNT(*) as total_count, 
    SUM(CASE WHEN termdate <= CURDATE() AND termdate <> '0000-00-00' THEN 1 ELSE 0 END) as terminated_count, 
    SUM(CASE WHEN termdate = '0000-00-00' THEN 1 ELSE 0 END) as active_count,
    (SUM(CASE WHEN termdate <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*)) as termination_rate
FROM `Human Resources`
WHERE age >= 18
GROUP BY department
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by state?
SELECT location_state, COUNT(*) as count
FROM `Human Resources`
WHERE age >= 18
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
    YEAR(hire_date) AS year, 
    COUNT(*) AS hires, 
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations, 
    COUNT(*) - SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS net_change,
    ROUND(((COUNT(*) - SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END)) / COUNT(*) * 100),2) AS net_change_percent
FROM 
    `Human Resources`
WHERE age >= 18
GROUP BY 
    YEAR(hire_date)
ORDER BY 
    YEAR(hire_date) ASC;
    
    SELECT 
    year, 
    hires, 
    terminations, 
    (hires - terminations) AS net_change,
    ROUND(((hires - terminations) / hires * 100), 2) AS net_change_percent
FROM (
    SELECT 
        YEAR(hire_date) AS year, 
        COUNT(*) AS hires, 
        SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM 
       `Human Resources`
    WHERE age >= 18
    GROUP BY 
        YEAR(hire_date)
) subquery
ORDER BY 
    year ASC;

-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(DATEDIFF(CURDATE(), termdate)/365),0) as avg_tenure
FROM `Human Resources`
WHERE termdate <= CURDATE() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department;