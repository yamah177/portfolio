USE [6985_Bobbygarcia]
GO
/****** Object:  StoredProcedure [documents].[usp_insert_staging_Documents]    Script Date: 7/29/2021 2:50:44 PM ******/
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
	BEGIN --	SELECT 			'[documents].[usp_insert_staging_Documents] has been created in [6985_Bobbygarcia] database.  Please review and modifiy the procedure.'

		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _Tes_ */
		/*================================================================================================*/
	------------------------------------------------ Getting the # out of the hashtag - it's not in the folderpath -----------------------------------------------------------------------	
	IF OBJECT_ID('TEMPDB.dbo.#CleanAlign', 'U') IS NOT NULL
	DROP TABLE #CleanAlign;

	SELECT 
		 Org_Name
		, [Name]
		, Full_Name
		, Phase
		, Project_Type
		, replace(Hashtags, '#', '') Hashtag
		INTO #CleanAlign
-- select *
		FROM [PT1_CLIENT_ALIGN].[Project_Doc_Alignment]

--		SELECT top 1000 * FROM #CleanAlign
----------------------------------- taking out invalid extraneous hashtag data ---------------------------------------------------------------------------------------------
	IF OBJECT_ID('TEMPDB.dbo.#Cleaneralign', 'U') IS NOT NULL
	DROP TABLE #Cleaneralign;
			
			SELECT distinct 
			--DocID
			 Org_Name
			, [Name]
			, Full_Name
			, Phase
			, Project_Type
			, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(replace(REPLACE(REPLACE(REPLACE(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(REPLACE(replace(REPLACE(REPLACE(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(hashtag, ', RAE', ''), ', TVM', ''), ', CG, HM', ''), ', HM', ''), ', GC', ''), ', CG, XARELTO', ''), ', ReferredOut', ''), ', JG', ''), ', BR, XARELTO', ''), 'HEAT', ''), ', Pending-MED-LIEN', ''), ', MT-BOX-91',''), ', Collections', ''), ', Essure', ''), ', CG', ''), ', nbspCG', ''), ', RU', ''), ', DECEASED', ''), ', UIM', ''), ', 3M', ''), ', LOSARTAN', ''), ', 1ST-ACCIDENT', ''), ',',''), ' 2ND-ACCIDENT', ''), ' POSTOFFICE', ''), ' TALC', ''), '3M ', ''), 'Asbestos ', ''), 'Attny-REF Business-Interruption', ''), 'Attny-Ref-TC Business-Interruption', ''), 'Attorney-REF-ALDOUS-STRAUCH NQ-VALSARTAN', ''), 'Attorney-Referral Pending-3M', ''), 'Benicar ', '')
			, 'Attny-REF-Carey-Danis-amp-Lowe ', ''), ' REF-ATTNY-EXPENSES-OWED', ''), 'Attny-ref-HERMAN-amp-HERMANN ', ''), 'Attny-REF-Katie-Klein ', ''), 'Attny-REF-Terry-Canales ', '')
			, 'Attorney-REF ', ''), '-GLO', ''), ' XARELTO', ''), ' T-GEL', ''), ' REVATIO', ''), ' BR', ''), ' NTC', ''), ' PRADAXA', ''), ' VIAGRA', ''), ' KNEE' ,''), ' KNEE-REPLACEMENT', '')
			, ' RISPERDAL', ''), ' UNSURE-HOW-CASE-WAS-REF', ''), ' YA', ''), ' BOX-29', ''), '-REPLACEMENT', ''), ' XARLETO', ''), ' TGEL', ''), ' MISSING-SIGNED-SETTLEMENT-MEMO', ''), ' IVC', '')
			, ' BONE-GRAFT', ''), ' NEXIUM', ''), 'COMMERCIAL', ''), ' BOX-91', ''), 'JOHN-FILE', ''), ' INVOKANA', ''), 'nbsp' ,''), ' HIPIMPLANT', ''), ' HIPnbsp', ''), ' gloria-cruz', '')
			, ' REF-ATTNY', ''), ' NEEDS-REVISION', ''), ' CYNDI', ''), ' ROUND-UP', ''), ' VALSARTAN', ''), ' HIP', ''), ' DD', '')
			CleanHashtag
			, replace(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(replace(REPLACE(REPLACE(REPLACE(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(REPLACE(replace(REPLACE(REPLACE(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(hashtag, ', RAE', ''), ', TVM', ''), ', CG, HM', ''), ', HM', ''), ', GC', ''), ', CG, XARELTO', ''), ', ReferredOut', ''), ', JG', ''), ', BR, XARELTO', ''), 'HEAT', ''), ', Pending-MED-LIEN', ''), ', MT-BOX-91',''), ', Collections', ''), ', Essure', ''), ', CG', ''), ', nbspCG', ''), ', RU', ''), ', DECEASED', ''), ', UIM', ''), ', 3M', ''), ', LOSARTAN', ''), ', 1ST-ACCIDENT', ''), ',',''), ' 2ND-ACCIDENT', ''), ' POSTOFFICE', ''), ' TALC', ''), '3M ', ''), 'Asbestos ', ''), 'Attny-REF Business-Interruption', ''), 'Attny-Ref-TC Business-Interruption', ''), 'Attorney-REF-ALDOUS-STRAUCH NQ-VALSARTAN', ''), 'Attorney-Referral Pending-3M', ''), 'Benicar ', '')
			, 'Attny-REF-Carey-Danis-amp-Lowe ', ''), ' REF-ATTNY-EXPENSES-OWED', ''), 'Attny-ref-HERMAN-amp-HERMANN ', ''), 'Attny-REF-Katie-Klein ', ''), 'Attny-REF-Terry-Canales ', '')
			, 'Attorney-REF ', ''), '-GLO', ''), ' XARELTO', ''), ' T-GEL', ''), ' REVATIO', ''), ' BR', ''), ' NTC', ''), ' PRADAXA', ''), ' VIAGRA', ''), ' KNEE' ,''), ' KNEE-REPLACEMENT', '')
			, ' RISPERDAL', ''), ' UNSURE-HOW-CASE-WAS-REF', ''), ' YA', ''), ' BOX-29', ''), '-REPLACEMENT', ''), ' XARLETO', ''), ' TGEL', ''), ' MISSING-SIGNED-SETTLEMENT-MEMO', ''), ' IVC', '')
			, ' BONE-GRAFT', ''), ' NEXIUM', ''), 'COMMERCIAL', ''), ' BOX-91', ''), 'JOHN-FILE', ''), ' INVOKANA', ''), 'nbsp' ,''), ' HIPIMPLANT', ''), ' HIPnbsp', ''), ' gloria-cruz', '')
			, ' REF-ATTNY', ''), ' NEEDS-REVISION', ''), ' CYNDI', ''), ' ROUND-UP', ''), ' VALSARTAN', ''), ' HIP', ''), ' DD', ''), 'BG-', '') noBGHashtag
		--	, hashtag original
		INTO #CleanerAlign
			from #CleanAlign 
			where hashtag is not null -- 2113'
			and  hashtag not in ('BIA-ALCL-BREAST-CANCER, CG','BOX-71, HM','BUSINESS-INTERRUPTION, CG','Business-Interruption, GC, MT-BOX-94, Ref-by-BR','CG','CG, HM','CG, IVC','CG, RU','CG, taxotere',
			'CG, Zantac','COMMERCIAL','commercial, driver, heat','COMMERCIAL, JG','covid-pending','COW','DEMANDDONE, JG, JJG','ESSURE','FATALITY','FN, TALC','FRACTURE','GC, HM','GC, PENCIL-FILE, RU',
			'GC, PENCIL-FILE, TVM','GC, PENDING-HM','GC, Pending-HM, Prev-caller-0317-YA','GC, pending-paraquat','GC, Pending-Talc','HEAT','HEAT, JG','HM','HM, NT','HM, RU','HM, TVM','hm-pend-rev',
			'HMnbsp','IVC','JG','JJG','LOSARTAN, RU, TALC','med-neg, TALC','METFORMIN','MIRENA','nbsp19-675b','nbsp19-991-b','NOMRI','NQ, PENDING-HM','NQ-3M','NQ-3Mnbsp','NQ-BREAST-IMP','NQ-CANCER',
			'NQ-HM','NQ-HMnbsp','NQ-HMnbsp, Pending-Talc, REF-BRGC','NQ-Losartan','NQ-RU','NQ-TALC','NQ-Talc, NQ-Taxotere','NQ-TVM','NQ-TVMnbsp','NQ-XELJANZ','NQ-Zantac','NTC-GC-file, PENDING-RU',
			'PARAQUAT','pend-business-int','Pend-Talc','pending','pending, ru','pending, TVM','PENDING-3M','Pending-HM','pending-RU','Pending-Talc','Pending-Talc-case','Pending-TVM','Pending-Zantac',
			'PRADAXA','PREG','PREGNANT','RAE','REFUSEDORTHO','Rocass','ROLLOVER','Rose','ROUND-UP','Roundup','RTKNEE','RU','slipandfall, WALMART','SUTURES','TALC','taxotere','TVM','ULORIC','UNINS',
			'WALMART','Winter-Storm','xarelto','XARLETO','Zantac','ATTNY-REF-JUAN-E-GARCIA-RGC','3M-Ear-plugs','2ND-ACCIDENT', '3M'
			)

		-- SELECT Top 1000 * FROM #Cleaneralign
	----------------------------------- taking out invalid file extensions, names, and small folderpath fixes ---------------------------------------------------------------------------------------------
	IF OBJECT_ID('TEMPDB.dbo.#CleanDocScan', 'U') IS NOT NULL
	DROP TABLE #CleanDocScan;

	--INSERT 
	SELECT  
		DocID
		, s.sourceS3Bucket 
		, s.sourceS3ObjectKey 
		, s.sourceS3ObjectKeyEncoded
		, s.folderpath original_folderpath
		, replace(replace(replace(replace(s.folderpath, 'Masstort/#recycle', ''), 'Cyndi Computer Backup/Dropbox/', ''), '/- DOCUMENTS/- Forms', ''), '/- DOCUMENTS/', '')  folderpath
		, s.[FileName]
		, s.FileExt
		, s.FileComplete
	-- SELECT COUNT(*)
	INTO #CleanDocScan
	-- select count(*)
		FROM s3docscan s
		WHERE fileext NOT IN ('tmp', 'dl_', 'da_', 'ex_', 'ch_', 'mt_', 'ca_', 'ch_')
			and filecomplete  not IN ('.dropbox', 'desktop.ini', 'Desktop.lnk', 'Downloads.lnk',  '.bzEmpty', 'Thumbs.db')
			and filename not like '%~%'

	-- SELECT top 1000 * from #CleanDocScan
		----------------------------------- fixing the destination folderpath ---------------------------------------------------------------------------------------------
	SET STATISTICS IO ON;
		
	IF OBJECT_ID('TEMPDB.dbo.#CleanerDocScan', 'U') IS NOT NULL
	DROP TABLE #CleanerDocScan;

