Declare @time as int
SELECT @time=DATEDIFF(SECOND,aj.start_execution_date,GetDate()) 
--SELECT @time=DATEDIFF(MINUTE,aj.start_execution_date,GetDate()) 
FROM msdb..sysjobactivity aj
JOIN msdb..sysjobs sj on sj.job_id = aj.job_id
WHERE aj.stop_execution_date IS NULL -- job hasn't stopped running
AND aj.start_execution_date IS NOT NULL -- job is currently running
AND sj.name = 'DatabaseBackup - USER_DATABASES - FULL'
and not exists( -- make sure this is the most recent run
    select 1
    from msdb..sysjobactivity new
    where new.job_id = aj.job_id
    and new.start_execution_date > aj.start_execution_date
)
print @time
If @time>30
begin

		Execute msdb.dbo.sp_send_dbmail
				 @profile_name = 'Test'
				,@recipients = 'rajasekharreddyb.dba@gmail.com,rajasekharreddyb.SQLdba@gmail.com'
				,@subject = 'Job Running Status'
				,@importance = 'High'
				,@query_result_header = 1
				,@query_result_separator='	' 
				,@query_result_no_padding=1
				,@query_result_width=32767 
				,@exclude_query_output	= 0
				--,@execute_query_database = 'master'
				,@body_format	= 'HTML'
				,@body = 'Hi Team,<BR>

				There is job running more than an 30 minuts in Prod.<BR>

				<BR>Note: This is automated mail, If you have any concerns, Please reach out to DBA Team<BR>

				<BR>Thanks'
		

end



Declare @flag as int= 0

select @flag=run_status from msdb.dbo.sysjobhistory jh join msdb.dbo.sysjobs j on j.job_id=jh.job_id 
 where instance_id=(select MAX(Instance_id) from msdb.dbo.sysjobhistory jh1 where  jh.job_id=jh1.job_id and jh.step_id=jh1.step_id) 
 and step_id=3 and name='ProdNaRestore'

 print @flag
If @flag=0
begin

		Execute msdb.dbo.sp_send_dbmail
				 @profile_name = 'Email Notifications'
				 ,@recipients = 'rajasekharreddyb.dba@gmail.com,rajasekharreddyb.SQLdba@gmail.com'
				--,@recipients = 'rajasekharreddyb.dba@gmail.com'
				,@subject = 'Job Running Status'
				,@importance = 'High'
				,@query_result_header = 1
				,@query_result_separator='	' 
				,@query_result_no_padding=1
				,@query_result_width=32767 
				,@exclude_query_output	= 0
				--,@execute_query_database = 'master'
				,@body_format	= 'HTML'
				,@body = 'Hi Team,<BR>

				Prod  Dump Restored Successfully in DEV.<BR>

				<BR>Note: This is automated mail, If you have any concerns, Please reach out to DBA Team<BR>

				<BR>Thanks//'
		

end