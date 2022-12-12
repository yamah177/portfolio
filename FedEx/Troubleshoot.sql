	
	
	SELECT *
	FROM 	FilevineStaging2Import.._FedexB_Test1_Projects___9909 p
	WHERE __projectid = 1921508

	SELECt *
	FROM filevinestaging2import.._FedexB_Test1__WTOFXGMaster_NC_CaseSummary_11514
	WHERE projectexternalid = '6715702'

	
-- proc that builds this [__FV_ProjectCustomFieldMetadata] and find table and see data there.


usp generate insertcustom field metadata



This one: [filevine].[usp_insert_reference_ProjectCustomFieldMetadata]

 	, d.docs [docsDocExternalIdCsv]
			, d.deponent deponentcontactexternalid --[deponentName]
			[7119_FedEx_II_r1].[dbo].[vw_PT_WTOFXGMaster_Depos] d
			find data types, find these columns in metadata and figure out.

ALTER   PROCEDURE [filevine].[usp_insert_reference_ProjectCustomFieldMetadata]
