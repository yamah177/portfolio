
SELECT *
FROM FilevineStaging2Import.._RobinsonTest1_Contacts___3841
--where __errormessage <> ''
where contactexternalid in ('C-CD9C2314-7413-44F9-83EC-A8FD00B14895','C-5334DC04-FFC5-41C3-93B6-A8FD00B14895')

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1_Projects___3837
--where __errormessage <> ''
where projectexternalid = 'P_017E8AF8-9155-4081-8935-A97B0101D5B4_C_27CA4CC2-3C2B-40B2-B5'
where projectexternalid = 'P_7676B582-C59F-4113-8912-A8FD00B1A29E_C_E60A8C45-A09F-4EBF-80'
and C-CD9C2314-7413-44F9-83EC-A8FD00B14895,C-5334DC04-FFC5-41C3-93B6-A8FD00B14895 -- assignedparalegalcontactexternalid


SELECT *
FROM FilevineStaging2Import.._RobinsonTest1_Notes___3839
where __errormessage <> ''

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__PersonalInjuryMaster_NC_CaseSummarySettle_3843
where __errormessage <> ''

-- accomodate this in the next test
--update FilevineStaging2Import.._RobinsonTest1__PersonalInjuryMaster_NC_CaseSummarySettle_3843
--set __importstatus  = 40
--, __errormessage = null
--, assignedparalegalcontactexternalid = 'C-5334DC04-FFC5-41C3-93B6-A8FD00B14895'
--where projectexternalid = 'P_7676B582-C59F-4113-8912-A8FD00B1A29E_C_E60A8C45-A09F-4EBF-80'

--P_7676B582-C59F-4113-8912-A8FD00B1A29E_C_E60A8C45-A09F-4EBF-80
--and C-CD9C2314-7413-44F9-83EC-A8FD00B14895,C-5334DC04-FFC5-41C3-93B6-A8FD00B14895 -- assignedparalegalcontactexternalid

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__PersonalInjuryMaster_NC_Litigation_3847
where __errormessage <> ''

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__CriminalMaster_NC_ProsecutionSummary_3851
where __errormessage <> ''
cannot find matching person for assignedparalegalContactExternalID
P_7676B582-C59F-4113-8912-A8FD00B1A29E_C_E60A8C45-A09F-4EBF-80
C-CD9C2314-7413-44F9-83EC-A8FD00B14895,C-5334DC04-FFC5-41C3-93B6-A8FD00B14895 -- assignedparalegalcontactexternalid

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1_ProjectContacts___3855
where __errormessage <> ''

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1_Deadlines___3857
where __errormessage <> ''

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__PersonalInjuryMaster_NC_Intake_6451
where __errormessage <> ''


SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__PersonalInjuryMaster_CL_Insurance_6542
where __errormessage <> ''

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__CriminalMaster_NC_Intake_6865
where __errormessage <> ''

SELECT *
FROM FilevineStaging2Import.._RobinsonTest1__PersonalInjuryMaster_CL_Expenses_6956
where __errormessage <> ''
