/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_data_explorer
* Program name: Dtm Opr Practitioner Data Explorer
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-09		duc.luxuan			Fix fan-out ở CTE sp_or_em_re: 1 NHN có thể có nhiều report
*                                       ORGANIZATION_REPORTS cùng termination_dt IS NULL (báo cáo lại
*                                       theo kỳ khi vẫn đang công tác), khiến JOIN nhân bản dòng CCHN.
*                                       Dedupe về đúng 1 report/NHN bằng ROW_NUMBER PARTITION BY
*                                       sp_code (business key, ổn định qua các version SCD) ORDER BY
*                                       data_dt DESC (CREATED_AT, luôn có giá trị, tăng đơn điệu).
*                                       Đổi khoá JOIN ngược ra ngoài từ sp_id sang sp_code để tránh
*                                       lệch surrogate key giữa version report cũ và version NHN hiện tại.
* 2026-09-11		nam.tranhoai		Đổi nguồn sang dtm_securities_practitioner_dim để chỉ lấy
*                                       NHN đã có Certificate_Record (đã lọc sẵn trong dim). Dim không
*                                       expose sp_id (trùng giá trị securities_practitioner_dim_id) nên
*                                       các join ngược xuống atm đổi sang securities_practitioner_dim_id
* 2026-09-12		nguyet.do			Áp dụng lại CTE trung gian gán mã practice_status_code 0/1/4
*                                       khi NULL (đồng bộ logic với dtm_opr_practitioner_360_profile),
*                                       gộp chung vào sp_or_em_re thay vì tách CTE riêng: dedupe report
*                                       theo data_dt KHÔNG lọc termination_dt trước rank (khác bản đầu
*                                       tách CTE sp_hire_term_dt), để current_organization_nm và
*                                       practice_status_code luôn suy ra từ CÙNG 1 report mới nhất -
*                                       tránh mâu thuẫn kiểu vừa show "current_organization" vừa
*                                       "Dừng hoạt động" nếu 2 cột lấy từ 2 report khác nhau. Cột
*                                       securities_organization_reference_id null hoá khi report đó
*                                       đã có termination_dt (không còn là tổ chức đang công tác).
*                                       LƯU Ý: khác filter cũ 2026-09-09 ở edge case report mới nhất
*                                       là report terminate trong khi có report cũ hơn (tổ chức khác)
*                                       vẫn termination_dt IS NULL - trước đây show tổ chức cũ đó là
*                                       "current", nay show NULL (khớp status Dừng hoạt động). Cần
*                                       BA xác nhận nếu edge case này có phát sinh thực tế.
*--------------------------------------------------------------------*
*/

