


WITH cte AS (
SELECT distinct top 1000 replace(S.folderpath, '%' + p.cleanhashtag+ '%' + '/', '') as folderpath
		, CASE 
			WHEN p.cleanhashtag like 'BG%' 
			THEN 		REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.cleanhashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'') -- going to give everything to the right of the cleanhashtag. nullif, if this field doesn't contain this, 
			ELSE 		REPLACE(SUBSTRING(S.folderpath, COALESCE(NULLIF(CHARINDEX(p.nobghashtag,S.folderpath)-1,1),1),8000),p.cleanhashtag,'')
		end	 jcobb_Path
		, S.folderpath original
		, s.filecomplete
		--,p.[name]
		, p.cleanhashtag
		, p.nobghashtag
		from tmp_jcobb s
		INNER JOIN tmp_jcobb_1 p
			ON s.folderpath like '%' + p.cleanHashtag +'%' -- 74,817
			OR s.folderpath like '%' + p.nobghashtag -- 75,365
			OR s.filecomplete like '%' + p.cleanHashtag + '%' -- 77051
			--OR s.filecomplete like '%' + p.nobghashtag -- 76,526
			where p.cleanhashtag <> '' -- 76821
			)
			SELECT
			original
			, jcobb_Path
			, CASE
				WHEN jcobb_Path NOT LIKE '%/%'
				THEN NULL
				ELSE SUBSTRING(jcobb_Path,CHARINDEX('/',jcobb_Path),LEN(jcobb_Path)) 
			  END AS CleanPath
			FROM cte



