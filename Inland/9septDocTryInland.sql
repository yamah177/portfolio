USE [162_Inland]
GO
/****** Object:  StoredProcedure [timematters].[usp_insert_staging_Documents]    Script Date: 9/9/2021 5:50:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[timematters].[usp_insert_staging_Documents]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN -- SELECT '[timematters].[usp_insert_staging_Documents] has been created in [162_Inland] database.  Please review and modifiy the procedure.'
			-- select count(*) 	FROM s3docscan -- 4,165,680

	IF OBJECT_ID('TEMPDB.dbo.#validfiles', 'U') IS NOT NULL
	DROP TABLE #validfiles;

		SELECt  *
		INTO #validfiles
		FROM s3docscan s
		WHERE RIGHT(s.SOURCES3OBJECTKEY,1) <> '/'
		AND filename <> ''
		AND s.FILENAME <> 'Thumbs'
		AND s.FILENAME NOT LIKE '~$%'
		AND ISNULL(s.FILEEXT,'') NOT IN (	'bat',	'cmd',	'com',	'dll',	'dmg',	'exe',	'js',	'msi',	'ocx',	'pif',	'pwl',	'vbs',	'bin',	'tmp'	)
		AND s.folderpath not like '%Tax returns%' --  ask client about 
		-- SELECT distinct * FROM #validfiles where folderpath like '%Closed Files- Misc Documents/%' order by folderpath -- 3,022,083
		-- Potential Cases/Potential Cases-2020/2020-Retained/Ptnl Med Mal- Cynthia Rizo/Research/Complex Regional Pain Syndrome Fact Sheet _ National Institute of Neurological Disorders and Stroke_files

	IF OBJECT_ID('TEMPDB.dbo.#CleanDocScan2', 'U') IS NOT NULL
	DROP TABLE #CleanDocScan2;

		SELECt    [ScanID]
				 ,[DocID]
				 ,[SourceS3Bucket]
				 ,[SourceS3ObjectKey]
				 ,[SourceS3ObjectKeyEncoded]
				 , Folderpath [OriginalFolderPath]
				 , CASE 
				   WHEN [FolderPath] like 'Closed Files- Misc Documents/%'
				   THEN replace([FolderPath], 'Closed Files- Misc Documents/','') 
				   ELSE [FolderPath]
				   end Folderpath
				 ,[FileName]
				 ,[FileExt]
				 ,[FileComplete]
				INTO #CleanDocScan2
				FROM #validfiles s
				-- select distinct * from #CleanDocScan2 order by folderpath 3,022,083
	
	IF OBJECT_ID('TEMPDB.dbo.#CleanDocCLOSED2', 'U') IS NOT NULL
		DROP TABLE #CleanDocCLOSED2;

		SELECt    [ScanID]
				 ,[DocID]
				 ,[SourceS3Bucket]
				 ,[SourceS3ObjectKey]
				 ,[SourceS3ObjectKeyEncoded]
				 , OriginalFolderPath
				 ,CASE 
					WHEN Folderpath like '%/%'
					THEN REPLACE(LEFT(Folderpath, CHARINDEX('/', Folderpath)), '/', '') 
					ELSE Folderpath 
					end CleanFolderpath  
				 ,[FileName]
				 ,[FileExt]
				 ,[FileComplete]
				INTO #CleanDocCLOSED2
				FROM #CleanDocScan2 s
				-- SELECT * FROM #CleanDocCLOSED2 order by cleanfolderpath -- 3,022,083
		
	IF OBJECT_ID('TEMPDB.dbo.#ExcessRemovalDoc', 'U') IS NOT NULL
		DROP TABLE #ExcessRemovalDoc;

		SELECt    [ScanID]
				 ,[DocID]
				 ,[SourceS3Bucket]
				 ,[SourceS3ObjectKey]
				 ,[SourceS3ObjectKeyEncoded]
				 , OriginalFolderPath
				 ,TRIM(replace(
				 CASE 
					WHEN CleanFolderPath like '%#%'
					THEN TRIM(LEFT(CleanFolderPath, (CHARINDEX('#', CleanFolderPath)-1)))
					WHEN CleanFolderPath like '% CLOSED%'
					THEN TRIM(LEFT(CleanFolderPath, (CHARINDEX(' CLOSED', CleanFolderPath)-1)))
					WHEN CleanFolderPath like '%CLOSED%'
					THEN TRIM(LEFT(CleanFolderPath, (CHARINDEX('CLOSED', CleanFolderPath) - 1)))
					ELSE CleanFolderPath 
					end, '+','')) ReducedPath
				 ,[FileName]
				 ,[FileExt]
				 ,[FileComplete]
				INTO #ExcessRemovalDoc
				FROM #CleanDocCLOSED2 s	
				-- SELECT DISTINCT * FROM #ExcessRemovalDoc order by reducedpath
				-- SELECT COUNT(*) FROM #ExcessRemovalDoc -- 3,022,083


	INSERT INTO
	-- select count(*) FROM 
	-- DELETE FROM
		--[PT1].[Documents]
		 FilevineStaging2Import.._162InlandTest2b_Documents___16668
		-- select count(*) FROM
		--FilevineStaging2Import.._162_inland_Test2a_Documents___14616 -- 2,018,430

			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__DocID]
				, [DocExternalID]
				, [ProjectExternalID]
				, [FilevineProjectID]
				, [NoteExternalID]
				, [SourceS3Bucket]
				, [SourceS3ObjectKey]
				, [SourceS3ObjectKeyEncoded]
				, [DestinationFileName]
				, [DestinationFolderPath]
				, [UploadDate]
				, [Hashtags]
				, [UploadedByUsername]
				, [SectionSelector]
				, [FieldSelector]
				, [CollectionItemExternalID]
				, [isReload]
			)
		SELECT DISTINCT --top 3000 
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, concat(s.DocID, ISNULL(CONCAT('P',NULLIF(MV.[sysid],''),'_C',COALESCE(NULLIF(CV.[sysid],''),'<none>') ),0)) [DocID]
			, ISNULL(CONCAT('P',NULLIF(MV.[sysid],''),'_C',COALESCE(NULLIF(CV.[sysid],''),'<none>') ),0) [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, s.SourceS3Bucket [SourceS3Bucket]
			, s.SourceS3ObjectKey [SourceS3ObjectKey]
			, s.SourceS3ObjectKeyEncoded [SourceS3ObjectKeyEncoded]
			, s.FileComplete [DestinationFileName]
			, CASE 
				WHEN s.FolderPath LIKE '%/%'
				THEN TRIM(RIGHT(s.FolderPath, len(s.FolderPath) - CHARINDEX('/', s.FolderPath)))
				ELSE NULL
				end [DestinationFolderPath]
			--	, s.folderpath
			, GETDATE() [UploadDate]
			--  Filevine_META.dbo.udfDate_ConvertUTC([UploadDate], 'Pacific' , 1) 	[UploadDate]
			, NULL [Hashtags]
			, 'datamigrationteam68' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
			--TRIM(RIGHT(OriginalFolderPath, len(OriginalFolderPath) - CHARINDEX('/', OriginalFolderPath))) [DestinationFolderPath] , OriginalFolderPath
	-- select count(*) --  distinct p.projectexternalid
		FROM PT1.Projects p -- 443 projects
		--__FV_ClientCaseMap ccm
		--INNER JOIN PT1.Projects p
		--	ON ccm.ProjectExternalID = p.projectexternalid
		LEFT JOIN [lntmuid].[MatterView] MV
			ON mv.mat_no = p.projectnumber --440 projects inner vs 443 left
		LEFT JOIN [162_Inland].[lntmuid].[ContactView] cv
				ON MV.[sysid]=cv.sysid
		LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_InlandHashtagDocAlign] a
			ON p.projectNumber = trim(replace(a.hashtag, '#','')) -- 197 projects inner vs 443 left
		LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign] b
			ON p.projectnumber = b.mat_no
		INNER JOIN #CleanDocScan2 s -- 643,690
			ON a.rootFolder = SUBSTRING (folderpath,0,CHARINDEX('/',folderpath)) -- 185 projects inner with 1,185,818 documents on 15 sept vs 443 projects with 1,186,091 docs.
			OR b.rootfolderpath = SUBSTRING (folderpath,0,CHARINDEX('/',folderpath)) --643,690 docs with left join vs 643,437 on inner
		
		--SELECT count(*)
		--FROM S3DocScan
		--WHERE folderpath like '%FORMS2%'

		-- 204 projects getting docs with inner vs 443
			-- bypass ccm and go to projects and get 185 projects with 1,185,818
		--	where p.projectname like '%ala%'
		-- 185 projects





	--IF OBJECT_ID('TEMPDB.dbo.#joinedProjects', 'U') IS NOT NULL
	--	DROP TABLE #joinedProjects;

	--	select distinct p.projectname, p.projectnumber
	--	INTO #joinedProjects
	--	FROM __FV_ClientCaseMap ccm
	--	INNER JOIN PT1.Projects p
	--		ON ccm.ProjectExternalID = p.projectexternalid
	--	INNER JOIN [lntmuid].[MatterView] MV
	--		ON mv.mat_no = p.projectnumber
	--	INNER JOIN [PT1_CLIENT_ALIGN].[__FV_InlandHashtagDocAlign] a
	--		ON p.projectNumber = trim(replace(a.hashtag, '#',''))
	--	INNER JOIN S3DocScan s
	--		ON a.rootFolder = SUBSTRING (folderpath,0,CHARINDEX('/',folderpath)) -- 1,189,901

	--	SELECT *
	--	FROM #joinedProjects -- 174

	--	IF OBJECT_ID('TEMPDB.dbo.#NotjoinedProjects', 'U') IS NOT NULL
	--	DROP TABLE #NotjoinedProjects;

	--SELECT  mat_ref, mat_no
	--INTO #NotjoinedProjects
	--FROM [162_Inland].[lntmuid].[MatterView] mv
	--WHERE status in ('Active','Settled','Actvie','Open') -- 428
	--	EXCEPT
	--SELECT *
	--FROM 			#joinedProjects -- 253 projects unjoined
			
	---- 
	--SELECT *
	--FROM #NotjoinedProjects p -- 253
	--INNER JOIN [lntmuid].[MatterView] MV
	--		ON mv.mat_no = p.mat_no
	--		OR mv.mat_ref = p.mat_ref
	--JOIN [PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign] a
	--ON p.mat_no = a.mat_no -- 19
	--OR p.mat_ref = a.mat_ref

	--WHERE a.Do_not_migrate IS NULL
	--order by 1 
	
	--SELECT *
	--FROM pt1.projects
	--order by projectname
	--where projectname like '%%paz%'

	--SELECT *
	--FROM [lntmuid].[MatterView] MV
	--where mat_no = '18-037'
	--Garcia, Nadia	



	--SELECT 
	--FROM  [PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign] a

	--SELECT *
	--FROM #joinedProjects p -- 253
	--where projectname like '%paz%'
	--WHERE projectnumber =	'18-037'


	--SELECT 17 + 19 = 36 -- 17... highlights. 
	
	--SELECT mat_no
	--FROM #NotjoinedProjects p -- 256
	--where mat_no <> ''
	--order by 1

	--SELECT mat_no
	--FROM [PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign]
	--WHERE mat_no is not null
	--order by 1
	
	--SELECt *
	--FROM [lntmuid].[MatterView] MV

	--SELECt replace(a.hashtag, '#',''), a.*
	--FROM [PT1_CLIENT_ALIGN].[__FV_InlandHashtagDocAlign] a

	--SELECT mv.mat_no, mv.[archive], a.*, mv.*
	--	FROM [lntmuid].[MatterView] MV
	--	INNER JOIN [PT1_CLIENT_ALIGN].[__FV_InlandHashtagDocAlign] a
	--		ON mv.mat_no = trim(replace(a.hashtag, '#',''))
	--		WHERE mv.[status] = 'Active'
	--	--	WHERE mv.archive = 0 -- 202

	-- select distinct projectNumber
	--	FROM __FV_ClientCaseMap ccm
	--	INNER JOIN PT1.Projects p
	--		ON ccm.ProjectExternalID = p.projectexternalid
	--		order by 1 desc

	--SELECt distinct sources3objectkey
	--FROM s3docscan
	--WHERE folderpath like '%alatorre%'


	
	--INNER JOIN #ExcessRemovalDoc ex
			--ON p.projectname = ex.ReducedPath -- 3022083 -- inner join 2018430 -- adjustment 2046309
	--		WHERE  ccm.ProjectExternalID is not null -- 13089

/*
	select count(*)
		FROM PT1.Projects p
			INNER JOIN #ExcessRemovalDoc ex
				ON p.projectname = ex.ReducedPath 
	
	select distinct projectname
	from pt1.projects
	order by projectname

	select distinct reducedpath
	from #ExcessRemovalDoc
	order by reducedpath
*/

