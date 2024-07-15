SELECT [schema_name] = s.name, table_name = o.name, MAX(I1.type_desc) ClusteredIndexorHeap, MAX(COALESCE(I2.NonClusteredIndex,0)) NonClusteredIndex, MAX(COALESCE(I4.NC_ColumnStoreIndex,0)) NC_ColumnStoreIndex, MAX(COALESCE(I3.OtherIndex,0)) OtherIndex FROM  sys.objects o INNER JOIN sys.schemas s ON o.[schema_id] = s.[schema_id] LEFT JOIN sys.indexes I1 ON o.OBJECT_ID = I1.OBJECT_ID AND I1.TYPE IN (0,1,5) LEFT JOIN  (SELECT OBJECT_ID,COUNT(Index_id) NonClusteredIndex FROM sys.indexes WHERE type = 2 GROUP BY OBJECT_ID) I2 ON o.OBJECT_ID = I2.OBJECT_ID  LEFT JOIN (SELECT OBJECT_ID,COUNT(Index_id) OtherIndex 
 FROM sys.indexes  WHERE type IN (3,4,7)  GROUP BY OBJECT_ID) I3  ON o.OBJECT_ID = I3.OBJECT_ID   LEFT JOIN (SELECT OBJECT_ID,COUNT(Index_id) NC_ColumnStoreIndex   
 FROM sys.indexes   WHERE type = 6   GROUP BY OBJECT_ID) I4 ON o.OBJECT_ID = I4.OBJECT_ID
  WHERE o.TYPE IN ('U') --and NonClusteredIndex=0 --and ClusteredIndexorHeap='Heap'
  GROUP BY s.name, o.name  
 ORDER BY NonClusteredIndex DESC, schema_name, table_name
