USE [990000153_Hogan_R1]
GO
/****** Object:  StoredProcedure [firmcentral].[usp_insert_staging_Documents]    Script Date: 10/17/2022 11:06:49 AM ******/
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
		SELECT '[firmcentral].[usp_insert_staging_Documents] has been created in [990000153_Hogan_R1] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: ALL */
		/*================================================================================================*/

		drop table if exists #docscan2;


		SELECT --SUBSTRING(replace(s.FolderPath, 'Aequum/',''),0,CHARINDEX('/',s.FolderPath)+1) link
		 replace(s.FolderPath, 'Aequum/','') afolder
		, replace(s.FolderPath, 'Hub City (Debt Collections)/Debtors/','') bfolder
		, s.*
		INTO #docscan2
		FROM s3docscan  s
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
		AND folderpath like '%hub city%'
		OR folderpath like '%aequum%'
		OR folderpath like '%will%'

		SELECT distinct afolder, bfolder
		FROM #docscan2;

		DROP TABLE IF EXISTS #docscan3;

		SELECT 
		replace(SUBSTRING(s.afolder,0,CHARINDEX('/',s.afolder)+1), '/', '') link
		
		, s.*
		INTO #docscan3
		FROM #docscan2 s



		drop table if exists #docscan;

		SELECT SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1) link
		--, CASE 
		--	WHEN s.FolderPath like '%aequum%'
		--	THEN replace(s.FolderPath, 'Aequum/','') 
		--	WHEN s.FolderPath like '%hub city%'
		--	THEN replace(s.FolderPath, 'Hub City (Debt Collections)/Debtors/','') 
		--  END AS link2
		, s.*
		INTO #docscan
		FROM s3docscan  s
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
		AND folderpath not like '%aequum%'
		AND folderpath not like '%hub city%'
		AND folderpath not like '%will%'
		;
		-- 340,986 with where clause 199,672
		
	

		SELECt *
		FROM s3docscan -- wills folder
		WHERE folderpath like  '%wills%' --'%john cherolikal%'


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
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]  a
		WHERE Matter_num != 'Unaligned Docs' -- 651
		order by Matter_Num
		;

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

		-- docs 1

		INSERT INTO
		-- SELECT * FROM  -- delete from
			[PT1].[Documents]
			--filevinestaging2import.._HoganT3_Documents___58214
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
			OR trim(a.folder_path) =s.folderpath 
			--OR trim(a.folder_path) like '%' + s.folderpath + '%'
			--OR trim(a.folder_path) = trim(s.link2) 
		 -- join #docscan3 s2
			--on s2.link = a.matter_name
			--OR  trim(a.folder_path) = s2.bfolder
		 --WHERE  ccm.projectexternalid = '1101_757' -- jennifer blackburn
		 --WHERE  ccm.projectexternalid = '0923_757' -- Briggs, Rob -- 77
		 --WHERE  ccm.projectexternalid = '0781_757' -- ronnie gonzalez
		  --WHERE  ccm.projectexternalid = '1103_757'-- 1103_757	757	Hallman, Sherri
		  --WHERE  ccm.projectexternalid = '0773_757'-- 0773_757	757	Hogg, Suzanne - LCHD v.
		  --WHERE  ccm.projectexternalid = '1107_757'-- 1107_757	757	Hood, Christopher
		  --WHERE  ccm.projectexternalid = '0775_757'-- 0775_757	757	Jasnocha, Jamie
		  --WHERE  ccm.projectexternalid = '0777_757'-- 0777_757	757	Kimbley, Debra
		  --WHERE  ccm.projectexternalid = '0929_0883'-- 0929_0883 Gallardo, Addyson HUB CITY
		  --WHERE  ccm.projectexternalid = '1103_757'-- 
		  --WHERE  ccm.projectexternalid = '1103_757'-- 
		  --WHERE  ccm.projectexternalid = '1103_757'--
		  
-- docs 2
	INSERT INTO
		-- SELECT * FROM  -- delete from
			--[PT1].[Documents]
			filevinestaging2import.._HoganT3_Documents___58643
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
	-- SELECT distinct ccm.projectexternalid
	-- SELECT count(1)
		FROM __FV_ClientCaseMap ccm
		JOIN pt1.projects p
			on ccm.projectexternalid = p.projectexternalid
		JOIN #docAlign a
			ON trim(ccm.caseid) = trim(a.matter_num_fix)
		join #docscan3 s
			--on trim(a.folder_path) = trim(s.link) -- 249,818 -- with cleaned up files it's 140,497
			--OR trim(a.folder_path) =s.folderpath 
			 on s.link = a.matter_name
			 OR  replace(replace(a.folder_path, 'AEQUUM/',''), '/','') = TRIM(s.link)
			 OR  a.folder_path = TRIM(s.bfolder)
			 WHERE ccm.projectexternalid != '0757_0745'
			 AND (s.folderpath like '%AEQUUM%' -- 1704
			 OR s.folderpath like '%hub%city%' -- 1740
			 OR s.folderpath like '%wills%') -- 2127
			 --AND ccm.projectexternalid like '%_757%' -- 0767
