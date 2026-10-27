/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_private_corporate_bond_international_offering_snpst
* Program name: Fact Private Corporate Bond International Offering Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		duc.luxuan		[UPD] Doi ten cot nguon Atomic theo LLD a21603a1 (market_type->market_tp, posting_date->posting_dt, report_month->rpt_month)
*--------------------------------------------------------------------*
*/

WITH pr_co_bo_of AS (
    SELECT
        bond_code,
        market_tp,
        rpt_month,
        currency_code,
        offering_bond_quantity,
        posting_dt,
        src_stm_code
    FROM {{ ref('atm_private_corp_bond_offering') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
),

private_corporate_bond_dim AS (
    SELECT
        private_corporate_bond_dim_id,
        bond_code
    FROM {{ ref('dtm_private_corporate_bond_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
)

SELECT
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')      AS snpst_dt_dim_id,
    CAST(private_corporate_bond_dim.private_corporate_bond_dim_id AS string)    AS private_corporate_bond_dim_id,
    CAST(pr_co_bo_of.rpt_month AS string)                                    AS rpt_month,
    CAST(pr_co_bo_of.market_tp AS string)                                     AS market_tp,
    CAST(pr_co_bo_of.currency_code AS string)                                   AS currency_code,
    CAST(pr_co_bo_of.offering_bond_quantity AS bigint)                          AS offering_bond_quantity,
    CAST(pr_co_bo_of.posting_dt AS date)                                      AS posting_dt,
    CAST(pr_co_bo_of.src_stm_code AS string)                                    AS src_stm_code
FROM pr_co_bo_of
INNER JOIN private_corporate_bond_dim
    ON private_corporate_bond_dim.bond_code = pr_co_bo_of.bond_code
