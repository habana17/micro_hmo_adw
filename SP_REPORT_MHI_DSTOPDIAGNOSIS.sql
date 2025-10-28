create
or replace PROCEDURE SP_REPORT_MHI_DSTOPDIAGNOSIS AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_DSTOPDIAGNOSIS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/30/2025       Francis          1. Create SP_REPORT_MHI_DSTOPDIAGNOSIS


NOTES:

 ******************************************************************************/


-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_TOP_DIAGNOSIS', 'SP_REPORT_MHI_DSTOPDIAGNOSIS', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_TOP_DIAGNOSIS
WHERE 1 = 1;
COMMIT;

  sp_top_diagnosis; --execute procedure insert data to temp 

-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_TOP_DIAGNOSIS', 'SP_REPORT_MICSP_REPORT_MHI_DSTOPDIAGNOSISRO_HMO', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
    INSERT INTO adw_prod_tgt.DS_TOP_DIAGNOSIS (
        no,icdcode,diagnosis,no_of_cases,totalamount,averageclaim
    )
    SELECT 
        no,icdcode,diagnosis,no_of_cases,totalamount,averageclaim
    FROM adw_prod_tgt.temp_ds_top_diagnosis
    ;

COMMIT;

-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_TOP_DIAGNOSIS', 'SP_REPORT_MHI_DSTOPDIAGNOSIS', SYSDATE, SYSDATE, 'UPDATE');

  END SP_REPORT_MHI_DSTOPDIAGNOSIS;
 