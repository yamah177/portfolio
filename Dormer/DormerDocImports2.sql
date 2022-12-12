
SELECt *
FROM [FilevineProductionImport].._DormerHarpringLLC_Documents___56532
where destinationfolderpath like '%jumps%'
where __importstatus = 60
and destinationfolderpath like '%jump%'

SELECt COUNT(*), __ErrorMessage
FROM [FilevineProductionImport].._DormerHarpringLLC_Documents___56532
where __importstatus = 70
group by __ErrorMessage
order by 1 desc



SELECt d.__ErrorMessage, d.DestinationFolderPath, d.DestinationFileName, d.*
FROM [FilevineProductionImport].._DormerHarpringLLC_Documents___56532 d
where d.__importstatus = 70 -- 2255
--and d.__ErrorMessage not like '%s3 file size limit exceeded:%' -- 2252
and d.DestinationFileName not like '%.h' --1967
and d.DestinationFileName not like 'Thumbs.db' --1877
and d.DestinationFileName not like '~%' -- 1855
and d.DestinationFileName not like 'desktop.ini' -- 1851
and d.DestinationFileName not like '%.tmp' -- 1849
and d.DestinationFileName not like '%.exe' -- 1582
and d.DestinationFileName not like '%.dll' -- 436
and d.DestinationFileName not like '%.js' -- 163
and d.DestinationFileName not like '%.bat' -- 78
and d.DestinationFileName not like '%.msi' -- 65
and d.DestinationFileName not like '.DS_Store' -- 64
and d.DestinationFileName not like '%.GIF' -- 58
and d.DestinationFileName not like '.DS_Store' -- 64
and d.DestinationFileName not like 'Attachment 14 receipt.com' --59
order by d.__ErrorMessage desc

-- 3 files too large:
1510 Kenya Jenkins 12-2-20.mp4
Andersen Expert File.zip
2021 01 14 Stroud Depo-VIDEO.mp4
