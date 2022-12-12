-- Subtotals and Grand Totals with GROUP BY

SELECT office_id, job_title, SUM(Salary)
FROM employees
group by office_id, job_title WITH ROLLUP
