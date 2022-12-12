


SELECT *
FROM filevineproductionimport.._OklahomaLegalService_Projects___59009
where __importstatus = 60

UPDATE filevineproductionimport.._OklahomaLegalService_Projects___59009
SET __importstatus  = 40
, __ErrorMessage = null
, username = 'cdr'


SELECt distinct uploadedbyusername
FROM filevineproductionimport.._OklahomaLegalService_Documents___59011

update filevineproductionimport.._OklahomaLegalService_Documents___59011
set uploadedbyusername = 'cdr'



-- docs validation

SELECT *
FROM filevineproductionimport.._OklahomaLegalService_Documents___59011
where __importstatus = 70
and destinationfilename not like '~%'

SELECT count(*), __importstatus
FROM filevineproductionimport.._OklahomaLegalService_Documents___59011
group by __importstatus

SELECT count(*), __errormessage
FROM filevineproductionimport.._OklahomaLegalService_Documents___59011
where __errormessage = 'cannot find matching project for ProjectExternalID'
and projectexternalid <> 'P_Pi A-Z_PI_1__Closed_Files/'
and projectexternalid <> 'P_Pi A-Z_PI_1_I_Closed_Files/'
and projectexternalid <> 'P_Pi A-Z_PI_1_Closed_Files/'
and projectexternalid <> 'P_WC A-Z_WC_1_C_Closed_Files/'
and projectexternalid <> 'P_WC A-Z_WC_1_CC_Closed_Files/'
group by __errormessage

SELECT *
FROM filevineproductionimport.._OklahomaLegalService_Documents___59011
where __errormessage = 'cannot find matching project for ProjectExternalID'
and projectexternalid <> 'P_Pi A-Z_PI_1__Closed_Files/'
and projectexternalid <> 'P_Pi A-Z_PI_1_I_Closed_Files/'
and projectexternalid <> 'P_Pi A-Z_PI_1_Closed_Files/'
and projectexternalid <> 'P_WC A-Z_WC_1_C_Closed_Files/'
and projectexternalid <> 'P_WC A-Z_WC_1_CC_Closed_Files/'



