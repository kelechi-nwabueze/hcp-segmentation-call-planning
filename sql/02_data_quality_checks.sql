/*
Script:   02_data_quality_checks.sql
Purpose:  Validate the raw HCP data before analysis
Source:   pharma_commercial.hcp
Checks:   row count, duplicate HCP_IDs, CRM copy records,
          missing values, Rx logic consistency
Findings: total_row (2500), 12 Duplicate hcp_id, 12 CRM copies,
          125 blank digital engagements, 0 logical error.
*/

-- 1. Total rows 
SELECT COUNT(*) AS total_rows
FROM pharma_commercial.hcp;

-- 2. Duplicate HCP_IDs 
SELECT hcp_id, COUNT(*) AS n
FROM pharma_commercial.hcp
GROUP BY hcp_id
HAVING COUNT(*) > 1
ORDER BY hcp_id;

-- 3. Records flagged as CRM copies 
SELECT COUNT(*) AS crm_copies
FROM pharma_commercial.hcp
WHERE hcp_name LIKE '%CRM copy%';

-- 4. Missing values per column
SELECT
  COUNT(*) FILTER (WHERE hcp_id IS NULL)              AS null_id,
  COUNT(*) FILTER (WHERE territory_region IS NULL)    AS null_region,
  COUNT(*) FILTER (WHERE total_cardio_rx IS NULL)     AS null_total_rx,
  COUNT(*) FILTER (WHERE our_brand_rx IS NULL)        AS null_our_rx,
  COUNT(*) FILTER (WHERE digital_engagement IS NULL)  AS null_digital
FROM pharma_commercial.hcp;


-- 5. Logic check: brand Rx should never exceed total Rx
SELECT COUNT(*) AS invalid_rows
FROM pharma_commercial.hcp
WHERE our_brand_rx + competitor_brand_rx > total_cardio_rx;