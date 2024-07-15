The syntax to rename a column in an existing table in SQL Server (Transact-SQL) is:

sp_rename 'table_name.old_column_name', 'new_column_name', 'COLUMN';
Use migration
go
SELECT DISTINCT obj.name AS Object_Name,obj.type_desc 
FROM sys.sql_modules sm INNER JOIN sys.objects obj ON sm.object_id=obj.object_id 
WHERE sm.definition Like '%PRICEH%'

sp_helptext 'Migration.CAP_SalesPrice'
