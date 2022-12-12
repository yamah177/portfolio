USE [7119_FedEx_II_r1];
--USE [5377_WEIGAND_II_R2];
GO

CREATE OR ALTER PROCEDURE FILEVINE.USP_GENERATE_CUSTOMTEMPLATEPROCEDUREINSERTS 
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
			 FROM [PT1].[TempSPMap__FedexB_Test1_] AS TSM
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