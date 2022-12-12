
SELECT *
FROM FilevineStaging2Import.._RobinsonTest1_Contacts___3841
where __ErrorMessage <> ''


SELECT *
FROM FilevineStaging2Import.._RobinsonTest1_Projects___3837
where projectexternalid = 'P_7676B582-C59F-4113-8912-A8FD00B1A29E_C_E60A8C45-A09F-4EBF-80'

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__PersonalInjuryMaster_NC_CaseSummarySettle_3843
where __ErrorMessage <> ''
--P_7676B582-C59F-4113-8912-A8FD00B1A29E_C_E60A8C45-A09F-4EBF-80
--cannot find matching person for assignedparalegalContactExternalID

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__CriminalMaster_NC_ProsecutionSummary_3851
where __ErrorMessage <> ''
cannot find matching person for assignedparalegalContactExternalID


SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__PersonalInjuryMaster_NC_Intake_6451
where __ErrorMessage <> ''
cannot find matching person for assignedparalegalContactExternalID
