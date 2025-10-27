create
or replace PROCEDURE SP_TEMP_MHI_TBLSOAACCOUNTS AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLSOAACCOUNTS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/29/2025       Francis          1. Create SP_TEMP_MHI_TBLSOAACCOUNTS
1.1        06/13/2025       Francis          1. Add TBLSOAACCOUNTS_HIST
1.2        10/24/2025       Francis          1. Add endorsementno

NOTES:

 ******************************************************************************/


--adw_prod_tgt.sp_adw_table_logs('TBLSOAACCOUNTS', 'SP_TEMP_MHI_TBLSOAACCOUNTS', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLSOAACCOUNTS
WHERE
  1 = 1
  AND TRUNC (soadate) >= TRUNC (SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLSOAACCOUNTS', 'SP_TEMP_MHI_TBLSOAACCOUNTS', SYSDATE, '', 'INSERT');
INSERT INTO
  adw_prod_tgt.TBLSOAACCOUNTS (
    soacode,
    soano,
    soadate,
    soadue,
    compcode,
    billingcompcode,
    soatype,
    statuscode,
    soaamount,
    paidamount,
    datepaid,
    vatpercent,
    commissionamount,
    grossamount,
    glamount,
    extrarate,
    coveredfrom,
    coveredto,
    discount,
    contractcode,
    generatedby,
    dategenerated,
    datereleased,
    releasedby,
    importedcode,
    referenceno,
    billingschedule,
    jvnoar,
    jvnoreversal,
    uploaded,
    billtype,
    rowmarker,
    adjamount,
    gpadminrate,
    gpadminfee,
    consolidatedcode,
    migrated,
    lifeamount,
    medicalamount,
    mastercode,
    agentno,
    remarks,
    replacement,
    replacesoacode,
    cancelconsolidatedcode,
    dateapproved,
    billingmodal,
    cancelmasterarcode,
    datecancelled,
    cdamount,
    otherdeductions,
    slagentno,
    soadueextension,
    currentaddressee,
    policydivision,
    collectionstatus,
    vattype,
    vatamount,
    companyfeedetno,
    grossamountriders,
    dstamount,
    premiumtax,
    localtax,
    netpremium,
    vatexempt,
    vatsales,
    vatoutput,
    billingagentno,
    groupno,
    additional,
    xlsmemberattachment,
    manualrenewal,
    withMAD,
    classorder,
    additionalamount,
    additionalpay,
    additionalsoacode,
    billngtype,
    cncimportedcode,
    dateencoded,
    encodedby,
    parentcompcode,
    last_update_date,
    endorsementno
  )
SELECT
  soacode,
  soano,
  soadate,
  soadue,
  compcode,
  billingcompcode,
  soatype,
  statuscode,
  soaamount,
  paidamount,
  datepaid,
  vatpercent,
  commissionamount,
  grossamount,
  glamount,
  extrarate,
  coveredfrom,
  coveredto,
  discount,
  contractcode,
  generatedby,
  dategenerated,
  datereleased,
  releasedby,
  importedcode,
  referenceno,
  billingschedule,
  jvnoar,
  jvnoreversal,
  uploaded,
  billtype,
  rowmarker,
  adjamount,
  gpadminrate,
  gpadminfee,
  consolidatedcode,
  migrated,
  lifeamount,
  medicalamount,
  mastercode,
  agentno,
  remarks,
  replacement,
  replacesoacode,
  cancelconsolidatedcode,
  dateapproved,
  billingmodal,
  cancelmasterarcode,
  datecancelled,
  cdamount,
  otherdeductions,
  slagentno,
  soadueextension,
  currentaddressee,
  policydivision,
  collectionstatus,
  vattype,
  vatamount,
  companyfeedetno,
  grossamountriders,
  dstamount,
  premiumtax,
  localtax,
  netpremium,
  vatexempt,
  vatsales,
  vatoutput,
  billingagentno,
  groupno,
  additional,
  xlsmemberattachment,
  manualrenewal,
  withMAD,
  classorder,
  additionalamount,
  additionalpay,
  additionalsoacode,
  billngtype,
  cncimportedcode,
  dateencoded,
  encodedby,
  parentcompcode,
  last_update_date,
  endorsementno
FROM
  adw_prod_tgt.TEMP_TBLSOAACCOUNTS;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLSOAACCOUNTS';
--adw_prod_tgt.sp_adw_table_logs('TBLSOAACCOUNTS', 'SP_TEMP_MHI_TBLSOAACCOUNTS', SYSDATE, SYSDATE, 'UPDATE');    



--transfer history 
--adw_prod_tgt.sp_adw_table_logs('TBLSOAACCOUNTS_HIST', 'SP_TEMP_MHI_TBLSOAACCOUNTS', SYSDATE, '', 'INSERT');
INSERT INTO --added by francis 06132025
    adw_prod_tgt.TBLSOAACCOUNTS_HIST (
  soacode,
  soano,
  soadate,
  soadue,
  compcode,
  billingcompcode,
  soatype,
  statuscode,
  soaamount,
  paidamount,
  datepaid,
  vatpercent,
  commissionamount,
  grossamount,
  glamount,
  extrarate,
  coveredfrom,
  coveredto,
  discount,
  contractcode,
  generatedby,
  dategenerated,
  datereleased,
  releasedby,
  importedcode,
  referenceno,
  billingschedule,
  jvnoar,
  jvnoreversal,
  uploaded,
  billtype,
  rowmarker,
  adjamount,
  gpadminrate,
  gpadminfee,
  consolidatedcode,
  migrated,
  lifeamount,
  medicalamount,
  mastercode,
  agentno,
  remarks,
  replacement,
  replacesoacode,
  cancelconsolidatedcode,
  dateapproved,
  billingmodal,
  cancelmasterarcode,
  datecancelled,
  cdamount,
  otherdeductions,
  slagentno,
  soadueextension,
  currentaddressee,
  policydivision,
  collectionstatus,
  vattype,
  vatamount,
  companyfeedetno,
  grossamountriders,
  dstamount,
  premiumtax,
  localtax,
  netpremium,
  vatexempt,
  vatsales,
  vatoutput,
  billingagentno,
  groupno,
  additional,
  xlsmemberattachment,
  manualrenewal,
  withMAD,
  classorder,
  additionalamount,
  additionalpay,
  additionalsoacode,
  billngtype,
  cncimportedcode,
  dateencoded,
  encodedby,
  parentcompcode,
  last_update_date,
  endorsementno
    )
SELECT
  soacode,
  soano,
  soadate,
  soadue,
  compcode,
  billingcompcode,
  soatype,
  statuscode,
  soaamount,
  paidamount,
  datepaid,
  vatpercent,
  commissionamount,
  grossamount,
  glamount,
  extrarate,
  coveredfrom,
  coveredto,
  discount,
  contractcode,
  generatedby,
  dategenerated,
  datereleased,
  releasedby,
  importedcode,
  referenceno,
  billingschedule,
  jvnoar,
  jvnoreversal,
  uploaded,
  billtype,
  rowmarker,
  adjamount,
  gpadminrate,
  gpadminfee,
  consolidatedcode,
  migrated,
  lifeamount,
  medicalamount,
  mastercode,
  agentno,
  remarks,
  replacement,
  replacesoacode,
  cancelconsolidatedcode,
  dateapproved,
  billingmodal,
  cancelmasterarcode,
  datecancelled,
  cdamount,
  otherdeductions,
  slagentno,
  soadueextension,
  currentaddressee,
  policydivision,
  collectionstatus,
  vattype,
  vatamount,
  companyfeedetno,
  grossamountriders,
  dstamount,
  premiumtax,
  localtax,
  netpremium,
  vatexempt,
  vatsales,
  vatoutput,
  billingagentno,
  groupno,
  additional,
  xlsmemberattachment,
  manualrenewal,
  withMAD,
  classorder,
  additionalamount,
  additionalpay,
  additionalsoacode,
  billngtype,
  cncimportedcode,
  dateencoded,
  encodedby,
  parentcompcode,
  last_update_date,
  endorsementno 
FROM
    (
        SELECT
        soacode,
  soano,
  soadate,
  soadue,
  compcode,
  billingcompcode,
  soatype,
  statuscode,
  soaamount,
  paidamount,
  datepaid,
  vatpercent,
  commissionamount,
  grossamount,
  glamount,
  extrarate,
  coveredfrom,
  coveredto,
  discount,
  contractcode,
  generatedby,
  dategenerated,
  datereleased,
  releasedby,
  importedcode,
  referenceno,
  billingschedule,
  jvnoar,
  jvnoreversal,
  uploaded,
  billtype,
  rowmarker,
  adjamount,
  gpadminrate,
  gpadminfee,
  consolidatedcode,
  migrated,
  lifeamount,
  medicalamount,
  mastercode,
  agentno,
  remarks,
  replacement,
  replacesoacode,
  cancelconsolidatedcode,
  dateapproved,
  billingmodal,
  cancelmasterarcode,
  datecancelled,
  cdamount,
  otherdeductions,
  slagentno,
  soadueextension,
  currentaddressee,
  policydivision,
  collectionstatus,
  vattype,
  vatamount,
  companyfeedetno,
  grossamountriders,
  dstamount,
  premiumtax,
  localtax,
  netpremium,
  vatexempt,
  vatsales,
  vatoutput,
  billingagentno,
  groupno,
  additional,
  xlsmemberattachment,
  manualrenewal,
  withMAD,
  classorder,
  additionalamount,
  additionalpay,
  additionalsoacode,
  billngtype,
  cncimportedcode,
  dateencoded,
  encodedby,
  parentcompcode,
  last_update_date,
  endorsementno,
            ROW_NUMBER() OVER (
                PARTITION BY
                    soacode 
                ORDER BY
                    CASE
                        WHEN last_update_date IS NULL THEN 1
                        ELSE 0
                    END,
                    last_update_date desc
            ) AS Row_Num
        FROM
            adw_prod_tgt.TBLSOAACCOUNTS
        WHERE
            soacode IN (
                SELECT
                    soacode
                FROM
                    adw_prod_tgt.TBLSOAACCOUNTS
                GROUP BY
                    soacode
                HAVING
                    COUNT(*) > 1
            )
    )
WHERE
    Row_Num > 1;

COMMIT;

DELETE FROM adw_prod_tgt.TBLSOAACCOUNTS --added by francis 06132025
WHERE
    ROWID IN (
        SELECT
            ROWID
        FROM
            (
                SELECT
                    ROWID,
                    ROW_NUMBER() OVER (
                        PARTITION BY
                            soacode
                        ORDER BY
                            CASE
                                WHEN last_update_date IS NULL THEN 1
                                ELSE 0
                            END,
                            last_update_date DESC
                    ) AS Row_Num
                FROM
                    adw_prod_tgt.TBLSOAACCOUNTS
            )
        WHERE
            Row_Num > 1
    );

COMMIT;

-- --adw_prod_tgt.sp_adw_table_logs('TBLSOAACCOUNTS_HIST', 'SP_TEMP_MHI_TBLSOAACCOUNTS', SYSDATE, SYSDATE, 'UPDATE');


 END SP_TEMP_MHI_TBLSOAACCOUNTS;
 