USE [7831_Oklahoma_GL]
GO

/****** Object:  StoredProcedure [dbo].[usp_insert_staging_NewDocuments]    Script Date: 10/13/2021 1:30:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE
	[dbo].[usp_insert_staging_NewDocuments]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		
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

IF OBJECT_ID('TEMPDB.dbo.#OpenFinal', 'U') IS NOT NULL
	DROP TABLE #OpenFinal;
 
select distinct docid, 
--replace(folderpath,'filevine-7831/docs/','') [folderpath],
replace(left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))), '/','') FolderPath
--APPLY 4 LOGIC TO GRAB CLIENT NAME
,left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))) RootFolder
,REPLACE(CASE WHEN CHARINDEX('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')) <> 0
	 THEN Left(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),''), charindex('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))
	 ELSE replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')
	 END,'/','') ClientName
-- SELECT count(*)
INTO #OpenFinal
from [dbo].[S3DocScan]
where left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/','')))
not in ('PI_Closed_Files/','WCC_Closed_Files/','','filevine-7831/')
and len(REPLACE(CASE WHEN CHARINDEX('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')) <> 0
	 THEN Left(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),''), charindex('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))
	 ELSE replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')
	 END,'/','')) > 1 -- 126743





		INSERT INTO
		--filevinestagingimport.._OklahomaLegalService_Documents___550060411
			[dbo].[_OklahomaLegalService_Documents]
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
			, null [__ErrorMessage] 
			, NULL [__WorkerID]
			, NULL [__DocID]
			, sds.docid AS [DocExternalID] -- PEID and DOCID
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
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, sds.SourceS3Bucket AS [SourceS3Bucket]
			, sds.SourceS3ObjectKey AS [SourceS3ObjectKey]
			, sds.SourceS3ObjectKeyEncoded AS [SourceS3ObjectKeyEncoded]
			, sds.FileComplete AS [DestinationFileName]
			--, fvd.[Doc_BasePath] AS [DestinationFolderPath]
			, CASE 
				WHEN    CHARINDEX('/', right(sds.folderpath, len(sds.folderpath) - (charindex(F.ClientName, sds.folderpath) ))) <> 0 -- AFTER WE KNOW EVERYTHING AFTER THE NAME... WHEN NO SLASH THEN NULL.
				THEN	right(sds.folderpath, len(sds.folderpath) - (charindex(F.ClientName, sds.folderpath) + len(F.ClientName)))
			 END AS [DestinationFolderPath] -- subfolders. 5+ or 6+. clientnames isolated in clients table, that string is in folderpath for every doc. 
			  -- take clientname and that will exist in folderpath for doc id. charindex folder path for that docid. charindex that and get position and take right of that starting at charindex of client name and then do a plus the length of the client name. gonna give a g in goeser starts. minus everything in front of charindex. 
			, Filevine_META.dbo.udfDate_ConvertUTC(GETDATE(), 'Central' , 1) AS [UploadDate]
			, NULL [Hashtags]
			, 'cdr' AS [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
-- select count(*)
			FROM [S3DocScan] SDS
				JOIN #OpenFinal F
					ON SDS.DOCID = F.DOCID -- 126743
			WHERE sds.SourceS3ObjectKey NOT like '%Thumbs.db%' -- TAKES OUT FOUR FILES
			AND sds.SourceS3ObjectKey NOT like '%.DS_Store%'
			AND sds.SourceS3ObjectKey NOT like '%.dll'
			AND sds.SourceS3ObjectKey NOT like '%.exe'
			AND sds.SourceS3ObjectKey NOT like '%DS_Store%' -- 122077
					--FfolderPath not like '%_Closed_%' -- 250,719






	INSERT INTO
		filevinestagingimport.._OklahomaLegalService_Documents___550061245
	--		[dbo].[_7831_Oklahoma_RepCas_NewDocuments]
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
			, null [__ErrorMessage] 
			, NULL [__WorkerID]
			, NULL [__DocID]
			, sds.docid AS [DocExternalID] -- PEID and DOCID
			, concat(md.ProjectExternalID,md.first_name) [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, sds.SourceS3Bucket AS [SourceS3Bucket]
			, sds.SourceS3ObjectKey AS [SourceS3ObjectKey]
			, sds.SourceS3ObjectKeyEncoded AS [SourceS3ObjectKeyEncoded]
			, sds.FileComplete AS [DestinationFileName]
			, replace(replace(replace(replace(replace(md.destinationfolderpath, '-7831/docs/', ''), '7831/docs/', ''), '831/docs/', ''), 'PI_Closed_Files/O/N/', ''), '/PI_Closed_Files/', '')   [DestinationFolderPath] 
			, Filevine_META.dbo.udfDate_ConvertUTC(GETDATE(), 'Central' , 1) AS [UploadDate]
			, NULL [Hashtags]
			, 'cdr' AS [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
-- select top 1000 *
			FROM [S3DocScan_Client_Import_Files] SDS
			inner join 			[dbo].[__FV_OklahomaDocsImportPEID2] md
			on sds.sourceS3objectkey = md.sourceS3objectkey 
			where errormessage = 'cannot find matching project for ProjectExternalID'

	
	SELECt *
	FROM filevinestagingimport.._OklahomaLegalService_Documents___550061245























	/*
		INSERT INTO
		--filevinestagingimport.._OklahomaLegalService_Documents___550056947
			[dbo].[_7831_Oklahoma_RepCas_NewDocuments]
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
			, null [__ErrorMessage] 
			, NULL [__WorkerID]
			, NULL [__DocID]
			, sds.docid AS [DocExternalID] -- PEID and DOCID
			,  concat_ws('_', replace(CONCAT_WS('_', CONCAT('P_', TRIM([5].[5])), replace(
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
			  END) AS [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, sds.SourceS3Bucket AS [SourceS3Bucket]
			, sds.SourceS3ObjectKey AS [SourceS3ObjectKey]
			, sds.SourceS3ObjectKeyEncoded AS [SourceS3ObjectKeyEncoded]
			, sds.FileComplete AS [DestinationFileName]
			--, fvd.[Doc_BasePath] AS [DestinationFolderPath]
			, CASE 
				WHEN    CHARINDEX('/', right(folderpath, len(folderpath) - (charindex([5].[5], folderpath) ))) <> 0 -- AFTER WE KNOW EVERYTHING AFTER THE NAME... WHEN NO SLASH THEN NULL.
				THEN	right(folderpath, len(folderpath) - (charindex([5].[5], folderpath) + len([5].[5])))
			 END AS [DestinationFolderPath] -- subfolders. 5+ or 6+. clientnames isolated in clients table, that string is in folderpath for every doc. 
			  -- take clientname and that will exist in folderpath for doc id. charindex folder path for that docid. charindex that and get position and take right of that starting at charindex of client name and then do a plus the length of the client name. gonna give a g in goeser starts. minus everything in front of charindex. 
			, Filevine_META.dbo.udfDate_ConvertUTC(GETDATE(), 'Central' , 1) AS [UploadDate]
			, NULL [Hashtags]
			, 'datamigrationteam' AS [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
-- select count(*)
			FROM [S3DocScan_Client_Import_Files] SDS
				JOIN #5Final [5] 
					ON SDS.DOCID = [5].DOCID
			WHERE folderPath like '%_Closed_%' -- 250,719
					AND sds.SourceS3ObjectKey NOT like '%Thumbs.db%' -- TAKES OUT FOUR FILES


					*/





