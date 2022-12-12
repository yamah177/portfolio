









SELECT *
FROM [dbo].[__FV_ProjectList]

Alter table [__FV_ProjectList]
alter column column1 PEID [nvarchar](50) NOT NULL

SELECt *
FROM  [__FV_Project_List]

DELETE FROM [__FV_Project_List]
WHERE PEID = 'PEID'
AND	  [Name] = 'Name'
AND	  [OrgName] = 'Org Name'
AND	  [Phase] = 'Phase'
AND	  [ProjectType] = 'Project Type'

INSERT INTO [__FV_Project_List]
SELECT *
FROM [__FV_ProjectList]

USE [5928_Hirji]
GO

/****** Object:  Table [dbo].[__FV_ProjectList]    Script Date: 3/10/2021 4:18:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[__FV_ProjectList](
	PEID [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[OrgName] [nvarchar](50) NOT NULL,
	[Phase] [nvarchar](50) NOT NULL,
	[ProjectType] [nvarchar](50) NOT NULL,
	[CleanName]  [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO




