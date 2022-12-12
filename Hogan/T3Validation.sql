-- T3 validation

-- pi summary 
SELECT *
FROM filevinestaging2import.._HoganT3__PersonalInjuryMaster_NC_CaseSummary_58200

-- immigration summary
SELECT *
FROM filevinestaging2import.._HoganT3__Immigration_NC_CaseSummary_58296



-- _HoganT3_Documents___58214
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_Documents___58214
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_Documents___58214
group by __importstatus

-- _HoganT3__PersonalInjuryMaster_CL_TrustQB_58210

SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3__PersonalInjuryMaster_CL_TrustQB_58210
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3__PersonalInjuryMaster_CL_TrustQB_58210
group by __importstatus

-- _HoganT3__PersonalInjuryMaster_CL_ExpensesQB_58208
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3__PersonalInjuryMaster_CL_ExpensesQB_58208
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3__PersonalInjuryMaster_CL_ExpensesQB_58208
group by __importstatus

-- _HoganT3__Immigration_CL_TrustQB_58206
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3__Immigration_CL_TrustQB_58206
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3__Immigration_CL_TrustQB_58206
group by __importstatus

-- _HoganT3__Immigration_CL_ExpensesQB_58204
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3__Immigration_CL_ExpensesQB_58204
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3__Immigration_CL_ExpensesQB_58204
group by __importstatus

-- pi intake _HoganT3__PersonalInjuryMaster_NC_IntakeInfo_58202
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3__PersonalInjuryMaster_NC_IntakeInfo_58202
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3__PersonalInjuryMaster_NC_IntakeInfo_58202
group by __importstatus

-- immigration intake _HoganT3__Immigration_NC_Intake_58198
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3__Immigration_NC_Intake_58198
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3__Immigration_NC_Intake_58198
group by __importstatus

-- pi case summary _HoganT3__PersonalInjuryMaster_NC_CaseSummary_58200
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3__PersonalInjuryMaster_NC_CaseSummary_58200
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3__PersonalInjuryMaster_NC_CaseSummary_58200
group by __importstatus


-- IM case summary _HoganT3__Immigration_NC_CaseSummary_58196 ..... filevinestaging2import.._HoganT3__Immigration_NC_CaseSummary_58296
SELECT *
							FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58218
							WHERE firstname like 'Robert'

							-- 4116F1

SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3__Immigration_NC_CaseSummary_58296
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3__Immigration_NC_CaseSummary_58296
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT3__Immigration_NC_CaseSummary_58296
roberthogan
-- deadlines _HoganT3_Deadlines___58216
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_Deadlines___58216
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_Deadlines___58216
group by __importstatus

-- notes  _HoganT3_Notes___58194

--UPDATE  filevinestaging2import.._HoganT3_Notes___58194
--set __ImportStatus = 40
--, __errormessage = null
--, author = 'joy6'
--WHERE __ImportStatus = 70

SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_Notes___58194
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_Notes___58194
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT3_Notes___58194
WHERE __importstatus = 70

--UPDATE filevinestaging2import.._HoganT3_Projects___58223
--SET __importstatus = 40
--, __errormessage = null

SELECT *
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58267
WHERE __importstatus = 70

SELECT *
FROM filevinestaging2import.._HoganT3_Projects___58223
WHERE __importstatus = 70

-- projects _HoganT3_Projects___58192
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_Projects___58223
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_Projects___58223
group by __importstatus

SELECt *
FROM filevinestaging2import.._HoganT3_Projects___58223
WHERE projectexternalid NOT IN (SELECT projectexternalid
							FROM __FV_clientcasemap
							)

SELECt *
FROM 			filevinestaging2import.._HoganT3_Projects___58223
WHERE contactexternalid  IN (SELECT contactcustomexternalid
							FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58218
							)

SELECt *
FROM filevinestaging2import.._HoganT3_Projects___58192
WHERE contactexternalid NOT IN (SELECT contactexternalid
							FROM __FV_clientcasemap
							)

SELECt *
FROM filevinestaging2import.._HoganT3_Projects___58192
WHERE contactexternalid NOT IN (SELECT contactexternalid
							FROM __FV_clientcasemap
							)



-- contactdetails  -- _HoganT3_ContactsCustom__CustomFields_Details_58219
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58219
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58219
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58219



-- contactinfo _HoganT3_ContactsCustom__ContactInfo__58218
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58218
group by __errormessage

SELECT *
FROM  filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58218


SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58218
group by __importstatus

-- MORE OLD STUFF --------------------------------------------------

-- projects  _HoganT3_Projects___58156
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_Projects___58156
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_Projects___58156
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT3_Projects___58156
WHERE TRIM(contactexternalid)  in (SELECT contactcustomexternalid
							FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58180
							)

-- contactdetails _HoganT3_ContactsCustom__CustomFields_Details_58181
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58181
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58181
group by __importstatus

-- contactinfo
--update filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58180
--set __importstatus = 40
--, __errormessage = null
--WHERE __importstatus = 70

SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58180
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58180
group by __importstatus


-- OLD --------------------------------------------------------------------------------------

-- project _HoganT3_Projects___58079

SELECT *
FROM filevinestaging2import.._HoganT3_Projects___58079
WHERE projectexternalid not in (SELECT projectexternalid 
							FROM __FV_clientcasemap
								)

SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_Projects___58079
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_Projects___58079
group by __importstatus

-- contact details
SELECT *
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58150
WHERE contactcustomexternalid  IN (SELECT	contactcustomexternalid 
									FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58105
									)
SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58150
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58150
group by __importstatus

-- contactInfo
--update filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58105
--set __importstatus = 40
--, __errormessage = null
--WHERE __importstatus = 70

SELECT *
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58105
WHERE __importstatus = 70

SELECT count(*), __errormessage
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58105
group by __errormessage

SELECT count(*), __importstatus
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58105
group by __importstatus








-- contact info
SELECT *
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58267
WHERE lastname = 'webb'


SELECT *
FROM filevinestaging2import.._HoganT3_ContactsCustom__ContactInfo__58218
-- details
SELECT *
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58530
WHERE contactcustomexternalid like  '%999%'

SELECT *
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58219
WHERE contactcustomexternalid like  '%999%'


SELECT *
FROM filevinestaging2import.._HoganT3_ContactsCustom__CustomFields_Details_58592
WHERE contactcustomexternalid like  '%999%'
