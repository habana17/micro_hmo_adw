create
or replace PROCEDURE SP_REPORT_MHI_DSAGINGREPORT AS BEGIN

/******************************************************************************

NAME:      SP_REPORT_MHI_DSAGINGREPORT
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        05/30/2025           Francis          1. Create SP_REPORT_MHI_DSAGINGREPORT
1.1        06/05/2025           Francis          1. Added ds_aging_report_hist


NOTES:

 ******************************************************************************/

----------------------VOID----------------------
-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_AGING_REPORT', 'SP_REPORT_MHI_DSAGINGREPORT', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
-- DELETE FROM adw_prod_tgt.DS_AGING_REPORT
-- WHERE 1=1
-- AND TRUNC() >= TRUNC(SYSDATE);
-- no need to have delete since there is no parameter to be used in the report
----------------------VOID----------------------


--COMMIT;
--Logging the INSERT operation 
--adw_prod_tgt.sp_adw_table_logs('DS_AGING_REPORT', 'SP_REPORT_MHI_DSAGINGREPORT', SYSDATE, '', 'INSERT');
--Insert new data into the target table
INSERT INTO
    adw_prod_tgt.DS_AGING_REPORT (
        client_no, -- Client Number
        client_name, -- Client Name
        effectivity_date, -- Effectivity Date
        inception_date, -- Inception Date
        expiry_date, -- Expiry Date
        issuing_ref, -- Issuing Reference
        pol_yr, -- Policy Year
        pol_no, -- Policy Number
        bill_no, -- Bill Number
        intm_code, -- Intermediary Code
        intm_name, -- Intermediary Name
        other_prem, -- Other Premium
        p_tax_vat, -- Premium Tax VAT
        other_charges, -- Other Charges
        notyetdue, -- Not Yet Due
        within30days, -- Within 30 Days
        a31to60, -- A31 to 60 Days
        a61to90, -- A61 to 90 Days
        a91to120, -- A91 to 120 Days
        a121to150, -- A121 to 150 Days
        a151to180, -- A151 to 180 Days
        a181to210, -- A181 to 210 Days
        a211to240, -- A211 to 240 Days
        a241to270, -- A241 to 270 Days
        a271to300, -- A271 to 300 Days
        a301to330, -- A301 to 330 Days
        a331to360, -- A331 to 360 Days
        over360, -- Over 360 Days
        total_amount, -- Total Amount
        payment, -- Payment
        balance, -- Balance
        currency_cd, -- Currency Code
        policy_status, -- Policy Status
        abl_mbl, -- Abl/Mbl
        user_id, -- User ID
        issue_date, -- Issue Date
        product_cd, -- Product Code
        product_channel_cd, -- Product Channel Code
        provincial_office, -- Provincial Office
        location_cd, -- Location Code
        soadate,
        last_update_date,
        datepaid 
    )