SELECT distinct
		  CASE 
			WHEN p.cleanhashtag like 'BG%' 
			THEN 		REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.cleanhashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'') -- going to give everything to the right of the cleanhashtag. nullif, if this field doesn't contain this, 
			WHEN p.cleanhashtag not like 'BG%' 
			THEN 		REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.nobghashtag,S.folderpath)-1,1),1),8000),p.nobghashtag,'')
			ELSE 		REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.nobghashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'') -- nobghashtag vs cleanhashtag
		end	 cleanerFolderPath
		, S.folderpath original
		, s.filecomplete
		--,p.[name]
		, p.cleanhashtag
		, p.nobghashtag
	--	INTO #CleanerDocScan
-- select TOP 10000 *
		from #CleanDocScan s
		INNER JOIN tmp_jcobb_1 p
			ON s.folderpath like '%' + p.nobghashtag + '%' -- 75,365
			AND FOLDERPATH LIKE '%[0-9][0-9]-[0-9][0-9][0-9]%' 
			OR s.filecomplete like '%' + p.nobghashtag +'%' -- 76,526
		WHERE p.cleanhashtag <> '' -- 76821
		
			
			--s.folderpath like '%' + p.cleanHashtag +'%' or -- 74,817 
			--OR s.filecomplete like '%' + p.nobghashtag + '%' -- 77051
			
	select DISTINCT FOLDERPATH
		from #CleanDocScan s
		WHERE FOLDERPATH LIKE '%[0-9][0-9]-[0-9][0-9][0-9]%' 
		ORDER BY 1

