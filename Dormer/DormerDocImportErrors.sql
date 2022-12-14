USE [7530_DormerHarpring_GL]
GO
/****** Object:  StoredProcedure [dbo].[usp_insert_staging_NewDocuments]    Script Date: 3/3/2021 9:54:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[dbo].[usp_insert_staging_NewDocuments]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	
	IF OBJECT_ID('TEMPDB.dbo.#TEMPS3', 'U') IS NOT NULL
	DROP TABLE #TEMPS3
	SELECT CONCAT('filevine-7530/Doc/',LEFT(REPLACE(S.FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(S.FOLDERPATH,'filevine-7530/Doc/','')))) link
	, REPLACE(FOLDERPATH,CONCAT('filevine-7530/Doc/',LEFT(REPLACE(FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(FOLDERPATH,'filevine-7530/Doc/','')))),'') [DestinationFolderPath]
	,* 
	INTO #TEMPS3 
	-- SELECt COUNT(*)
	FROM S3DocScan S -- 192,271

		INSERT INTO 
		Filevineproductionimport.._DormerHarpringLLC_Documents___56532
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
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, CONCAT_WS('_','DOC',P.ProjectExternalID,S.DOCID) [DocExternalID] -- uniqueID for doc.
			, P.ProjectExternalID [ProjectExternalID]
			, NULL [FilevineProjectID]  -- internal id when we create a project or client creates a new one from front end.
			, NULL [NoteExternalID] -- can take docs and attach to sections or notes. don't need section, etc.
			, S.[SourceS3Bucket] [SourceS3Bucket] -- straight from s3docscan to copy in
			, S.[SourceS3ObjectKey] [SourceS3ObjectKey] -- straight from s3docscan to copy in
			, S.SourceS3ObjectKeyEncoded [SourceS3ObjectKeyEncoded] --in case there are special chars. tries object key first then this and then fails.
			, S.[FILECOMPLETE] [DestinationFileName]
			, s.[DestinationFolderPath] [DestinationFolderPath]
			, GETDATE() [UploadDate]
			, NULL [Hashtags]
			, 'kch' [UploadedByUsername] -- Need
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload] -- 0 or null is first. 1 is it already exists and has a change. 1 does updates.
-- SELECt *
 	FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] P
		LEFT JOIN #TEMPS3 S 
			ON P.[S3 Folder Path] = s.link
		LEFT JOIN [__FV_PROJECTSNew] PN
			ON s.link = pn.folderpath
		WHERE ISNULL(S.FILEEXT,'') <> ''
		AND p.[S3 Folder Path] IN (
									SELECT [S3 Folder Path]
									FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS]
									GROUP BY [S3 Folder Path]
									HAVING COUNT(*) = 1
									)
		AND p.[S3 Folder Path] <> '#N/A'

		-- inserted 88,603


		/* second insert */
				INSERT INTO 
			Filevineproductionimport.._DormerHarpringLLC_Documents___56532
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
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__DocID]
			, CONCAT_WS('_','DOC',P.[ProjectExternalID],S.DOCID) [DocExternalID] -- uniqueID for doc.
			, P.ProjectExternalID [ProjectExternalID]
			, NULL [FilevineProjectID]  -- internal id when we create a project or client creates a new one from front end.  ProjectName???????????????????????????????????
			, NULL [NoteExternalID] -- can take docs and attach to sections or notes. don't need section, etc.
			, S.[SourceS3Bucket] [SourceS3Bucket] -- straight from s3docscan to copy in
			, S.[SourceS3ObjectKey] [SourceS3ObjectKey] -- straight from s3docscan to copy in
			, S.SourceS3ObjectKeyEncoded [SourceS3ObjectKeyEncoded] --in case there are special chars. tries object key first then this and then fails.
			, S.[FILECOMPLETE] [DestinationFileName]
			, s.[DestinationFolderPath] [DestinationFolderPath]
			, GETDATE() [UploadDate]
			, NULL [Hashtags]
			, 'kch' [UploadedByUsername]
			, NULL [SectionSelector]
			, NULL [FieldSelector]
			, NULL [CollectionItemExternalID]
			, NULL [isReload] -- 0 or null is first. 1 is it already exists and has a change. 1 does updates.
