USE [SacsNGLATAM_04232018]
GO
/****** Object:  Trigger [dbo].[tr_BasicArticle_AfterUpdate]    Script Date: 5/10/2018 2:26:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  /*-----------------------------------Change History-------------------------
05-May-2018 Sacsopr-769 Add  update trigger to  BasicArticle
---------------------------------------------------------------------------*/  
ALTER TRIGGER [dbo].[tr_BasicArticle_AfterUpdate] ON [dbo].[BasicArticle]   
FOR UPDATE  
AS  
BEGIN   
DECLARE @COLCOUNT bigint=0  
DECLARE @column varchar(max)  
DECLARE @query nvarchar(MAX)  
DECLARE @table_id int    
  CREATE TABLE #tempExecutionTime     
        (     
           id      bigint IDENTITY(1, 1),     
           StartTime datetime,  
     EndTime datetime     
        )    
 declare  @start datetime =getdate()  
 declare  @End datetime  
  
  CREATE TABLE #tempbacolumns     
        (     
           id      bigint IDENTITY(1, 1),     
           colname VARCHAR(max)     
        )   
   
 select @table_id = id from sysobjects  where  name='basicarticle'  
 ;with  --divide bitmask into bytes. this query requires number table Admin.tTally in the database   
 columnsCTE as --return columns belonging to table @TableObjectId, calculate appropriate bit masks  
 (  
   select column_id, [name] column_name,convert(binary(1), substring(columns_updated(), ((column_id - 1) / 8 + 1), 1)) [ByteValue],column_id as  ByteNumber, power(2, (((a.column_id - 1 ) % 8) + 1) - 1) BitMask  
   from sys.columns a  where a.object_id = @table_id  
 )    
  
 insert into #tempbacolumns(colname)   
 select column_name from columnsCTE where ByteValue & BitMask > 0 and  column_name NOT IN ( 'AuditId', 'Id', 'MasterUnitArticleId','UnitId'  ,     
                                      'ArticleNumber', 'WYUpdateDate',  'StandardPriceUpdateDate','StandardPriceUpdateUser' ,     
                                      'InflationRateUpdateDate', 'DayPriceUpdateDate', 'DayPriceUpdateUser', 'AuditDate',     
                                      'AuditUser', 'AuditApp', 'CreateUser', 'CreateDate', 'UpdateUser', 'UpdateDate', 'CommodityUpdateDate' )     
  
 select * into #Deleted from Deleted  
 select * into #inserted from inserted  
     
SELECT @COLCOUNT= Count(colname)  from #tempbacolumns  
  
 DECLARE @count bigint=1     
 WHILE( @count <= @COLCOUNT )   
   BEGIN  
   SELECT @column = colname  FROM   #tempbacolumns  WHERE  id = @count   
   SET @query='Select I.UnitId,I.Id, ''' + @column    
   + ''' ,I.'+ @column  +',D.'+@column  +''  +' ,getdate(),I.UpdateUser   
   from #inserted I INNER JOIN  #Deleted D   
   on I.ID= D.ID and I.UnitId=D.UnitId  
   where   ISNULL(I.'+ @column +',''0'') <> ISNULL (D.'+@column +',''0'')'  
  
   INSERT INTO BasicArticle_AuditLog(UnitId  ,BasicArticleId  ,FieldName , NewValue,OldValue   ,CreatedDate  ,CreatedUser   )   
   exec sp_executesql  @query    
   SET @count =@count + 1     
      
  END  
  set @End =getdate()  
   insert into TriggerExecutionTime  
   select 'tr_BasicArticle_AfterUpdate',@start,@End    
     
END  
  
 

