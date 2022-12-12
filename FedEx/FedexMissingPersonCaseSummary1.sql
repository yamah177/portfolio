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

  ID	Name
254781	Activity
254782	Case Summary -- 
254783	Calendar
254784	Docs
254785	Deadlines
254786	Team
254787	Contacts
254788	Depos
254789	Litigation Chain
254790	Related
254791	Experts
254792	Opposing Counsel
254793	Negotiations
254795	Case Budget
254796	Litigation Taskflows
254797	Case Analysis -- missing. 
258749	Activity
258750	Case Summary
258751	Calendar
258752	Documents
258753	Deadlines
258754	Team
258755	Contacts
258756	Depos
258757	Litigation Chain
258758	Related
258759	Experts
258760	Negotiations
258763	Litigation Taskflows
258764	Case Analysis
258765	Case Grade
258796	INSTRUCTIONS
258801	Potential Exposure
258806	Parties
258809	Key Events/Dates
258816	Case Budget/Billings
258833	Conflict Check
270379	Opt-Ins
355226	Activity
355227	Case Summary
355228	Calendar
355229	Documents
355230	Deadlines
355231	Team
355232	Contacts
355233	Depos
355234	Litigation Chain
355235	Related
355236	Experts
355237	Negotiations
355239	Case Analysis
355240	INSTRUCTIONS
355241	Potential Exposure
355242	Parties
355243	Key Events/Dates
355353	Info Sheet