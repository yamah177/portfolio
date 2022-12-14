USE [6985_Bobbygarcia]
GO
/****** Object:  StoredProcedure [documents].[usp_insert_staging_Documents]    Script Date: 8/23/2021 12:49:02 PM ******/
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
		SELECT count(*)
		FROM s3docscan -- 300,751
		-- thumbs.db
		-- .dll
		validfiles - 219k
		
		-- actually joinable betwen projects and docs
		SELECT count(*)
		FROM TEMP_CleanestDocScan -- 76,821

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

		-- SELECT Top 1000 * FROM Cleaneralign 
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
			, cleanerFolderPath		VARCHAR(1000)
			, original			VARCHAR(1000)
			, FileComplete		VARCHAR(1000)
			, [name]			VARCHAR(1000)
			, cleanhashtag		VARCHAR(1000)
	 		,  nobghashtag		VARCHAR(1000)
			, PROJECT_TYPE		VARCHAR(1000)
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
			 -- INTO #CleanestDocScan
			FROM TEMP_CleanerDocScan

	CREATE NONCLUSTERED INDEX cx_tempCleanestDocScan ON TEMP_CleaneSTDocScan (DOCID) include (CleanDestinationFolderPath);

		-- SELECT top 1000 * FROM TEMP_CleanestDocScan
------------------------------------------------- FOLDERPATH LOGIC --


-- folderpath 1
	IF OBJECT_ID('TEMPDB.dbo.#folderpath1', 'U') IS NOT NULL
	DROP TABLE #folderpath1;

		SELECT distinct
		  original
		, CleanDestinationFolderPath
		, CASE
			WHEN charindex ('/', CleanDestinationFolderPath, 2) = 0
			THEN NULL
			WHEN charindex ('/', CleanDestinationFolderPath, 2) <> 0
			THEN TRIM(RIGHT(CleanDestinationFolderPath, len(CleanDestinationFolderPath) - CHARINDEX('/', CleanDestinationFolderPath, 2))) 
		  END AS folderpath1
		INTO #folderpath1
		-- SELECt *
		FROM CleanestDocScan
		WHERE CleanDestinationFolderPath like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 932

-- folderpath 2
IF OBJECT_ID('TEMPDB.dbo.#folderpath2', 'U') IS NOT NULL
	DROP TABLE #folderpath2;

		SELECT distinct 
		  original
		, CleanDestinationFolderPath
		, CASE
			WHEN charindex ('/', folderpath1, 2) = 0
			THEN NULL
			WHEN charindex ('/', folderpath1, 2) <> 0
			THEN TRIM(RIGHT(folderpath1, len(folderpath1) - CHARINDEX('/', folderpath1, 2))) 
		  END AS folderpath2
		INTO #folderpath2
		FROM #folderpath1
		WHERE folderpath1 like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 741

-- folderpath 3
IF OBJECT_ID('TEMPDB.dbo.#folderpath3', 'U') IS NOT NULL
	DROP TABLE #folderpath3;

		SELECT distinct 
		  original
		, CleanDestinationFolderPath
		, CASE
			WHEN charindex ('/', folderpath2, 2) = 0
			THEN NULL
			WHEN charindex ('/', folderpath2, 2) <> 0
			THEN TRIM(RIGHT(folderpath2, len(folderpath2) - CHARINDEX('/', folderpath2, 2))) 
		  END AS folderpath3
		INTO #folderpath3
		FROM #folderpath2
		WHERE folderpath2 like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 368

-- folderpath 4
IF OBJECT_ID('TEMPDB.dbo.#folderpath4', 'U') IS NOT NULL
	DROP TABLE #folderpath4;

		SELECT distinct 
		  original
		, CleanDestinationFolderPath
		--, folderpath 	originalfolderpath
		, CASE
			WHEN charindex ('/', folderpath3, 2) = 0
			THEN NULL
			WHEN charindex ('/', folderpath3, 2) <> 0
			THEN TRIM(RIGHT(folderpath3, len(folderpath3) - CHARINDEX('/', folderpath3, 2))) 
		  END AS folderpath4
		INTO #folderpath4
		FROM #folderpath3
		WHERE folderpath3 like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 210

-- folderpath 5
IF OBJECT_ID('TEMPDB.dbo.#folderpath5', 'U') IS NOT NULL
	DROP TABLE #folderpath5;

		SELECT distinct 
		  original
		, CleanDestinationFolderPath
		, CASE
			WHEN charindex ('/', folderpath4, 2) = 0
			THEN NULL
			WHEN charindex ('/', folderpath4, 2) <> 0
			THEN TRIM(RIGHT(folderpath4, len(folderpath4) - CHARINDEX('/', folderpath4, 2))) 
		  END AS folderpath5
		INTO #folderpath5
		FROM #folderpath4
		WHERE folderpath4 like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 81

