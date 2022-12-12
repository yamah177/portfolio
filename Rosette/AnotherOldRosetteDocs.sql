USE [497_Rosette]
GO
/****** Object:  StoredProcedure [documents].[usp_insert_staging_Documents]    Script Date: 11/30/2022 1:11:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[documents].[usp_insert_staging_Documents]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT '[documents].[usp_insert_staging_Documents] has been created in [497_Rosette] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _T1_ */
		/*================================================================================================*/
	
		-- Clean
DROP TABLE IF EXISTS  #validfiles;

		SELECt  *
		into #validfiles
		from [dbo].[S3DocScan]
		WHERE filename not like '~%'
		and fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
		and filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini') 
		OR filename <> ''
		OR filename <> 'debug'


DROP TABLE IF EXISTS  #VALIDFILES;

SELECT  *
INTO #VALIDFILES
FROM [dbo].[S3DocScan] WITH(NOLOCK) 
WHERE [filename] IS NOT NULL
OR NULLIF(FileExt, '') IS NOT NULL
OR [filename] NOT LIKE '~%'
OR [filename] <> ''
OR [filename] <> 'debug'
OR fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
OR filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini') 

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
DROP TABLE IF EXISTS #tbl;

	SELECT distinct folderpath
		,SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)) firstLevel
		,replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') secondlevelOn
		, SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0)) secondLevel
		, replace(replace('/'+ replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') ,SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 1)) , '') , '//', '')ThirdLEvelOn
		INTO #tbl
		FROM #validfiles
		WHERE folderpath is not null;

DROP TABLE IF EXISTS #final;
		-- FINISHED QUERY LOGIC
		SELECt distinct
folderpath,
 firstlevel
,secondlevel
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
FROM #tbl

SELECt *
FROM [PT1_CLIENT_ALIGN].[__FV_Rosette_3ClientAlign2022_11_15]
WHERE client_master_project_parent = 'American web loan'


SELECt *
FROM [PT1_CLIENT_ALIGN].[__FV_Rosette_2ClientAlign2022_11_15]
WHERE client_master_project_parent = 'American web loan'

SELECT *
FROM #VALIDFILES
WHERE folderpath like '%american%web%loan%'

SELECt count(1)
		FROM __FV_ClientCaseMap ccm
		JOIN [PT1_CLIENT_ALIGN].[__FV_Rosette_3ClientAlign2022_11_15] a
		ON ccm.projectexternalid = left(a.projectname_billing_code_matter_matter, 62)
		JOIN #final f
			ON ccm.contactexternalid = f.client
			AND ccm.[CaseID] = f.projectname
		JOIN #validfiles s
			ON f.folderpath = s.folderpath

		WHERE a.client_master_project_parent = 'American Web Loan'
		and s.folderpath like '%American%Web%Loan%'


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
			, CONCAT(ccm.ProjectExternalID, '_',s.docid) [DocExternalID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, s.[SourceS3Bucket] [SourceS3Bucket]
			, s.[SourceS3ObjectKey] [SourceS3ObjectKey]
			, s.[SourceS3ObjectKeyEncoded] [SourceS3ObjectKeyEncoded]
			, s.filecomplete [DestinationFileName]
			, nullif(replace(replace(replace(s.folderpath, f.firstLevel, ''), f.secondLevel, ''), '//',''), '/') [DestinationFolderPath]
			, replace(nullif(replace('/'+s.folderpath, ccm.ProjectExternalID, ''), '//'), '//','') TESTTTT
			, nullif(replace(replace(s.folderpath, f.firstLevel, ''), '//',''), '/') test 
			, nullif(replace(replace(s.folderpath, '/' +ccm.ProjectExternalID, ''), '/' + f.firstLevel, '') , '/' +ccm.ProjectExternalID) test2
			, [Filevine_META].dbo.udfDate_ConvertUTC(GetDate(), 'eastern' , 1) [UploadDate]
			, NULL [Hashtags]
			, 'datamigrationteam314' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
	-- SELECT distinct  s.folderpath, nullif(replace(replace(replace(s.folderpath, f.firstLevel, ''), f.secondLevel, ''), '//',''), '/')
	--, nullif(replace(replace(s.folderpath, f.firstLevel, ''), '//',''), '/')
	-- SELECt count(1)
		FROM __FV_ClientCaseMap ccm
		JOIN [PT1_CLIENT_ALIGN].[__FV_Rosette_3ClientAlign2022_11_15] a
		ON ccm.projectexternalid = left(a.projectname_billing_code_matter_matter, 62)
		JOIN #final f
			ON ccm.contactexternalid = f.client
			AND ccm.[CaseID] = f.projectname
		JOIN #validfiles s
			ON f.folderpath = s.folderpath

		WHERE a.client_master_project_parent = 'American Web Loan'
		and s.folderpath like '%American Web Loan%'

		SELECT distinct *
		FROM #Final
		WHERE folderpath like '%American Web Loan%'

		SELECT distinct *
		FROM #validfiles
		WHERE  folderpath like '%American Web Loan%'

	
	
	--	JOIN #final f
	--		ON ccm.contactexternalid = f.client
	--		AND ccm.[CaseID] = f.projectname
	--	JOIN #validfiles s
	--		ON f.folderpath = s.folderpath

	--SELECt count(1)
	--FROM #validfiles
	--	where folderpath like '%1052.1 American Web Loan/%'
 

	--SELECt *
	--FROM #final 
	--where folderpath like '%1052.1 American Web Loan/%'
	/*
	-- ----------------------- Old -------------------------------------------------------------------------------------------

			-- Clean
DROP TABLE IF EXISTS  #validfiles;

		SELECt  *
		into #validfiles
		from [dbo].[S3DocScan]
		WHERE filename not like '~%'
		and filename not like '%#%'
		and filename not like '%&%'
		and filename not like '%*%'
		and filename not like '%{%'
		and filename not like '%}%'
		and filename not like '%\%'
		and filename not like '%:%'
		and filename not like '%<%'
		and filename not like '%>%'
		and filename not like '%?%'
		and filename not like '%/%'
		and filename not like '%+%'
		and filename not like '%|%'
		and filename not like '%"%'
		and filename <> ''
		AND filename <> 'debug'
		and fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
		and filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini') --343,519


DROP TABLE IF EXISTS #tbl;

	SELECT distinct folderpath
		,SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)) firstLevel
		,replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') secondlevelOn
		, SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0)) secondLevel
		, replace(replace('/'+ replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') ,SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 1)) , '') , '//', '')ThirdLEvelOn
		INTO #tbl
		FROM #validfiles
		WHERE folderpath is not null;

		-- BASE
/*
		SELECT distinct folderpath
		,SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)) firstLevel
		,replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') secondlevelOn
		, SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0)) secondLevel
		FROM #validfiles
		WHERE folderpath is not null
		*/


		-- FINISHED QUERY LOGIC
DROP TABLE IF EXISTS #final;
		-- FINISHED QUERY LOGIC
		SELECt distinct
folderpath,
 firstlevel
,secondlevel
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
FROM #tbl

--SELECT 
--FROM #final

--SELECt *
--FROM #validfiles


		INSERT INTO
			[PT1].[Documents]
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
			, CONCAT(ccm.ProjectExternalID, '_',s.docid) [DocExternalID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, s.[SourceS3Bucket] [SourceS3Bucket]
			, s.[SourceS3ObjectKey] [SourceS3ObjectKey]
			, s.[SourceS3ObjectKeyEncoded] [SourceS3ObjectKeyEncoded]
			, s.filecomplete [DestinationFileName]
			, replace(replace(replace(s.folderpath, f.firstLevel, ''), f.secondLevel, ''), '//','') [DestinationFolderPath]
			, [Filevine_META].dbo.udfDate_ConvertUTC(GetDate(), 'eastern' , 1) [UploadDate]
			, NULL [Hashtags]
			, 'datamigrationteam314' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
	-- SELECT count(1)
		FROM __FV_ClientCaseMap ccm
		JOIN #final f
			ON ccm.contactexternalid = f.client
			AND ccm.[CaseID] = f.projectname
		JOIN #validfiles s
			ON f.folderpath = s.folderpath
			--ON '%' + f.folderpath +'%' like s.folderpath -- without like we got docs, with like we got... expecting 343,519

		
				*/


	END
														