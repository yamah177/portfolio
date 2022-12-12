select count(1),__ImportStatus, __ErrorMessage from filevinestaging2import.dbo._Dorato_T1_MailroomItems___54495 where __ImportStatus = 70 
group by __ImportStatus, __ErrorMessage
order by 1 desc
