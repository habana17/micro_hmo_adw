create
or replace PROCEDURE SP_TEMP_MHI_TBLSOAPREMIUMMEMBERS AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLSOAPREMIUMMEMBERS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLSOAPREMIUMMEMBERS


NOTES:

 ******************************************************************************/

--adw_prod_tgt.sp_adw_table_logs('TBLSOAPREMIUMMEMBERS', 'SP_TEMP_MHI_TBLSOAPREMIUMMEMBERS', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLSOAPREMIUMMEMBERS
WHERE 1=1
AND TRUNC(dateencoded) >= TRUNC(SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLSOAPREMIUMMEMBERS', 'SP_TEMP_MHI_TBLSOAPREMIUMMEMBERS', SYSDATE, '', 'INSERT');
INSERT INTO adw_prod_tgt.TBLSOAPREMIUMMEMBERS (
detno,
soano,
soacode,
plancode,
soasobdetno,
memberpremium,
premiumcode,
compcode,
membercode,
memberno,
membername,
membercategory,
classorder,
sobamount,
batchcode,
batchtype,
dateencoded,
encodedby,
effectivity,
modalfrom,
modalto,
rowmarker,
basepremium,
policydivision,
vatamount,
feecode,
additional,
madamount,
memberfeecode,
premiumclass,
paidamount
)
SELECT
detno,
soano,
soacode,
plancode,
soasobdetno,
memberpremium,
premiumcode,
compcode,
membercode,
memberno,
membername,
membercategory,
classorder,
sobamount,
batchcode,
batchtype,
dateencoded,
encodedby,
effectivity,
modalfrom,
modalto,
rowmarker,
basepremium,
policydivision,
vatamount,
feecode,
additional,
madamount,
memberfeecode,
premiumclass,
paidamount
FROM adw_prod_tgt.TEMP_TBLSOAPREMIUMMEMBERS;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLSOAPREMIUMMEMBERS';
--adw_prod_tgt.sp_adw_table_logs('TBLSOAPREMIUMMEMBERS', 'SP_TEMP_MHI_TBLSOAPREMIUMMEMBERS', SYSDATE, SYSDATE, 'UPDATE');


 END SP_TEMP_MHI_TBLSOAPREMIUMMEMBERS;
 