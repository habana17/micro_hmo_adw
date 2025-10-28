create
or replace PROCEDURE SP_REPORT_MHI_DSBENEFICIARYDETAILS AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_DSBENEFICIARYDETAILS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_DSBENEFICIARYDETAILS


NOTES:

 ******************************************************************************/

-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_BENEFICIARY_DETAILS', 'SP_REPORT_MHI_DSBENEFICIARYDETAILS', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_BENEFICIARY_DETAILS
WHERE
    1 = 1
    AND TRUNC(dateencoded) >= TRUNC(sysdate)
    ;
COMMIT;
-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_BENEFICIARY_DETAILS', 'SP_REPORT_MHI_DSBENEFICIARYDETAILS', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
    adw_prod_tgt.DS_BENEFICIARY_DETAILS (
    policyholder, -- Policy Holder Name
    full_name , -- Beneficiary Full Name
    first_name , -- Beneficiary First Name
    middle_name, -- Beneficiary Middle Name
    last_name , -- Beneficiary Last Name
    general_name , -- Beneficiary General Name (Suffix, if any)
    birthplace , -- Beneficiary Birthplace
    place_of_birth , -- Beneficiary Place of Birth
    gender , -- Beneficiary Gender (e.g., Male/Female)
    civil_status, -- Beneficiary Civil Status
    ben_with_policyholder,  --relationship with the policy holder
    dateencoded
    )
SELECT 
    LTRIM(RTRIM(UPPER(NVL(b.membername, '')))) AS policyholder,
    LTRIM(RTRIM(UPPER(a.membername))) AS dependentfullname,
    LTRIM(RTRIM(UPPER(a.firstname))) AS dependentfirstname,
    LTRIM(RTRIM(UPPER(a.miname))) AS dependentminame,
    LTRIM(RTRIM(UPPER(a.lastname))) AS dependentlastname,
    LTRIM(RTRIM(UPPER(a.suffix))) AS dependentgeneralname,
    LTRIM(RTRIM(UPPER(NVL(c.birthplace, '')))) AS dependentbirthplace,
    TRUNC(a.birthdate) AS dependentbirthday,
    LTRIM(RTRIM(
        CASE 
            WHEN a.gender = 'M' THEN 'MALE' 
            WHEN a.gender = 'F' THEN 'FEMALE' 
            ELSE '' 
        END
    )) AS dependentgender,
    LTRIM(RTRIM(NVL(d.description, ''))) AS dependentcivilstatus,
    LTRIM(RTRIM(UPPER(a.relation))) AS dependentrelationship,
    a.dateencoded
FROM adw_prod_tgt.tblmembers a
LEFT JOIN adw_prod_tgt.tblmembers b ON a.principalcode = b.membercode
LEFT JOIN adw_prod_tgt.tblmemberdetails c ON a.membercode = c.membercode
LEFT JOIN adw_prod_tgt.tblgentables d 
    ON a.civilstatus = d.recordno 
    AND d.tablename = 'CIVILSTATUS'
WHERE NVL(b.membercode, 0) <> 0
  AND a.classorder = 1
  AND TRUNC(a.dateencoded) = TRUNC(sysdate - 1)-- incremental
  ;



COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_BENEFICIARY_DETAILS', 'SP_REPORT_MHI_DSBENEFICIARYDETAILS', SYSDATE, SYSDATE, 'UPDATE');

  END SP_REPORT_MHI_DSBENEFICIARYDETAILS;
 