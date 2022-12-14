USE [497_Rosette]
GO
/****** Object:  StoredProcedure [documents].[usp_insert_reference_ClientCaseMap]    Script Date: 10/20/2022 11:46:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[documents].[usp_insert_reference_ClientCaseMap]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT '[documents].[usp_insert_reference_ClientCaseMap] has been created in [497_Rosette] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: ALL */
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

-- select distinct client, projectname FROM #final
WHERE nullif(client, '') is not null
and nullif(projectname, '') is not null

SELECT distinct firstlevel
, filevine_meta_test.dbo.[RemoveNumericCharacters](firstLevel)
FROM #tbl
WHERE firstlevel = '1219.1 Dynamic Gaming Solutions'


		INSERT INTO
		-- SELECt * FROM -- delete from
			[dbo].[__FV_ClientCaseMap]
			(
				  [ProjectExternalID]
				, [ContactExternalID]
				, [CaseID]
				, [NameID]
				, [Filevine_ProjectTemplate]
				, [Active]
				, [Archived]
			)
		SELECT DISTINCT
			  left(CONCAT(reverse(projectname), '_', client), 62) [ProjectExternalID]
			, client [ContactExternalID]
			, projectname [CaseID]
			, left(client, 50) [NameID]
			, 'General' [Filevine_ProjectTemplate]
			, NULL [Active]
			, NULL [Archived]
			
	-- SELECT distinct client, projectname
			FROM #final
		WHERE NULLIF(client, '') IS NOT NULL
		AND NULLIF(projectname, '')  IS NOT NULL
		--AND projectname = 'Jicarilla Apache Nation v. U.S'
--Economic Development (1122.1)
--Jicarilla Apache Nation v. U.S
		AND left(CONCAT(reverse(projectname), '_', client), 62)= ')1.2211( tnempoleveD cimonocE_JicarillApache Nation'
		--AND left(CONCAT(left(client, 10), '_', left(reverse(projectname), 52) ), 62)= 'Big Valley_91-DIVOC - RVB 001.528'
	
	END
														