USE [990000147_Dorato_ST1]
GO
/****** Object:  StoredProcedure [practicemaster].[usp_insert_staging_Projects]    Script Date: 8/3/2022 12:37:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[practicemaster].[usp_insert_staging_Projects]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 	'[practicemaster].[usp_insert_staging_Projects] has been created in [990000147_Dorato_S1] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _ST1_ */
		/*================================================================================================*/
/*

/*		STG1 TEST SCRIPT	*/
				
		INSERT INTO
			[PT1].[Projects]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__ProjectID]
				, [ProjectExternalID]
				, [ContactExternalID]
				, [ProjectName]
				, [ProjectTemplate]
				, [IncidentDate]
				, [IncidentDescription]
				, [IsArchived]
				, [PhaseName]
				, [PhaseDate]
				, [Hashtags]
				, [Username]
				, [CreateDate]
				, [ProjectNumber]
				, [ProjectEmailPrefix]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__ProjectID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, ccm.ContactExternalID [ContactExternalID]
			, concat_ws(' - ',trim(ci.[Client__ID]),cl.[Name]) [ProjectName]
			, ccm.[Filevine_ProjectTemplate] [ProjectTemplate]
			, iif([pmDateOfAccident]='mm/dd/yyyy',null,[pmDateOfAccident]) [IncidentDate]
			, null [IncidentDescription]
			, ccm.archived [IsArchived]
			, case when [pmCaseRejected] = 'Y' then 'Archived'
					when [pmCaseResolved] = 'Y' then 'Archived'
					when [pmCaseAccepted] = 'Y' and [Filevine_ProjectTemplate] = 'PI Template' then 'Treating'
					when [pmCaseAccepted] = 'Y' and [Filevine_ProjectTemplate] = 'WC' then 'Monitor'
					when [pmCaseAccepted] = 'Y' and [Filevine_ProjectTemplate] = 'GAL' then 'Investigation'
					when [pmRecvSignedContract] = 'Y' and [Filevine_ProjectTemplate] = 'PI Template' then 'Treating'
					when [pmRecvSignedContract] = 'Y' and [Filevine_ProjectTemplate] = 'WC' then 'Monitor'
					when [pmRecvSignedContract] = 'Y' and [Filevine_ProjectTemplate] = 'GAL' then 'Investigation' 
					when [pmRecvSchedOrder] = 'Y' and [Filevine_ProjectTemplate] = 'PI Template' then 'Treating'
					when [pmRecvSchedOrder] = 'Y' and [Filevine_ProjectTemplate] = 'WC' then 'Monitor'
					when [pmRecvSchedOrder] = 'Y' and [Filevine_ProjectTemplate] = 'GAL' then 'Investigation' else 'Intake' end [PhaseName]
			, NULL [PhaseDate]
			, NULL [Hashtags]
			, CASE
				WHEN [Prim__Tkprname] = 'derek@doratoweems.com' THEN 'derekweems'
				WHEN [Prim__Tkprname] = 'Kaleigh@doratoweems.com' THEN 'kaleigh'
				WHEN [Prim__Tkprname] = 'veronica@doratoweems.com.com' THEN 'veronica1'
				ELSE NULL
			  END [Username]
			, [Filevine_META].dbo.udfDate_ConvertUTC(cast([Date__Open] as datetime), 'Mountain' , 1) [CreateDate]
			, NULL [ProjectNumber]
			, NULL [ProjectEmailPrefix]
			
		
		FROM 
			__FV_ClientCaseMap ccm
			join [CASEINFO] ci on ccm.caseid = trim(ci.[Client__ID])
			left join [CMCLIENT] cl on trim(cl.[Client__ID]) = trim(ci.[Client__ID])






*/

/*		STG2 TEST SCRIPT	*/

		INSERT INTO
		-- SELECT * FROM -- delete from 
