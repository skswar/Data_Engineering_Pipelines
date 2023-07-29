IF EXISTS(SELECT 1 FROM sys.procedures WHERE object_id=OBJECT_ID(N'[dbo].[load_Environmental_Table]'))
	DROP PROCEDURE [dbo].[load_Environmental_Table]
GO

CREATE PROCEDURE [dbo].[load_Environmental_Table]
AS 
BEGIN
	SET NOCOUNT ON

	UPDATE PRD
	SET
		 PRD.Date_UTC = STG.Date_UTC
		,PRD.Time_UTC = STG.Time_UTC
		,PRD.Date_EST = STG.Date_EST
		,PRD.Time_EST = STG.Time_EST
		,PRD.[Timestamp] = STG.[Timestamp]
		,PRD.Temperature_fahrenheit = STG.Temperature_fahrenheit
		,PRD.Dewpoint_fahrenheit = STG.Dewpoint_fahrenheit
		,PRD.ReltiveHumidity_rh = STG.ReltiveHumidity_rh
		,PRD.[Timestamphour] = CAST(FORMAT(STG.[Timestamp], 'yyyy-MM-dd hh tt') AS DATETIME)
		,Update_Date = GETDATE()
	FROM [dbo].[Environmental_Table_STG] STG
	INNER JOIN [dbo].[Environmental_Table_PRD] PRD
	ON PRD.[Timestamp] = STG.[Timestamp]

	DECLARE @@updatecount AS INT
	SELECT @@updatecount = @@ROWCOUNT

	INSERT INTO [dbo].[Environmental_Table_PRD]
	SELECT 

		 STG.Date_UTC
		,STG.Time_UTC
		,STG.Date_EST
		,STG.Time_EST
		,STG.[Timestamp]
		,STG.Temperature_fahrenheit
		,STG.Dewpoint_fahrenheit
		,STG.ReltiveHumidity_rh
		,CAST(FORMAT(STG.[Timestamp], 'yyyy-MM-dd hh tt') AS DATETIME) AS [Timestamphour]
		,GETDATE() AS Load_Date
		,NULL AS Update_Date
	FROM [dbo].[Environmental_Table_STG] STG
	LEFT JOIN [dbo].[Environmental_Table_PRD] PRD
	ON PRD.[Timestamp] = STG.[Timestamp]
	WHERE PRD.[Timestamp] IS NULL

	DECLARE @@insertcount AS INT
	SELECT @@insertcount = @@ROWCOUNT

	SELECT @@insertcount AS Rows_Inserted, @@updatecount AS Rows_Updated, GETDATE() as Load_Time

END
GO
