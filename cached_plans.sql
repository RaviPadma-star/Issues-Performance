SELECT text, cp.objtype, cp.size_in_bytes
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE cp.cacheobjtype = N'Compiled Plan'
AND cp.objtype IN(N'Adhoc', N'Prepared')
AND cp.usecounts = 1
and text like '%FIN_SLT_File_Save%'
ORDER BY cp.size_in_bytes DESC
OPTION (RECOMPILE);

SELECT st.text, qs.query_hash
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.text like '%FIN_SLT_File_Save%'



SELECT qp.query_plan, 
       CP.usecounts, 
       cp.cacheobjtype, 
       cp.size_in_bytes, 
       cp.usecounts, 
       SQLText.text
  FROM sys.dm_exec_cached_plans AS CP
  CROSS APPLY sys.dm_exec_sql_text( plan_handle)AS SQLText
  CROSS APPLY sys.dm_exec_query_plan( plan_handle)AS QP
  WHERE   SQLText.text like '%FIN_SLT_File_Save%'


  SELECT qp.*
  FROM sys.dm_exec_cached_plans AS CP
  CROSS APPLY sys.dm_exec_sql_text( plan_handle)AS SQLText
  CROSS APPLY sys.dm_exec_query_plan( plan_handle)AS QP
  WHERE   SQLText.text like '%FIN_SLT_File_Save%'


--All the plans for the objective
SELECT cp.objtype AS ObjectType,
OBJECT_NAME(st.objectid,st.dbid) AS ObjectName,
cp.usecounts AS ExecutionCount,
st.TEXT AS QueryText,
qp.query_plan AS QueryPlan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
--WHERE OBJECT_NAME(st.objectid,st.dbid) = 'YourObjectName'


--how much time a proc took recently
avg_elapsed_time=?

SELECT TOP(25) p.name AS [SP Name], qs.min_elapsed_time, qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time], 
qs.max_elapsed_time, qs.last_elapsed_time, qs.total_elapsed_time, qs.execution_count,  -- 13 -- This helps you find high average elapsed time cached stored procedures that
ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute], --  14: -- may be easy to optimize with standard query tuning techniques
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], 
qs.total_worker_time AS [TotalWorkerTime], qs.cached_time
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ON p.[object_id] = qs.[object_id] and p.name='RPT_INV_CateringSpecsPerFlightDateProductToCSVRpt'
WHERE qs.database_id = DB_ID()
ORDER BY avg_elapsed_time DESC OPTION (RECOMPILE);

select 1352208236/(1000000*60)
select 1352208236/(1000000*60)