
SELECT *
FROM [FilevineStagingImport].._HirjiChauTest3a_Documents___550058390
where DestinationFolderPath like '%harrell, R%'

SELECT *
FROM S3DocScan

SELECt docexternalid, __ErrorMessage, destinationFileName, DestinationFolderPath
FROM [FilevineStagingImport].._HirjiChauTest3a_Documents___550058390
WHERE __importstatus = 70 -- 1838
AND destinationFileName not like '%.ini' -- 1537 errors
AND destinationFileName not like '~%' -- 250 errors
AND destinationFileName not like 'Thumbs.db' -- 1 errors
AND destinationFileName not like '%.tmp' -- 9 errors
AND destinationFileName not like '%.exe' -- 12 errors
AND destinationFileName not like '%.dropbox' -- 1 errors
AND destinationFileName not like '%.js' -- 17 errors
AND destinationFileName not like '%.dll' -- 1 errors
order by __errormessage desc


SELECt count(*), __errormessage
FROM [FilevineStagingImport].._HirjiChauTest3a_Documents___550058390
WHERE __importstatus = 70
group by __errormessage
order by 1 desc -- 1838

---------- test 1 review
Select *
FROM [FilevineStagingImport].._HirjiChauTest3a_Documents___550058390
where projectexternalid = 'PEID008'
AND __IMPORTSTATUS = 70
and destinationfilename like '%change%'

SELECT *
FROM s3docscan
WHERE FOLDERPATH LIKE '%CATHEY, S%'
order by filecomplete
and filename like '19.11.14%change%in%law%firm%'
where filename like '%change%in%law%%'

SELECT *
FROM [__FV_Hirji_Project_List_Clean]
WHERE name like '%Cathey%'

select __ImportStatus, __ErrorMessage, DestinationFileName, DestinationFolderPath
from [FilevineStagingImport].._HirjiChauTest3a_Documents___550058390
where DESTINATIONFOLDERPATH LIKE '%CATHEY%SPECIAL%EDUCATION%PLEADINGS%'

select  COUNT(*)--__ImportStatus, __ErrorMessage, DestinationFileName, DestinationFolderPath
from S3DocScan -- 37592
WHERE FILENAME LIKE '%CATHEY%DPR%'

NEW DOCSCAN

SELECT 
SELECt folderpath
FROM [dbo].[S3DocScan]
where FolderPath <> ''

SELECt replace(Folderpath,'filevine-5928/', '')
FROM [dbo].[S3DocScan-old]
where FolderPath <> ''



SELECT count(*)
FROM [dbo].[S3DocScan-old]
