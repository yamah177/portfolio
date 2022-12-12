-- Match existing projects to folders using the BG Number or case number that is listed as a hashtag. Please see examples below. If Folder does not have a BG number or case number, do not migrate those folders.

SELECT count(*)
FROM [6985_Bobbygarcia].[dbo].[S3DocScan] -- 300751

SELECT *
FROM [6985_Bobbygarcia].[dbo].[S3DocScan] 
where fileext <> 'tmp'
and fileext <> 'dl_'
and fileext <> 'da_'
and fileext <> 'ex_'
and fileext <> 'ch_'
and fileext <> 'mt_'
and fileext <> 'ca_'
and fileext <> 'ch_'
and filecomplete <> '.dropbox'
and filename not like '%~%'
and filecomplete <> 'desktop.ini'
and filecomplete <> 'Desktop.lnk'
and filecomplete <> 'Downloads.lnk'
and filecomplete <> '.bzEmpty'
and filecomplete <> 'Thumbs.db'