--- MASS TORT CONTRACTS
--- MT CONTRACTS
--/KRISSY BACKUP/
--/TVM/
--MassTort/TVM/
--MassTort/HERNIA MESH CASES/NON ENGAGED files/
--MassTort/TVM/001-AMS-TVM Release Signed
--\MassTort/CASES WE ARE NO LONGER SIGNING/
--MassTort/TVM/NON ENGAGE/
--prelit/BEULAH'S CASES/JOHN CASES-BR/SETTLED/
--prelit/DAVID'S CASES/Former Employee Files/LEO CASES/CLOSED FILES 2015/
--prelit/Former Employee Files/ANNA CASES/
--prelit/Former Employee Files/LEO CASES/SETTLED FILES 2018/



	-- takes roughly 

	--		SELECt * FROM tmp_jcobb_1
			----------------------------------- fixing the destination folderpath even more ---------------------------------------------------------------------------------------------


	IF OBJECT_ID('TEMPDB.dbo.#CleanestDocScan', 'U') IS NOT NULL
	DROP TABLE #CleanestDocScan;

			SELECT
			original
			, cleanerFolderPath
			, CASE
				WHEN cleanerFolderPath NOT LIKE '%/%'
				THEN NULL
				ELSE SUBSTRING(cleanerFolderPath,CHARINDEX('/',cleanerFolderPath),LEN(cleanerFolderPath)) 
			  END AS CleanDestinationFolderPath
			  INTO #CleanestDocScan
			FROM #CleanerDocScan

		-- SELECT top 1000 * FROM #CleanestDocScan

		--CONTRACT & MA -> CONTRACTS
		--DEPO - DEPOSITIONS
		--X AMOUNT OF ROWS FOR PATHS TO MAIN PROJECT FOLDERS.



 -- insert
 	INSERT INTO
		-- select * from 
			[PT1].[Documents]
			filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550063711
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
			, left(concat_ws('_', 'DOC', s.DocID, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag) 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag)
			  END, 64)), 255) [DocExternalID]
			--, CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) [ProjectExternalID]
			, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag) 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag)
			  END, 64) AS  ProjectExternalID
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, left(s.sourceS3Bucket, 255) [SourceS3Bucket]
			, left(s.sourceS3ObjectKey, 512) [SourceS3ObjectKey]
			, left(s.sourceS3ObjectKeyEncoded, 512) [SourceS3ObjectKeyEncoded]
			, s.FileComplete [DestinationFileName]
			, s2.CleanDestinationFolderPath  AS	 [DestinationFolderPath]
			, Filevine_META.dbo.udfDate_ConvertUTC(getdate(), 'central' , 1) [UploadDate]
			, CASE 
				WHEN p.CleanHashtag IS NULL 
				THEN p.nobghashtag
				ELSE p.cleanhashtag
			  END AS [Hashtags]
			, 'datamigrationteam1' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
	-- SELECT distinct TOP 1000 * 
	-- SELECT Count(*)
		FROM #CleanDocScan s -- 219187
		INNER JOIN #CleanestDocScan s2
			ON s.original_folderpath = s2.original
		INNER JOIN #CleanerAlign p
			ON s.folderpath like '%' + p.cleanHashtag +'%' -- 74,817
			OR s.folderpath like '%' + p.nobghashtag -- 75,365
			OR s.filecomplete like '%' + p.cleanHashtag + '%' -- 77051
			--OR s.filecomplete like '%' + p.nobghashtag -- 76,526
			where p.cleanhashtag <> '' -- 76821
		--	and left(concat_ws('_', 'DOC', s.DocID), 255) = 'DOC_S3DOC_100771'































