



SELECt * --top 1000 *
FROM [dbo].[S3DocScan]
where FolderPath like '%jumps%' -- 1301
and folderpath like '%!%'


SELECt * --top 1000 *
FROM [dbo].[S3DocScan]
where -- FolderPath like '%jumps%' -- 1301
folderpath like '%!%'
and folderpath like '%Thielen%' -- 26



SELECt * --top 1000 *
FROM [dbo].[S3DocScan]
where FolderPath like '%Kirby%' -- 872
and folderpath like '%!%'

SELECt * --top 1000 *
FROM [dbo].[S3DocScan]
where FolderPath like '%Griffin%' -- 281
and folderpath like '%!%'

SELECt * --top 1000 *
FROM [dbo].[S3DocScan]
where FolderPath like '%Eveleth%' -- 1
and folderpath like '%!%'

SELECt *
FROM #TEMPS3



Jumps
Thielen (490)
Kirby
Griffin
Jakubiec -- another issue
Ekeler -- another issue
Eveleth