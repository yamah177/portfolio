
INSERT INTO filevinestaging2import.._HoganT5_Projects___60554
(
--__ID
__importstatus
, __importstatusdate
, __errormessage
,__workerID
, __projectID
, projectexternalid
, contactexternalid
, projectname
, projecttemplate
, incidentdate
, incidentdescription
, isARchived
, phasename
, phasedate
, hashtags
, username
, createdate
, projectnumber
, projectemailprefix
)
SELECt 
  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__ProjectID]
, projectexternalid
, contactexternalid
, projectname
, projecttemplate
, incidentdate
, incidentdescription
, isARchived
, phasename
, phasedate
, hashtags
, username
, createdate
, projectnumber
, projectemailprefix 
FROM pt1.projects
WHERE projectexternalid not in (
								SELECT projectexternalid
								FROM filevinestaging2import.._HoganT5_Projects___60290)

