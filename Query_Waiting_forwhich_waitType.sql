select * 
from sys.dm_exec_requests r
join sys.dm_os_tasks t on r.session_id = t.session_id
where r.session_id = 107