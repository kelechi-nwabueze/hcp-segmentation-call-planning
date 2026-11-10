
/*
Script:   01_create_table.sql
Purpose:  Creating the raw HCP table before importing the CSV
Source:   cardiology_hcp_targeting_synthetic_2500.csv
Output:   pharma_commercial.hcp (empty, ready for import)
Notes:    No primary key set because the raw file contains
          duplicate HCP_IDs. These are handled in step 03.
*/

CREATE TABLE pharma_commercial.hcp (
  hcp_id               VARCHAR(20),
  hcp_name             VARCHAR(100),
  territory_region     VARCHAR(50),
  total_cardio_rx      INT,
  our_brand_rx         INT,
  competitor_brand_rx  INT,
  digital_engagement   NUMERIC(5,1),
  last_call_days_ago   INT
);