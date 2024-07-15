
use sacsngna
go
CREATE TRIGGER tg_Basicarticle_UOM ON Basicarticle
FOR UPDATE
AS
BEGIN
declare @PurchaseToStoreUOC_old varchar(10)
declare @PurchaseToStoreUOC_new varchar(10)
select * into #Deleted from Deleted
select * into #inserted from inserted
select @PurchaseToStoreUOC_new=a.PurchaseToStoreUOC,@PurchaseToStoreUOC_old=b.PurchaseToStoreUOC
    FROM #inserted A
    INNER JOIN #Deleted B ON a.id = b.id
If (@PurchaseToStoreUOC_old<>@PurchaseToStoreUOC_new)
begin
    RAISERROR('Changes to PurchaseToStoreUOC not allowed', 16, 1);
   ROLLBACK
  END
END


CREATE TRIGGER tg_Basicarticle_UOM ON Basicarticle
FOR UPDATE
AS
BEGIN
  IF UPDATE(PurchaseUOM) OR UPDATE(MenuUOM) OR UPDATE(RestitutionUOM) OR UPDATE(StoreUOM)
  BEGIN
     select 1
    RAISERROR('Changes to UOM not allowed contact to Devops', 16, 1);
   ROLLBACK
  END
  else  
  begin
   select 1
   commit 
   return 
  end

END

grant UPDATE ON Basicarticle (PurchaseUOM, MenuUOM,RestitutionUOM,StoreUOM) TO sacsng;

update Basicarticle
set RestitutionUOM='CV'
where id=1

dbcc opentran