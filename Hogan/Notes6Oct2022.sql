USE [990000153_Hogan_R1]
GO
/****** Object:  StoredProcedure [firmcentral].[usp_insert_staging_Notes]    Script Date: 9/30/2022 2:11:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[firmcentral].[usp_insert_staging_Notes]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 	'[firmcentral].[usp_insert_staging_Notes] has been created in [990000153_Hogan_S1] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _ST1_ */
		/*================================================================================================*/
		
		INSERT INTO
		-- delete from
			[PT1].[Notes]
			--filevinestaging2import.._HoganT1_Notes___54762
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__NoteID]
				, [NoteExternalID]
				, [ProjectExternalID]
				, [Author]
				, [Body]
				, [CreateDate]
				, [Assignee]
				, [TargetDate]
				, [CompletedDate]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__NoteID]
			, concat('N_',ccm.ProjectExternalID) [NoteExternalID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, case when SUBSTRING(m.[MatterParticipants],0,CHARINDEX(';',m.[MatterParticipants])) = 'J Blaney' then 'joyblaney'
					when SUBSTRING(m.[MatterParticipants],0,CHARINDEX(';',m.[MatterParticipants])) = 'Robert Hogan' then 'roberthogan'
					when SUBSTRING(m.[MatterParticipants],0,CHARINDEX(';',m.[MatterParticipants])) = 'Jessica Jones' then 'jessicajones'
					when SUBSTRING(m.[MatterParticipants],0,CHARINDEX(';',m.[MatterParticipants])) = 'Lindsey Duran' then 'lindseyduran'
					when SUBSTRING(m.[MatterParticipants],0,CHARINDEX(';',m.[MatterParticipants])) = 'Norma Tambunga' then 'normatambunga' 
					else 'datamigrationteam280' 
				end [Author]
			,
		
			NULLIF(
			CONCAT('Description: ', m.[description], CHAR(13), 'Insurance: ', m.[Insurance_1] , CHAR(13), 'Insurance Policy: ', m.[InsurancePolicy_1], CHAR(13),'Insurance Policy 2: ', m.[InsurancePolicy_2] ,CHAR(13), 'Insurance Policy 3: ', m.[InsurancePolicy_3], CHAR(13) ,'Demands and Offers: ', m.[DemandsandOffers] , CHAR(13), 'Liens: ', m.[Liens], CHAR(13), 'Memo: ', m.[memo], CHAR(13), '#migratednotes') 
			, CONCAT('Description: ', CHAR(13), 'Insurance: ',  CHAR(13), 'Insurance Policy: ', CHAR(13),'Insurance Policy 2: ',CHAR(13), 'Insurance Policy 3: ', CHAR(13) ,'Demands and Offers: ', CHAR(13), 'Liens: ', CHAR(13), 'Memo: ', CHAR(13), '#migratednotes')
			) 
			-- 'Description: ', m.[description], CHAR(13), 
			[Body]
			--, [Filevine_META].dbo.udfDate_ConvertUTC(getdate(), 'Central' , 1) 
			, getdate() [CreateDate]
			, NULL [Assignee]
			, NULL [TargetDate]
			, NULL [CompletedDate]
	--SELECT * 
		FROM __FV_ClientCaseMap ccm
			join [Firm Central Matters_20220518] m 
			on ccm.CaseID = m.matternumber
			--where nullif(m.[memo],'') is not null
		
		-- 'Description: ', m.[description], CHAR(13), 

		--[Insurance_1]
  --    ,[InsurancePolicy_1]
  --    ,[InsurancePolicy_2]
  --    ,[InsurancePolicy_3]
  --    ,[DemandsandOffers]
  --    ,[Liens]

		-- all these fields need inserts
		--SELECt [Insurance_1]
  --    ,[InsurancePolicy_1]
  --    ,[InsurancePolicy_2]
  --    ,[InsurancePolicy_3]
  --    ,[DemandsandOffers]
  --    ,[Liens]
		--FROM [Firm Central Matters_20220518]

	END
														