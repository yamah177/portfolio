-- T2 Dorato Validation

--gal case intake 
select count(*), __errormessage
FROM filevinestaging2import.._Dorato_T2__GAL_NC_GuardianCaseIntake_52634
group by __errormessage


_Dorato_T2__GAL_NC_GuardianCaseIntake_52634

-- pi intake info

select count(*), __errormessage
FROM filevinestaging2import.._Dorato_T2__PITemplate_NC_IntakeInfo_52632
group by __errormessage

-- projects 
--update filevinestaging2import.._Dorato_T2_Projects___52626
--set username = 'derek'
--, __importstatus = 40
--, __errormessage = null
--where username = 'derekweems'

SELECT *
FROM filevinestaging2import.._Dorato_T2_Projects___52626
WHERE __importstatus = 70

select count(*), __errormessage
FROM filevinestaging2import.._Dorato_T2_Projects___52626
group by __errormessage

select count(*), __importstatus
FROM filevinestaging2import.._Dorato_T2_Projects___52626
group by __importstatus



-- interesting error contact details
select count(*), __errormessage
FROM filevinestaging2import.._Dorato_T2_ContactsCustom__CustomFields_Details_52674
group by __errormessage

select count(*), __importstatus
FROM filevinestaging2import.._Dorato_T2_ContactsCustom__CustomFields_Details_52674
group by __importstatus


