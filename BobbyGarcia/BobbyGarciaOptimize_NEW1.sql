USE [6985_Bobbygarcia]
GO
/****** Object:  StoredProcedure [documents].[usp_insert_staging_Documents]    Script Date: 8/12/2021 1:11:40 PM ******/
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
		 ROW_NUMBER() OVER ( ORDER BY (SELECT NULL )) DOCID
		, Org_Name
		, [Name]
		, Full_Name
		, Phase
		, Project_Type
		, replace(Hashtags, '#', '') Hashtag
		, hashtags original_hashtag
		INTO #CleanAlign
		-- SELECT *
		FROM [PT1_CLIENT_ALIGN].[Project_Doc_Alignment]

--		SELECT top 1000 * FROM #CleanAlign
----------------------------------- taking out invalid extraneous hashtag data ---------------------------------------------------------------------------------------------
	IF OBJECT_ID('TEMP_Cleaneralign', 'U') IS NOT NULL
	DROP TABLE TEMP_Cleaneralign;
			
	CREATE table TEMP_Cleaneralign 
	(
			DocID BIGINT
			, Org_Name VARCHAR(1000)
			, [Name] VARCHAR(1000)
			, Full_Name VARCHAR(1000)
			, Phase VARCHAR(1000)
			, Project_Type VARCHAR(1000)
			, CleanHashtag VARCHAR(1000)
			, noBGHashtag VARCHAR(1000)
			,  original_hashtag  VARCHAR(1000)
			)

			INSERT INTO  TEMP_Cleaneralign
			
			SELECT	
			  DocID
			, Org_Name
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
			, original_hashtag
		
		--INTO #CleanerAlign
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
			
		CREATE NONCLUSTERED INDEX cx_tempCleaneralign ON TEMP_Cleaneralign (DOCID) INCLUDE (CleanHashtag, noBGHashtag);

		-- SELECT Top 1000 * FROM #Cleaneralign
	----------------------------------- taking out invalid file extensions, names, and small folderpath fixes ---------------------------------------------------------------------------------------------
	IF OBJECT_ID('TEMP_CleanDocScan', 'U') IS NOT NULL
	DROP TABLE TEMP_CleanDocScan;
			
	CREATE table TEMP_CleanDocScan
	(
			DocID BIGINT
			, sourceS3Bucket 	VARCHAR(1000)
			, sourceS3ObjectKey 	VARCHAR(1000)
			, sourceS3ObjectKeyEncoded	VARCHAR(1000)
			, original_folderpath	VARCHAR(1000)
			, folderpath		VARCHAR(1000)
			, [FileName]		VARCHAR(1000)
			, FileExt			VARCHAR(1000)
			, FileComplete		VARCHAR(1000)
	 )
	
	INSERT into TEMP_CleanDocScan
	SELECT  
		ID DOCID
		, s.sourceS3Bucket 
		, s.sourceS3ObjectKey 
		, s.sourceS3ObjectKeyEncoded
		, s.folderpath original_folderpath
		, replace(replace(replace(replace(s.folderpath, 'Masstort/#recycle', ''), 'Cyndi Computer Backup/Dropbox/', ''), '/- DOCUMENTS/- Forms', ''), '/- DOCUMENTS/', '')  folderpath
		, s.[FileName]
		, s.FileExt
		, s.FileComplete
	-- SELECT COUNT(*)
	--INTO #CleanDocScan
	-- select top 1000 *
		FROM s3docscan s
		WHERE fileext NOT IN ('tmp', 'dl_', 'da_', 'ex_', 'ch_', 'mt_', 'ca_', 'ch_')
			and filecomplete  not IN ('.dropbox', 'desktop.ini', 'Desktop.lnk', 'Downloads.lnk',  '.bzEmpty', 'Thumbs.db')
			and filename not like '%~%'

		CREATE NONCLUSTERED INDEX cx_TEMP_CleanDocScan ON TEMP_CleanDocScan (DOCID) INCLUDE (folderpath, FileComplete);

	-- SELECT top 1000 * from #CleanDocScan
		----------------------------------- fixing the destination folderpath ---------------------------------------------------------------------------------------------
	IF OBJECT_ID('TEMP_CleanerDocScan', 'U') IS NOT NULL
	DROP TABLE TEMP_CleanerDocScan;
			
	CREATE table TEMP_CleanerDocScan
	(
			DocID BIGINT
			, folderpath		VARCHAR(1000)
			, cleanerFolderPath	VARCHAR(1000)
			, original			VARCHAR(1000)
			, FileComplete		VARCHAR(1000)
			, [name]			VARCHAR(1000)
			, cleanhashtag		VARCHAR(1000)
	 		,  nobghashtag		VARCHAR(1000)
			, PROJECT_TYPE		VARCHAR(1000)
			, sourceS3ObjectKey VARCHAR(1000)
		)

	INSERT INTO TEMP_CleanerDocScan
