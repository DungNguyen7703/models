/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_sc_firm_foreign_branch_service
* Program name: Staging SCMS.LNK_SC_FIRM_FOREIGN_BRANCH_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                          AS id
    , CAST(sc_firm_foreign_branch_id AS int) AS sc_firm_foreign_branch_id
    , CAST(service_id AS int)                AS service_id
    , CAST(created_at AS timestamp)          AS created_at
FROM {{ source('source_scms', 'raw_lnk_sc_firm_foreign_branch_service') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1