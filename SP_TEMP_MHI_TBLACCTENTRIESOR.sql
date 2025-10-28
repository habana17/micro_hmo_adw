create
or replace PROCEDURE SP_TEMP_MHI_TBLACCTENTRIESOR AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLACCTENTRIESOR
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLACCTENTRIESOR


NOTES:

 ******************************************************************************/
 
--adw_prod_tgt.sp_adw_table_logs('TBLACCTENTRIESOR', 'SP_TEMP_MHI_TBLACCTENTRIESOR', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLACCTENTRIESOR
WHERE 1=1
AND TRUNC(ordate) >= TRUNC(SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLACCTENTRIESOR', 'SP_TEMP_MHI_TBLACCTENTRIESOR', SYSDATE, '', 'INSERT');
INSERT INTO adw_prod_tgt.TBLACCTENTRIESOR (
trancode, 
orno, 
ordate, 
acctcode, 
acctname, 
firstname, 
lastname, 
miname, 
streetaddress, 
citycode, 
provincecode, 
tinno, 
branchno, 
paytype, 
particulars, 
statuscode, 
referenceno, 
tranamount, 
usdamount, 
paidamount, 
cashamount, 
checkno, 
checkdate, 
checkamount, 
confidential, 
outside, 
exchangerate, 
datecreated, 
preparedby, 
approvedby, 
checkedby, 
userbranchno, 
remarks, 
trandate, 
accttype, 
grossamount, 
netamount, 
vatsale, 
vatamount, 
vatexempt, 
vatzerorated, 
wtaxamount, 
branchfrom, 
bankcode, 
importedcode, 
groupcode, 
rowmarker, 
transmittalno, 
encodedby, 
compcode, 
oramount, 
totalamount, 
memocode, 
trantype, 
datecancelled, 
contractcode, 
variousaddress, 
varioustinno, 
cardnumber, 
cardholder, 
expiry, 
approvalcode, 
traceno, 
vattype, 
bankname
)
SELECT
trancode, 
orno, 
ordate, 
acctcode, 
acctname, 
firstname, 
lastname, 
miname, 
streetaddress, 
citycode, 
provincecode, 
tinno, 
branchno, 
paytype, 
particulars, 
statuscode, 
referenceno, 
tranamount, 
usdamount, 
paidamount, 
cashamount, 
checkno, 
checkdate, 
checkamount, 
confidential, 
outside, 
exchangerate, 
datecreated, 
preparedby, 
approvedby, 
checkedby, 
userbranchno, 
remarks, 
trandate, 
accttype, 
grossamount, 
netamount, 
vatsale, 
vatamount, 
vatexempt, 
vatzerorated, 
wtaxamount, 
branchfrom, 
bankcode, 
importedcode, 
groupcode, 
rowmarker, 
transmittalno, 
encodedby, 
compcode, 
oramount, 
totalamount, 
memocode, 
trantype, 
datecancelled, 
contractcode, 
variousaddress, 
varioustinno, 
cardnumber, 
cardholder, 
expiry, 
approvalcode, 
traceno, 
vattype, 
bankname  
FROM adw_prod_tgt.TEMP_TBLACCTENTRIESOR;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLACCTENTRIESOR';
--adw_prod_tgt.sp_adw_table_logs('TBLACCTENTRIESOR', 'SP_TEMP_MHI_TBLACCTENTRIESOR', SYSDATE, SYSDATE, 'UPDATE');  
 
 END SP_TEMP_MHI_TBLACCTENTRIESOR;
 