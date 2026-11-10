/*
Script:   05_segmentation.sql
Purpose:  Assign each HCP to a segment (A-D) with a call strategy
Source:   pharma_commercial.hcp_scored
Output:   pharma_commercial.hcp_segmented
Logic:    A = High potential / Low share   -> Convert
          B = High potential / High share  -> Defend and grow
          C = Low potential  / High share  -> Maintain
          D = Low potential  / Low share   -> Minimise
Assumptions: Target cadences are proposed planning rules, not
          derived from the data. Adjust to field capacity.
*/

DROP TABLE IF EXISTS pharma_commercial.hcp_segmented;

CREATE TABLE pharma_commercial.hcp_segmented AS
SELECT
  s.*,
  CASE
    WHEN potential_tier = 'High' AND share_level = 'Low'  THEN 'A'
    WHEN potential_tier = 'High' AND share_level = 'High' THEN 'B'
    WHEN potential_tier = 'Low'  AND share_level = 'High' THEN 'C'
    ELSE 'D'
  END AS segment,
  CASE
    WHEN potential_tier = 'High' AND share_level = 'Low'  THEN 'Convert'
    WHEN potential_tier = 'High' AND share_level = 'High' THEN 'Defend and grow'
    WHEN potential_tier = 'Low'  AND share_level = 'High' THEN 'Maintain'
    ELSE 'Minimise'
  END AS strategy,
  CASE
    WHEN potential_tier = 'High' AND share_level = 'Low'  THEN 'Field visit every 2 weeks'
    WHEN potential_tier = 'High' AND share_level = 'High' THEN 'Field visit monthly'
    WHEN potential_tier = 'Low'  AND share_level = 'High' THEN 'Digital-first, field quarterly'
    ELSE 'Digital / inside sales only'
  END AS target_cadence
FROM pharma_commercial.hcp_scored s;

---- Summary by segement
SELECT
  segment, strategy,
  COUNT(*)                                              AS hcps,
  SUM(total_cardio_rx)                                  AS market_rx,
  SUM(our_brand_rx)                                     AS our_rx,
  ROUND(100.0 * SUM(our_brand_rx) / SUM(total_cardio_rx), 1) AS segment_share_pct,
  SUM(whitespace_rx)                                    AS whitespace_rx,
  ROUND(100.0 * SUM(total_cardio_rx) / SUM(SUM(total_cardio_rx)) OVER (), 1) AS pct_of_market,
  ROUND(AVG(last_call_days_ago), 1)                     AS avg_days_since_call
FROM pharma_commercial.hcp_segmented
GROUP BY segment, strategy
ORDER BY segment;

----- Where Call Effort is Misallocated
SELECT
  COUNT(*) FILTER (WHERE segment = 'D' AND last_call_days_ago <= 30) AS d_called_last_30d,
  COUNT(*) FILTER (WHERE segment = 'A' AND last_call_days_ago > 60)  AS a_not_called_60d_plus
FROM pharma_commercial.hcp_segmented;

----- Tier A target by region
SELECT territory_region,
       COUNT(*) FILTER (WHERE segment = 'A') AS tier_a_hcps,
       COUNT(*)                              AS total_hcps,
       ROUND(100.0 * SUM(our_brand_rx) / SUM(total_cardio_rx), 1) AS region_share_pct
FROM pharma_commercial.hcp_segmented
GROUP BY territory_region
ORDER BY tier_a_hcps DESC;