CREATE OR REPLACE PROCEDURE sp_util_per_month 
AS
BEGIN


/******************************************************************************

NAME:       sp_util_per_month
PURPOSE:   create data for list of utilization per month 

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/22/2025              Francis          1. create sp_util_per_month
1.0        05/22/2025              Francis          1. create temp tables temp_utilization,temp_totalutilization,temp_ds_list_util_month

NOTES:

 ******************************************************************************/


    -- truncate temporary tables
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_utilization';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_totalutilization';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_ds_list_util_month';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;    


    -- Insert into temp_utilization
    INSERT INTO temp_utilization (dateavailed, claimtype, casetype, finalamount)
    SELECT a.dateavailed, a.claimtype, a.casetype, GetClaimPayable2('', a.provideramount, a.roomamount, a.pfamount, a.refundamount,
                     a.duetomember, a.phamount, a.discount, a.pfdiscount, a.finalreamount, a.eobamount, a.casetype,
                     a.npamount, a.nppfamount, a.refundamountpf, a.phpfamount, a.pfadjapproved, a.hbadjapproved, a.pfadjdisapproved, a.hbadjdisapproved)
    FROM tblclaims a
    WHERE a.claimcode <> 0 AND a.caseno IS NOT NULL
     AND EXTRACT(YEAR FROM a.dateavailed) =  EXTRACT(YEAR FROM SYSDATE -1)
     ;

    -- Insert distinct months into temp_totalutilization
    INSERT INTO temp_totalutilization (month, monthno)
    SELECT DISTINCT TO_CHAR(dateavailed, 'MONTH YYYY'), EXTRACT(MONTH FROM dateavailed)
    FROM temp_utilization;

    -- Update IP Cases
    UPDATE temp_totalutilization t
    SET (ipcases, ipamount) = (
        SELECT COUNT(*), NVL(SUM(finalamount), 0)
        FROM temp_utilization u
        WHERE u.claimtype = 2 AND u.casetype = 0 AND TO_CHAR(u.dateavailed, 'MONTH YYYY') = t.month
    );

    -- Update OP Cases
    UPDATE temp_totalutilization t
    SET (opcases, opamount) = (
        SELECT COUNT(*), NVL(SUM(finalamount), 0)
        FROM temp_utilization u
        WHERE u.claimtype = 1 AND u.casetype = 0 AND TO_CHAR(u.dateavailed, 'MONTH YYYY') = t.month
    );

    -- Update Reim Cases
    UPDATE temp_totalutilization t
    SET (reimcases, reimamount) = (
        SELECT COUNT(*), NVL(SUM(finalamount), 0)
        FROM temp_utilization u
        WHERE u.casetype = 1 AND TO_CHAR(u.dateavailed, 'MONTH YYYY') = t.month
    );

    -- Update APE Cases
    UPDATE temp_totalutilization t
    SET (apecases, apeamount) = (
        SELECT COUNT(*), NVL(SUM(finalamount), 0)
        FROM temp_utilization u
        WHERE u.casetype = 0 AND u.claimtype = 3 AND TO_CHAR(u.dateavailed, 'MONTH YYYY') = t.month
    );

    -- Update Total Utilization
    UPDATE temp_totalutilization
    SET totalutil = NVL(ipamount, 0) + NVL(opamount, 0) + NVL(reimamount, 0) + NVL(apeamount, 0);

    -- Insert final results into temp_ds_list_util_month
    INSERT INTO temp_ds_list_util_month (
        month, ipcases, ipamount, opcases, opamount, 
        reimcases, reimamount, apecases, apeamount, totalutil
    )
    SELECT 
        month, ipcases, ipamount, opcases, opamount, 
        reimcases, reimamount, apecases, apeamount, totalutil
    FROM temp_totalutilization
    order by monthno;

    -- Cleanup
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_utilization';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_totalutilization';

    DBMS_OUTPUT.PUT_LINE('Data successfully inserted into temp_ds_list_util_month.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END sp_util_per_month;
/
