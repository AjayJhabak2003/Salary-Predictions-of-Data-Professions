use salary_prediction;
select * from salary_predictions;

##Total number of employees
SELECT COUNT(*) AS total_employees
FROM salary_predictions;

 ##Average salary
SELECT AVG(salary) AS average_salary
FROM salary_predictions;

##Distribution of designations
SELECT designation, COUNT(*) AS count
FROM salary_predictions
GROUP BY designation;

##Average ratings by designation
SELECT designation, AVG(ratings) AS average_ratings
FROM salary_predictions
GROUP BY designation;

##Salary Distribution by Age Group:
SELECT
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    AVG(salary) AS average_salary
FROM salary_predictions
GROUP BY age_group;

##Renamed column
ALTER TABLE salary_predictions
RENAME COLUMN `FIRST NAME` TO first_name;
ALTER TABLE salary_predictions
RENAME COLUMN `LAST NAME` TO last_name;
ALTER TABLE salary_predictions
RENAME COLUMN `LEAVES REMAINING` TO leaves_remaining;
ALTER TABLE salary_predictions
RENAME COLUMN `LEAVES USED` TO leaves_used;

##Top 5 Highest Salaries
SELECT first_name, last_name, salary
FROM salary_predictions
ORDER BY salary DESC
LIMIT 5;

##Number of Employees per Year of Joining
SELECT EXTRACT(YEAR FROM doj) AS joining_year, COUNT(*) AS count
FROM salary_predictions
GROUP BY EXTRACT(YEAR FROM doj)
ORDER BY joining_year;

##Gender Ratio by Unit
SELECT unit, 
       SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END) AS male_count,
       SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END) AS female_count,
       COUNT(*) AS total_count
FROM salary_predictions
GROUP BY unit;

##Average Rating by Gender and Designation:
SELECT sex, designation, AVG(ratings) AS average_ratings
FROM salary_predictions
GROUP BY sex, designation
ORDER BY sex, designation;

##Percentage of Leaves Remaining by Unit:
SELECT unit,
       AVG((leaves_remaining / (leaves_used + leaves_remaining)) * 100) AS percentage_leaves_remaining
FROM salary_predictions
GROUP BY unit;

##Employees with Highest Ratings
SELECT first_name, last_name, unit, ratings
FROM salary_predictions
WHERE ratings = (SELECT MAX(ratings) FROM salary_predictions);

##-Create a view for average salary by unit
CREATE VIEW avg_salary_by_unit AS
SELECT unit, AVG(salary) AS average_salary
FROM salary_predictions
GROUP BY unit;

SELECT * FROM avg_salary_by_unit;

##Calculate the cumulative salary by unit
SELECT unit, first_name, last_name, salary,
       SUM(salary) OVER (PARTITION BY unit ORDER BY salary ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_salary
FROM salary_predictions;

##Rank employees by salary within each unit
SELECT unit, first_name, last_name, salary,
       RANK() OVER (PARTITION BY unit ORDER BY salary DESC) AS salary_rank
FROM salary_predictions;

##Get employees with salary above average salary in their unit
SELECT first_name, last_name, unit, salary
FROM salary_predictions sp
WHERE salary > (SELECT AVG(salary) FROM salary_predictions WHERE unit = sp.unit);

##Use CASE to categorize employees by salary range
SELECT first_name, last_name, salary,
       CASE
           WHEN salary < 30000 THEN 'Low'
           WHEN salary BETWEEN 30000 AND 70000 THEN 'Medium'
           ELSE 'High'
       END AS salary_category
FROM salary_predictions;

## CTE for employees who joined after 2015
WITH recent_employees AS (
    SELECT first_name, last_name, salary, doj
    FROM salary_predictions
    WHERE doj > '2015-01-01'
)
SELECT * FROM recent_employees;

## Concatenate first name and last name
SELECT first_name, last_name, CONCAT(first_name, ' ', last_name) AS full_name
FROM salary_predictions;

##Extract the first letter of the first name
SELECT first_name, LEFT(first_name, 1) AS first_initial
FROM salary_predictions;

##Replace 'unknown' last name with 'Not Provided'
SELECT first_name, last_name, 
       CASE 
           WHEN last_name = 'unknown' THEN 'Not Provided'
           ELSE last_name
       END AS last_name_updated
FROM salary_predictions;

##Find Employees Earning Above the Average Salary of Their Unit
   SELECT first_name, last_name, unit, salary
   FROM salary_predictions sp
   WHERE salary > (SELECT AVG(salary) FROM salary_predictions WHERE unit = sp.unit);
   
   ##Employees in Units with Average Rating Above a Threshold
   SELECT first_name, last_name, unit, ratings
   FROM salary_predictions sp
   WHERE unit IN (
       SELECT unit
       FROM salary_predictions
       GROUP BY unit
       HAVING AVG(ratings) > 3
   );
   
   ##Top 3 Salaries in Each Unit
   SELECT first_name, last_name, unit, salary
   FROM salary_predictions sp1
   WHERE 3 > (
       SELECT COUNT(*)
       FROM salary_predictions sp2
       WHERE sp2.unit = sp1.unit
       AND sp2.salary > sp1.salary
   )
   ORDER BY unit, salary DESC;
   
   ##Calculate Bonus Based on Ratings
   SELECT first_name, last_name, ratings, salary,
       CASE
           WHEN ratings = 5 THEN salary * 0.20
           WHEN ratings = 4 THEN salary * 0.15
           WHEN ratings = 3 THEN salary * 0.10
           WHEN ratings = 2 THEN salary * 0.05
           ELSE 0
       END AS bonus
   FROM salary_predictions;

##Annual Review Status Based on Joining Date
   SELECT first_name, last_name, doj,
       CASE
           WHEN TIMESTAMPDIFF(YEAR, doj, CURDATE()) >= 1 THEN 'Eligible for Annual Review'
           ELSE 'Not Eligible'
       END AS review_status
   FROM salary_predictions;
   
   ##Flag Employees Close to Using All Their Leaves
   SELECT first_name, last_name, leaves_used, leaves_remaining,
       CASE
           WHEN leaves_remaining < 5 THEN 'Low'
           WHEN leaves_remaining BETWEEN 5 AND 10 THEN 'Moderate'
           ELSE 'Plenty'
       END AS leave_status
   FROM salary_predictions;
