USE [NorthwindDW]
GO

/****** Object:  StoredProcedure [dbo].[insert_DIM_DATE]    Script Date: 9/27/2018 1:47:28 PM ******/
DROP PROCEDURE [dbo].[insert_DIM_DATE]
GO

/****** Object:  StoredProcedure [dbo].[insert_DIM_DATE]    Script Date: 9/27/2018 1:47:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Description:	Insert DIM_DATE

-- EXEC insert_DIM_DATE
-- =============================================

CREATE    PROCEDURE [dbo].[insert_DIM_DATE]
AS
BEGIN

TRUNCATE TABLE [DimDate];

DECLARE		@startdate		DATE;  
DECLARE		@enddate		DATE;     
DECLARE		@CurrentMonth	INT;

	  
BEGIN
	
	set @startdate = cast('2016-01-01' as date);
	set @enddate = cast('2019-01-01' as date);	-- not inclusive, stops before this
	set @CurrentMonth = cast(cast(datepart(year,getdate()) as char(4)) + '' + right('0' + cast(datepart(mm,getdate()) as varchar(2)),2) as int)

    WHILE @startdate < @enddate 

	BEGIN
    insert into DimDate
	([DateKey]
      ,[Date]
      ,[DayNameShort]
      ,[DayNameLong]
      ,[Weeknbr]
      ,[WeeknbrCode]
      ,[YearWeek]
      ,[DayNbr]
      ,[Monthnbr]
      ,[YearMonth]
      ,[MonthYear]
      ,[DayOfMonthnbr]
      ,[Year]
      ,[LastDayOfMonth]
      ,[LastDayOfQuartal]
      ,[LastDayOfFirstHalfOfYear]
      ,[LastDayOfYear]
      ,[LastDayOfOngoingMonth]
      ,[WorkingDayAmount]
      ,[DayAmount]
      ,[Quarter]
      ,[YearQuarter]
    )  
    VALUES
    (convert(int, convert(varchar,@startdate,112)),																		-- DATEKEY
	convert(date, @startdate),																							-- DATE
	case datepart(weekday, @startdate)																					-- DAYNAMESHORT
		when 2
		then 'MON'
		when 3
		then 'TUE'
		when 4
		then 'WED'
		when 5
		then 'THU'
		when 6
		then 'FRI'
		when 7
		then 'SAT'
		when 1
		then 'SUN' 
	end,
	case datepart(weekday, @startdate)																					-- DAYNAMELONG
		when 2
		then 'Monday'
		when 3
		then 'Tuesday'
		when 4
		then 'Wednesday'
		when 5
		then 'Thursday'
		when 6
		then 'Friday'
		when 7
		then 'Saturday'
		when 1
		then 'Sunday' 
	end,
	datepart(iso_week, @startdate),																						-- WEEKNBR
	right(('0' + convert(varchar,datename(ISO_WEEK, @startdate))), 2),													-- WEEKNBRCODE
	substring((convert(varchar,@startdate,112)),1,4) + '-' + right(('0' + convert(varchar,datename(ISO_WEEK, @startdate))), 2),	-- YEARWEEK
	datepart(weekday, @startdate),																						-- DAYNBR															
	cast(substring((convert(varchar,@startdate,112)),5,2) as int),														-- MONTHNUMBER
	substring((convert(varchar,@startdate,112)),1,6),																	-- YEARMONTH
	case month(@startdate)																								        -- MONTHYEAR
		when 1
		then 'JANUARY'
		when 2
		then 'FEBRUARY'
		when 3
		then 'MARCH'
		when 4
		then 'APRIL'
		when 5
		then 'MAY'
		when 6
		then 'JUNE'
		when 7
		then 'JULY'
		when 8
		then 'AUGUST'
		when 9
		then 'SEPTEMBER'
		when 10
		then 'OCTOBER'
		when 11
		then 'NOVEMBER'
		when 12
		then 'DECEMBER'
		end 
		+ ' ' +  CAST(YEAR(@startdate) AS VARCHAR(4)),		
	cast(substring((convert(varchar,@startdate,112)),7,2) as int),														-- MONTHDAYNUMBER
	cast(substring((convert(varchar,@startdate,112)),1,4) as int),														-- YEAR
	case																												-- LASTDAYOFMONTH
		when EOMONTH(@startdate) = @startdate
			then 'Y' 
		else 'N'
	end,																		
	case																												-- LASTDAYOFQUARTAL
		when EOMONTH(@startdate) = @startdate and month(@startdate) % 3 = 0
			then 'Y' 
		else 'N'
	end,																
	case																												-- LASTDAYOFMIDDLEOFYEAR
		when EOMONTH(@startdate) = @startdate and month(@startdate) % 6 = 0
			then 'Y' 
		else 'N'
	end,																
	case																												-- LASTDAYOFYEAR
		when EOMONTH(@startdate) = @startdate and month(@startdate) % 12 = 0
			then 'Y' 
		else 'N'	end,																							
	case																												-- LASTDAYOFONGOINGMONTH
		when @CurrentMonth = cast(cast(datepart(year,@startdate) as char(4)) + '' + right('0' + cast(datepart(mm,@startdate) as varchar(2)),2) as int)
			then 'Y'
			else 'N'
			end,
	case																												-- WORKINGDAYAMOUNT
	when datepart(dw,@startdate) in(1,7)  -- SAT / SUN
		then 0
		else 1  
		end,																
	1,																													-- DAYOMOUNT const = 1;
	datepart(quarter, @startdate),																						-- QUARTER
	concat(year(@startdate), '/Q', datepart(quarter, @startdate))														-- YEARQUARTER
	);

    set @startdate = dateadd(day, 1, @startdate);
    
	END

	END;

	---- Public holidays -  stationay

	WITH CTE_Weekdays AS
	( SELECT * FROM DimDate WHERE DATEPART([DW],[DATE]) between 2 and 6)

	update CTE_Weekdays
	set WORKINGDAYAMOUNT = 0
	where
	(MONTHNBR = 12 and DAYOFMONTHNBR = 6)  -- Itsenäisyyspäivä
	or 
	(MONTHNBR = 12 and DAYOFMONTHNBR between 24 and 26)  -- Joulu
	or 
	(MONTHNBR = 1 and DAYOFMONTHNBR = 1)  -- Uusi vuosi
	or 
	(MONTHNBR = 1 and DAYOFMONTHNBR = 6)  -- Loppiainen
	or 
	(MONTHNBR = 5 and DAYOFMONTHNBR = 1)  -- Vappu
	or 
	(MONTHNBR = 6 and DAYOFMONTHNBR between 20 and 26 and WEEKNBR = 6)  -- Juhannusaatto

	update DimDate
	set WORKINGDAYAMOUNT = 0
	where [DATE] = [dbo].fnAikaHelatorstai([YEAR])
	or [DATE] = [dbo].[fnAikaPaasiaissunnuntai]([YEAR]) + 1
	or [DATE] = [dbo].[fnAikaPaasiaissunnuntai]([YEAR]) - 2


END
	

GO


