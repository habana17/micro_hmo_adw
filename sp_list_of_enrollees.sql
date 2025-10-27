CREATE OR REPLACE PROCEDURE sp_list_of_enrollees
AS
BEGIN


/******************************************************************************

NAME:       sp_list_of_enrollees
PURPOSE:   create data for list of enrollees per account 

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/13/2025              Francis          1. create sp_list_of_enrollees
1.1        06/17/2025              Francis          1. add list of enrollees
1.2        08/04/2025              Francis          1. Added max det no to avoid duplication of membercode


NOTES:

 ******************************************************************************/

  -- truncate temporary tables
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_listofaccounts';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_listofaccountenrollees';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_memberfees';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;   

    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_benefitlimits';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;   




    --- Insert List of Accounts ---
    INSERT INTO temp_listofaccounts (compcode, membercode)
    SELECT a.compcode, a.membercode
    FROM tblmembers a
    WHERE 1=1
    AND trunc(a.dateencoded) = trunc(sysdate -1) -- incremental load
     ;
     COMMIT;

    --- Insert MEMBER FEES ---
INSERT INTO temp_memberfees (membercode, memberfee)
    SELECT 
        membercode, 
        SUM(CASE WHEN amountprorate != 0 THEN amountprorate ELSE amount END) AS memberfee
    FROM 
        tblmemberfees
    WHERE 
        active = 1 
        AND membercode IN (
            SELECT DISTINCT membercode 
            FROM temp_listofaccounts
        )
    GROUP BY 
        membercode;

COMMIT;


--- Insert Benefit Limits ---
 INSERT INTO temp_benefitlimits (contractcode, applicablegender, effectivity, limitamount, classcode, membertype, sobplancode)
    SELECT 
        contractcode, 
        applicablegender, 
        effectivity, 
        limitamount,
        LTRIM(RTRIM(classcode)) AS classcode,
        LTRIM(RTRIM(membertype)) AS membertype,
        LTRIM(RTRIM(planname)) AS sobplancode
    FROM 
        tblcompanybenefitplan
    WHERE 
        compcode IN (
            SELECT DISTINCT compcode 
            FROM temp_listofaccounts
        )
    ORDER BY 
        sobplancode;

COMMIT;

      -- Loop through each sobplancode and attempt to drop the corresponding column
    FOR column_drp IN (
        SELECT DISTINCT LOWER(TRIM(sobplancode)) AS sobplancode 
        FROM temp_benefitlimits
        ORDER BY LOWER(TRIM(sobplancode))
    ) LOOP
        BEGIN
            -- Attempt to drop the column dynamically
            EXECUTE IMMEDIATE 'ALTER TABLE temp_listofaccountenrollees DROP COLUMN "' || UPPER(column_drp.sobplancode) || '"';
        EXCEPTION
            WHEN OTHERS THEN
                -- Skip silently if the column does not exist
                IF SQLCODE = -00904 THEN
                    NULL; -- Do nothing and proceed to the next column
                ELSE
                    RAISE; -- Re-raise other unexpected errors
                END IF;
        END;
    END LOOP;    


    -- Add columns to temp_listofaccountenrollees based on sobplancode
    FOR column_rec IN (
        SELECT DISTINCT LOWER(TRIM(sobplancode)) AS sobplancode 
          FROM temp_benefitlimits
         ORDER BY LOWER(TRIM(sobplancode))
    ) LOOP
        -- Construct the ALTER TABLE statement
        EXECUTE IMMEDIATE 'ALTER TABLE temp_listofaccountenrollees ADD "' || UPPER(column_rec.sobplancode) || '" NUMERIC(18, 2) DEFAULT 0.00 ';
    END LOOP;

