

SELECt count(*)
FROM [S3DocScan_Client_Import_Files] -- 335058

SELECt count(*)
FROM [S3DocScan_Client_Import_Files] -- 335058
where folderpath like '%filevine-7831/docs/PI_Closed_Files%' -- 225076


SELECt count(*)
FROM [S3DocScan_Client_Import_Files] -- 335058
where folderpath like '%filevine-7831/docs/WCC_Closed_Files/%' -- 25625

SELECt * -- count(*)
FROM [7831_Oklahoma].[dbo].[S3DocScan] -- 7791

-- THIS IS WHAT WE WILL MIGRATE TO PROD TODAY (OPEN CASES)
SELECt count(*)
FROM [7831_Oklahoma_GL].[dbo].[S3DocScan] 
where folderpath not like '%WCC_Closed_Files%'
and folderpath not like '%PI_Closed_Files%' --138422 vs 84356

-- these are still in progress
--(Closed Cases)
SELECt count(*)
FROM [7831_Oklahoma_GL].[dbo].[S3DocScan] -- 366348
where folderpath like '%WCC_Closed_Files/%' -- 25625 in old, new is 21951

SELECt count(*)
FROM [7831_Oklahoma_GL].[dbo].[S3DocScan] -- 366348
where folderpath like '%PI_Closed_Files/%' -- 225076 in old, new is 205972
