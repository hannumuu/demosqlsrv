/****** Object:  UserDefinedFunction [dbo].[fnAikaHelatorstai]    Script Date: 9/27/2018 2:08:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[fnAikaHelatorstai] (@Vuosi INT)  
RETURNS DATETIME
WITH EXECUTE AS CALLER  
AS  
BEGIN  


DECLARE @a INT, @b INT, @c INT, @d int, @e int, @f int, @g int, @P_kk AS INT, @P_PV AS INT, @P_KK_CHAR AS CHAR(2), @P_PV_CHAR AS CHAR(2)

set @a = @Vuosi%19
set @b = @Vuosi%4
set @c = @Vuosi%7
set @f = 24
set @g = 5 
set @d = (19 * @a + @f)%30
set @e = (2* @b + 4* @c + 6* @d + @g)%7

IF (30 + @d + @e) >= 1 AND (30 + @d + @e) <= 30
	BEGIN 
		SET @P_kk = 4
		SET @P_PV = (30 + @d + @e)
	END

IF ( @d+ @e) >= 1 AND ( @d+ @e) <= 31
	BEGIN
		SET @P_kk = 5
		SET @P_PV = ( @d+ @e)
	END
ELSE
	BEGIN
		SET @P_kk = 6
		SET @P_PV = @d + @e - 31
	END


	--SELECT 'HUhti' = 30 + @d + @e , 'Touko' = @d+ @e, 'Kesä' = @d + @e - 31

SET @P_PV_CHAR = RIGHT('0' + CAST(@P_PV AS VARCHAR(2)),2)
SET @P_KK_CHAR = RIGHT('0' + CAST(@P_KK AS VARCHAR(2)),2)

RETURN (CAST(@Vuosi AS CHAR(4)) + '-' + @P_KK_CHAR + '-' + @P_PV_CHAR)


END
GO

