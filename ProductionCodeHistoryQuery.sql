use [filevine_meta]
go
SELECT [databasename]
      ,[schemaname]
      ,[objectname]
      ,[commandtext]
  FROM [dbo].[Production_Code_History]
  where [eventtype] like '%alter%'
  --and schemaname like  '%client%'
  and objectname like '%mailroom%'
  and databasename not like '%sandbox%'
  --and [schemaname] like '%practicemaster%'
order by databasename desc