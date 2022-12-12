USE [7831_Oklahoma_GL]
GO

/****** Object:  StoredProcedure [dbo].[usp_insert_staging_NewProjects]    Script Date: 10/13/2021 1:30:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
CREATE OR ALTER PROCEDURE
	[dbo].[usp_insert_staging_NewProjects]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		--SELECT 			'[unknown].[usp_insert_staging_NewProjects] has been created in [7831_Oklahoma] database.  Please review and modifiy the procedure.'
/*	
ALTER TABLE [dbo].[_7831_Oklahoma_RepCas_NewProjects]
ALTER COLUMN [ProjectExternalID] [varchar](64) not NULL
*/

		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _RepCas_ */
		/*================================================================================================*/


IF OBJECT_ID('TEMPDB.dbo.#ClosedFinal', 'U') IS NOT NULL
	DROP TABLE #ClosedFinal;
select distinct docid
--APPLY 5 LOGIC TO GRAB CLIENT NAME
--,replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'') Name
, replace(folderpath,'filevine-7831/docs/','') FolderPath
,left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))) RootFolder
 ,case when charindex('/',trim(right(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),len(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))-len(left(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),charindex('/',trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))))) )) <> 0
	 then replace(left(trim(right(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),len(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))-len(left(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),charindex('/',trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))))) ),charindex('/',trim(right(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),len(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))-len(left(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),charindex('/',trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))))) ))),'/','')
	 else trim(right(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),len(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))-len(left(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),charindex('/',trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))))) )
	 end AS clientname
	 INTO #ClosedFinal
	 --SELECT count(*)
	 --SELECT top 1000 * 
from [dbo].[S3DocScan] -- 366328
where left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/','')))
in ('PI_Closed_Files/','WCC_Closed_Files/') -- 227903



--SELECt *
--FROM #final

--SELECt 
--left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/','')))
--from [dbo].[S3DocScan_Client_Import_Files]

--apply 4 logic

---- openfinal is done. commenting out.
--IF OBJECT_ID('TEMPDB.dbo.#OpenFinal', 'U') IS NOT NULL
--	DROP TABLE #OpenFinal;
 
