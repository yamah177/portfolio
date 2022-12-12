figure out harrell, r



	IF OBJECT_ID('TEMPDB.dbo.#CleanDocScan', 'U') IS NOT NULL
	DROP TABLE dbo.#CleanDocScan;
	SELECT distinct *
		  , replace(replace(left(replace(replace(s.folderpath, 'open_/',''), 'docs/', ''), charindex('/',replace(replace(s.folderpath, 'open_/','') , 'docs/', '') )), '/', ''), '_', '') link
		  , replace(replace(sources3objectkey, 'filevine-5928/open_/', ''), 'filevine-5928/', '') NewCleanSources3objectkey
	INTO #CleanDocScan
	FROM [s3docscan] s -- 94701
	--where FolderPath like '%cathey%'
	--order by sources3objectkey -- 311 rows, good

	IF OBJECT_ID('TEMPDB.dbo.#OldCleanSources3objectkey', 'U') IS NOT NULL
	DROP TABLE TEMPDB.dbo.#OldCleanSources3objectkey;
	SELECT distinct*
		  , replace(sources3objectkey, 'filevine-5928/open_/', '') OldCleanSources3objectkey
	INTO #OldCleanSources3objectkey
	FROM [s3docscan-old] s -- 37592
	--where FolderPath like '%cathey%'
	--order by sources3objectkey -- 122



	IF OBJECT_ID('TEMPDB.dbo.#CleanDocScanNoDupe', 'U') IS NOT NULL
	DROP TABLE dbo.#CleanDocScanNoDupe;
		SELECT  distinct *
			INTO #CleanDocScanNoDupe
		FROM #CleanDocScan -- [5928_Hirji]..S3DOCSCAN s
		--WHERE folderpath LIKE '%CATHEY, S%'
		WHERE link <> ''
		AND NewCleanSources3objectkey  not in
										(SELECT OldCleanSources3objectkey
										 FROM #OldCleanSources3objectkey )

										 SELECT *
FROM [FilevineStagingImport].._HirjiChauTest3a_Documents___550058390
where DestinationFolderPath like '%harrell, R%'

SELECT count(*)
FROM S3DocScan -- 94701

SELECT count(*)
FROM #CleanDocScanNoDupe -- 59533

SELECT *
FROM S3DocScan -- 94701
where folderpath like '%harrell, R%' -- 1279 docs

SELECT *
FROM #CleanDocScanNoDupe -- 59533
where folderpath like '%harrell, R%' -- 1275 docs

SELECt *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%harrell, r%' -- 1275
and __importstatus = 60

SELECt distinct __importstatus
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%harrell, r%' -- 1275
------
-- Cathey, S
SELECT *
FROM S3DocScan -- 94701
where folderpath like '%Cathey, S%' -- 311 docs

SELECT *
FROM #CleanDocScanNoDupe -- 59533
where folderpath like '%Cathey, S%' -- 188 docs

SELECt *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%Cathey, S%' -- 309


SELECt count(*), __ErrorMessage
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%Cathey, S%' -- 309
group by __ErrorMessage -- 21 invalid filenames and 288 went in.


SELECt *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%Cathey, S%' -- 309
and __ImportStatus = 70

SELECt distinct __importstatus
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%Cathey, S%' -- 1275

-- missing couple files

SELECt *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%Cathey, S%' -- 309
and destinationfilename in ('19.09.10-19.11.19 LAS Notes.pdf', '19.09.16-19.11.22 Behavior problems chart.pdf')