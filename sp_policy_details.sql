CREATE OR REPLACE PROCEDURE sp_policy_details
AS lvatrate NUMBER (6, 2);
BEGIN


 -- Assign the VAT rate value to the variable
SELECT distinct
    vatrate INTO lvatrate
FROM
    tblsettingsaccounting;

/******************************************************************************

NAME:       sp_policy_details
PURPOSE:   create data for policy details

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/17/2025              Francis          1. create sp_policy_details


NOTES:

 ******************************************************************************/


  -- truncate temporary tables
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_soaaccounts';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_soapremiummembers';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_companybenefitplan';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_DS_POLICY_DETAILS';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;    



INSERT INTO temp_soaaccounts (
    soacode, compcode, contractcode, soadate, soano,
    dateenrolled, effectivity, expiry, contractno, companyname,
    companystatus, companytype, productlinecode, productline,
    locationno, locationname, rateamount, principalcount, dependentcount
)
SELECT 
    a.soacode, 
    a.compcode, 
    a.contractcode, 
    a.soadate, 
    a.soano,
    -- NVL(b.dateenrolled, TO_DATE('01-JAN-1900', 'DD-MON-YYYY')) AS dateenrolled,
    b.dateenrolled as dateenrolled,
    -- NVL(b.effectivity, TO_DATE('01-JAN-1900', 'DD-MON-YYYY')) AS effectivity,
    b.effectivity as effectivity,
    -- NVL(b.expiry, TO_DATE('01-JAN-1900', 'DD-MON-YYYY')) AS expiry,
    b.expiry AS expiry,
    NVL(b.contractno, '') AS contractno,
    NVL(decoder(b.ldflog, 0), '') AS companyname,
    NVL(c.statusname, '') AS companystatus,
    NVL(d.description, '') AS companytype,
    NVL(e.productlinecode, '') AS productlinecode,
    NVL(e.productline, '') AS productline,
    NVL(f.locationno, '') AS locationno,
    NVL(f.locationname, '') AS locationname,
    NVL(g.rateamount, 0.00) AS rateamount,
    0 AS principalcount,
    0 AS dependentcount
FROM 
    tblsoaaccounts a
    LEFT JOIN tblcompany b 
        ON a.compcode = b.compcode
    LEFT JOIN tblstatus c 
        ON b.statuscode = c.statusno AND c.statusfor = 'CORPORATE'
    LEFT JOIN tblgentables d 
        ON b.companytype = d.detno AND d.tablename = 'COMPANY TYPE'
    LEFT JOIN tblproductlines e 
        ON b.productcode = e.productcode
    LEFT JOIN tbllocations f 
        ON b.branch = f.locationcode AND f.locationtype = 'BRANCH'
    LEFT JOIN tblsettingssoatax g 
        ON b.branch = g.branchno 
           AND g.effectivitydate <= SYSDATE 
           AND g.taxcode = 'LGT'
WHERE 
    a.soacode <> 0
    AND TRUNC(a.soadate) = TRUNC(sysdate - 1) --incremental loading
    AND a.soatype <> 0;

    COMMIT;



INSERT INTO temp_soapremiummembers (
    soacode, membercode, classorder, compcode,
    membershipinstitutionno, benefitclass, agentno, gender, effectivity,
    membershipinstitutioncode, membership, institution,
    agentcode, agentname, commissionrate
)
SELECT 
    a.soacode, 
    a.membercode, 
    a.classorder, 
    a.compcode,
    NVL(b.membershipinstitutionno, 0) AS membershipinstitutionno,
    NVL(b.benefitclass, '') AS benefitclass,
    NVL(b.agentno, 0) AS agentno,
    NVL(b.gender, '') AS gender,
    -- NVL(b.effectivity, TO_DATE('01-JAN-1900', 'DD-MON-YYYY')) AS effectivity,
    b.effectivity AS effectivity,
    NVL(c.membershipinstitutioncode, '') AS membershipinstitutioncode,
    NVL(c.membership, '') AS membership,
    NVL(c.institution, '') AS institution,
    NVL(d.agentcode, '') AS agentcode,
    NVL(d.agentname, '') AS agentname,
    NVL(e.commissionrate, 0.00) AS commissionrate
FROM 
    tblsoapremiummembers a
    LEFT JOIN tblmembers b 
        ON a.membercode = b.membercode
    LEFT JOIN tblmembershipinstitutions c 
        ON b.membershipinstitutionno = c.membershipinstitutionno
    LEFT JOIN tblagents d 
        ON b.agentno = d.agentno
    LEFT JOIN tblcompanyagentcommission e 
        ON a.compcode = e.compcode 
        AND b.agentno <> 0 
        AND b.agentno = e.agentno 
        AND e.effectivity <= b.effectivity 
        AND e.active = 1
WHERE 
    a.soacode IN (SELECT soacode FROM temp_soaaccounts);

    COMMIT;