-- SELECT *
 	FROM [__FV_PROJECTSNew] P
		LEFT JOIN #TEMPS3 S 
			ON P.FolderPath = s.link
		WHERE ISNULL(S.FILEEXT,'') <> ''
		AND p.FolderPath <> '#N/A'

		-- 12,858 records inserted
		-- 101,461 total

		SELECT *
		FROM
		(

		SELECT LEFT(destinationFolderPath,CHARINDEX('/',destinationFolderPath + '/')-1) AS name1
		, p.[Name (Last, First)] name2
		, destinationFolderPath
		, d.*
		FROM Filevineproductionimport.._DormerHarpringLLC_Documents___56532 d
			LEFT JOIN [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] p
			ON LEFT(d.destinationFolderPath,CHARINDEX('/',d.destinationFolderPath + '/')-1) = p.[Name (Last, First)]
			) a
			--WHERE a.name1 = a.name2 -- 70,763
			WHERE a.name2 <> a.name1 -- 70,763

			SELECT *
			FROM 			[7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] 
			WHERE ProjectExternalID = 1158157474


			SELECT *
			FROM 			[7530_DormerHarpring_GL].[dbo].[__FV_PROJECTSNew] 
			WHERE ProjectExternalID = 1158157474


			-- This is fine, not a problem. put it in excel. failed docs. explanation. different sheets per error. send to Nicole Alder/
			SELECT d.__importStatus, d.__ErrorMessage, d.DestinationFileName, d.*
			FROM Filevineproductionimport.._DormerHarpringLLC_Documents___56532  D
			where __importStatus = 70 and d.__ErrorMessage  = 'invalid filename' -- 119
			and d.DestinationFileName not like '~%' -- takes it down to 97
			and d.DestinationFileName not like '%.db' -- takes it down to 7
			and d.DestinationFileName not like '%.ini' 
			and d.DestinationFileName not like '%.tmp'
			and d.DestinationFileName not like '%.DS%' 
			Order by d.__ErrorMessage 

			-- file not found usually odd chars in file name or folder path. fixing as we find them. identify what char is causing the error
			SELECT --d.__importStatus, d.__ErrorMessage, d.DestinationFileName,
			d.*
			FROM Filevineproductionimport.._DormerHarpringLLC_Documents___56532  D
			where __importStatus = 70 
			and d.__ErrorMessage  = 's3 file not found'
			--AND d.DestinationFileName not like '%+%'


			SELECT d.__importStatus, d.__ErrorMessage, d.DestinationFileName, d.*
			FROM Filevineproductionimport.._DormerHarpringLLC_Documents___56532  D
			where __errormessage  like '%file not found%'
			and destinationFileName not like '%.h'

			-- Error Getting FolderID. ./ is the issue.
			SELECT d.__importStatus, d.__ErrorMessage, d.DestinationFileName, d.destinationFolderPath, d.*
			FROM Filevineproductionimport.._DormerHarpringLLC_Documents___56532  D
			where __errormessage  like 'Error Getting FolderID' -- 27 -- takes  out 2
			and d.destinationFolderPath not like '%!%'-- takes  out 2

			SELECT distinct  d.destinationFolderPath
			FROM Filevineproductionimport.._DormerHarpringLLC_Documents___56532  D
			where __errormessage  like 'Error Getting FolderID' -- 27 -- takes  out 2
			and d.destinationFolderPath not like '%!%'-- takes  out 2

			these bad folder paths?:
