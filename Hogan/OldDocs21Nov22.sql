USE [990000153_Hogan_T2]
GO
/****** Object:  StoredProcedure [firmcentral].[usp_insert_staging_Documents]    Script Date: 11/21/2022 11:57:31 AM ******/
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
		
		--select *
		--from s3docscan -- 361719
--DROP TABLE IF EXISTS docs;

--CREATE TABLE docs (
--levelOne varchar(max)
--, levelTwo varchar(max)
--, levelThree varchar(max)
--, sources3objectkey varchar(max)
--, sources3objectkeyEncoded varchar(max)
--, folderpath varchar(max)
--, [filename] varchar(max)
--, fileext varchar(max)
--, filecomplete varchar(max)
--);

--INSERT INTO Docs
--( 
--levelOne
--,levelTwo
--,levelThree
--,sources3objectkey
--, sources3objectkeyEncoded
--, folderpath
--, [filename] 
--, fileext
--, filecomplete
--)

--SELECT  distinct  [Filevine_META_Test].[dbo].[udf_GetSplitString](folderpath, '/',1) 
--				, [Filevine_META_Test].[dbo].[udf_GetSplitString](folderpath, '/',2) 
--				, [Filevine_META_Test].[dbo].[udf_GetSplitString](folderpath, '/',3) 
--						, sources3objectkey
--						, sources3objectkeyEncoded
--						, folderpath
--						, [filename] 
--						, fileext
--						, filecomplete
--			--SELECT top 1000 *
--		--INTO docs
--		FROM s3docscan
--		WHERE filename not like '~%'
--		and filename <> ''
--		AND filename <> 'debug'
--		and fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
--		and filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini') --343,519
		;

		--SELECT *
		--FROM #docs
		--WHERE folderpath like '%johnson, john%'

		--SELECT distinct folderpath
		--FROM s3docscan
		--WHERE folderpath like '%aster%'
		--1035_757



		-- need to figure him out in hub city
		
		--select *
		--from s3docscan -- 361719
		--WHERE folderpath like '%cherol%'
		
		SELECT *
		FROM #docscan
		WHERE filename like 'POA%Invoice_6-2020.pdf'
		-- POA Invoice_6-2020.pdf WHAT IS FILTERING THIS OUT

		drop table if exists #docscan;

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
		INTO #docscan
		FROM s3docscan  s
		WHERE filename not like '~%'
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
	FROM #docscan s
--WHERE secondlevel like '%,%'

		
		SELECT *
		FROM #docscan
		WHERE folderpath like '%aequ%'

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
	
		SELECt *
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]
		--where matter_name like '%aster%'
		WHERE matter_num = '1035'
		

		DROP TABLE IF EXISTS #docUnAlign;

		SELECt *
		  INTO #docUnAlign
	-- SELECT *
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]  
		WHERE Matter_num = 'Unaligned Docs' -- 651



		SELECT *
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]  
		WHERE Matter_num != 'Unaligned Docs' -- 651

		INSERT INTO
		-- SELECT * FROM  -- delete from
			[PT1].[Documents]
			--filevinestaging2import.._HoganT4_Documents___60130
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
			
		join #docs /*#docscan*/ s
			on trim(a.folder_path) = trim(s.link) -- 249,818 -- with cleaned up files it's 140,497
			OR trim(a.folder_path) like '%'+ trim(s.firstlevel) + '%'
			OR trim(a.folder_path) like '%'+ trim(s.secondlevel) + '%'
			OR trim(a.folder_path) like '%'+ trim(s.secondlevel) + '%'
			OR trim(a.folder_path) like '%'+ replace(trim(s.thirdlevelON), '/','') + '%'
			--OR  trim(a.folder_path) = concat('Wills/',trim(s.link))
			--WHERE Left(CONCAT_WS('_',ccm.ProjectExternalID,reverse(s.[SourceS3ObjectKey]),s.docid,s.s3objectbytes, s.filecomplete,s.fileext  ), 255) = '0333_361_0e1!1m5!0e4!74e1!1m21!25e1!1m21!5011e5!sus3!nes2!7m3!0e1!1m2!1b6!0e5!99999999224868.!62834.33d3!2m4!32497 XT ,kcobbuL ,0022 dR ytnuoCs2!71fc86b645dcba66x0_7dcfcd248cf6ef68x0s1!7m2!8m8!729290693i3!thgiltopss2!2e1!21m2!821i4!10362i3!22241i2!51i1!4m'
			--WHERE sources3objectkey like '%chero%'
			--WHERE ccm.projectexternalid like '%0967_0893%' -- -- cherolika
			--and s.filecomplete like '%%'
			--WHERE ccm.projectexternalid = '0947_0883' -- john johnson
			--AND 		folderpath like '%johnson, john%'
			--AND 		folderpath like '%cherolika%'
			--WHERE Left(CONCAT_WS('_',ccm.ProjectExternalID,s.docid,reverse(s.[SourceS3ObjectKey]),s.s3objectbytes, s.filecomplete,s.fileext  ), 255) NOT IN (SELECT [DocExternalID]
			--				FROM  filevinestaging2import.._HoganT4_Documents___59004)
			--AND Left(CONCAT_WS('_',ccm.ProjectExternalID,s.docid,reverse(s.[SourceS3ObjectKey]),s.s3objectbytes, s.filecomplete,s.fileext  ), 255) 
			--NOT IN (SELECT [DocExternalID]
			--		FROM filevinestaging2import.._HoganT4_Documents___60130
			--		)
						
			order by 14

			--SELECt *
			--FROM pt1.projects
			--WHERE projectname like '%johnson%'

			--SELECt *
			--FROM #docs
			--	WHERE folderpath like '%johnson, john%'
			
			--SELECT *
			--FROM #docalign
			--WHERE matter_name like '%johnson, john%'

			SELECT *
			FROM #docAlign
			WHERE matter_num like '%757%' -- 1035_757

			SELECT *
			FROM #docAlign
			where matter_name like '%cherol%' 

			SELECT *
			FROM #docscan
			where link like '%cherol%'
			--John Cherolikal/

			SELECT top 1000 *
			FROM s3docscan
			WHERE [filename] like '%bioventus%'
			--BioVentus Bills:Rec:Inv_RichardsonR.pdf -- slashes/colons

			SELECT *
			FROM pt1.projects p
			WHERe projectname like '%cherolika%'

			SELECT top 1000 *
			FROM s3docscan
			WHERE folderpath like '%cherolika%'

			SELECT top 1000 *
			FROM s3docscan
			WHERE [filename] like '%chk%31389%'
			--Chk 31389_Anesthesia Phy Billing_RichardsonR.pdf

			SELECT *
			FROM filevinestaging2import.._HoganT4_Documents___59004
			WHERE projectexternalid like '%827%' -- 238
			and __importstatus = 70


	SELECt c.*
	FROM [Firm Central Contacts_20221103] c 
	WHERE lastname like '%chero%'

			-- UNALIGNED INSERT
		INSERT INTO
		-- delete from 
		[PT1].[Documents] 
		--	filevinestaging2import.._HoganT4_Documents___58214
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
			--, s.*
	-- select distinct ccm.projectexternalid --* --count(1)
	--  SELECT distinct s.docid 
		FROM #docUnAlign a
		join  #docscan s -- 829
			on a.folder_path like '%' + s.folderpath + '%' -- 829 folderpaths and 59,276 docs
			--WHERE a.folder_path  = 'Salazar, Salvador Jr/'
--		SELECT distinct a.folder_path
--		FROM #docUnAlign a

	END
														