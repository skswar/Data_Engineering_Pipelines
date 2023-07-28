--Check if procedure exists
IF EXISTS(SELECT 1 FROM sys.procedures where object_id=OBJECT_ID(N'[dbo].[load_tablename_main_daily]'))
	DROP PROC [dbo].[load_tablename_main_daily] 
	GO

--create proceduer
CREATE PROCEDURE [dbo].[load_tablename_main_daily]
AS
BEGIN
		SET NOCOUNT ON

		TRUNCATE TABLE [destinationdb].[dbo].[destination_tablename_STG]
		DECLARE @@maxtime AS DATETIME
		SELECT @@maxtime = MAX([measurementtime]) FROM [destinationdb].[dbo].[destination_tablename_main]

		--Load Stage Table
		INSERT INTO [destinationdb].[dbo].[destination_tablename_STG] ([size],[measurementtime],[area],[locx],[locy],[height])
		SELECT
			   [size]
			  ,[measurementtime]
			  ,[area]
			  ,[loc_x]
			  ,[loc_y]			
			  ,[height]
		FROM [sourcedb].[dbo].[source_tablename_main](NOLOCK)
		WHERE [measurementtime] > @@maxtime
		ORDER BY [measurementtime]

		--Apply calculations/data transformations on Stage
		UPDATE temp
		SET category = 
											CASE WHEN (loc_x=0 and loc_y=0) then 'misallgined'
												 WHEN (loc_x>=-10 and loc_x<=100) and (loc_y>=-10 and loc_y<=20) then 'lower-left'
												 WHEN (loc_x>=-10 and loc_x<=100) and (loc_y>20 and loc_y<=50) then 'mid-left'
												 WHEN (loc_x>=-10 and loc_x<=100) and (loc_y>50 and loc_y<=100) then 'upper-left'
												 WHEN (loc_x>100 and loc_x<=200) and (loc_y>=-10 and loc_y<=20 then 'lower-mid'
												 WHEN (loc_x>100 and loc_x<=200) and (loc_y>20 and loc_y<=50) then 'mid'
												 WHEN (loc_x>100 and loc_x<=200) and (loc_y>50 and loc_y<=100) then 'upper-mid'
												 WHEN (loc_x>200 and loc_x<=400) and (loc_y>=-10 and loc_y<=20  then 'lower-right'
												 WHEN (loc_x>200 and loc_x<=400) and (loc_y>20 and loc_y<=50)  then 'mid-right'
												 WHEN (loc_x>200 and loc_x<=400) and (loc_y>50 and loc_y<=100) then 'upper-right'
												 ELSE 'misallgined'
											END	
		FROM [destinationdb].[dbo].[destination_tablename_STG] temp (NOLOCK)
		WHERE [size]='x'

		UPDATE temp
		SET defect_location_category = 
											CASE WHEN (loc_x=0 and loc_y=0) then 'misallgined'
												 WHEN (loc_x>=-10 and loc_x<=100) and (loc_y>=-10 and loc_y<=20) then 'lower-left'
												 WHEN (loc_x>=-10 and loc_x<=100) and (loc_y>20 and loc_y<=50) then 'mid-left'
												 WHEN (loc_x>=-10 and loc_x<=100) and (loc_y>50 and loc_y<=100) then 'upper-left'
												 WHEN (loc_x>100 and loc_x<=200) and (loc_y>=-10 and loc_y<=20 then 'lower-mid'
												 WHEN (loc_x>100 and loc_x<=200) and (loc_y>20 and loc_y<=50) then 'mid'
												 WHEN (loc_x>100 and loc_x<=200) and (loc_y>50 and loc_y<=100) then 'upper-mid'
												 WHEN (loc_x>200 and loc_x<=400) and (loc_y>=-10 and loc_y<=20  then 'lower-right'
												 WHEN (loc_x>200 and loc_x<=400) and (loc_y>20 and loc_y<=50)  then 'mid-right'
												 WHEN (loc_x>200 and loc_x<=400) and (loc_y>50 and loc_y<=100) then 'upper-right'
												 ELSE 'misallgined'
											END	
		FROM [destinationdb].[dbo].[destination_tablename_STG] temp (NOLOCK)
		WHERE [size]='y'

		UPDATE temp
		SET defect_location_category = 
											CASE WHEN (loc_x=0 and loc_y=0) then 'misallgined'
												 WHEN (loc_x>=-10 and loc_x<=100) and (loc_y>=-10 and loc_y<=20) then 'lower-left'
												 WHEN (loc_x>=-10 and loc_x<=100) and (loc_y>20 and loc_y<=50) then 'mid-left'
												 WHEN (loc_x>=-10 and loc_x<=100) and (loc_y>50 and loc_y<=100) then 'upper-left'
												 WHEN (loc_x>100 and loc_x<=200) and (loc_y>=-10 and loc_y<=20 then 'lower-mid'
												 WHEN (loc_x>100 and loc_x<=200) and (loc_y>20 and loc_y<=50) then 'mid'
												 WHEN (loc_x>100 and loc_x<=200) and (loc_y>50 and loc_y<=100) then 'upper-mid'
												 WHEN (loc_x>200 and loc_x<=400) and (loc_y>=-10 and loc_y<=20  then 'lower-right'
												 WHEN (loc_x>200 and loc_x<=400) and (loc_y>20 and loc_y<=50)  then 'mid-right'
												 WHEN (loc_x>200 and loc_x<=400) and (loc_y>50 and loc_y<=100) then 'upper-right'
												 ELSE 'misallgined'
											END	
		FROM [destinationdb].[dbo].[destination_tablename_STG] temp (NOLOCK)
		WHERE [size]='z'

		--Data transformation on stage
		UPDATE [destinationdb].[dbo].[destination_tablename_STG]
		SET hour_col = CAST(FORMAT([measurementtime], 'yyyy-MM-dd hh tt') AS DATETIME)

		--Finally load into main table
		INSERT INTO [destinationdb].[dbo].[destination_tablename_main]
		SELECT * FROM [destinationdb].[dbo].[destination_tablename_STG](NOLOCK)

		--select information to send in email
		DECLARE @@cnt AS INT 
		SELECT @@cnt = COUNT(1) FROM [destinationdb].[dbo].[destination_tablename_STG](NOLOCK)

		SELECT @@cnt AS Total, GETDATE() AS Load_Time

END
GO