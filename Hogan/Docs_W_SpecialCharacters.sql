	SELECT-- SUBSTRING(s.FolderPath,0,CHARINDEX('/',s.FolderPath)+1) link
		--,
		s.*
		--INTO #docscan3
		FROM s3docscan  s
		WHERE-- filename  like '~%'
		--or 
		filename like '%#%'
		or filename like '%&%'
		or filename like '%*%'
		or filename like '%{%'
		or filename like '%}%'
		or filename like '%\%'
		or filename like '%:%'
		or filename like '%<%'
		or filename like '%>%'
		or filename like '%?%'
		or filename like '%/%'
		or filename like '%+%'
		or filename like '%|%'
		or filename like '%"%'
		--OR [filename] like '%.%'
		and filename <> ''
		AND filename <> 'debug'
		and fileext not in ('tmp', 'exe', '11]', 'dll', 'BIN', 'js', '!!!','!!!!', 'WE$$', 'WAT', '01', '02', '03', 'ini', 'CRS', 'LIB')
		and filecomplete NOT IN  ('Thumbs.db' , 'desktop.ini') --343,519