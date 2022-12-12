
SELECT count(*), __importstatus
FROM 			filevinestaging2import.._RobinsonTest2__PersonalInjuryMaster_CL_Liens_8256
group by __importstatus

SELECT *
FROM pt1.contacts c
join filevinestaging2import.._RobinsonTest2__PersonalInjuryMaster_CL_Liens_8256 l
on c.contactexternalid = concat('C_', l.lienholdercontactexternalid)

SELECt *
FROM 			filevinestaging2import.._RobinsonTest2__PersonalInjuryMaster_CL_Liens_8256 l
-- cannot find matching person for lienholderContactExternalID


UPDATE filevinestaging2import.._RobinsonTest2__PersonalInjuryMaster_CL_Meds_8258
set __importstatus = 40
,  [CollectionItemExternalID] = [CollectionItemExternalID] + '1'
--------

SELECT count(*), __importstatus
FROM 	FilevineStaging2Import.._RobinsonTest2__PersonalInjuryMaster_CL_Meds_8258
group by __importstatus

SELECT *
FROM FilevineStaging2Import.._RobinsonTest2__PersonalInjuryMaster_CL_Meds_8254
cannot find matching person for providerContactExternalID

-- sanchez cerrato

SELECT *
FROM FilevineStaging2Import.._RobinsonTest2_Projects___8159
where ProjectExternalID IN (
'P_601E5A41-6B51-4201-A16D-A93D00B392C5_C_68D6DECC-3A39-4391-8B',
'P_633B5682-2C3D-4A0E-B4C6-A93D00AEB7DA_C_A8647182-AC4E-4390-8A',
'P_929A6A57-84C5-435D-AE74-A92D009F6D7B_C_FAB3F237-87B3-49A9-8B',
'P_A818B340-4FE2-4E04-87CE-A90600FDD1D5_C_414EBA00-FE8C-40BD-AE',
'P_BE5C6B21-F8E9-4676-9262-A93D00C48C72_C_72A05020-CBA5-4C92-AC',
'P_C0382C42-B9A0-4E13-881A-AB3600F35A4F_C_889FFF4D-8482-4174-B6'
)


