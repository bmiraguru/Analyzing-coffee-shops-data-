#Analysed  data related to  coffee shops and their sales using SQL. Utilized skills such as  joins,CTEs, Window Functions(Lead,Rank and Dense_rank),Text functions ,Aggregations and other intermediate to advanced functions#

SELECT * FROM Parks_and_Recreation.employees;

#Gender bifcurcation of its employees#
SELECT 
    COUNT(*) AS totalcount, gender
FROM
    employees
GROUP BY gender
ORDER BY totalcount DESC;


#Gender birfurcation % of employees#

SELECT 
    gender,
    COUNT(*) AS count,
    ROUND((COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    employees)) * 100,
            0) AS percentage
FROM
    employees
GROUP BY
  gender order by percentage desc;
  
#No of employees hired over the year#
SELECT 
    COUNT(*) AS totalcount, YEAR(`hire_date`) AS hireyear
FROM
    employees
GROUP BY hireyear
ORDER BY hireyear;


#Combining first name and last name to fullname#

SELECT 
    *, CONCAT(`first_name`, ' ', `last_name`) AS fullname
FROM
    employees;
    
#Aggregations on the salary column#    

SELECT 
    ROUND(AVG(salary), 0) as avgsalary, MAX(salary) as maxsalary, MIN(salary) as minsalary, max(salary)-min(salary) as rangesalary,sum(salary) as totalsalary
FROM
    employees;
    


#Joining tables to get more insights on the employees of each coffeeshop#  

#No of employees per coffeeshop#
with cte as (select s.`coffeeshop_name` from employees e  join shops s on e.`coffeeshop_id`=s.`coffeeshop_id`)
select`coffeeshop_name`,count(*) as totalcount from cte group by `coffeeshop_name` order by totalcount desc;


#No of shops per country#
with cte as (select l.country ,l.city from shops ss join locations l on ss.`city_id`=l.`city_id`)
select count(*) as totalshops,country from cte group by country order by totalshops desc;

#Using sub queries to get the maximum salary#
SELECT 
    *
FROM
    employees
WHERE
    salary IN (SELECT 
            MAX(salary)
        FROM
            employees);
            
#Employees who get more than the overall average salary of the companies#            
            
            
  sELECT 
    *
FROM
    employees
WHERE
    salary > (SELECT 
		avg(salary)
        FROM
            employees); 
            
              
#Employees who get less than the overall average salary of all the companies#            
            
            
  sELECT 
    *
FROM
    employees
WHERE
    salary < (SELECT 
		avg(salary)
        FROM
            employees);          
   
#Employees who were hired less than 30 days from the hiring date of the current employee and their moving total#
   
with cte2 as (with cte1 as (with cte as (select * , lead(`hire_date`) over(order by `hire_date`) as nxthiredate from employees)
select *,datediff(nxthiredate,`hire_date`)as diff from cte)
select * from cte1 where diff<=30)
select `hire_date`, salary,sum(salary) over( order by `hire_date` rows between unbounded preceding and current row) as paypattern from cte2;

   
#Second maximum salary#

 SELECT 
    *
FROM
    employees
ORDER BY salary DESC
LIMIT 1 OFFSET 1;

#Supplier analysis by joining tables#


#Individual count of no of shops the suppliers provide their services to#
SELECT 
    COUNT(*) AS totalshops, `supplier_name`
FROM
    (SELECT 
        sh.`coffeeshop_name`, su.`supplier_name`, su.`coffee_type`
    FROM
        shops sh
    JOIN suppliers su ON sh.`coffeeshop_id` = su.`coffeeshop_id`) a
GROUP BY `supplier_name`
ORDER BY totalshops DESC;


#Most preferred coffeetype#

SELECT 
    COUNT(*) AS beancount, `coffee_type`
FROM
    suppliers
GROUP BY `coffee_type`
ORDER BY beancount DESC;


#Extract year,month and date from hiredate#

SELECT
	hire_date as date,
	EXTRACT(YEAR FROM hire_date) AS year,
	EXTRACT(MONTH FROM hire_date) AS month,
	EXTRACT(DAY FROM hire_date) AS day
FROM employees;


#Employees who get the median salary in all the coffeeshops#

with cte1 as (WITH cte AS (
    SELECT
        salary,`coffeeshop_id`,
        CONCAT(`first_name`, ' ', `last_name`) AS fullname,
        CAST(DENSE_RANK() OVER ( partition by `coffeeshop_id` ORDER BY salary ASC) AS SIGNED) AS arn,
        CAST(DENSE_RANK() OVER ( partition by `coffeeshop_id`ORDER BY salary DESC ) AS SIGNED) AS drn
    FROM
        employees
)
SELECT salary as mediansalary,`coffeeshop_id`,fullname FROM cte WHERE ABS(arn - drn) <= 1)
select c.mediansalary,c.`coffeeshop_id`,s.`coffeeshop_name`,c.fullname as employeename from cte1 c join shops s on c.`coffeeshop_id`=s.`coffeeshop_id`;

#Hiring trend of Female employees over the years#

