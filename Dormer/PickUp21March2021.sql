USE [7530_DormerHarpring_GL]
GO
/****** Object:  StoredProcedure [dbo].[usp_insert_staging_NewDocuments]    Script Date: 3/17/2021 1:25:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[dbo].[usp_insert_staging_NewDocuments]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	
	IF OBJECT_ID('TEMPDB.dbo.#TEMPS3', 'U') IS NOT NULL
	DROP TABLE #TEMPS3
	SELECT CONCAT('filevine-7530/Doc/',LEFT(REPLACE(S.FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(S.FOLDERPATH,'filevine-7530/Doc/','')))) link
	, REPLACE(FOLDERPATH,CONCAT('filevine-7530/Doc/',LEFT(REPLACE(FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(FOLDERPATH,'filevine-7530/Doc/','')))),'') [DestinationFolderPath]
	,* 
	INTO #TEMPS3 
	-- SELECt COUNT(*)
	FROM S3DocScan S -- 192,271

	/*
	Jumps
Thielen (490)
Kirby
Griffin
Jakubiec
Ekeler
Eveleth
*/

	SELECt *
	FROM #TEMPS3
	where folderpath like '%co-counsel%'
	and folderpath like '%jumps%'

	SELECT CONCAT('filevine-7530/Doc/',LEFT(REPLACE(S.FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(S.FOLDERPATH,'filevine-7530/Doc/','')))) link
	, REPLACE(FOLDERPATH,CONCAT('filevine-7530/Doc/',LEFT(REPLACE(FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(FOLDERPATH,'filevine-7530/Doc/','')))),'') [DestinationFolderPath]
	,* 
	FROM S3DocScan S 
	where folderpath like '%jumps%'
	or FolderPath like '%Thielen%'
	or FolderPath like '%Kirby%' -- 2722
	or FolderPath like '%griffin%' -- 3003
	or FolderPath like '%Eveleth%' -- 3052

	SELECT *
	FROM  #TEMPS3
	where folderpath like '%jumps%'
	or FolderPath like '%Thielen%'
	or FolderPath like '%Kirby%' -- 2722
	or FolderPath like '%griffin%' -- 3003
	or FolderPath like '%Eveleth%' -- 3052

	SELECT count(*)
	FROM 	[__FV_PROJECTSNew] --13
	SELECt count(*) 
	FROM 	[dbo].[__FV_ORIGINALDOCSIMPORT]

	SELECT count(*)
	FROM [dbo].[__FV_Projects_Active] -- 205
	SELECT count(*)
	FROM  [dbo].[__FV_Projects]-- 205

1. All cases prior to 1/1 [7530_DormerHarpring_GL]..[__FV_PROJECTSNew]
2. NEW cases after 1/1 [7530_DormerHarpring_r2]..[__FV_PROJECTS]
3. Active cases only [7530_DormerHarpring_GL]..[dbo].[__FV_Projects_Active]

select * from [7530_DormerHarpring_r2]..[__FV_PROJECTS]
where [ï»¿Name] like '%Eveleth%'
 

Jumps - [7530_DormerHarpring_GL]..[__FV_PROJECTSNew]
Thielen (490) - [7530_DormerHarpring_r2]..[__FV_PROJECTS]
Kirby - [7530_DormerHarpring_r2]..[__FV_PROJECTS]
Griffin - [7530_DormerHarpring_GL]..[__FV_PROJECTSNew]
Jakubiec - [7530_DormerHarpring_r2]..[__FV_PROJECTS]
Ekeler - [7530_DormerHarpring_r2]..[__FV_PROJECTS]
Eveleth - [7530_DormerHarpring_r2]..[__FV_PROJECTS]

		select * from [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] where [s3 folder path] = '#N/A' --the s3 folder path for these records is blank causing us to not be able to link 


 
		INSERT INTO 
