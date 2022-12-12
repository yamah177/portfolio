 
 		
		drop table if exists #doc;

		SELECT *
		, replace(s.FolderPath, '/','') link
		INTO #doc
		FROM s3docscan s; -- 219251
		--	on ccm.CaseID = replace(s.FolderPath, '/','') --218,578 

		drop table if exists #doc2;
		
		select try_convert(date, left([filename], 8)) datefix
		, left([filename], 8) dateold
		, *
		INTO #doc2
		FROM #doc -- 219251
		--where link = '990'

		drop table if exists #doc3;

		select a.filename oldfilename
		, replace(a.filename, b.dateold + '_', '') newSubject
		, try_convert(date,b.datefix) datefix2
		--, format(try_convert(date,a.datefix),  'ddMMyy') datefix2
		, b.link
		, b.datefix
		into #doc3
		FROM #doc2 a
		join #doc2 b
			on a.sources3objectkey = b.sources3objectkey
		--	where b.link = '990'

		SELECt *
		FROM #doc3

		SELECT *
		FROM CMJRNL
		WHERE trim(client__id)
		NOT IN (

select distinct destinationfilename --count(1) -- concat('E_',cmj.[Seq__No],'_',ccm.projectexternalid))
		FROM __FV_ClientCaseMap ccm
		join #doc3 d
			on ccm.caseid = trim(d.link) -- 52,025
		join CMJRNL c
		on d.link = trim(c.client__id)
		and trim(d.newSubject) = replace(c.[subject], ':', '_')
		and  FORMAT(try_convert(date,c.[date]), 'ddMMyy')  = format(try_convert(date,d.datefix),  'ddMMyy') -- 193696
		where ccm.archived = 0
		)

		SELECT *		FROM __FV_ClientCaseMap ccm
		where ccm.archived = 1 -- 6433

