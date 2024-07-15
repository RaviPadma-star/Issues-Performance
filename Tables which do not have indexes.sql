-- Tables which do not have any indexes(Not even clustered)
SELECT TOP 1000 o.name, i.type_desc, o.type_desc, o.create_date
FROM sys.indexes i
INNER JOIN sys.objects o
 ON  i.object_id = o.object_id
WHERE o.type_desc = 'USER_TABLE'
AND i.type_desc = 'HEAP'
ORDER BY o.name

-- Tables which do not have any non clustered indexes(Not even clustered)
SELECT TOP 1000 o.name, i.type_desc, o.type_desc, o.create_date
FROM sys.indexes i
INNER JOIN sys.objects o
 ON  i.object_id = o.object_id
WHERE o.type_desc = 'USER_TABLE'
AND i.type_desc = 'HEAP'
ORDER BY o.name


SELECT 
     schemaname = OBJECT_SCHEMA_NAME(o.object_id)
    ,tablename = o.NAME
FROM sys.objects o
INNER JOIN sys.indexes i ON i.OBJECT_ID = o.OBJECT_ID
-- tables that are heaps without any nonclustered indexes
WHERE (
        o.type = 'U'
        AND o.OBJECT_ID NOT IN (
            SELECT OBJECT_ID
            FROM sys.indexes
            WHERE index_id > 0
            )
        )