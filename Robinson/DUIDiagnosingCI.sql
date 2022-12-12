
SELECT count(*), Filevine_ProjectTemplate
SELECT *
FROM [__FV_ClientCaseMap]
where filevine_projecttemplate <> 'Personal Injury (Master)' 
group by Filevine_ProjectTemplate

SELECT *
FROM filevinestaging2import.._RobinsonTest1_Projects___3837
where projectexternalid in(
'P_E5C4F7FB-D1B5-4CBB-BA1F-A8FD00B1A2A5_C_21EE7151-EEE0-4D3F-A1',
'P_16DB50B7-07A2-4E8F-A172-A90A010C99B9_C_A0759B45-7B7F-41DA-A4'
)
-- DUI is criminal


SELECT m.header, count(*)
FROM cases c
join matter m
on c.matterid = m.id -- 1135
group by m.header
DUI	328

select *
from matter

SELECT *
FROM filevinestaging2import.._RobinsonTest1_Projects___3837
where projectexternalid in (
SELECT distinct  a.column2
		FROM __FV_ClientCaseMap ccm
			INNER JOIN insurance i
				ON  ccm.caseid = i.casesid -- 1449
			INNER JOIN [dbo].[insurance_type] it
				ON i.insurancetypeid = it.id -- 1425
			left JOIN [PT1_CLIENT_ALIGN].[__FV_PI_Insurance_align2] a
				ON it.type = a.column2 -- 1291 inner or 1429 left
				--where it.type in ('UIM','UM','UM/UIM') -- 6 or 29 on left
				)






