WITH practitioner AS (
    SELECT
        practitioner_code,
        full_nm,
        practice_status_code,
        src_stm_code,
        securities_practitioner_dim_id
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

certificate_document AS (
    SELECT
        sp_license_certificate_document_code,
        certificate_nbr,
        sp_license_certificate_tp_code,
        issue_dt,
        sp_id
    FROM {{ ref('atm_sp_license_certificate_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_CERTIFICATE_RECORDS'
),

certificate_type AS (
    SELECT
        sp_license_certificate_tp_code,
        certificate_tp_nm
    FROM {{ ref('atm_sp_license_certificate_type') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

employment_report_latest AS (
    -- Dedupe: lấy report mới nhất theo data_dt (CREATED_AT) cho mỗi NHN, KHÔNG lọc
    -- termination_dt trước khi rank - để hire_dt/termination_dt dùng derive practice_status_code
    -- và securities_organization_reference_id dùng làm "công ty hiện tại" luôn cùng xuất phát
    -- từ 1 report duy nhất (tránh mâu thuẫn giữa 2 cột nếu dedupe trên 2 tập lọc khác nhau).
    -- Null hoá securities_organization_reference_id khi report mới nhất đã terminate.
    SELECT
        sp_id,
        CASE WHEN termination_dt IS NULL THEN securities_organization_reference_id 
            END AS securities_organization_reference_id,
        hire_dt,
        termination_dt
    FROM (
        SELECT
            sp_id,
            securities_organization_reference_id,
            hire_dt,
            termination_dt,
            ROW_NUMBER() OVER (
                PARTITION BY sp_id
                ORDER BY hire_dt DESC NULLS LAST
            ) AS rn
        FROM {{ ref('atm_sp_organization_employment_report') }}
        WHERE src_stm_code = 'NHNCK_ORGANIZATION_REPORTS'
    ) t
    WHERE rn = 1
),

organization_reference AS (
    SELECT
        securities_organization_reference_nm,
        securities_organization_reference_id
    FROM {{ ref('atm_securities_organization_reference') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_ORGANIZATIONS'
),

ip_alternative_id AS (
    SELECT
        identification_tp_code,
        ip_id
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

practice_status_lookup AS (
    SELECT
        cl_nm,
        cl_code
    FROM {{ source('source_atm', 'raw_classification_value') }}
    WHERE schema_code = 'PRACTITIONER_PRACTICE_STATUS'
),

-- CTE trung gian: Xử lý gán mã 0, 1, 4 khi practice_status_code bị NULL
practitioner_enriched AS (
    SELECT
        p.*,
        CASE
            -- 1. Nếu đã có sẵn mã trạng thái thì giữ nguyên
            WHEN p.practice_status_code IS NOT NULL THEN p.practice_status_code

            -- 2. Khi NULL: Sàng lọc theo ngày vào làm / ngày nghỉ việc so với etl_date
            WHEN p.practice_status_code IS NULL THEN
                CASE
                    -- Mã '1': Đang hoạt động (Đã vào làm và chưa nghỉ việc hoặc ngày nghỉ sau ngày ETL)
                    WHEN r.hire_dt IS NOT NULL
                        AND r.hire_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                        AND (r.termination_dt IS NULL OR r.termination_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
                    THEN '1'

                    -- Mã '4': Dừng hoạt động (Ngày nghỉ việc đã diễn ra)
                    WHEN r.termination_dt IS NOT NULL
                        AND r.termination_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                    THEN '4'

                    -- Mã '0': Chưa hành nghề (Đã có thông tin hợp đồng nhưng ngày vào làm ở tương lai)
                    WHEN r.hire_dt IS NOT NULL
                        AND r.hire_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                    THEN '0'

                    -- Không rơi vào các trường hợp trên (hoặc không có bản ghi công tác) -> Trả về NULL
                    ELSE NULL
                END
        END AS derived_practice_status_code
    FROM practitioner p
    LEFT JOIN employment_report_latest r
        ON r.sp_id = p.securities_practitioner_dim_id
)

SELECT
    CAST(practitioner.practitioner_code AS string)                              AS practitioner_code,
    CAST(certificate_document.sp_license_certificate_document_code AS string)   AS license_certificate_document_code,
    CAST(practitioner.full_nm AS string)                                        AS full_nm,
    CAST(certificate_document.certificate_nbr AS string)                        AS certificate_nbr,
    CAST(certificate_document.sp_license_certificate_tp_code AS string)         AS certificate_tp_code,
    CAST(certificate_type.certificate_tp_nm AS string)                          AS certificate_tp_nm,
    CAST(practitioner.derived_practice_status_code AS string)                   AS practice_status_code,
    CAST(practice_status_lookup.cl_nm AS string)                                AS practice_status_nm,
    CAST(certificate_document.issue_dt AS date)                                 AS issue_dt,
    CAST(organization_reference.securities_organization_reference_nm AS string) AS current_organization_nm,
    CAST(ip_alternative_id.identification_tp_code AS string)                    AS identification_tp_code,
    CAST(practitioner.src_stm_code AS string)                                   AS src_stm_code
FROM practitioner_enriched practitioner
LEFT JOIN certificate_document
    ON certificate_document.sp_id = practitioner.securities_practitioner_dim_id
LEFT JOIN practice_status_lookup
    ON practice_status_lookup.cl_code = practitioner.derived_practice_status_code
LEFT JOIN certificate_type
    ON certificate_type.sp_license_certificate_tp_code = certificate_document.sp_license_certificate_tp_code
LEFT JOIN employment_report_latest
    ON employment_report_latest.sp_id = practitioner.securities_practitioner_dim_id
LEFT JOIN organization_reference
    ON organization_reference.securities_organization_reference_id = employment_report_latest.securities_organization_reference_id
LEFT JOIN ip_alternative_id
    ON ip_alternative_id.ip_id = practitioner.securities_practitioner_dim_id
