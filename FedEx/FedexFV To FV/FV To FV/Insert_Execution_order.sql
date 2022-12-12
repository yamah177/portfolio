/****** Script for SelectTopNRows command from SSMS  ******/
/****** Script for SelectTopNRows command from SSMS  ******/
use 7119_FedEx_II_r1
go
SELECT TOP (1000) 
[LegacyExOrdID]
      ,[LegacyDBID]
      ,[LegacySPID]
      ,[OrgID]
      ,[FvProdPrefix]
      ,[ExecutionOrder]
--      ,[Active]
      ,[CreatedDate]
  --    ,[ModifiedDate]
  , a.*
	FROM [PT1].[vw_LegacySP_FullMigration_ExecOrder] a

  insert into [PT1].[LegacySPExecutionOrder]
  ([LegacyDBID]
      ,[LegacySPID]
      ,[OrgID]
      ,[FvProdPrefix]
      ,[ExecutionOrder]
      ,[Active]
      ,[CreatedDate]
    --  ,[ModifiedDate]
	)
	  values
	  (12,
	  20801	  
	  ,7119
	  ,'_FedexB_Test1_'
	  ,920
	  ,1
	  ,getdate()
	--  ,NULL
	)

	  update [PT1].[LegacySPExecutionOrder]

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

