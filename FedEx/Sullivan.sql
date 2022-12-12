
SELECt *
FROM pt1.projects
WHERE projectname like '%claiborne%'
WHERE projectname like '%sullivan%'

WHERE projectname like '%blake%'

SELECt *
FROM filevinestaging2import.._FedexB_Test1_Documents___9941
-- where destinationfolderpath like '%claiborne%'
where destinationfolderpath like '%blake%'

SELECT distinct LEFT(replace(folderpath, 'Wheeler Trigg ODonnell - FedEx/',''), charindex('/', replace(folderpath, 'Wheeler Trigg ODonnell - FedEx/','') , 1)-1) rootfolder
, folderpath
FROM [7119_FedEx_II_r2].dbo.s3docscan 
where folderpath like '%sullivan%'

Sullivan-Blake/Opt-Ins/Scanner Data/
SELECt count(*)--, folderpath
FROM [7119_FedEx_II_r2].dbo.s3docscan 
where folderpath like '%sullivan%'
group by folderpath 
order by 1 desc

SELECT 7117 +
4265+
421+
253+
240+
173+
172+
70+
45+
43+
29+
20+
13+
12+
1+
1

-- 
SELECT 18897 - 12875 -- =6022

loaded 6504 
