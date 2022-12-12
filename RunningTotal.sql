SELECT
	invoice_id,
	invoice_total,
	SUM(invoice_total) OVER (ORDER BY invoice_id) AS total_sum
	FROM invoices
