SELECT TOP (1000) [Key]
      ,[ProjectID]
      ,[CustomSectionID]
      ,[CollectionItemGuid]
      ,[CustomFieldID]
      ,[PersonID]
  FROM [7119_FedEx_II_r3].[dbo].[CustomDataPerson]
  WHERE customsectionid = 254782


  SELECT TOP (1000) [ID]
     -- ,[CustomProjectTypeID]
      --,[CustomSectionType]
      ,[Name]
      --,[Position]       --,[Icon]      --,[IsCollection]      --,[InternalName]      --,[Notes]      --,[MainLeftFieldID]      --,[MainRightFieldID]      --,[TotalMainRight]      --,[DefaultSortFieldID]      --,[DefaultSortIsAsc]      --,SectionSelector]      --,[IsLockedForNonProjectAdmin]      --,[DefaultVisibility]
  FROM [7119_FedEx_II_r3].[dbo].[CustomSection]