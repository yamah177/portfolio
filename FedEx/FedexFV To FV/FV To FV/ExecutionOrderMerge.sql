USE [990000278_Merricks];
GO

WITH LSPEO_NEWENTRIES AS
(
	SELECT
		DB.LG_DB_ID AS LEGACYDBID,
		SP.LEGACYSPID AS LEGACYSPID,
		990000278 AS ORGID,
		'_T1Merricks_' AS FVPRODPREFIX,
		CASE SP.LEGACYSPNAME
			WHEN 'usp_insert_reference_Usernames'						THEN 200		
			WHEN 'usp_insert_reference_ClientCaseMap'					THEN 400		
			WHEN 'usp_insert_staging_Contacts'							THEN 500		
			WHEN 'usp_insert_staging_CalendarEvents'					THEN 700		
			WHEN 'usp_insert_staging_Deadlines'							THEN 700		
			WHEN 'usp_insert_staging_Notes'								THEN 700		
			WHEN 'usp_insert_staging_ProjectContacts'					THEN 700		
			WHEN 'usp_insert_staging_ProjectPermissions'				THEN 700		
			WHEN 'usp_insert_reference_Documents'						THEN 800		
			WHEN 'usp_insert_staging_Documents'							THEN 900		
			WHEN 'usp_insert_reference_ProjectCustomFieldMetaData'		THEN 910		
			WHEN 'usp_insert_reference_ContactCustomFieldMetaData'		THEN 910		
			WHEN 'usp_generate_ProjectCustomViews'						THEN 920		
			WHEN 'usp_generate_ContactCustomViews'						THEN 920
			WHEN 'usp_generate_CustomTemplateProcedureInserts'			THEN 930
		END AS EXECUTIONORDER,
		1 AS ACTIVE,
		GETDATE() AS CREATEDDATE,
		NULL AS MODIFIEDDATE
	FROM FILEVINE_META.DBO.LEGACY_DATABASE AS DB
	INNER JOIN FILEVINE_META.DBO.LEGACYSP AS SP
		ON SP.LEGACYSPNAME IN
		(
			'usp_insert_reference_Usernames'								,
			'usp_insert_reference_ClientCaseMap'						   ,
			'usp_insert_staging_Contacts'								   ,
			'usp_insert_staging_CalendarEvents'							   ,
			'usp_insert_staging_Deadlines'								   ,
			'usp_insert_staging_Notes'									   ,
			'usp_insert_staging_ProjectContacts'						   ,
			'usp_insert_staging_ProjectPermissions'						   ,
			'usp_insert_reference_Documents'							   ,
			'usp_insert_staging_Documents'								   ,
			'usp_insert_reference_ProjectCustomFieldMetaData'			   ,
			'usp_insert_reference_ContactCustomFieldMetaData'			   ,
			'usp_generate_ProjectCustomViews'							   ,
			'usp_generate_ContactCustomViews'							   ,
			'usp_generate_CustomTemplateProcedureInserts'
		)
	WHERE DB.LG_DB_NAME = 'Filevine'
)
MERGE INTO PT1.LEGACYSPEXECUTIONORDER AS DEST
USING LSPEO_NEWENTRIES AS SRC
    ON DEST.LEGACYDBID = SRC.LEGACYDBID
	AND DEST.LEGACYSPID = SRC.LEGACYSPID
	AND DEST.ORGID = SRC.ORGID
	AND DEST.FVPRODPREFIX = SRC.FVPRODPREFIX
WHEN MATCHED
	THEN UPDATE SET DEST.EXECUTIONORDER = SRC.EXECUTIONORDER
WHEN NOT MATCHED BY TARGET
	THEN 
        INSERT
		(
			LEGACYDBID,
			LEGACYSPID,
			ORGID,
			FVPRODPREFIX,
			EXECUTIONORDER,
			ACTIVE,
			CREATEDDATE,
			MODIFIEDDATE
		)  
        VALUES
		(
			SRC.LEGACYDBID,
			SRC.LEGACYSPID,
			SRC.ORGID,
			SRC.FVPRODPREFIX,
			SRC.EXECUTIONORDER,
			SRC.ACTIVE,
			SRC.CREATEDDATE,
			SRC.MODIFIEDDATE
		)
OUTPUT DELETED.*, INSERTED.*;