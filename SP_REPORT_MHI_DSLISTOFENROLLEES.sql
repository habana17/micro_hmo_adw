create
or replace PROCEDURE SP_REPORT_MHI_DSLISTOFENROLLEES AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_DSLISTOFENROLLEES
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/16/2025       Francis          1. Create SP_REPORT_MHI_DSLISTOFENROLLEES


NOTES:

******************************************************************************/

 


-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_LIST_OF_ENROLLEES', 'SP_REPORT_MHI_DSLISTOFENROLLEES', SYSDATE, '', 'INSERT');

sp_list_of_enrollees; --execute procedure insert data to target table

--adw_prod_tgt.sp_adw_table_logs('DS_LIST_OF_ENROLLEES', 'SP_REPORT_MHI_DSLISTOFENROLLEES', SYSDATE, SYSDATE, 'UPDATE');

 END SP_REPORT_MHI_DSLISTOFENROLLEES;