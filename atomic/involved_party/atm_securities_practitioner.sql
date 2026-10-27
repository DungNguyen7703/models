/*
*--------------------------------------------------------------------*
* Program code: atm_securities_practitioner
* Program name: Atomic Securities Practitioner
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pro AS (
    SELECT
        id
        , full_name
        , first_name
        , birth_date
        , birth_year
        , gender
        , education_level_id
        , registration_type
        , status_work
        , status_account
        , organization_id
        , nationality_id
        , workplace
        , position
        , department
        , previous_identity_number
        , hometown
        , national
        , religion
        , place_of_birth
        , avatar
        , place_of_birth_country_id
        , place_of_birth_province_id
        , place_of_birth_district_id
        , sso_synced
        , sso_user_id
    FROM {{ ref('ods_nhnck_professionals') }}
),

coun AS (
    SELECT
        id
        , country_code
    FROM {{ ref('ods_nhnck_countries') }}
),

prov AS (
    SELECT
        id
        , province_code
    FROM {{ ref('ods_nhnck_provinces') }}
),

dist AS (
    SELECT
        id
        , district_code
    FROM {{ ref('ods_nhnck_districts') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "pro.id") }}                AS sp_id
    , CAST(pro.id AS string)                                                            AS sp_code
    , CAST('NHNCK_PROFESSIONALS' AS string)                                             AS src_stm_code
    , CAST(pro.full_name AS string)                                                     AS full_nm
    , CAST(pro.first_name AS string)                                                    AS given_nm
    , CAST(pro.birth_date AS date)                                                      AS birth_dt
    , CAST(pro.birth_year AS string)                                                    AS birth_year
    , CAST(pro.gender AS string)                                                        AS gender_code
    , CAST(pro.education_level_id AS string)                                            AS education_level_code
    , CAST(pro.registration_type AS string)                                             AS practitioner_registration_tp_code
    , CAST(pro.status_work AS string)                                                   AS practice_status_code
    , CAST(pro.status_account AS string)                                                AS account_status_code
    , {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATIONS', "pro.organization_id") }} AS securities_organization_reference_id
    , CAST(pro.organization_id AS string)                                               AS securities_organization_reference_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "coun_nat.country_code") }}      AS nationality_id
    , CAST(pro.nationality_id AS string)                                                AS nationality_code
    , CAST(pro.workplace AS string)                                                     AS workplace_nm
    , CAST(pro.position AS string)                                                      AS position_nm
    , CAST(pro.department AS string)                                                    AS department_nm
    , CAST(pro.previous_identity_number AS string)                                      AS previous_identity_nbr
    , CAST(pro.hometown AS string)                                                      AS hometown
    , CAST(pro.national AS string)                                                      AS ethnicity_nm
    , CAST(pro.religion AS string)                                                      AS religion_nm
    , CAST(pro.place_of_birth AS string)                                                AS place_of_birth_description
    , CAST(pro.avatar AS string)                                                        AS avatar_file_path
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "coun_birth.country_code") }}    AS place_of_birth_country_id
    , CAST(pro.place_of_birth_country_id AS string)                                     AS place_of_birth_country_code
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "prov.province_code") }}    AS place_of_birth_province_id
    , CAST(pro.place_of_birth_province_id AS string)                                    AS place_of_birth_province_code
    , {{ generate_surrogate_key_bigint('ECAT_DISTRICT_OLD', "dist.district_code") }}    AS place_of_birth_district_id
    , CAST(pro.place_of_birth_district_id AS string)                                    AS place_of_birth_district_code
    , CAST(pro.sso_synced AS string)                                                    AS sso_sync_status_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "pro.sso_user_id") }}               AS identity_and_access_management_user_id
    , CAST(pro.sso_user_id AS string)                                                   AS identity_and_access_management_user_code
FROM pro
    LEFT JOIN coun coun_nat   ON pro.NATIONALITY_ID = coun_nat.ID
    LEFT JOIN coun coun_birth ON pro.PLACE_OF_BIRTH_COUNTRY_ID = coun_birth.ID
    LEFT JOIN prov ON pro.PLACE_OF_BIRTH_PROVINCE_ID = prov.ID
    LEFT JOIN dist ON pro.PLACE_OF_BIRTH_DISTRICT_ID = dist.ID