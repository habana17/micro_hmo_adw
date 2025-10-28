create
or replace PROCEDURE SP_REPORT_MHI_DSPREMIUMREGISTER AS lvatrate NUMBER (6, 2);

/******************************************************************************

NAME:       SP_REPORT_MHI_DSPREMIUMREGISTER
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_DSPREMIUMREGISTER
2.0        09/25/2025       Francis          1. adding git version control for testing 


NOTES:

 ******************************************************************************/


 BEGIN

 -- Assign the VAT rate value to the variable
SELECT distinct
    vatrate INTO lvatrate
FROM
    tblsettingsaccounting;

-- Logging the DELETE operation 
adw_prod_tgt.sp_adw_table_logs('DS_PREMIUM_REGISTER', 'SP_REPORT_MHI_DSPREMIUMREGISTER', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_PREMIUM_REGISTER
WHERE
1 = 1
AND TRUNC (invoice_date) >= TRUNC (SYSDATE);
COMMIT;
-- Logging the INSERT operation 
adw_prod_tgt.sp_adw_table_logs('DS_PREMIUM_REGISTER', 'SP_REPORT_MHI_DSPREMIUMREGISTER', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
adw_prod_tgt.DS_PREMIUM_REGISTER (
CO_CD,
ISS_NAME,
TRAN_TYPE,
POL_YY,
POL_SEQ_NO,
BILL_YY,
BILL_SEQ_NO,
CLIENT_NO,
CLIENT_NAME,
Membership,
Institution,
EFF_DT,
INTM_NO,
INTM_NAME,
COVERAGE_TYPE,
S_MBL_AMT,
INVOICE_NO,
INVOICE_DATE,
S_PREM_AMT,
VAT_AMT,
OTHER_CHARGES,
COMM_AMT,
COMM_RATE,
COMM_TAX,
PRODUCT_CD,
PRODUCT_CHANNEL_CD,
PROVINCIAL_OFFICE,
LOCATION_CD,
LAST_UPDATE_DATE
)
SELECT
'15' AS co_cd,
NVL (d.locationno, '') AS iss_name,
CASE
WHEN a.soatype IN (2, 3) THEN 1
WHEN a.soatype = 1 THEN 2
ELSE 3
END AS tran_type,
EXTRACT(
YEAR
FROM
NVL (
b.effectivity,
TO_DATE ('1900-01-01', 'YYYY-MM-DD')
)
) AS pol_yy,
NVL (b.contractno, '') AS pol_seq_no,
EXTRACT(
YEAR
FROM
a.soadate
) AS bill_yy,
a.soano AS bill_seq_no,
NVL (g.membershipinstitutioncode, '') AS client_no,
NVL (g.membership, '') || ' ' || NVL (g.institution, '') || ' - ' || NVL (f.benefitclass, '') || ' - ' || NVL (d.locationno, '') AS client_name,
NVL (g.membership, '') AS membership,
NVL (g.institution, '') AS institution,
NVL (
b.effectivity,
TO_DATE ('1900-01-01', 'YYYY-MM-DD')
) AS eff_dt,
NVL (h.agentcode, '') AS intm_no,
NVL (h.agentname, '') AS intm_name,
NVL (i.planname, '') AS coverage_type,
NVL (i.limitamount, 0) AS s_mbl_amt,
a.soano AS invoice_no,
a.soadate AS invoice_date,
NVL (i.premiumfeeamount, 0) / (1 + lvatrate + (NVL (l.rateamount, 0) / 100)) AS s_prem_amt,
NVL (i.premiumfeeamount, 0) / (1 + lvatrate + (NVL (l.rateamount, 0) / 100)) * lvatrate AS vat_amt,
NVL (i.premiumfeeamount, 0) / (1 + lvatrate + (NVL (l.rateamount, 0) / 100)) * (NVL (l.rateamount, 0) / 100) AS other_charges,
NVL (j.commissionrate, 0) AS comm_amt,
CASE
WHEN NVL (i.premiumfeeamount, 0) = 0 THEN 0
ELSE NVL (j.commissionrate, 0) / NVL (i.premiumfeeamount, 0)
END AS comm_rate,
NVL (k.wtaxrate, 0) AS comm_tax,
NVL (c.productlinecode, '') AS product_cd,
NVL (b.channel, '') AS product_channel_cd,
NVL (m.locationname, '') AS provincial_office,
'HO' AS location_cd,
a.last_update_date as last_update_date
FROM
tblsoaaccounts a
LEFT JOIN tblcompany b ON a.compcode = b.compcode
LEFT JOIN tblproductlines c ON b.productcode = c.productcode
LEFT JOIN tbllocations d ON d.locationtype = 'BRANCH'
AND b.branch = d.locationcode
LEFT JOIN  (select distinct membercode,soacode from tblsoapremiummembers) e ON a.soacode = e.soacode
LEFT JOIN tblmembers f ON a.compcode = f.compcode
AND e.membercode = f.membercode
LEFT JOIN tblmembershipinstitutions g ON f.membershipinstitutionno = g.membershipinstitutionno
--LEFT JOIN tblagents h ON h.agentno = g.agentno
LEFT JOIN (select distinct agentno,agentcode,agentname,wtaxno from tblagents) h ON f.agentno = h.agentno
LEFT JOIN tblcompanybenefitplan i ON a.compcode = i.compcode
AND a.contractcode = i.contractcode
AND f.benefitclass = i.classcode
AND i.effectivity <= f.effectivity
AND (
i.applicablegender = 3
OR (
i.applicablegender = 1
AND f.gender = 'F'
)
OR (
i.applicablegender = 2
AND f.gender = 'M'
)
)
LEFT JOIN tblcompanyagentcommission j ON a.compcode = j.compcode
AND f.agentno = j.agentno
AND j.effectivity <= f.effectivity
LEFT JOIN tblwtaxrates k ON h.wtaxno = k.wtaxno
LEFT JOIN tblsettingssoatax l ON b.branch = l.branchno
AND l.effectivitydate <= SYSDATE
AND l.taxcode = 'LGT'
LEFT JOIN tbllocations m ON b.branch <> 0
AND b.branch = m.locationcode
WHERE
1 = 1
AND TRUNC(a.last_update_date) = TRUNC(sysdate - 1) --incremental
ORDER BY
a.soano;
COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
adw_prod_tgt.sp_adw_table_logs('DS_PREMIUM_REGISTER', 'SP_REPORT_MHI_DSPREMIUMREGISTER', SYSDATE, SYSDATE, 'UPDATE');

  END SP_REPORT_MHI_DSPREMIUMREGISTER;
 