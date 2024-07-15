
DBCC SHOW_STATISTICS ("[dbo].CateringStowagePlanDetail", [PK_CateringStowagePlanDetail_Id]);  -- last updated dec 2016 
GO
Rows	Rows Sampled
497860	68799

EXEC sp_MSForEachTable 'UPDATE STATISTICS ? WITH FULLSCAN'

After Update Stats with full scan
Rows	Rows Sampled
497860	497860



use msdb
EXECUTE dbo.IndexOptimize
@Databases = 'SacsNGEMEA_12MAY',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y'