-- Update principalcount and dependentcount in temp_soaaccounts
UPDATE temp_soaaccounts a
SET a.principalcount = NVL((
        SELECT COUNT(x.membercode)
        FROM temp_soapremiummembers x
        WHERE x.soacode = a.soacode
          AND x.classorder = 0
    ), 0),
    a.dependentcount = NVL((
        SELECT COUNT(x.membercode)
        FROM temp_soapremiummembers x
        WHERE x.soacode = a.soacode
          AND x.classorder = 1
    ), 0);

    COMMIT;


INSERT INTO temp_companybenefitplan (
    compcode, contractcode, applicablegender, effectivity, classcode,
    planname, limitamount, premiumfeeamount
)
SELECT 
    a.compcode, 
    a.contractcode, 
    a.applicablegender, 
    a.effectivity, 
    a.classcode,
    a.planname, 
    a.limitamount, 
    a.premiumfeeamount
FROM 
    tblcompanybenefitplan a
WHERE 
    a.compcode IN (SELECT DISTINCT compcode FROM temp_soaaccounts)
    AND a.contractcode IN (SELECT DISTINCT contractcode FROM temp_soaaccounts)
    AND a.classcode IN (SELECT DISTINCT benefitclass FROM temp_soapremiummembers);


    COMMIT;



INSERT INTO TEMP_DS_POLICY_DETAILS (
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
    'HMS' AS source_system,
    LAST_DAY(SYSDATE) AS acctg_entry_date,
    a.soadate AS issue_date,
    -- NVL(a.dateenrolled, TO_DATE('1900-01-01', 'YYYY-MM-DD')) AS incept_date,
    a.dateenrolled AS incept_date,
    -- NVL(a.expiry, TO_DATE('1900-01-01', 'YYYY-MM-DD')) AS expiry_date,
    a.expiry AS expiry_date,
    NVL(a.effectivity, TO_DATE('1900-01-01', 'YYYY-MM-DD')) AS effectivity_date,
    NVL(a.contractno, '') AS policy_number,
    '' AS endt_number,
    NVL(b.membershipinstitutioncode, '') AS assured_no,
    NVL(b.membership, '') || ' ' || NVL(b.institution, '') || ' - ' || NVL(b.benefitclass, '') || ' - ' || NVL(a.locationno, '') AS assured_name,
    NVL(b.agentcode, '') AS intm_no,
    NVL(b.agentname, '') AS intm_name,
    NVL(b.membershipinstitutioncode, '') AS group_cd,
    NVL(b.institution, '') AS group_name,
    NVL(a.companystatus, '') AS policy_status,
    NVL(a.companytype, '') AS policy_type,
    NVL(a.locationno, '') AS iss_pref,
    '' AS org_type,
    NVL(a.companyname, '') AS company,
    NVL(a.productlinecode, '') AS line_pref,
    NVL(a.productline, '') AS line,
    NVL(c.planname, '') AS cover_type,
    '' AS referred_tag,
    'PHP' AS currency,
    NVL(a.productline, '') AS product_desc,
    'HMO' AS channel_desc,
    'HO' AS location_cd,
    'HEAD OFFICE' AS location_name,
    NVL(a.locationname, '') AS provincial_office,
    'HMS' AS platform_desc,
    NVL(c.premiumfeeamount, 0) / (1 + lvatrate + (NVL(a.rateamount, 0) / 100)) AS premium,
    NVL(c.premiumfeeamount, 0) / (1 + lvatrate + (NVL(a.rateamount, 0) / 100)) AS net_premium,
    NVL(b.commissionrate, 0) AS comm_amt,
    '' AS dst,
    NVL(c.premiumfeeamount, 0) / (1 + lvatrate + (NVL(a.rateamount, 0) / 100)) * lvatrate AS vat,
    '' AS lgt,
    '' AS prem_tax,
    '' AS fst,
    NVL(c.premiumfeeamount, 0) / (1 + lvatrate + (NVL(a.rateamount, 0) / 100)) * (NVL(a.rateamount, 0) / 100) AS other_charges,
    (NVL(c.premiumfeeamount, 0) / (1 + lvatrate + (NVL(a.rateamount, 0) / 100))) + 
    (NVL(c.premiumfeeamount, 0) / (1 + lvatrate + (NVL(a.rateamount, 0) / 100)) * lvatrate) +
    (NVL(c.premiumfeeamount, 0) / (1 + lvatrate + (NVL(a.rateamount, 0) / 100)) * (NVL(a.rateamount, 0) / 100)) AS sales,
    NVL(a.principalcount, 0) AS principal_enrollments,
    NVL(a.dependentcount, 0) AS dependent_enrollments,
    SYSDATE AS extract_date,
    a.soano AS invoice_no
FROM temp_soaaccounts a
LEFT JOIN temp_soapremiummembers b 
    ON a.soacode = b.soacode
LEFT JOIN temp_companybenefitplan c 
    ON a.compcode = c.compcode 
    AND a.contractcode = c.contractcode 
    AND b.benefitclass = c.classcode 
    AND c.effectivity <= b.effectivity 
    AND (c.applicablegender = 3 
         OR (c.applicablegender = 1 AND b.gender = 'F') 
         OR (c.applicablegender = 2 AND b.gender = 'M'));

    COMMIT;


 
  END sp_policy_details;
/
