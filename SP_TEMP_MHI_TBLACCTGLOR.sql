create
or replace PROCEDURE SP_TEMP_MHI_TBLACCTGLOR AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLACCTGLOR
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLACCTGLOR


NOTES:

 ******************************************************************************/
 
--adw_prod_tgt.sp_adw_table_logs('TBLACCTGLOR', 'SP_TEMP_MHI_TBLACCTGLOR', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLACCTGLOR
WHERE 1=1
AND TRUNC(ordate) >= TRUNC(SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLACCTGLOR', 'SP_TEMP_MHI_TBLACCTGLOR', SYSDATE, '', 'INSERT');
INSERT INTO adw_prod_tgt.TBLACCTGLOR (
detno, 
trancode, 
ordate, 
glno, 
slno, 
branchno, 
userbranchno, 
debit, 
credit, 
usddebit, 
usdcredit, 
sortorder, 
slcode, 
sldesc, 
sltype, 
trandate, 
importedcode, 
groupcode, 
matrancode, 
slno2, 
slcode2, 
sldesc2, 
sltype2, 
ormarker, 
vatmarker, 
wtaxmarker, 
costcenter, 
identifier_code
)
SELECT
detno, 
trancode, 
ordate, 
glno, 
slno, 
branchno, 
userbranchno, 
debit, 
credit, 
usddebit, 
usdcredit, 
sortorder, 
slcode, 
sldesc, 
sltype, 
trandate, 
importedcode, 
groupcode, 
matrancode, 
slno2, 
slcode2, 
sldesc2, 
sltype2, 
ormarker, 
vatmarker, 
wtaxmarker, 
costcenter, 
identifier_code
FROM adw_prod_tgt.TEMP_TBLACCTGLOR;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLACCTGLOR';
--adw_prod_tgt.sp_adw_table_logs('TBLACCTGLOR', 'SP_TEMP_MHI_TBLACCTGLOR', SYSDATE, SYSDATE, 'UPDATE');
 
 END SP_TEMP_MHI_TBLACCTGLOR;
 