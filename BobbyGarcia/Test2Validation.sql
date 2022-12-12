-- Test 2 validation
-- documents
--SELECT *
		--FROM 			filevinestagingimport.._BobbyGarciaTest2_Documents___550064167
SELECt count(*), __importstatus
FROM filevinestagingimport.._BobbyGarciaTest2_Documents___550064167
group by __importstatus

SELECt count(*), __errormessage
FROM filevinestagingimport.._BobbyGarciaTest2_Documents___550064167
group by __errormessage

-- projects
SELECt *
FROM filevinestagingimport.._BobbyGarciaTest2_Projects___550064163
WHERE projectexternalid not in (SELECt projectexternalid
										FROM __fv_clientcasemap)

SELECt count(*), __importstatus
FROM filevinestagingimport.._BobbyGarciaTest2_Projects___550064163
group by __importstatus

SELECt count(*), __errormessage
FROM filevinestagingimport.._BobbyGarciaTest2_Projects___550064163
group by __errormessage
-- Contacts
SELECt *
FROM filevinestagingimport.._BobbyGarciaTest2_ContactsCustom__ContactInfo__550064230

SELECt *
FROM filevinestagingimport.._BobbyGarciaTest2_ContactsCustom__ContactInfo__550064230
WHERE contactcustomexternalid in (SELECt contactexternalid 
										FROM __fv_clientcasemap)

SELECt count(*), __importstatus
FROM filevinestagingimport.._BobbyGarciaTest2_ContactsCustom__ContactInfo__550064230
group by __importstatus



SELECt count(*), __errormessage
FROM filevinestagingimport.._BobbyGarciaTest2_ContactsCustom__ContactInfo__550064230
group by __errormessage

