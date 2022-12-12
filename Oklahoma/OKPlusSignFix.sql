
'S3DOC_50935',
'S3DOC_32038',
'S3DOC_337161',
'S3DOC_7933'



SELECT *
FROM filevineproductionimport.._OklahomaLegalService_Documents___59011
--UPDATE filevineproductionimport.._OklahomaLegalService_Documents___59011
--set __ImportStatus  = 40
--, __ErrorMessage = null
where DocExternalID in ('S3DOC_50935',
'S3DOC_32038',
'S3DOC_337161',
'S3DOC_7933'
)
and __ImportStatus = 70

SELECT *
FROM filevineproductionimport.._OklahomaLegalService_Documents___59056
where DocExternalID in ('S3DOC_50935',
'S3DOC_32038',
'S3DOC_337161',
'S3DOC_7933'
)

where __importstatus = 70
and __errormessage = 'invalid filename'
and destinationfilename like '%+%'


SELECT *
FROM filevineproductionimport.._OklahomaLegalService_Documents___59065
where DocExternalID in ('S3DOC_50935',
'S3DOC_32038',
'S3DOC_337161',
'S3DOC_7933'
)

where __importstatus = 70
and __errormessage = 'invalid filename'
and destinationfilename like '%+%'












