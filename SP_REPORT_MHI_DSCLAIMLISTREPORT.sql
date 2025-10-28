create
or replace PROCEDURE SP_REPORT_MHI_DSCLAIMLISTREPORT AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_DSCLAIMLISTREPORT
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_DSCLAIMLISTREPORT


NOTES:

 ******************************************************************************/

-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_CLAIM_LIST_REPORT', 'SP_REPORT_MHI_DSCLAIMLISTREPORT', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_CLAIM_LIST_REPORT
WHERE
    1 = 1
    AND TRUNC (hospdatefrom) >= TRUNC (SYSDATE);
--update by francis 05202025
COMMIT;
-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_CLAIM_LIST_REPORT', 'SP_REPORT_MHI_DSCLAIMLISTREPORT', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
    adw_prod_tgt.DS_CLAIM_LIST_REPORT (
        partner,
        segment, -- Segment (empty for now)
        subseg, -- Line of business
        batchno, -- Bill number
        claimrefno, -- Case number
        datecreated, -- Date encoded (cast to DATE)
        membername, -- Decrypted member name
        rfp, -- Date completed
        lastn, -- Decrypted last name
        firstn, -- Decrypted first name
        midi, -- Decrypted middle initial
        gname, -- Suffix
        age, -- Calculated age
        clienttype, -- Client type (based on CASE logic)
        pomno, -- Card number
        uccno, -- Member number
        product, -- Plan name
        effdate, -- Effectivity date
        expdate, -- Expiry date
        bday, -- Birth date
        sex, -- Gender --updated by francis 5/16/2025
        addr, -- Address (concatenation)
        status, -- Member status --updated by francis 5/16/2025
        loa, -- Always ''YES''
        loano, -- LOA number
        dateutil, -- Date availed
        coveragetype, -- Coverage type description
        causeofavailment, -- Cause of availment
        provider, -- Provider type --updated by francis 05162025
        providername, -- Provider name
        hospdatefrom, -- Date availed (hospitalization start)
        hospdateto, -- Date discharged (hospitalization end) --updated by francis 5/16/2025
        availmentamount, -- LOA amount
        claimstatus, -- Claim status
        denialreason, -- Denial reason (empty for now)
        staff, -- Encoded by username
        branch_prov_office, -- Branch location name --updated by francis 05162025
        date_of_notice_to_partner,
        date_of_notice_to_pioneer,
        datecompletion, -- Date availed (completion)
        dateapproval, -- Date approved
        approveddate, -- Approved date
        authorizedperson, -- Beneficiary
        contact_number,
        payoutamt, -- Check amount
        remarks, -- Remarks
        dateposted
    )
