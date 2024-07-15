delete  from FinanceGLAccount
SET IDENTITY_INSERT FinanceGLAccount off
insert into FinanceGLAccount(Id, GLAccountNumber, DiscountAccountNumber, Description, CostCenterCode, CreateUser, CreateDate, UpdateUser, UpdateDate, AccountType)
select Id, GLAccountNumber, DiscountAccountNumber, Description, CostCenterCode, CreateUser, CreateDate, UpdateUser, UpdateDate, AccountType
from [172.25.40.69].[SacsNGSEAPAC].[dbo].FinanceGLAccount

DECLARE @MAX INT SELECT @MAX=MAX(ISNULL(Id,0)) FROM FinanceGLAccount

DBCC CHECKIDENT ('FinanceGLAccount', RESEED,@MAX)