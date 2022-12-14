                                                                     USE [7831_Oklahoma]
GO
/****** Object:  StoredProcedure [unknown].[usp_insert_staging_NewContacts]    Script Date: 4/14/2021 1:07:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[unknown].[usp_insert_staging_NewContacts]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	--	SELECT 			'[unknown].[usp_insert_staging_NewContacts] has been created in [7831_Oklahoma] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _RepCas_ */
		/*================================================================================================*/
		
	
IF OBJECT_ID('TEMPDB.dbo.#Final', 'U') IS NOT NULL
	DROP TABLE #Final;
select distinct docid
--APPLY 5 LOGIC TO GRAB CLIENT NAME
--,replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'') Name
, replace(folderpath,'filevine-7831/docs/','') FolderPath
,left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))) RootFolder
 ,case when charindex('/',trim(right(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),len(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))-len(left(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),charindex('/',trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))))) )) <> 0
	 then replace(left(trim(right(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),len(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))-len(left(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),charindex('/',trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))))) ),charindex('/',trim(right(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),len(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))-len(left(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),charindex('/',trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))))) ))),'/','')
	 else trim(right(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),len(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))-len(left(trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')),charindex('/',trim(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))))) )
	 end AS clientname
	 INTO #Final
from [dbo].[S3DocScan_Client_Import_Files]
where left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/','')))
in ('PI_Closed_Files/','WCC_Closed_Files/')


--SELECt *
--FROM #final

--SELECt 
--left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/','')))
--from [dbo].[S3DocScan_Client_Import_Files]

--apply 4 logic


INSERT INTO #FINAL 
 
select distinct docid, 
--replace(folderpath,'filevine-7831/docs/','') [folderpath],
replace(left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))), '/','') FolderPath
--APPLY 4 LOGIC TO GRAB CLIENT NAME
,left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))) RootFolder
,REPLACE(CASE WHEN CHARINDEX('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')) <> 0
	 THEN Left(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),''), charindex('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))
	 ELSE replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')
	 END,'/','') ClientName
from [dbo].[S3DocScan_Client_Import_Files]
where left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/','')))
not in ('PI_Closed_Files/','WCC_Closed_Files/','','filevine-7831/')
and len(REPLACE(CASE WHEN CHARINDEX('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')) <> 0
	 THEN Left(replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),''), charindex('/',replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')))
	 ELSE replace(replace(folderpath,'filevine-7831/docs/',''),left(replace(folderpath,'filevine-7831/docs/',''),charindex('/',replace(folderpath,'filevine-7831/docs/',''))),'')
	 END,'/','')) > 1


		INSERT INTO
		-- SELECt * FROM
		-- SELECt COUNT(*) FROM
		--filevinestagingimport.._OklahomaLegalService_Contacts___550060407
		[dbo].[_7831_Oklahoma_RepCas_NewContacts]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__PersonID]
				, [ContactExternalID]
				, [FirstName]
				, [MiddleName]
				, [LastName]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__PersonID]
			, concat_ws('_', replace(CONCAT_WS('_', CONCAT('CON_', TRIM(F.Clientname)), replace(
			CASE
				WHEN SDS.FolderPath like '%PI_%'
				THEN 'PI'
				WHEN SDS.FolderPath not like '%PI_%'
				THEN 'WC'
			  END ,' ', '') ),', ', '')
			  , CASE 
				WHEN SDS.FolderPath like '%PI_Closed_Files%'
				THEN 0
				WHEN SDS.FolderPath not like '%PI_Closed_Files%'
				THEN 1
			  END
			  , F.RootFolder)   [ContactExternalID]
			  --, F.Clientname
			,	CASE
					WHEN TRIM(REPLACE(REVERSE(LEFT(REVERSE(F.Clientname),CHARINDEX(',',REVERSE(F.Clientname)))), ', ', '')) = '' 
					THEN F.Clientname
					ELSE TRIM(REPLACE(REVERSE(LEFT(REVERSE(F.Clientname),CHARINDEX(',',REVERSE(F.Clientname)))), ', ', '')) 
				END AS FirstName
			--,	TRIM(REPLACE(REVERSE(LEFT(REVERSE(CLIENTNAME),CHARINDEX(' ',REVERSE(CLIENTNAME)))), ' ', '')) FirstName
			, null [MiddleName]
			,   trim(replace(left(F.Clientname, CHARINDEX(',', F.Clientname)), ',', '')) LastName
-- SELECT [4].*
		FROM [S3DocScan_Client_Import_Files] SDS
			JOIN #Final F 
				ON SDS.DOCID = F.DOCID -- 2249
			WHERE len(F.clientname) > 1 -- 2212
			and left(F.ClientName, 50) not like	'Pi A-Z' -- 2211



		INSERT INTO
		-- SELECt * FROM
		-- SELECt COUNT(*) FROM
		--filevinestagingimport.._OklahomaLegalService_Contacts___550061259
		[dbo].[_7831_Oklahoma_RepCas_NewContacts]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__PersonID]
				, [ContactExternalID]
				, [FirstName]
				, [MiddleName]
				, [LastName]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__PersonID]
			, concat(md.ContactExternalID, md.first_name)  [ContactExternalID]
			  --, F.Clientname
			, trim(replace(md.first_name, ' 2', '')) FirstName
			, null [MiddleName]
			, trim(md.last_name) LastName