--	WITH cte AS (
--SELECT distinct top 1000 replace(S.folderpath, '%' + p.cleanhashtag+ '%' + '/', '') as folderpath
--		, CASE 
--			WHEN p.cleanhashtag like 'BG%' 
--			THEN 		REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.cleanhashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'') -- going to give everything to the right of the cleanhashtag. nullif, if this field doesn't contain this, 
--			ELSE 		REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.nobghashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'')
--		end	 jcobb_Path
--		, S.folderpath original
--		, s.filecomplete
--		--,p.[name]
--		, p.cleanhashtag
--		, p.nobghashtag
--		from #CleanDocScan s
--		INNER JOIN tmp_jcobb_1 p
--			ON s.folderpath like '%' + p.cleanHashtag +'%' -- 74,817
--			OR s.folderpath like '%' + p.nobghashtag -- 75,365
--			OR s.filecomplete like '%' + p.cleanHashtag + '%' -- 77051
--			--OR s.filecomplete like '%' + p.nobghashtag -- 76,526
--			where p.cleanhashtag <> '' -- 76821
--			)
--			SELECT
--			original
--			, jcobb_Path
--			, CASE
--				WHEN jcobb_Path NOT LIKE '%/%'
--				THEN NULL
--				ELSE SUBSTRING(jcobb_Path,CHARINDEX('/',jcobb_Path),LEN(jcobb_Path)) 
--			  END AS CleanPath
--			FROM cte
			