SELECT distinct 
		  DOCID
		, replace(S.folderpath, '%' + p.cleanhashtag+ '%' + '/', '') as folderpath
		, CASE 
			WHEN p.cleanhashtag like 'BG%' 
			THEN 		REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.cleanhashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'') -- going to give everything to the right of the cleanhashtag. nullif, if this field doesn't contain this, 
			ELSE 		REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.nobghashtag,S.folderpath)-1,1),1),8000),p.nobghashtag,'')
		end	 cleanerFolderPath
		, S.folderpath original
		, s.filecomplete
		, p.[name]
		, p.cleanhashtag
		, p.nobghashtag
		, p.project_type
		, s.sourceS3ObjectKey
		--INTO #CleanerDocScan
	-- SELECT top 1000 * 
		from TEMP_CleanDocScan s
		INNER JOIN tmp_jcobb_1 p
			ON s.folderpath like '%' + p.cleanHashtag +'%' -- 74,817
			OR s.folderpath like '%' + p.nobghashtag -- 75,365
			OR s.filecomplete like '%' + p.cleanHashtag + '%' -- 77051
			--OR s.filecomplete like '%' + p.nobghashtag -- 76,526
			where p.cleanhashtag <> '' -- 76821

	--CREATE NONCLUSTERED INDEX cx_TEMP_CleanERDocScan ON TEMP_CleanERDocScan (DOCID) INCLUDE (folderpath, FileComplete);

	--		SELECt * FROM TEMP_CleanerDocScan

	----------------------------------- fixing the destination folderpath even more ---------------------------------------------------------------------------------------------
	IF OBJECT_ID('TEMP_CleanestDocScan', 'U') IS NOT NULL
	DROP TABLE TEMP_CleaneSTDocScan;
			
	CREATE table TEMP_CleaneSTDocScan
	(
			DocID BIGINT
			, ORIGINAL		VARCHAR(1000)
			, cleanerFolderPath		VARCHAR(1000)
			, CleanDestinationFolderPath			VARCHAR(1000)
			, sourceS3ObjectKey VARCHAR(1000)
	)

	insert into TEMP_CleanestDocScan
			SELECT
			 DOCID
			, original
			, cleanerFolderPath
			, CASE
				WHEN cleanerFolderPath NOT LIKE '%/%'
				THEN NULL
				ELSE SUBSTRING(cleanerFolderPath,CHARINDEX('/',cleanerFolderPath),LEN(cleanerFolderPath)) 
			  END AS CleanDestinationFolderPath
			, sourceS3ObjectKey
			 -- INTO #CleanestDocScan
			FROM TEMP_CleanerDocScan

	CREATE NONCLUSTERED INDEX cx_tempCleanestDocScan ON TEMP_CleaneSTDocScan (DOCID) include (CleanDestinationFolderPath);

		-- SELECT top 1000 * FROM TEMP_CleanestDocScan
	/*Clustered*/

	IF OBJECT_ID('TEMPDB.dbo.#DocsToLoad', 'U') IS NOT NULL
	DROP TABLE #DocsToLoad;


 -- insert
 	--INSERT INTO
		---- select * from 
		--	--[PT1].[Documents]
		--	-- delete from
		--	filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064074
		--	(
		--		  [__ImportStatus]
		--		, [__ImportStatusDate]
		--		, [__ErrorMessage]
		--		, [__WorkerID]
		--		, [__DocID]
		--		, [DocExternalID]
		--		, [ProjectExternalID]
		--		, [FilevineProjectID]
		--		, [NoteExternalID]
		--		, [SourceS3Bucket]
		--		, [SourceS3ObjectKey]
		--		, [SourceS3ObjectKeyEncoded]
		--		, [DestinationFileName]
		--		, [DestinationFolderPath]
		--		, [UploadDate]
		--		, [Hashtags]
		--		, [UploadedByUsername]
		--		, [SectionSelector]
		--		, [FieldSelector]
		--		, [CollectionItemExternalID]
		--		, [isReload]
		--	)     
			WITH cte AS
			(
			SELECT
				  row_number() OVER (partition by [DocExternalID] order by [projectexternalid]) AS DUPCNT
				, [__ImportStatus]
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
				FROM 
				(

			SELECT DISTINCT -- top 1000
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			,  left(concat_ws('_', 'DOC', s.DocID, left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag, s.FileComplete) 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag, s.FileComplete)
			  END, 64)), 255) [DocExternalID]
			--, CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) [ProjectExternalID]
			--, left(CASE 
			--	WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
			--	THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag) 
			--	ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag)
			--  END, 64) 
			, LEFT(CONCAT_WS('_', 'P', a.original_hashtag, a.phase, replace(a.Name, 'Passengers: ', ''), a.Project_Type), 62) AS  ProjectExternalID
		--	  LEFT(CONCAT_WS('_', 'P', a.hashtags, a.phase, replace(a.Name, 'Passengers: ', ''), a.Project_Type), 62) 
			, NULL [FilevineProjectID]
			, NULL [NoteExternalID]
			, left(s.sourceS3Bucket, 255) [SourceS3Bucket]
			, left(s.sourceS3ObjectKey, 512) [SourceS3ObjectKey]
			, left(s.sourceS3ObjectKeyEncoded, 512) [SourceS3ObjectKeyEncoded]
			, s.FileComplete [DestinationFileName]
			--, s2.cleandestinationFolderPath AS	 [DestinationFolderPath]
			, d.destinationFolderPath AS	 [DestinationFolderPath]
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
			, null [isReload]
			
	-- SELECT distinct TOP 1000 * 
	-- SELECt s2.*
	-- SELECT * FROM [PT1_CLIENT_ALIGN].[DestinationFolderPathFix] d
	-- SELECT count(*)
	-- SELECT count(*)
		FROM TEMP_CleanDocScan s -- 219187
		INNER JOIN TEMP_CleaneSTDocScan s2
			ON s.docid = s2.docid -- 76,821
		INNER JOIN TEMP_CleanerDocScan p
			ON P.DOCID = S.DOCID -- 89,989
		LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_DestinationFolderPathFix2] d
			ON s2.CleanDestinationFolderpath = d.CleanDestinationFolderpath -- 57650
		INNER JOIN TEMP_Cleaneralign a
			ON left(CASE 
				WHEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
				THEN CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.nobghashtag) 
				ELSE CONCAT_WS('_', 'P', p.[name], p.Project_Type, p.Cleanhashtag)
			  END, 64)  = left(CASE 
											WHEN CONCAT_WS('_', 'P', a.[name], a.Project_Type, a.Cleanhashtag) IS NULL 
											THEN CONCAT_WS('_', 'P', a.[name], a.Project_Type, a.nobghashtag) 
											ELSE CONCAT_WS('_', 'P', a.[name], a.Project_Type, a.Cleanhashtag)
											END, 64
											)
		--ON s.folderpath like '%' + p.cleanHashtag +'%' -- 74,817
			--OR s.folderpath like '%' + p.nobghashtag -- 75,365
			--OR s.filecomplete like '%' + p.cleanHashtag + '%' -- 77051
			--OR s.filecomplete like '%' + p.nobghashtag -- 76,526
			where p.cleanhashtag <> '' -- 91,078
			) a
			)
			SELECT *
			INTO #DocsToLoad
			FROM cte
			WHERE DUPCNT = 1 -- 76,821
			-- 48933

