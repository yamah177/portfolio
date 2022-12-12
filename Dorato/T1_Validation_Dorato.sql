-- dorato T1 validation

SELECt *
FROM filevinestaging2import.._Dorato_T1_ProjectContacts___51299

select *
FROM filevinestaging2import.._990000147_Dorato_ST4_ContactsCustom__ContactInfo__49025
where firstname like '%/%'
where firstname like '%ramon%'
and lastname like 'pando'


SELECt *
FROM filevinestaging2import.._Dorato_T1_Projects___51277

-- DOCUMENTS _Dorato_T1_Documents___51303

SELECT *
from FILEVINESTAGING2IMPORT.._Dorato_T1_Documents___51303
WHERE DESTINATIONFILENAME NOT LIKE '%MSG%'

-- _Dorato_T1__PITemplate_NC_CaseSummary_52127

SELECt distinct __errormessage
FROM filevinestaging2import.._Dorato_T1__PITemplate_NC_CaseSummary_52127
WHERE __importstatus = 70

-- project contacts _Dorato_T1_ProjectContacts___51299
SELECt *
FROM filevinestaging2import.._Dorato_T1_ProjectContacts___51299
WHERE contactcustomexternalid  in (SELECT nameid
										FROM __FV_clientcasemap
										)

-- _Dorato_T1__WC_NC_Intake_51291 employerContactExternalID
SELECT *
FROM filevinestaging2import.._Dorato_T1__WC_NC_Intake_51291
WHERE projectexternalid not IN (SELECT projectexternalid
							FROM filevinestaging2import.._Dorato_T1_Projects___51277)

SELECT *
FROM filevinestaging2import.._Dorato_T1__GAL_NC_GuardianCaseIntake_51287
WHERE petitioningAttorney IN (SELECT contactcustomexternalid
							FROM filevinestaging2import.._990000147_Dorato_ST4_ContactsCustom__ContactInfo__49025)


-- notes _Dorato_T1_Notes___51279
SELECt distinct __errormessage
FROM filevinestaging2import.._Dorato_T1_Notes___51279
WHERE __importstatus = 70

--update filevinestaging2import.._Dorato_T1_Notes___51279
--set __importstatus = 40
--, __errormessage = null
--where __importstatus = 70


-- _Dorato_T1__GAL_NC_GuardianCaseIntake_51287
SELECT *
FROM filevinestaging2import.._Dorato_T1__GAL_NC_GuardianCaseIntake_51287
WHERE projectexternalid not IN (SELECT projectexternalid
							FROM filevinestaging2import.._Dorato_T1_Projects___51277)

SELECT *
FROM filevinestaging2import.._Dorato_T1__GAL_NC_GuardianCaseIntake_51287
WHERE petitioningAttorney IN (SELECT contactcustomexternalid
							FROM filevinestaging2import.._990000147_Dorato_ST4_ContactsCustom__ContactInfo__49025)
-- pi intake info _Dorato_T1__PITemplate_NC_IntakeInfo_51283

--SELECT *
--FROM filevinestaging2import.._Dorato_T1__PITemplate_NC_IntakeInfo_51283
--WHERE __importstatus = 70

----------------------------------------------------------------------------------------


-- pi case summary filevinestaging2import.._Dorato_T1__PITemplate_NC_CaseSummary_51281

SELECT *
FROM filevinestaging2import.._Dorato_T1__PITemplate_NC_CaseSummary_51281
WHERE projectexternalid not IN (SELECT projectexternalid
							FROM filevinestaging2import.._Dorato_T1_Projects___51277)

SELECT distinct primaryattorneyContactExternalid 
FROM filevinestaging2import.._Dorato_T1__PITemplate_NC_CaseSummary_51281
WHERE primaryattorneyContactExternalid IN (SELECT contactcustomexternalid
							FROM filevinestaging2import.._990000147_Dorato_ST4_ContactsCustom__ContactInfo__49025)

