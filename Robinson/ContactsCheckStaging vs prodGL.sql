	SELECT *
FROM 		filevinestaging2import.._RobinsonTest2_Contacts___7888
WHERE contactexternalid in
							(
							SELECT contactexternalid
							FROM __FV_clientcasemap
							) 

							-- not in 13125
							-- in 1006