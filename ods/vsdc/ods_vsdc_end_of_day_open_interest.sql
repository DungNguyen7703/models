/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_end_of_day_open_interest
* Program name: ODS VSDC.END_OF_DAY_OPEN_INTEREST
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* 2026-10-19		tuan.nguyenvanb		[LLD atomic lld_VSDC_END_OF_DAY_OPEN_INTEREST.yaml] Them cot report_date (giua open_interest_volume va
*									ds_snpst_dt) de atomic bo sung rpt_dt. Can ALTER ODS ADD COLUMN report_date date AFTER open_interest_volume
*									(model append - insert theo vi tri).
*/

SELECT
    CAST(contract_code AS string)          AS contract_code
    , CAST(open_interest_volume AS bigint) AS open_interest_volume
    , CAST(report_date AS date)            AS report_date
    , CAST(ds_snpst_dt AS date)            AS ds_snpst_dt
FROM {{ source('source_vsdc', 'raw_end_of_day_open_interest') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
