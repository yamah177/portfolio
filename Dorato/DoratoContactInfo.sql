USE [990000147_Dorato_ST1]
GO
/****** Object:  StoredProcedure [practicemaster].[usp_insert_staging_ContactInfo]    Script Date: 8/2/2022 3:04:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[practicemaster].[usp_insert_staging_ContactInfo]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 			'[practicemaster].[usp_insert_staging_ContactInfo] has been created in [990000147_Dorato_S1] database.  Please review and modifiy the procedure.'
			
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _ST1_ */
		/*================================================================================================*/

-- fix homephone - phonenumber 1
DROP TABLE if exists #homephone;

		WITH homephonefix AS (
		SELECT distinct 
		  seq__no
		, replace(replace(replace(trim([Home__Phone]), '(',''), ') ',''), '-',' ') homephone
		FROM [CMRELATE]
		WHERE [Home__Phone] not like '%(%' -- 50% do not have the parenthesis, 2k of 4k
		 AND len(trim([Home__Phone] )) <= 12
		 AND len(trim([Home__Phone] )) >8
		 ) 
		 SELECT 
		   seq__no
		 , STUFF(STUFF(STUFF(replace(replace(replace(trim(homephone), '(',''), ')',' '), '-',' '), 7, 0, '-'), 4, 0, ') '), 1, 0, '(') AS homephone
		 INTO #homephone
		 FROM homephonefix
		
-- work phone, phone number 2 fix
DROP TABLE if exists #workphone;

		WITH workphonefix AS (
		SELECT distinct 
		  seq__no
		, replace(replace(replace(trim([Work__Phone]), '(',''), ') ',''), '-',' ') workphone
		FROM [CMRELATE]
		WHERE [Work__Phone] not like '%(%' -- 50% do not have the parenthesis, 2k of 4k
		 AND len(trim([Work__Phone] )) <= 12
		 AND len(trim([Work__Phone] )) >8
		 ) 
		 SELECT 
		   seq__no
		 , STUFF(STUFF(STUFF(replace(replace(replace(trim(workphone), '(',''), ')',' '), '-',' '), 7, 0, '-'), 4, 0, ') '), 1, 0, '(') AS workphone
		 INTO #workphone
		 FROM workphonefix

-- cell phone - phone number 3 fix


		DROP TABLE if exists #cellphone;

		WITH cellphonefix AS (
		SELECT distinct 
		  seq__no
		, replace(replace(replace(trim([Cellular__Phone]), '(',''), ') ',''), '-',' ') cellphone
		FROM [CMRELATE]
		WHERE [Cellular__Phone] not like '%(%' -- 50% do not have the parenthesis, 2k of 4k
		 AND len(trim([Cellular__Phone] )) <= 12
		 AND len(trim([Cellular__Phone] )) >8
		 ) 
		 SELECT 
		   seq__no
		 , STUFF(STUFF(STUFF(replace(replace(replace(trim(cellphone), '(',''), ')',' '), '-',' '), 7, 0, '-'), 4, 0, ') '), 1, 0, '(') AS cellphone
		 INTO #cellphone
		 FROM cellphonefix 

