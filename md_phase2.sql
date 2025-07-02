-- cleaning the employees table where the emails are nulls

select* from employee;
-- removing  the space between the first and last names using REPLACE().
select 
concat(lower(replace(employee_name, ' ','.')), '@ndogowater.gov') -- replace with fullstop and making it lower en adding the email using concat
from employee;

-- updating to their emails now
update employee
set email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov');

-- confrming the length of the phone numbers it should be 12 characters plus the code sign
select  length(phone_number)
from employee;

-- we found 13 characters lets trim it
select length(trim(phone_number))
from employee;

-- updating it to the table now
update employee
set phone_number = trim(phone_number);

-- Looking where our employees live (counting)
select count(employee_name) as num_of_employees,
town_name
from employee
group by town_name
order by num_of_employees desc
;

-- Getting three field surveyors with the most location visits.
select
-- emp.employee_name,
emp.assigned_employee_id,
count(v.visit_count) as num_of_visits
from employee as emp
join visits as v ON v.assigned_employee_id = emp.assigned_employee_id
group by emp.assigned_employee_id
order by num_of_visits desc
limit 3
;

-- achieving the same with a window function.
with employee_visit_count as ( -- calculating total number of counts first
select 
emp.assigned_employee_id,
COUNT(v.visit_count) AS num_of_visits -- Counts each visit record for the employee
    FROM
        employee AS emp
    JOIN
        visits AS v ON v.assigned_employee_id = emp.assigned_employee_id
    GROUP BY
        emp.assigned_employee_id
), 
ranked_employees as ( -- now applying the window function to rank
select 
assigned_employee_id,
num_of_visits,
rank() over (order by num_of_visits desc) as visit_rank
from employee_visit_count
)
select 
assigned_employee_id,
num_of_visits
from 
ranked_employees
-- where visit_rank <= 3
;

-- identifying those top 3 employees by there names, phone numbers and emails
-- here I noticed that the query is still running even though I had not included the non aggregated
-- values in the group by.. Correcting this with a cte 
select
emp.assigned_employee_id,
emp.employee_name,
emp.email,
count(v.visit_count) as num_of_visits
from employee as emp
join visits as v ON v.assigned_employee_id = emp.assigned_employee_id
group by emp.assigned_employee_id
order by num_of_visits desc
limit 3 ; 


-- corrected cte 

with employee_visit_count as (
-- total number of employee visists
SELECT
        v.assigned_employee_id,
        COUNT(v.visit_count) AS num_of_visits
    FROM
        visits AS v
    GROUP BY
        v.assigned_employee_id
)
select 
emp.assigned_employee_id,
    emp.employee_name,
    emp.email,
    emp.phone_number,
    evc.num_of_visits
FROM
    employee AS emp
    JOIN employee_visit_count as evc ON emp.assigned_employee_id = evc.assigned_employee_id
    order by 
    evc.num_of_visits desc 
    limit 3 ;
    
    -- looking into location table
    select*
    from location;
    -- counting records per town
select
town_name,
count(town_name) record_per_town
from location
group by town_name
order by record_per_town desc
limit 5
;

 -- counting records per province
 select
 province_name,
count(province_name) record_per_province
from location
group by province_name
 order by record_per_province desc
 limit 5
;

-- Now joining both town and province
select
province_name,
town_name,
count(town_name) as record_per_town
from location
group by 
province_name,
town_name
order by province_name
;

-- looking number of records of each location type 
-- comparing then by percentage
select 
location_type,
count(location_type) as num_sources,
round(COUNT(location_type) * 100.0 / (SELECT COUNT(*) FROM location)) AS percentage_of_total
from location
group by location_type
;

-- how many water sources do we have
select type_of_water_source,
count(type_of_water_source) as num_of_water_sources
from water_source
group by type_of_water_source
order by type_of_water_source desc
;

-- how many people use a specicif water source
select type_of_water_source,
round(avg(number_of_people_served)) as avg_people_per_source
from water_source
group by type_of_water_source
order by number_of_people_served  desc
;

-- The total number of people served by each type of water source in total
select 
type_of_water_source,
sum(number_of_people_served) as total_num_people_served,
round(sum(number_of_people_served) / 27000000 * 100 )as percentage_form
from water_source
group by type_of_water_source
order by number_of_people_served desc
;

-- ranking water sources based on the number of people it serves excluding those taps in homes.
with filtered_source_totals as (
select 
type_of_water_source,
sum(number_of_people_served) as total_num_people_served,
round(sum(number_of_people_served) / 27000000 * 100 )as percentage_of_people_served
from water_source 
where type_of_water_source != 'tap_in_home'
group by type_of_water_source
)
select type_of_water_source,
total_num_people_served,
percentage_of_people_served,
rank() over (order by total_num_people_served desc) as rank_by_people_served

from filtered_source_totals 
order by rank_by_people_served ;


-- which source should be fixed first? sources within each type assigned a rank 

select 
l.town_name,
l.address,
ws.source_id,
ws.type_of_water_source,
ws.number_of_people_served,
rank() over (partition by ws.type_of_water_source order by ws.number_of_people_served desc) as priority_rank
from water_source as ws 
JOIN visits as v ON ws.source_id = v.source_id
JOIN location as l ON  v.location_id = l.location_id
where ws.type_of_water_source != 'tap_in_home';

-- calculating how long the survey took in days
select
datediff(max(time_of_record), min(time_of_record)) as survey_duration_days
from visits
;

-- period in years
SELECT
    TIMESTAMPDIFF(year, MIN(time_of_record), MAX(time_of_record)) AS survey_duration_years
FROM
    md_water_services.visits;

-- calculating how long on average it takes to queue

select 
round(avg(nullif(time_in_queue, 0 )),2) as average_queue_time
from visits
;


-- 3. What is the average queue time on different days?
select 
dayname(time_in_queue) as day_of_week,
round(avg(nullif(time_in_queue, 0)),2) as average_queue_time
from visits
group by day_of_week
;


-- hour of day that people collect water
select 
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
round(AVG(NULLIF(time_in_queue, 0)),2) AS average_queue_time_minutes
from visits
group by hour_of_day
order by hour_of_day
;

-- using case() function to get the hours witihin each day used to queue
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
-- Thursday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
-- Friday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,

-- Sartuday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Sartuday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;