--	-- the last million records
--	IF OBJECT_ID('CleanDocScanLeftover', 'U') IS NOT NULL
--	DROP TABLE CleanDocScanLeftover;
	
--	WITH CTE AS (
--	SELECT SourceS3ObjectKey
--	FROM #ExcessRemovalDoc
--	EXCEPT
--	SELECT SourceS3ObjectKey
--	FROM [PT1].[Documents]
--	)
--	SELECT c2.*
--	INTO CleanDocScanLeftover
--	FROM cte c
--	INNER JOIN #CleanDocScan2 c2
--		ON c.SourceS3ObjectKey = c2.SourceS3ObjectKey

---- SELECT top 1000 * FROM CleanDocScanLeftover

--SELECT distinct folderpath
--FROM CleanDocScanLeftover

--	IF OBJECT_ID('CleanDocScanLeftover2', 'U') IS NOT NULL
--	DROP TABLE CleanDocScanLeftover2;

--	SELECT --top 10000 --folderpath
--	folderpath original_folderpath
--	, CASE
--		WHEN folderpath like '%#%'
--		THEN LEFT(folderpath, charindex('#',folderpath, 1)-1)
--		WHEN folderpath like '%CLOSED%'
--		THEN LEFT(folderpath, charindex('CLOSED',folderpath, 1)-1)
--		ELSE replace(replace(replace(replace(replace(replace(folderpath, '+',''), 'Potential Cases/Potential Cases-2020/2020-Consults/Potential Business- ',''), 'Potential Cases/Potential Cases-2021/Archieve/', ''), 'Potential Cases/Potential Cases-2021/2021 NO-GOs/',''), 'OFFICE/', ''), 'Potential Cases/Potential Cases-2016/','')
--	  END AS projectName

