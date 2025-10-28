create
or replace PROCEDURE SP_REPORT_MHI_DSLISTUTILMONTH AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_DSLISTUTILMONTH
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_DSLISTUTILMONTH


NOTES:

 ******************************************************************************/

-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_LIST_UTIL_MONTH', 'SP_REPORT_MHI_DSLISTUTILMONTH', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_LIST_UTIL_MONTH
WHERE
    1 = 1
   AND TO_CHAR (TO_DATE (month, 'MONTH YYYY'), 'YYYY') = TO_CHAR (SYSDATE - 1, 'YYYY')
   ;
COMMIT;
-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_LIST_UTIL_MONTH', 'SP_REPORT_MHI_DSLISTUTILMONTH', SYSDATE, '', 'INSERT');
--execute procedure , insert data to TEMP_DS_LIST_UTIL_MONTH
sp_util_per_month;
-- Insert new data into the target table
INSERT INTO
    adw_prod_tgt.DS_LIST_UTIL_MONTH (
        month,
        ipcases,
        ipamount,
        opcases,
        opamount,
        reimcases,
        reimamount,
        apecases,
        apeamount,
        totalutil
    )
select
    month,
    ipcases,
    ipamount,
    opcases,
    opamount,
    reimcases,
    reimamount,
    apecases,
    apeamount,
    totalutil
from
    TEMP_DS_LIST_UTIL_MONTH;
COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_LIST_UTIL_MONTH', 'SP_REPORT_MHI_DSLISTUTILMONTH', SYSDATE, SYSDATE, 'UPDATE');

  END SP_REPORT_MHI_DSLISTUTILMONTH;
 