declare @query nvarchar(max)
Declare @FileName nvarchar(max)='C:\PerfLogs\BLG\DataCollector01'
Declare @date nvarchar(20)
select @date=CONVERT(VARCHAR(10), GetDate()-1, 12)
set @FileName=@FileName+@date+'.blg'
--print @FileName
Execute msdb.dbo.sp_send_dbmail
	@profile_name = 'Email Notifications Account'
	,@from_address = 'Rajasekharreddyb.dba@gamail.com'
	,@recipients = 'Rajasekharreddyb.dba@gamail.com'
	,@subject = 'PROD server Performance Counters'
	,@body_format	= 'HTML'
	,@body = 'Hi All<BR><BR>Please find the Performance Counters Graph in the attached<BR><BR>Regards,<BR>SQLDBA '
	,@file_attachments = @FileName
	,@query_attachment_filename = @FileName

	