SELECT
    a.companyname AS partner,
    '' AS segment,
    NVL (b.lineofbusiness, '') AS subseg,
    a.billno AS batchno,
    a.caseno AS claimrefno,
    TRUNC (a.dateencoded) AS datecreated,
    a.membername AS membername,
    -- NVL (
    --     TRUNC (c.datecompleted),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS rfp,
    TRUNC (c.datecompleted) AS rfp,
    NVL (d.lastname, '') AS lastn,
    NVL (d.firstname, '') AS firstn,
    NVL (d.miname, '') AS midi,
    NVL (d.suffix, '') AS gname,
    TRUNC ((a.dateencoded - a.birthdate) / 365.26) AS age,
    CASE NVL (e.clienttype, 0)
        WHEN 1 THEN 'CARD PRINCIPAL'
        WHEN 2 THEN 'NON-CARD PRINCIPAL'
        WHEN 3 THEN 'NON-CARD SPOUSE'
        WHEN 4 THEN 'NON-CARD CHILD'
        ELSE ''
    END AS clienttype,
    NVL (d.cardnumber, '') AS pomno,
    a.memberno AS uccno,
    NVL (
        (
            SELECT
                LISTAGG (planname, ', ') WITHIN GROUP (
                    ORDER BY
                        planname
                )
            FROM
                (
                    SELECT DISTINCT
                        zz.planname
                    FROM
                        tblclaimdiagnosis zz
                    WHERE
                        zz.claimcode = a.claimcode
                        AND zz.plancode <> 0
                        AND zz.claimcode <> 0
                )
        ),
        ''
    ) AS product,
    NVL (TRUNC (d.effectivity), '') AS effdate,
    NVL (TRUNC (d.effectivity), '') AS expdate,
    NVL (TRUNC (d.birthdate), '') AS bday,
    a.gender AS gender,
    LTRIM (RTRIM (NVL (e.province, ''))) || CASE
        WHEN LTRIM (RTRIM (NVL (e.province, ''))) = '' THEN ''
        ELSE ', '
    END || LTRIM (RTRIM (NVL (e.municipality, ''))) || CASE
        WHEN LTRIM (RTRIM (NVL (e.municipality, ''))) = '' THEN ''
        ELSE ', '
    END || LTRIM (RTRIM (NVL (e.barangay, ''))) || CASE
        WHEN LTRIM (RTRIM (NVL (e.barangay, ''))) = '' THEN ''
        ELSE ', '
    END || LTRIM (RTRIM (NVL (e.street, ''))) AS addr,
    a.memberstatus,
    'YES' AS loa,
    a.loano AS loano,
    TRUNC (a.dateavailed) AS dateutil,
    NVL (i.description, '') AS coveragetype,
    NVL (
        (
            SELECT
                LISTAGG (
                    NVL (LTRIM (RTRIM (x.icddisease)), zz.admittingtext),
                    ', '
                ) WITHIN GROUP (
                    ORDER BY
                        zz.claimcode
                )
            FROM
                tblclaimdiagnosis zz
                LEFT JOIN tblicdtable x ON zz.icdno = x.icdno
                AND zz.icdno <> 0
            WHERE
                zz.claimcode = a.claimcode
                AND zz.icdno <> 0
                AND zz.claimcode <> 0
            group by
                zz.claimcode
        ),
        ''
    ) AS causeofavailment,
    CASE NVL (j.providertype, 0)
        WHEN 1 THEN 'HOSPITAL'
        WHEN 2 THEN 'CLINIC'
        WHEN 3 THEN 'BILLING COMPANY'
        WHEN 4 THEN 'DENTAL CLINIC'
        ELSE ''
    END AS providertype,
    NVL (j.providername, '') AS providername,
    -- TRUNC (a.dateavailed) AS hospdatefrom,
        CASE 
        WHEN TRUNC(a.dateavailed) = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE TRUNC(a.dateavailed)
    END AS hospdatefrom, --updated 07022025    
    -- TRUNC (a.datedischarged) AS hospdatetp,
        CASE 
        WHEN TRUNC(a.datedischarged) = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE TRUNC(a.datedischarged)
    END AS hospdatetp, --updated 07022025
    a.loaamount AS availmentamount,
    NVL (k.statusname, '') AS claimstatus,
    '' AS denialreason,
    NVL (l.username, '') AS staff,
    NVL (m.locationname, '') AS staffbranch,
    --TRUNC(a.claimreceived) as datenoticetopartner,
        CASE 
        WHEN TRUNC(a.claimreceived) = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE TRUNC(a.claimreceived)
    END AS datenoticetopartner, --updated 07022025
    --TO_DATE ('1900-01-01', 'YYYY-MM-DD') as datenoticetopioneer,
    '' as datenoticetopioneer,
    TRUNC (a.dateavailed) AS datecompletion,
    -- NVL (
    --     TRUNC (c.datecompleted),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS dateapproval,
    TRUNC (c.datecompleted) AS dateapproval,
    -- NVL (
    --     TRUNC (c.datecompleted),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS approveddate,
    TRUNC (c.datecompleted) AS approveddate,
    NVL (c.beneficiary, '') AS authorizedperson,
    NVL (e.mobile, '') as contactno,
    NVL (n.checkamount, 0.00) AS payoutamt,
    '' AS remarks,
    a.dateposted
FROM
    tblclaims a
    LEFT JOIN tblcompany b ON a.compcode = b.compcode
    LEFT JOIN tblclaimbillings c ON a.billno = c.billno
    LEFT JOIN tblmembers d ON a.membercode = d.membercode
    LEFT JOIN tblmemberdetails e ON a.membercode = e.membercode
    LEFT JOIN tblcompanybenefitplan f ON a.plancode = f.plancode
    LEFT JOIN tbllocations g ON e.homecity = g.locationcode
    LEFT JOIN tbllocations h ON e.homeprovince = h.locationcode
    LEFT JOIN tblgentables i ON a.claimtype = i.detno
    AND i.tablename = 'CLAIMS SERVICES'
    LEFT JOIN tblproviders j ON a.providercode = j.providercode
    LEFT JOIN tblstatus k ON a.claimstatus = k.statusno
    AND k.statusfor = 'CLAIMS'
    LEFT JOIN tblusers l ON a.encodedby = l.userno
    LEFT JOIN tbllocations m ON l.branchno = m.locationcode
    LEFT JOIN tbldisbursementvouchers n ON c.dvno IS NOT NULL
    AND c.dvno = n.dvno
WHERE
    a.claimcode <> 0
    AND (
        a.caseno IS NOT NULL
        or a.caseno <> ''
    )
    AND (TRUNC(a.dateencoded) = TRUNC(sysdate) - 1 OR TRUNC(a.dateposted) = TRUNC(sysdate -1)) -- incremental load 
order by
    TRUNC (a.dateencoded);
COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_CLAIM_LIST_REPORT', 'SP_REPORT_MHI_DSCLAIMLISTREPORT', SYSDATE, SYSDATE, 'UPDATE');
--ADDED by francis 05272025

--transfer old data to history 
--adw_prod_tgt.sp_adw_table_logs('DS_CLAIM_LIST_REPORT_HIST', 'SP_REPORT_MHI_DSCLAIMLISTREPORT', SYSDATE, '', 'INSERT');
INSERT INTO
    adw_prod_tgt.DS_CLAIM_LIST_REPORT_HIST (
        partner,
        segment, -- Segment (empty for now)
        subseg, -- Line of business
        batchno, -- Bill number
        claimrefno, -- Case number
        datecreated, -- Date encoded (cast to DATE)
        membername, -- Decrypted member name
        rfp, -- Date completed
        lastn, -- Decrypted last name
        firstn, -- Decrypted first name
        midi, -- Decrypted middle initial
        gname, -- Suffix
        age, -- Calculated age
        clienttype, -- Client type (based on CASE logic)
        pomno, -- Card number
        uccno, -- Member number
        product, -- Plan name
        effdate, -- Effectivity date
        expdate, -- Expiry date
        bday, -- Birth date
        sex, -- Gender --updated by francis 5/16/2025
        addr, -- Address (concatenation)
        status, -- Member status --updated by francis 5/16/2025
        loa, -- Always ''YES''
        loano, -- LOA number
        dateutil, -- Date availed
        coveragetype, -- Coverage type description
        causeofavailment, -- Cause of availment
        provider, -- Provider type --updated by francis 05162025
        providername, -- Provider name
        hospdatefrom, -- Date availed (hospitalization start)
        hospdateto, -- Date discharged (hospitalization end) --updated by francis 5/16/2025
        availmentamount, -- LOA amount
        claimstatus, -- Claim status
        denialreason, -- Denial reason (empty for now)
        staff, -- Encoded by username
        branch_prov_office, -- Branch location name --updated by francis 05162025
        date_of_notice_to_partner,
        date_of_notice_to_pioneer,
        datecompletion, -- Date availed (completion)
        dateapproval, -- Date approved
        approveddate, -- Approved date
        authorizedperson, -- Beneficiary
        contact_number,
        payoutamt, -- Check amount
        remarks, -- Remarks
        dateposted
    )
SELECT
    partner,
    segment, -- Segment (empty for now)
    subseg, -- Line of business
    batchno, -- Bill number
    claimrefno, -- Case number
    datecreated, -- Date encoded (cast to DATE)
    membername, -- Decrypted member name
    rfp, -- Date completed
    lastn, -- Decrypted last name
    firstn, -- Decrypted first name
    midi, -- Decrypted middle initial
    gname, -- Suffix
    age, -- Calculated age
    clienttype, -- Client type (based on CASE logic)
    pomno, -- Card number
    uccno, -- Member number
    product, -- Plan name
    effdate, -- Effectivity date
    expdate, -- Expiry date
    bday, -- Birth date
    sex, -- Gender --updated by francis 5/16/2025
    addr, -- Address (concatenation)
    status, -- Member status --updated by francis 5/16/2025
    loa, -- Always ''YES''
    loano, -- LOA number
    dateutil, -- Date availed
    coveragetype, -- Coverage type description
    causeofavailment, -- Cause of availment
    provider, -- Provider type --updated by francis 05162025
    providername, -- Provider name
    hospdatefrom, -- Date availed (hospitalization start)
    hospdateto, -- Date discharged (hospitalization end) --updated by francis 5/16/2025
    availmentamount, -- LOA amount
    claimstatus, -- Claim status
    denialreason, -- Denial reason (empty for now)
    staff, -- Encoded by username
    branch_prov_office, -- Branch location name --updated by francis 05162025
    date_of_notice_to_partner,
    date_of_notice_to_pioneer,
    datecompletion, -- Date availed (completion)
    dateapproval, -- Date approved
    approveddate, -- Approved date
    authorizedperson, -- Beneficiary
    contact_number,
    payoutamt, -- Check amount
    remarks, -- Remarks
    dateposted
FROM
    (
        SELECT
            partner,
            segment, -- Segment (empty for now)
            subseg, -- Line of business
            batchno, -- Bill number
            claimrefno, -- Case number
            datecreated, -- Date encoded (cast to DATE)
            membername, -- Decrypted member name
            rfp, -- Date completed
            lastn, -- Decrypted last name
            firstn, -- Decrypted first name
            midi, -- Decrypted middle initial
            gname, -- Suffix
            age, -- Calculated age
            clienttype, -- Client type (based on CASE logic)
            pomno, -- Card number
            uccno, -- Member number
            product, -- Plan name
            effdate, -- Effectivity date
            expdate, -- Expiry date
            bday, -- Birth date
            sex, -- Gender --updated by francis 5/16/2025
            addr, -- Address (concatenation)
            status, -- Member status --updated by francis 5/16/2025
            loa, -- Always ''YES''
            loano, -- LOA number
            dateutil, -- Date availed
            coveragetype, -- Coverage type description
            causeofavailment, -- Cause of availment
            provider, -- Provider type --updated by francis 05162025
            providername, -- Provider name
            hospdatefrom, -- Date availed (hospitalization start)
            hospdateto, -- Date discharged (hospitalization end) --updated by francis 5/16/2025
            availmentamount, -- LOA amount
            claimstatus, -- Claim status
            denialreason, -- Denial reason (empty for now)
            staff, -- Encoded by username
            branch_prov_office, -- Branch location name --updated by francis 05162025
            date_of_notice_to_partner,
            date_of_notice_to_pioneer,
            datecompletion, -- Date availed (completion)
            dateapproval, -- Date approved
            approveddate, -- Approved date
            authorizedperson, -- Beneficiary
            contact_number,
            payoutamt, -- Check amount
            remarks, -- Remarks
            dateposted,
            ROW_NUMBER() OVER (
                PARTITION BY
                    CLAIMREFNO
                ORDER BY
                    CASE
                        WHEN DATEPOSTED IS NULL THEN 1
                        ELSE 0
                    END,
                    DATEPOSTED DESC
            ) AS ROW_NUM
        FROM
            adw_prod_tgt.DS_CLAIM_LIST_REPORT
        WHERE
            CLAIMREFNO IN (
                SELECT
                    CLAIMREFNO
                FROM
                    adw_prod_tgt.DS_CLAIM_LIST_REPORT
                GROUP BY
                    CLAIMREFNO
                HAVING
                    COUNT(*) > 1
            )
    )
WHERE
    ROW_NUM > 1;
COMMIT;
DELETE FROM adw_prod_tgt.DS_CLAIM_LIST_REPORT --added by francis 05272025
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
                            CLAIMREFNO
                        ORDER BY
                            CASE
                                WHEN dateposted IS NULL THEN 1
                                ELSE 0
                            END,
                            dateposted desc
                    ) AS row_num
                from
                    adw_prod_tgt.ds_claim_list_report
            )
        where
            row_num > 1
    );
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('DS_CLAIM_LIST_REPORT_HIST', 'SP_REPORT_MHI_DSCLAIMLISTREPORT', SYSDATE, SYSDATE, 'UPDATE');


  END SP_REPORT_MHI_DSCLAIMLISTREPORT;
 