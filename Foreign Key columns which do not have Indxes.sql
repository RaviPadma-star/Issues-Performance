
use [SacsngEMEA_20180504]
go
CREATE TABLE #TempForeignKeys (TableName varchar(100), ForeignKeyName varchar(100) , ObjectID int,columnname  varchar(200) )
INSERT INTO #TempForeignKeys 
SELECT OBJ.NAME, ForKey.NAME, ForKey .[object_id] , c1.name AS FK_column
FROM sys.foreign_keys ForKey
INNER JOIN sys.objects OBJ
ON OBJ.[object_id] = ForKey.[parent_object_id]
INNER JOIN sys.foreign_key_columns fkc
        ON ForKey.object_id = fkc.constraint_object_id
 INNER JOIN sys.columns c1
        ON fkc.parent_object_id = c1.object_id
        AND fkc.parent_column_id = c1.column_id
WHERE OBJ.is_ms_shipped = 0
 
CREATE TABLE #TempIndexedFK (ObjectID int,columnname varchar(200))
INSERT INTO #TempIndexedFK  
SELECT ObjectID,COL_NAME(ForKeyCol.parent_object_id, ForKeyCol.parent_column_id)
FROM sys.foreign_key_columns ForKeyCol
JOIN sys.index_columns IDXCol
ON ForKeyCol.parent_object_id = IDXCol.[object_id]
JOIN #TempForeignKeys FK
ON  ForKeyCol.constraint_object_id = FK.ObjectID
WHERE ForKeyCol.parent_column_id = IDXCol.column_id 
 
SELECT * FROM #TempForeignKeys WHERE ObjectID NOT IN (SELECT ObjectID FROM #TempIndexedFK)
 
DROP TABLE #TempForeignKeys
DROP TABLE #TempIndexedFK
 
