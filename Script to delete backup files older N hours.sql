EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'TestDB'
GO
USE [master]
GO
/****** Object:  Database [TestDB]    Script Date: 9/5/2018 8:16:57 AM ******/
DROP DATABASE [TestDB]
GO


select database_name,physical_device_name from msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
left join sysdatabases on master.sys.sysdatabases.name=msdb.dbo.backupset.database_name
where master.sys.sysdatabases.name is null

CREATE PROCEDURE [dbo].[usp_DeleteOldBackupFiles] @path NVARCHAR(256),
	@extension NVARCHAR(10),
	@age_hrs INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DeleteDate NVARCHAR(50)
	DECLARE @DeleteDateTime DATETIME

	SET @DeleteDateTime = DateAdd(hh, - @age_hrs, GetDate())

        SET @DeleteDate = (Select Replace(Convert(nvarchar, @DeleteDateTime, 111), '/', '-') + 'T' + Convert(nvarchar, @DeleteDateTime, 108))

	EXECUTE master.dbo.xp_delete_file 0,
		@path,
		@extension,
		@DeleteDate,
		1
END

--usp_DeleteOldBackupFiles – calls the stored procedure we created earlier

--‘D:\MSSQL_DBBackups’ – the first parameter tells the stored procedure where to look
--‘bak’ – the second parameter tells what extension or file type to look

--Note: for the extension, do not use dot before the extension as the xp_delete_file already takes that into account. ‘.bak’ is incorrect use as opposed to ‘bak’, which is correct use.

--720 – the third parameter which tells the stored procedure the number of hours a backup file must be older than to get deleted. 
