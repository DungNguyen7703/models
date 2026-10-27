/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.SC_FIRM_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_br AS (
    SELECT
        id
        , address
        , province_id
        , district_id
        , district_name
        , ward_id
        , ward_name
    FROM {{ ref('ods_scms_sc_firm_branch') }}
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
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_br.id") }}         AS ip_id
    , CAST(sc_fi_br.id AS string)                                                     AS ip_code
    , CAST('SCMS_SC_FIRM_BRANCH' AS string)                                           AS src_stm_code
    , CAST('BRANCH' AS string)                                                        AS adr_tp_code
    , CAST(sc_fi_br.address AS string)                                                AS adr_val
    , CAST(sc_fi_br.province_id AS string)                                            AS province_code
    , CAST(NULL AS string)                                                            AS province_nm
    , CAST(sc_fi_br.district_id AS string)                                            AS district_code
    , CAST(sc_fi_br.district_name AS string)                                          AS district_nm
    , CAST(sc_fi_br.ward_id AS string)                                                AS ward_code
    , CAST(sc_fi_br.ward_name AS string)                                              AS ward_nm
    , CAST(NULL AS string)                                                            AS country_code
    , CAST(NULL AS string)                                                            AS country_id
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "ca_pr.province_code") }} AS province_id
    , {{ generate_surrogate_key_bigint('ECAT_DISTRICT_OLD', "ca_di.district_code") }} AS district_id
    , {{ generate_surrogate_key_bigint('ECAT_WARD_NEW', "ca_wa.ward_code") }}         AS ward_id
FROM sc_fi_br
    LEFT JOIN ca_pr ON sc_fi_br.PROVINCE_ID = ca_pr.ID
    LEFT JOIN ca_di ON sc_fi_br.DISTRICT_ID = ca_di.ID
    LEFT JOIN ca_wa ON sc_fi_br.WARD_ID = ca_wa.ID