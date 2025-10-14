CREATE PROCEDURE dbo.sp_hmo_monthly_report
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Call  existing sub-procedures 
    EXEC dbo.sp_m_dspremiumregister;
    EXEC dbo.sp_m_dscashdisbursement_reg;
    EXEC dbo.sp_m_dsclaimlistreport;
	EXEC dbo.sp_m_dsjournalvoucher;
    
END
GO

-- Usage:
EXEC dbo.sp_hmo_monthly_report;