/*
	select *
	from filevinestagingimport.._OklahomaLegalService_Documents___550056947
	where __ImportStatus = 70
					
	select distinct count(*), __ErrorMessage
	from filevinestagingimport.._OklahomaLegalService_Documents___550056947
	where __ImportStatus = 70
	group by  __ErrorMessage

		select *
			FROM [S3DocScan_Client_Import_Files] SDS
			INNER JOIN dbo.__FV_Clients C
				ON SDS.DOCID = C.DOCID
				where sds.FileComplete  like '%.exe'
	'.dropbox', 'desktop.ini'


	-- invalid FileExt 5132
		select count(*)
			FROM [S3DocScan_Client_Import_Files] SDS
			INNER JOIN dbo.__FV_Clients C
				ON SDS.DOCID = C.DOCID
				WHERE sds.FileNAme like '%Jennifer Interview%' -- 1
				or sds.FileNAme like '%Kelsie Interview%(2)%' -- 1
			    or sds.FileExt  like '%exe' -- 660
			    or sds.Fileext like '%dll' -- 5716
			    or sds.FileExt  like  '%js' -- 794
			    or sds.FileExt  like '%cmd%' -- 4
			    or sds.FileExt  like '%bat' --75
			    or sds.FileExt  like '%msi' -- 2
			    or sds.FileName like '~%' -- 1788
			    or sds.FileName like'%DS_Store%' -- 280
			    or sds.FileComplete  like '%tmp' -- 361
			   
	EXCEPT
	select count(*)
		FROM [S3DocScan_Client_Import_Files] SDS
		INNER JOIN dbo.__FV_Clients C
			ON SDS.DOCID = C.DOCID -- 335058
	334776

			   
				  

-- 	cannot find matching project for ProjectExternalID
	select *
	from filevinestagingimport.._OklahomaLegalService_Documents___550056947
	where __ImportStatus = 70
	and __ErrorMessage = 'cannot find matching project for ProjectExternalID'
	-- PEID of P__WC_1 and These all have and also DestinationFileName of .
-- So filter these out where these is no destinationFileName?

--	invalid file extension
select *
	from filevinestagingimport.._OklahomaLegalService_Documents___550056947
	where __ImportStatus = 70
	and __ErrorMessage = 'invalid file extension' -- 5132
-- .exe     .dll     .js        .cmd      -- .bat    - .msi

SELECT  a.__ErrorMessage, a.DestinationFileName
FROM (
select *
	from filevinestagingimport.._OklahomaLegalService_Documents___550056947
	where __ErrorMessage = 'invalid file extension'
	) a
	where a.destinationfilename not like '%.exe'
	or  a.destinationfilename not like '%.dll'
	or a.destinationfilename not like '%.js'
	or  a.destinationfilename not like '%.cmd'
	or  a.destinationfilename not like '%.bat'
	or  a.destinationfilename not like '%.msi'

------------------------------------------------------------------------

--	invalid filename
select distinct *
	from filevinestagingimport.._OklahomaLegalService_Documents___550056947
	where __ImportStatus = 70
	and __ErrorMessage = 'invalid filename'

SELECT DISTINCT a.__errorMEssage, a.DestinationFilename
from (
select  *
	from filevinestagingimport.._OklahomaLegalService_Documents___550056947
	where __ImportStatus = 70
	and __ErrorMessage = 'invalid filename' -- 3876
) a
WHERE destinationFileName not like '~%'
and destinationFileName not like '.DS_Store'
and destinationFileName not like '%.tmp'
and destinationFileName not like '.dropbox'
and destinationFileName not like 'desktop.ini'

-----------------------------------------------------------------------------
--	s3 file size limit exceeded: 8063108765 bytes
--	s3 file size limit exceeded: 8989624713 bytes
select *
	from filevinestagingimport.._OklahomaLegalService_Documents___550056947
	where __ImportStatus = 70
	and __ErrorMessage = 's3 file size limit exceeded: 8063108765 bytes'
	or __ErrorMessage = 's3 file size limit exceeded: 8989624713 bytes'
	--Jennifer Interview.mov
--Kelsie Interview (2).mov
	


	-- 329875				
----------------------------------------------------------------------------------------
/*

update filevinestagingimport.._OklahomaLegalService_Documents___550056947

	set __importstatus = 40
SELECT distinct folderpath
			,CASE 
				WHEN    CHARINDEX('/', right(folderpath, len(folderpath) - (charindex(c.clientname, folderpath) ))) <> 0 -- AFTER WE KNOW EVERYTHING AFTER THE NAME... WHEN NO SLASH THEN NULL.
				THEN	right(folderpath, len(folderpath) - (charindex(c.clientname, folderpath) + len(c.clientname)))
			 END AS SUBFOLDER
			 , CHARINDEX('/', right(folderpath, len(folderpath) - (charindex(c.clientname, folderpath)))) 
	FROM [S3DocScan_Client_Import_Files] SDS
			INNER JOIN dbo.__FV_Clients C
				ON SDS.DOCID = C.DOCID

				-- PROJECTS, CONTACTS AND DOCS, SCRIPT READY. GET ORG ACCESS AND PUSH IN TOMORROW. 


--				where folderpath = 'filevine-7831/docs/PI_2014/Wolf, Joanne ''Gai''/Emails'

				filevine-7831/docs/PI_2014/Wolf, Joanne 'Gai'/Emails
*/
				