-- phone number 4 work fax fix
	DROP TABLE if exists #workfaxfix;

		WITH workfaxfix AS (
		SELECT distinct 
		  seq__no
		, replace(replace(replace(trim([Work__Fax]), '(',''), ') ',''), '-',' ') workfax
		FROM [CMRELATE]
		WHERE [Work__Fax] not like '%(%' -- 50% do not have the parenthesis, 2k of 4k
		 AND len(trim([Work__Fax] )) <= 12
		 AND len(trim([Work__Fax] )) >8
		 ) 
		 SELECT 
		   seq__no
		 , STUFF(STUFF(STUFF(replace(replace(replace(trim(workfax), '(',''), ')',' '), '-',' '), 7, 0, '-'), 4, 0, ') '), 1, 0, '(') AS workfax
		 INTO #workfax
		 FROM workfaxfix  


		INSERT INTO
		-- select * from -- delete from
		--[FilevineStaging2Import].[BaseImport].[_990000147_Dorato_ST2_ContactsCustom__Standard__47440]
			[PT1].[ContactsCustom__ContactInfo]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CustomPersonID]
				, [ContactCustomExternalID]
				, [ContactTypeList]
				, [FirstName]
				, [MiddleName]
				, [LastName]
				, [Prefix]
				, [Suffix]
				, [Nickname]
				, [BirthDate]
				, [FromCompany]
				, [IsSingleName]
				, [Department]
				, [JobTitle]
				, [ContactHashtagList]
				, [PhoneLabelName1]
				, [PhoneNumber1]
				, [PhoneNote1]
				, [PhoneLabelName2]
				, [PhoneNumber2]
				, [PhoneNote2]
				, [PhoneLabelName3]
				, [PhoneNumber3]
				, [PhoneNote3]
				, [PhoneLabelName4]
				, [PhoneNumber4]
				, [PhoneNote4]
				, [PhoneLabelName5]
				, [PhoneNumber5]
				, [PhoneNote5]
				, [PhoneLabelName6]
				, [PhoneNumber6]
				, [PhoneNote6]
				, [PhoneLabelName7]
				, [PhoneNumber7]
				, [PhoneNote7]
				, [PhoneLabelName8]
				, [PhoneNumber8]
				, [PhoneNote8]
				, [PhoneLabelName9]
				, [PhoneNumber9]
				, [PhoneNote9]
				, [PhoneLabelName10]
				, [PhoneNumber10]
				, [PhoneNote10]
				, [EmailLabelName1]
				, [EmailAddress1]
				, [EmailNote1]
				, [EmailLabelName2]
				, [EmailAddress2]
				, [EmailNote2]
				, [EmailLabelName3]
				, [EmailAddress3]
				, [EmailNote3]
				, [EmailLabelName4]
				, [EmailAddress4]
				, [EmailNote4]
				, [EmailLabelName5]
				, [EmailAddress5]
				, [EmailNote5]
				, [EmailLabelName6]
				, [EmailAddress6]
				, [EmailNote6]
				, [EmailLabelName7]
				, [EmailAddress7]
				, [EmailNote7]
				, [EmailLabelName8]
				, [EmailAddress8]
				, [EmailNote8]
				, [EmailLabelName9]
				, [EmailAddress9]
				, [EmailNote9]
				, [EmailLabelName10]
				, [EmailAddress10]
				, [EmailNote10]
				, [Address1LabelName]
				, [Address1Line1]
				, [Address1Line2]
				, [Address1City]
				, [Address1State]
				, [Address1Zip]
				, [Address1Note]
				, [Address2LabelName]
				, [Address2Line1]
				, [Address2Line2]
				, [Address2City]
				, [Address2State]
				, [Address2Zip]
				, [Address2Note]
				, [Address3LabelName]
				, [Address3Line1]
				, [Address3Line2]
				, [Address3City]
				, [Address3State]
				, [Address3Zip]
				, [Address3Note]
				, [Address4LabelName]
				, [Address4Line1]
				, [Address4Line2]
				, [Address4City]
				, [Address4State]
				, [Address4Zip]
				, [Address4Note]
				, [Address5LabelName]
				, [Address5Line1]
				, [Address5Line2]
				, [Address5City]
				, [Address5State]
				, [Address5Zip]
				, [Address5Note]
		)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CustomPersonID]
			, trim(cmr.[Seq__No]) [ContactCustomExternalID]
			, CASE
				WHEN [RP__Cat] IN('adj', 'Adjustor', 'Adjuster', 'adj|Adjuster', 'Ad') THEN 'Adjuster'
				WHEN [RP__Cat] IN('OC', 'Attorney') THEN 'Attorney'
				WHEN [RP__Cat] IN('No Rep', 'clilent', 'NoRep', 'no|No Rep', 'non per', 'Non Rep', 'c', 'Client|No Rep','Client') THEN 'Client'
				WHEN [RP__Cat] IN('def', 'Defendant') THEN 'Defendant'
				WHEN [RP__Cat] IN('Employer') THEN 'Employer'
				WHEN [RP__Cat] IN('Governor') THEN 'Governor'
				WHEN [RP__Cat] IN('Insurance Company', 'Insurance') THEN 'Insurance Company'
				WHEN [RP__Cat] IN('Interpreter') THEN 'Interpreter'
				WHEN [RP__Cat] IN('Judge', 'Attorney|Judge') THEN 'Judge'
				WHEN [RP__Cat] IN('Mediator', 'med') THEN 'Mediator'
				WHEN [RP__Cat] IN('Physical Therapy', 'Medical') THEN 'Medical Provider'
				WHEN [RP__Cat] IN('Nurse Case Manager') THEN 'Nurse Case Manager'
				WHEN [RP__Cat] IN('qhcp') THEN 'Qualified Healthcare Provider'
				WHEN [RP__Cat] IN('Service Rep', 'Business Contact') THEN 'Vendor'
				WHEN [RP__Cat] IN('WCAdminOffice') THEN 'WC Administrative Office'
			END
				 [ContactTypeList] -- dca.[Contact Type in Filevine]
			, coalesce([First__Name],[Organization],cmr.[Name]) [FirstName]
			, [pmMiddleName] [MiddleName]
			, [Last__Name] [LastName]
			, [pmTitle] [Prefix]
			, [pmNameSuffix] [Suffix]
			, NULL [Nickname]
			, iif(cmr.[DOB]='mm/dd/yyyy',null,cmr.[DOB]) [BirthDate]
			, iif([Org__Sw]='N',[Organization],NULL) [FromCompany]
			, iif([Org__Sw]='N',0,1) [IsSingleName]
			, NULL [Department]
			, NULL [JobTitle]
			, NULL [ContactHashtagList]
			, iif([Home__Phone] is null,null,'Home') [PhoneLabelName1]
			, coalesce(hp.homephone, cmr.[Home__Phone]) [PhoneNumber1]
			, NULL [PhoneNote1]
			, iif([Work__Phone] is null,null,'Work') [PhoneLabelName2]
			, coalesce(wp.workphone, cmr.[Work__Phone]) [PhoneNumber2]
			, NULL [PhoneNote2]
			, iif([Cellular__Phone] is null,null,'Personal Mobile') [PhoneLabelName3]
			, coalesce(cp.cellphone, cmr.[Cellular__Phone]) [PhoneNumber3]
			, NULL [PhoneNote3]
			, iif([Work__Fax] is null,null,'Fax') [PhoneLabelName4]
			, coalesce(wf.workfax, cmr.[Work__Fax]) [PhoneNumber4]
			, NULL [PhoneNote4]
			, iif([Work__Phone_2] is null,null,'Work') [PhoneLabelName5]
			, [Work__Phone_2] [PhoneNumber5]
			, NULL [PhoneNote5]
			, iif([Home__Phone_2] is null,null,'Home') [PhoneLabelName6]
			, [Home__Phone_2] [PhoneNumber6]
			, NULL [PhoneNote6]
			, iif([Home__Fax] is null,null,'Fax') [PhoneLabelName7]
			, [Home__Fax] [PhoneNumber7]
			, NULL [PhoneNote7]
			, iif([Other__Phone] is null,null,'Other') [PhoneLabelName8]
			, [Other__Phone] [PhoneNumber8]
			, NULL [PhoneNote8]
			, NULL [PhoneLabelName9]
			, NULL [PhoneNumber9]
			, NULL [PhoneNote9]
			, NULL [PhoneLabelName10]
			, NULL [PhoneNumber10]
			, NULL [PhoneNote10]
			, NULL [EmailLabelName1]
			, [Email__Address_1] [EmailAddress1]
			, NULL [EmailNote1]
			, NULL [EmailLabelName2]
			, [Email__Address_2] [EmailAddress2]
			, NULL [EmailNote2]
			, NULL [EmailLabelName3]
			, [Email__Address_3] [EmailAddress3]
			, NULL [EmailNote3]
			, NULL [EmailLabelName4]
			, NULL [EmailAddress4]
			, NULL [EmailNote4]
			, NULL [EmailLabelName5]
			, NULL [EmailAddress5]
			, NULL [EmailNote5]
			, NULL [EmailLabelName6]
			, NULL [EmailAddress6]
			, NULL [EmailNote6]
			, NULL [EmailLabelName7]
			, NULL [EmailAddress7]
			, NULL [EmailNote7]
			, NULL [EmailLabelName8]
			, NULL [EmailAddress8]
			, NULL [EmailNote8]
			, NULL [EmailLabelName9]
			, NULL [EmailAddress9]
			, NULL [EmailNote9]
			, NULL [EmailLabelName10]
			, NULL [EmailAddress10]
			, NULL [EmailNote10]
			, NULL [Address1LabelName]
			, [Addr_1__Line_1] [Address1Line1]
			, coalesce([Addr_1__Line_2],[Addr_1__Line_3]) [Address1Line2]
			, [Addr_1__City] [Address1City]
			, left([Addr_1__State],2) [Address1State]
			, [Addr_1__Zip] [Address1Zip]
			, NULL [Address1Note]
			, NULL [Address2LabelName]
			, [Addr_2__Line_1] [Address2Line1]
			, coalesce([Addr_2__Line_2],[Addr_2__Line_3]) [Address2Line2]
			, [Addr_2__City] [Address2City]
			, left([Addr_2__State],2) [Address2State]
			, [Addr_2__Zip] [Address2Zip]
			, NULL [Address2Note]
			, NULL [Address3LabelName]
			, [Addr_3__Line_1] [Address3Line1]
			, coalesce([Addr_3__Line_2],[Addr_3__Line_3]) [Address3Line2]
			, [Addr_3__City] [Address3City]
			, left([Addr_3__State],2) [Address3State]
			, [Addr_3__Zip] [Address3Zip]
			, NULL [Address3Note]
			, NULL [Address4LabelName]
			, NULL [Address4Line1]
			, NULL [Address4Line2]
			, NULL [Address4City]
			, NULL [Address4State]
			, NULL [Address4Zip]
			, NULL [Address4Note]
			, NULL [Address5LabelName]
			, NULL [Address5Line1]
			, NULL [Address5Line2]
			, NULL [Address5City]
			, NULL [Address5State]
			, NULL [Address5Zip]
			, NULL [Address5Note]
	-- select * 
		FROM [CMRELATE] cmr
		left join #homephone hp
		on cmr.seq__no = hp.seq__no
		left join #workphone wp
		on cmr.seq__no = wp.seq__no
		left join #cellphone cp
		on cmr.seq__no = cp.seq__no
		left join #workfax wf
		on cmr.seq__no = wf.seq__no


		-- fabricate staff data
		--SELECT
		--  [__ImportStatus]
		--		, [__ImportStatusDate]
		--		, [__ErrorMessage]
		--		, [__WorkerID]
		--		, [__CustomPersonID]
		--		, [ContactCustomExternalID]
		--		, [ContactTypeList]
		--		, [FirstName]
		--		, [MiddleName]
		--		, [LastName]
		--		, [Prefix]
		--		, [Suffix]
		--		, [Nickname]
		--		, [BirthDate]
		--		, [FromCompany]
		--		, [IsSingleName]
		--		, [Department]
		--		, [JobTitle]
		--	FROM   
		--	SELECT 
		--	  40 [__ImportStatus]
		--	, GETDATE() [__ImportStatusDate]
		--	, NULL [__ErrorMessage]
		--	, NULL [__WorkerID]
		--	, NULL [__CustomPersonID]
		--	, [ContactCustomExternalID]
		--	, NULL	 [ContactTypeList] -- dca.[Contact Type in Filevine]
		--	,  [FirstName]
		--	, [MiddleName]
		--	, [LastName]
		--	, [Prefix]
		--	, [Suffix]
		--	, NULL [Nickname]
		--	, [BirthDate]
		--	, [FromCompany]
		--	, [IsSingleName]

		--UNION

		--UNION

		--[Prim__Tkpr]	
		
		--SELECT distinct [Prim__Tkpr]
		--FROM [dbo].[CMCLIENT]

		--SELECT *
		--FROM [dbo].[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT]
		--WHERE field_value = '1'

