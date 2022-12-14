USE [990000153_Hogan_T2]
GO
/****** Object:  StoredProcedure [firmcentral].[usp_insert_staging_Documents]    Script Date: 11/23/2022 9:36:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[firmcentral].[usp_insert_staging_Documents]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT '[firmcentral].[usp_insert_staging_Documents] has been created in [990000153_Hogan_T2] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: ALL */
		/*================================================================================================*/
		
		--SELECT *
		--FROM #docscan1
		--WHERE filename like 'POA%Invoice_6-2020.pdf'
		-- POA Invoice_6-2020.pdf WHAT IS FILTERING THIS OUT

		drop table if exists #docscan1;

		SELECT CASE
				 WHEN folderpath like 'Wills/%'
				 THEN SUBSTRING(replace(s.FolderPath , 'Wills/', ''),0,CHARINDEX('/',replace(s.FolderPath , 'Wills/', ''))+1)
				 ELSE SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1) 
			   END AS link
			   , replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(s.[filename], '#','_'), '&','_'), '*',''), '{','+'), '}','_'), '\','_'), ':','_'), '<','_'), '>','_'), '?','_'), '/','_'), '+','_'), '|','_'), '"','_') cleanFilename
				,SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)) firstLevel
		,replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') secondlevelOn
		, SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0)) secondLevel
		, nullif(replace(replace('/'+ replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') ,SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 1)) , '') , '//', ''), '/')ThirdLEvelOn
		, s.*
		INTO #docscan1
		FROM s3docscan  s
		WHERE filename not like '~%'
		and filename <> ''
		AND filename <> 'debug'
		and fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
		and filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini') --343,519
		;


	DROP TABLE IF EXISTS #docs;

		SELECT TRIM(replace(LEFT(secondlevel, charindex(' ', secondlevel) ), ',','')) firstname, 
		TRIM(RIGHT(secondlevel, CHARINDEX (' ' ,REVERSE(secondlevel)))) secondname
		,CONCAT(TRIM(replace(LEFT(secondlevel, charindex(' ', secondlevel) ), ',','')) ,' ',TRIM(RIGHT(secondlevel, CHARINDEX (' ' ,REVERSE(secondlevel))))) nm
	 , s.*
	INTO #docs
	FROM #docscan1 s


		
		--SELECT *
		--FROM ##docscan1
		--WHERE folderpath like '%aequ%'

		DROP TABLE IF EXISTS #docAlign;

		SELECt CASE
			WHEN LEN(TRIM(Matter_Num)) = 4
			THEN Matter_Num
			WHEN LEN(TRIM(Matter_Num)) = 3
			THEN CONCAT('0' , Matter_Num)
			WHEN LEN(TRIM(Matter_Num)) = 2
			THEN CONCAT('00' , Matter_Num) 
			WHEN LEN(TRIM(Matter_Num)) = 1
			THEN CONCAT('000', Matter_Num) 
			ELSE 'Unaligned Docs'
		  END AS Matter_Num_FIX
		  , a.*
		  INTO #docAlign
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign2] a
		WHERE Matter_num != 'Unaligned Docs' -- 651
		--AND matter_name like '%chero%'
		order by Matter_Num
	
		--SELECt *
		--FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]
		----where matter_name like '%aster%'
		--WHERE matter_num = '1035'
		

		DROP TABLE IF EXISTS #docUnAlign;

		SELECt *
		  INTO #docUnAlign
	-- SELECT *
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]  
		WHERE Matter_num = 'Unaligned Docs' -- 651



		--SELECT *
		--FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]  
		--WHERE Matter_num != 'Unaligned Docs' -- 651

		DROP TABLE IF EXISTS #Missing;

		SELECT [SourceS3ObjectKey]
		FROM #docscan1
		EXCEPT 
		SELECT [SourceS3ObjectKey]
		FROM 		filevinestaging2import.._HoganT5_Documents___60312
			
			



	-- all first level - but do they match clean to folderpath? 

		INSERT INTO
		-- SELECT * FROM  -- delete from -- select count(1) FROM 
			--[PT1].[Documents]
			filevinestaging2import.._HoganT5_Documents___60312
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
		SELECT DISTINCT --top 1000 
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, Left(CONCAT_WS('_',ccm.ProjectExternalID,s.docid,reverse(s.[SourceS3ObjectKey]),s.s3objectbytes, s.filecomplete,s.fileext  ), 255)[DocExternalID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, s.sourceS3Bucket [SourceS3Bucket]
			, s.[SourceS3ObjectKey] [SourceS3ObjectKey]
			, s.[SourceS3ObjectKeyEncoded] [SourceS3ObjectKeyEncoded]
			, s.filecomplete [DestinationFileName]
			, replace(SUBSTRING(s.FolderPath,CHARINDEX('/',s.FolderPath)+1,LEN(s.FolderPath)), p.projectname + '/', '')  [DestinationFolderPath]
			, [Filevine_META].dbo.udfDate_ConvertUTC(getdate(), 'pacific' , 1) [UploadDate]
			, NULL [Hashtags]
			, 'datamigrationteam280' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
			--, s.*
	-- select distinct s.*
	-- SELECT count(1)
		FROM __FV_ClientCaseMap ccm
		JOIN pt1.projects p
			on ccm.projectexternalid = p.projectexternalid
			
		JOIN #docAlign a
			ON trim(ccm.caseid) = trim(a.matter_num_fix)
			
		join #docs /*#docscan1*/ s
			on trim(a.folder_path) = trim(s.link) -- 249,818 -- with cleaned up files it's 149,564
			--OR trim(a.folder_path) like '%'+ trim(s.firstlevel) + '%'
			--OR trim(a.folder_path) like '%'+ trim(s.secondlevel) + '%'
			--OR trim(a.folder_path) like '%'+ trim(s.secondlevel) + '%'
			--OR trim(a.folder_path) like '%'+ replace(trim(s.thirdlevelON), '/','') + '%'			
			--order by 14
			
-- INSERT 2 ------------
	INSERT INTO
		-- SELECT * FROM  -- delete from -- select count(1)
			--[PT1].[Documents]
			filevinestaging2import.._HoganT5_Documents___60312
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
		SELECT DISTINCT --top 1000 
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, Left(CONCAT_WS('_',ccm.ProjectExternalID,s.docid,reverse(s.[SourceS3ObjectKey]),s.s3objectbytes, s.filecomplete,s.fileext  ), 255)[DocExternalID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, s.sourceS3Bucket [SourceS3Bucket]
			, s.[SourceS3ObjectKey] [SourceS3ObjectKey]
			, s.[SourceS3ObjectKeyEncoded] [SourceS3ObjectKeyEncoded]
			, s.filecomplete [DestinationFileName]
			, replace(SUBSTRING(s.FolderPath,CHARINDEX('/',s.FolderPath)+1,LEN(s.FolderPath)), p.projectname + '/', '')  [DestinationFolderPath]
			, [Filevine_META].dbo.udfDate_ConvertUTC(getdate(), 'pacific' , 1) [UploadDate]
			, NULL [Hashtags]
			, 'datamigrationteam280' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
			--, s.*
	-- select distinct s.*
	-- SELECT count(1)
		FROM __FV_ClientCaseMap ccm
		JOIN pt1.projects p
			on ccm.projectexternalid = p.projectexternalid
			
		JOIN #docAlign a
			ON trim(ccm.caseid) = trim(a.matter_num_fix)
			
		join #docs /*#docscan1*/ s
			on trim(a.folder_path) like '%'+ trim(s.firstlevel) + '%' -- 275909
		WHERE Left(CONCAT_WS('_',ccm.ProjectExternalID,s.docid,reverse(s.[SourceS3ObjectKey]),s.s3objectbytes, s.filecomplete,s.fileext  ), 255)NOT IN (SELECT [DocExternalID]
						FROM filevinestaging2import.._HoganT5_Documents___60312
						) -- 125,280

--OR trim(a.folder_path) like '%'+ trim(s.firstlevel) + '%'
			--OR trim(a.folder_path) like '%'+ trim(s.secondlevel) + '%'
			--OR trim(a.folder_path) like '%'+ trim(s.secondlevel) + '%'
			--OR trim(a.folder_path) like '%'+ replace(trim(s.thirdlevelON), '/','') + '%'	



			SELECt count(1)
			FROM #docs -- 209142

			SELECt count(1)
			FROM filevinestaging2import.._HoganT5_Documents___60312 -- 149563

			

			
			--SELECt *
			--FROM #docs
			--	WHERE folderpath like '%johnson, john%'
			
			--SELECT *
			--FROM #docalign
			--WHERE matter_name like '%johnson, john%'

	--		SELECT *
	--		FROM #docAlign
	--		WHERE matter_num like '%757%' -- 1035_757

	--		SELECT *
	--		FROM #docAlign
	--		where matter_name like '%cherol%' 

	--		SELECT *
	--		FROM #docscan1
	--		where link like '%cherol%'
	--		--John Cherolikal/

	--		SELECT top 1000 *
	--		FROM s3docscan
	--		WHERE [filename] like '%bioventus%'
	--		--BioVentus Bills:Rec:Inv_RichardsonR.pdf -- slashes/colons

	--		SELECT *
	--		FROM pt1.projects p
	--		WHERe projectname like '%cherolika%'

	--		SELECT top 1000 *
	--		FROM s3docscan
	--		WHERE folderpath like '%cherolika%'

	--		SELECT top 1000 *
	--		FROM s3docscan
	--		WHERE [filename] like '%chk%31389%'
	--		--Chk 31389_Anesthesia Phy Billing_RichardsonR.pdf

	--		SELECT *
	--		FROM filevinestaging2import.._HoganT5_Documents___59004
	--		WHERE projectexternalid like '%827%' -- 238
	--		and __importstatus = 70


	--SELECt c.*
	--FROM [Firm Central Contacts_20221103] c 
	--WHERE lastname like '%chero%'

			-- UNALIGNED INSERT
		INSERT INTO
		-- delete from 
		--[PT1].[Documents] 
			filevinestaging2import.._HoganT5_Documents___60312
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
		SELECT DISTINCT --top 1000 
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, s.sourceS3ObjectKey [DocExternalID]
			, 10000 [ProjectExternalID]
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, s.sourceS3Bucket [SourceS3Bucket]
			, s.[SourceS3ObjectKey] [SourceS3ObjectKey]
			, s.[SourceS3ObjectKeyEncoded] [SourceS3ObjectKeyEncoded]
			, s.filecomplete [DestinationFileName]
			--, SUBSTRING(s.FolderPath,CHARINDEX('/',s.FolderPath)+1,LEN(s.FolderPath)) [DestinationFolderPath]
			, s.FolderPath [DestinationFolderPath]
			, [Filevine_META].dbo.udfDate_ConvertUTC(getdate(), 'pacific' , 1) [UploadDate]
			, NULL [Hashtags]
			, 'datamigrationteam280' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
	-- select count(1)
		FROM #docUnAlign a
		join  #docscan1 s -- 829
			on a.folder_path like '%' + s.folderpath + '%' -- 829 folderpaths and 66,111 docs


	END
														