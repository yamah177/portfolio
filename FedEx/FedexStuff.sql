/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Key]
      ,[ProjectID]
      ,[CustomSectionID]
      ,[CollectionItemGuid]
      ,[CustomFieldID]
      ,[PersonID]
  FROM [7119_FedEx_II_r2].[dbo].[CustomDataPerson]
  WHERE customsectionid IN (258764,254797, 355239) -- customsectionid = 254782
  AND   [ProjectID] = 6715702


  fieldid 2459085