CREATE FUNCTION fn_recursivecheck
(@productid     INT,
 @productnumber NVARCHAR(25),
 @contentnumber NVARCHAR(25)
)
RETURNS INT
AS
     BEGIN
         IF @productnumber IS NULL
             SELECT TOP 1 @productnumber = productnumber
             FROM product(nolock)
             WHERE id = @productid;
         IF(@productnumber = @contentnumber)
             RETURN 0;
         RETURN 1;
     END;


ALTER TABLE ProductCPCDetail
WITH NOCHECK
ADD CONSTRAINT cpc_recursivecheck_cpc CHECK(dbo.fn_recursivecheck(productid, productnumber, contentnumber) = 1);


ALTER TABLE ProductBom
WITH NOCHECK
ADD CONSTRAINT recursivecheck_bom CHECK(dbo.fn_recursivecheck(productid, NULL, contentnumber) = 1);