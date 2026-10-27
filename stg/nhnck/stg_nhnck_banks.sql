/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_banks
* Program name: Staging NHNCK.BANKS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(bank_code AS string)         AS bank_code
    , CAST(bank_name AS string)         AS bank_name
    , CAST(short_name AS string)        AS short_name
    , CAST(bank_key AS string)          AS bank_key
    , CAST(english_bank_name AS string) AS english_bank_name
    , CAST(created_at AS date)          AS created_at
    , CAST(updated_at AS date)          AS updated_at
    , CAST(created_by AS int)           AS created_by
    , CAST(updated_by AS int)           AS updated_by
FROM {{ source('source_nhnck', 'raw_banks') }}