Anderson, T.J./Communication/Client/2019 02 18 from Cl encl Dog Attack Folder/Dog Attack Medical Records
Anderson, T.J./Communication/Client/2019 02 18 from Cl encl Dog Attack Folder/Pictures from Incident
Anderson, T.J./Communication/Client/2019 02 18 from Cl encl Dog Attack Folder/Receipts from Dog Attack
Anderson, T.J./Communication/Employers and Wage Data
Anderson, T.J./Communication/Farmers Ins. (Meredith Park Condos)
Anderson, T.J./Communication/Investigation
Anderson, T.J./Communication/Medical
Anderson, T.J./Pleadings
Anderson, T.J./Pleadings/Final Drafts
Romero, Phillip-Pro Bono/Communication/Medical/2020 05 18 from Ortho & Spine Ctr of Rockies encl CD of Images-Romero, P./IHE_PDI/000/000/001/582/1643/3072
Romero, Phillip-Pro Bono/Communication/Medical/2020 05 18 from Ortho & Spine Ctr of Rockies encl CD of Images-Romero, P./IHE_PDI/000/000/001/582/1643/3073
Romero, Phillip-Pro Bono/Communication/Medical/2020 05 18 from Ortho & Spine Ctr of Rockies encl CD of Images-Romero, P./IHE_PDI/REPORTS
Romero, Phillip-Pro Bono/Communication/Medical/2020 05 18 from Ortho & Spine Ctr of Rockies encl CD of Images-Romero, P./IHE_PDI/RESOURCE/IMAGES
Romero, Phillip-Pro Bono/Communication/Medical/2020 05 18 from Ortho & Spine Ctr of Rockies encl CD of Images-Romero, P./MPT
			

			SELECT count(*), d.__ErrorMessage
			FROM Filevineproductionimport.._DormerHarpringLLC_Documents___56532  D
			where __importStatus = 70
			GROUP by d.__ErrorMessage 
			order by count(*) desc

SELECT distinct  d.*
			FROM Filevineproductionimport.._DormerHarpringLLC_Documents___56532  D
			where __errormessage  like 's3 file size limit exceeded%'


