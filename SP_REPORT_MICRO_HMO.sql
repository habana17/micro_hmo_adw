CREATE
OR REPLACE PROCEDURE SP_REPORT_MICRO_HMO AS 

/******************************************************************************

NAME:       SP_REPORT_MICRO_HMO
PURPOSE:    Insert data for extraction

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/14/2025       Francis          1. Create SP_REPORT_MICRO_HMO
1.1        05/14/2025       Francis          1. added the ds_cash_disbursement_reg table extraction  
1.2        05/14/2025       Francis          1. added the ds_journal_voucher table extraction
1.3        05/16/2025       Francis          1. added the ds_claim_list_report,ds_cash_receipts_register
1.4        05/16/2025       Francis          1. change columnname in ds_claim_list_report (gender to sex, memberstatus to status ,providertype to provider , staffbranch to branch_prov_office ,hospdatetp to hospdateto)   
1.5        05/16/2025       Francis          1. change columnname in DS_CASH_RECEIPTS_REGISTER (STATUSNAME to OR_STATUS)
1.6        05/19/2025       Francis          1. add ds_accounts_payable_register
1.7        05/19/2025       Francis          1. add ds_premium_register 
1.8        05/19/2025       Francis          1. update ds_claim_list_report  
1.9        05/21/2025       Francis          1. ADD DS_LIST_OF_CORPORATE_BILLINGS
2.0        05/21/2025       Francis          1. updated the ds_aging_report
2.1        05/21/2025       Francis          1. add ds_list_util_month
2.2        05/26/2025       Francis          1. add contact_number,datetonoticetopartner,datetonoticetopioneer
2.2        05/27/2025       Francis          1. added ds_claim_list_report_hist
2.3        05/27/2025       Francis          1. added ds_production_report & ds_renewal_list
2.3        05/28/2025       Francis          1. add ds_renewal_list_hist
2.4        05/29/2025       Francis          1. add ds_summary_util_report
2.5        06/17/2025       Francis          1. add ds_list_of_enrollees
2.6        06/18/2025       Francis          1. add ds_policy_details
2.7        06/24/2025       Francis          1. add error handling

NOTES:

 ******************************************************************************/
BEGIN

---------------------------------------------------1--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSCASHDISBURSEMENTREG;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSCASHDISBURSEMENTREG', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------2--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSJOURNALVOUCHER;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSJOURNALVOUCHER', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------3--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSCLAIMLISTREPORT;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSCLAIMLISTREPORT', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------4--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSCASHRECEIPTSREGISTER;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSCASHRECEIPTSREGISTER', err_msg,'Micro HMO Integration'); 
            COMMIT;
        END;    
    END;
---------------------------------------------------5--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_ACCOUNTSPAYABLEREGISTER;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_ACCOUNTSPAYABLEREGISTER', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;

---------------------------------------------------6--------------------------------------------------------
 --still monitoring if gonna last_update_date or invoice_date
    BEGIN
        SP_REPORT_MHI_DSPREMIUMREGISTER;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSPREMIUMREGISTER', err_msg,'Micro HMO Integration');
        END;    
    END;
---------------------------------------------------7--------------------------------------------------------
-- still monitoring if gonna use last_update_date or soadate
    BEGIN
        SP_REPORT_MHI_DSAGINGREPORT;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSAGINGREPORT', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------8--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_LISTOFCORPORATEBILLINGS;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_LISTOFCORPORATEBILLINGS', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------9--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSLISTUTILMONTH;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSLISTUTILMONTH', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------10--------------------------------------------------------
 --need to monitor if it will add the previous remittance date 
    BEGIN
        SP_REPORT_MHI_DSPRODUCTIONREPORT;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSPRODUCTIONREPORT', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------11--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSRENEWALLIST;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSRENEWALLIST', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------12--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSSUMMARYUTILREPORT;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSSUMMARYUTILREPORT', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------13--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSTOPDIAGNOSIS;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSTOPDIAGNOSIS', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------14--------------------------------------------------------
--still monitoring
    BEGIN
        SP_REPORT_MHI_DSBENEFICIARYDETAILS;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSBENEFICIARYDETAILS', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------15--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSCUSTOMERDETAILS;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSCUSTOMERDETAILS', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------16--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSLISTOFENROLLEES;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSLISTOFENROLLEES', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;
---------------------------------------------------17--------------------------------------------------------
    BEGIN
        SP_REPORT_MHI_DSPOLICYDETAILS;
    EXCEPTION
            WHEN OTHERS THEN
        DECLARE
            err_msg VARCHAR2(4000);
        BEGIN
            err_msg := SQLERRM;
            INSERT INTO process_error_log (procedure_name, error_message,remarks)
            VALUES ('SP_REPORT_MHI_DSPOLICYDETAILS', err_msg,'Micro HMO Integration');
            COMMIT;
        END;    
    END;

END SP_REPORT_MICRO_HMO;