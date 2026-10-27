/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_trading_account
* Program name: Dtm Opr Individual Trading Account
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH se_co_sh AS (
    SELECT 
        sc_id,
        sc_shareholder_code, 
        sc_code, 
        trading_account, 
        shareholder_nm, 
        src_stm_code,
        src_rcrd_isrt_tms
    FROM {{ ref('atm_sc_shareholder') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
)

SELECT
    CAST(sc_shareholder_code AS string) AS sc_shareholder_code,
    CAST(sc_code AS string)             AS sc_code,
    CAST(trading_account AS string)     AS trading_account,
    CAST(shareholder_nm AS string)      AS shareholder_nm,
    CAST(src_stm_code AS string)        AS src_stm_code,
    CAST(src_rcrd_isrt_tms AS date)     AS created_dt
FROM se_co_sh
