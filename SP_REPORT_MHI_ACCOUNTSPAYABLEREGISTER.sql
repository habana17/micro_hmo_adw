create
or replace PROCEDURE SP_REPORT_MHI_ACCOUNTSPAYABLEREGISTER AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_ACCOUNTSPAYABLEREGISTER
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_ACCOUNTSPAYABLEREGISTER


NOTES:

 ******************************************************************************/

-- Logging the DELETE operation 
adw_prod_tgt.sp_adw_table_logs('DS_ACCOUNTS_PAYABLE_REGISTER', 'SP_REPORT_MHI_ACCOUNTSPAYABLEREGISTER', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_ACCOUNTS_PAYABLE_REGISTER
WHERE
1 = 1
AND TRUNC (date_received) >= TRUNC (SYSDATE);
COMMIT;
-- Logging the INSERT operation 
adw_prod_tgt.sp_adw_table_logs('DS_ACCOUNTS_PAYABLE_REGISTER', 'SP_REPORT_MHI_ACCOUNTSPAYABLEREGISTER', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
adw_prod_tgt.DS_ACCOUNTS_PAYABLE_REGISTER (
op_no,
op_date, -- Operation Date
invoice_no, -- Invoice Number
date_received,
invoice_date, -- Invoice Date
supplier_name, -- Supplier Name
supplier_tin, -- Supplier TIN
description, -- Description
gross_amount, -- Gross Amount
vat_amount, -- VAT Amount
wtax_amount, -- Withholding Tax Amount
other_charges, -- Other Charges
payable_amount -- Payable Amount
)
SELECT
NVL (LTRIM (RTRIM (c.dvno)), '') AS opno,
NVL (TRUNC (c.dvdate), DATE '1900-01-01') AS opdate,
LTRIM (RTRIM (a.billno)) AS invoiceno,
NVL (TRUNC (b.datereceived), DATE '1900-01-01') AS datereceived,
NVL (TRUNC (a.datecreated), DATE '1900-01-01') AS invoicedate,
NVL (LTRIM (RTRIM (c.vouchername)), '') AS suppliername,
LTRIM (RTRIM (a.tinno)) AS tin,
LTRIM (RTRIM (a.particulars)) AS description,
a.tranamount AS grossamount,
a.vatamount,
a.wtaxamount,
a.discount AS othercharges,
a.checkamount AS payableamount
FROM
tblacctentriescv a
LEFT JOIN (
SELECT
datereceived,
billno
FROM
tblclaimbillings
) b ON b.billno = a.billno
LEFT JOIN (
SELECT
dvdate,
dvno,
vouchername
FROM
tbldisbursementvouchers
) c ON a.dvno = c.dvno
WHERE
a.wtaxamount <> 0.00
AND TRUNC(b.datereceived) = TRUNC(sysdate) - 1 --incremental
ORDER BY
opno;
COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
adw_prod_tgt.sp_adw_table_logs('DS_ACCOUNTS_PAYABLE_REGISTER', 'SP_REPORT_MHI_ACCOUNTSPAYABLEREGISTER', SYSDATE, SYSDATE, 'UPDATE');

  END SP_REPORT_MHI_ACCOUNTSPAYABLEREGISTER;
 