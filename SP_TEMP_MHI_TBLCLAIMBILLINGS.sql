create
or replace PROCEDURE SP_TEMP_MHI_TBLCLAIMBILLINGS AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLCLAIMBILLINGS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLCLAIMBILLINGS


NOTES:

 ******************************************************************************/
 --adw_prod_tgt.sp_adw_table_logs('SP_TEMP_MHI_TBLCLAIMBILLINGS', 'SP_TEMP_MICRO_HMO', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLCLAIMBILLINGS
WHERE 1=1
AND TRUNC(dateendorsed) >= TRUNC(SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('SP_TEMP_MHI_TBLCLAIMBILLINGS', 'SP_TEMP_MICRO_HMO', SYSDATE, '', 'INSERT');
INSERT INTO adw_prod_tgt.TBLCLAIMBILLINGS (
billcode,
billno,
soano,
vouchername,
providerbilledto,
providercode,
doctorcode,
membercode,
membertype,
compcode,
claimtype,
billtype,
billedclaims,
projectedamount,
processedclaims,
processedamount,
discount,
creditterms,
claimsprocessor,
datereceived,
dateendorsed,
datedue,
datecompleted,
datereleased,
receivedby,
branchno,
remarks,
dvno,
voucherno,
checkno,
checkdate,
checkamount,
wtaxamount,
vatamount,
pettycash,
cancelled,
beneficiary,
pfprojectedamount,
rowmarker,
adjamount,
claimadjamount,
manualdvno,
oramount,
orno,
ordate,
orposteddate,
orpostedby,
csdateprepared,
cspreparedby,
vatrate,
vattype,
dateutilfrom,
dateutilto,
discountamount,
discountrate,
adminamount,
adminrate,
billingremarks,
billstatus,
paymentmethod,
paymentmethoddetail,
bankaccttype,
bankacctno
)
SELECT
billcode,
billno,
soano,
vouchername,
providerbilledto,
providercode,
doctorcode,
membercode,
membertype,
compcode,
claimtype,
billtype,
billedclaims,
projectedamount,
processedclaims,
processedamount,
discount,
creditterms,
claimsprocessor,
datereceived,
dateendorsed,
datedue,
datecompleted,
datereleased,
receivedby,
branchno,
remarks,
dvno,
voucherno,
checkno,
checkdate,
checkamount,
wtaxamount,
vatamount,
pettycash,
cancelled,
beneficiary,
pfprojectedamount,
rowmarker,
adjamount,
claimadjamount,
manualdvno,
oramount,
orno,
ordate,
orposteddate,
orpostedby,
csdateprepared,
cspreparedby,
vatrate,
vattype,
dateutilfrom,
dateutilto,
discountamount,
discountrate,
adminamount,
adminrate,
billingremarks,
billstatus,
paymentmethod,
paymentmethoddetail,
bankaccttype,
bankacctno
FROM adw_prod_tgt.TEMP_TBLCLAIMBILLINGS;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLCLAIMBILLINGS';
--adw_prod_tgt.sp_adw_table_logs('SP_TEMP_MHI_TBLCLAIMBILLINGS', 'SP_TEMP_MICRO_HMO', SYSDATE, SYSDATE, 'UPDATE');

 
 END SP_TEMP_MHI_TBLCLAIMBILLINGS;
 