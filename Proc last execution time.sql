	   SELECT object_name(object_id), last_execution_time, last_elapsed_time/1000 'last_elapsed_time in Milli secs'
FROM   sys.dm_exec_procedure_stats ps 
where lower(object_name(object_id)) like 'RPT_RET_BAStyleC208%'
order by 1