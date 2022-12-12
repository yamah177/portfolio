
-- _HoganT2_Deadlines___57371 -- reload affected dupe project info

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2_Deadlines___57371
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2_Deadlines___57371
group by __errormessage

-- pi expense qb _HoganT2__PersonalInjuryMaster_CL_ExpensesQB_57363 -- reload affected dupe project info
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2__PersonalInjuryMaster_CL_ExpensesQB_57363
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2__PersonalInjuryMaster_CL_ExpensesQB_57363
group by __errormessage



-- immigration trust QB _HoganT2__Immigration_CL_TrustQB_57361 
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2__Immigration_CL_TrustQB_57361
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2__Immigration_CL_TrustQB_57361
group by __errormessage

-- immigration expense qb _HoganT2__Immigration_CL_ExpensesQB_57359 -- reload duped project info
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2__Immigration_CL_ExpensesQB_57359
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2__Immigration_CL_ExpensesQB_57359
group by __errormessage


-- pi intake info _HoganT2__PersonalInjuryMaster_NC_IntakeInfo_57357 -- need to reload duped project info
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2__PersonalInjuryMaster_NC_IntakeInfo_57357
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2__PersonalInjuryMaster_NC_IntakeInfo_57357
group by __errormessage


-- pi case summary _HoganT2__PersonalInjuryMaster_NC_CaseSummary_57676 -- reload duped project info
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2__PersonalInjuryMaster_NC_CaseSummary_57676
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2__PersonalInjuryMaster_NC_CaseSummary_57676
group by __errormessage



-- immigration intake _HoganT2__Immigration_NC_Intake_57353 -- reload affected dupe projects
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2__Immigration_NC_Intake_57353
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2__Immigration_NC_Intake_57353
group by __errormessage

-- immigration case summary _HoganT2__Immigration_NC_CaseSummary_57351 -- reload duped projects
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2__Immigration_NC_CaseSummary_57674
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2__Immigration_NC_CaseSummary_57674
group by __errormessage

SELECT *
FROM filevinestaging2import.._HoganT2__Immigration_NC_CaseSummary_57351

-- docs _HoganT2_Documents___57369
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2_Documents___57369
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2_Documents___57369
group by __errormessage

SELECt *
FROM filevinestaging2import.._HoganT2_Documents___57369
WHERE __errormessage like 'cannot find projectID or ProjectExternalID%cannot find matching project for ProjectExternalID'
0018_145
SELECt *
FROM filevinestaging2import.._HoganT2_Documents___57369
WHERE __errormessage = 'invalid file extension'

SELECt *
FROM filevinestaging2import.._HoganT2_Documents___57369
WHERE __errormessage = 'invalid file extension'

SELECt *
FROM filevinestaging2import.._HoganT2_Documents___57369
WHERE __errormessage = 'invalid filename'

SELECt *
FROM filevinestaging2import.._HoganT2_Documents___57369
WHERE __errormessage = 's3 file not found'



-- notes _HoganT2_Notes___57349

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2_Notes___57349
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2_Notes___57349
group by __errormessage

--Expected, but if these projects need reloaded as legit dupes, then i need to redo these.

'0018_145',
			'0018_60',
			'0059_0018', --
			'0193_0016', --
			'0601_0603', --
			'0601_1033', --
			'0627_0627',
			'0665_663', --
			'0665_665', --
			'0667_663',
			'0667_665',
			'0883_663',
			'0883_665',
			'0985_0627',
			'1145_0603',
			'1145_1033'
			)

SELECt *
FROM filevinestaging2import.._HoganT2_Notes___57349

update filevinestaging2import.._HoganT2_Notes___57349
set __errormessage = null
, __importstatus = 40
, Author = 'joy6'
WHERE __importstatus = 70
AND Author = 'joyblaney'

-- projects _HoganT2_Projects___57347

SELECT *
FROM filevinestaging2import.._HoganT2_Projects___57347
WHERE projectexternalid IN (
			'0018_145',
			'0018_60',
			'0059_0018',
			'0193_0016',
			'0601_0603',
			'0601_1033',
			'0627_0627',
			'0665_663',
			'0665_665',
			'0667_663',
			'0667_665',
			'0883_663',
			'0883_665',
			'0985_0627',
			'1145_0603',
			'1145_1033'
			)

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2_Projects___57347
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2_Projects___57347
group by __errormessage

SELECT *
FROM filevinestaging2import.._HoganT2_Projects___57347
WHERE __importstatus = 70

SELECT *
FROM __FV_clientcasemap
WHERE projectexternalid = '0298_326'

--update filevinestaging2import.._HoganT2_Projects___57347
--set __importstatus  = 40
--, __errormessage = null
--WHERE __importstatus  = 70

-- contact details
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2_ContactsCustom__CustomFields_Details_57374
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2_ContactsCustom__CustomFields_Details_57374
group by __errormessage

-- contact info
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2_ContactsCustom__ContactInfo__57518
group by __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2_ContactsCustom__ContactInfo__57518
group by __errormessage

SELECt *
FROM filevinestaging2import.._HoganT2_ContactsCustom__ContactInfo__57518

WHERE __importstatus = 70


--update filevinestaging2import.._HoganT2_ContactsCustom__ContactInfo__57518
--set __importstatus = 40
--, __errormessage = null
--WHERE __importstatus= 70

SELECt *
FROM filevinestaging2import.._HoganT2_ContactsCustom__ContactInfo__57373
WHERE __importstatus = 70

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT2_ContactsCustom__ContactInfo__57373
group by __errormessage


SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT2_ContactsCustom__ContactInfo__57373
group by __importstatus

Prospective Client
Billing Contact


FROM filevinestaging2import.._HoganT2_ContactsCustom__ContactInfo__57373

SELECT contactexternalid
FROM filevinestaging2import.._HoganT2_Projects___57347
WHERE contactexternalid NOT in ( SELECT contactcustomexternalid
							FROM filevinestaging2import.._HoganT2_ContactsCustom__ContactInfo__57373
							)


