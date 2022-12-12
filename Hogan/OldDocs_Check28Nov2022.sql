
drop table if exists #docscan;

SELECT distinct CASE
	     WHEN folderpath like 'Wills/%'
		 THEN 'Wills/' + SUBSTRING(replace(s.FolderPath , 'Wills/', ''),0,CHARINDEX('/',replace(s.FolderPath , 'Wills/', ''))+1)
		 ELSE SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1) 
	   END AS link

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
		--AND folderpath like '%chero%'


		SELECt *
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]  
		WHERE  matter_name like '%chero%'
		--subfolders

		
		select *
		from s3docscan -- 361719
		WHERE folderpath like '%cherol%'
		
		

		SELECT CASE
	     WHEN folderpath like 'Wills/%'
		 THEN SUBSTRING(replace(s.FolderPath , 'Wills/', ''),0,CHARINDEX('/',replace(s.FolderPath , 'Wills/', ''))+1)
		 ELSE SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1) 
	   END AS link
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
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]  a
		WHERE Matter_num != 'Unaligned Docs' -- 651
		--AND matter_name like '%chero%'
		order by Matter_Num
	
		SELECT *
		FROM #docAlign
		

		DROP TABLE IF EXISTS #docUnAlign;

		SELECt *
		  INTO #docUnAlign
	-- SELECT *
		FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_DocAlign]  
		WHERE Matter_num = 'Unaligned Docs' -- 651

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
			OR  trim(a.matter_name) = trim(s.link)
			--WHERE Left(CONCAT_WS('_',ccm.ProjectExternalID,reverse(s.[SourceS3ObjectKey]),s.docid,s.s3objectbytes, s.filecomplete,s.fileext  ), 255) = '0333_361_0e1!1m5!0e4!74e1!1m21!25e1!1m21!5011e5!sus3!nes2!7m3!0e1!1m2!1b6!0e5!99999999224868.!62834.33d3!2m4!32497 XT ,kcobbuL ,0022 dR ytnuoCs2!71fc86b645dcba66x0_7dcfcd248cf6ef68x0s1!7m2!8m8!729290693i3!thgiltopss2!2e1!21m2!821i4!10362i3!22241i2!51i1!4m'
			--WHERE sources3objectkey like '%chero%'
			--WHERE ccm.projectexternalid like '%0967_0893%' -- -- cherolika
			--and s.filecomplete like '%%'
			order by 14

			SELECt     LEFT(link, CHARINDEX('-', link, CHARINDEX('-', link) + 1) -1) STRIPPED_STRING 
			, link

			FROM #docscan

			SELECT *
			FROM #docAlign



--Cherolikal, John/
--John Cherolikal/
