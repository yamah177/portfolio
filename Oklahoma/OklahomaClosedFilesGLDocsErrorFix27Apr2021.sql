	---- open docs load
	--SELECT count(*), __importstatus
	--FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59011
	--group by __importstatus -- 21052

	--SELECT count(*), __errormessage
	--FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59011
	--group by __errormessage

	--SELECt *
	-- FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59011
	--WHERE __errormessage = 'cannot find matching project for ProjectExternalID'
	---- 11096 closed folderpath in the open load. THESE ARE OKAY


	--SELECt distinct destinationfolderpath
	-- 	 FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59011
	--	 	WHERE __errormessage = 'cannot find matching project for ProjectExternalID'



	--SELECt *
	--FROM 		filevineproductionimport.._OklahomaLegalService_Projects___59009
	--WHERE projectexternalid like '%%Conway%Ronald%%'
	

	-- closed load

	SELECT count(*), __importstatus
	FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59056
	--where __errormessage <> 'invalid filename'
	--and __errormessage <> 'invalid file extension'
	group by __importstatus -- 21052 ... started with18090 in 70

	SELECT count(*), __errormessage
	FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59056
	group by __errormessage

	SELECT *
	FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59056
	--where sources3objectkey like '% /%' -- 15924
	where __errormessage = 's3 file not found' -- 
	-- space in the path, cannot change. sent back to customer to fix and rescan or manually upload. provide a list for the customer. 
		-- root folders

		-- 15924 docs and x amount root folderpaths. 

	SELECT distinct sources3objectkey
	FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59056
	where sources3objectkey like '% /%' -- 15924
	and __errormessage = 's3 file not found' -- 
	and sources3objectkey like '%closed_files%'

	left(replace(sources3objectkey,'filevine-7831/docs/',''),charindex('/',replace(sources3objectkey,'filevine-7831/docs/','')))




	SELECT *
	FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59056
---- done
--	UPDATE filevineproductionimport.._OklahomaLegalService_Documents___59056
--	SET docexternalid = concat(docexternalid, '_1')
--	, __importstatus = 40
--	, __errormessage = null
--	--FROM filevineproductionimport.._OklahomaLegalService_Documents___59056
--	where __errormessage = 'duplicate DocExternalID'

	SELECt *
	 FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59011
	WHERE docexternalid = 'S3DOC_302599'
	filevine-7831/docs/WCC_2019/Coffman, Nadia/Medical Records/McBride--Workstatus Report DOS 11-15-19.pdf
	filevine-7831/docs/PI_Closed_Files/Z/Zlotogura, Barry (do not delete)/Correspondence/2-24-12 ltr to Robin LaCava on UIM subro acknowledgement and next step on UIM settlement.doc



		SELECT *
	FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59056
	where __errormessage = 'cannot find matching project for ProjectExternalID'
	update these and reset these once i load the 25 projects and contacts
	where __errormessage = 'cannot find matching project for ProjectExternalID'

	SELECT *
	FROM filevineproductionimport.._OklahomaLegalService_Documents___59056
	WHERE __errormessage = 'cannot find matching project for ProjectExternalID'

	SELECT *
	FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59056
	WHERE __errormessage <> 'invalid file extension'
	AND __errormessage <> 'invalid filename'
	AND __errormessage <> ''

	SELECt *
	FROM 		filevineproductionimport.._OklahomaLegalService_Documents___59056
	WHERE __errormessage = 'duplicate DocExternalID'
