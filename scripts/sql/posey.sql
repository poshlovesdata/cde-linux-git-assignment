-- 1. Find a list of order IDs where either gloss_qty or poster_qty is greater than 4000. Only include the id field in the resulting table.
SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;

-- 2. Write a query that returns a list of orders where the standard_qty is zero and either the gloss_qty or poster_qty is over 1000.
SELECT *
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);

-- 3. Find all the company names that start with a 'C' or 'W', and where the primary contact contains 'ana' or 'Ana', but does not contain 'eana'.
SELECT company_name
FROM companies
WHERE (company_name LIKE 'C%' OR company_name LIKE 'W%')
  AND (primary_contact ILIKE '%ana%' AND primary_contact NOT ILIKE '%eana%');

-- 4. Provide a table that shows the region for each sales rep along with their associated accounts.
SELECT regions.region_name, sales_reps.name AS sales_rep_name, accounts.name AS account_name
FROM regions
JOIN sales_reps ON regions.id = sales_reps.region_id
JOIN accounts ON sales_reps.id = accounts.sales_rep_id
ORDER BY account_name;