--	, docid
--	, sources3bucket
--	, sources3objectkey
--	, sources3objectkeyEncoded
--	, FileName
--	, fileExt
--	, FileComplete
--INTO CleanDocScanLeftover2
---- SELECT count(*)
--	FROM CleanDocScanLeftover
--	where --folderpath not like '%#%'
--	      folderpath not like '%DHR%'
--	  AND folderpath not like '%Potential Cases%'
--	  AND folderpath not like 'FORMS%'
--	  AND folderpath not like 'OFFICE%'
--	  AND folderpath not like 'ricksoffice%'
--	  AND folderpath not like 'OLD CALL LOG%'
--	  AND folderpath not in ('Marketing Folder','MISC') -- Potential Cases/Potential Cases-2016 -- 918,279





--	IF OBJECT_ID('CleanDocScanLeftover3', 'U') IS NOT NULL
--	DROP TABLE CleanDocScanLeftover3;

--	  SELECt distinct top 10000
--	   CASE 
--		  WHEN projectName like '%/%'
--		  THEN LEFT(projectName, charindex('/',projectName, 1)-1)
--		  ELSE projectName
--		END AS CleanProjectName
--	-- , projectName
--	  --, docid
--	  --, sources3bucket
--	  --, sources3objectkey
--	  --, sources3objectkeyEncoded
--	  --, FileName
--	  --, fileExt
--	  --, FileComplete
--	  --, mv.mat_ref
--	  --, mv.client
--	--  INTO CleanDocScanLeftover3
--	-- select count(1)
--	  FROM CleanDocScanLeftover2 d
--	  	  INNER JOIN [lntmuid].[MatterView] mv
--		ON 	   CASE 
--				  WHEN d.projectName like '%/%'
--				  THEN LEFT(d.projectName, charindex('/',d.projectName, 1)-1)
--				  ELSE d.projectName
--				END 
--				like '%' + mv.mat_ref + '%' -- 64964

