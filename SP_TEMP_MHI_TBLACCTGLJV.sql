create
or replace PROCEDURE SP_TEMP_MHI_TBLACCTGLJV AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLACCTGLJV
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLACCTGLJV


NOTES:

 ******************************************************************************/
 
--adw_prod_tgt.sp_adw_table_logs('TBLACCTGLJV', 'SP_TEMP_MHI_TBLACCTGLJV', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLACCTGLJV
WHERE 1=1
AND TRUNC(voucherdate) >= TRUNC(SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLACCTGLJV', 'SP_TEMP_MHI_TBLACCTGLJV', SYSDATE, '', 'INSERT');
INSERT INTO adw_prod_tgt.TBLACCTGLJV (
detno,
trancode,
voucherdate,
jvno,
glno,
slno,
slcode,
sldesc,
branchno,
debit,
credit,
usddebit,
usdcredit,
userbranchno,
sortorder,
sltype,
renewal,
importedcode,
matrancode,
slno2,
slcode2,
sldesc2,
sltype2,
costcenter,
identifier_code,
jvdate,
compcode
)
SELECT
detno,
trancode,
voucherdate,
jvno,
glno,
slno,
slcode,
sldesc,
branchno,
debit,
credit,
usddebit,
usdcredit,
userbranchno,
sortorder,
sltype,
renewal,
importedcode,
matrancode,
slno2,
slcode2,
sldesc2,
sltype2,
costcenter,
identifier_code,
jvdate,
compcode
FROM adw_prod_tgt.TEMP_TBLACCTGLJV;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLACCTGLJV';
--adw_prod_tgt.sp_adw_table_logs('TBLACCTGLJV', 'SP_TEMP_MHI_TBLACCTGLJV', SYSDATE, SYSDATE, 'UPDATE');
 
 END SP_TEMP_MHI_TBLACCTGLJV;
 