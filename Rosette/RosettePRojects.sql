USE [497_Rosette]
GO
/****** Object:  StoredProcedure [documents].[usp_insert_staging_Projects]    Script Date: 10/20/2022 11:46:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[documents].[usp_insert_staging_Projects]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 	'[documents].[usp_insert_staging_Projects] has been created in [497_Rosette] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _T1_ */
		/*================================================================================================*/
		
		-- Clean
DROP TABLE IF EXISTS  #validfiles;

		SELECt  *
		into #validfiles
		from [dbo].[S3DocScan]
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


DROP TABLE IF EXISTS #tbl;

	SELECT distinct folderpath
		,SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)) firstLevel
		,replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') secondlevelOn
		, SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0)) secondLevel
		, replace(replace('/'+ replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') ,SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 1)) , '') , '//', '')ThirdLEvelOn
		INTO #tbl
		FROM #validfiles
		WHERE folderpath is not null;

		-- BASE
/*
		SELECT distinct folderpath
		,SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)) firstLevel
		,replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') secondlevelOn
		, SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0)) secondLevel
		FROM #validfiles
		WHERE folderpath is not null
		*/


		-- FINISHED QUERY LOGIC
DROP TABLE IF EXISTS #final;
		-- FINISHED QUERY LOGIC
		SELECt distinct
folderpath,
 firstlevel
,secondlevel
,	CASE 
	  WHEN firstLevel like '%.%'
	  THEN TRIM(replace(replace(filevine_meta_test.dbo.[RemoveNumericCharacters](firstLevel), '.', ''), '-',''))
	  WHEN secondLevel like '%.%'
	  AND firstlevel  not  like '%.%'
	  --AND secondlevel not like '%.%'
	  THEN TRIM(replace(replace(replace(filevine_meta_test.dbo.[RemoveNumericCharacters](firstLevel), '.', ''), '-',''), 'a ', ''))
	  ELSE replace(firstlevel, '%[-()0-9]%', '')
	END AS client
  , CASE 
	  WHEN firstLevel like '%.%'
	  THEN firstLevel 
	  WHEN firstLevel not like '%.%'
	  AND nullif(secondlevel, '') is not null
	  AND secondLevel like '%.%'
	  THEN secondLevel 
	  ELSE firstlevel
	END AS projectname
	INTO #final
FROM #tbl

		INSERT INTO
		-- SELECt * FROM -- delete from
			[PT1].[Projects]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__ProjectID]
				, [ProjectExternalID]
				, [ContactExternalID]
				, [ProjectName]
				, [ProjectTemplate]
				, [IncidentDate]
				, [IncidentDescription]
				, [IsArchived]
				, [PhaseName]
				, [PhaseDate]
				, [Hashtags]
				, [Username]
				, [CreateDate]
				, [ProjectNumber]
				, [ProjectEmailPrefix]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__ProjectID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, ccm.ContactExternalID [ContactExternalID]
			, c.projectname [ProjectName]
			, 'General' [ProjectTemplate]
			, NULL [IncidentDate]
			, NULL [IncidentDescription]
			, NULL [IsArchived]
			, NULL [PhaseName]
			, NULL [PhaseDate]
			, NULL [Hashtags]
			, 'sfunke' [Username]
			, [Filevine_META].dbo.udfDate_ConvertUTC(GETDATE(), 'eastern' , 1) [CreateDate]
			, NULL [ProjectNumber]
			, NULL [ProjectEmailPrefix]
	-- SELECT *
		FROM __FV_ClientCaseMap ccm
		JOIN #final c
		ON ccm.contactexternalid = c.client
		AND ccm.[CaseID] = c.projectname
		--WHERE ccm.ProjectExternalID = ')1.2211( tnempoleveD cimonocE_JicarillApache Nation'
					


	END
														