----------------------------------------------------------------------------------------

	
/*

		-- created rep case in staging2 and moved some files just for rep case from client-import-files into west. that is why two docs scans.
		-- don't go into west. that is for new clients. 



			SELECT DISTINCT
			  0 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, CASE 
				WHEN charindex('?',sds.FileComplete) != 0 
					THEN 'DestinationFileName has bidirectional characters' 
				ELSE NULL 
			  END AS [__ErrorMessage] -- ?
			, NULL [__WorkerID]
			, NULL [__DocID]
			, CONCAT(fvd.[FV_ProjectID],'_',fvd.[Legacy_DocID],'_1') AS [DocExternalID] -- need to create with root folder or something. remove all spaced between 2nd and 3rd slash. 
			, ccm.projectExternalID AS [ProjectExternalID] -- need. 
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, sds.SourceS3Bucket AS [SourceS3Bucket]
			, sds.SourceS3ObjectKey AS [SourceS3ObjectKey]
			, sds.SourceS3ObjectKeyEncoded AS [SourceS3ObjectKeyEncoded]
			, sds.FileComplete AS [DestinationFileName]
			--, fvd.[Doc_BasePath] AS [DestinationFolderPath]
			, CASE 
				WHEN RTRIM(SUBSTRING(sds.SourceS3ObjectKey,Filevine_META.dbo.udf_findNthOccurance('/',sds.SourceS3ObjectKey,2)+1,len(sds.SourceS3ObjectKey))) = sds.FileComplete 
				THEN NULL
				ELSE RTRIM(SUBSTRING(sds.FolderPath,Filevine_META.dbo.udf_findNthOccurance('/',sds.FolderPath,2)+1,len(sds.FolderPath))) 
			  END AS [DestinationFolderPath]
			, Filevine_META.dbo.udfDate_ConvertUTC(GETDATE(), 'Central' , 1) AS [UploadDate]
			, NULL [Hashtags]
			, 'datamigration' AS [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
-- select *	
__FV_ClientCaseMap ccm
		FROM S3DocScan_Client_Import_Files

		WHERE sds.SourceS3ObjectKey NOT like '%Thumbs.db%' -- TAKES OUT FOUR FILES

	-- root folder for each case is project name
	-- recommendation: just pull from s3docscan.
	-- filevine-7831/docs/PI_2017/Conway, Ronald/CSI/Texas Scene Pics/DSC_0236.JPG
	-- ^^ strip out first two parentheses and use the rest up until maybe the last parenthese to make it unique. or include the filename to make it easier. 
	-- do new projects. pi_closed or 
	   	  
		filevine-7831-west/Pallares, Luis Alonso/.DS_Store

		select top 1000 *	
		FROM [__FV_Documents] fvd
		filevine-7831-west/Pallares, Luis Alonso/Medical Records/DVD RW Drive/41928/41930/41933
		filevine-7831-west/Pallares, Luis Alonso/Medical Records/DVD RW Drive/421377/421381/421752

		SELECT top 1000 *
		FROM S3DocScan_Client_Import_Files
		where SourceS3ObjectKey like '%closed_files%' -- set to archived and phase to arhived too
	   
		SELECT count(*)
		FROM S3DocScan_Client_Import_Files
		where SourceS3ObjectKey not like '%closed_files%' -- set to archived and phase to arhived too. set to Treatment and Investigation
		-- not 84354
		-- not 250704

		-- two templates. migrate in is the same. workers comp and pi template. based off the first two characters after docs

		SELECT count(*)
		FROM S3DocScan_Client_Import_Files
		where SourceS3ObjectKey like '%PI_%' -- 282270

		SELECT count(*)
		FROM S3DocScan_Client_Import_Files
		where SourceS3ObjectKey not like '%PI_%' -- 52788

		Workers Comp (Master)
		Personal Injury (Master)

		SELECt *
		FROM

-- My guess is that s3docscan was used for the rep case to single out Louis pallares. the full migration needs to use S3DocScan_Client_Import_Files

SELECt *
FROM s3docscan -- 7791
where SourceS3ObjectKey like '%Pallares%'

filevine-7831-west/Pallares, Luis Alonso/1-OLS Case Management & Activity Log/~$tivity Log.docx

SELECT *
FROM S3DocScan_Client_Import_Files -- DO WE NEED ANYTHING FROM THIS TABLE? 335,058 RECORDS
wHERE SourceS3ObjectKey LIKE '%pALLARES%'
*/
*/

	END
														
GO


