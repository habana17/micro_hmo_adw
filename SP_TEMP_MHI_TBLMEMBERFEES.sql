create
or replace PROCEDURE SP_TEMP_MHI_TBLMEMBERFEES AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLMEMBERFEES
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_TEMP_MHI_TBLMEMBERFEES


NOTES:

 ******************************************************************************/

--adw_prod_tgt.sp_adw_table_logs('TBLMEMBERFEES', 'SP_TEMP_MHI_TBLMEMBERFEES', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLMEMBERFEES
WHERE
    1 = 1
    AND TRUNC (dateencoded) >= TRUNC (SYSDATE);
COMMIT;
--adw_prod_tgt.sp_adw_table_logs('TBLMEMBERFEES', 'SP_TEMP_MHI_TBLMEMBERFEES', SYSDATE, '', 'INSERT');
INSERT INTO
    adw_prod_tgt.TBLMEMBERFEES (
        memberfeecode,
        compcode,
        contractcode,
        plancode,
        feecode,
        membercode,
        batchcode,
        active,
        amount,
        amountprorate,
        effectivity,
        dateencoded,
        encodedby,
        retailfrom,
        retailto,
        cancelled,
        retailsoacode,
        origamount,
        modalfactor,
        specialrate,
        discount,
        monthused,
        monthcovered,
        annualamount,
        billclassdetno,
        billingschedule,
        dummymemberno,
        modalfrom,
        modalto,
        premiumclass,
        premiumcode,
        soacode,
        soano,
        vatrate,
        companyshare,
        employeeshare,
        memberamenddetno
    )
SELECT
    memberfeecode,
    compcode,
    contractcode,
    plancode,
    feecode,
    membercode,
    batchcode,
    active,
    amount,
    amountprorate,
    effectivity,
    dateencoded,
    encodedby,
    retailfrom,
    retailto,
    cancelled,
    retailsoacode,
    origamount,
    modalfactor,
    specialrate,
    discount,
    monthused,
    monthcovered,
    annualamount,
    billclassdetno,
    billingschedule,
    dummymemberno,
    modalfrom,
    modalto,
    premiumclass,
    premiumcode,
    soacode,
    soano,
    vatrate,
    companyshare,
    employeeshare,
    memberamenddetno
FROM
    adw_prod_tgt.TEMP_TBLMEMBERFEES
    WHERE 1=1 
    ;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLMEMBERFEES';
--adw_prod_tgt.sp_adw_table_logs('TBLMEMBERFEES', 'SP_TEMP_MHI_TBLMEMBERFEES', SYSDATE, SYSDATE, 'UPDATE');


 END SP_TEMP_MHI_TBLMEMBERFEES;
 