--	SELECt * FROM #DocsToLoad

	-- select * from #DocsToLoad
	-- select * from TEMP_Cleaneralign


	-- final insert
			INSERT INTO
		-- select count(*) from 
			--[PT1].[Documents]
			-- delete from
			filevinestagingimport.._BobbyGarciaTest2_Documents___550064167
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
		
			SELECT
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
				--, CASE
				--	WHEN [DestinationFolderPath] like '%[0-9][0-9]-[0-9][0-9][0-9]%' 
				--	 AND [DestinationFolderPath] not like '%/%'
				--	THEN Null
				--	WHEN [DestinationFolderPath] like '%[0-9][0-9]-[0-9][0-9][0-9]%/%' 
				--	 AND [DestinationFolderPath] not like '%/%'
				--	THEN right( [DestinationFolderPath], CHARINDEX('/', [DestinationFolderPath]))
				--	ELSE [DestinationFolderPath]
				--  END AS [DestinationFolderPath]
			    , [DestinationFolderPath]
				, [UploadDate]
				, [Hashtags]
				, [UploadedByUsername]
				, [SectionSelector]
				, [FieldSelector]
				, [CollectionItemExternalID]
				, [isReload]
		--SELECT count(*)
		FROM 		#DocsToLoad
		--order by 14

		--SELECT distinct destinationfolderpath
		--FROM 		#DocsToLoad

		--SELECT *
		--FROM 			filevinestagingimport.._BobbyGarciaTest2_Documents___550064167
		--WHERE projectexternalid not in (SELECT projectexternalid 
		--								FROM filevinestagingimport.._BobbyGarciaTest2_Projects___550064163
		--								)