SELECT distinct *
FROM filevinestaging2import.._990000147_Dorato_ST4_ContactsCustom__ContactInfo__49025
WHERE firstname like '%weems%'
--update filevinestaging2import.._Dorato_T1__PITemplate_NC_CaseSummary_51281
--set primaryattorneyContactExternalid = 'derek'
--WHERE primaryattorneyContactExternalid = 'derekweems'



SELECt count(*), __importstatus
FROM filevinestaging2import.._Dorato_T1_ProjectContacts___51299
group by __importstatus


SELECt count(*), __errormessage
FROM filevinestaging2import.._Dorato_T1_ProjectContacts___51299
group by __errormessage

-- calendar events _Dorato_T1_CalendarEvents___51307
SELECt distinct *
FROM filevinestaging2import.._Dorato_T1_CalendarEvents___51307
WHERE projectexternalid not IN (SELECT projectexternalid
							FROM filevinestaging2import.._Dorato_T1_Projects___51277)


SELECt count(*), __importstatus
FROM filevinestaging2import.._Dorato_T1_CalendarEvents___51307
group by __importstatus

SELECt count(*), __errormessage
FROM filevinestaging2import.._Dorato_T1_CalendarEvents___51307
group by __errormessage

-- projects _Dorato_T1_Projects___51277

SELECt count(*), __errormessage
FROM filevinestaging2import.._Dorato_T1_Projects___51277
group by __errormessage

SELECt *
FROM filevinestaging2import.._Dorato_T1_Projects___51277
WHERE __importstatus = 70

--update filevinestaging2import.._Dorato_T1_Projects___51277
--set --username = 'derek', 
--__importstatus = 40
--, __errormessage = null
--WHERE __importstatus = 70
----and username = 'derekweems'


--update filevinestaging2import.._Dorato_T1_Projects___51277
--set username = 'derek'
--, __importstatus = 40
--, __errormessage = null
--WHERE __importstatus = 70
--and username = 'derekweems'

--old _990000147_Dorato_ST4_Projects___49009
--SELECt count(*), __errormessage
--FROM filevinestaging2import.._990000147_Dorato_ST4_Projects___49009
--group by __errormessage

-- contact details _Dorato_T1_ContactsCustom__CustomFields_Details_51310

SELECt count(*), __errormessage
FROM filevinestaging2import.._Dorato_T1_ContactsCustom__CustomFields_Details_51310
group by __errormessage


-- contact info
SELECt *
FROM filevinestaging2import.._Dorato_T1_ContactsCustom__ContactInfo__51309
WHERE contactcustomexternalid  in (SELECT nameid
										FROM __FV_clientcasemap
										)

--update filevinestaging2import.._Dorato_T1_ContactsCustom__ContactInfo__51309
--set __importstatus = 40
--, __errormessage = null
--WHERE __importstatus = 70

SELECt count(*), __importstatus
FROM filevinestaging2import.._Dorato_T1_ContactsCustom__ContactInfo__51309
group by __importstatus

SELECt count(*), __errormessage
FROM filevinestaging2import.._Dorato_T1_ContactsCustom__ContactInfo__51309
group by __errormessage

SELECT *
FROM filevinestaging2import.._Dorato_T1_ContactsCustom__ContactInfo__51309
WHERE __importstatus = 70

Could not find a valid, matching Person ID for External ID: 12921   Invalid contact(s): Medical Provider

SELECT *
FROM filevinestaging2import.._990000147_Dorato_ST4_ContactsCustom__ContactInfo__49025
WHERE __ImportStatus = 60

SELECt count(*), __errormessage
FROM filevinestaging2import.._990000147_Dorato_ST4_ContactsCustom__ContactInfo__49025
group by __errormessage

SELECt count(*), __importstatus
FROM filevinestaging2import.._990000147_Dorato_ST3_ContactsCustom__ContactInfo__48561
group by __importstatus

