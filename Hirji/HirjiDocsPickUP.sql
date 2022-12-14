USE [5928_Hirji]
GO
/****** Object:  StoredProcedure [dbo].[usp_insert_staging_Documents]    Script Date: 3/10/2021 3:39:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[dbo].[usp_insert_staging_Documents]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN --		SELECT '[unknown].[usp_insert_staging_Documents] has been created in [5928_Hirji] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _ */
		/*================================================================================================*/
		
		SELECT 
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
			, CONCAT_WS('_',s.DocID, pl.PEID) [DocExternalID]
			, pl.PEID [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, s.SourceS3Bucket [SourceS3Bucket]
			, s.SourceS3ObjectKey [SourceS3ObjectKey]
			, CASE 
				WHEN len(s.SourceS3ObjectKeyEncoded) > 512
				THEN NULL
				ELSE s.SourceS3ObjectKeyEncoded
			  END AS  [SourceS3ObjectKeyEncoded]
			, s.FileComplete [DestinationFileName]
			, REPLACE(s.FolderPath, 'filevine-5928/OPEN_','') [DestinationFolderPath]
			, Filevine_META.dbo.udfDate_ConvertUTC(GETDATE(), 'pacific' , 1) [UploadDate]
			, NULL [Hashtags]
			, 'datamigrationteam1' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
	-- SELECt *	
	-- INTO   _HirjiChauTest3a_Documents
		FROM 	[dbo].[__FV_Hirji_Project_List_Clean] pl  --__FV_ClientCaseMap ccm
		INNER JOIN s3docscan s
			ON replace(replace(left(replace(s.folderpath, 'filevine-5928/open_/',''), charindex('/',replace(s.folderpath, 'filevine-5928/open_/',''))), '/', ''), '_', '') = pl.[NameClean] -- 33 rows matched
	where REPLACE(s.FolderPath, 'filevine-5928/OPEN_','') like '%Cathey%'


	/*
	SELECt max(len( REPLACE(FolderPath, 'filevine-5928/OPEN_','')))
	FROM  [dbo].[S3DocScan] 

	SELECt *
	FROM s3docscan 
	WHERE len(SourceS3Bucket) = 711

	SELECt max(len(SourceS3ObjectKeyEncoded))
	FROM  [dbo].[S3DocScan] 

	
	-- getting folder path

	SELECt distinct REPLACE(FolderPath, 'filevine-5928/OPEN_','')
	FROM  [dbo].[S3DocScan] 


	filevine-5928/OPEN_/ATSC NPA/Correspondence/Incoming


	-- import the ones that match. Let them know and see but check if there is a

	SELECT *
	FROM 	[__FV_Hirji_Project_List_Clean] -- 102 rows

	SELECt count(*)
	FROM  [dbo].[S3DocScan] -- 37592

	SELECT  distinct replace(replace(left(replace(folderpath, 'filevine-5928/open_/',''), charindex('/',replace(folderpath, 'filevine-5928/open_/',''))), '/', ''), '_', '')  name --	, pl.* 	, s.*
	--docid
	FROM [dbo].[__FV_Hirji_Project_List_Clean]  pl
	INNER JOIN s3docscan s
	ON replace(replace(left(replace(folderpath, 'filevine-5928/open_/',''), charindex('/',replace(folderpath, 'filevine-5928/open_/',''))), '/', ''), '_', '') = [Name] -- 32 matches

	
	SELECT  distinct replace(replace(left(replace(s.folderpath, 'filevine-5928/open_/',''), charindex('/',replace(s.folderpath, 'filevine-5928/open_/',''))), '/', ''), '_', '')  name --	, pl.* 	, s.*
	--docid
	FROM [dbo].[__FV_Hirji_Project_List_Clean]  pl
	INNER JOIN s3docscan s
	ON replace(replace(left(replace(s.folderpath, 'filevine-5928/open_/',''), charindex('/',replace(s.folderpath, 'filevine-5928/open_/',''))), '/', ''), '_', '') = pl.[NameClean] -- 33 rows matched


	SELECt distinct replace(left(replace(folderpath, 'filevine-5928/open_/',''), charindex('/',replace(folderpath, 'filevine-5928/open_/',''))), '/', '') 
	FROM s3docscan
	WHERE DOCID NOT IN (
	SELECT  --distinct replace(replace(left(replace(s.folderpath, 'filevine-5928/open_/',''), charindex('/',replace(s.folderpath, 'filevine-5928/open_/',''))), '/', ''), '_', '')  name --	, pl.* 	, s.*
	docid
	FROM [dbo].[__FV_Hirji_Project_List_Clean]  pl
	INNER JOIN s3docscan s
	ON replace(replace(left(replace(s.folderpath, 'filevine-5928/open_/',''), charindex('/',replace(s.folderpath, 'filevine-5928/open_/',''))), '/', ''), '_', '') = pl.[NameClean] -- 33 rows matched
	) -- 62 folders we couldn't relate. manual alignment? 




	-- get distinct list of root folders we couldn't find. 
	-- 17,837 records. roughly half matching. are we only taking potential clients or something?

	select distinct replace(replace(left(replace(s.folderpath, 'filevine-5928/open_/',''), charindex('/',replace(s.folderpath, 'filevine-5928/open_/',''))), '/', ''), '_', '')
from [5928_Hirji]..s3docscan

	SELECt count(*)
	FROM  [dbo].[S3DocScan] -- 37592

	
*/

	END
														