SELECT
    LTRIM (RTRIM (NVL (b.contractno, ''))) AS clientno, --client_no
    LTRIM (RTRIM (NVL (decoder (b.ldflog, 0), ''))) AS clientname, --client_name
    -- NVL (
    --     TRUNC (b.effectivity),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS effectivity, --effectivity_date
    TRUNC (b.effectivity) AS effectivity, --update 06302025
    -- NVL (
    --     TRUNC (b.dateenrolled),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS inceptiondate, --inception_date
    TRUNC (b.dateenrolled) AS inceptiondate,--update 06302025
    -- NVL (
    --     TRUNC (b.expiry),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS expiry, --expiry_date
    TRUNC (b.expiry) AS expiry, --update 06302025
    LTRIM (RTRIM (NVL (g.locationname, ''))) AS issuingref, --issuing_ref
    -- NVL (
    --     TRUNC (b.effectivity),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS polyr, --pol_yr
    TRUNC (b.effectivity) AS polyr, --update 06302025
    LTRIM (RTRIM (NVL (b.contractno, ''))) AS polno, --pol_no
    LTRIM (RTRIM (a.soano)) AS billno, --bill_no
    LTRIM (RTRIM (NVL (e.agentcode, ''))) AS intmcode, --intm_code
    LTRIM (RTRIM (NVL (e.agentname, ''))) AS intmname, --intm_name
    '0.00' AS otherprem, --other_prem
    a.vatamount AS premtaxvat, --p_tax_vat
    '0.00' AS othercharges, --other_charges
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) = 0 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS notyetdue, --notyetdue
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 30
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <> 0 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS within30days, --within30days
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 31
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 60 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a31to60, --a31to60
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 61
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 90 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a61to90, --a61to90
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 91
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 120 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a91to120, --a91to120
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 121
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 150 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a121to150, --a121to150
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 151
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 180 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a151to180, --a151to180
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 181
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 210 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a181to210,
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 211
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 240 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a211to240,
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 241
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 270 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a241to270,
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 271
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 300 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a271to300,
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 301
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 330 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a301to330,
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) >= 331
        AND CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) <= 360 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS a331to360,
    CASE
        WHEN CAST(
            REPLACE (
                REPLACE (
                    REPLACE (
                        GetSOAAging (
                            CASE
                                WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                                ELSE a.soadue
                            END,
                            a.paidamount
                        ),
                        '-',
                        ''
                    ),
                    'day/s',
                    ''
                ),
                'day',
                ''
            ) AS INT
        ) > 360 THEN CASE
            WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
            ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
        END
        ELSE 0.00
    END AS over360,
    CASE
        WHEN a.billtype = 1 THEN a.soaamount - a.adjamount
        ELSE a.soaamount - a.discount
    END AS totalamount, --total_amount
    a.paidamount AS payment, -- payment
    CASE
        WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
        ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
    END AS balance, --balance
    'PHP' AS currencycd, --currency_cd
    NVL (d.statusname, '') AS polstatus, --policy_status
    h.limitamount AS tsiamount, --abl_mbl
    NVL (f.username, '') AS userid, --user_id
    -- NVL (
    --     CAST(b.effectivity AS DATE),
    --     TO_DATE ('1900-01-01', 'YYYY-MM-DD')
    -- ) AS issuedate, --issue_date
    CAST(b.effectivity AS DATE) AS issuedate, --updated 06302025
    NVL (LTRIM (RTRIM (i.productlinecode)), '') AS productcode, --product_cd 
    NVL (b.channel, '') as product_channel_cd, -- added by francis 05212025
    NVL (m.locationname, '') as provincial_office, -- added by francis 05212025
    'HO' as location_cd, -- added by francis 05212025
    -- a.soadate,
    CASE 
        WHEN a.soadate = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE a.soadate 
    END AS soadate, --updated 06302025
    --a.last_update_date,
    CASE 
        WHEN a.last_update_date = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE a.last_update_date 
    END AS last_update_date, --updated 06302025
    --a.datepaid
        CASE 
        WHEN a.datepaid = TO_DATE('01/01/1900', 'MM/DD/YYYY') THEN NULL 
        ELSE a.datepaid 
    END AS datepaid --updated 06302025
FROM
    tblsoaaccounts a
    LEFT JOIN tblcompany b ON b.compcode = a.compcode
    LEFT JOIN tblstatus c ON a.statuscode = c.statusno
    AND c.statusfor = 'SOA'
    LEFT JOIN tblstatus d ON b.statuscode = d.statusno
    AND d.statusfor = 'CORPORATE'
    LEFT JOIN tblagents e ON e.agentno = b.agentno
    LEFT JOIN tblusers f ON f.userno = a.generatedby
    LEFT JOIN tbllocations g ON g.locationcode = f.branchno
    AND g.locationtype = 'BRANCH'
    LEFT JOIN (
        SELECT
            h.compcode,
            h.contractcode,
            CASE
                WHEN SUM(
                    CASE
                        WHEN h.limitamount > 0 THEN h.limitamount
                        ELSE 0
                    END
                ) > 0 THEN SUM(
                    CASE
                        WHEN h.limitamount > 0 THEN h.limitamount
                        ELSE 0
                    END
                )
                ELSE -1
            END AS limitamount
        FROM
            tblcompanybenefitplan h
        GROUP BY
            h.compcode,
            h.contractcode
    ) h ON h.compcode = a.compcode
    AND h.contractcode = h.contractcode
    LEFT JOIN tblproductlines i ON b.productcode = i.productcode
    LEFT JOIN tbllocations m ON m.locationcode = b.branch
    and b.branch <> 0 -- added by francis 05212025
WHERE
    UPPER(c.statusname) <> 'CANCELLED'
    AND TRUNC(a.last_update_date) = TRUNC(sysdate) - 1  --- for incremental loading 
ORDER BY
    a.soano;
COMMIT;
--Logging the UPDATE operation (uncomment if needed)
--adw_prod_tgt.sp_adw_table_logs('DS_AGING_REPORT', 'SP_REPORT_MHI_DSAGINGREPORT', SYSDATE, SYSDATE, 'UPDATE');





--transfer old data to history 
--adw_prod_tgt.sp_adw_table_logs('DS_AGING_REPORT_HIST', 'SP_REPORT_MHI_DSAGINGREPORT', SYSDATE, '', 'INSERT');
INSERT INTO
    adw_prod_tgt.DS_AGING_REPORT_HIST (
        client_no, -- Client Number
        client_name, -- Client Name
        effectivity_date, -- Effectivity Date
        inception_date, -- Inception Date
        expiry_date, -- Expiry Date
        ------1------
        issuing_ref, -- Issuing Reference
        pol_yr, -- Policy Year
        pol_no, -- Policy Number
        bill_no, -- Bill Number
        intm_code, -- Intermediary Code
        ------2------
        intm_name, -- Intermediary Name
        other_prem, -- Other Premium
        p_tax_vat, -- Premium Tax VAT
        other_charges, -- Other Charges
        notyetdue, -- Not Yet Due
        within30days, -- Within 30 Days
        a31to60, -- A31 to 60 Days
        a61to90, -- A61 to 90 Days
        a91to120, -- A91 to 120 Days
        a121to150, -- A121 to 150 Days
        a151to180, -- A151 to 180 Days
        a181to210, -- A181 to 210 Days
        a211to240, -- A211 to 240 Days
        a241to270, -- A241 to 270 Days
        a271to300, -- A271 to 300 Days
        a301to330, -- A301 to 330 Days
        a331to360, -- A331 to 360 Days
        over360, -- Over 360 Days
        total_amount, -- Total Amount
        payment, -- Payment
        balance, -- Balance
        currency_cd, -- Currency Code
        policy_status, -- Policy Status
        abl_mbl, -- Abl/Mbl
        user_id, -- User ID
        issue_date, -- Issue Date
        product_cd, -- Product Code
        product_channel_cd, -- Product Channel Code
        provincial_office, -- Provincial Office
        location_cd, -- Location Code
        soadate,
        last_update_date,
        datepaid 
    )
SELECT
        client_no, -- Client Number
        client_name, -- Client Name
        effectivity_date, -- Effectivity Date
        inception_date, -- Inception Date
        expiry_date, -- Expiry Date
        issuing_ref, -- Issuing Reference
        pol_yr, -- Policy Year
        pol_no, -- Policy Number
        bill_no, -- Bill Number
        intm_code, -- Intermediary Code
        intm_name, -- Intermediary Name
        other_prem, -- Other Premium
        p_tax_vat, -- Premium Tax VAT
        other_charges, -- Other Charges
        notyetdue, -- Not Yet Due
        within30days, -- Within 30 Days
        a31to60, -- A31 to 60 Days
        a61to90, -- A61 to 90 Days
        a91to120, -- A91 to 120 Days
        a121to150, -- A121 to 150 Days
        a151to180, -- A151 to 180 Days
        a181to210, -- A181 to 210 Days
        a211to240, -- A211 to 240 Days
        a241to270, -- A241 to 270 Days
        a271to300, -- A271 to 300 Days
        a301to330, -- A301 to 330 Days
        a331to360, -- A331 to 360 Days
        over360, -- Over 360 Days
        total_amount, -- Total Amount
        payment, -- Payment
        balance, -- Balance
        currency_cd, -- Currency Code
        policy_status, -- Policy Status
        abl_mbl, -- Abl/Mbl
        user_id, -- User ID
        issue_date, -- Issue Date
        product_cd, -- Product Code
        product_channel_cd, -- Product Channel Code
        provincial_office, -- Provincial Office
        location_cd, -- Location Code
        soadate,
        last_update_date,
        datepaid 
FROM
    (
        SELECT
        client_no, -- Client Number
        client_name, -- Client Name
        effectivity_date, -- Effectivity Date
        inception_date, -- Inception Date
        expiry_date, -- Expiry Date
        issuing_ref, -- Issuing Reference
        pol_yr, -- Policy Year
        pol_no, -- Policy Number
        bill_no, -- Bill Number
        intm_code, -- Intermediary Code
        intm_name, -- Intermediary Name
        other_prem, -- Other Premium
        p_tax_vat, -- Premium Tax VAT
        other_charges, -- Other Charges
        notyetdue, -- Not Yet Due
        within30days, -- Within 30 Days
        a31to60, -- A31 to 60 Days
        a61to90, -- A61 to 90 Days
        a91to120, -- A91 to 120 Days
        a121to150, -- A121 to 150 Days
        a151to180, -- A151 to 180 Days
        a181to210, -- A181 to 210 Days
        a211to240, -- A211 to 240 Days
        a241to270, -- A241 to 270 Days
        a271to300, -- A271 to 300 Days
        a301to330, -- A301 to 330 Days
        a331to360, -- A331 to 360 Days
        over360, -- Over 360 Days
        total_amount, -- Total Amount
        payment, -- Payment
        balance, -- Balance
        currency_cd, -- Currency Code
        policy_status, -- Policy Status
        abl_mbl, -- Abl/Mbl
        user_id, -- User ID
        issue_date, -- Issue Date
        product_cd, -- Product Code
        product_channel_cd, -- Product Channel Code
        provincial_office, -- Provincial Office
        location_cd, -- Location Code
        soadate,
        last_update_date,
        datepaid ,
            ROW_NUMBER() OVER (
                PARTITION BY
                    bill_no
                ORDER BY
                    CASE
                        WHEN last_update_date IS NULL THEN 1
                        ELSE 0
                    END,
                    last_update_date DESC
            ) AS ROW_NUM
        FROM
            adw_prod_tgt.DS_AGING_REPORT
        WHERE
            bill_no IN (
                SELECT
                    bill_no
                FROM
                    adw_prod_tgt.DS_AGING_REPORT
                GROUP BY
                    bill_no
                HAVING
                    COUNT(*) > 1
            )
    )
WHERE
    ROW_NUM > 1;

COMMIT;

DELETE FROM adw_prod_tgt.DS_AGING_REPORT
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
                            bill_no
                        ORDER BY
                            CASE
                                WHEN last_update_date IS NULL THEN 1
                                ELSE 0
                            END,
                            last_update_date desc
                    ) AS row_num
                from
                    adw_prod_tgt.DS_AGING_REPORT
            )
        where
            row_num > 1
    );

