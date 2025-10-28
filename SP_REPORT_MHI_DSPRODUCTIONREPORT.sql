create
or replace PROCEDURE SP_REPORT_MHI_DSPRODUCTIONREPORT AS lremitdate DATE; 

/******************************************************************************

NAME:       SP_REPORT_MHI_DSPRODUCTIONREPORT
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/30/2025       Francis          1. Create SP_REPORT_MHI_DSPRODUCTIONREPORT
1.1        06/19/2025       Francis          1. add lremitdate variable 


NOTES:

 ******************************************************************************/

 BEGIN

   SELECT min(remittancedate) INTO lremitdate
   FROM
   tblmembers 
   where trunc(dateencoded) = trunc(sysdate - 1)
   ; --add by francis 06192025



-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_PRODUCTION_REPORT', 'SP_REPORT_MHI_DSPRODUCTIONREPORT', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_PRODUCTION_REPORT
WHERE
    1 = 1
    AND TRUNC (remittancedate) >= TRUNC (lremitdate) --incremental load , need to get minimum remittance date to delete and insert later  updated by francis 06192025
    ;
COMMIT;
-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_PRODUCTION_REPORT', 'SP_REPORT_MHI_DSPRODUCTIONREPORT', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
    adw_prod_tgt.DS_PRODUCTION_REPORT (
        accountname, -- Trimmed account name
        product, -- Benefit class/product
        provincialoffice, -- Location name of the provincial office
        institution, -- Institution name
        modeofpayment, -- Mode of payment (CASH/LOAN/empty)
        bankbranchloan, -- Loan bank branch number
        bankbranchaccount, -- Account bank branch number
        remittancedate , -- Remittance date
        enrollmentcount , -- Count of records
        totalmemberfee
    )
WITH
    temp_memberfees AS (
        SELECT
            a.membercode,
            SUM(
                CASE
                    WHEN NVL (amountprorate, 0) <> 0 THEN NVL (amountprorate, 0)
                    ELSE NVL (amount, 0)
                END
            ) AS memberfee
        FROM
            tblmemberfees a
            LEFT JOIN tblmembers b ON a.membercode = b.membercode
        WHERE
            active = 1
            and trunc(b.remittancedate) >= trunc(lremitdate) --incremental load add by francis 06192025 
        GROUP BY
            a.membercode
    )
SELECT
    UPPER(LTRIM (RTRIM (NVL (decoder(b.ldflog, 0), '')))) AS accountname,
    UPPER(LTRIM (RTRIM (a.benefitclass))) AS product,
    UPPER(LTRIM (RTRIM (NVL (e.locationname, '')))) AS provincialoffice,
    UPPER(LTRIM (RTRIM (NVL (h.institution, '')))) AS institution,
    CASE NVL (c.modeofpayment, 0)
        WHEN 1 THEN 'CASH'
        WHEN 2 THEN 'LOAN'
        ELSE ''
    END AS modeofpayment,
    LTRIM (RTRIM (a.accountbankbranchno)) AS bankbranchloan,
    LTRIM (RTRIM (a.loanbankbranchno)) AS bankbranchaccount,
    --a.remittancedate,
    CASE 
        WHEN TRUNC(a.remittancedate) = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE TRUNC(a.remittancedate)
    END AS remittancedate, --updated 07022025
    COUNT(1) AS count,
    SUM(NVL (f.memberfee, 0)) AS totalmemberfee
FROM
    tblmembers a
    LEFT JOIN tblcompany b ON a.compcode = b.compcode
    LEFT JOIN tblmemberdetails c ON a.membercode = c.membercode
    LEFT JOIN tblagents d ON a.agentno = d.agentno
    LEFT JOIN tbllocations e ON d.branchno = e.locationcode
    AND e.locationtype = 'BRANCH'
    LEFT JOIN temp_memberfees f ON a.membercode = f.membercode
    LEFT JOIN tblmembershipinstitutions h ON a.membershipinstitutionno = h.membershipinstitutionno
    WHERE 1=1
    AND TRUNC(a.remittancedate) >= TRUNC(lremitdate) --incremental load updated by francis 06192025
GROUP BY
    b.ldflog,
    c.modeofpayment,
    a.benefitclass,
    e.locationname,
    h.institution,
    a.accountbankbranchno,
    a.loanbankbranchno,
    a.remittancedate;
COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_PRODUCTION_REPORT', 'SP_REPORT_MHI_DSPRODUCTIONREPORT', SYSDATE, SYSDATE, 'UPDATE');

  END SP_REPORT_MHI_DSPRODUCTIONREPORT;
 