--select distinct docid, 
----replace(folderpath,'filevine-7831/docs/','') [folderpath],
--replace(left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))), '/','') FolderPath
----APPLY 4 LOGIC TO GRAB CLIENT NAME
--,left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))) RootFolder
--,REPLACE(CASE WHEN CHARINDEX('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')) <> 0
--	 THEN Left(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),''), charindex('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))
--	 ELSE replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')
--	 END,'/','') ClientName
---- SELECT count(*)
--INTO #OpenFinal
--from [dbo].[S3DocScan]
--where left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/','')))
--not in ('PI_Closed_Files/','WCC_Closed_Files/','','filevine-7831/')
--and len(REPLACE(CASE WHEN CHARINDEX('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')) <> 0
--	 THEN Left(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),''), charindex('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))
--	 ELSE replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')
--	 END,'/','')) > 1 -- 126743



		INSERT INTO
	--	SELECT * FROM 
		--filevineproductionimport.._OklahomaLegalService_Projects___59054
		--order by contactexternalid
	--  SELECT * FROM 
	[dbo].[_OklahomaLegalService_Projects]
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
			, left(concat_ws('_', replace(CONCAT_WS('_', CONCAT('P_', TRIM(F.Clientname)), replace(
			CASE
				WHEN SDS.FolderPath like '%PI_%'
				THEN 'PI'
				WHEN SDS.FolderPath not like '%PI_%'
				THEN 'WC'
			  END ,' ', '') ),', ', '')
			  , CASE 
				WHEN SDS.FolderPath like '%PI_Closed_Files%'
				THEN 0
				WHEN SDS.FolderPath not like '%PI_Closed_Files%'
				THEN 1
			  END , F.RootFolder), 62)  [ProjectExternalID]
			, concat_ws('_', replace(CONCAT_WS('_', CONCAT('CON_', TRIM(F.Clientname)), replace(
			CASE
				WHEN SDS.FolderPath like '%PI_%'
				THEN 'PI'
				WHEN SDS.FolderPath not like '%PI_%'
				THEN 'WC'
			  END ,' ', '') ),', ', '')
			  , CASE 
				WHEN SDS.FolderPath like '%PI_Closed_Files%'
				THEN 0
				WHEN SDS.FolderPath not like '%PI_Closed_Files%'
				THEN 1
			  END
  			  , F.RootFolder)   [ContactExternalID]
			, null [ProjectName] 
			, CASE
				WHEN SDS.FolderPath like '%PI_%'
				THEN 'Personal Injury (Master)'
				WHEN SDS.FolderPath not like '%PI_%'
				THEN 'Workers Comp (Master)'
			  END [ProjectTemplate]
			, NULL [IncidentDate]
			, NULL [IncidentDescription]
			, CASE 
				WHEN SDS.FolderPath like '%_Closed_Files%'
				THEN 1
				WHEN SDS.FolderPath NOT like '%_Closed_Files%'
				THEN 0
			  END AS [IsArchived]
			, 'Treatment and Investigation' AS [PhaseName]
			, NULL [PhaseDate] 
			, NULL [Hashtags]
			, 'cdr' [Username] -- need dummy user in FV? same as ccm
			, NULL [CreateDate]
			, NULL [ProjectNumber] 
			, NULL [ProjectEmailPrefix]
		-- SELECT distinct RootFolder
		FROM [S3DocScan] SDS
				JOIN #ClosedFinal F
				ON SDS.DOCID = F.DOCID -- 2249
				WHERE len(F.clientname) > 1 -- 2212
				and left(F.ClientName, 50) not like	'Pi A-Z' -- 2211
				and left(F.Clientname, 50) not like 'WC A-Z'

	SELECT COUNT(*), __Importstatus
	FROM filevineproductionimport.._OklahomaLegalService_Projects___59054
	group by __importstatus

	
		INSERT INTO
	--	SELECT * FROM 
		--filevinestagingimport.._OklahomaLegalService_Projects___550060405
	--  SELECT * FROM 
		[dbo].[_OklahomaLegalService_Projects]
	--	filevineproductionimport.._OklahomaLegalService_Projects___59063
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
			, concat(md.ProjectExternalID,md.first_name) [ProjectExternalID]
			, concat(md.ContactExternalID, md.first_name)   [ContactExternalID]
			, null [ProjectName] 
			, CASE
				WHEN SDS.FolderPath like '%PI_%'
				THEN 'Personal Injury (Master)'
				WHEN SDS.FolderPath not like '%PI_%'
				THEN 'Workers Comp (Master)'
			  END [ProjectTemplate]
			, NULL [IncidentDate]
			, NULL [IncidentDescription]
			, CASE 
				WHEN SDS.FolderPath like '%_Closed_Files%'
				THEN 1
				WHEN SDS.FolderPath NOT like '%_Closed_Files%'
				THEN 0
			  END AS [IsArchived]
			, 'Treatment and Investigation' AS [PhaseName]
			, NULL [PhaseDate] 
			, NULL [Hashtags]
			, 'cdr' [Username] -- need dummy user in FV? same as ccm
			, NULL [CreateDate]
			, NULL [ProjectNumber] 
			, NULL [ProjectEmailPrefix]
		-- SELECT *
		FROM [S3DocScan] SDS
			inner join 			[dbo].[__FV_OklahomaDocsImportPEID2] md
			on sds.sourceS3objectkey = md.sourceS3objectkey 
			where errormessage = 'cannot find matching project for ProjectExternalID'


			--SELECT *
			--FROM 		filevineproductionimport.._OklahomaLegalService_Projects___59063

			--UPDATE filevineproductionimport.._OklahomaLegalService_Projects___59063
			--set __errormessage = null
			--, __importstatus = 40
			--, username = 'cdr'

			--WHERE f.folderPath like '%_Closed_%' -- 250,719
				--AND len(F.Clientname) > 1 -- 2072


		--FROM [S3DocScan_Client_Import_Files] SDS
		--		JOIN #5Final [5] 
		--		ON SDS.DOCID = [5].DOCID
		--	WHERE folderPath  like '%_Closed_%' -- 250,719
		--	AND len([5].[5]) > 1
		--	AND [5].[5] NOT IN ('PI_2014','PI_2016','WCC_2020','WCC_2019','WCC_2013', 'PI_2018','PI_2017','PI_2019','WCC_2017','WCC_2018', 'PI_2020')
		--	AND CASE
		--			WHEN TRIM(REPLACE(REVERSE(LEFT(REVERSE([5].[5]),CHARINDEX(',',REVERSE([5].[5])))), ', ', '')) = '' 
		--			THEN [5].[5]
		--			ELSE TRIM(REPLACE(REVERSE(LEFT(REVERSE([5].[5]),CHARINDEX(',',REVERSE([5].[5])))), ', ', '')) 
		--		END != ''
	

