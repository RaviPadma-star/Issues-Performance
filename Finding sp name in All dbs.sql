DECLARE @DB_Name varchar(100) 
DECLARE @Command nvarchar(2000)
DECLARE database_cursor CURSOR FOR 
SELECT name 
FROM MASTER.sys.sysdatabases
 WHERE dbid>4 and name not like '%html%'
and name not in ('ignite_RBreddy','DBA','SacsNG_Arch','SacsNGNA_EP7','EspecsNaVNext','SacsNA','EspecsUatNaVNext'
,'SacsNGGen') 

OPEN database_cursor

FETCH NEXT FROM database_cursor INTO @DB_Name

WHILE @@FETCH_STATUS = 0 
BEGIN 
--print @DB_Name
     SELECT @Command = 'USE '''+@DB_Name+''' 
sp_helptext simplesp
	'
     --EXEC sp_executesql @Command
	print @Command

     FETCH NEXT FROM database_cursor INTO @DB_Name 
END

CLOSE database_cursor 
DEALLOCATE database_cursor
