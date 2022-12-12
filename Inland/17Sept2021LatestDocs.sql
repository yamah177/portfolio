-- temp table create
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

-- first
		
	INSERT INTO
	-- select count(*) FROM 
	-- DELETE FROM
		--[PT1].[Documents]
		 --FilevineStaging2Import.._162InlandTest2b_Documents___16668 -- 2k successfully loaded
		-- FilevineStaging2Import.._162InlandTest2b_Documents___16865 -- this will get the rest.
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
			, concat(s.DocID, ISNULL(CONCAT('P',NULLIF(MV.[sysid],''),'_C',COALESCE(NULLIF(CV.[sysid],''),'<none>') ),0)) [DocExternalID]
			,	ccm.projectexternalid [ProjectExternalID]
			--, CONCAT('P',NULLIF(MV.[sysid],''),'_C',b.RootFolderPath) [ProjectExternalID]
			--, b.RootFolderPath [ProjectExternalID]
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
		FROM  __FV_ClientCaseMap ccm
			LEFT JOIN [162_Inland].[lntmuid].[MatterView] MV 
				ON ccm.CaseID = MV.[sysid]
			LEFT JOIN [162_Inland].[lntmuid].[ContactView] cv
				ON MV.[sysid]=cv.sysid
			LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_InlandHashtagDocAlign] a
				ON mv.mat_no = trim(replace(a.hashtag, '#','')) -- 197 projects inner vs 443 left
			INNER JOIN #CleanDocScan2 s -- 643,690
				ON a.rootFolder = SUBSTRING (folderpath,0,CHARINDEX('/',folderpath)) -- 185 projects inner with 1,185,818 documents on 15 sept vs 443 projects with 1,186,091 docs.
	-- 498,621

	---- validation
		--SELECT distinct projectexternalid
		--	FROM 		 FilevineStaging2Import.._162InlandTest2b_Documents___16865 -- this will get the rest.
		--	WHERE projectexternalid  not IN ( SELECT projectexternalid
		--										FROM  FilevineStaging2Import.._162InlandTest2b_Projects___16638
		--							)


-- second		-- second insert
	INSERT INTO
	-- select count(*) FROM 
	-- DELETE FROM
		[PT1].[Documents]
		 --FilevineStaging2Import.._162InlandTest2b_Documents___16668 -- 2k successfully loaded
		-- FilevineStaging2Import.._162InlandTest2b_Documents___16865 -- this will get the rest.
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
		SELECT DISTINCT -- top 3000 
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, concat(s.DocID,b.RootFolderPath ) [DocExternalID]
			--, ISNULL(CONCAT('P',NULLIF(MV.[sysid],''),'_C',COALESCE(NULLIF(CV.[sysid],''),'<none>') ),0) [ProjectExternalID]
		--	, CONCAT('P',NULLIF(MV.[sysid],''),'_C',b.RootFolderPath) [ProjectExternalID]
			, b.RootFolderPath [ProjectExternalID]
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

		--SELECT count(*)
		FROM PT1.Projects p -- 443 projects
		--__FV_ClientCaseMap ccm
		--INNER JOIN PT1.Projects p
		--	ON ccm.ProjectExternalID = p.projectexternalid
		--LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_InlandHashtagDocAlign] a
--			ON p.projectNumber = trim(replace(a.hashtag, '#','')) -- 197 projects inner vs 443 left
		FULL JOIN [PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign] b
			ON p.projectexternalid = b.rootfolderpath
		FULL OUTER JOIN #CleanDocScan2 s -- 643,690
	--		ON a.rootFolder = SUBSTRING (folderpath,0,CHARINDEX('/',folderpath)) -- 185 projects inner with 1,185,818 documents on 15 sept vs 443 projects with 1,186,091 docs.
			ON b.rootfolderpath = SUBSTRING (s.folderpath,0,CHARINDEX('/',s.folderpath)) --643,690 docs with left join vs 643,437 on inner
			WHERE b.create_shell = 'Y'
			AND b.RootFolderPath IN ('FORMS','FORMS2')
			--780
			--SELECT distinct *
			--FROM 			[PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign]

			--SELECT *
			--FROM #CleanDocScan2 s
			--WHERE SUBSTRING (s.folderpath,0,CHARINDEX('/',s.folderpath)) IN ('FORMS','FORMS2')

-- validation
		--SELECT distinct projectexternalid
		--	FROM 		 FilevineStaging2Import.._162InlandTest2b_Documents___16865 -- this will get the rest.
		--	WHERE projectexternalid  not IN ( SELECT projectexternalid
		--										FROM  FilevineStaging2Import.._162InlandTest2b_Projects___16638
		--							)