SELECT 
    COUNT(*) as femalecount, gender, YEAR(`hire_date`) AS hireyear
FROM
    employees
WHERE
    gender = 'F'
GROUP BY hireyear
ORDER BY hireyear ASC;

#Years where the current  year hiring count was lower than the previous year#

with cte1 as (with cte as(SELECT 
    YEAR(`hire_date`) AS hireyear,count(*) as currentyrcount
FROM
    employees
GROUP BY hireyear
ORDER BY hireyear ASC)
select *,lag(currentyrcount)over(order by hireyear asc) as prevyrcount from cte)
select * from cte1 where currentyrcount-prevyrcount<0;

#Avg salary of each coffeeshop#           
            
SELECT 
    `coffeeshop_name`, ROUND(AVG(salary), 0) AS avgsal
FROM
    (SELECT 
        e.salary, s.`coffeeshop_name`
    FROM
        employees e
    JOIN shops s ON e.`coffeeshop_id` = s.`coffeeshop_id`) a
GROUP BY `coffeeshop_name`
ORDER BY avgsal DESC;

#Total salary of each coffeeshop#  


SELECT 
    `coffeeshop_name`, sum(salary) AS totalsal
FROM
    (SELECT 
        e.salary, s.`coffeeshop_name`
    FROM
        employees e
    JOIN shops s ON e.`coffeeshop_id` = s.`coffeeshop_id`) a
GROUP BY `coffeeshop_name`
ORDER BY totalsal DESC;


#Avg salary over the years in all the companies#

SELECT 
    YEAR(`hire_date`) AS hireyear, ROUND(AVG(salary), 0) as avgsalary
FROM
    employees
GROUP BY hireyear order by hireyear asc;

#Avg salary per gender#
SELECT 
    gender, ROUND(AVG(salary), 0) as avgsalary
FROM
    employees
GROUP BY gender;


#Avg salary per city using multiple joins#

    select round(avg(salary),0) as avgsal,city from (SELECT 
      e.salary,l.city
    FROM
        employees e
    JOIN shops s ON e.`coffeeshop_id` = s.`coffeeshop_id`
    JOIN locations l ON l.`city_id` = s.`city_id`) a group by city order by avgsal desc;
    
#No of employees per city using multiple joins#

    select city,count(*) as totalemployeecount from (SELECT 
      e.salary,l.city
    FROM
        employees e
    JOIN shops s ON e.`coffeeshop_id` = s.`coffeeshop_id`
    JOIN locations l ON l.`city_id` = s.`city_id`) a group by city;    


#Average salary per country using multiple joins#


select round(avg(salary),0) as avgsal,country from (sELECT 
      country,salary
    FROM
        employees e
    JOIN shops s ON e.`coffeeshop_id` = s.`coffeeshop_id`
    JOIN locations l ON l.`city_id` = s.`city_id`)a group by country order by avgsal desc;
     
 #Employee count per country using multiple joins#

select count(*) as totalemployeecount,country from (SELECT 
      l.country
    FROM
        employees e
    JOIN shops s ON e.`coffeeshop_id` = s.`coffeeshop_id`
    JOIN locations l ON l.`city_id` = s.`city_id`) a group by country;  



#Hiring trend across the companies over the years#
WITH cte AS (
  SELECT 
   
    e.coffeeshop_id AS id,e.`hire_date`,
    s.`coffeeshop_name`
  FROM employees e
  JOIN shops s ON e.coffeeshop_id = s.coffeeshop_id
)
SELECT YEAR(cte.`hire_date`) AS hire_year, COUNT(*) AS employee_count,`coffeeshop_name`
FROM cte
GROUP BY hire_year,`coffeeshop_name`;

#Salary of male and female employees coffeeshop wise#

SELECT 
    `coffeeshop_name`, ROUND(AVG(salary), 0) AS avgsal,gender
FROM
    (SELECT 
        e.salary, s.`coffeeshop_name`,gender
    FROM
        employees e
    JOIN shops s ON e.`coffeeshop_id` = s.`coffeeshop_id`) a
GROUP BY `coffeeshop_name`,gender
ORDER BY avgsal DESC;

#Avg Salary  trend for female employees over the years# 
with cte as (SELECT 
   ROUND(AVG(salary), 0) AS avgsal,gender,hireyear
FROM
    (SELECT 
        e.salary, year(e.`hire_date`) as hireyear ,gender
    FROM
        employees e
    JOIN shops s ON e.`coffeeshop_id` = s.`coffeeshop_id`) a
    GROUP BY gender,hireyear
ORDER BY avgsal DESC)
select * from cte where gender="F" order by hireyear;

#Gender bifurcation % across  all the coffee shops#
 
	with cte as (SELECT
    `coffeeshop_id`,
    gender,
    round((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY `coffeeshop_id`)),0) AS genderpercentage
FROM
    employees
GROUP BY
    `coffeeshop_id`, gender)
    select s.`coffeeshop_name`, c.gender,c.genderpercentage from cte c join shops s on c.`coffeeshop_id`=s.`coffeeshop_id`;













