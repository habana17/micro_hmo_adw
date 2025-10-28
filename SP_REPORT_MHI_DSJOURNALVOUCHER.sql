create
or replace PROCEDURE SP_REPORT_MHI_DSJOURNALVOUCHER AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_DSJOURNALVOUCHER
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_DSJOURNALVOUCHER


NOTES:

 ******************************************************************************/

-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_JOURNAL_VOUCHER', 'SP_REPORT_MHI_DSJOURNALVOUCHER', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_JOURNAL_VOUCHER
WHERE
1 = 1
AND TRUNC (trandate) >= TRUNC (SYSDATE);
COMMIT;
-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_JOURNAL_VOUCHER', 'SP_REPORT_MHI_DSJOURNALVOUCHER', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
adw_prod_tgt.DS_JOURNAL_VOUCHER (
trandate, -- transaction date 
tranno, --transaction no
transtatus, --transaction status
particulars, -- particulars
closeuserid, --close user id 
glcode, --glcode
slcode, --slcode
debit, --debit
credit -- credit 
)
SELECT
a.voucherdate AS trandate,
LTRIM (RTRIM (a.jvno)) AS tranno,
NVL (LTRIM (RTRIM (b.statusname)), '') AS transtatus,
NVL (LTRIM (RTRIM (a.particulars)), '') AS particulars,
'' AS closeuserid,
LTRIM (RTRIM (c.glcode)) AS glcode,
LTRIM (RTRIM (c.slcode)) AS slcode,
LTRIM (RTRIM (c.debit)) AS debit,
LTRIM (RTRIM (c.credit)) AS credit
FROM
tblacctentriesjv a
LEFT JOIN (
SELECT
b.statusno,
b.statusname,
b.statusfor
FROM
tblstatus b
WHERE
b.statusfor = 'OR'
) b ON a.statuscode = b.statusno
LEFT JOIN (
SELECT
c.trancode,
c.glno,
c.slcode,
c.debit,
c.credit,
d.glcode
FROM
tblacctgljv c
LEFT JOIN tblgltemplate d ON c.glno = d.glno
) c ON a.trancode = c.trancode
WHERE
1 = 1
AND TRUNC(a.voucherdate) = TRUNC(sysdate) - 1 --incremental loading
ORDER BY
a.voucherdate,
a.trancode,
c.debit DESC;
COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_JOURNAL_VOUCHER', 'SP_REPORT_MHI_DSJOURNALVOUCHER', SYSDATE, SYSDATE, 'UPDATE');

  END SP_REPORT_MHI_DSJOURNALVOUCHER;
 