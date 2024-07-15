DECLARE @hr int
DECLARE @fso int
DECLARE @drive char(1)
DECLARE @odrive int
DECLARE @TotalSize varchar(20)
DECLARE @MB bigint ; 

SET @MB = 1048576

CREATE TABLE #drives (drive char(1) PRIMARY KEY,
FreeSpace int NULL,
TotalSize int NULL)
INSERT #drives(drive,FreeSpace)
EXEC master.dbo.xp_fixeddrives
EXEC @hr=sp_OACreate 'Scripting.FileSystemObject',@fso OUT
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
DECLARE dcur CURSOR LOCAL FAST_FORWARD
FOR SELECT drive from #drives
ORDER by drive
OPEN dcur
FETCH NEXT FROM dcur INTO @drive
WHILE @@FETCH_STATUS=0
BEGIN
EXEC @hr = sp_OAMethod @fso,'GetDrive', @odrive OUT, @drive
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
EXEC @hr = sp_OAGetProperty @odrive,'TotalSize', @TotalSize OUT
IF @hr <> 0 EXEC sp_OAGetErrorInfo @odrive

UPDATE #drives
SET TotalSize=@TotalSize/@MB
WHERE drive=@drive
FETCH NEXT FROM dcur INTO @drive
END

CLOSE dcur
DEALLOCATE dcur

EXEC @hr=sp_OADestroy @fso
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso

SELECT @@servername as ServerName, drive,
FreeSpace as 'Free(MB)',
TotalSize as 'Total(MB)',
CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) as 'Free(%)',
GETDATE() as Date_Entered
into #result_set
FROM #drives

declare @servername nvarchar(100), @drive1 nvarchar(2), @freeMB int, @totalMB int, @free int, @date_entered nvarchar(50)
      
declare db_crsr_T cursor for
   SELECT [ServerName], [drive], [Free(MB)], [Total(MB)], [Free(%)], [Date_Entered] from #result_set

open db_crsr_T
fetch next from db_crsr_T into @servername, @drive1, @FreeMB, @totalMB, @free, @date_entered
while @@fetch_status = 0
begin   
   
   if @free < 30 and @free > 10
      begin
      declare @msg1 nvarchar(500)
      SET @msg1 = 'Instance ' + RTRIM(@servername) + ' only has ' + CONVERT(NVARCHAR(9),@freeMB) + ' MB free on disk ' + CONVERT(CHAR(1),@drive1) + ':\. The percentage free is ' + CONVERT(NVARCHAR(3),@free) + '. Drive ' + CONVERT(CHAR(1),@drive1) +':\ has a total size of ' + LTRIM(CONVERT(NVARCHAR(10),@totalMB)) + ' MB and ' + CONVERT(NVARCHAR(9),@freeMB) + ' MB free.'
      EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'TEST', -- CHANGE THIS TO YOUR SERVERS MAIL PROFILE NAME...
    @recipients = 'rajasekharreddyb.dba@gmail.com', --CHANGE THIS TO YOUR EMAIL ADDRESS...
    @body = @msg1,
    @subject = 'Disk space alert' ;
      end
   if @free < 10
      begin
      declare @msg2 nvarchar(500)
      SET @msg2 = 'WARNING!! Instance ' + RTRIM(@servername) + ' only has ' + CONVERT(NVARCHAR(9),@freeMB) + ' MB free on disk ' + CONVERT(CHAR(1),@drive1) + ':\. The percentage free is ' + CONVERT(NVARCHAR(3),@free) + '. Drive ' + CONVERT(CHAR(1),@drive1) +':\ has a total size of ' + LTRIM(CONVERT(NVARCHAR(10),@totalMB)) + ' MB and ' + CONVERT(NVARCHAR(9),@freeMB) + ' MB free.'
      EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'TEST',  -- CHANGE THIS TO YOUR SERVERS MAIL PROFILE NAME...
    @recipients = 'rajasekharreddyb.dba@gmail.com', --CHANGE THIS TO YOUR EMAIL ADDRESS...
    @body = @msg2,
    @subject = 'Disk Space Warning!' ;
      end      

   fetch next from db_crsr_T into @servername, @drive1, @FreeMB, @totalMB, @free, @date_entered
end

close db_crsr_T
deallocate db_crsr_T


DROP TABLE #drives
DROP TABLE #result_set
--sp_configure 'Ole Automation Procedures',1
--reconfigure