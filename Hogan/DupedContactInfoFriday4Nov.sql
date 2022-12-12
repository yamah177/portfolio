-- save adjusted CI
USE [990000153_Hogan_T2]
GO
/****** Object:  StoredProcedure [firmcentral].[usp_insert_staging_ContactInfo]    Script Date: 11/4/2022 11:59:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[firmcentral].[usp_insert_staging_ContactInfo]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 	'[firmcentral].[usp_insert_staging_ContactInfo] has been created in [990000153_Hogan_S1] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _ST1_ */
		/*================================================================================================*/
				
		INSERT INTO
		-- select distinct count(1) FROM  -- delete from -- SELECT * FROM
			[PT1].[ContactsCustom__ContactInfo]
			--filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__58267
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
			, coalesce(concat(coalesce([FirstName],[BusinessName]) , '_', [Address_1Line_1], '_', case when [Roles] is null then null
					when [Roles] in ('Client;Expert','Expert;Client') then 'Expert'
					when [Roles] in ('First Party Adjuster','Liability Adjuster') then 'Adjuster'
					else [Roles] end ),'<none>') 
			,  coalesce([ClientNumber],'<none>') AS[ContactCustomExternalID]
			--, NULLIF([ClientNumber],'') AS[ContactCustomExternalID]
			, case when [Roles] is null then null
					when [Roles] in ('Client;Expert','Expert;Client') then 'Expert'
					when [Roles] in ('First Party Adjuster','Liability Adjuster') then 'Adjuster'
					else [Roles] end
					[ContactTypeList]
			, coalesce([FirstName],[BusinessName]) [FirstName]
			, [MiddleName] [MiddleName]
			, [LastName] [LastName]
			, [Prefix] [Prefix]
			, [Suffix] [Suffix]
			, [PreferredName] [Nickname]
			, [DateofBirth] [BirthDate]
			, [Employer] [FromCompany]
			, iif([ContactType]='person',0,1) [IsSingleName]
			, NULL [Department]
			, [JobTitle] [JobTitle]
			, NULL [ContactHashtagList]
			, iif([Phone_1Type] is null,null,case when [Phone_1Type] like 'Mobile' then 'Personal Mobile' when [Phone_1Type] like 'Phone' then 'Other' else [Phone_1Type] end) [PhoneLabelName1]
			, [Phone_1Number] [PhoneNumber1]
			, NULL [PhoneNote1]
			, iif([Phone_2Type] is null,null,case when [Phone_2Type] like 'Mobile' then 'Personal Mobile' when [Phone_2Type] like 'Phone' then 'Other' else [Phone_2Type] end) [PhoneLabelName2]
			, [Phone_2Number] [PhoneNumber2]
			, NULL [PhoneNote2]
			, iif([Phone_3Type] is null,null,case when [Phone_3Type] like 'Mobile' then 'Personal Mobile' when [Phone_3Type] like 'Phone' then 'Other' else [Phone_3Type] end) [PhoneLabelName3]
			, [Phone_3Number] [PhoneNumber3]
			, NULL [PhoneNote3]
			, iif([Phone_4Type] is null,null,case when [Phone_4Type] like 'Mobile' then 'Personal Mobile' when [Phone_4Type] like 'Phone' then 'Other' else [Phone_4Type] end) [PhoneLabelName4]
			, [Phone_4Number] [PhoneNumber4]
			, NULL [PhoneNote4]
			, iif([Phone_5Type] is null,null,case when [Phone_5Type] like 'Mobile' then 'Personal Mobile' when [Phone_5Type] like 'Phone' then 'Other' else [Phone_5Type] end) [PhoneLabelName5]
			, [Phone_5Number] [PhoneNumber5]
			, NULL [PhoneNote5]
			, iif([Email_1Type] is null,null,case when [Email_1Type] not in ('Other','Work') then 'Personal' else [Email_1Type] end) [EmailLabelName1]
			, [Email_1Address] [EmailAddress1]
			, NULL [EmailNote1]
			, iif([Email_2Type] is null,null,case when [Email_2Type] not in ('Other','Work') then 'Personal' else [Email_2Type] end) [EmailLabelName2]
			, [Email_2Address] [EmailAddress2]
			, NULL [EmailNote2]
			, iif([Email_3Type] is null,null,case when [Email_3Type] not in ('Other','Work') then 'Personal' else [Email_3Type] end) [EmailLabelName3]
			, [Email_3Address] [EmailAddress3]
			, NULL [EmailNote3]
			, iif([Email_4Type] is null,null,case when [Email_4Type] not in ('Other','Work') then 'Personal' else [Email_4Type] end) [EmailLabelName4]
			, [Email_4Address] [EmailAddress4]
			, NULL [EmailNote4]
			, iif([Email_5Type] is null,null,case when [Email_5Type] not in ('Other','Work') then 'Personal' else [Email_5Type] end) [EmailLabelName5]
			, [Email_5Address] [EmailAddress5]
			, NULL [EmailNote5]
			, iif([Address_1Type] is null,null,case when [Address_1Type] not in ('Home','Work') then 'Other' else [Address_1Type] end) [Address1LabelName]
			, [Address_1Line_1] [Address1Line1]
			, [Address_1Line_2] [Address1Line2]
			, [Address_1City] [Address1City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_1State]) [Address1State]
			, left([Address_1Zip],10) [Address1Zip]
			, NULL [Address1Note]
			, iif([Address_2Type] is null,null,case when [Address_2Type] not in ('Home','Work') then 'Other' else [Address_2Type] end) [Address2LabelName]
			, [Address_2Line_1] [Address2Line1]
			, [Address_2Line_2] [Address2Line2]
			, [Address_2City] [Address2City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_2State]) [Address2State]
			, left([Address_2Zip],10) [Address2Zip]
			, NULL [Address2Note]
			, iif([Address_3Type] is null,null,case when [Address_3Type] not in ('Home','Work') then 'Other' else [Address_3Type] end) [Address3LabelName]
			, [Address_3Line_1] [Address3Line1]
			, [Address_3Line_2] [Address3Line2]
			, [Address_3City] [Address3City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_3State]) [Address3State]
			, left([Address_3Zip],10) [Address3Zip]
			, NULL [Address3Note]
			, iif([Address_4Type] is null,null,case when [Address_4Type] not in ('Home','Work') then 'Other' else [Address_4Type] end) [Address4LabelName]
			, [Address_4Line_1] [Address4Line1]
			, [Address_4Line_2] [Address4Line2]
			, [Address_4City] [Address4City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_4State]) [Address4State]
			, left([Address_4Zip],10) [Address4Zip]
			, NULL [Address4Note]
			, iif([Address_5Type] is null,null,case when [Address_5Type] not in ('Home','Work') then 'Other' else [Address_5Type] end) [Address5LabelName]
			, [Address_5Line_1] [Address5Line1]
			, [Address_5Line_2] [Address5Line2]
			, [Address_5City] [Address5City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_5State]) [Address5State]
			, left([Address_5Zip],10) [Address5Zip]
			, NULL [Address5Note]	
	-- SELECT count(1), coalesce(clientnumber,left(newid(),6))
	-- SELECT *
		FROM [dbo].[Firm Central Contacts_20221103]
		WHERE coalesce(clientnumber,left(newid(),6)) != '326' -- robert hogan
		AND  coalesce(clientnumber,left(newid(),6)) != '0326'
		AND  coalesce(clientnumber,left(newid(),6)) != '0432' -- new dupe
		AND coalesce(clientnumber,left(newid(),6)) != '1053'
		--AND CASE
		--		WHEN coalesce([ClientNumber],'<none>')  = '<none>'
		--		THEN  coalesce(concat(coalesce([FirstName],[BusinessName]) , '_', [Address_1Line_1], '_', case when [Roles] is null then null
		--			when [Roles] in ('Client;Expert','Expert;Client') then 'Expert'
		--			when [Roles] in ('First Party Adjuster','Liability Adjuster') then 'Adjuster'
		--			else [Roles] end ),'<none>') 
		--		ELSE coalesce([ClientNumber],'<none>')
		--	  END
			 --  NOT IN ( SELECT contactcustomexternalid
				--FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__58218
				--)
	
	
			--group by coalesce(clientnumber,left(newid(),6))
			--HAVING count(1) > 1
			--0326-

			--SELECt *
			--FROM [990000153_Hogan_R1].[dbo].[Firm Central Contacts_20220519]

			--SELECT *
			--		FROM [dbo].[Firm Central Contacts_20221103]

			

		INSERT INTO
		-- select distinct count(1) FROM  -- delete from -- SELECT * FROM
			[PT1].[ContactsCustom__ContactInfo]
			--filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__58105
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
			--, coalesce(concat(coalesce([FirstName],[BusinessName]) , '_', [Address_1Line_1], '_', case when [Roles] is null then null
			--		when [Roles] in ('Client;Expert','Expert;Client') then 'Expert'
			--		when [Roles] in ('First Party Adjuster','Liability Adjuster') then 'Adjuster'
			--		else [Roles] end ),'<none>') 
			, CASE
				WHEN coalesce([ClientNumber],'<none>')  = '<none>'
				THEN  coalesce(concat(coalesce([FirstName],[BusinessName]) , '_', [Address_1Line_1], '_', case when [Roles] is null then null
					when [Roles] in ('Client;Expert','Expert;Client') then 'Expert'
					when [Roles] in ('First Party Adjuster','Liability Adjuster') then 'Adjuster'
					else [Roles] end ),'<none>') 
				ELSE coalesce([ClientNumber],'<none>')
			  END AS [ContactCustomExternalID]
			, case when [Roles] is null then null
					when [Roles] in ('Client;Expert','Expert;Client') then 'Expert'
					when [Roles] in ('First Party Adjuster','Liability Adjuster') then 'Adjuster'
					else [Roles] end
					[ContactTypeList]
			, coalesce([FirstName],[BusinessName]) [FirstName]
			, [MiddleName] [MiddleName]
			, [LastName] [LastName]
			, [Prefix] [Prefix]
			, [Suffix] [Suffix]
			, [PreferredName] [Nickname]
			, [DateofBirth] [BirthDate]
			, [Employer] [FromCompany]
			, iif([ContactType]='person',0,1) [IsSingleName]
			, NULL [Department]
			, [JobTitle] [JobTitle]
			, NULL [ContactHashtagList]
			, iif([Phone_1Type] is null,null,case when [Phone_1Type] like 'Mobile' then 'Personal Mobile' when [Phone_1Type] like 'Phone' then 'Other' else [Phone_1Type] end) [PhoneLabelName1]
			, [Phone_1Number] [PhoneNumber1]
			, NULL [PhoneNote1]
			, iif([Phone_2Type] is null,null,case when [Phone_2Type] like 'Mobile' then 'Personal Mobile' when [Phone_2Type] like 'Phone' then 'Other' else [Phone_2Type] end) [PhoneLabelName2]
			, [Phone_2Number] [PhoneNumber2]
			, NULL [PhoneNote2]
			, iif([Phone_3Type] is null,null,case when [Phone_3Type] like 'Mobile' then 'Personal Mobile' when [Phone_3Type] like 'Phone' then 'Other' else [Phone_3Type] end) [PhoneLabelName3]
			, [Phone_3Number] [PhoneNumber3]
			, NULL [PhoneNote3]
			, iif([Phone_4Type] is null,null,case when [Phone_4Type] like 'Mobile' then 'Personal Mobile' when [Phone_4Type] like 'Phone' then 'Other' else [Phone_4Type] end) [PhoneLabelName4]
			, [Phone_4Number] [PhoneNumber4]
			, NULL [PhoneNote4]
			, iif([Phone_5Type] is null,null,case when [Phone_5Type] like 'Mobile' then 'Personal Mobile' when [Phone_5Type] like 'Phone' then 'Other' else [Phone_5Type] end) [PhoneLabelName5]
			, [Phone_5Number] [PhoneNumber5]
			, NULL [PhoneNote5]
			, iif([Email_1Type] is null,null,case when [Email_1Type] not in ('Other','Work') then 'Personal' else [Email_1Type] end) [EmailLabelName1]
			, [Email_1Address] [EmailAddress1]
			, NULL [EmailNote1]
			, iif([Email_2Type] is null,null,case when [Email_2Type] not in ('Other','Work') then 'Personal' else [Email_2Type] end) [EmailLabelName2]
			, [Email_2Address] [EmailAddress2]
			, NULL [EmailNote2]
			, iif([Email_3Type] is null,null,case when [Email_3Type] not in ('Other','Work') then 'Personal' else [Email_3Type] end) [EmailLabelName3]
			, [Email_3Address] [EmailAddress3]
			, NULL [EmailNote3]
			, iif([Email_4Type] is null,null,case when [Email_4Type] not in ('Other','Work') then 'Personal' else [Email_4Type] end) [EmailLabelName4]
			, [Email_4Address] [EmailAddress4]
			, NULL [EmailNote4]
			, iif([Email_5Type] is null,null,case when [Email_5Type] not in ('Other','Work') then 'Personal' else [Email_5Type] end) [EmailLabelName5]
			, [Email_5Address] [EmailAddress5]
			, NULL [EmailNote5]
			, iif([Address_1Type] is null,null,case when [Address_1Type] not in ('Home','Work') then 'Other' else [Address_1Type] end) [Address1LabelName]
			, [Address_1Line_1] [Address1Line1]
			, [Address_1Line_2] [Address1Line2]
			, [Address_1City] [Address1City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_1State]) [Address1State]
			, left([Address_1Zip],10) [Address1Zip]
			, NULL [Address1Note]
			, iif([Address_2Type] is null,null,case when [Address_2Type] not in ('Home','Work') then 'Other' else [Address_2Type] end) [Address2LabelName]
			, [Address_2Line_1] [Address2Line1]
			, [Address_2Line_2] [Address2Line2]
			, [Address_2City] [Address2City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_2State]) [Address2State]
			, left([Address_2Zip],10) [Address2Zip]
			, NULL [Address2Note]
			, iif([Address_3Type] is null,null,case when [Address_3Type] not in ('Home','Work') then 'Other' else [Address_3Type] end) [Address3LabelName]
			, [Address_3Line_1] [Address3Line1]
			, [Address_3Line_2] [Address3Line2]
			, [Address_3City] [Address3City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_3State]) [Address3State]
			, left([Address_3Zip],10) [Address3Zip]
			, NULL [Address3Note]
			, iif([Address_4Type] is null,null,case when [Address_4Type] not in ('Home','Work') then 'Other' else [Address_4Type] end) [Address4LabelName]
			, [Address_4Line_1] [Address4Line1]
			, [Address_4Line_2] [Address4Line2]
			, [Address_4City] [Address4City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_4State]) [Address4State]
			, left([Address_4Zip],10) [Address4Zip]
			, NULL [Address4Note]
			, iif([Address_5Type] is null,null,case when [Address_5Type] not in ('Home','Work') then 'Other' else [Address_5Type] end) [Address5LabelName]
			, [Address_5Line_1] [Address5Line1]
			, [Address_5Line_2] [Address5Line2]
			, [Address_5City] [Address5City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([Address_5State]) [Address5State]
			, left([Address_5Zip],10) [Address5Zip]
			, NULL [Address5Note]	
	-- SELECT [Address_1County]
	-- SELECT *
		FROM [dbo].[Firm Central Contacts_20221103]
		WHERE coalesce(clientnumber,left(newid(),6)) != '326' -- robert hogan
		AND case when [Roles] is null then null
					when [Roles] in ('Client;Expert','Expert;Client') then 'Expert'
					when [Roles] in ('First Party Adjuster','Liability Adjuster') then 'Adjuster'
					else [Roles] end != 'Client'

				
				
		--AND  coalesce([FirstName],[BusinessName]) 
		--IN
		--(SELECT firstname
		--FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__57373
		--WHERE __importstatus = 70
		----AND contacttypelist != 'Client'
		--)

		--WHERE coalesce(clientnumber,left(newid(),6)) = '0000'
		
		-- opposing party

		INSERT INTO
		-- select distinct [PhoneNote1] FROM 
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
			, coalesce([OpposingParty_1],left(newid(),6)) [ContactCustomExternalID]
			, NULL [ContactTypeList]
			, [OpposingParty_1] [FirstName]
			, NULL [MiddleName]
			, NULL [LastName]
			, NULL [Prefix]
			, NULL [Suffix]
			, NULL [Nickname]
			, NULL [BirthDate]
			, NULL [FromCompany]
			, 0 [IsSingleName]
			, NULL [Department]
			, NULL [JobTitle]
			, NULL [ContactHashtagList]
			, case 
			    when [OpposingParty_1Phone_1Type] = 'Home' 
				then 'Home'
				when [OpposingParty_1Phone_1Type] = 'Work' 
				then 'Work' 
				else 'Other' 
			  end as [PhoneLabelName1]
			, [OpposingParty_1Phone_1] [PhoneNumber1]
			, NULL [PhoneNote1]
			, case 
			    when [OpposingParty_1Phone_2Type] = 'Home' 
				then 'Home'
				when [OpposingParty_1Phone_2Type] = 'Work' 
				then 'Work' 
				else 'Other' 
			  end AS [PhoneLabelName2]
			, [OpposingParty_1Phone_2] [PhoneNumber2]
			, NULL [PhoneNote2]
			, NULL [PhoneLabelName3]
			, NULL [PhoneNumber3]
			, NULL [PhoneNote3]
			, NULL [PhoneLabelName4]
			, NULL [PhoneNumber4]
			, NULL [PhoneNote4]
			, NULL [PhoneLabelName5]
			, NULL [PhoneNumber5]
			, NULL [PhoneNote5]
			, 'Other' [EmailLabelName1] --
			, [OpposingParty_1Email_1] [EmailAddress1] -- 
			, NULL [EmailNote1]
			, NULL [EmailLabelName2]
			, NULL [EmailAddress2]
			, NULL [EmailNote2]
			, NULL [EmailLabelName3]
			, NULL [EmailAddress3]
			, NULL [EmailNote3]
			, NULL [EmailLabelName4]
			, NULL [EmailAddress4]
			, NULL [EmailNote4]
			, NULL [EmailLabelName5]
			, NULL [EmailAddress5]
			, NULL [EmailNote5]
			, Case 
				when [OpposingParty_1Address_1Type] = 'Home' 
				then 'Home'
				when [OpposingParty_1Address_1Type] = 'Work' 
				then 'Work' 
				else 'Other' 
				END [Address1LabelName]
			, [OpposingParty_1Address_1Line_1] [Address1Line1]
			, [OpposingParty_1Address_1Line_2] [Address1Line2]
			, [OpposingParty_1Address_1City] [Address1City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([OpposingParty_1Address_1State]) [Address1State]
			, left([OpposingParty_1Address_1Zip],10) [Address1Zip]
			, CASE 
			    WHEN NULLIF([OpposingParty_1Address_1County], '') IS NOT NULL
				AND NULLIF([OpposingParty_1Address_1Country], '') IS NOT NULL
				THEN CONCAT('County: ', [OpposingParty_1Address_1County], CHAR(13), 'Country: ', [OpposingParty_1Address_1Country] )
				ELSE NULLIF(CONCAT('Country: ', [OpposingParty_1Address_1Country] ), 'Country: ') 
			  END  [Address1Note]
			, case 
				when [OpposingParty_1Address_2Type] = 'Home' 
				then 'Home'
				when [OpposingParty_1Address_2Type] = 'Work' 
				then 'Work' 
				else 'Other' 
			  END [Address2LabelName]
			, [OpposingParty_1Address_2Line_1] [Address2Line1]
			, [OpposingParty_1Address_2Line_2] [Address2Line2]
			, [OpposingParty_1Address_2City] [Address2City]
			, [FILEVINE_META].[dbo].[udfGetStateAbbreviation]([OpposingParty_1Address_2State]) [Address2State]
			, left([OpposingParty_1Address_2Zip],10) [Address2Zip]
			,  CASE 
			    WHEN NULLIF([OpposingParty_1Address_2County], '') IS NOT NULL
				AND NULLIF([OpposingParty_1Address_2Country], '') IS NOT NULL
				THEN CONCAT('County: ', [OpposingParty_1Address_2County], CHAR(13), 'Country: ', [OpposingParty_1Address_2Country] )
				ELSE NULLIF(CONCAT('Country: ', [OpposingParty_1Address_2Country] ), 'Country: ') 
			  END [Address2Note]
			, NULL [Address3LabelName]
			, NULL [Address3Line1]
			, NULL [Address3Line2]
			, NULL [Address3City]
			, NULL [Address3State]
			, NULL [Address3Zip]
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
	-- SELECT * 
		FROM [dbo].[Firm Central matters_20221026]
		WHERE nullif([OpposingParty_1], '') is not null
		AND [OpposingParty_1] != 'Maria J. Garza'
		--AND [OpposingParty_1Address_1Line_1] is null)
		
		
		
		-- attorney

		-- ROBERT HOGAN
		INSERT INTO
		-- select distinct [PhoneNote1] FROM 
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
				, [PhoneLabelName1]
				, [PhoneNumber1]
				, [PhoneNote1]
				, [EmailLabelName1]
				, [EmailAddress1]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CustomPersonID]
			, left(newid(),6) [ContactCustomExternalID]
			, 'Attorney' [ContactTypeList]
			, 'Robert' [FirstName]
			, NULL [MiddleName]
			, 'Hogan' [LastName]
			, NULL [Prefix]
			, NULL [Suffix]
			, NULL [Nickname]
			, NULL [BirthDate]
			, NULL [FromCompany]
			, 0 [IsSingleName]
			, NULL[PhoneLabelName1]
			, NULL [PhoneNumber1]
			, NULL [PhoneNote1]
			, NULL [EmailLabelName1] --
			, NULL [EmailAddress1] -- 
			
		-- Norma Tambuna

		INSERT INTO
		-- select distinct [PhoneNote1] FROM 
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
				, [PhoneLabelName1]
				, [PhoneNumber1]
				, [PhoneNote1]
				, [EmailLabelName1]
				, [EmailAddress1]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CustomPersonID]
			, left(newid(),6) [ContactCustomExternalID]
			, 'Firm' [ContactTypeList] -- case manager
			, 'Norma' [FirstName]
			, NULL [MiddleName]
			, 'Tambuna' [LastName]
			, NULL [Prefix]
			, NULL [Suffix]
			, NULL [Nickname]
			, NULL [BirthDate]
			, NULL [FromCompany]
			, 0 [IsSingleName]
			, NULL[PhoneLabelName1]
			, NULL [PhoneNumber1]
			, NULL [PhoneNote1]
			, NULL [EmailLabelName1] --
			, NULL [EmailAddress1] -- 

	-- joy blaney
	INSERT INTO
		-- select distinct [PhoneNote1] FROM 
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
				, [PhoneLabelName1]
				, [PhoneNumber1]
				, [PhoneNote1]
				, [EmailLabelName1]
				, [EmailAddress1]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CustomPersonID]
			, left(newid(),6) [ContactCustomExternalID]
			, 'Firm' [ContactTypeList]
			, 'Joy' [FirstName]
			, NULL [MiddleName]
			, 'Blaney' [LastName]
			, NULL [Prefix]
			, NULL [Suffix]
			, NULL [Nickname]
			, NULL [BirthDate]
			, NULL [FromCompany]
			, 0 [IsSingleName]
			, NULL[PhoneLabelName1]
			, NULL [PhoneNumber1]
			, NULL [PhoneNote1]
			, NULL [EmailLabelName1] --
			, NULL [EmailAddress1] -- 


