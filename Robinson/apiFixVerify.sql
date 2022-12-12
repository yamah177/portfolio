


SELECt *
FROM filevineproductionimport.._RobinsonAssociates_Projects___61528
where __projectid = 9579021

-- criminal intake
SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, NULL [timeofincident]
			, NULL [placeofincident]
			, cast(c.synopsis as varchar(max)) [descriptionofincident]
			, NULL [policeinvolvement]
			, NULL [911calluploadDocExternalID]
			, NULL [complainingwitnessContactExternalID]
			, NULL [arrest]
			, c.date_of_incident [dateofarrest] -- column 13
			, null arrestingofficerContactExternalID --, ArrestingOfficer.[data] [arrestingofficerContactExternalID] -- null it out. customer can convert to a plain text field. create contact cards is the other option
			, NULL [identification]
			, NULL [searchwarrant]
			, NULL [bodilyfluidscollected]
			, NULL [dui]
			, cast(bac.[data] as varchar(max)) [bac]
			, NULL [basisforstop]
			, c.intake_date [dateofintake]
			, NULLIF(CONCAT('C_', c.staffintakeid), 'C_') [personperformingintakeContactExternalID]
			, null [referralsource] --c.ReferredBy_namesid [referralsource] -- alignment?
			, NULLIF(CONCAT('C_', c.[ReferredBy_namesid]), 'C_')[referredfromContactExternalID]
			, CASE	
				WHEN c.[ReferredTo_namesid] IS NOT NULL 
				THEN 'Case Referred Out'
			  END AS [leadstatus]
			, NULLIF(CONCAT('C_',  c.ReferredTo_namesid), 'C_') [referredouttoContactExternalID]
			, NULL [referralfee]
			, NULL [reasonfordeclining]
			, NULL [datecontractsigned]
			, NULL [citizenship]
			, NULL [countyArrest]
			, NULL [baildetails]
			, NULL [priors]
			, NULL [listallpriors]
			, NULL [listallpendingcases]
			, c.date_of_incident [dateofincident]
			, NULL [referralsourcefee]
			, NULL [datecontractsent]
			, NULL [appointmentdate]
			, NULL [appointmenttime]
			, NULL [iscallertheclient]
			, NULL [callerContactExternalID]
			, NULL [relationshiptoclient]
			, NULLIF(CONCAT('C_', policeagencY.namesid), 'C_') [policeagencyContactExternalID] -- THIS NEEDS TO BE TEXT OR TAKE THE NAME AND CROSS REFERENCE BACK TO CONTACTS TO GET THE NAMEID. 
			, NULL [relationshipbetweentheparti]
			, NULL [wereyouonprobationorparol]
			, NULL [forwhichoffenseincludingt]
			, NULL [statementSMadeToPolice]
			, [trialDate].[casedate] [trialDate]
			, NULL [breathTest]
			, NULL [resultsOfBreathTest]
			, NULL [knowingRefusal]
			, NULL [age]
			, NULL [reasonForStop]
			, NULL [soundex]
			, CASE
				WHEN d2.casedate is not null
				AND d2.[datelabelid] = 'F2EDEA90-4DE0-424E-A294-A90B01044756'
				THEN 1
			  END AS [doWeNeedMVAHearing]
			, NULL [whoWillFile]
			, NULL [bACTechContactExternalID]
			, cast(accident.[data] as varchar) [accident]
			, NULL [airbagDeployed]
			, NULL [injuries]
			, NULL [singleCarAccident]
			, NULL [describeNatureOfInjuriesAn]
			, NULL [mVAIssues]
			, NULL [explain]
			, NULL [dR15OrBlowIssues]
			, NULL [describeNatureOfBlowIssues]
			, NULL [stopAndArrestIssues]
			, NULL [describe]
			, NULL [willTakeInterlock]
			, NULL [secretClearance]
			, NULL [minor]
			, NULL [provisionalLicense]
			, NULL [uSCitizen]
			, NULL [cDLDriver]
			, NULL [chargesTickets]
			, NULL [admissionsRegardingDrinking]
			, NULL [stateRequireAnyCivilianWit]
			, NULL [civilianWitnessesContactExternalIdCsv]
			, NULL [modelAndColorOfCar]
			, NULL [passengersInCarAtTimeOfA]
			, NULL [blowChecklistEvents]
			, NULL [explanation]
			, NULL [fSTsPerformed]
			, NULL [testsPerformed]
			, NULL [locationConditionOfTesting]
			, NULL [weatherTemperature]
			, NULL [clothingShoes]
			, NULL [priorInjuriesToTheBody]
			, NULL [priorInjuries]
			, NULL [medicationsTakenDaily]
			, NULL [listOfMedications]
			, NULL [dyslexicOrADHD]
			, NULL [which]
			, NULL [familyHistoryOfAlcoholAbus]
			, NULL [whoAndWhatExtent]
			, NULL [priorDUIOrCriminalCharges]
			, NULL [whichAndWhen]
			, NULL [currentPointsOnLicense]
			, NULL [pointDetails]
			, NULL [whereEducationWasCompleted]
			, NULL [whatIsTheirDegreeIn]
			, NULL [doTheyHaveClearance]
			, NULL [whoIsTheirEmployerAndHow]
			, NULL [whatIsTheirJobTitle]
			, NULL [whatAlcoholClassReferred]
			, NULL [maritalStatus]
			, NULL [children]
			, NULL [politeAndCourteous]
			, NULL [military]
			, NULL [stateOfLicense]
			, NULL [wasMVAHearingRequested]
			, NULL [mVASubmittedDocDocExternalID]
			, NULL [complainingWitness_1]
			, NULL [picturesOfAccidentDocExternalIdCsv]
			, NULL [statementsAndDocsDocExternalIdCsv]
			, NULL [ownerOfTheCar]
			, NULL [passengersInCar]
			, NULL [howFarInSchool_1]
			, NULL [clientAdvisement]
			, NULL [informationOnChildren]
			, NULL [informationOnMilitaryServic]
			, c.ReferredBy_namesid [otherReferralSource]
			--, PAN.[DATA] [policeAgencyNeedles]   -- was told to skip it. 
			, NULL [arrestingOfficeNeedles]
			, NULL [countyOfArrestNeedles]
			, cast([statement].[data] as varchar(max)) [statementsmadetopolice_1]
			, d2.casedate mvahearing
	-- SELECT distinct ccm.ProjectExternalID , count(*)
		FROM __FV_ClientCaseMap ccm
			 JOIN dbo.[cases] C
				ON CCM.CaseID = C.[id] -- 723
			left JOIN user_tab6_data utd
				ON C.id = utd.casesid -- 5506
			left JOIN dbo.case_dates d
				ON c.id = d.[casesid] -- 456
			
			LEFT JOIN [user_tab6_data] ArrestingOfficer
				ON ArrestingOfficer.casesid = CCM.CaseID
				AND  ArrestingOfficer.usercasefieldid = '22941F2B-F522-4F85-8777-A8FD00B1C245' -- 22941F2B-F522-4F85-8777-A8FD00B1C245
			LEFT JOIN [user_tab6_data] bac
				ON bac.casesid = CCM.CaseID
				AND  bac.usercasefieldid = 'EAE524D0-C016-4C73-BCBA-A8FD00B1C245'
			LEFT JOIN [user_tab6_data] policeagency
				ON policeagency.casesid = CCM.CaseID
				AND  policeagency.usercasefieldid = '93A1C269-4A57-4655-BFFA-A8FD00B1C245'
			LEFT JOIN [user_tab6_data] [statement]
				ON [statement].casesid = CCM.CaseID
				AND  [statement].usercasefieldid = 'F6C918C6-39FE-4ADE-A16F-A8FD00B1C244'
			LEFT JOIN case_dates [trialDate]
				ON [trialDate].casesid = CCM.CaseID
				AND  trialdate.[datelabelid] = '6852E3CF-893B-4C22-895A-A8FD00B1A231'
			LEFT JOIN [user_tab6_data] accident
				ON accident.casesid = CCM.CaseID
				AND  accident.usercasefieldid = '8EF5A630-E40A-45AB-BBBB-A90B00C2ADC8'
			LEFT join dbo.case_dates d2
				ON c.id = d2.casesid
				and d2. [datelabelid] = 'F2EDEA90-4DE0-424E-A294-A90B01044756'
				where ccm.filevine_projecttemplate = 'Criminal (Master)'
				and ccm.projectexternalid = 'P_AF021B2F-8693-47C6-AF2F-AB26013FB7AA_C_43FBEA7A-B018-4933-B3'

				SELECT *
				FROM FilevineProductionImport.._RobinsonAssociates__CriminalMaster_NC_Intake_61540
				where statementSMadeToPolice_1 is null

				SELECT witnessesstatementsgiven
				FROM FilevineProductionImport.._RobinsonAssociates__PersonalInjuryMaster_NC_Intake_61536
				where statementSMadeToPolice_1 is null
	--------------------------------------------------------------------- pi intake

				select distinct
			  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				, [accidenttype]
				, [descriptionofaccident]
				, [policereport]
				, [injuriessustainedpaincomplaints]
				, [witnessesstatementsgiven]
				, [locationofaccident]
				, [referralsource]
				, [hospitalContactExternalID]
				, [whatWereTheClientSTreatme]
				, [report]
				, [clientSVehicleType]
				, [defendantSVehicleType]
				, [jurisdiction]
			--	, [pleaseAttachRetainerDocExternalID]
				, [timeOfAccident]
				, [otherReferralSource]
			--	, [caseReferredToContactExternalID]
				, [otherAccidentType]
				, [jurisdictionNeedles]
		--		, [dateOfLoss]
				, [otherJurisdiction]
				, amountOfDamage
				, sum(wereThereLostWages)
				, sum(notes) notes
				, StatewhereAccidentOccured
				--into #test
			from
		(SELECT DISTINCT
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, null [accidenttype] -- c.matterid [accidenttype]
			, cast(c.synopsis as varchar(max)) [descriptionofaccident]--AccidentDetails.[data] [descriptionofaccident]
			, CASE 
				WHEN cast(policereport.[data] as varchar(max)) is not null
				THEN 1
				ELSE 0
			  END AS [policereport]
			, cast(injuriessus.[data] as varchar(max))  [injuriessustainedpaincomplaints]
			, cast(witnessstatement.[data] as varchar(max)) [witnessesstatementsgiven]
			, cast(locationofaccident.[data] as varchar(max)) [locationofaccident]
			, null [referralsource] -- c.ReferredBy_namesid [referralsource]   -- -- check alignment
			, null [hospitalContactExternalID]--, hospital.[data]  [hospitalContactExternalID]. convert to text or match it to an id.
			, cast(Clienttreatment.[data] as varchar(max))  [whatWereTheClientSTreatme] 
			, cast(report.[data] as varchar(max)) [report]
			, cast(clientveh.[data] as varchar(max)) [clientSVehicleType]
			, cast(defveh.[data] as varchar(max)) [defendantSVehicleType]
			, a.ALIGNMENT [jurisdiction]
		--	, (SELECT top 1 a.ALIGNMENT FROM  user_tab6_data utd2 join [PT1_CLIENT_ALIGN].[__FV_PI_Intake_Jurisdiction_Alignment] a
			--	ON utd.data = a.LEGACY WHERE utd2.casesid = utd.casesid AND  utd.[usercasefieldid] = 'EF17030D-EB83-4525-BB59-A8FD00B1C246')  [jurisdiction] -- (SELECT top 1 utd2.[data] FROM user_tab6_data utd2 WHERE utd2.casesid = utd.casesid AND  utd.[usercasefieldid] = 'EF17030D-EB83-4525-BB59-A8FD00B1C246') [jurisdiction]
			--, NULL [pleaseAttachRetainerDocExternalID]
			, cast(timeOfAccident.[data] as varchar(max)) [timeOfAccident]
			, c.ReferredBy_namesid [otherReferralSource]
		--	, NULL [caseReferredToContactExternalID]
		
			, m.description [otherAccidentType]
			, null [jurisdictionNeedles]
		--	, c.date_of_incident [dateOfLoss]
			, A.[ALIGNMENT] [otherJurisdiction]
			, CASE
				WHEN VC.CODE = 'PROP DAM'
				THEN V.total_value
			  END AS amountOfDamage
			, CASE
				WHEN VC.CODE = 'LOSTWAGE'
				THEN 1
			  END AS wereThereLostWages
			, CASE 
				WHEN VC.code = 'LOSTWAGE'
				THEN V.total_value
			  END AS notes
			, CASE 
				WHEN c.alt_case_num_2 = 'MD'
				THEN 'Maryland - MD'
				WHEN c.alt_case_num_2 = 'DE'
				THEN 'Delaware - DE'
				WHEN c.alt_case_num_2 = 'DE- new castle'
				THEN 'Delaware - DE'
				WHEN c.alt_case_num_2 = 'DC'
				THEN 'Washington DC'
				WHEN c.alt_case_num_2 = 'VA'
				THEN 'Virginia - VA'
				WHEN c.alt_case_num_2 = ''
				THEN NULL
			--	ELSE c.alt_case_num_2 
			  END AS StatewhereAccidentOccured
			  --, c.alt_case_num_2
  
		FROM [dbo].[__FV_ClientCaseMap] ccm 
		 	JOIN dbo.[cases] C
				ON CCM.CaseID = C.[id] -- 723
				and ccm.Filevine_ProjectTemplate = 'Personal Injury (Master)'
				and ccm.ProjectExternalID IN  ('P_4DFA225B-1F7A-4510-8993-A96600AA3853_C_AFE8969F-5AC0-4800-91', 'P_F71B4AF6-3AC2-4D5E-851C-A9EC0113844A_C_43E7C32B-B967-471D-A3', 'P_CDCAB221-D302-4737-8EC2-AAEA00E9726A_C_60F9C938-29A4-46FF-BC', 'P_855FFDC9-89DE-4246-A9DA-AA7000FDAC8A_C_50F1EFB1-5EEB-488B-B2', 'P_AD4B2A7F-ABCA-49B8-9897-AB58015568B6_C_474E14C8-BAC7-409C-89')
			LEFT JOIN [dbo].matter m on c.matterid = m.id
			LEFT JOIN [dbo].[value] v
				on ccm.caseid = v.casesid --1154
				--and v.valuecodeid = 'CC85257D-28E2-40A5-9B65-A8FD00B1A0EF'
						--where ccm.filevine_projecttemplate = 'Personal Injury (Master)'
			LEFT JOIN DBO.VALUE_CODE vc
				ON v.valuecodeid = vc.id and vc.code in ('PROP DAM','LOSTWAGE')
			
			--	AND VC.CODE LIKE '%prop%'
			--LEFT JOIN user_tab6_data utd
			--	ON utd.casesid = C.id  -- 5506
	--						WHERE ProjectExternalID = 'P_010F6F2E-88E9-4662-8B58-A8FD00B1A29E_C_28E11D09-C195-4E47-AD'
			LEFT JOIN [user_tab6_data] AccidentDetails
				ON AccidentDetails.casesid = CCM.CaseID
				AND  AccidentDetails.usercasefieldid = '98828FB4-929E-4637-A7ED-A90B00C2F5FF' --1153
		
			LEFT JOIN [user_tab6_data] policereport
				ON policereport.casesid = CCM.CaseID
				AND policereport.[usercasefieldid] = '75D86BF8-2C96-4766-8238-A8FD00B1C248' --1153
		
		LEFT JOIN [user_tab6_data] injuriessus
				ON injuriessus.casesid = CCM.CaseID
				AND injuriessus.[usercasefieldid] = '27713059-FEB4-4119-B8A9-A8FD00B1C245' --1153
	
			LEFT JOIN [user_tab6_data] witnessstatement
				ON witnessstatement.casesid = CCM.CaseID
				AND witnessstatement.[usercasefieldid] = 'F6C918C6-39FE-4ADE-A16F-A8FD00B1C244' --1153
				
			LEFT JOIN [user_tab6_data] locationofaccident
				ON locationofaccident.casesid = CCM.CaseID
				AND locationofaccident.[usercasefieldid] = '7A3154EF-6E97-44F4-AD95-A8FD00B1C246'
			--LEFT JOIN [user_tab6_data] hospital
			--	ON hospital.casesid = CCM.CaseID
			--	AND hospital.[usercasefieldid] = 'DD9B05D5-CB52-4F88-AEC1-A90B011EB6E0'
			LEFT JOIN [user_tab6_data] Clienttreatment
				ON Clienttreatment.casesid = CCM.CaseID
				AND Clienttreatment.[usercasefieldid] = '58615E9D-2071-435C-9BC9-A90B011EFFF8'
			LEFT JOIN [user_tab6_data] report
				ON report.casesid = CCM.CaseID
				AND report.[usercasefieldid] = 'CB1541FB-0441-44C3-B6D4-A8FD00B1C248'
			LEFT JOIN [user_tab6_data] clientveh
				ON clientveh.casesid = CCM.CaseID
				AND clientveh.[usercasefieldid] = '234520E0-E996-41D1-AB4F-A8FD00B1C248'
			LEFT JOIN [user_tab6_data] defveh
				ON defveh.casesid = CCM.CaseID
				AND defveh.[usercasefieldid] = 'C32DF805-B7EF-455D-9A87-A8FD00B1C248'
			LEFT JOIN [user_tab6_data] timeOfAccident
				ON timeOfAccident.casesid = CCM.CaseID
				AND timeOfAccident.[usercasefieldid] = '786FC7A4-7E34-4DAC-B83E-A8FD00B1C248'
			LEFT JOIN (SELECT top 1 
						a.alignment, C.ID
						FROM __FV_ClientCaseMap ccm
		 					JOIN dbo.[cases] C
								ON CCM.CaseID = C.[id] -- 723
							JOIN user_tab6_data utd
								ON utd.casesid = C.id  -- 5506
							JOIN [8298_Robinson_R1].[PT1_CLIENT_ALIGN].[__FV_PI_Intake_Jurisdiction_Alignment] a
								ON cast(utd.[data] as varchar) = a.LEGACY		
								) a
								ON C.ID = A.id
		) a
		group by
			  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [ProjectExternalID]
				, [accidenttype]
				, [descriptionofaccident]
				, [policereport]
				, [injuriessustainedpaincomplaints]
				, [witnessesstatementsgiven]
				, [locationofaccident]
				, [referralsource]
				, [hospitalContactExternalID]
				, [whatWereTheClientSTreatme]
				, [report]
				, [clientSVehicleType]
				, [defendantSVehicleType]
				, [jurisdiction]
			--	, [pleaseAttachRetainerDocExternalID]
				, [timeOfAccident]
				, [otherReferralSource]
			--	, [caseReferredToContactExternalID]
				, [otherAccidentType]
				, [jurisdictionNeedles]
		--		, [dateOfLoss]
				, [otherJurisdiction]
				, amountOfDamage
				--, wereThereLostWages				
				, StatewhereAccidentOccured
				
								
