USE [8298_Robinson_r1]
GO
/****** Object:  StoredProcedure [needles].[usp_insert_reference_ClientCaseMap]    Script Date: 6/16/2021 6:56:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE
	[needles].[usp_insert_reference_ClientCaseMap]
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN 	--	SELECT  			'[needles].[usp_insert_reference_ClientCaseMap] has been created in [8298_Robinson_r1] database.  Please review and modifiy the procedure.'
				
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: ALL */
		/*================================================================================================*/
		
	-- criminal/DUI cases
			INSERT INTO
		--SELECT * FROM
			[dbo].[__FV_ClientCaseMap]
			(
				  [ProjectExternalID]
				, [ContactExternalID]
				, [CaseID]
				, [NameID]
				, [Filevine_ProjectTemplate]
				, [Active]
				, [Archived]
			)
		SELECT DISTINCT
			  LEFT(CONCAT('P_',cas.[id],'_C_',party.[namesid]),62) [ProjectExternalID]
			, CONCAT('C_',party.[namesid]) [ContactExternalID]
			, cas.[id] [CaseID]
			, party.[namesid] [NameID]
			, CASE WHEN cas.[matterid] = 'CC35934C-9D06-4DA0-BFC7-A8FD00B1A14E' 
						THEN 'Criminal (Master)'
					ELSE 'Personal Injury (Master)'
				END [Filevine_ProjectTemplate]
			, CASE WHEN NULLIF([close_date],'') IS NOT NULL
						THEN '0'
					WHEN NULLIF([close_date],'') IS NULL
						THEN '1'
				END [Active]
			, CASE WHEN NULLIF([close_date],'') IS NOT NULL
						THEN '1'
					WHEN NULLIF([close_date],'') IS NULL
						THEN '0'
				END [Archived]
			--	, m.header    -- investigating DUI for criminal template
				--, party.[our_client]
-- SELECT top 1000 p.*
		FROM dbo.[cases] cas
			INNER JOIN dbo.[party] party
				ON cas.[id] = party.[casesid]
			 INNER JOIN matter m       -- investigating DUI for criminal template
				 on cas.matterid = m.id -- 1896, way more than 723   -- investigating DUI for criminal template
		WHERE party.[our_client] = '1' -- DUI are not falling out here
	--	AND cas.[classid] <> 'F35E68D5-0C04-43D5-BB67-ACE0016DE59F' -- 723 - this is where the dui is falling out
		and m.header = 'DUI' -- only get 2, but they come through when line 63 is commented out
		--and CASE WHEN NULLIF([close_date],'') IS NOT NULL
		--				THEN '0'
		--			WHEN NULLIF([close_date],'') IS NULL
		--				THEN '1'
		--		END = 1

	-- everything else

		INSERT INTO
		--SELECT * FROM
			[dbo].[__FV_ClientCaseMap]
			(
				  [ProjectExternalID]
				, [ContactExternalID]
				, [CaseID]
				, [NameID]
				, [Filevine_ProjectTemplate]
				, [Active]
				, [Archived]
			)
		SELECT DISTINCT
			  LEFT(CONCAT('P_',cas.[id],'_C_',party.[namesid]),62) [ProjectExternalID]
			, CONCAT('C_',party.[namesid]) [ContactExternalID]
			, cas.[id] [CaseID]
			, party.[namesid] [NameID]
			, CASE WHEN cas.[matterid] = 'CC35934C-9D06-4DA0-BFC7-A8FD00B1A14E' 
						THEN 'Criminal (Master)'
					ELSE 'Personal Injury (Master)'
				END [Filevine_ProjectTemplate]
			, CASE WHEN NULLIF([close_date],'') IS NOT NULL
						THEN '0'
					WHEN NULLIF([close_date],'') IS NULL
						THEN '1'
				END [Active]
			, CASE WHEN NULLIF([close_date],'') IS NOT NULL
						THEN '1'
					WHEN NULLIF([close_date],'') IS NULL
						THEN '0'
				END [Archived]
			--	, m.header    -- investigating DUI for criminal template
			--	, party.[our_client]
-- SELECT top 1000 p.*
		FROM dbo.[cases] cas
			INNER JOIN dbo.[party] party
				ON cas.[id] = party.[casesid]
			 --INNER JOIN matter m       -- investigating DUI for criminal template
				-- on cas.matterid = m.id -- 1896, way more than 723   -- investigating DUI for criminal template
		WHERE party.[our_client] = '1' -- DUI are not falling out here
		AND cas.[classid] <> 'F35E68D5-0C04-43D5-BB67-ACE0016DE59F' -- 723 - this is where the dui is falling out
		and LEFT(CONCAT('P_',cas.[id],'_C_',party.[namesid]),62) NOT IN (
																	SELECT projectexternalid 
																	from [dbo].[__FV_ClientCaseMap]
																	)
		--and m.header = 'DUI' -- only get 2, but they come through when line 63 is commented out
		--and CASE WHEN NULLIF([close_date],'') IS NOT NULL
		--				THEN '0'
		--			WHEN NULLIF([close_date],'') IS NULL
		--				THEN '1'
		--		END = 1
		
		
		
		--and LEFT(CONCAT('P_',cas.[id],'_C_',party.[namesid]),62) like '%anne%Eckert%'


	END
														