-- folderpath6
	IF OBJECT_ID('TEMPDB.dbo.#folderpath6', 'U') IS NOT NULL
	DROP TABLE #folderpath6;

		SELECT distinct
		  original
		, CleanDestinationFolderPath
		, CASE 
			WHEN CleanDestinationFolderPath like '%BG-%'
			THEN TRIM(RIGHT(CleanDestinationFolderPath, len(CleanDestinationFolderPath) - CHARINDEX('/', CleanDestinationFolderPath, 2))) 
		  END AS folderpath6
		  INTO #folderpath6
	-- SELECT *
		FROM CleanestDocScan
		WHERE CleanDestinationFolderPath not like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 2340
		AND CleanDestinationFolderPath like '%BG-%' -- 200

		-- folderpath7
IF OBJECT_ID('TEMPDB.dbo.#folderpath7', 'U') IS NOT NULL
	DROP TABLE #folderpath7;

		SELECT distinct 
		   original
		 , CleanDestinationFolderPath
		 , CASE 
			WHEN CleanDestinationFolderPath like '%BG-%'
			THEN TRIM(RIGHT(folderpath6, len(folderpath6) - CHARINDEX('/', folderpath6, 1))) 
		  END AS folderpath7
		INTO #folderpath7
		FROM #folderpath6
		WHERE CleanDestinationFolderPath not like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 2340
		AND folderpath6 like '%BG-%' -- 151

-- folderpath8
IF OBJECT_ID('TEMPDB.dbo.#folderpath8', 'U') IS NOT NULL
	DROP TABLE #folderpath8;

		SELECT distinct 
		   original
		 , CleanDestinationFolderPath
		 , replace(
		CASE 
			WHEN CleanDestinationFolderPath like '%BG-%'
			AND TRIM(RIGHT(folderpath7, len(folderpath7) - CHARINDEX('/', folderpath7, 1))) like '%BG-%'
			THEN NULL
			ELSE folderpath7
		END ,  'LERMA, FLORENTINO AKA FRANCISCO CARRALEZ BG-18-DO NOT USE FILE/', '') AS folderpath8
		INTO #folderpath8
		FROM #folderpath7
		WHERE CleanDestinationFolderPath not like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 2340
		AND folderpath7 like '%BG-%' -- 37
		--LERMA, FLORENTINO AKA FRANCISCO CARRALEZ BG-18-DO NOT USE FILE/Correspondence/Adverse

-- folderpath 9
	
	IF OBJECT_ID('TEMPDB.dbo.#folderpath9', 'U') IS NOT NULL
	DROP TABLE #folderpath9;

	SELECT distinct 
	      original
	    , CleanDestinationFolderPath
		, CASE 
			WHEN  CleanDestinationFolderPath like '/%'
			THEN  TRIM(RIGHT(CleanDestinationFolderPath, len(CleanDestinationFolderPath) - CHARINDEX('/', CleanDestinationFolderPath, 1)))
			ELSE CleanDestinationFolderPath
		  END AS folderpath9
		INTO #folderpath9
		FROM CleanestDocScan
		WHERE CleanDestinationFolderPath not like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 
		AND CleanDestinationFolderPath not like '%BG-%' -- 8329