-- docs unable to load
/*
WITH CTE AS (
SELECT sources3objectkey
FROM TEMP_CleanDocScan -- 219187
EXCEPT
SELECT sources3objectkey
FROM filevinestagingimport.._BobbyGarciaTest2_Documents___550064167 d1 -- 76,821
)
SELECT s.folderpath, s.filecomplete
FROM CTE c
join TEMP_CleanDocScan s
on c.sources3objectkey = s.sources3objectkey -- 148k

*/






















		--SELECT distinct destinationfolderpath
		--, CASE 
		--	WHEN replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(destinationfolderpath, '(Daniel C. Ramirez',''), '/Pic','Pic'), '-efiled',''), '1 stop', '')
		--		, 'Aguilar Susana, Meleney Moreno, Reynaldo Moreno 17-182/',''), 'Aguilar, Iris Lee  BG 15-891-P&C',''), 'Aguirre, Daniel BG-18-979','')
		--		, 'Aguirre,Israel vs. Gonzalez,Jessyca (BG-13-246)ALL/',''),'Aguirre,Israel vs. Gonzalez,Jessyca (BG-13-246)ALL/','')
		--		, 'Aguirre,Israel vs. Gonzalez,Jessyca (BG-13-246)ALLPics','Pics'), 'Aguirre,Israel vs. Gonzalez,Jessyca (BG-13-246)ALL',''), 'Ahrens, Roxie vs. VBMC (BG-14-1020)ALL','')
		--		, 'ALCOZER, HENRY 19-316  Rose/',''), 'ALCOZER, HENRY 19-316  Rose',''), 'alcozer henry 19-316',''), 'Alfaro Ruben -Franco Rodriguez (BG-12-076)JP/',''), 'Alfaro Ruben -Franco Rodriguez (BG-12-076)JP',''), 'Almanza, Javier (BG-16-702)ALL/',''), 'AMARO EDGAR 19-651',''), 'AVELINO, ARACELI JOSE MARIA J GARCIA 20-191/','')
		--		, 'AVELINO, ARACELI JOSE MARIA J GARCIA 20-191',''), 'AVILA, JR. JUAN BG-15-603',''), 'AVILA, JUAN III BG-17-458/','')
		--		,'BALDERAS, GRACIELA BG-/',''),'BALDERAS, GRACIELA BG-',''), 'Balleza Jose 18-1450',''), 'Barrera, Alfredo BG-16-103 GC',''), 'CAMARGO, ROSALINA & PEDRO BG-15-1479','')
		--		, 'Campos, Jose A. BG 17-924',''), 'Campos, Juanan Belinda BG 17-923',''),'Canales Arcelia 16-308/',''),'Canales Arcelia 16-308',''), 'Cano, Josefina BG-15-149','')
		--		, 'Cantu, Cristina R. BG-17-887',''), 'CANTU, EDWIN - 2ND MVA -BG-/',''), 'CANTU, EDWIN - 2ND MVA -BG-',''), 'Cantu, Jose Luis BG-17-1369','')
		--		, 'Caraballo-Delgado, Elena BG-17-750 GC',''), 'CARRERAS ROSA; HERNANDEZ, JOSE L 19-1107',''), 'CASAS, ALMA 17-997',''), 'CASAS, CESCAR BG-17-022/','')
		--		, 'CASAS, CESCAR BG-17-022',''), 'Casas, Rolando BG-16-009',''), 'Castaneda, Sulema G-15-565',''), 'Castillo, Ramiro (BG-7) JP-RR','')
		--		, 'Castro Sandra, Andrea Garcia, Alexxa Garcia, Ofelio Garcia 17-272/',''), 'CAVAZOS, BONIFICIA BG-18-/',''), 'CAVAZOS, BONIFICIA BG-18-','')
		--		, 'Cepeda, Roel ELIZABETH BRIONES et. al. BG-17-612/',''), 'CEPEDA, SARAY',''), 'Charles, Marie 17-1018/',''), 'Charles, Marie 17-1018','')
		--		, 'Chavez, Silvia Elena BG-18-1241',''), 'ZUNIGA ALEXANDER BG-',''), 'Zavala Crystal, Myiah Cabrera, Robinson Calderon 18-778',''), 'Zamora, Evelia G. BG-15-1562','')
		--		, 'Zamora Maria Elena 161-215',''), 'Villarreal, Roberto BG-17-656',''), 'Villarreal, Amaro BG 18-375',''), 'Villanueva, Brigido BG-17-296 GC','')
		--		, 'Velez, Felepe  BG-17-002',''), 'Vela, Dennisse  BG-15-1512',''), 'VARGAS VERONICA BG-',''), 'VALDEZ VICTOR A. 19-606',''), 'Trevino, Alonzo  GC','')
		--		, 'Trevino Ramirez, Maria BG-17-196',''), 'TREVINIO JOEWW15-1316',''), 'Trejo, Oneida  BG-16-533',''), 'Trejo, Leonel BG-16-598','')
		--		, 'Torres, Martin  BG-17-115',''), 'Torres, Alicia BG-15-244',''), 'Tena Teresa BG-17-187',''), 'TANGUMA, VERONICA BG-370',''), 'TAFOYA, KARLA ET AL BG-18-','')
		--		, 'Snell, Jose L.; Samuel S. (Minor) BG- JP',''), 'Silva, Juan Jr. BG-17-1339) JP',''), 'Siller, Hilda BG-19-545 GC','')
		--		, 'SANCHEZ, SYLIVA BG-15-289/',''), 'SANCHEZ, SYLIVA BG-15-289',''), 'Sanchez, Laurie Ann BG 19-286 GC',''), 'Sanchez, Elizabeth R.  BG-17-206','')
		--		, 'SANCHEZ, DAVID 17-1103  GC',''), 'SANCHEZ, DAVID 17-1103',''), 'Salinas, pedro  Dolores BG-17-592',''), 'Salinas, Mirthala BG-/','')
		--		, 'Salinas, Mirthala BG-',''), 'Salinas, Jose BG-14-497',''), 'Salinas, Imelda Bg-17-909',''), 'Salinas, Genoveva BG-15-1194',''), 'Salinas, Argelia BG-17-360','')
		--		, 'Salinas David, DALIA SALINAS 17-216',''), 'SALDANA, MARIA E 17-849',''), 'Salazar, Elva BG-17-448 GC','')
		--		IN ('/ALVAREZ, VICENTE, AUDREY & VICENTE  BG-','/Cazares G Leonel BG-17-','/CHAVEZ, CYNTHIA BG-19-','/Fish, Angel Leeann BG-(pre-lit)','/Flores, Martina -BG-',
		--			'/LERMA, FLORENTINO AKA FRANCISCO CARRALEZ BG-18-DO NOT USE FILE','/Ramos, Josue vs. Rocha, Rene (BG-)','/Rosales Stephanie BG- auto Ped',
		--			'_Downloaded (FN Use ONLY)/Anzaldua, Josie BG-17-1140','_Downloaded (FN Use ONLY)/Apairicio-Torres, Juan Manuel','_Downloaded (FN Use ONLY)/Cintron, Jose A. BG-18-353',
		--			'_Downloaded (FN Use ONLY)/CISNEROS ALICIA 18-281','_Downloaded (FN Use ONLY)/Cuellar, Ramona BG-17-870','_Downloaded (FN Use ONLY)/Davlos-Marquez, Roberto BG-17-911',
		--			'_Downloaded (FN Use ONLY)/Garcia-Gonzalez, Graciela BG-17-334','_Downloaded (FN Use ONLY)/Gonzalez, Carlos BG-176-489','_Downloaded (FN Use ONLY)/Ovalle Gloria 18-506',
		--			'_Downloaded (FN Use ONLY)/Rivas, Daniel BG-18-990','_Downloaded (FN Use ONLY)/Sustaita, Marisela BG-1231', 'Agado Maria Elena, Isaac Ovalle, Jaclyn Ovalle 16-254'
		--			,'Aguilar Susana, Meleney Moreno, Reynaldo Moreno 17-182', 'Aguilar, Nancy  BG 14-1004 P&C')
		--		THEN NULL
		--		ELSE replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(destinationfolderpath, '(Daniel C. Ramirez',''), '/Pic','Pic'), '-efiled',''), '1 stop', '')
		--		, 'Aguilar Susana, Meleney Moreno, Reynaldo Moreno 17-182/',''), 'Aguilar, Iris Lee  BG 15-891-P&C',''), 'Aguirre, Daniel BG-18-979','')
		--		, 'Aguirre,Israel vs. Gonzalez,Jessyca (BG-13-246)ALL/',''),'Aguirre,Israel vs. Gonzalez,Jessyca (BG-13-246)ALL/','')
		--		, 'Aguirre,Israel vs. Gonzalez,Jessyca (BG-13-246)ALLPics','Pics'), 'Aguirre,Israel vs. Gonzalez,Jessyca (BG-13-246)ALL',''), 'Ahrens, Roxie vs. VBMC (BG-14-1020)ALL','')
		--		, 'ALCOZER, HENRY 19-316  Rose/',''), 'ALCOZER, HENRY 19-316  Rose',''), 'alcozer henry 19-316',''), 'Alfaro Ruben -Franco Rodriguez (BG-12-076)JP/',''), 'Alfaro Ruben -Franco Rodriguez (BG-12-076)JP',''), 'Almanza, Javier (BG-16-702)ALL/',''), 'AMARO EDGAR 19-651',''), 'AVELINO, ARACELI JOSE MARIA J GARCIA 20-191/','')
		--		, 'AVELINO, ARACELI JOSE MARIA J GARCIA 20-191',''), 'AVILA, JR. JUAN BG-15-603',''), 'AVILA, JUAN III BG-17-458/','')
		--		,'BALDERAS, GRACIELA BG-/',''),'BALDERAS, GRACIELA BG-',''), 'Balleza Jose 18-1450',''), 'Barrera, Alfredo BG-16-103 GC',''), 'CAMARGO, ROSALINA & PEDRO BG-15-1479','')
		--		, 'Campos, Jose A. BG 17-924',''), 'Campos, Juanan Belinda BG 17-923',''),'Canales Arcelia 16-308/',''),'Canales Arcelia 16-308',''), 'Cano, Josefina BG-15-149','')
		--		, 'Cantu, Cristina R. BG-17-887',''), 'CANTU, EDWIN - 2ND MVA -BG-/',''), 'CANTU, EDWIN - 2ND MVA -BG-',''), 'Cantu, Jose Luis BG-17-1369','')
		--		, 'Caraballo-Delgado, Elena BG-17-750 GC',''), 'CARRERAS ROSA; HERNANDEZ, JOSE L 19-1107',''), 'CASAS, ALMA 17-997',''), 'CASAS, CESCAR BG-17-022/','')
		--		, 'CASAS, CESCAR BG-17-022',''), 'Casas, Rolando BG-16-009',''), 'Castaneda, Sulema G-15-565',''), 'Castillo, Ramiro (BG-7) JP-RR','')
		--		, 'Castro Sandra, Andrea Garcia, Alexxa Garcia, Ofelio Garcia 17-272/',''), 'CAVAZOS, BONIFICIA BG-18-/',''), 'CAVAZOS, BONIFICIA BG-18-','')
		--		, 'Cepeda, Roel ELIZABETH BRIONES et. al. BG-17-612/',''), 'CEPEDA, SARAY',''), 'Charles, Marie 17-1018/',''), 'Charles, Marie 17-1018','')
		--		, 'Chavez, Silvia Elena BG-18-1241',''), 'ZUNIGA ALEXANDER BG-',''), 'Zavala Crystal, Myiah Cabrera, Robinson Calderon 18-778',''), 'Zamora, Evelia G. BG-15-1562','')
		--		, 'Zamora Maria Elena 161-215',''), 'Villarreal, Roberto BG-17-656',''), 'Villarreal, Amaro BG 18-375',''), 'Villanueva, Brigido BG-17-296 GC','')
		--		, 'Velez, Felepe  BG-17-002',''), 'Vela, Dennisse  BG-15-1512',''), 'VARGAS VERONICA BG-',''), 'VALDEZ VICTOR A. 19-606',''), 'Trevino, Alonzo  GC','')
		--		, 'Trevino Ramirez, Maria BG-17-196',''), 'TREVINIO JOEWW15-1316',''), 'Trejo, Oneida  BG-16-533',''), 'Trejo, Leonel BG-16-598','')
		--		, 'Torres, Martin  BG-17-115',''), 'Torres, Alicia BG-15-244',''), 'Tena Teresa BG-17-187',''), 'TANGUMA, VERONICA BG-370',''), 'TAFOYA, KARLA ET AL BG-18-','')
		--		, 'Snell, Jose L.; Samuel S. (Minor) BG- JP',''), 'Silva, Juan Jr. BG-17-1339) JP',''), 'Siller, Hilda BG-19-545 GC','')
		--  END AS fixed
		--FROM #DocsToLoad
		--WHERE destinationfolderpath is not null
		--order by 1
		
		 
