create
or replace PROCEDURE SP_TEMP_MHI_TBLACCTENTRIESJV AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLACCTENTRIESJV
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLACCTENTRIESJV


NOTES:

 ******************************************************************************/
 
--adw_prod_tgt.sp_adw_table_logs('TBLACCTENTRIESJV', 'SP_TEMP_MHI_TBLACCTENTRIESJV', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLACCTENTRIESJV
WHERE 1=1
AND TRUNC(datecreated) >= TRUNC(SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLACCTENTRIESJV', 'SP_TEMP_MHI_TBLACCTENTRIESJV', SYSDATE, '', 'INSERT');
INSERT INTO adw_prod_tgt.TBLACCTENTRIESJV (
trancode,
jvno,
voucherdate,
trantype,
branchno,
particulars,
usdamount,
tranamount,
statuscode,
referenceno,
datecreated,
preparedby,
approvedby,
checkedby,
confidential,
outside,
exchangerate,
userbranchno,
memocode,
jvcategory,
transmittalno,
bankno,
accttype,
importedcode,
compcode,
jvtype,
jvdate,
jvamount,
datecancelled,
workstation,
referenceno2,
cancelledrecon,
oldjvno
)
SELECT
trancode,
jvno,
voucherdate,
trantype,
branchno,
particulars,
usdamount,
tranamount,
statuscode,
referenceno,
datecreated,
preparedby,
approvedby,
checkedby,
confidential,
outside,
exchangerate,
userbranchno,
memocode,
jvcategory,
transmittalno,
bankno,
accttype,
importedcode,
compcode,
jvtype,
jvdate,
jvamount,
datecancelled,
workstation,
referenceno2,
cancelledrecon,
oldjvno
FROM adw_prod_tgt.TEMP_TBLACCTENTRIESJV;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLACCTENTRIESJV';
--adw_prod_tgt.sp_adw_table_logs('TBLACCTENTRIESJV', 'SP_TEMP_MHI_TBLACCTENTRIESJV', SYSDATE, SYSDATE, 'UPDATE');
 
 END SP_TEMP_MHI_TBLACCTENTRIESJV;
 