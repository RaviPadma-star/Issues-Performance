alter FUNCTION CheckContentNumber(@productid int, @ContentNumber nvarchar(50), @IsBasicArticle bit) 
RETURNS int  
AS   
BEGIN  
               DECLARE @retval int  =0

               if (@IsBasicArticle = 1)
			begin
                              select @retval=1 from basicarticle(nolock)
                              where articlenumber=@contentnumber and unitid=(select unitid from product(nolock) where id=@productid)
			end
               else
			begin
                              select @retval=1 from product(nolock)
                              where productnumber=@contentnumber and unitid=(select unitid from product(nolock) where id=@productid)
               end 

               RETURN @retval 
END 



--ALTER TABLE ProductBom 
--ADD CONSTRAINT ContentNumberExists CHECK (dbo.CheckContentNumber(productid, ContentNumber, IsBasicArticle) >= 1 );  


ALTER TABLE ProductBom  with noCHECK
ADD CONSTRAINT ContentNumberExists CHECK (dbo.CheckContentNumber(productid, ContentNumber, IsBasicArticle) >= 1 );   
