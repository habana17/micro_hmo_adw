create
or replace PROCEDURE SP_REPORT_MHI_DSCASHRECEIPTSREGISTER AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_DSCASHRECEIPTSREGISTER
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_DSCASHRECEIPTSREGISTER


NOTES:

 ******************************************************************************/

-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_CASH_RECEIPTS_REGISTER', 'SP_REPORT_MHI_DSCASHRECEIPTSREGISTER', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_CASH_RECEIPTS_REGISTER
WHERE
1 = 1
AND TRUNC (trandate) >= TRUNC (SYSDATE);
COMMIT;
-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_CASH_RECEIPTS_REGISTER', 'SP_REPORT_MHI_DSCASHRECEIPTSREGISTER', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
adw_prod_tgt.DS_CASH_RECEIPTS_REGISTER (
TRANDATE,
ORNO,
PARTICULARS,
OR_STATUS,
POLICYNO,
PAYOR,
GLCODE,
SLCODE,
DEBIT,
CREDIT
)
SELECT
a.trandate,
LTRIM (RTRIM (a.orno)) AS orno,
NVL (LTRIM (RTRIM (a.particulars)), '') AS particulars,
NVL (LTRIM (RTRIM (b.statusname)), '') AS statusname,
NVL (LTRIM (RTRIM (c.contractno)), '') AS policyno,
NVL (LTRIM (RTRIM (a.acctname)), '') AS payor,
LTRIM (RTRIM (d.glcode)) AS glcode,
LTRIM (RTRIM (d.slcode)) AS slcode,
LTRIM (RTRIM (d.debit)) AS debit,
LTRIM (RTRIM (d.credit)) AS credit
FROM
tblacctentriesor a
LEFT JOIN (
SELECT
statusno,
statusname
FROM
tblstatus
WHERE
statusfor = 'OR'
) b ON a.statuscode = b.statusno
LEFT JOIN tblcompany c ON a.acctcode = c.compcode
LEFT JOIN (
SELECT
d.trancode,
e.glcode,
d.slcode,
d.debit,
d.credit
FROM
tblacctglor d
LEFT JOIN tblgltemplate e ON d.glno = e.glno
) d ON a.trancode = d.trancode
WHERE
1 = 1
AND TRUNC(a.trandate) = TRUNC(sysdate - 1) --incremental
ORDER BY
a.trandate,
a.trancode,
d.debit DESC;
COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_CASH_RECEIPTS_REGISTER', 'SP_REPORT_MHI_DSCASHRECEIPTSREGISTER', SYSDATE, SYSDATE, 'UPDATE');

  END SP_REPORT_MHI_DSCASHRECEIPTSREGISTER;
 