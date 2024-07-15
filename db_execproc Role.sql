
EXEC sp_MSforeachdb 'IF ''?''  IN (''sacsnglatam'',''sacsngseapac'',''sacsngemea'',''sacsngna'')
BEGIN
use [?];
  ALTER ROLE [db_owner] drop MEMBER sacsng
  Grant SHOWPLAN to sacsng
END'


use master
go
sp_msforeachdb 'use [?]; if exists(select 1 from sys.sysusers where name=''Sacsng'') and  exists(select 1 from sys.database_principals where name=''db_execproc'')
begin
GRANT EXECUTE TO db_execproc
Grant SHOWPLAN to sacsng
end'

ALTER ROLE [db_datareader] ADD MEMBER sacsng
ALTER ROLE [db_datawriter] ADD MEMBER sacsng
ALTER ROLE [db_execproc] ADD MEMBER sacsng
Grant SHOWPLAN to sacsng
GRANT VIEW ANY DEFINITION TO sacsng
