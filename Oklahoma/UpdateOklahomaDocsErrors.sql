
SELECt *
FROM filevinestagingimport.._OklahomaLegalService_Documents___550061261


--
SELECT top 1000 *
FROM filevinestagingimport.._OklahomaLegalService_Documents___550060411

SELECT count(*), __ErrorMessage
FROM filevinestagingimport.._OklahomaLegalService_Documents___550060411 -- 327739 docs
WHERE __ImportStatus = 70
group by __ErrorMessage


SELECT d.destinationfolderpath, f.folderpath, d.destinationfilename, f.filecomplete
FROM filevinestagingimport.._OklahomaLegalService_Documents___550060411 d
inner join [dbo].[S3DocScan_Client_Import_Files] f
	on d.sources3objectkeyencoded = f.sources3objectkeyencoded
where __ErrorMessage = 'cannot find matching project for ProjectExternalID'

SELECt *
FROM filevinestagingimport.._OklahomaLegalService_Documents___550060411 d
inner join [dbo].[S3DocScan_Client_Import_Files] f
	on d.sources3objectkeyencoded = f.sources3objectkeyencoded
where __ErrorMessage = 'cannot find matching project for ProjectExternalID'

P_N_PI_0_PI_Closed_Files/

SELECT *
FROM [S3DocScan_Client_Import_Files]
WHERE FolderPath like 'filevine-7831/docs/%PI%Closed%Files%'

filevine-7831/docs/PI_Closed_Files/

SELECt *
FROM filevinestagingimport.._OklahomaLegalService_Projects___550060405
where projectexternalid like 'P_%closed_files%'


SELECt *
FROM filevinestagingimport.._OklahomaLegalService_Projects___550060405
where projectexternalid like'P_R_WC_1_WCC_Closed_Files/'



SELECt *
FROM [dbo].[S3DocScan_Client_Import_Files]
WHERE 


SELECT  __importstatus, __ErrorMessage, docexternalid, projectexternalid, destinationFileName, DestinationFolderPath
FROM filevinestagingimport.._OklahomaLegalService_Documents___550060411 -- 327739 docs
WHERE __ImportStatus = 70 -- 7200 errors
and destinationFileName not like '~%' -- then 5412
and destinationFileName not like '%.js' -- 4658
and destinationFileName not like '%.dll' -- 873
and destinationFileName not like '%.ini' -- 640
and destinationFileName not like '%.exe' --  136
and destinationFileName not like '%.bat' -- 67
and destinationFileName not like '%.cmd' -- 63
and destinationFileName not like '%.tmp' -- 47
and destinationFileName not like '%.ocx' -- 37
and destinationFileName not like '%.lnk' -- 36
and destinationFileName not like '%.pif' -- 34
and destinationFileName not like '%.msi' -- 32
and destinationFileName not like '%.com' -- 30
and destinationFileName <> '.dropbox' -- 29
--group by __ErrorMessage
-- These are two big.
Jennifer Interview.mov
Kelsie Interview (2).mov

-- then 27 can't find project external id's because the name was messed up



SELECT count(*), __ImportStatus
FROM filevinestagingimport.._OklahomaLegalService_Documents___550060411
group by __ImportStatus




SELECT *
FROM filevinestagingimport.._OklahomaLegalService_Contacts___550060299

SELECT count(*), __ErrorMessage
FROM filevinestagingimport.._OklahomaLegalService_Contacts___550060299
WHERE __ImportStatus = 70
group by __ErrorMessage


SELECT count(*), __ImportStatus
FROM filevinestagingimport.._OklahomaLegalService_Contacts___550060299
group by __ImportStatus


SELECT *
FROM filevinestagingimport.._OklahomaLegalService_Projects___550060297

SELECT count(*), __ErrorMessage
FROM filevinestagingimport.._OklahomaLegalService_Projects___550060297
WHERE __ImportStatus = 70
group by __ErrorMessage


SELECT count(*), __ImportStatus
FROM filevinestagingimport.._OklahomaLegalService_Projects___550060297
group by __ImportStatus

UPDATE filevinestagingimport.._OklahomaLegalService_Projects___550060297
SET __ImportStatus = 40
, __ErrorMessage = null
, username = 'datamigrationteam1'



SELECT *
FROM filevinestagingimport.._OklahomaTest2_Documents___550060142

SELECT count(*), __ErrorMessage
FROM filevinestagingimport.._OklahomaTest2_Documents___550060142
WHERE __ImportStatus = 70
group by __ErrorMessage


SELECT count(*), __ImportStatus
FROM filevinestagingimport.._OklahomaTest2_Documents___550060142
group by __ImportStatus













SELECt *
FROM filevinestagingimport.._OklahomaTest2_Projects___550060281

cannot find matching person for ContactExternalID: C_MageeCheryl_PI_0
C_MageeCheryl_PI_0

SELECt *
FROM filevinestagingimport.._OklahomaTest2_Contacts___550060086
where contactexternalid like '%MageeChery%'

SELECt *
FROM filevinestagingimport.._OklahomaTest2_Projects___550060084

SELECt count(*), __ErrorMessage
FROM filevinestagingimport.._OklahomaTest2_Projects___550060118
where __ImportStatus = 70
group by  __ErrorMessage

-- cannot find matching person for ContactExternalID: C_AbbittDorothy_PI_0



SELECt count(*), __ImportStatus
FROM filevinestagingimport.._OklahomaTest2_Projects___550060084
group by  __ImportStatus


Update 		filevinestagingimport.._OklahomaTest2_Projects___550060084
SET __ImportStatus = 40
, __errormessage = null
, username = 'datamigrationteam1'
 


