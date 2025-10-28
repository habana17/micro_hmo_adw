create
or replace PROCEDURE SP_TEMP_MHI_TBLLOAS AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLLOAS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/29/2025       Francis          1. Create SP_TEMP_MHI_TBLLOAS


NOTES:

 ******************************************************************************/
 
--adw_prod_tgt.sp_adw_table_logs('TBLLOAS', 'SP_TEMP_MHI_TBLLOAS', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLLOAS
WHERE
    1 = 1
    AND TRUNC (dateencoded) >= TRUNC (SYSDATE);

COMMIT;

--adw_prod_tgt.sp_adw_table_logs('TBLLOAS', 'SP_TEMP_MHI_TBLLOAS', SYSDATE, '', 'INSERT');
INSERT INTO
    adw_prod_tgt.TBLLOAS (
        loacode,
        loadate,
        loano,
        claimtype,
        subclaimtype,
        callername,
        callercontact,
        compcode,
        companyname,
        companystatus,
        membercode,
        memberno,
        membername,
        membertype,
        membercategory,
        levelcode,
        memberstatus,
        principalcode,
        principalname,
        principalno,
        classorder,
        policydivision,
        providercode,
        dateavailed,
        datedischarged,
        loastatus,
        eligibilitystatus,
        loaamount,
        dateapproved,
        datedue,
        approvedby,
        oldplancode,
        planname,
        roomtype,
        coveredfrom,
        coveredto,
        birthdate,
        gender,
        vip,
        origeffectivity,
        intervininggroup,
        creditedamount,
        sharedplan,
        admittingtext,
        doctorcode,
        doctorname,
        otherexclusions,
        procedures,
        icdno,
        remarks,
        dateencoded,
        encodedend,
        encodedby,
        encodedduration,
        rowmarker,
        loaconcerndesc,
        loaconcernno,
        loarequestcode,
        withguaranteeletter,
        controlno,
        philhealth,
        miscrnb,
        miscrnbamount,
        miscancillary,
        miscancillaryamount,
        miscproffee,
        miscproffeeamount,
        miscmbl,
        miscmblamount,
        misctakehome,
        misctakehomeamount,
        miscothers,
        miscothersamount,
        misccharges,
        miscphonecharges,
        miscadmissionkit,
        miscorthopedic,
        dateused,
        provideraccess,
        retrievedforapproval,
        recreated,
        origloacode,
        benefitclass,
        contractno,
        plancode,
        finalstatus,
        roomamount,
        calleremail,
        streetaddress,
        province,
        municipality,
        barangay,
        last_update_date
    )
SELECT
    loacode,
    loadate,
    loano,
    claimtype,
    subclaimtype,
    callername,
    callercontact,
    compcode,
    companyname,
    companystatus,
    membercode,
    memberno,
    membername,
    membertype,
    membercategory,
    levelcode,
    memberstatus,
    principalcode,
    principalname,
    principalno,
    classorder,
    policydivision,
    providercode,
    dateavailed,
    datedischarged,
    loastatus,
    eligibilitystatus,
    loaamount,
    dateapproved,
    datedue,
    approvedby,
    oldplancode,
    planname,
    roomtype,
    coveredfrom,
    coveredto,
    birthdate,
    gender,
    vip,
    origeffectivity,
    intervininggroup,
    creditedamount,
    sharedplan,
    admittingtext,
    doctorcode,
    doctorname,
    otherexclusions,
    procedures,
    icdno,
    remarks,
    dateencoded,
    encodedend,
    encodedby,
    encodedduration,
    rowmarker,
    loaconcerndesc,
    loaconcernno,
    loarequestcode,
    withguaranteeletter,
    controlno,
    philhealth,
    miscrnb,
    miscrnbamount,
    miscancillary,
    miscancillaryamount,
    miscproffee,
    miscproffeeamount,
    miscmbl,
    miscmblamount,
    misctakehome,
    misctakehomeamount,
    miscothers,
    miscothersamount,
    misccharges,
    miscphonecharges,
    miscadmissionkit,
    miscorthopedic,
    dateused,
    provideraccess,
    retrievedforapproval,
    recreated,
    origloacode,
    benefitclass,
    contractno,
    plancode,
    finalstatus,
    roomamount,
    calleremail,
    streetaddress,
    province,
    municipality,
    barangay,
    last_update_date
FROM
    adw_prod_tgt.TEMP_TBLLOAS
WHERE
    1 = 1;

COMMIT;

EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLLOAS';

--adw_prod_tgt.sp_adw_table_logs('TBLLOAS', 'SP_TEMP_MICRO_HMO', SYSDATE, SYSDATE, 'UPDATE');  



--transfer history 
--adw_prod_tgt.sp_adw_table_logs('TBLLOAS_HIST', 'SP_TEMP_MICRO_HMO', SYSDATE, '', 'INSERT');
INSERT INTO --added by francis 05282025
    adw_prod_tgt.TBLLOAS_HIST (
    loacode,
    loadate,
    loano,
    claimtype,
    subclaimtype,
    callername,
    callercontact,
    compcode,
    companyname,
    companystatus,
    membercode,
    memberno,
    membername,
    membertype,
    membercategory,
    levelcode,
    memberstatus,
    principalcode,
    principalname,
    principalno,
    classorder,
    policydivision,
    providercode,
    dateavailed,
    datedischarged,
    loastatus,
    eligibilitystatus,
    loaamount,
    dateapproved,
    datedue,
    approvedby,
    oldplancode,
    planname,
    roomtype,
    coveredfrom,
    coveredto,
    birthdate,
    gender,
    vip,
    origeffectivity,
    intervininggroup,
    creditedamount,
    sharedplan,
    admittingtext,
    doctorcode,
    doctorname,
    otherexclusions,
    procedures,
    icdno,
    remarks,
    dateencoded,
    encodedend,
    encodedby,
    encodedduration,
    rowmarker,
    loaconcerndesc,
    loaconcernno,
    loarequestcode,
    withguaranteeletter,
    controlno,
    philhealth,
    miscrnb,
    miscrnbamount,
    miscancillary,
    miscancillaryamount,
    miscproffee,
    miscproffeeamount,
    miscmbl,
    miscmblamount,
    misctakehome,
    misctakehomeamount,
    miscothers,
    miscothersamount,
    misccharges,
    miscphonecharges,
    miscadmissionkit,
    miscorthopedic,
    dateused,
    provideraccess,
    retrievedforapproval,
    recreated,
    origloacode,
    benefitclass,
    contractno,
    plancode,
    finalstatus,
    roomamount,
    calleremail,
    streetaddress,
    province,
    municipality,
    barangay,
    last_update_date

    )
SELECT
    loacode,
    loadate,
    loano,
    claimtype,
    subclaimtype,
    callername,
    callercontact,
    compcode,
    companyname,
    companystatus,
    membercode,
    memberno,
    membername,
    membertype,
    membercategory,
    levelcode,
    memberstatus,
    principalcode,
    principalname,
    principalno,
    classorder,
    policydivision,
    providercode,
    dateavailed,
    datedischarged,
    loastatus,
    eligibilitystatus,
    loaamount,
    dateapproved,
    datedue,
    approvedby,
    oldplancode,
    planname,
    roomtype,
    coveredfrom,
    coveredto,
    birthdate,
    gender,
    vip,
    origeffectivity,
    intervininggroup,
    creditedamount,
    sharedplan,
    admittingtext,
    doctorcode,
    doctorname,
    otherexclusions,
    procedures,
    icdno,
    remarks,
    dateencoded,
    encodedend,
    encodedby,
    encodedduration,
    rowmarker,
    loaconcerndesc,
    loaconcernno,
    loarequestcode,
    withguaranteeletter,
    controlno,
    philhealth,
    miscrnb,
    miscrnbamount,
    miscancillary,
    miscancillaryamount,
    miscproffee,
    miscproffeeamount,
    miscmbl,
    miscmblamount,
    misctakehome,
    misctakehomeamount,
    miscothers,
    miscothersamount,
    misccharges,
    miscphonecharges,
    miscadmissionkit,
    miscorthopedic,
    dateused,
    provideraccess,
    retrievedforapproval,
    recreated,
    origloacode,
    benefitclass,
    contractno,
    plancode,
    finalstatus,
    roomamount,
    calleremail,
    streetaddress,
    province,
    municipality,
    barangay,
    last_update_date
FROM
    (
        SELECT
            loacode,
            loadate,
            loano,
            claimtype,
            subclaimtype,
            callername,
            callercontact,
            compcode,
            companyname,
            companystatus,
            membercode,
            memberno,
            membername,
            membertype,
            membercategory,
            levelcode,
            memberstatus,
            principalcode,
            principalname,
            principalno,
            classorder,
            policydivision,
            providercode,
            dateavailed,
            datedischarged,
            loastatus,
            eligibilitystatus,
            loaamount,
            dateapproved,
            datedue,
            approvedby,
            oldplancode,
            planname,
            roomtype,
            coveredfrom,
            coveredto,
            birthdate,
            gender,
            vip,
            origeffectivity,
            intervininggroup,
            creditedamount,
            sharedplan,
            admittingtext,
            doctorcode,
            doctorname,
            otherexclusions,
            procedures,
            icdno,
            remarks,
            dateencoded,
            encodedend,
            encodedby,
            encodedduration,
            rowmarker,
            loaconcerndesc,
            loaconcernno,
            loarequestcode,
            withguaranteeletter,
            controlno,
            philhealth,
            miscrnb,
            miscrnbamount,
            miscancillary,
            miscancillaryamount,
            miscproffee,
            miscproffeeamount,
            miscmbl,
            miscmblamount,
            misctakehome,
            misctakehomeamount,
            miscothers,
            miscothersamount,
            misccharges,
            miscphonecharges,
            miscadmissionkit,
            miscorthopedic,
            dateused,
            provideraccess,
            retrievedforapproval,
            recreated,
            origloacode,
            benefitclass,
            contractno,
            plancode,
            finalstatus,
            roomamount,
            calleremail,
            streetaddress,
            province,
            municipality,
            barangay,
            last_update_date,
            ROW_NUMBER() OVER (
                PARTITION BY
                    loacode
                ORDER BY
                    CASE
                        WHEN last_update_date IS NULL THEN 1
                        ELSE 0
                    END,
                    last_update_date desc
            ) AS Row_Num
        FROM
            adw_prod_tgt.TBLLOAS
        WHERE
            loacode IN (
                SELECT
                    loacode
                FROM
                    adw_prod_tgt.TBLLOAS
                GROUP BY
                    loacode
                HAVING
                    COUNT(*) > 1
            )
    )
WHERE
    Row_Num > 1;

COMMIT;

DELETE FROM adw_prod_tgt.TBLLOAS --added by francis 05282025
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
                            loacode
                        ORDER BY
                            CASE
                                WHEN last_update_date IS NULL THEN 1
                                ELSE 0
                            END,
                            last_update_date DESC
                    ) AS Row_Num
                FROM
                    adw_prod_tgt.TBLLOAS
            )
        WHERE
            Row_Num > 1
    );

COMMIT;

-- --adw_prod_tgt.sp_adw_table_logs('TBLLOAS_HIST', 'SP_TEMP_MHI_TBLLOAS', SYSDATE, SYSDATE, 'UPDATE');

 
 END SP_TEMP_MHI_TBLLOAS;
 