--NON ENGAGED files/Ramirez, Maria De Jesus BG-17-025
--NON ENGAGED files/Quintanilla, Martha BG-18-016  CG
--NON ENGAGED files/Quintanilla, Maria BG-14-873
--NON ENGAGED files/Villarreal, Maria Teresa BG-17-332
--NON ENGAGE/Sandoval, Lorie Taylor BG-15-1244
--NON ENGAGE/Piloto, Martha A. BG-17-379
--Rodriguez (BG-12-076)JP/Correspondence/CLIENT	...Alfaro Ruben -Franco Rodriguez (BG-12-076)JP/Correspondence/CLIENT
--	ALCOZER, HENRY 19-316  Rose/..... , HENRY 19-316  Rose/PRE LIT
--	316  Rose/PRE LIT/LOPS LIENS
--, HENRY 19-316  Rose/PRE LIT
--ENRY 19-316  Rose/PRE LIT/PR
--Rose/PRE LIT/PROPERTY DAMAGE
--PRE LIT/SETTLEMENT STATEMENT
--, HENRY 19-316  Rose/PRE LIT
--Y 19-316  Rose/Contract & MA
--ose/LITIGATION/Medical Bills
--e/LITIGATION/Medical Records
--Franco Rodriguez (BG-12-076)JP/Correspondence
--iguez (BG-12-076)JP/