-- SELECt * FROM
		Filevineproductionimport.._DormerHarpringLLC_Documents___56532
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
			, CONCAT_WS('_','DOC',P.ProjectExternalID,S.DOCID) [DocExternalID] -- uniqueID for doc.
			, P.ProjectExternalID [ProjectExternalID]
			, NULL [FilevineProjectID]  -- internal id when we create a project or client creates a new one from front end.
			, NULL [NoteExternalID] -- can take docs and attach to sections or notes. don't need section, etc.
			, S.[SourceS3Bucket] [SourceS3Bucket] -- straight from s3docscan to copy in
			, S.[SourceS3ObjectKey] [SourceS3ObjectKey] -- straight from s3docscan to copy in
			, S.SourceS3ObjectKeyEncoded [SourceS3ObjectKeyEncoded] --in case there are special chars. tries object key first then this and then fails.
			, S.[FILECOMPLETE] [DestinationFileName]
			, REPLACE(s.[DestinationFolderPath],LEFT(s.[DestinationFolderPath],CHARINDEX('/',s.[DestinationFolderPath])),'') [DestinationFolderPath]
			, GETDATE() [UploadDate]
			, NULL [Hashtags]
			, 'kch' [UploadedByUsername] -- Need
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, 1 [isReload] -- 0 or null is first. 1 is it already exists and has a change. 1 does updates.
-- SELECt count(*)
 	FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] P
		JOIN #TEMPS3 S 
			ON P.[S3 Folder Path] = s.link
	where [ï»¿Name] like '%Eveleth%'
		--LEFT JOIN [__FV_PROJECTSNew] PN
		--	ON s.link = pn.folderpath
		WHERE ISNULL(S.FILEEXT,'') <> ''
		AND p.[S3 Folder Path] IN (
									SELECT [S3 Folder Path]
									FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS]
									GROUP BY [S3 Folder Path]
									HAVING COUNT(*) = 1
									)
		AND p.[S3 Folder Path] <> '#N/A' -- 88603
		and [ï»¿Name] like '%Eveleth%'

		select link from #TEMPS3 where link like '%Eveleth%'
		select * from [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] where [ï»¿Name] like '%Eveleth%'


 		-- inserted 88,603


		/* second insert */
				INSERT INTO 
			Filevineproductionimport.._DormerHarpringLLC_Documents___56532
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
			, CONCAT_WS('_','DOC',P.[ProjectExternalID],S.DOCID) [DocExternalID] -- uniqueID for doc.
			, P.ProjectExternalID [ProjectExternalID]
			, NULL [FilevineProjectID]  -- internal id when we create a project or client creates a new one from front end.
			, NULL [NoteExternalID] -- can take docs and attach to sections or notes. don't need section, etc.
			, S.[SourceS3Bucket] [SourceS3Bucket] -- straight from s3docscan to copy in
			, S.[SourceS3ObjectKey] [SourceS3ObjectKey] -- straight from s3docscan to copy in
			, S.SourceS3ObjectKeyEncoded [SourceS3ObjectKeyEncoded] --in case there are special chars. tries object key first then this and then fails.
			, S.[FILECOMPLETE] [DestinationFileName]
			, s.[DestinationFolderPath] [DestinationFolderPath]
			, GETDATE() [UploadDate]
			, NULL [Hashtags]
			, 'kch' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload] -- 0 or null is first. 1 is it already exists and has a change. 1 does updates.