COMMIT;


INSERT INTO
    adw_prod_tgt.ds_aging_report_hist (
    client_no, -- Client Number
        client_name, -- Client Name
        effectivity_date, -- Effectivity Date
        inception_date, -- Inception Date
        expiry_date, -- Expiry Date
        issuing_ref, -- Issuing Reference
        pol_yr, -- Policy Year
        pol_no, -- Policy Number
        bill_no, -- Bill Number
        intm_code, -- Intermediary Code
        intm_name, -- Intermediary Name
        other_prem, -- Other Premium
        p_tax_vat, -- Premium Tax VAT
        other_charges, -- Other Charges
        notyetdue, -- Not Yet Due
        within30days, -- Within 30 Days
        a31to60, -- A31 to 60 Days
        a61to90, -- A61 to 90 Days
        a91to120, -- A91 to 120 Days
        a121to150, -- A121 to 150 Days
        a151to180, -- A151 to 180 Days
        a181to210, -- A181 to 210 Days
        a211to240, -- A211 to 240 Days
        a241to270, -- A241 to 270 Days
        a271to300, -- A271 to 300 Days
        a301to330, -- A301 to 330 Days
        a331to360, -- A331 to 360 Days
        over360, -- Over 360 Days
        total_amount, -- Total Amount
        payment, -- Payment
        balance, -- Balance
        currency_cd, -- Currency Code
        policy_status, -- Policy Status
        abl_mbl, -- Abl/Mbl
        user_id, -- User ID
        issue_date, -- Issue Date
        product_cd, -- Product Code
        product_channel_cd, -- Product Channel Code
        provincial_office, -- Provincial Office
        location_cd, -- Location Code
        soadate,
        last_update_date,
        datepaid 
    )
