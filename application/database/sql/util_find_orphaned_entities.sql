-- THIS DETERMINES WHICH OBJECTIDs may be orphaned
WITH m AS (
SELECT DISTINCT
  "Creator"
  ,jsonb_strip_nulls(jsonb_agg(DISTINCT "Municipality")) AS "set_Municipality"
  ,jsonb_strip_nulls(jsonb_agg(DISTINCT "State or Territory")) AS "set_Region"
  ,jsonb_strip_nulls(jsonb_agg(DISTINCT "OBJECTID")) "set_OBJECTID"
FROM
  giscorps
GROUP BY 
  "Creator"
),
n AS (
SELECT
  "Creator"
  ,MIN("CreationDate"::TIMESTAMP) AS "min_CreationDate"
  ,MAX("CreationDate"::TIMESTAMP) AS "max_CreationDate"
  ,COUNT("OBJECTID") AS "count_OBJECTID"
FROM
  giscorps
GROUP BY 
  "Creator"
)
, o AS (
SELECT DISTINCT
  m."Creator"
  ,(EXTRACT(DAY FROM CURRENT_TIMESTAMP - "max_CreationDate"::TIMESTAMP) > 13)  AS "isInactive"
  ,"min_CreationDate"
  ,"max_CreationDate"
  ,"count_OBJECTID"
  ,EXTRACT(DAY FROM "max_CreationDate"::TIMESTAMP - "min_CreationDate"::TIMESTAMP)  AS "DaysActive"
  ,EXTRACT(DAY FROM CURRENT_TIMESTAMP - "max_CreationDate"::TIMESTAMP)  AS "DaysSinceActive"
  ,"set_Region"
  ,"set_Municipality"
  ,"set_OBJECTID"
FROM 
  m,n
WHERE
  m."Creator" = n."Creator"
ORDER BY
  "DaysSinceActive" DESC, 
  "Creator" ASC
)
,p AS (
  SELECT 
    1
    ,jsonb_strip_nulls(jsonb_agg(DISTINCT "Municipality")) AS "atrisk_Municipalities" 
    ,COUNT(DISTINCT "Municipality") AS "count_atrisk_Municipalities" 
  FROM o,  giscorps
  WHERE 
    o."Creator" = giscorps."Creator"
    AND o."isInactive"
  GROUP BY 1
)
,q AS (
  SELECT 
    1
    ,jsonb_strip_nulls(jsonb_agg(DISTINCT "OBJECTID")) AS "atrisk_OBJECTID" 
    ,COUNT(DISTINCT "OBJECTID") AS "count_atrisk_OBJECTID" 
  FROM o,  giscorps
  WHERE 
    o."Creator" = giscorps."Creator"
    AND o."isInactive"
  GROUP BY 1
)
,r AS (
SELECT
--  jsonb_array_elements_text(jsonb_strip_nulls("atrisk_Municipalities")) AS "atrisk_Municipalities"
  jsonb_array_elements_text(jsonb_strip_nulls("atrisk_OBJECTID")) AS "atrisk_OBJECTID"
--  ,"count_atrisk_Municipalities"
--  ,"count_atrisk_OBJECTID"
FROM 
  p,q
WHERE 
--  "atrisk_Municipalities" IS NOT NULL 
--  AND
  "atrisk_OBJECTID" IS NOT NULL
)
SELECT
  *
FROM 
  o
