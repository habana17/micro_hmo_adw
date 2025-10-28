create
or replace PROCEDURE SP_REPORT_MHI_DSCASHDISBURSEMENTREG AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_DSCASHDISBURSEMENTREG
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_DSCASHDISBURSEMENTREG


NOTES:

 ******************************************************************************/


 -- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_CASH_DISBURSEMENT_REG', 'SP_REPORT_MHI_DSCASHDISBURSEMENTREG', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_CASH_DISBURSEMENT_REG
WHERE
1 = 1
AND TRUNC (cvdate) >= TRUNC (SYSDATE);
COMMIT;
-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_CASH_DISBURSEMENT_REG', 'SP_REPORT_MHI_DSCASHDISBURSEMENTREG', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
adw_prod_tgt.DS_CASH_DISBURSEMENT_REG (
cvdate, --cv date 
cvno, --cv no
cvstatus, --cv status 
bank, -- bank
checkno, --check no
particulars, --particulars
payeecode, --payee code
payee, --payee
glcode, --glcode
slcode, --slcode
debit, --debit 
credit -- credit
)
SELECT
a.voucherdate AS cvdate,
a.voucherno AS cvno,
NVL (LTRIM (RTRIM (b.statusname)), '') AS cvstatus,
NVL (c.description, '') || CASE
WHEN NVL (d.description, '') IS NOT NULL
OR NVL (d.description, '') <> '' THEN ' (' || NVL (d.description, '') || ')'
ELSE ''
END AS bank,
LTRIM (RTRIM (a.checkno)) AS checkno,
LTRIM (RTRIM (a.particulars)) AS particulars,
LTRIM (RTRIM (a.acctcode)) AS payeecode,
LTRIM (RTRIM (a.acctname)) AS payee,
LTRIM (RTRIM (e.glcode)) AS glcode,
LTRIM (RTRIM (e.slcode)) AS slcode,
LTRIM (RTRIM (e.debit)) AS debit,
LTRIM (RTRIM (e.credit)) AS credit
FROM
tblacctentriescv a
LEFT JOIN (
SELECT
statusname,
statusno
FROM
tblstatus
WHERE
statusfor = 'CV'
) b ON a.statuscode = b.statusno
LEFT JOIN (
SELECT
description,
detno
FROM
tblgentables
WHERE
tablename = 'MODE OF PAYMENT'
) c ON a.paymentmethod = c.detno
LEFT JOIN (
SELECT
description,
detno
FROM
tblgentables
WHERE
tablename = 'BANKS'
) d ON a.paymentmethoddetail = d.detno
LEFT JOIN (
SELECT
e.trancode,
e.glno,
e.slcode,
e.debit,
e.credit,
f.glcode
FROM
tblacctglcv e
LEFT JOIN (
SELECT
glcode,
glno
FROM
tblgltemplate
) f ON e.glno = f.glno
) e ON a.trancode = e.trancode
WHERE
1 = 1
AND TRUNC(a.voucherdate) = TRUNC(SYSDATE) - 1 -- for incremental loading 
ORDER BY
a.voucherdate,
a.trancode,
e.debit DESC;
COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_CASH_DISBURSEMENT_REG', 'SP_REPORT_MHI_DSCASHDISBURSEMENTREG', SYSDATE, SYSDATE, 'UPDATE');

   END SP_REPORT_MHI_DSCASHDISBURSEMENTREG;
 