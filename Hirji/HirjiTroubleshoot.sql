

SELECT *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%cathey, s%work%product%'

SELECT *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%cathey, s%student%'


SELECT *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%cathey, s%district%'


SELECT *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%cathey, s%OAH%'

SELECT *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%cathey, s%resolution%'

SELECT *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%cathey, s%correspondence%outgoing%'

SELECT *
FROM s3docscan
WHERE folderpath like '%cathey, s%correspondence%outgoing%'
-- 4 feel out of corresponding outgoing. 


SELECT *
FROM filevinestagingimport.._HirjiChauTest3a_Documents___550058390
where destinationfolderpath like '%cathey, s%correspondence%%incoming%'