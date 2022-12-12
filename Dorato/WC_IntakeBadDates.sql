
SELECT distinct
		CASE
				WHEN isdate(ci.[pmMMIDate]) = 0
				and nullif(ci.[pmMMIDate], '') is not null
				THEN ci.[pmMMIDate]
				ELSE NULL
			  END
			  FROM [CASEINFO] ci -- 159 bad records


		select distinct
			 CASE
				WHEN ISDATE(i.[pmSeparationDate]) = 0
				THEN i.pmSeparationDate
				ELSE NULL
			  END AS [separationDate] -- legacy field?
			  from intake i -- 766

select distinct 
			 CASE
				WHEN ISDATE(ci.[pmReleasedToWorkDT] ) = 0
				THEN ci.[pmReleasedToWorkDT] 
				ELSE NULL
			  END AS [dateReleasedReturnToWork] -- legacy field
			  from caseinfo ci -- 190
			
	select distinct 		
			 CASE
				WHEN ISDATE(ci.[pmReturnToWrkDate] ) = 0
				THEN ci.[pmReturnToWrkDate] 
				ELSE NULL
			  END
			  from caseinfo ci -- 167 bad records


		select distinct 
			  CASE
				WHEN ISDATE(i.pmhiredate) = 0
				THEN i.pmhiredate
				ELSE NULL
			  END AS [startDate]  --  need a legacy field for non date types.
			  from [INTAKE] i -- 806 bad records