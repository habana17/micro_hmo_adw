create
or replace PROCEDURE SP_TEMP_MHI_TBLUSERS AS BEGIN
/******************************************************************************

NAME:       SP_TEMP_MHI_TBLUSERS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/03/2025       Francis          1. Create SP_TEMP_MHI_TBLUSERS


NOTES:

 ******************************************************************************/

--adw_prod_tgt.sp_adw_table_logs('TBLUSERS', 'SP_TEMP_MHI_TBLUSERS', SYSDATE, '', 'DELETE');
DELETE FROM adw_prod_tgt.TBLUSERS
WHERE
    1 = 1
    AND TRUNC (last_update_date) >= TRUNC (SYSDATE);
COMMIT;


--adw_prod_tgt.sp_adw_table_logs('TBLUSERS', 'SP_TEMP_MHI_TBLUSERS', SYSDATE, '', 'INSERT');
INSERT INTO
    adw_prod_tgt.TBLUSERS (
        userno,
        usercode,
        username,
        userpass,
        useraccess,
        usertype,
        userpicture,
        nickname,
        activetask,
        activeuser,
        lastaccess,
        workstation,
        rememberpc,
        branchno,
        subbranchno,
        departmentno,
        emailadd,
        defaultdir,
        passwordlock,
        passwordexpiry,
        strongpassword,
        invalidtime,
        invalidattempt,
        accountindex,
        designation,
        cashier,
        employeeno,
        rowmarker,
        divisioncode,
        dashboard,
        datecreated,
        inactivedate,
        mobileno,
        tempno,
        tfa,
        lastcashierseries,
        passwordhash,
        passwordsalt,
        daterequestforgotpass,
        requestforgotpassguid,
        branchnos,
        digitalsignature,
        last_update_date 
    )
SELECT
     userno,
        usercode,
        username,
        userpass,
        useraccess,
        usertype,
        userpicture,
        nickname,
        activetask,
        activeuser,
        lastaccess,
        workstation,
        rememberpc,
        branchno,
        subbranchno,
        departmentno,
        emailadd,
        defaultdir,
        passwordlock,
        passwordexpiry,
        strongpassword,
        invalidtime,
        invalidattempt,
        accountindex,
        designation,
        cashier,
        employeeno,
        rowmarker,
        divisioncode,
        dashboard,
        datecreated,
        inactivedate,
        mobileno,
        tempno,
        tfa,
        lastcashierseries,
        passwordhash,
        passwordsalt,
        daterequestforgotpass,
        requestforgotpassguid,
        branchnos,
        digitalsignature,
        last_update_date
FROM
    adw_prod_tgt.TEMP_TBLUSERS
    WHERE 1=1 
    ;
COMMIT;
EXECUTE IMMEDIATE 'TRUNCATE TABLE adw_prod_tgt.TEMP_TBLUSERS';
--adw_prod_tgt.sp_adw_table_logs('TBLUSERS', 'SP_TEMP_MHI_TBLUSERS', SYSDATE, SYSDATE, 'UPDATE');



--transfer history 
--adw_prod_tgt.sp_adw_table_logs('TBLUSERS_HIST', 'SP_TEMP_MHI_TBLUSERS', SYSDATE, '', 'INSERT');
INSERT INTO 
    adw_prod_tgt.tblusers_hist (
        userno,
        usercode,
        username,
        userpass,
        useraccess,
        usertype,
        userpicture,
        nickname,
        activetask,
        activeuser,
        lastaccess,
        workstation,
        rememberpc,
        branchno,
        subbranchno,
        departmentno,
        emailadd,
        defaultdir,
        passwordlock,
        passwordexpiry,
        strongpassword,
        invalidtime,
        invalidattempt,
        accountindex,
        designation,
        cashier,
        employeeno,
        rowmarker,
        divisioncode,
        dashboard,
        datecreated,
        inactivedate,
        mobileno,
        tempno,
        tfa,
        lastcashierseries,
        passwordhash,
        passwordsalt,
        daterequestforgotpass,
        requestforgotpassguid,
        branchnos,
        digitalsignature,
        last_update_date

    )
SELECT
        userno,
        usercode,
        username,
        userpass,
        useraccess,
        usertype,
        userpicture,
        nickname,
        activetask,
        activeuser,
        lastaccess,
        workstation,
        rememberpc,
        branchno,
        subbranchno,
        departmentno,
        emailadd,
        defaultdir,
        passwordlock,
        passwordexpiry,
        strongpassword,
        invalidtime,
        invalidattempt,
        accountindex,
        designation,
        cashier,
        employeeno,
        rowmarker,
        divisioncode,
        dashboard,
        datecreated,
        inactivedate,
        mobileno,
        tempno,
        tfa,
        lastcashierseries,
        passwordhash,
        passwordsalt,
        daterequestforgotpass,
        requestforgotpassguid,
        branchnos,
        digitalsignature,
        last_update_date
FROM
    (
        SELECT
        userno,
        usercode,
        username,
        userpass,
        useraccess,
        usertype,
        userpicture,
        nickname,
        activetask,
        activeuser,
        lastaccess,
        workstation,
        rememberpc,
        branchno,
        subbranchno,
        departmentno,
        emailadd,
        defaultdir,
        passwordlock,
        passwordexpiry,
        strongpassword,
        invalidtime,
        invalidattempt,
        accountindex,
        designation,
        cashier,
        employeeno,
        rowmarker,
        divisioncode,
        dashboard,
        datecreated,
        inactivedate,
        mobileno,
        tempno,
        tfa,
        lastcashierseries,
        passwordhash,
        passwordsalt,
        daterequestforgotpass,
        requestforgotpassguid,
        branchnos,
        digitalsignature,
        last_update_date,
            ROW_NUMBER() OVER (
                PARTITION BY
                    userno
                ORDER BY
                    CASE
                        WHEN last_update_date IS NULL THEN 1
                        ELSE 0
                    END,
                    last_update_date desc
            ) AS Row_Num
        FROM
            adw_prod_tgt.TBLUSERS
        WHERE
            userno IN (
                SELECT
                    userno
                FROM
                    adw_prod_tgt.TBLUSERS
                GROUP BY
                    userno
                HAVING
                    COUNT(*) > 1
            )
    )
WHERE
    Row_Num > 1;

COMMIT;

DELETE FROM adw_prod_tgt.TBLUSERS 
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
                            userno
                        ORDER BY
                            CASE
                                WHEN last_update_date IS NULL THEN 1
                                ELSE 0
                            END,
                            last_update_date DESC
                    ) AS Row_Num
                FROM
                    adw_prod_tgt.TBLUSERS
            )
        WHERE
            Row_Num > 1
    );

COMMIT;

-- --adw_prod_tgt.sp_adw_table_logs('TBLUSERS_HIST', 'SP_TEMP_MHI_TBLUSERS', SYSDATE, SYSDATE, 'UPDATE');

  END SP_TEMP_MHI_TBLUSERS;
 