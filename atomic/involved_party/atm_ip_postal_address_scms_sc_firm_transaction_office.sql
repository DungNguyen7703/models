/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.SC_FIRM_TRANSACTION_OFFICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_tr_of AS (
    SELECT
        id
        , address
        , province_id
        , district_id
        , ward_id
    FROM {{ ref('ods_scms_sc_firm_transaction_office') }}
),

ca_pr AS (
    SELECT
        id
        , province_code
    FROM {{ ref('ods_scms_cat_province') }}
    WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
),

ca_di AS (
    SELECT
        id
        , district_code
    FROM {{ ref('ods_scms_cat_district') }}
    WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
),

ca_wa AS (
    SELECT
        id
        , ward_code
    FROM {{ ref('ods_scms_cat_ward') }}
    WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_TRANSACTION_OFFICE', "sc_fi_tr_of.id") }} AS ip_id
    , CAST(sc_fi_tr_of.id AS string)                                                         AS ip_code
    , CAST('SCMS_SC_FIRM_TRANSACTION_OFFICE' AS string)                                      AS src_stm_code
    , CAST('TRANSACTION_OFFICE' AS string)                                                   AS adr_tp_code
    , CAST(sc_fi_tr_of.address AS string)                                                    AS adr_val
    , CAST(sc_fi_tr_of.province_id AS string)                                                AS province_code
    , CAST(NULL AS string)                                                                   AS province_nm
    , CAST(sc_fi_tr_of.district_id AS string)                                                AS district_code
    , CAST(NULL AS string)                                                                   AS district_nm
    , CAST(sc_fi_tr_of.ward_id AS string)                                                    AS ward_code
    , CAST(NULL AS string)                                                                   AS ward_nm
    , CAST(NULL AS string)                                                                   AS country_code
    , CAST(NULL AS string)                                                                   AS country_id
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "ca_pr.province_code") }}        AS province_id
    , {{ generate_surrogate_key_bigint('ECAT_DISTRICT_OLD', "ca_di.district_code") }}        AS district_id
    , {{ generate_surrogate_key_bigint('ECAT_WARD_NEW', "ca_wa.ward_code") }}                AS ward_id
FROM sc_fi_tr_of
    LEFT JOIN ca_pr ON sc_fi_tr_of.PROVINCE_ID = ca_pr.ID
    LEFT JOIN ca_di ON sc_fi_tr_of.DISTRICT_ID = ca_di.ID
    LEFT JOIN ca_wa ON sc_fi_tr_of.WARD_ID = ca_wa.ID