create
or replace PROCEDURE SP_REPORT_MHI_DSRENEWALLIST AS BEGIN
/******************************************************************************

NAME:       SP_REPORT_MHI_DSRENEWALLIST
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/30/2025              Francis          1. Create SP_REPORT_MHI_DSRENEWALLIST
1.1        06/23/2025              Francis          1. modify to upper all charac


NOTES:

 ******************************************************************************/
-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_RENEWAL_LIST', 'SP_REPORT_MHI_DSRENEWALLIST', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_RENEWAL_LIST a
WHERE
    1 = 1
    AND TRUNC (a.dateencoded) >= TRUNC (sysdate);

COMMIT;

-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_RENEWAL_LIST', 'SP_REPORT_MHI_DSRENEWALLIST', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
    adw_prod_tgt.DS_RENEWAL_LIST (
        pomno,
        memberid,
        micaremembername,
        address,
        province,
        municipality,
        barangay,
        street,
        contactno,
        birthdate,
        age,
        effectivity,
        expiry,
        provincialoffice,
        unit,
        center,
        mic,
        membercode,
        dateencoded,
        last_update_date
    )
SELECT
    UPPER(LTRIM (RTRIM (a.cardnumber))) AS pomno,
    LTRIM (RTRIM (a.memberno)) AS memberid,
    UPPER(NVL (CAST(a.membername AS VARCHAR2 (100)), '')) AS micaremembername,
    UPPER(
        LTRIM (
            RTRIM (
                NVL (
                    REPLACE (REPLACE (b.province, CHR (13), ''), CHR (10), ''),
                    ''
                )
            )
        ) || DECODE (
            LTRIM (
                RTRIM (
                    NVL (
                        REPLACE (
                            REPLACE (b.municipality, CHR (13), ''),
                            CHR (10),
                            ''
                        ),
                        ''
                    )
                )
            ),
            '',
            '',
            ', '
        ) || LTRIM (
            RTRIM (
                NVL (
                    REPLACE (
                        REPLACE (b.municipality, CHR (13), ''),
                        CHR (10),
                        ''
                    ),
                    ''
                )
            )
        ) || DECODE (
            LTRIM (
                RTRIM (
                    NVL (
                        REPLACE (REPLACE (b.barangay, CHR (13), ''), CHR (10), ''),
                        ''
                    )
                )
            ),
            '',
            '',
            ', '
        ) || LTRIM (
            RTRIM (
                NVL (
                    REPLACE (REPLACE (b.barangay, CHR (13), ''), CHR (10), ''),
                    ''
                )
            )
        ) || DECODE (
            LTRIM (
                RTRIM (
                    NVL (
                        REPLACE (REPLACE (b.street, CHR (13), ''), CHR (10), ''),
                        ''
                    )
                )
            ),
            '',
            '',
            ', '
        ) || LTRIM (
            RTRIM (
                NVL (
                    REPLACE (REPLACE (b.street, CHR (13), ''), CHR (10), ''),
                    ''
                )
            )
        )
    ) AS address,
    UPPER(
        NVL (
            REPLACE (
                REPLACE (LTRIM (RTRIM (b.province)), CHR (13), ''),
                CHR (10),
                ''
            ),
            ''
        )
    ) AS province,
    UPPER(NVL (LTRIM (RTRIM (b.municipality)), '')) AS municipality,
    UPPER(NVL (LTRIM (RTRIM (b.barangay)), '')) AS barangay,
    UPPER(NVL (LTRIM (RTRIM (b.street)), '')) AS street,
    NVL (CAST(b.mobile AS VARCHAR2 (100)), '') AS contactno,
    TRUNC (a.birthdate) AS birthdate,
    FLOOR(MONTHS_BETWEEN (SYSDATE, a.birthdate) / 12) AS age,
    TRUNC (a.effectivity) AS effectivity,
    TRUNC (a.expiry) AS expiry,
    UPPER(NVL (LTRIM (RTRIM (d.locationname)), '')) AS provincialoffice,
    UPPER(NVL (LTRIM (RTRIM (e.locationname)), '')) AS unit,
    UPPER(NVL (LTRIM (RTRIM (b.center)), '')) AS center,
    UPPER(NVL (LTRIM (RTRIM (c.agentname)), '')) AS mic,
    a.membercode as membercode,
    a.dateencoded as dateencoded,
    a.last_update_date as last_update_date
FROM
    tblmembers a
    LEFT OUTER JOIN tblmemberdetails b ON a.membercode = b.membercode
    LEFT OUTER JOIN tblagents c ON a.agentno = c.agentno
    LEFT OUTER JOIN tbllocations d ON c.branchno = d.locationcode
    LEFT OUTER JOIN tbllocations e ON c.subbranchno = e.locationcode
WHERE
    a.membercode <> 0
    AND (
        (
            TRUNC (a.dateencoded) = TRUNC (sysdate - 1)
            OR TRUNC (a.last_update_date) = TRUNC (sysdate - 1)
        )
    ) -- incremental loading
ORDER BY
    a.memberno;

COMMIT;

-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_RENEWAL_LIST', 'SP_REPORT_MHI_DSRENEWALLIST', SYSDATE, SYSDATE, 'UPDATE');
--ADDED by francis 05282025 
--transfer old data to history 
--adw_prod_tgt.sp_adw_table_logs('DS_RENEWAL_LIST_HIST', 'SP_REPORT_MHI_DSRENEWALLIST', SYSDATE, '', 'INSERT');
INSERT INTO
    adw_prod_tgt.DS_RENEWAL_LIST_HIST (
        pomno,
        memberid,
        micaremembername,
        address,
        province,
        municipality,
        barangay,
        street,
        contactno,
        birthdate,
        age,
        effectivity,
        expiry,
        provincialoffice,
        unit,
        center,
        mic,
        membercode,
        dateencoded,
        last_update_date
    )
SELECT
    pomno,
    memberid,
    micaremembername,
    address,
    province,
    municipality,
    barangay,
    street,
    contactno,
    birthdate,
    age,
    effectivity,
    expiry,
    provincialoffice,
    unit,
    center,
    mic,
    membercode,
    dateencoded,
    last_update_date
FROM
    (
        SELECT
            pomno,
            memberid,
            micaremembername,
            address,
            province,
            municipality,
            barangay,
            street,
            contactno,
            birthdate,
            age,
            effectivity,
            expiry,
            provincialoffice,
            unit,
            center,
            mic,
            membercode,
            dateencoded,
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
            adw_prod_tgt.DS_RENEWAL_LIST
        WHERE
            membercode IN (
                SELECT
                    membercode
                FROM
                    adw_prod_tgt.DS_RENEWAL_LIST
                GROUP BY
                    membercode
                HAVING
                    COUNT(*) > 1
            )
    )
WHERE
    ROW_NUM > 1;

COMMIT;

DELETE FROM adw_prod_tgt.DS_RENEWAL_LIST --added by francis 05282025
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
                    adw_prod_tgt.DS_RENEWAL_LIST
            )
        where
            row_num > 1
    );

COMMIT;

--adw_prod_tgt.sp_adw_table_logs('DS_RENEWAL_LIST_HIST', 'SP_REPORT_MHI_DSRENEWALLIST', SYSDATE, SYSDATE, 'UPDATE');
END SP_REPORT_MHI_DSRENEWALLIST;