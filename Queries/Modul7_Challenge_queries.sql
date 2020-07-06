-- Create new table for retiring employees
SELECT count(first_name)
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Joining retirement_info and dept_emp tables into current_emp. 
SELECT ri.emp_no,
		ri.first_name,
		ri.last_name,
		de.to_date
INTO current_emp
FROM retirement_info AS ri
LEFT JOIN dept_emp AS de
ON ri.emp_no=de.emp_no
WHERE de.to_date=('9999-01-01');

--CHALLENGE 1:

--Retiring Employees by Title, all titles during their employment:
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	tt.title,
	tt.from_date,
	s.salary
INTO retiring_employees_by_title1
FROM current_emp as ce
INNER JOIN titles AS tt
ON (ce.emp_no = tt.emp_no)
INNER JOIN salaries AS s
ON (ce.emp_no = s.emp_no);

--Retiring Employees by Title with most recent title/current title with WHERE:
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	tt.title,
	tt.from_date,
	s.salary
INTO retiring_employees_by_title2
FROM current_emp as ce
INNER JOIN titles AS tt
ON (ce.emp_no = tt.emp_no)
INNER JOIN salaries AS s
ON (ce.emp_no = s.emp_no)
WHERE tt.to_date='9999-01-01';

-- Retiring Employees by Title with most recent title/current title with PARTITION:
SELECT emp_no,
	first_name,
	last_name,
	title,
	from_date,
	salary 
INTO title_per_employee_partition
FROM
  (SELECT emp_no,
	first_name,
	last_name,
	title,
	from_date,
	salary, ROW_NUMBER() OVER 
(PARTITION BY (emp_no) ORDER BY from_date DESC) rn
   FROM retiring_employees_by_title2
  ) tmp WHERE rn = 1;

-- Employee count by title:
SELECT title, COUNT(title)
FROM retiring_employees_by_title2
GROUP BY title;

-- Employee count by title partition:
SELECT title, COUNT(title)
FROM title_per_employee_partition
GROUP BY title;

--CHALLENGE 2:

-- Mentorship Eligibility
SELECT
	e.emp_no,
	e.first_name,
	e.last_name,
	tt.title,
	tt.from_date,
	tt.to_date
INTO mentorship_eligibility
FROM employees AS e
INNER JOIN titles AS tt
ON (e.emp_no = tt.emp_no)
-- employees have a date of birth between 01/01/1965 and 12/31/1965
-- employees are current employees
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	AND (tt.to_date='9999-01-01');

-- Mentorship Eligibility with partition:
SELECT emp_no,
	first_name,
	last_name,
	title,
	from_date
FROM
  (SELECT emp_no,
	first_name,
	last_name,
	title,
	from_date,
	ROW_NUMBER() OVER 
(PARTITION BY (emp_no) ORDER BY from_date DESC) rn
   FROM mentorship_eligibility
  ) tmp WHERE rn = 1;

-- Number of employees eligible for mentorship 

SELECT COUNT(emp_no)
FROM mentorship_eligibility;