-- Task 1:
-- Create a visualization that provides a breakdown between the male and female employees working in the company each year, starting from 1990. 

select 
year(de.from_date) calender_year,
e.gender,
count(de.from_date) number_of_emp
from t_employees e
join t_dept_emp de
on de.emp_no = e.emp_no
group by calender_year, gender
having calender_year >= 1990
order by 1