-------------------------------------------------------------------------------------------------------------------------------- first
	/*
	
	INSERT INTO
		-- select * from 
			--[PT1].[Documents]
		-- DELETE FROM
			--filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550063711
			filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064074
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
		SELECT DISTINCT -- top 1000
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, left(concat_ws('_', 'DOC', s.DocID, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag, '1') 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag )
			  END, 64)), 255) [DocExternalID]
			--, CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) [ProjectExternalID]
			, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag) 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag)
			  END, 64) AS  ProjectExternalID
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, left(s.sourceS3Bucket, 255) [SourceS3Bucket]
			, left(s.sourceS3ObjectKey, 512) [SourceS3ObjectKey]
			, left(s.sourceS3ObjectKeyEncoded, 512) [SourceS3ObjectKeyEncoded]
			, s.FileComplete [DestinationFileName]
			, s2.CleanDestinationFolderPath [DestinationFolderPath]
		--	, s2.cleanerFolderPath
		--	, s.original_folderpath
			, Filevine_META.dbo.udfDate_ConvertUTC(getdate(), 'central' , 1) [UploadDate]
			, CASE 
				WHEN p.CleanHashtag IS NULL 
				THEN p.nobghashtag
				ELSE p.cleanhashtag
			  END AS [Hashtags]
			, 'datamigrationteam1' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, 1 [isReload]
	-- SELECT distinct TOP 1000 * 
	-- SELECT Count(*)
		FROM #CleanDocScan s -- 219187
		INNER JOIN #CleanestDocScan s2
			ON s.original_folderpath = s2.original
		INNER JOIN #CleanerAlign p
			ON s.folderpath like '%' + p.cleanHashtag +'%' -- 74,817
			
		--	OR 
			--OR s.filecomplete like '%' + p.nobghashtag -- 76,526
			where p.cleanhashtag <> '' -- 76821


	-- 2nd insert
		INSERT INTO
		-- select * from 
			--[PT1].[Documents]
		-- DELETE FROM
			--filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550063711
			filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064074
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
		SELECT DISTINCT -- top 1000
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, left(concat_ws('_', 'DOC', s.DocID, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag, '1') 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag )
			  END, 64)), 255) [DocExternalID]
			--, CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) [ProjectExternalID]
			, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag) 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag)
			  END, 64) AS  ProjectExternalID
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, left(s.sourceS3Bucket, 255) [SourceS3Bucket]
			, left(s.sourceS3ObjectKey, 512) [SourceS3ObjectKey]
			, left(s.sourceS3ObjectKeyEncoded, 512) [SourceS3ObjectKeyEncoded]
			, s.FileComplete [DestinationFileName]
			, s2.CleanDestinationFolderPath [DestinationFolderPath]
		--	, s2.cleanerFolderPath
		--	, s.original_folderpath
			, Filevine_META.dbo.udfDate_ConvertUTC(getdate(), 'central' , 1) [UploadDate]
			, CASE 
				WHEN p.CleanHashtag IS NULL 
				THEN p.nobghashtag
				ELSE p.cleanhashtag
			  END AS [Hashtags]
			, 'datamigrationteam1' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, 1 [isReload]
	-- SELECT distinct TOP 1000 * 
	-- SELECT Count(*)
		FROM #CleanDocScan s -- 219187
		INNER JOIN #CleanestDocScan s2
			ON s.original_folderpath = s2.original
		INNER JOIN #CleanerAlign p
			ON s.folderpath like '%' + p.nobghashtag -- 75,365
		where p.cleanhashtag <> '' -- 76821
		and left(concat_ws('_', 'DOC', s.DocID, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag, '1') 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag )
			  END, 64)), 255) not in (SELECT	[DocExternalID]
									FROM filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064074
									)



		-- 3rd
			INSERT INTO
		-- select * from 
			--[PT1].[Documents]
		-- DELETE FROM
			--filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550063711
			filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064074
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
		SELECT DISTINCT -- top 1000
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, left(concat_ws('_', 'DOC', s.DocID, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag, '1') 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag )
			  END, 64)), 255) [DocExternalID]
			--, CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) [ProjectExternalID]
			, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag) 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag)
			  END, 64) AS  ProjectExternalID
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, left(s.sourceS3Bucket, 255) [SourceS3Bucket]
			, left(s.sourceS3ObjectKey, 512) [SourceS3ObjectKey]
			, left(s.sourceS3ObjectKeyEncoded, 512) [SourceS3ObjectKeyEncoded]
			, s.FileComplete [DestinationFileName]
			, s2.CleanDestinationFolderPath [DestinationFolderPath]
		--	, s2.cleanerFolderPath
		--	, s.original_folderpath
			, Filevine_META.dbo.udfDate_ConvertUTC(getdate(), 'central' , 1) [UploadDate]
			, CASE 
				WHEN p.CleanHashtag IS NULL 
				THEN p.nobghashtag
				ELSE p.cleanhashtag
			  END AS [Hashtags]
			, 'datamigrationteam1' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, 1 [isReload]
	-- SELECT distinct TOP 1000 * 
	-- SELECT Count(*)
		FROM #CleanDocScan s -- 219187
		INNER JOIN #CleanestDocScan s2
			ON s.original_folderpath = s2.original
		INNER JOIN #CleanerAlign p
			ON s.filecomplete like '%' + p.cleanHashtag + '%' -- 77051
						where p.cleanhashtag <> '' -- 76821
			and left(concat_ws('_', 'DOC', s.DocID, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag, '1') 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag )
			  END, 64)), 255) not in (SELECT	[DocExternalID]
									FROM filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064074
									)




-- OLD INSERT BELOW ------
		INSERT INTO
		-- select * from 
			--[PT1].[Documents]
			filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550063711
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
			, left(concat_ws('_', 'DOC', s.DocID, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag) 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag)
			  END, 64)), 255) [DocExternalID]
			--, CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) [ProjectExternalID]
			, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag) 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag)
			  END, 64) AS  ProjectExternalID
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, left(s.sourceS3Bucket, 255) [SourceS3Bucket]
			, left(s.sourceS3ObjectKey, 512) [SourceS3ObjectKey]
			, left(s.sourceS3ObjectKeyEncoded, 512) [SourceS3ObjectKeyEncoded]
			, s.FileComplete [DestinationFileName]
			, left(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
		  CASE 
			WHEN p.cleanhashtag like 'BG%' 
			THEN REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.cleanhashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'')
			ELSE REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.nobghashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'')
		   END
		   , '-7', ''), '-8', ''), '-5', ''), '-3', ''), '-4', ''), 'GC', ''), '-P&C', ''),  '/01 MASTER FILE', ''), '() ES/', ''), '-)', ''), '-', ''), '()', ''), '9', ''), '4', ''), '4/',''), '9/',''), '5', ''), '2',''), '7', ''), 'RS/',''), 'AB/', ''), 'EVS/',''),'1/','') ),512)  AS	 [DestinationFolderPath]
			, Filevine_META.dbo.udfDate_ConvertUTC(getdate(), 'central' , 1) [UploadDate]
			, CASE 
				WHEN p.CleanHashtag IS NULL 
				THEN p.nobghashtag
				ELSE p.cleanhashtag
			  END AS [Hashtags]
			, 'datamigrationteam1' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload]
	-- SELECT distinct TOP 1000 * 
	-- SELECT Count(*)
		FROM #CleanDocScan s -- 219187
		INNER JOIN #CleanerAlign p
			ON s.folderpath like '%' + p.cleanHashtag +'%' -- 74,817
			OR s.folderpath like '%' + p.nobghashtag -- 75,365
			OR s.filecomplete like '%' + p.cleanHashtag + '%' -- 77051
			--OR s.filecomplete like '%' + p.nobghashtag -- 76,526
			where p.cleanhashtag <> '' -- 76821
		--	and left(concat_ws('_', 'DOC', s.DocID), 255) = 'DOC_S3DOC_100771'
		

			
	SELECT distinct  --replace(S.folderpath, '%' + p.cleanhashtag+ '%' + '/', '') as folderpath
		 replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
		  CASE 
			WHEN p.cleanhashtag like 'BG%' 
			THEN REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.cleanhashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'')
			ELSE REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.nobghashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'')
		   END
		   , '-7', ''), '-8', ''), '-5', ''), '-3', ''), '-4', ''), 'GC', ''), '-P&C', ''),  '/01 MASTER FILE', ''), '() ES/', ''), '-)', ''), '-', ''), '()', ''), ')', ''), '(', '') AS	destinationfolderpath
	--	, S.folderpath original
		--, s.filecomplete
		--,p.[name]
		--, p.cleanhashtag
		--, p.nobghashtag
	FROM #CleanDocScan s -- 219187
		INNER JOIN #CleanerAlign p
			ON s.folderpath like '%' + p.cleanHashtag +'%' -- 74,817
			OR s.folderpath like '%' + p.nobghashtag -- 75,365
			OR s.filecomplete like '%' + p.cleanHashtag + '%' -- 77051
			--OR s.filecomplete like '%' + p.nobghashtag -- 76,526
			where p.cleanhashtag <> '' -- 76821
	
	SELECT distinct top 1000 replace(S.folderpath, '%' + p.cleanhashtag+ '%' + '/', '') as folderpath
		, S.folderpath original
		, s.filecomplete
		--,p.[name]
		, p.cleanhashtag
		, p.nobghashtag
		from #CleanDocScan s
		INNER JOIN #CleanerAlign p
			ON s.folderpath like '%' + p.cleanHashtag +'%' -- 74,817
			OR s.folderpath like '%' + p.nobghashtag -- 75,365
			OR s.filecomplete like '%' + p.cleanHashtag + '%' -- 77051
			--OR s.filecomplete like '%' + p.nobghashtag -- 76,526
			where p.cleanhashtag <> '' -- 76821
		
			
			--AND p.Hashtag like 'BG%' -- 18686

			SELECT top 1000 *
			FROM #CleanDocScan  

			SELECt *
			FROM #Cleaneralign -- 2033

			-- clean hashtag



		
		--SELECT count(filecomplete)
		--FROM #CleanDocScan s
		--INNER JOIN #CleanAlign p
		--	on s.folderpath like '%' + p.Hashtag +'%'
		--	and p.Hashtag not like 'BG%' -- 18686
		--	and p.hashtag not in ('ULORIC','COW','3M','FATAL-ITY','COMMERCIAL','MIRENA','taxotere','TVM','xarelto','HEAT','ZANTAC','RU','TALC','pending','ROUND-UP','CG','ESSURE','PRADAXA','Rose','WALMART','RAE','Rocass', 'HM','IVC') -- 12096

		--SELECT count(filecomplete)
		--FROM #CleanDocScan s
		--INNER JOIN #CleanAlign p
		--	on s.filecomplete like '%' + p.Hashtag +'%'
		--	and p.Hashtag not like 'BG%' -- 18686
		--	and p.hashtag not in ('ULORIC','COW','3M','FATAL-ITY','COMMERCIAL','MIRENA','taxotere','TVM','xarelto','HEAT','ZANTAC','RU','TALC','pending','ROUND-UP','CG','ESSURE','PRADAXA','Rose','WALMART','RAE','Rocass', 'HM','IVC') -- 18078

		--SELECT count(filecomplete)
		--FROM #CleanDocScan s
		--INNER JOIN #CleanAlign p
		--	on s.folderpath like '%' + p.Hashtag +'%'
		--	and p.Hashtag  like 'BG%' -- 18686
		--	and p.hashtag not in ('ULORIC','COW','3M','FATAL-ITY','COMMERCIAL','MIRENA','taxotere','TVM','xarelto','HEAT','ZANTAC','RU','TALC','pending','ROUND-UP','CG','ESSURE','PRADAXA','Rose','WALMART','RAE','Rocass', 'HM','IVC') -- 18078

		--	SELECT distinct --replace(replace(replace(replace(replace(replace(replace(replace(hashtag, ', RAE', ''), ', TVM', ''), ', CG, HM', ''), ', HM', ''), ', GC', ''), ', CG, XARELTO', ''), ', ReferredOut', ''), ', JG', '')
		--	hashtag
		--	from #CleanAlign 
		--	where hashtag is not null -- 2113'
		--	and  hashtag not in ('BIA-ALCL-BREAST-CANCER, CG','BOX-71, HM','BUSINESS-INTERRUPTION, CG','Business-Interruption, GC, MT-BOX-94, Ref-by-BR','CG','CG, HM','CG, IVC','CG, RU','CG, taxotere',
		--	'CG, Zantac','COMMERCIAL','commercial, driver, heat','COMMERCIAL, JG','covid-pending','COW','DEMANDDONE, JG, JJG','ESSURE','FATALITY','FN, TALC','FRACTURE','GC, HM','GC, PENCIL-FILE, RU',
		--	'GC, PENCIL-FILE, TVM','GC, PENDING-HM','GC, Pending-HM, Prev-caller-0317-YA','GC, pending-paraquat','GC, Pending-Talc','HEAT','HEAT, JG','HM','HM, NT','HM, RU','HM, TVM','hm-pend-rev',
		--	'HMnbsp','IVC','JG','JJG','LOSARTAN, RU, TALC','med-neg, TALC','METFORMIN','MIRENA','nbsp19-675b','nbsp19-991-b','NOMRI','NQ, PENDING-HM','NQ-3M','NQ-3Mnbsp','NQ-BREAST-IMP','NQ-CANCER',
		--	'NQ-HM','NQ-HMnbsp','NQ-HMnbsp, Pending-Talc, REF-BRGC','NQ-Losartan','NQ-RU','NQ-TALC','NQ-Talc, NQ-Taxotere','NQ-TVM','NQ-TVMnbsp','NQ-XELJANZ','NQ-Zantac','NTC-GC-file, PENDING-RU',
		--	'PARAQUAT','pend-business-int','Pend-Talc','pending','pending, ru','pending, TVM','PENDING-3M','Pending-HM','pending-RU','Pending-Talc','Pending-Talc-case','Pending-TVM','Pending-Zantac',
		--	'PRADAXA','PREG','PREGNANT','RAE','REFUSEDORTHO','Rocass','ROLLOVER','Rose','ROUND-UP','Roundup','RTKNEE','RU','slipandfall, WALMART','SUTURES','TALC','taxotere','TVM','ULORIC','UNINS',
		--	'WALMART','Winter-Storm','xarelto','XARLETO','Zantac','ATTNY-REF-JUAN-E-GARCIA-RGC','3M-Ear-plugs','2ND-ACCIDENT'
		--	)
		--	and hashtag not like '%,%'

	

		--	and hashtag like '%,%'
			---- 20-256A BG-20-256    --- LOOK AT THIS
			--BG-14-826 BG-14-826A
			--BG-17-968nbsp
			--BG-18-023 HIPnbsp

	SELECT *
	FROM #CleanAlign
	where hashtag like 'BG-18-225'

	SELECT *
	FROM #CleanDocSCan
	where folderpath like '%xarelto%'

		SELECT top 100 *
		FROM [PT1_CLIENT_ALIGN].[Project_Doc_Alignment]
		--/BRG MT/BG-HERNIA MESH/NON-ENGAGED/Garcia, Concepcion BG-18-225

		SELECT TOP 1000 
		folderpath original
		, replace(replace(replace(replace(folderpath, 'Masstort/#recycle', ''), 'Cyndi Computer Backup/Dropbox/', ''), '/- DOCUMENTS/- Forms', ''), '/- DOCUMENTS/', '')  folderpath
		, [FileName]
		, FileExt
		, FileComplete
		FROM s3docscan s
		where fileext <> 'tmp'
and fileext <> 'dl_'
and fileext <> 'da_'
and fileext <> 'ex_'
and fileext <> 'ch_'
and fileext <> 'mt_'
and fileext <> 'ca_'
and fileext <> 'ch_'
and filecomplete <> '.dropbox'
and filename not like '%~%'
and filecomplete <> 'desktop.ini'
and filecomplete <> 'Desktop.lnk'
and filecomplete <> 'Downloads.lnk'
and filecomplete <> '.bzEmpty'
and filecomplete <> 'Thumbs.db'
*/


	END
														