SELECT Sessions.session_id AS SessionID, 
       Sessions.STATUS, 
       Requests.start_time AS StartTime, 
       Requests.percent_complete, 
       databases.name AS DatabaseName, 
       Requests.database_id AS DatabaseID, 
       Sessions.login_name AS LoginName, 
       Sessions.host_name AS HostName, 
       Sessions.program_name AS ProgramName, 
       Sessions.client_interface_name AS ClientInterfaceName, 
       Requests.blocking_session_id AS BlockedBySessionID, 
       ISNULL(BlockRequests.BlockingRequestCount, 0) AS BlockingRequestCount, 
       Requests.wait_type AS WaitType, 
       Requests.wait_time AS WaitTime, 
       Requests.cpu_time AS CPUTime, 
       Requests.total_elapsed_time AS ElapsedTime, 
       Requests.reads AS Reads, 
       Requests.writes AS Writes, 
       Requests.logical_reads AS LogicalReads, 
       dm_os_tasks.PendingIOCount, 
       Requests.row_count AS [RowCount], 
       Requests.granted_query_memory * 8 AS GrantedQueryMemoryKB, 
       CONVERT(BIGINT, (Requests.cpu_time + 1)) * CONVERT(BIGINT, (Requests.reads * 10 + Requests.writes * 10 + Requests.logical_reads + 1)) AS Score, 
       Statements.text AS BatchText,
       CASE
           WHEN Requests.sql_handle IS NULL
           THEN ' '
           ELSE SUBSTRING(Statements.text, (Requests.statement_start_offset + 2) / 2, (CASE
                                                                                           WHEN Requests.statement_end_offset = -1
                                                                                           THEN LEN(CONVERT(NVARCHAR(MAX), Statements.text)) * 2
                                                                                           ELSE Requests.statement_end_offset
                                                                                       END - Requests.statement_start_offset) / 2)
       END AS StatementText, 
       QueryPlans.query_plan AS QueryPlan
FROM sys.dm_exec_sessions AS Sessions
     JOIN sys.dm_exec_requests AS Requests ON Sessions.session_id = Requests.session_id
     LEFT OUTER JOIN sys.databases ON Requests.database_id = databases.database_id
     LEFT OUTER JOIN
(
    SELECT blocking_session_id, 
           COUNT(*) AS BlockingRequestCount
    FROM sys.dm_exec_requests
    GROUP BY blocking_session_id
) AS BlockRequests ON Requests.session_id = BlockRequests.blocking_session_id
     LEFT OUTER JOIN
(
    SELECT request_id, 
           session_id, 
           SUM(pending_io_count) AS PendingIOCount
    FROM sys.dm_os_tasks WITH(NOLOCK)
    GROUP BY request_id, 
             session_id
) AS dm_os_tasks ON Requests.request_id = dm_os_tasks.request_id
                    AND Requests.session_id = dm_os_tasks.session_id
     CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS Statements
     CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QueryPlans
ORDER BY score DESC;