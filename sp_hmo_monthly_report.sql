CREATE
OR
ALTER PROCEDURE dbo.sp_hmo_monthly_report AS BEGIN
SET
    NOCOUNT ON;

-- Call existing sub-procedures 
EXEC dbo.sp_m_dspremiumregister;

EXEC dbo.sp_m_dscashdisbursement_reg;

EXEC dbo.sp_m_dsclaimlistreport;

EXEC dbo.sp_m_dsaccountspayableregister;

EXEC dbo.sp_m_dsagingreport;

EXEC dbo.sp_m_dscashreceiptsregister;

EXEC dbo.sp_m_dsjournalvoucher;

EXEC dbo.sp_m_dslistofcorporatebillings;

EXEC dbo.sp_m_dslistutilmonth;

EXEC dbo.sp_m_dsproductionreport;

EXEC dbo.sp_m_dsrenewallist;

EXEC dbo.sp_m_dssummaryutilreport;

END GO