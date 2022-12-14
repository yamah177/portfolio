USE [990000153_Hogan_R1]
GO
/****** Object:  StoredProcedure [firmcentral].[usp_insert_staging_TrustQB]    Script Date: 10/26/2022 9:10:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[firmcentral].[usp_insert_staging_TrustQB]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT '[firmcentral].[usp_insert_staging_TrustQB] has been created in [990000153_Hogan_R1] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _Immigration_ */
		/*================================================================================================*/
		
		INSERT INTO
		-- SELECT * FROM 
			[PT1].[Immigration_CL_TrustQB]
			--filevinestaging2import.._HoganT1__Immigration_CL_TrustQB_54774
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [expensetype]
				, [trustaccountingaccounttype]
				, [checknumber]
				, [notes]
				, [checkhistory]
				, [amountpaid]
				, [status]
				, [payeeContactExternalID]
				, [moreinfo]
				, [checkdate]
				, [amount]
				, [typeofcheck]
				, [title]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, CONCAT_WS('_', ccm.ProjectExternalID, t.[type],t.[Account], t.debits, t.credits, t.balance, t.[date], t.[user], t.payee, t.[description]) [CollectionItemExternalID]
			, NULL [expensetype]
			, CASE
			    WHEN t.[Account] like '%Pre-Payment%'
			    THEN 'Pre-Payment'
			    WHEN t.[Account] like '%Retainer%'
			    THEN 'Retainer'
			    WHEN t.[Account] like '%IOLTA%'
			    THEN 'IOLTA'
			    WHEN t.[Account] like '%Trust Account%'
			    THEN 'Trust Account'
				ELSE NULL
			  END AS  [trustaccountingaccounttype]
			, NULL [checknumber]
			--CASE 
			--	WHEN nullif([Account Type], '') is not null
			--	AND nullif([Payor], '') is not null
			--	AND nullif([Invoice Number], '') is not null
			--	AND nullif([Payment Type], '') is not null
			--	AND nullif([Description], '') is not null
			--	THEN
			, CONCAT('Account Type: ',t.[Account Type], CHAR(13), 'Payor: ', [Payor],CHAR(13),'Invoice Number: ', [Invoice Number], CHAR(13), 'Payment Type: ', [Payment Type], CHAR(13),'Description: ',[Description]) 
				--ELSE NULL 
			 --END AS
			 [notes]
			, NULL [checkhistory]
			, /*CASE
				WHEN t.[type] = 'Deposit' 
				THEN t.[Credits]
				WHEN t.[type] = 'Credit' 
				THEN try_convert(money, t.[Debits] * -1)
				ELSE NULL
			  END AS*/
			  NULL [amountpaid]
			, CASE
				WHEN NULLIF(t.credits, '') is not null 
				THEN 'Paid' 
				ELSE NULL
			  END [status]
			, NULL [payeeContactExternalID]
			, NULL [moreinfo]
			, NULL [checkdate]
			--, CONCAT('Credit: ',t.[Credits], 'Debits: ',t.[Debits]) 
			, CASE
				WHEN t.[type] = 'Deposit' 
				THEN try_convert(int, replace(replace(LEFT(nullif(t.[Credits], ''), CHARINDEX('.', nullif(t.[Credits], ''), CHARINDEX('.', nullif(t.[Credits], ''))) - 1) , '$', ''), ',',''))
				WHEN t.[type] = 'Disbursement' 
				THEN try_convert(int, replace(replace(LEFT(nullif(t.[Debits], ''), CHARINDEX('.', nullif(t.[Debits], ''), CHARINDEX('.', nullif(t.[Debits], ''))) - 1) , '$', ''), ',','')) * -1
				ELSE NULL
			  END AS [amount]
			  
			, CASE
				WHEN t.[type] = 'Deposit' 
				THEN 'Client Payment' 
				ELSE NULL
			  END AS [typeofcheck]
			, NULL [title]
	-- SELECT distinct  *,  t.[Account] 
		FROM __FV_ClientCaseMap ccm
		 INNER JOIN [dbo].[Trust_RetainerAccountDetails_Matter Rpt1] t
			ON ccm.caseid = TRIM(t.[matter ID]) -- lose 3 records
			WHERE ccm.Filevine_ProjectTemplate = 'Immigration'
			 --AND CONCAT_WS('_', ccm.ProjectExternalID, t.[type],t.[Account], t.debits, t.credits, t.balance, t.[date], t.[user], t.payee, t.[description]) = '0571_0573____Balance as of 01/01/2007'
			--AND CONCAT_WS('_', ccm.ProjectExternalID, t.[type], t.debits, t.credits, t.balance, t.[date], t.[user], t.payee, t.[description]) = '0631_0631____$0.00____Balance as of 01/01/2007'
		
	--	(([trustaccountingaccounttype]='Trust Account' OR [trustaccountingaccounttype]='Retainer' OR [trustaccountingaccounttype]='Pre-Payment' OR [trustaccountingaccounttype]='IOLTA'))
		--SELECT *
		 --FROM [dbo].[Trust_RetainerAccountDetails_Matter Rpt1] -- 186

				--INNER JOIN 
				--	[__FV_ProjectTemplateMap] ptm 
				--		ON ptm.Legacy_Case_ID = ccm.CaseID 
		
		
		SELECT *
		FROM [dbo].[Firm Central Matters_20220518]
		WHERE billingtype = 'Flat Fee'
		order by matterstatus -- 14 open of 32
				


		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _PersonalInjuryMaster_ */
		/*================================================================================================*/
		
		INSERT INTO
		-- select * from -- delete from
			[PT1].[PersonalInjuryMaster_CL_TrustQB]
			--filevinestaging2import.._HoganT3__PersonalInjuryMaster_CL_TrustQB_58608
			--filevinestaging2import.._HoganT1__PersonalInjuryMaster_CL_TrustQB_57325
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [expenseType]
				, [trustAccountingAccountType]
				, [checknumber]
				, [notes]
				, [checkhistory]
				, [amountpaid]
				, [status]
				, [payeeContactExternalID]
				, [moreinfo]
				, [checkdate]
				, [amount]
				, [typeofcheck]
				, [title]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, CONCAT_WS('_', ccm.ProjectExternalID, r.[type],r.[Account], r.debits, r.credits, r.balance, r.[date], r.[user], r.payee, r.[description], 1) [CollectionItemExternalID]
			, null [expenseType]
			,  CASE
			    WHEN r.[Account] like '%Pre-Payment%'
			    THEN 'Pre-Payment'
			    WHEN r.[Account] like '%Retainer%'
			    THEN 'Retainer'
			    WHEN r.[Account] like '%IOLTA%'
			    THEN 'IOLTA'
			    WHEN r.[Account] like '%Trust Account%'
			    THEN 'Trust Account'
				ELSE NULL
			  END AS [trustAccountingAccountType]
			, NULL [checknumber]
			, CONCAT('Account Type: ',r.[Account Type], CHAR(13), 'Payor: ', r.[Payor],CHAR(13),'Invoice Number: ', r.[Invoice Number], CHAR(13), 'Payment Type: ', r.[Payment Type], CHAR(13),'Description: ',r.[Description])  [notes]
			, NULL [checkhistory]
			,  /*CASE
				WHEN r.[type] = 'Deposit' 

				THEN try_convert(int, replace(replace(LEFT(nullif(r.[Credits], ''), CHARINDEX('.', nullif(r.[Credits], ''), CHARINDEX('.', nullif(r.[Credits], ''))) - 1) , '$', ''), ',',''))
				WHEN r.[type] = 'Credit' 
				THEN try_convert(int, replace(replace(LEFT(nullif(r.[Debits], ''), CHARINDEX('.', nullif(r.[Debits], ''), CHARINDEX('.', nullif(r.[Debits], ''))) - 1) , '$', ''), ',','')) * -1
				ELSE NULL
			  END AS*/
			  NULL [amountpaid]
			, CASE
				WHEN NULLIF(R.[Credits], '') IS NOT NULL
				THEN 'Paid'
				ELSE NULL
			  END as [status]
			, NULL [payeeContactExternalID]
			,  CONCAT('Account Type: ',R.[Account Type], CHAR(13), 'Payor: ', R.[Payor],CHAR(13),'Invoice Number: ', R.[Invoice Number], CHAR(13), 'Payment Type: ', R.[Payment Type], CHAR(13),'Description: ',R.[Description])  [moreinfo]
			, NULL [checkdate]
			, CASE
				WHEN R.[type] = 'Deposit' 
				THEN try_convert(int, replace(replace(LEFT(nullif(r.[Credits], ''), CHARINDEX('.', nullif(r.[Credits], ''), CHARINDEX('.', nullif(r.[Credits], ''))) - 1) , '$', ''), ',',''))
				WHEN R.[type] = 'Disbursement' 
				THEN try_convert(int, replace(replace(LEFT(nullif(r.[Debits], ''), CHARINDEX('.', nullif(r.[Debits], ''), CHARINDEX('.', nullif(r.[Debits], ''))) - 1) , '$', ''), ',','')) * -1
				ELSE NULL
			  END AS  [amount]
			, CASE
				WHEN r.[type] = 'Deposit' 
				THEN 'Client Payment' 
				ELSE NULL
			  END AS [typeofcheck]
			, NULL [title]
	-- SELECT distinct  *
		FROM __FV_ClientCaseMap ccm
		 INNER JOIN [dbo].[Trust_RetainerAccountDetails_Matter Rpt1] r
		 ON ccm.caseid = trim(r.[matter ID])
		 WHERE ccm.Filevine_ProjectTemplate = 'Personal Injury (Master)'
		 --AND ccm.ProjectExternalID = '1157_1043'
		 --OR ccm.ProjectExternalID = '0701_695'

		 --SELECt distinct matter
		 --FROM [dbo].[Trust_RetainerAccountDetails_Matter Rpt1]
		 ----WHERE matter like '%leaf%'
		 --WHERE [matter] like '%jesse%'

		 --SELECT *
		 --FROM pt1.projects
		 --WHERE projectname like '%Cruz%'
		 --OR projectname like '%Birley%'
		 --OR projectname like '%Neufeld%' -- he is not in backup

		 -- cruz: 1157_1043 & -- backup timing issue
		 -- birley: 1077_695 & 0701_695 -- data is good for CPS case in the report, the adoption one is not in the report
		 -- neufeld: 1189_1071 -- not in the report

