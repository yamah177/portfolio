-- T1 Rosette Validation

-- docs _497_Rosette_T1_Documents___58430

SELECt distinct destinationfolderpath
FROM filevinestaging2import.._497_Rosette_T1_Documents___58430
WHERE projectexternalid = 'naoL beW naciremA 1.2501_American Web Loan'
AND destinationfolderpath like '2015/'


SELECT count(1), __importstatus
FROM filevinestaging2import.._497_Rosette_T1_Documents___58430
GROUP BY __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._497_Rosette_T1_Documents___58430
GROUP BY __errormessage

-- projects _497_Rosette_T1_Projects___58428

SELECT count(1), __importstatus
FROM filevinestaging2import.._497_Rosette_T1_Projects___58428
GROUP BY __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._497_Rosette_T1_Projects___58428
GROUP BY __errormessage

SELECT *
FROM filevinestaging2import.._497_Rosette_T1_Projects___58428
WHERE projectname like '%gun%lake%'

SELECT *
FROM filevinestaging2import.._497_Rosette_T1_Projects___58428
WHERE projectname like '%american%web%'


-- contacts
SELECT count(1), __importstatus
FROM filevinestaging2import.._497_Rosette_T1_ContactsCustom__ContactInfo__58432
GROUP BY __importstatus

SELECT count(1), __errormessage
FROM filevinestaging2import.._497_Rosette_T1_ContactsCustom__ContactInfo__58432
GROUP BY __errormessage

