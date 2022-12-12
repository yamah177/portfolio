-- T4 Load

-- special character filename docs import
SELECT *
FROM filevinestaging2import.._HoganT4_Documents___60130
WHERE docexternalid = '10000'
WHERE destinationfilename like 'POA%Invoice_6-2020.pdf'

-- missing clients
SELECT *
FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__59008

WHERE contactcustomexternalid = '0733' -- kasandra ledesma
--'867' -- eduardo urias


-- _HoganT4__PersonalInjuryMaster_CL_ExpensesQB_59968 new expenses

--Another new one _HoganT4__PersonalInjuryMaster_CL_ExpensesQB_60208
SELECT *
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_CL_ExpensesQB_60208
WHERE projectexternalid = '0619_0619' -- nino 



SELECT *
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_CL_ExpensesQB_60047
--WHERE projectexternalid like '%0453%' -- caballero
--WHERE projectexternalid = '0319_347' -- neufeld
WHERE projectexternalid = '0619_0619' -- nino 
order by amount

--4.25
--97.35 --
19.81
--4.25
--950.30
--84.00
--88.41
--130.00
--3.34
--19.81
--367.57
--50.00
--225.00

-- figure out aequum

SELECT *
FROM filevinestaging2import.._HoganT4_Projects___58982
WHERe projectname like '%aequ%'

SELECT *
FROM 

-- relouad			filevinestaging2import.._HoganT4__Immigration_NC_Intake_59964
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4__Immigration_NC_Intake_59964
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4__Immigration_NC_Intake_59964
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4__Immigration_NC_Intake_59964
group by __errormessage



-- documents _HoganT4_Documents___59004
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4_Documents___59004
group by __importstatus

SELECt *
FROM filevinestaging2import.._HoganT4_Documents___59004
WHERE docexternalid = '10000'

SELECT *
FROM filevinestaging2import.._HoganT4_Documents___59004
WHERE projectexternalid = '1035_757'
WHERE projectexternalid like '%1233_757%'
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4_Documents___59004
group by __errormessage

-- pi case summary _HoganT4__PersonalInjuryMaster_NC_CaseSummary_59043
SELECT  count(1), __importstatus
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_NC_CaseSummary_59043
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_NC_CaseSummary_59043
group by __errormessage

-- pi intake info _HoganT4__PersonalInjuryMaster_NC_IntakeInfo_59045
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_NC_IntakeInfo_59045
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_NC_IntakeInfo_59045
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_NC_IntakeInfo_59045
group by __errormessage

-- pi trust  _HoganT4__PersonalInjuryMaster_CL_TrustQB_59000
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_CL_TrustQB_59000
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_CL_TrustQB_59000
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_CL_TrustQB_59000
group by __errormessage

-- pi expenses _HoganT4__PersonalInjuryMaster_CL_ExpensesQB_58998
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_CL_ExpensesQB_58998
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_CL_ExpensesQB_58998
WHERE projectexternalid = '0619_0619'
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4__PersonalInjuryMaster_CL_ExpensesQB_58998
group by __errormessage

-- immigration trust _HoganT4__Immigration_CL_TrustQB_58996

SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4__Immigration_CL_TrustQB_58996
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4__Immigration_CL_TrustQB_58996
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4__Immigration_CL_TrustQB_58996
group by __errormessage

-- immigration expenses
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4__Immigration_CL_ExpensesQB_58994
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4__Immigration_CL_ExpensesQB_58994
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4__Immigration_CL_ExpensesQB_58994
group by __errormessage

-- immigration intake _HoganT4__Immigration_NC_Intake_58990

SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4__Immigration_NC_Intake_58990
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4__Immigration_NC_Intake_58990
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4__Immigration_NC_Intake_58990
group by __errormessage

-- immigration case summary  _HoganT4__Immigration_NC_CaseSummary_58988
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4__Immigration_NC_CaseSummary_58988
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4__Immigration_NC_CaseSummary_58988
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4__Immigration_NC_CaseSummary_58988
group by __errormessage

-- notes _HoganT4_Notes___58984
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4_Notes___58984
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4_Notes___58984
WHERE __importstatus = 70

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4_Notes___58984
group by __errormessage

--Update filevinestaging2import.._HoganT4_Notes___58984
--SET __importstatus = 40
--,__errormessage = null
--,author = 'joy6'
--WHERE __importstatus = 70

-- projects  _HoganT4_Projects___58982
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4_Projects___58982
group by __importstatus

SELECT *
FROM filevinestaging2import.._HoganT4_Projects___58982
WHERE __projectid = 14912326
WHERE __importstatus = 70



SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4_Projects___58982
group by __errormessage

-- contact details
SELECT  count(1), __importstatus
FROM filevinestaging2import.._HoganT4_ContactsCustom__CustomFields_Details_59009
group by __importstatus

SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4_ContactsCustom__CustomFields_Details_59009
group by __errormessage

SELECt *
FROM filevinestaging2import.._HoganT4_ContactsCustom__CustomFields_Details_59009


-- contactinfo
SELECT  count(1), __errormessage
FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__59008
group by __errormessage


SELECT *
FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__59008
WHERE firstname like '%aeq%'

SELECT *
FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__59008
WHERE lastname like '%ast%'

