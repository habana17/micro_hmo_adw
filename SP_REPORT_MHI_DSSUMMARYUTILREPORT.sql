create
or replace PROCEDURE SP_REPORT_MHI_DSSUMMARYUTILREPORT AS 

/******************************************************************************

NAME:       SP_REPORT_MHI_DSSUMMARYUTILREPORT
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/29/2025             Francis          1. Create SP_REPORT_MHI_DSSUMMARYUTILREPORT
2.0        06/05/2025             Francis          2. Modified typeofaffiliatedhcd
2.0        06/24/2025             Francis          1. change default 1900-01-01 to NULL

NOTES:

 ******************************************************************************/


CURSOR c_summary_data  IS
SELECT DISTINCT
    a.membername AS micaremember,
    TRIM(b.cardnumber) AS pomno,
    TRIM(a.memberno) AS memberid,
    NVL (TRIM(f.loano), '') AS loano,
    TRIM(NVL (c.province, '')) || CASE
        WHEN TRIM(NVL (c.province, '')) IS NOT NULL THEN ', '
        ELSE ''
    END || TRIM(NVL (c.municipality, '')) || CASE
        WHEN TRIM(NVL (c.municipality, '')) IS NOT NULL THEN ', '
        ELSE ''
    END || TRIM(NVL (c.barangay, '')) || CASE
        WHEN TRIM(NVL (c.barangay, '')) IS NOT NULL THEN ', '
        ELSE ''
    END || TRIM(NVL (c.street, '')) AS address, --check 
    TRUNC (a.birthdate) AS birthdate,
    TRUNC ((TRUNC (SYSDATE) - TRUNC (a.birthdate)) / 365.26) as age,
    TRIM(a.gender) AS gender,
    NVL (TRIM(m.description), '') AS civilstatus,
    CASE
        WHEN c.clienttype = 1 THEN 'CARD PRINCIPAL'
        WHEN c.clienttype = 2 THEN 'NON-CARD PRINCIPAL'
        WHEN c.clienttype = 3 THEN 'NON-CARD SPOUSE'
        WHEN c.clienttype = 4 THEN 'NON-CARD CHILD'
        ELSE ''
    END AS clienttype,
    -- NVL (
    --     TRUNC (a.coveredfrom),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS effectivity,
    TRUNC (a.coveredfrom) as effectivity, --updated 06242025
    -- NVL (
    --     TRUNC (a.coveredto),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS expiry,
    TRUNC (a.coveredto) as expiry, --updated 06242025
    -- NVL (
    --     TRUNC (q.effectivity),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS agreementeffdate,
    TRUNC (q.effectivity) as agreementeffdate, --updated 06242025

    CASE
        WHEN (
            CASE
                WHEN NVL (b.statuscode, 0) = 5 THEN 'T'
                WHEN NVL (b.renewal, 0) = 1 THEN 'R'
                WHEN NVL (b.renewal, 0) = 0 THEN 'N'
                ELSE ''
            END
        ) = 'N' THEN 'NEW'
        ELSE 'RENEWAL'
    END AS newrenew,
    CASE
        WHEN e.providertype = 1 THEN 'HOSPITAL'
        WHEN e.providertype = 2 THEN 'CLINIC'
        WHEN e.providertype = 3 THEN 'BILLING COMPANY'
        WHEN e.providertype = 4 THEN 'DENTAL CLINIC'
        ELSE ''
    END AS providertype,
    NVL (TRIM(e.providername), '') AS providername,
    -- NVL (
    --     TRUNC (e.dateaccredited),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS dateaffiliated,
    CASE
    WHEN TRUNC(e.dateaccredited) = TO_DATE('1900-01-01', 'YYYY-MM-DD') THEN NULL
    ELSE TRUNC(e.dateaccredited)
    END AS dateaffiliated, --updated 06242025
    NVL (TRIM(f.doctorname), '') AS doctorname,
    NVL (TO_CHAR (g.specialization), '') AS doctorspecialization,
    CASE
        WHEN f.doctorcode IS NULL
        OR f.doctorcode = 0 THEN NULL--TO_DATE ('1900-01-01', 'YYYY-MM-DD') -updated 06242025
        ELSE TRUNC (e.dateaccredited)
    END AS dateaffiliateddoc,
    case when nvl(e.providersector,0) = 1 then 'PRIVATE' 
    WHEN nvl(e.providersector,0) = 2 then 'PUBLIC'
    else '' end 
     AS typeofaffiliatedhcd, --edited by francis 06052025
    NVL (LTRIM (RTRIM (n.description)), '') AS level1,
    NVL (LTRIM (RTRIM (j.locationname)), '') AS provincialoffice,
    NVL (LTRIM (RTRIM (r.productline)), '') AS product,
    -- TRUNC (a.dateavailed) AS dateavailed,
    CASE 
        WHEN TRUNC(a.dateavailed) = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE TRUNC(a.dateavailed)
    END AS dateavailed, --updated 07022025
    -- TRUNC (a.dateavailed) AS reportdate,
    CASE 
        WHEN TRUNC(a.claimreceived) = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE TRUNC(a.claimreceived)
    END AS reportdate, --updated 07022025
    -- TRUNC (a.datedischarged) AS datedischarged,
    CASE 
        WHEN TRUNC(a.datedischarged) = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE TRUNC(a.datedischarged)
    END AS datedischarged, --updated 07022025
    NVL (LTRIM (RTRIM (k.description)), '') AS claimservice,
    NVL (LTRIM (RTRIM (l.description)), '') AS subclaimservice,
    NVL (p.limitamount, 0.00) AS benefitlimit,
    CASE
        WHEN a.casetype = 0 THEN NVL (
            CASE
                WHEN a.casetype = 1 THEN a.reamount
                ELSE a.provideramount + a.reamount
            END,
            0.00
        ) + a.roomamount
        ELSE 0.00
    END - CASE
        WHEN a.casetype = 1 THEN 0.00
        ELSE a.phamount + a.discount + a.npamount + a.adjamount
    END - (
        NVL (
            CASE
                WHEN a.casetype <> 1 THEN a.hbadjapproved
                ELSE 0
            END,
            0.00
        ) + NVL (
            CASE
                WHEN a.casetype <> 1 THEN a.hbadjdisapproved
                ELSE 0
            END,
            0.00
        )
    ) as hospitalbill,
    a.phamount AS phamount,
    a.eobamount AS excessexpenses,
    CASE
        WHEN a.casetype = 0 THEN a.pfamount
        ELSE 0.00
    END - (
        a.pfdiscount + a.nppfamount + a.phpfamount + a.adjamountpf
    ) - (
        NVL (a.pfadjapproved, 0.00) + NVL (a.pfadjdisapproved, 0.00)
    ) as professionalfee,
    CASE
        WHEN a.casetype = 0 THEN 0.00
        ELSE a.finalreamount - (
            NVL (
                CASE
                    WHEN a.casetype = 1 THEN a.hbadjapproved
                    ELSE 0
                END,
                0.00
            ) + NVL (
                CASE
                    WHEN a.casetype = 1 THEN a.hbadjdisapproved
                    ELSE 0
                END,
                0.00
            )
        )
    END as reimbursementamount,
    (a.basicclaim + a.majorclaim + a.spilloverclaim) AS utilized,
    (
        NVL (oo.creditedamount, 0.00) - (a.basicclaim + a.majorclaim + a.spilloverclaim)
    ) AS remainingbalance,
    UPPER(
        NVL (
            (
                SELECT
                    LISTAGG (
                        LTRIM (RTRIM (x.icdcode)) || ' - ' || LTRIM (RTRIM (x.icddisease)),
                        ', '
                    ) WITHIN GROUP (
                        ORDER BY
                            x.icdcode
                    )
                FROM
                    tblclaimdiagnosis zz
                    LEFT JOIN tblicdtable x ON zz.icdno = x.icdno
                    AND zz.icdno <> 0
                WHERE
                    zz.claimcode = a.claimcode
                    AND zz.icdno <> 0
                    AND zz.diagnosistype = 2
            ),
            ''
        )
    ) AS availmentcause,
    CASE
        WHEN a.casetype = 0 THEN 'NETWORK CLAIM'
        WHEN a.casetype = 1 THEN 'OUT OF NETWORK CLAIM'
        ELSE ''
    END AS claimtype,
    NVL (
        (
            SELECT
                LISTAGG (
                    DISTINCT NVL (LTRIM (RTRIM (x.icdcode)), zz.admittingtext),
                    ', '
                ) WITHIN GROUP (
                    ORDER BY
                        NVL (LTRIM (RTRIM (x.icdcode)), zz.admittingtext)
                )
            FROM
                adw_prod_tgt.tblclaimdiagnosis zz
                LEFT JOIN tblicdtable x ON zz.icdno = x.icdno
                AND zz.icdno <> 0
            WHERE
                zz.claimcode = a.claimcode
                AND zz.icdno <> 0
                AND zz.claimcode <> 0
        ),
        NULL
    ) AS icdcode,
    UPPER(
        NVL (
            (
                SELECT
                    LISTAGG (
                        DISTINCT NVL (LTRIM (RTRIM (x.icddisease)), zz.admittingtext),
                        ', '
                    ) WITHIN GROUP (
                        ORDER BY
                            NVL (LTRIM (RTRIM (x.icddisease)), zz.admittingtext)
                    )
                FROM
                    adw_prod_tgt.tblclaimdiagnosis zz
                    LEFT JOIN tblicdtable x ON zz.icdno = x.icdno
                    AND zz.icdno <> 0
                WHERE
                    zz.claimcode = a.claimcode
                    AND zz.icdno <> 0
                    AND zz.claimcode <> 0
            ),
            NULL
        )
    ) AS icddisease,
    NVL (TRIM(o.paytype), '') as payeetype,
    NVL (TRIM(o.checkno), '') as paychan,

    -- NVL (
    --     TRUNC (o.checkdate),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) as datepaid,

    CASE
    WHEN TRUNC(o.checkdate) = TO_DATE('1900-01-01', 'YYYY-MM-DD') THEN NULL
    ELSE TRUNC(o.checkdate)
    END AS datepaid, --update by francis 06242025

    a.caseno,
    a.dateposted
FROM
    adw_prod_tgt.tblclaims a
    LEFT JOIN adw_prod_tgt.tblmembers b ON a.membercode = b.membercode
    LEFT JOIN adw_prod_tgt.tblmemberdetails c ON a.membercode = c.membercode
    LEFT JOIN adw_prod_tgt.tblproviders e ON a.providercode = e.providercode
    LEFT JOIN adw_prod_tgt.tblloas f ON a.loano = f.loano
    LEFT JOIN adw_prod_tgt.tbldoctorspecialization g ON f.doctorcode = g.doctorcode
    and f.doctorcode <> 0
    LEFT JOIN adw_prod_tgt.tblgentables h ON h.tablename = 'PROVIDER LEVEL'
    and e.providerlevel = h.detno
    LEFT JOIN adw_prod_tgt.tblagents i ON b.agentno = i.agentno
    LEFT JOIN adw_prod_tgt.tbllocations j ON i.branchno = j.locationcode
    AND j.locationtype = 'BRANCH'
    LEFT JOIN adw_prod_tgt.tblgentables k ON a.claimtype = k.detno
    AND k.tablename = 'CLAIMS SERVICES'
    LEFT JOIN adw_prod_tgt.tblgentables l ON a.subclaimtype = l.detno
    AND l.tablename = 'SUB CLAIM TYPE'
    LEFT JOIN adw_prod_tgt.tblgentables m ON c.civilstatus = m.recordno
    AND m.tablename = 'CIVILSTATUS'
    LEFT JOIN adw_prod_tgt.tblgentables n ON e.providerlevel = n.detno
    AND n.tablename = 'PROVIDER LEVEL'
    LEFT JOIN adw_prod_tgt.tblacctentriescv o ON a.dvno = o.dvno
    LEFT JOIN adw_prod_tgt.tblclaimdiagnosis oo ON a.claimcode = oo.claimcode
    and oo.diagnosistype = 2
    LEFt JOIN adw_prod_tgt.tblcompanybenefitplan p ON oo.plancode = p.plancode
    LEFT JOIN adw_prod_tgt.tblcompany q ON a.compcode = q.compcode
    LEFT JOIN adw_prod_tgt.tblproductlines r ON q.productcode = r.productcode
WHERE 1=1
    AND (
        a.caseno IS NOT NULL
        or a.caseno = ''
    )
    AND (TRUNC(a.dateencoded) = TRUNC(sysdate - 1) OR  TRUNC(a.dateposted) = TRUNC(sysdate - 1)) --incremental load 
ORDER BY
    dateavailed;



v_summary_data c_summary_data%ROWTYPE;


TYPE caseno_table_type IS TABLE OF adw_prod_tgt.DS_SUMMARY_UTIL_REPORT.caseno%TYPE;
caseno_table caseno_table_type;


BEGIN

 
-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_SUMMARY_UTIL_REPORT', 'SP_REPORT_MHI_DSSUMMARYUTILREPORT', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_SUMMARY_UTIL_REPORT
WHERE
    1 = 1
    AND TRUNC(last_update_date) >= TRUNC(sysdate) 
    ;

COMMIT;

-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_SUMMARY_UTIL_REPORT', 'SP_REPORT_MHI_DSSUMMARYUTILREPORT', SYSDATE, '', 'INSERT');
-- Insert new data into the target table

OPEN c_summary_data;

LOOP 
    FETCH c_summary_data INTO v_summary_data;
    EXIT WHEN c_summary_data%NOTFOUND; 

INSERT INTO
    adw_prod_tgt.DS_SUMMARY_UTIL_REPORT (
        micaremember,
        pomno,
        memberid,
        loano,
        address,
        dob,
        age,
        gender,
        civil_status,
        client_type,
        effective_date,
        expiry_date,
        agreement_eff_date,
        new_renew,
        provider_type,
        hospital_clinic_name,
        date_affiliated,
        doctor,
        doc_specialization,
        date_affiliated_doc,
        type_of_affiliated_hcds,
        level1,
        provincial_office,
        product,
        date_of_availment,
        report_date,
        discharge_date,
        claim_service,
        subclaim_service,
        benefit_limit,
        hospital_bill,
        philhealth,
        excess_abl_mbl,
        professional_fee,
        reimbursement_amount,
        utilized,
        remaining_balance,
        availment_cause,
        claim_type,
        icd_code,
        icd_code_description,
        payee_type,
        pay_chan,
        date_paid,
        caseno,
        last_update_date
    ) VALUES (
UPPER(v_summary_data.micaremember),
v_summary_data.pomno,
v_summary_data.memberid,
v_summary_data.loano,
UPPER(v_summary_data.address),
v_summary_data.birthdate,
v_summary_data.age,
UPPER(v_summary_data.gender),
UPPER(v_summary_data.civilstatus),
UPPER(v_summary_data.clienttype),
v_summary_data.effectivity,
v_summary_data.expiry,
v_summary_data.agreementeffdate,
UPPER(v_summary_data.newrenew),
UPPER(v_summary_data.providertype),
UPPER(v_summary_data.providername),
v_summary_data.dateaffiliated,
UPPER(v_summary_data.doctorname),
UPPER(v_summary_data.doctorspecialization),
v_summary_data.dateaffiliateddoc,
UPPER(v_summary_data.typeofaffiliatedhcd),
UPPER(v_summary_data.level1),
UPPER(v_summary_data.provincialoffice),
UPPER(v_summary_data.product),
v_summary_data.dateavailed,
v_summary_data.reportdate,
v_summary_data.datedischarged,
UPPER(v_summary_data.claimservice),
UPPER(v_summary_data.subclaimservice),
v_summary_data.benefitlimit,
v_summary_data.hospitalbill,
v_summary_data.phamount,
v_summary_data.excessexpenses,
v_summary_data.professionalfee,
v_summary_data.reimbursementamount,
v_summary_data.utilized,
v_summary_data.remainingbalance,
UPPER(v_summary_data.availmentcause),
UPPER(v_summary_data.claimtype),
UPPER(v_summary_data.icdcode),
UPPER(v_summary_data.icddisease),
UPPER(v_summary_data.payeetype),
UPPER(v_summary_data.paychan),
v_summary_data.datepaid,
v_summary_data.caseno,
v_summary_data.dateposted
    );
    END LOOP;


    CLOSE c_summary_data;

-- Collect distinct caseno where dateposted is today
    SELECT DISTINCT caseno
    BULK COLLECT INTO caseno_table
    FROM adw_prod_tgt.DS_SUMMARY_UTIL_REPORT
    WHERE TRUNC(last_update_date) = TRUNC(SYSDATE - 1);

-- Transfer details to another table based on the collected caseno values
    FORALL i IN caseno_table.FIRST .. caseno_table.LAST
        INSERT INTO adw_prod_tgt.ds_summary_util_report_hist (
        micaremember,
        pomno,
        memberid,
        loano,
        address,
        dob,
        age,
        gender,
        civil_status,
        client_type,
        effective_date,
        expiry_date,
        agreement_eff_date,
        new_renew,
        provider_type,
        hospital_clinic_name,
        date_affiliated,
        doctor,
        doc_specialization,
        date_affiliated_doc,
        type_of_affiliated_hcds,
        level1,
        provincial_office,
        product,
        date_of_availment,
        report_date,
        discharge_date,
        claim_service,
        subclaim_service,
        benefit_limit,
        hospital_bill,
        philhealth,
        excess_abl_mbl,
        professional_fee,
        reimbursement_amount,
        utilized,
        remaining_balance,
        availment_cause,
        claim_type,
        icd_code,
        icd_code_description,
        payee_type,
        pay_chan,
        date_paid,
        caseno,
        last_update_date
        )
        SELECT
        micaremember,
        pomno,
        memberid,
        loano,
        address,
        dob,
        age,
        gender,
        civil_status,
        client_type,
        effective_date,
        expiry_date,
        agreement_eff_date,
        new_renew,
        provider_type,
        hospital_clinic_name,
        date_affiliated,
        doctor,
        doc_specialization,
        date_affiliated_doc,
        type_of_affiliated_hcds,
        level1,
        provincial_office,
        product,
        date_of_availment,
        report_date,
        discharge_date,
        claim_service,
        subclaim_service,
        benefit_limit,
        hospital_bill,
        philhealth,
        excess_abl_mbl,
        professional_fee,
        reimbursement_amount,
        utilized,
        remaining_balance,
        availment_cause,
        claim_type,
        icd_code,
        icd_code_description,
        payee_type,
        pay_chan,
        date_paid,
        caseno,
        last_update_date
        FROM adw_prod_tgt.DS_SUMMARY_UTIL_REPORT
        WHERE 1=1
        AND caseno = caseno_table(i)
        AND TRUNC(last_update_date) != TRUNC(sysdate - 1)
        ;

COMMIT;


-- delete all the the data from the caseno that are updated 
    FORALL j IN caseno_table.FIRST .. caseno_table.LAST
        DELETE
        FROM adw_prod_tgt.DS_SUMMARY_UTIL_REPORT
        WHERE 1=1
        AND caseno = caseno_table(j)
        ;

COMMIT;



-- insert all the newest data from the caseno that are updated today. 
       FORALL k IN caseno_table.FIRST .. caseno_table.LAST
        INSERT INTO adw_prod_tgt.DS_SUMMARY_UTIL_REPORT (
          micaremember,
          pomno,
          memberid,
          loano,
          address,
          dob,
          age,
          gender,
          civil_status,
          client_type,
          effective_date,
          expiry_date,
          agreement_eff_date,
          new_renew,
          provider_type,
          hospital_clinic_name,
          date_affiliated,
          doctor,
          doc_specialization,
          date_affiliated_doc,
          type_of_affiliated_hcds,
          level1,
          provincial_office,
          product,
          date_of_availment,
          report_date,
          discharge_date,
          claim_service,
          subclaim_service,
          benefit_limit,
          hospital_bill,
          philhealth,
          excess_abl_mbl,
          professional_fee,
          reimbursement_amount,
          utilized,
          remaining_balance,
          availment_cause,
          claim_type,
          icd_code,
          icd_code_description,
          payee_type,
          pay_chan,
          date_paid,
          caseno,
          last_update_date
        ) 
        SELECT DISTINCT
    a.membername AS micaremember,
    TRIM(b.cardnumber) AS pomno,
    TRIM(a.memberno) AS memberid,
    NVL (TRIM(f.loano), '') AS loano,
    TRIM(NVL (c.province, '')) || CASE
        WHEN TRIM(NVL (c.province, '')) IS NOT NULL THEN ', '
        ELSE ''
    END || TRIM(NVL (c.municipality, '')) || CASE
        WHEN TRIM(NVL (c.municipality, '')) IS NOT NULL THEN ', '
        ELSE ''
    END || TRIM(NVL (c.barangay, '')) || CASE
        WHEN TRIM(NVL (c.barangay, '')) IS NOT NULL THEN ', '
        ELSE ''
    END || TRIM(NVL (c.street, '')) AS address, --check 
    TRUNC (a.birthdate) AS birthdate,
    TRUNC ((TRUNC (SYSDATE) - TRUNC (a.birthdate)) / 365.26) as age,
    TRIM(a.gender) AS gender,
    NVL (TRIM(m.description), '') AS civilstatus,
    CASE
        WHEN c.clienttype = 1 THEN 'CARD PRINCIPAL'
        WHEN c.clienttype = 2 THEN 'NON-CARD PRINCIPAL'
        WHEN c.clienttype = 3 THEN 'NON-CARD SPOUSE'
        WHEN c.clienttype = 4 THEN 'NON-CARD CHILD'
        ELSE ''
    END AS clienttype,
    -- NVL (
    --     TRUNC (a.coveredfrom),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS effectivity,

     TRUNC (a.coveredfrom) as effectivity, --updated 06242025

    -- NVL (
    --     TRUNC (a.coveredto),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS expiry,
    TRUNC (a.coveredto) as expiry,

    -- NVL (
    --     TRUNC (q.effectivity),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS agreementeffdate,
    TRUNC (q.effectivity) as agreementeffdate,

    CASE
        WHEN (
            CASE
                WHEN NVL (b.statuscode, 0) = 5 THEN 'T'
                WHEN NVL (b.renewal, 0) = 1 THEN 'R'
                WHEN NVL (b.renewal, 0) = 0 THEN 'N'
                ELSE ''
            END
        ) = 'N' THEN 'NEW'
        ELSE 'RENEWAL'
    END AS newrenew,
    CASE
        WHEN e.providertype = 1 THEN 'HOSPITAL'
        WHEN e.providertype = 2 THEN 'CLINIC'
        WHEN e.providertype = 3 THEN 'BILLING COMPANY'
        WHEN e.providertype = 4 THEN 'DENTAL CLINIC'
        ELSE ''
    END AS providertype,
    NVL (TRIM(e.providername), '') AS providername,

    -- NVL (
    --     TRUNC (e.dateaccredited),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS dateaffiliated,
    CASE
    WHEN TRUNC(e.dateaccredited) = TO_DATE('1900-01-01', 'YYYY-MM-DD') THEN NULL
    ELSE TRUNC(e.dateaccredited)
    END AS dateaffiliated, --updated 06242025



    NVL (TRIM(f.doctorname), '') AS doctorname,
    NVL (TO_CHAR (g.specialization), '') AS doctorspecialization,
    CASE
        WHEN f.doctorcode IS NULL
        OR f.doctorcode = 0 THEN NULL--TO_DATE ('1900-01-01', 'YYYY-MM-DD') --updated 06242025
        ELSE TRUNC (e.dateaccredited)
    END AS dateaffiliateddoc,
    '' AS typeofaffiliatedhcd,
    NVL (LTRIM (RTRIM (n.description)), '') AS level1,
    NVL (LTRIM (RTRIM (j.locationname)), '') AS provincialoffice,
    NVL (LTRIM (RTRIM (r.productline)), '') AS product,
    TRUNC (a.dateavailed) AS dateavailed,
    TRUNC (a.claimreceived) AS reportdate,
    TRUNC (a.datedischarged) AS datedischarged,
    NVL (LTRIM (RTRIM (k.description)), '') AS claimservice,
    NVL (LTRIM (RTRIM (l.description)), '') AS subclaimservice,
    NVL (p.limitamount, 0.00) AS benefitlimit,
    CASE
        WHEN a.casetype = 0 THEN NVL (
            CASE
                WHEN a.casetype = 1 THEN a.reamount
                ELSE a.provideramount + a.reamount
            END,
            0.00
        ) + a.roomamount
        ELSE 0.00
    END - CASE
        WHEN a.casetype = 1 THEN 0.00
        ELSE a.phamount + a.discount + a.npamount + a.adjamount
    END - (
        NVL (
            CASE
                WHEN a.casetype <> 1 THEN a.hbadjapproved
                ELSE 0
            END,
            0.00
        ) + NVL (
            CASE
                WHEN a.casetype <> 1 THEN a.hbadjdisapproved
                ELSE 0
            END,
            0.00
        )
    ) as hospitalbill,
    a.phamount AS phamount,
    a.eobamount AS excessexpenses,
    CASE
        WHEN a.casetype = 0 THEN a.pfamount
        ELSE 0.00
    END - (
        a.pfdiscount + a.nppfamount + a.phpfamount + a.adjamountpf
    ) - (
        NVL (a.pfadjapproved, 0.00) + NVL (a.pfadjdisapproved, 0.00)
    ) as professionalfee,
    CASE
        WHEN a.casetype = 0 THEN 0.00
        ELSE a.finalreamount - (
            NVL (
                CASE
                    WHEN a.casetype = 1 THEN a.hbadjapproved
                    ELSE 0
                END,
                0.00
            ) + NVL (
                CASE
                    WHEN a.casetype = 1 THEN a.hbadjdisapproved
                    ELSE 0
                END,
                0.00
            )
        )
    END as reimbursementamount,
    (a.basicclaim + a.majorclaim + a.spilloverclaim) AS utilized,
    (
        NVL (oo.creditedamount, 0.00) - (a.basicclaim + a.majorclaim + a.spilloverclaim)
    ) AS remainingbalance,
    UPPER(
        NVL (
            (
                SELECT
                    LISTAGG (
                        LTRIM (RTRIM (x.icdcode)) || ' - ' || LTRIM (RTRIM (x.icddisease)),
                        ', '
                    ) WITHIN GROUP (
                        ORDER BY
                            x.icdcode
                    )
                FROM
                    tblclaimdiagnosis zz
                    LEFT JOIN tblicdtable x ON zz.icdno = x.icdno
                    AND zz.icdno <> 0
                WHERE
                    zz.claimcode = a.claimcode
                    AND zz.icdno <> 0
                    AND zz.diagnosistype = 2
            ),
            ''
        )
    ) AS availmentcause,
    CASE
        WHEN a.casetype = 0 THEN 'NETWORK CLAIM'
        WHEN a.casetype = 1 THEN 'OUT OF NETWORK CLAIM'
        ELSE ''
    END AS claimtype,
    NVL (
        (
            SELECT
                LISTAGG (
                    DISTINCT NVL (LTRIM (RTRIM (x.icdcode)), zz.admittingtext),
                    ', '
                ) WITHIN GROUP (
                    ORDER BY
                        NVL (LTRIM (RTRIM (x.icdcode)), zz.admittingtext)
                )
            FROM
                adw_prod_tgt.tblclaimdiagnosis zz
                LEFT JOIN tblicdtable x ON zz.icdno = x.icdno
                AND zz.icdno <> 0
            WHERE
                zz.claimcode = a.claimcode
                AND zz.icdno <> 0
                AND zz.claimcode <> 0
        ),
        NULL
    ) AS icdcode,
    UPPER(
        NVL (
            (
                SELECT
                    LISTAGG (
                        DISTINCT NVL (LTRIM (RTRIM (x.icddisease)), zz.admittingtext),
                        ', '
                    ) WITHIN GROUP (
                        ORDER BY
                            NVL (LTRIM (RTRIM (x.icddisease)), zz.admittingtext)
                    )
                FROM
                    adw_prod_tgt.tblclaimdiagnosis zz
                    LEFT JOIN tblicdtable x ON zz.icdno = x.icdno
                    AND zz.icdno <> 0
                WHERE
                    zz.claimcode = a.claimcode
                    AND zz.icdno <> 0
                    AND zz.claimcode <> 0
            ),
            NULL
        )
    ) AS icddisease,
    NVL (TRIM(o.paytype), '') as payeetype,
    NVL (TRIM(o.checkno), '') as paychan,
    -- NVL (
    --     TRUNC (o.checkdate),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) as datepaid,
    CASE
    WHEN TRUNC(o.checkdate) = TO_DATE('1900-01-01', 'YYYY-MM-DD') THEN NULL
    ELSE TRUNC(o.checkdate)
        END AS datepaid, --updated 06242025
    a.caseno as caseno,
    a.dateposted as dateposted
FROM
    adw_prod_tgt.tblclaims a
    LEFT JOIN adw_prod_tgt.tblmembers b ON a.membercode = b.membercode
    LEFT JOIN adw_prod_tgt.tblmemberdetails c ON a.membercode = c.membercode
    LEFT JOIN adw_prod_tgt.tblproviders e ON a.providercode = e.providercode
    LEFT JOIN adw_prod_tgt.tblloas f ON a.loano = f.loano
    LEFT JOIN adw_prod_tgt.tbldoctorspecialization g ON f.doctorcode = g.doctorcode
    and f.doctorcode <> 0
    LEFT JOIN adw_prod_tgt.tblgentables h ON h.tablename = 'PROVIDER LEVEL'
    and e.providerlevel = h.detno
    LEFT JOIN adw_prod_tgt.tblagents i ON b.agentno = i.agentno
    LEFT JOIN adw_prod_tgt.tbllocations j ON i.branchno = j.locationcode
    AND j.locationtype = 'BRANCH'
    LEFT JOIN adw_prod_tgt.tblgentables k ON a.claimtype = k.detno
    AND k.tablename = 'CLAIMS SERVICES'
    LEFT JOIN adw_prod_tgt.tblgentables l ON a.subclaimtype = l.detno
    AND l.tablename = 'SUB CLAIM TYPE'
    LEFT JOIN adw_prod_tgt.tblgentables m ON c.civilstatus = m.recordno
    AND m.tablename = 'CIVILSTATUS'
    LEFT JOIN adw_prod_tgt.tblgentables n ON e.providerlevel = n.detno
    AND n.tablename = 'PROVIDER LEVEL'
    LEFT JOIN adw_prod_tgt.tblacctentriescv o ON a.dvno = o.dvno
    LEFT JOIN adw_prod_tgt.tblclaimdiagnosis oo ON a.claimcode = oo.claimcode
    and oo.diagnosistype = 2
    LEFt JOIN adw_prod_tgt.tblcompanybenefitplan p ON oo.plancode = p.plancode
    LEFT JOIN adw_prod_tgt.tblcompany q ON a.compcode = q.compcode
    LEFT JOIN adw_prod_tgt.tblproductlines r ON q.productcode = r.productcode
WHERE 1=1
    AND (
        a.caseno IS NOT NULL
        or a.caseno = ''
    )
    AND a.caseno = caseno_table(k) 
ORDER BY
    dateavailed
        ;


  COMMIT;


-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_SUMMARY_UTIL_REPORT', 'SP_REPORT_MHI_DSSUMMARYUTILREPORT', SYSDATE, SYSDATE, 'UPDATE');


 
 END SP_REPORT_MHI_DSSUMMARYUTILREPORT;
 