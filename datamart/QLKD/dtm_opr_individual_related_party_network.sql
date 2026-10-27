/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_related_party_network
* Program name: Dtm Opr Individual Related Party Network
* Created by: tuan.nguyenvanb
* Created date: 2026-10-02
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		tuan.nguyenvanb		[SUA] Bo sung self-join theo dung
*                                       LLD: r.sc_senior_personnel_id =
*                                       i.sc_senior_personnel_id AND
*                                       r.sc_insider_related_person_id !=
*                                       i.sc_insider_related_person_id, loai
*                                       tru ban ghi la chinh senior personnel.
*                                       GHI CHU/RUI RO CAN XEM XET LAI: doc
*                                       BRD nguon SCMS.SC_FIRM_INSIDER_
*                                       RELATION va atomic atm_sc_insider_
*                                       related_person, moi dong trong bang
*                                       nay von da la 1 "nguoi lien quan" gan
*                                       voi 1 SENIOR_PERSONNEL_ID rieng - chua
*                                       xac nhan duoc co dong nao tu tham
*                                       chieu (id = senior_personnel_id, tuc
*                                       la dong dai dien chinh senior
*                                       personnel) hay khong. Neu KHONG co
*                                       dong tu tham chieu, dieu kien self-
*                                       join nay se khong loai bo dong nao ca
*                                       (vo hieu luc). Can BA/nguoi viet LLD
*                                       xac nhan lai du lieu that.
*--------------------------------------------------------------------*
*/

WITH sc_in_re_pe AS (
    SELECT
        sc_insider_related_person_id,
        sc_insider_related_person_code,
        sc_senior_personnel_id,
        sc_senior_personnel_code,
        full_nm,
        rltnp,
        representative_position,
        shares_count,
        ownership_ratio,
        src_stm_code
    FROM {{ ref('atm_sc_insider_related_person') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INSIDER_RELATION'
),

ip_al_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification')}}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'NATIONAL_ID'
        AND src_stm_code = 'SCMS_SC_FIRM_INSIDER_RELATION'

)

SELECT
    CAST(r.sc_insider_related_person_code AS string) AS sc_insider_related_person_code,
    CAST(r.sc_senior_personnel_code AS string)       AS sc_senior_personnel_code,
    CAST(r.full_nm AS string)                        AS related_person_full_nm,
    CAST(r.rltnp AS string)                          AS rltnp,
    CAST(r.representative_position AS string)        AS representative_position,
    CAST(ip_al_id.identification_nbr AS string)      AS identification_nbr,
    CAST(r.shares_count AS int)                      AS shares_count,
    CAST(r.ownership_ratio AS decimal(5,2))          AS ownership_ratio,
    CAST(r.src_stm_code AS string)                   AS src_stm_code
FROM sc_in_re_pe r
JOIN sc_in_re_pe i
    ON  r.sc_senior_personnel_id = i.sc_senior_personnel_id
    AND r.sc_insider_related_person_id != i.sc_insider_related_person_id
JOIN ip_al_id
    ON r.sc_insider_related_person_id = ip_al_id.ip_id