-- Insert Account Enrollees
INSERT INTO temp_listofaccountenrollees (
    compcode, membercode, membershipinstitutionno, pomno, memberid, principalmemberid,
    micarememberlastname, micarefirstname, micaremembermiddleinitial, micaresuffix,
    dob, age, gender, newrenewal, effectivedate, expirydate, billingfrequency, benefitclass,
    membercategory, remittancedate, loanreleasedate, orno, datepaid, agentno, status,
    clientclass, uploadedby, billingschedule, effectivity,mem_dateencoded
)
SELECT 
    a.compcode, a.membercode, a.membershipinstitutionno, a.cardnumber,
    LTRIM(RTRIM(a.memberno)) AS memberid,
    NVL(LTRIM(RTRIM(b.memberno)), '') AS principalmemberid,
    LTRIM(RTRIM(decodercontains(a.llog, 0))) AS micarememberlastname,
    LTRIM(RTRIM(decodercontains(a.flog, 0))) AS micarefirstname,
    LTRIM(RTRIM(a.miname)) AS micaremembermiddleinitial,
    LTRIM(RTRIM(a.suffix)) AS micaresuffix,
    TO_CHAR(a.birthdate, 'MM/DD/YYYY') AS dob,
    FLOOR((SYSDATE - a.birthdate) / 365.26) AS age,
    LTRIM(RTRIM(a.gender)) AS gender,
    CASE 
        WHEN NVL(a.statuscode, 0) = 5 THEN 'T' 
        WHEN NVL(a.renewal, 0) = 1 THEN 'R' 
        WHEN NVL(a.renewal, 0) = 0 THEN 'N' 
        ELSE '' 
    END AS newrenewal,
    TO_CHAR(a.effectivity, 'MM/DD/YYYY') AS effectivedate,
    TO_CHAR(a.expiry, 'MM/DD/YYYY') AS expirydate,
    CASE a.billingschedule
        WHEN 1 THEN 'MONTHLY'
        WHEN 2 THEN 'QUARTERLY'
        WHEN 3 THEN 'SEMI-ANNUAL'
        WHEN 4 THEN 'ANNUAL'
        ELSE ''
    END AS billingfrequency,
    LTRIM(RTRIM(a.benefitclass)) AS benefitclass,
    LTRIM(RTRIM(a.membercategory)) AS membercategory,
    -- TO_CHAR(a.remittancedate, 'MM/DD/YYYY') AS remittancedate,
        CASE 
        WHEN TO_CHAR(a.remittancedate, 'MM/DD/YYYY') = '01/01/1900' THEN NULL 
        ELSE TO_CHAR(a.remittancedate, 'MM/DD/YYYY')
    END AS remittancedate, --updated 07022025
    -- TO_CHAR(a.loanreleasedate, 'MM/DD/YYYY') AS loanreleasedate,
    CASE 
        WHEN TO_CHAR(a.loanreleasedate, 'MM/DD/YYYY') = '01/01/1900' THEN NULL 
        ELSE TO_CHAR(a.loanreleasedate, 'MM/DD/YYYY')
    END AS loanreleasedate, --updated 07022025
    a.orno,
    -- TO_CHAR(a.datepaid, 'MM/DD/YYYY') AS datepaid,
    CASE 
        WHEN TO_CHAR(a.datepaid, 'MM/DD/YYYY') = '01/01/1900' THEN NULL 
        ELSE TO_CHAR(a.datepaid, 'MM/DD/YYYY')
    END AS datepaid, --updated 07022025    
    a.agentno,
    NVL(LTRIM(RTRIM(c.statusname)), '') AS status,
    CASE 
        WHEN a.classorder = 0 THEN 'PRINCIPAL' 
        ELSE NVL(TRIM(d.description), '') 
    END AS clientclass,
    NVL(LTRIM(RTRIM(e.username)), '') AS uploadedby,
    a.billingschedule,
    a.effectivity,
    a.dateencoded
FROM tblmembers a
LEFT JOIN tblmembers b ON a.principalcode = b.membercode
LEFT JOIN tblstatus c ON c.statusfor = 'MEMBER' AND a.statuscode = c.statusno
LEFT JOIN tblmembertypes d ON a.membercategory = d.membertype
LEFT JOIN tblusers e ON a.encodedby = e.userno
WHERE a.membercode IN (
    SELECT DISTINCT membercode 
    FROM temp_listofaccounts
);


UPDATE temp_listofaccountenrollees
SET micaremember = UPPER(LTRIM(RTRIM(micarememberlastname)) || ', ' || 
                         LTRIM(RTRIM(micarefirstname)) || ' ' || 
                         LTRIM(RTRIM(micaremembermiddleinitial)));

                         COMMIT;



