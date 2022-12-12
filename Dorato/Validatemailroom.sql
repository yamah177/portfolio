
SELECT *
FROM filevinestaging2import.dbo._Dorato_T1_MailroomItems___54495

SELECt *
FROM filevinestaging2import.dbo._Dorato_T1_MailroomItems___54243
where __importstatus = 70

update filevinestaging2import.._Dorato_T2_MailroomItems___54073
set [to] = 'derek@doratoweems.com'
, __importstatus = 40
, __errormessage = null
WHERE [to] = 'derek@dorato&weems.com'
derek@dorato&weems.com

SELECt distinct __errormessage, __importstatus, count(*)
FROM filevinestaging2import.dbo._Dorato_T1_MailroomItems___54495
--where emailfile_s3objectkey is null
where __importstatus = 70
group by __errormessage, __importstatus

update filevinestaging2import.dbo._Dorato_T1_MailroomItems___54495
set __importstatus = 40
, __errormessage = null
where __importstatus = 70


