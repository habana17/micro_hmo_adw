create
or replace PROCEDURE SP_TEMP_MHI_TBLCLAIMDIAGNOSIS AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLCLAIMDIAGNOSIS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/29/2025       Francis          1. Create SP_TEMP_MHI_TBLCLAIMDIAGNOSIS


NOTES:

 ******************************************************************************/
 
--adw_prod_tgt.sp_adw_table_logs('TBLCLAIMDIAGNOSIS', 'SP_TEMP_MHI_TBLCLAIMDIAGNOSIS', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLCLAIMDIAGNOSIS
WHERE 1=1
AND TRUNC(dateencoded) >= TRUNC(SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLCLAIMDIAGNOSIS', 'SP_TEMP_MHI_TBLCLAIMDIAGNOSIS', SYSDATE, '', 'INSERT');
INSERT INTO adw_prod_tgt.TBLCLAIMDIAGNOSIS (
detno,
caseno,
claimcode,
providercode,
compcode,
membercode,
icdno,
admittingtext,
diagnosistype,
dateavailed,
doctorcode,
icdlimitdetno,
encodedby,
dateencoded,
laymansterm,
basicclaim,
creditedamount,
intervininggroup,
majorclaim,
plancode,
planname,
relatedplangroup,
spilloverclaim,
deductible,
deductiblemajor,
deductiblespillover,
pecwaived,
npamount,
nppfamount,
phamount,
phpfamount,
adjamountpf,
discount,
pfdiscount,
adjamount,
refundamount,
refundamountpf,
hbadjdisapproved,
pfadjdisapproved,
hbadjapproved,
pfadjapproved,
eobamount
)
SELECT
detno,
caseno,
claimcode,
providercode,
compcode,
membercode,
icdno,
admittingtext,
diagnosistype,
dateavailed,
doctorcode,
icdlimitdetno,
encodedby,
dateencoded,
laymansterm,
basicclaim,
creditedamount,
intervininggroup,
majorclaim,
plancode,
planname,
relatedplangroup,
spilloverclaim,
deductible,
deductiblemajor,
deductiblespillover,
pecwaived,
npamount,
nppfamount,
phamount,
phpfamount,
adjamountpf,
discount,
pfdiscount,
adjamount,
refundamount,
refundamountpf,
hbadjdisapproved,
pfadjdisapproved,
hbadjapproved,
pfadjapproved,
eobamount
FROM adw_prod_tgt.TEMP_TBLCLAIMDIAGNOSIS;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLCLAIMDIAGNOSIS';
--adw_prod_tgt.sp_adw_table_logs('TBLCLAIMDIAGNOSIS', 'SP_TEMP_MHI_TBLCLAIMDIAGNOSIS', SYSDATE, SYSDATE, 'UPDATE');
 
 END SP_TEMP_MHI_TBLCLAIMDIAGNOSIS;
 