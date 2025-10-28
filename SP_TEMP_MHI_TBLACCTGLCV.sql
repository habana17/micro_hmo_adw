create
or replace PROCEDURE SP_TEMP_MHI_TBLACCTGLCV AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLACCTGLCV
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLACCTGLCV


NOTES:

 ******************************************************************************/
 
--adw_prod_tgt.sp_adw_table_logs('TBLACCTGLCV', 'SP_TEMP_MHI_TBLACCTGLCV', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLACCTGLCV
WHERE 1=1
--AND TRUNC(timestmp) >= run_date_iris
AND TRUNC(voucherdate) >= TRUNC(SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLACCTGLCV', 'SP_TEMP_MHI_TBLACCTGLCV', SYSDATE, '', 'INSERT');
INSERT INTO adw_prod_tgt.TBLACCTGLCV (
detno,
trancode,
voucherdate,
voucherno,
glno,
slno,
slcode,
sldesc,
sltype,
branchno,
debit,
credit,
usddebit,
usdcredit,
userbranchno,
checkmarker,
sortorder,
dvno,
bankno,
branchname,
accountno,
renewal,
matrancode,
slno2,
slcode2,
sldesc2,
sltype2,
vatmarker,
wtaxmarker,
costcenter,
identifier_code,
dvdate,
compcode
)
SELECT
detno,
trancode,
voucherdate,
voucherno,
glno,
slno,
slcode,
sldesc,
sltype,
branchno,
debit,
credit,
usddebit,
usdcredit,
userbranchno,
checkmarker,
sortorder,
dvno,
bankno,
branchname,
accountno,
renewal,
matrancode,
slno2,
slcode2,
sldesc2,
sltype2,
vatmarker,
wtaxmarker,
costcenter,
identifier_code,
dvdate,
compcode
FROM adw_prod_tgt.TEMP_TBLACCTGLCV;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLACCTGLCV';
--adw_prod_tgt.sp_adw_table_logs('TBLACCTGLCV', 'SP_TEMP_MHI_TBLACCTGLCV', SYSDATE, SYSDATE, 'UPDATE');
 
 END SP_TEMP_MHI_TBLACCTGLCV;
 