--SELECT distinct table_name, field_value
--FROM [dbo].[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT]
--WHERE field_value like '%weems%'
--AND field_value not like '%@%'
--AND field_value not like '%/%'
--AND field_value not like '%\%'


		---- validate phonenumber 1
		--SELECT distinct phonenumber1
		--FROM 			[PT1].[ContactsCustom__ContactInfo]
		--WHERE phonenumber1 not like '%(%'

		---- validate phonenumber 2
		--SELECT distinct PhoneNumber2
		--FROM 			[PT1].[ContactsCustom__ContactInfo]
		--WHERE PhoneNumber2 not like '%(%'

		---- validate phonenumber 3
		--SELECT distinct PhoneNumber3
		--FROM 			[PT1].[ContactsCustom__ContactInfo]
		--WHERE PhoneNumber3 not like '%(%'

		---- validate phonenumber 4
		--SELECT distinct PhoneNumber4
		--FROM 			[PT1].[ContactsCustom__ContactInfo]
		--WHERE PhoneNumber4 not like '%(%'
		

		-- --207 570 8151
		-- --238 2903

		-- SELECT distinct STUFF(STUFF(STUFF(replace(replace(replace(trim([Home__Phone]), '(',''), ')',' '), '-',' '), 7, 0, '-'), 4, 0, ') '), 1, 0, '(') AS fix_home_phone
		-- FROM #homephone
		-- WHERE [Home__Phone] not like '%(%'
		-- AND len(trim([Home__Phone] )) <= 12
		-- AND len(trim([Home__Phone] )) >8

		--  SELECT distinct     replace(STUFF(STUFF(STUFF(homephone, 8, 0, '-'), 4, 0, ') '), 1, 0, '('), '- ', '-') AS fix_home_phone
		-- FROM #homephone
		-- WHERE [Home__Phone] not like '%(%'
		-- AND len(trim([Home__Phone] )) <= 12
		-- AND len(trim([Home__Phone] )) >8

		--SELECT distinct [Work__Phone]
		--FROM [CMRELATE]
		--WHERE [Work__Phone] not like '%(%' -- 50% do not have the parenthesis. 173 of 1500 (12% ish)


		--DROP TABLE if exists #workfaxfix

		--WITH workfaxfix AS (
		--SELECT distinct 
		--  seq__no
		--, replace(replace(replace(trim([Work__Fax]), '(',''), ') ',''), '-',' ') workfax
		--FROM [CMRELATE]
		--WHERE [Work__Fax] not like '%(%' -- 50% do not have the parenthesis, 2k of 4k
		-- AND len(trim([Work__Fax] )) <= 12
		-- AND len(trim([Work__Fax] )) >8
		-- ) 
		-- SELECT 
		--   seq__no
		-- , STUFF(STUFF(STUFF(replace(replace(replace(trim(workfax), '(',''), ')',' '), '-',' '), 7, 0, '-'), 4, 0, ') '), 1, 0, '(') AS workfax
		-- INTO #workfax
		-- FROM workfaxfix  


			
			
		
		--SELECT distinct [Cellular__Phone]
		--FROM [CMRELATE]
		--WHERE [Cellular__Phone] not like '%(%' -- 50% do not have the parenthesis. 1500 of 4k + (30% ish)

		--SELECT distinct [Work__Fax]
		--FROM [CMRELATE]
		--WHERE [Work__Fax] not like '%(%' -- 50% do not have the parenthesis. 125 of 1000. 10% ish

		--	, [Work__Fax] [PhoneNumber4]
		
		--SELECT distinct [Work__Phone_2]
		--FROM [CMRELATE]
		--WHERE [Work__Phone_2] not like '%(%' -- 50% do not have the parenthesis. 6 of 92. 5%

		--	, [Work__Phone_2] [PhoneNumber5]
			
			
		--SELECT distinct [Home__Phone_2]
		--FROM [CMRELATE]
		--WHERE [Home__Phone_2] not like '%(%' -- good

		--	, [Home__Phone_2] [PhoneNumber6]
		

		--SELECT distinct [Home__Fax]
		--FROM [CMRELATE]
		--WHERE [Home__Fax] not like '%(%' -- good

		--	, [Home__Fax] [PhoneNumber7]
			
		--	SELECT distinct [Other__Phone]
		--FROM [CMRELATE]
		--WHERE [Other__Phone] not like '%(%' -- 1 bad

		--	, [Other__Phone] [PhoneNumber8]



--		LEFT JOIN [CMCLIENT] cmc ON cmc.[Name] = cmr.[RP__Key]
--		LEFT JOIN [PARTIES] p ON p.[Client__ID] = cmc.Client__ID

--		GROUP BY cmr.[Seq__No], [First__Name], [pmMiddleName], [Last__Name], [pmNameSuffix], [Organization], cmr.[Name], p.[Role], [pmTitle], cmr.[DOB],[Home__Phone], [Work__Phone], [Cellular__Phone],
--		[Org__Sw], [Work__Fax], [Work__Phone_2], [Home__Phone_2], [Home__Fax], [Other__Phone], [Email__Address_1], [Email__Address_2], [Email__Address_3], [Addr_1__Line_1], [Addr_1__Line_2], [Addr_1__Line_3],
--		[Addr_1__City], [Addr_1__State], [Addr_1__Zip],
--		LEFT JOIN [Dorato_ContactAlignment] dca ON dca.[Lookup__ID] = p.[Role]
		

	END
														