-- SELECT count(*)
 	FROM [__FV_PROJECTSNew] P
		LEFT JOIN #TEMPS3 S 
			ON P.FolderPath = s.link
		WHERE ISNULL(S.FILEEXT,'') <> ''
		AND p.FolderPath <> '#N/A' -- 12858
		and s.destinationfolderpath like '%griffin%' -- 623 vs 1301


		select * from filevineproductionimport.._DormerHarpringLLC_Documents___56532
		where SourceS3ObjectKey like '%jumps%'

		-- 12,858 records inserted
		-- 101,461 total

		--Elliott, Emily/Communication/BI
		/*
		SELECT *
		FROM #TEMPS3
		WHERE link like '%Hall%'
		









		SELECt pn.*
 	FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] P -- 
		LEFT JOIN #TEMPS3 S -- all docs
			ON P.[S3 Folder Path] = s.link
		LEFT JOIN [__FV_PROJECTSNew] PN -- hope's 26
			ON s.link = pn.folderpath
		WHERE ISNULL(S.FILEEXT,'') <> ''
		AND p.[S3 Folder Path] IN (
									SELECT [S3 Folder Path]
									FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS]
									GROUP BY [S3 Folder Path]
									HAVING COUNT(*) = 1
									)
		AND p.[S3 Folder Path] <> '#N/A'
	


		SELECt COUNT(*)
 	FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] P
		LEFT JOIN [7530_DormerHarpring_GL].[dbo].[__FV_Projects_Active] PA
			ON P.projectExternalID = PA.ProjectExternalID
		LEFT JOIN #TEMPS3 S 
			ON P.[S3 Folder Path] = s.link
		LEFT JOIN [__FV_PROJECTSNew] PN
			ON s.link = pn.folderpath
		WHERE ISNULL(S.FILEEXT,'') <> ''
		AND p.[S3 Folder Path] IN (
									SELECT [S3 Folder Path]
									FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS]
									GROUP BY [S3 Folder Path]
									HAVING COUNT(*) = 1
									)
		AND p.[S3 Folder Path] <> '#N/A'








SELECT *
FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS]

		--AND CONCAT_WS('_','DOC',P.[Project Number],S.DOCID) NOT IN  (
		--															SELECT DocExternalID
		--															FROM filevinestagingimport.._DormerHarpringTEST2_NewDocuments___550052341
		--															)



		SELECT distinct destinationfilename, __errormessage, destinationFolderPath
		FROM filevinestagingimport.._DormerHarpringTEST2_NewDocuments___550052341
		WHERE __ImportStatus = 70 --replace tilda?
		and destinationfilename not like '%.dll'
		and destinationfilename not like '%.js'
		and destinationfilename not like '%.exe'
		and destinationfilename not like '%.bat'
		and destinationfilename not like '%.tmp'
		and destinationfilename not like '%.ico'
		and destinationfilename not like '%.gif'
		and destinationfilename not like '%.HTM'
		and destinationfilename not like '%.h'
		and destinationfilename not like '%.ds_store'
		and destinationfilename not like '%.msi'
		and destinationfilename not like '%.cab'
		and destinationfilename not like '%.cmd'
		and destinationfilename not like '%.db'
		and destinationfilename not like '%.ini'
		and destinationfilename not like '%.dmg'
		and destinationfilename not like '~%'
		and destinationfilename not like '%.ocx'
		and destinationfilename not like '%.inf'


		SELECT distinct destinationfilename
		FROM filevinestagingimport.._DormerHarpringTEST2_NewDocuments___550052341
		WHERE __ImportStatus = 70 --replace tilda?

		SELECT *
		FROM filevinestagingimport.._DormerHarpringTEST2_NewDocuments___550052341
		
		--REP 1 1181365339
		--REP 2 1043357811

	SELECT *
	FROM [dbo].[__FV_PROJECTS] P
		JOIN [dbo].[S3DocScan] S 
		ON P.[S3 Folder Path] = CONCAT('filevine-7530/Doc/',LEFT(REPLACE(S.FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(S.FOLDERPATH,'filevine-7530/Doc/',''))))
		WHERE ISNULL(S.FILEEXT,'') <> ''

		SELECT s.FolderPath, CONCAT('filevine-7530/Doc/',LEFT(REPLACE(S.FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(S.FOLDERPATH,'filevine-7530/Doc/','')))) folderpath2

		SELECT *
		FROM [dbo].[S3DocScan] s
		WHERE folderpath like '%Sandifer%' --, Javier

		*/
	END
														