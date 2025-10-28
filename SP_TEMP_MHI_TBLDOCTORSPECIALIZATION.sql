create
or replace PROCEDURE SP_TEMP_MHI_TBLDOCTORSPECIALIZATION AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLDOCTORSPECIALIZATION
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLDOCTORSPECIALIZATION
1.1        06/10/2025       Francis          1. change doctorcode to detno

NOTES:

 ******************************************************************************/

--adw_prod_tgt.sp_adw_table_logs('TBLDOCTORSPECIALIZATION', 'SP_TEMP_MHI_TBLDOCTORSPECIALIZATION', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLDOCTORSPECIALIZATION
WHERE
    1 = 1
    AND TRUNC (last_update_date) >= TRUNC (SYSDATE);

COMMIT;

--adw_prod_tgt.sp_adw_table_logs('TBLDOCTORSPECIALIZATION', 'SP_TEMP_MHI_TBLDOCTORSPECIALIZATION', SYSDATE, '', 'INSERT');
INSERT INTO
    adw_prod_tgt.TBLDOCTORSPECIALIZATION (
        detno,
        doctorcode,
        specialization,
        superspecs,
        shortspecs,
        shortsuperspecs,
        society,
        importedcode,
        last_update_date
    )
SELECT
        detno,
        doctorcode,
        specialization,
        superspecs,
        shortspecs,
        shortsuperspecs,
        society,
        importedcode,
        last_update_date
FROM
    adw_prod_tgt.TEMP_TBLDOCTORSPECIALIZATION
WHERE
    1 = 1;

COMMIT;

EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLDOCTORSPECIALIZATION';

--adw_prod_tgt.sp_adw_table_logs('TBLDOCTORSPECIALIZATION', 'SP_TEMP_MHI_TBLDOCTORSPECIALIZATION', SYSDATE, SYSDATE, 'UPDATE');  


--transfer history 
--adw_prod_tgt.sp_adw_table_logs('TBLDOCTORSPECIALIZATION_HIST', 'SP_TEMP_MHI_TBLDOCTORSPECIALIZATION', SYSDATE, '', 'INSERT');
INSERT INTO --added by francis 05282025
    adw_prod_tgt.TBLDOCTORSPECIALIZATION_HIST (
        detno,
        doctorcode,
        specialization,
        superspecs,
        shortspecs,
        shortsuperspecs,
        society,
        importedcode,
        last_update_date

    )
SELECT
        detno,
        doctorcode,
        specialization,
        superspecs,
        shortspecs,
        shortsuperspecs,
        society,
        importedcode,
        last_update_date
FROM
    (
        SELECT
        detno,
        doctorcode,
        specialization,
        superspecs,
        shortspecs,
        shortsuperspecs,
        society,
        importedcode,
        last_update_date,
            ROW_NUMBER() OVER (
                PARTITION BY
                    detno --change doctorcode to detno, theres a duplicate doctorcode in the table 
                ORDER BY
                    CASE
                        WHEN last_update_date IS NULL THEN 1
                        ELSE 0
                    END,
                    last_update_date desc
            ) AS Row_Num
        FROM
            adw_prod_tgt.TBLDOCTORSPECIALIZATION
        WHERE
            detno IN (
                SELECT
                    detno
                FROM
                    adw_prod_tgt.TBLDOCTORSPECIALIZATION
                GROUP BY
                    detno
                HAVING
                    COUNT(*) > 1
            )
    )
WHERE
    Row_Num > 1;

COMMIT;

DELETE FROM adw_prod_tgt.TBLDOCTORSPECIALIZATION --added by francis 05282025
WHERE
    ROWID IN (
        SELECT
            ROWID
        FROM
            (
                SELECT
                    ROWID,
                    ROW_NUMBER() OVER (
                        PARTITION BY
                            detno
                        ORDER BY
                            CASE
                                WHEN last_update_date IS NULL THEN 1
                                ELSE 0
                            END,
                            last_update_date DESC
                    ) AS Row_Num
                FROM
                    adw_prod_tgt.TBLDOCTORSPECIALIZATION
            )
        WHERE
            Row_Num > 1
    );

COMMIT;

-- --adw_prod_tgt.sp_adw_table_logs('TBLDOCTORSPECIALIZATIONS_HIST', 'SP_TEMP_MHI_TBLDOCTORSPECIALIZATION', SYSDATE, SYSDATE, 'UPDATE');

 END SP_TEMP_MHI_TBLDOCTORSPECIALIZATION;
 