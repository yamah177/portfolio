-- Test 5 validation


-- missing ten validation
			AND ccm.projectexternalid in (SELECt ProjectExternalID 
												FROM filevinestaging2import.._HoganT5_Projects___60554)

SELECT *
FROM filevinestaging2import.._HoganT5__PersonalInjuryMaster_CL_ExpensesQB_60576

-- notes
SELECT *
FROM filevinestaging2import.._HoganT5_Notes___60564

SELECT *
FROM filevinestaging2import.._HoganT5_Projects___60554

-- docs

-- immigration case summar _HoganT5__Immigration_NC_CaseSummary_60294
SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT5__Immigration_NC_CaseSummary_60294
group by __errormessage

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT5__Immigration_NC_CaseSummary_60294
group by __importstatus

-- notes 			filevinestaging2import.._HoganT5_Notes___60292
SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT5_Notes___60292
group by __errormessage

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT5_Notes___60292
group by __importstatus

SELECt distinct author
FROM filevinestaging2import.._HoganT5_Notes___60292

-- projects
SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT5_Projects___60290
group by __errormessage

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT5_Projects___60290
group by __importstatus

SELECt count(1)
FROM filevinestaging2import.._HoganT4_Projects___58982 -- 687
--WHERE projectname = 'Aequum'
EXCEPT
SELECt count(1)
FROM filevinestaging2import.._HoganT5_Projects___60290 -- 666
--WHERE projectname = 'Aequum'

SELECt distinct username
FROM filevinestaging2import.._HoganT5_Projects___60290 -- 666

-- contact details
SELECt *
FROM filevinestaging2import.._HoganT4_ContactsCustom__CustomFields_Details_59009

SELECt *
FROM filevinestaging2import.._HoganT5_ContactsCustom__CustomFields_Details_60317

SELECt *
FROM filevinestaging2import.._HoganT5_ContactsCustom__CustomFields_Details_60322

--update filevinestaging2import.._HoganT5_ContactsCustom__ContactInfo__60316
--SET __importstatus = 40
--, __errormessage = null
--WHERE __importstatus = 70

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT5_ContactsCustom__ContactInfo__60316
group by __errormessage

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT5_ContactsCustom__ContactInfo__60316
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT5_ContactsCustom__ContactInfo__60316
WHERE __importstatus = 70
