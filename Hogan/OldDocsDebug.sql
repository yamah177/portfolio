USE [990000153_Hogan_T2]
GO
/****** Object:  StoredProcedure [firmcentral].[usp_insert_staging_Documents]    Script Date: 11/16/2022 9:20:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER DATABASE [990000153_Hogan_T2]
SET COMPATIBILITY_LEVEL = 130;  
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
		--WHERE [filename] like '%.%' -- 20692 with . in filename

		SELECT  distinct 
		        folderpath
			--, STRING_SPLIT(folderpath, '/') test
			, [Filevine_META_Test].[dbo].[udf_GetSplitString](folderpath, '/',1) level1
			, [Filevine_META_Test].[dbo].[udf_GetSplitString](folderpath, '/',2) level2
			, [Filevine_META_Test].[dbo].[udf_GetSplitString](folderpath, '/',3) level3
		FROM s3docscan
		--WHERE nullif(folderpath, '') is not null
		WHERE folderpath like '%johnson, john%'
		--WHERE folderpath not like '%/%'

		SELECT distinct folderpath
		FROM s3docscan
		WHERE folderpath like '%aster%'
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
		-- 361719 with where clause 204033
		--SELECT 361719 - 209142 -- temp. ~ filename

		--SELECT 209142 - 204033 -- 5109 special character filenames

		--SELECT SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1) link
		--, s.*
		--INTO #docscan2
		--FROM s3docscan  s
		--WHERE filename not like '~%'
		----and filename not like '%#%'
		----and filename not like '%&%'
		----and filename not like '%*%'
		----and filename not like '%{%'
		----and filename not like '%}%'
		----and filename not like '%\%'
		----and filename not like '%:%'
		----and filename not like '%<%'
		----and filename not like '%>%'
		----and filename not like '%?%'
		----and filename not like '%/%'
		----and filename not like '%+%'
		----and filename not like '%|%'
		----and filename not like '%"%'
		--and filename <> ''
		--AND filename <> 'debug'
		--and fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
		--and filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini') --343,519
		--; -- 209,142


	




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
		--order by Matter_Num
		

		-- 1. What to do with unaligneddocs
		-- Internal folders
--		0/
--0 - Updated Client Lists/
--00 - NEW CLIENT TEMPLATE/
--00 - New PI Client Packet/
--00 - Prospective Clients/
--00- Immigration -  Support Documentation Lists/
--00- Litigation/
--01 - Non Lit Cases/
--05-Non-Client/
--05-Non-Client/Lee, Diane/
--05-Non-Client/Olivas, Rose/
--06-Child Support Office/

-- project "Unaligned Docs"
-- load all unaligned docs into the folder.



		SELECT *
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]  
		WHERE Matter_num != 'Unaligned Docs' -- 651

		INSERT INTO
		-- SELECT * FROM  -- delete from
			--[PT1].[Documents]
			filevinestaging2import.._HoganT4_Documents___60130
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
	-- select distinct *
	-- SELECT count(1)
		FROM __FV_ClientCaseMap ccm
		JOIN pt1.projects p
			on ccm.projectexternalid = p.projectexternalid
			
		JOIN #docAlign a
			ON trim(ccm.caseid) = trim(a.matter_num_fix)
			
		join #docscan s
			on trim(a.folder_path) = trim(s.link) -- 249,818 -- with cleaned up files it's 140,497
			--OR  trim(a.folder_path) = concat('Wills/',trim(s.link))
			--WHERE Left(CONCAT_WS('_',ccm.ProjectExternalID,reverse(s.[SourceS3ObjectKey]),s.docid,s.s3objectbytes, s.filecomplete,s.fileext  ), 255) = '0333_361_0e1!1m5!0e4!74e1!1m21!25e1!1m21!5011e5!sus3!nes2!7m3!0e1!1m2!1b6!0e5!99999999224868.!62834.33d3!2m4!32497 XT ,kcobbuL ,0022 dR ytnuoCs2!71fc86b645dcba66x0_7dcfcd248cf6ef68x0s1!7m2!8m8!729290693i3!thgiltopss2!2e1!21m2!821i4!10362i3!22241i2!51i1!4m'
			--WHERE sources3objectkey like '%chero%'
			--WHERE ccm.projectexternalid like '%0967_0893%' -- -- cherolika
			--and s.filecomplete like '%%'
			--WHERE ccm.projectexternalid = '0947_0883'

			--WHERE Left(CONCAT_WS('_',ccm.ProjectExternalID,s.docid,reverse(s.[SourceS3ObjectKey]),s.s3objectbytes, s.filecomplete,s.fileext  ), 255) NOT IN (SELECT [DocExternalID]
				--			FROM  filevinestaging2import.._HoganT4_Documents___59004)
						
			order by 14

			SELECT *
			FROM #docAlign
			WHERE matter_num like '%757%' -- 1035_757
			--WHERE folder_path like '%aster%'
			--WHERE matter_name like '%aster%'


			SELECT *
			FROM #docAlign
			where matter_name like '%cherol%' 
--			John Cherolikal/
--Cherolikal, John/
			-- matter_name Cherolikal, John
			-- matter_num 967
			-- folderpath Wills/John Cherolikal/

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

-- aequum. hub city collections (not the other one)


SELECt *
fROM #docUnAlign
SELECT top 1000 *
FROM #docscan

--SELECT *
--FROM 	filevinestaging2import.._HoganT4_Documents___58214

--EXCEPT
--		SELECT distinct a.folder_path
--		FROM #docUnAlign a
--		join  #docscan s
--			on a.folder_path = s.folderpath -- 8,892

	--SELECT *
	--FROM pt1.projects
	--where projectname like '%unaligned%'




			--WHERE Left(CONCAT_WS('_',ccm.ProjectExternalID,s.fileext, reverse(s.[SourceS3ObjectKey])), 255) = '0333_361_86842299999999!5e0!6b1!2m1!1e0!3m7!2sen!3sus!5e1105!12m1!1e52!12m1!1e47!4e0!5m1!1e0_0e1!1m5!0e4!74e1!1m21!25e1!1m21!5011e5!sus3!nes2!7m3!0e1!1m2!1b6!0e5!99999999224868.!62834.33d3!2m4!32497 XT ,kcobbuL ,0022 dR ytnuoCs2!71fc86b645dcba66x0_7dcfcd2'



		--WHERE SUBSTRING(s.FolderPath,CHARINDEX('/',s.FolderPath)+1,LEN(s.FolderPath)) = '1187_1069_filevine-990000153/docs/Thomas, Penny Renae/DIscovery/Penny Thomas Discovery/0 - Baca et al - ALL DEFENDANTS/Jail Calls - All Defendants/BERMEA_Alberto/Bermea Jail Calls/10.36.144.21-8fb24d6d0a24901536d9e1c05c89eac9.mp3'
		-- need a dummy project to load the unaligned docs into.
		
		--SELECT *
		--FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign] a
		--join s3docscan s
		--	on a.folder_path = SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1)
		--	where matter_name = 'Unaligned Docs' -- 90248

		--SELECt top 1000 SUBSTRING(FolderPath,0,CHARINDEX('/',FolderPath))
		--, *--count(1)
		
		--FROM s3docscan -- 340,986
		--where FolderPath like '%ACJ Services, LLC_Phares, David:Cross, Audree/%'
		/*
		select count(1)
		FROM __FV_ClientCaseMap ccm
		JOIN #docAlign a
			ON ccm.caseid = a.matter_num_fix
		join #docscan s
			on trim(a.folder_path) like '%' + trim(s.link) + '%' -- 58,887 -- like join 85990
			OR ccm.caseid = a.matter_num -- 37167474

			SELECT *
			FROM #docAlign
			order by 1

			SELECT matter_num_fix
			FROM #docalign
			WHERE trim(matter_num_fix) not in (
			Select a.matter_num_fix
		FROM __FV_ClientCaseMap ccm
		JOIN #docAlign a
			ON trim(ccm.caseid) = trim(a.matter_num_fix))
/*
1217
1233
1231
1213
1235
1235
1219
1237
1237
1239
1215
1235
1219
1237
1239
*/

		Select a.matter_num_fix
		FROM __FV_ClientCaseMap ccm
		JOIN #docAlign a
			ON trim(ccm.caseid) = trim(a.matter_num_fix)
	WHERE a.matter_num_fix   IN (
	SELECT a.matter_num_fix
	FROM #docAlign)

		select count(1)
		FROM __FV_ClientCaseMap ccm -- 643
		JOIN [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign] a
			ON ccm.caseid = a.matter_num -- 109
		join s3docscan s
			on a.folder_path = SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1) -- 58,887
			--OR 
		--	ON ccm.caseid = a.matter_num -- 37167474


		SELECT trim(a.matter_num)
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign] a
		WHERE Matter_num != 'Unaligned Docs' -- 651
		AND trim(a.matter_num) IN (
									select ccm.CaseID
									FROM __FV_ClientCaseMap ccm -- 643
									JOIN [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign] a
										ON ccm.caseid = a.matter_num -- 109
									join #docscan s
										on trim(a.folder_path) like '%' + trim(s.link) + '%' -- 108
									--join s3docscan s
									--	on a.folder_path = SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1) -- 101
									)


									SELECT *
									FROM pt1.projects 
		
		select count(1)
		FROM __FV_ClientCaseMap ccm
		join pt1.projects p
			on ccm.projectexternalid = p.projectexternalid
		JOIN [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign] a
			ON ccm.caseid = a.matter_num
			OR '%' + a.matter_name + '%' like p.ProjectName
		join s3docscan s
			on 
			--a.folder_path = SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1) -- 58,887
			--OR 
			ccm.caseid = a.matter_num -- 37167474

		SELECT *
		FROM pt1.projects
		order by projectname

		SELECT CaseID
		FROM __FV_ClientCaseMap
		order by caseid

		



		SELECT *
		FROM pt1.projects
		--where projectname like '%biggs%'

		SELECt *
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign] 
		WHERE folder_path like '%biggs%'

		SELECT SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1)
		FROM s3docscan  s
		WHERE folderpath like '%biggs%'
		--Biggs, Gary/
		--Biggs, Gary/

		SELECT count(1)
		FROM s3docscan -- 340,986

		--WHERE projectexternalid = '0825_0801'
		*/
	END
														