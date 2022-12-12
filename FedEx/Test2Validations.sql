-- documents
SELECt count(*), __importstatus
FROM filevinestaging2import.._FedexB_Test2_Documents___18076
group by __importstatus

SELECT count(*)
FROM [7119_FedEx_II_r2].dbo.s3docscan -- 9293

SELECT count(*)
FROM [7119_FedEx_II_r1].dbo.s3docscan -- 18897


SELECT *
FROM 			filevinestaging2import.._FedexB_Test2__WTOFXGMaster_CL_OptIns_18064
WHERE __importstatus = 70
--
SELECT *
FROM filevinestaging2import.._FedexB_Test2__WTOFXGMaster_CL_Experts_18062
--

SELECt *
FROM FilevineStaging2Import.._FedexB_Test2_CalendarEvents___18080

--update  FilevineStaging2Import.._FedexB_Test2_CalendarEvents___18080
--SET __importstatus = 40
--, __errormessage = null
--, attendeeUserCSV = 'datamigrationteam101'
--WHERE __importstatus = 70
--

SELECt *
FROM FilevineStaging2Import.._FedexB_Test2__WTOFXGMaster_CL_Depos_18060


SELECt *
FROM 			filevinestaging2import.._FedexB_Test2__WTOFXGMaster_NC_CaseSummary_18056


--
SELECt *
FROM 			filevinestaging2import.._FedexB_Test2__WTOFXGMaster_NC_CaseAnalysis_18048


-- notes
SELECt distinct __errormessage
SELECt *
FROM 	filevinestaging2import.._FedexB_Test2_Notes___18046
WHERE __importstatus = 70

update filevinestaging2import.._FedexB_Test2_Notes___18046
set __importstatus = 40
, __errormessage = null
, assignee = null
WHERE __importstatus = 70

-- projects
SELECt *
FROM filevinestaging2import.._FedexB_Test2_Projects___18044
WHERE projectname like '%blake%'
--where __importstatus = 70

update  filevinestaging2import.._FedexB_Test2_Projects___18044
set __importstatus = 40
, __errormessage = null
, username = 'datamigrationteam101'
WHERE __importstatus = 70
and username = 'datamigrationteam'

update  filevinestaging2import.._FedexB_Test2_Projects___18044
set __importstatus = 40
, __errormessage = null
--, username = 'datamigrationteam101'
WHERE __importstatus = 70
and username = 'datamigrationteam'


update  filevinestaging2import.._FedexB_Test2_Projects___18044
set __importstatus = 40
, __errormessage = null
, username = 'scott7'
WHERE __importstatus = 70
AND username = 'jessica22'

update  filevinestaging2import.._FedexB_Test2_Projects___18044
set __importstatus = 40
, __errormessage = null
, username = 'stephanie8'
WHERE __importstatus = 70
AND username = 'stephanie49'



WHEN username = 
	THEN 
	END AS username