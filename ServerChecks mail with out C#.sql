--sp_helptext sysmail_configure_sp
----EXECUTE msdb.dbo.sysmail_configure_sp 'MaxFileSize', '10000000';
--File attachment or query results size exceeds allowable value of 1000000 bytes.




EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'Email Notifications',
@recipients = 'Rbreddy@xxx.com',
@subject = 'Memory Values',
@query = N'
print ''1. Drive sizes''
 exec xp_fixeddrives;

print ''2. DB sizes''

DECLARE @dbs TABLE
( DBname VARCHAR(100),
  Size FLOAT,
  Remarks VARCHAR(1000)
)
INSERT INTO @dbs EXEC sp_databases

DECLARE @FILES TABLE
(
	DatabaseName VARCHAR(100),
	LogicalName VARCHAR(100),
	PhysicalName VARCHAR(1000),
	SizeMB FLOAT
)

INSERT INTO @FILES SELECT DB_NAME(database_id) AS DatabaseName,
Name AS Logical_Name,
Physical_Name, (size*8) SizeMB
FROM sys.master_files
WHERE DB_NAME(database_id) IN (select DBName from @dbs where DBname not in (''master'',''model'',''msdb'')) 


SELECT f1.DatabaseName, round(SUM(f1.SizeMB)/1024/1024,2) AS ''Total (GB)'',(select round(sum(f2.SizeMB)/1024/1024,2) from @Files f2 where f1.DatabaseName = f2.DatabaseName and (f2.PhysicalName like ''%.mdf'' or f2.PhysicalName like ''%ndf'')) as ''Data (GB)'', (select round(sum(f3.SizeMB)/1024/1024,2) from @Files f3 where f1.DatabaseName =f3.DatabaseName and f3.PhysicalName like ''%.ldf'') as ''Log (GB)'' 
FROM @FILES f1 GROUP BY f1.DatabaseName;

print '' 3. JOB STATUS''

select distinct j.job_id as JobID, j.name as Jobname,CONVERT(DATETIME,RTRIM(jh.run_date)) +(jh.run_time * 9 + jh.run_time % 10000 * 6 + jh.run_time % 100 * 10) / 216e4 AS ''Last_run_date'', CONVERT(VARCHAR(10),CONVERT(DATETIME,RTRIM(19000101))+(jh.run_duration * 9 + jh.run_duration % 10000 * 6 + jh.run_duration % 100 * 10) / 216e4,108) AS ''Run_Time'', jh.run_status  as jobstatus from msdb.dbo.sysjobhistory jh join msdb.dbo.sysjobs j on j.job_id=jh.job_id join msdb.dbo.sysjobschedules js on j.job_id = js.job_id where instance_id=(select MAX(Instance_id) from msdb.dbo.sysjobhistory jh1 where  jh.job_id=jh1.job_id and jh.step_id=jh1.step_id) and jh.step_name=''(Job outcome)'' 
and j.enabled =1 Order by Last_run_date DESC

print ''4. SQL SERVER AGENT  ERROR  LOG DETAILS '' 
EXEC sp_readerrorlog 0, 2
print ''SQL ERROR LOG DETAILS''
EXEC sp_readerrorlog 0,1
-- 5.  JOBS DISABLED /SCHEDULE DISABLED
select ''Job(s) Disabled '' as Type,convert(varchar(200),name) as Job_Name from msdb.dbo.sysjobs where enabled=0 UNION ALL select Distinct ''Job(s)-Schedule Disabled '' as Type, convert(varchar(200),(J.name +'' - ''+S.name)) as Job_Name from   msdb.dbo.sysjobschedules js  JOIN msdb.dbo.sysjobs j on j.job_id=js.job_id   JOIN msdb.dbo.sysschedules S on js.schedule_id=S.schedule_id  where S.enabled=0  UNION ALL select ''Job(s) with no schedule  '' as Type,convert(varchar(200),J.name) as Job_Name from   msdb.dbo.sysjobs J LEFT JOIN msdb.dbo.sysjobschedules js 
  ON J.job_id=js.job_id where js.Schedule_id is null
  --6. BackUPTypes & Time
SELECT * From (select bs.database_name As DBName, MAX(bs.backup_finish_date)as BackUpDate,bs.type as Type from msdb..backupset bs JOIN sys.databases sdb on 
bs.database_name = sdb.name and bs.type in (''D'',''L'') GROUP BY bs.database_name,bs.type
)DB
PIVOT(MAX(BackUpDate) FOR Type IN([D],[L]))As pvt

',
@attach_query_result_as_file = 1,
@query_attachment_filename = 'ConfigureValues.txt'