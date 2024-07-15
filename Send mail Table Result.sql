--3 MB
--EXECUTE msdb.dbo.sysmail_configure_sp 'MaxFileSize', '5242880' 

--select 1024*1000*1024
--sys.dm_server_services

--Msg 22050, Level 16, State 1, Line 0
--Failed to initialize sqlcmd library with error number -2147467259.
--Need to give permissin to aql agent serice account in db level
use [msdb]
go
ALTER ROLE [db_owner] ADD MEMBER [COMPUTERNAME\SQLAgentAccountName]
go

set nocount on;
Declare @query nvarchar(max)
Declare @FileName nvarchar(max);
set @FileName='Product_'+convert(varchar(500),GetDate(),112) + '.csv'
    Set @query = 'set nocount on; select a.Id, a.UnitId, ProductNumber,a.CreateUser, a.CreateDate, a.UpdateUser, a.UpdateDate
from  [database1].dbo.[Product](nolock) a
left join [database1].dbo.ParentCustomer(nolock) b
on a.ParentCustomerId=b.Id
left join [database1].dbo.ChildCustomer(nolock) c
on a.ChildCustomerId=c.Id
';

Execute msdb.dbo.sp_send_dbmail
        @profile_name = 'Email Notification Accountx'
      , @recipients = 'DL_OPC_TEAM@xxx.com;xxxx@xx.com;RbReddy@xxx.com'
      , @subject = 'Product list '
	  ,@body_format	= 'HTML'
      , @body = 'Hi Team,<BR>

Please find the attached product list of Prod <BR>

<BR>Note: This is automated mail, If you have any concerns, Please reach out to RBreddy@xxxx.com <BR>

<BR>Thanks
'
      , @query = @query
      --, @query_result_separator = '|'
      , @query_result_header = 1
      , @attach_query_result_as_file = 1
      , @query_attachment_filename = @FileName
	  ,@query_result_separator='	' 
	,@query_result_no_padding=1
	,@query_result_width=32767 
	,@exclude_query_output	= 0
	,@execute_query_database = 'database1'

	select getutcdate()