MERGE INTO temp_listofaccountenrollees a
USING (
    SELECT a.compcode,
           a.gender,
           a.membercategory,
           a.effectivity,
           a.benefitclass,
           b.contractno,
           b.ldflog,
           b.effectivity AS company_effectivity,
           b.channel,
           b.accountcode,
           c.productlinecode,
           d.contractcode,a.membercode
      FROM temp_listofaccountenrollees a
      LEFT JOIN tblcompany b ON a.compcode = b.compcode
      LEFT JOIN tblproductlines c ON b.productcode = c.productcode
      LEFT JOIN tblcompanycontractyears d ON a.compcode = d.compcode AND b.effectivity = d.effectivity
     WHERE a.compcode <> 0
) src
ON (a.compcode = src.compcode and a.membercode = src.membercode) 
WHEN MATCHED THEN
UPDATE SET 
    a.agreementno = NVL(LTRIM(RTRIM(UPPER(src.contractno))), ''),
    a.clientname = NVL(LTRIM(RTRIM(UPPER(decoder(src.ldflog, 0)))), ''),
    a.agreementeffectivedate = TO_CHAR(NVL(src.company_effectivity, DATE '1900-01-01'), 'MM/DD/YYYY'),
    a.productchannel = NVL(LTRIM(RTRIM(src.channel)), ''),
    a.partnercode = NVL(LTRIM(RTRIM(src.accountcode)), ''),
    a.productcode = NVL(LTRIM(RTRIM(src.productlinecode)), ''),
    a.contractcode = NVL(src.contractcode, 0);


COMMIT;


MERGE INTO temp_listofaccountenrollees a
USING (
    SELECT b.membershipinstitutioncode,
           b.institution,
           a.membershipinstitutionno,
           a.compcode, a.membercode
      FROM temp_listofaccountenrollees a
      LEFT JOIN tblmembershipinstitutions b
        ON a.membershipinstitutionno = b.membershipinstitutionno
     WHERE a.compcode <> 0
) src
ON (a.membershipinstitutionno = src.membershipinstitutionno and a.compcode = src.compcode and a.membercode = src.membercode)
WHEN MATCHED THEN
UPDATE SET 
    a.institutioncode = NVL(LTRIM(RTRIM(src.membershipinstitutioncode)), ''),
    a.cardinstituded = NVL(LTRIM(RTRIM(src.institution)), '');

COMMIT;


MERGE INTO temp_listofaccountenrollees a
USING (
    SELECT a.membercode,
           a.compcode,
           NVL(LTRIM(RTRIM(b.province)), '') AS province,
           NVL(LTRIM(RTRIM(b.municipality)), '') AS municipality,
           NVL(LTRIM(RTRIM(b.barangay)), '') AS barangay,
           NVL(LTRIM(RTRIM(b.street)), '') AS street,
           NVL(LTRIM(RTRIM(b.mobile)), '') AS contactno,
           CASE 
               WHEN NVL(b.replastname, '') is not null 
               THEN NVL(UPPER(LTRIM(RTRIM(b.replastname))), '') || ', ' 
               ELSE '' 
           END || NVL(UPPER(LTRIM(RTRIM(b.repfirstname))), '') || ' ' || 
           NVL(UPPER(LTRIM(RTRIM(b.repminame))), '') AS representativeofmember,
           NVL(LTRIM(RTRIM(b.reprelationship)), '') AS relationtype,
           NVL(LTRIM(RTRIM(b.center)), '') AS center,
           CASE NVL(b.clienttype, 0)
               WHEN 1 THEN 'CARD PRINCIPAL' 
               WHEN 2 THEN 'NON-CARD PRINCIPAL'  
               WHEN 3 THEN 'NON-CARD SPOUSE'  
               WHEN 4 THEN 'NON-CARD CHILD'  
               ELSE '' 
           END AS clienttype,
           CASE NVL(b.modeofpayment, 0)
               WHEN 1 THEN 'CASH' 
               WHEN 2 THEN 'LOAN' 
               ELSE '' 
           END AS modeofpayment,
           NVL(LTRIM(RTRIM(b.returnstublink)), '') AS returnstublink,
           NVL(LTRIM(RTRIM(b.emailaddress)), '') AS emailaddress,
           NVL(LTRIM(RTRIM(b.placeofbirth)), '') AS placeofbirth,
           NVL(LTRIM(RTRIM(b.nationality)), '') AS nationality,
           NVL(LTRIM(RTRIM(c.description)), '') AS civilstatus
      FROM temp_listofaccountenrollees a
      --LEFT JOIN tblmemberdetails b ON a.membercode = b.membercode
      LEFT JOIN (
        SELECT *
        FROM tblmemberdetails b
        WHERE (b.membercode, b.detno) IN (
            SELECT membercode, MAX(detno)
            FROM tblmemberdetails
            GROUP BY membercode
        ) 
    ) b ON a.membercode = b.membercode --updated by francis 08042025 
      LEFT JOIN tblgentables c ON c.tablename = 'CIVILSTATUS' AND b.civilstatus = c.recordno
      WHERE a.membercode IS NOT NULL
) src
ON (a.membercode = src.membercode and a.compcode = src.compcode )
WHEN MATCHED THEN
UPDATE SET 
    a.province = src.province,
    a.municipality = src.municipality, 
    a.barangay = src.barangay, 
    a.street = src.street, 
    a.contactno = src.contactno,
    a.representativeofmember = src.representativeofmember,
    a.relationtype = src.relationtype, 
    a.center = src.center,
    a.clienttype = src.clienttype, 
    a.modeofpayment = src.modeofpayment, 
    a.returnstublink = src.returnstublink,
    a.emailaddress = src.emailaddress,
    a.placeofbirth = src.placeofbirth,
    a.nationality = src.nationality,
    a.civilstatus = src.civilstatus;