-- Lindsey Duran
	INSERT INTO
		-- select distinct [PhoneNote1] FROM 
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
				, [PhoneLabelName1]
				, [PhoneNumber1]
				, [PhoneNote1]
				, [EmailLabelName1]
				, [EmailAddress1]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CustomPersonID]
			, left(newid(),6) [ContactCustomExternalID]
			, 'Firm' [ContactTypeList]
			, 'Lindsey' [FirstName]
			, NULL [MiddleName]
			, 'Duran' [LastName]
			, NULL [Prefix]
			, NULL [Suffix]
			, NULL [Nickname]
			, NULL [BirthDate]
			, NULL [FromCompany]
			, 0 [IsSingleName]
			, NULL[PhoneLabelName1]
			, NULL [PhoneNumber1]
			, NULL [PhoneNote1]
			, NULL [EmailLabelName1] --
			, NULL [EmailAddress1] -- 


	INSERT INTO
		-- select distinct [PhoneNote1] FROM 
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
				, [PhoneLabelName1]
				, [PhoneNumber1]
				, [PhoneNote1]
				, [EmailLabelName1]
				, [EmailAddress1]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CustomPersonID]
			, left(newid(),6) [ContactCustomExternalID]
			, 'Firm' [ContactTypeList]
			, 'Jessica' [FirstName]
			, NULL [MiddleName]
			, 'Jones' [LastName]
			, NULL [Prefix]
			, NULL [Suffix]
			, NULL [Nickname]
			, NULL [BirthDate]
			, NULL [FromCompany]
			, 0 [IsSingleName]
			, NULL[PhoneLabelName1]
			, NULL [PhoneNumber1]
			, NULL [PhoneNote1]
			, NULL [EmailLabelName1] --
			, NULL [EmailAddress1] -- 

	-- SELECT * 

		--AND [OpposingParty_1Address_1Line_1] is null)
		
		
		
		
		
		
		
		SELECT *
		FROM [PT1].[ContactsCustom__ContactInfo] 
		--where firstname like '%joy%' 
		where firstname like '%robert%' --326


	END
														