--WHERE   CASE 
--		  WHEN projectName like '%/%'
--		  THEN LEFT(projectName, charindex('/',projectName, 1)-1)
--		  ELSE projectName
--		END <> ''

------	  CleanDocScanLeftover3

--	  INNER JOIN [lntmuid].[MatterView] mv
--		ON 	   CASE 
--				  WHEN d.projectName like '%/%'
--				  THEN LEFT(d.projectName, charindex('/',d.projectName, 1)-1)
--				  ELSE d.projectName
--				END 
--				= mv.client -- 112,668
	
--	SELECT distinct count(*)
--	 --  CASE 
--		--  WHEN projectName like '%/%'
--		--  THEN LEFT(projectName, charindex('/',projectName, 1)-1)
--		--  ELSE projectName
--		--END AS CleanProjectName
--		--  , mv.mat_ref
--	 -- , mv.client
--	 FROM CleanDocScanLeftover2 d
--	  INNER JOIN [lntmuid].[MatterView] mv
--		ON 	 CASE 
--				  WHEN d.projectName like '%/%'
--				  THEN LEFT(d.projectName, charindex('/',d.projectName, 1)-1)
--				  ELSE d.projectName
--				END 
--				= mv.mat_ref -- 27879
				

--	SELECT *
--	  FROM [lntmuid].[MatterView] 


	-- second insert
	--	INSERT INTO
	--	-- select count(*)
	--		[PT1].[Documents]
	--	-- select count(*) FROM
	--	--FilevineStaging2Import.._162_inland_Test2a_Documents___7668 -- 2,018,430
	--		(
	--			  [__ImportStatus]
	--			, [__ImportStatusDate]
	--			, [__ErrorMessage]
	--			, [__WorkerID]
	--			, [__DocID]
	--			, [DocExternalID]
	--			, [ProjectExternalID]
	--			, [FilevineProjectID]
	--			, [NoteExternalID]
	--			, [SourceS3Bucket]
	--			, [SourceS3ObjectKey]
	--			, [SourceS3ObjectKeyEncoded]
	--			, [DestinationFileName]
	--			, [DestinationFolderPath]
	--			, [UploadDate]
	--			, [Hashtags]
	--			, [UploadedByUsername]
	--			, [SectionSelector]
	--			, [FieldSelector]
	--			, [CollectionItemExternalID]
	--			, [isReload]
	--		)
	--	SELECT 
	--		  40 [__ImportStatus]
	--		, GETDATE() [__ImportStatusDate]
	--		, NULL [__ErrorMessage]
	--		, NULL [__WorkerID]
	--		, NULL [__DocID]
	--		, concat(ex.DocID, ccm.ProjectExternalID) [DocID]
	--		, ccm.ProjectExternalID [ProjectExternalID]
	--		, NULL [FilevineProjectID]
	--		, NULL [NoteExternalID]
	--		, ex.SourceS3Bucket [SourceS3Bucket]
	--		, ex.SourceS3ObjectKey [SourceS3ObjectKey]
	--		, ex.SourceS3ObjectKeyEncoded [SourceS3ObjectKeyEncoded]
	--		, ex.FileComplete [DestinationFileName]
	--		, CASE 
	--			WHEN OriginalFolderPath LIKE '%/%'
	--			THEN TRIM(RIGHT(OriginalFolderPath, len(OriginalFolderPath) - CHARINDEX('/', OriginalFolderPath)))
	--			ELSE NULL
	--			end [DestinationFolderPath]
	--		, GETDATE() [UploadDate]
	--		--  Filevine_META.dbo.udfDate_ConvertUTC([UploadDate], 'Pacific' , 1) 	[UploadDate]
	--		, NULL [Hashtags]
	--		, 'datamigrationteam68' [UploadedByUsername]
	--		, NULL [SectionSelector]
	--		, NULL [FieldSelector]
	--		, NULL [CollectionItemExternalID]
	--		, NULL [isReload]
	--		--TRIM(RIGHT(OriginalFolderPath, len(OriginalFolderPath) - CHARINDEX('/', OriginalFolderPath))) [DestinationFolderPath] , OriginalFolderPath
	---- select count(*)
	--SELECT *
	--	FROM __FV_ClientCaseMap ccm
	
	--	Left JOIN PT1.Projects p
	--		ON ccm.ProjectExternalID = p.projectexternalid
	--	where projectname like '%jk%'














	













































				--IF OBJECT_ID('TEMPDB.dbo.#CleanDocScan', 'U') IS NOT NULL
	--DROP TABLE #CleanDocScan;

		--SELECt    [ScanID]
		--		 ,[DocID]
		--		 ,[SourceS3Bucket]
		--		 ,[SourceS3ObjectKey]
		--		 ,[SourceS3ObjectKeyEncoded]
		--		 , replace([FolderPath], 'Closed Files- Misc Documents/','') Folderpath
		--		 ,[FileName]
		--		 ,[FileExt]
		--		 ,[FileComplete]
		--		INTO #CleanDocScan
		--		FROM #validfiles s
			-- SELECT * FROM #CleanDocScan -- 3,023,547


	--IF OBJECT_ID('TEMPDB.dbo.#CleanDocCLOSED', 'U') IS NOT NULL
	--	DROP TABLE #CleanDocCLOSED;

		--SELECt    [ScanID]
		--		 ,[DocID]
		--		 ,[SourceS3Bucket]
		--		 ,[SourceS3ObjectKey]
		--		 ,[SourceS3ObjectKeyEncoded]
		--		 ,  Folderpath OriginalFolderPath
		--		 , replace(LEFT(replace(replace(folderpath, 'CLOSED',' CLOSED'), 'CLOSED', ''), CHARINDEX('/', replace(replace(folderpath, 'CLOSED',' CLOSED'), 'CLOSED', ''))) , '/','')CleanFolderpath  
		--		 ,[FileName]
		--		 ,[FileExt]
		--		 ,[FileComplete]
		--		INTO #CleanDocCLOSED
		--		FROM #CleanDocScan s
		--		where folderpath like '%Closed%'
			-- select * FROM #CleanDocCLOSED 2,025,610
			-- SELECT 3023547 - 2025610 = 997937

	--IF OBJECT_ID('TEMPDB.dbo.#CleanDocOpen', 'U') IS NOT NULL
	--	DROP TABLE #CleanDocOpen;

	--		SELECt    [ScanID]
	--			 ,[DocID]
	--			 ,[SourceS3Bucket]
	--			 ,[SourceS3ObjectKey]
	--			 ,[SourceS3ObjectKeyEncoded]
	--			 ,  Folderpath OriginalFolderPath
	--			 , replace(LEFT(replace(replace(folderpath, 'CLOSED',' CLOSED'), 'CLOSED', ''), CHARINDEX('/', replace(replace(folderpath, 'CLOSED',' CLOSED'), 'CLOSED', ''))) , '/','')CleanFolderpath  
	--			 ,[FileName]
	--			 ,[FileExt]
	--			 ,[FileComplete]
	--			INTO #CleanDocOpen
	--			FROM #CleanDocScan s
	--			where folderpath not like '%Closed%'
				-- 997,937
