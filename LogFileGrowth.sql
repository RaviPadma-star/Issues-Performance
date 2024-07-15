SET NOCOUNT ON
 
DECLARE @threshold int=2
-- step 1: Create temp table and record sqlperf data
CREATE TABLE #tloglist 
( 
databaseName sysname, 
logSize decimal(18,5), 
logUsed decimal(18,5), 
status INT
) 
 
INSERT INTO #tloglist 
       EXECUTE('DBCC SQLPERF(LOGSPACE)') 
 
-- step 2: get T-logs exceeding threshold size in html table format
DECLARE  @xml nvarchar(max)
 
SELECT @xml = Cast((SELECT databasename AS 'td',
'',
logsize AS 'td',
'',
logused AS 'td'
 
FROM #tloglist
WHERE logsize >= (@threshold*1024) 
FOR xml path('tr'), elements) AS NVARCHAR(max))
 
-- step 3: Specify table header and complete html formatting
Declare @body nvarchar(max)
SET @body =
'<html><body><H2>High T-Log Size </H2><table border = 1 BORDERCOLOR="Black"> <tr><th> Database </th> <th> LogSize </th> <th> LogUsed </th> </tr>'
SET @body = @body + @xml + '</table></body></html>'
 
-- step 4: send email if a T-log exceeds threshold
if(@xml is not null)
BEGIN
EXEC msdb.dbo.Sp_send_dbmail
@profile_name = 'Test',
@body = @body,
@body_format ='html',
@recipients = 'rajasekharreddyb.dba@gmail.com',
@subject = 'ALERT: High T-Log Size';
END
 
DROP TABLE #tloglist 
SET NOCOUNT OFF