--			 AND ccm.projectexternalid not IN (SELECt projectexternalid
--FROM pt1.projects
--WHERE contactexternalid like '%757%'
--)
			--ORDER BY ccm.projectexternalid
			
			SELECT *
			FROM s3docscan
			WHERE folderpath like '%AEQUUM%'

			SELECT *
			FROM #docscan3
			WHERE folderpath like '%hub%city%'

			SELECT *
			FROM s3docscan
			WHERE folderpath like '%wills%'

			SELECT *
			FROM #docAlign 
			WHERE matter_name like '%neville%'

			SELECT *
			FROM #docAlign a
			WHERE a.matter_name like '%stone%'
			AND a.folder_path = 'AEQUUM/Stone, Kendra (Lucas)/'

			SELECT *
			FROM #docAlign a
			join #docscan3 s
				on replace(replace(a.folder_path, 'AEQUUM/',''), '/','') = TRIM(s.link)
			WHERE a.matter_name like '%stone%'
			AND a.folder_path = 'AEQUUM/Stone, Kendra (Lucas)/'

		  SELECT *
		  FROM #docscan3
		  WHERE folderpath like '%stone%'








		 SELECT *
		 FROM #docscan3 s
		 join #docAlign a
		 on s.link = a.matter_name
		 WHERE folderpath like '%Briggs%'
		

		 SELECT *
		 FROM #docAlign
		 WHERE matter_name like '%Briggs%'
		 --AEQUUM/Blackburn, Jennifer/
		

		 SELECt *
		 FROM #docscan
		 WHERE folderpath like '%Briggs%'
		 --AEQUUM/Blackburn, Jennifer/

-- hub city
SELECt *
FROM pt1.projects
--WHERE projectexternalid = '0757_0745'
WHERE contactexternalid like '%0883%'
--WHERE incidentdescription like '%city%'
--WHERE projectname like '%city%'
order by projectname

-- aequum
SELECt *
FROM pt1.projects
WHERE contactexternalid like '%757%'
--WHERE incidentdescription like '%AEQUUM%'
--WHERE projectname like '%Kendra%'
order by projectname
0767_757 -- Stone, Kendra - LCHD v.
0769_757 -- Robertson, Meagan - LCHD v.
0771_757 -- Oaks, Cody - LCHD v.
0887_757 -- Myers, Katelyn
0765_757 -- Long, Charles - LCHD v.
0773_757 -- Hogg, Suzanne - LCHD v.

SELECt *
FROM #docscan3
WHERE folderpath like '%stone%'

0757_0745
0775_757
0777_757
0779_757
0787_757
0923_757
1101_757
1103_757
1107_757
1125_757
1197_757

SELECT *
FROM pt1.contactcustomcontactinfo
WHERE 

-- AEQUUM
BlackburnJennifer
Briggs, Rob
Gonzales, Ronnie
Hallman, Sherri
Hogg, Suzanne
Hood, Christopher
Janocha, Jamie
Kimbley, Debra
Kimbley, Hayden
Lindsey, Kimberly
Long, Charles
Myers, Katelyn 
Nichols, Christal 
Oaks, Cody 
Wilson, Jessica
Robrtson, Meagan 0769_757 
Stone, Kendra 0767_757 -- supposedly aequum

One Doc Missing - Johnson, John - ScrnSht
All Docs missing on all cases below WilsonJessica - ScnSht
CherolikalJohn - Trophy Girl TV - Lee, Demetrius v. - Aster Elements 
HealdDennis - Gallardo, Addyson - Holloway, Dillon - Icard, Ryan - Johnson, John - Neville, John - Joyner, Shaun - Neville, John - O''Malley, William - Quintana, Lindsey - Ready, Hollis - Swopes, Simon - Trash, John - Wintermute, Thomas - Ysasaga, Bea
BlackburnJennifer
Briggs, Rob
Gonzales, Ronnie
Hallman, Sherri
Hogg, Suzanne
Hood, Christopher
Janocha, Jamie
Kimbley, Debra
Kimbley, Hayden
Lindsey, Kimberly
Long, Charles
Myers, Katelyn - Nichols, Christal - Oaks, Cody - Robrtson, Meagan - Stone, Kendra










			-- UNALIGNED INSERT
		INSERT INTO
		-- delete from 
		[PT1].[Documents] 
		--	filevinestaging2import.._HoganT3_Documents___58214
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

SELECT top 1000 *
FROM #docscan

SELECT *
FROM 	filevinestaging2import.._HoganT3_Documents___58214











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
														