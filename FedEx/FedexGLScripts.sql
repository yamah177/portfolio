USE [7119_FedEx_II_GL]
GO
/****** Object:  StoredProcedure [filevine].[usp_generate_ContactCustomViews]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [filevine].[usp_generate_ContactCustomViews]
	@DEBUGFLAG             BIT,
	@DATABASE              VARCHAR(1000),
	@SCHEMANAME            VARCHAR(1000),
	@FVPRODUCTIONPREFIX    VARCHAR(1000),
	@TIMEZONE              VARCHAR(1000)
AS
BEGIN
	--DECLARE @DEBUGFLAG    BIT = 1;
	/*#VIEWCONFIG: Contains the configuration values used to dynamically build sql scripts that create views for each Custom Contacts Tab*/

	IF OBJECT_ID('tempdb.dbo.#VIEWCONFIG') IS NOT NULL
	BEGIN
		DROP TABLE #VIEWCONFIG;
	END;

	CREATE TABLE #VIEWCONFIG
	(
		TAB				 NVARCHAR(MAX) NOT NULL,
		VIEWNAME         NVARCHAR(MAX) NOT NULL,
		VIEWHEADER       NVARCHAR(MAX) NOT NULL,
		FIELDID          BIGINT NOT NULL,
		FIELDPOSITION    NVARCHAR(MAX) NOT NULL,
		FIELDSELECTOR    NVARCHAR(MAX) NOT NULL,
		DATATYPE         NVARCHAR(MAX) NOT NULL
	);

	INSERT INTO #VIEWCONFIG
	(
		TAB,
		VIEWNAME,
		VIEWHEADER,
		FIELDID,
		FIELDPOSITION,
		FIELDSELECTOR,
		DATATYPE
	)
	SELECT DISTINCT 
		CF.TAB,
		QUOTENAME('dbo') + '.' + QUOTENAME('vw_CT_' + CF.TAB) AS VIEWNAME,
		'CREATE OR ALTER VIEW ' + QUOTENAME('dbo') + '.' + QUOTENAME('vw_CT_' + CF.TAB) + ' AS ' AS VIEWHEADER,
		CF.FIELDID,
		CF.FIELDPOSITION,
		CF.FIELDSELECTOR,
		CF.DATATYPE
	FROM DBO.__FV_CONTACTCUSTOMFIELDMETADATA AS CF;

	IF @DEBUGFLAG = 1
	BEGIN
		SELECT 
			TAB,
			VIEWNAME,
			VIEWHEADER,
			FIELDID,
			FIELDPOSITION,
			FIELDSELECTOR,
			DATATYPE
		FROM #VIEWCONFIG;
	END;

	/*#TABVIEWS: Contains the dynamically built view creation sql scripts*/

	IF OBJECT_ID('tempdb.dbo.#TABVIEWS') IS NOT NULL
	BEGIN
		DROP TABLE #TABVIEWS;
	END;

	CREATE TABLE #TABVIEWS
	(
		VIEWNAME      NVARCHAR(MAX) NOT NULL,
		FIELDCOUNT    INT NULL,
		SQLTEXT       NVARCHAR(MAX) NULL
	);

	DECLARE 
		@TAB			 NVARCHAR(MAX) = N'',
		@VIEWNAME        NVARCHAR(MAX) = N'',
		@VIEWSQL         NVARCHAR(MAX) = N'',
		@NEWLINE         NVARCHAR(MAX) = CHAR(13) + CHAR(10);

	DECLARE CURSOR_TABS CURSOR
	FOR SELECT DISTINCT 
			TAB,
			VIEWNAME,
			VIEWHEADER
		FROM #VIEWCONFIG
		ORDER BY 
			TAB;

	OPEN CURSOR_TABS;

	FETCH NEXT FROM CURSOR_TABS INTO 
		@TAB,
		@VIEWNAME,
		@VIEWSQL;

	WHILE @@FETCH_STATUS = 0
	BEGIN

		DECLARE 
			@QUERYSQL           NVARCHAR(MAX) = N'',
			@COLUMNS_SEL_GRP    NVARCHAR(MAX) = N'',
			@COLUMNS_SEL_PVT    NVARCHAR(MAX) = N'',
			@FIELDCOUNT         INT           = 0;

		SELECT 
			@FIELDCOUNT = COUNT(VC.FIELDID)
		FROM #VIEWCONFIG AS VC
		WHERE VC.TAB = @TAB;

		SELECT 
			@COLUMNS_SEL_PVT = STUFF(
			(
				SELECT TOP 4096/*MAX # OF TABLE COLUMNS IN SQL SERVER*/
					CHAR(13) + CHAR(10) + ',' + CONVERT(VARCHAR(MAX),
																   CASE
																	   WHEN VC.DATATYPE = 'BIT'
																		   THEN 'CONVERT(' + VC.DATATYPE + ', MAX(IIF(CCFM.[FIELDSELECTOR] = ''' + VC.FIELDSELECTOR + ''', CASE CCFM.[VALUE] WHEN ''1'' THEN 1 WHEN ''0'' THEN 0 END, NULL))) AS ' + QUOTENAME(VC.FIELDSELECTOR)
																	   ELSE 'MAX(IIF(CCFM.[FIELDSELECTOR] = ''' + VC.FIELDSELECTOR + ''', CONVERT(' + VC.DATATYPE + ',CCFM.[VALUE]), NULL)) AS ' + QUOTENAME(VC.FIELDSELECTOR)
																   END)
				FROM #VIEWCONFIG AS VC
				WHERE VC.TAB = @TAB
				ORDER BY 
					VC.FIELDPOSITION,
					VC.FIELDID FOR
				XML PATH(''),TYPE
			).value('.','nvarchar(max)'
			   ),1,0,'')
		FROM #VIEWCONFIG AS CONFIG
		WHERE CONFIG.TAB = @TAB;

		IF @FIELDCOUNT > 0
		BEGIN

			SET @QUERYSQL = @NEWLINE + @NEWLINE 
						   + 'SELECT' + @NEWLINE
						   + 'C.[ContactCustomExternalID] AS [ContactCustomExternalID]' + @COLUMNS_SEL_PVT + @NEWLINE
						   + 'FROM [PT1].[ContactsCustom__ContactInfo] AS C' + @NEWLINE
						   + 'INNER JOIN [dbo].[__FV_ContactCustomFieldMetadata] AS CCFM' + @NEWLINE
						   + 'ON CCFM.[PersonID] = C.[ContactCustomExternalID]' + @NEWLINE
						   + 'WHERE CCFM.[Tab] = ''' + @TAB + '''' + @NEWLINE
						   + 'GROUP BY' + @NEWLINE
						   + 'C.[ContactCustomExternalID]' + ';';
		END;

		IF NULLIF(@QUERYSQL,'') IS NULL
		BEGIN
			SET @QUERYSQL = @NEWLINE + @NEWLINE 
							+ 'SELECT' + @NEWLINE
							+ @VIEWNAME + ' has been created.  No data for this tab was found in the database.'' AS [EMPTYVIEWMESSAGE];';
		END;

		SET @VIEWSQL+=@QUERYSQL + @NEWLINE;

		INSERT INTO #TABVIEWS
		(
			VIEWNAME,
			FIELDCOUNT,
			SQLTEXT
		)
		SELECT 
			@VIEWNAME,
			@FIELDCOUNT,
			@VIEWSQL;
			
		EXEC SP_EXECUTESQL 
			@VIEWSQL;

		PRINT @VIEWNAME + ' has been created.';

		FETCH NEXT FROM CURSOR_TABS INTO 
			@TAB,
			@VIEWNAME,
			@VIEWSQL;
	END;

	CLOSE CURSOR_TABS;

	DEALLOCATE CURSOR_TABS;

	IF @DEBUGFLAG = 1
	BEGIN
		SELECT 
			VIEWNAME,
			FIELDCOUNT,
			SQLTEXT
		FROM #TABVIEWS;
	END;
END;
GO
/****** Object:  StoredProcedure [filevine].[USP_GENERATE_CUSTOMTEMPLATEPROCEDUREINSERTS]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create       PROCEDURE [filevine].[USP_GENERATE_CUSTOMTEMPLATEPROCEDUREINSERTS] 
	@DEBUGFLAG             BIT,
	@DATABASE              VARCHAR(1000),
	@SCHEMANAME            VARCHAR(1000),
	@FVPRODUCTIONPREFIX    VARCHAR(1000),
	@TIMEZONE              VARCHAR(1000)
AS
BEGIN
	WITH TABLE_VIEW_MAP
		 AS (SELECT 
				 TABLESPTYPE,
				 TEMPLATETYPE,
				 SYNONYMNAME,
				 QUOTENAME(LEGACYSCHEMA) + '.' + QUOTENAME(LEGACYSPNAME) AS PROCEDURENAME,
				 QUOTENAME('PT1') + '.' + QUOTENAME(SYNONYMNAME) AS SYNONYMTABLENAME,
				 CASE
					 WHEN TABLESPTYPE = 'Staging' AND TEMPLATETYPE = '__' AND SYNONYMNAME LIKE '%[_]NC[_]%'
						 THEN 'PROJECT'
					 WHEN TABLESPTYPE = 'Staging' AND TEMPLATETYPE = '__' AND SYNONYMNAME LIKE '%[_]CL[_]%'
						 THEN 'PROJECT'
					 WHEN TABLESPTYPE = 'Staging' AND TEMPLATETYPE = '_ContactsCustom_' AND SYNONYMNAME LIKE '%[_]CustomFields[_]%'
						 THEN 'CONTACT'
				 END AS CUSTOMTEMPLATETYPE,
				 LEFT(SYNONYMNAME,CHARINDEX('_',SYNONYMNAME) - 1) AS PROJECTTYPE,
				 TABLESPTYPENAME AS SECTION,
				 CONVERT(INT,DESTINATIONORDPOS) AS COLUMNORDER,
				 COLUMNALIAS AS STAGINGTABLE_COLUMNNAME,
				 C.IS_IDENTITY,
				 REPLACE(COLUMNALIAS,ISNULL(CASE
												WHEN COLUMNALIAS LIKE '%CONTACTEXTERNALIDCSV%'
													THEN 'CONTACTEXTERNALIDCSV'
												WHEN COLUMNALIAS LIKE '%CONTACTEXTERNALID%'
													THEN 'CONTACTEXTERNALID'
												WHEN COLUMNALIAS LIKE '%DOCEXTERNALIDCSV%'
													THEN 'DOCEXTERNALIDCSV'
												WHEN COLUMNALIAS LIKE '%DOCEXTERNALID%'
													THEN 'DOCEXTERNALID'
											END,''),'') AS TEMPLATEVIEW_COLUMNNAME_COMPUTED,
				 IIF(COLUMNALIAS LIKE '[_][_]%',ISNULL(LEGACYOVERRIDE,'NULL'),NULL) AS IMPORTCOLUMNOVERRIDEVALUE
			 FROM [PT1].[TempSPMap__FedexB_Test2_] AS TSM
			 INNER JOIN SYS.COLUMNS AS C
				 ON C.OBJECT_ID = OBJECT_ID('dbo.' + TSM.TABLENAME) AND C.NAME = TSM.COLUMNALIAS
			 /*Excluding IDENTITY __ID fields*/
			 WHERE C.IS_IDENTITY = 0
				   /*Excluding Reference tables*/
				   AND TSM.TABLESPTYPE <> 'Reference'
				   /*Excluding Standard tables*/
				   AND TSM.TEMPLATETYPE <> 'ALL'
				   /*Excluding Custom Contacts ContactInfo table*/
				   AND TSM.SYNONYMNAME <> 'ContactsCustom__ContactInfo'),
		 INSERT_BUILDER_MAP
		 AS (SELECT 
				 TVM.TABLESPTYPE,
				 TVM.TEMPLATETYPE,
				 TVM.SYNONYMNAME,
				 TVM.PROCEDURENAME,
				 TVM.SYNONYMTABLENAME,
				 TVM.CUSTOMTEMPLATETYPE,
				 TVM.PROJECTTYPE,
				 TVM.SECTION,
				 TVM.COLUMNORDER,
				 TVM.STAGINGTABLE_COLUMNNAME,
				 TVM.IS_IDENTITY,
				 'vw_' + CASE
							 WHEN TVM.CUSTOMTEMPLATETYPE = 'PROJECT'
								 THEN 'PT_' + TVM.PROJECTTYPE + '_' + TVM.SECTION
							 WHEN CUSTOMTEMPLATETYPE = 'CONTACT'
								 THEN 'CT_' + TVM.SECTION
						 END AS TEMPLATEVIEW_NAME_COMPUTED,
				 QUOTENAME(S.NAME) + '.' + QUOTENAME(V.NAME) AS TEMPLATEVIEW_NAME_ACTUAL,
				 TVM.TEMPLATEVIEW_COLUMNNAME_COMPUTED,
				 VC.NAME AS TEMPLATEVIEW_COLUMNNAME_ACTUAL,
				 CASE
					 WHEN TVM.STAGINGTABLE_COLUMNNAME = '__ID'
						 THEN 'ROW_NUMBER() OVER (ORDER BY NEWID())'
					 ELSE TVM.IMPORTCOLUMNOVERRIDEVALUE
				 END AS IMPORTCOLUMNOVERRIDEVALUE
			 FROM TABLE_VIEW_MAP AS TVM
			 INNER JOIN SYS.VIEWS AS V
				 ON V.NAME = 'vw_' + CASE
										 WHEN TVM.CUSTOMTEMPLATETYPE = 'PROJECT'
											 THEN 'PT_' + TVM.PROJECTTYPE + '_' + TVM.SECTION
										 WHEN CUSTOMTEMPLATETYPE = 'CONTACT'
											 THEN 'CT_' + TVM.SECTION
									 END
			 INNER JOIN SYS.SCHEMAS AS S
				 ON S.SCHEMA_ID = V.SCHEMA_ID
			 LEFT JOIN SYS.COLUMNS AS VC
				 ON VC.OBJECT_ID = V.OBJECT_ID AND VC.NAME = TVM.TEMPLATEVIEW_COLUMNNAME_COMPUTED)
		 SELECT DISTINCT 
			 IBM.PROCEDURENAME,
			 IBM.SYNONYMTABLENAME,
			 IBM.TEMPLATEVIEW_NAME_ACTUAL AS VIEWNAME,
			 CHAR(13) + CHAR(10) + 'DELETE FROM ' + IBM.SYNONYMTABLENAME + CHAR(13) + CHAR(10)
			 + 'WHERE 0=0;' + CHAR(13) + CHAR(10)
			 + 'INSERT INTO ' + IBM.SYNONYMTABLENAME + CHAR(13) + CHAR(10)
			 + '(' + CHAR(13) + CHAR(10)
			 + INSERT_COLUMNS.COLUMN_LIST + CHAR(13) + CHAR(10)
			 + ')' + CHAR(13) + CHAR(10)
			 + 'SELECT' + CHAR(13) + CHAR(10)
			 + SELECT_COLUMNS.COLUMN_LIST + CHAR(13) + CHAR(10)
			 + 'FROM ' + IBM.TEMPLATEVIEW_NAME_ACTUAL + ';' AS SCRIPTED_INSERT_SQL
		 FROM INSERT_BUILDER_MAP AS IBM
		 CROSS APPLY
		 (
			 SELECT 
				 STUFF(
			 (
				 SELECT TOP 100 PERCENT 
					 CHAR(13) + CHAR(10) + ',' + QUOTENAME(MAP.STAGINGTABLE_COLUMNNAME)
				 FROM INSERT_BUILDER_MAP AS MAP
				 WHERE MAP.PROCEDURENAME = IBM.PROCEDURENAME AND MAP.SYNONYMTABLENAME = IBM.SYNONYMTABLENAME
				 ORDER BY 
					 COLUMNORDER FOR
				 XML PATH(''),TYPE
			 ).value('.','nvarchar(max)'
					),1,3,'') AS COLUMN_LIST
		 ) AS INSERT_COLUMNS
		 CROSS APPLY
		 (
			 SELECT 
				 STUFF(
			 (
				 SELECT TOP 100 PERCENT 
					 CHAR(13) + CHAR(10) + ',' + COALESCE(
					 /*Override Value*/
					 MAP.IMPORTCOLUMNOVERRIDEVALUE,
					 /*View Column*/
					 QUOTENAME(MAP.TEMPLATEVIEW_COLUMNNAME_ACTUAL),
					 /*NULL*/
					 'NULL') + ' AS ' + QUOTENAME(MAP.STAGINGTABLE_COLUMNNAME)
				 FROM INSERT_BUILDER_MAP AS MAP
				 WHERE MAP.PROCEDURENAME = IBM.PROCEDURENAME AND MAP.SYNONYMTABLENAME = IBM.SYNONYMTABLENAME
				 ORDER BY 
					 COLUMNORDER FOR
				 XML PATH(''),TYPE
			 ).value('.','nvarchar(max)'
					),1,3,'') AS COLUMN_LIST
		 ) AS SELECT_COLUMNS
		 ORDER BY 
			 PROCEDURENAME,
			 SYNONYMTABLENAME,
			 VIEWNAME;
END;
GO
/****** Object:  StoredProcedure [filevine].[usp_generate_ProjectCustomViews]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE       PROCEDURE [filevine].[usp_generate_ProjectCustomViews]
	@DEBUGFLAG             BIT,
	@DATABASE              VARCHAR(1000),
	@SCHEMANAME            VARCHAR(1000),
	@FVPRODUCTIONPREFIX    VARCHAR(1000),
	@TIMEZONE              VARCHAR(1000)
AS
BEGIN
	--DECLARE @DEBUGFLAG    BIT = 1;
	/*#VIEWCONFIG: Contains the configuration values used to dynamically build sql scripts that create views for each ProjectType+Section combination*/

	IF OBJECT_ID('tempdb.dbo.#VIEWCONFIG') IS NOT NULL
	BEGIN
		DROP TABLE #VIEWCONFIG;
	END;

	CREATE TABLE #VIEWCONFIG
	(
		PROJECTTYPE      NVARCHAR(MAX) NOT NULL,
		SECTION          NVARCHAR(MAX) NOT NULL,
		VIEWNAME         NVARCHAR(MAX) NOT NULL,
		VIEWHEADER       NVARCHAR(MAX) NOT NULL,
		ISCOLLECTION     BIT NOT NULL,
		FIELDID          BIGINT NOT NULL,
		FIELDPOSITION    NVARCHAR(MAX) NOT NULL,
		FIELDSELECTOR    NVARCHAR(MAX) NOT NULL,
		DATATYPE         NVARCHAR(MAX) NOT NULL
	);

	INSERT INTO #VIEWCONFIG
	(
		PROJECTTYPE,
		SECTION,
		VIEWNAME,
		VIEWHEADER,
		ISCOLLECTION,
		FIELDID,
		FIELDPOSITION,
		FIELDSELECTOR,
		DATATYPE
	)
	SELECT DISTINCT 
		CF.PROJECTTYPE,
		CF.SECTION,
		QUOTENAME('dbo') + '.' + QUOTENAME('vw_PT_' + CF.PROJECTTYPE + '_' + CF.SECTION) AS VIEWNAME,
		'CREATE OR ALTER VIEW ' + QUOTENAME('dbo') + '.' + QUOTENAME('vw_PT_' + CF.PROJECTTYPE + '_' + CF.SECTION) + ' AS ' AS VIEWHEADER,
		CF.ISCOLLECTION,
		CF.FIELDID,
		CF.FIELDPOSITION,
		CF.FIELDSELECTOR,
		CF.DATATYPE
	FROM DBO.__FV_PROJECTCUSTOMFIELDMETADATA AS CF;

	IF @DEBUGFLAG = 1
	BEGIN
		SELECT 
			PROJECTTYPE,
			SECTION,
			VIEWNAME,
			VIEWHEADER,
			ISCOLLECTION,
			FIELDID,
			FIELDPOSITION,
			FIELDSELECTOR,
			DATATYPE
		FROM #VIEWCONFIG;
	END;

	/*#SECTIONVIEWS: Contains the dynamically built view creation sql scripts*/

	IF OBJECT_ID('tempdb.dbo.#SECTIONVIEWS') IS NOT NULL
	BEGIN
		DROP TABLE #SECTIONVIEWS;
	END;

	CREATE TABLE #SECTIONVIEWS
	(
		VIEWNAME      NVARCHAR(MAX) NOT NULL,
		FIELDCOUNT    INT NULL,
		SQLTEXT       NVARCHAR(MAX) NULL
	);

	DECLARE 
		@PROJECTTYPE     NVARCHAR(MAX) = N'',
		@SECTION         NVARCHAR(MAX) = N'',
		@ISCOLLECTION    BIT           = 0,
		@VIEWNAME        NVARCHAR(MAX) = N'',
		@VIEWSQL         NVARCHAR(MAX) = N'',
		@NEWLINE         NVARCHAR(MAX) = CHAR(13) + CHAR(10);

	DECLARE CURSOR_SECTIONS CURSOR
	FOR SELECT DISTINCT 
			PROJECTTYPE,
			SECTION,
			ISCOLLECTION,
			VIEWNAME,
			VIEWHEADER
		FROM #VIEWCONFIG
		ORDER BY 
			PROJECTTYPE,
			SECTION;

	OPEN CURSOR_SECTIONS;

	FETCH NEXT FROM CURSOR_SECTIONS INTO 
		@PROJECTTYPE,
		@SECTION,
		@ISCOLLECTION,
		@VIEWNAME,
		@VIEWSQL;

	WHILE @@FETCH_STATUS = 0
	BEGIN

		DECLARE 
			@QUERYSQL                   NVARCHAR(MAX) = N'',
			@COLUMNS_SEL_GRP_ALIASED    NVARCHAR(MAX) = N'',
			@COLUMNS_SEL_GRP            NVARCHAR(MAX) = N'',
			@COLUMNS_SEL_PVT            NVARCHAR(MAX) = N'',
			@FIELDCOUNT                 INT           = 0;

		SET @COLUMNS_SEL_GRP_ALIASED = CASE
										   WHEN @ISCOLLECTION = 0
											   THEN 'PCFM.[ProjectID] AS ProjectExternalID'
										   WHEN @ISCOLLECTION = 1
											   THEN 'PCFM.[ProjectID] AS ProjectExternalID' + ',' + @NEWLINE
												+ '''' + @PROJECTTYPE + ''' + ''_'' + ''' + @SECTION + ''' + ''_'' +  PCFM.[CollectionItemGUID] AS CollectionItemExternalID'
									   END;

		SET @COLUMNS_SEL_GRP = CASE
								   WHEN @ISCOLLECTION = 0
									   THEN 'PCFM.[ProjectID]'
								   WHEN @ISCOLLECTION = 1
									   THEN 'PCFM.[ProjectID]' + ',' + @NEWLINE
										+ '''' + @PROJECTTYPE + ''' + ''_'' + ''' + @SECTION + ''' + ''_'' +  PCFM.[CollectionItemGUID]'
							   END;
		SELECT 
			@FIELDCOUNT = COUNT(VC.FIELDID)
		FROM #VIEWCONFIG AS VC
		WHERE VC.PROJECTTYPE = @PROJECTTYPE AND VC.SECTION = @SECTION;

		SELECT 
			@COLUMNS_SEL_PVT = STUFF(
			(
				SELECT TOP 4096/*MAX # OF TABLE COLUMNS IN SQL SERVER*/
					CHAR(13) + CHAR(10) + ',' + CONVERT(VARCHAR(MAX),
																   CASE
																	   WHEN VC.DATATYPE = 'BIT'
																		   THEN 'CONVERT(' + VC.DATATYPE + ', MAX(CASE WHEN PCFM.[FIELDSELECTOR] = ''' + VC.FIELDSELECTOR + ''' THEN IIF(PCFM.[VALUE] = ''1'',1,0) END)) AS ' + QUOTENAME(VC.FIELDSELECTOR)
																	   ELSE 'MAX(CASE WHEN PCFM.[FIELDSELECTOR] = ''' + VC.FIELDSELECTOR + ''' THEN CONVERT(' + VC.DATATYPE + ',PCFM.[VALUE]) END) AS ' + QUOTENAME(VC.FIELDSELECTOR)
																   END)
				FROM #VIEWCONFIG AS VC
				WHERE VC.PROJECTTYPE = @PROJECTTYPE AND VC.SECTION = @SECTION
				ORDER BY 
					VC.FIELDPOSITION,
					VC.FIELDID FOR
				XML PATH(''),TYPE
			).value('.','nvarchar(max)'
			   ),1,0,'')
		FROM #VIEWCONFIG AS CONFIG
		WHERE CONFIG.PROJECTTYPE = @PROJECTTYPE AND CONFIG.SECTION = @SECTION;

		IF @FIELDCOUNT > 0
		BEGIN

			SET @QUERYSQL += @NEWLINE + @NEWLINE 
						   + 'SELECT' + @NEWLINE
						   + @COLUMNS_SEL_GRP_ALIASED + @COLUMNS_SEL_PVT + @NEWLINE
						   + 'FROM [dbo].[__FV_ClientCaseMap] AS CCM' + @NEWLINE
						   + 'INNER JOIN [DBO].[__FV_ProjectCustomFieldMetadata] AS PCFM' + @NEWLINE
						   + 'ON PCFM.[ProjectID] = CCM.[ProjectExternalID]' + @NEWLINE
						   + 'WHERE PCFM.[ProjectType] = ''' + @PROJECTTYPE + '''' + @NEWLINE
						   + 'AND PCFM.[Section] = ''' + @SECTION + '''' + @NEWLINE
						   + 'GROUP BY' + @NEWLINE
						   + @COLUMNS_SEL_GRP + ';';
		END;

		IF NULLIF(@QUERYSQL,'') IS NULL
		BEGIN
			SET @QUERYSQL = @NEWLINE + @NEWLINE 
							+ 'SELECT' + @NEWLINE
							+ @VIEWNAME + ' has been created.  No data for this section was found in the database.'' AS [EMPTYVIEWMESSAGE];';
		END;

		SET @VIEWSQL+=@QUERYSQL + @NEWLINE;

		INSERT INTO #SECTIONVIEWS
		(
			VIEWNAME,
			FIELDCOUNT,
			SQLTEXT
		)
		SELECT 
			@VIEWNAME,
			@FIELDCOUNT,
			@VIEWSQL;

		BEGIN TRY
			EXEC SP_EXECUTESQL 
				@VIEWSQL;
			PRINT @VIEWNAME + ' has been created.';
		END TRY
		BEGIN CATCH
			PRINT ERROR_MESSAGE();
		END CATCH;

		FETCH NEXT FROM CURSOR_SECTIONS INTO 
			@PROJECTTYPE,
			@SECTION,
			@ISCOLLECTION,
			@VIEWNAME,
			@VIEWSQL;
	END;

	CLOSE CURSOR_SECTIONS;

	DEALLOCATE CURSOR_SECTIONS;

	IF @DEBUGFLAG = 1
	BEGIN
		SELECT 
			VIEWNAME,
			FIELDCOUNT,
			SQLTEXT
		FROM #SECTIONVIEWS;
	END;
END;
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_reference_ClientCaseMap]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_reference_ClientCaseMap]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	DELETE FROM DBO.__FV_CLIENTCASEMAP
	WHERE 
		0 = 0;

	INSERT INTO
	-- SELECT * FROM
	DBO.__FV_CLIENTCASEMAP
	(
		PROJECTEXTERNALID,
		CONTACTEXTERNALID,
		CASEID,
		NAMEID,
		FILEVINE_PROJECTTEMPLATE,
		ACTIVE
	)
	SELECT 
		P.ID AS PROJECTEXTERNALID,
		P.CLIENTID AS CONTACTEXTERNALID,
		NULL AS CASEID,
		NULL AS NAMEID,
		PT.NAME AS FILEVINE_PROJECTTEMPLATE,
		IIF(PH.ISPERMANENT = 0,1,0) AS ACTIVE
-- SELECt * 
	FROM DBO.PROJECT AS P
	INNER JOIN DBO.CUSTOMPROJECTTYPE AS PT
		ON PT.ID = P.CUSTOMPROJECTTYPEID
	INNER JOIN PHASE AS PH
		ON PH.ID = P.PHASEID
		AND PH.CUSTOMPROJECTTYPEID = PT.ID
	/*Put the Org ID in here just in case*/
	WHERE P.ORGID = 7119;


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_reference_ContactCustomFieldMetadata]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [filevine].[usp_insert_reference_ContactCustomFieldMetadata]
	@DEBUGFLAG             BIT,
	@DATABASE              VARCHAR(1000),
	@SCHEMANAME            VARCHAR(1000),
	@FVPRODUCTIONPREFIX    VARCHAR(1000),
	@TIMEZONE              VARCHAR(1000)
AS
BEGIN

	DROP TABLE IF EXISTS 
		DBO.__FV_CONTACTCUSTOMFIELDMETADATA;

	CREATE TABLE [dbo].[__FV_ContactCustomFieldMetadata]
	(
		PERSONID         VARCHAR(MAX) NULL,
		TAB              VARCHAR(MAX) NOT NULL,
		FIELDPOSITION    VARCHAR(MAX) NOT NULL,
		FIELDSELECTOR    VARCHAR(MAX) NOT NULL,
		DISPLAYNAME      VARCHAR(MAX) NOT NULL,
		FIELDTYPE        VARCHAR(MAX) NOT NULL,
		DATATYPE         VARCHAR(MAX) NOT NULL,
		FIELDID          VARCHAR(MAX) NOT NULL,
		ITEMPOSITION     INT NULL,
		[VALUE]          VARCHAR(MAX) NULL
	);

	/*
		TODO:
			Docs not yet encountered
			DocLists not yet encountered
			PersonLinks not yet encountered
			PersonLinkLists not yet encountered
			StringLists not yet encountered
			Comments not yet encountered (Missing from current script)
			Several FieldTypes not yet encountered (Missing from ID list used in the filter below "PF.FIELDTYPE IN")
	*/

	WITH CONTACTTABFIELDS
		 AS (SELECT 
				 PF.ID AS PERSONFIELDID,
				 PT.TITLE AS FIELDTABNAME,
				 PFS.TITLE AS FIELDSETNAME,
				 CONCAT('(',RIGHT('0000' + CONVERT(VARCHAR(20),PFS.POSITION),4),',',RIGHT('0000' + CONVERT(VARCHAR(20),PF.POSITION),4),')') AS FIELDPOSITION,
				 PF.SELECTOR AS FIELDSELECTOR,
				 PF.TITLE AS DISPLAYNAME,
				 PF.FIELDTYPE,
				 DETAILSJSON,
				 JSON_VALUE(PF.DETAILSJSON,'$.defaultValue') AS DEFAULTVALUE
			 FROM PERSONTAB AS PT
			 INNER JOIN PERSONFIELDSET AS PFS
				 ON PFS.PERSONTABID = PT.ID
			 INNER JOIN PERSONFIELD AS PF
				 ON PF.PERSONFIELDSETID = PFS.ID
			 /*Including only field types that we can migrate into*/
			 WHERE PF.FIELDTYPE IN
				 (
				 01,	/*Integer = 1				->	PersonDataInteger	*/
				 02,	/*Currency = 2				->	PersonDataDecimal	*/
				 03,	/*String = 3				->	PersonDataString	*/
				 04,	/*Date = 4					->	PersonDataDate		*/
				 05,	/*Boolean = 5				->	PersonDataBoolean	*/
				 06,	/*Text = 6					->	PersonDataString	*/
				 07,	/*PersonLink = 7			->	PersonDataPersonLink*/
				 08,	/*Doc = 8					->	PersonDataDoc		*/
				 09,	/*Dropdown = 9				->	PersonDataString	*/
				 11,	/*DocList = 11				->	PersonDataDoc		*/
				 13,	/*PlainDecimal = 13			->	PersonDataDecimal	*/
				 14,	/*Percent = 14				->	PersonDataDecimal	*/
				 17,	/*TextLarge = 17			->	PersonDataString	*/
				 24,	/*StringList = 24			->	PersonDataString	*/
				 25,	/*PersonList = 25			->	PersonDataPersonLink*/
				 26,	/*MultiSelectList = 26		->	PersonDataString	*/
				 /*There are new Field Types that are missing from this list that came with the new Custom Contacts release*/
				 2051/*Switch = 2051				->	PersonDataBoolean	*/
				 ))
		 INSERT INTO DBO.__FV_CONTACTCUSTOMFIELDMETADATA
		 (
			 PERSONID,
			 TAB,
			 FIELDPOSITION,
			 FIELDSELECTOR,
			 DISPLAYNAME,
			 FIELDTYPE,
			 DATATYPE,
			 FIELDID,
			 ITEMPOSITION,
			 [VALUE]
		 )
		 SELECT 
			 D.PERSONID,
			 F.FIELDTABNAME,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'BOOLEAN' AS FIELDTYPE,
			 'BIT' AS DATATYPE,
			 F.PERSONFIELDID,
			 NULL AS ITEMPOSITION,
			 CONVERT(VARCHAR(MAX),ISNULL(D.VALUE,CONVERT(BIT,F.DEFAULTVALUE))) AS FIELDVALUE
		 FROM CONTACTTABFIELDS AS F
		 LEFT JOIN PERSONDATABOOLEAN AS D
			 ON D.PERSONFIELDID = F.PERSONFIELDID
		 WHERE F.FIELDTYPE IN
			 (
			 5,
			 2051
			 )
		 UNION
		 SELECT 
			 D.PERSONID,
			 F.FIELDTABNAME,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'DATE' AS FIELDTYPE,
			 'DATETIME' AS DATATYPE,
			 F.PERSONFIELDID,
			 NULL AS ITEMPOSITION,
			 CONVERT(VARCHAR(MAX),ISNULL(D.VALUE,CONVERT(DATETIME,F.DEFAULTVALUE))) AS FIELDVALUE
		 FROM CONTACTTABFIELDS AS F
		 LEFT JOIN PERSONDATADATE AS D
			 ON D.PERSONFIELDID = F.PERSONFIELDID
		 WHERE F.FIELDTYPE = 4
		 UNION
		 SELECT 
			 D.PERSONID,
			 F.FIELDTABNAME,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'DECIMAL' AS FIELDTYPE,
			 'DECIMAL(18,2)' AS DATATYPE,
			 F.PERSONFIELDID,
			 NULL AS ITEMPOSITION,
			 CONVERT(VARCHAR(MAX),ISNULL(D.VALUE,CONVERT(DECIMAL(18,2),F.DEFAULTVALUE))) AS FIELDVALUE
		 FROM CONTACTTABFIELDS AS F
		 LEFT JOIN PERSONDATADECIMAL AS D
			 ON D.PERSONFIELDID = F.PERSONFIELDID
		 WHERE F.FIELDTYPE IN
			 (
			 2,
			 13,
			 14
			 )
		 UNION
		 SELECT 
			 D.PERSONID,
			 F.FIELDTABNAME,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'DOC' AS FIELDTYPE,
			 'VARCHAR(MAX)' AS DATATYPE,
			 F.PERSONFIELDID,
			 D.ITEMPOSITION AS ITEMPOSITION,
			 CONVERT(VARCHAR(MAX),ND.DOCEXTERNALID) AS FIELDVALUE
		 FROM CONTACTTABFIELDS AS F
		 LEFT JOIN PERSONDATADOC AS D
			 ON D.PERSONFIELDID = F.PERSONFIELDID
		 LEFT JOIN PT1.DOCUMENTS AS ND
			 ON ND.DOCEXTERNALID = D.DOCID
		 WHERE F.FIELDTYPE IN
			 (
			 8,
			 11
			 )
		 UNION
		 SELECT 
			 D.PERSONID,
			 F.FIELDTABNAME,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'INTEGER' AS FIELDTYPE,
			 'INT' AS DATATYPE,
			 F.PERSONFIELDID,
			 NULL AS ITEMPOSITION,
			 CONVERT(VARCHAR(MAX),ISNULL(D.VALUE,CONVERT(INT,F.DEFAULTVALUE))) AS FIELDVALUE
		 FROM CONTACTTABFIELDS AS F
		 LEFT JOIN PERSONDATAINTEGER AS D
			 ON D.PERSONFIELDID = F.PERSONFIELDID
		 WHERE F.FIELDTYPE = 1
		 UNION
		 SELECT 
			 D.PERSONID,
			 F.FIELDTABNAME,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'PERSONLINK' AS FIELDTYPE,
			 'VARCHAR(MAX)' AS DATATYPE,
			 F.PERSONFIELDID,
			 D.ITEMPOSITION AS ITEMPOSITION,
			 CONVERT(VARCHAR(MAX),ND.CONTACTCUSTOMEXTERNALID) AS FIELDVALUE
		 FROM CONTACTTABFIELDS AS F
		 LEFT JOIN PERSONDATAPERSONLINK AS D
			 ON D.PERSONFIELDID = F.PERSONFIELDID
		 LEFT JOIN PT1.CONTACTSCUSTOM__CONTACTINFO AS ND
			 ON ND.CONTACTCUSTOMEXTERNALID = D.RELATEDPERSONID
		 WHERE F.FIELDTYPE IN
			 (
			 7,
			 25
			 )
		 UNION
		 SELECT 
			 D.PERSONID,
			 F.FIELDTABNAME,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'STRING' AS FIELDTYPE,
			 'NVARCHAR(MAX)' AS DATATYPE,
			 F.PERSONFIELDID,
			 D.ITEMPOSITION AS ITEMPOSITION,
			 CONVERT(VARCHAR(MAX),ISNULL(D.VALUE,F.DEFAULTVALUE)) AS FIELDVALUE
		 FROM CONTACTTABFIELDS AS F
		 LEFT JOIN PERSONDATASTRING AS D
			 ON D.PERSONFIELDID = F.PERSONFIELDID
		 WHERE F.FIELDTYPE IN
			 (
			 3,
			 6,
			 9,
			 17,
			 24,
			 26
			 )
		 ORDER BY 
			 FIELDPOSITION,
			 FIELDVALUE;

	/*Output Data Report for all Tabs*/
	SELECT 
		TAB,
		COUNT(DISTINCT FIELDSELECTOR) AS FIELDCOUNT,
		COUNT(*) AS RECORDCOUNT,
		SUM(IIF(VALUE IS NOT NULL,1.0,0.0)) / COUNT(*) AS NOTNULLPERCENT
	FROM __FV_CONTACTCUSTOMFIELDMETADATA
	GROUP BY 
		TAB
	ORDER BY 
		TAB;
END;
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_reference_Documents]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_reference_Documents]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_reference_Documents] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: ALL */
		/*================================================================================================*/
		/*
		INSERT INTO
			[dbo].[__FV_Documents]
			(
				  [FVD_RecID]
				, [FVDocID]
				, [ScanID]
				, [Legacy_DocID]
				, [Legacy_FileID]
				, [Legacy_ContactID]
				, [FV_ProjectID]
				, [FV_ContactFirstName]
				, [FV_ContactLastName]
				, [FV_Url]
				, [FV_Phase]
				, [FV_Archived]
				, [Doc_FullPath]
				, [Doc_BasePath]
				, [Doc_FileName]
				, [Doc_Ext]
				, [Doc_CompleteName]
				, [Doc_NeedRename]
				, [Doc_RenameTo]
				
			)
		SELECT DISTINCT
			  NULL [FVD_RecID]
			, NULL [FVDocID]
			, NULL [ScanID]
			, NULL [Legacy_DocID]
			, NULL [Legacy_FileID]
			, NULL [Legacy_ContactID]
			, NULL [FV_ProjectID]
			, NULL [FV_ContactFirstName]
			, NULL [FV_ContactLastName]
			, NULL [FV_Url]
			, NULL [FV_Phase]
			, NULL [FV_Archived]
			, NULL [Doc_FullPath]
			, NULL [Doc_BasePath]
			, NULL [Doc_FileName]
			, NULL [Doc_Ext]
			, NULL [Doc_CompleteName]
			, NULL [Doc_NeedRename]
			, NULL [Doc_RenameTo]
			
		
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_reference_DropDownListAlignment]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_reference_DropDownListAlignment]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_reference_DropDownListAlignment] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: ALL */
		/*================================================================================================*/
		/*
		INSERT INTO
			[dbo].[__FV_DropDownListAlignment]
			(
				  [ID]
				, [Table_Name]
				, [Column_Name]
				, [FV_Dropdown_Value]
				, [LEG_Field_Value]
				, [Active_Flag]
				, [Create_Date]
				, [Update_Date]
				
			)
		SELECT DISTINCT
			  NULL [ID]
			, NULL [Table_Name]
			, NULL [Column_Name]
			, NULL [FV_Dropdown_Value]
			, NULL [LEG_Field_Value]
			, NULL [Active_Flag]
			, [Filevine_META].dbo.udfDate_ConvertUTC([Create_Date], 'Eastern' , 1) [Create_Date]
			, [Filevine_META].dbo.udfDate_ConvertUTC([Update_Date], 'Eastern' , 1) [Update_Date]
			
		
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_reference_PhaseMap]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_reference_PhaseMap]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_reference_PhaseMap] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: ALL */
		/*================================================================================================*/
		/*
		INSERT INTO
			[dbo].[__FV_PhaseMap]
			(
				  [PhaseID]
				, [Legacy_Phase_ID]
				, [Legacy_Phase_Desc]
				, [Legacy_subPhase_ID]
				, [Legacy_subPhase_Desc]
				, [Filevine_Phase]
				, [isActive]
				
			)
		SELECT DISTINCT
			  NULL [PhaseID]
			, NULL [Legacy_Phase_ID]
			, NULL [Legacy_Phase_Desc]
			, NULL [Legacy_subPhase_ID]
			, NULL [Legacy_subPhase_Desc]
			, NULL [Filevine_Phase]
			, NULL [isActive]
			
		
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_reference_ProjectCustomFieldMetadata]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE       PROCEDURE [filevine].[usp_insert_reference_ProjectCustomFieldMetadata]
	@DEBUGFLAG             BIT,
	@DATABASE              VARCHAR(1000),
	@SCHEMANAME            VARCHAR(1000),
	@FVPRODUCTIONPREFIX    VARCHAR(1000),
	@TIMEZONE              VARCHAR(1000)
AS
BEGIN

	DROP TABLE IF EXISTS 
		DBO.__FV_PROJECTCUSTOMFIELDMETADATA;

	CREATE TABLE [dbo].[__FV_ProjectCustomFieldMetadata]
	(
		PROJECTID             VARCHAR(MAX) NULL,
		PROJECTTYPE           VARCHAR(MAX) NOT NULL,
		SECTION               VARCHAR(MAX) NOT NULL,
		ISCOLLECTION          VARCHAR(MAX) NOT NULL,
		FIELDPOSITION         VARCHAR(MAX) NOT NULL,
		FIELDSELECTOR         VARCHAR(MAX) NOT NULL,
		DISPLAYNAME           VARCHAR(MAX) NOT NULL,
		FIELDTYPE             VARCHAR(MAX) NOT NULL,
		DATATYPE              VARCHAR(MAX) NOT NULL,
		FIELDID               VARCHAR(MAX) NOT NULL,
		COLLECTIONITEMGUID    VARCHAR(MAX) NULL,
		[VALUE]               VARCHAR(MAX) NULL,
	);

	WITH PROJECTSECTIONFIELDS
		 AS (SELECT 
				 F.ID AS FIELDID,
				 LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PT.NAME,'/',' '),'&',' '),'(',' '),')',' '),' ',''),20) AS PROJECTTYPE,
				 LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(S.NAME,'/',' '),'&',' '),'(',' '),')',' '),' ',''),20) AS SECTION,
				 S.ISCOLLECTION AS ISCOLLECTION,
				 CONCAT('(',RIGHT('0000' + CONVERT(VARCHAR(20),F.ROW),4),',',RIGHT('0000' + CONVERT(VARCHAR(20),F.ORDERINROW),4),')') AS FIELDPOSITION,
				 F.FIELDSELECTOR AS FIELDSELECTOR,
				 F.NAME AS DISPLAYNAME,
				 F.CUSTOMFIELDTYPE
			 FROM DBO.CUSTOMPROJECTTYPE AS PT
			 INNER JOIN DBO.CUSTOMSECTION AS S
				 ON S.CUSTOMPROJECTTYPEID = PT.ID
			 INNER JOIN DBO.CUSTOMFIELD AS F
				 ON F.CUSTOMSECTIONID = S.ID
			 /*Including only field types that we can migrate into*/
			 WHERE F.CUSTOMFIELDTYPE IN
				 (
				 01,	/*Integer = 1				->	CustomDataInteger	*/
				 02,	/*Currency = 2				->	CustomDataDecimal	*/
				 03,	/*String = 3				->	CustomDataString	*/
				 04,	/*Date = 4					->	CustomDataDate		*/
				 05,	/*Boolean = 5				->	CustomDataBoolean	*/
				 06,	/*Text = 6					->	CustomDataString	*/
				 07,	/*PersonLink = 7			->	CustomDataPerson	*/
				 08,	/*Doc = 8					->	CustomDataDoc		*/
				 09,	/*Dropdown = 9				->	CustomDataString	*/
				 11,	/*DocList = 11				->	CustomDataDocList	*/
				 13,	/*PlainDecimal = 13			->	CustomDataDecimal	*/
				 14,	/*Percent = 14				->	CustomDataDecimal	*/
				 15,	/*Deadline = 15				->	CustomDataDeadline	*/
				 17,	/*TextLarge = 17			->	CustomDataString	*/
				 24,	/*StringList = 24			->	CustomDataStringList*/
				 25,	/*PersonList = 25			->	CustomDataPersonList*/
				 26		/*MultiSelectList = 26		->	CustomDataStringList*/
				 ))
		 INSERT INTO DBO.__FV_PROJECTCUSTOMFIELDMETADATA
		 (
			 PROJECTID,
			 PROJECTTYPE,
			 SECTION,
			 ISCOLLECTION,
			 FIELDPOSITION,
			 FIELDSELECTOR,
			 DISPLAYNAME,
			 FIELDTYPE,
			 DATATYPE,
			 FIELDID,
			 COLLECTIONITEMGUID,
			 [VALUE]
		 )
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'BOOLEAN' AS FIELDTYPE,
			 'BIT' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),D.BOOLVALUE) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATABOOLEAN AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 WHERE F.CUSTOMFIELDTYPE = 5
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'DATE' AS FIELDTYPE,
			 'DATETIME' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),D.DATEVALUE,121) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATADATE AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 WHERE F.CUSTOMFIELDTYPE = 4
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR + 'DUEDATE' AS FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'DEADLINEDUEDATE' AS FIELDTYPE,
			 'SMALLDATETIME' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),D.DATEVALUE,121) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATADEADLINE AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 WHERE F.CUSTOMFIELDTYPE = 15
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR + 'DONEDATE' AS FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'DEADLINEDONEDATE' AS FIELDTYPE,
			 'SMALLDATETIME' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),D.DONEDATE,121) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATADEADLINE AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 WHERE F.CUSTOMFIELDTYPE = 15
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'DECIMAL' AS FIELDTYPE,
			 'DECIMAL(18,2)' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),D.DECIMALVALUE) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATADECIMAL AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 WHERE F.CUSTOMFIELDTYPE IN
			 (
			 2,
			 13,
			 14
			 )
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'DOC' AS FIELDTYPE,
			 'VARCHAR(MAX)' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),ND.DOCEXTERNALID) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATADOC AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 LEFT JOIN PT1.DOCUMENTS AS ND
			 ON ND.DOCEXTERNALID = CONVERT(VARCHAR(MAX),D.DOCID)
		 WHERE F.CUSTOMFIELDTYPE = 8
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'DOCLIST' AS FIELDTYPE,
			 'VARCHAR(MAX)' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),DL.VALUECSV) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATADOCLIST AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 OUTER APPLY
		 (
			 SELECT 
				 STUFF(
			 (
				 SELECT TOP 100 PERCENT 
					 ',' + CONVERT(VARCHAR(MAX),ND.ID)
				 FROM DBO.CUSTOMDATADOCLISTITEM AS DLI
				 INNER JOIN DBO.DOC AS ND
					 ON ND.ID = CONVERT(VARCHAR(MAX),DLI.DOCID)
				 WHERE DLI.COLLECTIONITEMGUID = D.COLLECTIONITEMGUID AND DLI.PROJECTID = D.PROJECTID and DLI.CustomFieldID = D.customFieldid
				 ORDER BY 
					 DLI.COLLECTIONITEMGUID FOR
				 XML PATH('')
			 ),1,1,'') AS VALUECSV
		 ) AS DL
		 WHERE F.CUSTOMFIELDTYPE = 11
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'INTEGER' AS FIELDTYPE,
			 'INT' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),D.INTVALUE) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATAINTEGER AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 WHERE F.CUSTOMFIELDTYPE = 1
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'PERSON' AS FIELDTYPE,
			 'VARCHAR(MAX)' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 convert(varchar(max),D.personid) as value
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATAPERSON AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 --LEFT JOIN PT1.CONTACTSCUSTOM__CONTACTINFO AS ND
			-- ON ND.CONTACTCUSTOMEXTERNALID = CONVERT(VARCHAR(MAX),D.PERSONID)
		 WHERE F.CUSTOMFIELDTYPE = 7
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'PERSONLIST' AS FIELDTYPE,
			 'VARCHAR(MAX)' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),DL.VALUECSV) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATAPERSONLIST AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 OUTER APPLY
		 (
			 SELECT 
				 STUFF(
			 (
				 SELECT TOP 100 PERCENT 
					 ',' + CONVERT(VARCHAR(MAX),DLI.Personid)
				 FROM DBO.CUSTOMDATAPERSONLISTITEM AS DLI
				 --INNER JOIN PT1.CONTACTSCUSTOM__CONTACTINFO AS ND
					-- ON ND.CONTACTCUSTOMEXTERNALID = CONVERT(VARCHAR(MAX),DLI.PERSONID)
				 WHERE DLI.CustomFieldID =  D.CustomFieldid and DLI.PROJECTID = D.PROJECTID
				 ORDER BY 
					 DLI.POSITION FOR
				 XML PATH('')
			 ),1,1,'') AS VALUECSV
		 ) AS DL
		 WHERE F.CUSTOMFIELDTYPE = 25
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'STRING' AS FIELDTYPE,
			 'NVARCHAR(MAX)' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),D.STRINGVALUE) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATASTRING AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 WHERE F.CUSTOMFIELDTYPE IN
			 (
			 3,
			 6,
			 9,
			 17
			 )
		 UNION ALL
		 SELECT 
			 D.PROJECTID,
			 F.PROJECTTYPE,
			 F.SECTION,
			 F.ISCOLLECTION,
			 F.FIELDPOSITION,
			 F.FIELDSELECTOR,
			 F.DISPLAYNAME,
			 'STRINGLIST' AS FIELDTYPE,
			 'NVARCHAR(MAX)' AS DATATYPE,
			 F.FIELDID,
			 D.COLLECTIONITEMGUID,
			 CONVERT(VARCHAR(MAX),DL.VALUECSV) AS VALUE
		 FROM PROJECTSECTIONFIELDS AS F
		 LEFT JOIN DBO.CUSTOMDATASTRINGLIST AS D
			 ON D.CUSTOMFIELDID = F.FIELDID
		 OUTER APPLY
		 (
			 SELECT 
				 STUFF(
			 (
				 SELECT 
					 ',' + CONVERT(VARCHAR(MAX),DLI.STRINGVALUE)
				 FROM DBO.CUSTOMDATASTRINGLISTITEM AS DLI
				 WHERE DLI.CustomFieldID = D.CustomFieldID AND DLI.PROJECTID = D.PROJECTID
				 ORDER BY 
					 DLI.STRINGVALUE FOR
				 XML PATH('')
			 ),1,1,'') AS VALUECSV
		 ) AS DL
		 WHERE F.CUSTOMFIELDTYPE IN
			 (
			 24,
			 26
			 );

	/*Output Data Report about all ProjectType sections*/
	SELECT 
		PROJECTTYPE,
		SECTION,
		COUNT(DISTINCT FIELDSELECTOR) AS FIELDCOUNT,
		COUNT(*) AS RECORDCOUNT,
		SUM(IIF(VALUE IS NOT NULL,1.0,0.0)) / COUNT(*) AS NOTNULLPERCENT
	FROM __FV_PROJECTCUSTOMFIELDMETADATA
	GROUP BY 
		PROJECTTYPE,
		SECTION
	ORDER BY 
		PROJECTTYPE,
		SECTION;
END;

GO
/****** Object:  StoredProcedure [filevine].[usp_insert_reference_ProjectTemplateMap]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_reference_ProjectTemplateMap]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_reference_ProjectTemplateMap] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: ALL */
		/*================================================================================================*/
		/*
		INSERT INTO
			[dbo].[__FV_ProjectTemplateMap]
			(
				  [Project_Template_ID]
				, [Legacy_Case_ID]
				, [Legacy_Case_Desc]
				, [Legacy_subCase_ID]
				, [Legacy_subCase_Desc]
				, [Filevine_ProjectTemplate]
				, [Filevine_SubType]
				, [isActive]
				, [SpecialLogic]
				, [NeedsMigration]
				
			)
		SELECT DISTINCT
			  NULL [Project_Template_ID]
			, NULL [Legacy_Case_ID]
			, NULL [Legacy_Case_Desc]
			, NULL [Legacy_subCase_ID]
			, NULL [Legacy_subCase_Desc]
			, NULL [Filevine_ProjectTemplate]
			, NULL [Filevine_SubType]
			, NULL [isActive]
			, NULL [SpecialLogic]
			, NULL [NeedsMigration]
			
		
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_reference_User]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_reference_User]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_reference_User] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: ALL */
		/*================================================================================================*/
		/*
		INSERT INTO
			[dbo].[__FV_User]
			(
				  [ID]
				, [Email]
				, [FirstName]
				, [LastName]
				, [TimeZoneID]
				, [Username]
				, [PictureKey]
				, [IsActive]
				, [ExternalToken]
				, [CreatedAt]
				, [IsFilevineSystemAdmin]
				, [ApiKey]
				, [NotificationSmsNumber]
				, [ResetPassword]
				, [CognitoUserID]
				, [TenantID]
				
			)
		SELECT DISTINCT
			  NULL [ID]
			, NULL [Email]
			, NULL [FirstName]
			, NULL [LastName]
			, NULL [TimeZoneID]
			, 'datamigrationteam' [Username]
			, NULL [PictureKey]
			, NULL [IsActive]
			, NULL [ExternalToken]
			, [Filevine_META].dbo.udfDate_ConvertUTC([CreatedAt], 'Eastern' , 1) [CreatedAt]
			, NULL [IsFilevineSystemAdmin]
			, NULL [ApiKey]
			, NULL [NotificationSmsNumber]
			, NULL [ResetPassword]
			, NULL [CognitoUserID]
			, NULL [TenantID]
			
		
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_reference_Usernames]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_reference_Usernames]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	DELETE FROM DBO.__FV_USERNAMES
	WHERE 
		0 = 0;
	
	INSERT INTO DBO.__FV_USERNAMES
	(
		FV_USERNAME,
		LEGACY_USERNAME,
		LEGACY_USERNAME_ID,
		ISACTIVE,
		FIRSTNAME,
		LASTNAME,
		EMAIL1
	)
	SELECT
		U.USERNAME AS FV_USERNAME,
		U.USERNAME AS LEGACY_USERNAME,
		ISNULL(REFERENCEDUSERS.USERID, U.USERID) AS LEGACY_USERNAME_ID,
		U.ISACTIVE,
		U.FIRSTNAME,
		U.LASTNAME,
		U.EMAIL AS EMAIL1
	FROM
	(
		/*Look in these tables individually to find the users that are missing from the dbo.User table*/
		SELECT FIRSTPRIMARYUSERID	AS USERID FROM DBO.PROJECT
		UNION
		SELECT CREATEDBYID			AS USERID FROM DBO.APPOINTMENT
		UNION
		SELECT USERID				AS USERID FROM DBO.APPOINTMENTATTENDEE	WHERE ATTENDEETYPE	= 'User'
		UNION
		SELECT UPLOADERID			AS USERID FROM DBO.DOC					WHERE UPLOADERTYPE	= 'User'
		UNION
		SELECT AUTHORID				AS USERID FROM DBO.NOTE					WHERE AUTHORTYPE	= 'User'
		UNION
		SELECT ASSIGNEEID			AS USERID FROM DBO.NOTE					WHERE TYPETAG		= 'task'
		UNION
		SELECT AUTHORID				AS USERID FROM DBO.COMMENT				WHERE AUTHORTYPE	= 'User'
		UNION
		SELECT USERID				AS USERID FROM DBO.PERMISSION
	) AS REFERENCEDUSERS
	FULL JOIN
	(
		SELECT 
			U.USERNAME,
			U.ID AS USERID,
			U.ISACTIVE,
			U.FIRSTNAME,
			U.LASTNAME,
			U.EMAIL
		FROM DBO.[USER] AS U
		/*The Filevine System User (UserID = 1) needs to be changed to a dumy migration user different fro datamigrationteam*/
		UNION
		SELECT 
			'datamigrationteam' AS LEGACY_USERNAME,
			1 AS LEGACY_USERNAME_ID,
			0 AS ISACTIVE,
			'Data Migration Team' AS FIRSTNAME,
			'' AS LASTNAME,
			'data@import.filevine.com' AS EMAIL1
		/*
			Handle the rest of the missing users that were removed from the org here by either aligning them to a dummy migration user OR looking up their data (Notes, Docs, ect.) in app.filevine.com
			If they want to keep their references for historical purposes then these users will need to be re-added to the org (Setup > Orgs > Members) with no permissions and subsequently removed after the migration.
		*/
	) AS U
		ON U.USERID = REFERENCEDUSERS.USERID
	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_AdHocDeadlines]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_AdHocDeadlines]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_AdHocDeadlines] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		/*Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.*/
	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_CalendarEvents]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_CalendarEvents]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	DELETE FROM PT1.CALENDAREVENTS
	WHERE 
		0 = 0;

	INSERT INTO PT1.CALENDAREVENTS
	(
		__IMPORTSTATUS,
		__IMPORTSTATUSDATE,
		__ERRORMESSAGE,
		__WORKERID,
		__APPOINTMENTID,
		CALENDAREXTERNALID,
		PROJECTEXTERNALID,
		ALLDAY,
		STARTDATE,
		ENDDATE,
		LOCATION,
		NOTES,
		TITLE,
		AUTHOR,
		ATTENDEEUSERCSV,
		ATTENDEECONTACTCSV
	)
	SELECT 
		40 AS __IMPORTSTATUS,
		GETDATE() AS __IMPORTSTATUSDATE,
		NULL AS __ERRORMESSAGE,
		NULL AS __WORKERID,
		NULL AS __APPOINTMENTID,
		CE.ID AS CALENDAREXTERNALID,
		ISNULL(CCM.PROJECTEXTERNALID,CE.PROJECTID) AS PROJECTEXTERNALID,
		CE.ALLDAY AS ALLDAY,
		CE.[START] AS STARTDATE,
		IIF(CE.[START] >= CE.[END],DATEADD(HOUR,1,CE.[START] ),CE.[END]) AS ENDDATE,
		NULLIF(CE.LOCATION,'') AS LOCATION,
		NULLIF(CE.NOTES,'') AS NOTES,
		CE.TITLE AS TITLE,
		ISNULL(AU.FV_USERNAME,'datamigrationteam') AS AUTHOR,
		ISNULL(ACSV.ATTENDEEUSERCSV,'datamigrationteam') AS ATTENDEEUSERCSV,
		NULL AS ATTENDEECONTACTCSV
	FROM DBO.__FV_CLIENTCASEMAP AS CCM
	INNER JOIN DBO.APPOINTMENT AS CE
		ON CE.PROJECTID = CCM.PROJECTEXTERNALID
	LEFT JOIN DBO.__FV_USERNAMES AS AU
		ON AU.LEGACY_USERNAME_ID = CE.CREATEDBYID
	OUTER APPLY
	(
		SELECT 
			STUFF(
			(
				SELECT 
					',' + CONVERT(VARCHAR(MAX),U.FV_USERNAME)
				FROM DBO.APPOINTMENTATTENDEE AS AA
				LEFT JOIN DBO.__FV_USERNAMES AS U
					ON U.LEGACY_USERNAME_ID = AA.USERID/**/
						AND AA.ATTENDEETYPE = 'User'
				WHERE AA.ISREMOVED = 0 AND AA.APPOINTMENTID = CE.ID FOR
				XML PATH('')
			),1,1,'') AS ATTENDEEUSERCSV
	) AS ACSV;
	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_CaseAnalysis]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_CaseAnalysis]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN --		SELECT 	'[filevine].[usp_insert_staging_CaseAnalysis] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'
			
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
	delete from [PT1].[WTOFXGMaster_NC_CaseAnalysis]
	INSERT INTO
			[PT1].[WTOFXGMaster_NC_CaseAnalysis]
			
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				, [judgeContactExternalID]
				, [judgecomments]
				, [jurisdictionContactExternalID]
				, [jurisdictioncomments]
				, [namedplaintiffallegationscomments]
				, [plaintiffscounselContactExternalIdCsv]
				, [plaintiffscounselcomments]
				, [meritsdefensescomments]
				, [jointemploymenttestcomments]
				, [scopeofputativeclasscomme]
				, [spcooperationtcomment]
				, [venuecomments]
				, [totalcasevalue]
				, [judgecasevalue]
				, [lastUpdated]
				, [jurisdictionCaseValue]
				, [namedPlaintiffsAllegations]
				, [plaintiffsCounselCaseValu]
				, [meritsDefensesCaseValue]
				, [jointEmploymentTestCaseVa]
				, [scopeOfPutativeClassCase]
				, [SPCooperationCaseValue]
				, [venueCaseValue]
				, [totalCaseGradeAF]
				, [totalcasegrade]
			)

		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, ca.judge [judgeContactExternalID]
			, ca.judgecomments [judgecomments]
			, ca.jurisdiction [jurisdictionContactExternalID]
			, ca.jurisdictioncomments [jurisdictioncomments]
			, ca.namedplaintiffallegationscomments [namedplaintiffallegationscomments]
			, ca.plaintiffscounsel [plaintiffscounselContactExternalIdCsv]
			, ca.[plaintiffscounselcomments] [plaintiffscounselcomments]
			, ca.[meritsdefensescomments] [meritsdefensescomments]
			, ca.[jointemploymenttestcomments] [jointemploymenttestcomments]
			, ca.[scopeofputativeclasscomme] [scopeofputativeclasscomme]
			, ca.[spcooperationtcomment] [spcooperationtcomment]
			, ca.venuecomments [venuecomments]
			, ca.totalcasevalue [totalcasevalue]
			, ca.judgecasevalue [judgecasevalue]
			, ca.lastupdated [lastUpdated]
			, ca.jurisdictioncasevalue [jurisdictionCaseValue]
			, ca.namedplaintiffsallegations [namedPlaintiffsAllegations]
			, ca.[plaintiffsCounselCaseValu] [plaintiffsCounselCaseValu]
			, ca.[meritsDefensesCaseValue] [meritsDefensesCaseValue]
			, ca.[jointEmploymentTestCaseVa] [jointEmploymentTestCaseVa]
			, ca.[scopeOfPutativeClassCase] [scopeOfPutativeClassCase]
			, ca.[SPCooperationCaseValue] [SPCooperationCaseValue]
			, ca.venuecasevalue [venueCaseValue]
			, ca.totalcasegradeaf [totalCaseGradeAF]
			, ca.[totalcasegrade] [totalcasegrade]
	-- select ca.*
	FROM __FV_ClientCaseMap ccm
	INNER JOIN [7119_FedEx_II_r2].[dbo].[vw_PT_WTOFXGMaster_CaseAnalysis] ca
		ON ccm.projectexternalid = ca.projectexternalid
		
				
select * from [PT1].[WTOFXGMaster_NC_CaseAnalysis]

	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_CaseBudget]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_CaseBudget]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_CaseBudget] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _Defense_ */
		/*================================================================================================*/
		/*
		INSERT INTO
			[PT1].[Defense_CL_CaseBudget]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [dateofbudget]
				, [hourlyrate]
				, [pagesofdiscoverydocs]
				, [numberofaudiotapes]
				, [hoursofaudiotape]
				, [numberofvideotapes]
				, [hoursofvideotape]
				, [otherspecify]
				, [documents]
				, [discoveryretrieval]
				, [audiotapes]
				, [videotapes]
				, [other]
				, [estimatedlengthoftrialindays]
				, [hoursincourtperday]
				, [incourthoursfortrial]
				, [travelhoursfortrial]
				, [hoursoftraveltofromcourtperday]
				, [outofcourthoursfortrialpreparation]
				, [estimatedhoursincourt]
				, [estimatedtravelhourstofromcourt]
				, [estimatedoutofcourthoursforprep]
				, [estimatedhoursincourtdiscovery]
				, [estimatedtravelhourstofromcourtdiscovery]
				, [estimatedoutofcourthoursforprepdiscovery]
				, [estimatedhoursincourthearingschallenges]
				, [estimatedtravelhourstofromcourthearingschallenges]
				, [estimatedoutofcourthoursforpreparationhearingchall]
				, [estimatedhoursincourtsentencing]
				, [estimatedtravelhourstofromcourtsentencing]
				, [estimatedoutofcourthoursforprepsentencing]
				, [numberofpotentialwitnesses]
				, [estimatedhoursofinvestigationinterviews]
				, [otherinvestigation]
				, [estimatedhoursforotherinvestigation]
				, [estimatednumberofmeetingsconsultations]
				, [estimatedhoursofconsultation]
				, [isclientheldinremotefacility]
				, [roundtriptraveltimetoclient]
				, [totalestimatedhoursoftraveltimetoclient]
				, [otherclientconsultation]
				, [estimatedhoursforotherclientconsultation]
				, [expertwitnessesContactExternalIdCsv]
				, [totaltimeforexperts]
				, [withcocounselandassociates]
				, [withinvestigatorsandparalegals]
				, [withcounselforcodefendants]
				, [withopposingcounsel]
				, [totalestimatedtraveltime]
				, [indicateinhours]
				, [criminalrecordschecks]
				, [recordsretrieval]
				, [copyingcosts]
				, [transcripts]
				, [computerassistedlegalresearch]
				, [trialaids]
				, [othercosts]
				, [specify]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [CollectionItemExternalID]
			, NULL [dateofbudget]
			, NULL [hourlyrate]
			, NULL [pagesofdiscoverydocs]
			, NULL [numberofaudiotapes]
			, NULL [hoursofaudiotape]
			, NULL [numberofvideotapes]
			, NULL [hoursofvideotape]
			, NULL [otherspecify]
			, NULL [documents]
			, NULL [discoveryretrieval]
			, NULL [audiotapes]
			, NULL [videotapes]
			, NULL [other]
			, NULL [estimatedlengthoftrialindays]
			, NULL [hoursincourtperday]
			, NULL [incourthoursfortrial]
			, NULL [travelhoursfortrial]
			, NULL [hoursoftraveltofromcourtperday]
			, NULL [outofcourthoursfortrialpreparation]
			, NULL [estimatedhoursincourt]
			, NULL [estimatedtravelhourstofromcourt]
			, NULL [estimatedoutofcourthoursforprep]
			, NULL [estimatedhoursincourtdiscovery]
			, NULL [estimatedtravelhourstofromcourtdiscovery]
			, NULL [estimatedoutofcourthoursforprepdiscovery]
			, NULL [estimatedhoursincourthearingschallenges]
			, NULL [estimatedtravelhourstofromcourthearingschallenges]
			, NULL [estimatedoutofcourthoursforpreparationhearingchall]
			, NULL [estimatedhoursincourtsentencing]
			, NULL [estimatedtravelhourstofromcourtsentencing]
			, NULL [estimatedoutofcourthoursforprepsentencing]
			, NULL [numberofpotentialwitnesses]
			, NULL [estimatedhoursofinvestigationinterviews]
			, NULL [otherinvestigation]
			, NULL [estimatedhoursforotherinvestigation]
			, NULL [estimatednumberofmeetingsconsultations]
			, NULL [estimatedhoursofconsultation]
			, NULL [isclientheldinremotefacility]
			, NULL [roundtriptraveltimetoclient]
			, NULL [totalestimatedhoursoftraveltimetoclient]
			, NULL [otherclientconsultation]
			, NULL [estimatedhoursforotherclientconsultation]
			, NULL [expertwitnessesContactExternalIdCsv]
			, NULL [totaltimeforexperts]
			, NULL [withcocounselandassociates]
			, NULL [withinvestigatorsandparalegals]
			, NULL [withcounselforcodefendants]
			, NULL [withopposingcounsel]
			, NULL [totalestimatedtraveltime]
			, NULL [indicateinhours]
			, NULL [criminalrecordschecks]
			, NULL [recordsretrieval]
			, NULL [copyingcosts]
			, NULL [transcripts]
			, NULL [computerassistedlegalresearch]
			, NULL [trialaids]
			, NULL [othercosts]
			, NULL [specify]
			
		
		FROM 
			__FV_ClientCaseMap ccm
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_CaseBudgetBillings]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_CaseBudgetBillings]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_CaseBudgetBillings] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/


		INSERT INTO
			[PT1].[WTOFXGMaster_CL_CaseBudgetBillings]
			
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [month]
				, [estimatedBudget]
				, [amountBilled]
				, [dateBill]
				, [billingInvoicePastDue]
				, [fiscalYear]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, CB.[CollectionItemExternalID] [CollectionItemExternalID]
			, CB.MONTH [month]
			, CB.[estimatedBudget] [estimatedBudget]
			, CB.[amountBilled] [amountBilled]
			, CB.[dateBill] [dateBill]
			, CB.[billingInvoicePastDue] [billingInvoicePastDue]
			, CB.[fiscalYear] [fiscalYear]
	-- select CB.*		
		FROM __FV_ClientCaseMap ccm
		INNER JOIN [dbo].[vw_PT_WTOFXGMaster_CaseBudgetBillings] CB
			ON CCM.PROJECTEXTERNALID = CB.PROJECTEXTERNALID
		
		

				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_CaseSummary]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_CaseSummary]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_CaseSummary] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'

		


	delete from [PT1].[WTOFXGMaster_NC_CaseSummary]
		INSERT INTO
			[PT1].[WTOFXGMaster_NC_CaseSummary]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				,[ProjectExternalID]
      ,[responsibleprofessionalContactExternalID]
      ,[SignificantDevelopments]
      ,[MatterDescription]
      ,[matterNumber]
      ,[outsideLawFirmContactExternalIdCsv]
      ,[plaintiffSCounselContactExternalIdCsv]
      ,[SPSContactExternalIdCsv]
      ,[cSPSActive]
      ,[entityID]
      ,[SPSNamedAsCoDef]
      ,[SPSRepByCounsel]
      ,[priorLCGInv]
      ,[pCIssued]
      ,[pCIssueDate]
      ,[startOfLimitationsPeriod]
      ,[significantDevelopmentsDate]
      ,[matterStatus]
      ,[matterStatusDate]
      ,[additionalUpdatesToMatterS]
      ,[matterStatus1]
      ,[matterStatusDate1]
      ,[litigationHold]
      ,[dateHoldOccurred]
      ,[primaryFacilityStation]
      ,[secondaryFacilityStation]
      ,[division]
      ,[region]
      ,[forumType]
      ,[caseWeightingScale]
      ,[juryOrNonJury]
      ,[disposition]
      ,[dispositionAmount]
      ,[dispositionDate]
      ,[pSAClaim]
      ,[contractorModelClaim]
      ,[classCertificationRiskFacto]
      ,[classCertificationRiskFacto_1]
      ,[contractorModelClaimComment]
      ,[caseSpecificLiabilityDama]
      ,[riskOfLoss]
      ,[potentialClassMembers]
      ,[potentialClassMembers_1]
      ,[potentialClassMembersCommen]
      ,[currentExposure]
      ,[exposureEvaluationDate]
      ,[hasTheClassActionBeenCert]
      ,[classOrCollectiveAction]
      ,[matterType]
      ,[challengedEmploymentAction]
      ,[litigationStatus]
      ,[litigationStatusComments]
      ,[fXGSRole]
      ,[conflictAnalysisComplete]
      ,[appropriateCommmunicationsEx]
      ,[caseCaption]
      ,[courtType]
      ,[docketNumber]
      ,[courtNameContactExternalID]
      ,[dateSuitFiled]
      ,[dateServed]
      ,[trialReportDueDueDate]
      ,[trialReportDueDoneDate]
      ,[sPNamed]
      ,[venueState]
      ,[aOSContactExternalIdCsv]
      ,[scope]
      ,[estimatedBudget]
      ,[totalSpend]		
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]		
      ,[responsibleprofessional]
      ,[SignificantDevelopments]
      ,[MatterDescription]
      ,[matterNumber]
      ,[outsideLawFirm]
      ,[plaintiffSCounsel]
      ,[SPS]
      ,[cSPSActive]
      ,[entityID]
      ,[SPSNamedAsCoDef]
      ,[SPSRepByCounsel]
      ,[priorLCGInv]
      ,[pCIssued]
      ,[pCIssueDate]
      ,[startOfLimitationsPeriod]
      ,[significantDevelopmentsDate]
      ,[matterStatus]
      ,[matterStatusDate]
      ,[additionalUpdatesToMatterS]
      ,[matterStatus1]
      ,[matterStatusDate1]
      ,[litigationHold]
      ,[dateHoldOccurred]
      ,[primaryFacilityStation]
      ,[secondaryFacilityStation]
      ,[division]
      ,[region]
      ,[forumType]
      ,[caseWeightingScale]
      ,[juryOrNonJury]
      ,[disposition]
      ,[dispositionAmount]
      ,[dispositionDate]
      ,[pSAClaim]
      ,[contractorModelClaim]
      ,[classCertificationRiskFacto]
      ,[classCertificationRiskFacto_1]
      ,[contractorModelClaimComment]
      ,[caseSpecificLiabilityDama]
      ,[riskOfLoss]
      ,[potentialClassMembers]
      ,[potentialClassMembers_1]
      ,[potentialClassMembersCommen]
      ,[currentExposure]
      ,[exposureEvaluationDate]
      ,[hasTheClassActionBeenCert]
      ,[classOrCollectiveAction]
      ,replace([matterType],'&amp;','&') [matterType]
      ,replace([challengedEmploymentAction],'&amp;','&') [challengedEmploymentAction]
      ,[litigationStatus]
      ,[litigationStatusComments]
      ,[fXGSRole]
      ,[conflictAnalysisComplete]
      ,[appropriateCommmunicationsEx]
      ,[caseCaption]
      ,[courtType]
      ,[docketNumber]
      ,[courtName]
      ,[dateSuitFiled]
      ,[dateServed]
      ,[trialReportDueDueDate]
      ,[trialReportDueDoneDate]
      ,[sPNamed]
      ,[venueState]
      ,[aOS]
      ,[scope]
      ,[estimatedBudget]
      ,[totalSpend]
		FROM 
			__FV_ClientCaseMap ccm
		INNER JOIN [dbo].[vw_PT_WTOFXGMaster_CaseSummary] cs
			ON ccm.projectexternalid = cs.projectexternalid
		
		
				


	END
							
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_ContactInfo]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_ContactInfo]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_ContactInfo] has been created in [4982_Ronstadt_II] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
		
		if object_id('TEMPDB.DBO.#phones','U') is not null
		drop table #phones;

		select DENSE_RANK() over(partition by personid order by pp.id) #rank,pp.id phoneid,number,personid,ppl.name,notes into #phones from PersonPhone pp left join PersonPhoneLabel ppl on pp.phonelabelid = ppl.id

		if object_id('TEMPDB.DBO.#address','U') is not null
		drop table #address;


		select DENSE_RANK() over(partition by personid order by a.id) #rank,a.id addid,personid,line1,line2,city,state,zip,pal.Name,notes into #address from PersonAddress a left join PersonAddressLabel pal on a.AddressLabelID = pal.ID

		if object_id('TEMPDB.DBO.#email','U') is not null
		drop table #email;

		select DENSE_RANK() over(partition by personid order by pe.id) #rank,pe.id emailid,personid,[address], pel.name ,notes into #email from PersonEmail pe left join personemaillabel pel on pe.emaillabelid = pel.id 

		INSERT INTO
			[PT1].[ContactsCustom__ContactInfo]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CustomPersonID]
				, [ContactCustomExternalID]
				, [ContactTypeList]
				, [FirstName]
				, [MiddleName]
				, [LastName]
				, [Prefix]
				, [Suffix]
				, [Nickname]
				, [BirthDate]
				, [FromCompany]
				, [IsSingleName]
				, [Department]
				, [JobTitle]
				, [ContactHashtagList]
				, [PhoneLabelName1]
				, [PhoneNumber1]
				, [PhoneNote1]
				, [PhoneLabelName2]
				, [PhoneNumber2]
				, [PhoneNote2]
				, [PhoneLabelName3]
				, [PhoneNumber3]
				, [PhoneNote3]
				, [PhoneLabelName4]
				, [PhoneNumber4]
				, [PhoneNote4]
				, [PhoneLabelName5]
				, [PhoneNumber5]
				, [PhoneNote5]
				, [PhoneLabelName6]
				, [PhoneNumber6]
				, [PhoneNote6]
				, [PhoneLabelName7]
				, [PhoneNumber7]
				, [PhoneNote7]
				, [PhoneLabelName8]
				, [PhoneNumber8]
				, [PhoneNote8]
				, [PhoneLabelName9]
				, [PhoneNumber9]
				, [PhoneNote9]
				, [PhoneLabelName10]
				, [PhoneNumber10]
				, [PhoneNote10]
				, [EmailLabelName1]
				, [EmailAddress1]
				, [EmailNote1]
				, [EmailLabelName2]
				, [EmailAddress2]
				, [EmailNote2]
				, [EmailLabelName3]
				, [EmailAddress3]
				, [EmailNote3]
				, [EmailLabelName4]
				, [EmailAddress4]
				, [EmailNote4]
				, [EmailLabelName5]
				, [EmailAddress5]
				, [EmailNote5]
				, [EmailLabelName6]
				, [EmailAddress6]
				, [EmailNote6]
				, [EmailLabelName7]
				, [EmailAddress7]
				, [EmailNote7]
				, [EmailLabelName8]
				, [EmailAddress8]
				, [EmailNote8]
				, [EmailLabelName9]
				, [EmailAddress9]
				, [EmailNote9]
				, [EmailLabelName10]
				, [EmailAddress10]
				, [EmailNote10]
				, [Address1LabelName]
				, [Address1Line1]
				, [Address1Line2]
				, [Address1City]
				, [Address1State]
				, [Address1Zip]
				, [Address1Note]
				, [Address2LabelName]
				, [Address2Line1]
				, [Address2Line2]
				, [Address2City]
				, [Address2State]
				, [Address2Zip]
				, [Address2Note]
				, [Address3LabelName]
				, [Address3Line1]
				, [Address3Line2]
				, [Address3City]
				, [Address3State]
				, [Address3Zip]
				, [Address3Note]
				, [Address4LabelName]
				, [Address4Line1]
				, [Address4Line2]
				, [Address4City]
				, [Address4State]
				, [Address4Zip]
				, [Address4Note]
				, [Address5LabelName]
				, [Address5Line1]
				, [Address5Line2]
				, [Address5City]
				, [Address5State]
				, [Address5Zip]
				, [Address5Note]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CustomPersonID]
			, p.id [ContactCustomExternalID]
			, NULL [ContactTypeList]
			, P.firstname [FirstName]
			, P.Middlename [MiddleName]
			, P.LastName [LastName]
			, P.prefix [Prefix]
			, P.suffix [Suffix]
			, P.NickName [Nickname]
			, P.BirthDate [BirthDate]
			, P.FromCompany [FromCompany]
			, P.isSingleName [IsSingleName]
			, P.Department [Department]
			, P.JobTitle [JobTitle]
			, NULL [ContactHashtagList]
			, case when pn.name is null
				then 'Other'  
				else pn.Name 
				end [PhoneLabelName1]
			,  pn.number  [PhoneNumber1]
			, pn.notes [PhoneNote1]
			, case when pn2.name is null 
				then 'Other'  
				else pn2.Name 
				end						[PhoneLabelName2]
			, pn2.number				[PhoneNumber2]
			, pn2.notes					[PhoneNote2]
			,case when pn3.name is null
				then 'Other'  
				else pn3.Name 
				end						
			,pn3.number				
			,pn3.notes
			,case when pn4.name is null
				then 'Other'  
				else pn4.Name 
				end						
			,pn4.number				
			,pn4.notes
			,case when pn5.Name is null
				then 'Other'  
				else pn5.Name 
				end						
			,pn5.number				
			,pn5.notes
			,case when pn6.Name is null
				then 'Other'  
				else pn6.Name 
				end						
			,pn6.number				
			,pn6.notes
			,case when pn7.Name is null
				then 'Other'  
				else pn7.Name 
				end						
			,pn7.number				
			,pn7.notes
			,case when pn8.Name is null
				then 'Other'  
				else pn8.Name 
				end						
			,pn8.number				
			,pn8.notes
			,case when pn9.Name is null
				then 'Other'  
				else pn9.Name 
				end						
			,pn9.number				
			,pn9.notes
			,case when pn10.Name is null
				then 'Other'  
				else pn10.Name 
				end						
			,pn10.number				
			,pn10.notes			
			, case when e.Name is null
				then 'Other'  
				else e.Name 
				end [EmailLabelName1]
			, e.Address  [EmailAddress1]
			, e.notes 		 [EmailNote1]
			, case when e2.Name is null
				then 'Other'  
				else e2.Name 
				end [EmailLabelName2]
			, e2.Address  [EmailAddress2]
			, e2.notes		 [EmailNote2]
			, case when e3.Name is null
				then 'Other'  
				else e3.Name 
				end [EmailLabelName3]
			, e3.Address  [EmailAddress3]
			, e3.notes		 [EmailNote3]
			, case when e4.Name is null
				then 'Other'  
				else e4.Name 
				end [EmailLabelName4]
			, e4.Address [EmailAddress4]
			, e4.notes	 [EmailNote4]
			, case when e5.Name is null
				then 'Other'  
				else e5.Name 
				end 												[EmailLabelName5]
			, e5.Address		[EmailAddress5]
			, e5.notes			[EmailNote5]
			, case when e6.name is null
				then 'Other'  
				else e6.Name 
				end  [EmailLabelName6]
			, e6.Address [EmailAddress6]
			, e6.notes	 [EmailNote6]
			, case when e7.Name is null
				then 'Other'  
				else e7.Name 
				end  [EmailLabelName7]
			, e7.Address [EmailAddress7]
			, e7.notes	 [EmailNote7]
			, case when e8.name is null
				then 'Other'  
				else e8.Name 
				end [EmailLabelName8]
			, e8.Address [EmailAddress8]
			, e8.notes	 [EmailNote8]
			, case when e9.name is null
				then 'Other'  
				else e9.Name 
				end  [EmailLabelName9]
			, e2.Address [EmailAddress9]
			, e2.notes	[EmailNote9]			
			, case when e10.name is null
				then 'Other'  
				else e10.Name 
				end  [EmailLabelName10]
			, e10.Address [EmailAddress10]
			, e10.notes	[EmailNote10]
			, case when a.name is null
			  then 'Other'
			  else a.[name] end								[Address1LabelName]
			, case when a.#rank = 1 then a.Line1 end			[Address1Line1]
			, case when a.#rank = 1 then a.line2 end			[Address1Line2]
			, case when a.#rank = 1 then a.city end				[Address1City]
			, case when a.#rank = 1 then a.state end			[Address1State]
			, case when a.#rank = 1 then a.zip end				[Address1Zip]
			, case when a.#rank = 1 then a.Notes end			[Address1Note]
			, case when a2.name is null
			  then 'Other'
			  else a2.[name] end									[Address2LabelName]
			, case when a.#rank = 2 then a.Line1 end				[Address2Line1]
			, case when a.#rank = 2 then a.line2 end				[Address2Line2]
			, case when a.#rank = 2 then a.city end					[Address2City]
			, case when a.#rank = 2 then a.state end				[Address2State]
			, case when a.#rank = 2 then a.zip end					[Address2Zip]
			, case when a.#rank = 2 then a.Notes end				[Address2Note]
			, case when a3.name is null
			  then 'Other'
			  else a3.[name] end									 [Address3LabelName]
			, case when a.#rank = 3 then a.Line1 end [Address3Line1]
			, case when a.#rank = 3 then a.line2 end [Address3Line2]
			, case when a.#rank = 3 then a.city end	 [Address3City]
			, case when a.#rank = 3 then a.state end [Address3State]
			, case when a.#rank = 3 then a.zip end	 [Address3Zip]
			, case when a.#rank = 3 then a.Notes end [Address3Note]
			, case when a4.name is null 
			  then 'Other'
			  else a4.[name] end									 [Address4LabelName]
			, a4.Line1	 [Address4Line1]
			, a4.line2	 [Address4Line2]
			, a4.city		 [Address4City]
			, a4.state	 [Address4State]
			, a4.zip		 [Address4Zip]
			, a4.Notes	 [Address4Note]
			, case when a5.name is null 
			  then 'Other'
			  else a5.[name] end									 [Address5LabelName]
			, a5.Line1  [Address5Line1]
			, a5.line2  [Address5Line2]
			, a5.city 	 [Address5City]
			, a5.state  [Address5State]
			, a5.zip 	 [Address5Zip]
			, a5.Notes  [Address5Note]
			
		
		FROM 
		[dbo].[Person] p 
		left join #phones pn on p.id = pn.PersonID and pn.#rank = 1
		left join #phones pn2 on p.id = pn2.PersonID and pn2.#rank = 2
		left join #phones pn3 on p.id = pn3.PersonID and pn3.#rank = 3
		left join #phones pn4 on p.id = pn4.PersonID and pn4.#rank = 4
		left join #phones pn5 on p.id = pn5.PersonID and pn5.#rank = 5
		left join #phones pn6 on p.id = pn6.PersonID and pn6.#rank = 6
		left join #phones pn7 on p.id = pn7.PersonID and pn7.#rank = 7
		left join #phones pn8 on p.id = pn8.PersonID and pn8.#rank = 8
		left join #phones pn9 on p.id = pn9.PersonID and pn9.#rank = 1
		left join #phones pn10 on p.id = pn10.PersonID and pn10.#rank = 10
		left join #address a on p.id = a.personid and	a.#rank = 1
		left join #address a2 on p.id = a2.personid and	a.#rank = 2
		left join #address a3 on p.id = a3.personid and	a.#rank = 3
		left join #address a4 on p.id = a4.personid and	a.#rank = 4
		left join #address a5 on p.id = a5.personid and	a.#rank = 5		
		left join #email e on p.id = e.personid and e.#rank = 1
		left join #email e2 on p.id = e2.personid and e2.#rank = 2
		left join #email e3 on p.id = e3.personid and e2.#rank = 3
		left join #email e4 on p.id = e4.personid and e4.#rank = 4
		left join #email e5 on p.id = e5.personid and e5.#rank = 5
		left join #email e6 on p.id = e6.personid and e6.#rank = 6
		left join #email e7 on p.id = e7.personid and e2.#rank = 7
		left join #email e8 on p.id = e8.personid and e8.#rank = 8
		left join #email e9 on p.id = e2.personid and e9.#rank = 9
		left join #email e10 on p.id = e10.personid and e10.#rank = 10
		
		
		
		
			
			

	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Deadlines]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_Deadlines]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	DELETE FROM PT1.DEADLINES
	WHERE 
		0 = 0;

	INSERT INTO
	--SELECt * FROM 
PT1.DEADLINES
--	filevinestaging2import.._FedexB_Test2_Deadlines___18078
	(
		__IMPORTSTATUS,
		__IMPORTSTATUSDATE,
		__ERRORMESSAGE,
		__WORKERID,
		__DEADLINEID,
		DEADLINEEXTERNALID,
		PROJECTEXTERNALID,
		NAME,
		NOTES,
		DUEDATE,
		DONEDATE
	)
	SELECT 
		40 AS __IMPORTSTATUS,
		GETDATE() AS __IMPORTSTATUSDATE,
		NULL AS __ERRORMESSAGE,
		NULL AS __WORKERID,
		NULL AS __DEADLINEID,
		D.ID AS DEADLINEEXTERNALID,
		CCM.PROJECTEXTERNALID AS PROJECTEXTERNALID,
		NULLIF(D.NAME,'') AS NAME,
		NULLIF(D.NOTES,'') AS NOTES,
		D.DUEDATE AS DUEDATE,
		D.DONEDATE AS DONEDATE
	FROM DBO.__FV_CLIENTCASEMAP AS CCM
	INNER JOIN DBO.DEADLINE AS D
		ON D.PROJECTID = CCM.PROJECTEXTERNALID;


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_DemandNegotiations]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_DemandNegotiations]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_DemandNegotiations] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		/*Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.*/
	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Depos]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_Depos]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_Depos] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
	
	delete from [PT1].[WTOFXGMaster_CL_Depos]
		INSERT INTO
			[PT1].[WTOFXGMaster_CL_Depos]
			--FilevineStaging2Import.._fedexT_4__WTOFXGMaster_CL_Depos_18060
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [deponentType]
				, GeneralNotes
				, [docsDocExternalIdCsv]
				, deponentcontactexternalid
				, datescheduledDueDate
				, datescheduledDoneDate
			)
	
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.projectexternalid [ProjectExternalID]
			, d.collectionItemExternalID [CollectionItemExternalID]
			,d.[deponentType] deponentType
			, d.GeneralNotes GeneralNotes --[notes]
			, d.docs [docsDocExternalIdCsv]
			, d.deponent deponentcontactexternalid --[deponentName]
			, d.datescheduledDueDate datescheduledDueDate --[depoNoticeBy]
			, d.datescheduledDoneDate datescheduledDoneDate --[depoIsScheduledFor]
	-- select d.*
		FROM 	__FV_ClientCaseMap ccm	--	[dbo].[vw_PT_Defense_Depos]
		 inner join [dbo].[vw_PT_WTOFXGMaster_Depos] d
		 on ccm.projectexternalid = d.projectexternalid


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Details]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_Details]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_Details] has been created in [4982_Ronstadt_II] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
		
		INSERT INTO
			[PT1].[ContactsCustom__CustomFields_Details]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ContactCustomExternalID]
				, [salutation]
				, [abbreviatedName]
				, [specialty]
				, [isTextingPermitted]
				, [remarket]
				, [isMinor]
				, [gender]
				, [maritalStatus]
				, [language]
				, [driverLicenseNumber]
				, [fiduciary]
				, [ssn]
				, [barNumber]
				, [notes]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, [ContactCustomExternalID]
			, [salutation]
			, [abbreviatedName]
			, [specialty]
			, [isTextingPermitted]
			, [remarket]
			, [isMinor]
			, [gender]
			, [maritalStatus]
			, [language]
			, [driverLicenseNumber]
			, [fiduciary]
			, [ssn]
			, [barNumber]
			, [notes]
			

		FROM 
			[dbo].[vw_CT_Details]
		
		
		
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Documents]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_Documents]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 	SELECT '[filevine].[usp_insert_staging_Documents] has been created in database.  Please review and modifiy the procedure.';
		
	DELETE FROM 
	--filevinestaging2import.._FedexB_Test1_Documents___9941
	-- select * from 
	PT1.DOCUMENTS
	-- SELECT * FROM filevinestaging2import.._FedexB_Test1_Documents___9941
	WHERE 
		0 = 0;
	
	DECLARE 
		@CLIENTS3BUCKETPREFIX    VARCHAR(MAX),
		@ORGID INT;

	SELECT TOP 1 
		@CLIENTS3BUCKETPREFIX = LEFT(SOURCES3OBJECTKEY,CHARINDEX('/',SOURCES3OBJECTKEY) - 1)
	FROM DBO.S3DOCSCAN;
	
	SELECT 
		@ORGID = 7119 --LEFT(CLIENTS3BUCKETPREFIX_NOFILEVINEPREFIX, ISNULL(NULLIF(CHARINDEX('-',CLIENTS3BUCKETPREFIX_NOFILEVINEPREFIX),0)-1,LEN(CLIENTS3BUCKETPREFIX_NOFILEVINEPREFIX)))
	FROM
	(
		SELECT TOP 1
			REPLACE(@CLIENTS3BUCKETPREFIX,'filevine-','') AS CLIENTS3BUCKETPREFIX_NOFILEVINEPREFIX
	) AS X;

	/*#DOCFOLDERS: Identifies the Org Root Folder and cleans up data issues with the dbo.DocFolder table that could result in infinite recursion*/

	IF OBJECT_ID('tempdb.dbo.#DOCFOLDERS') IS NOT NULL
	BEGIN
		DROP TABLE #DOCFOLDERS;
	END;
	
	CREATE TABLE #DOCFOLDERS
	(
		ORGID                INT NULL,
		PROJECTID            INT NULL,
		FOLDERID             INT NOT NULL,
		PARENTID             INT NULL INDEX NCX_#DOCFOLDERS_PARENTID NONCLUSTERED,
		FOLDERNAME           VARCHAR(MAX) NOT NULL,
		IS_ORG_ROOTFOLDER    BIT NOT NULL
	);

	INSERT INTO #DOCFOLDERS
	(
		ORGID,
		PROJECTID,
		FOLDERID,
		PARENTID,
		FOLDERNAME,
		IS_ORG_ROOTFOLDER
	)
	SELECT 
		DF.ORGID,
		NULL AS PROJECTID,
		DF.ID AS FOLDERID,
		NULL AS PARENTID,
		CONVERT(VARCHAR(MAX),DF.NAME) AS FOLDERNAME,
		1 AS IS_ORG_ROOTFOLDER
	FROM DBO.DOCFOLDER AS DF
	WHERE DF.ORGID = 7119
		AND DF.PROJECTID IS NULL
		AND DF.PARENTID IS NULL
	UNION ALL
	SELECT 
		DF.ORGID,
		DF.PROJECTID,
		DF.ID AS FOLDERID,
		CASE
			WHEN DF.PARENTID = DF.ID
				THEN ISNULL(P.ROOTDOCFOLDERID,ORF.ID)
			ELSE DF.PARENTID
		END AS PARENTID,
		CONVERT(VARCHAR(MAX),DF.NAME) AS FOLDERNAME,
		0 AS IS_ORG_ROOTFOLDER
	FROM DBO.__FV_CLIENTCASEMAP AS CCM
	INNER JOIN DBO.DOCFOLDER AS DF
		ON DF.PROJECTID = CCM.PROJECTEXTERNALID
	LEFT JOIN DBO.PROJECT AS P
		ON P.ORGID = DF.ORGID AND P.ID = DF.PROJECTID
	LEFT JOIN DBO.DOCFOLDER AS ORF
		ON ORF.ORGID = DF.ORGID
		AND ORF.PROJECTID IS NULL
		AND ORF.PARENTID IS NULL
	WHERE DF.ORGID = 7119 --@ORGID
		AND DF.ISREMOVED = 0;

	/*#FOLDERPATHS: Results of recursive DocFolder folderpath builder for faster run time*/

	IF OBJECT_ID('tempdb.dbo.#FOLDERPATHS') IS NOT NULL
	BEGIN
		DROP TABLE #FOLDERPATHS;
	END;

	CREATE TABLE #FOLDERPATHS
	(
		ORGID         INT NOT NULL,
		PROJECTID     INT NULL,
		FOLDERID      INT NOT NULL,
		PARENTID      INT NULL,
		FOLDERNAME    VARCHAR(MAX) NOT NULL
	);

	WITH FOLDERPATHS
		 AS (SELECT 
				 RF.ORGID,
				 RF.PROJECTID,
				 RF.FOLDERID,
				 RF.PARENTID,
				 RF.FOLDERNAME
			 FROM #DOCFOLDERS AS RF
			 WHERE RF.IS_ORG_ROOTFOLDER = 1
			 UNION ALL
			 SELECT 
				 DF.ORGID,
				 DF.PROJECTID,
				 DF.FOLDERID,
				 DF.PARENTID,
				 FP.FOLDERNAME + '/' + DF.FOLDERNAME AS FOLDERNAME
			 FROM FOLDERPATHS AS FP
			 INNER JOIN #DOCFOLDERS AS DF
				 ON DF.PARENTID = FP.FOLDERID)
		 INSERT INTO #FOLDERPATHS
		 (
			 ORGID,
			 PROJECTID,
			 FOLDERID,
			 PARENTID,
			 FOLDERNAME
		 )
		 SELECT 
			 ORGID,
			 PROJECTID,
			 FOLDERID,
			 PARENTID,
			 FOLDERNAME
		 FROM FOLDERPATHS;

	/*#PROJECTFOLDERS: Mapping of Project ID and Project Root Folder Path for easy replacement to determine NewDocuments.DestinationFolderPath*/

	IF OBJECT_ID('tempdb.dbo.#PROJECTFOLDERS') IS NOT NULL
	BEGIN
		DROP TABLE #PROJECTFOLDERS;
	END;

	CREATE TABLE #PROJECTFOLDERS
	(
		PROJECTEXTERNALID      INT NOT NULL,
		PROJECTROOTFOLDER      VARCHAR(MAX) NOT NULL,
		PROJECTROOTFOLDERS3    VARCHAR(MAX) NOT NULL
	);

	INSERT INTO #PROJECTFOLDERS
	(
		PROJECTEXTERNALID,
		PROJECTROOTFOLDER,
		PROJECTROOTFOLDERS3
	)
	SELECT 
		CCM.PROJECTEXTERNALID,
		ORF.FOLDERNAME + '/' + PRF.FOLDERNAME AS PROJECTROOTFOLDER,
		PRF.FOLDERNAME AS PROJECTROOTFOLDERS3
	FROM DBO.__FV_CLIENTCASEMAP AS CCM
	INNER JOIN DBO.PROJECT AS P
		ON P.ID = CCM.PROJECTEXTERNALID
	INNER JOIN #DOCFOLDERS AS ORF
		ON ORF.ORGID = P.ORGID
		AND ORF.IS_ORG_ROOTFOLDER = 1
	INNER JOIN #DOCFOLDERS AS PRF
		ON PRF.ORGID = P.ORGID
		AND PRF.PROJECTID = P.ID
		AND PRF.FOLDERID = P.ROOTDOCFOLDERID;
		
	INSERT INTO 
	 [FilevineImport_ShardB].._FedExGround_Documents___3677
	--PT1.DOCUMENTS
	
	(
		__IMPORTSTATUS,
		__IMPORTSTATUSDATE,
		__ERRORMESSAGE,
		__WORKERID,
		__DOCID,
		DOCEXTERNALID,
		PROJECTEXTERNALID,
		FILEVINEPROJECTID,
		NOTEEXTERNALID,
		SOURCES3BUCKET,
		SOURCES3OBJECTKEY,
		SOURCES3OBJECTKEYENCODED,
		DESTINATIONFILENAME,
		DESTINATIONFOLDERPATH,
		UPLOADDATE,
		HASHTAGS,
		UPLOADEDBYUSERNAME,
		SECTIONSELECTOR,
		FIELDSELECTOR,
		COLLECTIONITEMEXTERNALID,
		ISRELOAD
	)
	SELECT distinct
		40 AS __IMPORTSTATUS,
		GETDATE() AS __IMPORTSTATUSDATE,
		NULL AS __ERRORMESSAGE,
		NULL AS __WORKERID,
		NULL AS __DOCID,
		D.ID AS DOCEXTERNALID,
		P.ID AS PROJECTEXTERNALID,
		NULL AS FILEVINEPROJECTID,
		N.NOTEEXTERNALID AS NOTEEXTERNALID,
		SDS.SOURCES3BUCKET AS SOURCES3BUCKET,
		SDS.SOURCES3OBJECTKEY AS SOURCES3OBJECTKEY,
		SDS.SOURCES3OBJECTKEYENCODED AS SOURCES3OBJECTKEYENCODED,
		D.FILENAME AS DESTINATIONFILENAME,
		NULLIF(CASE
				   WHEN FP.FOLDERNAME = PF.PROJECTROOTFOLDER
					   THEN REPLACE(FP.FOLDERNAME,PF.PROJECTROOTFOLDER,'')
				   ELSE REPLACE(FP.FOLDERNAME,PF.PROJECTROOTFOLDER + '/','')
			   END,'') AS DESTINATIONFOLDERPATH,
		D.UPLOADDATE AS UPLOADDATE,
		HT.HASHTAGS AS HASHTAGS,
		/*Docs uploaded via sms or other non-user referencing methods will need to have this field defaulted to a dummy user since this is validated against usernames*/
		ISNULL(U.FV_USERNAME,'formeremployee5') 
		AS UPLOADEDBYUSERNAME,
		NULL AS SECTIONSELECTOR,
		NULL AS FIELDSELECTOR,
		NULL AS COLLECTIONITEMEXTERNALID,
		NULL AS ISRELOAD
	
	FROM DBO.__FV_CLIENTCASEMAP AS CCM
	INNER JOIN DBO.DOC AS D
		ON D.PROJECTID = CCM.PROJECTEXTERNALID
	INNER JOIN DBO.PROJECT AS P
		ON P.ORGID = D.ORGID
		AND P.ID = CCM.PROJECTEXTERNALID
	INNER JOIN #DOCFOLDERS AS ORF
		ON ORF.ORGID = D.ORGID
		AND ORF.IS_ORG_ROOTFOLDER = 1
	INNER JOIN #FOLDERPATHS AS FP
		ON FP.ORGID = D.ORGID
		AND FP.PROJECTID = CCM.PROJECTEXTERNALID
		AND FP.FOLDERID = COALESCE(D.FOLDERID,P.ROOTDOCFOLDERID,ORF.FOLDERID)
	INNER JOIN DBO.S3DOCSCAN AS SDS
		/*Use Collation to perform Case-Sensitive matching*/
		--ON SDS.SOURCES3OBJECTKEY = 'filevine-7119-II/docs/'+ replace(fp.foldername,'Claiborne','Sullivan-Blake') + '/' + D.FILENAME COLLATE LATIN1_GENERAL_CS_AS
		ON replace(SDS.SOURCES3OBJECTKEY,'filevine-7119-II/','') = fp.foldername + '/' + D.FILENAME COLLATE LATIN1_GENERAL_CS_AS
	LEFT JOIN #PROJECTFOLDERS AS PF
		ON PF.PROJECTEXTERNALID = CCM.PROJECTEXTERNALID
	LEFT JOIN DBO.COMMENT AS CMT
		ON CMT.ID = IIF(D.DOCABLETYPE = 'Comment',D.DOCABLEID,NULL)
	--LEFT JOIN PT1.NEWNOTES AS N
	LEFT JOIN PT1.NOTES AS N
	

		ON N.NOTEEXTERNALID = CASE D.DOCABLETYPE
								  WHEN 'Note'
									  THEN D.DOCABLEID
								  WHEN 'Comment'
									  THEN CMT.NOTEID
							  END
	LEFT JOIN DBO.__FV_USERNAMES AS U
		ON U.LEGACY_USERNAME_ID = D.UPLOADERID
	--/* claiborne */
	--LEFt JOIN [PT1_CLIENT_ALIGN].[__FV_FedexClaiborneDocAlign] a
	--ON ccm.projectexternalid = a.projectexternalid
	--and p.projectname = a.projectname
	OUTER APPLY
	(
		SELECT 
			STUFF(
			(
				SELECT 
					',' + CONVERT(VARCHAR(MAX),DH.HASHTAG)
				FROM DBO.DOCHASHTAG AS DH
				WHERE DH.DOCID = D.ID FOR
				XML PATH('')
			),1,1,'') AS HASHTAGS
	) AS HT
	where sds.docid in (select docid from s3docscan where filecomplete in
(select filecomplete from S3DocScan
except
select DestinationFileName from [FilevineImport_ShardB].._FedExGround_Documents___3600))
	

	
	


	



	--SELECt *
	--FROM [PT1_CLIENT_ALIGN].[__FV_FedexClaiborneDocAlign]

	--SELECT *
	--FROM DBO.PROJECT
	

	/*In case of a mismatch between the database backup docs data (dbo.Doc) and the docs export (dbo.S3DocScan), import any remaining files contained in the Project Root Folders with defaults*/
	INSERT INTO 
	-- select * from
	PT1.DOCUMENTS -- DELETE FROM
	-- select * from
	--filevinestaging2import.._FedexB_Test1_Documents___9941
	(
		__IMPORTSTATUS,
		__IMPORTSTATUSDATE,
		__ERRORMESSAGE,
		__WORKERID,
		__DOCID,
		DOCEXTERNALID,
		PROJECTEXTERNALID,
		FILEVINEPROJECTID,
		NOTEEXTERNALID,
		SOURCES3BUCKET,
		SOURCES3OBJECTKEY,
		SOURCES3OBJECTKEYENCODED,
		DESTINATIONFILENAME,
		DESTINATIONFOLDERPATH,
		UPLOADDATE,
		HASHTAGS,
		UPLOADEDBYUSERNAME,
		SECTIONSELECTOR,
		FIELDSELECTOR,
		COLLECTIONITEMEXTERNALID,
		ISRELOAD
	)
	SELECT 
		40 AS __IMPORTSTATUS,
		GETDATE() AS __IMPORTSTATUSDATE,
		NULL AS __ERRORMESSAGE,
		NULL AS __WORKERID,
		NULL AS __DOCID,
		SDS.DOCID AS DOCEXTERNALID,
		PF.PROJECTEXTERNALID AS PROJECTEXTERNALID,
		NULL AS FILEVINEPROJECTID,
		NULL AS NOTEEXTERNALID,
		SDS.SOURCES3BUCKET AS SOURCES3BUCKET,
		SDS.SOURCES3OBJECTKEY AS SOURCES3OBJECTKEY,
		SDS.SOURCES3OBJECTKEYENCODED AS SOURCES3OBJECTKEYENCODED,
		SDS.FILECOMPLETE AS DESTINATIONFILENAME,
		NULLIF(CASE
				   WHEN SDS.FOLDERPATH = PF.PROJECTROOTFOLDERS3
					   THEN REPLACE(SDS.FOLDERPATH,PF.PROJECTROOTFOLDERS3,'')
				   ELSE REPLACE(SDS.FOLDERPATH,PF.PROJECTROOTFOLDERS3 + '/','')
			   END,'') AS DESTINATIONFOLDERPATH,
		/*Put at additional " AT TIME ZONE '<see sys.time_zone_info>' " for your timezone in between your datetime and the " AT TIME ZONE 'UTC' " to convert as needed*/
		CONVERT(DATETIME, GETDATE() AT TIME ZONE 'UTC') AS UPLOADDATE,
		NULL AS HASHTAGS,
		'formeremployee5' AS UPLOADEDBYUSERNAME,
		NULL AS SECTIONSELECTOR,
		NULL AS FIELDSELECTOR,
		NULL AS COLLECTIONITEMEXTERNALID,
		NULL AS ISRELOAD
	FROM #PROJECTFOLDERS AS PF
	INNER JOIN DBO.__FV_DOCUMENTS AS FVD
		ON FVD.FV_PROJECTID = PF.PROJECTEXTERNALID
	INNER JOIN DBO.S3DOCSCAN AS SDS
		ON SDS.ID = FVD.SCANID
	WHERE NOT EXISTS
	(
		SELECT 
			1
		FROM 
		PT1.DOCUMENTS AS D
	--	filevinestaging2import.._FedexB_Test1_Documents___9941 AS D
		WHERE D.SOURCES3OBJECTKEY = SDS.SOURCES3OBJECTKEY
	);
	
	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Experts]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_Experts]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_Experts] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/


		INSERT INTO
		--SELECt * FROM 
		[PT1].[WTOFXGMaster_CL_Experts]
		--	filevinestaging2import.._fedexT_4__WTOFXGMaster_CL_Experts_18062
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [expertContactExternalID]
				, [experttype]
				, [commentsgeneral]
				, [cvDocExternalID]
				, [reportDocExternalID]
				, [depositionsDocExternalIdCsv]
				, [referencematerialsDocExternalIdCsv]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, e.projectexternalid [ProjectExternalID]
			, e.CollectionItemExternalID [CollectionItemExternalID]
			, e.expert [expertnameContactExternalID] -- should match expertname
			, e.ExpertType [experttype]
			, e.commentsGeneral [commentsgeneral]
			, e.CV [cvDocExternalID]
			, e.report [reportDocExternalID]
			, e.depositionS [depositionsDocExternalIdCsv]
			, e.referenceMaterials [referencematerialsDocExternalIdCsv]
	-- SELECt * 
		FROM [dbo].[vw_PT_WTOFXGMaster_Experts] e


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Exposure]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_Exposure]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_Exposure] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		/*Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.*/
	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_INSTRUCTIONS]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_INSTRUCTIONS]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_INSTRUCTIONS] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _FedExGround_ */
		/*================================================================================================*/
		/*
		INSERT INTO
			[PT1].[NC_INSTRUCTIONS]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			
		
		FROM 
			__FV_ClientCaseMap ccm
		 
				INNER JOIN 
					[__FV_ProjectTemplateMap] ptm 
						ON ptm.Legacy_Case_ID = ccm.CaseID 
		
		
		*/
				


		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _WTOFXGMaster_ */
		/*================================================================================================*/
		/*
		INSERT INTO
			[PT1].[WTOFXGMaster_NC_INSTRUCTIONS]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			
		
		FROM 
			__FV_ClientCaseMap ccm
		 
				INNER JOIN 
					[__FV_ProjectTemplateMap] ptm 
						ON ptm.Legacy_Case_ID = ccm.CaseID 
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_KeyEventsDates]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_KeyEventsDates]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN -- 	SELECT 	'[filevine].[usp_insert_staging_KeyEventsDates] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'
			
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
	
		INSERT INTO
			[PT1].[WTOFXGMaster_NC_KeyEventsDates]
		--	filevinestaging2import.._fedexT_4__WTOFXGMaster_NC_KeyEventsDates_18054
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				, [trialDueDate]
				, [trialDoneDate]
				, [mediationSchedulingNeeded]
				, [mediationDueDate]
				, [mediationDoneDate]
				, [rule23CertificationDueDate]
				, [rule23CertificationDoneDate]
				, [initialCaseAssessmentDueDate]
				, [initialCaseAssessmentDoneDate]
				, [fLSAConditionalCertificationDueDate]
				, [fLSAConditionalCertificationDoneDate]
				, [summaryJudgmentDateDueDate]
				, [summaryJudgmentDateDoneDate]
				, [discoveryCutoffDateDueDate]
				, [discoveryCutoffDateDoneDate]
				, [rule23]
				, [fLSAConditionalCertificationapp]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, K.[trialDueDate] [trialDueDate]
			, K.[trialDoneDate] [trialDoneDate]
			, K.[mediationSchedulingNeeded] [mediationSchedulingNeeded]
			, K.[mediationDueDate] [mediationDueDate]
			, K.[mediationDoneDate] [mediationDoneDate]
			, K.[rule23CertificationDueDate] [rule23CertificationDueDate]
			, K.[rule23CertificationDoneDate] [rule23CertificationDoneDate]
			, K.[initialCaseAssessmentDueDate] [initialCaseAssessmentDueDate]
			, K.[initialCaseAssessmentDoneDate] [initialCaseAssessmentDoneDate]
			, K.[fLSAConditionalCertificationDueDate] [fLSAConditionalCertificationDueDate]
			, K.[fLSAConditionalCertificationDoneDate] [fLSAConditionalCertificationDoneDate]
			, K.[summaryJudgmentDateDueDate] [summaryJudgmentDateDueDate]
			, K.[summaryJudgmentDateDoneDate] [summaryJudgmentDateDoneDate]
			, K.[discoveryCutoffDateDueDate] [discoveryCutoffDateDueDate]
			, K.[discoveryCutoffDateDoneDate] [discoveryCutoffDateDoneDate]
			, K.[rule23] [rule23]
			, K.[fLSAConditionalCertificationapp] [fLSAConditionalCertificationapp]	
	-- SELECT K.*
		FROM __FV_ClientCaseMap ccm
		INNER JOIN [dbo].[vw_PT_WTOFXGMaster_KeyEventsDates] K
			ON CCM.PROJECTEXTERNALID = K.PROJECTEXTERNALID
		
		

				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_LitigationTaskflows]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_LitigationTaskflows]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_LitigationTaskflows] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _Defense_ */
		/*================================================================================================*/
		/*
		INSERT INTO
			[PT1].[Defense_NC_LitigationTaskflows]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			
		
		FROM 
			__FV_ClientCaseMap ccm
		 
				INNER JOIN 
					[__FV_ProjectTemplateMap] ptm 
						ON ptm.Legacy_Case_ID = ccm.CaseID 
		
		
		*/
				


		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _WTOFXGMaster_ */
		/*================================================================================================*/
		/*
		INSERT INTO
			[PT1].[WTOFXGMaster_NC_LitigationTaskflows]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			
		
		FROM 
			__FV_ClientCaseMap ccm
		 
				INNER JOIN 
					[__FV_ProjectTemplateMap] ptm 
						ON ptm.Legacy_Case_ID = ccm.CaseID 
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_MailroomItems]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_MailroomItems]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_MailroomItems] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _ */
		/*================================================================================================*/
		/*
		INSERT INTO
			[PT1].[MailroomItems]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__NoteID]
				, [MailroomExternalID]
				, [ProjectExternalID]
				, [CreateDate]
				, [From]
				, [To]
				, [CC]
				, [Subject]
				, [Body]
				, [emailFile_S3Bucket]
				, [emailFile_S3ObjectKey]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__NoteID]
			, NULL [MailroomExternalID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, [Filevine_META].dbo.udfDate_ConvertUTC([CreateDate], 'Eastern' , 1) [CreateDate]
			, NULL [From]
			, NULL [To]
			, NULL [CC]
			, NULL [Subject]
			, NULL [Body]
			, NULL [emailFile_S3Bucket]
			, NULL [emailFile_S3ObjectKey]
			
		
		FROM 
			__FV_ClientCaseMap ccm
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Negotiations]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_Negotiations]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_Negotiations] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
		
		INSERT INTO
			[PT1].[WTOFXGMaster_CL_Negotiations]
			
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				,[ProjectExternalID]
				,[CollectionItemExternalID]
				,[demandoffersettled]
				,[amount]
				,[date]
				,[notes]
				,[docsDocExternalIdCsv]
				,[tofrom]
				,[fXGContribution]
				,[sPContribution]
				,[fXGContributionType]
			)
	SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItem Guid]
			, ccm.[ProjectExternalID]
			, [CollectionItemExternalID]
			,[demandoffersettled]
			,[amount]
			,[date]
			,[notes]
			,[docs]
			,[tofrom]
			,[fXGContribution]
			,[sPContribution]
			,[fXGContributionType]
	 
		FROM __FV_ClientCaseMap ccm
		INNER JOIN [7119_FedEx_II_r2].[dbo].[vw_PT_WTOFXGMaster_Negotiations] N
			ON CCM.PROJECTEXTERNALID = N.PROJECTEXTERNALID

				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Notes]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_Notes]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	DELETE FROM PT1.NOTES
	WHERE 
		0 = 0;

	INSERT INTO 
-- select * from
	PT1.NOTES
--	filevinestaging2import.._fedexT_4_Notes___18046
	(
		__IMPORTSTATUS,
		__IMPORTSTATUSDATE,
		__ERRORMESSAGE,
		__WORKERID,
		__NOTEID,
		NOTEEXTERNALID,
		PROJECTEXTERNALID,
		AUTHOR,
		BODY,
		CREATEDATE,
		ASSIGNEE,
		TARGETDATE,
		COMPLETEDDATE
	)
	SELECT 
	__IMPORTSTATUS,
		__IMPORTSTATUSDATE,
		__ERRORMESSAGE,
		__WORKERID,
		__NOTEID,
		NOTEEXTERNALID,
		PROJECTEXTERNALID,
		CASE
			WHEN ASSIGNEE = 'jessica22'
			THEN 'scott7'
			WHEN ASSIGNEE= 'stephanie49'
			THEN 'stephanie8'
			when assignee is null 
			Then 'datamigrationteam101'
			ELSE ASSIGNEE
		END AS AUTHOR,
		BODY,
		CREATEDATE,
		CASE
			WHEN ASSIGNEE = 'jessica22'
			THEN 'scott7'
			WHEN ASSIGNEE= 'stephanie49'
			THEN 'stephanie8'
			when assignee is null 
			Then 'datamigrationteam101'
			ELSE ASSIGNEE
		END AS ASSIGNEE,
		TARGETDATE,
		COMPLETEDDATE
	FROM (
	SELECT 
		40 AS __IMPORTSTATUS,
		GETDATE() AS __IMPORTSTATUSDATE,
		NULL AS __ERRORMESSAGE,
		NULL AS __WORKERID,
		NULL AS __NOTEID,
		CONVERT(VARCHAR(64),N.ID) AS NOTEEXTERNALID,
		CCM.PROJECTEXTERNALID AS PROJECTEXTERNALID,
		ISNULL(ATH.FV_USERNAME,'datamigrationteam101') AS AUTHOR,
		IIF(N.TYPETAG NOT IN('note','task'),'#' + N.TYPETAG + CHAR(10), '')
			+ IIF(ISPINNEDTOPROJECT = 1,'#pinned' + CHAR(10), '')
			+ ISNULL(NULLIF(N.BODY,''),'(no note body)')
			+ IIF(NULLIF(CMT.FORMATTED_COMMENT_CHAIN, '') IS NOT NULL, CHAR(10) + CHAR(10) + 'Comments:' + CHAR(10) + CMT.FORMATTED_COMMENT_CHAIN, '') AS BODY,
		IIF(N.CREATEDAT > GETDATE(),GETDATE(),N.CREATEDAT) AS CREATEDATE,
		--CASE WHEN 
		IIF(N.TYPETAG = 'task',ISNULL(ASN.FV_USERNAME,'datamigrationteam101'),NULL) --= 'jessica22'
			--THEN 'scott7'		END 
		AS ASSIGNEE,
		N.TARGETDATE AS TARGETDATE,
		N.COMPLETEDDATE AS COMPLETEDDATE
	FROM __FV_CLIENTCASEMAP AS CCM
	INNER JOIN NOTE AS N
		ON N.PROJECTID = CCM.PROJECTEXTERNALID
			AND N.ISREMOVED = 0
			AND IIF(NULLIF(N.BODY,'') IS NULL AND N.TYPETAG = 'note',1,0) = 0
	LEFT JOIN __FV_USERNAMES AS ATH
		ON ATH.LEGACY_USERNAME_ID = N.AUTHORID
	LEFT JOIN __FV_USERNAMES AS ASN
		ON ASN.LEGACY_USERNAME_ID = N.ASSIGNEEID
	OUTER APPLY
	(
		SELECT 
			STUFF(
			(
				SELECT
					CHAR(10) + CHAR(10)
					/*Formatting Comment Body for concatenation to have threads*/
					+ C.BODY
					+ CHAR(10)
					+ 'Posted by '
					+ IIF(CAU.FIRSTNAME IS NOT NULL, CAU.FIRSTNAME, '')
					+ IIF(CAU.LASTNAME IS NOT NULL, ' ' + CAU.LASTNAME, '')
					+ IIF(CAU.FIRSTNAME IS NULL AND CAU.LASTNAME IS NULL, CAU.LEGACY_USERNAME, '')
					+ ' on '
					/*Change the second " AT TIME ZONE 'UTC' " to the correct value from sys.time_zone_info in order to convert the timestamp text to the client specific timezone*/
					+ FORMAT(C.CREATEDAT AT TIME ZONE 'UTC' AT TIME ZONE 'UTC' , 'M/d/yyyy hh:mm tt') AS FORMATTED_COMMENT_BODY
				FROM COMMENT AS C
				LEFT JOIN __FV_USERNAMES AS CAU
					ON CAU.LEGACY_USERNAME_ID = C.AUTHORID
				WHERE C.ISREMOVED = 0
					AND NULLIF(C.BODY,'') IS NOT NULL
					AND C.NOTEID = N.ID 
					FOR
				XML PATH(''),TYPE
			).value('.','nvarchar(max)'),1,1,'') AS FORMATTED_COMMENT_CHAIN
	) AS CMT
	) a;


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_OpposingCounsel]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_OpposingCounsel]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_OpposingCounsel] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _Defense_ */
		/*================================================================================================*/
		/*
		INSERT INTO
			[PT1].[Defense_NC_OpposingCounsel]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				, [number]
				, [opposingcounself1ContactExternalID]
				, [opposingcounsel2ContactExternalID]
				, [opposingcounsel3ContactExternalID]
				, [opposingcounsel4ContactExternalID]
				, [opposing5ContactExternalID]
				, [opposing6]
				, [plaintiff1ContactExternalID]
				, [plaintiff2ContactExternalID]
				, [plaintiff3ContactExternalID]
				, [plaintiff4ContactExternalID]
				, [plaintiff5]
				, [plaintiffs6ormore]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [number]
			, NULL [opposingcounself1ContactExternalID]
			, NULL [opposingcounsel2ContactExternalID]
			, NULL [opposingcounsel3ContactExternalID]
			, NULL [opposingcounsel4ContactExternalID]
			, NULL [opposing5ContactExternalID]
			, NULL [opposing6]
			, NULL [plaintiff1ContactExternalID]
			, NULL [plaintiff2ContactExternalID]
			, NULL [plaintiff3ContactExternalID]
			, NULL [plaintiff4ContactExternalID]
			, NULL [plaintiff5]
			, NULL [plaintiffs6ormore]
			
		
		FROM 
			__FV_ClientCaseMap ccm
		 
				INNER JOIN 
					[__FV_ProjectTemplateMap] ptm 
						ON ptm.Legacy_Case_ID = ccm.CaseID 
		
		
		*/
				


		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _FedExGround_ */
		/*================================================================================================*/
		/*
		INSERT INTO
			[PT1].[NC_OpposingCounsel]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				, [opposingCounselNameContactExternalID]
				, [comments]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [opposingCounselNameContactExternalID]
			, NULL [comments]
			
		
		FROM 
			__FV_ClientCaseMap ccm
		 
				INNER JOIN 
					[__FV_ProjectTemplateMap] ptm 
						ON ptm.Legacy_Case_ID = ccm.CaseID 
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_OptIns]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_OptIns]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_OptIns] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
		

		INSERT INTO
			[PT1].[WTOFXGMaster_CL_OptIns]
			
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [discoveryPool]
				, [optInFormDocExternalID]
				, [discoveryDocExternalID]
				, [depositionsDocExternalID]
				, [documentsDocExternalID]
				, [BegDate]
				, [endDate]
				, [fedExStation]
				, [zipCode]
				, [lastName]
				, [firstName]
				, [anotherStation]
				, [fedExStation2]
				, [zipCode2]
				, [moreStations]
				, [fedExStation3]
				, [zipCode3]
				, [station]
				, [station2]
				, [station3]
				, [notesReQuestionnaires]
				, [sPName1]
				, [begDateSP1]
				, [endDateSP1]
				, [rate1]
				, [bonus]
				, [anotherStation_1]
				, [sPName2]
				, [begDateSP2]
				, [endDateSP2]
				, [rate2]
				, [bonus2]
				, [anotherSP]
				, [sPName3]
				, [begDateSP3]
				, [endDateSP3]
				, [rate3]
				, [bonus3]
				, [additionalSP]
				, [sPName4]
				, [begDateSP4]
				, [endDateSP4]
				, [zipCode2_1]
				, [zipCode3_1]
				, [zipCode_1]
				, [rate4]
				, [bonus4]
				, [additionalSP_1]
				, [sPName5]
				, [begDateSP5]
				, [endDateSP5]
				, [rate5]
				, [bonus5]
				, [moreSP]
				, [sPName6]
				, [begDateSP6]
				, [endDateSP6]
				, [rate6]
				, [bonus6]
				, [moreSP_1]
				, [sPName7]
				, [begDateSP7]
				, [endDateSP7]
				, [rate7]
				, [bonus7]
				, [addSP]
				, [sPName8]
				, [begDateSP8]
				, [endDateSP8]
				, [rate8]
				, [bonus8]
				, [notesFromSPInterviews]
				, [notesFromFXGManagers]
				, [discoveryCandidate]
				, [documents_1DocExternalIdCsv]
				, [collectionItemExported]
				
			)
		
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, o.[CollectionItemExternalID] [CollectionItemExternalID]
			, o.[discoveryPool] [discoveryPool]
			, o.optinform [optInFormDocExternalID]
			, o.discovery [discoveryDocExternalID]
			, o.depositions [depositionsDocExternalID]
			, o.documents [documentsDocExternalID]
			, o.begdate [BegDate]
			, o.enddate [endDate]
			, o.[fedExStation] [fedExStation]
			, o.[zipCode] [zipCode]
			, o.[lastName] [lastName]
			, o.[firstName] [firstName]
			, o.[anotherStation] [anotherStation]
			, o.[fedExStation2] [fedExStation2]
			, o.zipcode_1 [zipCode2]
			, o.[moreStations] [moreStations]
			, o.[fedExStation3] [fedExStation3]
			, o.[zipCode3] [zipCode3]
			, o.[station] [station]
			, o.[station2] [station2]
			, o.[station3] [station3]
			, o.[notesReQuestionnaires] [notesReQuestionnaires]
			, o.[sPName1] [sPName1]
			, o.[begDateSP1] [begDateSP1]
			, o.[endDateSP1] [endDateSP1]
			, o.[rate1] [rate1]
			, o.[bonus] [bonus]
			, o.[anotherStation_1] [anotherStation_1]
			, o.[sPName2] [sPName2]
			, o.[begDateSP2] [begDateSP2]
			, o.[endDateSP2] [endDateSP2]
			, o.[rate2] [rate2]
			, o.[bonus2] [bonus2]
			, o.[anotherSP] [anotherSP]
			, o.[sPName3] [sPName3]
			, o.[begDateSP3] [begDateSP3]
			, o.[endDateSP3] [endDateSP3]
			, o.[rate3] [rate3]
			, o.[bonus3] [bonus3]
			, o.[additionalSP] [additionalSP]
			, o.[sPName4] [sPName4]
			, o.[begDateSP4] [begDateSP4]
			, o.[endDateSP4] [endDateSP4]
			, o.[zipCode2_1] [zipCode2_1]
			, o.[zipCode3_1] [zipCode3_1]
			, o.[zipCode_1] [zipCode_1]
			, o.[rate4] [rate4]
			, o.[bonus4] [bonus4]
			, o.[additionalSP_1] [additionalSP_1]
			, o.[sPName5] [sPName5]
			, o.[begDateSP5] [begDateSP5]
			, o.[endDateSP5] [endDateSP5]
			, o.[rate5] [rate5]
			, o.[bonus5] [bonus5]
			, o.[moreSP] [moreSP]
			, o.[sPName6] [sPName6]
			, o.[begDateSP6] [begDateSP6]
			, o.[endDateSP6] [endDateSP6]
			, o.[rate6] [rate6]
			, o.[bonus6] [bonus6]
			, o.[moreSP_1] [moreSP_1]
			, o.[sPName7] [sPName7]
			, o.[begDateSP7] [begDateSP7]
			, o.[endDateSP7] [endDateSP7]
			, o.[rate7] [rate7]
			, o.[bonus7] [bonus7]
			, o.[addSP] [addSP]
			, o.[sPName8] [sPName8]
			, o.[begDateSP8] [begDateSP8]
			, o.[endDateSP8] [endDateSP8]
			, o.[rate8] [rate8]
			, o.[bonus8] [bonus8]
			, o.[notesFromSPInterviews] [notesFromSPInterviews]
			, o.[notesFromFXGManagers] [notesFromFXGManagers]
			, o.[discoveryCandidate] [discoveryCandidate]
			, o.documents_1 [documents_1DocExternalIdCsv]
			, o.[collectionItemExported] [collectionItemExported]		
-- select o.*
		FROM __FV_ClientCaseMap ccm
		inner join [dbo].[vw_PT_WTOFXGMaster_Opt-Ins] o
			on ccm.projectexternalid = o.projectexternalid
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Parties]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREAte   PROCEDURE
	[filevine].[usp_insert_staging_Parties]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_Parties] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
		
		INSERT INTO
			[PT1].[WTOFXGMaster_CL_Parties]
		
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [partyType]
				, [otherExplanation]
				, [partyContactExternalID]
				, [comments]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, p.[CollectionItemExternalID] [CollectionItemExternalID]
			, p.[partyType] [partyType]
			, p.[otherExplanation] [otherExplanation]
			, p.party [partyContactExternalID]
			, p.comments [comments]
-- select p.*		
		FROM __FV_ClientCaseMap ccm
		inner join [dbo].[vw_PT_WTOFXGMaster_Parties] p
			on ccm.projectexternalid = p.projectexternalid		


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_PlaintiffMgt]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_PlaintiffMgt]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_PlaintiffMgt] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		/*Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.*/
	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_PotentialExposure]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_PotentialExposure]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_PotentialExposure] has been created in [7119_FedEx_II_r2] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: __ */
		/*================================================================================================*/
	

		INSERT INTO
			[PT1].[WTOFXGMaster_CL_PotentialExposure]
			
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__CollectionItemGuid]
				, [ProjectExternalID]
				, [CollectionItemExternalID]
				, [newExposure]
				, [date]
				, [commentsPleaseFillOut]
				
			)
			SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__CollectionItemGuid]
			, ccm.ProjectExternalID [ProjectExternalID]
			, PE.COLLECTIONITEMEXTERNALID [CollectionItemExternalID]
			, PE.[newExposure] [newExposure]
			, PE.[date] [date]
			, PE.[commentsPleaseFillOut] [commentsPleaseFillOut]
	-- select PE.*		
		FROM __FV_ClientCaseMap ccm
		INNER JOIN [dbo].[vw_PT_WTOFXGMaster_PotentialExposure] PE
			ON CCM.PROJECTEXTERNALID = PE.PROJECTEXTERNALID
		
		
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_ProjectContacts]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_ProjectContacts]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	DELETE FROM PT1.PROJECTCONTACTS
	WHERE 
		0 = 0;

	INSERT INTO 
	-- select * from 
	PT1.PROJECTCONTACTS

	(
		__IMPORTSTATUS,
		__IMPORTSTATUSDATE,
		__ERRORMESSAGE,
		__WORKERID,
		__CONTACTID,
		PROJECTEXTERNALID,
		CONTACTEXTERNALID,
		ROLE
	)
	SELECT 
		40 AS __IMPORTSTATUS,
		GETDATE() AS __IMPORTSTATUSDATE,
		NULL AS __ERRORMESSAGE,
		NULL AS __WORKERID,
		NULL AS __CONTACTID,
		CCM.PROJECTEXTERNALID AS PROJECTEXTERNALID,
		PC.Personid  AS CONTACTEXTERNALID,
		NULLIF(PC.ROLE,'') AS ROLE
-- select * 
	FROM DBO.__FV_CLIENTCASEMAP AS CCM
	INNER JOIN DBO.CONTACT AS PC
		ON PC.PROJECTID = CCM.PROJECTEXTERNALID
	;

	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_ProjectPermissions]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_ProjectPermissions]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	DELETE FROM PT1.PROJECTPERMISSIONS
	WHERE 
		0 = 0;

	INSERT INTO 
	-- select * from
	PT1.PROJECTPERMISSIONS
	
	(
		__IMPORTSTATUS,
		__IMPORTSTATUSDATE,
		__ERRORMESSAGE,
		__WORKERID,
		__PERMISSIONID,
		PROJECTEXTERNALID,
		USERNAME,
		ISPRIMARY,
		ISFIRSTPRIMARY,
		ISFOLLOWER,
		ACCESSLEVEL,
		ROLE1,
		ROLE2,
		ROLE3
	)
	SELECT distinct
		40 AS __IMPORTSTATUS,
		GETDATE() AS __IMPORTSTATUSDATE,
		NULL AS __ERRORMESSAGE,
		NULL AS __WORKERID,
		NULL AS __PERMISSIONID,
		CCM.PROJECTEXTERNALID AS PROJECTEXTERNALID,
		ISNULL(U.FV_USERNAME, 'datamigrationteam101') AS USERNAME,
		P.ISPRIMARY AS ISPRIMARY,
		0 AS ISFIRSTPRIMARY,
		P.FOLLOW AS ISFOLLOWER,
		CASE P.ACCESSLEVEL
			WHEN 3
				THEN 'ADMIN'
			WHEN 2
				THEN 'FULL'
			WHEN 1
				THEN 'GUEST'
		END AS ACCESSLEVEL,
		PRR.ROLE1 AS ROLE1,
		PRR.ROLE2 AS ROLE2,
		PRR.ROLE3 AS ROLE3
	FROM DBO.__FV_CLIENTCASEMAP AS CCM
	INNER JOIN DBO.PERMISSION AS P
		ON P.PROJECTID = CCM.PROJECTEXTERNALID
	LEFT JOIN DBO.__FV_USERNAMES AS U
		ON U.LEGACY_USERNAME_ID = P.USERID
	OUTER APPLY
	(
		SELECT 
			MAX(IIF(ROLE_SEQ = 1,ROLE,NULL)) AS ROLE1,
			MAX(IIF(ROLE_SEQ = 2,ROLE,NULL)) AS ROLE2,
			MAX(IIF(ROLE_SEQ = 3,ROLE,NULL)) AS ROLE3
		FROM
		(
			SELECT 
				PR.PERMISSIONID,
				R.NAME AS ROLE,
				ROW_NUMBER() OVER(PARTITION BY PR.PERMISSIONID
				ORDER BY 
				PR.ID) AS ROLE_SEQ
			FROM DBO.PERMISSIONROLE AS PR
			INNER JOIN DBO.ROLE AS R
				ON R.ID = PR.OrgRoleID
			WHERE PR.PERMISSIONID = P.ID
		) AS ORDERED_PERMISSIONROLES
	) AS PRR

	END
			
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_Projects]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   PROCEDURE
	[filevine].[usp_insert_staging_Projects]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
	DELETE FROM PT1.PROJECTS
	WHERE 
		0 = 0;

	INSERT INTO 
-- SELECt * FROM 
	PT1.PROJECTS
	--filevinestaging2import.._fedexT_4_Projects___18044
	(
		__IMPORTSTATUS,
		__IMPORTSTATUSDATE,
		__ERRORMESSAGE,
		__WORKERID,
		__PROJECTID,
		PROJECTEXTERNALID,
		CONTACTEXTERNALID,
		PROJECTNAME,
		PROJECTTEMPLATE,
		INCIDENTDATE,
		INCIDENTDESCRIPTION,
		ISARCHIVED,
		PHASENAME,
		PHASEDATE,
		HASHTAGS,
		USERNAME,
		CREATEDATE,
		PROJECTNUMBER,
		PROJECTEMAILPREFIX
	)
	SELECT DISTINCT 
		0 AS __IMPORTSTATUS,
		GETDATE() AS __IMPORTSTATUSDATE,
		NULL AS __ERRORMESSAGE,
		NULL AS __WORKERID,
		NULL AS __PROJECTID,
		CCM.PROJECTEXTERNALID AS PROJECTEXTERNALID,
		CCM.CONTACTEXTERNALID AS CONTACTEXTERNALID,
		P.PROJECTNAME AS PROJECTNAME,
		PT.NAME AS PROJECTTEMPLATE,
		P.INCIDENTDATE AS INCIDENTDATE,
		P.DESCRIPTION AS INCIDENTDESCRIPTION,
		PH.ISPERMANENT AS ISARCHIVED,
		PH.NAME AS PHASENAME,
		P.PHASEDATE AS PHASEDATE,
		HT.HASHTAGS AS HASHTAGS,
		ISNULL(FP.FV_USERNAME, 'datamigrationteam') AS USERNAME,
		P.CREATEDATE AS CREATEDATE,
		P.NUMBER AS PROJECTNUMBER,
		NULL AS PROJECTEMAILPREFIX/*Unable to use P.UNIQUEKEY here since the project email address needs to be unique across all of filevine*/
	-- select *
	FROM DBO.__FV_CLIENTCASEMAP AS CCM
	INNER JOIN DBO.PROJECT AS P
		ON P.ID = CCM.PROJECTEXTERNALID AND P.CLIENTID = CCM.CONTACTEXTERNALID
	INNER JOIN DBO.CUSTOMPROJECTTYPE AS PT
		ON PT.ID = P.CUSTOMPROJECTTYPEID
	INNER JOIN DBO.PHASE AS PH
		ON PH.ID = P.PHASEID AND PH.CUSTOMPROJECTTYPEID = PT.ID
	LEFT JOIN DBO.__FV_USERNAMES AS FP
		ON FP.LEGACY_USERNAME_ID = P.FIRSTPRIMARYUSERID
	OUTER APPLY
	(
		SELECT 
			STUFF(
			(
				SELECT 
					',' + CONVERT(VARCHAR(MAX),PH.HASHTAG)
				FROM DBO.PROJECTHASHTAG AS PH
				WHERE PH.PROJECTID = P.ID FOR
				XML PATH('')
			),1,1,'') AS HASHTAGS
	) AS HT;


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_ProjectSectionVisibilityImporter]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_ProjectSectionVisibilityImporter]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_ProjectSectionVisibilityImporter] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _ */
		/*================================================================================================*/
		/*
		INSERT INTO
			[PT1].[ProjectSectionVisibilityImporter]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__ProjectSectionVisibilityImporterID]
				, [ProjectExternalID]
				, [SectionSelector]
				, [ShowSection]
				
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__ProjectSectionVisibilityImporterID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [SectionSelector]
			, NULL [ShowSection]
			
		
		FROM 
			__FV_ClientCaseMap ccm
		
		
		*/
				


	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_SignificantDev]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_SignificantDev]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_SignificantDev] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		/*Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.*/
	END
														
GO
/****** Object:  StoredProcedure [filevine].[usp_insert_staging_VenueJudge]    Script Date: 4/27/2022 2:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE
	[filevine].[usp_insert_staging_VenueJudge]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT 
			'[filevine].[usp_insert_staging_VenueJudge] has been created in [7119_FedEx_II_gl] database.  Please review and modifiy the procedure.'

		/*Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.*/
	END
														
GO
