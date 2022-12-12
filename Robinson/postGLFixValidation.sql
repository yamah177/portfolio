-- scope of issue

SELECT __projectID
FROM filevineproductionimport.._RobinsonAssociates_Projects___61528
-- projectid (all of them in excel, name of section, columnname and data. 
api key from IC.

SELECt *
FROM filevineproductionimport.._RobinsonAssociates__CriminalMaster_NC_Intake_61540
-- Column names: descriptionofincident, statementsmadeToPolice_1

SELECT *
FROM filevineproductionimport.._RobinsonAssociates__PersonalInjuryMaster_NC_Intake_61536
-- Column names: descriptionofaccident, injuriessustainedpaincomplaints, locationOfAccident, whatweretheclientstreatme

-- We're gonna see this issue in the criminal master intake too, everything got cut off by the cast to varchar in description of incident and Also Statements Made to police
-- personal injury intake has issues with description of incident and injuriessustainedpaincomplaints, locationOfAccident, whatweretheclientstreame.
-- validation below 
SELECt *
FROM filevineproductionimport.._RobinsonAssociates_Projects___61528
where projectname like   'Abongmekam Epsn, et al. v. Thomas'
-- see that this has project template of Personal Injury (Master)

-- not in PI intake
SELECt *
FROM filevineproductionimport.._RobinsonAssociates__PersonalInjuryMaster_NC_Intake_61536
where projectexternalid = 'P_0F201ABE-99F9-4BA9-B91D-A8FD00B1A2A4_C_A56A4FA9-3251-433A-84'

-- but it is in criminal intake
SELECt *
FROM filevineproductionimport.._RobinsonAssociates__CriminalMaster_NC_Intake_61540
where projectexternalid = 'P_0F201ABE-99F9-4BA9-B91D-A8FD00B1A2A4_C_A56A4FA9-3251-433A-84'

-- description of accient does not show on front end
https://robinsonassociates.fvmigration.com/#/project/94825/custom/intake206