--		 0871_839
--1037_839
--1091_839

--Cruz/ScrnSht - Birley, Anita (CPS Case) - Neufeld, Peter

--		 Ibarra/ScrnSht
--Hogan/ScrnShot
--BridgesHeith &HerreraBrandy MVA
--Nino-RomeroJuan
--Ayala, Beatrice & Salas, Lupe v. Spencer


		 --select * from
			--[PT1].[PersonalInjuryMaster_CL_TrustQB]
			--WHERE ProjectExternalID = '1077_695'

			--SELECT *
			--FROM  filevinestaging2import.._HoganT1__PersonalInjuryMaster_CL_TrustQB_57325
			--WHERE ProjectExternalID = '1077_695'


			--SELECT *
			--FROM  filevinestaging2import.._HoganT1__PersonalInjuryMaster_CL_TrustQB_54778
			--WHERE ProjectExternalID = '1077_695'


		 --SELECt *
		 --FROM pt1.projects
		 --WHERe projectname like '%anita%' -- birley (cps case) there is another kind. 1077_695

		 --0701_695
		
		
		--([trustAccountingAccountType]='Trust Account' OR [trustAccountingAccountType]='Retainer' OR [trustAccountingAccountType]='Pre-Payment' OR [trustAccountingAccountType]='IOLTA'))


	--	(([expenseType]='Witness Fees' OR [expenseType]='Travel Expense' OR [expenseType]='Translations' OR [expenseType]='Taxi / Uber / Parking' OR [expenseType]='Postage' OR [expenseType]='Miscellaneous' OR [expenseType]='Mileage' OR [expenseType]='Medical Treatment' OR [expenseType]='Medical Record' OR [expenseType]='Mediation / Arbitration' OR [expenseType]='Expert Fees' OR [expenseType]='Crash Report' OR [expenseType]='Court Reporter / Videographer' OR [expenseType]='Court Filing Fee' OR [expenseType]='Court Costs' OR [expenseType]='Courier / Messenger' OR [expenseType]='Copying' OR [expenseType]='Consultant'))
		
		--) a
		 --[account type]
		 
		 --SELECT distinct try_convert(int, replace(replace(LEFT(nullif([Credits], ''), CHARINDEX('.', nullif([Credits], ''), CHARINDEX('.', nullif([Credits], ''))) - 1) , '$', ''), ',',''))
		 --FROM [dbo].[Trust_RetainerAccountDetails_Matter Rpt1]

				--INNER JOIN 
				--	[__FV_ProjectTemplateMap] ptm 
				--		ON ptm.Legacy_Case_ID = ccm.CaseID 
		
		
		
				


	END
														