/*
			INSERT INTO
		--	SELECT COUNT(*) FROM 
			filevinestagingimport.._OklahomaTest2_Projects___550060120
		--[dbo].[_OklahomaLegalService_Projects]
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
			, concat_ws('_', replace(CONCAT_WS('_', CONCAT('P_', TRIM([4].[4])), replace(
			CASE
				WHEN SDS.FolderPath like '%PI_%'
				THEN 'PI'
				WHEN SDS.FolderPath not like '%PI_%'
				THEN 'WC'
			  END ,' ', '') ),', ', '')
			  , CASE 
				WHEN SDS.FolderPath like '%PI_Closed_Files%'
				THEN 0
				WHEN SDS.FolderPath not like '%PI_Closed_Files%'
				THEN 1
			  END)  [ProjectExternalID]
			, concat_ws('_', replace(CONCAT_WS('_', CONCAT('CON_', TRIM([4].[4])), replace(
			CASE
				WHEN SDS.FolderPath like '%PI_%'
				THEN 'PI'
				WHEN SDS.FolderPath not like '%PI_%'
				THEN 'WC'
			  END ,' ', '') ),', ', '')
			  , CASE 
				WHEN SDS.FolderPath like '%PI_Closed_Files%'
				THEN 0
				WHEN SDS.FolderPath not like '%PI_Closed_Files%'
				THEN 1
			  END)   [ContactExternalID]
			, null [ProjectName] 
			, CASE
				WHEN SDS.FolderPath like '%PI_%'
				THEN 'Personal Injury (Master)'
				WHEN SDS.FolderPath not like '%PI_%'
				THEN 'Workers Comp (Master)'
			  END [ProjectTemplate]
			, NULL [IncidentDate]
			, NULL [IncidentDescription]
			, CASE 
				WHEN SDS.FolderPath like '%_Closed_Files%'
				THEN 1
				WHEN SDS.FolderPath NOT like '%_Closed_Files%'
				THEN 0
			  END AS [IsArchived]
			, 'Treatment and Investigation' AS [PhaseName]
			, NULL [PhaseDate] 
			, NULL [Hashtags]
			, 'datamigrationteam' [Username] -- need dummy user in FV? same as ccm
			, NULL [CreateDate]
			, NULL [ProjectNumber] 
			, NULL [ProjectEmailPrefix]
		-- SELECT TOP 1000 
		FROM [S3DocScan_Client_Import_Files] SDS
				JOIN #4Final [4] 
				ON SDS.DOCID = [4].DOCID
			WHERE folderPath not like '%_Closed_%' -- 250,719
				AND len([4].[4]) > 1
				AND [4].[4] NOT IN ('PI_2014','PI_2016','WCC_2020','WCC_2019','WCC_2013', 'PI_2018','PI_2017','PI_2019','WCC_2017','WCC_2018', 'PI_2020') -- 137

	


	SELECT distinct folderpath
	FROM [S3DocScan_Client_Import_Files]
	where folderpath like '%smiley%'


			--AND CASE 
			--	WHEN SDS.FolderPath like '%PI_Closed_Files%'
			--	THEN 0
			--	WHEN SDS.FolderPath not like '%PI_Closed_Files%'
			--	THEN 1
			--  END  
			--NOT IN ('CON__WC_1','CON_PI_2014_PI_1','CON_PI_2016_PI_1','CON_PI_2017_PI_1','CON_PI_2018_PI_1','CON_PI_2019_PI_1','CON_PI_2020_PI_1','CON_WCC_2013_WC_1','CON_WCC_2017_WC_1','CON_WCC_2018_WC_1','CON_WCC_2019_WC_1')



--				where folderpath like '%filevine-7831/docs/PI_2016/Musgrave, Diana/Pleadings/OKWD Pleadings- CV-00637 (closed)%'
				--where folderpath like '%closed%'
			
				-- do i need to accommodate for this in the archived logic?
				-- filevine-7831/docs/PI_2016/Musgrave, Diana/Pleadings/OKWD Pleadings- CV-00637 (closed) 
		
	
		
		

		--WHERE ccm.ProjectExternalID like '%P_CagleJohnny_PersonalInjury%'
	*/			
----------------------------------------
-- usually do the '<none>' for the contactExternalID when there is no client for the case
/*	
-- do projects be

	select *
		from filevinestagingimport.._OklahomaLegalService_Projects___550056943

update filevinestagingimport.._OklahomaLegalService_Projects___550056943
	set __importstatus = 40


	update filevinestagingimport.._OklahomaLegalService_Projects___550056943
		set __importstatus = 40,
		__errormessage = null,
		projectTemplate = projecttemplate + ' (Master)'
		where __importstatus =70
*/

----------------------------------------


	END
														
GO


