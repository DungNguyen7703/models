/*
*--------------------------------------------------------------------*
* Program code: stg_scms_disclosure_news
* Program name: Staging SCMS.DISCLOSURE_NEWS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(newsid AS decimal(20,0))  AS newsid
    , CAST(category AS int)          AS category
    , CAST(record_type AS int)       AS record_type
    , CAST(secid AS decimal(20,0))   AS secid
    , CAST(title AS string)          AS title
    , CAST(content AS string)        AS content
    , CAST(datecreated AS date)      AS datecreated
    , CAST(errlog AS string)         AS errlog
    , CAST(description AS string)    AS description
    , CAST(publishby AS string)      AS publishby
    , CAST(publishdate AS date)      AS publishdate
    , CAST(senddate AS date)         AS senddate
    , CAST(record_status AS int)     AS record_status
    , CAST(published_date AS string) AS published_date
FROM {{ source('source_scms', 'raw_disclosure_news') }}