--		[FilevineStaging2Import].[BaseImport].[_Dorato_T1_Projects___49009]
--		[FilevineStaging2Import].[BaseImport].[_990000147_Dorato_ST2_Projects___47424] -- STG 2
			[PT1].[Projects]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__ProjectID]
				, [ProjectExternalID]
				, [ContactExternalID]
				, [ProjectName]
				, [ProjectTemplate]
				, [IncidentDate]
				, [IncidentDescription]
				, [IsArchived]
				, [PhaseName]
				, [PhaseDate]
				, [Hashtags]
				, [Username]
				, [CreateDate]
				, [ProjectNumber]
				, [ProjectEmailPrefix]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__ProjectID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, ccm.ContactExternalID [ContactExternalID]
			--, concat_ws(' - ',trim(cl.[Client__ID]),cl.[Name]) [ProjectName]
			, concat_ws(' - ',trim(cl.[Client__ID]),cmr.[Name])[ProjectName]-- [ProjectNameNew]
			, ccm.[Filevine_ProjectTemplate] [ProjectTemplate]
			, iif([pmDateOfAccident]='mm/dd/yyyy',null,[pmDateOfAccident]) [IncidentDate]
			, null [IncidentDescription]
			, ccm.archived [IsArchived]
			, case --when [pmCaseRejected] = 'Y' then 'Archived'
					when cl.[Inactive] = 'Y' then 'Archived'
					--when [pmCaseResolved] = 'Y' then 'Archived'
					when [Filevine_ProjectTemplate] = 'PI Template' then 'Treating'
					when [Filevine_ProjectTemplate] = 'WC' then 'Monitor'
					when [Filevine_ProjectTemplate] = 'GAL' then 'Investigation'
					else 'Intake' end [PhaseName]
			, NULL [PhaseDate]
			, NULL [Hashtags]
			, CASE
				WHEN [Prim__Tkprname] = 'derek@doratoweems.com' THEN 'derekweems'
				WHEN [Prim__Tkprname] = 'Kaleigh@doratoweems.com' THEN 'kaleigh'
				WHEN [Prim__Tkprname] = 'veronica@doratoweems.com.com' THEN 'veronica1'
				ELSE 'datamigrationteam275'
			  END [Username]
			, [Filevine_META].dbo.udfDate_ConvertUTC(cast([Date__Open] as datetime), 'Mountain' , 1) [CreateDate]
			, NULL [ProjectNumber]
			, NULL [ProjectEmailPrefix]
	-- SELECT distinct cl.[Prim__Tkprname], cl.*
		FROM __FV_ClientCaseMap ccm
		left join [CMCLIENT] cl 
			on trim(cl.[Client__ID]) = ccm.caseid
		left join cmrelate cmr 
			on cl.name = cmr.rp__key

			--2veronica 3 - kaleigh
			--1 derek
		
		--SELECt *
		--FROM [CMCLIENT] 

		--Select *
		--FROM cmrelate

--SELECT distinct *--count(*), PhaseName
--FROM [PT1].[Projects]
--group by PhaseName

--			WHERE cl.[Name] LIKE '%Baros%'
--			join [CASEINFO] ci on ccm.caseid = trim(ci.[Client__ID])
--			left join [CMCLIENT] cl on trim(cl.[Client__ID]) = trim(ci.[Client__ID])



/*


case --when [pmCaseRejected] = 'Y' then 'Archived'
					when [Inactive] = 'Y' then 'Archived'
					--when [pmCaseResolved] = 'Y' then 'Archived'
					when [pmCaseAccepted] = 'Y' and [Filevine_ProjectTemplate] = 'PI Template' then 'Treating'
					when [pmCaseAccepted] = 'Y' and [Filevine_ProjectTemplate] = 'WC' then 'Monitor'
					when [pmCaseAccepted] = 'Y' and [Filevine_ProjectTemplate] = 'GAL' then 'Investigation'
					when [pmRecvSignedContract] = 'Y' and [Filevine_ProjectTemplate] = 'PI Template' then 'Treating'
					when [pmRecvSignedContract] = 'Y' and [Filevine_ProjectTemplate] = 'WC' then 'Monitor'
					when [pmRecvSignedContract] = 'Y' and [Filevine_ProjectTemplate] = 'GAL' then 'Investigation' 
					when [pmRecvSchedOrder] = 'Y' and [Filevine_ProjectTemplate] = 'PI Template' then 'Treating'
					when [pmRecvSchedOrder] = 'Y' and [Filevine_ProjectTemplate] = 'WC' then 'Monitor'
					when [pmRecvSchedOrder] = 'Y' and [Filevine_ProjectTemplate] = 'GAL' then 'Investigation' 
					else 'Intake' end [PhaseName]



	WHERE ccm.ProjectExternalID IN(
				'14204_810'
				,'14254_858'
				,'18573_5160'
				,'18597_5184'
				,'19544_6124'
				,'19552_6132'
				,'19623_6203'
				,'19652_6232'
				,'19703_6281'
				,'19780_6358'
				,'19791_6369'
				,'19794_6372'
				,'19795_6373'
				,'19809_6387'
				,'19846_6422'
				,'19899_6475'
				,'19903_6479'
				,'19908_6484'
				,'19909_6485'
				)

*/



		
	END
														