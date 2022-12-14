USE [990000153_Hogan_R1]
GO
/****** Object:  StoredProcedure [firmcentral].[usp_insert_staging_ExpensesQB]    Script Date: 10/26/2022 9:25:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[firmcentral].[usp_insert_staging_ExpensesQB]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT '[firmcentral].[usp_insert_staging_ExpensesQB] has been created in [990000153_Hogan_R1] database.  Please review and modifiy the procedure.'
			
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _Immigration_ */
		/*================================================================================================*/
		
		INSERT INTO
			[PT1].[Immigration_CL_ExpensesQB]
			--filevinestaging2import.._HoganT3__Immigration_CL_ExpensesQB_58600
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [expensetype]
				, [checknumber]
				, [notes]
				, [checkhistory]
				, [amountpaid]
				, [status]
				, [checkdate]
				, [moreinfo]
				, [date]
				, [invoiceuploadDocExternalID]
				, [title]
				, [payeeContactExternalID]
				, [amount]
				, [typeofcheck]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, concat_WS('_',ccm.ProjectExternalID, e.[ExpenseEntryDate], e.[value], e.expenseCode, e.[ExternalNarrative], e.quantity) [CollectionItemExternalID]
			,CASE
				WHEN a.fv_itemType = 'Courier/messenger'
				THEN 'Courier / Messenger'
				WHEN e.expenseCode = 'Filing Fee'
				THEN 'Court Filing Fee'
				WHEN e.expenseCode = 'Court Fees'
				THEN 'Court Costs'
				WHEN a.fv_itemType = 'Taxi/Uber/Parking'
				THEN 'Taxi / Uber / Parking'
				WHEN a.fv_itemType = 'Mileage'
				THEN NULL
				ELSE e.expenseCode
			  END AS [expensetype]
			, NULL [checknumber]
			, e.[ExternalNarrative] [notes]
			, NULL [checkhistory]
			, e.[Value] [amountpaid]
			, NULL [status]
			, NULL [checkdate]
			, NULL [moreinfo]
			, e.[ExpenseEntryDate] [date]
			, NULL [invoiceuploadDocExternalID]
			, NULL [title]
			, NULL [payeeContactExternalID]
			, e.[Value] [amount]
			, NULL [typeofcheck]
	-- select distinct *
			 -- SELECt distinct  
		FROM __FV_ClientCaseMap ccm
		 join pt1.projects p
		 on ccm.projectexternalid = p.projectexternalid
		INNER JOIN [dbo].[ExpensebyMatterReport 20220519 105120] e
			ON ccm.caseid = trim(e.matterid)
				--	WHERE filevine_projectTemplate = 'Immigration'
			OR p.projectname = TRIM(e.matter)
		LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_IM_ExpenseCodeAlign] a
			ON e.expenseCode = a.expenseCode
			--WHERE concat_WS('_',ccm.ProjectExternalID, e.[ExpenseEntryDate], e.[value], e.expenseCode, e.[ExternalNarrative]) = '0625_0625_09/25/2020_$326.42_filing fee'
			--order by 7 desc
		WHERE filevine_projectTemplate = 'Immigration'
			--AND p.projectexternalid IN ('0505_0507','0506_508')
			--AND concat_WS('_',ccm.ProjectExternalID, e.[ExpenseEntryDate], e.[value], e.expenseCode, e.[ExternalNarrative], e.quantity) not in (SELECT		collectionitemexternalid
			--			FROM filevinestaging2import.._HoganT3__Immigration_CL_ExpensesQB_58204
			--			)

		--SELECt *
		--FROM [ExpensebyMatterReport 20220519 105120]
		--WHERE client like '%HEALD%'

	
		
		
		
		SELECT *
		FROM pt1.projects
		WHERE projectname like '%heald%'

