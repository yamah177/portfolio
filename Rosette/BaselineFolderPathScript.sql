


SELECt count(1)
FROM s3docscan --  348,924

SELECT *
FROM s3docscan 
WHERE folderpath like '%1052.1%'

SELECT *
FROM s3docscan 
WHERE folderpath like '%1209.5%' -- indian child welfare matters. multiple individual litigation matters pertaining to children they intervene on behalf of
Santa Rosa Rancheria - Tachi-Yokut/1209.5 SRR - ICWA/Ramos and Atwell/Correspondence/

SELECT distinct folderpath
FROM s3docscan 
order by folderpath

Jicarilla Apache Nation/
Michigan Attorney/-- take this out of active clients folder.
USB
Justin Gray



project name to this level:  1209.5 SRR - ICWA    --/Ramos and Atwell/Correspondence/

Santa Rosa Rancheria - Tachi-Yokut this is client.

different billing code has differenct projects.

icwa is different thing and different matters, tribe has them represent them in these matters. everything in this file is unique to this litigation.

each folder represents specific litigation matter that only pertains to people in that matter. 

docs in the individual folders may go to one single court case...

Santa Rosa Rancheria - Tachi-Yokut


project built off folderpath


-- contact

for 1052.1 American Web loan is the client but underneath that handling collections matter
each name will have their own folder associated 


1209.5

DROP TABLE IF EXISTS  #validfiles;

		SELECt  *
		into #validfiles
		from [dbo].[S3DocScan]
		WHERE filename not like '~%'
		and filename not like '%#%'
		and filename not like '%&%'
		and filename not like '%*%'
		and filename not like '%{%'
		and filename not like '%}%'
		and filename not like '%\%'
		and filename not like '%:%'
		and filename not like '%<%'
		and filename not like '%>%'
		and filename not like '%?%'
		and filename not like '%/%'
		and filename not like '%+%'
		and filename not like '%|%'
		and filename not like '%"%'
		and filename <> ''
		AND filename <> 'debug'
		and fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
		and filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini') --343,519

		-- BASE

		SELECT distinct folderpath
		,SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)) firstLevel
		,replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , '') secondlevelOn
		, SUBSTRING(replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0, charindex('/', replace(folderpath, SUBSTRING(folderpath, 0, charindex('/', folderpath, 0)+1) , ''), 0)) secondLevel
		FROM #validfiles
		WHERE folderpath is not null





--		SourceS3ObjectKey = replace(SourceS3ObjectKey,'[%]','%'),
--SourceS3ObjectKeyEncoded = replace(SourceS3ObjectKeyEncoded,'[%]','%'),
--DestinationFileName = replace(DestinationFileName,'[%]','%'),