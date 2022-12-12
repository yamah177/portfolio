-- docs
SELECt count(*)
FROM  filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064137
where projectexternalid   in (SELECT projectexternalid
							FROM FilevineStagingImport.._6985_BobbyGarcia_Tes_Projects___550064123
							)

SELECT *
FROM filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064137


SELECt count(*), __importstatus
from filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064137
group by __importstatus

SELECt count(*), __errormessage
from filevinestagingimport.._6985_BobbyGarcia_Tes_Documents___550064137
group by __errormessage

SElect 14 + 204+22+32+1+1+1+1+1+1+1+1+1+1

-- projects

SELECt *
FROM FilevineStagingImport.._6985_BobbyGarcia_Tes_Projects___550064123
where projectexternalid like  'P_BG-17-087_With F&N_Noemi Garcia_Mass Tort - Medical Devices'

update filevinestagingimport.._6985_BobbyGarcia_Tes_Projects___550064123
set __importstatus = 40
, __errormessage = null
, username = 'datamigrationteam1'

SELECt count(*), __importstatus
from filevinestagingimport.._6985_BobbyGarcia_Tes_Projects___550064123
group by __importstatus

SELECt count(*), __errormessage
from filevinestagingimport.._6985_BobbyGarcia_Tes_Projects___550064123
group by __errormessage

-- contacts 
SELECt count(*), __importstatus
from filevinestagingimport.._6985_BobbyGarcia_Tes_Contacts___550063713
group by __importstatus

SELECt count(*), __errormessage
from filevinestagingimport.._6985_BobbyGarcia_Tes_Contacts___550063713
group by __errormessage




SELECT count(*)
FROM s3docscan -- 300751
