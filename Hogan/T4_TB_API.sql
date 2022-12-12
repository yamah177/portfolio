
SELECT *
FROM [dbo].[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT]
WHERE field_value like '%RR Review%'

CM Client Meeting
CN Consulting
CC Correspondence
CO Court Time
DP Deposition
DC Documentation
DR Draft/Revise
EC Email
OM Meeting – other
OR Online Research
PC Phone Call
RS Research
RR Review
TN Training
TV Travel 

ProjectID,BillingType,ItemDescription,ItemUnit,ItemRate,ItemQuantity,ItemDate,Billable?,Chargeable?,Code1,Code2

SELECT distinct p.__projectID projectid
		,'Time' BillingType
		, e.externalNarrative itemdescription
		, 'Per hour' itemUnit 
		, e.priceperunit ItemRate
		, e.quantity itemQuantity
		, e.expenseEntryDate ItemDate
		, CASE
			when e.billed = 'Yes'
			THEN 'TRUE'
			ELSE 'FALSE'
		  END AS [Billable?]
		, CASE
			when e.billed = 'Yes'
			THEN 'TRUE'
			ELSE 'FALSE'
		  END AS [Chargeable?]
		 -- , e.expenseCode--, e.*
		  , CASE
			  WHEN nullif(t.activity,'') is not null
			  THEN nullif(t.activity,'') 
			  ELSE 'OM Other Meeting'
			END AS code1
		  , NULL CODE2
		  --, t.[user] -- robert hogan
		  , 'roberthogan' [User]
		--, code2
		--SELECT  distinct e.expenseCode--, t.*
FROM filevinestaging2import.._HoganT4_Projects___58982 p
join [ExpensebyMatterReport 20221027 090638] e
ON p.projectnumber = e.matterid
left join [TimebyUserReport 20221109 044923] t
on p.projectnumber = t.[matter id]
--WHERE nullif(t.activity,'') is null
--OM Other Meeting


SELECT *
FROM [TimebyUserReport 20221109 044923] t
ProjectID,BillingType,ItemDescription,ItemUnit,ItemRate,ItemQuantity,ItemDate,Billable?,Chargeable?,Code1,Code2

SELECT distinct  p.__projectID projectid 		
		, 'Time' BillingType
		, t.[external Narrative] itemdescription
		, CASE
			WHEN t.[billing type] = 'Hourly'
			THEN 'Per Hour'
			ELSE t.[billing type] 
		  END AS itemUnit 
		, t.rate ItemRate
		, t.[billable hours] itemQuantity
		, t.[date] ItemDate
		, CASE
			when t.[billable hours] = '0'
			THEN 'FALSE'
			ELSE 'TRUE'
		  END AS [Billable?]
		, CASE
			when t.[billable hours] = '0'
			THEN 'FALSE'
			ELSE 'TRUE'
		  END AS [Chargeable?]
		, NULLIF(t.activity, '') code1
		, NULL CODE2
		, CASE
		    WHEN t.[user] = 'Hogan Robert'
			THEN 'roberthogan'
			WHEN t.[user] = 'Blaney J'
			THEN 'joy6'
			WHEN t.[user] = 'McKeown Rachael E'
			THEN 'datamigrationteam280'
			ELSE NULL
		  END AS[User]
	--   SELECT distinct t.[billing type] 
FROM [TimebyUserReport 20221109 044923] tCROSS APPLY(SELECT TOP 1 __projectID 
			FROM filevinestaging2import.._HoganT4_Projects___58982 p
			WHERE p.projectnumber = RIGHT('0000'+CAST(t.[matter id] AS VARCHAR(4)),4)
			) p -- 1095

--	FROM [TimebyUserReport 20221109 044923] t
--join  filevinestaging2import.._HoganT4_Projects___58982 p
--on RIGHT('0000'+CAST([matter id] AS VARCHAR(4)),4)   = p.projectnumber


--FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__59008 c
--join [TimebyUserReport 20221109 044923] t
--on concat_WS(' ', c.firstname, c.lastname) = t.client
--or  replace(concat_WS(' ', c.firstname, c.lastname), ',','') = t.client

--FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__59008 c
--join [TimebyUserReport 20221109 044923] t
--on concat_WS(' ', c.firstname, c.lastname) = t.client
--or  replace(concat_WS(' ', c.firstname, c.lastname), ',','') = t.client
-----
--join __FV_clientcasemap ccm
--on ccm.contactexternalid = c.contactcustomexternalid
--join  filevinestaging2import.._HoganT4_Projects___58982 p
--on ccm.CaseID = p.projectnumber

select COUNT(*), caseid from __FV_ClientCaseMapgroup by caseid 
having count(*) > 1
-- THESE CASES HAVE TWO CONTACTS.. IF EXPENSES GO TO WRONG PROJECT HAVE CLIENT REVIEW WHICH CONTACT.

SELECT *
from __FV_ClientCaseMap
WHERE caseid = 0765

--FROM filevinestaging2import.._HoganT4_Projects___58982 p
--left  join [TimebyUserReport 20221109 044923] t
--on p.projectnumber = t.[matter id]
--OR trim(p.projectname) = trim(t.matter)




SELECT distinct matter, [matter id] 
FROM [TimebyUserReport 20221109 044923] t
--order by 1 desc
--EXCEPT
SELECT distinct matter, [matter id] 
FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__59008 c
join [TimebyUserReport 20221109 044923] t
on concat_WS(' ', c.firstname, c.lastname) = t.client
or  replace(concat_WS(' ', c.firstname, c.lastname), ',','') = t.client



SELECT distinct matter, [matter id] 
FROM [TimebyUserReport 20221109 044923] t -- 146
--order by 1 desc
EXCEPT
SELECT distinct matter, [matter id] 
FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__59008 c
join [TimebyUserReport 20221109 044923] t
on concat_WS(' ', c.firstname, c.lastname) = t.client
or  replace(concat_WS(' ', c.firstname, c.lastname), ',','') = t.client
---
left join __FV_clientcasemap ccm
on ccm.contactexternalid = c.contactcustomexternalid
left join  filevinestaging2import.._HoganT4_Projects___58982 p
on ccm.CaseID = p.projectnumber


--order by 1 desc

SELECT *
FROM filevinestaging2import.._HoganT4_ContactsCustom__ContactInfo__59008
WHERE lastname like '%Mangold%'
WHERE firstname like '%Nurturing Center%'
WHERE firstname like '%WMC - COL Bid%'

SELECT *
FROM [TimebyUserReport 20221109 044923] t -- 1097
WHERE matter like '%mangold%'


1247
565
833

--join filevinestaging2import.._HoganT4_Projects___58982 p
--on p.projectnumber = t.[matter id]

SELECT distinct projectname, projectnumber , *
FROM filevinestaging2import.._HoganT4_Projects___58982
order by 1 desc
SELECT distinct matter, [matter id] , *
FROM [TimebyUserReport 20221109 044923] t
order by 1 desc

SELECT distinct matter, CASE 
		WHEN LEN([matter id] ) = 1
		THEN '000' + [matter id] 
		WHEN LEN([matter id] ) = 2
		THEN '00' + [matter id] 
		WHEN LEN([matter id] ) = 3
		THEN '0' + [matter id] 
		WHEN LEN([matter id] ) = 4
		THEN [matter id]
		END 
FROM [TimebyUserReport 20221109 044923] t -- 146
EXCEPT
SELECT distinct matter,
	  CASE 
		WHEN LEN([matter id] ) = 1
		THEN '000' + [matter id] 
		WHEN LEN([matter id] ) = 2
		THEN '00' + [matter id] 
		WHEN LEN([matter id] ) = 3
		THEN '0' + [matter id] 
		WHEN LEN([matter id] ) = 4
		THEN [matter id]
		END  AS [matter id]
FROM [TimebyUserReport 20221109 044923] t
join filevinestaging2import.._HoganT4_Projects___58982 p
on RIGHT('0000'+CAST([matter id] AS VARCHAR(4)),4)   = p.projectnumber
