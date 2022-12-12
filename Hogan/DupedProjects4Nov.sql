

SELECT distinct count(1), projectexternalid
				FROM __FV_ClientCaseMap ccm
				JOIN 	[dbo].[Firm Central matters_20221026] m
					ON ccm.caseid = m.matternumber
				join [Firm Central Contacts_20221103]  c 
					ON (iif(c.preferredname is null,coalesce(nullif(concat(c.lastname,', ',c.firstname),', '),c.businessname),coalesce(nullif(concat(c.lastname,', ',c.firstname,' "',c.preferredname,'"'),', '),c.businessname)) = m.ClientName
					OR concat(c.lastname, ', ', c.Firstname) = m.ClientName)
				left join [PT1].[ContactsCustom__ContactInfo] ci
					on c.employer = ci.firstname 
				LEFT JOIN [PT1_CLIENT_ALIGN].[__FV_Hogan_PI_Intake_AccidentTypeAlign] a
					ON TRIM(m.casetype) = TRIM(a.casetype_firm_central)
				WHERE ccm.filevine_projectTemplate = 'Personal Injury (Master)'
				AND projectexternalid != '1145_1033'
				AND projectexternalid != '1145_0603'
				AND ProjectExternalID != '0601_1033'
				AND projectexternalid != '0601_0603'
				AND projectexternalid != '0765_0751' -- new dupe
				AND projectexternalid  != '0765_757' -- new dupe
				AND projectexternalid  != '0767_0751'-- new dupe
				AND projectexternalid NOT IN
				('0767_757','0769_0751','0769_757','0771_0751','0771_757','0773_0751','0773_757','0775_0751','0775_757','0777_0751','0777_757','0779_0751','0779_757','0781_0751','0781_757','0787_07','0787_757','0887_0751','0887_757','0923_0751','0923_757','0935_0751','0935_757','1005_929','1011_0751','1011_757','1035_0751','1035_757','1101_0751','1101_757','1103_0751','1103','1107_0751','1107_757','1125_0751','1125_757','1197_0751','1197_757','1233_0751','1233_757','0787_0751','1103_757')
				group by projectexternalid
				HAVING count(1) >1 -- projectexternalid