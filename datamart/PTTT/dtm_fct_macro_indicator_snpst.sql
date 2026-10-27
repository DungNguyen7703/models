/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_macro_indicator_snpst
* Program name: Fact Macro Indicator Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Da Glob xac nhan TON TAI ca 2 nguon atomic can dung:
*   atm_cl_risk_indicator (models/atomic/common) va
*   atm_cl_risk_indicator_value (models/atomic/common) -> KHONG cot nao
*   PENDING trong model nay.
* - Grain: 1 dong / chi tieu vi mo (cl_risk_ind_code) / ky bao cao
*   (period_dt). Loc dung 1 ky = etl_date o buoc cuoi (theo dung uu tien
*   trong yeu cau), nhung CTE trung gian ri_val_hist doc lich su
*   period_dt <= etl_date de co du du lieu tinh LAG/AVG (prev_period_val,
*   pct_change, yoy_pct_change, ma_n_val 30 ky) -- giong ky thuat da
*   dung o dtm_fct_futures_intraday_snpst.sql (2 CTE se_tr_snpst_hist /
*   tr_hist doc <= etl_date, chi loc dung ngay o buoc cuoi).
* - prev_period_val / pct_change: LAG(val) OVER (PARTITION BY
*   cl_risk_ind_code ORDER BY period_dt) - ky lien truoc THEO THU TU
*   period_dt (khong phai theo period_val/period_year), dung dung cong
*   thuc LLD.
* - yoy_pct_change: LLD viet PARTITION BY cl_risk_ind_code, period_val
*   ORDER BY period_year - tuc la so sanh CUNG period_val (vd cung
*   thang 3, cung quy 1...) giua cac nam, LAG 1 buoc = nam lien truoc
*   cung ky. Copy dung cong thuc LLD, KHONG doi logic.
* - ma_n_val: AVG(val) OVER (PARTITION BY cl_risk_ind_code ORDER BY
*   period_dt ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) - trung binh
*   truot 30 ky gan nhat theo period_dt.
* - src_stm_code hardcode 'MRMS' theo dung LLD (khac voi src_stm_code
*   that cua atm_cl_risk_indicator_value la 'MRMS_RISK_INDICATOR_VALUE'
*   - day la lua chon co chu dich cua LLD cho tang datamart, khong phai
*   loi, nen GIU NGUYEN 'MRMS' nhu yeu cau).
* - snpst_dt_dim_id tinh truc tiep bang date_format(period_dt,
*   'yyyyMMdd'), khong JOIN vat ly toi dtm_cdr_dt_dim, giong convention
*   chung PTTT.
*--------------------------------------------------------------------*
* 2026-10-23			tuan.nguyenvanb		[LLD CHOT CUA SO 20 PHIEN] ma_n_val: ROWS BETWEEN 29 -> 19 PRECEDING (N = 20, K_PTTT_257/258 lai suat trung binh/do lech chuan N phien).
*									Khong doi cot/kieu -> khong can ALTER. Ghi chu '30 ky' o tren la lich su.
* 2026-10-24			tuan.nguyenvanb		[FIX DUP] Bat lai 2 dieu kien loc ngay da bi comment tu ban dau: ri_val_hist WHERE period_dt <= etl_date (du lich su cho LAG/AVG) va SELECT cuoi WHERE period_dt = etl_date (moi lan chay chi ghi 1 ngay). Truoc day moi lan build ghi ca lich su vao partition ds_snpst_dt -> flat doc N ban sao/ngay. Khong doi cot/kieu. Can xoa dong thua o mart/flat (xem huong dan) roi chay lai.
*/

WITH ri_val_hist AS (

    SELECT
        cl_risk_ind_code
        , period_tp_code
        , period_val
        , period_year
        , period_dt
        , period_label
        , val
    FROM {{ ref('atm_cl_risk_indicator_value') }}
    WHERE period_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

ri_ind AS (

    SELECT
        cl_risk_ind_code
        , ind_nm
    FROM {{ ref('atm_cl_risk_indicator') }}

),

windowed AS (

    SELECT
        ri_val_hist.*
        , LAG(ri_val_hist.val) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code
            ORDER BY ri_val_hist.period_dt
        ) AS prev_period_val
        , LAG(ri_val_hist.val, 1) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code, ri_val_hist.period_val
            ORDER BY ri_val_hist.period_year
        ) AS prev_year_val
        , AVG(ri_val_hist.val) OVER (
            PARTITION BY ri_val_hist.cl_risk_ind_code
            ORDER BY ri_val_hist.period_dt
            ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
        ) AS ma_n_val
    FROM ri_val_hist

)

SELECT
    CAST(date_format(windowed.period_dt, 'yyyyMMdd') AS string)      AS snpst_dt_dim_id,
    CAST(windowed.cl_risk_ind_code AS string)                        AS macro_indicator_code,
    CAST(ri_ind.ind_nm AS string)                                    AS macro_indicator_name,
    CAST(windowed.period_tp_code AS string)                         AS period_tp_code,
    CAST(windowed.period_label AS string)                            AS period_label,
    CAST(windowed.val AS decimal(23,4))                              AS indicator_val,
    CAST(windowed.prev_period_val AS decimal(23,4))                  AS prev_period_val,
    CAST(
        ROUND(
            (windowed.val - windowed.prev_period_val) / NULLIF(windowed.prev_period_val, 0) * 100
        , 2)
    AS decimal(5,2))                                                  AS pct_change,
    CAST(
        ROUND(
            (windowed.val - windowed.prev_year_val) / NULLIF(windowed.prev_year_val, 0) * 100
        , 2)
    AS decimal(5,2))                                                  AS yoy_pct_change,
    CAST(windowed.ma_n_val AS decimal(23,4))                          AS ma_n_val,
    CAST('MRMS' AS string)                                            AS src_stm_code
FROM windowed
LEFT JOIN ri_ind
    ON ri_ind.cl_risk_ind_code = windowed.cl_risk_ind_code
WHERE windowed.period_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
