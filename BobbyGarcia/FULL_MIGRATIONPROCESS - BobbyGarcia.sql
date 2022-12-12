--REPLACE THIS USE <DATABASE>; STATEMENT WITH YOUR CLIENT'S DATABASE NAME
USE [NNNNNNNN_AAAAAAAAA];
GO

/*
USE SANDBOX_DC;
GO

DECLARE 
	@TABLESLIST AS    SCHEMATABLE_TT;


INSERT INTO @TABLESLIST
(
    TABLE_SCHEMA,
    TABLE_NAME
)
VALUES
('dbo','');

EXECUTE SANDBOX_DC.DBO.CLEANALLSPACES_CLR 
	@DEBUGFLAG             = 0,
	@LEGACYDB              = 'AAAAAAAAAAAAAA',
	@CLEANALLTABLESFLAG    = 0,
	@TABLESLIST            = @TABLESLIST;

--REPLACE THIS USE <DATABASE>; STATEMENT WITH YOUR CLIENT'S DATABASE NAME
USE [NNNNNNNN_AAAAAAAAA];
GO
*/
select *
FROM Filevine_META.[dbo].[Legacy_Database]


SELECT *
FROM [Filevine_META].[dbo].[Filevine_Organization]
where orgid like '%6985%'

-- creates tables as existing in legacy db. creates procs if not there and runs as far as it can and gets a count of rows in each table. 
EXECUTE FILEVINE_META.PT1.FULL_MIGRATIONPROCESS 
	@DEBUGFLAG = 0,
	@LEGACYDBTYPE = 'documents',
	@LEGACYDB = '6985_Bobbygarcia',
	@PREVIOUSDB = NULL,
	@ORGID = 6985,
	@SCHEMANAME = 'dbo',
	@FVPRODUCTIONPREFIX = '_BobbyGarciaTest2_', -- _8133_Setareh_RC_ used to do that find and replace. now we have synonym and it updates that to be new prefix. Makes it easier to not track the mispelled prefix etc. easier to write generic templates. 
	@FVPREVIOUSPREFIX = null, -- not needed
	@IMPORTDATABASENAME = 'FilevineStaging2Import', -- have the 2 or not
	@EXECUTIONDB = 'Filevine_META', -- never changed.
	@USEGENERICTEMPLATE = 0,
	@TIMEZONE = 'central';
--	@REFRESHPROCS = 0; -- optional and loaded gun. set to 1, then bad deal, overwrite with empty. 

EXEC FILEVINE_META.QA.USP_VERIFY_IMPORT_LOAD 
	@STAGINGIMPORT = 1,
	@REVIEWDATA = 1,
	@FVDATABASE = 'AAAAAAAAAAAAAA',
	@FVSCHEMA = 'dbo',
	@FVPRODUCTIONPREFIX = 'AAAAAAAAAAAAAA',
	@FVPRODUCTIONDB = 'FilevineStagingImport';

EXEC FILEVINE_META.DBO.USP_LOAD_STAGING_TO_IMPORT 
	@DEBUGFLAG = 0,
	@IMPORTSERVER = 'FilevineStaging2Import',
	@LEGACYDB = '6985_Bobbygarcia',
	@FVPRODUCTIONPREFIX = '_BobbyGarciaTest2_',
	@PEIDLIST = '', -- never used
	@TRUNCATETABLES = 0; -- everybody runs it off (0). won't overwrite and don't want it to, to control what is in there. use delete from on import side tables and continue to run this

	-- Try to not rerun a lot in prod. lose id's that make post migration easier.

			            SELECT               COUNT(*)             , __ImportStatus             FROM              FilevineStagingImport.dbo.[_OklahomaLegalService_Contacts___550056945]            GROUP BY             __ImportStatus            			       								


--UPDATE for Execution Order

UPDATE PT1.VW_LEGACYSP_FULLMIGRATION_EXECORDER
SET 
	EXECUTIONORDER = 1000
WHERE 
	LEGACYDATABASETYPE = 'AAAAAAAAAAAAAA' AND FVPRODPREFIX LIKE '%AAAAAAAAAAAAAA%' AND LEGACYSPNAME IN
	('AAAAAAAAAAAAAA'
	);
--Execution Order

SELECT DISTINCT 
	ORGID,
	FVPRODPREFIX,
	LEGACYDATABASETYPE,
	LEGACYSPNAME,
	EXECUTIONORDER
FROM PT1.VW_LEGACYSP_FULLMIGRATION_EXECORDER
WHERE LEGACYDATABASETYPE = 'AAAAAAAA' AND FVPRODPREFIX LIKE '%AAAAAAAA%'
ORDER BY 
	ORGID,
	EXECUTIONORDER,
	LEGACYSPNAME;
--Standard Procedures

SELECT 
	LD.LG_DB_ID,
	LD.LG_DB_NAME,
	LS.LEGACYSPID AS LG_SP_ID,
	LS.LEGACYSPNAME AS LG_SP_NAME,
	LMAS.SCRIPT_CODE,
	LMAS.ACTIVE
FROM FILEVINE_META.DBO.LEGACY_DATABASE AS LD
INNER JOIN FILEVINE_META.DBO.LEGACY_MASTER_AUTO_SCRIPT AS LMAS
	ON LMAS.LG_DB_ID = LD.LG_DB_ID
INNER JOIN FILEVINE_META.DBO.LEGACYSP AS LS
	ON LS.LEGACYSPID = LMAS.LG_SP_ID
WHERE LG_DB_NAME = 'AAAAAAAA'
ORDER BY 
	LG_DB_ID,
	LG_SP_ID;
--Previous Migration Procedure Body Search

SELECT 
	*
FROM FILEVINE_META.DBO.PRODUCTION_CODE_HISTORY
WHERE SCHEMANAME = 'AAAAAAAA'
--AND OBJECTNAME LIKE '%AAAAAAAA%
--AND COMMANDTEXT LIKE '%AAAAAAAA%'
--Column Name Search

SELECT 
	*
FROM DBO.VW_TABLE_SOURCE_ANALYSIS_MAIN_REPORT AS VTSAMR
WHERE VTSAMR.COLUMN_NAME LIKE '%AAAAAAAA%';
--Field Value Search

SELECT 
	*
FROM DBO.VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT AS VTSAVR
WHERE VTSAVR.FIELD_VALUE LIKE '%AAAAAAAA%';

--DOC SCAN DATA VOLUME

SELECT 
	CONVERT(VARCHAR(MAX),SCANID) AS SCANID,
	SUM(S3OBJECTBYTES) / /*KB*/	1024.0 / /*MB*/	1024.0 / /*GB*/	1024.0 AS SCANNED_GB
FROM S3DOCSCAN
GROUP BY 
	SCANID
UNION
SELECT 
	'ERROR' AS SCANID,
	SUM(SIZE) / /*KB*/	1024.0 / /*MB*/	1024.0 / /*GB*/	1024.0 AS SCANNED_GB
FROM S3DOCSCAN_ERROR;

--ERROR FILES

SELECT 
	ISNULL(ERRORMESSAGE,'Scan application failed to process the file.') AS ERRORMESSAGE,
	SANDBOX_DC.DBO.RELATIVEPATHFROMFIRSTMATCH(BUCKET,'filevine-','/',0
											 ) AS FOLDERPATH,
	FILENAME,
	SIZE AS SIZEBYTES
FROM S3DOCSCAN_ERROR
ORDER BY 
	ERRORMESSAGE,
	FOLDERPATH,
	FILENAME;