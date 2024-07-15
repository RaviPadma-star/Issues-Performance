DECLARE @Table TABLE(
        SPID INT,
        Status VARCHAR(MAX),
        LOGIN VARCHAR(MAX),
        HostName VARCHAR(MAX),
        BlkBy VARCHAR(MAX),
        DBName VARCHAR(MAX),
        Command VARCHAR(MAX),
        CPUTime INT,
        DiskIO INT,
        LastBatch VARCHAR(MAX),
        ProramName VARCHAR(MAX),
        SPID_1 INT,
        REQUESTID INT
)

INSERT INTO @Table EXEC sp_who2

SELECT  *
FROM    @Table
WHERE DBName='SacsNgLatam_HotFix1'


EXEC sp_renamedb 'SacsNgLatam_HotFix', 'SacsNgLatam_HotFixold'
EXEC sp_renamedb 'SacsNgLatam_HotFix1', 'SacsNgLatam_HotFix'

sp_helpdb SacsNgLatam_HotFix