SELECT
    client_no, -- Client Number
        client_name, -- Client Name
        effectivity_date, -- Effectivity Date
        inception_date, -- Inception Date
        expiry_date, -- Expiry Date
        issuing_ref, -- Issuing Reference
        pol_yr, -- Policy Year
        pol_no, -- Policy Number
        bill_no, -- Bill Number
        intm_code, -- Intermediary Code
        intm_name, -- Intermediary Name
        other_prem, -- Other Premium
        p_tax_vat, -- Premium Tax VAT
        other_charges, -- Other Charges
        notyetdue, -- Not Yet Due
        within30days, -- Within 30 Days
        a31to60, -- A31 to 60 Days
        a61to90, -- A61 to 90 Days
        a91to120, -- A91 to 120 Days
        a121to150, -- A121 to 150 Days
        a151to180, -- A151 to 180 Days
        a181to210, -- A181 to 210 Days
        a211to240, -- A211 to 240 Days
        a241to270, -- A241 to 270 Days
        a271to300, -- A271 to 300 Days
        a301to330, -- A301 to 330 Days
        a331to360, -- A331 to 360 Days
        over360, -- Over 360 Days
        total_amount, -- Total Amount
        payment, -- Payment
        balance, -- Balance
        currency_cd, -- Currency Code
        policy_status, -- Policy Status
        abl_mbl, -- Abl/Mbl
        user_id, -- User ID
        issue_date, -- Issue Date
        product_cd, -- Product Code
        product_channel_cd, -- Product Channel Code
        provincial_office, -- Provincial Office
        location_cd, -- Location Code
        soadate,
        last_update_date,
        datepaid 