-- SELECT *
		FROM [S3DocScan_Client_Import_Files] SDS
			inner join 			[dbo].[__FV_OklahomaDocsImportPEID2] md
			on sds.sourceS3objectkey = md.sourceS3objectkey 
			where errormessage = 'cannot find matching project for ProjectExternalID'







			--AND F.Clientname NOT IN ('PI_2014','PI_2016','WCC_2020','WCC_2019','WCC_2013', 'PI_2018','PI_2017','PI_2019','WCC_2017','WCC_2018', 'PI_2020')
			--f.folderPath not like '%_Closed_%' -- 250,719
		--	AND len(F.clientname) > 1
			--AND .[4] NOT IN ('PI_2014','PI_2016','WCC_2020','WCC_2019','WCC_2013', 'PI_2018','PI_2017','PI_2019','WCC_2017','WCC_2018', 'PI_2020')


			
			--	order by lastname desc


			--	SELECt --distinct [4]
			--	distinct CASE
			--		WHEN TRIM(REPLACE(REVERSE(LEFT(REVERSE([4].[4]),CHARINDEX(',',REVERSE([4].[4])))), ', ', '')) = '' 
			--		THEN [4].[4]
			--		ELSE TRIM(REPLACE(REVERSE(LEFT(REVERSE([4].[4]),CHARINDEX(',',REVERSE([4].[4])))), ', ', '')) 
			--	END AS FirstName
			----,	TRIM(REPLACE(REVERSE(LEFT(REVERSE(CLIENTNAME),CHARINDEX(' ',REVERSE(CLIENTNAME)))), ' ', '')) FirstName
			--, null [MiddleName]
			--,   trim(replace(left([4].[4], CHARINDEX(',', [4].[4])), ',', '')) LastName
			--, [4].[4]
			--	FROM [S3DocScan_Client_Import_Files] SDS
			--	JOIN #4Final [4] 
			--		ON SDS.DOCID = [4].DOCID
			--	WHERE folderPath not like '%_Closed_%' -- 250,719
			--		AND len([4].[4]) > 1
			--					AND [4].[4] NOT IN ('PI_2014','PI_2016','WCC_2020','WCC_2019','WCC_2013', 'PI_2018','PI_2017','PI_2019','WCC_2017','WCC_2018', 'PI_2020')


			--	[4].[4]

			--	AND concat_ws('_', replace(CONCAT_WS('_', CONCAT('C_', TRIM([4].[4])), replace(
			--CASE
			--	WHEN SDS.FolderPath like '%PI_%'
			--	THEN 'PI'
			--	WHEN SDS.FolderPath not like '%PI_%'
			--	THEN 'WC'
			--  END ,' ', '') ),', ', '')
			--  , CASE 
			--	WHEN SDS.FolderPath like '%PI_Closed_Files%'
			--	THEN 0
			--	WHEN SDS.FolderPath not like '%PI_Closed_Files%'
			--	THEN 1
			--  END)  != 'C_AlvisFernando_WC_1'
			----INNER JOIN dbo.__FV_Clients C
			----	ON SDS.DOCID = C.DOCID
				

