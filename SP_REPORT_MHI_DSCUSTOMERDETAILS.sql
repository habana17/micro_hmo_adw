create
or replace PROCEDURE SP_REPORT_MHI_DSCUSTOMERDETAILS AS BEGIN
/******************************************************************************

NAME:       SP_REPORT_MHI_DSCUSTOMERDETAILS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_DSCUSTOMERDETAILS


NOTES:

 ******************************************************************************/
-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_CUSTOMER_DETAILS', 'SP_REPORT_MHI_DSCUSTOMERDETAILS', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_CUSTOMER_DETAILS
WHERE
    1 = 1
    AND trunc (last_update_date) >= trunc (sysdate);

COMMIT;

-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_CUSTOMER_DETAILS', 'SP_REPORT_MHI_DSCUSTOMERDETAILS', SYSDATE, '', 'INSERT');
INSERT INTO
    adw_prod_tgt.DS_CUSTOMER_DETAILS (
        first_name,
        middle_name,
        last_name,
        general_name,
        birthplace,
        birthday,
        gender,
        civil_status,
        citizenship,
        contact_number,
        address,
        application_date,
        email_address,
        membercode,
        last_update_date
    )
SELECT
    LTRIM (RTRIM (UPPER(a.firstname))) AS firstname,
    LTRIM (RTRIM (UPPER(a.miname))) AS miname,
    LTRIM (RTRIM (UPPER(a.lastname))) AS lastname,
    LTRIM (RTRIM (UPPER(a.suffix))) AS generalname,
    LTRIM (RTRIM (UPPER(NVL (b.birthplace, '')))) AS birthplace,
    TRUNC (a.birthdate) AS birthday,
    LTRIM (
        RTRIM (
            CASE
                WHEN a.gender = 'M' THEN 'MALE'
                WHEN a.gender = 'F' THEN 'FEMALE'
                ELSE ''
            END
        )
    ) AS gender,
    LTRIM (RTRIM (NVL (c.description, ''))) AS civilstatus,
    LTRIM (RTRIM (UPPER(b.nationality))) AS citizenship,
    LTRIM (RTRIM (b.mobile)) AS contactno,
    UPPER(
        LTRIM (RTRIM (NVL (b.province, ''))) || DECODE (
            LTRIM (RTRIM (NVL (b.municipality, ''))),
            '',
            '',
            ', '
        ) || LTRIM (RTRIM (NVL (b.municipality, ''))) || DECODE (
            LTRIM (RTRIM (NVL (b.barangay, ''))),
            '',
            '',
            ', '
        ) || LTRIM (RTRIM (NVL (b.barangay, ''))) || DECODE (LTRIM (RTRIM (NVL (b.street, ''))), '', '', ', ') || LTRIM (RTRIM (NVL (b.street, '')))
    ) AS address,
    TRUNC (a.origeffectivity) AS applicationdate,
    LTRIM (RTRIM (b.emailaddress)) AS emailaddress,
    a.membercode,
    a.last_update_date
FROM
    tblmembers a
    LEFT JOIN tblmemberdetails b ON a.membercode = b.membercode
    LEFT JOIN tblgentables c ON a.civilstatus = c.recordno
    AND c.tablename = 'CIVILSTATUS'
WHERE
    1 = 1
    AND a.classorder = 0
    AND TRUNC (a.last_update_date) = TRUNC (sysdate - 1) --incremental
order by
    firstname;

COMMIT;

--Logging the UPDATE operation (uncomment if needed)
--adw_prod_tgt.sp_adw_table_logs('DS_CUSTOMER_DETAILS', 'SP_REPORT_MHI_DSCUSTOMERDETAILS', SYSDATE, SYSDATE, 'UPDATE');





--transfer old data to history 
--adw_prod_tgt.sp_adw_table_logs('DS_CUSTOMER_DETAILS', 'SP_REPORT_MHI_DSCUSTOMERDETAILS', SYSDATE, '', 'INSERT');
INSERT INTO
    adw_prod_tgt.DS_CUSTOMER_DETAILS_HIST (
        first_name,
        middle_name,
        last_name,
        general_name,
        birthplace,
        birthday,
        gender,
        civil_status,
        citizenship,
        contact_number,
        address,
        application_date,
        email_address,
        membercode,
        last_update_date
    )
SELECT
    first_name,
    middle_name,
    last_name,
    general_name,
    birthplace,
    birthday,
    gender,
    civil_status,
    citizenship,
    contact_number,
    address,
    application_date,
    email_address,
    membercode,
    last_update_date
FROM
    (
        SELECT
            first_name,
            middle_name,
            last_name,
            general_name,
            birthplace,
            birthday,
            gender,
            civil_status,
            citizenship,
            contact_number,
            address,
            application_date,
            email_address,
            membercode,
            last_update_date,
            ROW_NUMBER() OVER (
                PARTITION BY
                    membercode
                ORDER BY
                    CASE
                        WHEN last_update_date IS NULL THEN 1
                        ELSE 0
                    END,
                    last_update_date DESC
            ) AS ROW_NUM
        FROM
            adw_prod_tgt.DS_CUSTOMER_DETAILS
        WHERE
            membercode IN (
                SELECT
                    membercode
                FROM
                    adw_prod_tgt.DS_CUSTOMER_DETAILS
                GROUP BY
                    membercode
                HAVING
                    COUNT(*) > 1
            )
    )
WHERE
    ROW_NUM > 1;

COMMIT;

DELETE FROM adw_prod_tgt.DS_CUSTOMER_DETAILS
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
                            membercode
                        ORDER BY
                            CASE
                                WHEN last_update_date IS NULL THEN 1
                                ELSE 0
                            END,
                            last_update_date desc
                    ) AS row_num
                from
                    adw_prod_tgt.DS_CUSTOMER_DETAILS
            )
        where
            row_num > 1
    );

COMMIT;

--adw_prod_tgt.sp_adw_table_logs('DS_CUSTOMER_DETAILS', 'SP_REPORT_MHI_DSCUSTOMERDETAILS', SYSDATE, SYSDATE, 'UPDATE');
END SP_REPORT_MHI_DSCUSTOMERDETAILS;