-- follow up. Cole
	--SELECT *
	--FROM #CleanDocOpen
	--where originalfolderpath not like '%#%'
	-- Hughes-Swanson+
	-- JK Solar #20-072/Client's documents

	-- #CleanDocOpen


--	Barahona CLOSED
	
		
	--IF OBJECT_ID('TEMPDB.dbo.#CleanDocHashtag', 'U') IS NOT NULL
	--DROP TABLE #CleanDocHashtag;

	--	SELECt    [ScanID]
	--			 ,[DocID]
	--			 ,[SourceS3Bucket]
	--			 ,[SourceS3ObjectKey]
	--			 ,[SourceS3ObjectKeyEncoded]
	--			 ,  OriginalFolderPath
	--			 , cleanfolderpath
	--			 , TRIM(replace(LEFT(s.CleanFolderpath, CHARINDEX('#', s.CleanFolderpath)), '#', '')) ProjectName
	--			 ,[FileName]
	--			 ,[FileExt]
	--			 ,[FileComplete]
	--			INTO #CleanDocHashtag
	--			FROM #CleanDocCLOSED s
	--			where CleanFolderpath like '%#%'
				-- 3717

		-- SELECT *		FROM #CleanDocHashtag -- 3717

		-- SELECT distinct count(*) 		FROM #CleanDocCLOSED -- 145
		-- 2344

		-- SELECT TRIM(LEFT(s.folderpath, CHARINDEX('CLOSED', s.folderpath))) ProjectName
		-- WHERE TRIM(LEFT(s.folderpath, CHARINDEX('CLOSED', s.folderpath))) <> ''
		--	where folderpath like '%#%'
			
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _Test1_ */
		/*================================================================================================*/
	-- insert for docs with folderpath like name and hashtag: TRIM(replace(LEFT(folderpath, CHARINDEX('#', folderpath)),'#', '')) DocProjectName

	-----------------Function
	--CREATE FUNCTION folderPathSplit (@fpath varchar())
	--returns table as 

	--select value from STRING_SPLIT('apple,banana,lemon,kiwi,orange,coconut',',')
	
	--	INSERT INTO
	--		[PT1].[Documents]
	--		(
	--			  [__ImportStatus]
	--			, [__ImportStatusDate]
	--			, [__ErrorMessage]
	--			, [__WorkerID]
	--			, [__DocID]
	--			, [DocExternalID]
	--			, [ProjectExternalID]
	--			, [FilevineProjectID]
	--			, [NoteExternalID]
	--			, [SourceS3Bucket]
	--			, [SourceS3ObjectKey]
	--			, [SourceS3ObjectKeyEncoded]
	--			, [DestinationFileName]
	--			, [DestinationFolderPath]
	--			, [UploadDate]
	--			, [Hashtags]
	--			, [UploadedByUsername]
	--			, [SectionSelector]
	--			, [FieldSelector]
	--			, [CollectionItemExternalID]
	--			, [isReload]
	--		)
	--	SELECT DISTINCT
	--		  40 [__ImportStatus]
	--		, GETDATE() [__ImportStatusDate]
	--		, NULL [__ErrorMessage]
	--		, NULL [__WorkerID]
	--		, NULL [__DocID]
	--		, NULL [DocExternalID]
	--		, ccm.ProjectExternalID [ProjectExternalID]
	--		, NULL [FilevineProjectID]
	--		, NULL [NoteExternalID]
	--		, NULL [SourceS3Bucket]
	--		, NULL [SourceS3ObjectKey]
	--		, NULL [SourceS3ObjectKeyEncoded]
	--		, NULL [DestinationFileName]
	--		, NULL [DestinationFolderPath]
	--		, NULL --Filevine_META.dbo.udfDate_ConvertUTC([UploadDate], 'Pacific' , 1) 
	--		[UploadDate]
	--		, NULL [Hashtags]
	--		, NULL [UploadedByUsername]
	--		, NULL [SectionSelector]
	--		, NULL [FieldSelector]
	--		, NULL [CollectionItemExternalID]
	--		, NULL [isReload]
	---- select count(*) 			
	--	FROM __FV_ClientCaseMap ccm
	--	INNER JOIN PT1.Projects p
	--		ON ccm.ProjectExternalID = p.projectexternalid
	--	INNER JOIN #validfiles  s
	--		ON p.projectname = TRIM(replace(LEFT(s.folderpath, CHARINDEX('#', s.folderpath)),'#', '')) --
		

	--SELECT distinct top 10000 TRIM(replace(LEFT(folderpath, CHARINDEX('#', folderpath)),'#', '')) DocProjectName -- 221 distinct folderpaths
	--, folderpath original
	--FROM s3docscan -- 4,165,680

	--SELECT top (10000) * 
	--FROM s3docscan -- 4,165,680
		
	--	where ex.OriginalFolderPath IN ('365 Logistic Solutions, LLC #19-114', 'Martin, Erwin on behalf of Aiden #18-085')
			-- 365 Logistic Solutions, LLC #19-114
			-- Martin, Erwin on behalf of Aiden #18-085
		--	'Discovery/POD/Radiology/SARH - XR Wrist (Left)/SARH - CT Spine Lumbar DOS 10-6-2017/data/VIEWER/bin/resources'
		

		--	ON p.projectname = TRIM(LEFT(s.folderpath, CHARINDEX('CLOSED', s.folderpath) --

			/*
	-- how many folderpaths/files are in Closed Files- Misc Documents.
Closed Files- Misc Documents/Estrada, P CLOSED/Estrada, Patrick (1.9.19 accident)/Letters
Closed Files- Misc Documents/Castorena-Quan, Linda CLOSED/Letters
Closed Files- Misc Documents/Estrada, P CLOSED/Estrada, Patrick (1.9.19 accident)/Medical/Team PT
Closed Files- Misc Documents/Estrada, P CLOSED/Letters
George, Alonzo CLOSED/Discovery/RPD Set 2/
Hitt, Wyatt CLOSED
--
Hofrock, Sandra+/Letters
Ho, Michelle+/2nd Accident - 1-2-17/Pleadings
Hillman, John & Francesca+/Pleadings
-- strip out everything left of the first slash
Decton/Mechanic Liens
Huerta, J/Retainers & Intakes

Huerta, J/Spanish
Hughes-Swanson+/Discovery/Def POD/Exhibit C ARMC Radiology Films/data/VIEWER/sys/data/Emerald/DisplayProtocol/{0552054B-80BC-4C58-8897-450B290551B9}
Closed Files- Misc Documents/Estrada, P CLOSED/Estrada, Patrick (1.9.19 accident)
Huerta, J/Spanish/spanish letters
Huerta, J/Time Sheets/Time Off Request
		
		
*/


	END
														