/*
1785	invalid file extension -- .dll, .exe, .js, .bat, .msi
There were 320 with	s3 file not found  -- mostly files that end in .h, but a few that end in  pdf, msg, xlsx. Might want to check on these.
119	invalid filename -- .db, .ini, temp files, 
27	error getting folderID -- .JPG, GIF, EXE, CAB, PDF, WAV, XLSX, DOC.... THIS ONE i'M NOT SURE OF.
1	s3 file size limit exceeded: 7900835316 bytes
1	s3 file size limit exceeded: 9248610282 bytes
1	s3 file size limit exceeded: 9250441831 bytes



----------------- 3 large files. two mp4's and a zip
1510 Kenya Jenkins 12-2-20.mp4
Andersen Expert File.zip
2021 01 14 Stroud Depo-VIDEO.mp4

DOC_1213799659_S3DOC_49974
DOC_1050768226_S3DOC_113288
DOC_1050768226_S3DOC_102274

Maguire, Virginia-Bowman & Chamberlain CC/Discovery/Depos/2020 12 02 Chanson & Perlmutter 30b6
Moreno, Victor/Discovery/Disclosures/2021 02 03 Def 2nd Supp a2
Moreno, Victor/Discovery/Depos/2021 01 14 David Stroud    
*/


			SELECT 
		, p.[Name (Last, First)] name2
		, destinationFolderPath
		FROM Filevineproductionimport.._DormerHarpringLLC_Documents___56532 d
			LEFT JOIN [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] p
			ON LEFT(d.destinationFolderPath,CHARINDEX('/',d.destinationFolderPath + '/')-1) = p.[Name (Last, First)]
		
			

		
		--Elliott, Emily/Communication/BI
		/*
		SELECT *
		FROM #TEMPS3
		WHERE link like '%Hall%'
		









		SELECt pn.*
 	FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] P -- 
		LEFT JOIN #TEMPS3 S -- all docs
			ON P.[S3 Folder Path] = s.link
		LEFT JOIN [__FV_PROJECTSNew] PN -- hope's 26
			ON s.link = pn.folderpath
		WHERE ISNULL(S.FILEEXT,'') <> ''
		AND p.[S3 Folder Path] IN (
									SELECT [S3 Folder Path]
									FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS]
									GROUP BY [S3 Folder Path]
									HAVING COUNT(*) = 1
									)
		AND p.[S3 Folder Path] <> '#N/A'
	


		SELECt COUNT(*)
 	FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS] P
		LEFT JOIN [7530_DormerHarpring_GL].[dbo].[__FV_Projects_Active] PA
			ON P.projectExternalID = PA.ProjectExternalID
		LEFT JOIN #TEMPS3 S 
			ON P.[S3 Folder Path] = s.link
		LEFT JOIN [__FV_PROJECTSNew] PN
			ON s.link = pn.folderpath
		WHERE ISNULL(S.FILEEXT,'') <> ''
		AND p.[S3 Folder Path] IN (
									SELECT [S3 Folder Path]
									FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS]
									GROUP BY [S3 Folder Path]
									HAVING COUNT(*) = 1
									)
		AND p.[S3 Folder Path] <> '#N/A'








SELECT *
FROM [7530_DormerHarpring_R2].[dbo].[__FV_PROJECTS]

		--AND CONCAT_WS('_','DOC',P.[Project Number],S.DOCID) NOT IN  (
		--															SELECT DocExternalID
		--															FROM filevinestagingimport.._DormerHarpringTEST2_NewDocuments___550052341
		--															)



		SELECT distinct destinationfilename, __errormessage, destinationFolderPath
		FROM filevinestagingimport.._DormerHarpringTEST2_NewDocuments___550052341
		WHERE __ImportStatus = 70 --replace tilda?
		and destinationfilename not like '%.dll'
		and destinationfilename not like '%.js'
		and destinationfilename not like '%.exe'
		and destinationfilename not like '%.bat'
		and destinationfilename not like '%.tmp'
		and destinationfilename not like '%.ico'
		and destinationfilename not like '%.gif'
		and destinationfilename not like '%.HTM'
		and destinationfilename not like '%.h'
		and destinationfilename not like '%.ds_store'
		and destinationfilename not like '%.msi'
		and destinationfilename not like '%.cab'
		and destinationfilename not like '%.cmd'
		and destinationfilename not like '%.db'
		and destinationfilename not like '%.ini'
		and destinationfilename not like '%.dmg'
		and destinationfilename not like '~%'
		and destinationfilename not like '%.ocx'
		and destinationfilename not like '%.inf'


		SELECT distinct destinationfilename
		FROM filevinestagingimport.._DormerHarpringTEST2_NewDocuments___550052341
		WHERE __ImportStatus = 70 --replace tilda?

		SELECT *
		FROM filevinestagingimport.._DormerHarpringTEST2_NewDocuments___550052341
		
		--REP 1 1181365339
		--REP 2 1043357811

	SELECT *
	FROM [dbo].[__FV_PROJECTS] P
		JOIN [dbo].[S3DocScan] S 
		ON P.[S3 Folder Path] = CONCAT('filevine-7530/Doc/',LEFT(REPLACE(S.FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(S.FOLDERPATH,'filevine-7530/Doc/',''))))
		WHERE ISNULL(S.FILEEXT,'') <> ''

		SELECT s.FolderPath, CONCAT('filevine-7530/Doc/',LEFT(REPLACE(S.FOLDERPATH,'filevine-7530/Doc/',''),CHARINDEX('/',REPLACE(S.FOLDERPATH,'filevine-7530/Doc/','')))) folderpath2

		SELECT *
		FROM [dbo].[S3DocScan] s
		WHERE folderpath like '%Sandifer%' --, Javier

		*/
	END
														