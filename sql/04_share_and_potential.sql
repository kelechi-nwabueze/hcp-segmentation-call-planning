/*
Script:   04_share_and_potential.sql
Purpose:  Calculate brand share, whitespace and potential tier per HCP
Source:   pharma_commercial.hcp_clean (2,488 rows)
Output:   pharma_commercial.hcp_scored
Logic:    brand_share   = our_brand_rx / total_cardio_rx
          whitespace_rx = total_cardio_rx - our_brand_rx
          potential_tier: High if total_cardio_rx >= median
          share_level:    High if HCP share >= overall brand share
Assumptions: Potential is measured by total cardio Rx volume.
          Share cutoff is the weighted overall share (total our Rx
          / total market Rx), not the average of HCP shares.
*/

DROP TABLE IF EXISTS pharma_commercial.hcp_scored;

CREATE TABLE pharma_commercial.hcp_scored AS
WITH cutoffs AS (
  SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_cardio_rx) AS potential_cutoff,
    SUM(our_brand_rx)::NUMERIC / SUM(total_cardio_rx)            AS share_cutoff
  FROM pharma_commercial.hcp_clean
)
SELECT
  h.*,
  ROUND(h.our_brand_rx::NUMERIC / h.total_cardio_rx, 4) AS brand_share,
  h.total_cardio_rx - h.our_brand_rx                    AS whitespace_rx,
  CASE WHEN h.total_cardio_rx >= c.potential_cutoff
       THEN 'High' ELSE 'Low' END                       AS potential_tier,
  CASE WHEN h.our_brand_rx::NUMERIC / h.total_cardio_rx >= c.share_cutoff
       THEN 'High' ELSE 'Low' END                       AS share_level
FROM pharma_commercial.hcp_clean h
CROSS JOIN cutoffs c;

---- Verifying my calculation and created columns
-- 1. Cutoffs (Potential cutoff= 86 and Share cutoff= 0.305)
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_cardio_rx) AS potential_cutoff,
  ROUND(SUM(our_brand_rx)::NUMERIC / SUM(total_cardio_rx), 4)   AS share_cutoff
FROM pharma_commercial.hcp_clean;

-- 2. Count per combination:
-----  High/High = 575
------ High/Low = 676
------ Low/High = 551
------ Low/Low = 686
SELECT potential_tier, share_level, COUNT(*) AS hcps
FROM pharma_commercial.hcp_scored
GROUP BY potential_tier, share_level
ORDER BY potential_tier, share_level;