--/Blank Discovery
--o Rodriguez (BG-12-076)JP/Discovery/Responses
--o Rodriguez (BG-12-076)JP/Discovery/Responses
--o Rodriguez (BG-12-076)JP/Discovery/Responses
--riguez (BG-12-076)JP/Doc. Faxed to Law Office
--riguez (BG-12-076)JP/Doc. Faxed to Law Office
--458/Property Damage/Photos	AVILA, JUAN III BG-17-458/Property Damage/Photos
--BG - Erica OP - Copy
--BG - Erica OP
--Castillo, Ramiro (BG-7) JP-RR
--	NON ENGAGED files/Quintanilla, Maria BG-14-873

	END

			--SELECt *
			--FROM #DocsToLoad
			--SELECT *
			--froM TEMP_Cleaneralign

			--SELECT *
			--FROM [PT1_CLIENT_ALIGN].[Project_Doc_Alignment] a
			 

			--SELECT *
			--FROM cte
			--where dupcnt > 1
			--order by 1 desc
			
	--		SELECT count(*), __ImportStatus
	--		FROM 			filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064074
	--		group by __ImportStatus

	--		SELECT count(*), __ErrorMessage
	--		FROM 			filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064074
	--		group by __ErrorMessage

	--		SELECT count(*) 
	--		FROM filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550063711
	--		where ProjectExternalID not in (SELECT ProjectExternalID 
	--									FROM filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064074
	--									)

	---- SELECT *
	--	FROM [PT1_CLIENT_ALIGN].[Project_Doc_Alignment]
	--	-- This loo


	--		and  a.[DocExternalID] = 'DOC_126806_Maria Teresa Villarreal-MT-Hernia Mesh BG-17-332_Mass Tort - Med'
			



	--		and left(concat_ws('_', 'DOC', s.DocID, left(CASE 
	--			WHEN CONCAT_WS('_', p.[name], p.Project_Type, p.Cleanhashtag) IS NULL 
	--			THEN CONCAT_WS('_', p.[name], p.Project_Type, p.nobghashtag, 1) 
	--			ELSE CONCAT_WS('_', p.[name], p.Project_Type, s2.CleanDestinationFolderPath, p.Cleanhashtag )
	--		  END, 64)), 255)  = 'DOC_102880_Maria Quintanilla-MT-Xarelto_Mass Tort - Pharmaceutical_17-495_2'
	--		  --'DOC_100247_P_Margarita Garcia_Mass Tort - Medical Devices_BG-17-046'
	--	--	and left(concat_ws('_', 'DOC', s.DocID), 255) = 'DOC_S3DOC_100771'


	--	SELECT *
	--	FROM filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550063711
