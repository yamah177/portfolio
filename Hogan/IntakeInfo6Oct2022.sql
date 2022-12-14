USE [990000153_Hogan_R1]
GO
/****** Object:  StoredProcedure [firmcentral].[usp_insert_staging_IntakeInfo]    Script Date: 10/5/2022 10:39:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[firmcentral].[usp_insert_staging_IntakeInfo]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 
		SELECT '[firmcentral].[usp_insert_staging_IntakeInfo] has been created in [990000153_Hogan_R1] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: _PersonalInjuryMaster_ */
		/*================================================================================================*/
		
		INSERT INTO
		-- delete from -- select * from
			--[PT1].[PersonalInjuryMaster_NC_IntakeInfo]
			filevinestaging2import.._HoganT1__PersonalInjuryMaster_NC_IntakeInfo_56057
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				, [legacyReferralSource]
				, [defendantVehicleDamageDescr]
				, [additionalDescriptionOfDama]
				, [medicalBillsComplete]
				, [medicalRecordsComplete]
				, [isClientStillTreating]
				, [detailsOfWhoSPayingForTr]
				, [listApproximateDatesOfPrev]
				, [previousIncidentsAtTheNurs]
				, [listAnyMedicalProviderThat]
				, [dateNotified]
				, [notificationOfNegligenceAbu]
				, [reportDocExternalID]
				, [negligenceAndOrAbuseReportContactExternalID]
				, [negligenceReported]
				, [dateOfAdmittance]
				, [residenceContactExternalID]
				, [explanationS]
				, [employer3HourlyRateSalary]
				, [employer3ContactExternalID]
				, [employer2HourlyRateSalary]
				, [employer2ContactExternalID]
				, [losingWages]
				, [employed]
				, [amountOfDamagesToClientS]
				, [amountOfDamagesToDefendant]
				, [currentLocationOfDefendant]
				, [defendantSVehicleTowedByContactExternalID]
				, [defendantSVehicleTowed]
				, [currentLocationOfClientSV]
				, [defendantSPlateNo]
				, [photosOfClientSDamagesDocExternalIdCsv]
				, [photosOfDefendantSDamagesDocExternalIdCsv]
				, [describeDamagesAndAmounts]
				, [listDateOfAccidentInjurie]
				, [describeDamagesThingsClien]
				, [w21099DocExternalIdCsv]
				, [additionalEmployment]
				, [lostWageNotes]
				, [medicalProviderNotes]
				, [witnessNotes]
				, [initialInsuranceNotes]
				, [marriageDetailsHowLongMar]
				, [authorityCalledToTheSceneContactExternalID]
				, [animalControlWardenContactExternalID]
				, [descriptionOfAnimal]
				, [countyOfAccident]
				, [lossOfConsortiumClaim]
				, [propertyownersContactExternalIdCsv]
				, [responsibleemployerContactExternalID]
				, [prioraccidentsclaims]
				, [probatecountycourtContactExternalID]
				, [probateopened]
				, [probatecasenumber]
				, [wrongfuldeath1]
				, [leadqualified]
				, [intakedocumentsDocExternalIdCsv]
				, [paystubsifanyDocExternalIdCsv]
				, [clientasvisitortotheprop]
				, [clientsplateno]
				, [deadlinetoprovidenoticeofDueDate]
				, [deadlinetoprovidenoticeofDoneDate]
				, [governmentagencynoticeofcl]
				, [clientwas]
				, [vehicleownerContactExternalID]
				, [whoreceivedacitation]
				, [otheraccidenttype]
				, [referredouttoContactExternalID]
				, [referredfromContactExternalID]
				, [personperformingintakeContactExternalID]
				, [payperiod]
				, [animalownerContactExternalIdCsv]
				, [manufacturerContactExternalIdCsv]
				, [physicianshospitalsorotheContactExternalIdCsv]
				, [whoispayingfortreatmentContactExternalID]
				, [defendantvehicletype]
				, [referralsourcefee]
				, [injuriessustained]
				, [clientvehicletype]
				, [weatherandroadconditions]
				, [executorContactExternalID]
				, [hasanestatebeenopened]
				, [personalrepresentativeContactExternalID]
				, [dateofdeath]
				, [datecontractsent]
				, [datecontractsigned]
				, [reasonfordeclining]
				, [taxreturnsDocExternalIdCsv]
				, [leadstatus]
				, [whatimplantandwherewasitimplanted]
				, [wasinjurycausedbydefectivesurgicalimplant]
				, [forwhatconditionwereyouoriginallyseeingdoct]
				, [othermedmal]
				, [typeofmedmal]
				, [permanentinjury]
				, [nameofambulanceContactExternalID]
				, [wereyoutransportedinanambulance]
				, [referralfee]
				, [referralsource]
				, [dateofintake]
				, [locationofaccident]
				, [additionaldocsDocExternalIdCsv]
				, [authorizedtreatingphysicianContactExternalID]
				, [additionalinfo]
				, [supervisorContactExternalID]
				, [product]
				, [amountperperiod]
				, [benefitsreceivingreceived]
				, [receivingbenefits]
				, [whatform4336etc]
				, [responsegiven]
				, [towhomwasitgivenContactExternalID]
				, [accidentsreportfirstreportofinjuryuploadDocExternalID]
				, [accidentreportfirstreportofinjury]
				, [lastdateworked]
				, [clientjobdescriptiontitleduties]
				, [reviewsocialmedialetterpolicy]
				, [subsequentaccidents]
				, [healthhistoryoverallhealthsurgeriesbrokenbonesetc]
				, [clientshourlyratesalary]
				, [duties]
				, [jobtitle]
				, [lostwagesend]
				, [lostwagesstart]
				, [employerContactExternalID]
				, [picturesofinjuriesDocExternalIdCsv]
				, [injuriessustainedpaincomplaints]
				, [towedbyContactExternalID]
				, [vehicletowed]
				, [damagetodefendantsvehicle]
				, [defendantsvehiclemakemodel]
				, [damagetoclientsvehicle]
				, [clientsvehiclemakemodel]
				, [policereportuploadDocExternalID]
				, [policereport]
				, [accidentdiagramsDocExternalIdCsv]
				, [descriptionofaccident]
				, [uploadpremisepicsDocExternalIdCsv]
				, [werecitationsissued]
				, [timeofaccident]
				, [accidenttype]
			)
		SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, c.clientReferredBy [legacyReferralSource]
			, NULL [defendantVehicleDamageDescr]
			, NULL [additionalDescriptionOfDama]
			, CASE
				WHEN m.medicalBillsComplete = 'Yes'
				THEN 1
				WHEN m.medicalBillsComplete = 'No'
				THEN 0
				ELSE NULL
			  END AS [medicalBillsComplete]
			, CASE
				WHEN m.[medicalRecordsComplete] = 'Yes'
				THEN 1
				WHEN m.[medicalRecordsComplete] = 'No'
				THEN 0
				ELSE NULL
			  END AS  [medicalRecordsComplete]
			, CASE
				WHEN m.[ClientStillTreating] = 'Yes'
				THEN 1
				WHEN m.[ClientStillTreating] = 'No'
				THEN 0
				ELSE NULL
			  END AS  [isClientStillTreating]
			, NULL [detailsOfWhoSPayingForTr]
			, NULL [listApproximateDatesOfPrev]
			, NULL [previousIncidentsAtTheNurs]
			, NULL [listAnyMedicalProviderThat]
			, NULL [dateNotified]
			, NULL [notificationOfNegligenceAbu]
			, NULL [reportDocExternalID]
			, NULL [negligenceAndOrAbuseReportContactExternalID]
			, NULL [negligenceReported]
			, NULL [dateOfAdmittance]
			, NULL [residenceContactExternalID]
			, NULL [explanationS]
			, NULL [employer3HourlyRateSalary]
			, NULL [employer3ContactExternalID]
			, NULL [employer2HourlyRateSalary]
			, NULL [employer2ContactExternalID]
			, NULL [losingWages]
			, NULL [employed]
			, NULL [amountOfDamagesToClientS]
			, NULL [amountOfDamagesToDefendant]
			, NULL [currentLocationOfDefendant]
			, NULL [defendantSVehicleTowedByContactExternalID]
			, NULL [defendantSVehicleTowed]
			, NULL [currentLocationOfClientSV]
			, NULL [defendantSPlateNo]
			, NULL [photosOfClientSDamagesDocExternalIdCsv]
			, NULL [photosOfDefendantSDamagesDocExternalIdCsv]
			, NULL [describeDamagesAndAmounts]
			, NULL [listDateOfAccidentInjurie]
			, NULL [describeDamagesThingsClien]
			, NULL [w21099DocExternalIdCsv]
			, NULL [additionalEmployment]
			, NULL [lostWageNotes]
			, c.[MedicalProviders] [medicalProviderNotes] -- 
			, NULL [witnessNotes]
			, NULL [initialInsuranceNotes]
			, NULL [marriageDetailsHowLongMar]
			, NULL [authorityCalledToTheSceneContactExternalID]
			, NULL [animalControlWardenContactExternalID]
			, NULL [descriptionOfAnimal]
			, NULL [countyOfAccident]
			, NULL [lossOfConsortiumClaim]
			, NULL [propertyownersContactExternalIdCsv]
			, NULL [responsibleemployerContactExternalID]
			, NULL [prioraccidentsclaims]
			, NULL [probatecountycourtContactExternalID]
			, NULL [probateopened]
			, NULL [probatecasenumber]
			, NULL [wrongfuldeath1]
			, NULL [leadqualified]
			, NULL [intakedocumentsDocExternalIdCsv]
			, NULL [paystubsifanyDocExternalIdCsv]
			, NULL [clientasvisitortotheprop]
			, NULL [clientsplateno]
			, NULL [deadlinetoprovidenoticeofDueDate]
			, NULL [deadlinetoprovidenoticeofDoneDate]
			, NULL [governmentagencynoticeofcl]
			, NULL [clientwas]
			, NULL [vehicleownerContactExternalID]
			, NULL [whoreceivedacitation]
			, NULL [otheraccidenttype]
			, NULL [referredouttoContactExternalID]
			, NULL [referredfromContactExternalID]
			, NULL [personperformingintakeContactExternalID]
			, NULL [payperiod]
			, NULL [animalownerContactExternalIdCsv]
			, NULL [manufacturerContactExternalIdCsv]
			, NULL [physicianshospitalsorotheContactExternalIdCsv]
			, NULL [whoispayingfortreatmentContactExternalID]
			, NULL [defendantvehicletype]
			, NULL [referralsourcefee]
			, NULL [injuriessustained]
			, NULL [clientvehicletype]
			, NULL [weatherandroadconditions]
			, NULL [executorContactExternalID]
			, NULL [hasanestatebeenopened]
			, NULL [personalrepresentativeContactExternalID]
			, NULL [dateofdeath]
			, NULL [datecontractsent]
			, NULL [datecontractsigned]
			, NULL [reasonfordeclining]
			, NULL [taxreturnsDocExternalIdCsv]
			, NULL [leadstatus]
			, NULL [whatimplantandwherewasitimplanted]
			, NULL [wasinjurycausedbydefectivesurgicalimplant]
			, NULL [forwhatconditionwereyouoriginallyseeingdoct]
			, NULL [othermedmal]
			, NULL [typeofmedmal]
			, NULL [permanentinjury]
			, NULL [nameofambulanceContactExternalID]
			, NULL [wereyoutransportedinanambulance]
			, NULL [referralfee]
			, NULL [referralsource]
			, m.opendate [dateofintake]
			, NULL [locationofaccident]
			, NULL [additionaldocsDocExternalIdCsv]
			, NULL [authorizedtreatingphysicianContactExternalID]
			, NULL [additionalinfo]
			, NULL [supervisorContactExternalID]
			, NULL [product]
			, NULL [amountperperiod]
			, NULL [benefitsreceivingreceived]
			, NULL [receivingbenefits]
			, NULL [whatform4336etc]
			, NULL [responsegiven]
			, NULL [towhomwasitgivenContactExternalID]
			, NULL [accidentsreportfirstreportofinjuryuploadDocExternalID]
			, NULL [accidentreportfirstreportofinjury]
			, NULL [lastdateworked]
			, NULL [clientjobdescriptiontitleduties]
			, NULL [reviewsocialmedialetterpolicy]
			, NULL [subsequentaccidents]
			, NULL [healthhistoryoverallhealthsurgeriesbrokenbonesetc]
			, NULL [clientshourlyratesalary]
			, NULL [duties]
			, c.jobtitle [jobtitle]
			, NULL [lostwagesend]
			, NULL [lostwagesstart]
			, /*c.employer*/ null [employerContactExternalID] -- need legacy field
			, NULL [picturesofinjuriesDocExternalIdCsv]
			, NULL [injuriessustainedpaincomplaints]
			, NULL [towedbyContactExternalID]
			, NULL [vehicletowed]
			, NULL [damagetodefendantsvehicle]
			, NULL [defendantsvehiclemakemodel]
			, NULL [damagetoclientsvehicle]
			, NULL [clientsvehiclemakemodel]
			, NULL [policereportuploadDocExternalID]
			, NULL [policereport]
			, NULL [accidentdiagramsDocExternalIdCsv]
			, CASE
				WHEN m.[Description] is not null
				AND m.memo is not null
				THEN CONCAT('Description: ', m.[Description], CHAR(13), 'Memo: ', m.memo)
				
				WHEN m.[Description] is null
				AND m.memo is not null
				THEN CONCAT('Memo: ', m.memo) 
				
				WHEN m.[Description] is not null
				AND m.memo is null
				THEN CONCAT('Description: ', m.[Description])
				ELSE NULL
			  END AS [descriptionofaccident]
			, NULL [uploadpremisepicsDocExternalIdCsv]
			, NULL [werecitationsissued]
			, NULL [timeofaccident]
			--, m.casetype
			, CASE
				WHEN a.incident_Type_PI_Template  = 'Wills & Estate Planning'
				THEN 'Wills and Estate Planning'
				WHEN a.incident_Type_PI_Template = 'Wrongful Death'
				THEN NULL
				ELSE a.incident_Type_PI_Template 
			  END AS [accidenttype]
	-- SELECT distinct c.[MedicalProviders] --c.employer, ci.*
		FROM __FV_ClientCaseMap ccm
		JOIN 	[dbo].[Firm Central Matters_20220518] m
			ON ccm.caseid = m.matternumber
		left join [Firm Central Contacts_20220519] c 
			on iif(preferredname is null,coalesce(nullif(concat(lastname,', ',firstname),', '),businessname),coalesce(nullif(concat(lastname,', ',firstname,' "',preferredname,'"'),', '),businessname)) = m.ClientName
			AND c.clientNumber = ccm.caseid
			left join [PT1].[ContactsCustom__ContactInfo] ci
			on c.employer = ci.firstname 
		LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_Hogan_PI_Intake_AccidentTypeAlign] a
			ON m.casetype = a.casetype_firm_central
			WHERE ccm.filevine_projectTemplate = 'Personal Injury (Master)'
			AND ProjectExternalID = '0282_0308'
		
		
		SELECt *
		FROM pt1.projects
		WHERE projectname like '%scott%'
		
		--WHERE c.clientNumber <> 1033
			--order by 1 
		