--		INSERT INTO
--		filevinestagingimport.._OklahomaTest2_Contacts___550060086
--			(
--				  [__ImportStatus]
--				, [__ImportStatusDate]
--				, [__ErrorMessage]
--				, [__WorkerID]
--				, [__PersonID]
--				, [ContactExternalID]
--				, [FirstName]
--				, [MiddleName]
--				, [LastName]
--			)
--		SELECT DISTINCT
--			  40 [__ImportStatus]
--			, GETDATE() [__ImportStatusDate]
--			, NULL [__ErrorMessage]
--			, NULL [__WorkerID]
--			, NULL [__PersonID]
--			, concat_ws('_', replace(CONCAT_WS('_', CONCAT('C_', TRIM([5].[5])), replace(
--			CASE
--				WHEN SDS.FolderPath like '%PI_%'
--				THEN 'PI'
--				WHEN SDS.FolderPath not like '%PI_%'
--				THEN 'WC'
--			  END ,' ', '') ),', ', '')
--			  , CASE 
--				WHEN SDS.FolderPath like '%PI_Closed_Files%'
--				THEN 0
--				WHEN SDS.FolderPath not like '%PI_Closed_Files%'
--				THEN 1
--			  END)   [ContactExternalID]
--		--	  , [5].[5]
--			,	CASE
--					WHEN TRIM(REPLACE(REVERSE(LEFT(REVERSE([5].[5]),CHARINDEX(',',REVERSE([5].[5])))), ', ', '')) = '' 
--					THEN [5].[5]
--					ELSE TRIM(REPLACE(REVERSE(LEFT(REVERSE([5].[5]),CHARINDEX(',',REVERSE([5].[5])))), ', ', '')) 
--				END AS FirstName
--			--,	TRIM(REPLACE(REVERSE(LEFT(REVERSE(CLIENTNAME),CHARINDEX(' ',REVERSE(CLIENTNAME)))), ' ', '')) FirstName
--			, null [MiddleName]
--			,   trim(replace(left([5].[5], CHARINDEX(',', [5].[5])), ',', '')) LastName
--			, [5]
---- SELECT distinct[5]
--	FROM [S3DocScan_Client_Import_Files] SDS
--		JOIN #5Final [5] 
--					ON SDS.DOCID = [5].DOCID
--			WHERE folderPath like '%_Closed_%' -- 250,719
--			AND len([5].[5]) > 1 -- 1976
--			AND [5].[5] NOT IN ('PI_2014','PI_2016','WCC_2020','WCC_2019','WCC_2013', 'PI_2018','PI_2017','PI_2019','WCC_2017','WCC_2018', 'PI_2020')
--			AND CASE
--					WHEN TRIM(REPLACE(REVERSE(LEFT(REVERSE([5].[5]),CHARINDEX(',',REVERSE([5].[5])))), ', ', '')) = '' 
--					THEN [5].[5]
--					ELSE TRIM(REPLACE(REVERSE(LEFT(REVERSE([5].[5]),CHARINDEX(',',REVERSE([5].[5])))), ', ', '')) 
--				END != ''
--	--where a.CLIENTNAME like 'schwab, Curti%'

		-- have to have first name

		/*

			select *
	from filevinestagingimport.._OklahomaLegalService_Contacts___550056945
	update filevinestagingimport.._OklahomaLegalService_Contacts___550056945
	set __importstatus = 40

		select DISTINCT CLIENTNAME, trim(value) as LastName
	--	, case 
		--	when  CHARINDEX(',', CLIENTNAME) = 0
			--then Len(clientname)
--			else LEFT(replace(clientname,', ', ' '), CHARINDEX(',', CLIENTNAME))
			--end as foistname
		--	 , left(replace(clientname,', ', ' '), CHARINDEX(',', CLIENTNAME)) LastName2
		-- , right(REPLACE(replace(CLIENTNAME,', ',''), LEFT(replace(CLIENTNAME,', ',''), CHARINDEX(',',replace(CLIENTNAME,', ',''))), ''), 15) as FirstName
		 --, TRIM(REPLACE(REVERSE(LEFT(REVERSE(CLIENTNAME),CHARINDEX(',',REVERSE(CLIENTNAME)))), ', ', '')) fname
		--, replace(CLIENTNAME ')
		from __FV_Clients c
		CROSS APPLY string_split(c.CLIENTNAME, ',') CNM
		ORDER BY CLIENTNAME
		--from 

		-- FIRSTNAME
		select DISTINCT TRIM(REPLACE(REVERSE(LEFT(REVERSE(CLIENTNAME),CHARINDEX(',',REVERSE(CLIENTNAME)))), ', ', '')) FirstName
			,  CLIENTNAME
		from __FV_Clients c

		-- FIRSTNAME, LASTNAME
		select DISTINCT 
				TRIM(REPLACE(REVERSE(LEFT(REVERSE(CLIENTNAME),CHARINDEX(',',REVERSE(CLIENTNAME)))), ', ', '')) FirstName
			,   left(replace(clientname,', ', ' '), CHARINDEX(',', CLIENTNAME)) LastName
			,   CLIENTNAME
		from __FV_Clients c
		ORDER BY CLIENTNAME DESC

		-- NO COMMAS
		-- FIRSTNAME, LASTNAME 
		select DISTINCT 
			    CASE 
					WHEN LEN(CLIENTNAME) = 1
					THEN CLIENTNAME
					WHEN CLIENTNAME NOT LIKE '%,%'
					THEN CLIENTNAME
					ELSE TRIM(REPLACE(REVERSE(LEFT(REVERSE(CLIENTNAME),CHARINDEX(' ',REVERSE(CLIENTNAME)))), ' ', '')) 
					END AS FIRSTNAME
			,	TRIM(REPLACE(REVERSE(LEFT(REVERSE(CLIENTNAME),CHARINDEX(' ',REVERSE(CLIENTNAME)))), ' ', '')) FirstName
			,   left(replace(clientname,', ', ' '), CHARINDEX(' ', CLIENTNAME)) LastName
			,   CLIENTNAME
		from __FV_Clients c
		WHERE CLIENTNAME NOT LIKE '%,%'
		ORDER BY CLIENTNAME DESC

		SELECT DISTINCT CLIENTNAME
		from __FV_Clients c
		WHERE CLIENTNAME LIKE '%.%'
		ORDER BY CLIENTNAME DESC


		select DISTINCT CLIENTNAME, REPLACE(value, ' ', '') as LastName
		from __FV_Clients c
		CROSS APPLY string_split(c.CLIENTNAME, ',') CNM

ALTER DATABASE [7831_Oklahoma]
SET COMPATIBILITY_LEVEL = 130

		*/				

	END
														