/*
		select distinct *
		FROM __FV_ClientCaseMap ccm -- 83 immigration cases
		INNER JOIN [dbo].[ExpensebyMatterReport 20220519 105120] e
			ON ccm.caseid = trim(e.matterid)
					WHERE filevine_projectTemplate = 'Immigration' -- down to 60 from 83

		LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_IM_ExpenseCodeAlign] a
			ON e.expenseCode = a.expenseCode
			--WHERE concat_WS('_',ccm.ProjectExternalID, e.[ExpenseEntryDate], e.[value], e.expenseCode, e.[ExternalNarrative]) = '0625_0625_09/25/2020_$326.42_filing fee'
			--order by 7 desc
		WHERE filevine_projectTemplate = 'Immigration'

		select distinct *
		FROM __FV_ClientCaseMap ccm -- 83 immigration cases
		WHERE filevine_projectTemplate = 'Immigration' -- down to 60 from 83
		AND caseid not IN (
						SELECt distinct MatterID
						FROM [dbo].[ExpensebyMatterReport 20220519 105120] 
						)

		SELECt distinct MatterID
		FROM [dbo].[ExpensebyMatterReport 20220519 105120] 
		--WHERE matterid like '%0795%'
		WHERE matterid in (0505,0506)



		SELECT *
		FROM pt1.projects
		WHERE projectTemplate != 'Immigration'
		order by projectname

		--Derek Wilson
		--0795
		
		--Heald
		--0505
		--0506
		
		--SELECT distinct [ExpenseCode]
		--SELECT *
		--FROM [dbo].[ExpensebyMatterReport 20220519 105120]

		--'Witness Fees' 
		--'Travel Expense' --
		--'Taxi / Uber / Parking' 
		--'Process Servers' 
		--'Postage' --
		--'Miscellaneous'  --
		--'Medical Treatment' 
		--'Medical Record' 
		--'Mediation / Arbitration' 
		--'Expert Fees' 
		--'Crash Report' 
		--'Court Reporter / Videographer' 
		--'Court Filing Fee' --
		--'Court Costs' 
		--'Courier / Messenger' --
		--'Copying' 
		--'Consultant'


		--'Witness Fees' OR [expensetype]='Travel Expense' OR [expensetype]='Taxi / Uber / Parking' OR [expensetype]='Process Servers' OR [expensetype]='Postage' OR [expensetype]='Miscellaneous' OR [expensetype]='Medical Treatment' OR [expensetype]='Medical Record' OR [expensetype]='Mediation / Arbitration' OR [expensetype]='Expert Fees' OR [expensetype]='Crash Report' OR [expensetype]='Court Reporter / Videographer' OR [expensetype]='Court Filing Fee' OR [expensetype]='Court Costs' 
		----SELECT *
		----FROM [PT1_CLIENT_ALIGN].[__FV_IM_ExpenseCodeAlign] 

		----'Consultant',
		----'Copying',
		--'Courier / Messenger','Court Costs',
		--'Court Filing Fee',
		--'Court Reporter / Videographer','Crash Report',
		--'Expert Fees','Mediation / Arbitration',
		--'Medical Record','Medical Treatment',
		--'Mileage','Miscellaneous','Postage','Taxi / Uber / Parking','Translations','Travel Expense','Witness Fees'

				--INNER JOIN 
				--	[__FV_ProjectTemplateMap] ptm 
				--		ON ptm.Legacy_Case_ID = ccm.CaseID 
		
		
		*/
				


		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _PersonalInjuryMaster_ */
		/*================================================================================================*/
		
		SELECT *
		FROM pt1.projects
		WHERe projectname like '%derek%'

		


		INSERT INTO
		-- select * from
			[PT1].[PersonalInjuryMaster_CL_ExpensesQB]
			--filevinestaging2import.._HoganT1__PersonalInjuryMaster_CL_ExpensesQB_54776
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [expenseType]
				, [checknumber]
				, [notes]
				, [checkhistory]
				, [amountpaid]
				, [status]
				, [checkdate]
				, [moreinfo]
				, [date]
				, [invoiceuploadDocExternalID]
				, [title]
				, [payeeContactExternalID]
				, [amount]
				, [typeofcheck]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, concat_WS('_',ccm.ProjectExternalID, e.[ExpenseEntryDate], e.[value], e.expenseCode, e.[ExternalNarrative], e.quantity) [CollectionItemExternalID]
			, TRIM(CASE
				WHEN a.fv_itemType = 'Courier/messenger'
				THEN 'Courier / Messenger'
				WHEN e.expensecode = 'Filing Fee'
				THEN 'Court Filing Fee'
				WHEN a.fv_itemType = 'Taxi/Uber/Parking'
				THEN 'Taxi / Uber / Parking'
				WHEN e.expensecode = 'Medical Records'
				THEN 'Medical Record'
				WHEN e.expenseCode = 'Experts'
				THEN 'Expert Fees'
				WHEN e.expensecode IN ('Court Fees','Process Serv','Settlement Costs','Supplies', 'Appraisal Fees')
				THEN NULL
				ELSE e.expenseCode
			  END) [expenseType]
			, NULL [checknumber]
			, e.[ExternalNarrative] [notes]
			, NULL [checkhistory]
			, NUll [amountpaid] -- comes from quickbooks
			, NULL [status]
			, NULL [checkdate]
			, NULL [moreinfo]
			, e.[ExpenseEntryDate] [date]
			, NULL [invoiceuploadDocExternalID]
			, NULL [title]
			, NULL [payeeContactExternalID]
			, e.[Value] [amount]
			, NULL [typeofcheck]
	-- select distinct  
		
		FROM __FV_ClientCaseMap ccm
		 join pt1.projects p
		 on ccm.projectexternalid = p.projectexternalid
		 left JOIN [dbo].[ExpensebyMatterReport 20220519 105120] e
			ON ccm.caseID = TRIM(e.matterID)
			OR p.projectname = TRIM(e.matter)
		--WHERE 		 
		LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_IM_ExpenseCodeAlign] a
			ON e.expenseCode = a.expenseCode
		WHERE filevine_projectTemplate = 'Personal Injury (Master)'
			--AND ccm.projectexternalid = '0446_0454'	
			 
			 --'Witness Fees' 
			 --'Travel Expense' 
			 --'Translations' 
			 --'Taxi / Uber / Parking' 
			 --'Process Servers' 
			 --'Postage' 
			 --'Miscellaneous' 
			 --'Mileage' 
			 --'Medical Treatment' 
			 --'Medical Record' 
			 --'Mediation / Arbitration' 
			 -- 'Expert Fees' 
			 --'Crash Report' 
			 --'Court Reporter / Videographer' 
			 --'Court Filing Fee' 
			 --'Court Costs' 
			 --'Courier / Messenger' 
			 --'Copying' 
			 --'Consultant'

			  SELECt  e.expenseCode, TRIM(CASE
				WHEN a.fv_itemType = 'Courier/messenger'
				THEN 'Courier / Messenger'
				WHEN e.expensecode = 'Filing Fee'
				THEN 'Court Filing Fee'
				WHEN a.fv_itemType = 'Taxi/Uber/Parking'
				THEN 'Taxi / Uber / Parking'
				WHEN e.expensecode = 'Medical Records'
				THEN 'Medical Record'
				WHEN e.expenseCode = 'Experts'
				THEN 'Expert Fees'
				WHEN e.expensecode IN ('Court Fees','Process Serv','Settlement Costs','Supplies', 'Appraisal Fees')
				THEN NULL
				ELSE e.expenseCode
			  END)
		FROM __FV_ClientCaseMap ccm
		 join pt1.projects p
		 on ccm.projectexternalid = p.projectexternalid
		 left JOIN [dbo].[ExpensebyMatterReport 20220519 105120] e
			ON ccm.caseID = TRIM(e.matterID)
			OR p.projectname = TRIM(e.matter)
		--WHERE 		 
		LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_IM_ExpenseCodeAlign] a
			ON e.expenseCode = a.expenseCode
		WHERE filevine_projectTemplate = 'Personal Injury (Master)'
			--AND ccm.projectexternalid = '0446_0454'	

			 --Neufeld & Ibarra & Wilson & Buchanan & WilsonJ/ScrnShts - Nino-RomeroJuan

			SELECT *
			FROM pt1.projects
			WHERE projectname like '%buchan%'
		
			SELECT *
			FROM [dbo].[ExpensebyMatterReport 20220519 105120]
			WHERE matter like '%nino%'

		 --SELECt *
		 --FROM [dbo].[ExpensebyMatterReport 20220519 105120]
				--INNER JOIN 
				--	[__FV_ProjectTemplateMap] ptm 
				--		ON ptm.Legacy_Case_ID = ccm.CaseID 
	
		--'Copying', --
		--'Courier / Messenger', --
		--'Court Costs',
		--'Court Filing Fee', --
		--'Court Reporter / Videographer','Crash Report',
		--'Expert Fees',
		--'Mediation / Arbitration',
		--'Medical Record' -- 
		--,'Medical Treatment',
		--'Mileage',
		--'Miscellaneous',
		--'Postage',
		--'Taxi / Uber / Parking','Translations',
		--'Travel Expense',
		--'Witness Fees'
	
				


	END
														