-- 3rd insert
	INSERT INTO
	-- select count(*) FROM 
	-- DELETE FROM
		[PT1].[Documents]
		 --FilevineStaging2Import.._162InlandTest2b_Documents___16668 -- 2k successfully loaded
		-- FilevineStaging2Import.._162InlandTest2b_Documents___16865 -- this will get the rest.
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
			, concat(s.DocID,  CONCAT('P',NULLIF(MV.[sysid],''),'_C',a.RootFolderPath)) [DocExternalID]
			--, ISNULL(CONCAT('P',NULLIF(MV.[sysid],''),'_C',COALESCE(NULLIF(CV.[sysid],''),'<none>') ),0) [ProjectExternalID]
			, left(CONCAT('P',NULLIF(MV.[sysid],''),'_C',a.RootFolderPath)  , 64) [ProjectExternalID]
			--, b.RootFolderPath [ProjectExternalID]
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
	FROM [PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign] a   
	LEFT JOIN [162_Inland].[lntmuid].[MatterView] MV       
		ON a.mat_no = MV.mat_no     
		OR a.mat_ref = mv.mat_ref    
	LEFT JOIN [162_Inland].[lntmuid].[ContactView] cv     
		ON MV.[sysid]=cv.sysid    
		INNER JOIN #CleanDocScan2 s 
			ON a.rootfolderpath = SUBSTRING (folderpath,0,CHARINDEX('/',folderpath)) 
	WHERE a.do_not_migrate = 'x'   -- 147,362   

--			FROM [PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign] a     
--LEFT JOIN [162_Inland].[lntmuid].[MatterView] MV       
--ON a.mat_no = MV.mat_no     
--OR a.mat_ref = mv.mat_ref    
--LEFT JOIN [162_Inland].[lntmuid].[ContactView] cv     
--ON MV.[sysid]=cv.sysid    
--WHERE a.do_not_migrate = 'x'     


--			SELECT distinct projectexternalid
--			FROM 		 FilevineStaging2Import.._162InlandTest2b_Documents___16865 -- this will get the rest.
--WHERE projectexternalid  not IN ( SELECT projectexternalid
--								FROM  FilevineStaging2Import.._162InlandTest2b_Projects___16638
--							--	WHERE projectexternalid like '%forms%'
--								)



---- old 3rd insert from
--FROM PT1.Projects p -- 443 projects
--		--__FV_ClientCaseMap ccm
--		--INNER JOIN PT1.Projects p
--		--	ON ccm.ProjectExternalID = p.projectexternalid
--		LEFT JOIN [lntmuid].[MatterView] MV
--			ON mv.mat_no = p.projectnumber --440 projects inner vs 443 left
--		LEFT JOIN [162_Inland].[lntmuid].[ContactView] cv
--				ON MV.[sysid]=cv.sysid
--	--	LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_InlandHashtagDocAlign] a
--		--	ON p.projectNumber = trim(replace(a.hashtag, '#','')) -- 197 projects inner vs 443 left
--		LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign] b
--			ON p.projectnumber = b.mat_no
--	--	FROM PT1.Projects p -- 443 projects
--	--	--__FV_ClientCaseMap ccm
--	--	--INNER JOIN PT1.Projects p
--	--	--	ON ccm.ProjectExternalID = p.projectexternalid
--	--	LEFT JOIN [lntmuid].[MatterView] MV
--	--		ON mv.mat_no = p.projectnumber --440 projects inner vs 443 left
--	--	LEFT JOIN [162_Inland].[lntmuid].[ContactView] cv
--	--			ON MV.[sysid]=cv.sysid
--	----	LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_InlandHashtagDocAlign] a
--	--	--	ON p.projectNumber = trim(replace(a.hashtag, '#','')) -- 197 projects inner vs 443 left
--	--	LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_InlandProjectDocAlign] b
--	--		ON p.projectnumber = b.mat_no
--		INNER JOIN #CleanDocScan2 s -- 643,690
--	--		ON a.rootFolder = SUBSTRING (folderpath,0,CHARINDEX('/',folderpath)) -- 185 projects inner with 1,185,818 documents on 15 sept vs 443 projects with 1,186,091 docs.
--			ON b.rootfolderpath = SUBSTRING (folderpath,0,CHARINDEX('/',folderpath)) --643,690 docs with left join vs 643,437 on inner
--			-- 144,816