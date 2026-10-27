/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_open_investors
* Program name: ODS VSDC.OPEN_INVESTORS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-15
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-15		tuan.nguyenvanb		[MOI] Lay 1-1 bang VSDC open_investors (BM 5, thong tin va danh tinh NDT
*                                       mo tai khoan) tu source_vsdc. Phuc vu phan loai ca nhan va to chuc
*                                       trong nuoc cua GSTT (investor_type 3 hoac 5). Bang nguon co the trung
*                                       so tai khoan, ODS giu nguyen khong dedupe.
* 2026-10-16		tuan.nguyenvanb		So nhan du lieu ~1 lan/tuan, KHONG loc theo etl_date: lay cac ds_snpst_dt co o STG ma ODS
*                                       chua co + ghi de lai ngay moi nhat cua STG (idempotent, tranh rong -> macro append
*                                       xoa partition etl_date).
*--------------------------------------------------------------------*
*/

-- [2026-10-16] Ngay can nap: ngay STG co ma ODS chua co, cong ngay moi nhat cua STG (luon ghi de lai)
WITH new_dt AS (
    SELECT s.ds_snpst_dt
    FROM (
        SELECT DISTINCT CAST(ds_snpst_dt AS date) AS ds_snpst_dt
        FROM {{ source('source_vsdc', 'raw_open_investors') }}
    ) s
    LEFT ANTI JOIN (
        SELECT DISTINCT ds_snpst_dt FROM {{ this }}
    ) t ON t.ds_snpst_dt = s.ds_snpst_dt
    UNION
    SELECT MAX(CAST(ds_snpst_dt AS date)) AS ds_snpst_dt
    FROM {{ source('source_vsdc', 'raw_open_investors') }}
)

SELECT
    CAST(customer_name AS string)          AS customer_name
    , CAST(investor_type AS string)        AS investor_type
    , CAST(trading_account_no AS string)   AS trading_account_no
    , CAST(address AS string)              AS address
    , CAST(id_number AS string)            AS id_number
    , CAST(issue_date AS date)             AS issue_date
    , CAST(issue_place AS string)          AS issue_place
    , CAST(open_date AS date)              AS open_date
    , CAST(nationality AS string)          AS nationality
    , CAST(phone_number AS string)         AS phone_number
    , CAST(email AS string)                AS email
    , CAST(src.ds_snpst_dt AS date)        AS ds_snpst_dt
FROM {{ source('source_vsdc', 'raw_open_investors') }} src
INNER JOIN new_dt
    ON new_dt.ds_snpst_dt = CAST(src.ds_snpst_dt AS date)
