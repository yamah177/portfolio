

SELECT count(*), __ImportStatus
FROM 			filevinestaging2import.._BobbyGarciaTest2_Documents___22112
group by __ImportStatus

SELECT count(*), __errormessage
FROM 			filevinestaging2import.._BobbyGarciaTest2_Documents___22112
group by __errormessage