COMMIT;


UPDATE temp_listofaccountenrollees a
SET a.address = 
    (CASE WHEN province IS NOT NULL THEN LTRIM(RTRIM(province)) || ', ' ELSE '' END ||
     CASE WHEN municipality IS NOT NULL  THEN LTRIM(RTRIM(municipality)) || ', ' ELSE '' END ||
     CASE WHEN barangay IS NOT NULL  THEN LTRIM(RTRIM(barangay)) || ', ' ELSE '' END ||
     CASE WHEN street IS NOT NULL THEN LTRIM(RTRIM(street)) || ', ' ELSE '' END);

COMMIT;

MERGE INTO temp_listofaccountenrollees a
USING (
    SELECT 
        a.agentno,
        CASE 
            WHEN NVL(b.lastname, '') <> '' OR b.lastname is not null THEN 
                NVL(UPPER(LTRIM(RTRIM(b.lastname))), '') || ', ' 
            ELSE '' 
        END || NVL(UPPER(LTRIM(RTRIM(b.firstname))), '') || ' ' || NVL(UPPER(LTRIM(RTRIM(b.miname))), '') AS microinsurancecoordinator,
        NVL(UPPER(LTRIM(RTRIM(c.locationname))), '') AS provincialoffice, 
        NVL(LTRIM(RTRIM(d.locationname)), '') AS unit,
        a.membercode
    FROM 
        temp_listofaccountenrollees a
        LEFT JOIN (select distinct lastname,firstname,miname,agentno,branchno,subbranchno from tblagents) b ON a.agentno = b.agentno
        LEFT JOIN tbllocations c ON b.branchno = c.locationcode AND c.locationtype = 'BRANCH'
        LEFT JOIN tbllocations d ON b.subbranchno = d.locationcode AND d.locationtype = 'SUBBRANCH'
    WHERE 
        a.agentno IS NOT NULL
) src
ON (a.agentno = src.agentno and a.membercode = src.membercode)
WHEN MATCHED THEN
UPDATE SET 
    a.microinsurancecoordinator = src.microinsurancecoordinator,
    a.provincialoffice = src.provincialoffice,
    a.unit = src.unit;

COMMIT;

UPDATE temp_listofaccountenrollees a
SET a.commissionamount = NVL(
    (SELECT commissionrate
     FROM (SELECT commissionrate 
           FROM tblcompanyagentcommission x
           WHERE x.compcode = a.compcode
           ORDER BY x.agentlevel DESC) 
     WHERE ROWNUM = 1), 
    0.00)
WHERE a.compcode <> 0;

COMMIT;


MERGE INTO temp_listofaccountenrollees a
USING (
    SELECT 
        a.membercode,
        a.compcode,
        NVL(b.memberfee, 0) AS membershipfee,
        CASE a.billingschedule
            WHEN 1 THEN NVL(b.memberfee, 0) * NVL(c.monthly, 0)
            WHEN 2 THEN NVL(b.memberfee, 0) * NVL(c.quarterly, 0)
            WHEN 3 THEN NVL(b.memberfee, 0) * NVL(c.semiannual, 0)
            WHEN 4 THEN NVL(b.memberfee, 0) * NVL(c.annual, 0)
            ELSE NVL(b.memberfee, 0)
        END AS modalmembershipfee
    FROM 
        temp_listofaccountenrollees a
        LEFT JOIN temp_memberfees b ON a.membercode = b.membercode
        LEFT JOIN tblcompanymodalfactor c 
            ON a.compcode = c.compcode AND c.effectivity <= a.effectivity
) src
ON (a.membercode = src.membercode and a.compcode = src.compcode)
WHEN MATCHED THEN
UPDATE SET 
    a.membershipfee = src.membershipfee,
    a.modalmembershipfee = src.modalmembershipfee;

COMMIT;

--- Update Columns ---
FOR column_rec IN (
        SELECT DISTINCT LOWER(TRIM(sobplancode)) AS sobplancode 
          FROM temp_benefitlimits
         ORDER BY LOWER(TRIM(sobplancode))
    ) LOOP
        EXECUTE IMMEDIATE '
