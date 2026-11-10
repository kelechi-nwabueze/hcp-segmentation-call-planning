/*
Script:   03_clean_table.sql
Purpose:  Creating a clean HCP table with duplicates removed
Source:   pharma_commercial.hcp (2,500 rows)
Output:   pharma_commercial.hcp_clean 
Logic:    Drop records flagged "(CRM copy)"; Duplicate removed from 2500 to 2488
Notes:    Digital_Engagement NULLs left as-is (not used in
          share or potential calculations.
*/

DROP TABLE IF EXISTS pharma_commercial.hcp_clean;

CREATE TABLE pharma_commercial.hcp_clean AS
SELECT *
FROM pharma_commercial.hcp
WHERE hcp_name NOT LIKE '%CRM copy%';

-- Adding a primary key now that IDs are unique
ALTER TABLE pharma_commercial.hcp_clean
  ADD PRIMARY KEY (hcp_id);

---- Verifying my count
SELECT COUNT(*) FROM pharma_commercial.hcp_clean; 

SELECT COUNT(DISTINCT hcp_id) FROM pharma_commercial.hcp_clean;
--- Both returned with 2488 after cleaning.