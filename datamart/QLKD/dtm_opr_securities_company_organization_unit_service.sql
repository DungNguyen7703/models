/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_organization_unit_service
* Program name: Dtm Opr Securities Company Organization Unit Service
* Created by: tuan.nguyenvanb
* Created date: 2026-10-02
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		tuan.nguyenvanb		[MOI] Sinh moi theo LLD QLKD -
*                                       Operational Securities Company
*                                       Organization Unit Service, gop 2
*                                       nguon: SCMS_LNK_TRANSACTION_OFFICE_
*                                       SERVICE (qua atm_sc_ou_x_cl_sc_firm_
*                                       service_relationship) va
*                                       SCMS_SC_FIRM_BRANCH (LATERAL VIEW
*                                       EXPLODE business_lines).
*--------------------------------------------------------------------*
*/

WITH ou_x_cl_sc_fi_se AS (
    SELECT
        sc_ou_code,
        cl_sc_firm_service_id,
        cl_sc_firm_service_code,
        src_stm_code
    FROM {{ ref('atm_sc_ou_x_cl_sc_firm_service_relationship') }}
    WHERE src_stm_code = 'SCMS_LNK_TRANSACTION_OFFICE_SERVICE'
),

sc_or_un_tr_of AS (
    SELECT
        sc_ou_code,
        sc_code,
        ou_tp_code,
        decision_dt,
        src_stm_code
    FROM {{ ref('atm_sc_organization_unit') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_TRANSACTION_OFFICE'
        AND record_status_code = '1'
),

sc_or_un_br AS (
    SELECT
        sc_ou_code,
        sc_code,
        ou_tp_code,
        decision_dt,
        business_lines,
        src_stm_code
    FROM {{ ref('atm_sc_organization_unit') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_BRANCH'
        AND record_status_code = '1'
        AND business_lines IS NOT NULL
),

cl_sc_fi_se AS (
    SELECT
        cl_sc_firm_service_id,
        cl_sc_firm_service_code,
        catalog_code,
        src_stm_code
    FROM {{ ref('atm_cl_securities_company_firm_service') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_CAT_SERVICE_LEGAL_CAPITAL'
),

-- Tách business_lines thành từng mã dịch vụ của BRANCH
branch_service_lines AS (
    SELECT
        sc_or_un_br.sc_ou_code,
        sc_or_un_br.sc_code,
        sc_or_un_br.ou_tp_code,
        sc_or_un_br.decision_dt,
        sc_or_un_br.src_stm_code,
        TRIM(bl.service_id_txt) AS service_id_txt
    FROM sc_or_un_br
    LATERAL VIEW EXPLODE(
        SPLIT(sc_or_un_br.business_lines, ',')
    ) bl AS service_id_txt
)

-- Nguồn 1: TRANSACTION_OFFICE
SELECT
    CAST(
        {{ generate_surrogate_key_bigint(
            'SCMS_LNK_TRANSACTION_OFFICE_SERVICE',
            "CONCAT(ou_x_cl_sc_fi_se.sc_ou_code, '|', sc_or_un_tr_of.ou_tp_code, '|', ou_x_cl_sc_fi_se.cl_sc_firm_service_code)"
        ) }}
        AS string
    ) AS organization_unit_service_id,
    CAST(ou_x_cl_sc_fi_se.sc_ou_code AS string)
        AS sc_ou_code,
    CAST(ou_x_cl_sc_fi_se.cl_sc_firm_service_code AS string)
        AS cl_sc_firm_service_code,
    CAST(sc_or_un_tr_of.sc_code AS string)
        AS sc_code,
    CAST(sc_or_un_tr_of.ou_tp_code AS string)
        AS ou_tp_code,
    CAST(cl_sc_fi_se.catalog_code AS string)
        AS catalog_code,
    CAST(sc_or_un_tr_of.decision_dt AS date)
        AS decision_dt,
    CAST(ou_x_cl_sc_fi_se.src_stm_code AS string)
        AS src_stm_code
FROM ou_x_cl_sc_fi_se
JOIN sc_or_un_tr_of
    ON sc_or_un_tr_of.sc_ou_code =
       ou_x_cl_sc_fi_se.sc_ou_code
LEFT JOIN cl_sc_fi_se
    ON cl_sc_fi_se.cl_sc_firm_service_id =
       ou_x_cl_sc_fi_se.cl_sc_firm_service_id

UNION ALL

-- Nguồn 2: BRANCH
SELECT
    CAST(
        {{ generate_surrogate_key_bigint(
            'SCMS_SC_FIRM_BRANCH',
            "CONCAT(branch_service_lines.sc_ou_code, '|', branch_service_lines.ou_tp_code, '|', branch_service_lines.service_id_txt)"
        ) }}
        AS string
    ) AS organization_unit_service_id,
    CAST(branch_service_lines.sc_ou_code AS string)
        AS sc_ou_code,
    CAST(branch_service_lines.service_id_txt AS string)
        AS cl_sc_firm_service_code,
    CAST(branch_service_lines.sc_code AS string)
        AS sc_code,
    CAST(branch_service_lines.ou_tp_code AS string)
        AS ou_tp_code,
    CAST(cl_sc_fi_se.catalog_code AS string)
        AS catalog_code,
    CAST(branch_service_lines.decision_dt AS date)
        AS decision_dt,
    CAST(branch_service_lines.src_stm_code AS string)
        AS src_stm_code
FROM branch_service_lines
LEFT JOIN cl_sc_fi_se
    ON cl_sc_fi_se.cl_sc_firm_service_code =
       branch_service_lines.service_id_txt