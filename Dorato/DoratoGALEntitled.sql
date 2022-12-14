USE [990000147_Dorato_ST1]
GO
/****** Object:  StoredProcedure [practicemaster].[usp_insert_staging_EntitledtoNotice]    Script Date: 8/4/2022 2:19:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[practicemaster].[usp_insert_staging_EntitledtoNotice]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 	'[practicemaster].[usp_insert_staging_EntitledtoNotice] has been created in [990000147_Dorato_ST1] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
		
		INSERT INTO
			[PT1].[GAL_CL_EntitledtoNotice]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [notes]
				, [documentsDocExternalIdCsv]
				, [allegedIncapacitatedPersonContactExternalID]
				, [petitionerContactExternalID]
				, [courtVisitorContactExternalID]
				, [qualifiedHealthCareProviderContactExternalID]
				, [assignedJudgeContactExternalID]
				, [opposingAttorneys]
				, [nameOfOpposingAttorneySContactExternalIdCsv]
				, [attorneySRepresentingAIP]
				, [attorneySRepresentingContactExternalIdCsv]
				, [allOtherPersonsListedInPeContactExternalIdCsv]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, CONCAT_WS('_',ccm.ProjectExternalID  , g.[pmIncapacitatedPers] 				,g.[pmCourtVisitor]				,g.[pmQHCP]				,g.[pmPetitioningAtty] ) [CollectionItemExternalID]
			--, [pmIncapacitatedPers]
			--	,[pmCourtVisitor]
			--	,[pmQHCP]
			--	,[pmPetitioningAtty] [notes] -- only when cannot find matching name, include column name followed by data

			,CASE
				WHEN nullif(g.[pmIncapacitatedPers], '') is not null
				 AND nullif(g.[pmCourtVisitor], '') is not null
				 AND nullif(g.[pmQHCP], '') is not null
				 AND nullif(g.[pmPetitioningAtty], '') is not null
				THEN CONCAT('Incapacitated Person: ', g.[pmIncapacitatedPers], CHAR(13), ' Court Visitor: ', g.[pmCourtVisitor], CHAR(13), ' QHCP: ', g.[pmQHCP], CHAR(13), ' Petitioning Attorney: ', g.[pmPetitioningAtty]) 
				
				-- threes
				-- bottom three
				WHEN nullif(g.[pmIncapacitatedPers], '') is  null
				AND nullif(g.[pmCourtVisitor], '') is not null
				AND nullif(g.[pmQHCP], '') is not null
				AND nullif(g.[pmPetitioningAtty], '') is not null
				THEN CONCAT('Court Visitor: ', g.[pmCourtVisitor], CHAR(13), ' QHCP: ', g.[pmQHCP], CHAR(13), ' Petitioning Attorney: ', g.[pmPetitioningAtty]) 

				-- 1 ,3, 4
				WHEN nullif(g.[pmIncapacitatedPers], '') is not null
				AND nullif(g.[pmCourtVisitor], '') is  null
				AND nullif(g.[pmQHCP], '') is not null
				AND nullif(g.[pmPetitioningAtty], '') is not null
				THEN CONCAT('Incapacitated Person: ', g.[pmIncapacitatedPers], CHAR(13), ' QHCP: ', g.[pmQHCP], CHAR(13), ' Petitioning Attorney: ', g.[pmPetitioningAtty]) 

				-- top three
				WHEN nullif(g.[pmIncapacitatedPers], '') is not null
				AND nullif(g.[pmCourtVisitor], '') is not null
				AND nullif(g.[pmQHCP], '') is not null
				AND nullif(g.[pmPetitioningAtty], '') is  null
				THEN CONCAT('Incapacitated Person: ', g.[pmIncapacitatedPers], CHAR(13), ' Court Visitor: ', g.[pmCourtVisitor], CHAR(13), ' QHCP: ', g.[pmQHCP], CHAR(13)) 

				-- 1,2,4
				WHEN nullif(g.[pmIncapacitatedPers], '') is not null
				AND nullif(g.[pmCourtVisitor], '') is not null
				AND nullif(g.[pmQHCP], '') is not null
				AND nullif(g.[pmPetitioningAtty], '') is  null
				THEN CONCAT('Incapacitated Person: ', g.[pmIncapacitatedPers], CHAR(13), ' Court Visitor: ', g.[pmCourtVisitor], CHAR(13), ' Petitioning Attorney: ', g.[pmPetitioningAtty]) 

				-- twos

				WHEN nullif(g.[pmIncapacitatedPers], '') is not null
				AND nullif(g.[pmCourtVisitor], '') is not null
				AND nullif(g.[pmQHCP], '') is null
				AND nullif(g.[pmPetitioningAtty], '') is null
				THEN CONCAT('Incapacitated Person: ', g.[pmIncapacitatedPers], CHAR(13), ' Court Visitor: ', g.[pmCourtVisitor]) 

				WHEN nullif(g.[pmIncapacitatedPers], '') is  null
				AND nullif(g.[pmCourtVisitor], '') is not null
				AND nullif(g.[pmQHCP], '') is not null
				AND nullif(g.[pmPetitioningAtty], '') is null
				THEN CONCAT('Court Visitor: ', g.[pmCourtVisitor], CHAR(13), ' QHCP: ', g.[pmQHCP]) 
				
				WHEN nullif(g.[pmIncapacitatedPers], '') is  null
				AND nullif(g.[pmCourtVisitor], '') is  null
				AND nullif(g.[pmQHCP], '') is not null
				AND nullif(g.[pmPetitioningAtty], '') is not null
				THEN CONCAT('QHCP: ', g.[pmQHCP], CHAR(13), ' Petitioning Attorney: ', g.[pmPetitioningAtty]) 

				WHEN nullif(g.[pmIncapacitatedPers], '') is not null
				AND nullif(g.[pmCourtVisitor], '') is  null
				AND nullif(g.[pmQHCP], '') is  null
				AND nullif(g.[pmPetitioningAtty], '') is not null
				THEN CONCAT('Incapacitated Person: ', g.[pmIncapacitatedPers], CHAR(13), ' Petitioning Attorney: ', g.[pmPetitioningAtty]) 

				WHEN nullif(g.[pmIncapacitatedPers], '') is not null
				AND nullif(g.[pmCourtVisitor], '') is  null
				AND nullif(g.[pmQHCP], '') is not null
				AND nullif(g.[pmPetitioningAtty], '') is not null
				THEN CONCAT('Incapacitated Person: ', g.[pmIncapacitatedPers], CHAR(13), ' QHCP: ', g.[pmQHCP]) 

					WHEN nullif(g.[pmIncapacitatedPers], '') is  null
				AND nullif(g.[pmCourtVisitor], '') is not null
				AND nullif(g.[pmQHCP], '') is null
				AND nullif(g.[pmPetitioningAtty], '') is not null
				THEN CONCAT('Court Visitor: ', g.[pmCourtVisitor], CHAR(13), ' Petitioning Attorney: ', g.[pmPetitioningAtty]) 
				
				-- ones

				WHEN nullif(g.[pmIncapacitatedPers], '') is  null
				AND nullif(g.[pmCourtVisitor], '') is not null
				AND nullif(g.[pmQHCP], '') is  null
				AND nullif(g.[pmPetitioningAtty], '') is  null
				THEN CONCAT('Incapacitated Person: ', g.[pmIncapacitatedPers]) 

				WHEN nullif(g.[pmIncapacitatedPers], '') is  null
				AND nullif(g.[pmCourtVisitor], '') is not null
				AND nullif(g.[pmQHCP], '') is  null
				AND nullif(g.[pmPetitioningAtty], '') is  null
				THEN CONCAT('Court Visitor: ', g.[pmCourtVisitor]) 


				WHEN nullif(g.[pmIncapacitatedPers], '') is  null
				AND nullif(g.[pmCourtVisitor], '') is  null
				AND nullif(g.[pmQHCP], '') is not null
				AND nullif(g.[pmPetitioningAtty], '') is  null
				THEN CONCAT('QHCP: ', g.[pmQHCP]) 

				WHEN nullif(g.[pmIncapacitatedPers], '') is  null
				AND nullif(g.[pmCourtVisitor], '') is  null
				AND nullif(g.[pmQHCP], '') is  null
				AND nullif(g.[pmPetitioningAtty], '') is not null
				THEN CONCAT('Petitioning Attorney: ', g.[pmPetitioningAtty]) 

				END AS [notes]

			, NULL [documentsDocExternalIdCsv]
			, /*g.[pmIncapacitatedPers] */ ip.seq__no [allegedIncapacitatedPersonContactExternalID] -- join on name [dbo].[CMRELATE] when possible and join [dbo].[CMRELATE] to client on rp__key = [name]. When not put in Notes
			, /*g.[pmPetitioningAtty]*/  pet.seq__no[petitionerContactExternalID]
			, /*g.[pmCourtVisitor]*/ cv.seq__no [courtVisitorContactExternalID]
			, /*g.[pmQHCP]*/  qhcp.seq__no[qualifiedHealthCareProviderContactExternalID]
			, NULL [assignedJudgeContactExternalID]
			, NULL [opposingAttorneys]
			, NULL [nameOfOpposingAttorneySContactExternalIdCsv]
			, NULL [attorneySRepresentingAIP]
			, NULL [attorneySRepresentingContactExternalIdCsv]
			, NULL [allOtherPersonsListedInPeContactExternalIdCsv]
	-- select *
		FROM __FV_ClientCaseMap ccm
		join [dbo].[GALINTAK] g
			on ccm.caseid = g.Seq__No
		join [dbo].[CMRELATE] ip
			on g.[pmIncapacitatedPers] = ip.name
		join [dbo].[CMRELATE] pet
			on g.[pmIncapacitatedPers] = pet.name
		join [dbo].[CMRELATE] cv
			on g.[pmIncapacitatedPers] = cv.name
		join [dbo].[CMRELATE] qhcp
			on g.[pmIncapacitatedPers] = qhcp.name

		--SELECt *
		--FROM [dbo].[GALINTAK]
		
		--SELECt *
		--FROM [PT1].[ContactsCustom__ContactInfo]
		---- join on name [dbo].[CMRELATE] when possible and join [dbo].[CMRELATE] to client on rp__key = [name]. When not put in Notes
		--SELECT *
		--FROM [dbo].[CMRELATE] 
		
		--when possible and join [dbo].[CMRELATE] to client on rp__key = [name]. When not put in Notes
		
						


	END
														