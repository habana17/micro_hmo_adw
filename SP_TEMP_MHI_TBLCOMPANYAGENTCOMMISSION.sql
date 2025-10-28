create
or replace PROCEDURE SP_TEMP_MHI_TBLCOMPANYAGENTCOMMISSION AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLCOMPANYAGENTCOMMISSION
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLCOMPANYAGENTCOMMISSION


NOTES:

 ******************************************************************************/

--adw_prod_tgt.sp_adw_table_logs('TBLCOMPANYAGENTCOMMISSION', 'SP_TEMP_MHI_TBLCOMPANYAGENTCOMMISSION', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLCOMPANYAGENTCOMMISSION
WHERE 1=1
AND TRUNC(dateencoded) >= TRUNC(SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLCOMPANYAGENTCOMMISSION', 'SP_TEMP_MHI_TBLCOMPANYAGENTCOMMISSION', SYSDATE, '', 'INSERT');
INSERT INTO adw_prod_tgt.TBLCOMPANYAGENTCOMMISSION (
commcode,
compcode,
agentno,
commissionrate,
effectivity,
inactivedate,
statuscode,
dateencoded,
encodedby,
active,
applicationcode,
agentlevel
)
SELECT
commcode,
compcode,
agentno,
commissionrate,
effectivity,
inactivedate,
statuscode,
dateencoded,
encodedby,
active,
applicationcode,
agentlevel
FROM adw_prod_tgt.TEMP_TBLCOMPANYAGENTCOMMISSION;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLCOMPANYAGENTCOMMISSION';
--adw_prod_tgt.sp_adw_table_logs('TBLCOMPANYAGENTCOMMISSION', 'SP_TEMP_MHI_TBLCOMPANYAGENTCOMMISSION', SYSDATE, SYSDATE, 'UPDATE');

 END SP_TEMP_MHI_TBLCOMPANYAGENTCOMMISSION;
 