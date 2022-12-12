-- new try docs
	-- Clean
DROP TABLE IF EXISTS  #validfiles;

		SELECt  *
		into #validfiles
		from [dbo].[S3DocScan]
		WHERE filename not like '~%'
		and fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
		and filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini') 
		AND filename <> ''
		AND filename <> 'debug' -- 347471


--DROP TABLE IF EXISTS  #VALIDFILES;

--SELECT  *
--INTO #VALIDFILES
---- select count(1)
--FROM [dbo].[S3DocScan] WITH(NOLOCK) 
--WHERE [filename] IS NOT NULL
--OR NULLIF(FileExt, '') IS NOT NULL
--OR [filename] NOT LIKE '~%'
--OR [filename] <> ''
--OR [filename] <> 'debug'
--OR fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
--OR filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini')  -- 348924

		--and filename not like '%#%'
		--and filename not like '%&%'
		--and filename not like '%*%'
		--and filename not like '%{%'
		--and filename not like '%}%'
		--and filename not like '%\%'
		--and filename not like '%:%'
		--and filename not like '%<%'
		--and filename not like '%>%'
		--and filename not like '%?%'
		--and filename not like '%/%'
		--and filename not like '%+%'
		--and filename not like '%|%'
		--and filename not like '%"%'

SELECT count(1)
FROM #VALIDFILES
WHERE folderpath like '%American%web%loan%' -- 2232

DROP TABLE IF EXISTS #tbl;

	SELECT distinct s.*
		,SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)) firstLevel
		,replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') secondlevelOn
		, SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0)) secondLevel
		, replace(replace('/'+ replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') ,SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 1)) , '') , '//', '')ThirdLEvelOn
		INTO #tbl
		FROM #validfiles s
		WHERE folderpath is not null;

		SELECT *
		FROM #tbl
		WHERe folderpath like  '%American%web%loan%'

DROP TABLE IF EXISTS #final;
		-- FINISHED QUERY LOGIC
		SELECt distinct
		s.*
--folderpath,
-- firstlevel
--,secondlevel
,	CASE 
	  WHEN firstLevel like '%.%'
	  THEN TRIM(replace(replace(filevine_meta_test.dbo.[RemoveNumericCharacters](firstLevel), '.', ''), '-',''))
	  WHEN secondLevel like '%.%'
	  AND firstlevel  not  like '%.%'
	  --AND secondlevel not like '%.%'
	  THEN TRIM(replace(replace(replace(filevine_meta_test.dbo.[RemoveNumericCharacters](firstLevel), '.', ''), '-',''), 'a ', ''))
	  ELSE replace(firstlevel, '%[-()0-9]%', '')
	END AS client
  , CASE 
	  WHEN firstLevel like '%.%'
	  THEN firstLevel 
	  WHEN firstLevel not like '%.%'
	  AND nullif(secondlevel, '') is not null
	  AND secondLevel like '%.%'
	  THEN secondLevel 
	  ELSE firstlevel
	END AS projectname
	INTO #final
FROM #tbl s

SELECT *
FROM #final
WHERE client = 'american web loan'

		INSERT INTO
		-- delete from
			[PT1].[Documents]
			--filevinestaging2import.._Rosette_T2_Documents___60282
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
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, CONCAT(ccm.ProjectExternalID, '_',f.docid) [DocExternalID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, f.[SourceS3Bucket] [SourceS3Bucket]
			, f.[SourceS3ObjectKey] [SourceS3ObjectKey]
			, f.[SourceS3ObjectKeyEncoded] [SourceS3ObjectKeyEncoded]
			, f.filecomplete [DestinationFileName]
			,  replace(nullif(replace('/'+f.folderpath, ccm.ProjectExternalID, ''), '//'), '//','')[DestinationFolderPath]
			, [Filevine_META].dbo.udfDate_ConvertUTC(GetDate(), 'eastern' , 1) [UploadDate]
			, NULL [Hashtags]
			, 'datamigrationteam314' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
	-- SELECT distinct  s.folderpath, nullif(replace(replace(replace(s.folderpath, f.firstLevel, ''), f.secondLevel, ''), '//',''), '/')
	--, nullif(replace(replace(s.folderpath, f.firstLevel, ''), '//',''), '/')
	--SELECt * FROM [PT1_CLIENT_ALIGN].[__FV_Rosette_3ClientAlign2022_11_15] 
	-- select count(1) -- select *
		FROM __FV_ClientCaseMap ccm
		-- select *
		left JOIN [PT1_CLIENT_ALIGN].[__FV_Rosette_3ClientAlign2022_11_15] a
		--FROM [PT1_CLIENT_ALIGN].[__FV_Rosette_3ClientAlign2022_11_15] a
		ON trim(ccm.projectexternalid) = left(a.projectname_billing_code_matter_matter, 62)
		JOIN #final f
			--ON ccm.contactexternalid = f.client
			ON a.client_master_project_parent = f.client
			AND f.FolderPath like  '%' + a.subfolders + '%' 
			WHERE projectexternalid like '%american%'
			--order by f.filename 
			--AND ccm.caseid = f.projectname
			--AND left(a.projectname_billing_code_matter_matter, 62) = f.projectname
	
			

		--JOIN #validfiles s
		--	ON f.folderpath = s.folderpath
			WHERE  s.sources3objectkey like '%American%Web%Loan%'
		AND a.client_master_project_parent = 'American Web Loan'
		--AND projectexternalid = '1052.1 American Web Loan'
		and s.folderpath like '%American Web Loan%'


		SELECt *
		FROM  [PT1_CLIENT_ALIGN].[__FV_Rosette_3ClientAlign2022_11_15]
			WHERE projectexternalid like '%american%'
		and f.client =  'American Web Loan'

		SELECT *
		FROM #final
		
		WHERE folderpath like '%American Web Loan%'

		SELECT distinct *
		FROM #Final
		WHERE folderpath like '%American Web Loan%'

		SELECT distinct *
		FROM #validfiles
		WHERE  folderpath like '%American Web Loan%'