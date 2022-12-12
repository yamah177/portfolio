/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [LegacyDBID]
      ,[LegacyDatabaseType]
      ,[LegacySPID]
      ,[LegacyExOrdID]
      ,[LegacySPName]
      ,[ExecutionOrder]
      ,[OrgID]
      ,[Orgname]
      ,[FvProdPrefix]
      ,[ActiveProcedure]
      ,[ActiveMapping]
      ,[CreatedDate]
  FROM [PT1].[vw_LegacySP_FullMigration_ExecOrder] order by executionorder

200		usp_insert_reference_Usernames				
400		usp_insert_reference_ClientCaseMap			
500		usp_insert_staging_Contacts					
600		usp_insert_staging_Projects					
700		usp_insert_staging_CalendarEvents			
700		usp_insert_staging_Deadlines				
700		usp_insert_staging_Notes					
700		usp_insert_staging_ProjectContacts			
700		usp_insert_staging_ProjectPermissions		
800		usp_insert_reference_Documents				
900		usp_insert_staging_Documents

  update [PT1].[vw_LegacySP_FullMigration_ExecOrder] set ExecutionOrder = case LegacySPName 
  when 'usp_insert_reference_Usernames'			then 200
  when 'usp_insert_reference_ClientCaseMap'		then 400
  when 'usp_insert_staging_Contacts'			then 500
  when 'usp_insert_staging_Projects'			then 600
  when 'usp_insert_staging_CalendarEvents'		then 700
  when 'usp_insert_staging_Deadlines'			then 700
  when 'usp_insert_staging_Notes'				then 700
  when 'usp_insert_staging_ProjectContacts'		then 700
  when 'usp_insert_staging_ProjectPermissions'	then 700
  when 'usp_insert_reference_Documents'			then 800
  when 'usp_insert_staging_Documents'			then 900
  end
  from [PT1].[vw_LegacySP_FullMigration_ExecOrder]
  where LegacySPName in(
  'usp_insert_reference_Usernames'			,
  'usp_insert_reference_ClientCaseMap'		,
  'usp_insert_staging_Contacts'				,
  'usp_insert_staging_Projects'				,
  'usp_insert_staging_CalendarEvents'		,
  'usp_insert_staging_Deadlines'			,
  'usp_insert_staging_Notes'				,
  'usp_insert_staging_ProjectContacts'		,
  'usp_insert_staging_ProjectPermissions'	,
  'usp_insert_reference_Documents'			,
  'usp_insert_staging_Documents'			
  )

  select 