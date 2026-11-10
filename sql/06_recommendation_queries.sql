/*
Script:   06_recommendation_queries.sql
Purpose:  Quantify the call-planning recommendation
Source:   pharma_commercial.hcp_segmented
Assumptions (illustrative, replace with company figures):
          - Share uplift scenarios of 3, 5 and 10 points in Tier A
          - Tier D field visits avoided: 12 per HCP per year
          - Average field visit including travel: 3 hours
Note:     Dataset has days since last call only, not call counts,
          so freed-visit estimates are scenarios, not measurements.
Findings: 'Gaining 5 share points in Tier A would add about 5,800 prescriptions.”		  
          The range is roughly 3,500 Rx at a cautious 3 points to 11,500 Rx at an ambitious 10 points.”
        

*/        

-- 1. Prescription growth scenarios from Tier A share uplift
----- 3 share_point = 3455 incremental_rx
----- 5 share_point =5758 incremental_rx
----- 10 share_point =11516 incremental_rx
WITH a AS (
  SELECT SUM(total_cardio_rx) AS a_market_rx
  FROM pharma_commercial.hcp_segmented
  WHERE segment = 'A'
)
SELECT u.uplift_pts AS share_uplift_points,
       ROUND(a.a_market_rx * u.uplift_pts / 100.0) AS incremental_rx
FROM a
CROSS JOIN (VALUES (3), (5), (10)) AS u(uplift_pts);

-- 2. Travel time released by moving Tier D to digital
----hcp recently visited =293, visit avoided per year=3516, field hour freed per year=10548
SELECT
  COUNT(*)                         AS d_hcps_recently_called,
  COUNT(*) * 12                    AS visits_avoided_per_year,
  COUNT(*) * 12 * 3                AS field_hours_freed_per_year
FROM pharma_commercial.hcp_segmented
WHERE segment = 'D' AND last_call_days_ago <= 30;

-- 3. Priority call list: Tier A, overdue, ranked by whitespace
SELECT hcp_id, hcp_name, territory_region,
       total_cardio_rx, brand_share, whitespace_rx, last_call_days_ago
FROM pharma_commercial.hcp_segmented
WHERE segment = 'A' AND last_call_days_ago > 60
ORDER BY whitespace_rx DESC;