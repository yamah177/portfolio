



-- new notes try


INSERT INTO
			[PT1].[Notes]
			(
				  [__ImportStatus]
				, [__ImportStatusDate]
				, [__ErrorMessage]
				, [__WorkerID]
				, [__NoteID]
				, [NoteExternalID]
				, [ProjectExternalID]
				, [Author]
				, [Body]
				, [CreateDate]
				, [Assignee]
				, [TargetDate]
				, [CompletedDate]
			)
		SELECT DISTINCT 
			  40 [__ImportStatus]
			, GETDATE() [__ImportStatusDate]
			, NULL [__ErrorMessage]
			, NULL [__WorkerID]
			, NULL [__NoteID]
			, concat('E_',[Seq__No],'_',ccm.projectexternalid) 
			, concat(a.ProjectExternalID, a.CreateDate)   [NoteExternalID]
			, ccm.ProjectExternalID [ProjectExternalID]
			, null [Author] -- ??? needed?
			, e.subject1 [Body] -- concat_ws
			, e.2014-08-26 [CreateDate]
			, NULL [Assignee]
			, NULL [TargetDate]
			, NULL [CompletedDate]
	-- select *
		FROM #emails e

DROP TABLE IF EXISTS emails;

with maxMsg as (
select Client__ID, Subject,  Max(Seq__No) Seq_No 
from CMJRNL 
--where Client__ID = 990
WHERE nullif(Subject, '') is not null
group by CLient__ID, Subject
) 
, latestMessage as (
select c.Client__ID, c.Subject, TRIM([Filevine_Meta_Test].[dbo].[udfReplaceAscii](filevine_meta.dbo.udfStripHTML(c.Email__Body))) [Body]
from CMJRNL c
right join maxMsg m on m.Client__ID = c.Client__ID and m.Subject = c.Subject and c.Seq__No = m.Seq_No
)
select 
cast(LEFT(s3.[FileName],[filevine_meta].[dbo].[udf_findNthOccurance]('_',[FileName],01)-1) as date) [Date]
,RIGHT(s3.[FileName], LEN(s3.[FileName]) - [filevine_meta].[dbo].[udf_findNthOccurance]('_',s3.[FileName],1)) [subject1]
,REPLACE(lm.Body,'  ',' ') Body1
, lm.Body body2
, *
into emails
from S3DocScan s3 
left join latestMessage lm 
on lm.subject = RIGHT(s3.[FileName], LEN(s3.[FileName]) - [filevine_meta].[dbo].[udf_findNthOccurance]('_',s3.[FileName],1))
	and TRIM(lm.Client__ID) = REPLACE(s3.FolderPath,'/','')
where fileext = 'msg' 
--and FolderPath = '990/'
and Filename NOT LIKE '%RE_%'
and Filename NOT LIKE '%FW_%'
and Filename NOT LIKE '%Fwd_%'

