

SELECt count(*), d.__ErrorMessage--, d.destinationFolderPath, d.DestinationFileName, d.*
FROM [FilevineStagingImport].._OklahomaLegalService_Documents___550056947 d
WHERE __ImportStatus = 70
GROUP BY d.__ErrorMessage
order by 1 desc

SELECt *
FROM [FilevineStagingImport].._OklahomaLegalService_Documents___550056947 d
where d.__ErrorMessage like '%s3 file size limit exceeded%'



SELECt d.__ErrorMessage, d.destinationFolderPath, d.DestinationFileName, d.*
FROM [FilevineStagingImport].._OklahomaLegalService_Documents___550056947 d
WHERE __ImportStatus = 70
and d.destinationFileName not like '%.dll'
and d.destinationFileName not like '%.bat'
and d.destinationFileName not like '%.exe'
and d.destinationFileName not like '%.js'
and d.destinationFileName not like '%.ocx'
and d.destinationFileName not like '%.com'
and d.destinationFileName not like '%.cmd'
and d.destinationFileName not like '%.msi'
and d.destinationFileName not like '%.pif'
and d.destinationFileName not like '%.DS_Store'
and d.destinationFileName not like '~%'
and d.destinationFileName not like 'desktop.ini'
and d.destinationFileName not like '%.tmp'
and d.destinationFileName not like '%.dropbox'

Order By d.__ErrorMessage

-- 12 cannot find matching project for ProjectExternalID

SELECt count(*)
FROM [dbo].[S3DocScan]

SELECT COUNT(*)
FROM [FilevineStagingImport].._OklahomaLegalService_Documents___550056947 d

SELECT COUNT(*)
FROM [dbo].[S3DocScan_Client_Import_Files]

SELECT MAX(Len(FolderPath)) -- 264
FROM [dbo].[S3DocScan_Client_Import_Files]

SELECT LEN(MAX(FolderPath)) -- 58
FROM [dbo].[S3DocScan_Client_Import_Files] 
