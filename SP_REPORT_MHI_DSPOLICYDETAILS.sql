CREATE OR REPLACE PROCEDURE SP_REPORT_MHI_DSPOLICYDETAILS
AS
BEGIN


/******************************************************************************

NAME:       SP_REPORT_MHI_DSPOLICYDETAILS
PURPOSE:   create data for list of enrollees per account 

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/18/2025              Francis          1. create SP_REPORT_MHI_DSPOLICYDETAILS


NOTES:

 ******************************************************************************/


-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_POLICY_DETAILS', 'SP_REPORT_MHI_DSPOLICYDETAILS', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_POLICY_DETAILS
WHERE
1 = 1
AND TRUNC (issue_date) >= TRUNC (SYSDATE);
COMMIT;


sp_policy_details;  -- execute procedure 


--Logging the INSERT operation 
--adw_prod_tgt.sp_adw_table_logs('DS_POLICY_DETAILS', 'SP_REPORT_MHI_DSPOLICYDETAILS', SYSDATE, '', 'INSERT');
--Insert new data into the target table

INSERT INTO DS_POLICY_DETAILS (
    source_system,
    acctg_entry_date,
    issue_date,
    incept_date,
    expiry_date,
    effectivity_date,
    policy_number,
    endt_number,
    assured_no,
    assured_name,
    intm_no,
    intm_name,
    group_cd,
    group_name,
    policy_status,
    policy_type,
    iss_pref,
    org_type,
    company,
    line_pref,
    line,
    cover_type,
    referred_tag,
    currency,
    product_desc,
    channel_desc,
    location_cd,
    location_name,
    provincial_office,
    platform_desc,
    premium,
    net_premium,
    comm_amt,
    dst,
    vat,
    lgt,
    prem_tax,
    fst,
    other_charges,
    sales,
    principal_enrollments,
    dependent_enrollments,
    extract_date,
    invoice_no
)
    SELECT 
    source_system,
    acctg_entry_date,
    issue_date,
    incept_date,
    expiry_date,
    effectivity_date,
    policy_number,
    endt_number,
    assured_no,
    assured_name,
    intm_no,
    intm_name,
    group_cd,
    group_name,
    policy_status,
    policy_type,
    iss_pref,
    org_type,
    company,
    line_pref,
    line,
    cover_type,
    referred_tag,
    currency,
    product_desc,
    channel_desc,
    location_cd,
    location_name,
    provincial_office,
    platform_desc,
    premium,
    net_premium,
    comm_amt,
    dst,
    vat,
    lgt,
    prem_tax,
    fst,
    other_charges,
    sales,
    principal_enrollments,
    dependent_enrollments,
    extract_date,
    invoice_no
    FROM 
    TEMP_DS_POLICY_DETAILS;

    COMMIT;

-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_POLICY_DETAILS', 'SP_REPORT_MHI_DSPOLICYDETAILS', SYSDATE, SYSDATE, 'UPDATE');


  END SP_REPORT_MHI_DSPOLICYDETAILS;
/