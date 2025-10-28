CREATE OR REPLACE PROCEDURE sp_top_diagnosis 
AS
BEGIN
    /******************************************************************************
    NAME:       sp_top_diagnosis
    PURPOSE:    Create data for the top diagnoses based on total claims or total amount.

    REVISIONS:
    Ver          Date                  Author             Description
    ---------    ----------          ---------------  ------------------------------------
    1.0          06/02/2025          Francis           1. Create sp_top_diagnosis
  
    NOTES:
    ******************************************************************************/

   
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_ds_top_diagnosis';

    -- Insert data into temp_diagnosis
    INSERT INTO temp_diagnosis (icdno, claimpayable, claimcode, icdcode, icddisease)
    SELECT  DISTINCT
        NVL(b.icdno, null) AS icdno,
        GetClaimPayable(
            a.provideramount, a.roomamount, a.pfamount, a.refundamount,
            a.duetomember, a.phamount, a.discount, a.pfdiscount, a.finalreamount,
            a.eobamount, a.casetype, a.npamount, a.nppfamount, a.refundamountpf, a.phpfamount
        ) AS claimpayable,
        a.claimcode,
        NVL(c.icdcode, '') AS icdcode,
        NVL(c.icddisease, '') AS icddisease
    FROM tblclaims a
    LEFT JOIN tblclaimdiagnosis b ON a.claimcode = b.claimcode
    LEFT JOIN tblicdtable c ON b.icdno = c.icdno
    WHERE b.icdno <> 0
      AND (a.caseno IS NOT NULL OR a.caseno <> '')
      AND a.claimstatus NOT IN (99, 98, 10, 97, 96);

    -- Insert data into temp_topdiagnosis using ranking logic
    INSERT INTO temp_topdiagnosis (no, icdcode, diagnosis, totalclaims, totalamount, averageclaim)
    SELECT 
        ROW_NUMBER() OVER (
            ORDER BY COUNT(claimcode) DESC
        ) AS no,
        icdcode,
        icddisease AS diagnosis,
        COUNT(claimcode) AS totalclaims,
        SUM(claimpayable) AS totalamount,
        SUM(claimpayable) * 1.0 / NULLIF(COUNT(claimcode), 0) AS averageclaim
    FROM temp_diagnosis
    GROUP BY icdno, icdcode, icddisease;

    --insert results  to temp table
    INSERT INTO temp_ds_top_diagnosis (
        no,icdcode,diagnosis,no_of_cases,totalamount,averageclaim
    )
    SELECT 
        no, icdcode, UPPER(diagnosis), totalclaims, totalamount, averageclaim
    FROM temp_topdiagnosis
    ;
   

    -- Cleanup temporary tables
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_diagnosis';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_topdiagnosis';
END sp_top_diagnosis;
/