-- folderpath 107
	
	IF OBJECT_ID('TEMPDB.dbo.#folderpath10', 'U') IS NOT NULL
	DROP TABLE #folderpath10;
	
	SELECT distinct 
	      original
	    , CleanDestinationFolderPath
		, CASE 
			WHEN folderpath9 like '%Copy/%'
			THEN TRIM(RIGHT(folderpath9, len(folderpath9) - CHARINDEX('/', folderpath9, 1)))
			WHEN folderpath9 like '01 Master File%'
			OR folderpath9 like   '01 MasterFile%' 
			OR folderpath9 like 'Master File Copy%'
			THEN null
			--WHEN folderpath like '01 Master File%'
			--THEN  TRIM(RIGHT(folderpath, len(folderpath) - CHARINDEX('/', folderpath, 1)))
			--WHEN folderpath like '%/%Copy%'
			--THEN NULL
			ELSE folderpath9
		  END AS folderpath10
		INTO #folderpath10
		FROM #folderpath9
		WHERE CleanDestinationFolderPath not like '%[0-9][0-9]-[0-9][0-9][0-9]%' -- 
		AND CleanDestinationFolderPath not like '%BG-%' -- 8329
		--order by 3

	IF OBJECT_ID('TEMPDB.dbo.#folderpath11', 'U') IS NOT NULL
	DROP TABLE #folderpath11;

		SELECt distinct 
		  original
	    , CleanDestinationFolderPath
		, replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
		  replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
		  replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
		  replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
		  replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
		  replace(replace(replace(replace(replace(replace(replace(replace(folderpath10, '- Forms/000 STATE BAR/',''), 'Alexis Dominguez',''), 'SALINAS, JOSE MANUEL /','')
		, 'SALINAS, JOSE MANUEL ',''), 'ALINAS, JOSE MANUEL',''), 'Annabel Garza',''), 'Garcia, Regan vs Frances Hernandez () TG/',''), 'Garcia, Regan vs Frances Hernandez () TG','')
		,'Garcia, Elsa & Garcia, Krista /',''),'Garcia, Elsa & Garcia, Krista ','') , 'arcia, Elsa & Garcia, Krista',''), 'Garcia, Regan /',''), 'Garcia, Regan ',''), 'arcia, Regan','')
		, 'Arispe, Jesus  /',''), 'Arispe, Jesus  ',''), 'GARZA, HOMERO /',''), 'GARZA, HOMERO ',''), 'ARZA, HOMERO',''), 'AUSTIN NURSING CENTER INC v. LOVATO _ FindLaw_files', '')
		, 'Austin, Norma C -NE/',''), 'Austin, Norma C -NE',''), 'Carlos Aleman', ''), 'Carlos Gutierrez/',''), 'Carlos Gutierrez',''), 'CLOISNG', 'CLOSING'), 'Crystal Zavala', '') 
		, 'Dalia Salinas  3-24-16',''), 'DAVID GUERRERO/', ''), 'DAVID GUERRERO', ''), 'De Alba, Raquel ( A-C) JP/', ''), 'De Alba, Raquel ( A-C) JP', ''), 'Dr Shwery/', '')
		, 'Dr Shwery', ''),'Dr Shwery(Daniel C. Ramirez', ''), 'Eduardo Sanchez',''), 'Mendoza, Jose Martin /', '') , 'Mendoza, Jose Martin', ''), 'endoza, Jose Martin', '')
		, 'Enrique Urtusastegui',''), 'ERICA EDITH ALONZO',''),'ernandez, Hector',''), 'Gabriel Hernandez', ''), 'Garcia, Elsa & Garcia, Krista ',''), 'Garza, Blanca E. () ES/', '')
		, 'Garza, Blanca E. () ES', ''), 'Garza, Blanca E. () ES/Garza, Blanca E. () Rose/',''), 'Garza, Blanca E. () ES/Garza, Blanca E. () Rose',''), 'Garza, Blanca E. () Rose/', '')
		, 'Garza, Blanca E. () Rose', ''), 'interprter', 'Interpreter'), 'ispe, Jesus', '') , 'James Phillips',''), 'Leticia Francis' ,''), 'LORENZEN, RODNEY 4/', ''), 'LORENZEN, RODNEY /'
		, ''), 'LORENZEN, RODNEY ', ''), 'Marie J. Liedl', ''), 'Mario Echavarria', ''), 'Marroquin , Elizabeth_255655/', ''), 'Marroquin , Elizabeth_255655', '')
		, 'Master File Copy - Copy - Copy - Copy - Copy - Copy - Copy - Copy - Copy - Copy - Copy - Copy - Copy',''), 'Master File Copy - Copy - Copy','' ), 'Master File Copy -', '')
		, 'Master File Copy',''), 'MASTER COPY', ''), 'Navarro, Nancy ()ALL/', ''), 'Navarro, Nancy ()ALL', ''), 'RODRIGUEZ, GENESIS /', ''), 'RODRIGUEZ, GENESIS ', '')
		, 'ODRIGUEZ, GENESIS',''),'ORENZEN, RODNEY', ''), 'Pam Joselin','') , 'Pena, Jose A., Jr. ()/', ''), 'Pena, Jose A., Jr. ()', ''), 'Perez, Andrew () jp/','')
		, 'Perez, Andrew () jp',''), 'q/','') , 'q',''), 'Rebecca Martinez/',''), 'Reyes, Hugo Enrique', ''), 'Reyes, San Juantia v. Ponchos () JP(RF)/','')
		, 'Reyes, San Juantia v. Ponchos () JP(RF)','') , 'Rios, Joel (EVS)/',''), 'Rios, Joel (EVS)',''), 'RODRIGUEZ, GENESIS ', ''), 'Romeo Villarreal',''), 'Salinas, Ramiro ()Rose/','')
		, 'Salinas, Ramiro ()Rose',''), 'Salvador Delgado',''), 'Sandra Valdez/Sandra L Valdez 27.06.21',''), 'Scannd docs/',''), 'Scannd docs',''), 'Scand docs/',''), 'Scand docs','')
		, 'Scannded docs',''),'Scanned Documents/',''),'Scanned Documents',''), 'Scanned docs/',''), 'Scanned docs',''), 'Scanned Doc/',''), 'Scanned Doc',''), 'Scnd docs/','')
		, 'Scnd docs',''), 'New folder/',''),'New folder',''), 'lexius nexis', 'Lexis Nexis'), 'Reyes, Hugo Enriue/',''), 'Reyes, Hugo Enriue','')
		, 'Copy (34) of Master File Copy - Copy - Copy - Copy - Copy - Copy - Copy - Copy',''), 'OCHOA ALEJANDRO 280531',''), 'RAMIREZ, DANIEL C',''), 'Rebecca Martinez','') as folderpath11
		INTO #Folderpath11
		FROM #folderpath10    -- 8329