FROM
    (
        SELECT
            client_no, -- Client Number
        client_name, -- Client Name
        effectivity_date, -- Effectivity Date
        inception_date, -- Inception Date
        expiry_date, -- Expiry Date
        issuing_ref, -- Issuing Reference
        pol_yr, -- Policy Year
        pol_no, -- Policy Number
        bill_no, -- Bill Number
        intm_code, -- Intermediary Code
        intm_name, -- Intermediary Name
        other_prem, -- Other Premium
        p_tax_vat, -- Premium Tax VAT
        other_charges, -- Other Charges
        notyetdue, -- Not Yet Due
        within30days, -- Within 30 Days
        a31to60, -- A31 to 60 Days
        a61to90, -- A61 to 90 Days
        a91to120, -- A91 to 120 Days
        a121to150, -- A121 to 150 Days
        a151to180, -- A151 to 180 Days
        a181to210, -- A181 to 210 Days
        a211to240, -- A211 to 240 Days
        a241to270, -- A241 to 270 Days
        a271to300, -- A271 to 300 Days
        a301to330, -- A301 to 330 Days
        a331to360, -- A331 to 360 Days
        over360, -- Over 360 Days
        total_amount, -- Total Amount
        payment, -- Payment
        balance, -- Balance
        currency_cd, -- Currency Code
        policy_status, -- Policy Status
        abl_mbl, -- Abl/Mbl
        user_id, -- User ID
        issue_date, -- Issue Date
        product_cd, -- Product Code
        product_channel_cd, -- Product Channel Code
        provincial_office, -- Provincial Office
        location_cd, -- Location Code
        soadate,
        last_update_date,
        datepaid ,
            ROW_NUMBER() OVER (
                PARTITION BY
                    bill_no
                ORDER BY
                    CASE
                        WHEN datepaid IS NULL THEN 1
                        ELSE 0
                    END,
                    datepaid DESC
            ) AS ROW_NUM
        FROM
            adw_prod_tgt.DS_AGING_REPORT
        WHERE
            bill_no IN (
                SELECT
                    bill_no
                FROM
                    adw_prod_tgt.DS_AGING_REPORT
                GROUP BY
                    bill_no
                HAVING
                    COUNT(*) > 1
            )
    )
WHERE
    ROW_NUM > 1;

COMMIT;

DELETE FROM adw_prod_tgt.DS_AGING_REPORT
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
                            bill_no
                        ORDER BY
                            CASE
                                WHEN datepaid IS NULL THEN 1
                                ELSE 0
                            END,
                            datepaid desc
                    ) AS row_num
                from
                    adw_prod_tgt.DS_AGING_REPORT
            )
        where
            row_num > 1
    );

COMMIT;


--adw_prod_tgt.sp_adw_table_logs('DS_AGING_REPORT_HIST', 'SP_REPORT_MHI_DSAGINGREPORT', SYSDATE, SYSDATE, 'UPDATE');




 END SP_REPORT_MHI_DSAGINGREPORT;
 