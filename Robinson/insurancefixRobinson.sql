

SELECT *
FROM filevinestaging2import.._RobinsonTest1_Projects___3837
where __projectid = '621772'

SELECt *
FROM filevinestaging2import.._RobinsonTest1__PersonalInjuryMaster_CL_Insurance_6542
WHERE projectexternalid = 'P_0F201ABE-99F9-4BA9-B91D-A8FD00B1A2A4_C_A56A4FA9-3251-433A-84'


SELECt *
FROM filevinestaging2import.._RobinsonTest1__PersonalInjuryMaster_CL_Insurance_6542
where insurancetype like '%UM%'

-- so this alignment is good
SELECT distinct it.* 
FROM insurance i
	INNER JOIN [dbo].[insurance_type] it
				ON i.insurancetypeid = it.id
where it.type in ('UIM','UM','UM/UIM')

SELECT distinct i.* 
FROM insurance i
	INNER JOIN [dbo].[insurance_type] it
				ON i.insurancetypeid = it.id
where it.type in ('UIM','UM','UM/UIM') -- 33

SELECT *
FROM filevinestaging2import.._RobinsonTest1_Projects___3837
where projectexternalid in (
SELECT projectexternalid		
		FROM __FV_ClientCaseMap ccm
			INNER JOIN insurance i
				ON  ccm.caseid = i.casesid -- 1449
			INNER JOIN [dbo].[insurance_type] it
				ON i.insurancetypeid = it.id -- 1425
			left JOIN [PT1_CLIENT_ALIGN].[__FV_PI_Insurance_align2] a
				ON it.type = a.column2 -- 1291 inner or 1429 left
				where it.type in ('UIM','UM','UM/UIM') -- 6 or 29 on left
				)