IF OBJECT_ID('TEMPDB.dbo.#InsertedFolderpath', 'U') IS NOT NULL
	DROP TABLE #InsertedFolderpath;

	SELECT distinct 
		  original
		, folderpath1 as folderpath
	INTO #InsertedFolderpath
	FROM #Folderpath1
	
	
	--SELECT *
	--FROM #Folderpath1

	INSERT INTO #InsertedFolderpath
	(original, folderpath)
	SELECT distinct   
		  original
		, folderpath2 as folderpath
	FROM #Folderpath2

	INSERT INTO #InsertedFolderpath
	(original, folderpath)
	SELECT distinct   
		  original
		, folderpath3 as folderpath
	FROM #folderpath3

	INSERT INTO #InsertedFolderpath
	(original, folderpath)
	SELECT distinct   
		  original
		, folderpath4 as folderpath
	FROM #folderpath4

	INSERT INTO #InsertedFolderpath
	(original, folderpath)
	SELECT distinct   
		  original
		, folderpath5 as folderpath
	FROM #folderpath5

	INSERT INTO #InsertedFolderpath
	(original, folderpath)
	SELECT distinct   
		  original
		, folderpath6 as folderpath
	FROM #folderpath6

	INSERT INTO #InsertedFolderpath
	(original, folderpath)
	SELECT distinct   
		  original
		, folderpath7 as folderpath
	FROM #folderpath7

	INSERT INTO #InsertedFolderpath
	(original, folderpath)
	SELECT distinct   
		  original
		, folderpath8 as folderpath
	FROM #folderpath8

INSERT INTO #InsertedFolderpath
	(original, folderpath)
	SELECT distinct   
		  original
		, folderpath11 as folderpath
	FROM #folderpath11

	SELECT *
	FROM #InsertedFolderpath
	WHERE folderpath like '%ELIZONDO SILVIA 164019/UROLOGY%'

	--SELECT top 1000 *
	--FROM #DocsToLoad

IF OBJECT_ID('TEMPDB.dbo.#FolderPathAlignment', 'U') IS NOT NULL
	DROP TABLE #FolderPathAlignment;

	SELECt distinct f.*, s.docid
	INTO #FolderPathAlignment
	FROM #InsertedFolderpath f
	INNER JOIN TEMP_CleanDocScan s
	ON f.original = s.folderpath
	where f.folderpath IS NOT NULL

	--SELECT *
	--FROM #FolderPathAlignment

------------------------------------------------- END FOLDERPATH LOGIC --

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
			, f.folderpath  AS	 [DestinationFolderPath]
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
	-- SELECT distinct  count(*)
		FROM TEMP_CleanDocScan s -- 219187
		INNER JOIN TEMP_CleaneSTDocScan s2
			ON s.docid = s2.docid -- 76,821
		INNER JOIN TEMP_CleanerDocScan p
			ON P.DOCID = S.DOCID -- 89,989
		LEFT JOIN #FolderPathAlignment f
			ON p.docid = f.docid
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
		--INNER JOIN #FolderPathAlignment f
		--	ON s.docid = f.docid
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

	-- select * from #DocsToLoad
	-- select * from TEMP_Cleaneralign



			INSERT INTO
		-- select * from 
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
				, CASE
					WHEN [DestinationFolderPath] like '%[0-9][0-9]-[0-9][0-9][0-9]%' 
					 AND [DestinationFolderPath] not like '%/%'
					THEN Null
					WHEN [DestinationFolderPath] like '%[0-9][0-9]-[0-9][0-9][0-9]%/%' 
					THEN right( [DestinationFolderPath], CHARINDEX('/', [DestinationFolderPath]))
					ELSE [DestinationFolderPath]
				  END AS [DestinationFolderPath]
			 --   , [DestinationFolderPath]
				, [UploadDate]
				, [Hashtags]
				, [UploadedByUsername]
				, [SectionSelector]
				, [FieldSelector]
				, [CollectionItemExternalID]
				, [isReload]
		--SELECT count(*)
		FROM 		#DocsToLoad
		 
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
--iguez (BG-12-076)JP/Discovery/Blank Discovery
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
