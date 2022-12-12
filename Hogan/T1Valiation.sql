-- hogan T1 validation

-- immigration intake _HoganT1__Immigration_NC_Intake_54766
SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT1__Immigration_NC_Intake_54766 -- 643
group by __errormessage

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT1__Immigration_NC_Intake_54766 -- 643
group by __importstatus


-- immigration ncase summary _HoganT1__Immigration_NC_CaseSummary_54764
SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT1__Immigration_NC_CaseSummary_54764 -- 643
group by __errormessage

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT1__Immigration_NC_CaseSummary_54764 -- 643
group by __importstatus

SELECT distinct *
FROM filevinestaging2import.._HoganT1__Immigration_NC_CaseSummary_54764 -- 643
WHERE primaryAttorneyContactExternalid IN (
SELECT contactcustomexternalid
FROM filevinestaging2import.._HoganT1_ContactsCustom__ContactInfo__54786 -- 748
										)

SELECT *
FROM filevinestaging2import.._HoganT1_ContactsCustom__ContactInfo__54786 -- 748
where firstname = 'robert'

-- notes  _HoganT1_Notes___54762
--update filevinestaging2import.._HoganT1_Notes___54762 -- 643
--set author = 'joy6'
--, __importstatus = 40
--, __errormessage = null
--WHERE author = 'joyblaney'

SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT1_Notes___54762 -- 643
group by __errormessage

SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT1_Notes___54762 -- 643
group by __importstatus

SELECT distinct *
FROM filevinestaging2import.._HoganT1_Notes___54762 -- 643
WHERE author = 'joyblaney'

--update filevinestaging2import.._HoganT1_Notes___54762 -- 643
--set author = 'joy6'
--WHERE author = 'joyblaney'

-- projects _HoganT1_Projects___54760
SELECT count(1), __errormessage
FROM filevinestaging2import.._HoganT1_Projects___54760 -- 643
group by __errormessage


--update filevinestaging2import.._HoganT1_Projects___54760 -- 643
--SET username = 'joy6'
--, __errormessage = null
--, __importstatus  = 40
--WHERE __errormessage = 'cannot find correct primary for new project joyblaney'

--update filevinestaging2import.._HoganT1_Projects___54760 -- 643
--SET  __errormessage = null
--, __importstatus  = 40
--WHERE __importstatus = 70

--joy6
--NormaTambunga@filevine.com
--roberthogan@filevine.com
--jessicajones@filevine.com
SELECT count(1), __importstatus
FROM filevinestaging2import.._HoganT1_Projects___54760 -- 643
group by __importstatus

SELECT distinct *
FROM filevinestaging2import.._HoganT1_Projects___54760 -- 643
WHERE __errormessage = 'cannot find correct primary for new project jessicajones'
WHERE projectexternalid in (
								SELECT projectexternalid 
								FROM __FV_Clientcasemap		
									) -- 643

-- contactdetails
SELECT distinct *
FROM filevinestaging2import.._HoganT1_ContactsCustom__CustomFields_Details_54787 -- 316
WHERE contactcustomexternalid in (
								SELECT contactexternalid
								FROM __FV_Clientcasemap		
									) -- 313


-- contactinfo
SELECT distinct --contacttypelist 
FROM filevinestaging2import.._HoganT1_ContactsCustom__ContactInfo__54786 -- 748
WHERE contacttypelist = 'Client' -- 582
AND contactcustomexternalid in (
								SELECT contactexternalid
								FROM __FV_Clientcasemap		
									) -- 564



SELECT *
FROM __FV_Clientcasemap

