create
or replace PROCEDURE SP_REPORT_MHI_LISTOFCORPORATEBILLINGS AS BEGIN

/******************************************************************************

NAME:       SP_REPORT_MHI_LISTOFCORPORATEBILLINGS
PURPOSE:   temp table to target

REVISIONS:
Ver          Date                  Author             Description
---------  ----------          ---------------  ------------------------------------
1.0        06/02/2025       Francis          1. Create SP_REPORT_MHI_LISTOFCORPORATEBILLINGS


NOTES:

 ******************************************************************************/

-- Logging the DELETE operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_LIST_OF_CORPORATE_BILLINGS', 'SP_REPORT_MHI_LISTOFCORPORATEBILLINGS', SYSDATE, '', 'DELETE');
-- Delete existing records from the target table 
DELETE FROM adw_prod_tgt.DS_LIST_OF_CORPORATE_BILLINGS
WHERE
    1 = 1
    AND TRUNC (invoice_date) >= TRUNC (SYSDATE);
COMMIT;
-- Logging the INSERT operation 
-- adw_prod_tgt.sp_adw_table_logs('DS_LIST_OF_CORPORATE_BILLINGS', 'SP_REPORT_MHI_LISTOFCORPORATEBILLINGS', SYSDATE, '', 'INSERT');
-- Insert new data into the target table
INSERT INTO
    adw_prod_tgt.DS_LIST_OF_CORPORATE_BILLINGS (
        agreement_no, --agreement number
        company_name, --company name
        sub_group, --sub group
        invoice_no,
        invoice_date,
        invoice_due,
        vat_type,
        status,
        billing_schedule,
        billing_for,
        bill_type,
        bill_amount,
        gross_amount,
        adjustment,
        vat_amount,
        paid_amount,
        balance,
        soa_no,
        aging,
        jv_no,
        jv_no_reversal,
        period_covered,
        generated, --generatedby
        generated_by --generatedname
    )
SELECT
    NVL (LTRIM (RTRIM (b.contractno)), '') AS agreementno,
    LTRIM (RTRIM (NVL (decoder (b.ldflog, 0), ''))) AS companyname,
    NVL (LTRIM (RTRIM (g.divisionname)), '') AS subgroup,
    LTRIM (RTRIM (a.soano)) AS invoiceno,
    TRUNC (a.soadate) AS invoicedate,
    TRUNC (a.soadue) AS invoicedue,
    CASE a.vattype
        WHEN 1 THEN 'VATable'
        WHEN 2 THEN 'VAT-Exempt'
        WHEN 3 THEN 'Zero-Rated'
        WHEN 4 THEN 'Non-Vat'
        ELSE ''
    END AS vattype,
    NVL (LTRIM (RTRIM (d.statusname)), '') AS status,
    CASE a.billingschedule
        WHEN 1 THEN 'MONTHLY'
        WHEN 2 THEN 'QUARTERLY'
        WHEN 3 THEN 'SEMI-ANNUAL'
        WHEN 4 THEN 'ANNUAL'
        ELSE ''
    END AS billingschedule,
    NVL (LTRIM (RTRIM (f.description)), '') AS billfor,
    CASE a.soatype
        WHEN 1 THEN 'MODAL'
        WHEN 2 THEN 'INITIAL'
        WHEN 3 THEN 'RENEWAL'
        WHEN 5 THEN 'OTHER'
        ELSE ''
    END AS billtype,
    CASE
        WHEN a.billtype = 1 THEN a.soaamount - a.adjamount
        ELSE a.soaamount - a.adjamount - a.discount
    END AS billamount,
    a.soaamount AS grossamount,
    a.adjamount AS adjustment,
    a.vatoutput AS vatamount,
    (a.paidamount + a.additionalpay) AS paidamount,
    CASE
        WHEN a.billtype = 1 THEN a.soaamount - a.paidamount - a.adjamount
        ELSE a.soaamount - a.paidamount - a.discount - a.adjamount
    END AS balance,
    NVL (LTRIM (RTRIM (i.consolidatedsoano)), '') AS soano,
    CASE
        WHEN UPPER(NVL (LTRIM (RTRIM (d.statusname)), '')) = 'CANCELLED' THEN '0 days'
        ELSE REPLACE (
            GetSOAAging (
                CASE
                    WHEN a.soadueextension <> TO_DATE ('1900-01-01', 'YYYY-MM-DD') THEN a.soadueextension
                    ELSE a.soadue
                END,
                a.paidamount
            ),
            '-',
            ''
        )
    END AS aging,
    LTRIM (RTRIM (a.jvnoar)) AS jvno,
    LTRIM (RTRIM (a.jvnoreversal)) AS jvnoreversal,
    TO_CHAR (a.coveredfrom, 'MM/DD/YYYY') || ' - ' || TO_CHAR (a.coveredto, 'MM/DD/YYYY') AS periodcovered,
    TRUNC (a.dategenerated) AS generated,
    NVL (LTRIM (RTRIM (c.username)), '') AS generatedbyname
FROM
    tblsoaaccounts a
    LEFT JOIN (
        SELECT
            compcode,
            contractno,
            ldflog,
            streetaddress,
            citycode,
            provincecode,
            tinno
        FROM
            tblcompany
    ) b ON a.compcode = b.compcode
    LEFT JOIN (
        SELECT
            userno,
            username
        FROM
            tblusers
    ) c ON a.generatedby = c.userno
    LEFT JOIN (
        SELECT
            statusno,
            statusname,
            statusfor
        FROM
            tblstatus
        WHERE
            statusfor = 'SOA'
    ) d ON a.statuscode = d.statusno
    LEFT JOIN (
        SELECT
            recordno,
            recordcode,
            description,
            tablename
        FROM
            tblgentables
        WHERE
            tablename = 'BILLTYPE'
    ) f ON a.billtype = f.recordno
    LEFT JOIN (
        SELECT
            compcode,
            divisioncode,
            divisionname
        FROM
            tblcompanydivision
    ) g ON b.compcode = g.compcode
    AND a.policydivision = g.divisioncode
    LEFT JOIN (
        SELECT
            consolidatedcode,
            consolidatedsoano
        FROM
            tblsoaconsolidated
    ) i ON a.consolidatedcode = i.consolidatedcode
WHERE
    1 = 1
    AND TRUNC(a.soadate) = TRUNC(sysdate) - 1 -- incremental
ORDER BY
    a.soadate DESC;
COMMIT;
-- Logging the UPDATE operation (uncomment if needed)
-- adw_prod_tgt.sp_adw_table_logs('DS_LIST_OF_CORPORATE_BILLINGS', 'SP_REPORT_MHI_LISTOFCORPORATEBILLINGS', SYSDATE, SYSDATE, 'UPDATE');



   END SP_REPORT_MHI_LISTOFCORPORATEBILLINGS;
 