--		SELECT *
--			FROM [PT1].[ContactsCustom__ContactInfo] 
--			WHERE firstname like '%shaw%'
--Torchy's Tacos
--UMC

			/*
			Civil RightsConsumer LawContractsFamily LawInsurancePersonal InjuryWills & Estate PlanningWills and Estate Planning
			SELECt *
			FROM [PT1_CLIENT_ALIGN].[__FV_Hogan_PI_Intake_AccidentTypeAlign]
		
		'Other' 
		'Workers'' Comp (WC)' 
		'Wills and Estate Planning' 
		'Trucking Collision' 
		'Torts' 
		'Products Liability' 
		'Product Liability' 
		'Premise Liability'-- 
		'Personal Injury' --
		'Nursing Home Negligence' 
		'Motor Vehicle Collision' 
		'Medical Malpractice' 
		'Insurance' --
		'Immigration and Citizenship' 
		'General Practice' 
		'Family Law' --
		'Education Law' 
		'Dual - Trucking Collision / WC' 
		'Dual - Product Liability / Motor Vehicle Collision' 
		'Dual - Premise Liability / WC' 
		'Dual - Motor Vehicle Collision / WC' 
		'Dog Bite' 
		'Debtor/Creditor' 
		'Criminal Law' 
		'Corporations/Business Entitities' 
		'Contracts' --
		'Consumer Law' --
		'Civil Rights' --
		'Business Transactions'
		*/
				--SELECt distinct [ClientStillTreating] 
				--FROM [dbo].[Firm Central Matters_20220518]

				--[medicalRecordsComplete]
				--[ClientStillTreating] 


	END
														