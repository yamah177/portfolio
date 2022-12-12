

Select *
FROM pt1.projects
where projectname like '%dolores%'

Select count(1), projectname
FROM pt1.projects
group by projectname
having count(1) > 1
order by 1 desc

SELECT *
FROM pt1.projects
WHERE projectname in (
'Conner, Tamorra & Clara v.',
'Martin Sanchez vs. Swisher County',
'Mata, Steve',
'Mendoza, Dolores',
'Mendoza, Dolores (2021)',
'Tovar, Rosalinda',
'Tovar, Rosalinda N600',
'Tovar, Rosalinda obo Armendariz Eudelia'
)



Conner, Tamorra & Clara v.
Martin Sanchez vs. Swisher County
Mata, Steve
Mendoza, Dolores
Mendoza, Dolores (2021)
Tovar, Rosalinda
Tovar, Rosalinda N600
Tovar, Rosalinda obo Armendariz Eudelia




I believe there are 227 of them roughly, and it happens sometimes when I import projects into staging2. and if any of them have an error (incorrect phase, username, etc), I have to clear the errors out, fix whatever was wrong and restart the import.

this historically has duped projects, but what's interesting about these is that both projects have data..... I've never seen that. usually one project will have case summary, activity, intake info, all the extra data, and the first time errored out project will be blank, basically a dummy project.

So I believe that is what happened but just weird because i see data in both when I only expect it in one.

Bottom line, I ran a report for the T1 org and just did the List of Projects, include archived flat to yes. 643 projects, I dont see 