MERGE INTO temp_listofaccountenrollees a
USING (
    SELECT 
        a.contractcode,a.gender,a.membercategory,a.effectivity,
        a.benefitclass,b.limitamount,b.sobplancode,a.compcode,
        a.membercode
    FROM 
        temp_listofaccountenrollees a
        LEFT JOIN temp_benefitlimits b
          ON b.sobplancode = ''' || UPPER(column_rec.sobplancode) || '''
          AND b.contractcode = a.contractcode
          AND (b.applicablegender = 3 OR 
               (b.applicablegender = 1 AND a.gender = ''F'') OR
               (b.applicablegender = 2 AND a.gender = ''M''))
          AND b.membertype LIKE ''%'' || a.membercategory || ''%''
          AND b.effectivity <= a.effectivity
          AND b.classcode = a.benefitclass
    WHERE b.limitamount IS NOT NULL AND b.limitamount <> 0.00
) src
ON (a.contractcode = src.contractcode
    AND a.gender = src.gender
    AND a.membercategory = src.membercategory
    AND a.effectivity = src.effectivity
    AND a.benefitclass = src.benefitclass
    AND a.compcode = src.compcode
    AND a.membercode = src.membercode)
WHEN MATCHED THEN
UPDATE SET 
    "' || UPPER(column_rec.sobplancode) || '" = NVL(src.limitamount, 0.00)
        ';
    END LOOP;

        COMMIT;


--- INSERT Columns TO EXTRACT TABLE ---
FOR column_rec IN (
        SELECT DISTINCT LOWER(TRIM(sobplancode)) AS sobplancode 
          FROM temp_benefitlimits
         ORDER BY LOWER(TRIM(sobplancode))
    ) LOOP
        EXECUTE IMMEDIATE '
     INSERT INTO DS_LIST_OF_ENROLLEES (
    agreementno, clientname, agreementeffectivedate, productchannel, productcode,
    partnercode, institutioncode, pomno, memberid, principalmemberid, micaremember,
    micarememberlastname, micarefirstname, micaremembermiddleinitial, micaresuffix, 
    ADDRESS, PROVINCE, MUNICIPALITY, BARANGAY, STREET, DOB, AGE, civilstatus, GENDER, 
    STATUS, contactno, effectivedate, expirydate, representativeofmember, relationtype, 
    membershipfee, modalmembershipfee, billingfrequency, microinsurancecoordinator, 
    provincialoffice, UNIT, CENTER, clienttype, clientclass, modeofpayment, remittancedate, 
    loanreleasedate, CARDINSTITUTION, orno, datepaid, commissionamount, returnstublink, 
    emailaddress, placeofbirth, NATIONALITY, uploadedby, benefit_type, BENEFIT_VALUE,mem_dateencoded
     )
      SELECT 
    UPPER(agreementno), UPPER(clientname), agreementeffectivedate, UPPER(productchannel), UPPER(productcode),
    UPPER(partnercode), UPPER(institutioncode), UPPER(pomno), memberid, principalmemberid, UPPER(micaremember),
    UPPER(micarememberlastname), UPPER(micarefirstname), UPPER(micaremembermiddleinitial), UPPER(micaresuffix), 
    UPPER(ADDRESS), UPPER(PROVINCE), UPPER(MUNICIPALITY), UPPER(BARANGAY), UPPER(STREET), DOB, AGE, UPPER(civilstatus), GENDER, 
    UPPER(STATUS), contactno, effectivedate, expirydate, UPPER(representativeofmember), UPPER(relationtype), 
    membershipfee, modalmembershipfee, UPPER(billingfrequency), UPPER(microinsurancecoordinator), 
    UPPER(provincialoffice), UPPER(UNIT), UPPER(CENTER), UPPER(clienttype), UPPER(clientclass), UPPER(modeofpayment), remittancedate, 
    loanreleasedate, UPPER(cardinstituded), orno, datepaid, commissionamount, UPPER(returnstublink), 
    UPPER(emailaddress),UPPER(placeofbirth),UPPER(NATIONALITY),UPPER(uploadedby),UPPER(column_name) AS benefit_type,value,mem_dateencoded
FROM temp_listofaccountenrollees
UNPIVOT (
    value FOR column_name IN (
        "' || UPPER(column_rec.sobplancode) || '"  AS ''' || UPPER(column_rec.sobplancode) || '''
    )
) 
        ';
    END LOOP;

        COMMIT;


 END sp_list_of_enrollees;
/
