/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_private_corporate_bond_issuance_snpst
* Program name: Fact Private Corporate Bond Issuance Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-19		duc.luxuan		[UPD] Doi ten cot nguon Atomic theo LLD a21603a1 (posting_date->posting_dt, report_month->rpt_month, issue_date->issue_dt, maturity_date->maturity_dt, par_value->par_val)
*--------------------------------------------------------------------*
*/

WITH pr_co_bo_of_all AS (
    SELECT
        bond_code,
        issue_dt,
        maturity_dt,
        rpt_month,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY bond_code, rpt_month
            ORDER BY posting_dt DESC)
        AS rn
    FROM {{ ref('atm_private_corp_bond_offering') }} 
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_OFFERING'
        AND bond_code IS NOT NULL
),

pr_co_bo_of AS (
    SELECT
        bond_code,
        issue_dt,
        maturity_dt,
        rpt_month,
        src_stm_code
    FROM pr_co_bo_of_all
    WHERE rn = 1
),

pr_co_bo_re_all AS (
    SELECT
        bond_code,
        issue_dt,
        maturity_dt,
        rpt_month,
        issued_bond_quantity,
        par_val,
        ROW_NUMBER() OVER (
            PARTITION BY bond_code, issue_dt, maturity_dt, rpt_month
            ORDER BY ds_snpst_dt DESC)
        AS rn
    FROM {{ ref('atm_private_corp_bond_registration') }} 
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'HNX_PRIVATE_CORP_BOND_REGISTRATION'
),

pr_co_bo_re AS (
    SELECT
        bond_code,
        issue_dt,
        maturity_dt,
        rpt_month,
        issued_bond_quantity,
        par_val
    FROM pr_co_bo_re_all
    WHERE rn = 1
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
    CAST(pr_co_bo_re.issued_bond_quantity AS bigint)                            AS issued_bond_quantity,
    CAST(pr_co_bo_re.par_val AS decimal(23,2))                                AS par_value,
    CAST(CAST(pr_co_bo_re.issued_bond_quantity AS decimal(23,2)) * pr_co_bo_re.par_val AS decimal(23,2)) AS issued_bond_val_amt,
    CAST(pr_co_bo_of.src_stm_code AS string)                                    AS src_stm_code
FROM pr_co_bo_of
LEFT JOIN pr_co_bo_re
    ON pr_co_bo_re.bond_code = pr_co_bo_of.bond_code
    AND pr_co_bo_re.issue_dt = pr_co_bo_of.issue_dt
    AND pr_co_bo_re.maturity_dt = pr_co_bo_of.maturity_dt
    AND pr_co_bo_re.rpt_month = pr_co_bo_of.rpt_month
INNER JOIN private_corporate_bond_dim
    ON private_corporate_bond_dim.bond_code = pr_co_bo_of.bond_code
