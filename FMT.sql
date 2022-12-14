USE [Filevine_META_Test]
GO
/****** Object:  UserDefinedFunction [dbo].[CleanSpaces]    Script Date: 12/12/2022 1:36:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Katie Jumonville
-- Create date: Updated for Filevine on 6/28/2019
-- Description:	Runs Left trim and right trim on the value. Removes all double spaces and tab characters in a given string based on provided bits
-- =============================================
CREATE   FUNCTION [dbo].[CleanSpaces](@String varchar(MAX), @RemoveDoublespace BIT, @ReplaceTabs BIT)
RETURNS varchar(MAX)
AS
BEGIN
	/*Do the typical trim*/
	SET @String = ltrim(rtrim(@String))

	/*Remove trailing tabs, line feeds, and carriage returns*/
	WHILE RIGHT(@String,1) IN (CHAR(9),CHAR(10),CHAR(13),' ') AND LEN(@String) > 0
	BEGIN
		SET @String = LEFT(@String, len(@String)-1)
	END

	/*Redo the typical trim*/
	SET @String = ltrim(rtrim(@String))
	
	/*Replace tabs if necessary*/
	IF @ReplaceTabs = '1'
	BEGIN
		SET @String = replace(@String,char(9),'; ')
	END

	/*Remove doublespaces if necessary*/
	IF @RemoveDoublespace = '1'
	BEGIN
		WHILE charindex('  ',@String) > 0
		BEGIN
			SET @String = replace(replace(replace(replace(@String,'     ',' '),'    ',' '),'   ',' '),'  ',' ') /*attempt to go though this loop as few times as possible*/
		END
	END

	RETURN @String
END;
GO
/****** Object:  UserDefinedFunction [dbo].[DamerauLevenschtein]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[DamerauLevenschtein] ( @SourceString nvarchar(100), @TargetString nvarchar(100) ) 
--Returns the Damerau Levenshtein Distance between @SourceString string and @TargetString
--Updated by Phil Factor to add transposition as an edit
returns int
as
BEGIN
--DECLARE  @SourceString nvarchar(100)='achieve', @TargetString nvarchar(100)='acheive'
DECLARE @Matrix Nvarchar(4000), @LD int, @TargetStringLength int, @SourceStringLength int,
@ii int, @jj int, @CurrentSourceChar nchar(1), @CurrentTargetChar nchar(1),@Cost int, 
@Above int,@AboveAndToLeft int,@ToTheLeft int, @MinimumValueOfCells INT, @previous INT
 
-- Step 1: Set n to be the length of s. Set m to be the length of t. 
  SELECT @SourceString=RTRIM(LTRIM(COALESCE(@sourceString,''))),
         @TargetString=RTRIM(LTRIM(COALESCE(@TargetString,''))),
		 @SourceStringLength=LEN(@SourceString), 
         @TargetStringLength=LEN(@TargetString)
 
  -- remove matches at the beginning and end
  IF SUBSTRING(@sourceString,1,1)=SUBSTRING(@targetString,1,1)
  BEGIN
  SET @ii=1
  WHILE SUBSTRING(@sourceString+'!!',@ii+1,1)=SUBSTRING(@targetString+'??',@ii+1,1)
    BEGIN
    SELECT @ii=@ii+1 
    END
  SELECT @sourceString=STUFF(@sourceString,1,@ii,''),
         @targetString=STUFF(@targetString,1,@ii,'')
  END
 
 SELECT @SourceStringLength =LEN(@sourceString), @TargetStringLength =LEN(@TargetString) 
 IF SUBSTRING(@sourceString,@SourceStringLength,1)=SUBSTRING(@targetString,@TargetStringLength,1)
  BEGIN
  WHILE SUBSTRING(@sourceString,@SourceStringLength-1,1)=SUBSTRING(@targetString,@TargetStringLength-1,1) 
	AND @SourceStringLength>0 AND @TargetStringLength>0
    BEGIN
    SELECT @SourceStringLength=@SourceStringLength-1,
	       @TargetStringLength=@TargetStringLength-1
	END
  SELECT @sourceString=LEFT(@sourceString,@SourceStringLength)
  SELECT @targetString=LEFT(@targetString,@TargetStringLength)
  END
--    If n = 0, return m and exit.
--    If m = 0, return n and exit.
If @SourceStringLength = 0 return @TargetStringLength
If @TargetStringLength = 0 return @SourceStringLength
if (@TargetStringLength+1)*(@SourceStringLength+1)> 4000 return -1
  IF @SourceStringLength=1 
    RETURN @TargetStringLength
          -CASE WHEN CHARINDEX(@SourceString,@TargetString)>0 THEN 1 ELSE 0 end
  IF @TargetStringLength=1 
    RETURN @SourceStringLength
          -CASE WHEN CHARINDEX(@TargetString,@SourceString)>0 THEN 1 ELSE 0 end
--    Construct a matrix containing 0..m rows and 0..n columns.
SELECT @Matrix=replicate(nchar(0),(@SourceStringLength+1)*(@TargetStringLength+1))
--Step 2: Initialize the first row to 0..n.
--     Initialize the first column to 0..m.
SET @ii=0
WHILE @ii<=@SourceStringLength
    BEGIN
    SET @Matrix=STUFF(@Matrix,@ii+1,1,nchar(@ii))--d(i, 0) = i
    SET @ii=@ii+1
    END
SET @ii=0
WHILE @ii<=@TargetStringLength
    BEGIN
    SET @Matrix=STUFF(@Matrix,@ii*(@SourceStringLength+1)+1,1,nchar(@ii))--d(0, j) = j
    SET @ii=@ii+1
    END
--Step 3 Examine each character of s (i from 1 to n).
SET @ii=1
WHILE @ii<=@SourceStringLength
    BEGIN
--Step 4   Examine each character of t (j from 1 to m).
    SET @jj=1
    WHILE @jj<=@TargetStringLength
        BEGIN
--Step 5 and 6
        Select 
        --Set cell d[i,j] of the matrix equal to the minimum of:
        --a. The cell immediately above plus 1: d[i-1,j] + 1.
        --b. The cell immediately to the left plus 1: d[i,j-1] + 1.
        --c. The cell diagonally above and to the left plus the cost: d[i-1,j-1] + cost 
		@Cost=case when (substring(@SourceString,@ii,1)) = (substring(@TargetString,@jj,1)) 
            then 0 else 1 END,--the cost
        -- If s[i] equals t[j], the cost is 0.
        -- If s[i] doesn't equal t[j], the cost is 1. 
        @Above         =unicode(substring(@Matrix, @jj *  (@SourceStringLength+1)+@ii-1+1,1))+1,
        @ToTheLeft     =unicode(substring(@Matrix,(@jj-1)*(@SourceStringLength+1)+@ii+1  ,1))+1,
        @AboveAndToLeft=unicode(substring(@Matrix,(@jj-1)*(@SourceStringLength+1)+@ii-1+1,1))+@cost,
        @previous      =unicode(substring(@Matrix,(@jj-2)*(@SourceStringLength+1)+@ii-2+1,1))+@cost
        -- now calculate the minimum value of the three
        if (@Above < @ToTheLeft) AND (@Above < @AboveAndToLeft) 
            select @MinimumValueOfCells=@Above
      else if (@ToTheLeft < @Above) AND (@ToTheLeft < @AboveAndToLeft)
            select @MinimumValueOfCells=@ToTheLeft
        else
            select @MinimumValueOfCells=@AboveAndToLeft
        IF (substring(@SourceString,@ii,1) = substring(@TargetString,@jj-1,1) 
              and substring(@TargetString,@jj,1) = substring(@SourceString,@ii-1,1))
            begin
			SELECT @MinimumValueOfCells = 
			  CASE WHEN @MinimumValueOfCells< @previous 
				THEN @MinimumValueOfCells ELSE @previous END 
			  end  
			  --write it to the matrix
		SELECT @Matrix=STUFF(@Matrix,
                   @jj*(@SourceStringLength+1)+@ii+1,1,
                   nchar(@MinimumValueOfCells)),
           @jj=@jj+1
        END
    SET @ii=@ii+1
    END    
--Step 7 After iteration steps (3, 4, 5, 6) are complete, distance is found in cell d[n,m]
return unicode(substring(
   @Matrix,@SourceStringLength*(@TargetStringLength+1)+@TargetStringLength+1,1
   ))
end
GO
/****** Object:  UserDefinedFunction [dbo].[fn_NameSplit_Step1]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_NameSplit_Step1] (@name varchar(100),@nodenum int)  
RETURNS varchar(200) AS  
BEGIN 

declare @salutation varchar(100)
declare @forename varchar(100)
declare @initials varchar(100)
declare @surname varchar(100)
declare @suffix varchar(100)
declare @myword varchar(100)
declare @icount integer
declare @icountprevious integer
declare @namelen integer
declare @returnval varchar(100)

if @name is not null 
   begin
   
   set @icount = 1
   set @icountprevious = 1
   set @myword = null
   set @salutation = ''
   set @forename = ''
   set @initials = ''
   set @surname = ''
   set @Suffix = ''
   
   -- Search suffix and remove from @name
   select @myword = Suffix  from NameSplit_suffix_table where patindex('% ' + Suffix ,@name)<> 0 or @name = Suffix
   while @@rowcount <> 0
      begin
      set @suffix =  ltrim(substring(@name, len(@name) - len(@myword), len(@myword)+1) + ' ' + @suffix)
      set @name = rtrim(substring(@name, 1, len(@name) - len(@myword)))
      select @myword = Suffix  from NameSplit_suffix_table where patindex('% ' + Suffix ,@name)<> 0 or @name = Suffix
      end
      
   -- Search Salutation and remove from @name
   select @myword = Title  from NameSplit_Title_Table where patindex(Title + ' %',@name)<> 0 or @name = Title
   while @@rowcount <> 0
      begin
      set @salutation =  ltrim(@salutation + ' ' + substring(@name, 1, len(@myword)))
      set @name = ltrim(substring(@name, len(@myword)+1 ,len(@name) - len(@myword)))
      select @myword = Title  from NameSplit_Title_Table where patindex(Title + ' %',@name)<> 0 or @name = Title
      end
   -- Split @name into words
   set @namelen = len(@name)
   while @icount < @namelen
      begin
      if substring(@name, @icount,1) = ' ' 
         begin
         set @myword = rtrim(ltrim(substring(@name, @icountprevious, @icount - @icountprevious)))
         
         -- if word is not surname prefix, then
         -- add to @forename with first letter added to @initials
         if not exists (select * from NameSplit_Prefix_Table where Prefix = @myword)
            begin 
            set @forename = ltrim(@forename + ' ' + @myword)
            set @initials = ltrim(@initials + ' ' + left(@myword,1))
            set @icountprevious = @icount
            end
         -- else exit loop 
         else break
         end 
      set @icount = @icount + 1
      end
   -- Add remaining to Surname
   if @surname ='' set  @surname =  ltrim(substring(@name, @icountprevious ,@namelen -  @icountprevious +1))
   end
   if isnull(@nodenum,0) = 0 
		set @returnval = '|1'+ @salutation + '|2'+ @forename + '|3'+ @initials + '|4'+ @surname + '|5'+ @suffix
	if @nodenum =1
		set @returnval = @salutation
	if @nodenum =2
		set @returnval =  @forename 
	if @nodenum =3
		set @returnval=  @initials
    if @nodenum =4
		set @returnval = @surname 
	if @nodenum =5
		set @returnval = @suffix
		 
return @returnval
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_RemoveNonPrintableChars]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   FUNCTION [dbo].[fn_RemoveNonPrintableChars]
(
 @strIn as varchar(1000)
)
returns varchar(1000)
as
begin
 declare @iPtr as int
 set @iPtr = patindex('%[^ -~0-9A-Z]%', @strIn COLLATE LATIN1_GENERAL_BIN)
 while @iPtr > 0 begin
  set @strIn = replace(@strIn COLLATE LATIN1_GENERAL_BIN, substring(@strIn, @iPtr, 1), '')
  set @iPtr = patindex('%[^ -~0-9A-Z]%', @strIn COLLATE LATIN1_GENERAL_BIN)
 end
 return replace(@strIn,'?',' ')
end
GO
/****** Object:  UserDefinedFunction [dbo].[fnCountInstanceInString]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fnCountInstanceInString]
(
      @String NVARCHAR(MAX)
	, @Instance NVARCHAR(MAX)
)  
RETURNS VARCHAR(MAX)

AS  
BEGIN 
	DECLARE 
		  @ReturnString VARCHAR(MAX)  
		, @EmptyString VARCHAR(10) = ''
    
	
	RETURN LEN(REPLACE(REPLACE(REPLACE(@String, CHAR(10), '_'), CHAR(13), '_'), ' ', '_')) - LEN(REPLACE(REPLACE(REPLACE(REPLACE(@String, CHAR(10), '_'), CHAR(13), '_'), ' ', '_'), @Instance, ''))
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnFormatPhone]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnFormatPhone] (@PhoneNumber VARCHAR(32))
RETURNS VARCHAR(32)
AS
BEGIN
    DECLARE @Phone CHAR(32)


    SET @Phone = sandbox_jc.dbo.fnStripCharacters(@PhoneNumber,'^0-9')

    -- cleanse phone number string
    WHILE PATINDEX('%[^0-9]%', @PhoneNumber) > 0
        SET @PhoneNumber = REPLACE(@PhoneNumber, SUBSTRING(@PhoneNumber, PATINDEX('%[^0-9]%', @PhoneNumber), 1), '')

    -- skip foreign phones
    IF (
            SUBSTRING(@PhoneNumber, 1, 1) = '1'
            OR SUBSTRING(@PhoneNumber, 1, 1) = '+'
            OR SUBSTRING(@PhoneNumber, 1, 1) = '0'
            )
        AND LEN(@PhoneNumber) > 11
        RETURN @Phone

    -- build US standard phone number
    SET @Phone = @PhoneNumber
    SET @PhoneNumber = '(' + SUBSTRING(@PhoneNumber, 1, 3) + ') ' + SUBSTRING(@PhoneNumber, 4, 3) + '-' + SUBSTRING(@PhoneNumber, 7, 4)

    IF LEN(@Phone) - 10 > 1
        SET @PhoneNumber = @PhoneNumber + ' X' + SUBSTRING(@Phone, 11, LEN(@Phone) - 10)
	IF LEN(@Phone) < 1 
		SET @PhoneNumber = ''
    RETURN @PhoneNumber
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetFVImportTableColumns]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fnGetFVImportTableColumns]
(
    @TablePrefix varchar(500)= '',
	@TableSubject  varchar(500)= ''
)  
RETURNS @ReturnValue TABLE 
(
    Id INT IDENTITY(1,1),
	importdb_tablename varchar(500) null,
	orgDBTablename varchar(500) null,
	tableSubject	varchar(500) null,
	ordinal_position	int null,
	column_name	varchar(500) null,
	dataColumnType	varchar(500) null,
	requiredFlag varchar (25)
  
) 
AS  
BEGIN 


    DECLARE @Counter INT
	DECLARE @ShortTablePrefix varchar(500)
    SET @Counter = 1
    --set @ShortTablePrefix = substring(@TablePrefix,1,charindex('_',@TablePrefix,2)) -- remove the _scores
	

	insert into @ReturnValue (importdb_tablename,orgDBTablename,	tableSubject,ordinal_position,column_name,dataColumnType,requiredFlag)

	select distinct table_name importdb_tablename, 
	'__FV_'+table_name	 orgDBTablename,
	@TableSubject tableSubject,
	ordinal_position,
	 column_name, 

	case when data_type LIKE '%varchar%' then 
			  data_type+' ('+case when convert(varchar(20),character_maximum_length) = '-1' then 'max' else  convert(varchar(20),character_maximum_length) end +')'
		 when data_type =  'decimal' then data_type+'('+convert(varchar(5),numeric_precision)+','+convert(varchar(5),numeric_Scale)+')' 
		 when data_type like 'ntext' then 'nvarchar(max)'
		 else data_type
			 END dataColumnType,
		case when is_nullable = 'YES' then 'null' else 'not null' end requiredFlag

	from [FilevineProductionImport].INFORMATION_SCHEMA.COLUMNS
	where (table_name like '%'+@TablePrefix+'%') -- or table_name like '%'+@ShortTablePrefix+'%')
			and (table_name like '%'+@TableSubject+'%')
						--or substring(replace(table_name,@ShortTablePrefix,''),1,charindex('_',replace(table_name,@ShortTablePrefix,''),1)-1) like '%'+ @TableSubject+'%')

	order by table_name, ordinal_position

   
    RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnNullIF0and1]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fnNullIF0and1] (@ColumnName NVARCHAR(200))  
RETURNS INT

AS  
BEGIN 
	DECLARE 
		  @Return0_1 INT 		
			SET @Return0_1 = (SELECT CASE WHEN NULLIF(@ColumnName, '') IS NULL THEN 0 ELSE 1 END)

	
		
    RETURN @Return0_1
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnStringSplit]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fnStringSplit]
(
    @String NVARCHAR(MAX),
    @Delimiter NVARCHAR(5)
)  
RETURNS @ReturnValue TABLE 
(
    Id INT IDENTITY(1,1),
    Data NVARCHAR(MAX)
) 
AS  
BEGIN 
	/*Splits out a string based on whatever delimiter you want to use and returns as a table
	You can use STUFF and for XML PATH to pivot the results of the table back to a horizontal record

	example:

	STUFF
		(
			(
				SELECT data
				FROM dbo.fnStringSplit
					(
						(
							select [field] 
							from [table]
							where [ID] = @counter 
						)
						,','
					)
				FOR XML PATH(''),type).value('.','varchar(max)'
			),1,0,''
		)
	*/

    DECLARE @Counter INT
    SET @Counter = 1

    WHILE (CHARINDEX(@Delimiter,@String)>0)
    BEGIN
        INSERT INTO @ReturnValue (data)
        SELECT 
            Data = LTRIM(RTRIM(SUBSTRING(@String,1,CHARINDEX(@Delimiter,@String)-1)))

        SET @String = SUBSTRING(@String,CHARINDEX(@Delimiter,@String)+1,LEN(@String))
        SET @Counter = @Counter + 1
    END

    INSERT INTO @ReturnValue (data)
    SELECT Data = LTRIM(RTRIM(@String))

    RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnStripCharacters]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fnStripCharacters]
(
    @String NVARCHAR(MAX), 
    @MatchExpression VARCHAR(255)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
/*
fnStripCharacters -  any time you need to remove special characters, numbers, and/or letters
Valid Options:
fnStripCharacters(@str,'^a-z ') -- Letters only - with space

fnStripCharacters(@str,'^a-z0-9 ') -- AlphaNumeric - with space

fnStripCharacters(@str,'^a-z0-9') -- AlphaNumeric - no space

fnStripCharacters(@str,'^0-9 ') -- Numbers Only - with space

fnStripCharacters(@str,'^0-9') -- Numbers Only - no space
*/


    SET @MatchExpression =  '%['+@MatchExpression+']%'
    
    WHILE PatIndex(@MatchExpression, @String) > 0
        SET @String = Stuff(@String, PatIndex(@MatchExpression, @String), 1, '')
    
    RETURN @String


    
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnTrueQuoteName]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fnTrueQuoteName]
(
      @String NVARCHAR(MAX)
	, @FirstQuote NVARCHAR(MAX)
	, @LastQuote NVARCHAR(MAX)
)  
RETURNS VARCHAR(MAX)

AS  
BEGIN 
	DECLARE 
		  @ReturnString VARCHAR(MAX)  
		, @FirstQuoteExists BIT = 0
		, @LastQuoteExists BIT = 0
		, @True BIT = 1
		, @False BIT = 0
		, @EmptyString VARCHAR(10) = ''
    
	
	IF SUBSTRING(@String, 1, 1) = @FirstQuote
		BEGIN
			SET @FirstQuoteExists = @True
		END

	IF SUBSTRING(REVERSE(@String), 1, 1) = @LastQuote
		BEGIN
			SET @LastQuoteExists = @True
		END

	IF @FirstQuoteExists = @True AND @LastQuoteExists = @True
		BEGIN
			SET @ReturnString = @FirstQuote + SUBSTRING(@String, LEN(@String) - (LEN(@String) - 2), LEN(@String) - 2) + @LastQuote
		END
	ELSE
		BEGIN
			SET @ReturnString = @FirstQuote + @String + @LastQuote
		END
		
    RETURN REPLACE(@ReturnString,'"','')
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetLiteralDataType]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[GetLiteralDataType]( @TableName as VARCHAR(100), @ColumnName as VARCHAR(100) )
    RETURNS VARCHAR(100)
    AS
    BEGIN

        DECLARE @DataType	  VARCHAR(100);
        DECLARE @MaxLength	  VARCHAR(100);
        DECLARE @Precision	  VARCHAR(100);
        DECLARE @Scale		  VARCHAR(100);
		DECLARE @FullDataType VARCHAR(100);

		DECLARE @SQL NVARCHAR(max);
		
		SELECT @DataType = UPPER(DATA_TYPE),
			   @MaxLength = CHARACTER_MAXIMUM_LENGTH,
			   @Precision = NUMERIC_PRECISION,
			   @Scale = NUMERIC_SCALE
		  FROM INFORMATION_SCHEMA.COLUMNS
		 WHERE TABLE_NAME = @TableName
		   AND COLUMN_NAME = @ColumnName;		
	

		SELECT @FullDataType = 
		  CASE WHEN @DataType ='DECIMAL'   THEN @DataType+'('+ @Precision + ',' + @Scale + ')'
			   WHEN @DataType LIKE '%CHAR' THEN @DataType+'('+ CASE WHEN @MaxLength = '-1' THEN 'MAX' ELSE @MaxLength END + ')'
			   ELSE @DataType
		   END;

        RETURN @FullDataType ;
    END
GO
/****** Object:  UserDefinedFunction [dbo].[GetLiteralDataType_Dynamic]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[GetLiteralDataType_Dynamic]( @TableName as VARCHAR(100), @ColumnName as VARCHAR(100),@Database as varchar(100) )
    RETURNS VARCHAR(100)
    AS
    BEGIN

        DECLARE @DataType	  VARCHAR(100);
        DECLARE @MaxLength	  VARCHAR(100);
        DECLARE @Precision	  VARCHAR(100);
        DECLARE @Scale		  VARCHAR(100);
		DECLARE @FullDataType VARCHAR(100);

		DECLARE @SQL NVARCHAR(max);
		set @SQL = ' USE ['+@Database +'] 
		SELECT @DataType = UPPER(DATA_TYPE),
			   @MaxLength = CHARACTER_MAXIMUM_LENGTH,
			   @Precision = NUMERIC_PRECISION,
			   @Scale = NUMERIC_SCALE
		  FROM INFORMATION_SCHEMA.COLUMNS
		 WHERE TABLE_NAME = '''+@TableName+'''
		   AND COLUMN_NAME = '''+@ColumnName+''';'		
		  EXEC sp_executesql @SQL,N'@DataType varchar(100) OUTPUT, @MaxLength varchar(100) OUTPUT,@Precision varchar(100),@Scale varchar(100) '
										,@DataType OUTPUT
										,@MaxLength OUTPUT
										,@Precision OUTPUT
										,@Scale OUTPUT

		SELECT @FullDataType = 
		  CASE WHEN @DataType ='DECIMAL'   THEN @DataType+'('+ @Precision + ',' + @Scale + ')'
			   WHEN @DataType LIKE '%CHAR' THEN @DataType+'('+ CASE WHEN @MaxLength = '-1' THEN 'MAX' ELSE @MaxLength END + ')'
			   ELSE @DataType
		   END;

        RETURN @FullDataType ;
    END
GO
/****** Object:  UserDefinedFunction [dbo].[isnotnull]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   FUNCTION [dbo].[isnotnull](@CheckExpression varchar(MAX),@ReplacementValue varchar(MAX))

RETURNS varchar(MAX)
AS
BEGIN
	
	RETURN CASE WHEN NULLIF(@CheckExpression,'') IS NULL THEN NULL ELSE @ReplacementValue END
 

END
GO
/****** Object:  UserDefinedFunction [dbo].[RemoveNumericCharacters]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Function [dbo].[RemoveNumericCharacters](@Temp VarChar(1000))
Returns VarChar(1000)
AS
Begin

    Declare @NumRange as varchar(50) = '%[0-9]%'
    While PatIndex(@NumRange, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@NumRange, @Temp), 1, '')

    Return @Temp
End

GO
/****** Object:  UserDefinedFunction [dbo].[SplitToRows]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[SplitToRows] (@column varchar(max), @separator varchar(20))
RETURNS @rtnTable TABLE
  (
  ID int identity(1,1),
  ColumnA varchar(max)
  )
 AS
BEGIN
    DECLARE @position int = 0
    DECLARE @endAt int = 0
    DECLARE @tempString varchar(max)

    set @column = ltrim(rtrim(@column))

    WHILE @position<=len(@column)
    BEGIN       
        set @endAt = CHARINDEX(@separator,@column,@position)
            if(@endAt=0)
            begin
            Insert into @rtnTable(ColumnA) Select substring(@column,@position,len(@column)-@position)
            break;
            end
        set @tempString = substring(ltrim(rtrim(@column)),@position,@endAt-@position)

        Insert into @rtnTable(ColumnA) select @tempString
        set @position=@endAt+1;
    END
    return
END
GO
/****** Object:  UserDefinedFunction [dbo].[StripNonNumerics]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[StripNonNumerics]
(
  @Temp varchar(255)
)
RETURNS varchar(255)
AS
Begin

    Declare @KeepValues as varchar(50)
    Set @KeepValues = '%[^0-9]%'
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')

    Return @Temp
End
GO
/****** Object:  UserDefinedFunction [dbo].[ToTitleCase]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ToTitleCase] (@inputString NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @stringTable TABLE (
		[ID] INT IDENTITY(1,1) NOT NULL,
		[LOWER] NVARCHAR(MAX) NOT NULL,
		[TITLE] NVARCHAR(MAX) NOT NULL
	)
	DECLARE @outputString NVARCHAR(255) = ''

	SET @inputString = LOWER(TRIM(@inputString))
	WHILE (PATINDEX('%  %',@inputString) > 0)
		SET @inputString = REPLACE(@inputString,'  ',' ')

	INSERT INTO @stringTable ([LOWER],[TITLE])
	SELECT
		LOWER(VALUE) AS [LOWER],
		CONCAT(UPPER(LEFT(VALUE,1)),SUBSTRING(VALUE,2,LEN(VALUE)-1)) AS [TITLE]
	FROM STRING_SPLIT(@inputString,' ')


	SELECT @outputString += CONCAT([TITLE],' ') FROM @stringTable

	RETURN TRIM(@outputString)
END


--SELECT dbo.ToTitleCase('this  that  other')

GO
/****** Object:  UserDefinedFunction [dbo].[udf_CleanColumnName]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_CleanColumnName] (@in VARCHAR(4000))
RETURNS VARCHAR(4000)
AS
BEGIN

declare 
    @out varchar(4000) = '',
    @word varchar(4000) = '',
    @x int = 1,
    @a char = '';

set @in = replace(replace(@in, '[', ''), ']', '');

WHILE @x <= LEN(@in)
BEGIN

    set @a = substring(@in, @x, 1);

    -- Add word characters to @word.
    IF @a LIKE '[a-z]'
    BEGIN
        set @word = @word + case when @word = '' then upper(@a)
                                 else @a
                             end;
    END;

    -- Output @word when you reach the end of the word or the end of the input. Capitalize acronymns.
    IF @x = LEN(@in) OR @a NOT LIKE '[a-z]'
    BEGIN 
        SET @out = @out + CASE 
                              WHEN @word IN ( 'ID') THEN UPPER(@word)
                              ELSE @word
                          END;
        SET @word = '';
    END;

    -- Add non-word characters to @word.
    IF @a NOT LIKE '[a-z]'
    BEGIN
        SET @out = @out + @a;
    END;

    SET @x += 1;
END;


--SELECT @out = REPLACE(REPLACE(REPLACE(@out, StringToReplace, ReplacementString), CHAR(13), ''), CHAR(10), '')
--  FROM ColumnNameReplaceMap

-- Use the original case if nothing has changed.
IF LEN(@out) = LEN(@in) AND @out = @in 
SET @out = @in;

-- Capitalize id at the end of the input. Do not capitalize ID in Bid.
IF SUBSTRING(@out, LEN(@out) - 1, 2) = 'Id' 
    AND SUBSTRING(@out, LEN(@out) - 2, 1) NOT IN ('B')
BEGIN 
    SET @out = STUFF(@out, (LEN(@out) - 1), 2, UPPER(SUBSTRING(@out, LEN(@out) - 1, 2)));
END;

SET @out = QUOTENAME(@out)

-- Replace 1St with 1st.
IF CHARINDEX('1st ', @in) <> 0
SET @out = REPLACE(@out, '1St', '1st');

RETURN @out

END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_extractInteger]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_extractInteger](@string VARCHAR(2000))
    RETURNS VARCHAR(2000)
AS
BEGIN
    DECLARE @count int
    DECLARE @intNumbers VARCHAR(1000)
    SET @count = 0
    SET @intNumbers = ''

    WHILE @count <= LEN(@string)
    BEGIN 
        IF SUBSTRING(@string, @count, 1)>='0' and SUBSTRING (@string, @count, 1) <='9'
            BEGIN
                SET @intNumbers = @intNumbers + SUBSTRING (@string, @count, 1)
            END
        SET @count = @count + 1
    END
    RETURN @intNumbers
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_findNthOccurance]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_findNthOccurance]
(
@TargetStr varchar(8000), 
@SearchedStr varchar(8000), 
@Occurrence int
)

RETURNS int

as
begin

declare @pos int, @counter int, @ret int

set @pos = CHARINDEX(@TargetStr, @SearchedStr)
set @counter = 1

if @Occurrence = 1 set @ret = @pos

else
begin

while (@counter < @Occurrence)
begin

select @ret = CHARINDEX(@TargetStr, @SearchedStr, @pos + 1)
	
set @counter = @counter + 1

set @pos = @ret

end

end

RETURN(@ret)

end
GO
/****** Object:  UserDefinedFunction [dbo].[udf_FormatSSN]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_FormatSSN]
/* Created by Cole Stuart 
*/

(
@ssn int
)
RETURNS int
AS
BEGIN
--declare @ssn varchar(max)= '123-45-6789'
SET @ssn = 



--select 
case
	--when @ssn like '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
	--THEN 1
	WHEN @ssn like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	THEN '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
	else 0
end 

RETURN @ssn
END 
GO
/****** Object:  UserDefinedFunction [dbo].[udf_getAgeFromDOB]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   function [dbo].[udf_getAgeFromDOB](
    @DOB    datetime,
    @PassedDate datetime
)

returns int
as
begin

declare @iMonthDayDob int
declare @iMonthDayPassedDate int


select @iMonthDayDob = CAST(datepart (mm,@DOB) * 100 + datepart  (dd,@DOB) AS int) 
select @iMonthDayPassedDate = CAST(datepart (mm,@PassedDate) * 100 + datepart  (dd,@PassedDate) AS int) 

return DateDiff(yy,@DOB, @PassedDate) 
- CASE WHEN @iMonthDayDob <= @iMonthDayPassedDate
  THEN 0 
  ELSE 1
  END

End
GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetFirstName]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_GetFirstName]  
(  
 @FullName varchar(500)  
)  
RETURNS varchar(500)  
AS  
BEGIN  
 -- Declare the return variable here  
 DECLARE @RetName varchar(500)  

 SET @FullName = replace( replace( replace( replace( @FullName, '.', '' ), 'Mrs', '' ), 'Ms', '' ), 'Mr', '' )  

 SELECT   
  @RetName =   
    CASE WHEN charindex( ' ', ltrim( rtrim( @FullName ) ) ) > 0 THEN left( ltrim( rtrim( @FullName ) ), charindex( ' ', ltrim( rtrim( @FullName  ) ) ) - 1 ) ELSE '' END  

 RETURN @RetName  
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetLastName]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_GetLastName]  
(  
 @FullName varchar(500)  
)  
RETURNS varchar(500)  
AS  
BEGIN  
 DECLARE @RetName varchar(500)  

 IF(right(ltrim(rtrim(@FullName)), 2) < > ' I')  
 BEGIN  
  set @RetName = left(   
   CASE WHEN   
    charindex( ' ', reverse( ltrim( rtrim(   
    replace( replace( replace( replace( replace( replace( @FullName, ' Jr', '' ), ' III', '' ), ' II', '' ), ' Jr.', '' ), ' Sr', ''), 'Sr.', '')  
    ) ) ) ) > 0   
   THEN   
    right( ltrim( rtrim(   
    replace( replace( replace( replace( replace( replace( @FullName, ' Jr', '' ), ' III', '' ), ' II', '' ), ' Jr.', '' ), ' Sr', ''), 'Sr.', '')  
    ) ) , charindex( ' ', reverse( ltrim( rtrim(   
    replace( replace( replace( replace( replace( replace( @FullName, ' Jr', '' ), ' III', '' ), ' II', '' ), ' Jr.', '' ), ' Sr', ''), 'Sr.', '')  
    ) ) )  ) - 1 )   
   ELSE '' END  
  , 25 )  
 END  
 ELSE  
 BEGIN  
  SET @RetName = left(   
   CASE WHEN   
    charindex( ' ', reverse( ltrim( rtrim(   
    replace( replace( replace( replace( replace( replace( replace( @FullName, ' Jr', '' ), ' III', '' ), ' II', '' ), ' I', '' ), ' Jr.', '' ), ' Sr', ''), 'Sr.', '')  
    ) ) ) ) > 0   
   THEN   
    right( ltrim( rtrim(   
    replace( replace( replace( replace( replace( replace( replace( @FullName, ' Jr', '' ), ' III', '' ), ' II', '' ), ' I', '' ), ' Jr.', '' ), ' Sr', ''), 'Sr.', '')  
    ) ) , charindex( ' ', reverse( ltrim( rtrim(   
    replace( replace( replace( replace( replace( replace( replace( @FullName, ' Jr', '' ), ' III', '' ), ' II', '' ), ' I', '' ), ' Jr.', '' ), ' Sr', ''), 'Sr.', '')  
    ) ) )  ) - 1 )   
   ELSE '' END  
  , 25 )  
 END  

 RETURN @RetName  
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetSplitString]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

    Added "Set @List = " to replace &, < and > so the this does not error with "XML parsing: line 1, character 1203, illegal name character".

    Test with:
    select dbo.udf_GetSplitString('Date & Such,Account <ID,Account >Label,Campaign ID,Some % of some',',',1)

    Removed code to replace & < and >. This effects code that joins by name in usp_METAL1_FileToStage1MAIN.


*/

CREATE   FUNCTION [dbo].[udf_GetSplitString]
(
   @List       VARCHAR(MAX),
   @Delimiter  VARCHAR(255),
   @ElementNumber INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

       DECLARE @xml XML;

       SET @xml = '<split><el>' + REPLACE(@list,@Delimiter,'</el><el>') + '</el></split>'

       DECLARE @ret VARCHAR(MAX)
       SET @ret = (SELECT
              el = split.el.value('.','varchar(max)')
       FROM  @xml.nodes('/split/el[string-length(.)>0][position() = sql:variable("@elementnumber")]') split(el))

       RETURN @ret

END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_getTranslationRuleLGMKeys]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_getTranslationRuleLGMKeys]
(
    @string_rule varchar(max)
)  
RETURNS @ReturnValue TABLE 
(
    Id INT IDENTITY(1,1),
	lgm_key int,
	trans_rule varchar(max)
  
) 
AS  
BEGIN 

declare @totalOc int 
declare @counter int = 0
declare @assignNumber varchar(20)
declare @remainder varchar(max)
declare @beginNumberIndex int
declare @endNumberIndex int

set @totalOc =(
select (len(@string_rule) - len(replace(replace( @string_rule,'{',''),'}','')))/2)
set @remainder = @string_rule

While @counter < @totalOc
begin
	
	set @beginNumberIndex = (select charindex('{',@remainder))
	--select @beginNumberIndex
	set @endNumberIndex = (select charindex('}',@remainder,@beginNumberIndex)-1)
--	select @endNumberIndex
	set @assignNumber = (select substring(@remainder,@beginNumberIndex+1,@endNumberIndex-@beginNumberIndex))
	insert into @ReturnValue (lgm_key,trans_rule) select @assignNumber,@string_rule
	--select @assignNumber assignNumber
	set @remainder = (select substring(@remainder,@endNumberIndex+2,len(@remainder)-(@endNumberIndex+1)))
	--select @remainder remainder
	set @counter = @counter + 1

end


    RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_mapStringAsciiValues]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_mapStringAsciiValues]
(
      @String NVARCHAR(MAX)
	, @StringLen BIGINT
)  
RETURNS @ReturnValue TABLE 
(
    Id INT IDENTITY(1,1),
    Data NVARCHAR(MAX),
	AsciiCode BIGINT
) 
AS  
BEGIN 
	DECLARE 
		  @Counter INT
		, @Code BIGINT
    SET @Counter = 1
	

    WHILE @Counter <= @StringLen
    BEGIN
        INSERT INTO @ReturnValue (data,Asciicode)
        SELECT 
              Data = SUBSTRING(@String,@counter, 1)
			, AsciiCode = ASCII(SUBSTRING(@String,@counter, 1))

        --SET @String = SUBSTRING(@String,@counter,2)
		--SET @code = ASCII(SUBSTRING(@String,@counter, 1))
        SET @Counter = @Counter + 1
    END

    --INSERT INTO @ReturnValue (data,Asciicode)
    --SELECT Data = LTRIM(RTRIM(@String)), ASCII(@String)

    RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_ParseValues]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_ParseValues]
(@String varchar(8000), @Delimiter varchar(10) )
RETURNS @RESULTS TABLE (ID int identity(1,1), Val varchar(8000))
AS
BEGIN
DECLARE @Value varchar(100)
WHILE @String is not null
BEGIN
SELECT @Value=CASE WHEN PATINDEX('%'+@Delimiter+'%',@String) >0 THEN LEFT(@String,PATINDEX('%'+@Delimiter+'%',@String)-1) ELSE @String END
, @String=CASE WHEN PATINDEX('%'+@Delimiter+'%',@String) >0 THEN SUBSTRING(@String,PATINDEX('%'+@Delimiter+'%',@String)+LEN(@Delimiter),LEN(@String)) ELSE NULL END
INSERT INTO @RESULTS (Val)
SELECT @Value
END
RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_RemoveAllNonAlphaNumerics]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_RemoveAllNonAlphaNumerics]
(
    @string VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @_invalidFileNameRegStr VARCHAR(255) = '%[^-a-z0-9. _~()]%'
	DECLARE @pos INT

	SET @string = REPLACE(@string,'&','_and_')
	SET @string = REPLACE(@string,'#','no')
	SET @string = REPLACE(@string,'.','')
	SET @string = REPLACE(REPLACE(@string,'(',''),')','')

	WHILE PATINDEX(@_invalidFileNameRegStr,@string) > 0
	BEGIN
		SET @pos = PATINDEX(@_invalidFileNameRegStr,@string)
		SET @string = REPLACE(@string,SUBSTRING(@string,@pos,1),'')
	END
	set @string = replace(replace(@string,'-',''),' ','')
	RETURN @string
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_ReplaceHexCharacters]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_ReplaceHexCharacters]
(
    @string VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	/* CONTROL CHARACTERS */
	DECLARE
		@null_byte VARCHAR(1) = CHAR(0),
		@start_of_heading VARCHAR(1) = CHAR(1),
		@start_of_text VARCHAR(1) = CHAR(2),
		@end_of_text VARCHAR(1) = CHAR(3),
		@end_of_transmission VARCHAR(1) = CHAR(4),
		@enquiry VARCHAR(1) = CHAR(5),
		@acknowledge VARCHAR(1) = CHAR(6),
		@ring_terminal_bell VARCHAR(1) = CHAR(7),
		@backspace VARCHAR(1) = CHAR(8),
		@horizontal_tab VARCHAR(1) = CHAR(9),
		@line_feed VARCHAR(1) = CHAR(10),
		@vertical_tab VARCHAR(1) = CHAR(11),
		@form_feed VARCHAR(1) = CHAR(12),
		@carriage_return VARCHAR(1) = CHAR(13),
		@shift_out VARCHAR(1) = CHAR(14),
		@shift_in VARCHAR(1) = CHAR(15)

	SET @string = REPLACE(@string,'\x00',@null_byte)
	SET @string = REPLACE(@string,'\x01',@start_of_heading)
	SET @string = REPLACE(@string,'\x02',@start_of_text)
	SET @string = REPLACE(@string,'\x03',@end_of_text)
	SET @string = REPLACE(@string,'\x04',@end_of_transmission)
	SET @string = REPLACE(@string,'\x05',@enquiry)
	SET @string = REPLACE(@string,'\x06',@acknowledge)
	SET @string = REPLACE(@string,'\x07',@ring_terminal_bell)
	SET @string = REPLACE(@string,'\x08',@backspace)
	SET @string = REPLACE(@string,'\x09',@horizontal_tab)
	SET @string = REPLACE(@string,'\x0A',@line_feed)
	SET @string = REPLACE(@string,'\x0B',@vertical_tab)
	SET @string = REPLACE(@string,'\x0C',@form_feed)
	SET @string = REPLACE(@string,'\x0D',@carriage_return)
	SET @string = REPLACE(@string,'\x0E',@shift_out)
	SET @string = REPLACE(@string,'\x0F',@shift_in)

	RETURN @string
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_SplitFullNameString]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_SplitFullNameString] 
( 
    @sname NVARCHAR(MAX), 
    @myformat varchar(50) ='Lastname,Suffix,Salutation,Firstname'
) 
RETURNS @output TABLE
(Fullname NVARCHAR(MAX),Firstname NVARCHAR(MAX), Lastname NVARCHAR(MAX))
as
BEGIN
set @sname = replace(replace(replace(@sname,'.',','),'"',''),',,',',')
set @sname = case when RIGHT(@sname,1) =',' then substring(@sname,1,len(@sname)-1)
				else @sname end
insert into @output
select 	@sname Fullname,
		case when charindex(' ',case when charindex(' ',PARSENAME (replace(@sname,',','.'),1))>0 then SUBSTRING(PARSENAME (replace(@sname,',','.'),1),2,len(PARSENAME (replace(@sname,',','.'),1))-1) 
			else PARSENAME (replace(@sname,',','.'),1) end ,1) > 0 then
		substring(case when charindex(' ',PARSENAME (replace(@sname,',','.'),1))>0 then SUBSTRING(PARSENAME (replace(@sname,',','.'),1),2,len(PARSENAME (replace(@sname,',','.'),1))-1) 
			else PARSENAME (replace(@sname,',','.'),1) end,1,charindex(' ',case when charindex(' ',PARSENAME (replace(@sname,',','.'),1))>0 then SUBSTRING(PARSENAME (replace(@sname,',','.'),1),2,len(PARSENAME (replace(@sname,',','.'),1))-1) 
			else PARSENAME (replace(@sname,',','.'),1) end ,1)) 
			else case when charindex(' ',PARSENAME (replace(@sname,',','.'),1))>0 then SUBSTRING(PARSENAME (replace(@sname,',','.'),1),2,len(PARSENAME (replace(@sname,',','.'),1))-1) 
			else PARSENAME (replace(@sname,',','.'),1) end end	Firstname,
					  
		case when PARSENAME (replace(@sname,',','.'),4) is not null and PARSENAME (replace(@sname,',','.'),3) is not null  then 
							concat(PARSENAME (replace(@sname,',','.'),4),',',PARSENAME (replace(@sname,',','.'),3))
			when PARSENAME (replace(@sname,',','.'),4) is  null and PARSENAME (replace(@sname,',','.'),3) is not null then PARSENAME (replace(@sname,',','.'),3) 
			when  PARSENAME (replace(@sname,',','.'),4) is  null and PARSENAME (replace(@sname,',','.'),3) is  null then PARSENAME (replace(@sname,',','.'),2)  end Lastname
 
 RETURN
     
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_trySQLBlock]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_trySQLBlock] (
	@DebugFlag BIT,
	@FVProductionPrefix NVARCHAR(MAX),
	@ProcName NVARCHAR(MAX),
	@StepName NVARCHAR(MAX),
	@DatabaseBrackets NVARCHAR(MAX),
	@SPObject NVARCHAR(MAX),
	@SQL_INSERT NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @SQL_AUDIT_SETUP NVARCHAR(MAX),
			@SQL_TRY NVARCHAR(MAX),
			@SQL_CATCH NVARCHAR(MAX),
			@SQL_FULL_STATEMENT NVARCHAR(MAX);

	DECLARE	@NewLine	CHAR(2) = CHAR(13) + CHAR(10)

	/* SQL AUDIT STATEMENT */
	SET  @SQL_AUDIT_SETUP = N'
	USE '+@DatabaseBrackets+' ' +CAST(@NewLine AS NVARCHAR(MAX))+ '
		
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @ProcName	 VARCHAR(200) = ''' +@ProcName+ ''',
			@StepName	 VARCHAR(100) = '''+@StepName+''',
			@SubStepName VARCHAR(250)= ''SQL: ' + @FVProductionPrefix + '_' + @SPObject + ''',
			@NewLine	CHAR(2) = CHAR(13) + CHAR(10),
			@DebugFlag   BIT = '+CONVERT(NVARCHAR(MAX),@DebugFlag) +'

	DECLARE @ErrorMsg   NVARCHAR(2048) = N'''',
			@ErrorCode  INT = 0;
	DECLARE @totalNumberofProjectTypes int = 0,
			@countProject int = 0,
			@ProjectTypeName varchar(50) =''''

	BEGIN
		SET @sql = N'''
	
	/* SQL TRY STATEMENT */
	SET @SQL_TRY = N'''
	BEGIN TRY
		set @sql = N' + @SQL_INSERT + ' 
		IF @DebugFlag = 0		
			EXEC sp_executesql @sql
		ELSE
			select ' + @SQL_INSERT + '
		EXEC Filevine_META.[dbo].[migration_update_process_status] '''+@DatabaseBrackets+''',@ProcName, @StepName, @SubStepName, ''COMPLETE'', @@ROWCOUNT, @ErrorCode, @ErrorMsg; 
	END TRY
	'

	/* SQL CATCH STATEMENT */			
	SET @SQL_CATCH = '
	BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();
		SET @ErrorMsg = N''!!!!ERROR - FAILED to ''+@sql + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);
		EXEC Filevine_META.[dbo].[migration_update_process_status] '''+@DatabaseBrackets+''',@ProcName, @StepName, @SubStepName, ''FAILED'', @@ROWCOUNT, @ErrorCode, @ErrorMsg; 
		SET @ErrorCode=0
		SET @ErrorMsg=N''''
	END CATCH
	END
	'
		
	SET @SQL_FULL_STATEMENT = CONCAT(@SQL_AUDIT_SETUP, @SQL_TRY, @SQL_CATCH)

	RETURN @SQL_FULL_STATEMENT

END
GO
/****** Object:  UserDefinedFunction [dbo].[udfDate_ClarionDate]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udfDate_ClarionDate]
(
    @date VARCHAR(255)
	,@time VARCHAR(255) = 1
)
RETURNS DATETIME
AS
BEGIN
    DECLARE @Result DATETIME
	DECLARE @ActualDate DATETIME

	IF ISNUMERIC(@date) = 1 AND ISNUMERIC(@time) = 1 AND ISDATE(CONVERT(VARCHAR(25),CAST(CAST(@date AS INT) AS DATETIME),120)) = 1
		BEGIN
			SET @ActualDate = CONVERT(VARCHAR(25),CAST(CAST((@date-36163) AS INT) AS DATETIME),120)
			SET @Result = DATEADD(MS, (@time-1)*10,@ActualDate)
		END
	ELSE
		SET @Result = NULL

	RETURN @Result
END
GO
/****** Object:  UserDefinedFunction [dbo].[udfDate_ConvertUTC]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udfDate_ConvertUTC]
(
    @ActualDate DATETIME, /* Datetime to evaluate */
	@TimeZone VARCHAR(50), /* pacific, mountain, central, eastern, atlantic */
	@useDST BIT = 1 /* Toggle observance of daylight savings time */
)
RETURNS DATETIME
AS
BEGIN

	DECLARE
		@Result DATETIME,
		@Year INT = DATEPART(YEAR,@ActualDate),
		@DstStart DATETIME,
		@DstEnd DATETIME,
		@Adjust int

	IF @ActualDate < '03-11-2007'
		BEGIN
			DECLARE
				@StartOfApril DATETIME ,
				@StartOfOctober DATETIME 

			SET @StartOfApril = DATEADD(MONTH, 3, DATEADD(YEAR, @Year - 1900, 0))
			SET @StartOfOctober = DATEADD(MONTH, 9, DATEADD(YEAR, @Year - 1900, 0));
			SET @DstStart = DATEADD(HOUR, 2, DATEADD(day, ( ( 15 - DATEPART(dw, @StartOfApril) ) % 7 ) + 7, @StartOfApril))
			SET @DstEnd = DATEADD(HOUR, 2,DATEADD(day,DATEDIFF(day,@StartOfOctober,DATEADD(month,DATEDIFF(MONTH,0,@StartOfOctober),30))/7*7,@StartOfOctober))
		END
	ELSE
		BEGIN
			DECLARE
				@StartOfMarch DATETIME ,
				@StartOfNovember DATETIME 

			SET @StartOfMarch = DATEADD(MONTH, 2, DATEADD(YEAR, @Year - 1900, 0))
			SET @StartOfNovember = DATEADD(MONTH, 10, DATEADD(YEAR, @Year - 1900, 0));
			SET @DstStart = DATEADD(HOUR, 2, DATEADD(day, ( ( 15 - DATEPART(dw, @StartOfMarch) ) % 7 ) + 7, @StartOfMarch))
			SET @DstEnd = DATEADD(HOUR, 2, DATEADD(day, ( ( 8 - DATEPART(dw, @StartOfNovember) ) % 7 ), @StartOfNovember))
		END

	--Zone conversion
	DECLARE @Zone INT = 0
	SELECT @Zone =
		CASE lower(@TimeZone)
			WHEN 'atlantic' THEN 3
			WHEN 'eastern' THEN 4
			WHEN 'central' THEN 5
			WHEN 'mountain' THEN 6
			WHEN 'pacific' THEN 7
			ELSE 0
		END 

	IF @ActualDate BETWEEN @DstStart AND @DstEnd AND @useDST = 1
		SET @Adjust = @Zone
	ELSE
		SET @Adjust = @Zone + 1

	SET @Result = DATEADD(HOUR,@adjust,@ActualDate);

	RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[udfExtractEmail]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jim Cobb
-- Create date: 4/11/2022
-- Description:	Extracts Email from String - Returns NULL if no email found
-- =============================================
CREATE FUNCTION [dbo].[udfExtractEmail]
(
    @input nvarchar(500)
)
RETURNS nvarchar(100)
AS
BEGIN
    DECLARE @atPosition int
    DECLARE @firstRelevantSpace int
    DECLARE @name nvarchar(100)
    DECLARE @secondRelelvantSpace int
    DECLARE @everythingAfterAt nvarchar(500)
    DECLARE @domain nvarchar(100)
    DECLARE @email nvarchar(100) = ''
    IF CHARINDEX('@', @input,0) > 0
    BEGIN
        SET @input = ' ' + @input
        SET @atPosition = CHARINDEX('@', @input, 0)
        SET @firstRelevantSpace = CHARINDEX(' ',REVERSE(LEFT(REPLACE(@input,'-',' '), CHARINDEX('@', @input, 0) - 1)))
        SET @name = REVERSE(LEFT(REVERSE(LEFT(@input, @atPosition - 1)),@firstRelevantSpace-1))
        SET @everythingAfterAt = SUBSTRING(@input, @atPosition,len(@input)-@atPosition+1)
        SET @secondRelelvantSpace = CHARINDEX(' ',@everythingAfterAt)
        IF @secondRelelvantSpace = 0
            SET @domain = @everythingAfterAt
        ELSE
            SET @domain = LEFT(@everythingAfterAt, @secondRelelvantSpace)
        SET @email = TRIM(REPLACE(REPLACE(@name + @domain, '(',''),')',''))
    END
    RETURN @email
END
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetStateAbbreviation]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfGetStateAbbreviation]
(
@name varchar(50)
)
RETURNS varchar(2)
AS
BEGIN
DECLARE @abbr varchar(2)
SELECT  @abbr = (select abbreviation from stateLookup where [Name] = @name)

if LEN(replace(@name,' ','')) > 2
SET @abbr = @abbr
if LEN(replace(@name,' ','')) = 2
SET @abbr = @name
if LEN(replace(@name,' ','')) < 2
SET @abbr = NULL


RETURN @abbr
END
GO
/****** Object:  UserDefinedFunction [dbo].[udfIsSSN]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfIsSSN]
/* Created by Cole Stuart 
*/

(
@ssn varchar(MAX)
)
RETURNS varchar(MAX)
AS
BEGIN
--declare @ssn varchar(max)= '123-45-6789'
SET @ssn = 



--select 
case
	when @ssn like '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
	then 1
	else 0
end 

RETURN TRIM(@ssn)
END 
GO
/****** Object:  UserDefinedFunction [dbo].[udfReplaceAscii]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udfReplaceAscii]
/* Created by Jim Cobb 
sandbox_jc.[dbo].[udfReplaceAscii]
*/

(
@str varchar(MAX)
)
RETURNS varchar(MAX)
AS
BEGIN
SET @str = 

TRIM(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
              (@str, '\001',' '),'\002',' '),'\003',' '),'\005',' '),'\009',' '),'\010',CHAR(10)),'\013',CHAR(13)),'\027',' '),'\030',' '),'\034','"'),
					'\044',','),'\092','\'),'\128',' '),'\129',' '),'\130',' '),'\131',' '),'\132',' '),'\133',' '),'\134',' '),'\136',' '),
					'\137',' '),'\139',' '),'\140',' '),'\141',' '),'\142',' '),'\143',' '),'\144',' '),'\145',' '),'\146',' '),'\147',' '),
					'\148',' '),'\149',' '),'\150',' '),'\151',' '),'\152',' '),'\153',' '),'\154',' '),'\155',' '),'\156',' '),'\157',' '),
					'\158',' '),'\159',' '),'\160',' '),'\161','¡'),'\162','¢'),'\164','¤'),'\165','¥'),'\166','¦'),'\167','§'),'\168','¨'),
					'\169','©'),'\170','ª'),'\171','«'),'\172','¬'),'\173',' '),'\174','®'),'\175','¯¯'),'\176','°'),'\177','±'),'\179','³'),
					'\180','´'),'\182','¶'),'\183','·'),'\184','¸'),'\185','¹'),'\186','º'),'\187','»'),'\188','¼'),'\189','½'),'\190','¾'),
					'\191','¿'),'\194','Â'),'\195','Ã'),'\196','Ä'),'\197','Å'),'\198','Æ'),'\201','É'),'\208','Ð'),'\215','×'),'\216','Ø'),
					'\217','Ù'),'\224','à'),'\225','á'),'\226','â'),'\227','ã'),'\230','æ'),'\232','è'),'\233','é'),'\235','ë'),'\238','î'),
					'\237','í'),'\236','ì'),'\239','ï'),'\240','ð'),'\241','ñ'),'\243','ó'),'\253','ý'),'\135',' '),'\138',' '),'\163','£'),
					'\178','²'),'\181','µ'),'\203','Ë'),'\206','Î'),'\207','Ï'),'\209','Ñ'),'\229','å'),'\231','ç'),'\234','ê'),'\236','ì'),
					'\246','ö'),'\250','ú'),'\213','Õ'),'\228','ä'),'\247','÷'),'\249','ù'),'\192','À'),'\200','È'),'\221','Ý'),'\222','Þ')
					)

RETURN LTRIM(RTRIM(@str))
END 
GO
/****** Object:  UserDefinedFunction [dbo].[udfReplaceRTF]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[udfReplaceRTF]
/* Created by Cole Stuart
sandbox_jc.[dbo].[udfReplaceAscii]
*/

(
@str varchar(MAX)
)
RETURNS varchar(MAX)
AS
BEGIN
SET @str = 

TRIM(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
              (@str,'\''20',' '),'\''21','!'),'\''22','"'),'\''23','#'),'\''24','$'),'\''25','%'),'\''26','&'),'\''27',''''),'\''28','('),'\''29',')')
			  ,'\''2a','*'),'\''2b','+'),'\''2c',','),'\''2d','-'),'\''2e','.'),'\''2f','/'),'\''30','0'),'\''31','1'),'\''32','2'),'\''33','3'),'\''34','4')
			  ,'\''35','5'),'\''36','6'),'\''37','7'),'\''38','8'),'\''39','9'),'\''3a',':'),'\''3b',';'),'\''3c','<'),'\''3d','='),'\''3e','>'),'\''3f','?')
			  ,'\''40','@'),'\''5b','['),'\''5c','\'),'\''5d',']'),'\''5e','^'),'\''5f','_'),'\''60','`'),'\''7b','{'),'\''7c','|'),'\''7d','}'),'\''7e','`')
			  ,'\''7f',''),'\''80',''),'\''81',''),'\''82','͵'),'\''83','ƒ'),'\''84',',,'),'\''85','...'),'\''86','†'),'\''87','‡'),'\''88','∘'),'\''89','‰')
			  ,'\''8a','Š'),'\''8b','‹'),'\''8c','Œ'),'\''8d',''),'\''8e','Ž'),'\''8f',''),'\''90',''),'\''91','‘'),'\''92','’'),'\''93','“'),'\''94','”')
			  ,'\''95','•'),'\''96','–'),'\''97','—'),'\''98','~'),'\''99','™'),'\''9a','š'),'\''9b','›'),'\''9c','œ'),'\''9d',''),'\''9e','ž'),'\''9f','Ÿ')
			  ,'\''a1','¡'),'\''a2','¢'),'\''a3','£'),'\''a4','¤'),'\''a5','¥'),'\''a6','¦'),'\''a7','§'),'\''a8','¨'),'\''a9','©'),'\''aa','ª'),'\''ab','«')
			  ,'\''ac','¬')
					)

RETURN LTRIM(RTRIM(@str))
END 
GO
/****** Object:  UserDefinedFunction [dbo].[udfStripHTML]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfStripHTML]
/* Created by Jim Cobb 
inspired by http://stackoverflow.com/questions/457701/best-way-to-strip-html-tags-from-a-string-in-sql-server/39253602#39253602
*/

(
@HTMLText varchar(MAX)
)
RETURNS varchar(MAX)
AS
BEGIN
DECLARE @Start  int
DECLARE @End    int
DECLARE @Length int

set @HTMLText = replace(@htmlText, '<br>',CHAR(13) + CHAR(10))
set @HTMLText = replace(@htmlText, '<br/>',CHAR(13) + CHAR(10))
set @HTMLText = replace(@htmlText, '<br />',CHAR(13) + CHAR(10))
set @HTMLText = replace(@htmlText, '<li>','- ')
set @HTMLText = replace(@htmlText, '</li>',CHAR(13) + CHAR(10))

set @HTMLText = replace(@htmlText, '&rsquo;' collate Latin1_General_CS_AS, ''''  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&quot;' collate Latin1_General_CS_AS, '"'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&amp;' collate Latin1_General_CS_AS, '&'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&euro;' collate Latin1_General_CS_AS, '€'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&lt;' collate Latin1_General_CS_AS, '<'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&gt;' collate Latin1_General_CS_AS, '>'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&oelig;' collate Latin1_General_CS_AS, 'oe'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&nbsp;' collate Latin1_General_CS_AS, ' '  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&copy;' collate Latin1_General_CS_AS, '©'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&laquo;' collate Latin1_General_CS_AS, '«'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&reg;' collate Latin1_General_CS_AS, '®'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&plusmn;' collate Latin1_General_CS_AS, '±'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&sup2;' collate Latin1_General_CS_AS, '²'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&sup3;' collate Latin1_General_CS_AS, '³'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&micro;' collate Latin1_General_CS_AS, 'µ'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&middot;' collate Latin1_General_CS_AS, '·'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&ordm;' collate Latin1_General_CS_AS, 'º'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&raquo;' collate Latin1_General_CS_AS, '»'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&frac14;' collate Latin1_General_CS_AS, '¼'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&frac12;' collate Latin1_General_CS_AS, '½'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&frac34;' collate Latin1_General_CS_AS, '¾'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&Aelig' collate Latin1_General_CS_AS, 'Æ'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&Ccedil;' collate Latin1_General_CS_AS, 'Ç'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&Egrave;' collate Latin1_General_CS_AS, 'È'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&Eacute;' collate Latin1_General_CS_AS, 'É'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&Ecirc;' collate Latin1_General_CS_AS, 'Ê'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&Ouml;' collate Latin1_General_CS_AS, 'Ö'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&agrave;' collate Latin1_General_CS_AS, 'à'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&acirc;' collate Latin1_General_CS_AS, 'â'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&auml;' collate Latin1_General_CS_AS, 'ä'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&aelig;' collate Latin1_General_CS_AS, 'æ'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&ccedil;' collate Latin1_General_CS_AS, 'ç'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&egrave;' collate Latin1_General_CS_AS, 'è'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&eacute;' collate Latin1_General_CS_AS, 'é'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&ecirc;' collate Latin1_General_CS_AS, 'ê'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&euml;' collate Latin1_General_CS_AS, 'ë'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&icirc;' collate Latin1_General_CS_AS, 'î'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&ocirc;' collate Latin1_General_CS_AS, 'ô'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&ouml;' collate Latin1_General_CS_AS, 'ö'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&divide;' collate Latin1_General_CS_AS, '÷'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&oslash;' collate Latin1_General_CS_AS, 'ø'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&ugrave;' collate Latin1_General_CS_AS, 'ù'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&uacute;' collate Latin1_General_CS_AS, 'ú'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&ucirc;' collate Latin1_General_CS_AS, 'û'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&uuml;' collate Latin1_General_CS_AS, 'ü'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&quot;' collate Latin1_General_CS_AS, '"'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&amp;' collate Latin1_General_CS_AS, '&'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&lsaquo;' collate Latin1_General_CS_AS, '<'  collate Latin1_General_CS_AS)
set @HTMLText = replace(@htmlText, '&rsaquo;' collate Latin1_General_CS_AS, '>'  collate Latin1_General_CS_AS)


-- Remove anything between <STYLE> tags
SET @Start = CHARINDEX('<STYLE', @HTMLText)
SET @End = CHARINDEX('</STYLE>', @HTMLText, CHARINDEX('<', @HTMLText)) + 7
SET @Length = (@End - @Start) + 1

WHILE (@Start > 0 AND @End > 0 AND @Length > 0) BEGIN
SET @HTMLText = STUFF(@HTMLText, @Start, @Length, '')
SET @Start = CHARINDEX('<STYLE', @HTMLText)
SET @End = CHARINDEX('</STYLE>', @HTMLText, CHARINDEX('</STYLE>', @HTMLText)) + 7
SET @Length = (@End - @Start) + 1
END

-- Remove anything between <whatever> tags
SET @Start = CHARINDEX('<', @HTMLText)
SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
SET @Length = (@End - @Start) + 1

WHILE (@Start > 0 AND @End > 0 AND @Length > 0) BEGIN
SET @HTMLText = STUFF(@HTMLText, @Start, @Length, '')
SET @Start = CHARINDEX('<', @HTMLText)
SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
SET @Length = (@End - @Start) + 1
END

RETURN LTRIM(RTRIM(@HTMLText))

END
GO
/****** Object:  UserDefinedFunction [mycase].[udf_getClientFromCaseContact]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        <Author,,Name>
-- Create date: <Create Date, ,>
-- Description:    <Description, ,>
-- =============================================
CREATE   FUNCTION [mycase].[udf_getClientFromCaseContact]
(
    -- Add the parameters for the function here
    @contactString    varchar(max)
)
RETURNS varchar(max)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @ResultVar varchar(max)
    set @ResultVar = (
select 
substring(
replace(substring(@contactString,(charindex('(client)',@contactString,1)+8-charindex('(', reverse(@contactString), (charindex('(', reverse(@contactString), 1))+1)),charindex('(', reverse(@contactString), (charindex('(', reverse(@contactString), 1))+1)),' (client)',''),
case when
charindex(')',
replace(substring(@contactString,(charindex('(client)',@contactString,1)+8-charindex('(', reverse(@contactString), (charindex('(', reverse(@contactString), 1))+1)),charindex('(', reverse(@contactString), (charindex('(', reverse(@contactString), 1))+1)),' (client)','')) = 0 then 2
    else charindex(')',
replace(substring(@contactString,(charindex('(client)',@contactString,1)+8-charindex('(', reverse(@contactString), (charindex('(', reverse(@contactString), 1))+1)),charindex('(', reverse(@contactString), (charindex('(', reverse(@contactString), 1))+1)),' (client)','')) +2 end,
len(replace(substring(@contactString,(charindex('(client)',@contactString,1)+8-charindex('(', reverse(@contactString), (charindex('(', reverse(@contactString), 1))+1)),charindex('(', reverse(@contactString), (charindex('(', reverse(@contactString), 1))+1)),' (client)',''))))


    
Return @ResultVar
END
GO
/****** Object:  UserDefinedFunction [needles].[udf_getFullName]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [needles].[udf_getFullName] (
    @prefix VARCHAR(255),
    @firstname VARCHAR(255),
    @initial VARCHAR(255),
    @lastname VARCHAR(255),
    @suffix VARCHAR(255),
    @format INT
)
RETURNS VARCHAR(30)
AS
BEGIN
    DECLARE 
        @comma VARCHAR(1) = ',',
        @space VARCHAR(1) = ' ',
        @fullfirst VARCHAR(255) = '',
        @fulllast VARCHAR(255) = '',
        @fullname VARCHAR(255) = '' 

    
    IF @firstname IS NOT NULL
        BEGIN
            SET @fullfirst = ISNULL(@firstname,'')

            IF NULLIF(@prefix,'') IS NOT NULL
                SET @fullfirst = CONCAT(@prefix,@space,@fullfirst)

            IF NULLIF(@initial,'') IS NOT NULL
                SET @fullfirst = CONCAT(@fullfirst,@space,@initial)
        END
    
    IF @lastname IS NOT NULL
        BEGIN
            SET @fulllast = @lastname

            IF NULLIF(@suffix,'') IS NOT NULL
                SET @fulllast = CONCAT(@fulllast,@comma,@space,@suffix)
        END
    
    IF NULLIF(@fullfirst,'') IS NOT NULL
        BEGIN
            IF @format = 1 --Last, First
                SET @fullname = CONCAT(@fulllast,@comma,@space,@fullfirst)
            IF @format = 2 --First Last
                SET @fullname = CONCAT(@fullfirst,@space,@fulllast)
        END
    ELSE
        SET @fullname = @fulllast

    RETURN @fullname
END
GO
/****** Object:  UserDefinedFunction [dbo].[SplitStrings_Ordered]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[SplitStrings_Ordered]
(
    @List       VARCHAR(8000),
    @Delimiter  VARCHAR(255)
)
RETURNS TABLE
AS
    RETURN (SELECT [Index] = ROW_NUMBER() OVER (ORDER BY Number), Item 
    FROM (SELECT Number, Item = SUBSTRING(@List, Number, 
      CHARINDEX(@Delimiter, @List + @Delimiter, Number) - Number)
     FROM (SELECT ROW_NUMBER() OVER (ORDER BY [object_id])
      FROM sys.all_columns) AS n(Number)
      WHERE Number <= CONVERT(INT, LEN(@List))
      AND SUBSTRING(@Delimiter + @List, Number, LEN(@Delimiter)) = @Delimiter
    ) AS y);
GO
/****** Object:  UserDefinedFunction [dbo].[udf_TitleCase]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udf_TitleCase]
(
    @Input nvarchar(MAX),
	@splitdelimiter char(1)
)
RETURNS TABLE
AS
RETURN
SELECT Item = STRING_AGG(splits.Word, @splitdelimiter)
FROM (
    SELECT Word = UPPER(LEFT(value, 1)) + LOWER(RIGHT(value, LEN(value) - 1))
    FROM STRING_SPLIT(@Input, @splitdelimiter)
    ) splits(Word);

GO
/****** Object:  StoredProcedure [dbo].[aaa_jh_FMP_Audit]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[aaa_jh_FMP_Audit]
@LEGACYDB nvarchar(max), @FVProductionPrefix nvarchar(max), @DocsAudit bit = 1, @ListNCLSections bit = 0, @ListCLSections bit = 0
AS
BEGIN	
	IF (SELECT COUNT(*) FROM sys.databases WHERE [NAME] = REPLACE(REPLACE(@LEGACYDB,'[',''),']','')) = 0
	BEGIN
		SELECT 'VERIFY YOUR DATABASE EXISTS'
		RETURN;
	END 

	SELECT @LEGACYDB = CASE 
							WHEN LEFT(@LEGACYDB,1) = '[' AND RIGHT(@LEGACYDB,1) = ']' 
							THEN @LEGACYDB
							ELSE '['+@LEGACYDB+']'
						END 

	DECLARE @SQL NVARCHAR(MAX), @COUNTS INT

	--BREAK SP IF NO TABLES WITH PREFIX EXIST--
	SELECT @SQL = '	
				SELECT @cnt=COUNT(*)
				FROM '+@LegacyDb+'.INFORMATION_SCHEMA.TABLES
				WHERE TABLE_NAME LIKE '''+@FVProductionPrefix+'%'' '
	EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt=@counts OUTPUT
	IF @COUNTS = 0
	BEGIN
		PRINT 'NO TABLES EXIST FOR THIS PREFIX. PLEASE TROUBLESHOOOT'
		RETURN;
	END

	--DB META DATA
	BEGIN		
		DECLARE @CREATEDATE VARCHAR(MAX), @COMPLEVEL VARCHAR(MAX), @COLLATION VARCHAR(MAX)
	
		SELECT @CREATEDATE = CAST(CREATE_DATE AS DATE) FROM SYS.DATABASES WHERE [NAME] = REPLACE(REPLACE(@LEGACYDB,'[',''),']','') 
		SELECT @COMPLEVEL = [COMPATIBILITY_LEVEL] FROM SYS.DATABASES WHERE [NAME] = REPLACE(REPLACE(@LEGACYDB,'[',''),']','')  
		SELECT @COLLATION = [COLLATION_NAME] FROM SYS.DATABASES WHERE [NAME] = REPLACE(REPLACE(@LEGACYDB,'[',''),']','')  

		--DATABASE AGE WARNING
		SELECT 'YOUR DATABASE IS '+CONVERT(VARCHAR(MAX),DATEDIFF(DAY,@CREATEDATE,GETDATE())) +' DAYS OLD' AS '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ALERT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
		
		SELECT 	REPLACE(REPLACE(@LEGACYDB,'[',''),']','') AS 'DATABASE NAME',
				@CREATEDATE AS 'CREATE DATE',
				@COMPLEVEL AS 'COMPATIBILITY LEVEL',
				@COLLATION AS 'COLLATION',
				datename(weekday,@CREATEDATE) as 'DAY OF WEEK THAT DATABASE WAS UPLOADED'
	
	END

	--PROJECTS--
	IF OBJECT_ID(@LegacyDb+'.PT1.PROJECTS') IS NOT NULL
	BEGIN
		SELECT @SQL = ' 
						DECLARE @PROJECT_REPORT TABLE
						(
							[SECTION] NVARCHAR(MAX),
							[COUNT] NVARCHAR(MAX),
							[MAX INCIDENT DATE] NVARCHAR(MAX),
							[MAX CREATE DATE] NVARCHAR(MAX),
							[MISSING PHASE] NVARCHAR(MAX),
							[UNIQUE PHASES] NVARCHAR(MAX),
							[UNIQUE PROJECT TEMPLATES] NVARCHAR(MAX),
							[MISSING INCIDENT DATE] NVARCHAR(MAX),
							[MISSING USERNAME] NVARCHAR(MAX),
							[USERS OUT OF ALIGNMENT] NVARCHAR(MAX)
						)
					
						INSERT INTO @PROJECT_REPORT
						SELECT
						''PROJECTS'',
						(SELECT COUNT(*) AS ''COUNT'' FROM '+@LegacyDb+'.PT1.PROJECTS),
						(SELECT MAX(CAST(INCIDENTDATE AS DATE)) AS ''MAX INCIDENT DATE'' FROM '+@LegacyDb+'.PT1.PROJECTS),
						(SELECT MAX(CAST(CREATEDATE AS DATE)) AS ''MAX CREATE DATE'' FROM '+@LegacyDb+'.PT1.PROJECTS),
						(SELECT COUNT(*) AS ''MISSING PHASE'' FROM '+@LegacyDb+'.PT1.PROJECTS WHERE NULLIF(PHASENAME,'''') IS NULL),
						(SELECT COUNT(DISTINCT PHASENAME) AS ''UNIQUE PHASES'' FROM '+@LegacyDb+'.PT1.PROJECTS WHERE NULLIF(PHASENAME,'''') IS NOT NULL),
						(SELECT COUNT(DISTINCT PROJECTTEMPLATE) AS ''UNIQUE PROJECT TEMPLATES'' FROM '+@LegacyDb+'.PT1.PROJECTS),
						(SELECT COUNT(*) AS ''MISSING INCIDENT DATE'' FROM '+@LegacyDb+'.PT1.PROJECTS WHERE NULLIF([INCIDENTDATE],'''') IS NULL),
						(SELECT COUNT(*) AS ''MISSING USERNAME'' FROM '+@LegacyDb+'.PT1.PROJECTS WHERE NULLIF([USERNAME],'''') IS NULL),
						(SELECT COUNT(*) AS ''USERS OUT OF ALIGNMENT'' FROM '+@LegacyDb+'.PT1.PROJECTS WHERE USERNAME NOT IN (SELECT DISTINCT FV_USERNAME FROM '+@LegacyDb+'.DBO.__FV_USERNAMES))

						SELECT * FROM @PROJECT_REPORT'
		EXEC(@SQL)
	END 
	ELSE
	BEGIN
		SELECT 'VERIFY YOUR PROJECTS TABLE HAS BEEN CREATED' AS ALERT
	END

	--CONTACTS--
	IF OBJECT_ID(@LegacyDb+'.PT1.ContactsCustom__ContactInfo') IS NOT NULL 
	BEGIN
		SELECT @SQL = ' 
						DECLARE @CONTACT_REPORT TABLE
						(
							[SECTION] NVARCHAR(MAX),
							[COUNT] NVARCHAR(MAX),
							[MISSING FIRST NAME] NVARCHAR(MAX),
							[MISSING CONTACT TYPE] NVARCHAR(MAX),
							[INDIVIDUALS] NVARCHAR(MAX),
							[COMPANIES] NVARCHAR(MAX)
						)
					
						INSERT INTO @CONTACT_REPORT
						SELECT
						''CONTACTS'',
						(SELECT COUNT(*) ''COUNT'' FROM '+@LegacyDb+'.[PT1].[ContactsCustom__ContactInfo]),
						(SELECT COUNT(*) AS ''MISSING FIRST NAME'' FROM '+@LegacyDb+'.[PT1].[ContactsCustom__ContactInfo] WHERE NULLIF(FIRSTNAME,'''') IS NULL),
						(SELECT COUNT(*) AS ''MISSING CONTACT TYPE'' FROM '+@LegacyDb+'.[PT1].[ContactsCustom__ContactInfo] WHERE NULLIF(CONTACTTYPELIST,'''') IS NULL),
						(SELECT COUNT(*) AS ''INDIVIDUALS'' FROM '+@LegacyDb+'.[PT1].[ContactsCustom__ContactInfo] WHERE ISSINGLENAME = 0),
						(SELECT COUNT(*) AS ''COMPANIES'' FROM '+@LegacyDb+'.[PT1].[ContactsCustom__ContactInfo] WHERE ISSINGLENAME = 1)

						SELECT * FROM @CONTACT_REPORT'
		EXEC(@SQL)
	END 
	ELSE
	BEGIN
		SELECT 'VERIFY YOUR CONTACTS TABLE HAS BEEN CREATED' AS ALERT
	END

		--PROJECT CONTACTS--
	IF OBJECT_ID(@LegacyDb+'.PT1.ProjectContacts') IS NOT NULL 
	BEGIN
		SELECT @SQL = ' 
						DECLARE @PROJECT_CONTACT_REPORT TABLE
						(
							[SECTION] NVARCHAR(MAX),
							[COUNT] NVARCHAR(MAX),
							[CONTACTS NOT IN CONTACTINFO TABLE] NVARCHAR(MAX),
							[UNIQUE ROLES]  NVARCHAR(MAX)
						)
					
						INSERT INTO @PROJECT_CONTACT_REPORT
						SELECT
						''PROJECT CONTACTS'',
						(SELECT COUNT(*) ''COUNT'' FROM '+@LegacyDb+'.[PT1].[PROJECTCONTACTS]),
						(SELECT COUNT(*) AS ''CONTACTS NOT IN CONTACTINFO TABLE'' FROM '+@LegacyDb+'.[PT1].[PROJECTCONTACTS] WHERE CONTACTEXTERNALID NOT IN (SELECT DISTINCT CONTACTCUSTOMEXTERNALID FROM '+@LegacyDb+'.[PT1].[ContactsCustom__ContactInfo] )),
						(SELECT COUNT(DISTINCT ROLE) AS ''UNIQUE ROLES'' FROM '+@LegacyDb+'.[PT1].[PROJECTCONTACTS])

						SELECT * FROM @PROJECT_CONTACT_REPORT'
		EXEC(@SQL)
	END 
	ELSE
	BEGIN
		SELECT 'VERIFY YOUR PROJECT CONTACTS TABLE HAS BEEN CREATED' AS ALERT
	END

	--NOTES--
	IF OBJECT_ID(@LegacyDb+'.PT1.NOTES') IS NOT NULL
	BEGIN
		SELECT @SQL = ' 
						DECLARE @NOTES_REPORT TABLE
						(
							[SECTION] NVARCHAR(MAX),
							[COUNT] NVARCHAR(MAX),
							[INCOMPLETE TASKS] NVARCHAR(MAX),
							[COMPLETED TASKS] NVARCHAR(MAX),
							[TARGET DATE PRESENT WITHOUT ASSIGNEE] NVARCHAR(MAX),
							[MISSING BODY] NVARCHAR(MAX),
							[AUTHOR MISSING IN USER ALIGNMENT] NVARCHAR(MAX),
							[MINIMUM CREATE DATE] NVARCHAR(MAX),
							[MAXIMUM CREATE DATE] NVARCHAR(MAX)
							
						)				
						INSERT INTO @NOTES_REPORT
						SELECT
						''ACTIVITY'',
						(SELECT COUNT(*) AS ''COUNT'' FROM '+@LegacyDb+'.PT1.NOTES),
						(SELECT COUNT(*) AS ''INCOMPLETE TASKS'' FROM '+@LegacyDb+'.PT1.NOTES WHERE NULLIF(COMPLETEDDATE,'''') IS NULL AND NULLIF(TARGETDATE,'''') IS NOT NULL),
						(SELECT COUNT(*) AS ''COMPLETED TASKS'' FROM '+@LegacyDb+'.PT1.NOTES WHERE NULLIF(COMPLETEDDATE,'''') IS NOT NULL AND NULLIF(TARGETDATE,'''') IS NOT NULL),
						(SELECT COUNT(*) AS ''TARGET DATE PRESENT WITHOUT ASSIGNEE'' FROM '+@LegacyDb+'.PT1.NOTES WHERE NULLIF(TARGETDATE,'''') IS NOT NULL AND NULLIF(ASSIGNEE,'''') IS NULL),
						(SELECT COUNT(*) AS ''RECORDS MISSING BODY'' FROM '+@LegacyDb+'.PT1.NOTES WHERE NULLIF(BODY,'''') IS NULL),
						(SELECT COUNT(*) AS ''AUTHOR MISSING IN USER ALIGNMENT'' FROM '+@LegacyDb+'.PT1.NOTES WHERE AUTHOR NOT IN (SELECT DISTINCT FV_USERNAME FROM '+@LegacyDb+'.DBO.__FV_USERNAMES)),
						(SELECT CAST(MIN(CREATEDATE) AS DATE) AS ''MINIMUM CREATE DATE'' FROM '+@LegacyDb+'.PT1.NOTES),
						(SELECT CAST(MAX(CREATEDATE) AS DATE) AS ''MAXIMUM CREATE DATE'' FROM '+@LegacyDb+'.PT1.NOTES)

						SELECT * FROM @NOTES_REPORT'
		EXEC(@SQL)
	END
	ELSE
	BEGIN
		SELECT 'VERIFY YOUR NOTES TABLE IS MAPPED AND HAS BEEN CREATED' AS ALERT
	END

	--CALENDAR EVENTS--
	IF OBJECT_ID(@LegacyDb+'.PT1.CALENDAREVENTS') IS NOT NULL
	BEGIN
		SELECT @SQL = ' 
						DECLARE @CALENDAR_REPORT TABLE
						(
							[SECTION] NVARCHAR(MAX),
							[COUNT] NVARCHAR(MAX),
							[END DATE BEFORE START DATE] NVARCHAR(MAX),
							[MISSING START DATE] NVARCHAR(MAX),
							[MISSING END DATE] NVARCHAR(MAX),
							[AUTHOR MISSING IN USER ALIGNMENT] NVARCHAR(MAX),
							[EVENTS WITHOUT AUTHOR] NVARCHAR(MAX),
							[EVENTS WITHOUT ATTENDEE] NVARCHAR(MAX),
							[MINIMUM START DATE] NVARCHAR(MAX),
							[MAXIMUM START DATE] NVARCHAR(MAX),
							[MINIMUM END DATE] NVARCHAR(MAX),
							[MAXIMUM END DATE] NVARCHAR(MAX)
						)				
						INSERT INTO @CALENDAR_REPORT
						SELECT
						''CALENDAR'',
						(SELECT COUNT(*) AS ''COUNT'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS),
						(SELECT COUNT(*) AS ''END DATE BEFORE START DATE'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS WHERE ENDDATE < STARTDATE),
						(SELECT COUNT(*) AS ''MISSING START DATE'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS WHERE NULLIF(STARTDATE,'''') IS NULL),
						(SELECT COUNT(*) AS ''MISSING END DATE'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS WHERE NULLIF(ENDDATE,'''') IS NULL),
						(SELECT COUNT(*) AS ''AUTHOR MISSING IN USER ALIGNMENT'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS WHERE AUTHOR NOT IN (SELECT DISTINCT FV_USERNAME FROM '+@LegacyDb+'.DBO.__FV_USERNAMES)),
						(SELECT COUNT(*) AS ''MISSING AUTHOR'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS WHERE NULLIF(AUTHOR,'''') IS NULL),
						(SELECT COUNT(*) AS ''MISSING ATTENDEE'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS WHERE (NULLIF(AttendeeUserCsv,'''') IS NULL AND NULLIF(AttendeeContactCSV,'''') IS NULL)),
						(SELECT CAST(MIN(STARTDATE) AS DATE) AS ''MINIMUM START DATE'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS),
						(SELECT CAST(MAX(STARTDATE) AS DATE) AS ''MAXIMUM START DATE'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS),
						(SELECT CAST(MIN(ENDDATE) AS DATE) AS ''MINIMUM END DATE'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS),
						(SELECT CAST(MAX(ENDDATE) AS DATE) AS ''MINIMUM END DATE'' FROM '+@LegacyDb+'.PT1.CALENDAREVENTS)

						SELECT * FROM @CALENDAR_REPORT'
		EXEC(@SQL)
	END
	ELSE
	BEGIN
		SELECT 'VERIFY YOUR CALENDAR EVENTS TABLE IS MAPPED AND HAS BEEN CREATED' AS ALERT
	END

	--DEADLINES--
	IF OBJECT_ID(@LegacyDb+'.PT1.DEADLINES') IS NOT NULL
	BEGIN
		SELECT @SQL = ' 
						DECLARE @DEADLINE_REPORT TABLE
						(
							[SECTION] NVARCHAR(MAX),
							[COUNT] NVARCHAR(MAX),
							[MISSING NAME] NVARCHAR(MAX),
							[MISSING NOTES] NVARCHAR(MAX),
							[MISSING DUE DATE] NVARCHAR(MAX),
							[MISSING DONE DATE] NVARCHAR(MAX),
							[DONE DATE IS BEFORE DUE DATE] NVARCHAR(MAX),
							[MINIMUM DUE DATE] NVARCHAR(MAX),
							[MAXIMUM DUE DATE] NVARCHAR(MAX),
							[MINIMUM DONE DATE] NVARCHAR(MAX),
							[MAXIMUM DONE DATE] NVARCHAR(MAX)
						)				
						INSERT INTO @DEADLINE_REPORT
						SELECT
						''DEADLINES'',
						(SELECT COUNT(*) AS ''COUNT'' FROM '+@LegacyDb+'.PT1.DEADLINES),
						(SELECT COUNT(*) AS ''MISSING NAME'' FROM '+@LegacyDb+'.PT1.DEADLINES WHERE NULLIF(NAME,'''') IS NULL),
						(SELECT COUNT(*) AS ''MISSING NOTES'' FROM '+@LegacyDb+'.PT1.DEADLINES WHERE NULLIF(NOTES,'''') IS NULL),
						(SELECT COUNT(*) AS ''MISSING DUE DATE'' FROM '+@LegacyDb+'.PT1.DEADLINES WHERE NULLIF(DUEDATE,'''') IS NULL),
						(SELECT COUNT(*) AS ''MISSING DONE DATE'' FROM '+@LegacyDb+'.PT1.DEADLINES WHERE NULLIF(DONEDATE,'''') IS NULL),
						(SELECT COUNT(*) AS ''DONE DATE IS NOT AFTER DUE DATE'' FROM '+@LegacyDb+'.PT1.DEADLINES WHERE DONEDATE < DUEDATE),
						(SELECT CAST(MIN(DUEDATE) AS DATE) AS ''MINIMUM DUE DATE'' FROM '+@LegacyDb+'.PT1.DEADLINES),
						(SELECT CAST(MAX(DUEDATE) AS DATE) AS ''MAXIMUM DUE DATE'' FROM '+@LegacyDb+'.PT1.DEADLINES),
						(SELECT CAST(MIN(DONEDATE) AS DATE) AS ''MINIMUM DONE DATE'' FROM '+@LegacyDb+'.PT1.DEADLINES),
						(SELECT CAST(MAX(DONEDATE) AS DATE) AS ''MINIMUM DONE DATE'' FROM '+@LegacyDb+'.PT1.DEADLINES)

						SELECT * FROM @DEADLINE_REPORT'
		EXEC(@SQL)
	END
	ELSE
	BEGIN
		SELECT 'VERIFY YOUR DEADLINES TABLE IS MAPPED AND HAS BEEN CREATED' AS ALERT
	END

	--FV_USERNAMES--
	IF OBJECT_ID(@LegacyDb+'.DBO.__FV_USERNAMES') IS NOT NULL
	BEGIN
		SELECT @SQL = ' 
						DECLARE @USERNAMES_REPORT TABLE
						(
							[SECTION] NVARCHAR(MAX),
							[COUNT] NVARCHAR(MAX),
							[MISSING FV_USERNAME] NVARCHAR(MAX)
						)				
						INSERT INTO @USERNAMES_REPORT
						SELECT
						''USERNAMES'',
						(SELECT COUNT(*) AS ''COUNT'' FROM '+@LegacyDb+'.DBO.__FV_USERNAMES),
						(SELECT COUNT(*) AS ''MISSING FV_USERNAME'' FROM '+@LegacyDb+'.DBO.__FV_USERNAMES WHERE NULLIF(FV_USERNAME,'''') IS NULL 
																												AND (NULLIF(LEGACY_USERNAME,'''') IS NOT NULL OR NULLIF(LEGACY_USERNAME_ID,'''') IS NOT NULL))

						SELECT * FROM @USERNAMES_REPORT'
		EXEC(@SQL)
	END
	ELSE
	BEGIN
		SELECT 'VERIFY YOUR FV_USERNAMES TABLE IS MAPPED AND HAS BEEN CREATED' AS ALERT
	END

	--DOCUMENTS--
	IF @DocsAudit = 1
	BEGIN
		IF OBJECT_ID(@LegacyDb+'.PT1.DOCUMENTS') IS NOT NULL 
		BEGIN
			SELECT @SQL = ' 
							DECLARE @DOCUMENT_REPORT TABLE
							(
								[SECTION] NVARCHAR(MAX),
								[NUMBER OF DOCUMENTS] NVARCHAR(MAX),
								[MISSING USERNAME] NVARCHAR(MAX),
								[MISSING FOLDER PATH] NVARCHAR(MAX),
								[TEMP FILES] NVARCHAR(MAX),
								[UNSUPPORTED FILES] NVARCHAR(MAX),
								[PERCENT OF DOCUMENTS WITH VALID EXTENSION THAT ARE EMPTY] NVARCHAR(MAX)
							)				
							INSERT INTO @DOCUMENT_REPORT
							SELECT
							''DOCUMENTS'',
							(SELECT COUNT(*) AS ''DOCUMENTS'' FROM '+@LegacyDb+'.PT1.DOCUMENTS),
							(SELECT COUNT(*) AS ''MISSING USERNAME'' FROM '+@LegacyDb+'.PT1.DOCUMENTS WHERE NULLIF(UPLOADEDBYUSERNAME,'''') IS NULL),
							(SELECT COUNT(*) AS ''MISSING FOLDER PATH'' FROM '+@LegacyDb+'.PT1.DOCUMENTS WHERE NULLIF(DESTINATIONFOLDERPATH,'''') IS NULL),
							(SELECT COUNT(*) AS ''TEMP FILES'' FROM '+@LegacyDb+'.PT1.DOCUMENTS WHERE DESTINATIONFILENAME LIKE ''~$%''),
							(SELECT COUNT(*) AS ''UNSUPPORTED FILES'' 
									FROM '+@LegacyDb+'.PT1.DOCUMENTS 
									WHERE 1=1
									AND PATINDEX(''%.exe'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.com'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.bat'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.js'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.vbs'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.pif'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.cmd'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.dll'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.ocx'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.pwl'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.msi'',DESTINATIONFILENAME) > 0 
									OR PATINDEX(''%.dmg'',DESTINATIONFILENAME) > 0 ),
							   (SELECT	CAST(
											(SELECT CAST(COUNT(*) AS DECIMAL(18,2)) FROM '+@LegacyDb+'..S3DOCSCAN WHERE FILEEXT IS NOT NULL AND S3OBJECTBYTES = 0) /  (SELECT CAST(COUNT(*) AS DECIMAL(18,2)) FROM '+@LegacyDb+'..S3DOCSCAN WHERE FILEEXT IS NOT NULL)
											* 100  AS DECIMAL(18,2)
										) AS PERCENT_OF_EMPTY_DOCS_VALIDFILEEXT
								)
  

							SELECT * FROM @DOCUMENT_REPORT'
			EXEC(@SQL)
		END
		ELSE
		BEGIN
			SELECT 'VERIFY YOUR DOCUMENTS TABLE IS MAPPED AND HAS BEEN CREATED' AS ALERT
		END
	END
	-----------------------------------------------------------------------------------------------------------------------
	--COLLECTION SECTIONS--
	DECLARE @COLLECTION_TABLES TABLE
	(ID INT IDENTITY (1,1), DB__NAME NVARCHAR(MAX), TABLE_NAME NVARCHAR(MAX), [ROWCOUNT] NVARCHAR(MAX),[DUPLICATES (YES OR NO)] NVARCHAR(MAX))

	DECLARE @COLLECTION_DUPES TABLE
	(ID INT IDENTITY (1,1), TABLE_NAME NVARCHAR(MAX))

	SELECT @SQL = '	
				SELECT DISTINCT TABLE_CATALOG, TABLE_NAME,NULL,NULL
				FROM '+@LegacyDb+'.INFORMATION_SCHEMA.TABLES
				WHERE TABLE_NAME LIKE ''%'+@FVProductionPrefix+'%[_]CL[_]%'' '
	INSERT INTO @COLLECTION_TABLES
	EXEC(@SQL)

	DECLARE @Counter INT, @MAX INT, @DB NVARCHAR(MAX), @TN NVARCHAR(MAX)
	SET @Counter=1
	SELECT @MAX = COUNT(*) FROM @COLLECTION_TABLES
	WHILE ( @Counter <= @MAX)
	BEGIN
		SELECT @DB= DB__NAME, 
			   @TN = TABLE_NAME 
		FROM @COLLECTION_TABLES WHERE ID = @COUNTER

		SELECT @SQL = 	
				'SELECT DISTINCT [TABLE] FROM 
					(SELECT ''['+@TN+']'' AS [TABLE], [COLLECTIONITEMEXTERNALID], COUNT(*) AS [MYCOUNT]
					FROM ['+@DB+']..['+@TN+']
					GROUP BY [COLLECTIONITEMEXTERNALID]
					HAVING COUNT(*) > 1
					) Z'

		INSERT INTO @COLLECTION_DUPES
		EXEC(@SQL)

		SET @Counter  = @Counter  + 1
	END

	--UPDATE DUPES
	UPDATE C1
	SET C1.[DUPLICATES (YES OR NO)] = CASE
										WHEN '['+C1.[TABLE_NAME]+']' = C2.[TABLE_NAME] THEN 'YES'
										ELSE 'NO'
									  END
	FROM @COLLECTION_TABLES C1
	LEFT JOIN @COLLECTION_DUPES C2 ON '['+C1.[TABLE_NAME]+']' = C2.[TABLE_NAME]

	--UPDATE ROW COUNT
	SELECT @Counter=1
	WHILE ( @Counter <= @MAX)
	BEGIN
		SELECT @DB= DB__NAME, 
			   @TN = TABLE_NAME 
		FROM @COLLECTION_TABLES WHERE ID = @COUNTER

		SELECT @SQL = '	
				SELECT @cnt=COUNT(*)
				FROM ['+@DB+']..['+@TN+']'
		EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt=@counts OUTPUT

		UPDATE @COLLECTION_TABLES 
		SET [ROWCOUNT] = @counts
		WHERE DB__NAME = @DB AND TABLE_NAME  = @TN

		SET @Counter  = @Counter  + 1
	END

	--PRINT RESULTS
	IF @ListCLSections = 1 
	BEGIN 
		SELECT [TABLE_NAME] AS [COLLECTION SECTION],[ROWCOUNT], [DUPLICATES (YES OR NO)] FROM @COLLECTION_TABLES 
	END
	----------------------------------------------------------------------
	--NON-COLLECTION SECTIONS--
	DECLARE @NONCOLLECTION_TABLES TABLE
	(ID INT IDENTITY (1,1), DB__NAME NVARCHAR(MAX), TABLE_NAME NVARCHAR(MAX),[ROWCOUNT] NVARCHAR(MAX), [DUPLICATES (YES OR NO)] NVARCHAR(MAX))

	DECLARE @NONCOLLECTION_DUPES TABLE
	(ID INT IDENTITY (1,1), TABLE_NAME NVARCHAR(MAX))

	SELECT @SQL = '	
				SELECT DISTINCT TABLE_CATALOG, TABLE_NAME, NULL, NULL
				FROM '+@LegacyDb+'.INFORMATION_SCHEMA.TABLES
				WHERE TABLE_NAME LIKE ''%'+@FVProductionPrefix+'%[_]NC[_]%'' '
	INSERT INTO @NONCOLLECTION_TABLES
	EXEC(@SQL)
	--IF @ListNCLSections = 1 BEGIN SELECT [TABLE_NAME] AS [NON-COLLECTION SECTIONS] FROM @NONCOLLECTION_TABLES END

	SET @Counter=1
	SELECT @MAX = COUNT(*) FROM @NONCOLLECTION_TABLES
	WHILE ( @Counter <= @MAX)
	BEGIN
		SELECT @DB= DB__NAME, 
			   @TN = TABLE_NAME 
		FROM @NONCOLLECTION_TABLES WHERE ID = @COUNTER
		
		SELECT @SQL = 	
				'SELECT DISTINCT [TABLE] FROM 
					(SELECT ''['+@TN+']'' AS [TABLE], [PROJECTEXTERNALID], COUNT(*) AS [MYCOUNT]
					FROM ['+@DB+']..'+@TN+' 
					GROUP BY [PROJECTEXTERNALID]
					HAVING COUNT(*) > 1
					) Z'

		INSERT INTO @NONCOLLECTION_DUPES
		EXEC(@SQL)

		SET @Counter  = @Counter  + 1
	END

	--UPDATE DUPES
	UPDATE NC1
	SET NC1.[DUPLICATES (YES OR NO)] = CASE
										WHEN '['+NC1.[TABLE_NAME]+']' = NC2.[TABLE_NAME] THEN 'YES'
										ELSE 'NO'
									  END
	FROM @NONCOLLECTION_TABLES NC1
	LEFT JOIN @NONCOLLECTION_DUPES NC2 ON '['+NC1.[TABLE_NAME]+']' = NC2.[TABLE_NAME]

	--UPDATE ROW COUNT
	SELECT @Counter=1
	WHILE ( @Counter <= @MAX)
	BEGIN
		SELECT @DB= DB__NAME, 
			   @TN = TABLE_NAME 
		FROM @NONCOLLECTION_TABLES WHERE ID = @COUNTER

		SELECT @SQL = '	
				SELECT @cnt=COUNT(*)
				FROM ['+@DB+']..['+@TN+']'
		EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt=@counts OUTPUT

		UPDATE @NONCOLLECTION_TABLES 
		SET [ROWCOUNT] = @counts
		WHERE DB__NAME = @DB AND TABLE_NAME  = @TN

		SET @Counter  = @Counter  + 1
	END
	
	--PRINT RESULTS
	IF @ListNCLSections = 1 
	BEGIN 
		SELECT [TABLE_NAME] AS [NON-COLLECTION SECTION], [ROWCOUNT], [DUPLICATES (YES OR NO)] FROM @NONCOLLECTION_TABLES 
	END
	-------------------------------------------------------------

END
GO
/****** Object:  StoredProcedure [dbo].[CalendarEvents_AlignUsernames]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CalendarEvents_AlignUsernames]
@legacyDatabase varchar(max)
, @legacyEventsTable varchar(max)
, @legacyEventsEventID varchar(max)
, @legacyEventsUserListField varchar(max)
, @legacyEventsUserListFieldDelimiter varchar(max)
, @FVUserTable varchar(max)
, @FVLegacyUserField varchar(max)
, @FVUserField varchar(max)

AS
BEGIN
		declare @sql varchar(max)

		/* FOR TESTING
		----drop table if exists aaa_attendees

		----create table aaa_attendees (apptID int,attendees varchar(max))

		----insert into aaa_attendees 
		----select 1,'AMENSH;CLEWIS;DLAFRAM'

		----insert into aaa_attendees 
		----select 2,'NPARFITT;NALI;PLYONS'
		
		declare @legacyDatabase varchar(max)
		, @legacyEventsTable varchar(max)
		, @legacyEventsEventID varchar(max)
		, @legacyEventsUserListField varchar(max)
		, @legacyEventsUserListFieldDelimiter varchar(max)
		, @FVUserTable varchar(max)
		, @FVLegacyUserField varchar(max)
		, @FVUserField varchar(max)
		, @sql varchar(max)

		select @legacyDatabase = '[8049_Hess_GL]'--'184_Ashcraft_r1'
		select @legacyEventsTable = 'calendar'--'aaa_attendees' 
		select @legacyEventsEventID = 'id' --apptID
		select @legacyEventsUserListField = 'staff' --'assignees'
		select @legacyEventsUserListFieldDelimiter = ';'
		select @FVUserTable = '[PT1_CLIENT_ALIGN].[__FV_USERALIGNMENT]'--'__FV_Alignment_Users' --'__FV_Usernames'
		select @FVLegacyUserField = 'Needles_staff_code' --'Login' --'Legacy_Username'
		select @FVUserField = 'fvProd' --'FilevineProd' --'Fv_username'
		*/

		--WHEN @legacyEventsUserListField STARTS WITH THE DELIMITER, THEN IGNORE LEADING DELIMITER
		select @legacyEventsUserListField = case
												when left(@legacyEventsUserListField,1) = @legacyEventsUserListFieldDelimiter
												then substring(@legacyEventsUserListField,2,len(@legacyEventsUserListField))
												else @legacyEventsUserListField
											end

		--RECREATE __FV_Events_Split; POPULATE __FV_Events_Split (BREAK APART DELIMITED LIST OF LEGACY USERS)
		select @sql = '
		use ['+replace(replace(@legacyDatabase,'[',''),']','')+']

		drop table if exists __FV_Events_Split 
		create table __FV_Events_Split (calendarEventID varchar(max), legacyUser varchar(max)) /*CREATING PHYSICAL TABLE FOR TROUBLESHOOTING PURPOSES*/
		
		insert into __FV_Events_Split
		select a.['+@legacyEventsEventID+'],z.* from 
		'+@legacyEventsTable+' a
		cross apply string_split(a.'+@legacyEventsUserListField+','''+@legacyEventsUserListFieldDelimiter+''') z
		'
		exec(@sql)


		--RECREATE __FV_Events_Join; POPULATE __FV_Events_Join (JOIN LEGACY USERS TO FV USERS)
		select @sql = '
		use ['+replace(replace(@legacyDatabase,'[',''),']','')+']

		drop table if exists __FV_Events_Join
		create table __FV_Events_Join (calendarEventID varchar(max), legacyUser varchar(max), filevineUser varchar(max)) /*CREATING PHYSICAL TABLE FOR TROUBLESHOOTING PURPOSES*/
		
		insert into __FV_Events_Join
		select s.*,u.['+@FVUserField+'] from __FV_Events_Split s
		join '+@FVUserTable+' u on u.['+@FVLegacyUserField+'] = s.legacyUser
		'
		exec(@sql)


		--RECREATE __FV_Events_Final, POPULATE, AND RETRIEVE FINAL OUTPUT
		select @sql = '
		use ['+replace(replace(@legacyDatabase,'[',''),']','')+']
		
		drop table if exists __FV_Events_Final
		create table __FV_Events_Final (calendarEventID varchar(max),filevineUserList varchar(max))

		insert into __FV_Events_Final
		select calendarEventID,string_agg(filevineUser,'','')
		from __FV_Events_Join
		group by calendarEventID

		select * from __FV_Events_Final'
		exec(@sql)

END

/*
exec [filevine_meta_test].dbo.CalendarEvents_AlignUsernames
	@legacyDatabase = '[8049_Hess_GL]'--'184_Ashcraft_r1'
	,@legacyEventsTable = 'calendar'--'aaa_attendees' 
	,@legacyEventsEventID = 'id' --apptID
	,@legacyEventsUserListField = 'staff' --'assignees'
	,@legacyEventsUserListFieldDelimiter = ';'
	,@FVUserTable = '[PT1_CLIENT_ALIGN].[__FV_USERALIGNMENT]'--'__FV_Alignment_Users' --'__FV_Usernames'
	,@FVLegacyUserField = 'Needles_staff_code' --'Login' --'Legacy_Username'
	,@FVUserField = 'fvProd' --'FilevineProd' --'Fv_username'
*/
GO
/****** Object:  StoredProcedure [dbo].[CleanAllSpaces]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Katie Jumonville
-- Create date: 6/28/2019
-- Description:	Trims all data in legacy tables. Can remove all extra spaces and tab characters in the legacy tables.
--					Then sets any values that are blank (in the tables it updated) to NULL.
-- =============================================
CREATE   PROCEDURE [dbo].[CleanAllSpaces]
	@DebugFlag BIT					/*Enables debugging SQL output.  TRUE: dumps output SQL code.  FALSE: runs proc normally.*/
	,@LegacyDb VARCHAR(500)			/*Name of your client specific database.  i.e. [4436_borland]*/
	,@CleanAllTablesFlag BIT		/*TRUE: Loop through the client database and clean all columns in all tables. FALSE: This requires the next parameters to not be null - @SchemaName & @TableName*/
	,@SchemaName VARCHAR(500)		/*Schema of the table you would like to clean*/
	,@TableName VARCHAR(500)		/*Table you would like to clean*/    
	,@RemoveDoublespace BIT			/*TRUE: Removes all double spaces. FALSE: Leaves double spaces*/
	,@ReplaceTabs BIT				/*TRUE: Replaces tab characters with '; '. Leaves tab characters */

AS
	BEGIN
		SET NOCOUNT ON;

		DECLARE
			  @DB_Table VARCHAR(500)
			, @Schema_Name VARCHAR(500)
			, @Table_Name VARCHAR(500)
			, @TemporaryTable VARCHAR(500)
			, @Column_Name VARCHAR(500)
			, @Is_Nullable CHAR(3)
			, @ErrorMsg VARCHAR(MAX)
			, @CheckResult BIT
			, @True BIT = 1
			, @False BIT = 0
			, @SQL NVARCHAR(MAX)
			, @i INT = 1
			, @j INT

		/*Clean inputs*/
		SET @LegacyDb = CASE 
			WHEN LEFT(@LegacyDb,1) = '[' AND RIGHT(@LegacyDb,1) = ']' THEN @LegacyDb 
			ELSE QUOTENAME(@LegacyDb) 
			END
		SET @SchemaName = CASE 
			WHEN @SchemaName IS NULL OR @SchemaName = '' OR @SchemaName = ' ' THEN NULL 
			WHEN LEFT(@SchemaName,1) = '[' AND RIGHT(@SchemaName,1) = ']' THEN SUBSTRING(@SchemaName,2, LEN(@SchemaName)-2)
			ELSE @SchemaName
			END
		SET @TableName = CASE 
			WHEN @TableName IS NULL OR @TableName = '' OR @TableName = ' ' THEN NULL 
			WHEN LEFT(@TableName,1) = '['  AND RIGHT(@TableName,1) = ']' THEN SUBSTRING(@TableName,2, LEN(@TableName)-2)
			ELSE @TableName
			END
		SET @Schema_Name = QUOTENAME(@SchemaName) 
		SET @Table_Name = QUOTENAME(@TableName)
		SET @TemporaryTable = @LegacyDb+'.[dbo].[Whitespace_Cleaning_Table]'


		/*Given database does not exist*/
		IF @LegacyDb NOT IN (SELECT QUOTENAME([name]) FROM sys.databases)
			BEGIN
				SET @ErrorMsg = @LegacyDb+' either does not exist or is spelled incorrectly.'
				RAISERROR (@ErrorMsg,16,1)
			END
		/*Given database exists*/
		ELSE
			BEGIN
				/*Make sure view exists*/
				SET @DB_Table = @LegacyDb +'.INFORMATION_SCHEMA.TABLES'
				SET @SQL = 
					N'IF EXISTS (SELECT TABLE_NAME FROM '+@DB_Table+N' WHERE TABLE_SCHEMA = ''dbo'' AND TABLE_NAME = ''VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT'')
						BEGIN
							SET @CheckResultOUT = 1
						END
					ELSE
						BEGIN
							SET @CheckResultOUT = 0
						END'
				IF @DebugFlag = @True
					BEGIN	
						PRINT @SQL	
					END
				EXEC sp_executesql @SQL, N'@CheckResultOUT bit OUTPUT', @CheckResultOUT = @CheckResult OUTPUT

				/*PMAT has not been run yet*/
				IF @CheckResult = @False 
					BEGIN
						SET @ErrorMsg = '[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT] does not exist. This is most likely because PMAT has not yet been run. Please run PMAT.'
						RAISERROR(@ErrorMsg,16,1);
					END

				/*PMAT has been run and the view exists*/
				ELSE 
					BEGIN
						/*Validate given Schema and Table Name if @CleanAllTables is false*/
						IF @CleanAllTablesFlag = @False AND (@SchemaName IS NULL OR @TableName IS NULL)
							BEGIN
								SET @CheckResult = @False
							END
						ELSE IF @CleanAllTablesFlag = @False
							BEGIN
								SET @SQL = 
									N'IF EXISTS (SELECT TABLE_SCHEMA,TABLE_NAME FROM '+@DB_Table+N' WHERE TABLE_SCHEMA = '''+@SchemaName+N''' AND TABLE_NAME = '''+@TableName+N''')
										BEGIN
											SET @CheckResultOUT = 1
										END
									ELSE
										BEGIN
											SET @CheckResultOUT = 0
										END'
								IF @DebugFlag = @True
									BEGIN	
										PRINT @SQL	
									END
								EXEC sp_executesql @SQL, N'@CheckResultOUT bit OUTPUT', @CheckResultOUT = @CheckResult OUTPUT
							END
						ELSE /*@CleanAllTablesFlag = @True*/
							BEGIN
								SET @CheckResult = @True
							END
								
						/*Given Schema and Table do not exist in the database*/
						IF @CheckResult = @False 
							BEGIN
								SET @ErrorMsg = 'Either no Schema or Table were provided or the given Schema and Table do not exist in '+@LegacyDb+'.'
								RAISERROR(@ErrorMsg,16,1);
							END

						/*Given Schema and Table exist in the database OR all tables will be cleaned*/
						ELSE 
							BEGIN
								/*Drop Temp Table if it already exists*/
								SET @SQL = 
									N'DROP TABLE IF EXISTS '+@TemporaryTable
								IF @DebugFlag = @True
									BEGIN	
										PRINT @SQL	
									END
								EXEC sp_executesql @SQL
								/*Assign Source Table*/
								SET @DB_Table = @LegacyDb +N'.[dbo].[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT]'

								/*Create Cleaning Table*/
								SET @SQL = 
									N'CREATE TABLE '+@TemporaryTable+N'
									(
										[ID] int identity(1,1)
										,[TABLE_SCHEMA] nvarchar(500)
										,[TABLE_NAME] nvarchar(500)
										,[COLUMN_NAME] nvarchar(500)
										,[IS_NULLABLE] nchar(3)
										,[Whitespace Removed] nvarchar(MAX)
										,[Blanks set to Nulls] nvarchar(MAX)
									)'
								IF @DebugFlag = @True
									BEGIN	
										PRINT @SQL	
									END
								EXEC sp_executesql @SQL

								SET @SQL = 
									N'INSERT INTO '+@TemporaryTable+N'
									SELECT distinct 
									vw.[TABLE_SCHEMA]
									,vw.[TABLE_NAME]
									,vw.[COLUMN_NAME]
									,isc.[IS_NULLABLE]
									,NULL AS ''Whitespace Removed''
									,NULL AS ''Blanks set to Nulls''
									FROM '+@DB_Table+N' vw
									LEFT JOIN '+@LegacyDb +N'.INFORMATION_SCHEMA.COLUMNS isc
									ON vw.[TABLE_SCHEMA] = isc.[TABLE_SCHEMA] AND vw.[TABLE_NAME] = isc.[TABLE_NAME] AND vw.[COLUMN_NAME] = isc.[COLUMN_NAME]
									LEFT JOIN '+@LegacyDb +N'.INFORMATION_SCHEMA.TABLES ist
									ON vw.[TABLE_SCHEMA] = ist.[TABLE_SCHEMA] AND vw.[TABLE_NAME] = ist.[TABLE_NAME]'


								/*Populate Cleaning Table based on @CleanAllTables*/
								IF @CleanAllTablesFlag = @False
									BEGIN
										SET @SQL = @SQL + N'
											WHERE vw.[TABLE_SCHEMA] = '''+@SchemaName+N''' AND vw.[TABLE_NAME] = '''+@TableName+N'''
											AND ist.[TABLE_TYPE] = ''BASE TABLE'' /*don''t include views*/
											AND (vw.[FIELD_VALUE] = '''' /*value is blank - blank values should end up in this table even without this line*/
											OR charindex('' '', vw.[FIELD_VALUE]) = 1 /*needs to left trimmed*/
											OR charindex('' '', vw.[FIELD_VALUE]) = len(vw.[FIELD_VALUE]) /*needs to be right trimmed*/'
											
									END
								ELSE /*@CleanAllTablesFlag = @True*/
									BEGIN
										SET @SQL = @SQL + N'
											WHERE ist.[TABLE_TYPE] = ''BASE TABLE'' /*don''t include views*/
											AND vw.[TABLE_NAME] != ''s3docscan''
											AND (vw.[FIELD_VALUE] = '''' /*value is blank - blank values should end up in this table even without this line*/
											OR charindex('' '', vw.[FIELD_VALUE]) = 1 /*needs to left trimmed*/
											OR charindex('' '', vw.[FIELD_VALUE]) = len(vw.[FIELD_VALUE]) /*needs to be right trimmed*/'
											
									END
								/*Populate Cleaning Table based on @RemoveDoublespace*/
								IF @RemoveDoublespace = @True
									BEGIN
										SET @SQL = @SQL + N'
											OR charindex(''  '', vw.[FIELD_VALUE]) != 0 /*double spaces exist*/'
									END
								/*Populate Cleaning Table based on @ReplaceTabs*/
								IF @ReplaceTabs = @True
									BEGIN
										SET @SQL = @SQL +N'
											OR charindex(char(9), vw.[FIELD_VALUE]) != 0 /*includes a tab character*/'
									END
								
								/*Insert closing parantheses*/
								SET @SQL = @SQL+N')'

								IF @DebugFlag = @True
									BEGIN	
										PRINT @SQL	
									END
								EXEC sp_executesql @SQL

								
								/*Set @j to # of rows in table*/
								SET @SQL = 
									N'SET @jOUT = (SELECT COUNT(*) FROM '+@TemporaryTable+N')'
								IF @DebugFlag = @True
									BEGIN	
										PRINT @SQL	
									END
								EXEC sp_executesql @SQL, N'@jOUT int OUTPUT', @jOUT = @j OUTPUT
								IF @DebugFlag = @True
									BEGIN
										PRINT @j
									END

								/*Begin Loop*/
								WHILE (@i <= @j)
									BEGIN
										IF @DebugFlag = @True
											BEGIN
												PRINT @i
											END

										/*Set Schema, Table, Column, and Is Nullable*/
										/*Set Schema Name*/
										SET @SQL = 
											N'SET @Schema_NameOUT = (SELECT QUOTENAME([TABLE_SCHEMA]) FROM '+@TemporaryTable+N' WHERE ID = @i)'
										IF @DebugFlag = @True
											BEGIN	
												PRINT @SQL	
											END
										EXEC sp_executesql @SQL, N'@Schema_NameOUT VARCHAR(500) OUTPUT,@i int', @Schema_NameOUT = @Schema_Name OUTPUT, @i = @i
										IF @DebugFlag = @True
											BEGIN
												PRINT @Schema_Name
											END
										/*Set Table Name*/
										SET @SQL = 
											N'SET @Table_NameOUT = (SELECT QUOTENAME([TABLE_NAME]) FROM '+@TemporaryTable+N' WHERE ID = @i)'
										IF @DebugFlag = @True
											BEGIN	
												PRINT @SQL	
											END
										EXEC sp_executesql @SQL, N'@Table_NameOUT VARCHAR(500) OUTPUT,@i int', @Table_NameOUT = @Table_Name OUTPUT, @i = @i
										IF @DebugFlag = @True
											BEGIN
												PRINT @Table_Name
											END
										/*Set Column Name*/
										SET @SQL = 
											N'SET @Column_NameOUT = (SELECT QUOTENAME([COLUMN_NAME]) FROM '+@TemporaryTable+N' WHERE ID = @i)'
										IF @DebugFlag = @True
											BEGIN	
												PRINT @SQL	
											END
										EXEC sp_executesql @SQL, N'@Column_NameOUT VARCHAR(500) OUTPUT,@i int', @Column_NameOUT = @Column_Name OUTPUT, @i = @i
										IF @DebugFlag = @True
											BEGIN
												PRINT @Column_Name
												PRINT @Schema_Name+'.'+@Table_Name+'.'+@Column_Name
											END
										/*Set Is Nullable*/
										SET @SQL = 
											N'SET @Is_NullableOUT = (SELECT [IS_NULLABLE] FROM '+@TemporaryTable+N' WHERE ID = @i)'
										IF @DebugFlag = @True
											BEGIN	
												PRINT @SQL	
											END
										EXEC sp_executesql @SQL, N'@Is_NullableOUT CHAR(3) OUTPUT,@i int', @Is_NullableOUT = @Is_Nullable OUTPUT, @i = @i
										IF @DebugFlag = @True
											BEGIN
												PRINT @Is_Nullable
											END

										/*Run CleanSpaces for that Column*/
										BEGIN TRY
											/*Run Cleanspaces*/
											SET @SQL = 
												N'UPDATE '+@LegacyDb+N'.'+@Schema_Name+N'.'+@Table_Name+N'
												SET '+@Column_Name+N' = dbo.CleanSpaces('+@Column_Name+N', '+convert(nvarchar(1),@RemoveDoublespace)+N', '+convert(nvarchar(1),@ReplaceTabs)+N')
													WHERE charindex('' '', '+@Column_Name+N') = 1 /*needs to left trimmed*/
													OR right('+@Column_Name+N',1) IN ('' '',CHAR(9),CHAR(10),CHAR(13)) /*needs to be right trimmed*/'
													
											/*Run Cleanspaces based on @RemoveDoublespace*/		
											IF @RemoveDoublespace = @True
												BEGIN
													SET @SQL = @SQL + N'
														OR charindex(''  '', '+@Column_Name+N') != 0 /*double spaces exist*/'
												END
											/*Run Cleanspaces based on @ReplaceTabs*/	
											IF @ReplaceTabs = @True
												BEGIN
													SET @SQL = @SQL + N'
														OR charindex(char(9), '+@Column_Name+N') != 0 /*includes a tab character*/'
												END
											
											IF @DebugFlag = @True
												BEGIN	
													PRINT @SQL	
												END
											EXEC sp_executesql @SQL

											/*Write Success*/
											SET @SQL = 
												N'UPDATE '+@TemporaryTable+N'
												SET [Whitespace Removed] = ''Success''
												WHERE ID = @i'

											IF @DebugFlag = @True
											BEGIN	
												PRINT @SQL	
											END
											EXEC sp_executesql @SQL, N'@i int', @i = @i
										END TRY

										/*If there were errors, write errors*/
										BEGIN CATCH
											SET @SQL = 
												N'UPDATE '+@TemporaryTable+N'
												SET [Whitespace Removed] = ''Error: ''+ERROR_MESSAGE()
												WHERE ID = @i'

											IF @DebugFlag = @True
											BEGIN	
												PRINT @SQL	
											END
											EXEC sp_executesql @SQL, N'@i int', @i = @i
										END CATCH

										BEGIN TRY
											/*Set blanks to NULL for that Column*/
											IF @Is_Nullable = 'YES'
												BEGIN
													SET @SQL = 
														N'UPDATE '+@LegacyDb+N'.'+@Schema_Name+N'.'+@Table_Name+N'
														SET '+@Column_Name+N' = NULL
														WHERE '+@Column_Name+N' = '''' /*string is empty*/'
													IF @DebugFlag = @True
														BEGIN	
															PRINT @SQL	
														END
													EXEC sp_executesql @SQL

													/*Write Success*/
													SET @SQL = 
														N'UPDATE '+@TemporaryTable+N'
														SET [Blanks set to Nulls] = ''Success''
														WHERE ID = @i'

													IF @DebugFlag = @True
													BEGIN	
														PRINT @SQL	
													END
													EXEC sp_executesql @SQL, N'@i int', @i = @i
												END

											ELSE /*@Is_Nullable = 'NO'*/
												BEGIN
													/*Write Success*/
													SET @SQL = 
														N'UPDATE '+@TemporaryTable+N'
														SET [Blanks set to Nulls] = ''Not Nullable''
														WHERE ID = @i'

													IF @DebugFlag = @True
													BEGIN	
														PRINT @SQL	
													END
													EXEC sp_executesql @SQL, N'@i int', @i = @i
												END
										END TRY

										/*If there were errors, write errors*/
										BEGIN CATCH
											SET @SQL = 
												N'UPDATE '+@TemporaryTable+N'
												SET [Blanks set to Nulls] = ''Error: ''+ERROR_MESSAGE()
												WHERE ID = @i'

											IF @DebugFlag = @True
											BEGIN	
												PRINT @SQL	
											END
											EXEC sp_executesql @SQL, N'@i int', @i = @i
										END CATCH


										/*Increment @i*/
										SET @i += 1
									END

								/*Print the Table and its results*/
								SET @SQL = 
									N'SELECT * FROM '+@TemporaryTable
								IF @DebugFlag = @True
									BEGIN	
										PRINT @SQL	
									END
								EXEC sp_executesql @SQL

								/*Drop temporary table*/
								/* We decided to not drop the temporary table. But here is the code in case we decide to change that.
								SET @SQL = N'DROP TABLE '+@TemporaryTable
								IF @DebugFlag = @True
									BEGIN	
										PRINT @SQL	
									END
								EXEC sp_executesql @SQL
								*/
								
							END
					END
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[DropStoredProcBySchema]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE 
	[dbo].[DropStoredProcBySchema]
		  @Schema VARCHAR(MAX)
		, @DB VARCHAR(MAX)
AS
	BEGIN
		DECLARE
			  @SQL VARCHAR(MAX)
			, @SchemaQuote VARCHAR(MAX)
			, @DBQuote VARCHAR(MAX)

		SET @Schema = REPLACE(REPLACE(@Schema, '[',''), ']','')
		SET @SchemaQuote = '[' + @Schema + ']'
		SET @DB = REPLACE(REPLACE(@DB, '[',''), ']','')
		SET @DBQuote = '[' + @DB + ']'
		
		SET @SQL = 
			'
				USE ' + @DBQuote + '

				DECLARE
					@tempDropSPTab TABLE
						(
							  ID INT IDENTITY(1,1)
							, Proc_Schema VARCHAR(MAX)
							, Proc_Name VARCHAR(MAX)
							, Proc_DB VARCHAR(MAX)
						)

				INSERT INTO
					@tempDropSPTab
						(
							  Proc_Schema
							, Proc_name
							, Proc_DB
						)
				SELECT DISTINCT
					  SPECIFIC_SCHEMA
					, ROUTINE_NAME
					, SPECIFIC_CATALOG
				FROM
					INFORMATION_SCHEMA.ROUTINES
				WHERE 
						SPECIFIC_SCHEMA = ''' + @Schema + '''
					AND ROUTINE_TYPE = ''PROCEDURE''
					AND ROUTINE_CATALOG = ''' + @DB + '''

				DECLARE
					  @Counter INT = 1
					, @Max INT = (SELECT MAX(ID) FROM @tempDropSPTab)
					, @SQL VARCHAR(MAX)
					, @LoopSchema VARCHAR(MAX)
					, @LoopProc VARCHAR(MAX)
					, @LoopDB VARCHAR(MAX)

				WHILE @Counter <= @Max
					BEGIN
						SELECT
							  @LoopSchema = Proc_Schema
							, @LoopProc = Proc_Name
							, @LoopDB = Proc_DB
						FROM
							@tempDropSPTab
						WHERE 
							ID = @Counter

						SET @SQL =
							''
								USE ['' + @LoopDB + ''];
								DROP PROCEDURE
									['' + @LoopSchema + ''].['' + @LoopProc + ''];
							''

						EXEC (@SQL)

						SET @Counter = @Counter + 1
					END
			'

		EXEC (@SQL)
	END
GO
/****** Object:  StoredProcedure [dbo].[migration_update_process_status]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[migration_update_process_status]	
	  @Database VARCHAR(500)
	, @step_exec VARCHAR(500)
	, @step_name VARCHAR(100)
	, @sub_step_name VARCHAR(MAX)
	, @status VARCHAR(25)
	, @row_count BIGINT = 0
	, @error_code BIGINT = 0
	, @error_msg VARCHAR(MAX) = ''

AS
	BEGIN
		DECLARE @SQL VARCHAR(MAX)

		SET @SQL = 
			'
				USE ' + @Database + ' 

				INSERT INTO 
					[dbo].[MIGRATION_PROCESS_STATUS]
					(
						  [STEP_EXECUTABLE]
						, [STEP_NAME]
						, [SUB_STEP_NAME]
						, [STATUS]
						, [ROW_COUNT]
						, [ERROR_CODE]
						, [ERROR_MESSAGE]
					)
				VALUES 
					(
						  ''' + @step_exec + '''
						, ''' + @step_name + '''
						, ''' + @sub_step_name + '''
						, ''' + @status + '''
						, ''' + CONVERT(VARCHAR(10), @row_count) + '''
						, ''' + CONVERT(VARCHAR(15), @error_code) + '''
						, ''' + @error_msg + '''
					);
			'
		
		/*	select @sql */
		
		EXEC (@SQL)
	END

GO
/****** Object:  StoredProcedure [dbo].[usp_addusers]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--example useage: EXEC [Filevine_META].[dbo].[usp_addusers] '1234_OrgName'
/*
	CURRENTLY SUPPORTED SERVER INSTANCES
	US IMPORT: [WIN-H26AAAB7UO6]	
	CANADA IMPORT: [IMPORT-CANADA\MSSQLSERVERCA]
	RED PEPPER IMPORT: [EC2AMAZ-924ASRA]
*/

CREATE PROCEDURE 
	[dbo].[usp_addusers] 
		  @dbname varchar(255)
		, @debugFlag BIT = 0
AS
	BEGIN
		DECLARE 
			  @Sql VARCHAR(MAX)
			, @SQLUser VARCHAR(MAX)
			, @DBRole VARCHAR(MAX)
			, @ServerName VARCHAR(MAX) = @@SERVERNAME
			, @USImportServerName VARCHAR(1000) = 'WIN-H26AAAB7UO6'
			, @CAImportServerName VARCHAR(1000) = 'IMPORT-CANADA\MSSQLSERVERCA'
			, @RPImportServerName VARCHAR(1000) = 'EC2AMAZ-924ASRA'
			, @METAL_User_Role VARCHAR(1000) = 'METAL_User'
			, @DM_user_Role VARCHAR(1000) = 'DM_user'
			, @Counter INT = 1
			, @MaxID INT

		SET @dbname = REPLACE(REPLACE(@dbname, '[', ''), ']', '')

		--Map out DM Users
		BEGIN
			DECLARE
				@DMUsers TABLE
				(
					  ID BIGINT IDENTITY(1,1)
					, ServerName VARCHAR(MAX)
					, RoleName VARCHAR(MAX)
					, DBRole VARCHAR(MAX)
					, SQLUserName VARCHAR(MAX)
				)

			/*
			  =================================================================================
			  ==== ADD NEW USERS HERE.  Users are added based on server roles. ================
			  =================================================================================
			*/

			/*METAL and DM Roles*/
			BEGIN
				INSERT INTO
					@DMUsers
					(
						  [ServerName]
						, [RoleName]
						, [DBRole]
						, [SQLUserName]
					)
				SELECT 
					  @ServerName
					, sp.[name] AS RoleName
					, CASE
						WHEN sp.[name] IN (@METAL_User_Role, @DM_user_Role)
						THEN 'db_owner'

						ELSE 'NONE'
					  END
					, mem.[name] AS MemberName 
				FROM sys.server_role_members  srm
					JOIN sys.server_principals AS sp  
						ON srm.role_principal_id = sp.principal_id  
					JOIN sys.server_principals AS mem  
						ON srm.member_principal_id = mem.principal_id
				WHERE
					sp.NAME IN (@METAL_User_Role, @DM_user_Role)
				ORDER BY
					  sp.[name]
					, mem.[name]
			END
				
			SELECT 
				*
			FROM
				@DMUsers
				
			SET @MaxID = (SELECT MAX(ID) FROM @DMUsers)
		END
				
		WHILE @Counter <= @MaxID
			BEGIN
				SET @SQLUser = (SELECT SQLUserName FROM @DMUsers WHERE ID = @Counter)
				SET @DBRole = (SELECT [DBRole] FROM @DMUsers WHERE ID = @Counter)
				
				PRINT 'Creating User ' + ISNULL('[' + @SQLUser + ']', '') + ' for DB [' + @dbname + '] with role [' + @DBRole + '].'
				
				IF @DBRole <> 'NONE'
					BEGIN
						SET @SQL = 
							'
								USE [' + @dbname + ']

								DECLARE 
									  @ErrorCode INT
									, @ErrorMsg NVARCHAR(500)
						
								BEGIN TRY

									ALTER AUTHORIZATION ON DATABASE::[' + @dbname + '] TO [sa]
							' +
							CASE
								WHEN NULLIF(@SQLUser, '') IS NULL
								THEN ''

								ELSE
									'
									CREATE USER 
										[' + @SQLUser + '] 
									FOR LOGIN 
										[' + @SQLUser + ']
	
									ALTER ROLE 
										[' + @DBRole + '] 
									ADD MEMBER 
										[' + @SQLUser + ']
									'
							END +
							' 
								END TRY

								BEGIN CATCH
									SET @ErrorCode = ERROR_NUMBER();		
									SET @ErrorMsg = N''!!!!ERROR - FAILED to create user '' + ''' + @SQLUser + ' '' + ERROR_MESSAGE();
									SELECT @ErrorMsg
								END CATCH
							'
					END
				ELSE
					BEGIN
						SET @Sql = ''
					END

				IF @Sql = ''
					BEGIN
						PRINT 'User ' + @SQLUser + ' is not assigned to a server level role that will be assigned a database level role.'
					END
				ELSE
					BEGIN
						IF @DebugFlag = 1
							BEGIN
								SELECT 'USER' + @SqlUser, @Sql
							END
						EXEC(@SQL)
					END

				SET @Counter = @Counter + 1
			END

	END
GO
/****** Object:  StoredProcedure [dbo].[usp_Create_Mapping_Config_Table]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_Create_Mapping_Config_Table]
	  @DatabaseName VARCHAR(1000)
	, @OrgPrefix VARCHAR(1000)

AS
	BEGIN
		DECLARE 
			  @DatabaseNameUnquoted VARCHAR(1000) = REPLACE(REPLACE(@DatabaseName, '[', ''), ']', '')
			, @DatabaseNameQuoted VARCHAR(1000) = '[' + REPLACE(REPLACE(@DatabaseName, '[', ''), ']', '') + ']'
			
		DECLARE
			@WorkingUse VARCHAR(1000) = 'USE ' + @DatabaseNameQuoted
			
		DECLARE
			@SQL VARCHAR(MAX) = @WorkingUse + 
				'
					IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_CATALOG = ''' + @DatabaseNameUnquoted + ''' AND TABLE_NAME = ''MAPPING_CONFIG'')
						BEGIN
							CREATE TABLE 
								dbo.MAPPING_CONFIG
								( 
									  [FieldKey] [BIGINT] IDENTITY(1,1) NOT NULL --PK
									, [GroupTable] [INT] NOT NULL --ranking number for the ProjectType/section
									, [CE_Section_ID] [BIGINT] NOT NULL --CustomsEditor Table ID
									, [CE_Section_Name] [VARCHAR] (500) NOT NULL --Customs Editor table Name
									, [CE_Section_Alias] [VARCHAR](50) NOT NULL --short name for Customs Editor table name
									, [Section_Type] VARCHAR(50) NOT NULL --Collection/Non-collection/standard table types
 									, [CE_Field_ID] [BIGINT] NOT NULL --CustomsEditor field ID
									, [CE_Field_Name] [VARCHAR](500) NOT NULL --CustomsEditor Field name
									, [CE_Data_Type] [VARCHAR] (500) NOT NULL --custom editor data type (no precision)
									, [CE_field_Type] [VARCHAR] (500) NOT NULL --custom editor field type (i.e. dropdown, radio button, etc.)
									, [CE_Max_Len] [INT] NULL --custom editor field length
									, [CE_Num_Precison] [INT] NULL --custom editor precision
									, [CE_Num_Scale] [INT] NULL --custom editor scale
									, [CE_full_Data_Type] [VARCHAR](100) NOT NULL --custom editor full datatype
									, [CE_ORDINAL_POSITION] [INT] NULL --custom editor ordinal position
									, [CE_null_Stmt] [VARCHAR](100) NOT NULL --custom editor null allowable flag
									, [lg_table_ID] [VARCHAR] (500) NULL --legacy Table ID
									, [lg_table_Name] [VARCHAR] (500) NULL --legacy table Name
									, [lg_table_Alias] [VARCHAR](50) NULL --short name for legacy table name
 									, [lg_Field_ID] [BIGINT] NULL --legacy field ID
									, [lg_Field_Name] [VARCHAR](500) null --legacy Field name
									, [lg_Data_Type] [VARCHAR] (500) NULL --legacy data type (no precision)
									, [lg_Max_Len] [INT] NULL --legacy field length
									, [lg_Num_Precison] [INT] NULL --legacy precision
									, [lg_Num_Scale] [INT] NULL --legacy scale
									, [lg_full_Data_Type] [VARCHAR](100) NULL --legacy full datatype
									, [lg_ORDINAL_POSITION] [INT] NULL --legacy ordinal position
									, [lg_null_Stmt] [VARCHAR](100) NULL --legacy null allowable flag
								) ON [PRIMARY]
							WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.MAPPING_CONFIG_AUDIT));
				'

		EXEC (@SQL)
	END
GO
/****** Object:  StoredProcedure [dbo].[usp_create_trigger_production_code_history]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE
	[dbo].[usp_create_trigger_production_code_history] 
		@dbname VARCHAR(255)

AS
	BEGIN
		DECLARE 
			  @SQL NVARCHAR(MAX) = N''
			, @NewLine CHAR(2) = CHAR(13) + CHAR(10)
			, @SQL2 NVARCHAR(MAX) = N''
			, @totalSQL NVARCHAR(MAX)
			, @True BIT = 1
			, @False BIT = 0

		/*Create Trigger for Stored Procedures*/
		SET @SQL = 
			'
				EXEC [' + @dbname + '].dbo.sp_executesql 
					N''
						CREATE OR ALTER TRIGGER 
							[trg__Production_Code_History]
						ON DATABASE
						FOR
							  CREATE_PROCEDURE
							, ALTER_PROCEDURE
							, DROP_PROCEDURE
							AS
								BEGIN
									DECLARE
										@xml xml

									SELECT @xml = EVENTDATA();

									INSERT INTO
										[Filevine_META].[dbo].[Production_Code_History]  
										(
											  [eventtype]
											, [posttime]
											, [spid]
											, [servername]
											, [loginname]
											, [username]
											, [databasename]
											, [schemaname]
											, [objectname]
											, [objecttype]
											, [commandtext]
										)
									SELECT
										  x.Rec.query(''''./EventType'''').value(''''.'''',''''nvarchar(2000)'''' ) as eventtype
										, x.Rec.query(''''./PostTime'''').value(''''.'''',''''nvarchar(2000)'''' ) as posttime
										, x.Rec.query(''''./SPID'''').value(''''.'''',''''nvarchar(2000)'''' ) as spid
										, x.Rec.query(''''./ServerName'''').value(''''.'''',''''nvarchar(2000)'''' ) as servername
										, x.Rec.query(''''./LoginName'''').value(''''.'''',''''nvarchar(2000)'''' ) as loginname
										, x.Rec.query(''''./UserName'''').value(''''.'''',''''nvarchar(2000)'''' ) as [username]
										, x.Rec.query(''''./DatabaseName'''').value(''''.'''',''''nvarchar(2000)'''' ) as [databasename]
										, x.Rec.query(''''./SchemaName'''').value(''''.'''',''''nvarchar(2000)'''' ) as schemaname
										, x.Rec.query(''''./ObjectName'''').value(''''.'''',''''nvarchar(2000)'''' ) as objectname
										, x.Rec.query(''''./ObjectType'''').value(''''.'''',''''nvarchar(2000)'''' ) as objecttype
										, x.Rec.query(''''./TSQLCommand/CommandText'''').value(''''.'''',''''nvarchar(max)'''' ) as commandtext		 	 
									FROM
										@xml.nodes(''''/EVENT_INSTANCE'''') as x(Rec)
								END;
						''
			'

		EXEC (@SQL)

		/*Create Trigger for Functions*/
		SET @SQL = 
			'
				EXEC [' + @dbname + '].dbo.sp_executesql 
					N''
						CREATE OR ALTER TRIGGER 
							[trg__Production_Code_History_functions]
						ON DATABASE
						FOR
							  CREATE_FUNCTION
							, ALTER_FUNCTION
							, DROP_FUNCTION
							AS
								BEGIN
									DECLARE
										@xml xml

									SELECT @xml = EVENTDATA();

									INSERT INTO
										[Filevine_META].[dbo].[Production_Code_History]  
										(
											  [eventtype]
											, [posttime]
											, [spid]
											, [servername]
											, [loginname]
											, [username]
											, [databasename]
											, [schemaname]
											, [objectname]
											, [objecttype]
											, [commandtext]
										)
									SELECT
										  x.Rec.query(''''./EventType'''').value(''''.'''',''''nvarchar(2000)'''' ) as eventtype
										, x.Rec.query(''''./PostTime'''').value(''''.'''',''''nvarchar(2000)'''' ) as posttime
										, x.Rec.query(''''./SPID'''').value(''''.'''',''''nvarchar(2000)'''' ) as spid
										, x.Rec.query(''''./ServerName'''').value(''''.'''',''''nvarchar(2000)'''' ) as servername
										, x.Rec.query(''''./LoginName'''').value(''''.'''',''''nvarchar(2000)'''' ) as loginname
										, x.Rec.query(''''./UserName'''').value(''''.'''',''''nvarchar(2000)'''' ) as [username]
										, x.Rec.query(''''./DatabaseName'''').value(''''.'''',''''nvarchar(2000)'''' ) as [databasename]
										, x.Rec.query(''''./SchemaName'''').value(''''.'''',''''nvarchar(2000)'''' ) as schemaname
										, x.Rec.query(''''./ObjectName'''').value(''''.'''',''''nvarchar(2000)'''' ) as objectname
										, x.Rec.query(''''./ObjectType'''').value(''''.'''',''''nvarchar(2000)'''' ) as objecttype
										, x.Rec.query(''''./TSQLCommand/CommandText'''').value(''''.'''',''''nvarchar(max)'''' ) as commandtext		 	 
									FROM
										@xml.nodes(''''/EVENT_INSTANCE'''') as x(Rec)  
								END;
					''
			'

		EXEC (@SQL)
		
	END
GO
/****** Object:  StoredProcedure [dbo].[usp_createdb]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE 
	[dbo].[usp_createdb] 
		  @dbname VARCHAR(255)
		, @DebugFlag BIT = 0

AS
	BEGIN
		DECLARE 
			  @SQL NVARCHAR(MAX) = N''
			, @NewLine CHAR(2) = CHAR(13) + CHAR(10)
			, @SQL2 NVARCHAR(MAX) = N''
			, @totalSQL NVARCHAR(MAX)
			, @True BIT = 1
			, @False BIT = 0

		/*Create the database if not exists*/
		IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE [name] = @dbname)
			BEGIN
				-- Size: Data = 20MB, Log=4MB. Autogrow 10% on both, no limit
				SET @SQL =
					N'
						CREATE DATABASE 
							[' + @dbname + ']
						CONTAINMENT = NONE
						ON PRIMARY 
						(
							  NAME = N''' + @dbname + '''
							, FILENAME = N''D:\SQL_DATA\' + @dbname + '.mdf'' 
							, SIZE = 20MB 
							, FILEGROWTH = 10%
						)
						LOG ON 
						( 
							  NAME = N''' + @dbname + '_log''
							, FILENAME = N''D:\SQL_DATA\' + @dbname + '_log.ldf'' 
							, SIZE = 4MB 
							, FILEGROWTH = 10%
						)
						COLLATE 
							SQL_Latin1_General_CP1_CI_AS
					'
				
				PRINT 'CREATE DATABASE'

				IF @DebugFlag = @True
					BEGIN
						SELECT @SQL 'Create Database SQL'
					END
				
				EXEC (@SQL)
			END

		/*Set Recovery Mode Simple*/
		BEGIN
			SET @SQL =
				N'
					USE [' + @dbname + ']
					
					ALTER DATABASE
						[' + @dbname + '] 
					SET RECOVERY SIMPLE
				'
			
			IF @DebugFlag = @True
				BEGIN
					SELECT @SQL 'Set Recovery Mode SQL'
				END
			
			EXEC (@SQL)
		END

		/*Create Database Roles*/
		BEGIN
			PRINT 'CREATE DATABASE ROLES'
		END

		/*Create Users*/
		BEGIN
			PRINT 'CREATE USERS'
			
			EXEC Filevine_META.[dbo].[usp_addusers]
				@dbname = @dbname
		END

		/*Create Production Code History Triggers*/
		BEGIN
			PRINT 'CREATE PRODUCTION CODE HISTORY TRIGGERS'

			EXEC [Filevine_META].[dbo].[usp_create_trigger_production_code_history]
				@dbname = @dbname	
		END
		
END
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateServerRoles]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_CreateServerRoles]

AS
	BEGIN
		/*METAL_User Role*/
		IF NOT EXISTS(SELECT 1 FROM sys.server_principals WHERE name = 'METAL_User')
			BEGIN
				CREATE SERVER ROLE [METAL_User];
				ALTER SERVER ROLE [securityadmin] ADD MEMBER [METAL_User]
				ALTER SERVER ROLE [serveradmin] ADD MEMBER [METAL_User]
				ALTER SERVER ROLE [setupadmin] ADD MEMBER [METAL_User]
				ALTER SERVER ROLE [processadmin] ADD MEMBER [METAL_User]
				ALTER SERVER ROLE [diskadmin] ADD MEMBER [METAL_User]
				ALTER SERVER ROLE [dbcreator] ADD MEMBER [METAL_User]
				ALTER SERVER ROLE [bulkadmin] ADD MEMBER [METAL_User]
			END

		/*DM_user Role*/
		IF NOT EXISTS(SELECT 1 FROM sys.server_principals WHERE name = 'DM_user')
			BEGIN
				CREATE SERVER ROLE [DM_user]
				ALTER SERVER ROLE [setupadmin] ADD MEMBER [DM_user]
				ALTER SERVER ROLE [dbcreator] ADD MEMBER [DM_user]
				ALTER SERVER ROLE [bulkadmin] ADD MEMBER [DM_user]
			END

		/*Partner_User Role*/
		IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Partner_User')
			BEGIN
				CREATE SERVER ROLE [Partner_User]
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[usp_database_activity]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_database_activity]
as
begin
WITH agg AS
(
SELECT
last_user_seek,
last_user_scan,
last_user_lookup,
last_user_update,d.database_id, 
sp.status number_of_connections,
mf.physical_name,
size * 8/1024 mb_size
FROM sys.databases d 
inner join sys.master_files mf on d.database_id = mf.database_id
LEFT outer JOIN sys.sysprocesses sp ON d.database_id = sp.dbid
left outer join sys.dm_db_index_usage_stats ind on d.database_id = ind.database_id
)

SELECT
database_id, DB_NAME(database_id) DatabaseName,
last_read = MAX(last_read),
last_write = MAX(last_write),
number_of_connections =count(distinct number_of_connections),
mb_size = mb_size,
physical_name=physical_name,
lm.last_modified_object_Date
FROM
(
SELECT database_id,last_user_seek, NULL,mb_size,physical_name,number_of_connections FROM agg
UNION ALL
SELECT database_id,last_user_scan, NULL,mb_size ,physical_name,number_of_connections FROM agg
UNION ALL
SELECT database_id,last_user_lookup, NULL,mb_size,physical_name,number_of_connections FROM agg
UNION ALL
SELECT database_id,NULL, last_user_update,mb_size,physical_name,number_of_connections FROM agg
) AS x (database_id,last_read, last_write,mb_size,physical_name,number_of_connections)
left outer join Maintenance.dbo.last_mod_db_obj lm on DB_NAME(database_id) = lm.dbname
group by database_id,mb_size,physical_name,number_of_connections,lm.last_modified_object_Date
order by DatabaseName
end
GO
/****** Object:  StoredProcedure [dbo].[usp_database_size]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   PROC [dbo].[usp_database_size]
as
begin
with fs
as
(
select database_id, type, size * 8.0 / 1024 size, physical_name
from sys.master_files
)
select 
name,
(select sum(size) from fs where type = 0 and fs.database_id = db.database_id) DataFileSizeMB,
(select sum(size) from fs where type = 1 and fs.database_id = db.database_id) LogFileSizeMB,
    (select max(fs.physical_name) from fs where type = 0 and fs.database_id = db.database_id) physical_name
from sys.databases db
--WHERE name IN ('6198_cohen_gl')
WHERE (select max(fs.physical_name) from fs where type = 0 and fs.database_id = db.database_id) LIKE '%c:\%'
order by [DataFileSizeMB] desc;
with fs


as
(
select database_id, type, size * 8.0 / 1024 size, physical_name
from sys.master_files
)
select 
name,
(select sum(size) from fs where type = 0 and fs.database_id = db.database_id) DataFileSizeMB,
(select sum(size) from fs where type = 1 and fs.database_id = db.database_id) LogFileSizeMB,
    (select max(fs.physical_name) from fs where type = 1 and fs.database_id = db.database_id) physical_name
from sys.databases db
WHERE (select max(fs.physical_name) from fs where type = 0 and fs.database_id = db.database_id) LIKE '%c:\%'
order by [LogFileSizeMB] DESC
end
GO
/****** Object:  StoredProcedure [dbo].[usp_docScan_SPLIT]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE
	[dbo].[usp_docScan_SPLIT]
		  @docscanDatabase varchar(max),
		  @docscanTable varchar(max)
AS
	BEGIN 
		--Jon Hanna (9-8-22)
		--Creates new doc scan table and partitions the folderPath field into individual folder fields
		--------------------------------------------------------------------------------------------------------

		----FOR TESTING
		--declare @docscanDatabase varchar(max),@docscanTable varchar(max)
		--select @docScanDatabase = '[7284_KlineSpecter_GL]', @docScanTable = '[S3DocScan_HDrive]'
		--------------------------------------------------------------------------------------------------------

		declare @fullDbTable varchar(max), @fullDbTableSPLIT varchar(max)
		select @fullDbTable =  '['+replace(replace(@docscanDatabase,'[',''),']','')+']..['+replace(replace(@docscanTable,'[',''),']','')+']'
		select @fullDbTableSPLIT =  '['+replace(replace(@docscanDatabase,'[',''),']','')+']..['+replace(replace(@docscanTable,'[',''),']','')+'_SPLIT]'
		
		declare @sql nvarchar(max),@maxFolderPath varchar(max), @maxFolderPathLen int, @maxFolderNumber int
		select @sql = 'select @length = max(len(folderPath)) 
						from '+@fullDbTable
		execute sp_executesql @SQL, N'@length int OUTPUT', @length=@maxFolderPathLen OUTPUT
		--select @maxFolderPathLen

		select @sql = 'select top 1 @folderPath = FolderPath
						from '+@fullDbTable+'
						where len(FolderPath) = '+convert(varchar(max),@maxFolderPathLen)
		execute sp_executesql @SQL, N'@folderPath varchar(max) OUTPUT', @folderPath=@maxFolderPath OUTPUT
		--select @maxFolderPath

		select @maxFolderNumber = len(@maxFolderPath) - len(replace(@maxFolderPath, '/', ''))
		--select @maxFolderNumber

		-----------------------------------------------------------------------------------------------------------------------------------
		--create new s3docscan table
		select @sql = 'drop table if exists '+@fullDbTableSPLIT+'
						
						select
						*
						into '+@fullDbTableSPLIT+'
						from '+@fullDbTable
		exec (@sql)

		--loop and add number of folders needed to new s3docscan table (using maxFolderPathLen to determine size of field - needed for nonclustered index)
		DECLARE @Counter INT 
		SET @Counter=1
		WHILE ( @Counter <= @maxFolderNumber)
		BEGIN
			select @sql = 'ALTER TABLE '+@fullDbTableSPLIT+'
							ADD folder_'+convert(varchar(max),@counter)+' varchar('+convert(varchar(max),@maxFolderPathLen)+')'
							/*
							CREATE NONCLUSTERED INDEX IX_S3DocScan_SPLIT_folder'+convert(varchar(max),@counter)+'
						    ON '+@fullDbTableSPLIT+' (folder_'+convert(varchar(max),@counter)+');   
							'*/	
				exec (@sql)
			SET @Counter  = @Counter  + 1
		END

		--update each folder field (Folder1 - FolderN)
		SET @Counter=1
		WHILE ( @Counter <= @maxFolderNumber)
		BEGIN
			select @sql = 'UPDATE '+@fullDbTableSPLIT+'
							SET folder_'+convert(varchar(max),@counter)+' = 
							CASE 
								WHEN '+CONVERT(VARCHAR(MAX),@counter-1)+' = 0
								THEN replace(substring(folderPath,1,charindex(''/'',folderPath,1)),''/'','''')
								ELSE
									replace(
										substring(
												folderpath
												,[filevine_meta].[dbo].[udf_findNthOccurance](''/'',folderPath,'+CONVERT(VARCHAR(MAX),@counter-1)+')
												,[filevine_meta].[dbo].[udf_findNthOccurance](''/'',folderPath,'+CONVERT(VARCHAR(MAX),@counter)+')-[filevine_meta].[dbo].[udf_findNthOccurance](''/'',folderPath,'+CONVERT(VARCHAR(MAX),@counter-1)+')
												) 
										,''/'','''')
							END
							'		
				EXEC (@sql)
			SET @Counter  = @Counter  + 1
		END

		print @fullDbTableSPLIT + ' has been created.'
	END

	
GO
/****** Object:  StoredProcedure [dbo].[usp_drop_all_constraints_on_table]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[usp_drop_all_constraints_on_table] 
	-- Add the parameters for the stored procedure here
	@tablename varchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	 set nocount on
   set xact_abort on
   while 0=0 begin
      declare @constraintName varchar(128)
      set @constraintName = (
         select top 1 constraint_name
            from information_schema.constraint_column_usage
            where table_name = @tableName  )
      if @constraintName is null break
      exec ('alter table "'+@tableName+'" drop constraint "'+@constraintName+'"')
      end
END
GO
/****** Object:  StoredProcedure [dbo].[usp_find_column_in_legacy]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[usp_find_column_in_legacy]
	-- Add the parameters for the stored procedure here
	@databasename varchar(max),
	@ColumnIn varchar(max),
	@debugflag bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @sql varchar(max)

set @sql = 'USE '+ @databasename + '
SELECT      COLUMN_NAME AS ''ColumnName''
            ,TABLE_NAME AS  ''TableName''
FROM        INFORMATION_SCHEMA.COLUMNS
WHERE       lower(COLUMN_NAME) LIKE ''%'+lower(@ColumnIn)+'%''
ORDER BY    TableName
            ,ColumnName;'

if @debugflag = 1 
	Select @sql
else
	exec(@sql)

END
GO
/****** Object:  StoredProcedure [dbo].[usp_get_staging_table_constraints]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_get_staging_table_constraints]
	@DebugFlag int,
	@LegacyDb varchar(500),
	@FVProductionPrefix varchar(500)
	
AS
begin
Declare @DebugFlagExt int = @DebugFlag
Declare @DatabaseBrackets varchar(500)
Declare @Sql varchar(max)


set @DatabaseBrackets = case when charindex('[',@LegacyDb,1) = 0 then '['+@LegacyDb+']' 
									else @LegacyDb end
set @Sql = 'USE ' + @DatabaseBrackets + '
SELECT
t.[name] AS [TABLE_NAME],
c.[name] AS [COLUMN_NAME],
cc.[definition] AS [CONSTRAINT_DEFINITION]
FROM sys.tables AS t
INNER JOIN sys.columns AS c ON t.[object_id] = c.[object_id]
INNER JOIN sys.check_constraints AS cc ON t.[object_id] = cc.[parent_object_id] AND c.[column_id] = cc.[parent_column_id]
WHERE t.[name] LIKE ''%'+@FVProductionPrefix +'%''
ORDER BY t.[name], c.[column_id]
'

if @DebugFlagExt = 1
	select @Sql
else
	exec(@Sql)

end
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportSybaseAnywhere_AllVersions]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_ImportSybaseAnywhere_AllVersions]
	@DB_Name varchar(255), @LegacyDB_FilePath varchar(500)
as
--
-- How to run: EXEC dbo.usp_ImportSybaseAnywhere_AllVersions '9999_Client','C:\temp\9999_ClientName\Needles.db'
-- Argument 1: dbname (db gets created)
-- Argument 2: filepath (include filename and also have log file in same directory in case it is linked
-- Flow:       1) Get the legacy sybase database version
--		       2) Create the export directory
--		       3) Extract all tables from Needles.db
--		       4) Loop thru each table and create a file in the export directory
--		       5) Import files into the client's staging db
-- Comment:    This proc will load all supported Sybase versions, or will return an error
--
DECLARE	@isExists INT
		, @cmd varchar(8000)
		, @arg0 varchar(1000)
		, @arg1 varchar(4000)
		, @arg2 varchar(4000)
		, @return_code int = 1
		, @looper int = 0	
		, @Sybase_Export_Path varchar(500)
		, @gettables varchar(4000)
		, @looptables varchar(4000)

-- 1) First, query the legacy sybase database to get the correct driver

	SET @arg0 = '"C:\Windows\system32\cmd.exe" /c '
	SET @arg2 = '"select version from SYSHISTORY"'

	-- check to make sure the db file passed in even exists, exit if it doesn't
	exec master.dbo.xp_fileexist @LegacyDB_FilePath, @isExists OUTPUT
	if @isExists != 1
	BEGIN
		PRINT 'ERROR !!! ' + @LegacyDB_FilePath + ' !!! does NOT exist'
		RETURN
	END
	
	-- try sybase version 17 first
	SET @arg1 = 'cd C:\Program Files\SQL Anywhere 17\Bin64 && dbisql.com -c "UID=dba;PWD=sql;DBF='+@LegacyDB_FilePath+'" -onerror exit '	
		
	WHILE @return_code != 0
	BEGIN
		SET @cmd =  @arg1 + @arg2	
		
		CREATE TABLE #output_v (id int identity(1,1), sybase_version nvarchar(255) null)		
		INSERT #output_v exec @return_code = master..xp_cmdshell @cmd -- Run cmd to try to get the db version, if fails, try the next driver in the loop below

		if @return_code != 0
		  BEGIN
			drop TABLE #output_v			
			set @looper = @looper + 1
			
			if @looper = 1 set  @arg1 = 'cd C:\Program Files\SQL Anywhere 16\Bin64 && dbisql.com -c "UID=dba;PWD=sql;DBF='+@LegacyDB_FilePath+'" -onerror exit ' -- try version 16					
			if @looper = 2 set  @arg1 = 'cd C:\Program Files\SQL Anywhere 12\Bin64 && dbisql.com -c "UID=dba;PWD=sql;DBF='+@LegacyDB_FilePath+'" -onerror exit ' -- try version 12
			if @looper = 3 BEGIN Select 'ERROR - Sybase version not supported, db must be upgraded, refer to instructions: filevine.atlassian.net/wiki/spaces/DM/pages/44728321/Import+Database+from+Backups' RETURN END -- no version works, so exit with error
		  END
	END	
	
	select [sybase_version] from #output_v where id = (select max(id) from #output_v where sybase_version like '%.%.%') -- return version to caller
	drop TABLE #output_v
	/*** @arg1 *** is now set and can used to extract data from the legacy database using the correct driver ***/

--2) Create a directory for the Sybase files to be exported to

	SET @Sybase_Export_Path = substring(@LegacyDB_FilePath,0,len(@LegacyDB_FilePath)-charindex('\',reverse(@LegacyDB_FilePath))+2) + 'sybase_exports\'
	SET @cmd = 'mkdir ' + @Sybase_Export_Path
	EXEC @return_code = master..xp_cmdshell @cmd
	SELECT @return_code as 'ReturnCode - Create Export Dir' -- 0 = success 1 = failure

--3) Run this shell cmd against Needles.db to get all TABLEs and capture output for use in step 4

	SET @gettables = 
	'"DECLARE @unloadpath varchar(255) = '''+replace(@Sybase_Export_Path,'\','\\\\')+''' 
	SELECT ''SELECT * FROM '' + replace(TABLE_name,''.txt'','''') + ''; OUTPUT TO '''''' + @unloadpath + '''' + TABLE_name + ''.txt'''' FORMAT ASCII DELIMITED BY ''''\x09'''' QUOTE '''''''' WITH COLUMN NAMES;'' 
	FROM sysTABLE 
	where primary_root != 0 and creator=1 
	order by TABLE_name"'

	SET @gettables = replace(@gettables,char(10),'')
	SET @gettables = replace(@gettables,char(13),'')

	-- Here we use @arg1 from above to run the correct sybase version
	SET @cmd = @arg1 + @gettables
	----------------    DEBUG
	--select @cmd as 'RunCommand - Get Legacy Tables'
 
	CREATE TABLE #output (id int identity(1,1), output nvarchar(255) null)
	INSERT #output exec @return_code = master..xp_cmdshell @cmd
	SELECT @return_code as 'ReturnCode - Get Legacy Tables' 

	----------------    DEBUG
	--select * from #output

--4) Loop thru results FROM step 3 and output tab delimited txt file for each TABLE

	CREATE TABLE #loop_output (id int identity(1,1), output nvarchar(255) null)
	DECLARE @i int
	SELECT @i = min(ID) FROM #output where output like 'SELECT%'
	WHILE @i is not null
	BEGIN
	  SELECT @looptables = output FROM #output where id = @i
	  SET @cmd = @arg1 + @looptables

		INSERT #loop_output exec @return_code = master..xp_cmdshell @cmd 
		SELECT @return_code as 'ReturnCode - Loop thru Tables'
		SELECT * FROM #loop_output

	  SELECT @i = min(ID) FROM #output where ID > @i and output like 'SELECT%'
	END

--5) Import files FROM step 4 into sql using bulk INSERT inside loop
	SET @DB_Name = replace(replace(@DB_Name,'[',''),']','')

	-- CREATE THE CLIENT STAGING DATABASE
	EXEC Filevine_META.dbo.usp_createdb @DB_Name

	SET @CMD = '
	USE ['+@DB_Name+']

	DECLARE @path varchar(255),@cmd VARCHAR(500), @filename varchar(255), @sql varchar(max)
	DROP TABLE FileNames
	CREATE TABLE FileNames([file] varchar(255), [path] varchar(255))
	--get the list of files to process:
	SET @path = '''+@Sybase_Export_Path+'''
	SET @cmd = ''dir '' + @path + ''*.txt /b''
	INSERT INTO  FileNames([file])
	EXEC Master..xp_cmdShell @cmd
	UPDATE FileNames SET [path] = @path where [path] is null

	

	--cursor loop
	DECLARE c1 cursor for SELECT [path],[file]
	FROM FileNames
	WHERE [file] in
	(
		SELECT [file] FROM FileNames
		where replace([file],''.txt'','''') not in
		(
			SELECT TABLE_name FROM information_schema.TABLES
		)
	)
	OPEN c1
	FETCH next FROM c1 into @path,@filename
	WHILE @@fetch_status <> -1
		BEGIN
			IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = ''vw_temp_csvdata'')
						BEGIN
							DROP VIEW [vw_temp_csvdata];
						END	
						

						IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables WHERE TABLE_NAME = ''temp_csvdata'')
						BEGIN
							DROP table [temp_csvdata];
						END	
				CREATE TABLE temp_csvdata (ID bigint identity(1,1), rowdata varchar(max))

			EXEC(''CREATE VIEW [vw_temp_csvdata] AS SELECT rowdata CsvData FROM temp_csvdata'')

			truncate TABLE temp_csvdata	
			SET @sql = ''BULK INSERT vw_temp_csvdata FROM '''''' + @path + @filename + '''''' ''
				+ ''     WITH ( 
						FIELDTERMINATOR = ''''\t'''', 
						ROWTERMINATOR = ''''\n'''', 
						FIRSTROW = 1
					) ''
			print @sql
			exec (@sql)

			DECLARE @toprow varchar(max), @fieldnames varchar(max)
			SELECT top 1 @toprow = rowdata FROM temp_csvdata where ID = 1
			SELECT @toprow

			--each column is varchar max for now, need to map data types FROM schema meta later
			SET @toprow = replace(@toprow,''"'','''')
			SELECT @fieldnames = ''['' + replace(@toprow,char(9),''] varchar(max), ['') + ''] varchar(max)''

			SET @sql = ''drop TABLE [''+replace(@filename,''.txt'','''')+''] CREATE TABLE [''+replace(@filename,''.txt'','''')+''] (''+ @fieldnames +'')''
			print @sql
			exec (@sql)

			SET @sql = ''BULK INSERT [''+replace(@filename,''.txt'','''')+''] FROM '''''' + @path + @filename + '''''' '' + ''
						WITH ( 
						FIELDTERMINATOR = ''''\t'''', 
						ROWTERMINATOR = ''''0x0a'''', 
						FIRSTROW = 2)''
			print @sql
			exec (@sql)

		fetch next FROM c1 into @path,@filename
		END
	CLOSE c1
	DEALLOCATE c1

	SELECT t.name
	FROM sys.TABLEs AS t
	WHERE t.is_ms_shipped = 0 
	order by t.name'

	EXEC(@cmd)

drop TABLE #output
drop TABLE #loop_output
GO
/****** Object:  StoredProcedure [dbo].[usp_ImportSybaseAnywhere_AllVersions_dbowner_not_dba]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [dbo].[usp_ImportSybaseAnywhere_AllVersions_dbowner_not_dba]
	@DB_Name varchar(255), @LegacyDB_FilePath varchar(500)
as
--
-- How to run: EXEC dbo.usp_ImportSybaseAnywhere_AllVersions '9999_Client','C:\temp\9999_ClientName\Needles.db'
-- Argument 1: dbname (db gets created)
-- Argument 2: filepath (include filename and also have log file in same directory in case it is linked
-- Flow:       1) Get the legacy sybase database version
--		       2) Create the export directory
--		       3) Extract all tables from Needles.db
--		       4) Loop thru each table and create a file in the export directory
--		       5) Import files into the client's staging db
-- Comment:    This proc will load all supported Sybase versions, or will return an error
--
DECLARE	@isExists INT
		, @cmd varchar(8000)
		, @arg0 varchar(1000)
		, @arg1 varchar(4000)
		, @arg2 varchar(4000)
		, @return_code int = 1
		, @looper int = 0	
		, @Sybase_Export_Path varchar(500)
		, @gettables varchar(4000)
		, @looptables varchar(4000)

-- 1) First, query the legacy sybase database to get the correct driver

	SET @arg0 = '"C:\Windows\system32\cmd.exe" /c '
	SET @arg2 = '"select version from SYSHISTORY"'

	-- check to make sure the db file passed in even exists, exit if it doesn't
	exec master.dbo.xp_fileexist @LegacyDB_FilePath, @isExists OUTPUT
	if @isExists != 1
	BEGIN
		PRINT 'ERROR !!! ' + @LegacyDB_FilePath + ' !!! does NOT exist'
		RETURN
	END
	
	-- try sybase version 17 first
	SET @arg1 = 'cd C:\Program Files\SQL Anywhere 17\Bin64 && dbisql.com -c "UID=dba;PWD=sql;DBF='+@LegacyDB_FilePath+'" -onerror exit '	
		
	WHILE @return_code != 0
	BEGIN
		SET @cmd =  @arg1 + @arg2	
		
		CREATE TABLE #output_v (id int identity(1,1), sybase_version nvarchar(255) null)		
		INSERT #output_v exec @return_code = master..xp_cmdshell @cmd -- Run cmd to try to get the db version, if fails, try the next driver in the loop below

		if @return_code != 0
		  BEGIN
			drop TABLE #output_v			
			set @looper = @looper + 1
			
			if @looper = 1 set  @arg1 = 'cd C:\Program Files\SQL Anywhere 16\Bin64 && dbisql.com -c "UID=dba;PWD=sql;DBF='+@LegacyDB_FilePath+'" -onerror exit ' -- try version 16					
			if @looper = 2 set  @arg1 = 'cd C:\Program Files\SQL Anywhere 12\Bin64 && dbisql.com -c "UID=dba;PWD=sql;DBF='+@LegacyDB_FilePath+'" -onerror exit ' -- try version 12
			if @looper = 3 BEGIN Select 'ERROR - Sybase version not supported, db must be upgraded, refer to instructions: filevine.atlassian.net/wiki/spaces/DM/pages/44728321/Import+Database+from+Backups' RETURN END -- no version works, so exit with error
		  END
	END	
	
	select [sybase_version] from #output_v where id = (select max(id) from #output_v where sybase_version like '%.%.%') -- return version to caller
	drop TABLE #output_v
	/*** @arg1 *** is now set and can used to extract data from the legacy database using the correct driver ***/

--2) Create a directory for the Sybase files to be exported to

	SET @Sybase_Export_Path = substring(@LegacyDB_FilePath,0,len(@LegacyDB_FilePath)-charindex('\',reverse(@LegacyDB_FilePath))+2) + 'sybase_exports\'
	SET @cmd = 'mkdir ' + @Sybase_Export_Path
	EXEC @return_code = master..xp_cmdshell @cmd
	SELECT @return_code as 'ReturnCode - Create Export Dir' -- 0 = success 1 = failure

--3) Run this shell cmd against Needles.db to get all TABLEs and capture output for use in step 4

	SET @gettables = 
	'"DECLARE @unloadpath varchar(255) = '''+replace(@Sybase_Export_Path,'\','\\\\')+''' 
	SELECT ''SELECT * FROM dbowner.'' + replace(TABLE_name,''.txt'','''') + ''; OUTPUT TO '''''' + @unloadpath + '''' + TABLE_name + ''.txt'''' FORMAT ASCII DELIMITED BY ''''\x09'''' QUOTE '''''''' WITH COLUMN NAMES;'' 
	FROM sysTABLE 
	where primary_root != 0  
	order by TABLE_name"'

	SET @gettables = replace(@gettables,char(10),'')
	SET @gettables = replace(@gettables,char(13),'')

	-- Here we use @arg1 from above to run the correct sybase version
	SET @cmd = @arg1 + @gettables
	----------------    DEBUG
	--select @cmd as 'RunCommand - Get Legacy Tables'
 
	CREATE TABLE #output (id int identity(1,1), output nvarchar(255) null)
	INSERT #output exec @return_code = master..xp_cmdshell @cmd
	SELECT @return_code as 'ReturnCode - Get Legacy Tables' 

	----------------    DEBUG
	--select * from #output

--4) Loop thru results FROM step 3 and output tab delimited txt file for each TABLE

	CREATE TABLE #loop_output (id int identity(1,1), output nvarchar(255) null)
	DECLARE @i int
	SELECT @i = min(ID) FROM #output where output like 'SELECT%'
	WHILE @i is not null
	BEGIN
	  SELECT @looptables = output FROM #output where id = @i
	  SET @cmd = @arg1 + @looptables

		INSERT #loop_output exec @return_code = master..xp_cmdshell @cmd 
		SELECT @return_code as 'ReturnCode - Loop thru Tables'
		SELECT * FROM #loop_output

	  SELECT @i = min(ID) FROM #output where ID > @i and output like 'SELECT%'
	END

--5) Import files FROM step 4 into sql using bulk INSERT inside loop
	SET @DB_Name = replace(replace(@DB_Name,'[',''),']','')

	--CREATE CLIENT STAGING DATABASE
	EXEC Filevine_META.dbo.usp_createdb @DB_Name

	SET @CMD = '
	USE ['+@DB_Name+']

	DECLARE @path varchar(255),@cmd VARCHAR(500), @filename varchar(255), @sql varchar(max)
	DROP TABLE FileNames
	CREATE TABLE FileNames([file] varchar(255), [path] varchar(255))
	--get the list of files to process:
	SET @path = '''+@Sybase_Export_Path+'''
	SET @cmd = ''dir '' + @path + ''*.txt /b''
	INSERT INTO  FileNames([file])
	EXEC Master..xp_cmdShell @cmd
	UPDATE FileNames SET [path] = @path where [path] is null


	--cursor loop
	DECLARE c1 cursor for SELECT [path],[file]
	FROM FileNames
	WHERE [file] in
	(
		SELECT [file] FROM FileNames
		where replace([file],''.txt'','''') not in
		(
			SELECT TABLE_name FROM information_schema.TABLES
		)
	)
	OPEN c1
	FETCH next FROM c1 into @path,@filename
	WHILE @@fetch_status <> -1
		BEGIN
			IF NOT exists(SELECT * FROM sysobjects WHERE NAME = ''temp_csvdata'' and xtype=''u'')
				CREATE TABLE temp_csvdata (rowdata varchar(max))
			truncate TABLE temp_csvdata	
			SET @sql = ''BULK INSERT temp_csvdata FROM '''''' + @path + @filename + '''''' ''
				+ ''     WITH ( 
						FIELDTERMINATOR = ''''\t'''', 
						ROWTERMINATOR = ''''\n'''', 
						FIRSTROW = 1
					) ''
			print @sql
			exec (@sql)

			DECLARE @toprow varchar(max), @fieldnames varchar(max)
			SELECT top 1 @toprow = rowdata FROM temp_csvdata
			SELECT @toprow

			--each column is varchar max for now, need to map data types FROM schema meta later
			SET @toprow = replace(@toprow,''"'','''')
			SELECT @fieldnames = ''['' + replace(@toprow,char(9),''] varchar(max), ['') + ''] varchar(max)''

			SET @sql = ''drop TABLE [''+replace(@filename,''.txt'','''')+''] CREATE TABLE [''+replace(@filename,''.txt'','''')+''] (''+ @fieldnames +'')''
			print @sql
			exec (@sql)

			SET @sql = ''BULK INSERT [''+replace(@filename,''.txt'','''')+''] FROM '''''' + @path + @filename + '''''' '' + ''
						WITH ( 
						FIELDTERMINATOR = ''''\t'''', 
						ROWTERMINATOR = ''''0x0a'''', 
						FIRSTROW = 2)''
			print @sql
			exec (@sql)

		fetch next FROM c1 into @path,@filename
		END
	CLOSE c1
	DEALLOCATE c1

	SELECT t.name
	FROM sys.TABLEs AS t
	WHERE t.is_ms_shipped = 0 
	order by t.name'

	EXEC(@cmd)

drop TABLE #output
drop TABLE #loop_output
GO
/****** Object:  StoredProcedure [dbo].[usp_load_staging_to_import]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE 
	[dbo].[usp_load_staging_to_import]
		  @DebugFlag BIT
		, @ImportServer VARCHAR(500)
		, @LegacyDb VARCHAR(500)
		, @FVProductionPrefix VARCHAR(500)
		, @PEIDList VARCHAR(MAX) null  --example ' where ProjectExternalID in (''ACTOS.9FC832C5-B3F6-45AC-A331-90758A132551'',  ''PRADAXA.EE7A5D9C-A08A-44F0-A025-CDDAAD7762F5'',  ''XARELTO.8BE881BC-9487-4BA1-922A-AF6DB3EDCDFF'',  ''RISPERDAL.A36CCE1D-AC6B-418F-9B1B-BAFB3B27DBC6'')'
		, @TruncateTables BIT
		--,	@CEIDList VARCHAR(MAX) null future 

AS
	BEGIN
		DECLARE 
			  @return_value INT
			, @DatabaseBrackets VARCHAR(500)
			, @SQL VARCHAR(MAX)
			, @temptable VARCHAR(500)
			, @True BIT = 1
			, @False BIT = 0
		 
		SET @LegacyDb = REPLACE(REPLACE(@LegacyDb, '[', ''), ']', '')
		SET @DatabaseBrackets = '[' + REPLACE(REPLACE(@LegacyDb, '[', ''), ']', '') + ']'
		SET @temptable = 'tempProdList'
		
		DECLARE
			  @MigrationConfigTable VARCHAR(1000) = 'MIGRATION_CONFIG'
			, @PT1Schema VARCHAR(1000) = 'PT1'

		DECLARE
			@LegacyUse VARCHAR(1000) = 'USE ' + @DatabaseBrackets
		
		SELECT @DatabaseBrackets

		DECLARE @reSETMigrationConfig VARCHAR(MAX) = @LegacyUse + 
			'
				UPDATE
					[' + @PT1Schema + '].[' + @MigrationConfigTable + ']
				SET
					InsertedIntoFVProdImport = ''N''
			'

		IF @TruncateTables = @True 
			BEGIN
				IF @DebugFlag = @True
					SELECT 
						@reSETMigrationConfig
				ELSE
					EXEC(@reSETMigrationConfig)
			END

		SET @SQL = @LegacyUse + 
			'
				IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @temptable + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
					DROP TABLE [' + @PT1Schema + '].[' + @temptable + ']; 

				DECLARE 
					  @maxtableCount INT
					, @maxtablecolumnCount INT
					, @prodTablename VARCHAR(500)
					, @stageTableName VARCHAR(500)
					, @tableColumnName VARCHAR(500)
					, @sqlColumnList VARCHAR(MAX)
					, @sqlColumnListInsert VARCHAR(MAX)
					, @sqlTruncate VARCHAR(MAX)
					, @SqlInsert VARCHAR(MAX)
					, @processCounter INT
					, @processColumnCounter INT
					, @clientDatabase VARCHAR(500)
					, @FVTablePrefix VARCHAR(500)
					, @QAQuery VARCHAR(500)
					, @InsertedIntoFVProdImport CHAR(1)
					, @sql VARCHAR(MAX)
					, @temptable VARCHAR(500)
					, @updateSql VARCHAR(MAX)
					, @whereClausePEID VARCHAR(MAX)
					, @whereClauseCEID VARCHAR(MAX)
					, @istherePEID BIT
					, @isthereCEID BIT

				SET @whereClausePEID = 
					''' 
						+ REPLACE(@PEIDList, '''', '''''') + 
					'''

				SELECT 
				 	  DENSE_RANK() OVER (ORDER BY prodtable) AS groupnum
					, *
				INTO 
					[' + @PT1Schema + '].[' + @temptable + ']
				FROM 
					(
						SELECT DISTINCT
							  [TABLE_NAME] [prodtable]
							, [NewStagingTablename] [clienttable]
							, [Column_name]
							, [Ordinal_position]
							, [InsertedIntoFVProdImport]
						FROM
							[' + @PT1Schema + '].[' + @MigrationConfigTable + ']
					)A 

				SELECT
					*
				FROM
					[' + @PT1Schema + '].[' + @temptable + ' ] 

				SET @processCounter = 1
				SET @maxtableCount = (SELECT MAX(groupnum) from [' + @PT1Schema + '].[' + @temptable + '])

				SELECT @maxtableCount

				WHILE @processCounter <= @maxtableCount
					BEGIN
						SET @maxtablecolumnCount = 0
						SET @processColumnCounter = 1
						SET @sqlColumnList = ''''
						SET @sqlColumnListInsert = ''''
	
						SELECT 
							@InsertedIntoFVProdImport = ISNULL(InsertedIntoFVProdImport, ''N'') 
						FROM
							[' + @PT1Schema + '].[' + @temptable + ']
						WHERE
							groupnum = @processCounter

						SELECT 
							@maxtablecolumnCount = MAX(Ordinal_position) 
						FROM
							[' + @PT1Schema + '].[' + @temptable + ']
						WHERE
							groupnum = @processCounter
	
						SET @prodTablename = (SELECT DISTINCT prodtable FROM [' + @PT1Schema + '].[' + @temptable + '] WHERE groupnum = @processCounter)
						SET @stageTableName = (SELECT DISTINCT clienttable FROM [' + @PT1Schema + '].[' + @temptable + '] WHERE groupnum = @processCounter)
 
						IF @InsertedIntoFVProdImport = ''Y''
							BEGIN
								SET @QAQuery = ''select count(*), __ImportStatus from ' + @ImportServer + '.dbo.['' + @prodTablename + ''] group by __ImportStatus''
								SELECT ''ALREADY LOADED '', @QAQuery
							END
						ELSE 
							BEGIN
								SELECT 
									  @sqlColumnList = COALESCE(@sqlColumnList + CASE WHEN Column_Name = ''__ImportStatus'' THEN ''40'' WHEN Column_Name = ''__ImportStatusDate'' THEN ''GETDATE()'' ELSE QUOTENAME(Column_name) END + '' '' + QUOTENAME(Column_name), '''') + '', ''
									, @sqlColumnListInsert = COALESCE(@sqlColumnListInsert + QUOTENAME(Column_name), '''') + '', '' 
								FROM 
									[' + @PT1Schema + '].[' + @temptable + '] 
								WHERE
										groupnum = @processCounter
									AND column_name not in (''__ID'')
								ORDER BY
									Ordinal_position

								SELECT @isTherePEID = LEN(@sqlColumnList) - LEN(REPLACE(@sqlColumnList, ''[ProjectExternalID]'', ''''))

								SET @sqlColumnList = LEFT(@SqlColumnList, LEN(@sqlColumnList) - 1)
								SET @sqlColumnListInsert = LEFT(@sqlColumnListInsert, LEN(@sqlColumnListInsert) - 1)

								SET @sqltruncate = 
									''
										IF OBJECT_ID('''''' + @prodTableName + '''''', ''''U'''') IS NOT NULL 
											BEGIN 
												DELETE 
												FROM 
													' + @ImportServer + '.dbo.['' + @prodTableName + ''] 
											END
									''   
			'
		
		IF @TruncateTables = @True 
			SET @SQL = @SQL + 
				' 
								SET @SqlInsert = 
									''
										DELETE 
										FROM 
											' + @ImportServer + '.dbo.['' + @prodTablename + '']    
				
										INSERT INTO
											' + @ImportServer + '.dbo.['' + @prodTablename + ''] 
											(
												'' + @sqlColumnListInsert + ''
											)		
									''
				'
		ELSE
			SET @SQL = @SQL + 
				'
								SET @SqlInsert = 
									''
										INSERT INTO
											' + @ImportServer + '.dbo.['' + @prodTablename + ''] 
												(
													'' + @sqlColumnListInsert + ''
												)		
									''
				'

		SET @SQL = @SQL + 
			' 
								SET @SqlInsert = @SqlInsert +
									''
										SELECT 
											'' + @sqlColumnList + '' 
										FROM 
											' + @DatabaseBrackets + '.dbo.['' + @stageTableName + ''] 
									''
			
								IF @isTherePEID > 0
									SET @SqlInsert = @SqlInsert + @whereClausePEID

								SET @QAQuery = 
									''
										SELECT
											  COUNT(*)
											, __ImportStatus 
										FROM 
											' + @ImportServer + '.dbo.['' + @prodTablename + '']
										GROUP BY
											__ImportStatus 
									'' 
		 
								IF ' + CONVERT(VARCHAR(1), @DebugFlag) + ' = 1
									BEGIN
										SET @updateSql = 
											''
												UPDATE 
													' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @MigrationConfigTable + ']
												SET 
													[InsertedIntoFVProdImport] = ''''Y'''' 
												WHERE
													[NewStagingTablename] = '''''' + @stageTableName + '''''''' 
				  
												SELECT
													  @SqlInsert AS ''InsertQuery''
													, @QAQuery ''QAQuery''
													, @updateSql ''UpdateSQL''
									END
		
								IF ' + CONVERT(VARCHAR(1), @DebugFlag) + ' = 0  
									BEGIN TRY
										EXEC (@SqlInsert)
						
										SET @updateSql = 
											''
												UPDATE 
													' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @MigrationConfigTable + ']
												SET 
													[InsertedIntoFVProdImport] = ''''Y''''
												WHERE
													[NewStagingTablename] = '''''' + @stageTableName + ''''''
											''
					    
										EXEC (@updateSql)
					    
										SELECT
											  @prodTablename ''has been Inserted'' 
											, @QAQuery ''QAQuery''	
									END TRY
									BEGIN CATCH
										SELECT
											  @SqlInsert ''ErrorInsert'' 
											, @updateSql ''ErrorEupdate''
									END CATCH 
		
	
							END
				
						SET @processCounter = @processCounter + 1
					END
	
				DROP TABLE
					[' + @PT1Schema + '].[' + @temptable + ']
			'


		IF @DebugFlag = @True
			SELECT @SQL
		ELSE
			EXEC(@SQL)
	END
GO
/****** Object:  StoredProcedure [dbo].[usp_move_staging_to_backup_copy]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[usp_load_staging_to_import]    Script Date: 11/19/2018 2:06:19 PM 
DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_move_staging_to_backup_copy]
		@DebugFlag =0,
		@LegacyDb = N'5006_TautfestBond',
		@schema =N'dbo',
		@FVProductionPrefix = N'_TautfestTest2_',
		@backup_suffix = N'_test2b'

SELECT	'Return Value' = @return_value


******/


CREATE   PROCEDURE [dbo].[usp_move_staging_to_backup_copy]
	@DebugFlag int,
	@LegacyDb varchar(500),
	@schema varchar(500),
	@FVProductionPrefix varchar(500),
	@backup_suffix varchar(500)
	
AS
begin
Declare @DebugFlagExt int = @DebugFlag
DECLARE @SQL varchar(max)
Declare @DatabaseBrackets varchar(500)
set @DatabaseBrackets = case when charindex('[',@LegacyDb,1) = 0 then '['+@LegacyDb+']' 
									else @LegacyDb end
		 
set @LegacyDb =  replace(replace(@LegacyDb,'[',''),']','')
DECLARE	@return_value int

set @SQL = '

USE '+@DatabaseBrackets+'
declare @stageTableName varchar(500),
		@clientDatabase varchar(500),
		@FVTablePrefix varchar(500),
		@SQL varchar(max),
		@temptable varchar(500),
		@totalTable int,
		@counter int,
		@tablename varchar(500)

set @counter = 1

SELECT  TABLE_NAME, ROW_NUMBER() over (order by TABLE_NAME) rn
into '+@DatabaseBrackets+'.'+@schema+'.MIGRATION_MoveTablesToBackup
from '+@DatabaseBrackets+'.INFORMATION_SCHEMA.TABLES
where TABLE_NAME like '''+@FVProductionPrefix+'%'' and TABLE_NAME not like '''+@backup_suffix+'%''

select @totalTable = max(rn) from '+@DatabaseBrackets+'.'+@schema+'.MIGRATION_MoveTablesToBackup

while @counter<= @totalTable
begin
	select @tablename=TABLE_NAME from '+@DatabaseBrackets+'.'+@schema+'.MIGRATION_MoveTablesToBackup where rn = @counter
	set @SQL =''select * into ''+@tablename+''_''+'''+@backup_suffix+''' + '' from '' + @tablename
	begin try
	    exec (@SQL)
	    set @SQL = ''drop table ''+@tablename
	    exec (@SQL)
	end try
	begin catch
		select ''ERROR - Could not MOVE ''+@tablename + '' to the backup name''
	end catch

	set @counter = @counter  + 1
end 
drop  table '+@DatabaseBrackets+'.'+@schema+'.MIGRATION_MoveTablesToBackup
'


if @DebugFlag = 1
	select @SQL
ELSE
	EXEC(@SQL)

end
GO
/****** Object:  StoredProcedure [dbo].[usp_ParseVaryingColumnFileData]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_ParseVaryingColumnFileData]
(
@DestinationTable VARCHAR(36)
,@InputFileType VARCHAR(36)
)
AS
BEGIN
DECLARE @MaxRows int;
DECLARE @DestinationTableColsList VARCHAR(2000);
DECLARE @DestinationTableColsListRaw VARCHAR(2000);
DECLARE @InsertDynSQL VARCHAR(4000);
--SELECT @MaxRows = MAX(LEN([csvData]) - LEN(REPLACE([csvData],',','')))
--FROM billtest.dbo.csvClean_casescsv_1
DECLARE @ColList varchar(8000);
--Remove double quotes before attempting import
UPDATE billtest.dbo.csvClean_casescsv_1
SET csvData = replace(csvData, '"','');
SELECT @DestinationTableColsListRaw = (SELECT TOP 1 csvData
FROM billtest.dbo.csvClean_casescsv_1  WITH (NOLOCK));
SELECT @MaxRows = (LEN(@DestinationTableColsListRaw) - LEN(REPLACE(@DestinationTableColsListRaw,',','')) + 1);
--Marketing data: Fix destination table column names before attempting dynamic mapping for insert statement
SELECT @DestinationTableColsList = (SELECT TOP 1
lower(replace(replace(replace(replace(@DestinationTableColsListRaw, '(Y or N)', ''),
'LTC_Insurance (Y or N)', 'ltc_insurance'), 'US_Veteran (Y or N)', 'us_veteran'),
'VA_Benefits (Y or N)', 'va_benefits'))
FROM billtest.dbo.csvClean_casescsv_1  WITH (NOLOCK)
WHERE Upper(@InputFileType) = 'MARKETING'
);
SELECT @DestinationTableColsList = @DestinationTableColsListRaw
WHERE @DestinationTableColsList IS NULL;
SELECT @DestinationTableColsList = replace(@DestinationTableColsList, ' ', '');
SET @InsertDynSQL = 'Insert Into ' + @DestinationTable + '(' + @DestinationTableColsList + ')';
SELECT @InsertDynSQL = replace(replace(replace(@InsertDynSQL,'(', '(['),')','])'), ',','],[');
;With Number(N)
AS
(
SELECT 1
UNION ALL
SELECT 1
UNION ALL
SELECT 1
),Num_Matrix(Seq)
AS
(
SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1))
FROM Number n1
CROSS JOIN Number n2
CROSS JOIN Number n3
CROSS JOIN Number n4
CROSS JOIN Number n5
)
SELECT @ColList = STUFF((SELECT ',[' + CAST(Seq  AS varchar(10)) + ']'
FROM Num_Matrix WHERE Seq <=@MaxRows FOR XML PATH('')),1,1,'')
DECLARE @SQL varchar(max)= @InsertDynSQL + ' SELECT '+ @ColList + '
FROM
(
SELECT *
FROM billtest.dbo.csvClean_casescsv_1 t
CROSS APPLY dbo.udf_ParseValues(t.[csvData],'','')f
)m
PIVOT(MAX(Val) FOR ID IN ('+ @ColList + '))P
WHERE P.csvData <> ''' + @DestinationTableColsListRaw + ''''
SELECT @SQL
EXEC(@SQL);
--Optional so as to clear out the source table once parsed in order to make room for      --the contents of the next file to be parsed.
TRUNCATE TABLE billtest.dbo.csvClean_casescsv_1;
END;

GO
/****** Object:  StoredProcedure [dbo].[usp_RecoverlatestPT1SPFromCodeHistory]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_RecoverlatestPT1SPFromCodeHistory]
	  @LegacydbName VARCHAR(1000)
	, @lookbackdate DATETIME

AS 

BEGIN

DECLARE
	@RecovSP TABLE
		(
			  ID BIGINT IDENTITY(1,1)
			, SPName VARCHAR(MAX)
			, CodeHistoryID BIGINT
			, PostTime DATETIME
			, Code VARCHAR(MAX)
			, EventType VARCHAR(1000)
			, DBNAme VARCHAR(MAX)
		)

INSERT INTO 
	@RecovSP
	(
	    SPName,
	    CodeHistoryID,
	    PostTime,
	    Code,
	    EventType,
		DBNAme
	)
SELECT DISTINCT
	  a.objectname
	, a.ID
	, a.posttime
	, a.commandtext
	, a.eventtype
	, a.databasename
FROM
	(
		SELECT 
			  *
			, DENSE_RANK() OVER(PARTITION BY objectname ORDER BY posttime DESC) drank
		FROM 
			Filevine_META.dbo.Production_Code_History
		WHERE 
			databasename = @LegacydbName
			AND eventtype = 'ALTER_PROCEDURE'
			AND TRY_CAST(posttime AS DATETIME) < ISNULL(NULLIF(TRY_CAST(@lookbackdate AS DATETIME), ''), GETDATE())
		--GROUP BY 
		--	objectname
	) a
WHERE
	a.drank = 1
ORDER BY 
	  objectname
	, posttime DESC

SELECT * FROM @RecovSP

DECLARE 
	  @Counter BIGINT = 1
	, @MaxID BIGINT = (SELECT MAX(ID) FROM @RecovSP)

WHILE @Counter <= @MaxID
	BEGIN
		DECLARE 
			    @ALTERSQL VARCHAR(MAX) = (SELECT code FROM @RecovSP WHERE @Counter = ID)
			  , @SQL VARCHAR(MAX)
		
		SET @SQL = 
		'
			USE [' + @LegacydbName + '];

			EXEC(''' + REPLACE(@ALTERSQL, '''', '''''') + ''')
		'

		BEGIN TRY
			EXEC(@SQL)
		END TRY

		BEGIN CATCH
			SELECT 'ALTER FAILED', @SQL, ERROR_MESSAGE()
		END CATCH

		SET @Counter = @Counter + 1
	END

END
GO
/****** Object:  StoredProcedure [dbo].[usp_SybaseDB_Import_17_64]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	example execution: [usp_Sybase_Import] '4375_Kramer','C:\temp\Kramer\Sybase.db'
	argument 1 dbname (db gets created)
	argument 2 filepath (include filename and also have log file in same directory in case it is linked
*/
CREATE   PROC [dbo].[usp_SybaseDB_Import_17_64] 

	@DB_Name varchar(255), @SybaseDB_FilePath varchar(500) 

AS	

DECLARE @cmd varchar(8000),@arg0 varchar(1000), @arg1 varchar(4000), @return_code int, @Sybase_Export_Path varchar(500)

--0) create directory for Sybase files to be exported to

	SET @Sybase_Export_Path = substring(@SybaseDB_FilePath,0,len(@SybaseDB_FilePath)-charindex('\',reverse(@SybaseDB_FilePath))+2) + 'sybase_exports\'
	SET @cmd = 'mkdir ' + @Sybase_Export_Path
	EXEC @return_code = master..xp_cmdshell @cmd
	SELECT @return_code as rc -- 0 = success 1 = failure
	
--1) Run this shell cmd against Sybase.db to get all TABLEs and capture output for use in step 2

	SET @arg1 = 
	'"DECLARE @unloadpath varchar(255) = '''+replace(@Sybase_Export_Path,'\','\\\\')+''' 
	SELECT ''SELECT * FROM '' + replace(TABLE_name,''.txt'','''') + ''; OUTPUT TO '''''' + @unloadpath + '''' + TABLE_name + ''.txt'''' FORMAT ASCII DELIMITED BY ''''\x09'''' QUOTE '''''''' WITH COLUMN NAMES;'' 
	FROM sysTable
	where primary_root != 0 and creator=1 
	order by TABLE_name"'

	SET @arg1 = replace(@arg1,char(10),'')
	SET @arg1 = replace(@arg1,char(13),'')

	SET @arg0 = 'cd C:\Program Files\SQL Anywhere 17\Bin64 && dbisql.com -c "UID=dba;PWD=sql;DBF='+@SybaseDB_FilePath+'" '
	SET @cmd = @arg0 + @arg1
	select @cmd
	print @cmd
 
	CREATE TABLE #output (id int identity(1,1), output nvarchar(255) null)
	INSERT #output exec @return_code = master..xp_cmdshell @cmd
	SELECT @return_code as rc



--2) Loop thru results FROM step 1 and output 1 tab delimited txt file for each TABLE

	CREATE TABLE #loop_output (id int identity(1,1), output nvarchar(255) null)
	DECLARE @i int
	SELECT @i = min(ID) FROM #output where output like 'SELECT%'
	WHILE @i is not null
	BEGIN
	  SELECT @arg1 = output FROM #output where id = @i
	  SET @cmd = @arg0 + @arg1

		INSERT #loop_output exec @return_code = master..xp_cmdshell @cmd 
		SELECT @return_code as rc
		SELECT * FROM #loop_output

	  SELECT @i = min(ID) FROM #output where ID > @i and output like 'SELECT%'
	END



--3) Import files FROM step 2 into sql using bulk INSERT inside loop
	SET @DB_Name = replace(replace(@DB_Name,'[',''),']','')
	EXEC Filevine_META.dbo.usp_createdb @DB_Name

	SET @CMD = '
	USE ['+@DB_Name+']

	DECLARE @path varchar(255),@cmd VARCHAR(500), @filename varchar(255), @sql varchar(max)
	DROP TABLE FileNames
	CREATE TABLE FileNames([file] varchar(255), [path] varchar(255))

	SET @path = '''+@Sybase_Export_Path+'''
	SET @cmd = ''dir '' + @path + ''*.txt /b''
	INSERT INTO  FileNames([file])
	EXEC Master..xp_cmdShell @cmd
	UPDATE FileNames SET [path] = @path where [path] is null


	DECLARE c1 cursor for SELECT [path],[file]
	FROM FileNames
	WHERE [file] in
	(
		SELECT [file] FROM FileNames
		where replace([file],''.txt'','''') not in
		(
			SELECT TABLE_name FROM information_schema.TABLES
		)
	)
	OPEN c1
	FETCH next FROM c1 into @path,@filename
	WHILE @@fetch_status <> -1
		BEGIN
			IF NOT exists(SELECT * FROM sysobjects WHERE NAME = ''temp_csvdata'' and xtype=''u'')
				CREATE TABLE temp_csvdata (rowdata varchar(max))
			truncate TABLE temp_csvdata	
			SET @sql = ''BULK INSERT temp_csvdata FROM '''''' + @path + @filename + '''''' ''
				+ ''     WITH ( 
						FIELDTERMINATOR = ''''\t'''', 
						ROWTERMINATOR = ''''\n'''', 
						FIRSTROW = 1
					) ''
			print @sql
			exec (@sql)

			DECLARE @toprow varchar(max), @fieldnames varchar(max)
			SELECT top 1 @toprow = rowdata FROM temp_csvdata
			SELECT @toprow

	
			SET @toprow = replace(@toprow,''"'','''')
			SELECT @fieldnames = ''['' + replace(@toprow,char(9),''] varchar(max), ['') + ''] varchar(max)''

			SET @sql = ''drop TABLE [''+replace(@filename,''.txt'','''')+''] CREATE TABLE [''+replace(@filename,''.txt'','''')+''] (''+ @fieldnames +'')''
			print @sql
			exec (@sql)

			SET @sql = ''BULK INSERT [''+replace(@filename,''.txt'','''')+''] FROM '''''' + @path + @filename + '''''' '' + ''
						WITH ( 
						FIELDTERMINATOR = ''''\t'''', 
						ROWTERMINATOR = ''''0x0a'''', 
						FIRSTROW = 2)''
			print @sql
			exec (@sql)

		fetch next FROM c1 into @path,@filename
		END
	CLOSE c1
	DEALLOCATE c1

	SELECT t.name
	FROM sys.TABLEs AS t
	WHERE t.is_ms_shipped = 0 
	order by t.name'

	EXEC(@cmd)

drop TABLE #output
drop TABLE #loop_output
GO
/****** Object:  StoredProcedure [INTAKE].[usp_AutoIntake]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [INTAKE].[usp_AutoIntake]
		@vexecutable_db varchar(500) ='', -- Where does the Stored Procs to be executed - Default = Filevine_META
		@vDebugFlag bit =0,
		@vLegacyDb varchar(500)='', --Client's database to be processed 	
		@CoverageAnalysis Bit = 0, -- Counts how many values are populated in a column
		@NullAnalysis Bit = 0, -- counts the nulls within a column
		@ValueAnalysis Bit = 0, -- Will create the detailed inventory all values in the client DB and populated the [dbo].[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT]
		@MinMaxAnalysis Bit = 0, -- Will give the min and max values within each column
		@PctAnalysis Bit = 0 -- Will provie the calculation of 100.00%
	
	
AS
	BEGIN
		SET NOCOUNT ON;

		declare 
		@return_value int,
		@successFlag bit = 0,
		@sql varchar(max) = '',
		@sqlcmd varchar(2000)='',
		@NewLine  CHAR(2) = CHAR(13) + CHAR(10),
		@SubStepName VARCHAR(250) =N'',
		@ErrorCode INT = 0,
		@ErrorMsg  NVARCHAR(2048) = N''
	
		/********************************
		SET COMPATIBILITY_LEVEL = 130; 
		*************************************/
		/******************************************
			Create the AUTOINTAKE_LOG
		******************************************/
		Select 'START INTAKE ANALYSIS*****' as StepName

		begin try
			set @SubStepName='********CREATE Client DB trigger'	+@NewLine	
	
			If @vDebugFlag = 0
			begin
				begin try
						EXEC	@return_value = [Filevine_META].[dbo].[usp_create_trigger_production_code_history]
							@dbname = @vLegacyDb

						Print @SubStepName+@NewLine
				end try
				begin catch
					SET @ErrorCode = ERROR_NUMBER();		
					SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
					RAISERROR(@ErrorMsg, 16, 1);
				end catch
			end
				Print @SubStepName ++@NewLine+ ' COMPLETED'

		end try
		begin catch
				Print @SubStepName ++@NewLine+ ' Trigger exists'
		end catch

		
	/******************************************
			Execute the PMAT
	******************************************/
	begin try
		
		set @SubStepName='******** EXECUTE the PMAT '	
		--if @vDebugFlag = 0
		--begin
		  select 'START - PMAT' as StepName
				EXEC	@return_value = [Filevine_META].[PMAT].[usp_PMAT]
						@executable_db = @vexecutable_db,
						@Database = @vLegacyDb,
						@DebugFlag = @vDebugFlag,
						 @CoverageAnalysis  =@CoverageAnalysis,
						 @NullAnalysis  =@NullAnalysis,
						 @ValueAnalysis  = @ValueAnalysis,
						 @MinMaxAnalysis  = @MinMaxAnalysis,
						 @PctAnalysis  = @PctAnalysis,
						@successFlag = @successFlag OUTPUT
						Select 'PMAT - COMPLETE' as StepName
				Print @SubStepName ++@NewLine+ ' COMPLETED'
				if isnull(@return_value,0) <> 0
				begin
					SET @ErrorCode = 9999999;		
					SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
					RAISERROR(@ErrorMsg, 16, 1);
				end
			--end
			--	else 
					Print @NewLine+@SubStepName+@NewLine
	end try
	begin catch
		SET @ErrorCode = ERROR_NUMBER();		
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);
	end catch
	 
    /**************************************************
	Execute the Mapping Config table
	***************************************************/
	
      begin try
			set @SubStepName='********EXECUTE the initial usp_create_mapping_config_table'	+@NewLine
			if @vDebugFlag = 0
				begin
					select 'START- usp_create_mapping_config_table' as StepName
					EXEC	@return_value = [Filevine_META].[PMAT].[usp_create_mapping_config_table]
							@DatabaseName = @vLegacyDb,
							
							@successFlag = @successFlag OUTPUT
					Select 'usp_create_mapping_config_table- COMPLETE' as StepName
					
					if @return_value <> 0
					begin
						SET @ErrorCode = 9999999;		
						SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
						RAISERROR(@ErrorMsg, 16, 1);
					end
					else 
						Print @SubStepName+@NewLine+ ' COMPLETED'
				end
				else 
					Print @SubStepName+@NewLine
		end try
		begin catch
			SET @ErrorCode = ERROR_NUMBER();		
			SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
			RAISERROR(@ErrorMsg, 16, 1);
		end catch
------------------------------------------------------------------------------------------------
	

--/*********************************************************************************************
--		Export the Log,  and IC report
--***********************************************************************************************/
	set @SubStepName='******** Export the Log and IC report to your specificed location'	
	Print @NewLine+@SubStepName +@NewLine
	If @vDebugFlag = 0
		begin
		 begin try
			
				set @sqlcmd='sqlcmd -S . -s "," -W -Q "SELECT * FROM ['+@vLegacyDb+'].[dbo].VW_TABLE_SOURCE_ANALYSIS_MAIN_REPORT" -o C:\AUTO_INTAKE_OUTPUT\'+@vLegacyDb+'_VW_TABLE_ANALYSIS_IC_REPORT.csv'

				EXEC master.dbo.xp_cmdshell  @sqlcmd 
				Select 'PMAT - EXPORTED on Import Server  - COMPLETED' as StepName
				Print @NewLine+@SubStepName+@NewLine + ' COMPLETED '
		end try
		begin catch
			SET @ErrorCode = ERROR_NUMBER();		
			SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
			RAISERROR(@ErrorMsg, 16, 1);
		end catch
		end
	else 
		Print @NewLine+@SubStepName +@NewLine



END
GO
/****** Object:  StoredProcedure [INTAKE].[usp_DLF_Setup]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [INTAKE].[usp_DLF_Setup]
	  @TargetDatabase VARCHAR(1000)
	, @Pass BIT OUTPUT

AS
	BEGIN
		DECLARE
			@ExecutionDatabase VARCHAR(MAX) = 'Filevine_META'
		
		DECLARE 
			  @SQL VARCHAR(MAX)
			, @SQLn NVARCHAR(MAX)
			, @TargetDB VARCHAR(1000) = REPLACE(REPLACE(@TargetDatabase, '[', ''), ']', '')
			, @TargetDBQuoted VARCHAR(1000) = '[' + REPLACE(REPLACE(@TargetDatabase, '[', ''), ']', '') + ']'
			, @ExecutionDB VARCHAR(1000) = REPLACE(REPLACE(@ExecutionDatabase, '[', ''), ']', '')
			, @ExecutionDBQuoted VARCHAR(1000) = '[' + REPLACE(REPLACE(@ExecutionDatabase, '[', ''), ']', '') + ']'
			, @DLF_FILE_TYPE_TABLE VARCHAR(1000) = 'DLF_FILE_TYPE'
			, @DLF_S3_VERSION_TABLE VARCHAR(1000) = 'DLF_S3_VERSION'
			, @DLF_S3_VERSION_FILE_TYPE_TABLE VARCHAR(1000) = 'DLF_S3_VERSION_FILE_TYPE'
			, @DLF_ERROR_LOG_TABLE VARCHAR(1000) = 'DLF_ERROR_LOG'
			, @DLF_FILE_PROCESSING_TABLE VARCHAR(1000) = 'DLF_FILE_PROCESSING'
			, @DLF_FILE_PROCESSING_VIEW VARCHAR(1000) = 'vw_DLF_FILE_PROCESSING'

		DECLARE
			  @TargetUse VARCHAR(1000) = 'USE ' + @TargetDBQuoted
			, @ExecutionUse VARCHAR(1000) = 'USE ' + @ExecutionDBQuoted 

		/*If db doesn't exist, create and force collation*/
		BEGIN
			--DECLARE @targetDB VARCHAR(1000) = 'Sandbox_BP_IntakeS3_Demo' 
			
			IF NOT EXISTS (SELECT * FROM sys.databases WHERE [name] = @TargetDB)
				BEGIN
					EXEC Filevine_META.dbo.usp_createdb 
						@dbname = @TargetDB
					
				END
		END

		/*CREATE DLF_FILE_TYPE*/
		BEGIN
			SET @SQL = @ExecutionUse + 
				'
					IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_FILE_TYPE_TABLE + ''')
						BEGIN
							CREATE TABLE [dbo].[' + @DLF_FILE_TYPE_TABLE + '](
								[Id] [INT] IDENTITY(1,1) NOT NULL,
								[FileType] [NVARCHAR](32) NOT NULL,
								[FileTypeGraph] [NVARCHAR](128) NULL,
								[FileTypeDescription] [NVARCHAR](256) NULL,
								[FilePriority] [INT] NOT NULL DEFAULT 2,
							 CONSTRAINT [PK_' + @DLF_FILE_TYPE_TABLE + '] PRIMARY KEY CLUSTERED 
							(
								[Id] ASC
							)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
							 CONSTRAINT [UQ_' + @DLF_FILE_TYPE_TABLE + '_FILE_TYPE] UNIQUE NONCLUSTERED 
							(
								[FileType] ASC
							)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
							) ON [PRIMARY]
						END
				'
				
			EXEC (@SQL)
		END
		
		/*CREATE DLF_S3_VERSION*/
		BEGIN
			SET @SQL = @ExecutionUse + 
				'
					IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_S3_VERSION_TABLE + ''')
						BEGIN
							CREATE TABLE [dbo].[' + @DLF_S3_VERSION_TABLE + '](
								[Id] [INT] IDENTITY(1,1) NOT NULL,
								[OrgId] [NVARCHAR](4) NOT NULL,
								[VersionDateReceived] [DATETIME2](3) NOT NULL,
								[VersionName] [NVARCHAR](32) NOT NULL,
								[VersionPath] [NVARCHAR](1024) NULL,
								[VersionBucket] [VARCHAR](1000) NOT NULL,
							 CONSTRAINT [PK_' + @DLF_S3_VERSION_TABLE + '] PRIMARY KEY CLUSTERED 
							(
								[Id] ASC
							)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
							) ON [PRIMARY]
					

							ALTER TABLE [dbo].[' + @DLF_S3_VERSION_TABLE + '] ADD  DEFAULT (''client-import-files'') FOR [VersionBucket]

							ALTER TABLE [dbo].[' + @DLF_S3_VERSION_TABLE + '] ADD CONSTRAINT [UC_' + @DLF_S3_VERSION_TABLE + '] UNIQUE([OrgID], [VersionName], [VersionPath], [VersionBucket]);
						END
				'
				
			EXEC (@SQL)
		END
		
		/*CREATE DLF_S3_VERSION_FILE_TYPE*/
		BEGIN
			SET @SQL = @ExecutionUse + 
				'
					IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_S3_VERSION_FILE_TYPE_TABLE + ''')
						BEGIN
							CREATE TABLE [dbo].[' + @DLF_S3_VERSION_FILE_TYPE_TABLE + '](
								[Id] [INT] IDENTITY(1,1) NOT NULL,
								[S3Version] [INT] NOT NULL,
								[Path] [NVARCHAR](1024) NULL,
								[FileExtension] [NVARCHAR](8) NOT NULL,
								[FileType] [INT] NOT NULL,
								[MappingDescription] [NVARCHAR](256) NULL,
							 CONSTRAINT [PK_' + @DLF_S3_VERSION_FILE_TYPE_TABLE + '] PRIMARY KEY CLUSTERED 
							(
								[Id] ASC
							)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
							) ON [PRIMARY]
					

							ALTER TABLE [dbo].[' + @DLF_S3_VERSION_FILE_TYPE_TABLE + ']  WITH CHECK ADD  CONSTRAINT [FK_' + @DLF_S3_VERSION_FILE_TYPE_TABLE + '_FILE_TYPE] FOREIGN KEY([FileType])
							REFERENCES [dbo].[' + @DLF_FILE_TYPE_TABLE + '] ([Id])
							ON DELETE CASCADE
					

							ALTER TABLE [dbo].[' + @DLF_S3_VERSION_FILE_TYPE_TABLE + '] CHECK CONSTRAINT [FK_' + @DLF_S3_VERSION_FILE_TYPE_TABLE + '_FILE_TYPE]
					

							ALTER TABLE [dbo].[' + @DLF_S3_VERSION_FILE_TYPE_TABLE + ']  WITH CHECK ADD  CONSTRAINT [FK_' + @DLF_S3_VERSION_FILE_TYPE_TABLE + '_S3_VERSION] FOREIGN KEY([S3Version])
							REFERENCES [dbo].[' + @DLF_S3_VERSION_TABLE + '] ([Id])
							ON DELETE CASCADE
					

							ALTER TABLE [dbo].[' + @DLF_S3_VERSION_FILE_TYPE_TABLE + '] CHECK CONSTRAINT [FK_' + @DLF_S3_VERSION_FILE_TYPE_TABLE + '_S3_VERSION]
						END
					
				'
				
			EXEC (@SQL)
		END

		/*CREATE DLF_ERROR_LOG*/
		BEGIN
			SET @SQL = @ExecutionUse + 
				'
					IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_ERROR_LOG_TABLE + ''')
						BEGIN
							CREATE TABLE [dbo].[' + @DLF_ERROR_LOG_TABLE + '](
								[Id] [INT] IDENTITY(1,1) NOT NULL,
								[CloverJobId] [INT] NOT NULL,
								[ErrorTimestamp] [DATETIME2](3) NOT NULL,
								[ErrorText] [NVARCHAR](2048) NULL,
							 CONSTRAINT [PK_' + @DLF_ERROR_LOG_TABLE + '] PRIMARY KEY CLUSTERED 
							(
								[Id] ASC
							)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
							) ON [PRIMARY]
						END
				'
				
			EXEC (@SQL)
		END
		
		/*CREATE DLF_FILE_PROCESSING*/
		BEGIN
			SET @SQL = @ExecutionUse + 
				'
					IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_FILE_PROCESSING_TABLE + ''')
						BEGIN
							CREATE TABLE [dbo].[' + @DLF_FILE_PROCESSING_TABLE + '](
								[Id] [INT] IDENTITY(1,1) NOT NULL,
								[DestinationDatabase] [NVARCHAR](1024) NOT NULL,
								[S3Version] [INT] NOT NULL,
								[S3BucketName] [NVARCHAR](MAX) NOT NULL,
								[FilePath] [NVARCHAR](MAX) NULL,
								[FilenameWithExtension] [NVARCHAR](MAX) NOT NULL,
								[Filename] [NVARCHAR](MAX) NOT NULL,
								[FileExtension] [NVARCHAR](MAX) NOT NULL,
								[FileSize] [INT] NOT NULL,
								[FileLastModifiedAt] [DATETIME2](3) NOT NULL,
								[FileType] [INT] NULL,
								[FileTypeProcessor] [NVARCHAR](128) NULL,
								[Status] [NVARCHAR](32) NOT NULL,
								[ErrorDetails] [INT] NULL,
								[Reprocessed] [INT] NULL,
								[LastProcessingCloverJobId] [INT] NULL,
								[LastProcessingStartedAt] [DATETIME2](3) NULL,
								[LastProcessingFinishedAt] [DATETIME2](3) NULL,
								[LastProcessingDuration] [INT] NULL,
								[LastProcessingTablesCreated] [INT] NULL,
								[LastProcessingRecordsRead] [INT] NULL,
								[LastProcessingRecordsWritten] [INT] NULL,
								[ArchivedFilePath] [NVARCHAR](MAX) NULL,
								[ProcessingGroupID] BIGINT NULL,
							 CONSTRAINT [PK_' + @DLF_FILE_PROCESSING_TABLE + '] PRIMARY KEY CLUSTERED 
							(
								[Id] ASC
							)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
							) ON [PRIMARY]
					

							ALTER TABLE [dbo].[' + @DLF_FILE_PROCESSING_TABLE + ']  WITH CHECK ADD  CONSTRAINT [FK_' + @DLF_FILE_PROCESSING_TABLE + '_ERROR_DETAILS] FOREIGN KEY([ErrorDetails])
							REFERENCES [dbo].[' + @DLF_ERROR_LOG_TABLE + '] ([Id])
					

							ALTER TABLE [dbo].[' + @DLF_FILE_PROCESSING_TABLE + '] CHECK CONSTRAINT [FK_' + @DLF_FILE_PROCESSING_TABLE + '_ERROR_DETAILS]
					

							ALTER TABLE [dbo].[' + @DLF_FILE_PROCESSING_TABLE + ']  WITH CHECK ADD  CONSTRAINT [FK_' + @DLF_FILE_PROCESSING_TABLE + '_FILE_TYPE] FOREIGN KEY([FileType])
							REFERENCES [dbo].[' + @DLF_FILE_TYPE_TABLE + '] ([Id])
							ON DELETE CASCADE
					

							ALTER TABLE [dbo].[' + @DLF_FILE_PROCESSING_TABLE + '] CHECK CONSTRAINT [FK_' + @DLF_FILE_PROCESSING_TABLE + '_FILE_TYPE]
					

							ALTER TABLE [dbo].[' + @DLF_FILE_PROCESSING_TABLE + ']  WITH CHECK ADD  CONSTRAINT [FK_' + @DLF_FILE_PROCESSING_TABLE + '_S3_VERSION] FOREIGN KEY([S3Version])
							REFERENCES [dbo].[' + @DLF_S3_VERSION_TABLE + '] ([Id])
							ON DELETE CASCADE
					

							ALTER TABLE [dbo].[' + @DLF_FILE_PROCESSING_TABLE + '] CHECK CONSTRAINT [FK_' + @DLF_FILE_PROCESSING_TABLE + '_S3_VERSION]
						END
				'
				
			EXEC (@SQL)
		END

		/*Create vw_DLF_FILE_PROCESSING*/
		BEGIN
			SET @SQL =  @ExecutionUse + 
				'
					IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_FILE_PROCESSING_VIEW + ''')
						BEGIN
							EXEC(
								''
									CREATE VIEW [dbo].[' + @DLF_FILE_PROCESSING_VIEW + ']
									AS
									SELECT 
										  [f].id
										, [f].ProcessingGroupID
										, [f].[S3Version]
										, [v].[VersionName]
										, [v].[VersionBucket]
										, [v].[VersionPath]
										, [f].[DestinationDatabase]
										, [f].[Status]
										, [e].[ErrorText]
										, [t].[FilePriority]
										, [f].[FilePath]
										, [f].[FilenameWithExtension]
										, [f].[FileExtension]
										, [f].[FileSize]
										, [f].[FileTypeProcessor]
										, [f].[Reprocessed]
										, [f].[LastProcessingCloverJobId]
										, [f].[LastProcessingStartedAt]
										, [f].[LastProcessingFinishedAt]
										, [f].[LastProcessingDuration]
										, [f].[LastProcessingTablesCreated]
										, [f].[LastProcessingRecordsRead]
										, [f].[LastProcessingRecordsWritten]
									FROM 
										[dbo].[DLF_FILE_PROCESSING] f 
											INNER JOIN [dbo].[DLF_S3_VERSION] v
												ON v.id = f.[S3Version]
											LEFT JOIN [dbo].[DLF_ERROR_LOG] e 
												ON f.[ErrorDetails] = e.id
											LEFT JOIN [dbo].[DLF_FILE_TYPE] t
												ON t.id = f.[FileType]
								''
								)
						END
				'
				
			EXEC (@SQL)
		END

		/*Validate the tables exist*/
		BEGIN			
			SET @SQLn = @ExecutionUse + 
				'
					DECLARE
						  @FileType BIT = (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_FILE_TYPE_TABLE + ''')
						, @s3Ver BIT = (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_S3_VERSION_TABLE + ''')
						, @s3VerFileType BIT = (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_S3_VERSION_FILE_TYPE_TABLE + ''')
						, @errorLog BIT = (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_ERROR_LOG_TABLE + ''')
						, @FileProc BIT = (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @DLF_FILE_PROCESSING_TABLE + ''')

					IF COALESCE(@FileType, @s3Ver, @s3VerFileType, @errorLog, @FileProc, '''') IS NOT NULL
						BEGIN
							SET @Pass = 1
						END
					ELSE
						BEGIN
							SET @Pass = 0
						END					
				'

			EXECUTE [sys].[sp_executesql]
				  @SQLn
				, N'@Pass BIT OUTPUT'
				, @Pass = @Pass OUTPUT

			RETURN
		END
	END
GO
/****** Object:  StoredProcedure [INTAKE].[usp_Insert_DLF_S3_Version]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [INTAKE].[usp_Insert_DLF_S3_Version]
	  @VersionPath VARCHAR(MAX)
	, @VersionBucket VARCHAR(MAX)
	, @VersionName VARCHAR(MAX)
	, @OrgID BIGINT
	, @Pass BIT OUTPUT

AS
	BEGIN
		/*Insert new S3 Version record*/
		IF NOT EXISTS 
			(
				SELECT 
					* 
				FROM 
					[dbo].[DLF_S3_VERSION] 
				WHERE 
						[VersionPath] = @VersionPath 
					AND [VersionBucket] = @VersionBucket
					AND [VersionName] = @VersionName
					AND [OrgId] = @OrgID
			) 
			BEGIN 
				INSERT INTO 
					[dbo].[DLF_S3_VERSION] 
					(
						  [OrgId]
						, [VersionName]
						, [VersionDateReceived]
						, [VersionPath]
						, [VersionBucket]
					) 
				SELECT 
					  @OrgID
					, @VersionName
					, GETDATE()
					, @VersionPath
					, @VersionBucket 
			END

		/*Determine if Pass*/
		BEGIN
			SET @Pass = CASE
							WHEN EXISTS 
								(
									SELECT 
										* 
									FROM 
										[dbo].[DLF_S3_VERSION] 
									WHERE 
											[VersionPath] = @VersionPath 
										AND [VersionBucket] = @VersionBucket
										AND [VersionName] = @VersionName
										AND [OrgId] = @OrgID
								)
							THEN 1

							ELSE 0
						END
		END

		RETURN 
	END
GO
/****** Object:  StoredProcedure [INTAKE].[usp_PopulateBakRestoreMeta]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [INTAKE].[usp_PopulateBakRestoreMeta]
	  @FilePath VARCHAR(MAX) OUTPUT
	, @FileName VARCHAR(MAX) OUTPUT
	, @DestinationDatabaseName VARCHAR(MAX) OUTPUT
	, @mdfName VARCHAR(MAX) = '' OUTPUT
	, @ldfName VARCHAR(MAX) = '' OUTPUT

AS
	BEGIN
		DECLARE 
			  @SQL VARCHAR(MAX)
			, @SQLn NVARCHAR(MAX)
			, @DBName VARCHAR(MAX) = REPLACE(REPLACE(@DestinationDatabaseName, '[', ''), ']', '')
			, @DBNameQuoted VARCHAR(MAX) = '[' + REPLACE(REPLACE(@DestinationDatabaseName, '[', ''), ']', '') + ']'
			, @tempRestoreDB VARCHAR(MAX) = 'TempRestoreDBMETA'
			, @tempRestoreDBMetaTable VARCHAR(MAX) = 'FileListMeta_' + @DestinationDatabaseName
			, @tempRestoreDBMetaTableSchema VARCHAR(MAX) = 'dbo'
			
		
		DECLARE
			@WorkingUse VARCHAR(MAX) = 'USE ' + @DBNameQuoted
			
		/*create temp restore meta db*/
		IF NOT EXISTS(SELECT * FROM sys.Databases WHERE [name] = @tempRestoreDB)
			BEGIN
				SET @SQL = 
					'
						USE [master]

						CREATE DATABASE ' + @tempRestoreDB + '
					'

				EXEC (@SQL)
			END

		/*create temp db meta table*/
		BEGIN
			SET @SQL = 
				'
					USE [' + @tempRestoreDB + ']

					IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @tempRestoreDBMetaTable + ''' AND TABLE_SCHEMA = ''' + @tempRestoreDBMetaTableSchema + ''')
						BEGIN
							DROP TABLE [' + @tempRestoreDBMetaTableSchema + '].[' + @tempRestoreDBMetaTable + ']
						END

					CREATE TABLE 
						[' + @tempRestoreDBMetaTableSchema + '].[' + @tempRestoreDBMetaTable + ']
						(
							  id bigint identity(1,1) 
							, LogicalName VARCHAR(MAX)
							, PhysicalName VARCHAR(MAX)	
							, Type VARCHAR(MAX)	
							, FileGroupName VARCHAR(MAX)	
							, Size VARCHAR(MAX)	
							, MaxSize VARCHAR(MAX)	
							, FileId VARCHAR(MAX)	
							, CreateLSN VARCHAR(MAX)	
							, DropLSN VARCHAR(MAX)	
							, UniqueId VARCHAR(MAX)	
							, ReadOnlyLSN VARCHAR(MAX)	
							, ReadWriteLSN VARCHAR(MAX)	
							, BackupSizeInBytes VARCHAR(MAX)	
							, SourceBlockSize VARCHAR(MAX)	
							, FileGroupId VARCHAR(MAX)	
							, LogGroupGUID VARCHAR(MAX)	
							, DifferentialBaseLSN VARCHAR(MAX)	
							, DifferentialBaseGUID VARCHAR(MAX)	
							, IsReadOnly VARCHAR(MAX)	
							, IsPresent VARCHAR(MAX)	
							, TDEThumbprint VARCHAR(MAX)	
							, SnapshotUrl VARCHAR(MAX)
						)
				'

			EXEC (@SQL)
		END

		/*Grab logical files from backup and write to temp db meta*/
		BEGIN
			SET @SQLn = 
				'
					USE [master]
			
					INSERT INTO 
						[' + @tempRestoreDB + '].[' + @tempRestoreDBMetaTableSchema + '].[' + @tempRestoreDBMetaTable + ']
					EXEC(''restore FILELISTONLY FROM DISK = ''''' + @FilePath + '\' + @FileName + ''''''')

					SELECT
						  @mdfName = (SELECT TOP 1 LogicalName FROM [' + @tempRestoreDB + '].[' + @tempRestoreDBMetaTableSchema + '].[' + @tempRestoreDBMetaTable + '] WHERE TYPE = ''D'')
						, @ldfName = (SELECT TOP 1 LogicalName FROM [' + @tempRestoreDB + '].[' + @tempRestoreDBMetaTableSchema + '].[' + @tempRestoreDBMetaTable + '] WHERE TYPE = ''L'')
					
				'
			
			EXECUTE sp_executeSQL
				  @SQLn
				, N'@mdfName VARCHAR(MAX) OUTPUT
				   ,@ldfName VARCHAR(MAX) OUTPUT'
				, @mdfName = @mdfName OUTPUT
				, @ldfName = @ldfName OUTPUT
		END
	END
GO
/****** Object:  StoredProcedure [INTAKE].[usp_RestoreBak]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [INTAKE].[usp_RestoreBak]
	  @FilePath VARCHAR(MAX)
	, @FileName VARCHAR(MAX)
	, @DestinationDatabaseName VARCHAR(MAX)
	, @mdfName VARCHAR(MAX)
	, @ldfName VARCHAR(MAX)

AS
	BEGIN
		DECLARE 
			  @SQL VARCHAR(MAX)
			, @SQLn NVARCHAR(MAX)
			, @DBName VARCHAR(MAX) = REPLACE(REPLACE(@DestinationDatabaseName, '[', ''), ']', '')
			, @DBNameQuoted VARCHAR(MAX) = '[' + REPLACE(REPLACE(@DestinationDatabaseName, '[', ''), ']', '') + ']'
			, @tempRestoreDB VARCHAR(MAX) = 'TempRestoreDBMETA'
			, @tempRestoreDBMetaTable VARCHAR(MAX) = 'FileListMeta_' + @DestinationDatabaseName
			, @tempRestoreDBMetaTableSchema VARCHAR(MAX) = 'dbo'
			
		
		DECLARE
			@WorkingUse VARCHAR(MAX) = 'USE ' + @DBNameQuoted

		/*restore from the bak file and replace (in case the DB exists)*/
		SET @SQL = 
			'
				USE [master]
				
				RESTORE DATABASE
					' + @DBNameQuoted + '
				FROM DISK =
					''' + @FilePath + '\' + @FileName + '''
				WITH 
					  REPLACE
					, MOVE ''' + @mdfName + ''' TO ''D:\SQL_DATA\' + @DBName + '.mdf''
					, MOVE ''' + @ldfName + ''' TO ''D:\SQL_DATA\' + @DBName + '_log.ldf'';
			'
		
		print @SQL
		BEGIN TRY
			EXEC (@SQL)
		END TRY

		BEGIN CATCH
			DECLARE @ErrorMsg VARCHAR(MAX) = ERROR_MESSAGE()
		
			RAISERROR(@ErrorMsg,16,1);
		END CATCH
		
		/*Next, make sure our internal stuff is added to the database*/
		BEGIN
			/*Set recovery Mode*/
			SET @SQL = 
				'
					USE [master]
					
					ALTER DATABASE
						' + @DBNameQuoted + '
					SET RECOVERY 
						SIMPLE;
				'
				
			EXEC (@SQL)
		
			/*Set Collation/ Add Production Code History Triggers*/
			SET @SQL = @WorkingUse + 
				'
					EXEC Filevine_META.dbo.usp_create_trigger_production_code_history
						@dbname = ''' + @DBName + '''
				'
				
			EXEC (@SQL)

			/*Create users*/
			SET @SQL = @WorkingUse +
				'
					EXEC Filevine_META.[dbo].[usp_addusers]
						@dbname = ''' + @DBName + '''
				'
			
			EXEC (@SQL)
		END
	END
GO
/****** Object:  StoredProcedure [PMAT].[pmat_build_TABLE_config_flag_table_main]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************/
/*                    OVERVIEW of TABLE Process	     	           */
/*******************************************************************************************/
/* [TABLE_SOURCE_ANALYSIS] is a TABLE Definition table containing FIELD_KEY (PK-ID) column,    */
/* INFORMATION_SCHEMA.Columns data for each Staging/Source table and Config Flags columns. */
/* Each Config Flag column represents the type of analysis to be done at the               */			
/* Source table's column level and has a dedicated table named after a flag with           */ 
/* a following pattern: 'TABLE_'+REPLACE([FLAG_NAME],'_FLAG','')                             */
/*                                                                                         */ 
/* Example of naming convention for a Config Flag Table                                    */
/* Config Flag 		: [PCT_COVERAGE]_FLAG                                                  */
/* Config Flag Table: TABLE_[PCT_COVERAGE]                                                   */
/*                                                                                         */
/* The process scans the [TABLE_SOURCE_ANALYSIS] table structure and populates Config Flag   */ 
/* tables for a distinct instance of a Source table in a TABLE Definition table.             */
/* Config Flag Tables must have a FIELD_KEY column (FK to [TABLE_SOURCE_ANALYSIS].FIELD_KEY) */
/* Then the FIELD_KEY is used to join [TABLE_SOURCE_ANALYSIS] table with Config Flag Tables  */
/* to produce final output for the Source Analysis Report.                                 */
/*******************************************************************************************/

--
-- Description	: [PMAT].[pmat_build_TABLE_config_flag_table_main] is a Main SP that generates data
--				: for TABLE Reports;
--				: Logs main actions/errors; raises errors;
--				: Could be executed in Debug mode to print out SQL statements only;
-- Steps		: 1) Gets list of Config Flag Columns from syscolumns for a passed TABLE Definition table - [@TableConfig] parm;
--				: 2) Gets list of Source Tables defined in TABLE Definition table - [@TableConfig] parm;
--				:    If [@TableSrc] Input parameter is passed then the procedure will process for this table only;
--				: 3) Loops and processes each [@ConfigFlag] for each [@TableSrc];
--				:	3.1) Gets the record count from a Source table - [@TableSrc] variable;
--				:	3.2) Assigns [@TableFinal] variable;
--				:	3.3) Calls [PMAT].[pmat_build_TABLE_config_flag_table_sub1] to continue the Process;
--
-- Input Params : @DebugFlag   - 0 to execute; non-zero - to print SQL statements
--				: @Database	   - database where [TABLE Source Analysis] Definition table is stored
--				: @SchemaName  - table schema where [TABLE Source Analysis] Definition table is stored
--				: @TableConfig - name of the [TABLE Source Analysis] Definition table
--				: @TableSrc    - name of the Source table (if NULL - runs for all sources defined in TABLE Definition table; runs for 1 source otherwise)
--
-- Dependencies :
-- Stored Procs	: [PMAT].[pmat_build_TABLE_config_flag_table_sub1] 
--				: [PMAT].[pmat_build_TABLE_config_flag_table_sub2]
--				: [PMAT].[pmat_build_TABLE_config_flag_table_sub3]
--				: [PMAT].[pmat_update_TABLE_process_status] - Logs TABLE Process Status
-- Functions	: [PMAT].[GetLiteralDataType]
-- Lookup Tables: [PMAT].[TABLE_DATA_CATEGORY]    - Lookup DATA_CATEGORY_NAME used in TABLE Definition table
-- Tables		: [PMAT].[TABLE_SOURCE_ANALYSIS]  - TABLE Definition table's defining Config Flags
--				: [PMAT].[TABLE_COUNT_COVERAGE]   - Config Flag Table 
--				: [PMAT].[TABLE_COUNT_NULL_BLANK] - Config Flag Table
--				: [PMAT].[TABLE_MIN_MAX_VALUE]    - Config Flag Table
--				: [PMAT].[TABLE_COUNT_COVERAGE]   - Config Flag Table
--				: [PMAT].[TABLE_PCT_COVERAGE]     - Config Flag Table
--				: [PMAT].[TABLE_PROCESS_STATUS]   - Logs TABLE Process Status
-- Views		: [PMAT].[VW_TABLE_SOURCE_ANALYSIS_LOAD]         - Used for BULK INSERT TABLE Definition data INTO [TABLE_SOURCE_ANALYSIS] table
--				: [PMAT].[VW_TABLE_SOURCE_ANALYSIS_MAIN_REPORT]  - Used for retriving data for a [Source_Main] Tab of a Source Analysis Report
--				: [PMAT].[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT] - Used for retriving data for a [Value_Count] Tab of a Source Analysis Report
/***********************************************************************************/
CREATE    PROCEDURE [PMAT].[pmat_build_TABLE_config_flag_table_main]
	@executable_db  varchar(50),
	@DebugFlag		BIT = 0, /* 0 - to execute; non-zero - to print SQL statements */
	@Database		varchar(500),
	@SchemaName		varchar(500),
	@TableConfig	varchar(500),
	@TableSrc		varchar(500) = NULL
AS
BEGIN

	DECLARE @TableFinal		 varchar(500),
			@ConfigFlag		 varchar(500),
			@ConfigFlagValue NCHAR(1) = N'1',
			@TableSrcRecCnt	 NVARCHAR(20) = N'0';

	DECLARE @cnt1 INT = 0, 
			@cnt2 INT = 0;

	DECLARE @TableSrcCnt   INT = CASE WHEN NULLIF(@TableSrc,'') IS NULL THEN 0 ELSE 1 END, 
			@ConfigFlagCnt INT = 0;

	DECLARE @SQL	  NVARCHAR(MAX) = N'',
			@SQLWhere NVARCHAR(200) = N'',
			@NewLine  CHAR(2) = CHAR(13) + CHAR(10);

	DECLARE @ProcName	 VARCHAR(200) = OBJECT_NAME(@@PROCID),
			@StepName	 VARCHAR(100) = 'Update TABLE Config Flag Tables - MAIN',
			@SubStepName VARCHAR(250) = 'Check if Source table is provided as an Input parameter @TableSrc';

	DECLARE @ErrorCode INT = 0,
			@ErrorMsg  NVARCHAR(2048) = N'';

	BEGIN TRY
		IF @DebugFlag = 1 SELECT [@StepName] = 'BEGIN '+@StepName;

		--1) Gets list of Config Flags from TABLE Analysis table
		SET @SubStepName = 'Get list of Config Flags from TABLE Definition table into #config_flag_list_tmp table';	

		-- Config Flag columns must be suffixed with a 'FLAG' keyword 
			SET @SQL = 	N'IF OBJECT_ID(N''['+ @Database+'].dbo.TABLE_CONFIG_FLAG_LIST_TMP'') IS NOT NULL'+@NewLine+ 
				   'DROP TABLE ['+ @Database+'].dbo.TABLE_CONFIG_FLAG_LIST_TMP;';

		EXECUTE sp_executesql @SQL;	

		
		/********************************/
		SET @SQL = ' use ['+ @Database+'] 
		;WITH CONFIG_FLAG_LIST AS (
		  SELECT DISTINCT COLUMN_NAME
		  FROM [INFORMATION_SCHEMA].COLUMNS CLM
		  WHERE CLM.TABLE_CATALOG ='''+ @Database+''' 
		  AND CLM.TABLE_SCHEMA ='''+ 'dbo'+ '''
		  AND TABLE_NAME = '''+ @TableConfig+ '''
		  AND COLUMN_NAME LIKE ''%FLAG''
		)
		SELECT ROW_NUMBER() OVER (ORDER BY [COLUMN_NAME]) AS ROW_ID, * 
		INTO ['+ @Database+'].dbo.TABLE_CONFIG_FLAG_LIST_TMP 
		FROM CONFIG_FLAG_LIST;'
	
	
		IF @DebugFlag = 1 
		   SELECT '['+@SQL +'SELECT INTO ['+ @Database+'].dbo.TABLE_CONFIG_FLAG_LIST_TMP] = @SQL';

		EXECUTE sp_executesql @SQL;	


		SET @ConfigFlagCnt = @@ROWCOUNT;
		--1) END

		IF @TableSrcCnt <> 0 --Source table was passed as an Input parameter;
			SET @SQLWhere = ' WHERE DATABASE_NAME = ''['+@Database+']'' AND 			
						/* TABLE_SCHEMA = '''+@SchemaName+''' AND */ TABLE_NAME = '''+@TableSrc+''' ';


		--2) Gets list of Source Tables defined in TABLE Definition table - [@TableConfig] parameter
		SET @SubStepName = 'Get list of Source Table(s) defined in TABLE Definition table into '+@Database+'.dbo.TABLE_LIST_TMP table';

		SET @SQL = 	N'IF OBJECT_ID(N''['+@Database+'].dbo.TABLE_LIST_TMP'') IS NOT NULL'+@NewLine+ 
				   'DROP TABLE ['+@Database+'].dbo.TABLE_LIST_TMP;';
		
		EXECUTE sp_executesql @SQL;	


		SET @SQL = ' use ['+ @Database+'] 
		;WITH TABLE_LIST AS (
		  SELECT DISTINCT [DATABASE_NAME], [TABLE_SCHEMA], [TABLE_NAME]
		  FROM ['+@Database+'].'+'dbo'+'.'+@TableConfig+@SQLWhere+'
		)
		SELECT ROW_NUMBER() OVER (ORDER BY [TABLE_NAME]) AS ROW_ID, * 
		INTO ['+@Database+'].dbo.TABLE_LIST_TMP 
		FROM TABLE_LIST; '
		
		IF @DebugFlag = 1 
			SELECT '['+@SQL +' SELECT INTO '+@Database+'.dbo.TABLE_LIST_TMP] = @SQL;'

		EXECUTE sp_executesql @SQL;	
	
		SET @TableSrcCnt = @@ROWCOUNT;	
	
		IF @DebugFlag = 1 SELECT [Procedure Name] = @ProcName, [@SQL to Get list of Source Table(s)] = @SQL;
		--2) END

		--3) Loops and processes each [@ConfigFlag] for each [@TableSrc]
		--select @cnt1 '@cnt1',@TableSrcCnt'@TableSrcCnt'

		set @Database = '['+@Database+']'

		WHILE @cnt1 < @TableSrcCnt
		BEGIN
			SET @cnt1 = @cnt1 + 1;
	
			SET @SubStepName = 'Assign @Database, @SchemaName and @TableSrc vars';	
			---------------------------------
		    set @SQL =' SELECT @Database   = DATABASE_NAME,  @SchemaName = TABLE_SCHEMA,  @TableSrc  = ''''+TABLE_NAME+'''' 
			  FROM '+ @Database+'.dbo.TABLE_LIST_TMP
			 WHERE ROW_ID = '+ convert(varchar(100),@cnt1) ;	
			
			EXEC sp_executesql @SQL,N'@Database varchar(500) OUTPUT,@SchemaName varchar(500) OUTPUT,@TableSrc varchar(500) OUTPUT '  ,@Database OUTPUT,@SchemaName OUTPUT
					,@TableSrc OUTPUT	;
		
			IF @DebugFlag = 1 
				 SELECT [Procedure Name] = @ProcName, 
						[@Database] = @Database, 
						[@SchemaName] = @SchemaName, 
						[@TableSrc] = @TableSrc;
					----------------------------------------------------

			--3.1) Gets the record count from a Source table - [@TableSrc] variable		
			SET @SubStepName = 'Assign @TableSrcRecCnt var for: '+case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end;
		

			set @SQL = 'USE '+@Database+'
			 
			SELECT @TableSrcRecCnt = CONVERT(NVARCHAR(20), MAX(I.ROWS))
			FROM SYSINDEXES I, INFORMATION_SCHEMA.TABLES T
			WHERE T.TABLE_NAME = OBJECT_NAME(I.ID)
				  AND T.TABLE_TYPE = ''BASE TABLE''
				  AND T.TABLE_SCHEMA = '''+@SchemaName+''' 
				  AND T.TABLE_NAME = '''+case when charindex('''',@TableSrc,1)=1
						then replace(@TableSrc,'''','''''')
						else
							@TableSrc
						end+'''
			GROUP BY T.TABLE_SCHEMA, T.TABLE_NAME;	'
		
			EXEC sp_executesql @SQL,N'@TableSrcRecCnt INT OUTPUT',	@TableSrcRecCnt OUTPUT;
				
			IF @DebugFlag = 1 
				 SELECT [Procedure Name] = @ProcName, 
					[@TableSrc] = 
							@TableSrc,
							[@TableSrcRecCnt] = @TableSrcRecCnt;		
			--3.1) END

			SET @SubStepName = 'BEGIN Updating TABLE Config Flag Tables for: '+@SchemaName+'.'+case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end;	

			IF @DebugFlag = 1 
				SELECT [@SubStepName] = @SubStepName;
		
			--Assigns @TableFinal variable;
			--Calls [PMAT].[sp_build_TABLE_config_flag_table_sub1] to continue the Process;

			--select @cnt2 '@cnt2',@ConfigFlagCnt '@ConfigFlagCnt'
			WHILE @cnt2 < @ConfigFlagCnt
			BEGIN
				SET @cnt2 = @cnt2 + 1;

				--3.2) Assigns @TableFinal variable;
				SET @SubStepName = 'Assign @ConfigFlag and @TableFinal vars for: '+@SchemaName+'.'+	case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end;
				set @SQL =' SELECT @ConfigFlag = COLUMN_NAME, 
					   @TableFinal = ''TABLE_''+REPLACE(COLUMN_NAME,''_FLAG'','''')
				  FROM '+ @Database+'.dbo.TABLE_CONFIG_FLAG_LIST_TMP
				 WHERE ROW_ID = '+convert(varchar(100),@cnt2)+';'
	
			    EXEC sp_executesql @SQL,N'@ConfigFlag VARCHAR(500) OUTPUT,@TableFinal VARCHAR(500) OUTPUT ',	@ConfigFlag OUTPUT,@TableFinal OUTPUT;
			

				IF @DebugFlag = 1 
					 SELECT [Procedure Name] = @ProcName, 
							[ConfigFlag] = @ConfigFlag, 
							[@TableFinal] = @TableFinal;
				--3.2) END
			
				--3.3) Calls [PMAT].[sp_build_TABLE_config_flag_table_sub1] to continue the Process;	
				SET @SubStepName = 'EXECUTE '+	@executable_db+'.PMAT.[pmat_build_TABLE_config_flag_table_sub1] for: '+@SchemaName+'.'+	case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end	;
		

				SET @SQL  =  	@executable_db+'.PMAT.[pmat_build_TABLE_config_flag_table_sub1] 
							@executable_db = ['+@executable_db+'],
							 @DebugFlag = '+CAST(@DebugFlag AS CHAR(1))+', 
							 @Database	= '''+@Database+''', 
							 @SchemaName = '''+@SchemaName+''', 
							 @TableConfig ='' '+@TableConfig+''', 
							 @TableSrc = '''+replace(@TableSrc,'''','''''')+''', 
							 @TableFinal = '''+@TableFinal+''', 
							 @ConfigFlag = '''+@ConfigFlag+''', 
							 @ConfigFlagValue = '''+@ConfigFlagValue+''', 
							 @TableSrcRecCnt ='' '+@TableSrcRecCnt+''';';
				SET  @SQL = 'EXECUTE '+@SQL;
			
				IF @DebugFlag = 1 
					SELECT 'EXECUTE PMAT.[pmat_build_TABLE_config_flag_table_sub1]' = @SQL;
				ELSE
					 EXEC [PMAT].[pmat_update_TABLE_process_status] @Database,'dbo', @ProcName, @StepName, @SubStepName, 'BEGIN', @TableSrcRecCnt, @ErrorCode, @ErrorMsg;
		
				EXEC sp_executesql @SQL;
			--3.3) END

			END	

			SET @SubStepName = 'END Updating TABLE Config Flag Tables for: '+case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end;

			IF @DebugFlag = 1
				SELECT [@SubStepName] = @SubStepName;
			ELSE
				EXEC [PMAT].[pmat_update_TABLE_process_status] @Database,'dbo', @ProcName, @StepName, @SubStepName, 'BEGIN', @TableSrcRecCnt, @ErrorCode, @ErrorMsg;			
			SET @cnt2 = 0;
				
		END

		SET @SubStepName = 'Drop '+@Database+'.dbo.TABLE_LIST_TMP and '+ @Database+'.dbo.TABLE_CONFIG_FLAG_LIST_TMP temp tables';

		SET @SQL = 	N'IF OBJECT_ID(N'''+@Database+'.dbo.TABLE_LIST_TMP'') IS NOT NULL'+@NewLine+ 
				   'DROP TABLE '+@Database+'.dbo.TABLE_LIST_TMP;';
	
		exec sp_executesql @SQL;
		SET @SQL = 	N'IF OBJECT_ID(N'''+@Database+'.dbo.TABLE_LIST_TMP'') IS NOT NULL'+@NewLine+ 
				   'DROP TABLE '+@Database+'.dbo.TABLE_LIST_TMP;';
		
		EXECUTE sp_executesql @SQL;	
				
				IF @DebugFlag = 1 
					SELECT 'DROP TABLE '+@Database+'.dbo.TABLE_LIST_TMP;		DROP TABLE '+ @Database+'.dbo.TABLE_CONFIG_FLAG_LIST_TMP;	' 
				ELSE
				 begin
					EXEC [PMAT].[pmat_update_TABLE_process_status] @Database,'dbo', @ProcName, @StepName, @SubStepName, 'BEGIN', @TableSrcRecCnt, @ErrorCode, @ErrorMsg;
		  			end

		IF @DebugFlag = 1 SELECT [@StepName] = 'END '+@StepName;
	END TRY

	BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();		
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);
		SET @SQL = 	N'IF OBJECT_ID(N'''+@Database+'.dbo.TABLE_LIST_TMP'') IS NOT NULL'+@NewLine+ 
				   'DROP TABLE '+@Database+'.dbo.TABLE_LIST_TMP;';
		 EXEC sp_executesql @SQL;
		SET @SQL = 	N'IF OBJECT_ID(N'''+@Database+'.dbo.TABLE_LIST_TMP'') IS NOT NULL'+@NewLine+ 
				   'DROP TABLE '+@Database+'.dbo.TABLE_LIST_TMP;';
		
		EXECUTE sp_executesql @SQL;	

		IF @DebugFlag <> 1 
				EXEC [PMAT].[pmat_update_TABLE_process_status] @Database,'dbo', @ProcName, @StepName, @SubStepName, 'BEGIN', @TableSrcRecCnt, @ErrorCode, @ErrorMsg;	
		RETURN @ErrorCode;
	END CATCH
END
GO
/****** Object:  StoredProcedure [PMAT].[pmat_build_TABLE_config_flag_table_sub1]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************************************/

-- Description	: This stored procedure is called from a Main stored procedure [pmat_build_TABLE_config_flag_table_part1]
--				: Initiates and Validates Input Parameters for [pmat_build_TABLE_config_flag_table_part3] call
--				: Logs main actions/errors; raises errors;
--				: Could be executed in Debug mode to print out SQL statements only;
-- Steps		: 1) Defines Config Flag table's Column List and their datatypes;
--				: 2) Assigns @ColName[1-3] and @ColDataType[1-3] variables;
--				: 3) Deletes an existing data from the [@ConfigFlag] tables - @TableFinal variable;AS NVARCHAR(1000)
--				: 4) Checks if @TableSrcRecCnt = 0; Logs a WARNING and Returns to the Main SP to continue the Process;
--				: 5) Checks if @ColName1 = [FIELD_KEY] (required field) and @ColDataType1 is numeric
--				:	5.1) Assigns @MinFieldKeyPerm, @MaxFieldKeyPerm and @Partition variables;
--				:	5.2) Logs the Error; Exits in Error;
--				: 6) Checks if Config Flag column is not populated in @TableConfig; Logs a WARNING and Returns to the Main SP to continue the Process;
--				: 7) Calls [PMAT].[pmat_build_TABLE_config_flag_table_part3] to continue the Process;
--	Susan	20180619	Modification for Schema Name
/**************************************************************************************************************************/

CREATE    PROCEDURE [PMAT].[pmat_build_TABLE_config_flag_table_sub1]
	@executable_db	varchar(50),
	@DebugFlag		  BIT = 1,   -- 1 to output SQL statements; 0 to execute	
	@Database		  varchar(500),
	@SchemaName		  varchar(500),
	@TableConfig	  varchar(500),
	@TableSrc		  varchar(500),
	@TableFinal		  varchar(500),
	@ConfigFlag		  varchar(500),
	@ConfigFlagValue  NCHAR(1),
	@TableSrcRecCnt	  NVARCHAR(20)

AS	
BEGIN

	DECLARE @TableInterm NVARCHAR(257) = @TableFinal+'_'+case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end ;
	DECLARE @DatabaseBrackets varchar(500);
	DECLARE @SchemaBrackets varchar(500);
	DECLARE @cnt INT = 0, 
			@cnt2 INT = 0;
	DECLARE @TableCnt INT = 0, 
			@ConfigFlagTblColCnt INT = 0;

	--Breaks Dynamic SQL into number of chunks
	DECLARE @SQLPartsNum  NCHAR(1) = '7'; 	
		
	--Stores intermediate SQL
	DECLARE @SQL		NVARCHAR(MAX) = N'',
			@NewLine	CHAR(2) = CHAR(13) + CHAR(10);

	--Stores Min/Max KeyField's values and the number of KeyFields to compute in one chunck of SQL
	DECLARE @MinFieldKeyPerm  INT = 0,
			@MaxFieldKeyPerm  INT = 0,
			@MinFieldKeyTemp  INT = 0,
			@MaxFieldKeyTemp  INT = 0,
			@Partition		  INT = 0;

	DECLARE @ColName1 nvarchar(200) = N'',
			@ColName2 nvarchar(200) = N'',
			@ColName3 nvarchar(200) = N'';

	DECLARE @ColDataType1 NVARCHAR(25) = N'',
			@ColDataType2 NVARCHAR(25) = N'',
			@ColDataType3 NVARCHAR(25) = N'';

	DECLARE @ProcName	 VARCHAR(200) = OBJECT_NAME(@@PROCID),
			@StepName	 VARCHAR(100) = 'Prepare to Update '+@TableFinal+' table',
			@SubStepName VARCHAR(250);

	DECLARE @ErrorMsg   NVARCHAR(2048) = N'',
			@ErrorCode  INT = 0;

	BEGIN TRY
		--1) Defines Config Flag table's Column List and their datatypes;
		--   Stores Column Names and Dataypes INTO #config_flag_table_column_list_tmp table
		SET @SubStepName = 'Define '+@TableFinal+' table column list and their datatypes into #config_flag_table_column_list_tmp table';
	
		set @DatabaseBrackets = case when charindex('[',@Database,1) = 0 then '['+@Database+']' 
									else @Database end
		 
	    set @Database =  replace(replace(@Database,'[',''),']','')

		set @SchemaBrackets = case when charindex('[',@SchemaName,1) = 0 then '['+@SchemaName+']' 
									else @SchemaName end
		 
	    set @SchemaName =  replace(replace(@SchemaName,'[',''),']','')


	    SET @SQL=	N' USE '+@DatabaseBrackets+' ' +@NewLine+ 
			'IF OBJECT_ID(N'''+@SchemaBrackets+'.config_flag_table_column_list_tmp'') IS NOT NULL'+@NewLine+ 
									'	DROP TABLE '+@SchemaBrackets+'.config_flag_table_column_list_tmp ;'
								 
		
		EXEC sp_executesql @SQL
		
		SET @SQL= ' USE  '+@DatabaseBrackets+' 
		;WITH CONFIG_FLAG_TABLE_COLUMN_LIST AS (
			SELECT DISTINCT COLUMN_NAME, 
							 dbo.GetLiteralDataType(TABLE_NAME, COLUMN_NAME) DATA_TYPE, 
							ORDINAL_POSITION
			  FROM [INFORMATION_SCHEMA].COLUMNS
			 WHERE TABLE_CATALOG = '''+@Database+'''
			   /*AND TABLE_SCHEMA = '''+@SchemaName+'''*/
			   AND TABLE_NAME = '''+@TableFinal+''' 
			   AND COLUMN_NAME LIKE ''FIELD%''
			   AND COLUMN_DEFAULT IS NULL      
		)
		SELECT ROW_NUMBER() OVER (ORDER BY [ORDINAL_POSITION], [COLUMN_NAME]) AS ROW_ID, 
			   COLUMN_NAME, DATA_TYPE	 
		INTO   '+@DatabaseBrackets+'.'+@SchemaBrackets+'.config_flag_table_column_list_tmp 
		FROM  CONFIG_FLAG_TABLE_COLUMN_LIST
		
		 ;
		'
	
		EXEC sp_executesql @SQL
	
		SET @ConfigFlagTblColCnt = @@ROWCOUNT;

		--1) END

		--2) Assigns variables
		--   Currently there could be up to 3 non-audit columns in TABLE_[@ConfigFlag] table
		--   Assign column names and datatypes variables
		SET @SubStepName = 'Assign @ColName[1-3] and @ColDataType[1-3] variables';

		WHILE @cnt < @ConfigFlagTblColCnt
		BEGIN
			SET @cnt = @cnt + 1;
		  	
			IF @cnt = 1 
			   begin
				  SET @SQL = 'SELECT @ColName1 = COLUMN_NAME, @ColDataType1 = DATA_TYPE 
				   FROM  '+@DatabaseBrackets+'.'+@SchemaBrackets+'.config_flag_table_column_list_tmp 
				   WHERE ROW_ID = '+ convert(varchar(5),@cnt) +';'
				  EXEC sp_executesql @SQL,N'@ColName1 nvarchar(50) OUTPUT, @ColDataType1 nvarchar(50) OUTPUT'
										,@ColName1 OUTPUT
										,@ColDataType1 OUTPUT
			   end

			IF @cnt = 2 
				begin
				  SET @SQL = 'SELECT @ColName2 = COLUMN_NAME, @ColDataType2 = DATA_TYPE 
				  FROM  '+@DatabaseBrackets+'.'+@SchemaBrackets+'.config_flag_table_column_list_tmp 
				   WHERE ROW_ID = '+ convert(varchar(5),@cnt) +';'
				  EXEC sp_executesql @SQL,N'@ColName2 nvarchar(50) OUTPUT, @ColDataType2 nvarchar(50) OUTPUT'
										,@ColName2 OUTPUT
										,@ColDataType2 OUTPUT
				
				end
			IF @cnt = 3 
				begin
				 SET @SQL = 'SELECT @ColName3 = COLUMN_NAME, @ColDataType3 = DATA_TYPE 
				   FROM  '+@DatabaseBrackets+'.'+@SchemaBrackets+'.config_flag_table_column_list_tmp 
				   WHERE ROW_ID = '+ convert(varchar(5),@cnt) +';'
				  EXEC sp_executesql @SQL,N'@ColName3 nvarchar(50) OUTPUT, @ColDataType3 nvarchar(50) OUTPUT'
										,@ColName3 OUTPUT
										,@ColDataType3 OUTPUT
				end
		
	
		END		

		SET @SubStepName = '--will DROP ##config_flag_table_column_list_tmp temp table';

		 SET @SQL=	N' USE '+@DatabaseBrackets+' ' +@NewLine+ 
			'IF OBJECT_ID(N'''+@SchemaBrackets+'.config_flag_table_column_list_tmp'') IS NOT NULL'+@NewLine+ 
									'	DROP TABLE '+@SchemaBrackets+'.config_flag_table_column_list_tmp ;'
		EXEC sp_executesql @SQL

		IF @DebugFlag = 1 
			 SELECT @SQL,[Procedure Name] = @ProcName, [@TableFinal] = @TableFinal, 
					[@ColName1] = @ColName1, [@ColDataType1] = @ColDataType1, 
					[@ColName2] = @ColName2, [@ColDataType2] = @ColDataType2, 
					[@ColName3] = @ColName3, [@ColDataType3] = @ColDataType3;
		ELSE
		
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
	
	END TRY

	BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);

		IF @DebugFlag <> 1 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'FAILED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;

		RETURN @ErrorCode;
	END CATCH
	--2) END

	--3) Deletes existing data from the [@ConfigFlag] table - @TableFinal variable	
	BEGIN TRY
		SET @SubStepName = 'DELETE existing data from '+@DatabaseBrackets+'.'+@SchemaBrackets+'.'+@TableFinal;

		SET @SQL = 	N'IF OBJECT_ID(N'''+@DatabaseBrackets+'.'+'dbo'+'.'+@TableFinal+''') IS NOT NULL'+@NewLine+ 
				   'DELETE '+@DatabaseBrackets+'.'+'dbo'+'.'+@TableFinal+@NewLine+
				   'WHERE EXISTS (SELECT 1 FROM '+@DatabaseBrackets+'.'+'dbo'+'.'+ltrim(@TableConfig)+'
								   WHERE DATABASE_NAME = '''+@DatabaseBrackets+''' 
									 AND TABLE_NAME = '''+case when charindex('''',@TableSrc,1)=1
														then replace(@TableSrc,'''','''''')
														else
															@TableSrc
														end+''' 
									 AND TABLE_SCHEMA ='''+@SchemaName+'''
									 AND '+@ConfigFlag+' = '+@ConfigFlagValue+'
									 AND '+@TableFinal+'.'+@ColName1+' = '+@ColName1+');'+@NewLine+@NewLine;
  
		 if @DebugFlag =1
			 SELECT [Procedure Name] = @ProcName, 
					[Delete @SQL] = @SQL;
		ELSE
		BEGIN
			EXEC sp_executesql @SQL;
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
		end
 	END	TRY

	BEGIN catch
		SET @ErrorCode = ERROR_NUMBER();
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);

		IF @DebugFlag <> 1 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'FAILED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
			
		RETURN @ErrorCode;
	END CATCH
	--3) END

	--4) Checks if @TableSrcRecCnt = 0; Logs a WARNING and Returns to the Main SP to continue the Process
	IF ISNULL(@TableSrcRecCnt, '0') = '0 '
	BEGIN		
		SET @SubStepName = 'Check '+case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end+' table record count';		
		
		SET @ErrorMsg  = '!!!!WARNING - Table '+@TableSrc+' is empty!!! Returning to the Main procedure.';

		IF @DebugFlag = 1
			SELECT WARNING = @ErrorMsg;
		ELSE 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'WARNING', @@ROWCOUNT, @ErrorCode, @ErrorMsg;

		RETURN @ErrorCode;
	END
	--4) END

	--5) Checks if @ColName1 = [FIELD_KEY] (required field) and @ColDataType1 is numeric 
	IF @ColName1 = 'FIELD_KEY' AND @ColDataType1 LIKE '%INT'
	BEGIN --5.1) Assigns @MinFieldKeyPerm, @MaxFieldKeyPerm and @Partition variables
		BEGIN TRY
			-- Gets Min/Max FIELD_KEY value and calculate Partition size for a given Config Flag to break the final SQL into chunks
			SET @SubStepName = 'Assign @MinFieldKeyPerm, @MaxFieldKeyPerm and @Partition vars';
	
	      set @SQL = N'SELECT @MinFieldKeyPerm = MIN('+@ColName1+'), '+@NewLine+
						'		@MaxFieldKeyPerm = MAX('+@ColName1+'), '+@NewLine+
						'		@Partition = ( MAX('+@ColName1+') - MIN('+@ColName1+') ) / '+@SQLPartsNum+' + 1'+@NewLine+
						'  FROM '+@DatabaseBrackets+'.'+'dbo'+'.'+ltrim(@TableConfig)+@NewLine+
						' WHERE DATABASE_NAME = '''+@DatabaseBrackets+''''+@NewLine+
						'  AND TABLE_SCHEMA = '''+@SchemaName+''''+@NewLine+
						'	AND TABLE_NAME = '''+case when charindex('''',@TableSrc,1)=1
														then replace(@TableSrc,'''','''''')
														else
															@TableSrc
														end+''''+@NewLine+
						'	AND '+@ConfigFlag+' = '+@ConfigFlagValue+';'			

			EXEC sp_executesql @SQL,
						N'@MinFieldKeyPerm INT OUTPUT,@MaxFieldKeyPerm INT OUTPUT, @Partition INT OUTPUT',
						@MinFieldKeyPerm OUTPUT, @MaxFieldKeyPerm OUTPUT, @Partition OUTPUT;
		
			IF @DebugFlag = 1 
				SELECT [Procedure Name] = @ProcName, 
					   [@MinFieldKeyPerm] = CAST(@MinFieldKeyPerm AS NVARCHAR(25)), 
					   [@MaxFieldKeyPerm] = CAST(@MaxFieldKeyPerm AS NVARCHAR(25)), 
					   [@Partition] = CAST(@Partition AS NVARCHAR(10)), 
					   [Select @SQL] = @SQL;
			ELSE			
				EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
		END TRY

		BEGIN catch
         	SET @ErrorCode = ERROR_NUMBER();
			SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
			RAISERROR(@ErrorMsg, 16, 1);

			IF @DebugFlag <> 1 
				EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'FAILED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
				
			RETURN @ErrorCode;
		END CATCH		
	END --5.1) END
	ELSE 
	BEGIN --5.2) Logs the Error; Exits in Error
		SET @ErrorCode = -1;
		SET @SubStepName = 'Checks assigned values to @ColName1 and @ColDataType1 vars'; 		
		SET @ErrorMsg = '!!!!ERROR - Table '+@TableFinal+' must contain [FIELD_KEY] column with BIG[INT] datatype!!! Exiting...';

		RAISERROR(@ErrorMsg, 16, 1);

		IF @DebugFlag <> 1 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'FAILED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;		

		RETURN @ErrorCode;
	END --5.2) END
	--5) END

	--6) Checks if Config Flag column is not populated in @TableConfig;
	--   Logs a WARNING and Returns to the Main SP to continue the Process	
	IF @MinFieldKeyPerm IS NULL 
	BEGIN
		SET @ErrorCode = 0;
		SET @SubStepName = 'Check if Config Flag column is not populated in '+@TableConfig;
		SET @ErrorMsg = 'WARNING: '+@TableConfig+'.'+@ConfigFlag+' is not configured for '+case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end+'; Table: '+@TableFinal+' was not populated.';
		
		IF @DebugFlag =1
			SELECT WARNING = @ErrorMsg;
		ELSE 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'WARNING', @@ROWCOUNT, @ErrorCode, @ErrorMsg;

		RETURN @ErrorCode;
	END
	--6) END

	--7) Calls [PMAT].[sp_build_TABLE_config_flag_table_part3] to continue the Process
	BEGIN TRY
		SET @SubStepName = 'EXECUTE '+@executable_db+'.PMAT.[pmat_build_TABLE_config_flag_table_sub2] ';
		
		SET @SQL = 'EXECUTE '+@executable_db+'.PMAT.[pmat_build_TABLE_config_flag_table_sub2] 
					@executable_db	 = ['+@executable_db+'],
					@DebugFlag		 = '+CAST(@DebugFlag AS CHAR(1))+', 
					@Database		 = '+@DatabaseBrackets+', 
					@SchemaName		 = '+@SchemaBrackets+', 
					@TableConfig	 = '+@TableConfig+', 
					@TableSrc		 = '''+case when charindex('''',@TableSrc,1)=1
														then replace(@TableSrc,'''','''''')
														else
															@TableSrc
														end+''', 
					@TableFinal		 = '+@TableFinal+',
					@TableInterm	 = '''+@TableInterm+''', 
					@ConfigFlag		 = '+@ConfigFlag+',
					@ConfigFlagValue = '+@ConfigFlagValue+', 
					@TableSrcRecCnt  = '+@TableSrcRecCnt+', 
					@SQLPartsNum	 = '+@SQLPartsNum+', 
					@MinFieldKeyPerm = '+CAST(@MinFieldKeyPerm AS NVARCHAR(25))+', 
					@MaxFieldKeyPerm = '+CAST(@MaxFieldKeyPerm AS NVARCHAR(25))+', 
					@MinFieldKeyTemp = '+CAST(@MinFieldKeyTemp AS NVARCHAR(25))+', 
					@MaxFieldKeyTemp = '+CAST(@MaxFieldKeyTemp AS NVARCHAR(25))+', 
					@Partition		 = '+CAST(@Partition AS NVARCHAR(10))+', 
					@ColName1 		 = '''+@ColName1+''', 
					@ColName2 		 = '''+@ColName2+''', 
					@ColName3 		 = '''+@ColName3+''', 
					@ColDataType1	 = '''+@ColDataType1+''', 
					@ColDataType2 	 = '''+@ColDataType2+''', 
					@ColDataType3	 = '''+@ColDataType3+''';';
		 
		IF @DebugFlag = 1 
			SELECT 'EXECUTE [pmat_build_TABLE_config_flag_table_sub2]' = 'EXEC '+@SQL;
			
		EXEC sp_executesql @SQL;
		
		IF @DebugFlag <> 1 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
		
		RETURN @ErrorCode;	
	END TRY

	BEGIN CATCH
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);

		IF @DebugFlag <> 1 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'FAILED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;

		RETURN @ErrorCode;
	END CATCH
	--7) END

END
GO
/****** Object:  StoredProcedure [PMAT].[pmat_build_TABLE_config_flag_table_sub2]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************************************/

-- Description	: PART I  - Creates and executes dynamic SQL to build an Interm TABLE_[@ConfigFlag]_[@TableSrc] PIVOT table
--				: PART II - Calls [PMAT].[sp_build_TABLE_config_flag_table_part4]
--				: Could be executed in Debug mode to print out SQL statements only;
--				: 1) DELETEs an existing data from a TABLE_[@ConfigFlag] table;
--				: 2) UNPIVOTs TABLE_[@ConfigFlag]_[@TableSrc] Interm table's data and INSERTs data into TABLE_[@ConfigFlag] table;
--				: 3) DROPs TABLE_[@ConfigFlag] Intermediate table;
--	20180619	Susan	Changes for Schema Name
--	20180622	Susan	Changes for the Null decimals
--	20190828	Susan	Added SQL7
/**************************************************************************************************************************/

CREATE   PROCEDURE [PMAT].[pmat_build_TABLE_config_flag_table_sub2]
	@executable_db		varchar(50),
	@DebugFlag		  BIT = 1, /* 0 - to execute; non-zero - to print SQL statements */
	@Database		  varchar(500),
	@SchemaName		  varchar(500),
	@TableConfig	  varchar(500),
	@TableSrc		  varchar(500),
	@TableFinal		  varchar(500),
	@TableInterm	  varchar(500),
	@ConfigFlag		  varchar(500),
	@ConfigFlagValue  NCHAR(1),
	@TableSrcRecCnt   NVARCHAR(25) = N'0',
	@SQLPartsNum	  NCHAR(1) = '7',

	--Stores Min/Max KeyField's values and the number of KeyFields to compute in one chunck of SQL
	@MinFieldKeyPerm  INT = 0,
	@MaxFieldKeyPerm  INT = 0,
	@MinFieldKeyTemp  INT = 0,
	@MaxFieldKeyTemp  INT = 0,
	@Partition		  INT = 0,
	@ColName1	  varchar(500) = N'',
	@ColName2	  varchar(500) = N'',
	@ColName3	  varchar(500) = N'',
	@ColDataType1 NVARCHAR(25) = N'',
	@ColDataType2 NVARCHAR(25) = N'',
	@ColDataType3 NVARCHAR(25) = N''

AS    
BEGIN 
  

	DECLARE @ColNamePattern1 NVARCHAR(50) = '_'+@ColName1,
			@ColNamePattern2 NVARCHAR(50) = '_'+@ColName2,
			@ColNamePattern3 NVARCHAR(50) = CASE WHEN @ColName3 <> '' THEN '_'+@ColName3 ELSE '' END;

	DECLARE @NewLine NVARCHAR(50) = CHAR(13) + CHAR(10);

	DECLARE @DatabaseBrackets varchar(500);
	DECLARE @SchemaBrackets varchar(500);
	
	DECLARE @SQLStrDrop		NVARCHAR(MAX) = N'',
			@SQLStrDelete	NVARCHAR(MAX) = N'',
			@SQLStrInsert	NVARCHAR(MAX) = N'',
			@SQLStrIn		NVARCHAR(MAX) = N'',
			@SQLStrSelect	NVARCHAR(MAX) = N'',
			@SQLStrOrder	NVARCHAR(MAX) = N'',
			@SQLStrFrom		NVARCHAR(MAX) = N'',
			@SQLStrOut		NVARCHAR(MAX) = N'',
			@ParmDefinition	NVARCHAR(500) = N'';

	--to prevent dynamic SQL from exceeding 8000 chars, break SQL into chunks;
	--if final SQL Statement gets truncated, DECLARE @SQL8... vars and add logic accordingly
	DECLARE	@SQL  NVARCHAR(MAX) = N'',
			@SQL1 NVARCHAR(MAX) = N'',
			@SQL1b NVARCHAR(MAX) = N'',
			@SQL2 NVARCHAR(MAX) = N'',
			@SQL3 NVARCHAR(MAX) = N'',
			@SQL4 NVARCHAR(MAX) = N'',
			@SQL5 NVARCHAR(MAX) = N'',
			@SQL6 NVARCHAR(MAX) = N'',
			@SQL7 NVARCHAR(MAX) = N'';

	DECLARE @ProcName	 VARCHAR(200) = OBJECT_NAME(@@PROCID),
			@StepName	 VARCHAR(100) = 'Build '+@TableInterm+' - PIVOT table',
			@SubStepName VARCHAR(250);

	DECLARE @ErrorCode INT = 0,
			@Cnt	   INT = 1,
			@CntChar   NVARCHAR(25) = N'1',
			@ColCnt	   INT = 0,
			@ErrorMsg NVARCHAR(2048) = N'';
			
	set @DatabaseBrackets = case when charindex('[',@Database,1) = 0 then '['+@Database+']' 
									else @Database end
		 
	set @Database =  replace(replace(@Database,'[',''),']','')

	set @SchemaBrackets = case when charindex('[',@SchemaName,1) = 0 then '['+@SchemaName+']' 
									else @SchemaName end
		 
	set @SchemaName =  replace(replace(@SchemaName,'[',''),']','')

	--Intialize Min/Max Table's Key values to be used in a WHERE Clause as a range 
	SET @MinFieldKeyTemp = @MinFieldKeyPerm;
	SET @MaxFieldKeyTemp = @MinFieldKeyPerm + @Partition;
	
	--/*SB DEBUG*/
	--SELECT 'Start Sub2 ' + @SchemaBrackets
	--Creates SELECT parts of a SQL statement specific to the @ConfigFlag
	IF @ConfigFlag = 'COUNT_COVERAGE_FLAG'
	BEGIN
		SET @SubStepName = 'Assign @SQLStrSelect var for '+@ConfigFlag+' Config Flag';
		SET @SQLStrSelect = '
		SELECT @SQLStrOut += '','' + CAST('+@ColName1+' AS VARCHAR(25))+''  ''+QUOTENAME(COLUMN_NAME+@ColNamePattern1)+'', ''+ 
		 CASE WHEN DATA_TYPE LIKE ''%CHAR%'' THEN 
		          ''COUNT(NULLIF(''+QUOTENAME(COLUMN_NAME)+'', '''''''')) ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+@NewLine
		      WHEN  DATA_TYPE LIKE ''%INT%'' or DATA_TYPE LIKE ''DEC%'' THEN 
			  	  ''COUNT(NULLIF(''+QUOTENAME(COLUMN_NAME)+'', 0)) ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+@NewLine
			ELSE 
		           ''COUNT(''+QUOTENAME(COLUMN_NAME)+'') ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+@NewLine END';
	END

	IF @ConfigFlag = 'COUNT_NULL_BLANK_FLAG'
	BEGIN
		SET @SubStepName = 'Assign @SQLStrSelect var for '+@ConfigFlag+' Config Flag';
		SET @SQLStrSelect = '
		SELECT @SQLStrOut += '','' + CAST('+@ColName1+' AS VARCHAR(25))+'' ''+QUOTENAME(COLUMN_NAME+@ColNamePattern1)+'', ''+ 
		CASE WHEN DATA_TYPE LIKE ''%CHAR%'' THEN 
					''SUM(CASE WHEN NULLIF(''+QUOTENAME(COLUMN_NAME)+'', '''''''') IS NULL THEN 1 ELSE 0 END) ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+@NewLine
			WHEN  DATA_TYPE LIKE ''%INT%'' or DATA_TYPE LIKE ''DEC%'' THEN 
			   	    ''SUM(CASE WHEN NULLIF(''+QUOTENAME(COLUMN_NAME)+'', 0) IS NULL THEN 1 ELSE 0 END) ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+@NewLine
		ELSE 
		''SUM(CASE WHEN ''+QUOTENAME(COLUMN_NAME)+'' IS NULL THEN 1 ELSE 0 END) ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+@NewLine END';
	END

	IF @ConfigFlag = 'PCT_COVERAGE_FLAG'
	BEGIN
		SET @SubStepName = 'Assign @SQLStrSelect var for '+@ConfigFlag+' Config Flag';
		SET @SQLStrSelect = '
		SELECT @SQLStrOut += '','' + CAST('+@ColName1+' AS VARCHAR(25))+'' ''+QUOTENAME(COLUMN_NAME+@ColNamePattern1)+'', ''+ 
		CASE WHEN DATA_TYPE LIKE ''%CHAR%'' THEN
		''CONVERT('+@ColDataType2+', SUM(CASE WHEN NULLIF(''+QUOTENAME(COLUMN_NAME)+'', '''''''') IS NULL THEN 0 ELSE 1 END) * 100.00/'+case when @TableSrcRecCnt = 0 then '1' else @TableSrcRecCnt end+') ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+@NewLine
		      WHEN  DATA_TYPE LIKE ''%INT%'' or DATA_TYPE LIKE ''DEC%'' THEN 
			   	    ''CONVERT('+@ColDataType2+', SUM(CASE WHEN NULLIF(''+QUOTENAME(COLUMN_NAME)+'', 0) IS NULL THEN 0 ELSE 1 END) * 100.00/'+case when @TableSrcRecCnt = 0 then '1' else @TableSrcRecCnt end+') ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+@NewLine
		ELSE 
		''CONVERT('+@ColDataType2+', SUM(CASE WHEN ''+QUOTENAME(COLUMN_NAME)+'' IS NULL THEN 0 ELSE 1 END) * 100.00/'+case when @TableSrcRecCnt = 0 then '1' else @TableSrcRecCnt end+') ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+@NewLine END';
	END
	
	IF @ConfigFlag = 'MIN_MAX_VALUE_FLAG'
	BEGIN
	
		SET @SubStepName = 'Assign @SQLStrSelect var for '+@ConfigFlag+' Config Flag';
		SET @SQLStrSelect = '
		SELECT @SQLStrOut += '','' + CAST('+@ColName1+' AS VARCHAR(25))+''  ''+QUOTENAME(COLUMN_NAME+@ColNamePattern1)+'', ''+ 
		CASE WHEN DATA_TYPE LIKE ''%CHAR%'' THEN
				''ISNULL(MIN(NULLIF(''+QUOTENAME(COLUMN_NAME)+'', '''''''')), '''''''') ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+'' , ''	
			 WHEN DATA_TYPE LIKE ''%DATE%'' THEN
				''ISNULL(MIN(NULLIF(CONVERT(NVARCHAR(25),''+QUOTENAME(COLUMN_NAME)+'',23), ''''1900-01-01'''')), '''''''')  ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+'', ''	
			 WHEN DATA_TYPE LIKE ''%INT%'' THEN
			    ''ISNULL(MIN(NULLIF(''+QUOTENAME(COLUMN_NAME)+'', 0)), 0) ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+'', ''	
			 WHEN DATA_TYPE LIKE ''DEC%'' THEN
			    ''ISNULL(MIN(NULLIF(''+QUOTENAME(COLUMN_NAME)+'', 0)), 0)''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+'', ''	
			 ELSE
				''ISNULL(MIN(''+QUOTENAME(COLUMN_NAME)+''), '''''''') ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+'', ''
		END+
		CASE WHEN DATA_TYPE LIKE ''%DATE%'' THEN
				''ISNULL(MAX(NULLIF(CONVERT(NVARCHAR(25),''+QUOTENAME(COLUMN_NAME)+'',23), ''''1900-01-01'''')), '''''''') ''+QUOTENAME(COLUMN_NAME+@ColNamePattern3)+@NewLine
			  WHEN DATA_TYPE LIKE ''%INT'' THEN
					''ISNULL(MAX(''+QUOTENAME(COLUMN_NAME)+''), 0) ''+QUOTENAME(COLUMN_NAME+@ColNamePattern3)+@NewLine
			WHEN DATA_TYPE LIKE ''DEC%'' THEN
					''ISNULL(MAX(''+QUOTENAME(COLUMN_NAME)+''), 0) ''+QUOTENAME(COLUMN_NAME+@ColNamePattern3)+@NewLine
			 ELSE
				''ISNULL(MAX(''+QUOTENAME(COLUMN_NAME)+''), '''''''') collate database_default ''+QUOTENAME(COLUMN_NAME+@ColNamePattern3)+@NewLine 
		END';
	END
	--		

	--Creates INSERT and SELECT parts of a SQL statement specific to the @ConfigFlag
	
	IF @ConfigFlag = 'COUNT_VALUE_FLAG'
	BEGIN
		SET @SubStepName = 'Assign @SQLStrInsert var for '+@ConfigFlag+' Config Flag';
		SET @SQLStrInsert += N'INSERT INTO ['+@Database+'].'+'dbo'+'.['+@TableFinal+'] ('+@ColName1+', '+@ColName2+CASE WHEN @ColNamePattern3 <> '' THEN ', '+@ColName3 ELSE '' END+')'+@NewLine;
		
		SET @SubStepName = 'Assign @SQLStrSelect var for '+@ConfigFlag+' Config Flag';
		SET @SQLStrSelect = '
		SELECT @SQLStrOut += ''UNION SELECT ''+ CAST('+@ColName1+' AS VARCHAR(25))+'' ''+QUOTENAME(COLUMN_NAME+@ColNamePattern1)+'', 	 
		CAST(''+QUOTENAME(COLUMN_NAME)+'' AS '+@ColDataType2+') ''+QUOTENAME(COLUMN_NAME+@ColNamePattern2)+'', ''+
		''COUNT(ISNULL(''+QUOTENAME(COLUMN_NAME)+'',null)) ''+QUOTENAME(COLUMN_NAME+@ColNamePattern3)+@NewLine+'' ''+	
		''FROM ['+@Database+'].'+@SchemaBrackets+'.['+case when charindex('''',@TableSrc,1)=1
															then replace(@TableSrc,'''','''''')
															else
																@TableSrc
															end+']''+@NewLine+
		''GROUP BY ''+QUOTENAME(COLUMN_NAME)+@NewLine';
	END
	--
	
	
	--Loop through num of SQL parts and Assign @SQL1-7
	BEGIN TRY
		SET @SubStepName = 'Loop through '+@SQLPartsNum+' times to generate and exec dynamic SQL';		

		--Initiate PIVOT table name
		SET @TableInterm = @TableInterm + @CntChar;
	
		WHILE @Cnt <= @SQLPartsNum
		BEGIN		
			SET @SubStepName = 'Loop counter: '+CAST(@Cnt AS VARCHAR(2))+' - generate dynamic SQL';
	
			
			IF @DebugFlag = 1 
				 SELECT [Procedure Name] = @ProcName, 
						[Loop @Cnt] = CAST(@Cnt AS VARCHAR(2)), 
						[@MinFieldKeyTemp] = CAST(@MinFieldKeyTemp AS VARCHAR(25)), 
						[@MaxFieldKeyTemp] = CAST(@MaxFieldKeyTemp AS VARCHAR(25));


			--SQL to DELETE an existing data from a TABLE_[@ConfigFlag] table
			SET @SubStepName = 'Assign @SQLStrDelete var to DELETE an existing data from a TABLE_[@ConfigFlag] table';

			SET @SQLStrDelete = 
						N'IF OBJECT_ID(N''['+@Database+'].'+'dbo'+'.['+@TableFinal+']'') IS NOT NULL'+@NewLine+ 
					   'DELETE ['+@Database+'].'+'dbo'+'.['+@TableFinal+']'+@NewLine+
					   'WHERE EXISTS (SELECT 1 FROM ['+@Database+'].'+'dbo'+'.'+@TableConfig+'
									   WHERE DATABASE_NAME = '''+@DatabaseBrackets+'''
										 AND TABLE_NAME = '''+case when charindex('''',@TableSrc,1)=1
															then replace(@TableSrc,'''','''''')
															else
																@TableSrc
															end+''' 
										 AND SCHEMA_NAME ='''+replace(replace(@SchemaBrackets,'[',''),']','')+'''
										 AND '+@ConfigFlag+' = '+@ConfigFlagValue+'
										 AND '+@TableFinal+'.'+@ColName1+' = '+@ColName1+'
										 AND '+@TableFinal+'.'+@ColName1+' BETWEEN '+CAST(@MinFieldKeyTemp AS VARCHAR(5))+' AND '+CAST(@MaxFieldKeyTemp AS VARCHAR(5))+');'+@NewLine+@NewLine;

			--Creates DROP and INSERT parts of a SQL statement specific to the @ConfigFlag and loop counter
			IF @ConfigFlag IN ('COUNT_COVERAGE_FLAG','COUNT_NULL_BLANK_FLAG','PCT_COVERAGE_FLAG','MIN_MAX_VALUE_FLAG')
			BEGIN
				SET @SubStepName = 'Assign @SubStepName var to DROP ['+@Database+'].'+@SchemaBrackets+'.['+@TableInterm+'] table';
				SET @SQLStrDrop = N'IF OBJECT_ID(N''['+@Database+'].'+@SchemaBrackets+'.['+@TableInterm+']'') IS NOT NULL DROP TABLE ['+@Database+'].'+@SchemaBrackets+'.['+@TableInterm+'];'+@NewLine;

				SET @SubStepName = 'Assign @SQLStrInsert var generate INTO and FROM parts of SQL statement';
				SET @SQLStrInsert = ' INTO ['+@Database+'].'+@SchemaBrackets+'.['+@TableInterm+'] FROM ['+@Database+'].'+@SchemaBrackets+'.['+@TableSrc+']';

			END

			
	
			SET @SubStepName = 'Loop counter: '+@CntChar+' Assign @SQLStrFrom var';
			SET @SQLStrFrom = '
			FROM ['+@Database+'].'+'dbo'+'.'+@TableConfig+'
			WHERE DATABASE_NAME = '''+ @DatabaseBrackets+'''
			 AND TABLE_SCHEMA ='''+replace(replace(@SchemaBrackets,'[',''),']','')+''' 
			 AND TABLE_NAME = '''+case when charindex('''',@TableSrc,1)=1
						then replace(@TableSrc,'''','''''')
						else
							@TableSrc
						end+''' 
			AND '+@ConfigFlag+' = '+@ConfigFlagValue+'
			AND '+@ColName1+' BETWEEN '+CAST(@MinFieldKeyTemp AS VARCHAR(5))+' AND '+CAST(@MaxFieldKeyTemp AS VARCHAR(5))+'
			ORDER BY '+@ColName1+';';
			

			SET @SubStepName = 'Assign @SQLStrIn = @SQLStrSelect + @SQLStrFrom';
		
			SET @SQLStrIn = @SQLStrSelect + @SQLStrFrom;


			IF @DebugFlag = 1 
				 SELECT [Procedure Name] = @ProcName, 
						[@SQLStrIn] = @SQLStrIn;
			
			SET @SubStepName = 'EXECUTE sp_executesql from @SQLStrIn and @ParmDefinition';
			SET @ParmDefinition = N'@ColNamePattern1 SYSNAME, @ColNamePattern2 SYSNAME, @ColNamePattern3 SYSNAME, @NewLine NVARCHAR(50),
									@SQLStrOut NVARCHAR(MAX) OUTPUT';
     --           /*SB DEBUG*/
			  --select 'BEfore the SQLStrINS' + @SQLStrIn
			EXECUTE sp_executesql  
				 @SQLStrIn  
				,@ParmDefinition  		
				,@ColNamePattern1 = @ColNamePattern1 
				,@ColNamePattern2 = @ColNamePattern2
				,@ColNamePattern3 = @ColNamePattern3 
				,@NewLine = @NewLine
				,@SQLStrOut = @SQLStrOut OUTPUT; 


			IF @DebugFlag = 1 
				 SELECT [Procedure Name] = @ProcName, 
						[@ParmDefinition] = @ParmDefinition,
						[@SQLStrOut] = @SQLStrOut;


	if NULLIF(@SQLStrOut,'') IS NOT NULL 
			BEGIN
				--Reassign @SQLStrOut to the permanent @SQL1 variable 
				SET @SubStepName = 'Reassign @SQLStrOut to the permanent @SQL1 var';
			
				SET @SQL1 = ISNULL(@SQLStrOut,'');
			
				IF @DebugFlag = 1 
					SELECT [Procedure Name] = @ProcName, 
						   [@SQL1] = @SQL1;	

			
	
				IF @ConfigFlag IN ('COUNT_COVERAGE_FLAG','COUNT_NULL_BLANK_FLAG','PCT_COVERAGE_FLAG','MIN_MAX_VALUE_FLAG')
				BEGIN
				
					SET @SQL1 = 'SELECT '+ STUFF(@SQL1, 1, 1, ''); --Remove 1st comma		
					
					-- PART I -- 
					SET @SubStepName = 'Combine and Execute @SQLStrDrop + @SQL1 + @SQLStrInsert Statements';

					DECLARE @SQLStrWhere NVARCHAR(50) = N'';

					IF @DebugFlag = 1 
					BEGIN				
						 SET @SQLStrWhere = 'WHERE 1 = 0'; --Creates table structure for debbuging SQL 

						 SELECT [Procedure Name] = @ProcName, 
								[@SQLStrDrop] = @SQLStrDrop, 
								[@SQL1]	= @SQL1 ,
								[@SQLStrInsert] = @SQLStrInsert,
								[@SQLStrWhere] = @SQLStrWhere;

					END	
				
	
					EXEC (@SQLStrDrop+' '+@SQL1+' '+@SQLStrInsert+' '+@SQLStrWhere+';');
		

					IF @DebugFlag <> 1
						EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;

		           
				
					-- PART II ----replace(replace(@SchemaBrackets,'[',''),']','')+', 
					SET @SubStepName = 'EXECUTE [pmat_build_TABLE_config_flag_table_sub3] for: '+case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end;
			
					SET @SQL = 'EXECUTE '+@executable_db+'.PMAT.[pmat_build_TABLE_config_flag_table_sub3]'+@NewLine+'
								@executable_db		= ['+@executable_db+'],
							   @DebugFlag       = '+CAST(@DebugFlag AS NCHAR(1))+',
							   @Database		= ['+@Database+'],
							   @SchemaName		= '+@SchemaBrackets +',							   
							   @TableConfig	    = '+@TableConfig+',
							   @ConfigFlag		= '+@ConfigFlag+',
							   @ConfigFlagValue = '+@ConfigFlagValue+',
							   @TableSrc		= '''+case when charindex('''',@TableSrc,1)=1
														then replace(@TableSrc,'''','''''')
														else
															@TableSrc
														end+''',
							   @TableInterm		= '''+@TableInterm+''',
							   @TableFinal		= '+@TableFinal+',
							   @ColName1		= '''+@ColName1+''',
							   @ColName2		= '''+@ColName2+''',
							   @ColName3		= '''+@ColName3+''',
							   @ColDataType1	= '''+@ColDataType1+''',
							   @ColDataType2	= '''+@ColDataType2+''',
							   @ColDataType3	= '''+@ColDataType3+''';';
				
					IF @DebugFlag = 1 
						SELECT 'EXECUTE [PMAT].[pmat_build_TABLE_config_flag_table_sub3]' = 'EXEC '+@SQL;
					ELSE
					EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
				
					EXEC sp_executesql @SQL;		

				END

				--Build TABLE_[@ConfigFlag] table
				IF @ConfigFlag = 'COUNT_VALUE_FLAG'

				BEGIN 
					SET @SQL1 = STUFF(replace(@SQL1,'AS NVARCHAR(2000))','AS NVARCHAR(2000))   collate database_default  '), 1, 6, ''); --Remove 1st UNION operator

					SET @SQLStrOrder = 'ORDER BY 1, 2'+CASE WHEN @ColNamePattern3 <> '' THEN ', 3' ELSE '' END+';';

					SET @StepName = 'Update '+@TableFinal+' table for '+case when charindex('''',@TableSrc,1)=1 then replace(@TableSrc,'''','') else @TableSrc end+' table';

					SET @SubStepName = 'Combine and Execute @SQLStrDelete + @SQLStrInsert + @SQL1 + @SQLStrOrder Statements';

					IF @DebugFlag = 1 
						 SELECT [Procedure Name] = @ProcName, 
								[@SQLStrDelete] = @SQLStrDelete, 
								[@SQLStrInsert] = @SQLStrInsert,
								[@SQL1]	= @SQL1,
								[@SQLStrOrder] = @SQLStrOrder;
					ELSE
					BEGIN
						
						--select (@SQLStrInsert+' '+@SQL1+' '+@SQLStrOrder);
						EXEC (@SQLStrInsert+' '+@SQL1+' '+@SQLStrOrder);
						EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName,  @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
					END
				END

			END

			--Reset @SQLStrOut
			SET @SubStepName = 'Reset @SQLStrOut var';
			SET @SQLStrOut = '';

			--Increment loop the counter
			SET @SubStepName = 'Increment the loop counter';
			SET @Cnt = @Cnt + 1;
			SET @CntChar = CAST(@Cnt AS NVARCHAR);

			--Reassign 
			SET @SubStepName = 'Reassign PIVOT table name';
			SET @TableInterm = LEFT(@TableInterm, LEN(@TableInterm) - 1) + @CntChar;

			--Increment Min/Max Field's Key values to be used in a WHERE Clause as a range 
			SET @SubStepName = 'Increment @MinFieldKeyTemp and @MaxFieldKeyTemp vars';
			SET @MinFieldKeyTemp = @MaxFieldKeyTemp + 1;
			SET @MaxFieldKeyTemp = @MinFieldKeyPerm + @Partition * @Cnt;
		END

		IF @ConfigFlag = 'COUNT_VALUE_FLAG' SET @StepName = 'Update '+@TableFinal+' table';
	
		IF @DebugFlag <> 1					
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'COMPLETED',
			@@ROWCOUNT, @ErrorCode, @ErrorMsg;

		RETURN @ErrorCode;
	END TRY
	
	BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);
		
		IF @DebugFlag <> 1 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'FAILED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;		
			
		RETURN @ErrorCode;
	END CATCH
	--

END
GO
/****** Object:  StoredProcedure [PMAT].[pmat_build_TABLE_config_flag_table_sub3]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [PMAT].[pmat_build_TABLE_config_flag_table_sub3] 
		@executable_db	 nvarchar(50) = N'',
		@DebugFlag		 BIT = 1, /* 0 - to execute; non-zero - to print SQL statements */
		@Database		 SYSNAME  = N'',
		@SchemaName		 SYSNAME  = N'',
		@TableConfig	 SYSNAME  = N'',
		@ConfigFlag		 SYSNAME  = N'',
		@ConfigFlagValue NCHAR(1) = N'',
		@TableSrc		 SYSNAME  = N'',
		@TableInterm	 SYSNAME  = N'',
		@TableFinal		 SYSNAME  = N'',
		@ColName1		 SYSNAME  = N'',
		@ColName2		 SYSNAME  = N'',
		@ColName3		 SYSNAME  = N'',
		@ColDataType1	 NVARCHAR(25) = N'',
		@ColDataType2	 NVARCHAR(25) = N'',
		@ColDataType3	 NVARCHAR(25) = N''

AS    
BEGIN

	DECLARE @SQL		  NVARCHAR(MAX) = '';
	DECLARE @NewLine	  NVARCHAR(50) = CHAR(13) + CHAR(10);

	DECLARE @ProcName	  VARCHAR(200) = OBJECT_NAME(@@PROCID),
			@StepName	  VARCHAR(100) = 'Update TABLE_'+@TableFinal+' table',
			@SubStepName  VARCHAR(250);
	
	DECLARE @ColList1	  NVARCHAR(MAX) = N'',
			@ColList2	  NVARCHAR(MAX) = N'',
			@ColList3	  NVARCHAR(MAX) = N'';

	DECLARE @ColList1Cast NVARCHAR(MAX) = N'',
			@ColList2Cast NVARCHAR(MAX) = N'',
			@ColList3Cast NVARCHAR(MAX) = N'';

	DECLARE @ErrorCode	  INT = 0,
			@ErrorMsg	  NVARCHAR(2048) = N'',
			@RowCnt		  INT;

	DECLARE @DatabaseBrackets varchar(500);
	DECLARE @SchemaBrackets varchar(500);

	BEGIN TRY
		--Get list of columns from TABLE_[@ConfigFlag]_[@TableSrc] Intermediate table with pattern matching TABLE_[@ConfigFlag] Table columns'
		--Accepts up to 3 columns (KEY plus COUNT_COVERAGE|PCT_COVERAGE|MIN_VALUE & MAX_VALUE columns)
		--Add more as needed
		
		
		set @DatabaseBrackets = case when charindex('[',@Database,1) = 0 then '['+@Database+']' 
									else @Database end
		 
	    set @Database =  replace(replace(@Database,'[',''),']','')	
		
		set @SchemaBrackets = case when charindex('[',@SchemaName,1) = 0 then '['+@SchemaName+']' 
									else @SchemaName end
		 
	    set @SchemaName =  replace(replace(@SchemaName,'[',''),']','')	

		IF @ColName1 <> ''
		BEGIN
			SET @SubStepName = 'Create @ColList1 with columns of the same pattern as ''%'+@ColName1+''' from '+@TableInterm;
			
			SET @SQL = '
			SELECT @ColList1 += '', '' + QUOTENAME(COLUMN_NAME)
			  FROM '+@DatabaseBrackets+'.INFORMATION_SCHEMA.COLUMNS 
			 WHERE TABLE_NAME = '''+@TableInterm+''' 
			   AND COLUMN_NAME LIKE ''%'+@ColName1+''' ORDER BY ORDINAL_POSITION;'
		     EXEC sp_executesql @SQL,N'@ColList1 NVARCHAR(MAX) OUTPUT',@ColList1 OUTPUT
	
		END
	
		IF @ColName2 <> ''	
		BEGIN
			SET @SubStepName = 'Create @ColList2 with columns of the same pattern as ''%'+@ColName2+''' from '+@TableInterm;

			SET @SQL = 'SELECT @ColList2 += '', '' + QUOTENAME(COLUMN_NAME),
				   @ColList2Cast += '', CAST(''+QUOTENAME(COLUMN_NAME)+'' AS '+@ColDataType2+')   ''+QUOTENAME(COLUMN_NAME)
			  FROM '+@DatabaseBrackets+'.INFORMATION_SCHEMA.COLUMNS 
			 WHERE TABLE_NAME = '''+@TableInterm+''' 
			   AND COLUMN_NAME LIKE ''%'+@ColName2+'''
			 ORDER BY ORDINAL_POSITION;'

			  EXEC sp_executesql @SQL,N'@ColList2 NVARCHAR(MAX) OUTPUT, @ColList2Cast NVARCHAR(MAX) OUTPUT'
						,@ColList2 OUTPUT, @ColList2Cast OUTPUT

		END

		IF @ColName3 <> ''
		BEGIN
			SET @SubStepName = 'Create @ColList3 with columns of the same pattern as ''%'+@ColName3+''' from '+@TableInterm;

			SET @SQL = 'SELECT @ColList3 += '', ''+QUOTENAME(COLUMN_NAME),
				   @ColList3Cast += '', CAST(''+QUOTENAME(COLUMN_NAME)+'' AS '+@ColDataType3+')  ''+QUOTENAME(COLUMN_NAME)
			  FROM '+@DatabaseBrackets+'.INFORMATION_SCHEMA.COLUMNS 
			 WHERE TABLE_NAME = '''+@TableInterm+''' 
			   AND COLUMN_NAME LIKE ''%'+@ColName3+'''
			 ORDER BY ORDINAL_POSITION;'
			  EXEC sp_executesql @SQL,N'@ColList3 NVARCHAR(MAX) OUTPUT, @ColList3Cast NVARCHAR(MAX) OUTPUT'
						,@ColList3 OUTPUT, @ColList3Cast OUTPUT
		END

		IF @DebugFlag = 1 
			SELECT [Procedure Name] = @ProcName, 
					[@ColList1] = @ColList1, 
					[@ColList2] = @ColList2, 
					[@ColList3] = @ColList3;
		--
	
		-- 1) SQL to DELETE an existing data from a TABLE_[@ConfigFlag] table; 
		--    The same step exists in [sp_build_TABLE_config_flag_table_sub1]; left here if this  SP ran independently;
		--    Won't Log if @RowCnt = 0 (the data was already deleted in the preveous step or the table was never populated);	
	
		--SET @SubStepName = 'DELETE existing data from '+@Database+'.'+@SchemaName+'.'+@TableFinal;

		--SET @SQL = 	N'IF OBJECT_ID(N'''+@Database+'.'+@SchemaName+'.'+@TableFinal+''') IS NOT NULL'+@NewLine+ 
		--		   'DELETE '+@Database+'.'+@SchemaName+'.'+@TableFinal+@NewLine+
		--		   'WHERE EXISTS (SELECT 1 FROM '+@Database+'.'+@SchemaName+'.'+@TableConfig+'
		--						   WHERE DATABASE_NAME = '''+@Database+'''
		--							 AND TABLE_NAME = '''+@TableSrc+'''
		--							 AND '+@ConfigFlag+' = '+@ConfigFlagValue+'
		--							 AND '+@TableFinal+'.'+@ColName1+' = '+@ColName1+');'+@NewLine+@NewLine;
	
		--IF @DebugFlag = 1 
		--	 SELECT [Procedure Name] = @ProcName, 
		--			[Delete @SQL] = @SQL;
		--ELSE
		--BEGIN
		--	EXEC sp_executesql @SQL;
		--	IF @@ROWCOUNT > 0
		--		EXEC [PMAT].[sp_update_TABLE_process_status] @ProcName, @StepName, @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
		--END
		-- 1) END
		
		
		-- 2) SQL to UNPIVOT TABLE_[@ConfigFlag]_[@TableSrc] Intermediate table's data,
		--	  UNPIVOT and INSERT data into TABLE_[@ConfigFlag] table	
		SET @SubStepName = 'UNPIVOT and INSERT data INTO ['+@Database+'].'+'dbo'+'.'+@TableFinal;
		--select Replace(@ColList2Cast,'AS NVARCHAR(1000))','AS NVARCHAR(1000))   collate database_default  ') 
		--select Replace(@ColList3Cast,'AS NVARCHAR(1000))','AS NVARCHAR(1000))   collate database_default  ')

		SET @SQL = N'INSERT INTO ['+@Database+'].'+'dbo'+'.['+@TableFinal+'] ('+@ColName1+', '+@ColName2+CASE WHEN @ColName3 <> '' THEN ', '+@ColName3 ELSE '' END+')'+@NewLine+
		'SELECT '+@ColName1+', '+@ColName2+ CASE WHEN @ColName3 <> '' THEN ', '+@ColName3 ELSE '' END+'
			FROM 
			(
			  SELECT '+@ColName1+', '+@ColName2+', '+  CASE WHEN @ColName3 <> '' THEN @ColName3+',' ELSE '' END +'
				'+@ColName1+'ID = REPLACE('+@ColName1+'s,'''+@ColName1+''',''''),
				'+@ColName2+'ID = REPLACE('+@ColName2+'s,'''+@ColName2+''','''')'+
				CASE WHEN @ColName3 <> '' THEN 
				', '+@ColName3+'ID = REPLACE('+@ColName3+'s,'''+@ColName3+''','''')'
				ELSE '' END+' 
			  FROM
			  (
				SELECT '+ STUFF(@ColList1, 1, 1, '') + Replace(@ColList2Cast,'AS NVARCHAR(1000))','AS NVARCHAR(1000))   collate database_default  ')  + Replace(@ColList3Cast,'AS NVARCHAR(1000))','AS NVARCHAR(1000))   collate database_default   ') + '
				FROM [' + @Database+'].'+@SchemaBrackets+'.['+@TableInterm + ']
			  ) AS CNT
			  UNPIVOT 
			  (
				'+@ColName1+' FOR '+@ColName1+'s IN (' + STUFF(@ColList1, 1, 1, '') + ')
			  ) AS F1
			  UNPIVOT
			  (
				'+@ColName2+' FOR '+@ColName2+'s IN (' + STUFF(@ColList2, 1, 1, '') + ')
			  ) AS F2'+
			  CASE WHEN @ColName3 <> '' THEN '
			  UNPIVOT
			  (
				'+@ColName3+' FOR '+@ColName3+'s IN (' + STUFF(@ColList3, 1, 1, '') + ')
			  ) AS F3'
			  ELSE '' END +'
			) AS X
			WHERE '+@ColName1+'ID = '+@ColName2+'ID '+ CASE WHEN @ColName3 <> '' THEN 'AND '+@ColName1+'ID = '+@ColName3+'ID' ELSE '' END
			+@NewLine+' ORDER BY '+@ColName1+';'

	
		IF @DebugFlag = 1 
			SELECT [Procedure Name] = @ProcName, 
					[Delete @SQL] = @SQL;
		ELSE
		BEGIN
			EXEC sp_executesql @SQL;
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo',@ProcName, @StepName, @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
		END

	END TRY

	BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);

		IF @DebugFlag <> 1 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets, 'dbo',@ProcName, @StepName, @SubStepName, 'FAILED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
			
		RETURN @ErrorCode;
	END CATCH
	--2) END

	--3) DROP TABLE_[@ConfigFlag] Intermediate table
	BEGIN TRY
		SET @SubStepName = 'DROP PIVOT table ['+@Database+'].'+@SchemaBrackets+'.['+@TableInterm+']';
		
		SET @SQL = N'IF OBJECT_ID(N''['+@Database+'].'+@SchemaBrackets+'.['+@TableInterm+']'') IS NOT NULL 
						DROP TABLE ['+@Database+'].'+@SchemaBrackets+'.['+@TableInterm+'];';

		IF @DebugFlag = 1 
			SELECT [Procedure Name] = @ProcName, [Drop @SQL] = @SQL;

		EXEC sp_executesql @SQL;
		EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets, 'dbo',@ProcName, @StepName, @SubStepName, 'COMPLETED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
	END TRY	

	BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);

		IF @DebugFlag <> 1 
			EXEC [PMAT].[pmat_update_TABLE_process_status] @DatabaseBrackets,'dbo', @ProcName, @StepName, @SubStepName, 'FAILED', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
			
		RETURN @ErrorCode;
	END CATCH
	-- 3) END

END
GO
/****** Object:  StoredProcedure [PMAT].[pmat_generate_analysis_flag_table]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************/
/*                    OVERVIEW of TABLE Process	     	           */
/*******************************************************************************************/
/*                             */
/*******************************************************************************************/

/***********************************************************************************/
CREATE     PROCEDURE [PMAT].[pmat_generate_analysis_flag_table] 
	@executable_db  varchar(50),
	@DebugFlag		BIT = 0, /* 0 - to execute; non-zero - to print SQL statements */
	@Database		varchar(500),
	@SchemaName		varchar(500),
	 @CoverageAnalysis Bit = 0,
	 @NullAnalysis Bit = 0,
	 @ValueAnalysis Bit = 0,
	 @MinMaxAnalysis Bit = 0,
	 @PctAnalysis Bit = 0
AS
BEGIN

	

	DECLARE @SQL	  NVARCHAR(MAX) = N'',
			@SQLWhere NVARCHAR(200) = N'',
			@NewLine  CHAR(2) = CHAR(13) + CHAR(10);

	DECLARE @ProcName	 VARCHAR(200) = OBJECT_NAME(@@PROCID),
			@StepName	 VARCHAR(100) = 'Update TABLE Config Flag Tables - MAIN',
			@SubStepName VARCHAR(250) = 'Check if Source table is provided as an Input parameter @TableSrc';

	DECLARE @ErrorCode INT = 0,
			@ErrorMsg  NVARCHAR(2048) = N'';

	BEGIN TRY
		IF @DebugFlag = 1 SELECT [@StepName] = 'BEGIN '+@StepName;

		--1) Gets list of Config Flags from TABLE Analysis table
		SET @SubStepName = 'Create the tables for wha metrics to perform ';	

declare @dropTableSql nvarchar(max)
declare @databaseName nvarchar(500)

declare @DatabaseBrackets nvarchar(500)

declare @schema nvarchar(500)

declare @schemaBrackets nvarchar(500)

set @databaseName = @Database
set @schema = @SchemaName

set @DatabaseBrackets = case when charindex('[',@databaseName,1) = 0 then '['+@databaseName+']'
									else @databaseName end
		 
set @databaseName =  replace(replace(@databaseName,'[',''),']','')


set @schemaBrackets = case when charindex('[',@schema ,1) = 0 then '['+@schema +']' 
									else @schema  end
		 
set @schema  =  replace(replace(@schema ,'[',''),']','')

set @sql = 'USE '+@DatabaseBrackets + ' 
Truncate table '+@schemaBrackets+'.[TABLE_COUNT_COVERAGE] 
Truncate table  '+@schemaBrackets+'.[TABLE_COUNT_NULL_BLANK] 
Truncate table '+@schemaBrackets+'.[TABLE_COUNT_VALUE] 
Truncate table '+@schemaBrackets+'.[TABLE_MIN_MAX_VALUE] 
Truncate table '+@schemaBrackets+'.[TABLE_PCT_COVERAGE] 
Truncate table '+@schemaBrackets+'.[TABLE_PROCESS_STATUS] 
Truncate table '+@schemaBrackets+'.[TABLE_SOURCE_ANALYSIS]  '


if @DebugFlag = 1
		select @sql
else
		exec(@sql)


set @Sql = 'USE '+@DatabaseBrackets + '
DECLARE	@return_value int
EXEC	@return_value = '+@executable_db+'.PMAT.[pmat_generate_TABLE_template]
		@executable_db = '''+@executable_db+''',
		@DebugFlag = 0,
		@Database = '''+@DatabaseBrackets+''',
		@SchemaName =''dbo'',
		@TableSrc=''All'',
		@CoverageAnalysis  = '+convert(varchar(1),@CoverageAnalysis)+',
		@NullAnalysis  = '+ convert(varchar(1),@NullAnalysis)+',
		@ValueAnalysis = '+ convert(varchar(1),@ValueAnalysis)+',
		@MinMaxAnalysis  = '+convert(varchar(1),@MinMaxAnalysis)+',
		@PctAnalysis  = '+ convert(varchar(1),@PctAnalysis)+''

if @DebugFlag = 1
		select @sql

else
		exec(@sql)

END TRY

BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();		
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);

		
		RETURN @ErrorCode;
END CATCH
END
GO
/****** Object:  StoredProcedure [PMAT].[pmat_generate_infastructure_tables]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************/
/*                    OVERVIEW of TABLE Process	     	           */
/*******************************************************************************************/
CREATE   PROCEDURE [PMAT].[pmat_generate_infastructure_tables]
	@DebugFlag		BIT = 0, /* 0 - to execute; non-zero - to print SQL statements */
	@Database		varchar(500),
	@SchemaName		varchar(500)
AS
BEGIN


	DECLARE @SQL	  NVARCHAR(MAX) = N'',
			@SQLWhere NVARCHAR(200) = N'',
			@NewLine  CHAR(2) = CHAR(13) + CHAR(10);

	DECLARE @ProcName	 VARCHAR(200) = OBJECT_NAME(@@PROCID),
			@StepName	 VARCHAR(100) = 'Update TABLE Config Flag Tables - MAIN',
			@SubStepName VARCHAR(250) = 'Check if Source table is provided as an Input parameter @TableSrc';

	DECLARE @ErrorCode INT = 0,
			@ErrorMsg  NVARCHAR(2048) = N'';

	BEGIN TRY
		IF @DebugFlag = 1 SELECT [@StepName] = 'BEGIN '+@StepName;

		--1) Gets list of Config Flags from TABLE Analysis table
		SET @SubStepName = 'Create the tables need to hold the metrics ';	

		
DECLARE @DatabaseNameSys as SYSNAME
DECLARE @Collation as varchar(50)

declare @dropTableSql nvarchar(max)
declare @databaseName nvarchar(500)

declare @DatabaseBrackets nvarchar(500)

declare @schema nvarchar(500)

set @databaseName = @Database
set @schema = @SchemaName

set @DatabaseBrackets = case when charindex('[',@databaseName,1) = 0 then '['+@databaseName+']'
									else @databaseName end
		 
set @databaseName =  replace(replace(@databaseName,'[',''),']','')

SET @DatabaseNameSys = convert(SYSNAME,@databaseName)
--select @DatabaseNameSys
SELECT @Collation =convert(varchar(50), DATABASEPROPERTYEX(@DatabaseNameSys, 'Collation') )
--select @Collation
set @dropTableSql = 'USE '+@DatabaseBrackets + ' 
		 IF OBJECT_ID(N'''+@schema+'.TABLE_SOURCE_ANALYSIS'') IS NOT NULL'+@NewLine+ 
				   '  DROP TABLE '+@schema+'.TABLE_SOURCE_ANALYSIS ;';
if @DebugFlag = 1
		select @dropTableSql

exec (@dropTableSql)

set @dropTableSql = 'USE '+@DatabaseBrackets + ' 
		 IF OBJECT_ID(N'''+@schema+'.TABLE_DATA_CATEGORY'') IS NOT NULL'+@NewLine+ 
				   '  DROP TABLE '+@schema+'.TABLE_DATA_CATEGORY ;';
if @DebugFlag = 1
		select @dropTableSql

exec (@dropTableSql)
set @dropTableSql = 'USE '+@DatabaseBrackets + ' 
		 IF OBJECT_ID(N'''+@schema+'.TABLE_COUNT_COVERAGE'') IS NOT NULL'+@NewLine+ 
				   '  DROP TABLE '+@schema+'.TABLE_COUNT_COVERAGE ;';
if @DebugFlag = 1
		select @dropTableSql

exec (@dropTableSql)
set @dropTableSql = 'USE '+@DatabaseBrackets + ' 
		 IF OBJECT_ID(N'''+@schema+'.TABLE_COUNT_NULL_BLANK'') IS NOT NULL'+@NewLine+ 
				   '  DROP TABLE '+@schema+'.TABLE_COUNT_NULL_BLANK ;';
if @DebugFlag = 1
		select @dropTableSql

exec (@dropTableSql)
set @dropTableSql = 'USE '+@DatabaseBrackets + ' 
		 IF OBJECT_ID(N'''+@schema+'.TABLE_COUNT_VALUE'') IS NOT NULL'+@NewLine+ 
				   '  DROP TABLE '+@schema+'.TABLE_COUNT_VALUE ;';
if @DebugFlag = 1
		select @dropTableSql

exec (@dropTableSql)
set @dropTableSql = 'USE '+@DatabaseBrackets + ' 
		 IF OBJECT_ID(N'''+@schema+'.TABLE_MIN_MAX_VALUE'') IS NOT NULL'+@NewLine+ 
				   '  DROP TABLE '+@schema+'.TABLE_MIN_MAX_VALUE ;';
if @DebugFlag = 1
		select @dropTableSql

exec (@dropTableSql)
set @dropTableSql = 'USE '+@DatabaseBrackets + ' 
		 IF OBJECT_ID(N'''+@schema+'.TABLE_PCT_COVERAGE'') IS NOT NULL'+@NewLine+ 
				   '  DROP TABLE '+@schema+'.TABLE_PCT_COVERAGE ;';
if @DebugFlag = 1
		select @dropTableSql

exec (@dropTableSql)
set @dropTableSql = 'USE '+@DatabaseBrackets + ' 
		 IF OBJECT_ID(N'''+@schema+'.TABLE_PROCESS_STATUS'') IS NOT NULL'+@NewLine+ 
				   '  DROP TABLE '+@schema+'.TABLE_PROCESS_STATUS ;';
if @DebugFlag = 1
		select @dropTableSql

exec (@dropTableSql)

set @sql='
USE '+@DatabaseBrackets + '
CREATE TABLE '+@schema+'.[TABLE_SOURCE_ANALYSIS](
	[FIELD_KEY] [int] IDENTITY(1,1) NOT NULL,
	[DATABASE_NAME] [nvarchar](500)  NOT NULL,
	[TABLE_SCHEMA] [nvarchar](500)    NOT NULL,
	[TABLE_NAME] [nvarchar](500)    NOT NULL,
	[TABLE_ROW_COUNT] bigint   null,
	[COLUMN_NAME] [nvarchar](500)   NOT NULL,
	[ORDINAL_POSITION] [int]   NOT NULL,
	[DATA_TYPE] [nvarchar](500)    NOT NULL,
	[DATA_CATEGORY_NAME] [nvarchar](500)   NULL,
	[COUNT_COVERAGE_FLAG] [bit]  NULL,
	[PCT_COVERAGE_FLAG] [bit]    NULL,
	[MIN_MAX_VALUE_FLAG] [bit]    NULL,
	[COUNT_NULL_BLANK_FLAG] [bit]    NULL,
	[COUNT_VALUE_FLAG] [bit]    NULL,
	[CREATE_DATE] [datetime]    NOT NULL DEFAULT (getdate()),
	[CREATE_USER] [nvarchar](500)    NOT NULL DEFAULT (user_name()),
	[MODIFY_DATE] [datetime]   NULL,
	[MODIFY_USER] [nvarchar](500)    NULL,
	[ANALYZE_COLUMN] [bit]  NULL,
	[MAIN_TABLE] [varchar](50)    NULL,
	PRIMARY KEY CLUSTERED 
(	[FIELD_KEY] ASC)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]'

If @DebugFlag=1
	select @SQL
ELSE 
	EXECUTE sp_executesql @SQL;	
set @sql='
USE '+@DatabaseBrackets + '
CREATE TABLE '+@schema+'.[TABLE_DATA_CATEGORY](
	[DATA_CATEGORY_ID] [int] IDENTITY(1,1) NOT NULL,
	[DATA_CATEGORY_NAME] [nvarchar](255) COLLATE database_default   NOT NULL,
	[CREATE_DATE] [datetime] NULL DEFAULT (getdate()),
	[CREATE_USER] [nvarchar](25) COLLATE database_default  NULL DEFAULT (user_name()),
	[MODIFY_DATE] [datetime] NULL,
	[MODIFY_USER] [nvarchar](25) COLLATE database_default  NULL,
 CONSTRAINT [PK_DATA_CATEGORY] PRIMARY KEY CLUSTERED 
(	[DATA_CATEGORY_ID] ASC)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]) ON [PRIMARY]
'

If @DebugFlag=1
	select @SQL
ELSE 
	EXECUTE sp_executesql @SQL;	
set @sql='
USE '+@DatabaseBrackets + '
INSERT INTO '+@schema+'.TABLE_DATA_CATEGORY
(DATA_CATEGORY_NAME)
select	''Contacts'' 	UNION select	''Cases'' 	UNION select	''Notes'' 	UNION select	''Permissions'' 	UNION select	''Case Summary'' 	UNION
select	''Damages'' 	UNION select	''Defendants'' 	UNION select	''Depos'' UNION select	''Documents'' 	UNION select	''Expenses'' 	UNION
select	''Experts'' 	UNION select	''Forms'' 	UNION select	''Insurance'' 	UNION select	''Intake'' 	UNION select	''Issues'' 	UNION
select	''Liens'' 	UNION  select	''Meds'' 	UNION select	''Negotiations'' 	UNION select	''PleadingIndex'' 	UNION
select	''TimeWorked'' 	UNION select	''Witnesses'' 	UNION select	''WrittenDisc''	'

If @DebugFlag=1
	select @SQL
ELSE 
	EXECUTE sp_executesql @SQL;	

set @sql='
USE '+@DatabaseBrackets + '

CREATE TABLE '+@schema+'.[TABLE_COUNT_COVERAGE](
	[FIELD_KEY] [int] NULL,
	[FIELD_COUNT] [bigint] NULL,
	[CREATE_DATE] [datetime] NULL DEFAULT (getdate()),
	[CREATE_USER] [nvarchar](25) COLLATE database_default  NULL DEFAULT (user_name())) ON [PRIMARY]'	
	
If @DebugFlag=1
	select @SQL
ELSE 
	EXECUTE sp_executesql @SQL;	
set @sql='
USE '+@DatabaseBrackets + '
CREATE TABLE '+@schema+'.[TABLE_COUNT_NULL_BLANK](
	[FIELD_KEY] [int] NULL,
	[FIELD_COUNT] [bigint] NULL,
	[CREATE_DATE] [datetime] NULL DEFAULT (getdate()),
	[CREATE_USER] [nvarchar](25) COLLATE database_default   NULL DEFAULT (user_name())) ON [PRIMARY]'
	
If @DebugFlag=1
	select @SQL
ELSE 
	EXECUTE sp_executesql @SQL;	
set @sql='
USE '+@DatabaseBrackets + '
CREATE TABLE '+@schema+'.[TABLE_COUNT_VALUE](
	[FIELD_KEY] [int] NULL,
	[FIELD_VALUE] [nvarchar](4000) COLLATE database_default  NULL,
	[FIELD_COUNT] [bigint] NULL,
	[CREATE_DATE] [datetime] NULL DEFAULT (getdate()),
	[CREATE_USER] [nvarchar](25) COLLATE database_default  NULL DEFAULT (user_name())) ON [PRIMARY]
	
	CREATE NONCLUSTERED INDEX [NCX_TABLECOUNTVALUE_FIELDKEY_INC_FIELDVALUE]
ON [dbo].[TABLE_COUNT_VALUE] ([FIELD_KEY])
INCLUDE ([FIELD_VALUE])'
If @DebugFlag=1
	select @SQL
ELSE 
	EXECUTE sp_executesql @SQL;	
set @sql='
USE '+@DatabaseBrackets + '
CREATE TABLE '+@schema+'.[TABLE_MIN_MAX_VALUE](
	[FIELD_KEY] [int] NULL,
	[FIELD_MIN_VALUE] [nvarchar](4000) COLLATE database_default  NULL,
	[FIELD_MAX_VALUE] [nvarchar](4000) COLLATE database_default  NULL,
	[CREATE_DATE] [datetime] NULL DEFAULT (getdate()),
	[CREATE_USER] [nvarchar](25) COLLATE database_default  NULL DEFAULT (user_name())) ON [PRIMARY]'
	
If @DebugFlag=1
	select @SQL
ELSE 
	EXECUTE sp_executesql @SQL;	
set @sql='
USE '+@DatabaseBrackets + '
CREATE TABLE '+@schema+'.[TABLE_PCT_COVERAGE](
	[FIELD_KEY] [int] NULL,
	[FIELD_PCT] [decimal](18, 2) NULL,
	[CREATE_DATE] [datetime] NULL DEFAULT (getdate()),
	[CREATE_USER] [nvarchar](25) COLLATE database_default  NULL DEFAULT (user_name())) ON [PRIMARY]'
	
If @DebugFlag=1
	select @SQL
ELSE 
	EXECUTE sp_executesql @SQL;	
	
set @sql='
USE '+@DatabaseBrackets + '
CREATE TABLE '+@schema+'.[TABLE_PROCESS_STATUS](
	[STEP_NO] [bigint] IDENTITY(1,1) NOT NULL,
	[STEP_EXECUTABLE] [sysname] NULL,
	[STEP_NAME] [nvarchar](100) COLLATE database_default  NULL,
	[SUB_STEP_NAME] [nvarchar](250) COLLATE database_default  NULL,
	[STATUS] [nvarchar](25) COLLATE database_default  NULL,
	[ROW_COUNT] [bigint] NULL,
	[ERROR_CODE] [bigint] NULL,
	[ERROR_MESSAGE] [nvarchar](max) COLLATE database_default  NULL,
	[RUN_DATE_TIME] [datetime] NOT NULL DEFAULT (getdate()),
	[RUN_USER_ID] [sysname] NOT NULL DEFAULT (user_name())) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]'


If @DebugFlag=1
	select @SQL
ELSE 
	EXECUTE sp_executesql @SQL;	
		/********************************/
SET @SubStepName = 'END Create tables for metrics'

SET @SubStepName = 'BEGIN Create views for metrics'
set @dropTableSql = 'USE '+@DatabaseBrackets + '
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'''+@schema+'.[VW_TABLE_SOURCE_ANALYSIS_LOAD]'')
                  AND type IN ( N''V'' ))
  DROP VIEW '+@schema+'.[VW_TABLE_SOURCE_ANALYSIS_LOAD];
		'
if @DebugFlag = 1
		select @dropTableSql

else
		exec (@dropTableSql)

set @dropTableSql = 'USE '+@DatabaseBrackets + '
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'''+@schema+'.[VW_TABLE_SOURCE_ANALYSIS_MAIN_REPORT]'')
                  AND type IN ( N''V'' ))
  DROP VIEW '+@schema+'.[VW_TABLE_SOURCE_ANALYSIS_MAIN_REPORT];
		'
if @DebugFlag = 1
		select @dropTableSql

else
		exec(@dropTableSql)

set @dropTableSql = 'USE '+@DatabaseBrackets + '
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'''+@schema+'.[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT]'')
                  AND type IN ( N''V'' ))
  DROP VIEW '+@schema+'.[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT];
		'
if @DebugFlag = 1
		select @dropTableSql
else
		exec(@dropTableSql)

		
set @dropTableSql = 'USE '+@DatabaseBrackets + '
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'''+@schema+'.[VW_TABLE_ANALYSIS_IC_REPORT]'')
                  AND type IN ( N''V'' ))
  DROP VIEW '+@schema+'.[VW_TABLE_ANALYSIS_IC_REPORT];
		'
if @DebugFlag = 1
		select @dropTableSql

else
		exec(@dropTableSql)

IF @DebugFlag = 1
	SELECT [@SubStepName] = @SubStepName;
	
SET @SubStepName = 'Create views'


set @sql =  'USE '+@DatabaseBrackets + '; 
exec( ''CREATE VIEW '+@schema+'.[VW_TABLE_SOURCE_ANALYSIS_LOAD] AS 
SELECT [DATABASE_NAME]
      ,[TABLE_SCHEMA]
      ,[TABLE_NAME]
	  ,[TABLE_ROW_COUNT] 
      ,[COLUMN_NAME]
	  ,[FIELD_KEY]
      ,[ORDINAL_POSITION]
      ,[DATA_TYPE]
      ,[DATA_CATEGORY_NAME]
      ,[COUNT_COVERAGE_FLAG]
      ,[PCT_COVERAGE_FLAG]
      ,[MIN_MAX_VALUE_FLAG]
      ,[COUNT_NULL_BLANK_FLAG]
      ,[COUNT_VALUE_FLAG]
  FROM  '+@schema+'.[TABLE_SOURCE_ANALYSIS]'');
		'
if @DebugFlag = 1
		select @sql 
else
        exec(@sql)

set @sql = 'USE '+@DatabaseBrackets + '; 
exec( ''CREATE VIEW '+@schema+'.[VW_TABLE_SOURCE_ANALYSIS_MAIN_REPORT] AS 
	SELECT DSA.[DATABASE_NAME]	
		  ,DSA.[TABLE_SCHEMA]
		  ,DSA.[TABLE_NAME]
		  ,DSA.[TABLE_ROW_COUNT] 
		  ,DSA.[COLUMN_NAME]
		  ,DSA.[FIELD_KEY]
		  ,DSA.[ORDINAL_POSITION]
		  ,DSA.[DATA_TYPE]
		  ,[DATA_CATEGORY_NAME]
		  ,[COUNT_COVERAGE] = Cnt.[FIELD_COUNT]
		  ,[COUNT_NULL_BLANK] = NoValCNT.[FIELD_COUNT]
		  ,[MAX_VALUE] = MaxMinVal.[FIELD_MAX_VALUE]
		  ,[MIN_VALUE] = MaxMinVal.[FIELD_MIN_VALUE]
		  ,[COUNT_VALUE] = CASE WHEN DSA.[COUNT_VALUE_FLAG] = 1 THEN ''''See [Value_Count] Tab'''' ELSE '''''''' END
		  ,[PCT_COVERAGE] = PctCovrg.[FIELD_PCT]
	  FROM '+@schema+'.[TABLE_SOURCE_ANALYSIS] DSA
	  LEFT JOIN '+@schema+'.[TABLE_COUNT_COVERAGE]        Cnt ON DSA.[FIELD_KEY] = Cnt.[FIELD_KEY]
	  LEFT JOIN '+@schema+'.[TABLE_COUNT_NULL_BLANK] NoValCnt ON DSA.[FIELD_KEY] = NoValCnt.[FIELD_KEY]
	  LEFT JOIN '+@schema+'.[TABLE_MIN_MAX_VALUE]   MaxMinVal ON DSA.[FIELD_KEY] = MaxMinVal.[FIELD_KEY]
	  LEFT JOIN '+@schema+'.[TABLE_PCT_COVERAGE]     PctCovrg ON DSA.[FIELD_KEY] = PctCovrg.[FIELD_KEY]'');
		'
if @DebugFlag = 1
		select @sql
else
		exec(@sql)


set @sql = 'USE '+@DatabaseBrackets + '; 
exec( ''CREATE VIEW '+@schema+'.[VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT] AS 
	SELECT DSA.[DATABASE_NAME]
		  ,DSA.[TABLE_SCHEMA]
		  ,DSA.[TABLE_NAME]
		  ,DSA.[TABLE_ROW_COUNT] 
		  ,DSA.[COLUMN_NAME]
		  ,DSA.[FIELD_KEY]
		  ,DSA.[ORDINAL_POSITION]
		  ,DSA.[DATA_TYPE]
		  ,ValCnt.[FIELD_VALUE]
		  ,ValCnt.[FIELD_COUNT] 
  FROM '+@schema+'.[TABLE_COUNT_VALUE] ValCnt
 INNER JOIN '+@schema+'.[TABLE_SOURCE_ANALYSIS] DSA ON ValCnt.[FIELD_KEY] = DSA.[FIELD_KEY]'');
		'
if @DebugFlag = 1
		select @sql
else
		exec(@sql)


set @sql = 'USE '+@DatabaseBrackets + '; 
exec( ''CREATE VIEW '+@schema+'.[VW_TABLE_ANALYSIS_IC_REPORT] AS 
	SELECT DSA.[DATABASE_NAME]	
			,DSA.[TABLE_SCHEMA]
		  ,DSA.[TABLE_NAME]
		  ,DSA.[TABLE_ROW_COUNT] 
		  ,DSA.[COLUMN_NAME]
		  ,DSA.[FIELD_KEY]
		  ,DSA.[DATA_TYPE]
		  ,[DATA_CATEGORY_NAME]
		  ,[COUNT_COVERAGE] = Cnt.[FIELD_COUNT]
		  ,[COUNT_NULL_BLANK] = NoValCNT.[FIELD_COUNT]
		  ,[PCT_COVERAGE] = PctCovrg.[FIELD_PCT]
	  FROM '+@schema+'.[TABLE_SOURCE_ANALYSIS] DSA
	  LEFT JOIN '+@schema+'.[TABLE_COUNT_COVERAGE]        Cnt ON DSA.[FIELD_KEY] = Cnt.[FIELD_KEY]
	  LEFT JOIN '+@schema+'.[TABLE_COUNT_NULL_BLANK] NoValCnt ON DSA.[FIELD_KEY] = NoValCnt.[FIELD_KEY]
	  LEFT JOIN '+@schema+'.[TABLE_PCT_COVERAGE]     PctCovrg ON DSA.[FIELD_KEY] = PctCovrg.[FIELD_KEY] 
	  where DSA.[TABLE_SCHEMA] not in (''''MDETL'''') ''
		);
		'
--		select @sql
if @DebugFlag = 1
		select @sql
else
		exec(@sql)

set @sql = 'USE '+@DatabaseBrackets + '
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'''+@schema+'.[GetLiteralDataType]'')
                  AND type IN ( N''FN'', N''IF'', N''TF'', N''FS'', N''FT'' ))
  DROP FUNCTION '+@schema+'.[GetLiteralDataType];
'
if @DebugFlag = 1
		select @sql
else
		exec(@sql)

set @sql =  'USE '+@DatabaseBrackets + '; 
exec( ''CREATE FUNCTION '+@schema+'.[GetLiteralDataType]( @TableName as VARCHAR(100), @ColumnName as VARCHAR(100) )
    RETURNS VARCHAR(100)
    AS
    BEGIN

        DECLARE @DataType	  VARCHAR(100);
        DECLARE @MaxLength	  VARCHAR(100);
        DECLARE @Precision	  VARCHAR(100);
        DECLARE @Scale		  VARCHAR(100);
		DECLARE @FullDataType VARCHAR(100);

		SELECT @DataType = UPPER(DATA_TYPE),
			   @MaxLength = CHARACTER_MAXIMUM_LENGTH,
			   @Precision = NUMERIC_PRECISION,
			   @Scale = NUMERIC_SCALE
		  FROM INFORMATION_SCHEMA.COLUMNS
		 WHERE TABLE_NAME = @TableName
		   AND COLUMN_NAME = @ColumnName;		

		SELECT @FullDataType = 
		  CASE WHEN @DataType =''''DECIMAL''''   THEN @DataType+''''(''''+ @Precision + '''','''' + @Scale + '''')''''
			   WHEN @DataType LIKE ''''%CHAR'''' THEN @DataType+''''(''''+ CASE WHEN @MaxLength = ''''-1'''' THEN ''''MAX'''' ELSE @MaxLength END + '''')''''
			   ELSE @DataType
		   END;

        RETURN @FullDataType ;
    END'');
		'
if @DebugFlag = 1
		select @sql
else
		exec(@sql)



END TRY

BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();		
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);

		
		RETURN @ErrorCode;
END CATCH
END
GO
/****** Object:  StoredProcedure [PMAT].[pmat_generate_TABLE_template]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*=======================================================================================================
 

 Input Params: @DebugFlag   - 0 to execute; non-zero - to print SQL statements
			 : @Database	- database where [Source] table is stored
			 : @SchemaName  - table schema where [Source] table is stored
			 : @TableSrc    - name of the [Source] table

 *** Execution syntax ***
 
 EXEC	[Your_Database].[Your_Table_Schema].[pmat_generate_TABLE_template]
		@DebugFlag  = [1|0], --0 - to execute; non-zero - to print SQL statements
		@Database   = [Your_Database],
		@SchemaName = [Your_Table_Schema],
		@TableSrc   = [Your_Source_Table_Name]
 GO
	
	2018-06-19	Susan	Modified for the schema names as a varchar	  
	2018-06-28	Susan	Modified the table for the flags to eliminate any Timestamp field from analysis 

========================================================================================================*/

CREATE   PROCEDURE [PMAT].[pmat_generate_TABLE_template] 	
	@executable_db varchar(50),
	@DebugFlag	BIT = 1, /* 0 - to execute; non-zero - to print SQL statements */
	@Database	varchar(500),
	@SchemaName	varchar(500),
	@TableSrc	varchar(500),
	@CoverageAnalysis Bit ,
	 @NullAnalysis Bit ,
	 @ValueAnalysis Bit ,
	 @MinMaxAnalysis Bit,
	 @PctAnalysis Bit 

AS    
BEGIN

	
	DECLARE @sql varchar(max)

set @sql=' USE '+@Database + ' 

	Declare @TableSrc varchar(500)
	Declare @Database	varchar(500),
			@SchemaName	varchar(500),
			@DebugFlag int 		

	DECLARE @ErrorMsg	 NVARCHAR(2048) = N'''',
		@ErrorCode	 INT = 0,
		@NewLine	 CHAR(2) = CHAR(13) + CHAR(10),
		@RecCntChar	 varchar(10);
	DECLARE @ProcName	 VARCHAR(200) = ''pmat_generate_TABLE_template'';
	DECLARE	@StepName	 VARCHAR(100) = ''Generate TABLE Template'';	
	DECLARE @sql varchar(max)
		
    set @TableSrc =''' + @TableSrc+'''
	set @Database = '''+ @Database+'''
	set @SchemaName =''' +@SchemaName+' ''
	set @DebugFlag ='+ convert(varchar(1),convert(int,@DebugFlag))+'
	DECLARE	@SubStepName	 VARCHAR(250) = @StepName+'' for ''+@Database+'' all tables'';

	BEGIN TRY
		if @TableSrc = ''All'' 
			begin 			 insert into '+@SchemaName+'.[TABLE_SOURCE_ANALYSIS] 
			 ( [DATABASE_NAME], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_ROW_COUNT], [COLUMN_NAME], [ORDINAL_POSITION],
			  [DATA_TYPE], [DATA_CATEGORY_NAME], [COUNT_COVERAGE_FLAG], [PCT_COVERAGE_FLAG],
			   [MIN_MAX_VALUE_FLAG], [COUNT_NULL_BLANK_FLAG], [COUNT_VALUE_FLAG]
			    )
			SELECT	DISTINCT DATABASE_NAME = ''[''+TB.TABLE_CATALOG+'']'',
				TB.TABLE_SCHEMA,TB.TABLE_NAME,	i.Rows [TABLE_ROW_COUNT],COLUMN_NAME,ORDINAL_POSITION,	 convert(varchar(100),case when UPPER(DATA_TYPE) =''DECIMAL''   THEN UPPER(DATA_TYPE)+''(''+ convert(varchar(5),NUMERIC_PRECISION) + '','' +convert(varchar(5), NUMERIC_SCALE) + '')''	 WHEN UPPER(DATA_TYPE) LIKE ''%CHAR'' THEN UPPER(DATA_TYPE)+''(''+ CASE WHEN convert(varchar(5),CHARACTER_MAXIMUM_LENGTH) = ''-1'' THEN ''MAX'' ELSE convert(varchar(5),CHARACTER_MAXIMUM_LENGTH) END + '')''
			       ELSE DATA_TYPE END) DataType,
				 null,
				COUNT_COVERAGE_FLAG =  case when UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'') then 0 else 1 end,
				PCT_COVERAGE_FLAG = case when UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'') then 0 else 1 end,
				MIN_MAX_VALUE_FLAG = case when  UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'')or TB.TABLE_NAME =''UserProfile''  then 0 
											when UPPER(DATA_TYPE) in (''BIT'',''TIMESTAMP'',''TEXT'',''VARBINARY'') or TB.TABLE_NAME =''UserProfile'' then 0 else 1 end,			
				COUNT_NULL_BLANK_FLAG = case when UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'') then 0 else 1 end,
				COUNT_VALUE_FLAG =case when  UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'') or TB.TABLE_NAME =''UserProfile'' then 0 else 1 end 
		 FROM INFORMATION_SCHEMA.COLUMNS ISC
			  inner join INFORMATION_SCHEMA.TABLES TB on ISC.TABLE_NAME = TB.TABLE_NAME and ISC.TABLE_SCHEMA = TB.TABLE_SCHEMA
              INNER JOIN sys.objects t  ON t.name = ISC.TABLE_NAME and SCHEMA_NAME(t.schema_id) = TB.TABLE_SCHEMA
              left outer JOIN sysindexes i on  t.type = ''U'' and i.id = t.object_id and i.indid in (0,1)
			  		WHERE TB.TABLE_CATALOG = replace(replace(@Database,''['',''''),'']'','''')
		 		  and ( (TB.TABLE_NAME not in ( ''VW_TABLE_ANALYSIS_IC_REPORT'',''VW_TABLE_SOURCE_ANALYSIS_LOAD'',''VW_TABLE_SOURCE_ANALYSIS_MAIN_REPORT'',''VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT'',''MAPPING_CONFIG'',''MAPPING_CONFIG_HISTORY'',''cmsv_all'',''cmsv_cases'',''cmsv_parties'',''cmsp_court'',''cmsp_patty'',''cmsp_plaint'',''cmsv_test'' ) and  TB.TABLE_NAME not like ''Whitespace_%'' and  TB.TABLE_NAME not like ''__FV%'' and TB.TABLE_NAME not like (''TABLE%'')) ) 
			ORDER BY TB.TABLE_NAME,ORDINAL_POSITION
		end
	else 
		begin 			 insert into '+@SchemaName+'.[TABLE_SOURCE_ANALYSIS] 
			 ( [DATABASE_NAME], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_ROW_COUNT], [COLUMN_NAME], [ORDINAL_POSITION], [DATA_TYPE], [DATA_CATEGORY_NAME], [COUNT_COVERAGE_FLAG], [PCT_COVERAGE_FLAG], [MIN_MAX_VALUE_FLAG], [COUNT_NULL_BLANK_FLAG], [COUNT_VALUE_FLAG]   )
			SELECT	DISTINCT DATABASE_NAME = ''[''+TB.TABLE_CATALOG+'']'',	TB.TABLE_SCHEMA,	TB.TABLE_NAME,	i.Rows [TABLE_ROW_COUNT],COLUMN_NAME,ORDINAL_POSITION, convert(varchar(100),case when UPPER(DATA_TYPE) =''DECIMAL''   THEN UPPER(DATA_TYPE)+''(''+ convert(varchar(5),NUMERIC_PRECISION) + '','' +convert(varchar(5), NUMERIC_SCALE) + '')''
			       WHEN UPPER(DATA_TYPE) LIKE ''%CHAR'' THEN UPPER(DATA_TYPE)+''(''+ CASE WHEN convert(varchar(5),CHARACTER_MAXIMUM_LENGTH) = ''-1'' THEN ''MAX'' ELSE convert(varchar(5),CHARACTER_MAXIMUM_LENGTH) END + '')''
			       ELSE DATA_TYPE END) DataType,
				 case when TB.TABLE_NAME like ''%contact%'' then ''CONTACTS''
						   when TB.TABLE_NAME like ''%case%'' then ''CASES''
						      WHEN TB.TABLE_NAME like ''%matter%'' THEN ''CASES''
						   when TB.TABLE_NAME like ''%comment%'' then ''NOTES''
						   when TB.TABLE_NAME like ''%message%'' then ''NOTES''
						   when TB.TABLE_NAME like ''%document%'' then ''DOCUMENTS''
						   when TB.TABLE_NAME like ''%witn%'' then ''WITNESSES''
						   when TB.TABLE_NAME like ''%offer%'' then ''NEGOTIATIONS''
						   when TB.TABLE_NAME like ''%entity%'' then ''CONTACTS''
						   WHEN TB.TABLE_NAME like ''%employee%'' then ''USER''
						   when TB.TABLE_NAME like ''%incid%'' then ''INTAKE''
						   when TB.TABLE_NAME like ''%issue%'' then ''ISSUES''
						   when TB.TABLE_NAME like ''%defend%'' then ''DEFENDANT''
						ELSE	''OTHER''	END,
				COUNT_COVERAGE_FLAG =  case when UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'') then 0 else 1 end,
				PCT_COVERAGE_FLAG = case when UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'') then 0 else 1 end,
				MIN_MAX_VALUE_FLAG = case when  UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'')or TB.TABLE_NAME =''UserProfile''  then 0 
											when UPPER(DATA_TYPE) in (''BIT'',''TIMESTAMP'',''TEXT'',''VARBINARY'') or TB.TABLE_NAME =''UserProfile'' then 0 else 1 end,			
				COUNT_NULL_BLANK_FLAG = case when UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'') then 0 else 1 end,
				COUNT_VALUE_FLAG =case when  UPPER(DATA_TYPE) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'') or TB.TABLE_NAME =''UserProfile'' then 0 else 1 end 
		 FROM INFORMATION_SCHEMA.COLUMNS ISC
		  inner join INFORMATION_SCHEMA.TABLES TB on ISC.TABLE_NAME = TB.TABLE_NAME and ISC.TABLE_SCHEMA = TB.TABLE_SCHEMA
              INNER JOIN sys.objects t  ON t.name = ISC.TABLE_NAME and SCHEMA_NAME(t.schema_id) = TB.TABLE_SCHEMA
              left outer JOIN sysindexes i on  t.type = ''U'' and i.id = t.object_id and i.indid in (0,1)
			  WHERE TB.TABLE_CATALOG = replace(replace(@Database,''['',''''),'']'','''')  and ( (TB.TABLE_NAME not in ( ''VW_TABLE_ANALYSIS_IC_REPORT'',''VW_TABLE_SOURCE_ANALYSIS_LOAD'',''VW_TABLE_SOURCE_ANALYSIS_MAIN_REPORT'',''VW_TABLE_SOURCE_ANALYSIS_VALUE_REPORT'',''MAPPING_CONFIG'',''MAPPING_CONFIG_HISTORY'', ''cmsv_all'',''cmsv_cases'', ''cmsv_parties'' , ''cmsp_court'' ,''cmsp_patty'' , ''cmsp_plaint'',''cmsv_test'' ) and 
				  TB.TABLE_NAME not like ''Whitespace_%'' and TB.TABLE_NAME not like ''__FV%'' and TB.TABLE_NAME not like (''TABLE%'')) ) and TB.TABLE_NAME = '''+@TableSrc+''' 	ORDER BY TB.TABLE_NAME,ORDINAL_POSITION
		end
		SET @RecCntChar = CAST(@@ROWCOUNT AS VARCHAR(10));			
		IF @DebugFlag = 1 
			SELECT @SubStepName+'' will produce ''+@RecCntChar+'' number of entries''
		ELSE		
			EXEC '+@executable_db+'.[PMAT].[pmat_update_TABLE_process_status] @Database,@SchemaName, @ProcName, @StepName,  ''COMPLETED'', @RecCntChar, @ErrorCode, @ErrorMsg;
	END TRY	
	BEGIN CATCH
		SET @ErrorMsg = N''!!!!ERROR - FAILED to ''+@SubStepName + @NewLine + ERROR_MESSAGE();
		EXEC '+@executable_db+'.[PMAT].[pmat_update_TABLE_process_status] @Database,@SchemaName, @ProcName, @StepName, @SubStepName, ''FAILED'', @@ROWCOUNT, @ErrorCode, @ErrorMsg;
	END CATCH '
	IF @DebugFlag = 1 
		select @sql

	exec(@sql)
	
	set @sql=' USE '+@Database + ' 

					Declare @TableSrc varchar(500)
					Declare @Database	varchar(500),
							@SchemaName	varchar(500),
							@DebugFlag int 			

					DECLARE @ErrorMsg	 NVARCHAR(2048) = N'''',
						@ErrorCode	 INT = 0,
						@NewLine	 CHAR(2) = CHAR(13) + CHAR(10),
						@RecCntChar	 varchar(10);
					DECLARE @ProcName	 VARCHAR(200) = ''pmat_generate_TABLE_template - set flags'';
					DECLARE	@StepName	 VARCHAR(100) = ''Generate TABLE Template  - set flags'';
	
					DECLARE @sql varchar(max)
		
					set @TableSrc =''' + @TableSrc+'''
					set @Database = '''+ @Database+'''
					set @SchemaName =''' +@SchemaName+' ''
					set @DebugFlag ='+ convert(varchar(1),convert(int,@DebugFlag))+'
					DECLARE	@SubStepName	 VARCHAR(250) = @StepName+'' for ''+@Database+'' all tables Process set flags'';
					
					update '+@SchemaName+'.[TABLE_SOURCE_ANALYSIS] 
						set 
						[COUNT_COVERAGE_FLAG]='+convert(varchar(1),convert(int,@CoverageAnalysis))+',
						[PCT_COVERAGE_FLAG]='+ convert(varchar(1),convert(int,@PctAnalysis))+',
						[MIN_MAX_VALUE_FLAG]='+ convert(varchar(1),convert(int,@MinMaxAnalysis))+', 
						[COUNT_NULL_BLANK_FLAG]= '+convert(varchar(1),convert(int,@NullAnalysis))+', 
						[COUNT_VALUE_FLAG]= '+ convert(varchar(1),convert(int,@ValueAnalysis))+'
						'
							
					IF @DebugFlag = 1 
						select @sql
					 exec(@sql)
				
	set @sql=' USE '+@Database + ' 

					Declare @TableSrc varchar(500)
					Declare @Database	varchar(500),
							@SchemaName	varchar(500),
							@DebugFlag int 		

					DECLARE @ErrorMsg	 NVARCHAR(2048) = N'''',
						@ErrorCode	 INT = 0,
						@NewLine	 CHAR(2) = CHAR(13) + CHAR(10),
						@RecCntChar	 varchar(10);
					DECLARE @ProcName	 VARCHAR(200) = ''pmat_generate_TABLE_template - set flags'';
					DECLARE	@StepName	 VARCHAR(100) = ''Generate TABLE Template  - set flags'';
	
					DECLARE @sql varchar(max)
		
					set @TableSrc =''' + @TableSrc+'''
					set @Database = '''+ @Database+'''
					set @SchemaName =''' +@SchemaName+' ''
					set @DebugFlag ='+ convert(varchar(1),convert(int,@DebugFlag))+'
					DECLARE	@SubStepName	 VARCHAR(250) = @StepName+'' for ''+@Database+'' all tables Process Inventory Only'';
					
					update '+@SchemaName+'.[TABLE_SOURCE_ANALYSIS] 
					set [PCT_COVERAGE_FLAG]=0,
						[MIN_MAX_VALUE_FLAG]=0,
						COUNT_VALUE_FLAG=0,
						COUNT_COVERAGE_FLAG = 0 ,
						COUNT_NULL_BLANK_FLAG = 0
						where UPPER([DATA_TYPE]) in (''IMAGE'',''TIMESTAMP'',''TEXT'',''VARBINARY'',''NTEXT'')'
							
					IF @DebugFlag = 1 
						select @sql
					 exec(@sql)

END
GO
/****** Object:  StoredProcedure [PMAT].[pmat_update_flags_datatypes]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************/
/*                    OVERVIEW of TABLE Process	     	           */
/*******************************************************************************************/
/*                             */
/*******************************************************************************************/

/***********************************************************************************/
CREATE   PROCEDURE [PMAT].[pmat_update_flags_datatypes]
	@DebugFlag		BIT = 0, /* 0 - to execute; non-zero - to print SQL statements */
	@Database		varchar(500),
	@SchemaName		varchar(500)
AS
BEGIN

	DECLARE @SQL	  NVARCHAR(MAX) = N'',
			@SQL_2    NVARCHAR(MAX) = N'',
			@SQLWhere NVARCHAR(200) = N'',
			@NewLine  CHAR(2) = CHAR(13) + CHAR(10);

	DECLARE @ProcName	 VARCHAR(200) = OBJECT_NAME(@@PROCID),
			@StepName	 VARCHAR(100) = 'Update TABLE Config Flag Tables - MAIN',
			@SubStepName VARCHAR(250) = 'Check datatypes and flags for analysis';

	DECLARE @ErrorCode INT = 0,
			@ErrorMsg  NVARCHAR(2048) = N'';

	BEGIN TRY
		IF @DebugFlag = 1 SELECT [@StepName] = 'BEGIN '+@StepName;

		--1) Gets list of Config Flags from TABLE Analysis table
		SET @SubStepName = 'Create the tables for datatypes and flag ';	

declare @dropTableSql nvarchar(max)
declare @databaseName nvarchar(500)
declare @DatabaseBrackets nvarchar(500)
declare @schema nvarchar(500)
declare @schemaBrackets nvarchar(500)

set @databaseName = @Database
set @schema = @SchemaName
set @DatabaseBrackets = case when charindex('[',@databaseName,1) = 0 then '['+@databaseName+']'
									else @databaseName end		 
set @databaseName =  replace(replace(@databaseName,'[',''),']','')
set @schemaBrackets = case when charindex('[',@schema ,1) = 0 then '['+@schema +']' 
									else @schema  end		 
set @schema  =  replace(replace(@schema ,'[',''),']','')

set @sql = 'USE '+@DatabaseBrackets + '   
declare @sql nvarchar(max)
declare @countColumns int 
declare @counter int

set @counter = 1
select @countColumns=count(*) from '+@schema+'.[TABLE_SOURCE_ANALYSIS] where DATA_TYPE like ''%max%''

while @counter <= @countColumns
begin
	select @sql = mysql
	from (	select ''ALTER TABLE ''+DATABASE_NAME+''.''+TABLE_SCHEMA+''.[''+TABLE_NAME+'']
				ALTER COLUMN [''+COLUMN_NAME+''] ''+DATA_TYPE+''  COLLATE SQL_Latin1_General_CP1_CI_AS NULL; '' mysql, row_number() over (order by Table_Name) rn
	from '+@schema+'.[TABLE_SOURCE_ANALYSIS] 
	where DATA_TYPE like ''%max%'') a	where a.rn = @counter
		
	begin try
	exec (@sql)
		set @counter=@counter+1
	end try
	begin catch
		set @counter=@counter+1
	end catch
end 
set @counter = 1
select @countColumns=count(*) from '+@schema+'.[TABLE_SOURCE_ANALYSIS] where  (DATA_TYPE like ''%numeric%'' or DATA_TYPE in(''real'',''float'',''money''))

while @counter <= @countColumns
begin
	select @sql = mysql
	from (	select ''ALTER TABLE ''+DATABASE_NAME+''.''+TABLE_SCHEMA+''.[''+TABLE_NAME+'']
				ALTER COLUMN [''+COLUMN_NAME+''] ''+case when (DATA_TYPE like ''%numeric%'' or DATA_TYPE in(''real'',''float'',''money'')) then ''decimal(10,2)'' else DATA_TYPE end+'' NULL; '' mysql, row_number() over (order by Table_Name) rn
	from '+@schema+'.[TABLE_SOURCE_ANALYSIS] where DATA_TYPE like ''%numeric%''
	) a	where a.rn = @counter	
	begin try
	exec (@sql)
		set @counter=@counter+1
	end try
	begin catch
		set @counter=@counter+1
	end catch
end

set @counter = 1
select @countColumns=count(*) from '+@schema+'.[TABLE_SOURCE_ANALYSIS] where DATA_TYPE like ''%text%''

while @counter <= @countColumns
begin
	select @sql = mysql
	from (	select ''ALTER TABLE ''+DATABASE_NAME+''.''+TABLE_SCHEMA+''.[''+TABLE_NAME+'']
				ALTER COLUMN [''+COLUMN_NAME+''] varchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL; '' mysql, row_number() over (order by Table_Name) rn
	from '+@schema+'.[TABLE_SOURCE_ANALYSIS] where DATA_TYPE like ''%text%''
	) a	where a.rn = @counter
	
	begin try
	exec (@sql)
		set @counter=@counter+1
	end try
	begin catch
		set @counter=@counter+1
	end catch
end

set @counter = 1
select @countColumns=count(*)  FROM sys.columns c
JOIN sys.types t ON c.system_type_id = t.system_type_id
JOIN INFORMATION_SCHEMA.COLUMNS col on col.COLUMN_NAME = c.name and c.object_id = OBJECT_ID(col.TABLE_NAME)
LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT OUTER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
where  (t.Name LIKE ''%char%'' OR t.Name LIKE ''%text%'') AND c.collation_name <> ''SQL_Latin1_General_CP1_CI_AS''

while @counter <= @countColumns
begin
	select @sql = mysql
	from (	select 	 CASE  WHEN t.Name like ''%text%''
            THEN ''alter TABLE ['' + TABLE_NAME + ''] ALTER COLUMN ['' + c.name + ''] '' + t.Name + '' COLLATE SQL_Latin1_General_CP1_CI_AS '' + CASE WHEN c.is_nullable = 0 THEN ''NOT NULL;'' ELSE ''NULL; '' END
            ELSE ''alter TABLE ['' + TABLE_NAME + ''] ALTER COLUMN ['' + c.name + ''] '' + t.Name + ''('' + convert(nvarchar(5),col.CHARACTER_MAXIMUM_LENGTH) + '') COLLATE SQL_Latin1_General_CP1_CI_AS '' + CASE WHEN c.is_nullable = 0 THEN ''NOT NULL; '' ELSE ''NULL; '' END END mysql, row_number() over (order by col.TABLE_NAME) rn
		FROM sys.columns c
		JOIN sys.types t ON c.system_type_id = t.system_type_id
		JOIN INFORMATION_SCHEMA.COLUMNS col on col.COLUMN_NAME = c.name and c.object_id = OBJECT_ID(col.TABLE_NAME)
		LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
		LEFT OUTER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
		where  (t.Name LIKE ''%char%'' OR t.Name LIKE ''%text%'') 	AND c.collation_name <> ''SQL_Latin1_General_CP1_CI_AS''
	) a	where a.rn = @counter

	begin try	
		exec (@sql) 
		set @counter=@counter+1	
	end try
	begin catch
		set @counter=@counter+1
	end catch	
end '
if @DebugFlag = 1
		select @sql as 'DataTypes'
else
		begin
		exec(@sql)		
		
		
	
		end 
END TRY


BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();		
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);		
		RETURN @ErrorCode;
END catch

begin try
set @SQL_2 =  'USE '+@DatabaseBrackets + ' 
update '+@schema+'.[TABLE_SOURCE_ANALYSIS] 
set Data_type =''decimal(10,2)''
where Data_type in(''numeric'',''real'',''float'',''money'')

update '+@schema+'.[TABLE_SOURCE_ANALYSIS] 
set Data_type =''varchar(max)'', [MIN_MAX_VALUE_FLAG] = 0
where Data_type=''text''

update '+@schema+'.[TABLE_SOURCE_ANALYSIS] 
set [MIN_MAX_VALUE_FLAG] = 0
where Data_type in (''bit'',''uniqueidentifier'',''guid'',''time'',''binary'')

update '+@schema+'.[TABLE_SOURCE_ANALYSIS] 
set   COUNT_COVERAGE_FLAG = 0,
  PCT_COVERAGE_FLAG =0,
  MIN_MAX_VALUE_FLAG=0,
  COUNT_NULL_BLANK_FLAG=0,
  COUNT_VALUE_FLAG=0
  WHERE TABLE_NAME like ''%_log%''
 
 update '+@schema+'.[TABLE_SOURCE_ANALYSIS] 
set   COUNT_COVERAGE_FLAG = 0,
  PCT_COVERAGE_FLAG =0,
  MIN_MAX_VALUE_FLAG=0,
  COUNT_NULL_BLANK_FLAG=0,
  COUNT_VALUE_FLAG=0
  WHERE lower(Data_type)=''xml''
  '



if @DebugFlag = 1
		select @sql as 'DataTypes - updates'
else
		begin
			
		exec(@sql_2)	
	
		end 
END TRY


BEGIN CATCH
		SET @ErrorCode = ERROR_NUMBER();		
		SET @ErrorMsg = N'!!!!ERROR - FAILED to '+@SubStepName + @NewLine + ERROR_MESSAGE();
		RAISERROR(@ErrorMsg, 16, 1);		
		RETURN @ErrorCode;
END CATCH
END
GO
/****** Object:  StoredProcedure [PMAT].[pmat_update_TABLE_process_status]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [PMAT].[pmat_update_TABLE_process_status]	
	@Database VARCHAR(500),
	@SchemaName VARCHAR(500),
	@step_exec	VARCHAR(500),
	@step_name	VARCHAR(100),
	@sub_step_name	VARCHAR(250),
	@status		VARCHAR(25),
	@row_count	BIGINT = 0,
	@error_code	BIGINT = 0,
	@error_msg	VARCHAR(MAX)='' 

AS
BEGIN
	DECLARE @sql VARCHAR(MAX)

	SET @sql = ' USE ' +@Database+' 

	INSERT INTO '+@SchemaName+'.[TABLE_PROCESS_STATUS](
		   [STEP_EXECUTABLE]
		  ,[STEP_NAME]
		  ,[SUB_STEP_NAME]
		  ,[STATUS]
		  ,[ROW_COUNT]
		  ,[ERROR_CODE]
		  ,[ERROR_MESSAGE])
	 VALUES ('''+
		   @step_exec +''','''+@step_name+''','''+@sub_step_name+''','''+@status+''','''+CONVERT(VARCHAR(10),@row_count)+''','''+CONVERT(VARCHAR(15),@error_code)+''','''+@error_msg+''');'
	--select @sql
	EXEC(@sql)
	
END
GO
/****** Object:  StoredProcedure [PMAT].[usp_create_mapping_config_table]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*DECLARE	@return_value int

EXEC	@return_value = [PMAT].[usp_create_mapping_config_table]
		@DatabaseName = N'8325_MayItForwardOrganization'

SELECT	'Return Value' = @return_value

GO
*/

CREATE   procedure [PMAT].[usp_create_mapping_config_table]
	  @DatabaseName varchar(1000),
	  @successFlag bit output

as
	begin
		declare 
			  @DatabaseNameUnquoted varchar(1000) = replace(replace(@DatabaseName, '[', ''), ']', '')
			, @DatabaseNameQuoted varchar(1000) = '[' + replace(replace(@DatabaseName, '[', ''), ']', '') + ']'
			
		declare
			@WorkingUse varchar(1000) = 'USE ' + @DatabaseNameQuoted
			
		declare
			@SQL varchar(max) = @WorkingUse + 
				'
					IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_CATALOG = ''' + @DatabaseNameUnquoted + ''' AND TABLE_NAME = ''MAPPING_CONFIG'')
						BEGIN
						create table  dbo.MAPPING_CONFIG_HISTORY      
						(   [FieldKey] [BIGINT]  NOT NULL /*PK*/       
						, [GroupTable] [INT] NOT NULL /*ranking number for the ProjectType/section*/     
						, [CE_Section_ID] [BIGINT] NOT NULL /*CustomsEditor Table ID*/        
						, [CE_Section_Name] [VARCHAR] (500) NOT NULL /*Customs Editor table Name*/    
						, [CE_Section_Alias] [VARCHAR](50) NOT NULL /*short name for Customs Editor table name*/          
						, [Section_Type] VARCHAR(50) NOT NULL /*Collection/Non-collection/standard table types*/       
						, [CE_Field_ID] [BIGINT] NOT NULL /*CustomsEditor field ID*/     
						, [CE_Field_Name] [VARCHAR](500) NOT NULL /*CustomsEditor Field name*/      
						, [CE_Data_Type] [VARCHAR] (500) NOT NULL /*custom editor data type (no precision)*/        
						, [CE_field_Type] [VARCHAR] (500) NOT NULL /*custom editor field type (i.e. dropdown, radio button, etc.)*/     
						, [CE_Max_Len] [INT] NULL /*custom editor field length*/         
						, [CE_Num_Precison] [INT] NULL /*custom editor precision*/       
						, [CE_Num_Scale] [INT] NULL /*custom editor scale*/       
						, [CE_full_Data_Type] [VARCHAR](100) NOT NULL /*custom editor full datatype*/       
						, [CE_ORDINAL_POSITION] [INT] NULL /*custom editor ordinal position*/     
						, [CE_null_Stmt] [varchar](100) not null /*custom editor null allowable flag*/  
						, [lg_table_ID] [varchar] (500) null /*legacy Table ID*/        
						, [lg_table_Name] [VARCHAR] (500) NULL /*legacy table Name*/     
						, [lg_table_Alias] [varchar](50) null /*short name for legacy table name*/     

						, [lg_Field_ID] [BIGINT] NULL /*legacy field ID*/           , [lg_Field_Name] [VARCHAR](500) null /*legacy Field name*/     
						, [lg_Data_Type] [varchar] (500) null /*legacy data type (no precision)*/           , [lg_Max_Len] [int] null /*legacy field length*/    
						, [lg_Num_Precison] [INT] NULL /*legacy precision*/           , [lg_Num_Scale] [INT] NULL /*legacy scale*/          
						, [lg_full_Data_Type] [VARCHAR](100) NULL /*legacy full datatype*/          
						, [lg_ORDINAL_POSITION] [INT] NULL /*legacy ordinal position*/    
						, [lg_null_Stmt] [VARCHAR](100) NULL /*legacy null allowable flag*/        
						,SysStartTime DATETIME2 NOT NULL
						  , SysEndTime DATETIME2 NOT NULL) 


						CREATE CLUSTERED COLUMNSTORE  index IX_MAPPING_CONFIG_HISTORY    ON MAPPING_CONFIG_HISTORY;
						CREATE NONCLUSTERED INDEX IX_MAPPING_CONFIG_HISTORY_ID_PERIOD_COLUMNS     ON MAPPING_CONFIG_HISTORY (SysEndTime, SysStartTime, [FieldKey]);

						create table   dbo.MAPPING_CONFIG   
						(    [FieldKey] [BIGINT] IDENTITY(1,1) NOT null PRIMARY KEY CLUSTERED /*PK*/       
						, [GroupTable] [INT] NOT NULL /*ranking number for the ProjectType/section*/     
						, [CE_Section_ID] [BIGINT] NOT NULL /*CustomsEditor Table ID*/        
						, [CE_Section_Name] [VARCHAR] (500) NOT NULL /*Customs Editor table Name*/    
						, [CE_Section_Alias] [VARCHAR](50) NOT NULL /*short name for Customs Editor table name*/          
						, [Section_Type] VARCHAR(50) NOT NULL /*Collection/Non-collection/standard table types*/       
						, [CE_Field_ID] [BIGINT] NOT NULL /*CustomsEditor field ID*/     
						, [CE_Field_Name] [VARCHAR](500) NOT NULL /*CustomsEditor Field name*/      
						, [CE_Data_Type] [VARCHAR] (500) NOT NULL /*custom editor data type (no precision)*/        
						, [CE_field_Type] [VARCHAR] (500) NOT NULL /*custom editor field type (i.e. dropdown, radio button, etc.)*/     
						, [CE_Max_Len] [INT] NULL /*custom editor field length*/         
						, [CE_Num_Precison] [INT] NULL /*custom editor precision*/       
						, [CE_Num_Scale] [INT] NULL /*custom editor scale*/       
						, [CE_full_Data_Type] [VARCHAR](100) NOT NULL /*custom editor full datatype*/       
						, [CE_ORDINAL_POSITION] [INT] NULL /*custom editor ordinal position*/     
						, [CE_null_Stmt] [varchar](100) not null /*custom editor null allowable flag*/  
						, [lg_table_ID] [varchar] (500) null /*legacy Table ID*/        
						, [lg_table_Name] [VARCHAR] (500) NULL /*legacy table Name*/     
						, [lg_table_Alias] [varchar](50) null /*short name for legacy table name*/     

						, [lg_Field_ID] [BIGINT] NULL /*legacy field ID*/           , [lg_Field_Name] [VARCHAR](500) null /*legacy Field name*/     
						, [lg_Data_Type] [varchar] (500) null /*legacy data type (no precision)*/           , [lg_Max_Len] [int] null /*legacy field length*/    
						, [lg_Num_Precison] [INT] NULL /*legacy precision*/           , [lg_Num_Scale] [INT] NULL /*legacy scale*/          
						, [lg_full_Data_Type] [VARCHAR](100) NULL /*legacy full datatype*/          
						, [lg_ORDINAL_POSITION] [INT] NULL /*legacy ordinal position*/    
						, [lg_null_Stmt] [VARCHAR](100) NULL /*legacy null allowable flag*/        
						, SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL
						  , SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL
						  , PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime)
						)
						WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.MAPPING_CONFIG_HISTORY));

					END
				'
				select @SQL
		exec (@SQL)
	end
GO
/****** Object:  StoredProcedure [PMAT].[usp_PMAT]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [PMAT].[usp_PMAT]
	  @executable_db varchar(50)=N'',
     @Database varchar(50) = N'',
	 @DebugFlag BIT = 0,
	 @CoverageAnalysis Bit = 0,
	 @NullAnalysis Bit = 0,
	 @ValueAnalysis Bit = 0,
	 @MinMaxAnalysis Bit = 0,
	 @PctAnalysis Bit = 0,
	@successFlag bit output

AS
	BEGIN
		SET NOCOUNT ON
		declare @DatabaseBrackets nvarchar(500)
		declare @databaseName nvarchar(500)

		set @databaseName = @Database
		set @DatabaseBrackets = case when charindex('[',@databaseName,1) = 0 then '['+@databaseName+']'
									else @databaseName end
		 
		set @databaseName =  replace(replace(@databaseName,'[',''),']','')



	--	BEGIN TRY

	     if @DebugFlag = 0
		 begin
			exec('Declare @return_value int EXEC	@return_value = ['+@executable_db+'].[PMAT].[pmat_generate_infastructure_tables]
			@DebugFlag = 0,
			@Database = N'''+@DatabaseBrackets+''',
			@SchemaName = N''dbo''')

		
			exec('Declare @return_value int EXEC	@return_value = ['+@executable_db+'].[PMAT].[pmat_generate_analysis_flag_table]
			@executable_db =N'''+@executable_db+''',
			@DebugFlag = 0,
			@Database = N'''+@DatabaseBrackets+''',
			@SchemaName = N''dbo'',
			@CoverageAnalysis  = '+@CoverageAnalysis+',
			@NullAnalysis  = '+ @NullAnalysis+',
			@ValueAnalysis = '+ @ValueAnalysis+',
			@MinMaxAnalysis  = '+@MinMaxAnalysis+',
			@PctAnalysis  = '+ @PctAnalysis+'')
		
		/*****SB_DEBUG **/

			select 'pmat_update_flags_datatypes'
			exec('Declare @return_value int EXEC	@return_value = ['+@executable_db+'].[PMAT].[pmat_update_flags_datatypes]
				@DebugFlag = 0,
			@Database = N'''+@DatabaseBrackets+''',
			@SchemaName = N''dbo''')

		
  			exec('Declare @return_value int EXEC	@return_value = ['+@executable_db+'].[PMAT].[pmat_build_TABLE_config_flag_table_main]
					@executable_db =N'''+@executable_db+''',
					@DebugFlag = '+@DebugFlag+',
				@Database = N'''+@databaseName+''',
				@SchemaName = N''dbo'',
				@TableConfig =N''TABLE_SOURCE_ANALYSIS''
			   ,@TableSrc=N''''')
			end
			else
			begin
					select 	'exec(''Declare @return_value int EXEC	@return_value = ['+@executable_db+'].[PMAT].[pmat_generate_infastructure_tables]
						@DebugFlag = 0,
						@Database = N'''+@DatabaseBrackets+''',
						@SchemaName = N''dbo'''')'

		
					select 'exec(''Declare @return_value int EXEC	@return_value = ['+@executable_db+'].[PMAT].[pmat_generate_analysis_flag_table]
						@executable_db =N'''+@executable_db+''',
						@DebugFlag = 0,
						@Database = N'''+@DatabaseBrackets+''',
						@SchemaName = N''dbo'',
						@CoverageAnalysis  = '+convert(nvarchar(1),@CoverageAnalysis)+',
						@NullAnalysis  = '+ convert(nvarchar(1),@NullAnalysis)+',
						@ValueAnalysis = '+ convert(nvarchar(1),@ValueAnalysis)+',
						@MinMaxAnalysis  = '+convert(nvarchar(1),@MinMaxAnalysis)+',
						@PctAnalysis  = '+ convert(nvarchar(1),@PctAnalysis)+''')'

					select 'pmat_update_flags_datatypes'

					select 'exec(''Declare @return_value int EXEC	@return_value = ['+@executable_db+'].[PMAT].[pmat_update_flags_datatypes]
							@DebugFlag = 0,
						@Database = N'''+@DatabaseBrackets+''',
						@SchemaName = N''dbo'''')'

		
  					 select	'exec(''declare @return_value int EXEC	@return_value = ['+@executable_db+'].[PMAT].[pmat_build_TABLE_config_flag_table_main]
								@executable_db =N'''+@executable_db+''',
								@DebugFlag = '+convert(nvarchar(1),@DebugFlag)+',
							@Database = N'''+@databaseName+''',
							@SchemaName = N''dbo'',
							@TableConfig =N''TABLE_SOURCE_ANALYSIS''
						   ,@TableSrc=N'''''')'



			end 



	--END TRY

		--BEGIN CATCH
		--	THROW 50000,'Error - Major fail',1;
		--END CATCH
--EXEC msdb.dbo.sp_start_job N'MDETL';
END
GO
/****** Object:  StoredProcedure [PT1].[FULL_MigrationProcess]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PT1].[FULL_MigrationProcess]
	  @DebugFlag BIT = 1
		/*enables debugging SQL output.  TRUE: dumps output SQL code.  FALSE: runs proc normally.*/

	, @LegacyDbType VARCHAR(200) 
		/*Name of the legacy database.  (SELECT * FROM Filevine_META.dbo.legacy_database ORDER BY lg_db_name)*/
	
	, @LegacyDb VARCHAR(500) 
		/*Name of your client specific database.  i.e. [4436_borland]*/
	
	, @PreviousDB VARCHAR(500) = ''
		/*Name of the previous client DB you have used, i.e. test db going to golive/refresh db*/
	
	, @OrgID BIGINT	
		/*ID number for your org.  i.e. 4436.  (SELECT * FROM Filevine_META.dbo.filevine_organization ORDER BY OrgName)*/
	
	, @SchemaName VARCHAR(500) = 'dbo'
		/*legacy database schema.  Most default to dbo, but some legacy systems use a different schema, i.e. Timematters and lmtu13 schema*/
	
	, @FVProductionPrefix VARCHAR(500) 
		/*prefix for your import tables, i.e. _borlandTest8_*/
	
	, @FVPreviousPrefix VARCHAR(500) 
		/*If you are loading a previous test and want to copy of the execution order from a previous, pass your previous previx in here. i.e. _BorlandTest1_*/
	
	, @ImportDatabaseName VARCHAR(500) = 'FilevineProductionImport'
		/*where the Import batch tables lives (FilevineStagingImport, FilevineProductionImport, FilevineCanadaImport)*/
	
	, @ExecutionDB VARCHAR(500) = 'Filevine_META'
		/*database environment that will execute the procs, i.e.(Filevine_META, Filevine_META_QA, Sandbox_BP, etc.)*/
	
	, @UseGenericTemplate BIT = 1
		/*true = use generic template auto script code   false = just generate blank shell SP's*/
	
	, @Timezone VARCHAR(500) 
		/*client's timezone for datetime functions i.e. eastern, central, mountain, etc.*/
	
	, @RefreshProcs BIT = 0
		/*TRUE: drops and recreates all generated SP's in the client specific database.  FALSE: does nothing*/
AS
	BEGIN
		DECLARE 
			  @DebugFlagExt BIT = @DebugFlag
			, @DatabaseBrackets VARCHAR(500)
			, @PrevDatabaseBrackets VARCHAR(500)
			, @ExecutionDBBrackets VARCHAR(500)
			, @ErrorMsg NVARCHAR(2048) = N''
			, @SQL VARCHAR(MAX)
			, @SQLn NVARCHAR(MAX)
			, @SQLWrapper NVARCHAR(MAX)
			, @True BIT = 1
			, @False BIT = 0
			, @ProcName	VARCHAR(200) = OBJECT_NAME(@@PROCID)
			, @StepName VARCHAR(200) = 'Main Full Migration Process Procedure'
			, @SubStepName VARCHAR(200) = 'Main Proc'
			, @CreateMigrationMetaSQL VARCHAR(MAX)
			, @CreateReferenceSQL VARCHAR(MAX)
			, @CreateStagingSQL VARCHAR(MAX)
			, @CreateDropdownListSQL VARCHAR(MAX)
			, @CreateLegacySPMappingSQL VARCHAR(MAX)
			, @MigrationInsertMainSQL VARCHAR(MAX)
			, @LegacyDBTypeLookup VARCHAR(1000)
			, @return_value INT = 0
			, @PT1Schema VARCHAR(10) = 'PT1'
			, @MigrationProcessStatusTable VARCHAR(1000) = 'MIGRATION_PROCESS_STATUS'
			, @MigrationConfigTable VARCHAR(1000) = 'MIGRATION_CONFIG'
			, @ExecOrderTable VARCHAR(1000) = 'LegacySPExecutionOrder'
			, @ExecOrderView VARCHAR(1000) = 'vw_LegacySP_FullMigration_ExecOrder'
			, @BaseImportSchema VARCHAR(100) = 'BaseImport'
			, @AuditImportSchema VARCHAR(100) = 'AuditImport'
			, @ImportSQLAuditTable VARCHAR(100) = 'ImportSQLAudit'
			, @ImportTableMapTable VARCHAR(100) = 'ImportTableMap'

		/*set execution DB*/
		DECLARE 
			@WorkingUse VARCHAR(500) = 
				'
					USE [' + @ExecutionDB + ']; 
				'
		
		/*Normalize DB and Prefix names for script*/
		BEGIN
			SELECT
				  @ImportDatabaseName = REPLACE(REPLACE(@ImportDatabaseName, '[', ''), ']', '')
				, @ExecutionDB = REPLACE(REPLACE(@ExecutionDB, '[', ''), ']', '')
				, @PreviousDB = ISNULL(NULLIF(@PreviousDB, @LegacyDb), '')
				, @FVPreviousPrefix = NULLIF(NULLIF(@FVPreviousPrefix, @FVProductionPrefix), '')
				, @DatabaseBrackets = '[' + REPLACE(REPLACE(@LegacyDb, '[', ''), ']', '') + ']'

			SELECT
				  @LegacyDb = REPLACE(REPLACE(@LegacyDb, '[', ''), ']', '')
				, @PrevDatabaseBrackets = '[' + REPLACE(REPLACE(@PreviousDB, '[', ''), ']', '') + ']'
				, @ExecutionDBBrackets = '[' + REPLACE(REPLACE(@ExecutionDB, '[', ''), ']', '') + ']'
		END

		/*Determine if invalid timezone string*/
		IF @Timezone NOT IN ('pacific', 'mountain', 'central', 'eastern', 'atlantic')
			BEGIN
				SET @ErrorMsg = 'Invalid Timezone entered.  Value Entered { ' + @Timezone + ' }  Accepted Values: pacific, mountain, central, eastern, atlantic'

				RAISERROR(@ErrorMsg, 16, 1);
				
				RETURN -6
			END
			
		/*Lookup the legacyDBType to ensure it exist in Legacy_Database table*/
		BEGIN
			SET @LegacyDBTypeLookup = (SELECT TOP 1 lg_db_SchemaName FROM [dbo].[Legacy_Database] WHERE lg_db_name = @LegacyDbType)

			IF @LegacyDBTypeLookup IS NULL
				BEGIN
					SET @ErrorMsg = 'Legacy Database Type [' + @LegacyDBType + '] either does not exist in [' + @ExecutionDB + '].[dbo].[legacy_database] table or is spelled incorrectly.  Please check spelling of Legacy DB name and that a record exists for this legacy system.'

					RAISERROR(@ErrorMsg,16,1);

					RETURN -6
				END
		END

		-----------------------------------------------------------------------------------------------------------------------
		----	CREATE PT1 SCHEMA	  -----------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------------
		BEGIN
			SET @SQL =
				'
					USE ' + @DatabaseBrackets + ' 

					IF NOT EXISTS
						(
							SELECT 
								1 
							FROM 
								' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[SCHEMATA]
							WHERE 
									CATALOG_NAME = ''' + @LegacyDb + '''
								AND SCHEMA_NAME = '''  + @PT1Schema + '''
						)
						BEGIN
							EXEC(''CREATE SCHEMA [' + @PT1Schema + ']'')
						END	
				'

			EXEC (@SQL)
		END

		-----------------------------------------------------------------------------------------------------------------------
		----	CREATE STATUS TABLES	   ------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------------
		BEGIN
			SET @SQL =	
				N'
					USE ' + @DatabaseBrackets + '

					IF OBJECT_ID(N''' + @PT1Schema + '.' + @MigrationProcessStatusTable + ''') IS NOT NULL 
						BEGIN
							DROP TABLE ' + @PT1Schema + '.' + @MigrationProcessStatusTable + '		
						END
			
					CREATE TABLE 
						' + @PT1Schema + '.' + @MigrationProcessStatusTable + '
						(
							  [STEP_NO] [BIGINT] IDENTITY(1,1) NOT NULL
							, [STEP_EXECUTABLE] [SYSNAME] NULL
							, [STEP_NAME] [NVARCHAR](100) NULL
							, [SUB_STEP_NAME] [NVARCHAR](250) NULL
							, [STATUS] [NVARCHAR](25) NULL
							, [ROW_COUNT] [BIGINT] NULL
							, [ERROR_CODE] [BIGINT] NULL
							, [ERROR_MESSAGE] [NVARCHAR](MAX) NULL
							, [RUN_DATE_TIME] [DATETIME] NOT NULL
							, [RUN_USER_ID] [SYSNAME] NOT NULL
							, [EXECUTED_SQL] [VARCHAR] (MAX)
							, [InsertedIntoFVProdImport] CHAR(1) null 
						) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
											
					ALTER TABLE 
						' + @PT1Schema + '.[' + @MigrationProcessStatusTable + '] 
					ADD 
						DEFAULT (GETDATE()) FOR [RUN_DATE_TIME];
				 
					ALTER TABLE 
						' + @PT1Schema + '.[' + @MigrationProcessStatusTable + '] 
					ADD 
						DEFAULT (USER_NAME()) FOR [RUN_USER_ID]; 
				'
					
			EXEC (@SQL)		 			
		END

		/**********************************************************************************************************************
		*********************************************EXEC PRE-MIGRATION PROCEDURES*********************************************
		**********************************************************************************************************************/
		BEGIN
			/**********************************************************************************************************************
			****	CREATE MIGRATION TABLES	   ************************************************************************************
			**********************************************************************************************************************/
			SET @CreateMigrationMetaSQL = 
				'
					EXEC [' + @ExecutionDB + '].[PT1].[usp_create_meta_MigrationTables]
						  @DebugFlag = ' + CONVERT(VARCHAR, @DebugFlagExt) + '
						, @SchemaName = ''dbo''
						, @Database	= ''' + @DatabaseBrackets + '''
						, @ExecutionDB = ''' + @ExecutionDB + '''
						, @PT1Schema = ''' + @PT1Schema + '''
						, @MigrationProcessStatusTable = ''' + @MigrationProcessStatusTable + '''
						, @MigrationConfigTable = ''' + @MigrationConfigTable + '''
						, @ExecOrderTable = ''' + @ExecOrderTable + '''
						, @ExecOrderView = ''' + @ExecOrderView + '''
				'

			/**********************************************************************************************************************
			****	CREATE REFERENCE TABLES	   ************************************************************************************
			**********************************************************************************************************************/
			SET @CreateReferenceSQL = 
				'
					EXEC [' + @ExecutionDB + '].[PT1].[usp_create_meta_ReferenceTables]
						  @DebugFlag = ' + CONVERT(VARCHAR, @DebugFlagExt) + '
						, @SchemaName = ''dbo''
						, @Database	= ''' + @DatabaseBrackets + '''
						, @PreviousDatabase = ''' + ISNULL(@PreviousDB, '') + '''
						, @ExecutionDB = ''' + @ExecutionDB + '''
						, @PT1Schema = ''' + @PT1Schema + '''
						, @MigrationProcessStatusTable = ''' + @MigrationProcessStatusTable + '''
				'

			/**********************************************************************************************************************
			****	CREATE STAGING TABLES	   ************************************************************************************
			**********************************************************************************************************************/
			SET @CreateStagingSQL = 
				'
					EXEC [' + @ExecutionDB + '].[PT1].[usp_create_meta_StagingTables]
						  @DebugFlag = ' + CONVERT(VARCHAR, @DebugFlagExt) + '
						, @Database = ''' + @DatabaseBrackets + '''
						, @SchemaName = N''dbo''
						, @prefix = ''' + @FVProductionPrefix + '''
						, @ImportDatabaseName = ''' + @ImportDatabaseName + '''
						, @ExecutionDB = ''' + @ExecutionDB + '''
						, @BaseImportSchema = ''' + @BaseImportSchema + '''
						, @AuditImportSchema = ''' + @AuditImportSchema + '''
						, @ImportSQLAuditTable = ''' + @ImportSQLAuditTable + '''
						, @ImportTableMapTable = ''' + @ImportTableMapTable + '''
						, @PT1Schema = ''' + @PT1Schema + '''
						, @MigrationProcessStatusTable = ''' + @MigrationProcessStatusTable + '''
						, @MigrationConfigTable = ''' + @MigrationConfigTable + '''
				'

			/**********************************************************************************************************************
			****	CREATE DropDownList Alignment TABLE****************************************************************************
			**********************************************************************************************************************/
			SET @CreateDropdownListSQL = 
				'
					EXEC [' + @ExecutionDB + '].[PT1].[usp_get_column_contraint_list]
						  @DebugFlag = ' + CONVERT(VARCHAR, @DebugFlagExt) + '
						, @Database = ''' + @DatabaseBrackets + '''
						, @SchemaName = N''dbo''
						, @executable_db = ''' + @ExecutionDB + '''
						, @TableSrc = N''''
						, @PT1Schema = ''' + @PT1Schema + '''
						, @MigrationProcessStatusTable = ''' + @MigrationProcessStatusTable + '''
				'
		
			/**********************************************************************************************************************
			****	CREATE LEGACY SP MAPPING	   ********************************************************************************
			**********************************************************************************************************************/
			SET @CreateLegacySPMappingSQL = 
				'
					EXEC [' + @ExecutionDB + '].[PT1].[usp_create_meta_LegacySPMapping]
						  @DebugFlag = ' + CONVERT(VARCHAR, @DebugFlagExt) + '
						, @Database = ''' + @DatabaseBrackets + '''
						, @PrevDatabase = ''' + ISNULL(@PreviousDB, '') + '''
						, @LegacyDbType = ''' + @LegacyDBTypeLookup + '''
						, @OrgID = ''' + CONVERT(VARCHAR, @OrgID) + '''
						, @SchemaName = N''dbo''
						, @ExecutionDB = ''' + @ExecutionDB + '''
						, @FVProductionPrefix = ''' + @FVProductionPrefix + '''
						, @FVPreviousPrefix = ''' + ISNULL(@FVPreviousPrefix, '') + '''
						, @UseGenericTemplate = ''' + CONVERT(VARCHAR, ISNULL(@UseGenericTemplate, @False)) + '''
						, @timezone = ''' + CONVERT(VARCHAR, @Timezone) + '''
						, @RefreshProcs = ' + CONVERT(VARCHAR, @RefreshProcs) + '
						, @PT1Schema = ''' + @PT1Schema + '''
						, @MigrationProcessStatusTable = ''' + @MigrationProcessStatusTable + '''
						, @MigrationConfigTable = ''' + @MigrationConfigTable + '''
				'

			/**********************************************************************************************************************
			*********************************************EXEC LEGACY SPECIFIC PROCEDURES*******************************************
			**********************************************************************************************************************/
			SET @MigrationInsertMainSQL = 
				'
					EXEC [' + @ExecutionDB + '].[PT1].[usp_migration_insert_main]
						  @DebugFlag = ' + CONVERT(VARCHAR, @DebugFlagExt) + '
						, @Database = ''' + @DatabaseBrackets + '''
						, @LegacyDbType = ''' + @LegacyDBTypeLookup + '''
						, @SchemaName = ''' + @SchemaName + '''
						, @OrgID = ' + CONVERT(VARCHAR, @OrgID) + '
						, @ExecutionDB = ''' + @ExecutionDB + '''
						, @FVProductionPrefix = ''' + @FVProductionPrefix + '''
						, @timezone = ''' + @Timezone + '''
						, @PT1Schema = ''' + @PT1Schema + '''
						, @MigrationProcessStatusTable = ''' + @MigrationProcessStatusTable + '''
				'

			SET @SubStepName = 'MAIN PROC'

			SET @SQLn = 
				  @WorkingUse 
				+ ' ' + @CreateMigrationMetaSQL
				+ ' ' + @CreateReferenceSQL
				+ ' ' + @CreateStagingSQL
				+ ' ' + @CreateDropdownListSQL
				+ ' ' + @CreateLegacySPMappingSQL
				+ ' ' + @MigrationInsertMainSQL
			
			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQLn
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable

			SELECT 'Return Value' = @return_value

			/*review*/
			BEGIN
				SET @SQL = @WorkingUse +
					'
						EXEC ' + @ExecutionDBBrackets + '.[qa].[usp_verify_import_load] 
							  @StagingImport = 1
							, @ReviewData = 0
							, @FVDatabase = ''' + @LegacyDb + '''
							, @FVSchema = ''' + @SchemaName + '''
							, @FVProductionPrefix = ''' + @FVProductionPrefix + '''
							, @FVProductionDB = ''' + @ExecutionDB + '''
							, @Batch = 1000
							, @PEIDS = ''''
					'

				EXEC (@SQL)
			END

		END
	END

	RETURN @return_value
GO
/****** Object:  StoredProcedure [PT1].[migration_update_process_status]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PT1].[migration_update_process_status]	
	  @Database VARCHAR(500)
	, @step_exec VARCHAR(500)
	, @step_name VARCHAR(100)
	, @sub_step_name VARCHAR(MAX)
	, @status VARCHAR(25)
	, @row_count BIGINT = 0
	, @error_code BIGINT = 0
	, @error_msg VARCHAR(MAX) = ''
	, @sqlcode VARCHAR(MAX) = ''
	, @PT1Schema VARCHAR(1000)
	, @MigrationProcessStatusTable VARCHAR(1000)

AS
	BEGIN
		DECLARE @SQL VARCHAR(MAX)

		SET @SQL = 
			'
				USE ' + @Database + ' 

				INSERT INTO 
					[' + @PT1Schema + '].[' + @MigrationProcessStatusTable + ']
					(
						  [STEP_EXECUTABLE]
						, [STEP_NAME]
						, [SUB_STEP_NAME]
						, [STATUS]
						, [ROW_COUNT]
						, [ERROR_CODE]
						, [ERROR_MESSAGE]
						, [EXECUTED_SQL]
					)
				VALUES 
					(
						  ''' + @step_exec + '''
						, ''' + @step_name + '''
						, ''' + @sub_step_name + '''
						, ''' + @status + '''
						, ''' + CONVERT(VARCHAR(10), @row_count) + '''
						, ''' + CONVERT(VARCHAR(15), @error_code) + '''
						, ''' + @error_msg + '''
						, ''' + @SQLCode + '''
					);
			'
		
		EXEC (@SQL)
	END
GO
/****** Object:  StoredProcedure [PT1].[usp_create_documents_folder_paths]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [PT1].[usp_create_documents_folder_paths]

	@removefrompath VARCHAR(500)

	,@databasename VARCHAR(500)

	,@S3DocScanTable VARCHAR(500)

	,@linkingValuePosition INT

	,@DebugFlag BIT

	,@S3DocId VARCHAR(500)

	,@TopXValue INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SQL VARCHAR(MAX) 
	, @dropTableSql VARCHAR(MAX)
	--, @S3ScanNameAppend VARCHAR(MAX)

	set @databasename = REPLACE(REPLACE(@databasename,'[',''),']','')

	set @S3DocScanTable = REPLACE(REPLACE(REPLACE(REPLACE(@S3DocScanTable,'dbo',''),'[',''),']',''),'.','')

	set @dropTableSql = 'USE ['+@databasename + ']
         IF OBJECT_ID(N''[dbo].__FolderPaths_'+@S3DocScanTable+''') IS NOT NULL
		 DROP TABLE [dbo].__FolderPaths_'+@S3DocScanTable+';';

	if @DebugFlag = 1
        select @dropTableSql
	exec (@dropTableSql)

	SET @SQL = 'USE ['+@databasename + ']
	;WITH docs AS (
	SELECT'+ CASE WHEN @TopXValue > 1 
				THEN ' TOP ('+CONVERT(VARCHAR(100),@TopXValue)+')'
				ELSE ' '
				END + '
		DocID,
		SourceS3ObjectKey,
		STRING_AGG(keysplit,''/'') AS filePath,
		MAX(CASE WHEN a.RN = '+CONVERT(VARCHAR(100),@linkingValuePosition)+' THEN a.keysplit ELSE null END) AS linkingValue
	FROM (
		SELECT   
			ROW_NUMBER() OVER(PARTITION BY DocID ORDER BY DocID) AS RN,
			DocId,
			SourceS3ObjectKey,
			FileComplete,
			VALUE AS keysplit
		FROM ['+@databasename+'].[dbo].['+@S3DocScanTable+']
		CROSS APPLY STRING_SPLIT(REPLACE([SourceS3ObjectKey],'''+@removefrompath+''',''''),''/'')
		WHERE right([SourceS3ObjectKey],1) != ''/''
		) AS a
	WHERE'+ CASE WHEN NULLIF(@S3DocId,' ') IS NOT NULL 
				THEN ' DocID ='''+@S3DocId+''' and ' 
				ELSE ' '
				END
				+'FileComplete != keysplit and RN > '+CONVERT(VARCHAR(100),@linkingValuePosition-1)+'
	GROUP BY DocID,SourceS3ObjectKey
	)        

	SELECT *, REPLACE(filePath,CONCAT(linkingValue,''/''),'''') AS folderPath INTO [dbo].__FolderPaths_'+@S3DocScanTable+' FROM docs'
	IF @DebugFlag = 1
		SELECT @SQL
	ELSE exec(@SQL)

END

GO
/****** Object:  StoredProcedure [PT1].[usp_create_documents_folderPathBuilder]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
create PROCEDURE [PT1].[usp_create_documents_folderPathBuilder]

	@removefrompath VARCHAR(500)

	,@databasename VARCHAR(500)

	,@linkingValuePosition INT

	,@DebugFlag BIT

	,@S3DocId VARCHAR(500)

	,@TopXValue INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SQL VARCHAR(MAX) 
	, @dropTableSql VARCHAR(MAX)

	set @databasename = REPLACE(REPLACE(@databasename,'[',''),']','')

	set @dropTableSql = 'USE ['+@databasename + ']
         IF OBJECT_ID(N''[dbo].__FV_DocsFolderPaths'') IS NOT NULL
		 DROP TABLE [dbo].__FV_DocsFolderPaths ;';

	if @DebugFlag = 1
        select @dropTableSql
	exec (@dropTableSql)

	SET @SQL = 'USE ['+@databasename + ']
	;WITH docs AS (
	SELECT'+ CASE WHEN @TopXValue > 1 
				THEN ' TOP ('+CONVERT(VARCHAR(100),@TopXValue)+')'
				ELSE ' '
				END + '
		DocID,
		SourceS3ObjectKey,
		STRING_AGG(keysplit,''/'') AS filePath,
		MAX(CASE WHEN a.RN = '+CONVERT(VARCHAR(100),@linkingValuePosition)+' THEN a.keysplit ELSE null END) AS linkingValue
	FROM (
		SELECT   
			ROW_NUMBER() OVER(PARTITION BY DocID ORDER BY DocID) AS RN,
			DocId,
			SourceS3ObjectKey,
			FileComplete,
			VALUE AS keysplit
		FROM ['+@databasename+'].[dbo].[S3DocScan]
		CROSS APPLY STRING_SPLIT(REPLACE([SourceS3ObjectKey],'''+@removefrompath+''',''''),''/'')
		WHERE right([SourceS3ObjectKey],1) != ''/''
		) AS a
	WHERE'+ CASE WHEN NULLIF(@S3DocId,' ') IS NOT NULL 
				THEN ' DocID ='''+@S3DocId+''' and ' 
				ELSE ' '
				END
				+'FileComplete != keysplit and RN > '+CONVERT(VARCHAR(100),@linkingValuePosition-1)+'
	GROUP BY DocID,SourceS3ObjectKey
	)        

	SELECT *, REPLACE(filePath,CONCAT(linkingValue,''/''),'''') AS folderPath INTO [dbo].__FV_DocsFolderPaths FROM docs'
	IF @DebugFlag = 1
		SELECT @SQL
	ELSE exec(@SQL)

end
*/

create   procedure [PT1].[usp_create_documents_folderPathBuilder]

	@removefrompath VARCHAR(500)

	,@databasename VARCHAR(500)

	,@linkingValuePosition INT

	,@DebugFlag BIT

	,@S3DocId VARCHAR(500)

	,@TopXValue INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SQL VARCHAR(MAX) 
	, @dropTableSql VARCHAR(MAX)

	set @databasename = REPLACE(REPLACE(@databasename,'[',''),']','')

	set @dropTableSql = 'USE ['+@databasename + ']
         IF OBJECT_ID(N''[dbo].__FV_DocsFolderPaths'') IS NOT NULL
		 DROP TABLE [dbo].__FV_DocsFolderPaths ;';

	if @DebugFlag = 1
        select @dropTableSql
	exec (@dropTableSql)

	SET @SQL = 'USE ['+@databasename + ']
	;WITH docs AS (
	SELECT'+ CASE WHEN @TopXValue > 1 
				THEN ' TOP ('+CONVERT(VARCHAR(100),@TopXValue)+')'
				ELSE ' '
				END + '
		DocID,
		SourceS3ObjectKey,
		 (select  Stuff(( select ''/'' + keysplit  
				from
				(
					select row_number() over (partition by DocID order by DocID) as RN
						 , DocID
						 , SourceS3ObjectKey
						 , FileComplete
						 , value                                                 as keysplit
					from ['+@databasename+'].[dbo].[S3DocScan]
						CROSS APPLY STRING_SPLIT(REPLACE([SourceS3ObjectKey],'''+@removefrompath+''',''''),''/'')
					where right([SourceS3ObjectKey], 1) != ''/''
				) a where 
				'+ CASE WHEN NULLIF(@S3DocId,' ') IS NOT NULL 
				THEN ' DocID ='''+@S3DocId+''' and ' 
				ELSE ' '
				END
				+'FileComplete != keysplit and RN > '+CONVERT(VARCHAR(100),@linkingValuePosition-1)+' 	
				for XML PATH(''), TYPE).value(''.'', ''varchar(max)''),1,1,'''')) AS filePath,
		MAX(CASE WHEN a.RN = '+CONVERT(VARCHAR(100),@linkingValuePosition)+' THEN a.keysplit ELSE null END) AS linkingValue
	FROM (
		SELECT   
			ROW_NUMBER() OVER(PARTITION BY DocID ORDER BY DocID) AS RN,
			DocId,
			SourceS3ObjectKey,
			FileComplete,
			VALUE AS keysplit
		FROM ['+@databasename+'].[dbo].[S3DocScan]
		CROSS APPLY STRING_SPLIT(REPLACE([SourceS3ObjectKey],'''+@removefrompath+''',''''),''/'')
		WHERE right([SourceS3ObjectKey],1) != ''/''
		) AS a
	WHERE'+ CASE WHEN NULLIF(@S3DocId,' ') IS NOT NULL 
				THEN ' DocID ='''+@S3DocId+''' and ' 
				ELSE ' '
				END
				+'FileComplete != keysplit and RN > '+CONVERT(VARCHAR(100),@linkingValuePosition-1)+'
	GROUP BY DocID,SourceS3ObjectKey
	)        

	SELECT *, REPLACE(filePath,CONCAT(linkingValue,''/''),'''') AS folderPath INTO [dbo].__FV_DocsFolderPaths FROM docs'
	IF @DebugFlag = 1
		SELECT @SQL
	ELSE exec(@SQL)

END
GO
/****** Object:  StoredProcedure [PT1].[usp_create_Insert_For_SP]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PT1].[usp_create_Insert_For_SP]
	  @DB VARCHAR(MAX) 
	, @LegacyTempSPMapTableName VARCHAR(MAX)
	, @TempSQLInsertTable VARCHAR(MAX)
	, @SPName VARCHAR(MAX)
	, @Schema VARCHAR(MAX) = 'dbo'
	, @DebugFlag BIT = 0
	, @FVProductionPrefix VARCHAR(MAX)
	, @timezone VARCHAR(1000)
	, @PT1Schema VARCHAR(1000)
	, @MigrationProcessStatusTable VARCHAR(1000)
	, @MigrationConfigTable VARCHAR(1000)
	, @ExecutionDB VARCHAR(500)

AS

BEGIN
	DECLARE
		  @SQL VARCHAR(MAX)
		, @SQLn NVARCHAR(MAX)
		, @MultiInserts BIT
		, @True BIT = 1
		, @False BIT = 0
	
	SET @DB = REPLACE(REPLACE(@DB, '[', ''), ']', '')
		
	DECLARE 
		@DatabaseBrackets VARCHAR(500) = '[' + @DB + ']'

	DECLARE
		@WorkingUse VARCHAR(1000) = 'USE ' + @DatabaseBrackets

		/*set @SQL = @WorkingUse + 'select * from ' + @LegacyTempSPMapTableName + ' ORDER BY legacyspname'
		exec (@SQL)*/

	/*If multiple project template types, then we need to create multiple inserts in the proc*/
	BEGIN
		SET @SQLn = @WorkingUse + 
			'
				SELECT
					@MultiInserts = 
						CASE
							WHEN 1 <
								(
									SELECT
										COUNT(*)
									FROM
										(
											SELECT DISTINCT 
												  TemplateCategoryID
												, LegacySPName
											FROM 
												[' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + ']
											WHERE 
												LegacySPName = ''' + @SPName + '''
										) a
								)
							THEN 1

							ELSE 0
						END
			'

		EXECUTE sp_executesql	
			  @SQLn
			, N'@MultiInserts BIT OUTPUT'
			, @MultiInserts = @MultiInserts OUTPUT

	END

	BEGIN
		SET @SQLn = @WorkingUse + 
			'
				IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @TempSQLInsertTable + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
					BEGIN
						DROP TABLE [' + @PT1Schema + '].[' + @TempSQLInsertTable + ']
					END
			'
			
		EXEC (@SQLn)
	END
		

	SET @SQLn = @WorkingUse + 
		'
			
			CREATE TABLE
				[' + @PT1Schema + '].[' + @TempSQLInsertTable + ']
					(
						  ID BIGINT IDENTITY(1,1) 
						, TableRank BIGINT
						, SynonymName VARCHAR(MAX)
						, TableName VARCHAR(MAX)
						, ProjectTemplateName VARCHAR(MAX)
						, SPType VARCHAR(MAX)
						, InsertSQL VARCHAR(MAX)
						, SelectSQL VARCHAR(MAX)
						, FromTable VARCHAR(MAX)
						, FromAlias VARCHAR(MAX)
						, JoinTable VARCHAR(MAX)
						, JoinAlias VARCHAR(MAX)
						, SQLInsert VARCHAR(MAX)
					)

			DECLARE
				  @Counter BIGINT = 1
				, @MaxID BIGINT

			INSERT INTO
				[' + @PT1Schema + '].[' + @TempSQLInsertTable + ']
				(
					  SynonymName
					, TableName
					, TableRank
					, ProjectTemplateName
					, SpType
				)
			SELECT DISTINCT
				  temp.SynonymName
				, temp.TableName
				, temp.Tablerank
				, temp.TemplateType
				, temp.TableSPType
			FROM 
				[' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] temp
			WHERE          
				LegacySPName = ''' + @SPName + '''

			SET @MaxID = (SELECT MAX(ID) FROM [' + @PT1Schema + '].[' + @TempSQLInsertTable + '])

			WHILE @Counter <= @MaxID
				BEGIN
					DECLARE 
						  @InsertCols VARCHAR(MAX) = ''''
						, @SelectCols VARCHAR(MAX) = ''''
						, @FromTable VARCHAR(MAX) = ''''
						, @FromAlias VARCHAR(MAX) = ''''  
						, @SynonymName VARCHAR(MAX) = (SELECT SynonymName FROM [' + @PT1Schema + '].[' + @TempSQLInsertTable + '] WHERE ID = @Counter) 
						, @TableName VARCHAR(MAX) = (SELECT TableName FROM [' + @PT1Schema + '].[' + @TempSQLInsertTable + '] WHERE ID = @Counter) 
						, @SPType VARCHAR(MAX) = (SELECT SPType FROM [' + @PT1Schema + '].[' + @TempSQLInsertTable + '] WHERE ID = @Counter)

					SELECT         
						  @InsertCols = COALESCE(@InsertCols + ''['' + Column_name + '']'', '''') + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + '', ''       
						, @SelectCols = COALESCE(@SelectCols + CASE WHEN LegacyOverride IS NOT NULL THEN CONVERT(VARCHAR(MAX), LegacyOverride) + '' ['' + Column_name + '']'' WHEN a.DATA_TYPE LIKE ''%datetime%'' THEN ''[' + @ExecutionDB + '].dbo.udfDate_ConvertUTC(['' + Column_Name + ''], ''''' + @timezone + ''''' , 1) ['' + Column_Name + '']'' ELSE ''NULL ['' + Column_name + '']'' END, '''') + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + CHAR(9) + '', ''        
						, @FromTable = FromTable  
						, @FromAlias = FromAlias
					FROM       
						(        
							SELECT DISTINCT            
								  COLUMN_NAME [Column_Name]         
								, DENSE_RANK() OVER(ORDER BY ORDINAL_POSITION) [OrdRANK] 
								, Data_Type          
								, LegacyOverride [LegacyOverride]         
								, FromTable         
								, FromAlias  
							FROM         
								INFORMATION_SCHEMA.Columns cols          
									LEFT JOIN [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] temp         
										ON temp.DestinationFieldName = cols.COLUMN_NAME            
										AND temp.TableName = cols.TABLE_NAME         
							WHERE          
									LegacySPName = ''' + @SPName + '''
								AND temp.TableName = @TableName  
								AND COLUMN_NAME NOT IN (''__ID'')    
						) a      
					ORDER BY       
						a.OrdRANK  

					UPDATE 
						[' + @PT1Schema + '].[' + @TempSQLInsertTable + ']
					SET 
						  InsertSQL = @InsertCols
						, SelectSQL = @SelectCols
						, FromTable = @FromTable
						, FromAlias = @FromAlias
						, SQLInsert = ''
		/*================================================================================================*/
		/*INSERT FOR PROJECT TEMPLATE: '' + ISNULL(ProjectTemplateName, ''Unknown Template'') + '' */
		/*================================================================================================*/
		/*
		INSERT INTO
			['' + CASE WHEN @SPType = ''Staging'' THEN ''PT1'' ELSE ''' + @Schema + ''' END + ''].['' + CASE WHEN @SPType = ''Reference'' THEN TableName WHEN @SPType = ''Staging'' THEN SynonymName END + '']
			(
				'' + ''  '' + SUBSTRING(@InsertCols, 1, LEN(@InsertCols) - 1) + ''
			)
		SELECT DISTINCT
			'' + ''  '' + SUBSTRING(@SelectCols, 1, LEN(@SelectCols) - 1) + ''
		'' + CASE 
				WHEN NULLIF(@FromTable, '''') IS NOT NULL 
				THEN 
		''
		FROM 
			'' + @FromTable +  '' '' + @FromAlias 
				ELSE '''' 
			END + ''
		'' + CASE 
				WHEN ' + CONVERT(VARCHAR, @MultiInserts) + ' = 1 
				THEN 
		'' 
				INNER JOIN 
					[__FV_ProjectTemplateMap] ptm 
						ON ptm.Legacy_Case_ID = ccm.CaseID 
		'' 
				ELSE '''' 
			END + ''
		'' + CASE 
				WHEN @FromTable LIKE ''%documents%'' 
				THEN 
		'' 
		/*WHERE
			FileExt NOT IN (''''[Add Comma Delimited List of File Extensions to Exclude Here]'''')*/
		'' 
				ELSE '''' 
			END + ''
		*/
				''
					WHERE
						TableName = @TableName

					SET @Counter = @Counter + 1
				END 


			'

		EXECUTE sp_executesql 
			  @SQLn 
				    
	RETURN		    
END
GO
/****** Object:  StoredProcedure [PT1].[usp_Create_LegacySPExecutionOrder]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [PT1].[usp_Create_LegacySPExecutionOrder]
	  @Database VARCHAR(1000)
	, @ExecutionDB VARCHAR(1000) = 'Filevine_META'
	, @DebugFlag BIT = 0
	, @PT1Schema VARCHAR(100)
	, @MigrationProcessStatusTable VARCHAR(1000)
	, @ExecOrderTable VARCHAR(1000)
	, @ExecOrderView VARCHAR(1000)
	
AS
	BEGIN
		DECLARE 
			  @SQL VARCHAR(MAX)
			, @SQLn NVARCHAR(MAX) = N''
			, @SQLWrapper NVARCHAR(MAX) = N''
			, @DatabaseBrackets VARCHAR(1000) = '[' + REPLACE(REPLACE(@Database, ']', ''), ']', '') + ']'
			, @ExecutionDBQuoted VARCHAR(1000) = '[' + REPLACE(REPLACE(@ExecutionDB, ']', ''), ']', '') + ']'
			, @ProcName	VARCHAR(200) = OBJECT_NAME(@@PROCID)
			, @StepName	VARCHAR(100) = 'migration for ' + @Database
			, @SubStepName VARCHAR(250) = ''
			, @ErrorMsg NVARCHAR(2048) = N''
			, @ErrorCode INT = 0
			, @EmptyString VARCHAR(10) = ''
			, @True BIT = 1
			, @False BIT = 0

		DECLARE
			  @LegacyUse VARCHAR(1000) = 'USE ' + @DatabaseBrackets
			, @WorkingUse VARCHAR(1000) = 'USE ' + @ExecutionDBQuoted

		/*Create Execution Order Table*/
		BEGIN
			SET @SQLn = @LegacyUse + 
				'
					IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @ExecOrderTable + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
						BEGIN
							CREATE TABLE 
								[' + @PT1Schema + '].[' + @ExecOrderTable + ']
								(
									  [LegacyExOrdID] [BIGINT] IDENTITY(1,1) NOT NULL
									, [LegacyDBID] [INT] NOT NULL
									, [LegacySPID] [BIGINT] NOT NULL
									, [OrgID] [BIGINT] NOT NULL
									, [FvProdPrefix] [VARCHAR](100) NOT NULL
									, [ExecutionOrder] [INT] NOT NULL DEFAULT 0
									, [Active] [BIT] NOT NULL DEFAULT 1
									, [CreatedDate] [DATETIME] NOT NULL DEFAULT GETDATE()
									, [ModifiedDate] [DATETIME] NULL
									, CONSTRAINT [pk__LegacyExOrdID] PRIMARY KEY CLUSTERED 
									  (
										  [LegacyDBID] ASC
										, [LegacySPID] ASC
										, [OrgID] ASC
										, [FvProdPrefix] ASC
										, [ExecutionOrder] ASC
									  )
									  WITH 
									  (
										  PAD_INDEX = OFF
										, STATISTICS_NORECOMPUTE = OFF
										, IGNORE_DUP_KEY = OFF
										, ALLOW_ROW_LOCKS = ON
										, ALLOW_PAGE_LOCKS = ON
										, FILLFACTOR = 10
									  ) ON [PRIMARY]
								) ON [PRIMARY]
						END
				'
			
			SET @SubStepName = 'Create ' + @ExecOrderTable
			
			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQLn
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END

		/*Create Execution Order View*/
		BEGIN
			SET @SQLn = @LegacyUse + 
				'
					IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = ''' + @ExecOrderView + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
						BEGIN
							EXEC
							(
								''
									CREATE VIEW
										[' + @PT1Schema + '].[' + @ExecOrderView +  ']
									AS
										SELECT
											  ldb.lg_db_id LegacyDBID 
											, Lg_db_Schemaname LegacyDatabaseType
											, lsp.LegacySPID
											, LegacyExOrdID 
											, LegacySPName
											, ExecutionOrder
											, fvorg.OrgID
											, Orgname
											, FvProdPrefix  
											, lsp.Active ActiveProcedure
											, lspeo.Active ActiveMapping
											, lspeo.CreatedDate CreatedDate
										FROM 
											[' + @ExecutionDB + '].[dbo].[LegacySP] lsp
												INNER JOIN [' + @PT1Schema + '].[' + @ExecOrderTable + '] lspeo
													ON lsp.LegacySPID = lspeo.LegacySPID
												INNER JOIN [' + @ExecutionDB + '].dbo.legacy_database ldb
													ON ldb.lg_db_id = lspeo.legacydbID
												INNER JOIN [' + @ExecutionDB + '].dbo.filevine_organization fvorg
													ON fvorg.orgID = lspeo.orgID
								''
							)
						END				
				'
			
			SET @SubStepName = 'Create ' + @ExecOrderView
			
			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQLn
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END
	END
GO
/****** Object:  StoredProcedure [PT1].[usp_create_meta_LegacySPMapping]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    PROCEDURE [PT1].[usp_create_meta_LegacySPMapping]
	  @DebugFlag BIT = 1  /*1 to output SQL statements; 0 to execute*/	
	, @Database VARCHAR(500)
	, @PrevDatabase VARCHAR(500)
	, @LegacyDbType VARCHAR(500)
	, @OrgID BIGINT 
	, @SchemaName VARCHAR(500)
	, @ExecutionDB VARCHAR(500)
	, @FVProductionPrefix VARCHAR(500)
	, @FVPreviousPrefix VARCHAR(500)
	, @UseGenericTemplate BIT
	, @timezone VARCHAR(500)
	, @RefreshProcs BIT = 0
	, @PT1Schema VARCHAR(500)
	, @MigrationProcessStatusTable VARCHAR(500)
	, @MigrationConfigTable VARCHAR(500)

AS
	BEGIN
		SELECT
			  @PrevDatabase = NULLIF(@PrevDatabase, '')
			, @FVPreviousPrefix = NULLIF(@FVPreviousPrefix, '')
		
		SELECT 
			  @Database = REPLACE(REPLACE(@Database, '[', ''), ']', '')
			, @PrevDatabase = REPLACE(REPLACE(@PrevDatabase, '[', ''), ']', '')
		
		DECLARE 
			  @DatabaseBrackets VARCHAR(500) = '[' + @Database + ']'
			, @PrevDatabaseBrackets VARCHAR(500) = '[' + @PrevDatabase + ']'
			, @SQL VARCHAR(MAX) = ''
			, @SQLn NVARCHAR(MAX) = N''
			, @SQLWrapper NVARCHAR(MAX) = N''
			, @NewLine CHAR(2) = CHAR(13) + CHAR(10)
			, @ProcName	VARCHAR(200) = OBJECT_NAME(@@PROCID)
			, @StepName	VARCHAR(100) = 'Generate Legacy SP Mapping for ' + @Database
			, @SubStepName VARCHAR(250) = ''
			, @ErrorMsg NVARCHAR(2048) = N''
			, @ErrorCode INT = 0
			, @EmptyString VARCHAR(10) = ''
			, @True BIT = 1
			, @False BIT = 0
			, @LegacySchema VARCHAR(100) = @LegacyDbType
			, @LegacyDBID BIGINT 
			, @LegacyOrgID BIGINT 
			, @LegacyTempSPMapTableName VARCHAR(MAX) = 'TempSPMap_' + @FVProductionPrefix
			, @TempSQLInsertTable VARCHAR(MAX) = 'TempSQLInsert_' + @FVProductionPrefix
			, @ExecutionOrderTable VARCHAR(1000) = 'LegacySPExecutionOrder'
		
		/*Check for legacy db record in Legacy_Database*/
		BEGIN
			SET @ErrorMsg = @ProcName + ' Failed to find a legacy DB record in [' + @ExecutionDB + '].[dbo].[Legacy_Database].  Please check spelling of Legacy DB name and that a record exists for this legacy system.'
			SELECT @LegacyDbType
			SET @LegacyDBID = (SELECT TOP 1 lg_db_id FROM [dbo].[Legacy_Database] WHERE lg_db_schemaname = @LegacyDbType)

			IF @LegacyDBID IS NULL
				BEGIN
					RAISERROR(@ErrorMsg,16,1);
				END
		END

		/*Check for active Organization in Filevine_Organization*/
		BEGIN
			SET @ErrorMsg = @ProcName + ' Failed to find an active Organization in [' + @ExecutionDB + '].[dbo].[Filevine_Organization].  Please check spelling of Legacy DB name and that a record exists for this legacy system.'

			SET @LegacyOrgID = (SELECT TOP 1 OrgID FROM [dbo].[Filevine_Organization] WHERE CONVERT(VARCHAR, OrgID) = SUBSTRING(@Database, 1, CHARINDEX('_', @Database)- 1))
		
			/*
				BP
				setting this to be the parameter that was passed to the SP.
				This is in case the target DB does not have an org ID in it, i.e. a sandbox db.
				This should only be the case when Testing in a sandbox
			*/
			IF @Database LIKE 'Sandbox_%'
				BEGIN
					SET @LegacyOrgID = @OrgID
				END
				
			IF @LegacyOrgID IS NULL
				BEGIN
					RAISERROR(@ErrorMsg,16,1);
				END

			IF @LegacyOrgID IS NULL
					BEGIN
						PRINT 
							'Insert OrgID for database: ' + @Database
				
						INSERT INTO	
							[dbo].[Filevine_Organization]
							(
								  [OrgID]
								, [OrgName]
								, [InsertDate] 
								, [lg_db_id]
								, [SpecialNotes]
							)
					
						SELECT
							  SUBSTRING(@Database, 1, CHARINDEX('_', @Database)- 1)
							, REPLACE(@Database, SUBSTRING(@Database, 1, CHARINDEX('_', @Database)), '')
							, GETDATE()
							, @LegacyDBID
							, 'Inserted thru FullMigration SP'
					END
		END

		/*reset error msg*/
		SET @ErrorMSG = NULL

		DECLARE
			  @LegacyUse VARCHAR(1000) = 'USE ' + @DatabaseBrackets
			, @WorkingUse VARCHAR(1000) = 'USE ' + @ExecutionDB

		BEGIN
			/*map out Existing SP's for generated Ref/Stage tables*/
			BEGIN
				/*regenerate temp sp map table*/
				SET @SQLn = @LegacyUse + 
					'
						IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @LegacyTempSPMapTableName + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
							BEGIN
								DROP TABLE [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + ']
							END

					'

				BEGIN
					SET @SubStepName = 'Drop table ' + @LegacyTempSPMapTableName

					SET @SQLWrapper = @WorkingUse + 
						'
							EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
								  @SQLCode = @SQLWrapper 
								, @DatabaseBrackets = @DatabaseBrackets
								, @ExecutionDB = @ExecutionDB
								, @ProcName = @ProcName
								, @StepName = @StepName
								, @SubStepName = @SubStepName
								, @DebugFlag = @DebugFlag
								, @PT1Schema = @PT1Schema
								, @MigrationProcessStatusTable = @MigrationProcessStatusTable
						'

					EXEC sp_executesql
						  @SQLWrapper
						, N'@SQLWrapper VARCHAR(MAX)
						  , @DatabaseBrackets VARCHAR(1000)
						  , @ExecutionDB VARCHAR(1000)
						  , @ProcName VARCHAR(1000)
						  , @StepName VARCHAR(1000)
						  , @SubStepName VARCHAR(1000)
						  , @DebugFlag BIT
						  , @PT1Schema VARCHAR(1000)
						  , @MigrationProcessStatusTable VARCHAR(1000)'
						, @SQLWrapper = @SQLn
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				END

				/*Create the table*/
				SET @SQLn = @LegacyUse +
					'		
						CREATE TABLE 
							[' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + ']
								(
									  ID INT IDENTITY(1,1)
									, LegacyDBID BIGINT
									, LegacySPID BIGINT
									, ImportCategoryID BIGINT
									, TemplateCategoryID BIGINT
									, LegacySchema VARCHAR(MAX)
									, LegacySPName VARCHAR(MAX)
									, LegacyOrgID BIGINT
									, FVProdPrefix VARCHAR(MAX)
									, TableName VARCHAR(MAX)
									, SynonymName VARCHAR(MAX)
									, TableRank BIGINT
									, TableSPTypeName VARCHAR(MAX)
									, TemplateType VARCHAR(MAX)
									, TableSPType VARCHAR(MAX)		
									, DestinationFieldName VARCHAR(MAX)
									, DestinationOrdPos VARCHAR(MAX)
									, DestinationDataType VARCHAR(MAX)
									, ColumnAlias VARCHAR(MAX)
									, FromTable VARCHAR(MAX)
									, FromAlias VARCHAR(MAX)
									, JoinDB VARCHAR(MAX)
									, JoinSchema VARCHAR(MAX)
									, JoinTabs VARCHAR(MAX)
									, JoinTypes VARCHAR(MAX)
									, LegacyOverride VARCHAR(MAX)
									, LegacyAutoScript VARCHAR(MAX)
									, IsNullable BIT							
								)

						INSERT INTO
							[' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + ']
							(
								  LegacyDBID
								, LegacySPID
								, ImportCategoryID
								, TemplateCategoryID
								, LegacySchema
								, LegacySPName
								, LegacyOrgID
								, FVProdPrefix
								, TableName
								, SynonymName
								, TableRank
								, TableSPTypeName
								, TemplateType
								, TableSPType  
								, DestinationFieldName
								, DestinationOrdPos
								, DestinationDataType
								, ColumnAlias
								, FromTable
								, FromAlias
								, JoinDB
								, JoinSchema
								, JoinTabs
								, JoinTypes
								, LegacyOverride
								, LegacyAutoScript
								, IsNullable
							)
						SELECT DISTINCT
							  a.[LegacyDBID] [LegacyDBID]
							, CASE 
								WHEN lspRef.LegacySPID IS NOT NULL 
								THEN lspRef.LegacySPID         

								WHEN lspStg.LegacySPID IS NOT NULL 
								THEN lspStg.LegacySPID 
							  END [LegacySPID] 
					' + CASE
							WHEN @UseGenericTemplate = @True
							THEN 
					'		, autoScr.fm_category_id [ImportCategoryID]
							, autoScr.fm_project_template_id [TemplateCategoryID]
					'
							ELSE
					'		, cat.fm_category_id [ImportCategoryID]
							, temp.ID [TemplateCategoryID]
					
					'
						END +
					'
							, ''' + @LegacyDbType + ''' [LegacySchema]
							, CASE 
								WHEN lspRef.LegacySPName IS NOT NULL 
								THEN lspRef.LegacySPName         

								WHEN lspStg.LegacySPName IS NOT NULL 
								THEN lspStg.LegacySPName 
							  END [LegacySPName]
							, ' + CONVERT(VARCHAR, @LegacyOrgID) + ' [LegacyOrgID]
							, ''' + @FVProductionPrefix + ''' [FVProdPrefix]
							, a.[TableName] [TableName]
							, mc.SynonymName [SynonymName]
							, DENSE_RANK() OVER(ORDER BY TableName) [TableRank]
							, a.[TableSPTypeName] [TableSPTypeName]
							, a.[TemplateType] [TemplateType]
							, a.[TableSPType] [TableSPType]
							, a.[DestinationFieldName] [DestinationFieldName]         
							, a.[DestinationOrdPos] [DestinationOrdPos]         
							, a.[DestinationDataType] [DestinationDataType]         
							, a.[ColumnAlias] [ColumnAlias] 
							, a.[FromTable] [FromTable]
							, a.[FromAlias] [FromAlias]
							, a.[JoinDB] [JoinDB]         
							, a.[JoinSchema] [JoinSchema]         
							, a.[JoinTabs]  [JoinTabs]         
							, a.[JoinTypes]  [JoinTypes]         
							, a.[LegacyOverride]  [LegacyOverride]  
					' + CASE
							WHEN @UseGenericTemplate = @True
							THEN 
					'		, CASE 
								WHEN autoScr.script_code IS NOT NULL
								THEN autoScr.script_code
							  END [LegacyAutoScript]
					'
							ELSE 
					'		, Null [LegacyAutoScript]
					'
						END +
					'       
							, a.[IsNullable] [IsNullable] 
						FROM
							(
								SELECT DISTINCT
									  ' + CONVERT(VARCHAR, @LegacyDBID) + ' [LegacyDBID]
									, Table_Name [TableName]
									, SUBSTRING(Table_Name, LEN(Table_Name) - CHARINDEX(''_'', REVERSE(Table_Name), 1) + 2, LEN(Table_Name))  [TableSPTypeName]
									, ISNULL(NULLIF(SUBSTRING(Table_Name, [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 3), CASE WHEN [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 4) - [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 3) + 1 < 0 THEN 0 ELSE [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 4) - [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 3) + 1 END) , '''') , ''ALL'') [TemplateType]
									, CASE             
										WHEN Table_Name LIKE ''[_][_]FV[_]%''            
										THEN ''Reference''                     
				
										ELSE ''Staging''
									  END [TableSPType] 
									, COLUMN_NAME [DestinationFieldName]         
									, ORDINAL_POSITION [DestinationOrdPos]         
									, CASE
										WHEN DATA_TYPE IN (''VARCHAR'', ''NVARCHAR'', ''CHAR'', ''NCHAR'')
										THEN DATA_TYPE + 
											CASE 
												WHEN CHARACTER_MAXIMUM_LENGTH = -1 
												THEN ''(MAX)''
						
												ELSE ''('' + ISNULL(CONVERT(VARCHAR, CHARACTER_MAXIMUM_LENGTH), ''50'') + '')''
											END

										WHEN DATA_TYPE IN (''DECIMAL'', ''NUMERIC'')
										THEN DATA_TYPE + ''('' + CONVERT(VARCHAR, NUMERIC_PRECISION) + '','' + CONVERT(VARCHAR, NUMERIC_SCALE) + '')''
				
										WHEN DATA_TYPE IN (''BIGINT'', ''INT'', ''BIT'',''DATETIME'', ''DATE'')
										THEN DATA_TYPE
									  END [DestinationDataType]         
									, COLUMN_NAME [ColumnAlias] 
									, CASE 
										WHEN Table_Name NOT LIKE ''[_][_]FV[_]%''            
										THEN ''__FV_ClientCaseMap''
									  END [FromTable]
									, CASE 
										WHEN Table_Name NOT LIKE ''[_][_]FV[_]%''            
										THEN ''ccm''
									  END [FromAlias]
									, NULL [JoinDB]         
									, NULL [JoinSchema]         
									, NULL [JoinTabs]         
									, NULL [JoinTypes]         
									, CASE
										WHEN COLUMN_NAME IN (''__ID'')
										THEN ''0''

										WHEN COLUMN_NAME IN (''__ImportStatus'')
										THEN ''40''

										WHEN COLUMN_NAME IN (''__ImportStatusDate'')
										THEN ''GETDATE()''

										WHEN COLUMN_NAME IN (''ProjectExternalID'')
										THEN CASE WHEN Table_Name NOT LIKE ''[_][_]FV[_]%'' THEN ''ccm.'' ELSE '''' END + ''ProjectExternalID''

										WHEN COLUMN_NAME IN (''ContactExternalID'')
										THEN CASE WHEN Table_Name NOT LIKE ''[_][_]FV[_]%'' THEN ''ccm.'' ELSE '''' END + ''ContactExternalID''

										WHEN COLUMN_NAME IN (''Username'', ''Author'')
										THEN ''''''datamigrationteam''''''
									  END [LegacyOverride]  
									, NULL [LegacyAutoScript]       
									, CASE 
										WHEN IS_NULLABLE = ''YES''
										THEN 1
				
										WHEN IS_NULLABLE = ''NO''
										THEN 0
									  END [IsNullable]    
								FROM
									' + @DatabaseBrackets + '.INFORMATION_SCHEMA.COLUMNS t
								WHERE
									(
											t.TABLE_NAME LIKE ''' + @FVProductionPrefix + '%''
										OR	t.TABLE_NAME LIKE ''[_][_]FV[_]%''
									)
									AND t.TABLE_NAME NOT LIKE ''%QATab%''
									AND TABLE_SCHEMA NOT IN (''baseimport'')
							) a
								LEFT JOIN [' + @ExecutionDB + '].[dbo].[LegacySP] lspREF           
									ON SUBSTRING(lspREF.LegacySPName, LEN(lspREF.LegacySPName) - CHARINDEX(''_'', REVERSE(lspREF.LegacySPName), 1) + 2, LEN(lspREF.LegacySPName)) = a.TableSPTypeName
									AND lspRef.LegacySPName LIKE ''%reference%''
									AND a.TableSPType = ''reference''
									AND lspREF.[Active] = ' + CONVERT(VARCHAR, @True) + '
								LEFT JOIN [' + @ExecutionDB + '].[dbo].[LegacySP] lspStg           
									ON SUBSTRING(lspStg.LegacySPName, LEN(lspStg.LegacySPName) - CHARINDEX(''_'', REVERSE(lspStg.LegacySPName), 1) + 2, LEN(lspStg.LegacySPName)) = a.TableSPTypeName  
									AND lspstg.LegacySPName LIKE ''%staging%''
									AND a.TableSPType = ''staging''
									AND lspStg.[Active] = ' + CONVERT(VARCHAR, @True) + '
					' + CASE
							WHEN @UseGenericTemplate = @True
							THEN 
					'
								OUTER APPLY 
									(
										SELECT TOP 1
											  lg_db_id
											, lg_sp_id
											, ascr.fm_category_ID
											, fm_project_template_id
											, REPLACE(REPLACE(REPLACE(script_code, ''###DBNAME###'', ''[' + @Database + ']''), ''###PREFIX###'', ''' + @FVProductionPrefix + '''), ''###TIMEZONE###'', ''''''' + @timezone + ''''''') script_code
											, Active
										FROM
											[' + @ExecutionDB + '].[dbo].[vwLegacyMasterAutoScript] ascr
												LEFT JOIN [' + @ExecutionDB + '].[dbo].[FilevineMigration_Master_ImportCategory] mic
													ON mic.fm_category_id = ascr.fm_category_id
												LEFT JOIN [' + @ExecutionDB + '].[dbo].[FilevineMigration_Master_ProjectTemplate] mpt
													ON mpt.id = ascr.fm_project_template_id
										WHERE
												ascr.lg_db_ID = a.[LegacyDBID]
											AND ascr.active = 1
											AND ascr.lg_sp_id = 
												CASE 
													WHEN lspRef.LegacySPID IS NOT NULL 
													THEN lspRef.LegacySPID

													WHEN lspStg.LegacySPID IS NOT NULL 
													THEN lspStg.LegacySPID
												END 
									) autoscr
					'
							ELSE 
					'
								OUTER APPLY
								(
									SELECT TOP 1
										*
									FROM
										[' + @ExecutionDB + '].[dbo].[FilevineMigration_Master_ProjectTemplate] mpt
									WHERE
										ImportTableMask = templatetype
								) Temp 
							OUTER APPLY
								(
									SELECT TOP 1
										*
									FROM
										[' + @ExecutionDB + '].[dbo].[FilevineMigration_Master_ImportCategory] mit
									WHERE
										mit.Filevine_ImportCategory = tablesptypename
								) cat    
					'
						  END +
					'
							LEFT JOIN [' + @PT1Schema + '].[' + @MigrationConfigTable + '] mc
								ON mc.NewStagingTableName = a.[TableName]
								AND mc.column_name = a.[DestinationFieldName]
						ORDER BY
							  a.TableSPType
							, a.TableName
					' 
					+ CASE WHEN @DebugFlag = @True THEN ' SELECT * FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + ']' ELSE '' END
	
				BEGIN
					SET @SubStepName = 'Create Table ' + @LegacyTempSPMapTableName
					
					SET @SQLWrapper = @WorkingUse + 
						'
							EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
								  @SQLCode = @SQLWrapper 
								, @DatabaseBrackets = @DatabaseBrackets
								, @ExecutionDB = @ExecutionDB
								, @ProcName = @ProcName
								, @StepName = @StepName
								, @SubStepName = @SubStepName
								, @DebugFlag = @DebugFlag
								, @PT1Schema = @PT1Schema
								, @MigrationProcessStatusTable = @MigrationProcessStatusTable
						'

					EXEC sp_executesql
						  @SQLWrapper
						, N'@SQLWrapper VARCHAR(MAX)
						  , @DatabaseBrackets VARCHAR(1000)
						  , @ExecutionDB VARCHAR(1000)
						  , @ProcName VARCHAR(1000)
						  , @StepName VARCHAR(1000)
						  , @SubStepName VARCHAR(1000)
						  , @DebugFlag BIT
						  , @PT1Schema VARCHAR(1000)
						  , @MigrationProcessStatusTable VARCHAR(1000)'
						, @SQLWrapper = @SQLn
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				END
			END

			/*Loop through Temp Map and Insert mapping*/
			BEGIN
				SET @SQLn = @LegacyUse + 
					'
						DECLARE
							  @Counter INT = 1
							, @MaxID INT = (SELECT MAX(TableRank) FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '])
						
						WHILE @Counter <= @MaxID
							BEGIN
								DECLARE
									  @LoopLegacyDBID BIGINT = ' + CONVERT(VARCHAR, @LegacyDBID) + '
									, @LoopLegacySPID BIGINT = (SELECT TOP 1 LegacySPID FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopLegacySchema VARCHAR(MAX) = (SELECT TOP 1 LegacySchema FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopLegacySPName VARCHAR(MAX) = (SELECT TOP 1 LegacySPName FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopSynonymName VARCHAR(MAX) = (SELECT TOP 1 SynonymName FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopLegacyORGID BIGINT = (SELECT TOP 1 LegacyORGID FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopFVProdPrefix VARCHAR(MAX) = (SELECT TOP 1 FVProdPrefix FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopPreviousPrefix VARCHAR(MAX) = NULLIF(''' + ISNULL(@FVPreviousPrefix, '') + ''', '''')
									, @LoopPreviousDB VARCHAR(MAX) = NULLIF(''' + ISNULL(@PrevDatabase, '') + ''', '''')
									, @LoopTableName VARCHAR(MAX) = (SELECT TOP 1 TableName FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopTableSPType VARCHAR(MAX) = (SELECT TOP 1 tablesptype FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopTableSPTypeName VARCHAR(MAX) = (SELECT TOP 1 tablesptypename FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopLegacyAutoScript VARCHAR(MAX) = (SELECT TOP 1 LegacyAutoScript FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopTimezone VARCHAR(MAX) = ''' + @timezone + '''
									, @SQL VARCHAR(MAX)
									, @SQLn NVARCHAR(MAX)
									, @SQLWrapper NVARCHAR(MAX)
									, @SubStepName VARCHAR(500) = ''''
									, @WorkingUse VARCHAR(100) = ''' + @WorkingUse + '''
									, @LegacyUse VARCHAR(1000) = ''' + @LegacyUse + '''
									, @DatabaseBrackets VARCHAR(1000) = ''' + @DatabaseBrackets + '''
									, @ExecutionDB VARCHAR(1000) = ''' + @ExecutionDB + '''
									, @ProcName VARCHAR(1000) = ''' + @ProcName + '''
									, @StepName VARCHAR(1000) = ''' + @StepName + '''
									, @DebugFlag BIT = ''' + CONVERT(VARCHAR, @DebugFlag) + '''
									, @PT1Schema VARCHAR(1000) = ''' + @PT1Schema + '''
									, @MigrationProcessStatusTable VARCHAR(1000) = ''' + @MigrationProcessStatusTable + '''
								
								DECLARE
									@LoopExecutionOrder INT = 
										(
											SELECT
												LMAS.ExecutionOrder
											FROM [' + @ExecutionDB + '].[dbo].[Legacy_Master_Auto_Script] AS LMAS
											WHERE LMAS.lg_db_id = @LoopLegacyDBID
												AND LMAS.lg_sp_id = @LoopLegacySPID
										);

								IF @LoopExecutionOrder IS NULL
									BEGIN
										SET @LoopExecutionOrder =
											CASE
												 WHEN @LoopLegacySPName IN(''usp_Insert_Reference_PhaseMap'')
													 THEN 100
												 WHEN @LoopLegacySPName IN(''usp_insert_reference_StaffContacts'',''usp_insert_reference_Usernames'')
													 THEN 200
												 WHEN @LoopLegacySPName IN(''usp_insert_reference_ProjectTemplateMap'')
													 THEN 300
												 WHEN @LoopLegacySPName IN(''usp_insert_reference_ClientCaseMap'')
													 THEN 400
												 WHEN @LoopLegacySPName IN(''usp_insert_staging_NewContacts'',''usp_insert_staging_Contacts'',''usp_insert_staging_ContactInfo'')
													 THEN 500
												 WHEN @LoopLegacySPName IN(''usp_insert_staging_NewProjects'',''usp_insert_staging_Projects'')
													 THEN 600
												 WHEN @LoopLegacySPName IN(''usp_insert_reference_Documents'')
													 THEN 700
												 WHEN @LoopLegacySPName IN(''usp_insert_staging_NewCalendarEvent'',''usp_insert_staging_NewCalendarEvents'',''usp_insert_staging_NewDeadlines'',''usp_insert_staging_NewMailroomItems'',''usp_insert_staging_NewNotes'',''usp_insert_staging_NewProjectContacts'',''usp_insert_staging_NewProjectPermissions'',''usp_insert_staging_CalendarEvent'',''usp_insert_staging_CalendarEvents'',''usp_insert_staging_Deadlines'',''usp_insert_staging_MailroomItems'',''usp_insert_staging_Notes'',''usp_insert_staging_ProjectContacts'',''usp_insert_staging_ProjectPermissions'')
													 THEN 800
												 WHEN @LoopLegacySPName IN(''usp_insert_staging_NewDocuments'',''usp_insert_staging_Documents'')
													 THEN 9999
												 ELSE 1000
											 END
									END;
					' +
					
					/*If no matching SP is found, create new SP record and map it*/
					'
								IF @LoopLegacySPID IS NULL 
									BEGIN
										SET @LoopLegacySPName = ''usp_insert_'' + LOWER(@LoopTableSPType) + ''_'' + @LoopTableSPTypeName

										IF NOT EXISTS
											(
												SELECT 
													1 
												FROM 
													[' + @ExecutionDB + '].[dbo].[LegacySP] 
												WHERE 
													LegacySPName = @LoopLegacySPName
											)
											BEGIN
												INSERT INTO
													[' + @ExecutionDB + '].[dbo].[LegacySP]
													(
														  LegacySPName
													)
												SELECT
													@LoopLegacySPName
											END

										SET @LoopLegacySPID = (SELECT MAX(LegacySPID) FROM [' + @ExecutionDB + '].dbo.LegacySP WHERE LegacySPName = @LoopLegacySPName)
									END
					' +

					/*If no mapping is found, create it*/
					'

								IF NOT EXISTS
									(
										SELECT 
											1 
										FROM 
											' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
										WHERE 
												LegacyDBID = @LoopLegacyDBID
											AND LegacySPID = @LoopLegacySPID
											AND OrgID = @LoopLegacyOrgID
											AND FvProdPrefix = @LoopFVProdPrefix
									)
									BEGIN
										IF EXISTS
											(
												SELECT 
													1 
												FROM 
													' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
												WHERE 
														LegacyDBID = @LoopLegacyDBID
													AND LegacySPID = @LoopLegacySPID
													AND OrgID = @LoopLegacyOrgID
													AND FvProdPrefix = @LoopPreviousPrefix
					' + CASE 
							WHEN NULLIF(@PrevDatabaseBrackets, '') IS NOT NULL 
							THEN '
												UNION
												SELECT 
													1 
												FROM 
													' + @PrevDatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
												WHERE 
														LegacyDBID = @LoopLegacyDBID
													AND LegacySPID = @LoopLegacySPID
													AND OrgID = @LoopLegacyOrgID
													AND FvProdPrefix = @LoopPreviousPrefix
								 '
							ELSE ''
						END +
					'
											)
											BEGIN
												INSERT INTO
													' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
													(
														  [LegacyDBID]
														, [LegacySPID]
														, [OrgID]
														, [FVProdPrefix]
														, [ExecutionOrder]
														, [Active]
													)
												SELECT DISTINCT
													  [LegacyDBID]
													, [LegacySPID]
													, [OrgID]
													, [FVProdPrefix]
													, [ExecutionOrder]
													, [Active]
												FROM
													(
														SELECT
															  [LegacyDBID] [LegacyDBID]
															, [LegacySPID] [LegacySPID]
															, [OrgID] [OrgID]
															, @LoopFVProdPrefix [FVProdPrefix]
															, [ExecutionOrder] [ExecutionOrder]
															, [Active] [Active]
														FROM
															' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
														WHERE
																[LegacyDBID] = @LoopLegacyDBID 
															AND [LegacySPID] = @LoopLegacySPID  
															AND	[FVProdPrefix] = @LoopPreviousPrefix
					' + CASE 
							WHEN NULLIF(@PrevDatabaseBrackets, '') IS NOT NULL 
							THEN '
														UNION
														SELECT
															  [LegacyDBID] [LegacyDBID]
															, [LegacySPID] [LegacySPID]
															, [OrgID] [OrgID]
															, @LoopFVProdPrefix [FVProdPrefix]
															, [ExecutionOrder] [ExecutionOrder]
															, [Active] [Active]
														FROM
															' + @PrevDatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
														WHERE
																[LegacyDBID] = @LoopLegacyDBID 
															AND [LegacySPID] = @LoopLegacySPID  
															AND	[FVProdPrefix] = @LoopPreviousPrefix
								  '

							ELSE ''
						END + 
					'
													) a
											END
										ELSE
											BEGIN
												INSERT INTO
													' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
													(
														  [LegacyDBID]
														, [LegacySPID]
														, [OrgID]
														, [FVProdPrefix]
														, [ExecutionOrder]
														, [Active]
													)
												SELECT
													  @LoopLegacyDBID [LegacyDBID]
													, @LoopLegacySPID [LegacySPID]
													, @LoopLegacyORGID [OrgID]
													, @LoopFVProdPrefix [FVProdPrefix]
													, @LoopExecutionOrder [ExecutionOrder]
													, 1 [Active]
											END
									END
					' +

					/*If Legacy Schema does not exist in client db, create it*/
					'
								IF NOT EXISTS
									(
										SELECT 
											1 
										FROM 
											' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[SCHEMATA]
										WHERE 
												CATALOG_NAME = ''' + @database + '''
											AND SCHEMA_NAME = @LoopLegacySchema
									)
									BEGIN
										SET @SubStepName = ''Create Legacy Schema '' + @LoopLegacySchema

										SET @SQLN = @LegacyUse + '' EXEC(''''CREATE SCHEMA ['' + @LoopLegacySchema + '']'''')''

										SET @SQLWrapper = @WorkingUse + 
											''
												EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
													  @SQLCode = @SQLWrapper 
													, @DatabaseBrackets = @DatabaseBrackets
													, @ExecutionDB = @ExecutionDB
													, @ProcName = @ProcName
													, @StepName = @StepName
													, @SubStepName = @SubStepName
													, @DebugFlag = @DebugFlag
													, @PT1Schema = @PT1Schema
													, @MigrationProcessStatusTable = @MigrationProcessStatusTable
											''

										EXEC sp_executesql
											  @SQLWrapper
											, N''@SQLWrapper VARCHAR(MAX)
											  , @DatabaseBrackets VARCHAR(1000)
											  , @ExecutionDB VARCHAR(1000)
											  , @ProcName VARCHAR(1000)
											  , @StepName VARCHAR(1000)
											  , @SubStepName VARCHAR(1000)
											  , @DebugFlag BIT
											  , @PT1Schema VARCHAR(1000)
											  , @MigrationProcessStatusTable VARCHAR(1000)''
											, @SQLWrapper = @SQLn
											, @DatabaseBrackets = @DatabaseBrackets
											, @ExecutionDB = @ExecutionDB
											, @ProcName = @ProcName
											, @StepName = @StepName
											, @SubStepName = @SubStepName
											, @DebugFlag = @DebugFlag
											, @PT1Schema = @PT1Schema
											, @MigrationProcessStatusTable = @MigrationProcessStatusTable
									END	
					' +

					/*If refresh flag = 1, then drop the proc and recreate*/
					'
								IF ' + CONVERT(VARCHAR, @RefreshProcs) + ' = 1 
									AND 
										EXISTS
										(
											SELECT 
												1 
											FROM 
												' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout
											WHERE 
													SPECIFIC_SCHEMA = @LoopLegacySchema 
												AND SPECIFIC_NAME = @LoopLegacySPName
										)
									BEGIN
										SET @SQLn = @LegacyUse + 
											''
												DROP PROCEDURE
													['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  '']
											''
										
										BEGIN
											SET @SubStepName = ''REFRESH PROCEDURE ['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  '']''

											SET @SQLWrapper = @WorkingUse + 
												''
													EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
														  @SQLCode = @SQLWrapper 
														, @DatabaseBrackets = @DatabaseBrackets
														, @ExecutionDB = @ExecutionDB
														, @ProcName = @ProcName
														, @StepName = @StepName
														, @SubStepName = @SubStepName
														, @DebugFlag = @DebugFlag
														, @PT1Schema = @PT1Schema
														, @MigrationProcessStatusTable = @MigrationProcessStatusTable
												''

											EXEC sp_executesql
												  @SQLWrapper
												, N''@SQLWrapper VARCHAR(MAX)
												  , @DatabaseBrackets VARCHAR(1000)
												  , @ExecutionDB VARCHAR(1000)
												  , @ProcName VARCHAR(1000)
												  , @StepName VARCHAR(1000)
												  , @SubStepName VARCHAR(1000)
												  , @DebugFlag BIT
												  , @PT1Schema VARCHAR(1000)
												  , @MigrationProcessStatusTable VARCHAR(1000)''
												, @SQLWrapper = @SQLn
												, @DatabaseBrackets = @DatabaseBrackets
												, @ExecutionDB = @ExecutionDB
												, @ProcName = @ProcName
												, @StepName = @StepName
												, @SubStepName = @SubStepName
												, @DebugFlag = @DebugFlag
												, @PT1Schema = @PT1Schema
												, @MigrationProcessStatusTable = @MigrationProcessStatusTable
										END	
									END
					' +

					/*If Procedure does not exist in client db, create it */
					'
								IF NOT EXISTS
									(
										SELECT 
											1 
										FROM 
											' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout
										WHERE 
												SPECIFIC_SCHEMA = @LoopLegacySchema 
											AND SPECIFIC_NAME = @LoopLegacySPName
									)
									BEGIN										
										IF NULLIF(ISNULL(@LoopPreviousDB, ''''), '''') IS NULL
											BEGIN
												DECLARE
													@SQLInsert VARCHAR(MAX) = ''''
												
												SET @SQLn = @workingUse + 
													''
														EXEC ['' + @ExecutionDB + ''].[PT1].[usp_create_Insert_For_SP]
															  @DB = ''''' + @Database + '''''
															, @LegacyTempSPMapTableName = ''''' + @LegacyTempSPMapTableName + '''''
															, @TempSQLInsertTable = ''''' + @TempSQLInsertTable + '''''
															, @SPName = '''''' + @LoopLegacySPName + ''''''
															, @Schema = ''''' + @SchemaName + '''''
															, @DebugFlag = ''''' + CONVERT(VARCHAR, @DebugFlag) + '''''
															, @FVProductionPrefix = ''''' + ISNULL(@FVProductionPrefix, '') + '''''
															, @timezone = ''''' + @timezone + '''''
															, @PT1Schema = ''''' + @PT1Schema + '''''
															, @MigrationProcessStatusTable = ''''' + @MigrationProcessStatusTable + '''''
															, @MigrationConfigTable = ''''' + @MigrationConfigTable + '''''
															, @ExecutionDB = ''''' + @ExecutionDB + '''''
													''

												BEGIN
													SET @SubStepName = ''Create Insert for SP ['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  '']''

													SET @SQLWrapper = @WorkingUse + 
														''
															EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
																  @SQLCode = @SQLWrapper 
																, @DatabaseBrackets = @DatabaseBrackets
																, @ExecutionDB = @ExecutionDB
																, @ProcName = @ProcName
																, @StepName = @StepName
																, @SubStepName = @SubStepName
																, @DebugFlag = @DebugFlag
																, @PT1Schema = @PT1Schema
																, @MigrationProcessStatusTable = @MigrationProcessStatusTable
														''

													EXEC sp_executesql
														  @SQLWrapper
														, N''@SQLWrapper VARCHAR(MAX)
														  , @DatabaseBrackets VARCHAR(1000)
														  , @ExecutionDB VARCHAR(1000)
														  , @ProcName VARCHAR(1000)
														  , @StepName VARCHAR(1000)
														  , @SubStepName VARCHAR(1000)
														  , @DebugFlag BIT
														  , @PT1Schema VARCHAR(1000)
														  , @MigrationProcessStatusTable VARCHAR(1000)''
														, @SQLWrapper = @SQLn
														, @DatabaseBrackets = @DatabaseBrackets
														, @ExecutionDB = @ExecutionDB
														, @ProcName = @ProcName
														, @StepName = @StepName
														, @SubStepName = @SubStepName
														, @DebugFlag = @DebugFlag
														, @PT1Schema = @PT1Schema
														, @MigrationProcessStatusTable = @MigrationProcessStatusTable
												END

												SELECT 
													@SQLInsert = COALESCE(@SQLInsert + SQLInsert, '''') + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
												FROM
													[' + @PT1Schema + '].[' + @TempSQLInsertTable + ']
									
												SET @SQL = CONCAT(
														'' 
CREATE PROCEDURE
	['',@LoopLegacySchema,''].['',@LoopLegacySPName,'']
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN '',
	
	CASE 
		WHEN @LoopLegacyAutoScript IS NOT NULL 
		THEN @loopLegacyAutoScript 
		
		ELSE ''
		SELECT 
			''''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName + ''] has been created in [' + @Database + '] database.  Please review and modifiy the procedure.''''

		'' + ISNULL(NULLIF(@SQLInsert, ''''), ''/*'' + ''Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.'' + ''*/'') 
		END, 
		
		''
	END
														'')
												
												BEGIN TRY
													EXEC (@SQL)
												END TRY
												
												BEGIN CATCH
													SET @SQL = CONCAT(
														'' 
CREATE PROCEDURE
	['',@LoopLegacySchema,''].['',@LoopLegacySPName,'']
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN '',
	
	CASE 
		WHEN @LoopLegacyAutoScript IS NOT NULL 
		THEN ''/*'' + @loopLegacyAutoScript + ''*/''
		
		ELSE ''
		SELECT 
			''''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  ''] has been created in [' + @Database + '] database.  Please review and modifiy the procedure.''''

		'' + ISNULL(''/*'' + @SQLInsert + ''*/'', ''/*'' + ''Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.'' + ''*/'') 
		END,
		
		''
	END
														'')

													EXEC (@SQL)

													DECLARE @Errormsg VARCHAR(MAX) = ''There was a problem creating the script for ['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  ''].  The script will be created, but the code will be commented out.  Please review the stored procedure and troubleshoot manually.''

													SELECT @Errormsg
													
												END CATCH
											END
										ELSE
											BEGIN
												IF EXISTS
												(
													SELECT 
														1 
													FROM 
														' + CASE WHEN ISNULL(NULLIF(@PrevDatabaseBrackets, ''), '') = '' THEN '[INFORMATION_SCHEMA].[Routines] Rout' ELSE @PrevDatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout' END + '
													WHERE 
															SPECIFIC_SCHEMA = @LoopLegacySchema 
														AND SPECIFIC_NAME = @LoopLegacySPName
												)
												AND NOT EXISTS
												(
													SELECT 
														1 
													FROM 
														' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout
													WHERE 
															SPECIFIC_SCHEMA = @LoopLegacySchema 
														AND SPECIFIC_NAME = @LoopLegacySPName
												)
												BEGIN
													DECLARE @SQLCodeClone VARCHAR(MAX) =
														(
															SELECT TOP 1 
																REPLACE(REPLACE([DEFINITION], ''' + ISNULL(@PrevDatabase, '') + ''', ''' + @Database + '''), ''ALTER PROCEDURE'', ''CREATE PROCEDURE'')
															FROM 
																' + CASE WHEN ISNULL(@PrevDatabaseBrackets, '') = '' THEN '[sys].[sql_modules]' ELSE @PrevDatabaseBrackets + '.[sys].[sql_modules]' END + '
															WHERE 
																object_id = (OBJECT_ID(N''' + CASE WHEN ISNULL(@PrevDatabase, '') = '' THEN  ''' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))' ELSE @PrevDatabase + '.' + ''' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))' END + '
														)

													BEGIN TRY
														EXEC (@SQLCodeClone)
													END TRY

													BEGIN CATCH
														SET @SQLCodeClone = 
															(
																SELECT TOP 1 
																	REPLACE(REPLACE([DEFINITION], ''' + ISNULL(@PrevDatabase, '') + ''', ''' + @Database + '''), ''ALTER PROCEDURE'', ''CREATE PROCEDURE'')
																FROM 
																	' + CASE WHEN ISNULL(@PrevDatabaseBrackets, '') = '' THEN '[sys].[sql_modules]' ELSE @PrevDatabaseBrackets + '.[sys].[sql_modules]' END + '
																WHERE 
																	object_id = (OBJECT_ID(N''' + CASE WHEN ISNULL(@PrevDatabase, '') = '' THEN  ''' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))' ELSE @PrevDatabase + '.' + ''' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))' END + '
															)
															+ ''/*'' 
															+ ''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName + ''] failed to clone from the database ' + ISNULL(@PrevDatabaseBrackets, '') + ' .  Please investigate.''
															+ ''*/''
															  
														
														SELECT ''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName + ''] failed to clone from the database ' + ISNULL(@PrevDatabaseBrackets, '') + ' .  Please investigate.''
														
														EXEC (@SQLCodeClone)
													END CATCH
												END
											END
									END
					' +

					/*If SP Exists and looking to previous test, replace the prefix in the existing SP with the new one*/
					'
								IF EXISTS
									(
										SELECT 
											1 
										FROM 
											' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout
										WHERE 
												SPECIFIC_SCHEMA = @LoopLegacySchema 
											AND SPECIFIC_NAME = @LoopLegacySPName
											AND ROUTINE_DEFINITION LIKE ''%'' + REPLACE(@LoopPreviousPrefix, ''_'', ''[_]'') + ''%''
											AND ROUTINE_DEFINITION NOT LIKE ''%'' + REPLACE(@LoopFVProdPrefix, ''_'', ''[_]'') + ''%''
									)
									AND @LoopPreviousPrefix IS NOT NULL
									BEGIN
										DECLARE 
											@SQLCode VARCHAR(MAX) = 
												(
													SELECT TOP 1 
														REPLACE(REPLACE([DEFINITION], ''CREATE PROCEDURE'', ''ALTER PROCEDURE''), @LoopPreviousPrefix, @LoopFVProdPrefix)
													FROM 
														' + @DatabaseBrackets + '.[sys].[sql_modules] 
													WHERE 
														object_id = (OBJECT_ID(N''' + @Database + '.'' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))
												)
										
										BEGIN TRY
											EXEC (@SQLCode)
										END TRY

										BEGIN CATCH
											SELECT 
												  ''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName + ''] failed to alter previous prefix name in existing SP.  Please investigate.''
												, @SQLCode ''altersql''
										END CATCH
									END

								SET @Counter = @Counter + 1					
							END
					'

				BEGIN
					SET @SubStepName = 'Loop through ' + @LegacyTempSPMapTableName + ' and insert mappings'
					
					SET @SQLWrapper = @WorkingUse + 
						'
							EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
								  @SQLCode = @SQLWrapper 
								, @DatabaseBrackets = @DatabaseBrackets
								, @ExecutionDB = @ExecutionDB
								, @ProcName = @ProcName
								, @StepName = @StepName
								, @SubStepName = @SubStepName
								, @DebugFlag = @DebugFlag
								, @PT1Schema = @PT1Schema
								, @MigrationProcessStatusTable = @MigrationProcessStatusTable
						'

					EXEC sp_executesql
						  @SQLWrapper
						, N'@SQLWrapper VARCHAR(MAX)
						  , @DatabaseBrackets VARCHAR(1000)
						  , @ExecutionDB VARCHAR(1000)
						  , @ProcName VARCHAR(1000)
						  , @StepName VARCHAR(1000)
						  , @SubStepName VARCHAR(1000)
						  , @DebugFlag BIT
						  , @PT1Schema VARCHAR(1000)
						  , @MigrationProcessStatusTable VARCHAR(1000)'
						, @SQLWrapper = @SQLn
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				END
			END

			/*Cleanup*/
			BEGIN
				SET @SQL = @LegacyUse + 
					'
						IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @TempSQLInsertTable + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
							BEGIN
								DROP TABLE [' + @PT1Schema + '].[' + @TempSQLInsertTable + ']
							END
					'
					
				EXEC (@SQL)
			END

			
		END
	END
GO
/****** Object:  StoredProcedure [PT1].[usp_create_meta_LegacySPMapping_Original]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [PT1].[usp_create_meta_LegacySPMapping_Original]
	  @DebugFlag BIT = 1  /*1 to output SQL statements; 0 to execute*/	
	, @Database VARCHAR(500)
	, @PrevDatabase VARCHAR(500)
	, @LegacyDbType VARCHAR(500)
	, @OrgID BIGINT 
	, @SchemaName VARCHAR(500)
	, @ExecutionDB VARCHAR(500)
	, @FVProductionPrefix VARCHAR(500)
	, @FVPreviousPrefix VARCHAR(500)
	, @UseGenericTemplate BIT
	, @timezone VARCHAR(500)
	, @RefreshProcs BIT = 0
	, @PT1Schema VARCHAR(500)
	, @MigrationProcessStatusTable VARCHAR(500)
	, @MigrationConfigTable VARCHAR(500)

AS
	BEGIN
		SELECT
			  @PrevDatabase = NULLIF(@PrevDatabase, '')
			, @FVPreviousPrefix = NULLIF(@FVPreviousPrefix, '')
		
		SELECT 
			  @Database = REPLACE(REPLACE(@Database, '[', ''), ']', '')
			, @PrevDatabase = REPLACE(REPLACE(@PrevDatabase, '[', ''), ']', '')
		
		DECLARE 
			  @DatabaseBrackets VARCHAR(500) = '[' + @Database + ']'
			, @PrevDatabaseBrackets VARCHAR(500) = '[' + @PrevDatabase + ']'
			, @SQL VARCHAR(MAX) = ''
			, @SQLn NVARCHAR(MAX) = N''
			, @SQLWrapper NVARCHAR(MAX) = N''
			, @NewLine CHAR(2) = CHAR(13) + CHAR(10)
			, @ProcName	VARCHAR(200) = OBJECT_NAME(@@PROCID)
			, @StepName	VARCHAR(100) = 'Generate Legacy SP Mapping for ' + @Database
			, @SubStepName VARCHAR(250) = ''
			, @ErrorMsg NVARCHAR(2048) = N''
			, @ErrorCode INT = 0
			, @EmptyString VARCHAR(10) = ''
			, @True BIT = 1
			, @False BIT = 0
			, @LegacySchema VARCHAR(100) = @LegacyDbType
			, @LegacyDBID BIGINT 
			, @LegacyOrgID BIGINT 
			, @LegacyTempSPMapTableName VARCHAR(MAX) = 'TempSPMap_' + @FVProductionPrefix
			, @TempSQLInsertTable VARCHAR(MAX) = 'TempSQLInsert_' + @FVProductionPrefix
			, @ExecutionOrderTable VARCHAR(1000) = 'LegacySPExecutionOrder'
		
		/*Check for legacy db record in Legacy_Database*/
		BEGIN
			SET @ErrorMsg = @ProcName + ' Failed to find a legacy DB record in [Filevine_META_TEST].[dbo].[Legacy_Database].  Please check spelling of Legacy DB name and that a record exists for this legacy system.'
			SELECT @LegacyDbType
			SET @LegacyDBID = (SELECT TOP 1 lg_db_id FROM [Filevine_META_TEST].[dbo].[Legacy_Database] WHERE lg_db_schemaname = @LegacyDbType)

			IF @LegacyDBID IS NULL
				BEGIN
					RAISERROR(@ErrorMsg,16,1);
				END
		END

		/*Check for active Organization in Filevine_Organization*/
		BEGIN
			SET @ErrorMsg = @ProcName + ' Failed to find an active Organization in [Filevine_META_TEST].[dbo].[Filevine_Organization].  Please check spelling of Legacy DB name and that a record exists for this legacy system.'

			SET @LegacyOrgID = (SELECT TOP 1 OrgID FROM [Filevine_META_TEST].[dbo].[Filevine_Organization] WHERE CONVERT(VARCHAR, OrgID) = SUBSTRING(@Database, 1, CHARINDEX('_', @Database)- 1))
		
			/*
				BP
				setting this to be the parameter that was passed to the SP.
				This is in case the target DB does not have an org ID in it, i.e. a sandbox db.
				This should only be the case when Testing in a sandbox
			*/
			IF @Database LIKE 'Sandbox_%'
				BEGIN
					SET @LegacyOrgID = @OrgID
				END

			IF @LegacyOrgID IS NULL
				BEGIN
					RAISERROR(@ErrorMsg,16,1);
				END

			IF @LegacyOrgID IS NULL
					BEGIN
						PRINT 
							'Insert OrgID for database: ' + @Database
				
						INSERT INTO	
							[Filevine_META_TEST].[dbo].[Filevine_Organization]
							(
								  [OrgID]
								, [OrgName]
								, [InsertDate] 
								, [lg_db_id]
								, [SpecialNotes]
							)
					
						SELECT
							  SUBSTRING(@Database, 1, CHARINDEX('_', @Database)- 1)
							, REPLACE(@Database, SUBSTRING(@Database, 1, CHARINDEX('_', @Database)), '')
							, GETDATE()
							, @LegacyDBID
							, 'Inserted thru FullMigration SP'
					END
		END

		DECLARE
			  @LegacyUse VARCHAR(1000) = 'USE ' + @DatabaseBrackets
			, @WorkingUse VARCHAR(1000) = 'USE ' + @ExecutionDB

		BEGIN
			/*map out Existing SP's for generated Ref/Stage tables*/
			BEGIN
				/*regenerate temp sp map table*/
				SET @SQLn = @LegacyUse + 
					'
						IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @LegacyTempSPMapTableName + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
							BEGIN
								DROP TABLE [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + ']
							END

					'

				BEGIN
					SET @SubStepName = 'Drop table ' + @LegacyTempSPMapTableName

					SET @SQLWrapper = @WorkingUse + 
						'
							EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
								  @SQLCode = @SQLWrapper 
								, @DatabaseBrackets = @DatabaseBrackets
								, @ExecutionDB = @ExecutionDB
								, @ProcName = @ProcName
								, @StepName = @StepName
								, @SubStepName = @SubStepName
								, @DebugFlag = @DebugFlag
								, @PT1Schema = @PT1Schema
								, @MigrationProcessStatusTable = @MigrationProcessStatusTable
						'

					EXEC sp_executesql
						  @SQLWrapper
						, N'@SQLWrapper VARCHAR(MAX)
						  , @DatabaseBrackets VARCHAR(1000)
						  , @ExecutionDB VARCHAR(1000)
						  , @ProcName VARCHAR(1000)
						  , @StepName VARCHAR(1000)
						  , @SubStepName VARCHAR(1000)
						  , @DebugFlag BIT
						  , @PT1Schema VARCHAR(1000)
						  , @MigrationProcessStatusTable VARCHAR(1000)'
						, @SQLWrapper = @SQLn
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				END

				/*Create the table*/
				SET @SQLn = @LegacyUse +
					'		
						CREATE TABLE 
							[' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + ']
								(
									  ID INT IDENTITY(1,1)
									, LegacyDBID BIGINT
									, LegacySPID BIGINT
									, ImportCategoryID BIGINT
									, TemplateCategoryID BIGINT
									, LegacySchema VARCHAR(MAX)
									, LegacySPName VARCHAR(MAX)
									, LegacyOrgID BIGINT
									, FVProdPrefix VARCHAR(MAX)
									, TableName VARCHAR(MAX)
									, SynonymName VARCHAR(MAX)
									, TableRank BIGINT
									, TableSPTypeName VARCHAR(MAX)
									, TemplateType VARCHAR(MAX)
									, TableSPType VARCHAR(MAX)		
									, DestinationFieldName VARCHAR(MAX)
									, DestinationOrdPos VARCHAR(MAX)
									, DestinationDataType VARCHAR(MAX)
									, ColumnAlias VARCHAR(MAX)
									, FromTable VARCHAR(MAX)
									, FromAlias VARCHAR(MAX)
									, JoinDB VARCHAR(MAX)
									, JoinSchema VARCHAR(MAX)
									, JoinTabs VARCHAR(MAX)
									, JoinTypes VARCHAR(MAX)
									, LegacyOverride VARCHAR(MAX)
									, LegacyAutoScript VARCHAR(MAX)
									, IsNullable BIT							
								)

						INSERT INTO
							[' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + ']
							(
								  LegacyDBID
								, LegacySPID
								, ImportCategoryID
								, TemplateCategoryID
								, LegacySchema
								, LegacySPName
								, LegacyOrgID
								, FVProdPrefix
								, TableName
								, SynonymName
								, TableRank
								, TableSPTypeName
								, TemplateType
								, TableSPType  
								, DestinationFieldName
								, DestinationOrdPos
								, DestinationDataType
								, ColumnAlias
								, FromTable
								, FromAlias
								, JoinDB
								, JoinSchema
								, JoinTabs
								, JoinTypes
								, LegacyOverride
								, LegacyAutoScript
								, IsNullable
							)
						SELECT DISTINCT
							  a.[LegacyDBID] [LegacyDBID]
							, CASE 
								WHEN lspRef.LegacySPID IS NOT NULL 
								THEN lspRef.LegacySPID         

								WHEN lspStg.LegacySPID IS NOT NULL 
								THEN lspStg.LegacySPID 
							  END [LegacySPID] 
					' + CASE
							WHEN @UseGenericTemplate = @True
							THEN 
					'		, autoScr.fm_category_id [ImportCategoryID]
							, autoScr.fm_project_template_id [TemplateCategoryID]
					'
							ELSE
					'		, cat.fm_category_id [ImportCategoryID]
							, temp.ID [TemplateCategoryID]
					
					'
						END +
					'
							, ''' + @LegacyDbType + ''' [LegacySchema]
							, CASE 
								WHEN lspRef.LegacySPName IS NOT NULL 
								THEN lspRef.LegacySPName         

								WHEN lspStg.LegacySPName IS NOT NULL 
								THEN lspStg.LegacySPName 
							  END [LegacySPName]
							, ' + CONVERT(VARCHAR, @LegacyOrgID) + ' [LegacyOrgID]
							, ''' + @FVProductionPrefix + ''' [FVProdPrefix]
							, a.[TableName] [TableName]
							, mc.SynonymName [SynonymName]
							, DENSE_RANK() OVER(ORDER BY TableName) [TableRank]
							, a.[TableSPTypeName] [TableSPTypeName]
							, a.[TemplateType] [TemplateType]
							, a.[TableSPType] [TableSPType]
							, a.[DestinationFieldName] [DestinationFieldName]         
							, a.[DestinationOrdPos] [DestinationOrdPos]         
							, a.[DestinationDataType] [DestinationDataType]         
							, a.[ColumnAlias] [ColumnAlias] 
							, a.[FromTable] [FromTable]
							, a.[FromAlias] [FromAlias]
							, a.[JoinDB] [JoinDB]         
							, a.[JoinSchema] [JoinSchema]         
							, a.[JoinTabs]  [JoinTabs]         
							, a.[JoinTypes]  [JoinTypes]         
							, a.[LegacyOverride]  [LegacyOverride]  
					' + CASE
							WHEN @UseGenericTemplate = @True
							THEN 
					'		, CASE 
								WHEN autoScr.script_code IS NOT NULL
								THEN autoScr.script_code
							  END [LegacyAutoScript]
					'
							ELSE 
					'		, Null [LegacyAutoScript]
					'
						END +
					'       
							, a.[IsNullable] [IsNullable] 
						FROM
							(
								SELECT DISTINCT
									  ' + CONVERT(VARCHAR, @LegacyDBID) + ' [LegacyDBID]
									, Table_Name [TableName]
									, SUBSTRING(Table_Name, LEN(Table_Name) - CHARINDEX(''_'', REVERSE(Table_Name), 1) + 2, LEN(Table_Name))  [TableSPTypeName]
									, ISNULL(NULLIF(SUBSTRING(Table_Name, Filevine_META_TEST.dbo.udf_findNthOccurance(''_'', Table_Name, 3), CASE WHEN Filevine_META_TEST.dbo.udf_findNthOccurance(''_'', Table_Name, 4) - Filevine_META_TEST.dbo.udf_findNthOccurance(''_'', Table_Name, 3) + 1 < 0 THEN 0 ELSE Filevine_META_TEST.dbo.udf_findNthOccurance(''_'', Table_Name, 4) - Filevine_META_TEST.dbo.udf_findNthOccurance(''_'', Table_Name, 3) + 1 END) , '''') , ''ALL'') [TemplateType]
									, CASE             
										WHEN Table_Name LIKE ''[_][_]FV[_]%''            
										THEN ''Reference''                     
				
										ELSE ''Staging''
									  END [TableSPType] 
									, COLUMN_NAME [DestinationFieldName]         
									, ORDINAL_POSITION [DestinationOrdPos]         
									, CASE
										WHEN DATA_TYPE IN (''VARCHAR'', ''NVARCHAR'', ''CHAR'', ''NCHAR'')
										THEN DATA_TYPE + 
											CASE 
												WHEN CHARACTER_MAXIMUM_LENGTH = -1 
												THEN ''(MAX)''
						
												ELSE ''('' + ISNULL(CONVERT(VARCHAR, CHARACTER_MAXIMUM_LENGTH), ''50'') + '')''
											END

										WHEN DATA_TYPE IN (''DECIMAL'', ''NUMERIC'')
										THEN DATA_TYPE + ''('' + CONVERT(VARCHAR, NUMERIC_PRECISION) + '','' + CONVERT(VARCHAR, NUMERIC_SCALE) + '')''
				
										WHEN DATA_TYPE IN (''BIGINT'', ''INT'', ''BIT'',''DATETIME'', ''DATE'')
										THEN DATA_TYPE
									  END [DestinationDataType]         
									, COLUMN_NAME [ColumnAlias] 
									, CASE 
										WHEN Table_Name NOT LIKE ''[_][_]FV[_]%''            
										THEN ''__FV_ClientCaseMap''
									  END [FromTable]
									, CASE 
										WHEN Table_Name NOT LIKE ''[_][_]FV[_]%''            
										THEN ''ccm''
									  END [FromAlias]
									, NULL [JoinDB]         
									, NULL [JoinSchema]         
									, NULL [JoinTabs]         
									, NULL [JoinTypes]         
									, CASE
										WHEN COLUMN_NAME IN (''__ID'')
										THEN ''0''

										WHEN COLUMN_NAME IN (''__ImportStatus'')
										THEN ''40''

										WHEN COLUMN_NAME IN (''__ImportStatusDate'')
										THEN ''GETDATE()''

										WHEN COLUMN_NAME IN (''ProjectExternalID'')
										THEN CASE WHEN Table_Name NOT LIKE ''[_][_]FV[_]%'' THEN ''ccm.'' ELSE '''' END + ''ProjectExternalID''

										WHEN COLUMN_NAME IN (''ContactExternalID'')
										THEN CASE WHEN Table_Name NOT LIKE ''[_][_]FV[_]%'' THEN ''ccm.'' ELSE '''' END + ''ContactExternalID''

										WHEN COLUMN_NAME IN (''Username'', ''Author'')
										THEN ''''''datamigrationteam''''''
									  END [LegacyOverride]  
									, NULL [LegacyAutoScript]       
									, CASE 
										WHEN IS_NULLABLE = ''YES''
										THEN 1
				
										WHEN IS_NULLABLE = ''NO''
										THEN 0
									  END [IsNullable]    
								FROM
									' + @DatabaseBrackets + '.INFORMATION_SCHEMA.COLUMNS t
								WHERE
									(
											t.TABLE_NAME LIKE ''' + @FVProductionPrefix + '%''
										OR	t.TABLE_NAME LIKE ''[_][_]FV[_]%''
									)
									AND t.TABLE_NAME NOT LIKE ''%QATab%''
									AND TABLE_SCHEMA NOT IN (''baseimport'')
							) a
								LEFT JOIN [Filevine_META_TEST].[dbo].[LegacySP] lspREF           
									ON SUBSTRING(lspREF.LegacySPName, LEN(lspREF.LegacySPName) - CHARINDEX(''_'', REVERSE(lspREF.LegacySPName), 1) + 2, LEN(lspREF.LegacySPName)) = a.TableSPTypeName
									AND lspRef.LegacySPName LIKE ''%reference%''
									AND a.TableSPType = ''reference''
									AND lspREF.[Active] = ' + CONVERT(VARCHAR, @True) + '
								LEFT JOIN [Filevine_META_TEST].[dbo].[LegacySP] lspStg           
									ON SUBSTRING(lspStg.LegacySPName, LEN(lspStg.LegacySPName) - CHARINDEX(''_'', REVERSE(lspStg.LegacySPName), 1) + 2, LEN(lspStg.LegacySPName)) = a.TableSPTypeName  
									AND lspstg.LegacySPName LIKE ''%staging%''
									AND a.TableSPType = ''staging''
									AND lspStg.[Active] = ' + CONVERT(VARCHAR, @True) + '
					' + CASE
							WHEN @UseGenericTemplate = @True
							THEN 
					'
								OUTER APPLY 
									(
										SELECT TOP 1
											  lg_db_id
											, lg_sp_id
											, ascr.fm_category_ID
											, fm_project_template_id
											, REPLACE(REPLACE(REPLACE(script_code, ''###DBNAME###'', ''[' + @Database + ']''), ''###PREFIX###'', ''' + @FVProductionPrefix + '''), ''###TIMEZONE###'', ''''''' + @timezone + ''''''') script_code
											, Active
										FROM
											[Filevine_META_TEST].[dbo].[vwLegacyMasterAutoScript] ascr
												LEFT JOIN [Filevine_META_TEST].[dbo].[FilevineMigration_Master_ImportCategory] mic
													ON mic.fm_category_id = ascr.fm_category_id
												LEFT JOIN [Filevine_META_TEST].[dbo].[FilevineMigration_Master_ProjectTemplate] mpt
													ON mpt.id = ascr.fm_project_template_id
										WHERE
												ascr.lg_db_ID = a.[LegacyDBID]
											AND ascr.active = 1
											AND ascr.lg_sp_id = 
												CASE 
													WHEN lspRef.LegacySPID IS NOT NULL 
													THEN lspRef.LegacySPID

													WHEN lspStg.LegacySPID IS NOT NULL 
													THEN lspStg.LegacySPID
												END 
									) autoscr
					'
							ELSE 
					'
								OUTER APPLY
								(
									SELECT TOP 1
										*
									FROM
										[Filevine_META_TEST].[dbo].[FilevineMigration_Master_ProjectTemplate] mpt
									WHERE
										ImportTableMask = templatetype
								) Temp 
							OUTER APPLY
								(
									SELECT TOP 1
										*
									FROM
										[Filevine_META_TEST].[dbo].[FilevineMigration_Master_ImportCategory] mit
									WHERE
										mit.Filevine_ImportCategory = tablesptypename
								) cat    
					'
						  END +
					'
							LEFT JOIN [' + @PT1Schema + '].[' + @MigrationConfigTable + '] mc
								ON mc.NewStagingTableName = a.[TableName]
								AND mc.column_name = a.[DestinationFieldName]
						ORDER BY
							  a.TableSPType
							, a.TableName
					' 
					+ CASE WHEN @DebugFlag = @True THEN ' SELECT * FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + ']' ELSE '' END
	
				BEGIN
					SET @SubStepName = 'Create Table ' + @LegacyTempSPMapTableName
					
					SET @SQLWrapper = @WorkingUse + 
						'
							EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
								  @SQLCode = @SQLWrapper 
								, @DatabaseBrackets = @DatabaseBrackets
								, @ExecutionDB = @ExecutionDB
								, @ProcName = @ProcName
								, @StepName = @StepName
								, @SubStepName = @SubStepName
								, @DebugFlag = @DebugFlag
								, @PT1Schema = @PT1Schema
								, @MigrationProcessStatusTable = @MigrationProcessStatusTable
						'

					EXEC sp_executesql
						  @SQLWrapper
						, N'@SQLWrapper VARCHAR(MAX)
						  , @DatabaseBrackets VARCHAR(1000)
						  , @ExecutionDB VARCHAR(1000)
						  , @ProcName VARCHAR(1000)
						  , @StepName VARCHAR(1000)
						  , @SubStepName VARCHAR(1000)
						  , @DebugFlag BIT
						  , @PT1Schema VARCHAR(1000)
						  , @MigrationProcessStatusTable VARCHAR(1000)'
						, @SQLWrapper = @SQLn
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				END
			END

			/*Loop through Temp Map and Insert mapping*/
			BEGIN
				SET @SQLn = @LegacyUse + 
					'
						DECLARE
							  @Counter INT = 1
							, @MaxID INT = (SELECT MAX(TableRank) FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '])
						
						WHILE @Counter <= @MaxID
							BEGIN
								DECLARE
									  @LoopLegacyDBID BIGINT = ' + CONVERT(VARCHAR, @LegacyDBID) + '
									, @LoopLegacySPID BIGINT = (SELECT TOP 1 LegacySPID FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopLegacySchema VARCHAR(MAX) = (SELECT TOP 1 LegacySchema FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopLegacySPName VARCHAR(MAX) = (SELECT TOP 1 LegacySPName FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopSynonymName VARCHAR(MAX) = (SELECT TOP 1 SynonymName FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopLegacyORGID BIGINT = (SELECT TOP 1 LegacyORGID FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopFVProdPrefix VARCHAR(MAX) = (SELECT TOP 1 FVProdPrefix FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopPreviousPrefix VARCHAR(MAX) = NULLIF(''' + ISNULL(@FVPreviousPrefix, '') + ''', '''')
									, @LoopPreviousDB VARCHAR(MAX) = NULLIF(''' + ISNULL(@PrevDatabase, '') + ''', '''')
									, @LoopTableName VARCHAR(MAX) = (SELECT TOP 1 TableName FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopTableSPType VARCHAR(MAX) = (SELECT TOP 1 tablesptype FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopTableSPTypeName VARCHAR(MAX) = (SELECT TOP 1 tablesptypename FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopLegacyAutoScript VARCHAR(MAX) = (SELECT TOP 1 LegacyAutoScript FROM [' + @PT1Schema + '].[' + @LegacyTempSPMapTableName + '] WHERE TableRank = @Counter)
									, @LoopTimezone VARCHAR(MAX) = ''' + @timezone + '''
									, @SQL VARCHAR(MAX)
									, @SQLn NVARCHAR(MAX)
									, @SQLWrapper NVARCHAR(MAX)
									, @SubStepName VARCHAR(500) = ''''
									, @WorkingUse VARCHAR(100) = ''' + @WorkingUse + '''
									, @LegacyUse VARCHAR(1000) = ''' + @LegacyUse + '''
									, @DatabaseBrackets VARCHAR(1000) = ''' + @DatabaseBrackets + '''
									, @ExecutionDB VARCHAR(1000) = ''' + @ExecutionDB + '''
									, @ProcName VARCHAR(1000) = ''' + @ProcName + '''
									, @StepName VARCHAR(1000) = ''' + @StepName + '''
									, @DebugFlag BIT = ''' + CONVERT(VARCHAR, @DebugFlag) + '''
									, @PT1Schema VARCHAR(1000) = ''' + @PT1Schema + '''
									, @MigrationProcessStatusTable VARCHAR(1000) = ''' + @MigrationProcessStatusTable + '''
								
								DECLARE
									@LoopExecutionOrder INT = 
										(
											SELECT
												LMAS.ExecutionOrder
											FROM [Filevine_META_TEST].[dbo].[Legacy_Master_Auto_Script] AS LMAS
											WHERE LMAS.lg_db_id = @LoopLegacyDBID
												AND LMAS.lg_sp_id = @LoopLegacySPID
												AND LMAS.Active=1
										);

								IF @LoopExecutionOrder IS NULL
									BEGIN
										SET @LoopExecutionOrder =
											CASE
												 WHEN @LoopLegacySPName IN(''usp_Insert_Reference_PhaseMap'')
													 THEN 100
												 WHEN @LoopLegacySPName IN(''usp_insert_reference_StaffContacts'',''usp_insert_reference_Usernames'')
													 THEN 200
												 WHEN @LoopLegacySPName IN(''usp_insert_reference_ProjectTemplateMap'')
													 THEN 300
												 WHEN @LoopLegacySPName IN(''usp_insert_reference_ClientCaseMap'')
													 THEN 400
												 WHEN @LoopLegacySPName IN(''usp_insert_staging_NewContacts'',''usp_insert_staging_Contacts'',''usp_insert_staging_ContactInfo'')
													 THEN 500
												 WHEN @LoopLegacySPName IN(''usp_insert_staging_NewProjects'',''usp_insert_staging_Projects'')
													 THEN 600
												 WHEN @LoopLegacySPName IN(''usp_insert_reference_Documents'')
													 THEN 700
												 WHEN @LoopLegacySPName IN(''usp_insert_staging_NewCalendarEvent'',''usp_insert_staging_NewCalendarEvents'',''usp_insert_staging_NewDeadlines'',''usp_insert_staging_NewMailroomItems'',''usp_insert_staging_NewNotes'',''usp_insert_staging_NewProjectContacts'',''usp_insert_staging_NewProjectPermissions'',''usp_insert_staging_CalendarEvent'',''usp_insert_staging_CalendarEvents'',''usp_insert_staging_Deadlines'',''usp_insert_staging_MailroomItems'',''usp_insert_staging_Notes'',''usp_insert_staging_ProjectContacts'',''usp_insert_staging_ProjectPermissions'')
													 THEN 800
												 WHEN @LoopLegacySPName IN(''usp_insert_staging_NewDocuments'',''usp_insert_staging_Documents'')
													 THEN 9999
												 ELSE 1000
											 END
									END;
					' +
					
					/*If no matching SP is found, create new SP record and map it*/
					'
								IF @LoopLegacySPID IS NULL 
									BEGIN
										SET @LoopLegacySPName = ''usp_insert_'' + LOWER(@LoopTableSPType) + ''_'' + @LoopTableSPTypeName

										IF NOT EXISTS
											(
												SELECT 
													1 
												FROM 
													[Filevine_META_TEST].[dbo].[LegacySP] 
												WHERE 
													LegacySPName = @LoopLegacySPName
											)
											BEGIN
												INSERT INTO
													[Filevine_META_TEST].[dbo].[LegacySP]
													(
														  LegacySPName
													)
												SELECT
													@LoopLegacySPName
											END

										SET @LoopLegacySPID = (SELECT MAX(LegacySPID) FROM Filevine_META_TEST.dbo.LegacySP WHERE LegacySPName = @LoopLegacySPName)
									END
					' +

					/*If no mapping is found, create it*/
					'

								IF NOT EXISTS
									(
										SELECT 
											1 
										FROM 
											' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
										WHERE 
												LegacyDBID = @LoopLegacyDBID
											AND LegacySPID = @LoopLegacySPID
											AND OrgID = @LoopLegacyOrgID
											AND FvProdPrefix = @LoopFVProdPrefix
									)
									BEGIN
										IF EXISTS
											(
												SELECT 
													1 
												FROM 
													' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
												WHERE 
														LegacyDBID = @LoopLegacyDBID
													AND LegacySPID = @LoopLegacySPID
													AND OrgID = @LoopLegacyOrgID
													AND FvProdPrefix = @LoopPreviousPrefix
					' + CASE 
							WHEN NULLIF(@PrevDatabaseBrackets, '') IS NOT NULL 
							THEN '
												UNION
												SELECT 
													1 
												FROM 
													' + @PrevDatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
												WHERE 
														LegacyDBID = @LoopLegacyDBID
													AND LegacySPID = @LoopLegacySPID
													AND OrgID = @LoopLegacyOrgID
													AND FvProdPrefix = @LoopPreviousPrefix
								 '
							ELSE ''
						END +
					'
											)
											BEGIN
												INSERT INTO
													' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
													(
														  [LegacyDBID]
														, [LegacySPID]
														, [OrgID]
														, [FVProdPrefix]
														, [ExecutionOrder]
														, [Active]
													)
												SELECT DISTINCT
													  [LegacyDBID]
													, [LegacySPID]
													, [OrgID]
													, [FVProdPrefix]
													, [ExecutionOrder]
													, [Active]
												FROM
													(
														SELECT
															  [LegacyDBID] [LegacyDBID]
															, [LegacySPID] [LegacySPID]
															, [OrgID] [OrgID]
															, @LoopFVProdPrefix [FVProdPrefix]
															, [ExecutionOrder] [ExecutionOrder]
															, [Active] [Active]
														FROM
															' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
														WHERE
																[LegacyDBID] = @LoopLegacyDBID 
															AND [LegacySPID] = @LoopLegacySPID  
															AND	[FVProdPrefix] = @LoopPreviousPrefix
					' + CASE 
							WHEN NULLIF(@PrevDatabaseBrackets, '') IS NOT NULL 
							THEN '
														UNION
														SELECT
															  [LegacyDBID] [LegacyDBID]
															, [LegacySPID] [LegacySPID]
															, [OrgID] [OrgID]
															, @LoopFVProdPrefix [FVProdPrefix]
															, [ExecutionOrder] [ExecutionOrder]
															, [Active] [Active]
														FROM
															' + @PrevDatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
														WHERE
																[LegacyDBID] = @LoopLegacyDBID 
															AND [LegacySPID] = @LoopLegacySPID  
															AND	[FVProdPrefix] = @LoopPreviousPrefix
								  '

							ELSE ''
						END + 
					'
													) a
											END
										ELSE
											BEGIN
												INSERT INTO
													' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderTable + '] 
													(
														  [LegacyDBID]
														, [LegacySPID]
														, [OrgID]
														, [FVProdPrefix]
														, [ExecutionOrder]
														, [Active]
													)
												SELECT
													  @LoopLegacyDBID [LegacyDBID]
													, @LoopLegacySPID [LegacySPID]
													, @LoopLegacyORGID [OrgID]
													, @LoopFVProdPrefix [FVProdPrefix]
													, @LoopExecutionOrder [ExecutionOrder]
													, 1 [Active]
											END
									END
					' +

					/*If Legacy Schema does not exist in client db, create it*/
					'
								IF NOT EXISTS
									(
										SELECT 
											1 
										FROM 
											' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[SCHEMATA]
										WHERE 
												CATALOG_NAME = ''' + @database + '''
											AND SCHEMA_NAME = @LoopLegacySchema
									)
									BEGIN
										SET @SubStepName = ''Create Legacy Schema '' + @LoopLegacySchema

										SET @SQLN = @LegacyUse + '' EXEC(''''CREATE SCHEMA ['' + @LoopLegacySchema + '']'''')''

										SET @SQLWrapper = @WorkingUse + 
											''
												EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
													  @SQLCode = @SQLWrapper 
													, @DatabaseBrackets = @DatabaseBrackets
													, @ExecutionDB = @ExecutionDB
													, @ProcName = @ProcName
													, @StepName = @StepName
													, @SubStepName = @SubStepName
													, @DebugFlag = @DebugFlag
													, @PT1Schema = @PT1Schema
													, @MigrationProcessStatusTable = @MigrationProcessStatusTable
											''

										EXEC sp_executesql
											  @SQLWrapper
											, N''@SQLWrapper VARCHAR(MAX)
											  , @DatabaseBrackets VARCHAR(1000)
											  , @ExecutionDB VARCHAR(1000)
											  , @ProcName VARCHAR(1000)
											  , @StepName VARCHAR(1000)
											  , @SubStepName VARCHAR(1000)
											  , @DebugFlag BIT
											  , @PT1Schema VARCHAR(1000)
											  , @MigrationProcessStatusTable VARCHAR(1000)''
											, @SQLWrapper = @SQLn
											, @DatabaseBrackets = @DatabaseBrackets
											, @ExecutionDB = @ExecutionDB
											, @ProcName = @ProcName
											, @StepName = @StepName
											, @SubStepName = @SubStepName
											, @DebugFlag = @DebugFlag
											, @PT1Schema = @PT1Schema
											, @MigrationProcessStatusTable = @MigrationProcessStatusTable
									END	
					' +

					/*If refresh flag = 1, then drop the proc and recreate*/
					'
								IF ' + CONVERT(VARCHAR, @RefreshProcs) + ' = 1 
									AND 
										EXISTS
										(
											SELECT 
												1 
											FROM 
												' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout
											WHERE 
													SPECIFIC_SCHEMA = @LoopLegacySchema 
												AND SPECIFIC_NAME = @LoopLegacySPName
										)
									BEGIN
										SET @SQLn = @LegacyUse + 
											''
												DROP PROCEDURE
													['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  '']
											''
										
										BEGIN
											SET @SubStepName = ''REFRESH PROCEDURE ['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  '']''

											SET @SQLWrapper = @WorkingUse + 
												''
													EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
														  @SQLCode = @SQLWrapper 
														, @DatabaseBrackets = @DatabaseBrackets
														, @ExecutionDB = @ExecutionDB
														, @ProcName = @ProcName
														, @StepName = @StepName
														, @SubStepName = @SubStepName
														, @DebugFlag = @DebugFlag
														, @PT1Schema = @PT1Schema
														, @MigrationProcessStatusTable = @MigrationProcessStatusTable
												''

											EXEC sp_executesql
												  @SQLWrapper
												, N''@SQLWrapper VARCHAR(MAX)
												  , @DatabaseBrackets VARCHAR(1000)
												  , @ExecutionDB VARCHAR(1000)
												  , @ProcName VARCHAR(1000)
												  , @StepName VARCHAR(1000)
												  , @SubStepName VARCHAR(1000)
												  , @DebugFlag BIT
												  , @PT1Schema VARCHAR(1000)
												  , @MigrationProcessStatusTable VARCHAR(1000)''
												, @SQLWrapper = @SQLn
												, @DatabaseBrackets = @DatabaseBrackets
												, @ExecutionDB = @ExecutionDB
												, @ProcName = @ProcName
												, @StepName = @StepName
												, @SubStepName = @SubStepName
												, @DebugFlag = @DebugFlag
												, @PT1Schema = @PT1Schema
												, @MigrationProcessStatusTable = @MigrationProcessStatusTable
										END	
									END
					' +

					/*If Procedure does not exist in client db, create it */
					'
								IF NOT EXISTS
									(
										SELECT 
											1 
										FROM 
											' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout
										WHERE 
												SPECIFIC_SCHEMA = @LoopLegacySchema 
											AND SPECIFIC_NAME = @LoopLegacySPName
									)
									BEGIN										
										IF NULLIF(ISNULL(@LoopPreviousDB, ''''), '''') IS NULL
											BEGIN
												DECLARE
													@SQLInsert VARCHAR(MAX) = ''''
												
												SET @SQLn = @workingUse + 
													''
														EXEC ['' + @ExecutionDB + ''].[PT1].[usp_create_Insert_For_SP]
															  @DB = ''''' + @Database + '''''
															, @LegacyTempSPMapTableName = ''''' + @LegacyTempSPMapTableName + '''''
															, @TempSQLInsertTable = ''''' + @TempSQLInsertTable + '''''
															, @SPName = '''''' + @LoopLegacySPName + ''''''
															, @Schema = ''''' + @SchemaName + '''''
															, @DebugFlag = ''''' + CONVERT(VARCHAR, @DebugFlag) + '''''
															, @FVProductionPrefix = ''''' + ISNULL(@FVProductionPrefix, '') + '''''
															, @timezone = ''''' + @timezone + '''''
															, @PT1Schema = ''''' + @PT1Schema + '''''
															, @MigrationProcessStatusTable = ''''' + @MigrationProcessStatusTable + '''''
															, @MigrationConfigTable = ''''' + @MigrationConfigTable + '''''
													''

												BEGIN
													SET @SubStepName = ''Create Insert for SP ['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  '']''

													SET @SQLWrapper = @WorkingUse + 
														''
															EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
																  @SQLCode = @SQLWrapper 
																, @DatabaseBrackets = @DatabaseBrackets
																, @ExecutionDB = @ExecutionDB
																, @ProcName = @ProcName
																, @StepName = @StepName
																, @SubStepName = @SubStepName
																, @DebugFlag = @DebugFlag
																, @PT1Schema = @PT1Schema
																, @MigrationProcessStatusTable = @MigrationProcessStatusTable
														''

													EXEC sp_executesql
														  @SQLWrapper
														, N''@SQLWrapper VARCHAR(MAX)
														  , @DatabaseBrackets VARCHAR(1000)
														  , @ExecutionDB VARCHAR(1000)
														  , @ProcName VARCHAR(1000)
														  , @StepName VARCHAR(1000)
														  , @SubStepName VARCHAR(1000)
														  , @DebugFlag BIT
														  , @PT1Schema VARCHAR(1000)
														  , @MigrationProcessStatusTable VARCHAR(1000)''
														, @SQLWrapper = @SQLn
														, @DatabaseBrackets = @DatabaseBrackets
														, @ExecutionDB = @ExecutionDB
														, @ProcName = @ProcName
														, @StepName = @StepName
														, @SubStepName = @SubStepName
														, @DebugFlag = @DebugFlag
														, @PT1Schema = @PT1Schema
														, @MigrationProcessStatusTable = @MigrationProcessStatusTable
												END

												SELECT 
													@SQLInsert = COALESCE(@SQLInsert + SQLInsert, '''') + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
												FROM
													[' + @PT1Schema + '].[' + @TempSQLInsertTable + ']
									
												SET @SQL = 
														'' 
CREATE PROCEDURE
	['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  '']
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN '' + 
	
	CASE 
		WHEN @LoopLegacyAutoScript IS NOT NULL 
		THEN @loopLegacyAutoScript 
		
		ELSE ''
		SELECT 
			''''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  ''] has been created in [' + @Database + '] database.  Please review and modifiy the procedure.''''

		'' + ISNULL(NULLIF(@SQLInsert, ''''), ''/*'' + ''Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.'' + ''*/'') 
		END + 
		
		''
	END
														''
												
												BEGIN TRY
													EXEC (@SQL)
												END TRY
												
												BEGIN CATCH
													SET @SQL = 
														'' 
CREATE PROCEDURE
	['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  '']
		  @DebugFlag BIT
		, @Database VARCHAR(1000)
		, @SchemaName VARCHAR(1000)
		, @FVProductionPrefix VARCHAR(1000)
		, @timezone VARCHAR(1000)
AS
	BEGIN '' + 
	
	CASE 
		WHEN @LoopLegacyAutoScript IS NOT NULL 
		THEN ''/*'' + @loopLegacyAutoScript + ''*/''
		
		ELSE ''
		SELECT 
			''''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  ''] has been created in [' + @Database + '] database.  Please review and modifiy the procedure.''''

		'' + ISNULL(''/*'' + @SQLInsert + ''*/'', ''/*'' + ''Some value came back as a null and it blew up the insert code that should be dropped here.  Try dropping the proc and rerunning Full_migrationProcess and see if it works.  If not, submit a METAL bug request.'' + ''*/'') 
		END + 
		
		''
	END
														''

													EXEC (@SQL)

													DECLARE @Errormsg VARCHAR(MAX) = ''There was a problem creating the script for ['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName +  ''].  The script will be created, but the code will be commented out.  Please review the stored procedure and troubleshoot manually.''

													SELECT @Errormsg
													
												END CATCH
											END
										ELSE
											BEGIN
												IF EXISTS
												(
													SELECT 
														1 
													FROM 
														' + CASE WHEN ISNULL(NULLIF(@PrevDatabaseBrackets, ''), '') = '' THEN '[INFORMATION_SCHEMA].[Routines] Rout' ELSE @PrevDatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout' END + '
													WHERE 
															SPECIFIC_SCHEMA = @LoopLegacySchema 
														AND SPECIFIC_NAME = @LoopLegacySPName
												)
												AND NOT EXISTS
												(
													SELECT 
														1 
													FROM 
														' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout
													WHERE 
															SPECIFIC_SCHEMA = @LoopLegacySchema 
														AND SPECIFIC_NAME = @LoopLegacySPName
												)
												BEGIN
													DECLARE @SQLCodeClone VARCHAR(MAX) =
														(
															SELECT TOP 1 
																REPLACE(REPLACE([DEFINITION], ''' + ISNULL(@PrevDatabase, '') + ''', ''' + @Database + '''), ''ALTER PROCEDURE'', ''CREATE PROCEDURE'')
															FROM 
																' + CASE WHEN ISNULL(@PrevDatabaseBrackets, '') = '' THEN '[sys].[sql_modules]' ELSE @PrevDatabaseBrackets + '.[sys].[sql_modules]' END + '
															WHERE 
																object_id = (OBJECT_ID(N''' + CASE WHEN ISNULL(@PrevDatabase, '') = '' THEN  ''' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))' ELSE @PrevDatabase + '.' + ''' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))' END + '
														)

													BEGIN TRY
														EXEC (@SQLCodeClone)
													END TRY

													BEGIN CATCH
														SET @SQLCodeClone = 
															(
																SELECT TOP 1 
																	REPLACE(REPLACE([DEFINITION], ''' + ISNULL(@PrevDatabase, '') + ''', ''' + @Database + '''), ''ALTER PROCEDURE'', ''CREATE PROCEDURE'')
																FROM 
																	' + CASE WHEN ISNULL(@PrevDatabaseBrackets, '') = '' THEN '[sys].[sql_modules]' ELSE @PrevDatabaseBrackets + '.[sys].[sql_modules]' END + '
																WHERE 
																	object_id = (OBJECT_ID(N''' + CASE WHEN ISNULL(@PrevDatabase, '') = '' THEN  ''' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))' ELSE @PrevDatabase + '.' + ''' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))' END + '
															)
															+ ''/*'' 
															+ ''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName + ''] failed to clone from the database ' + ISNULL(@PrevDatabaseBrackets, '') + ' .  Please investigate.''
															+ ''*/''
															  
														
														SELECT ''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName + ''] failed to clone from the database ' + ISNULL(@PrevDatabaseBrackets, '') + ' .  Please investigate.''
														
														EXEC (@SQLCodeClone)
													END CATCH
												END
											END
									END
					' +

					/*If SP Exists and looking to previous test, replace the prefix in the existing SP with the new one*/
					'
								IF EXISTS
									(
										SELECT 
											1 
										FROM 
											' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[Routines] Rout
										WHERE 
												SPECIFIC_SCHEMA = @LoopLegacySchema 
											AND SPECIFIC_NAME = @LoopLegacySPName
											AND ROUTINE_DEFINITION LIKE ''%'' + REPLACE(@LoopPreviousPrefix, ''_'', ''[_]'') + ''%''
											AND ROUTINE_DEFINITION NOT LIKE ''%'' + REPLACE(@LoopFVProdPrefix, ''_'', ''[_]'') + ''%''
									)
									AND @LoopPreviousPrefix IS NOT NULL
									BEGIN
										DECLARE 
											@SQLCode VARCHAR(MAX) = 
												(
													SELECT TOP 1 
														REPLACE(REPLACE([DEFINITION], ''CREATE PROCEDURE'', ''ALTER PROCEDURE''), @LoopPreviousPrefix, @LoopFVProdPrefix)
													FROM 
														' + @DatabaseBrackets + '.[sys].[sql_modules] 
													WHERE 
														object_id = (OBJECT_ID(N''' + @Database + '.'' + @LoopLegacySchema + ''.'' + @LoopLegacySPName))
												)
										
										BEGIN TRY
											EXEC (@SQLCode)
										END TRY

										BEGIN CATCH
											SELECT 
												  ''['' + @LoopLegacySchema + ''].['' + @LoopLegacySPName + ''] failed to alter previous prefix name in existing SP.  Please investigate.''
												, @SQLCode ''altersql''
										END CATCH
									END

								SET @Counter = @Counter + 1					
							END
					'

				BEGIN
					SET @SubStepName = 'Loop through ' + @LegacyTempSPMapTableName + ' and insert mappings'
					
					SET @SQLWrapper = @WorkingUse + 
						'
							EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
								  @SQLCode = @SQLWrapper 
								, @DatabaseBrackets = @DatabaseBrackets
								, @ExecutionDB = @ExecutionDB
								, @ProcName = @ProcName
								, @StepName = @StepName
								, @SubStepName = @SubStepName
								, @DebugFlag = @DebugFlag
								, @PT1Schema = @PT1Schema
								, @MigrationProcessStatusTable = @MigrationProcessStatusTable
						'

					EXEC sp_executesql
						  @SQLWrapper
						, N'@SQLWrapper VARCHAR(MAX)
						  , @DatabaseBrackets VARCHAR(1000)
						  , @ExecutionDB VARCHAR(1000)
						  , @ProcName VARCHAR(1000)
						  , @StepName VARCHAR(1000)
						  , @SubStepName VARCHAR(1000)
						  , @DebugFlag BIT
						  , @PT1Schema VARCHAR(1000)
						  , @MigrationProcessStatusTable VARCHAR(1000)'
						, @SQLWrapper = @SQLn
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				END
			END

			/*Cleanup*/
			BEGIN
				SET @SQL = @LegacyUse + 
					'
						IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @TempSQLInsertTable + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
							BEGIN
								DROP TABLE [' + @PT1Schema + '].[' + @TempSQLInsertTable + ']
							END
					'
					
				EXEC (@SQL)
			END

			
		END
	END
GO
/****** Object:  StoredProcedure [PT1].[usp_create_meta_MigrationTables]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE 
	[PT1].[usp_create_meta_MigrationTables]
		  @DebugFlag BIT = 1   -- 1 to output SQL statements; 0 to EXECUTE	
		, @Database VARCHAR(500)
		, @SchemaName VARCHAR(500)
		, @ExecutionDB VARCHAR(500)
		, @PT1Schema VARCHAR(100)
		, @MigrationProcessStatusTable VARCHAR(1000)
		, @MigrationConfigTable VARCHAR(1000)
		, @ExecOrderTable VARCHAR(1000)
		, @ExecOrderView VARCHAR(1000)
AS

	BEGIN
		DECLARE 
			  @DatabaseBrackets VARCHAR(500)
			, @SQLn NVARCHAR(MAX) = N''
			, @SQL VARCHAR(MAX)
			, @SQLLog NVARCHAR(MAX)
			, @SQLWrapper NVARCHAR(MAX) = N''
			, @NewLine CHAR(2) = CHAR(13) + CHAR(10)
			, @ProcName	VARCHAR(200) = OBJECT_NAME(@@PROCID)
			, @StepName	VARCHAR(100) = 'Create Migration Tables for ' + @Database + '.'
			, @SubStepName VARCHAR(250)
			, @ErrorMsg NVARCHAR(2048) = N''
			, @ErrorCode INT = 0
			, @False BIT = 0
			, @True BIT = 1
			, @WorkingUse VARCHAR(1000) = 'USE ' + @ExecutionDB

		BEGIN
			SET @DatabaseBrackets = 
				CASE
					WHEN CHARINDEX('[', @Database, 1) = 0 
					THEN '[' + @Database + ']' 
					
					ELSE @Database 
				END
		 
			SET @Database = REPLACE(REPLACE(@Database, '[', ''), ']', '')

			-----------------------------------------------------------------------------------------------------------------------
			----	CREATE CONFIG TABLES	   ------------------------------------------------------------------------------------
			-----------------------------------------------------------------------------------------------------------------------
			BEGIN
				SET @SubStepName = 'Setup Config table if it doesnt exist. ' + @MigrationConfigTable + '';
			
				SET @SQLn = 
					N'
						USE ' + @DatabaseBrackets + ' 

						IF OBJECT_ID(N''' + @PT1Schema + '.' + @MigrationConfigTable + ''') IS NOT NULL
							BEGIN
								DROP TABLE ' + @PT1Schema + '.' + @MigrationConfigTable + '
							END
				
						CREATE TABLE 
							' + @PT1Schema + '.' + @MigrationConfigTable + '
							( 
								  [ROWNUM] [BIGINT] IDENTITY(1,1) NOT NULL
								, [GroupTable] [INT] NOT NULL
								, [OBJECT_ID] BIGINT NOT NULL
								, [TABLE_SCHEMA] [VARCHAR](500) NOT NULL
								, [TABLE_NAME] [VARCHAR] (500) NOT NULL
								, [Base_Object_ID] BIGINT NOT NULL
								, [Base_Table_Schema] [VARCHAR] (500) NOT NULL
								, [Base_Table_Name] VARCHAR(500) NOT NULL
								, [Meta_table_name] VARCHAR(500) NOT NULL
								, [NewStagingTablename] [VARCHAR] (500) NOT NULL
								, [FVTableID] [BIGINT] NOT NULL
								, [CustomTab] BIT NOT NULL DEFAULT 0
								, [COLUMN_NAME] [VARCHAR] (500) NOT NULL
								, [DataType] [VARCHAR] (500) NOT NULL
								, [MaxLen] [INT] NULL
								, [NumPrecison] [INT] NULL
								, [NumScale] [INT] NULL
								, [fullDataType] [VARCHAR](100) NOT NULL
								, [ORDINAL_POSITION] [INT] NULL
								, [nullStmt] [VARCHAR](100) NOT NULL
								, [InsertedIntoFVProdImport] CHAR(1) NULL 
								, [SynonymName] VARCHAR(500) NOT NULL
							) ON [PRIMARY]
					'
						 
				SET @SQLWrapper = @WorkingUse + 
					'
						EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
							  @SQLCode = @SQLWrapper 
							, @DatabaseBrackets = @DatabaseBrackets
							, @ExecutionDB = @ExecutionDB
							, @ProcName = @ProcName
							, @StepName = @StepName
							, @SubStepName = @SubStepName
							, @DebugFlag = @DebugFlag
							, @PT1Schema = @PT1Schema
							, @MigrationProcessStatusTable = @MigrationProcessStatusTable
					'

				EXEC sp_executesql
					  @SQLWrapper
					, N'@SQLWrapper VARCHAR(MAX)
					  , @DatabaseBrackets VARCHAR(1000)
					  , @ExecutionDB VARCHAR(1000)
					  , @ProcName VARCHAR(1000)
					  , @StepName VARCHAR(1000)
					  , @SubStepName VARCHAR(1000)
					  , @DebugFlag BIT
					  , @PT1Schema VARCHAR(1000)
					  , @MigrationProcessStatusTable VARCHAR(1000)'
					, @SQLWrapper = @SQLn
					, @DatabaseBrackets = @DatabaseBrackets
					, @ExecutionDB = @ExecutionDB
					, @ProcName = @ProcName
					, @StepName = @StepName
					, @SubStepName = @SubStepName
					, @DebugFlag = @DebugFlag
					, @PT1Schema = @PT1Schema
					, @MigrationProcessStatusTable = @MigrationProcessStatusTable		 			
			END

			-----------------------------------------------------------------------------------------------------------------------
			----	CREATE EXECUTION ORDER TABLE/VIEW	   ------------------------------------------------------------------------
			-----------------------------------------------------------------------------------------------------------------------
			BEGIN
				SET @SubStepName = 'Exec [' + @PT1Schema + '].[usp_Create_LegacySPExecutionOrder]';
			
				SET @SQLn = 
					N'
						USE ' + @DatabaseBrackets + ' 

						EXEC [' + @ExecutionDB + '].[' + @PT1Schema + '].[usp_Create_LegacySPExecutionOrder]
							  @Database = ''' + @Database + '''
							, @ExecutionDB = ''' + @ExecutionDB + '''
							, @DebugFlag = ' + CONVERT(VARCHAR, @DebugFlag) + '
							, @PT1Schema = ''' + @PT1Schema + '''
							, @MigrationProcessStatusTable = ''' + @MigrationProcessStatusTable + '''
							, @ExecOrderTable = ''' + @ExecOrderTable + '''
							, @ExecOrderView = ''' + @ExecOrderView + '''
					'
						 
				SET @SQLWrapper = @WorkingUse + 
					'
						EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
							  @SQLCode = @SQLWrapper 
							, @DatabaseBrackets = @DatabaseBrackets
							, @ExecutionDB = @ExecutionDB
							, @ProcName = @ProcName
							, @StepName = @StepName
							, @SubStepName = @SubStepName
							, @DebugFlag = @DebugFlag
							, @PT1Schema = @PT1Schema
							, @MigrationProcessStatusTable = @MigrationProcessStatusTable
					'

				EXEC sp_executesql
					  @SQLWrapper
					, N'@SQLWrapper VARCHAR(MAX)
					  , @DatabaseBrackets VARCHAR(1000)
					  , @ExecutionDB VARCHAR(1000)
					  , @ProcName VARCHAR(1000)
					  , @StepName VARCHAR(1000)
					  , @SubStepName VARCHAR(1000)
					  , @DebugFlag BIT
					  , @PT1Schema VARCHAR(1000)
					  , @MigrationProcessStatusTable VARCHAR(1000)'
					, @SQLWrapper = @SQLn
					, @DatabaseBrackets = @DatabaseBrackets
					, @ExecutionDB = @ExecutionDB
					, @ProcName = @ProcName
					, @StepName = @StepName
					, @SubStepName = @SubStepName
					, @DebugFlag = @DebugFlag
					, @PT1Schema = @PT1Schema
					, @MigrationProcessStatusTable = @MigrationProcessStatusTable
			END
		END
	END
GO
/****** Object:  StoredProcedure [PT1].[usp_create_meta_ReferenceTables]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE 
	[PT1].[usp_create_meta_ReferenceTables]
		  @DebugFlag BIT = 0   -- 1 to output SQL statements; 0 to execute	
		, @Database VARCHAR(500)
		, @PreviousDatabase VARCHAR(500)
		, @SchemaName VARCHAR(500) = 'dbo'
		, @ExecutionDB VARCHAR(500)
		, @PT1Schema VARCHAR(1000)
		, @MigrationProcessStatusTable VARCHAR(1000) 

AS
	BEGIN
		DECLARE 
			  @SQL NVARCHAR(MAX) = N''
			, @SQLn NVARCHAR(MAX) = N''
			, @NewLine CHAR(2) = CHAR(13) + CHAR(10)
			, @ProcName VARCHAR(200) = OBJECT_NAME(@@PROCID)
			, @StepName VARCHAR(100) = 'Create __FV_{reference} Tables'
			, @SubStepName VARCHAR(250) = 'Setup __FV_{reference} SQLs'
			, @ErrorMsg NVARCHAR(2048) = N''
			, @ErrorCode INT = 0
			, @FVDocuments NVARCHAR(MAX)
			, @FVUsernames VARCHAR(MAX)
			, @FVProjectTemplates NVARCHAR(MAX)
			, @FVPhaseMap NVARCHAR(MAX)	
			, @ClientAlignSchema VARCHAR(1000) = 'PT1_CLIENT_ALIGN'
			, @FVSOLs NVARCHAR(MAX)
			, @FVClientCasesMap NVARCHAR(MAX)
			, @True BIT = 1
			, @False BIT = 0
			, @SQLWrapper NVARCHAR(MAX) = ''
			, @WorkingUse VARCHAR(100) = 'USE ' + @ExecutionDB
			, @DatabaseBrackets VARCHAR(500) = 
				CASE 
					WHEN CHARINDEX('[', @Database, 1) = 0 
					THEN '[' + @Database + ']' 
									
					ELSE @Database 
				END

		SET @Database =  REPLACE(REPLACE(@Database, '[', ''), ']', '')

		/*Create Schema for Alignments*/
		BEGIN
			SET @SubStepName = 'Create the [' + @ClientAlignSchema + '] Schema'

			SET @SQLn =
				'
					USE ' + @DatabaseBrackets + ' 

					IF NOT EXISTS
						(
							SELECT 
								1 
							FROM 
								' + @DatabaseBrackets + '.[INFORMATION_SCHEMA].[SCHEMATA]
							WHERE 
									CATALOG_NAME = ''' + @Database + '''
								AND SCHEMA_NAME = ''' + @ClientAlignSchema + '''
						)
						BEGIN
							EXEC(''CREATE SCHEMA [' + @ClientAlignSchema + ']'')
						END	
				'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQLn
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END

		/*If tables exist in this alignment schema in previous database, clone to current database.*/
		IF NULLIF(@PreviousDatabase, '') IS NOT NULL
			BEGIN
				SET @SubStepName = 'Clone ' + @ClientAlignSchema + ' supported objects'
				
				SET @SQLn = 
					'
						USE ' + @DatabaseBrackets + '
					
						DECLARE 
							@TempAlignLoopTab TABLE
								(
									  ID BIGINT IDENTITY(1,1)
									, AlignSchema VARCHAR(1000)
									, AlignTable VARCHAR(1000)
								)

						DECLARE
							  @Counter BIGINT = 1
							, @MaxID BIGINT

						INSERT INTO
							@TempAlignLoopTab
								(
									  AlignSchema
									, AlignTable
								)
						SELECT DISTINCT
							  TABLE_SCHEMA
							, TABLE_NAME
						FROM
							[' + @PreviousDatabase + '].INFORMATION_SCHEMA.TABLES
						WHERE
								TABLE_SCHEMA = ''' + @ClientAlignSchema + '''
							AND TABLE_TYPE = ''BASE TABLE''

						SET @MaxID = (SELECT MAX(ID) FROM @TempAlignLoopTab)

						WHILE @Counter <= @MaxID
							BEGIN
								DECLARE
									  @SQLClone VARCHAR(MAX)
									, @LoopSchema VARCHAR(MAX) = (SELECT [AlignSchema] FROM @TempAlignLoopTab WHERE ID = @Counter)
									, @LoopTable VARCHAR(MAX) = (SELECT [AlignTable] FROM @TempAlignLoopTab WHERE ID = @Counter)

								SET @SQLClone = 
									''
										USE ' + @DatabaseBrackets + '

										IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '''''' + @loopTable + '''''' AND TABLE_SCHEMA = '''''' + @LoopSchema + '''''') 
											BEGIN
												SELECT
													*
												INTO
													['' + @LoopSchema + ''].['' + @LoopTable + '']
												FROM
													[' + @PreviousDatabase + '].['' + @LoopSchema + ''].['' + @LoopTable + '']
											END
									''
									
								EXEC (@SQLClone)

								SET @Counter = @Counter + 1
							END
					'

				SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQLn
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
			END

		/*Create __FV_NewDocuments*/
		BEGIN
			SET @SubStepName = 'Create [__FV_Documents] table'
				
			SET @FVDocuments =
				N'
					USE ' + @DatabaseBrackets + '
	 
					IF OBJECT_ID(N''[' + @SchemaName + '].[__FV_Documents]'') IS NOT NULL  
						BEGIN
							DROP TABLE [' + @SchemaName + '].[__FV_Documents];
						END  
							
					CREATE TABLE 
						' + @DatabaseBrackets + '.[' + @SchemaName + '].[__FV_Documents]
						(
							  [FVD_RecID] BIGINT IDENTITY(1,1)
							, [FVDocID] VARCHAR(96)
							, [ScanID] VARCHAR(96)
							, [Legacy_DocID] VARCHAR(96)
							, [Legacy_FileID] VARCHAR(96)
							, [Legacy_ContactID] VARCHAR(96)
							, [FV_ProjectID] VARCHAR(96)
							, [FV_ContactFirstName] VARCHAR(255)
							, [FV_ContactLastName] VARCHAR(255)
							, [FV_Url] VARCHAR(MAX)
							, [FV_Phase] VARCHAR(MAX)
							, [FV_Archived] BIT
							, [Doc_FullPath] VARCHAR(MAX)
							, [Doc_BasePath] VARCHAR(MAX)
							, [Doc_FileName] VARCHAR(MAX)
							, [Doc_Ext] VARCHAR(MAX)
							, [Doc_CompleteName] VARCHAR(MAX)
							, [Doc_NeedRename] BIT
							, [Doc_RenameTo] VARCHAR(MAX)
						);
				'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @FVDocuments
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END

		/*Create __FV_Usernames*/
		BEGIN
			SET @SubStepName = 'Create [__FV_Usernames] table'

			SET @FVUsernames = 
				'
					USE ' + @DatabaseBrackets + '
	                        
					IF OBJECT_ID(N''[' + @SchemaName + '].[__FV_Usernames]'') IS NOT NULL  
						BEGIN
							DROP TABLE [' + @SchemaName + '].[__FV_Usernames];
						END  
							
					CREATE TABLE 
						' + @DatabaseBrackets + '.[' + @SchemaName + '].[__FV_Usernames]
						(
							  [Username_ID] BIGINT IDENTITY(1,1)
							, [Staff_ID] AS ''STAFF''+ CAST([Username_ID] AS VARCHAR(10)) PERSISTED PRIMARY KEY
							, [FV_Username] [VARCHAR](255)
							, [Legacy_Username] [VARCHAR](255)
							, [Legacy_Username_ID] [VARCHAR](96)
							, [isActive] [BIT]
							, [FirstName] [VARCHAR](96)
							, [MiddleName] [VARCHAR](96)
							, [LastName] [VARCHAR](96)
							, [Initials] [VARCHAR](96)
							, [EmployeeNumber] [VARCHAR](255)
							, [AbbreviatedName] [VARCHAR](100) NULL
							, [IsCompany] [BIT] NULL
							, [CompanyName] [VARCHAR](max) NULL
							, [Ssn] [VARCHAR](255) NULL
							, [DriverLicNo] [VARCHAR](64) NULL
							, [Gender] [CHAR](2) NULL
							, [MaritalStatus] [CHAR](2) NULL
							, [Language] [VARCHAR](100) NULL
							, [Birthdate] [DATETIME] NULL
							, [Salutation] [VARCHAR](50) NULL
							, [Specialty] [VARCHAR](max) NULL
							, [BarNumber] [VARCHAR](50) NULL
							, [Notes] [VARCHAR](max) NULL
							, [IsTypeClient] [BIT] NULL
							, [IsTypeAdjuster] [BIT] NULL
							, [IsTypeAttorney] [BIT] NULL
							, [IsTypeFirm] [BIT] NULL
							, [IsTypeExpert] [BIT] NULL
							, [IsTypeMedicalProvider] [BIT] NULL
							, [IsTypeInvolvedParty] [BIT] NULL
							, [IsTypeJudge] [BIT] NULL
							, [IsTypeCourt] [BIT] NULL
							, [IsTypeInsuranceCompany] [BIT] NULL
							, [IsTypeDefendant] [BIT] NULL
							, [CanText] [BIT] NULL
							, [CanRemarket] [BIT] NULL
							, [IsMinor] [BIT] NULL
							, [Fiduciary] [VARCHAR](255) NULL
							, [Phone1] [VARCHAR](255) NULL 
							, [Phone2] [VARCHAR](255) NULL 
							, [Phone3] [VARCHAR](255) NULL 
							, [Phone4] [VARCHAR](255) NULL 
							, [Phone5] [VARCHAR](255) NULL 
							, [Phone6] [VARCHAR](255) NULL 
							, [Phone7] [VARCHAR](255) NULL 
							, [Phone8] [VARCHAR](255) NULL 
							, [Phone9] [VARCHAR](255) NULL 
							, [Phone10] [VARCHAR](255) NULL 
							, [Phone1Label] [VARCHAR](50) NULL 
							, [Phone2Label] [VARCHAR](50) NULL 
							, [Phone3Label] [VARCHAR](50) NULL 
							, [Phone4Label] [VARCHAR](50) NULL 
							, [Phone5Label] [VARCHAR](50) NULL 
							, [Phone6Label] [VARCHAR](50) NULL 
							, [Phone7Label] [VARCHAR](50) NULL 
							, [Phone8Label] [VARCHAR](50) NULL 
							, [Phone9Label] [VARCHAR](50) NULL 
							, [Phone10Label] [VARCHAR](50) NULL 
							, [Email1] [VARCHAR](255) NULL 
							, [Email2] [VARCHAR](255) NULL 
							, [Email3] [VARCHAR](255) NULL 
							, [Email4] [VARCHAR](255) NULL 
							, [Email5] [VARCHAR](255) NULL 
							, [Email1Label] [VARCHAR](50) NULL 
							, [Email2Label] [VARCHAR](50) NULL 
							, [Email3Label] [VARCHAR](50) NULL 
							, [Email4Label] [VARCHAR](50) NULL 
							, [Email5Label] [VARCHAR](50) NULL 
							, [Address1Line1] [VARCHAR](max) NULL 
							, [Address2Line1] [VARCHAR](max) NULL 
							, [Address3Line1] [VARCHAR](max) NULL 
							, [Address4Line1] [VARCHAR](max) NULL 
							, [Address5Line1] [VARCHAR](max) NULL 
							, [Address1Line2] [VARCHAR](255) NULL 
							, [Address2Line2] [VARCHAR](255) NULL 
							, [Address3Line2] [VARCHAR](255) NULL 
							, [Address4Line2] [VARCHAR](255) NULL 
							, [Address5Line2] [VARCHAR](255) NULL 
							, [Address1City] [VARCHAR](50) NULL 
							, [Address2City] [VARCHAR](50) NULL 
							, [Address3City] [VARCHAR](50) NULL 
							, [Address4City] [VARCHAR](50) NULL 
							, [Address5City] [VARCHAR](50) NULL 
							, [Address1State] [VARCHAR](50) NULL 
							, [Address2State] [VARCHAR](50) NULL 
							, [Address3State] [VARCHAR](50) NULL 
							, [Address4State] [VARCHAR](50) NULL 
							, [Address5State] [VARCHAR](50) NULL 
							, [Address1Zip] [VARCHAR](10) NULL 
							, [Address2Zip] [VARCHAR](10) NULL 
							, [Address3Zip] [VARCHAR](10) NULL 
							, [Address4Zip] [VARCHAR](10) NULL 
							, [Address5Zip] [VARCHAR](10) NULL 
							, [Address1Label] [VARCHAR](50) NULL 
							, [Address2Label] [VARCHAR](50) NULL 
							, [Address3Label] [VARCHAR](50) NULL 
							, [Address4Label] [VARCHAR](50) NULL 
							, [Address5Label] [VARCHAR](50) NULL
						);
				'
				
			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @FVUsernames
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable	
		END

		/*Create __FV_ProjectTemplateMap*/
		BEGIN
			SET @SubStepName = 'Create [__FV_ProjectTemplateMap] table'

			SET @FVProjectTemplates = 
				N'
					USE ' + @DatabaseBrackets + '
	                        
					IF OBJECT_ID(N''[' + @SchemaName + '].[__FV_ProjectTemplateMap]'') IS NOT NULL  
						BEGIN
							DROP TABLE [' + @SchemaName + '].[__FV_ProjectTemplateMap];  
						END
							
					CREATE TABLE 
						' + @DatabaseBrackets + '.[' + @SchemaName + '].[__FV_ProjectTemplateMap]
						(
							  [Project_Template_ID] [BIGINT] IDENTITY(1,1)
							, [Legacy_Case_ID] [VARCHAR](255) NULL
							, [Legacy_Case_Desc] [VARCHAR](255) NULL
							, [Legacy_subCase_ID] [VARCHAR](255) NULL
							, [Legacy_subCase_Desc] [VARCHAR](255) NULL
							, [Filevine_ProjectTemplate] [VARCHAR](255) NULL
							, [Filevine_SubType] [VARCHAR](255) NULL
							, [isActive] [BIT] NOT NULL
							, [SpecialLogic] [VARCHAR](MAX) NULL
							, [NeedsMigration] [BIT]
						);
				'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @FVProjectTemplates
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END

		/*Create __FV_PhaseMap*/
		BEGIN
			SET @SubStepName = 'Create [__FV_PhaseMap] table'

			SET	@FVPhaseMap = 
				N'
					USE ' + @DatabaseBrackets + '
					
					IF OBJECT_ID(N''[' + @SchemaName + '].[__FV_PhaseMap]'') IS NOT NULL  
						BEGIN
							DROP TABLE [' + @SchemaName + '].[__FV_PhaseMap];
						END  
					
					CREATE TABLE 
						' + @DatabaseBrackets + '.[' + @SchemaName + '].[__FV_PhaseMap]
						(
							  PhaseID [BIGINT] IDENTITY(1,1)
							, Legacy_Phase_ID [VARCHAR](255)
							, Legacy_Phase_Desc [VARCHAR](255)
							, Legacy_subPhase_ID [VARCHAR](255)
							, Legacy_subPhase_Desc [VARCHAR](255)
							, Filevine_Phase [VARCHAR](255)
							, isActive [BIT]
						);
				'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @FVPhaseMap
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END

		/*Create __FV_ClientCaseMap*/
		BEGIN
			SET @SubStepName = 'Create [__FV_ClientCaseMap] table'

			SET	@FVClientCasesMap = 
				N'
					USE ' + @DatabaseBrackets + '
					
					IF OBJECT_ID(N''[' + @SchemaName + '].[__FV_ClientCaseMap]'') IS NOT NULL  
						BEGIN
							DROP TABLE [' + @SchemaName + '].[__FV_ClientCaseMap];  
						END
					
					CREATE TABLE 
						' + @DatabaseBrackets + '.[' + @SchemaName + '].[__FV_ClientCaseMap]
						(
							  [ProjectExternalID] [varchar](62) NOT NULL
							, [ContactExternalID] [varchar](500) NULL
							, [CaseID] [varchar](max) NULL
							, [NameID] varchar(50) null
							, [Filevine_ProjectTemplate] [varchar](255) NULL
							, [Active] BIT NULL DEFAULT 1
							, [Archived] BIT NULL DEFAULT 0
						);
				'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @FVClientCasesMap
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END
	END
GO
/****** Object:  StoredProcedure [PT1].[usp_create_meta_StagingTables]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROCEDURE  
	[PT1].[usp_create_meta_StagingTables]
		  @DebugFlag BIT    -- 1 to output SQL statements; 0 to execute	
		, @Database VARCHAR(500)
		, @SchemaName VARCHAR(500)
		, @prefix VARCHAR(50)
		, @ImportDatabaseName VARCHAR(500)
		, @ExecutionDB VARCHAR(500)
		, @BaseImportSchema VARCHAR(500)
		, @AuditImportSchema VARCHAR(500)
		, @ImportSQLAuditTable VARCHAR(500)
		, @ImportTableMapTable VARCHAR(500)
		, @PT1Schema VARCHAR(500)
		, @MigrationProcessStatusTable VARCHAR(500)
		, @MigrationConfigTable VARCHAR(1000)

AS	
	BEGIN
		SET NOCOUNT ON

		DECLARE
			  @SQL VARCHAR(MAX)
			, @SQL1 VARCHAR(MAX) = ''
			, @SQL2 VARCHAR(MAX) = ''
			, @SQL3 VARCHAR(MAX) = ''
			, @SQL4 VARCHAR(MAX) = ''
			, @SQL5 VARCHAR(MAX) = ''
			, @SQL6 VARCHAR(MAX) = ''
			, @SQL7 VARCHAR(MAX) = ''
			, @SQL8 VARCHAR(MAX) = ''
			, @SQL9 VARCHAR(MAX) = ''
			, @SQL10 VARCHAR(MAX) = ''
			, @SQL11 VARCHAR(MAX) = ''
			, @SQL12 VARCHAR(MAX) = ''
			, @SQL13 VARCHAR(MAX) = ''
			, @SQL14 VARCHAR(MAX) = ''
			, @SQL15 VARCHAR(MAX) = ''
			, @SQL16 VARCHAR(MAX) = ''
			, @SQL17 VARCHAR(MAX) = ''
			, @SQL18 VARCHAR(MAX) = ''
			, @SQL19 VARCHAR(MAX) = ''
			, @SQL20 VARCHAR(MAX) = ''
			, @SQLN NVARCHAR(MAX)
			, @SQLWrapper NVARCHAR(MAX) = ''
			, @DatabaseBrackets VARCHAR(500)
			, @NewLine CHAR(2) = CHAR(13) + CHAR(10)
			, @totalTables INT = 0
			, @processGroupNumber INT = 1
			, @newStageTable VARCHAR(500)
			, @fullDataType VARCHAR(500)
			, @nullStmt VARCHAR(25)
			, @collist VARCHAR(MAX)
			, @ProcName	VARCHAR(200) = OBJECT_NAME(@@PROCID)
			, @StepName	VARCHAR(100) = 'Create all Staging tables for ' + @Database + ' table'
			, @SubStepName VARCHAR(250)
			, @LegacyUse VARCHAR(MAX)
			, @WorkingUse VARCHAR(1000) = 'USE ' + @ExecutionDB
			, @ErrorMsg NVARCHAR(2048) = N''
			, @ErrorCode INT = 0
			, @True BIT = 1
			, @False BIT = 0;

		SET @DatabaseBrackets = 
			CASE
				WHEN CHARINDEX('[', @Database, 1) = 0 
				THEN '[' + @Database + ']'
				
				ELSE @Database 
			END

		SET @LegacyUse = 'USE ' + @DatabaseBrackets + ';'
		
		--establish import table map
		BEGIN
			SET @SubStepName = 'Create import map table'
			
			SET @SQLn = @LegacyUse + 
				'
					IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @ImportTableMapTable + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
						BEGIN
							DROP TABLE [' + @PT1Schema + '].[' + @ImportTableMapTable + ']
						END

					CREATE TABLE
						[' + @PT1Schema + '].[' + @ImportTableMapTable + ']
						(
							  ID BIGINT IDENTITY(1,1)
							, BASE_SCHEMA VARCHAR(1000) NOT NULL
							, BASE_TABLE VARCHAR(1000) NOT NULL
							, BASE_OBJECT_ID VARCHAR(1000)
							, VIEW_SCHEMA VARCHAR(1000) NOT NULL
							, VIEW_NAME VARCHAR(1000) NOT NULL
							, VIEW_OBJECT_ID VARCHAR(1000)
							, FVTableID VARCHAR(1000)
							, META_TABLE VARCHAR(1000)
							, Prefix VARCHAR(1000)
						)

					INSERT INTO
						[' + @PT1Schema + '].[' + @ImportTableMapTable + ']
						(
							  BASE_SCHEMA
							, BASE_TABLE
							, BASE_OBJECT_ID
							, VIEW_SCHEMA
							, VIEW_NAME
							, VIEW_OBJECT_ID
							, FVTableID
							, META_TABLE
							, Prefix
						)
					SELECT DISTINCT
						  ''' + @BaseImportSchema + ''' [BASE_SCHEMA]
						, LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(BASE_TABLE_NAME, ''['', ''''), '']'', ''''), ''' + @BaseImportSchema + '.'', ''''))) [BASE_TABLE]
						, CONVERT(VARCHAR, OBJECT_ID(''' + @ImportDatabaseName + '.' + @BaseImportSchema + '.'' + REPLACE(REPLACE(REPLACE(BASE_TABLE_NAME, ''['', ''''), '']'', ''''), ''' + @BaseImportSchema + '.'', '''')))[BASE_OBJECT_ID]
						, ''DBO'' [VIEW_SCHEMA]
						, LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(IMPORT_VIEW_NAME, ''['', ''''), '']'', ''''), ''dbo.'', ''''))) [VIEW_NAME]
						, CONVERT(VARCHAR, OBJECT_ID(''' + @ImportDatabaseName + '.DBO.'' + REPLACE(REPLACE(REPLACE(IMPORT_VIEW_NAME, ''['', ''''), '']'', ''''), ''dbo.'', '''')))[VIEW_OBJECT_ID]
						, CONVERT(VARCHAR, REVERSE(SUBSTRING(REVERSE(REPLACE(REPLACE(REPLACE(BASE_TABLE_NAME, ''['', ''''), '']'', ''''), ''' + @BaseImportSchema + '.'', '''')), 1, CHARINDEX(''_'', REVERSE(REPLACE(REPLACE(REPLACE(BASE_TABLE_NAME, ''['', ''''), '']'', ''''), ''' + @BaseImportSchema + '.'', '''')), 1) - 1))) [FVTableID]
						, REPLACE(REPLACE(REPLACE(import_meta_table_name, ''['', ''''), '']'', ''''), ''' + @BaseImportSchema + '.'', '''')
						, ''' + @prefix + '''
					FROM 
						[' + @ImportDatabaseName + '].[' + @AuditImportSchema + '].[' + @ImportSQLAuditTable + ']
					WHERE 
					
							COALESCE(NULLIF(BASE_TABLE_NAME, '''') + NULLIF(IMPORT_VIEW_NAME, ''''), NULL) IS NOT NULL
						AND CHARINDEX(''' + @prefix + ''', BASE_TABLE_NAME, 1) > 0  
				
				'
				
			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQLn
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable

			IF @DebugFlag = @True
				BEGIN
					SET @SQL = @LegacyUse + ' SELECT ''ImportTableMap'', * FROM [' + @PT1Schema + '].[' + @ImportTableMapTable + ']'

					EXEC (@SQL)
				END
		END

		-----------------------------------------------------------------------------------------------------------------------
		----	POPULATE CONFIG TABLES	   ------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------------
		BEGIN 
			SET @SubStepName = 'Populate ' + @MigrationConfigTable

			IF @DebugFlag = @True
				PRINT @SubStepName

			SET @SQLn = @LegacyUse + 
				N'
					TRUNCATE TABLE
						[' + @PT1Schema + '].[' + @MigrationConfigTable + '];
			
					INSERT INTO
						[' + @PT1Schema + '].[' + @MigrationConfigTable + ']
						(
							  [GroupTable]
							, [TABLE_SCHEMA]
							, [TABLE_NAME]
							, [Base_Table_Schema]
							, [Base_Table_Name]
							, [Meta_table_name]
							, [NewStagingTablename]
							, [COLUMN_NAME]
							, [CustomTab]
							, [FVTableID]
							, [DataType]
							, [MaxLen]
							, [NumPrecison]
							, [NumScale]
							, [fullDataType]
							, [ORDINAL_POSITION]
							, [nullStmt]
							, [Object_ID]
							, [Base_object_ID]
							, [SynonymName]
						)
					SELECT
						  [GroupTable]
						, [TABLE_SCHEMA]
						, [TABLE_NAME]
						, [Base_Table_Schema]
						, [Base_Table_Name]
						, [Meta_table_name]
						, [NewStagingTablename]
						, [ColumnName]
						, CASE
							WHEN TABLE_NAME <> BASE_TABLE_NAME AND BASE_TABLE_NAME NOT LIKE ''%Standard%''
							THEN 1

							ELSE 0
						  END[CustomTab]
						, [FVTableID]
						, [DataType]
						, [MaxLen]
						, [NumPrecison]
						, [NumScale]
						, [fullDataType]
						, [OrdinalPosition]
						, [nullStmt]
						, [Object_ID]
						, [Base_object_ID]
						, [SynonymName]
					FROM
						(
							SELECT DISTINCT
								  DENSE_RANK() OVER(ORDER BY [NewStagingTablename]) [GroupTable]
								, DENSE_RANK() OVER(PARTITION BY [NewStagingTableName] ORDER BY FVTableID DESC) DRANK
								, [TABLE_SCHEMA]
								, [TABLE_NAME]
								, [Base_Table_Schema]
								, [Base_Table_Name]
								, [Meta_Table_Name]
								, [NewStagingTablename]
								, [ColumnName]
								, [FVTableID]
								, [DataType]
								, [MaxLen]
								, [NumPrecison]
								, [NumScale]
								, [fullDataType]
								, [OrdinalPosition]
								, [nullStmt]
								, [Object_ID]
								, [Base_object_ID]
								, CASE 
									WHEN LEFT([SynonymName], 1) = ''_''
									THEN RIGHT([SynonymName], LEN([SynonymName]) - 1)
								
									ELSE [SynonymName]
								  END [SynonymName]
							FROM
								(
									SELECT DISTINCT
										  [TABLE_SCHEMA]
										, [TABLE_NAME]
										, a.BASE_SCHEMA BASE_TABLE_SCHEMA
										, a.BASE_TABLE Base_TABLE_NAME
										, a.Meta_Table [Meta_Table_Name]
										, CASE
											WHEN PATINDEX(''%[a-z]%'', REVERSE(TABLE_NAME)) > 1
											THEN LEFT(TABLE_NAME, LEN(TABLE_NAME) - PATINDEX(''%[a-z]%'', REVERSE(TABLE_NAME)) + 1)
				
											ELSE ''''
										  END [NewStagingTablename]
										, COLUMN_NAME [ColumnName]
										, CONVERT(BIGINT, REVERSE(SUBSTRING(REVERSE(TABLE_NAME), 1, CHARINDEX(''_'', REVERSE(TABLE_NAME), 1) - 1))) [FVTableID]
										, UPPER(DATA_TYPE) [DataType]
										, CHARACTER_MAXIMUM_LENGTH [MaxLen]
										, NUMERIC_PRECISION [NumPrecison]
										, NUMERIC_SCALE [NumScale]
										, CASE
											WHEN UPPER(DATA_TYPE) = ''DECIMAL''
											THEN UPPER(DATA_TYPE) + ''('' + CONVERT(NVARCHAR(25), NUMERIC_PRECISION) + '','' + CONVERT(NVARCHAR(25), NUMERIC_SCALE) + '')''
				
											WHEN UPPER(DATA_TYPE) LIKE ''%CHAR''
											THEN UPPER(DATA_TYPE) + ''('' +
												CASE
													WHEN CONVERT(NVARCHAR(25), CHARACTER_MAXIMUM_LENGTH) = ''-1''
													THEN ''MAX''
						
													ELSE CONVERT(NVARCHAR(25), CHARACTER_MAXIMUM_LENGTH)
												END + '')''
				
											ELSE UPPER(DATA_TYPE)
										  END [fullDataType]
										, ORDINAL_POSITION [OrdinalPosition]
										, CASE
											WHEN IS_NULLABLE = ''NO''
											THEN '' NOT NULL ''
				
											ELSE '' NULL ''
										  END nullStmt
										, OBJECT_ID(''['' + TABLE_CATALOG + ''].['' + TABLE_SCHEMA + ''].['' + TABLE_NAME + '']'') [Object_ID]
										, OBJECT_ID(''['' + TABLE_CATALOG + ''].['' + a.BASE_SCHEMA + ''].['' + a.BASE_TABLE + '']'') [Base_object_ID]
										, REPLACE(LEFT(TABLE_NAME, LEN(TABLE_NAME) - PATINDEX(''%[a-z]%'', REVERSE(TABLE_NAME)) + 1), ''' + @prefix + ''', '''')  [SynonymName]
									FROM
										' + @ImportDatabaseName + '.[INFORMATION_SCHEMA].COLUMNS c
											OUTER APPLY
											(
												SELECT TOP 1
													*
												FROM
													' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ImportTableMapTable + '] b
												WHERE
														c.table_schema = b.view_schema
													AND c.table_name = b.view_name
											) a
									WHERE
											TABLE_CATALOG = ''' + @ImportDatabaseName + '''
										AND TABLE_SCHEMA = ''' + @SchemaName + '''
										AND TABLE_SCHEMA NOT IN (''' + @BaseImportSchema + ''')
										AND CHARINDEX(''' + @prefix + ''', TABLE_NAME, 1) > 0
								) a
						) list
					WHERE
						DRANK = 1
				'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [' + @PT1Schema + '].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQLn
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END

		-----------------------------------------------------------------------------------------------------------------------
		----	START CLONING TABLES	   ------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------------
		BEGIN
			SET @StepName = 'Staging tables for ' + @Database + ''
			SET @SubStepName = 'Inside Loop'

			IF @DebugFlag = @True
				PRINT @StepName + ' - ' + @SubStepName

			/*Loop Variables*/
			SET @SQL1 = @LegacyUse + 
				N' 
					DECLARE 
						  @totalTables INT = (SELECT MAX(DISTINCT GroupTable) FROM [' + @PT1Schema + '].[' + @MigrationConfigTable + '])
						, @processGroupNumber INT = 1
						, @newStageTable VARCHAR(500)
						, @oldStageTable VARCHAR(500)
						, @BaseTableSchema VARCHAR(500)
						, @BaseTableName VARCHAR(500)
						, @MetaTableName VARCHAR(500)
						, @synonymName VARCHAR(500)
						, @SQL NVARCHAR(MAX)
						, @SubStepName VARCHAR(500)
						, @ErrorMsg NVARCHAR(2048) = N''''
						, @ErrorCode INT = 0 
						, @DebugFlag INT
						, @collist VARCHAR(MAX)
						, @SqlContraint VARCHAR(MAX)
						, @ObjectID VARCHAR(MAX)
						, @BaseObjectID VARCHAR(MAX)
						, @SQLWrapper NVARCHAR(MAX) = N''''
						, @WorkingUse VARCHAR(1000) = ''' + @WorkingUse + '''
						, @LegacyUse VARCHAR(1000) = ''' + @LegacyUse + '''
						, @PT1Schema VARCHAR(1000) = ''' + @PT1Schema + '''
						, @MigrationProcessStatusTable VARCHAR(1000) = ''' + @MigrationProcessStatusTable + '''
						, @isCustomTab BIT
	  			'
			
			/*Drop constraints and table*/
			SET @SQL2 = 
				'
					SET @DebugFlag = ' + CONVERT(VARCHAR(1), @DebugFlag) + ' 
	
					WHILE @processGroupNumber <= @totalTables
						BEGIN
							SELECT TOP 1
								  @newStageTable = NewStagingTablename 
								, @oldStageTable = TABLE_NAME
								, @BaseTableSchema = [Base_Table_Schema]
								, @BaseTableName = [Base_Table_Name]
								, @MetaTableName = [Meta_Table_Name]
								, @synonymName = SynonymName
								, @objectID = [Object_ID]
								, @BaseObjectID = [Base_Object_ID]
								, @IsCustomTab = CustomTab
							FROM 
								[' + @PT1Schema + '].[' + @MigrationConfigTable + '] 
							WHERE 
								GroupTable = @processGroupNumber  
		
							SET @SubStepName = ''Remove the existing table for ['' + @newStageTable + '']'';
							
							IF @DebugFlag = ' + CONVERT(VARCHAR, @True) + '
								PRINT @SubStepName

							DECLARE 
								@TaskName VARCHAR(1000) = ''' + @StepName + ''' + '' - ['' + @newStageTable + '']''
       	
							SET @SQL =	
								N'' 
									USE ' + @DatabaseBrackets + ' 
   								
									IF OBJECT_ID(N''''' + @SchemaName + '.['' + @newStageTable + '']''+'''''') IS NOT NULL
										BEGIN
											WHILE 0 = 0
												BEGIN
													DECLARE 
														  @constraintName VARCHAR(128)
														, @constraintDefinition VARCHAR(MAX)
														, @alterSQL VARCHAR(MAX)
						
													SET @constraintName = 
														(
															SELECT TOP 1 
																constraint_name
															FROM
																information_schema.constraint_column_usage
															WHERE 
																table_name = '''''' + @newStageTable + '''''' 
														)
													
													SET @alterSQL = ''''ALTER TABLE ['' + @newStageTable + '']  DROP CONSTRAINT ['''' + @constraintName + '''']''''

													IF ' + CONVERT(VARCHAR, @DebugFlag) + ' = ' + CONVERT(VARCHAR, @True) + '
														PRINT @alterSQL

													IF @constraintName IS NOT NULL
														BEGIN
															EXEC (@alterSQL)
														END
													ELSE
														BREAK 
			   									END	

											IF ' + CONVERT(VARCHAR, @DebugFlag) + ' = ' + CONVERT(VARCHAR, @True) + '
												PRINT ''''DROP TABLE '''' + ''''['' + @newStageTable + '']''''
											
											DROP TABLE ' + @SchemaName + '.['' + @newStageTable + ''];
										END
								''
				'

			/*execute*/
			SET @SQL3 =
				'
							BEGIN
								SET @SQLWrapper = @WorkingUse + 
									''
										EXEC [' + @ExecutionDB + '].[PT1].[usp_PT1_DynamicSQL_Wrapper]
											  @SQLCode = @SQLWrapper 
											, @DatabaseBrackets = @DatabaseBrackets
											, @ExecutionDB = @ExecutionDB
											, @ProcName = @ProcName
											, @StepName = @StepName
											, @SubStepName = @SubStepName
											, @DebugFlag = @DebugFlag
											, @PT1Schema = @PT1Schema
											, @MigrationProcessStatusTable = @MigrationProcessStatusTable
									''

								EXEC sp_executesql
									  @SQLWrapper
									, N''@SQLWrapper VARCHAR(MAX)
									  , @DatabaseBrackets VARCHAR(1000)
									  , @ExecutionDB VARCHAR(1000)
									  , @ProcName VARCHAR(1000)
									  , @StepName VARCHAR(1000)
									  , @SubStepName VARCHAR(1000)
									  , @DebugFlag BIT
									  , @PT1Schema VARCHAR(1000)
									  , @MigrationProcessStatusTable VARCHAR(1000)''
									, @SQLWrapper = @SQL
									, @DatabaseBrackets = ''' + @DatabaseBrackets + '''
									, @ExecutionDB = ''' + @ExecutionDB + '''
									, @ProcName = ''' + @ProcName + '''
									, @StepName = @TaskName
									, @SubStepName = @SubStepName
									, @DebugFlag = @DebugFlag
									, @PT1Schema = @PT1Schema
									, @MigrationProcessStatusTable = @MigrationProcessStatusTable
							END
				'

			/*CLONE THE TABLE AND CREATE SYNONYM*/
			SET @SQL4 = 
				'
        					BEGIN
								SET @SubStepName = ''Create Table ['' + @newStageTable + ''] and Synonym ['' + @SynonymName + '']'';
							
								IF @DebugFlag = ' + CONVERT(VARCHAR, @True) + '
									PRINT @SubStepName

								DECLARE 
									  @SQLCreate NVARCHAR(MAX)
									, @SQLSynonym NVARCHAR(MAX)


								SELECT @SQLCreate = 
									N'' 
										USE ' + @DatabaseBrackets + ' 

										DECLARE
											@SQLSelectIntoTab TABLE
												(
													  ID BIGINT IDENTITY(1,1)
													, OrdinalPos BIGINT
													, ColumnName VARCHAR(MAX)
												)

										INSERT INTO
											@SQLSelectIntoTab
										SELECT
											  ORDINAL_POSITION
											, COLUMN_NAME
										FROM
											[' + @ImportDatabaseName + '].INFORMATION_SCHEMA.COLUMNS
										WHERE
												TABLE_NAME = '''''' + @oldStageTable + ''''''
											AND TABLE_SCHEMA = ''''dbo''''
											AND COLUMN_NAME NOT IN (''''__ID'''')

										DECLARE
											@SQLSelectIntoString VARCHAR(MAX) = ''''''''

										SELECT 
											@SQLSelectIntoString = COALESCE(@SQLSelectIntoString + '''','''', '''''''') + ''''['''' + ColumnName + '''']''''
										FROM
											@SQLSelectIntoTab
										ORDER BY
											OrdinalPos
										
										SET @SQLSelectIntoString =
											'''' 
												USE ' + @Database + '

												SELECT TOP 0
													  IDENTITY(BIGINT, 1, 1) AS [__ID] 
													 '''' + @SQLSelectIntoString + ''''
												INTO
													[dbo].['' + @newStageTable + '']
												FROM
													[' + @ImportDatabaseName + '].[dbo].['' + @oldStageTable + '']
											''''

										EXEC (@SQLSelectIntoString)
									''
									
								SELECT @SQLSynonym =
									N''
										USE ' + @DatabaseBrackets + '

										DROP SYNONYM IF EXISTS 
											[PT1].['' + @synonymName + '']
									
										CREATE SYNONYM 
											[PT1].['' + @synonymName + '']
										FOR
											[dbo].['' + @newStageTable + '']
									 ''

								SET @SQLCreate = @SQLCreate + @SQLSynonym
				'

			/*Execute*/
			SET @SQL5 = 
				'
								BEGIN
									SET @SQLWrapper = @WorkingUse + 
										''
											EXEC [' + @ExecutionDB + '].[PT1].[usp_PT1_DynamicSQL_Wrapper]
												  @SQLCode = @SQLWrapper 
												, @DatabaseBrackets = @DatabaseBrackets
												, @ExecutionDB = @ExecutionDB
												, @ProcName = @ProcName
												, @StepName = @StepName
												, @SubStepName = @SubStepName
												, @DebugFlag = @DebugFlag
												, @PT1Schema = @PT1Schema
												, @MigrationProcessStatusTable = @MigrationProcessStatusTable
										''

									EXEC sp_executesql
										  @SQLWrapper
										, N''@SQLWrapper VARCHAR(MAX)
										  , @DatabaseBrackets VARCHAR(1000)
										  , @ExecutionDB VARCHAR(1000)
										  , @ProcName VARCHAR(1000)
										  , @StepName VARCHAR(1000)
										  , @SubStepName VARCHAR(1000)
										  , @DebugFlag BIT
										  , @PT1Schema VARCHAR(1000)
										  , @MigrationProcessStatusTable VARCHAR(1000)''
										, @SQLWrapper = @SQLCreate
										, @DatabaseBrackets = ''' + @DatabaseBrackets + '''
										, @ExecutionDB = ''' + @ExecutionDB + '''
										, @ProcName = ''' + @ProcName + '''
										, @StepName = @TaskName
										, @SubStepName = @SubStepName
										, @DebugFlag = @DebugFlag
										, @PT1Schema = @PT1Schema
										, @MigrationProcessStatusTable = @MigrationProcessStatusTable
								END
							END
				'

			/*IF __ID is nullable, make non-nullable*/
			SET @SQL6 = 
				'
							BEGIN
								DECLARE
									  @SQLFixPK NVARCHAR(MAX) = ''''
									, @IDColumn VARCHAR(100) = (SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @newStageTable AND COLUMN_NAME = ''__ID'')
									, @IsNullableIDField BIT = (SELECT TOP 1 CASE WHEN IS_NULLABLE = ''YES'' THEN 1 ELSE 0 END FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @newStageTable AND COLUMN_NAME = ''__ID'')
									, @Datatype VARCHAR(100) = (SELECT TOP 1 DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @newStageTable AND COLUMN_NAME = ''__ID'')

								SET @SubStepName = ''Set PK to be NULL if NOT NULL for table ['' + @newStageTable + '']''

								IF @IsNullableIDField = ' + CONVERT(VARCHAR, @True) + '
									BEGIN
										SET @SQLFixPK =
											''
												USE ' + @DatabaseBrackets + '

												ALTER TABLE
													['' + @newStageTable + '']
												ALTER COLUMN
													'' + @IDColumn + ''
														'' + @Datatype + '' NOT NULL
											''
									END
				'

			/*Execute*/
			SET @SQL7 =
				'
								BEGIN
									SET @SQLWrapper = @WorkingUse + 
										''
											EXEC [' + @ExecutionDB + '].[PT1].[usp_PT1_DynamicSQL_Wrapper]
												  @SQLCode = @SQLWrapper 
												, @DatabaseBrackets = @DatabaseBrackets
												, @ExecutionDB = @ExecutionDB
												, @ProcName = @ProcName
												, @StepName = @StepName
												, @SubStepName = @SubStepName
												, @DebugFlag = @DebugFlag
												, @PT1Schema = @PT1Schema
												, @MigrationProcessStatusTable = @MigrationProcessStatusTable
										''

									EXEC sp_executesql
										  @SQLWrapper
										, N''@SQLWrapper VARCHAR(MAX)
										  , @DatabaseBrackets VARCHAR(1000)
										  , @ExecutionDB VARCHAR(1000)
										  , @ProcName VARCHAR(1000)
										  , @StepName VARCHAR(1000)
										  , @SubStepName VARCHAR(1000)
										  , @DebugFlag BIT
										  , @PT1Schema VARCHAR(1000)
										  , @MigrationProcessStatusTable VARCHAR(1000)''
										, @SQLWrapper = @SQLFixPK
										, @DatabaseBrackets = ''' + @DatabaseBrackets + '''
										, @ExecutionDB = ''' + @ExecutionDB + '''
										, @ProcName = ''' + @ProcName + '''
										, @StepName = @TaskName
										, @SubStepName = @SubStepName
										, @DebugFlag = @DebugFlag
										, @PT1Schema = @PT1Schema
										, @MigrationProcessStatusTable = @MigrationProcessStatusTable
								END
							END
				'

			/*CREATE PRIMARY KEY*/
			SET @SQL8 = 
				'
							BEGIN
								SET @SubStepName = ''Create Primary Key for ['' + @newStageTable + '']'';
							
								IF @DebugFlag = ' + CONVERT(VARCHAR, @True) + '
									PRINT @SubStepName

								DECLARE 
									  @PKSchema VARCHAR(MAX) = ''''
									, @PKName VARCHAR(MAX) = ''''
									, @NewPKName VARCHAR(MAX) = ''''
									, @PKSQL VARCHAR(MAX) = ''''
			
								SELECT TOP 1 
									  @PKSchema = CONSTRAINT_SCHEMA
									, @PKName = [tc].[CONSTRAINT_NAME]
									, @NewPKName = REPLACE(CONSTRAINT_NAME, @BaseTableName, @newStageTable) 
								FROM 
									[' + @ImportDatabaseName + '].INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
										INNER JOIN [' + @PT1Schema + '].[' + @MigrationConfigTable + '] mc
											on tc.table_schema = mc.base_table_Schema
											and tc.table_name = mc.base_table_name
								WHERE 
										tc.TABLE_SCHEMA = '''' + @BaseTableSchema + '''' 
									AND tc.TABLE_NAME = '''' + @BaseTableName + ''''
									AND CONSTRAINT_TYPE = ''PRIMARY KEY''

								IF ISNULL(@PKSchema, '''') IS NOT NULL AND ISNULL(@PKName, '''') IS NOT NULL
									BEGIN
										DECLARE 
											@PKColumns NVARCHAR(MAX) = ''''
							
										SELECT 
											@PKColumns = @PKColumns + ''['' + CU.COLUMN_NAME + ''] ,''
										FROM 
											[' + @ImportDatabaseName + '].INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU
												INNER JOIN [' + @ImportDatabaseName + '].INFORMATION_SCHEMA.COLUMNS co
													on cu.COLUMN_NAME = co.COLUMN_NAME
													AND co.TABLE_NAME = '''' + @BaseTableName + ''''
													AND co.TABLE_SCHEMA = '''' + @BaseTableSchema + ''''
										WHERE 
												CU.TABLE_NAME = '''' + @BaseTableName + ''''
											AND CU.TABLE_SCHEMA = '''' + @BaseTableSchema + '''' 
											AND CONSTRAINT_SCHEMA = @PKSchema 
											AND CONSTRAINT_NAME = @PKName
										ORDER BY 
											CU.ORDINAL_POSITION

										IF NULLIF(@PKColumns, '''') IS NOT NULL
											BEGIN
												SET @PKColumns = LEFT(@PKColumns, LEN(@PKColumns) - 1)

												SET @PKSQL = @LegacyUse +  
													''
														ALTER TABLE 
															[dbo].['' + @newStageTable + ''] 
														ADD CONSTRAINT 
															['' + @NewPKName + '']
														PRIMARY KEY CLUSTERED 
															('' + @PKColumns + '')
													''
											END
									END	
								
									SET @SubStepName = @SubStepName + '' - '' + @PKName

									IF @DebugFlag = ' + CONVERT(VARCHAR, @True) + '
										PRINT @SubStepName
				'

			/*Execute*/
			SET @SQL9 =
				'
									BEGIN
										SET @SQLWrapper = @WorkingUse + 
											''
												EXEC [' + @ExecutionDB + '].[PT1].[usp_PT1_DynamicSQL_Wrapper]
													  @SQLCode = @SQLWrapper 
													, @DatabaseBrackets = @DatabaseBrackets
													, @ExecutionDB = @ExecutionDB
													, @ProcName = @ProcName
													, @StepName = @StepName
													, @SubStepName = @SubStepName
													, @DebugFlag = @DebugFlag
													, @PT1Schema = @PT1Schema
													, @MigrationProcessStatusTable = @MigrationProcessStatusTable
											''

										EXEC sp_executesql
											  @SQLWrapper
											, N''@SQLWrapper VARCHAR(MAX)
											  , @DatabaseBrackets VARCHAR(1000)
											  , @ExecutionDB VARCHAR(1000)
											  , @ProcName VARCHAR(1000)
											  , @StepName VARCHAR(1000)
											  , @SubStepName VARCHAR(1000)
											  , @DebugFlag BIT
											  , @PT1Schema VARCHAR(1000)
											  , @MigrationProcessStatusTable VARCHAR(1000)''
											, @SQLWrapper = @PKSQL
											, @DatabaseBrackets = ''' + @DatabaseBrackets + '''
											, @ExecutionDB = ''' + @ExecutionDB + '''
											, @ProcName = ''' + @ProcName + '''
											, @StepName = @TaskName
											, @SubStepName = @SubStepName
											, @DebugFlag = @DebugFlag
											, @PT1Schema = @PT1Schema
											, @MigrationProcessStatusTable = @MigrationProcessStatusTable
									END

							END
				' 

			/*CREATE OTHER INDEXES*/
			SET @SQL10 = 
				'
							BEGIN
								DECLARE
									@SQLIDX VARCHAR(MAX)

								DECLARE
									@IDXTab TABLE
									(
										  ID BIGINT IDENTITY(1,1) NOT NULL
										, IndexID BIGINT
										, IndexName VARCHAR(MAX)
										, isUnique BIT
										, isUniqueConstraint BIT
										, filterDefinition VARCHAR(MAX)
										, [clustered] BIT
										, CustomTab BIT
									)

								DELETE FROM @IDXTab

								INSERT INTO
									@IDXTab
									(
										  IndexID
										, IndexName
										, isUnique
										, isUniqueConstraint
										, filterDefinition
										, [clustered]
										, CustomTab
									)
								SELECT DISTINCT
									  [index_id]
									, REPLACE([i].[name], @BaseTableName, @newStageTable) [name]
									, is_unique
									, is_unique_constraint
									, filter_definition 
									, CASE
										WHEN type_desc = ''CLUSTERED''
										THEN 1

										ELSE 0
									  END [clustered]
									, CustomTab
								FROM 
									[' + @ImportDatabaseName + '].sys.indexes i
										INNER JOIN ['+ @PT1Schema + '].[' + @MigrationConfigTable + '] mc
											ON i.object_ID = mc.Base_object_ID
								WHERE 
										type = 2 
									AND i.object_id = @BaseobjectID
									AND mc.NewStagingTableName = @newStageTable
									AND mc.CustomTab = ' + CONVERT(VARCHAR, @False) + '
								UNION
								SELECT TOP 1
									  a.Index_ID
									, a.[Name]
									, a.is_Unique
									, a.is_Unique_Constraint
									, a.filter_Definition
									, a.[clustered]
									, a.CustomTab
								FROM
									(
										SELECT TOP 1
											  (SELECT ISNULL(MAX(index_id), 0) FROM sys.indexes i WHERE i.object_ID = mc.Base_Object_ID) + ROW_NUMBER() OVER(ORDER BY TABLE_NAME) [index_id]
											, ''idx_uq__'' + @newStageTable + ''_'' + [mc].[COLUMN_NAME] [name]
											, ' + CONVERT(VARCHAR, @True) + ' [is_unique]
											, ' + CONVERT(VARCHAR, @True) + ' [is_unique_constraint]
											, NULL [filter_definition]
											, ' + CONVERT(VARCHAR, @True) + ' [clustered]
											, CustomTab [CustomTab]
											, ORDINAL_POSITION
										FROM 
											['+ @PT1Schema + '].[' + @MigrationConfigTable + '] mc
										WHERE 
												mc.NewStagingTablename = @newStageTable
											AND [mc].[CustomTab] = ' + CONVERT(VARCHAR, @True) + '
											AND [mc].[COLUMN_NAME] LIKE ''%externalID%''
										ORDER BY
											ORDINAL_POSITION
									) a;

								DECLARE
									  @MAXID BIGINT = (SELECT MAX(ID) FROM @IDXTab)
									, @Counter BIGINT = 1
				'

			/*begin loop*/
			SET @SQL11 = 
				'
								WHILE @Counter <= @MAXID
									BEGIN
										SET @SubStepName = ''Create Index for ['' + @newStageTable + '']'';
							
										DECLARE 
											  @Unique VARCHAR(MAX) = (SELECT CASE WHEN isUnique = 1 THEN '' UNIQUE'' ELSE '''' END FROM @IDXTab WHERE ID = @Counter)
											, @IndexID BIGINT = (SELECT IndexID FROM @IDXTab WHERE ID = @Counter)
											, @indexName VARCHAR(MAX) = (SELECT IndexName FROM @IDXTab WHERE ID = @Counter)
											, @FilterDefinition VARCHAR(MAX) = (SELECT FilterDefinition FROM @IDXTab WHERE ID = @Counter)
											, @isUniqueConstraint BIT = (SELECT isUniqueConstraint FROM @IDXTab WHERE ID = @Counter)
											, @KeyColumns NVARCHAR(MAX) = ''''
											, @IncludedColumns NVARCHAR(MAX) = ''''
											, @IsClustered BIT = (SELECT [clustered] FROM @IDXTab WHERE ID = @Counter)
											, @IsCustomTabLoop BIT = (SELECT CustomTab FROM @IDXTab WHERE ID = @Counter)

										IF @IsCustomTabLoop = 1
										BEGIN
											SELECT
												@KeyColumns =
												(
													SELECT TOP 1 
														COLUMN_NAME  + '','' 
													FROM 
														' + @DatabaseBrackets + '.INFORMATION_SCHEMA.COLUMNS 
													WHERE 
															TABLE_NAME = @NewStageTable
														AND COLUMN_NAME LIKE ''%ExternalID%''
													ORDER BY
														ORDINAL_POSITION
												);
										END

										IF @IsCustomTabLoop = 0
										BEGIN
										SELECT
											@KeyColumns = COALESCE(@KeyColumns + ''['' + c.name + ''] '' + CASE WHEN is_descending_key = 1 THEN ''DESC'' ELSE ''ASC'' END, '''' ) + '','' 
										FROM 
											[' + @ImportDatabaseName + '].sys.index_columns ic
												INNER JOIN [' + @ImportDatabaseName + '].sys.columns c 
													ON c.object_id = ic.object_id 
													AND c.column_id = ic.column_id
										WHERE 
												index_id = @IndexId 
											AND ic.object_id = @BaseobjectID
											AND key_ordinal > 0
										ORDER BY
											index_column_id
										END

										SELECT
											  @KeyColumns = CASE WHEN LEN(@KeyColumns) > 0 THEN LEFT(@keyColumns, LEN(@keyColumns) - 1) ELSE '''' END
											, @includedColumns = CASE WHEN LEN(@includedColumns) > 0 THEN '' INCLUDE ('' + LEFT(@includedColumns, LEN(@includedColumns) - 1) + '')'' ELSE '''' END
											, @filterDefinition = CASE WHEN @filterDefinition IS NOT NULL THEN '' WHERE '' + @filterDefinition + '' '' ELSE '''' END

				'

			SET @SQL12 = 
				'
										IF @IsUniqueConstraint = 0
											BEGIN
												SET @SQLIDX = @LegacyUse +
													''
														CREATE '' + @Unique + '' NONCLUSTERED INDEX 
															['' + @IndexName + ''] 
														ON 
															[dbo].['' + @newStageTable + ''] ('' + @KeyColumns + '')'' 
														+ @IncludedColumns 
														+ @FilterDefinition + ''
													''
											END
										ELSE
											BEGIN
												SET @SQLIDX = @LegacyUse +
													''
														ALTER TABLE 
															[dbo].['' + @newStageTable + ''] 
														ADD CONSTRAINT 
															['' + @IndexName + ''] 
														UNIQUE NONCLUSTERED ('' + @KeyColumns + '')
													''
											END
										
				'
				
			/*execute*/
			SET @SQL13 = 
				'
										BEGIN
											SET @SubStepName = @SubStepName + '' - ['' + @IndexName + '']''
										
											SET @SQLWrapper = @WorkingUse + 
												''
													EXEC [' + @ExecutionDB + '].[PT1].[usp_PT1_DynamicSQL_Wrapper]
														  @SQLCode = @SQLWrapper 
														, @DatabaseBrackets = @DatabaseBrackets
														, @ExecutionDB = @ExecutionDB
														, @ProcName = @ProcName
														, @StepName = @StepName
														, @SubStepName = @SubStepName
														, @DebugFlag = @DebugFlag
														, @PT1Schema = @PT1Schema
														, @MigrationProcessStatusTable = @MigrationProcessStatusTable
												''

											EXEC sp_executesql
												  @SQLWrapper
												, N''@SQLWrapper VARCHAR(MAX)
												  , @DatabaseBrackets VARCHAR(1000)
												  , @ExecutionDB VARCHAR(1000)
												  , @ProcName VARCHAR(1000)
												  , @StepName VARCHAR(1000)
												  , @SubStepName VARCHAR(1000)
												  , @DebugFlag BIT
												  , @PT1Schema VARCHAR(1000)
												  , @MigrationProcessStatusTable VARCHAR(1000)''
												, @SQLWrapper = @SQLIDX
												, @DatabaseBrackets = ''' + @DatabaseBrackets + '''
												, @ExecutionDB = ''' + @ExecutionDB + '''
												, @ProcName = ''' + @ProcName + '''
												, @StepName = @TaskName
												, @SubStepName = @SubStepName
												, @DebugFlag = @DebugFlag
												, @PT1Schema = @PT1Schema
												, @MigrationProcessStatusTable = @MigrationProcessStatusTable
										END

										SET @Counter = @Counter + 1
									END
							END
				'
			
			

			/*ADD OTHER CONSTRAINTS*/
			SET @SQL14 =
				'
							BEGIN
								DECLARE 
									  @SQLn NVARCHAR(MAX)
									, @SQLn1 VARCHAR(MAX)
									, @SQLn2 VARCHAR(MAX)
									, @SQLn3 VARCHAR(MAX)

								SET @SQLn1 =
									''
										DECLARE 
											  @SQLCon1 VARCHAR(MAX) = ''''''''
											, @SQLCon2 VARCHAR(MAX) = ''''''''

										DECLARE
											@CONTab TABLE
											(
												  ID BIGINT IDENTITY(1,1) NOT NULL
												, ConstraintName VARCHAR(MAX)
												, CheckClause VARCHAR(MAX)
											)

										DELETE FROM @CONTab	

										INSERT INTO
											@CONTab
											(
												  ConstraintName
												, CheckClause
											)
										SELECT DISTINCT
											  chk.name
											, chk.definition 
										FROM 
											[' + @ImportDatabaseName + '].sys.check_constraints chk
												INNER JOIN [' + @ImportDatabaseName + '].sys.tables st 
													ON chk.parent_object_id = st.object_id
												INNER JOIN ' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @MigrationConfigTable + '] mc 
													ON st.object_id = mc.Base_OBJECT_ID 
													AND mc.CustomTab = ' + CONVERT(VARCHAR, @False) + '
										WHERE
											st.name = '''''' + @basetablename + ''''''
									''
									+ CASE 
										WHEN NULLIF(@MetaTableName, '''') IS NOT NULL
										THEN
											''
										UNION
										SELECT DISTINCT 
											  ''''chk_'''' + mc.base_table_name + ''''_'''' + filevineFieldName
											, CASE
												WHEN filevineCustomFieldType IN (''''Dropdown'''', ''''multiselectlist'''', ''''MultipleChoice'''') AND filevineconstraintlist LIKE ''''%selectitems%''''
												THEN REPLACE(
													REPLACE(
													REPLACE(
													REPLACE(
														filevineconstraintlist
													, ''''{"selectItems": ["'''', ''''(['''' + FilevinefieldName + ''''] = '''''''''''')
													, ''''{"selectItems":["'''', ''''(['''' + FilevinefieldName + ''''] = '''''''''''')
													, ''''"]}'''', '''''''''''')'''')
													, ''''","'''', '''''''''''' OR [''''+ FilevinefieldName + ''''] = '''''''''''')

												WHEN filevineCustomFieldType IN (''''Dropdown'''', ''''multiselectlist'''', ''''MultipleChoice'''') AND filevineconstraintlist NOT LIKE ''''%selectitems%''''
												THEN ''''(['''' + FilevinefieldName + ''''] = '''''''''''' + REPLACE(filevineconstraintlist, '''''''''''','''''''''''', '''''''''''' OR ['''' + FilevinefieldName + ''''] = '''') + '''')''''

												ELSE ''''''''
											  END
										FROM 
											' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @MigrationConfigTable + '] mc
												OUTER APPLY
													(
														SELECT 
															  m.persontabID
															, persontabtitle
															, personfieldID
															, filevinefieldname
															, REPLACE(filevineconstraintlist,'''''''''''''''','''''''''''''''''''''''') AS filevineconstraintlist
															, filevinecustomfieldtype
														FROM 
															[' + @ImportDatabaseName + '].[' + @AuditImportSchema + '].[' + @ImportSQLAuditTable + '] i
																INNER JOIN [' + @ImportDatabaseName + '].[' + @BaseImportSchema + '].['' + @MetaTableName + ''] m
															ON i.tabID = ISNULL(m.persontabID, 0)
															/*AND i.fieldid = ISNULL(m.personfieldID, 0)*/
														WHERE 
																mc.base_table_schema + ''''.'''' + mc.Base_table_name = LTRIM(RTRIM(REPLACE(REPLACE(i.BASE_TABLE_NAME, ''''['''', ''''''''), '''']'''', '''''''')))
															AND i.status = ''''COMPLETED''''
															AND i.tabID != 0
														GROUP BY 
															  m.persontabID
															, persontabtitle
															, personfieldID
															, filevinefieldname
															, filevineconstraintlist
															, filevinecustomfieldtype
													) i
										WHERE 
												mc.Base_Table_Name = '''''' + @basetablename + ''''''
											AND mc.NewStagingTableName = '''''' + @NewStageTable + ''''''
											AND mc.table_name LIKE ''''%'''' + persontabtitle + ''''%''''
											AND mc.Column_name = i.filevinefieldname
											AND NULLIF(filevineconstraintlist, '''''''') IS NOT null 
											AND filevinecustomfieldTYPE IN (''''Dropdown'''', ''''MultipleChoice'''', ''''MultiSelectList'''')
											''

										ELSE ''''
									 END 

								SET @SQLn2 = 
									''
										DECLARE 
										  @ConCounter BIGINT = 1
										, @MaxConID BIGINT = (SELECT MAX(ID) FROM @CONTab)
				'

			/*Loop*/
			SET @SQL15 =
				'
										WHILE @ConCounter <= @MaxConID
											BEGIN
												DECLARE
													  @SubStepName VARCHAR(1000)
													, @SQLWrapper NVARCHAR(MAX)

												SET @SubStepName = ''''Create Constraint for ['' + @newStageTable + '']'''';
							
												DECLARE
													  @ConName VARCHAR(MAX) = (SELECT TOP 1 ConstraintName FROM @ConTab WHERE ID = @ConCounter)
													, @ConCheck VARCHAR(MAX) = (SELECT TOP 1 CheckClause FROM @ConTab WHERE ID = @ConCounter)
									
												SET @SQLCon1 = '''''' + @LegacyUse + '''''' +
													''''
														ALTER TABLE 
															[dbo].['' + @NewStageTable + ''] 
														WITH CHECK 
														ADD CONSTRAINT 
															['''' + @ConName + ''''] 
														CHECK 
															'''' + @ConCheck + '''';
													''''

												SET @SQLCon2 = '''''' + @LegacyUse + '''''' +
													''''
														ALTER TABLE 
															[dbo].['' + @NewStageTable + ''] 
														CHECK CONSTRAINT 
															['''' + @ConName + ''''];
													''''
									''

								SET @SQLn3 =
									''
												BEGIN
													SET @SubStepName = @SubStepName + '''' - '''' + @ConName

													SET @SQLWrapper = '''''' + @WorkingUse + '''''' + 
														''''
															EXEC [' + @ExecutionDB + '].[PT1].[usp_PT1_DynamicSQL_Wrapper]
																  @SQLCode = @SQLWrapper 
																, @DatabaseBrackets = @DatabaseBrackets
																, @ExecutionDB = @ExecutionDB
																, @ProcName = @ProcName
																, @StepName = @StepName
																, @SubStepName = @SubStepName 
																, @DebugFlag = @DebugFlag
																, @PT1Schema = @PT1Schema
																, @MigrationProcessStatusTable = @MigrationProcessStatusTable
														''''

													EXEC sp_executesql
														  @SQLWrapper
														, N''''@SQLWrapper VARCHAR(MAX)
														  , @DatabaseBrackets VARCHAR(1000)
														  , @ExecutionDB VARCHAR(1000)
														  , @ProcName VARCHAR(1000)
														  , @StepName VARCHAR(1000)
														  , @SubStepName VARCHAR(1000)
														  , @DebugFlag BIT
														  , @PT1Schema VARCHAR(1000)
														  , @MigrationProcessStatusTable VARCHAR(1000)''''
														, @SQLWrapper = @SQLCon1
														, @DatabaseBrackets = ''''' + @DatabaseBrackets + '''''
														, @ExecutionDB = ''''' + @ExecutionDB + '''''
														, @ProcName = ''''' + @ProcName + '''''
														, @StepName = '''''' + @TaskName + ''''''
														, @SubStepName = '''''' + @SubStepName + ''''''
														, @DebugFlag = '''''' + CONVERT(VARCHAR, @DebugFlag) + ''''''
														, @PT1Schema = '''''' + @PT1Schema + ''''''
														, @MigrationProcessStatusTable = '''''' + @MigrationProcessStatusTable + ''''''

													SET @SubStepName = REPLACE(@SubStepName, ''''Create Constraint'''', ''''Check Constraint'''')

													SET @SQLWrapper = '''''' + @WorkingUse + '''''' + 
														''''
															EXEC [' + @ExecutionDB + '].[PT1].[usp_PT1_DynamicSQL_Wrapper]
																  @SQLCode = @SQLWrapper 
																, @DatabaseBrackets = @DatabaseBrackets
																, @ExecutionDB = @ExecutionDB
																, @ProcName = @ProcName
																, @StepName = @StepName
																, @SubStepName = @SubStepName
																, @DebugFlag = @DebugFlag
																, @PT1Schema = @PT1Schema
																, @MigrationProcessStatusTable = @MigrationProcessStatusTable
														''''

													EXEC sp_executesql
														  @SQLWrapper
														, N''''@SQLWrapper VARCHAR(MAX)
														  , @DatabaseBrackets VARCHAR(1000)
														  , @ExecutionDB VARCHAR(1000)
														  , @ProcName VARCHAR(1000)
														  , @StepName VARCHAR(1000)
														  , @SubStepName VARCHAR(1000)
														  , @DebugFlag BIT
														  , @PT1Schema VARCHAR(1000)
														  , @MigrationProcessStatusTable VARCHAR(1000)''''
														, @SQLWrapper = @SQLCon2
														, @DatabaseBrackets = ''''' + @DatabaseBrackets + '''''
														, @ExecutionDB = ''''' + @ExecutionDB + '''''
														, @ProcName = ''''' + @ProcName + '''''
														, @StepName = '''''' + @TaskName + ''''''
														, @SubStepName = '''''' + @SubStepName + ''''''
														, @DebugFlag = '''''' + CONVERT(VARCHAR, @DebugFlag) + ''''''
														, @PT1Schema = '''''' + @PT1Schema + ''''''
														, @MigrationProcessStatusTable = '''''' + @MigrationProcessStatusTable + ''''''
												END
								
												SET @ConCounter = @ConCounter + 1
											END
									''
								
								SET @SQLn =
									  @SQLn1
									+ @SQLn2
									+ @SQLn3

								SET @SubStepName = REPLACE(@SubStepName, ''Create Constraint'', ''Build Constraint SQL'')

								SET @SQLWrapper = @WorkingUse + 
									''
										EXEC [' + @ExecutionDB + '].[PT1].[usp_PT1_DynamicSQL_Wrapper]
											  @SQLCode = @SQLWrapper 
											, @DatabaseBrackets = @DatabaseBrackets
											, @ExecutionDB = @ExecutionDB
											, @ProcName = @ProcName
											, @StepName = @StepName
											, @SubStepName = @SubStepName
											, @DebugFlag = @DebugFlag
											, @PT1Schema = @PT1Schema
											, @MigrationProcessStatusTable = @MigrationProcessStatusTable
									''

								EXEC sp_executesql
									  @SQLWrapper
									, N''@SQLWrapper VARCHAR(MAX)
									   , @DatabaseBrackets VARCHAR(1000)
									   , @ExecutionDB VARCHAR(1000)
									   , @ProcName VARCHAR(1000)
									   , @StepName VARCHAR(1000)
									   , @SubStepName VARCHAR(1000)
									   , @DebugFlag BIT
									   , @PT1Schema VARCHAR(1000)
									   , @MigrationProcessStatusTable VARCHAR(1000)''
									, @SQLWrapper = @SQLn
									, @DatabaseBrackets = ''' + @DatabaseBrackets + '''
									, @ExecutionDB = ''' + @ExecutionDB + '''
									, @ProcName = ''' + @ProcName + '''
									, @StepName = @TaskName
									, @SubStepName = @SubStepName
									, @DebugFlag = @DebugFlag
									, @PT1Schema = @PT1Schema
									, @MigrationProcessStatusTable = @MigrationProcessStatusTable
							END
				'

			/*Disable indexes*/
			SET @SQL16 = 
				'
							BEGIN
								SET @SubStepName = ''Disable all indexes for table '' + @newStageTable

								DECLARE
									@TempDisableIndexes TABLE
										(
											  ID BIGINT IDENTITY(1,1)
											, IndexName VARCHAR(MAX)
											, IndexType VARCHAR(MAX)
											, isPK BIT
											, indexID BIGINT
											, tablename VARCHAR(MAX)
											, schemaname varchar(max)
										)

								DELETE FROM @TempDisableIndexes

								INSERT INTO 
									@TempDisableIndexes 
										(
											  IndexName
											, IndexType
											, isPK
											, indexID
											, tablename
											, schemaname
										)
								SELECT DISTINCT
									  i.name
									, i.type_desc
									, i.is_primary_key
									, index_ID
									, t.name
									, ''dbo''
								FROM
									' + @DatabaseBrackets + '.sys.indexes i 
										INNER JOIN ' + @DatabaseBrackets + '.sys.tables t 
											ON i.[object_id] = t.[object_id]
										INNER JOIN ' + @DatabaseBrackets + '.[' + @pt1Schema + '].[' + @MigrationConfigTable + '] mc
											ON mc.NewStagingTablename = t.name
								WHERE
										mc.NewStagingTableName = @newStageTable
									AND i.is_primary_key = ' + CONVERT(VARCHAR, @False) + '
								ORDER BY
									  t.name
									, i.index_ID
								
								DECLARE 
									  @IndexLoopCounter BIGINT = 1
									, @IndexLoopMaxID BIGINT = (SELECT MAX(ID) FROM @TempDisableIndexes)
									, @SqlDisable NVARCHAR(MAX)

								WHILE @IndexLoopCounter <= @IndexLoopMaxID
									BEGIN
										DECLARE 
											  @DisableIndexName VARCHAR(MAX) = (SELECT IndexName FROM @TempDisableIndexes WHERE ID = @IndexLoopCounter)
											, @DisableTableName VARCHAR(MAX) = (SELECT tablename FROM @TempDisableIndexes WHERE ID = @IndexLoopCounter)
											, @DisableSchemaName VARCHAR(MAX) = (SELECT schemaname FROM @TempDisableIndexes WHERE ID = @IndexLoopCounter)
										
										SET @SqlDisable =  
											''
												USE ' + @DatabaseBrackets + '
										
												ALTER INDEX 
													['' + @DisableIndexName + '']
													ON ['' + @DisableSchemaName + ''].['' + @DisableTableName + ''] 
												DISABLE;
											''
				'

			/*execute*/
			SET @SQL17 =
				'
										BEGIN
											SET @SQLWrapper = @WorkingUse + 
												''
													EXEC [' + @ExecutionDB + '].[PT1].[usp_PT1_DynamicSQL_Wrapper]
														  @SQLCode = @SQLWrapper 
														, @DatabaseBrackets = @DatabaseBrackets
														, @ExecutionDB = @ExecutionDB
														, @ProcName = @ProcName
														, @StepName = @StepName
														, @SubStepName = @SubStepName
														, @DebugFlag = @DebugFlag
														, @PT1Schema = @PT1Schema
														, @MigrationProcessStatusTable = @MigrationProcessStatusTable
												''

											EXEC sp_executesql
													@SQLWrapper
												, N''@SQLWrapper VARCHAR(MAX)
													, @DatabaseBrackets VARCHAR(1000)
													, @ExecutionDB VARCHAR(1000)
													, @ProcName VARCHAR(1000)
													, @StepName VARCHAR(1000)
													, @SubStepName VARCHAR(1000)
													, @DebugFlag BIT
													, @PT1Schema VARCHAR(1000)
													, @MigrationProcessStatusTable VARCHAR(1000)''
												, @SQLWrapper = @SqlDisable
												, @DatabaseBrackets = ''' + @DatabaseBrackets + '''
												, @ExecutionDB = ''' + @ExecutionDB + '''
												, @ProcName = ''' + @ProcName + '''
												, @StepName = @TaskName
												, @SubStepName = @SubStepName
												, @DebugFlag = @DebugFlag
												, @PT1Schema = @PT1Schema
												, @MigrationProcessStatusTable = @MigrationProcessStatusTable
									
										SET @IndexLoopCounter = @IndexLoopCounter + 1
									END
								END

							END
				' 

			SET @SQL18 =
				'
							SET @processGroupNumber = @processGroupNumber + 1
						END 
				'

			SET @SQL = 
				  @SQL1 
				+ @SQL2 
				+ @SQL3 
				+ @SQL4 
				+ @SQL5
				+ @SQL6
				+ @SQL7
				+ @SQL8
				+ @SQL9
				+ @SQL10
				+ @SQL11
				+ @SQL12
				+ @SQL13
				+ @SQL14
				+ @SQL15
				+ @SQL16
				+ @SQL17
				+ @SQL18
				+ @SQL19
				+ @SQL20

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQL
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END

		/*log some additional metdata*/
		BEGIN
			/*If new category type, insert record*/
			SET @StepName = 'New Category Type'
			SET @SubStepName = 'Log any New category type'
			
			SET @SQL = @LegacyUse +
				'
					DECLARE
						@ImportCategoryTable TABLE
							(
								  ID BIGINT IDENTITY(1,1) 
								, CategoryType VARCHAR(MAX)
								, CategoryID INT
							)

					INSERT INTO 
						@ImportCategoryTable
						(
							CategoryType,
							CategoryID
						)
					SELECT DISTINCT
						  SUBSTRING(con.NewStagingTablename, LEN(NewStagingTablename) - CHARINDEX(''_'', REVERSE(NewStagingTablename), 1) + 2, LEN(NewStagingTablename))
						, fm_category_id
					FROM
						[' + @PT1Schema + '].[' + @MigrationConfigTable + '] con
							LEFT JOIN [' + @ExecutionDB + '].[dbo].[FilevineMigration_Master_ImportCategory] cat
								ON cat.Filevine_ImportCategory = SUBSTRING(NewStagingTablename, LEN(NewStagingTablename) - CHARINDEX(''_'', REVERSE(NewStagingTablename), 1) + 2, LEN(NewStagingTablename))
					WHERE
						cat.fm_category_id IS NULL

					DECLARE
						  @Counter BIGINT = 1
						, @MaxID BIGINT = (SELECT ISNULL(MAX(ID), 2) FROM @ImportCategoryTable)
						, @CategoryType VARCHAR(MAX)

					WHILE @Counter <= @MaxID
						BEGIN
							SET @CategoryType = (SELECT CategoryType FROM @ImportCategoryTable WHERE ID = @Counter)

							IF @CategoryType IS NOT NULL
								BEGIN
									INSERT INTO	
										[' + @ExecutionDB + '].[dbo].[FilevineMigration_Master_ImportCategory]
									SELECT
										@CategoryType
								END

							PRINT ''New Category Type Added: '' + @CategoryType

							SET @Counter = @Counter + 1
						END	
				'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQL
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable

			SET @StepName = 'New Project Type'
			SET @SubStepName = 'Log any new project type'

			/*If new Projecttype, insert record*/
			SET @SQL = @LegacyUse +
				'
					DECLARE
						@ProjectTypeTable TABLE
							(
								  ID BIGINT IDENTITY(1,1) 
								, ProjectType VARCHAR(MAX)	
								, ProjectID VARCHAR(MAX)	
							)

					INSERT INTO 
						@ProjectTypeTable
						(
								ProjectType
							  , ProjectID
						)
					SELECT DISTINCT
						  ISNULL(NULLIF(SUBSTRING(Table_Name, [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 3), CASE WHEN [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 4) - [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 3) + 1 < 0 THEN 0 ELSE [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 4) - [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 3) + 1 END) , '''') , ''ALL'')
						, temp.ID
					FROM
						[' + @PT1Schema + '].[' + @MigrationConfigTable + '] con
							LEFT JOIN [' + @ExecutionDB + '].[dbo].[FilevineMigration_Master_ProjectTemplate] temp
								ON temp.ImportTableMask = ISNULL(NULLIF(SUBSTRING(Table_Name, [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 3), CASE WHEN [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 4) - [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 3) + 1 < 0 THEN 0 ELSE [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 4) - [' + @ExecutionDB + '].dbo.udf_findNthOccurance(''_'', Table_Name, 3) + 1 END) , '''') , ''ALL'')
					WHERE
						temp.ID IS NULL

					DECLARE
						  @Counter BIGINT = 1
						, @MaxID BIGINT = (SELECT ISNULL(MAX(ID), 2) FROM @ProjectTypeTable)
						, @ProjectType VARCHAR(MAX)

					WHILE @Counter <= @MaxID
						BEGIN
							SET @ProjectType = (SELECT ProjectType FROM @ProjectTypeTable WHERE ID = @Counter)

							IF @ProjectType IS NOT NULL	
								BEGIN
									INSERT INTO	
										[' + @ExecutionDB + '].[dbo].[FilevineMigration_Master_ProjectTemplate]
										(
											ImportTableMask
										)
									SELECT
										@ProjectType
								END

							PRINT ''New Project Type Added: '' + @ProjectType

							SET @Counter = @Counter + 1
						END
				'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQL
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END
	END
GO
/****** Object:  StoredProcedure [PT1].[usp_get_column_contraint_list]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PT1].[usp_get_column_contraint_list] 
		  @executable_db NVARCHAR(500) = N''
		, @DebugFlag BIT = 1 /* 0 - to execute; non-zero - to print SQL statements */
		, @Database VARCHAR(500) = N''
		, @SchemaName VARCHAR(500) = N''
		, @TableSrc VARCHAR(500) = N''
		, @PT1Schema VARCHAR(10)
		, @MigrationProcessStatusTable VARCHAR(1000)
		
AS    
	BEGIN
		DECLARE 
			  @SQL NVARCHAR(MAX) = ''
			, @NewLine NVARCHAR(50) = CHAR(13) + CHAR(10)
			, @DatabaseBrackets VARCHAR(500) = '[' + REPLACE(REPLACE(@Database, '[', ''), ']', '') + ']'
			, @SchemaBrackets VARCHAR(500) = '[' + REPLACE(REPLACE(@SchemaName, '[', ''), ']', '') + ']'
			, @SQLWrapper NVARCHAR(MAX) = ''
			, @StepName VARCHAR(1000) = 'Create [__FV_DropDownListAlignment] Table'
			, @SubStepName VARCHAR(1000)
			, @ExecutionDB VARCHAR(500) = @executable_db
			, @ProcName	VARCHAR(200) = OBJECT_NAME(@@PROCID)

		SELECT
			  @Database = REPLACE(REPLACE(@Database, '[', ''), ']', '')	
			, @SchemaName = REPLACE(REPLACE(@SchemaName, '[', ''), ']', '')	

		DECLARE
			  @LegacyUse VARCHAR(500) = 'USE ' + @DatabaseBrackets
			, @WorkingUSe VARCHAR(500) = 'USE ' + @executable_db

		/*Build the create statement*/
		SET @SQL = @LegacyUse + 
			'
				IF OBJECT_ID(N''[dbo].[__FV_DropDownListAlignment]'') IS NULL 
					BEGIN
						CREATE TABLE 
							[dbo].[__FV_DropDownListAlignment]   
							( 
								  ID BIGINT IDENTITY(1,1) NOT NULL
								, Table_Name VARCHAR(500) NOT NULL
								, Column_Name VARCHAR(500) NOT NULL
								, FV_Dropdown_Value VARCHAR(2000) NULL
								, LEG_Field_Value VARCHAR(2000) NULL
								, Active_Flag BIT NULL
								, Create_Date DATETIME NULL
								, Update_Date DATETIME NULL
						   )
					END
			'
	     
		BEGIN
			SET @SubStepName = 'Create the Table'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQL
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END
		 
		/*Build the Merge Statement*/
		SET	@SQL = @LegacyUse + 
			' 
				MERGE INTO
					[dbo].[__FV_DropDownListAlignment] 
				AS 
					TARGET
				USING 
					(
						SELECT 
							  t.[name] [TABLE_NAME]
							, c.[name] [COLUMN_NAME]
							, LTRIM(RTRIM(cs.ColumnA)) ColumnA
						FROM 
							sys.tables AS t
								INNER JOIN sys.columns c 
									ON t.[object_id] = c.[object_id]
								INNER JOIN sys.check_constraints cc 
									ON  t.[object_id] = cc.[parent_object_id] 
									AND c.[column_id] = cc.[parent_column_id]
								CROSS APPLY [' + @executable_db + '].[dbo].[SplitToRows]           
								(              
									  REPLACE
									  (
										REPLACE
										(
											  REPLACE(SUBSTRING(cc.[definition], 2, LEN(cc.definition) - 2), '''''''''''', '''''''')
											, '''''' OR ''
											, ''þ''
										)
										, ''['' + c.[name] + '']=''''''
										, ''''
									  )
									, ''þ''           
								) cs 
				' 
			  + CASE 
					WHEN @TableSrc != '' 
					THEN 
				'
						WHERE t.[name] = ''' + @TableSrc + '''
				'
					ELSE '' 
				END 
			 + ' ) AS SOURCE 
					ON  TARGET.Table_Name = SOURCE.TABLE_NAME
					AND TARGET.Column_Name = SOURCE.COLUMN_NAME
					AND TARGET.FV_Dropdown_Value = SOURCE.ColumnA
				WHEN NOT MATCHED BY TARGET THEN 
					INSERT 
						(
							  Table_Name
							, Column_Name
							, FV_Dropdown_Value
							, Active_Flag
							, Create_Date
						)
					VALUES 
						(
							  source.[TABLE_NAME]
							, source.[COLUMN_NAME]
							, LTRIM(RTRIM(source.ColumnA))
							, 1
							, getdate()
						)
				WHEN NOT MATCHED BY SOURCE THEN
					UPDATE 
						SET 
							  target.Active_Flag = 0
							, target.Update_Date = getdate();
			'
		
		BEGIN
			SET @SubStepName = 'Merge changes'

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQL
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable
		END
	END
GO
/****** Object:  StoredProcedure [PT1].[usp_Log_ReleaseVersionProcs_By_Schema]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [PT1].[usp_Log_ReleaseVersionProcs_By_Schema]
	  @LegacyDB VARCHAR(1000) = ''
	, @LegacySchemaList VARCHAR(1000) = '' /*comma delimited list of schemas*/

AS

BEGIN
	DECLARE 
		  @SQL VARCHAR(MAX)
		, @LegacyDBUnquoted VARCHAR(1000) = REPLACE(REPLACE(@LegacyDB, '[', ''), ']', '')
		, @LegacyDBQuoted VARCHAR(1000) = '[' + REPLACE(REPLACE(@LegacyDB, '[', ''), ']', '') + ']'

	SET @SQL =
		'
			USE ' + @LegacyDBQuoted + '

			DECLARE 
				@SchemaList TABLE
				(
					  ID BIGINT IDENTITY(1,1)
					, SchemaName VARCHAR(1000)
				)

			INSERT INTO
				@SchemaList
			SELECT
				value
			FROM
				STRING_SPLIT(''' + @LegacySchemaList + ''', '','')

			DECLARE 
				@SPLoopTab TABLE
				(
					  ID BIGINT IDENTITY(1,1)
					, Object_ID BIGINT NOT NULL
					, LegacyDBName VARCHAR(1000)
					, LegacyDBID BIGINT
					, LegacySchemaName VARCHAR(1000)
					, LegacySPID BIGINT
					, LegacySPName VARCHAR(1000)
					, SPDefinition VARCHAR(MAX)
				)

			INSERT INTO 
				@SPLoopTab
				(
					  Object_ID
					, LegacyDBName
					, LegacyDBID
					, LegacySchemaName
					, LegacySPID
					, LegacySPName
				)
			SELECT 
				  OBJECT_ID(Rout.SPECIFIC_CATALOG + ''.'' + Rout.SPECIFIC_SCHEMA + ''.'' + Rout.SPECIFIC_NAME)[Object_ID]
				, Rout.SPECIFIC_CATALOG [LegacyDBName]
				, ld.lg_db_id [LegacyDBID]
				, Rout.SPECIFIC_SCHEMA [LegacySchemaName]
				, ls.LegacySPID [LegacySPID]
				, Rout.SPECIFIC_NAME [LegacySPName]
			FROM 
				' + @LegacyDBQuoted + '.[INFORMATION_SCHEMA].[Routines] Rout
					INNER JOIN @SchemaList sl
						ON Rout.SPECIFIC_SCHEMA = sl.SchemaName
					LEFT JOIN [Filevine_META].[dbo].[Legacy_Database] ld
						ON ld.lg_db_SchemaName = sl.SchemaName
					LEFT JOIN [Filevine_META].[dbo].[LegacySP] ls
						ON ls.LegacySPName = Rout.SPECIFIC_NAME
			WHERE
					SPECIFIC_CATALOG = ''' + @LegacyDBUnquoted + '''

			UPDATE 
				sp
			SET 
				SPDefinition = ''/'' + ''*RELEASE VERSION*'' + ''/'' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + REPLACE(REPLACE(sm.definition, ''CREATE FUNCTION'', ''ALTER FUNCTION''), ''CREATE PROCEDURE'', ''ALTER PROCEDURE'')
			FROM 
				@SPLoopTab sp
					INNER JOIN [sys].[sql_modules] sm
						ON sp.Object_ID = sm.object_ID

			SELECT 
				*
			FROM
				@SPLoopTab sp

			BEGIN	
				DECLARE
					  @Counter BIGINT = 1
					, @MaxID BIGINT = (SELECT MAX(ID) FROM @SPLoopTab)

				WHILE @Counter <= @MaxID
					BEGIN
						DECLARE 
							@SQLAlter VARCHAR(MAX) = (SELECT SPDefinition FROM @SPLoopTab WHERE @Counter = ID)

						BEGIN TRY
							EXEC(@SQLAlter)
						END TRY

						BEGIN CATCH
							SELECT ''FAILURE'', @SQLAlter
						END CATCH
						
						SET @Counter = @Counter + 1
					END
			END
		'

	EXEC(@SQL)
END
GO
/****** Object:  StoredProcedure [PT1].[usp_migration_insert_main]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PT1].[usp_migration_insert_main]
	  @DebugFlag BIT = 1   /*1 to output SQL statements; 0 to execute	*/
	, @Database VARCHAR(500)
	, @LegacyDbType VARCHAR(500)
	, @SchemaName VARCHAR(500)
	, @OrgID BIGINT
	, @ExecutionDB VARCHAR(500)
	, @FVProductionPrefix VARCHAR(500)
	, @timezone VARCHAR(500)
	, @PT1Schema VARCHAR(500)
	, @MigrationProcessStatusTable VARCHAR(500)

AS
	BEGIN
		DECLARE 
			  @DatabaseBrackets VARCHAR(500) = ''
			, @SQL NVARCHAR(MAX) = ''
			, @SQL1 VARCHAR(MAX) = ''
			, @SQL2 VARCHAR(MAX) = ''
			, @SQL3 VARCHAR(MAX) = ''
			, @SQL4 VARCHAR(MAX) = ''
			, @SQLn NVARCHAR(MAX) = N''
			, @NewLine CHAR(2) = CHAR(13) + CHAR(10)
			, @ProcName	VARCHAR(200) = OBJECT_NAME(@@PROCID)
			, @StepName	VARCHAR(100) = 'migration for ' + @Database
			, @SubStepName VARCHAR(250) = ''
			, @ErrorMsg NVARCHAR(2048) = N''
			, @ErrorCode INT = 0
			, @EmptyString VARCHAR(10) = ''
			, @True BIT = 1
			, @False BIT = 0
			, @LegacySchema VARCHAR(100) = @LegacyDbType
			, @Counter INT = 1
			, @MaxTabID INT = 0
			, @MinTabID INT = 0
			, @LoopLegacySchema VARCHAR(100) = ''
			, @LoopProcName VARCHAR(1000) = ''
			, @WorkingUse VARCHAR(1000) = 'USE ' + @ExecutionDB
			, @SQLWrapper NVARCHAR(MAX)
			, @ExecutionOrderTable VARCHAR(1000) = 'LegacySPExecutionOrder'
			, @ExecutionOrderView VARCHAR(1000) = 'vw_LegacySP_FullMigration_ExecOrder'

		BEGIN
			SELECT 
				  @DatabaseBrackets = 
					CASE
						WHEN CHARINDEX('[', @Database, 1) = 0 
						THEN '[' + @Database + ']' 
						
						ELSE @Database 
					END
				, @Database = REPLACE(REPLACE(@Database, '[' , ''), ']', '')

			SET @SQL1 = 
				'
					USE [' + @Database + ']

					DECLARE 
						  @DebugFlag BIT = ' + CONVERT(VARCHAR(10), @DebugFlag) + '
						, @SQLWrapper NVARCHAR(MAX)
						, @WorkingUse VARCHAR(100) = ''USE ' + @ExecutionDB + '''
						, @ExecutionDB VARCHAR(1000) = ''' + @ExecutionDB + '''
						, @MaxTabID INT = 0
						, @MinTabID INT = 0
						, @LegacySchema VARCHAR(100) = ''' + @LegacySchema + '''
						, @True BIT = 1
						, @False BIT = 0
						, @Counter INT = 1
						, @ProcName	VARCHAR(200) = ''''
						, @StepName	VARCHAR(100) = ''''
						, @SubStepName VARCHAR(250) = ''''
						, @ErrorMsg NVARCHAR(2048) = N''''
						, @ErrorCode INT = 0
						, @EmptyString VARCHAR(10) = ''''
						, @LoopLegacySchema VARCHAR(100) = ''''
						, @LoopProcName VARCHAR(1000) = ''''
						, @SQLn NVARCHAR(MAX) = N''''
						, @DatabaseBrackets VARCHAR(500) = ''' + @DatabaseBrackets + '''
						, @PT1Schema VARCHAR(1000) = ''' + @PT1Schema + '''
						, @MigrationProcessStatusTable VARCHAR(1000) = ''' + @MigrationProcessStatusTable + '''
					
					/*Map out legacy SP*/
					BEGIN
						DECLARE 
							@LegacySPMap TABLE
								(
									  ID INT IDENTITY(1,1)
									, LegacySchemaTypeName VARCHAR(1000)
									, LegacySPName VARCHAR(1000)
									, LegacySPExecutionOrder INT
								)

						/*Legacy Order BY*/
						INSERT INTO 
							@LegacySPMap
						SELECT DISTINCT
							  SPECIFIC_SCHEMA
							, ROUTINE_NAME
							, fmeo.ExecutionOrder
						FROM
							' + @DatabaseBrackets + '.[' + @PT1Schema + '].[' + @ExecutionOrderView + '] fmeo
								LEFT JOIN [' + @Database + '].[INFORMATION_SCHEMA].[Routines] Rout
									ON rout.ROUTINE_NAME = fmeo.LegacySPName
									AND rout.SPECIFIC_SCHEMA = fmeo.LegacyDatabaseType
						WHERE
								SPECIFIC_SCHEMA = @LegacySchema
							AND ROUTINE_TYPE = ''PROCEDURE''
							AND ROUTINE_NAME != ''usp_migration_insert_main''
							AND ActiveMapping = @True
							AND ActiveProcedure = @True
							AND FvProdPrefix = ''' + @FVProductionPrefix + '''
							AND OrgID = ' + CONVERT(VARCHAR, @OrgID) + '
						ORDER BY
							  ExecutionOrder
							, ROUTINE_NAME
					END

					/*EXEC reference table Insert procedures*/
					BEGIN
						SELECT 
							  @MinTabID = ISNULL(MIN(ID),0)
							, @MaxTabID = ISNULL(MAX(ID),0) 
						FROM 
							@LegacySPMap 
						WHERE 
							LegacySPName LIKE ''usp_insert_reference_%''
						 
				'

			SET @SQL2 =
				'
						IF @MaxTabID > 0
							BEGIN
								WHILE @Counter >= @MinTabID AND @Counter <= @MaxTabID
									BEGIN
										SELECT 
											  @LoopLegacySchema = LegacySchemaTypeName
											, @LoopProcName = LegacySPName
										FROM
											@LegacySPMap
										WHERE
											ID = @Counter
					
										SET @SubStepName = ''Run ['' + @LoopLegacySchema + ''].['' + @LoopProcName + '']''
										SET @ProcName = @LoopProcName
										
										SET @SQLn = 
											''
												EXEC 
													[' + @Database + '].['' + @LoopLegacySchema + ''].['' + @LoopProcName + '']
														  @DebugFlag = ''''' + CONVERT(VARCHAR(10), @DebugFlag) + '''''
														, @Database =  ''''' + @DatabaseBrackets + '''''
														, @SchemaName = ''''' + @SchemaName + '''''
														, @FVProductionPrefix = ''''' + @FVProductionPrefix + '''''
														, @timezone = ''''' + @timezone + '''''
											''
											
										BEGIN
											SET @SQLWrapper = @WorkingUse + 
												''
													EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
														  @SQLCode = @SQLWrapper 
														, @DatabaseBrackets = @DatabaseBrackets
														, @ExecutionDB = @ExecutionDB
														, @ProcName = @ProcName
														, @StepName = @StepName
														, @SubStepName = @SubStepName
														, @DebugFlag = @DebugFlag
														, @PrintFlag = 1
														, @PT1Schema = @PT1Schema
														, @MigrationProcessStatusTable = @MigrationProcessStatusTable
												''

											EXEC sp_executesql
												  @SQLWrapper
												, N''@SQLWrapper VARCHAR(MAX)
												   , @DatabaseBrackets VARCHAR(1000)
												   , @ExecutionDB VARCHAR(1000)
												   , @ProcName VARCHAR(1000)
												   , @StepName VARCHAR(1000)
												   , @SubStepName VARCHAR(1000)
												   , @DebugFlag BIT
												   , @PT1Schema VARCHAR(1000)
												   , @MigrationProcessStatusTable VARCHAR(1000)''
												, @SQLWrapper = @SQLn
												, @DatabaseBrackets = @DatabaseBrackets
												, @ExecutionDB = @ExecutionDB
												, @ProcName = @ProcName
												, @StepName = @StepName
												, @SubStepName = @SubStepName
												, @DebugFlag = @DebugFlag
												, @PT1Schema = @PT1Schema
												, @MigrationProcessStatusTable = @MigrationProcessStatusTable
										END

										SET @Counter = @Counter + 1
									END
							END
				'

			SET @SQL3 =
				'
						ELSE
							BEGIN
								select ERROR_MESSAGE()
								SET @ErrorMsg = ''Legacy Schema ['' + @LegacySchema + ''] does not have any existing "reference" stored procedures.  Please check spelling of Legacy DB and Production Prefix names for typos and ensure that your procedure exists.''
								RAISERROR(@ErrorMsg,16,1);
							END
					END

					/*EXEC Insert Staging Procedures*/
					BEGIN
						SELECT 
							  @MinTabID = ISNULL(MIN(ID), 0)
							, @MaxTabID = ISNULL(MAX(ID), 0) 
						FROM 
							@LegacySPMap 
						WHERE 
							LegacySPName LIKE ''usp_insert_staging_%''
					
						IF @MaxTabID > 0
							BEGIN
								WHILE @Counter >= @MinTabID AND @Counter <= @MaxTabID
									BEGIN
										SELECT 
											  @LoopLegacySchema = LegacySchemaTypeName
											, @LoopProcName = LegacySPName
										FROM
											@LegacySPMap
										WHERE
											ID = @Counter

										SET @SubStepName = ''Run ['' + @LoopLegacySchema + ''].['' + @LoopProcName + '']''
										SET @ProcName = @LoopProcName
										
										SET @SQLn = 
											''
												EXEC 
													[' + @Database + '].['' + @LoopLegacySchema + ''].['' + @LoopProcName + '']
														  @DebugFlag = ''''' + CONVERT(VARCHAR(10), @DebugFlag) + '''''
														, @Database =  ''''' + @DatabaseBrackets + '''''
														, @SchemaName = ''''' + @SchemaName + '''''
														, @FVProductionPrefix = ''''' + @FVProductionPrefix + '''''
														, @timezone = ''''' + @timezone + '''''
											''
				'

			SET @SQL4 =
				'
										Checkpoint;

										BEGIN
											SET @SQLWrapper = @WorkingUse + 
												''
													EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
														  @SQLCode = @SQLWrapper 
														, @DatabaseBrackets = @DatabaseBrackets
														, @ExecutionDB = @ExecutionDB
														, @ProcName = @ProcName
														, @StepName = @StepName
														, @SubStepName = @SubStepName
														, @DebugFlag = @DebugFlag
														, @PrintFlag = 1
														, @PT1Schema = @PT1Schema
														, @MigrationProcessStatusTable = @MigrationProcessStatusTable
												''

											EXEC sp_executesql
												  @SQLWrapper
												, N''@SQLWrapper VARCHAR(MAX)
												   , @DatabaseBrackets VARCHAR(1000)
												   , @ExecutionDB VARCHAR(1000)
												   , @ProcName VARCHAR(1000)
												   , @StepName VARCHAR(1000)
												   , @SubStepName VARCHAR(1000)
												   , @DebugFlag BIT
												   , @PT1Schema VARCHAR(1000)
												   , @MigrationProcessStatusTable VARCHAR(1000)''
												, @SQLWrapper = @SQLn
												, @DatabaseBrackets = @DatabaseBrackets
												, @ExecutionDB = @ExecutionDB
												, @ProcName = @ProcName
												, @StepName = @StepName
												, @SubStepName = @SubStepName
												, @DebugFlag = @DebugFlag
												, @PT1Schema = @PT1Schema
												, @MigrationProcessStatusTable = @MigrationProcessStatusTable
										END

										SET @Counter = @Counter + 1
									END
							END
						ELSE
							BEGIN
								SET @ErrorMsg = ''Legacy Schema ['' + @LegacySchema + ''] does not have any existing "staging" stored procedures.  Please check spelling of Legacy DB name and that your procedure exists.''
								RAISERROR(@ErrorMsg,16,1);
							END
					END

				'

			SET @SQLn = @SQL1 + ' ' + @SQL2 + ' ' + @SQL3 + ' ' + @SQL4

			SET @SQLWrapper = @WorkingUse + 
				'
					EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
						  @SQLCode = @SQLWrapper 
						, @DatabaseBrackets = @DatabaseBrackets
						, @ExecutionDB = @ExecutionDB
						, @ProcName = @ProcName
						, @StepName = @StepName
						, @SubStepName = @SubStepName
						, @DebugFlag = @DebugFlag
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				'

			EXEC sp_executesql
				  @SQLWrapper
				, N'@SQLWrapper VARCHAR(MAX)
				  , @DatabaseBrackets VARCHAR(1000)
				  , @ExecutionDB VARCHAR(1000)
				  , @ProcName VARCHAR(1000)
				  , @StepName VARCHAR(1000)
				  , @SubStepName VARCHAR(1000)
				  , @DebugFlag BIT
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @SQLWrapper = @SQLn
				, @DatabaseBrackets = @DatabaseBrackets
				, @ExecutionDB = @ExecutionDB
				, @ProcName = @ProcName
				, @StepName = @StepName
				, @SubStepName = @SubStepName
				, @DebugFlag = @DebugFlag
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable

			
			/*Rebuild Indexes After everything completes*/
			BEGIN
				SET @SubStepName = 'REBUILD INDEXES'
				
				SET @SQL = @WorkingUse + 
					'
						DECLARE
							@ReIndex TABLE
								(
									  ID BIGINT IDENTITY(1,1)
									, TableSchema VARCHAR(100)
									, TableName VARCHAR(MAX)
								)

						DECLARE 
							  @RebuildSQL VARCHAR(MAX)
							, @RebuildCounter BIGINT = 1
							, @RebuildMaxID BIGINT

						INSERT INTO
							@ReIndex
							(
								  [TableSchema]
								, [TableName]
							)
						SELECT DISTINCT
							  TABLE_SCHEMA
							, TABLE_NAME
						FROM
							[INFORMATION_SCHEMA].[TABLES]
						WHERE
							TABLE_NAME LIKE ''%' + @FVProductionPrefix + '%''
						ORDER BY
							TABLE_NAME

						SET @RebuildMaxID = (SELECT MAX(ID) FROM @ReIndex)

						WHILE @RebuildMaxID >= @RebuildCounter
							BEGIN
								DECLARE
									  @Schema VARCHAR(1000) = (SELECT TableSchema FROM @ReIndex WHERE @RebuildCounter = ID)
									, @Table VARCHAR(1000) = (SELECT TableName FROM @ReIndex WHERE @RebuildCounter = ID)
								
								SET @RebuildSQL = ''' + @WorkingUse + ''' +
									''
										ALTER INDEX ALL ON ['' + @Schema + ''].['' + @Table + '']
										REBUILD;
									''

								PRINT ''REBUILDING INDEXES ON ['' + @Schema + ''].['' + @Table + '']: STARTED''

								EXEC (@RebuildSQL)

								PRINT ''REBUILDING INDEXES ON ['' + @Schema + ''].['' + @Table + '']: COMPLETED''

								CHECKPOINT
							END
					'
					

				SET @SQLWrapper = @WorkingUse + 
					'
						EXEC [PT1].[usp_PT1_DynamicSQL_Wrapper]
							  @SQLCode = @SQLWrapper 
							, @DatabaseBrackets = @DatabaseBrackets
							, @ExecutionDB = @ExecutionDB
							, @ProcName = @ProcName
							, @StepName = @StepName
							, @SubStepName = @SubStepName
							, @DebugFlag = @DebugFlag
							, @PT1Schema = @PT1Schema
							, @MigrationProcessStatusTable = @MigrationProcessStatusTable
					'

				EXEC sp_executesql
					  @SQLWrapper
					, N'@SQLWrapper VARCHAR(MAX)
					  , @DatabaseBrackets VARCHAR(1000)
					  , @ExecutionDB VARCHAR(1000)
					  , @ProcName VARCHAR(1000)
					  , @StepName VARCHAR(1000)
					  , @SubStepName VARCHAR(1000)
					  , @DebugFlag BIT
					  , @PT1Schema VARCHAR(1000)
					  , @MigrationProcessStatusTable VARCHAR(1000)'
					, @SQLWrapper = @SQL
					, @DatabaseBrackets = @DatabaseBrackets
					, @ExecutionDB = @ExecutionDB
					, @ProcName = @ProcName
					, @StepName = @StepName
					, @SubStepName = @SubStepName
					, @DebugFlag = @DebugFlag
					, @PT1Schema = @PT1Schema
					, @MigrationProcessStatusTable = @MigrationProcessStatusTable
			END
		END
	END
GO
/****** Object:  StoredProcedure [PT1].[usp_PT1_DynamicSQL_Wrapper]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PT1].[usp_PT1_DynamicSQL_Wrapper]
	  @SQLCode VARCHAR(MAX) = ''
	, @DatabaseBrackets VARCHAR(1000) = ''
	, @ExecutionDB VARCHAR(1000) = ''
	, @ProcName VARCHAR(1000) = ''
	, @StepName VARCHAR(1000) = ''
	, @SubStepName VARCHAR(1000) = ''
	, @DebugFlag BIT = 0
	, @PrintFlag BIT = 0
	, @PT1Schema VARCHAR(1000)
	, @MigrationProcessStatusTable VARCHAR(1000)

AS
	BEGIN
		DECLARE 
			  @EscapedSQL VARCHAR(MAX) = REPLACE(@SQLCode, '''', '''''')
			, @NewLine CHAR(2) = CHAR(13) + CHAR(10)
			, @SQLLog NVARCHAR(MAX) = ''
			, @ErrorCode INT = '0'
			, @ErrorMsg VARCHAR(MAX) = ''
			, @True BIT = 1
			, @False BIT = 0
			, @RowCount VARCHAR(100) = '0'

		SET NOCOUNT OFF

		BEGIN TRY
			/*print status and log it*/
			BEGIN
				IF @PrintFlag = @True
					BEGIN
						PRINT 'EXECUTING: ' + @ProcName + ' - ' + @StepName + ' - ' + @SubStepName
					END

				SET @SQLLog =
					'
						USE ' + @DatabaseBrackets + '

						IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @MigrationProcessStatusTable + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
							BEGIN
								EXEC [' + @ExecutionDB + '].[' + @PT1Schema + '].[migration_update_process_status] 
									  @Database = ''' + @DatabaseBrackets + '''
									, @step_exec = ''' + @ProcName + '''
									, @step_name = ''' + @StepName + '''
									, @sub_step_name = ''' + @SubStepName + '''
									, @status = ''STARTED''
									, @row_count = @RowCount
									, @error_code = @ErrorCode
									, @error_msg = @ErrorMsg
									, @sqlcode = @EscapedSQL
									, @PT1Schema = @PT1Schema
									, @MigrationProcessStatusTable = @MigrationProcessStatusTable
							END
					'
			
				EXEC sp_executeSQL 
						@SQLLog
					, N'@EscapedSQL VARCHAR(MAX)
						, @ErrorMsg VARCHAR(MAX)
						, @ErrorCode VARCHAR(100)
						, @RowCount VARCHAR(1000)
						, @PT1Schema VARCHAR(1000)
						, @MigrationProcessStatusTable VARCHAR(1000)'
					, @EscapedSQL = @EscapedSQL
					, @ErrorMsg = @ErrorMsg
					, @ErrorCode = @ErrorCode
					, @RowCount = @RowCount
					, @PT1Schema = @PT1Schema
					, @MigrationProcessStatusTable = @MigrationProcessStatusTable
			END

			/*the actual code executing*/
			EXEC (@SQLCode)
			
			/*Print completed and log*/
			IF ISNULL(ERROR_NUMBER(), 0) = 0
				BEGIN
					IF @PrintFlag = @True
						BEGIN
							PRINT 'COMPLETED: ' + @ProcName + ' - ' + @StepName + ' - ' + @SubStepName
						END
					
					SET @SQLLog =
						'
							USE ' + @DatabaseBrackets + '

							IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @MigrationProcessStatusTable + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
								BEGIN
									EXEC [' + @ExecutionDB + '].[' + @PT1Schema + '].[migration_update_process_status]  
										  @Database = ''' + @DatabaseBrackets + '''
										, @step_exec = ''' + @ProcName + '''
										, @step_name = ''' + @StepName + '''
										, @sub_step_name = ''' + @SubStepName + '''
										, @status = ''COMPLETE''
										, @row_count = @RowCount
										, @error_code = @ErrorCode
										, @error_msg = @ErrorMsg
										, @sqlcode = @EscapedSQL
										, @PT1Schema = @PT1Schema
										, @MigrationProcessStatusTable = @MigrationProcessStatusTable
								END
						'
			
					EXEC sp_executeSQL 
						  @SQLLog
						, N'@EscapedSQL VARCHAR(MAX)
						  , @ErrorMsg VARCHAR(MAX)
						  , @ErrorCode VARCHAR(100)
						  , @RowCount VARCHAR(1000)
						  , @PT1Schema VARCHAR(1000)
						  , @MigrationProcessStatusTable VARCHAR(1000)'
						, @EscapedSQL = @EscapedSQL
						, @ErrorMsg = @ErrorMsg
						, @ErrorCode = @ErrorCode
						, @RowCount = @RowCount
						, @PT1Schema = @PT1Schema
						, @MigrationProcessStatusTable = @MigrationProcessStatusTable
				END
		END TRY

		BEGIN CATCH
			PRINT 'FAILED: ' + @ProcName + ' - ' + @StepName + ' - ' + @SubStepName
			
			IF @DebugFlag = @True
				BEGIN
					SELECT 
						  'FAILED: ' + @ProcName + ' - ' + @StepName + ' - ' + @SubStepName
						, @ProcName [ProcName]
						, @StepName [StepName]
						, @SubStepName [SubStepName]
						, @SQLCode [SQLCode]
				END

			SELECT
				  @ErrorCode = CONVERT(VARCHAR, ERROR_NUMBER())
				, @ErrorMsg = N'!!!!ERROR - FAILED to ' + @SubStepName + @NewLine + REPLACE(ERROR_MESSAGE(), '''', '''''')
					
			SET @SQLLog =
				'
					USE ' + @DatabaseBrackets + '

					IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @MigrationProcessStatusTable + ''' AND TABLE_SCHEMA = ''' + @PT1Schema + ''')
						BEGIN									
							EXEC [' + @ExecutionDB + '].[' + @PT1Schema + '].[migration_update_process_status] 
								  @Database = ''' + @DatabaseBrackets + '''
								, @step_exec = ''' + @ProcName + '''
								, @step_name = ''' + @StepName + '''
								, @sub_step_name = ''' + @SubStepName + '''
								, @status = ''FAILED''
								, @row_count = @RowCount
								, @error_code = @ErrorCode
								, @error_msg = @ErrorMsg
								, @sqlcode = @EscapedSQL
								, @PT1Schema = @PT1Schema
								, @MigrationProcessStatusTable = @MigrationProcessStatusTable
						END
				'
						
			EXEC sp_executeSQL 
				  @SQLLog
				, N'@EscapedSQL VARCHAR(MAX)
				  , @ErrorMsg VARCHAR(MAX)
				  , @ErrorCode VARCHAR(100)
				  , @RowCount VARCHAR(1000)
				  , @PT1Schema VARCHAR(1000)
				  , @MigrationProcessStatusTable VARCHAR(1000)'
				, @EscapedSQL = @EscapedSQL
				, @ErrorMsg = @ErrorMsg
				, @ErrorCode = @ErrorCode
				, @RowCount = @RowCount
				, @PT1Schema = @PT1Schema
				, @MigrationProcessStatusTable = @MigrationProcessStatusTable

			RAISERROR(@ErrorMsg, 16, 1);
		END CATCH
		
		RETURN @ErrorCode
	END
GO
/****** Object:  StoredProcedure [QA].[DumpFVStagingImportToCSV]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [QA].[DumpFVStagingImportToCSV]
	  @SQLDB VARCHAR(500) = '4436_Borland' /*Group ID for the Migrations*/
	, @SQLSchema VARCHAR(500) = 'dbo'
	, @SQLPrefix VARCHAR(500) = '_BorlandTest8_'
	, @OutputPath VARCHAR(MAX) = 'c:\temp\csvDump\'
	, @ZipFlag BIT = 0
	, @DebugFlag BIT = 0

AS
	BEGIN
		BEGIN TRY

		DECLARE 
			  @SSISPath VARCHAR(8000)
			, @Command VARCHAR(8000)
			, @ReturnCode INT
			, @ErrorMessage VARCHAR(4000)

	/* MDETL.dtsx lives in SSISDB and will be executed via Integration Services
		Par "$ServerOption::SYNCHRONIZED(Boolean)";True   forces the stored proc to wait for the package to complete before exiting*/
		SET @SSISPath = ' /ISServer "\SSISDB\Migrations\DBDumpToCSV\DumpDBtoCSV.dtsx"  /Server "localhost" /Par "$ServerOption::SYNCHRONIZED(Boolean)";True';
		SET @Command = '"C:\Program Files (x86)\Microsoft SQL Server\120\DTS\Binn\DTExec.exe"';
		SET @Command = 'cd.. && ' + @Command + @SSISPath;

		/*Set Remote Package Parameters*/
		SET @Command = @Command + ' /SET \Package.Variables[User::SQLDB].Properties[Value];"' + @SQLDB + '"';
		SET @Command = @Command + ' /SET \Package.Variables[User::SQLSchema].Properties[Value];"' + @SQLSchema + '"';
		SET @Command = @Command + ' /SET \Package.Variables[User::SQLPrefix].Properties[Value];"' + @SQLPrefix + '"';
		SET @Command = @Command + ' /SET \Package.Variables[User::SQLTableOutputDir].Properties[Value];"' + REPLACE(@OutputPath, '\', '\\') + '"';
		SET @Command = @Command + ' /SET \Package.Variables[User::ZipFlag].Properties[Value];' + CONVERT(VARCHAR, @ZipFlag) + '';

		IF @DebugFlag = 1
			BEGIN
				SELECT @Command Command
			END

		CREATE TABLE 
			#output (outputValue VARCHAR(max) NULL);
		INSERT 
			#output 
		EXEC @ReturnCode = master..xp_cmdshell @Command; /*@ReturnCode=[0,1] (success, failure)*/
		select @returncode
		/*select * FROM #outputIf we have an error assign @ErrorMessage variable*/
		IF @ReturnCode <> 0 
			BEGIN
				SELECT @ErrorMessage = @ErrorMessage + outputValue
				FROM #output
				WHERE outputValue IS NOT NULL;
				select * From #output
				DROP TABLE #output;  
			END

		SELECT 
			  @ErrorMessage  ErrorMessage
			, @SQLDB SQLDB
			, @SQLSchema SQLSchema
			, @SQLPrefix SQLPrefix;

IF @ErrorMessage IS NOT NULL
BEGIN 
    SELECT 5/0; /* Fake the error */
END
END TRY

BEGIN CATCH
    THROW 50000, @ErrorMessage, 1;
END CATCH

END
GO
/****** Object:  StoredProcedure [QA].[usp_compare_migration_tables_overview]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [QA].[usp_compare_migration_tables_overview]
	@DebugFlag BIT
	,@SourceDB NVARCHAR(500)   --Client Staging, FilevineProductionImport, FilevineCanadianImport,FilevineStagingImport
	,@SourceSchema NVARCHAR(500)	
	,@SourcePrefix NVARCHAR(500)
	,@TargetDB NVARCHAR(500) --Client Staging, FilevineProductionImport, FilevineCanadianImport,FilevineStagingImport
	,@TargetSchema NVARCHAR(500)
	, @TargetPrefix NVARCHAR(500)
AS
BEGIN
declare
	@SQLn nvarchar(max)
	, @SourceFVImportPrefixQuoteUnderscore VARCHAR(1000)
	, @TargetFVImportPrefixQuoteUnderscore VARCHAR(1000)
	,@SQLn_TableRowCounts nvarchar(max)
	,@fullSQL varchar(max)
	,@SQLn_SubSelect nvarchar(max)

--set @SourceDB='4933_JohnZaid_r'
--set @TargetDB='550000003_ZaidTestStage'
--set @SourceSchema='dbo'
--set @TargetSchema='dbo'
--set @SourcePrefix ='_JKZTest4_'
--set @TargetPrefix='_ZaidTestStage_'
SET @SourceFVImportPrefixQuoteUnderscore = REPLACE(@SourcePrefix, '_', '[_]')
SET @TargetFVImportPrefixQuoteUnderscore = REPLACE(@TargetPrefix, '_', '[_]')
set @SQLn_TableRowCounts='with Table_row_counts([CommonTableName],FullTableName1,FullTableName1_ROWCOUNT,  FullTableName2,FullTableName2_ROWCOUNT,RowCount_EQUAL,RowCount_REMOVED,RowCount_ADDED)
as (select   CASE    WHEN test1.[Table] IS NOT NULL THEN test1.[Table]    ELSE test2.[Table]  END [CommonTableName] ,
  test1.[TableName] FullTableName1,isnull(test1.[TotalRowCount],0) FullTableName1_ROWCOUNT,
    test2.[TableName] FullTableName2,
isnull(test2.[TotalRowCount],0) FullTableName2_ROWCOUNT,
  CASE    WHEN (isnull(test1.[TotalRowCount],0) - isnull(test2.[TotalRowCount],0))  <= 0 THEN isnull(test1.[TotalRowCount],0) 
		  ELSE isnull(test2.[TotalRowCount],0)
		  END RowCount_EQUAL,
  CASE    WHEN (isnull(test1.[TotalRowCount],0)   - isnull(test2.[TotalRowCount],0)) > 0 THEN (isnull(test1.[TotalRowCount],0)  - isnull(test2.[TotalRowCount],0))
	      ELSE 0		  END RowCount_REMOVED,
  CASE	  WHEN (isnull(test1.[TotalRowCount],0) - isnull(test2.[TotalRowCount],0))  <= 0 THEN  (isnull(test2.[TotalRowCount],0) - isnull(test1.[TotalRowCount],0) )
			ELSE 0				  END RowCount_ADDED
from(SELECT  t.[name] AS [TableName]  ,REPLACE(LEFT(t.[name],LEN(t.[name]) - PATINDEX(''%[A-Za-z]%'',REVERSE(t.[name])) + 1),'''+@SourcePrefix+''','''')  AS [Table],  SUM(ISNULL(p.[rows], 0)) [TotalRowCount]
FROM ['+@SourceDB+'].sys.tables AS t
INNER JOIN ['+@SourceDB+'].sys.partitions AS p  ON t.object_id = p.[object_id]  AND p.index_id IN (0, 1)
WHERE t.[name] LIKE ''%'+@SourceFVImportPrefixQuoteUnderscore+'%'' GROUP BY SCHEMA_NAME(schema_id),         t.name) as test1
 full outer join( SELECT  t.[name] AS [TableName] ,REPLACE(LEFT(t.[name],LEN(t.[name]) - PATINDEX(''%[A-Za-z]%'',REVERSE(t.[name])) + 1),'''+@TargetPrefix+''','''') AS [Table],
  SUM(ISNULL(p.[rows], 0)) [TotalRowCount]
  FROM ['+@TargetDB+'].sys.tables AS t
INNER JOIN ['+@TargetDB+'].sys.partitions AS p  ON t.object_id = p.[object_id]  AND p.index_id IN (0, 1)
WHERE t.[name] LIKE ''%'+@TargetFVImportPrefixQuoteUnderscore+'%'' GROUP BY SCHEMA_NAME(schema_id),         t.name) as test2 on test1.[Table]=test2.[Table]
) '

set @SQLn=' select b.[CommonTableName],'''+@SourceDB+'.'+@SourceSchema+'.''+'+' SourceTableName as SourceTableName,
'''+@TargetDB+'.'+@TargetSchema+'.''+'+' TargetTablename as TargetTableName,max(FullTableName1_ROWCOUNT) 
Source_ROWCOUNT,max(FullTableName2_ROWCOUNT) Target_ROWCOUNT,  max(RowCount_EQUAL) RowCount_EQUAL,max(RowCount_REMOVED) RowCount_REMOVED,
max(RowCount_ADDED) RowCount_ADDED,  max(ColumnNames_EQUAL) ColumnNames_EQUAL,max(ColumnNames_REMOVED_From_TARGET) ColumnNames_REMOVED_From_TARGET,
max(ColumnNames_ADDED_To_TARGET) ColumnNames_ADDED_To_TARGET,case when ColumnNames_REMOVED_From_TARGET > 0 then ListofColumnsSource  else null end ListofColumns_REMOVED_From_TARGET,   
case when ColumnNames_ADDED_To_TARGET > 0 then ListofColumnsTarget else null end ListofColumns_ADDED_To_TARGET
from(
SELECT  a.[CommonTableName],  max(FullTableName1) SourceTableName,  max(FullTableName2) TargetTablename,  
SUM(ISNULL([EQUAL], 0)) ColumnNames_EQUAL,  SUM(ISNULL([REMOVED], 0)) ColumnNames_REMOVED_From_TARGET,  SUM(ISNULL([ADDED], 0)) ColumnNames_ADDED_To_TARGET, 
string_agg(case when [ColumnName1] is not null and ColumnName2 is null then ColumnName1 else null end ,'','') ListofColumnsSource,  
string_agg(case when [ColumnName2] is not null and ColumnName1 is null then ColumnName2 else null end,'','') ListofColumnsTarget 
from  ( '
set @SQLn_SubSelect='
select case when test1.TableName is not null then REPLACE(LEFT(test1.[TableName], LEN(test1.[TableName]) - PATINDEX(''%[A-Za-z]%'', REVERSE(test1.[TableName])) + 1), '''+@SourcePrefix+''', '''') 		else REPLACE(LEFT(test2.[TableName], LEN(test2.[TableName]) - PATINDEX(''%[A-Za-z]%'', REVERSE(test2.[TableName])) + 1), '''+@TargetPrefix+''', '''') end CommonTableName,max(test1.TableName) FullTableName1,test1.ColumnName [ColumnName1],max(test2.TableName) FullTableName2,test2.ColumnName [ColumnName2], max(CASE  WHEN COALESCE(test2.[TableName], test2.[ColumnName]) IS NOT NULL AND      COALESCE(test1.[TableName], test1.[ColumnName]) IS NOT NULL THEN 1  END) [EQUAL],  max(CASE    WHEN COALESCE(test2.[TableName], test2.[ColumnName]) IS NULL THEN 1  END) [REMOVED],  max(CASE    WHEN COALESCE(test1.[TableName], test1.[ColumnName]) IS NULL THEN 1  END) [ADDED]  from  (	SELECT		t.[name] AS [TableName]		,c.[name] AS [ColumnName]		,c.[column_id]		,REPLACE(LEFT(t.[name],LEN(t.[name]) - PATINDEX(''%[A-Za-z]%'',REVERSE(t.[name])) + 1),'''+@SourcePrefix+''','''') AS [Table]	FROM		['+@SourceDB+'].sys.tables AS t	INNER JOIN ['+@SourceDB+'].sys.columns AS c ON t.object_id = c.object_id	WHERE		t.[name] LIKE ''%'+@SourceFVImportPrefixQuoteUnderscore+'%''  GROUP BY SCHEMA_NAME(schema_id), t.name,c.[name],c.[column_id] ) AS test1 FULL OUTER JOIN (	SELECT		t.[name] AS [TableName]		,c.[name] AS [ColumnName]		,c.[column_id]		,REPLACE(LEFT(t.[name],LEN(t.[name]) - PATINDEX(''%[A-Za-z]%'',REVERSE(t.[name])) + 1),'''+@TargetPrefix+''','''') AS [Table]
	FROM		['+@TargetDB+'].sys.tables AS t	INNER JOIN ['+@TargetDB+'].sys.columns AS c ON t.object_id = c.object_id	WHERE	t.[name] LIKE ''%'+@TargetFVImportPrefixQuoteUnderscore+'%''  GROUP BY SCHEMA_NAME(schema_id), t.name,c.[name],c.[column_id]) AS test2 ON test1.[ColumnName] = test2.[ColumnName] AND     REPLACE(LEFT(test1.[TableName], LEN(test1.[TableName]) - PATINDEX(''%[A-Za-z]%'', REVERSE(test1.[TableName])) + 1), '''+@SourcePrefix+''', '''')  =   REPLACE(LEFT(test2.[TableName], LEN(test2.[TableName]) - PATINDEX(''%[A-Za-z]%'', REVERSE(test2.[TableName])) + 1), '''+@TargetPrefix+''', '''')    group by case when test1.TableName is not null then REPLACE(LEFT(test1.[TableName], LEN(test1.[TableName]) - PATINDEX(''%[A-Za-z]%'', REVERSE(test1.[TableName])) + 1), '''+@SourcePrefix+''', '''')  else REPLACE(LEFT(test2.[TableName], LEN(test2.[TableName]) - PATINDEX(''%[A-Za-z]%'', REVERSE(test2.[TableName])) + 1), '''+@TargetPrefix+''', '''')  end ,test1.ColumnName ,test2.ColumnName )a group by  a.[CommonTableName]) b full outer JOIN Table_row_counts trc  ON b.SourceTableName  = trc.FullTableName1 and b.TargetTablename=trc.FullTableName2 where b.CommonTableName is not NULL GROUP BY b.[CommonTableName],'''+@SourceDB+'.'+@SourceSchema+'.''+'+' SourceTableName,'''+@TargetDB+'.'+@TargetSchema+'.''+'+' TargetTablename, ColumnNames_REMOVED_From_TARGET, ListofColumnsSource,	 ColumnNames_ADDED_To_TARGET, ListofColumnsTarget order by b.[CommonTableName]'
	set @fullSQL = (select concat(@SQLn_TableRowCounts,' ',@SQLn,@SQLn_SubSelect))
IF @DebugFlag = 0
				EXEC (@fullSQL)
Else	
	Select @fullSQL
END



GO
/****** Object:  StoredProcedure [QA].[usp_verify_import_load]    Script Date: 12/12/2022 1:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [QA].[usp_verify_import_load]
      @StagingImport BIT = 0 --staging tables = 1/import tables = 0
    , @ReviewData BIT = 0 --select top 100 * from table = 1/ counts = 0
    , @FVDatabase VARCHAR(1000) = '' --'4472_MargolisEdelstein'
    , @FVSchema VARCHAR(1000) = '' --'dbo'
    , @FVProductionPrefix VARCHAR(1000) = '' --'_MargolisEdelsteinBea_'
    , @FVProductionDB VARCHAR(1000) = 'FilevineProductionImport'
    , @Batch VARCHAR(1000) = '100'
    , @PEIDS varchar(500) ='' --SINGLE VALUE ONLY
    --, @CEIDS varchar(500) = '' -- comma list of CEIDs 

AS
    BEGIN
        DECLARE 
             @FVProductionDBQuoteUnderscore VARCHAR(1000)
            , @SQL VARCHAR(MAX)
            , @SQL1 VARCHAR(MAX)
			, @SQL2 VARCHAR(MAX)
			, @SQL3 VARCHAR(MAX)
			, @SQL4 VARCHAR(MAX)

        SET @FVProductionDBQuoteUnderscore = REPLACE(@FVProductionPrefix, '_', '[_]')

        BEGIN
            PRINT 'Import review'
            
            SET @SQL1 = 
                 '
                 ' 
                + CASE 
                    WHEN @StagingImport = 0 
                    THEN 'USE [' + @FVProductionDB + ']'

                    ELSE 'USE [' + @FVDatabase + ']'
                 END
                + '
                    DECLARE 
                        @VerifyMapping TABLE 
                            (
                                 ID INT IDENTITY(1,1)
                                , TabID INT
                                , TableName VARCHAR(1000)
                                , SchemaName VARCHAR(1000)
                                , ColumnName VARCHAR(1000)
                                , OrderSubString varchar(1000)
                            );

                    DECLARE
                             @Counter INT = 1
                            , @SQL VARCHAR(MAX)
                            , @SQLCount NVARCHAR(MAX)
                            , @plist nvarchar(500)
                            /*, @clist nvarchar(500)*/

                    SET @plist = ''' + @PEIDS + '''
                
                    IF EXISTS
                        (
                            SELECT
                                1
                            FROM
                                INFORMATION_SCHEMA.TABLES t
                            WHERE
                                TABLE_NAME LIKE ''' + @FVProductionDBQuoteUnderscore + '%''
                        )
                        BEGIN
                            INSERT INTO
                                @VerifyMapping
                                (
                                     Tablename
                                    , SchemaName
                                    , ColumnName
                                    , TabID
                                    , OrderSubString
                                )
                            SELECT DISTINCT
                                 t.TABLE_NAME
                                , t.TABLE_SCHEMA
                                , c.COLUMN_NAME
                                , DENSE_RANK() OVER(ORDER BY t.TABLE_NAME) TABID
                                , SUBSTRING(t.TABLE_NAME, LEN(REPLACE(t.TABLE_NAME, '' '', ''_'')) - CHARINDEX(''_'', REVERSE(t.TABLE_NAME), 1), LEN(REPLACE(t.TABLE_NAME, '' '', ''_'')))
                            FROM 
                                INFORMATION_SCHEMA.TABLES t
                                    INNER JOIN INFORMATION_SCHEMA.COLUMNS c
                                        ON t.TABLE_NAME = C.TABLE_NAME
                            WHERE
                                (
                                        t.TABLE_NAME LIKE ''' + @FVProductionDBQuoteUnderscore + '%''
                                    OR  t.TABLE_NAME LIKE ''__FV_%''
                                )
								AND t.TABLE_NAME NOT LIKE ''' + @FVProductionDBQuoteUnderscore + '%_Meta%''
                            GROUP BY
                                 t.table_name
                                , t.table_SCHEMA
                                , c.COLUMN_NAME
                            ORDER BY
                                 t.table_name
                                , t.table_SCHEMA
                                , SUBSTRING(t.TABLE_NAME, LEN(REPLACE(t.TABLE_NAME, '' '', ''_'')) - CHARINDEX(''_'', REVERSE(t.TABLE_NAME), 1), LEN(REPLACE(t.TABLE_NAME, '' '', ''_'')))
                                , c.COLUMN_NAME


                 ' 

            -----------------------------
            -- Loop through the tables --
            -----------------------------
			SET @SQL2 = 
                 '
                            DECLARE
                                @CountTabs INT = (SELECT MAX(TabID) FROM @VerifyMapping)

                            WHILE @Counter <= @CountTabs
                                BEGIN
                                    DECLARE
                                         @TabName VARCHAR(1000) = (SELECT TOP 1 TableName FROM @VerifyMapping WHERE TabID = @counter)
                                        , @SchemaName VARCHAR(1000) = (SELECT TOP 1 SchemaName FROM @VerifyMapping WHERE TabID = @counter)

                        
                 '
                 
			-----------------------------
            -- count or display rows --
            -----------------------------
			SET @SQL3 = 
				 '
                                    IF ' + CONVERT(VARCHAR, @ReviewData) + ' = 0
                                        BEGIN
                                            DECLARE 
                                                @tablereccount BIGINT
                                    
                                            SET @SQLCount = 
                                                ''
                                                    PRINT ''''VARIABLE COUNT FOR TABLE ['' + @SchemaName + ''].['' + @TabName + '']''''
                                                    
                                                    SELECT 
                                                        @tablereccount = COUNT(*)
                                                    FROM
                                                        ['' + @SchemaName + ''].['' + @TabName + '']
                                                ''

                                            execute sp_executesql
                                                 @sqlcount
                                                , N''@tablereccount bigint output''
                                                , @tablereccount = @tablereccount output
                        
                                            IF @tablereccount > 0
                                                BEGIN
                                                    SET @SQL = 
                                                        ''
                                                            PRINT ''''COUNTS FOR TABLE ['' + @SchemaName + ''].['' + @TabName + '']''''
                                                            
                                                            SELECT
                                                                 '''''' + @TabName + '''''' [TableName]
                                                                , '''''' + @SchemaName + '''''' [SchemaName]
                                                                , COUNT(*) [RowCount]
                                                                 '' + CASE WHEN LEFT(@TabName,5) != ''__FV_'' THEN '', __ImportStatus '' ELSE '''' END + ''
                                                                 '' + CASE WHEN LEFT(@TabName,5) != ''__FV_'' THEN '', __errorMessage '' ELSE '''' END + ''
                                                            FROM
                                                                ['' + @SchemaName + ''].['' + @TabName + '']''
                                                            + CASE 
                                                                WHEN LEFT(@TabName,5) != ''__FV_'' 
                                                                THEN ''
                                                            GROUP BY
                                                                 __ImportStatus
                                                                , __errorMessage
                                                            ORDER BY
                                                                __Importstatus
                                                                    ''

                                                                ELSE ''''
                                                             END
                            
                                                    EXEC (@SQL)
                                                END
                                        END
                                    ELSE
                                        BEGIN
                                            DECLARE 
                                                 @PEIDField VARCHAR(1000) = (SELECT TOP 1 ColumnName FROM @VerifyMapping WHERE ColumnName = ''ProjectExternalID'' AND TabID = @counter)
                                                , @CEIDField VARCHAR(1000) = (SELECT TOP 1 ColumnName FROM @VerifyMapping WHERE ColumnName = ''ContactExternalID'' AND TabID = @counter)
				'
				
			SET @SQL4 = 
				'
                                            SET @SQL = 
                                                '' 
                                                    PRINT ''''RECORDS FOR TABLE ['' + @SchemaName + ''].['' + @TabName + '']''''
                                                    
                                                    SELECT ' + CASE WHEN ISNUMERIC(@Batch) = 1 THEN ' top ' + @Batch ELSE '' END + '
                                                         '''''' + @TabName + '''''' [TableName]
                                                        , '''''' + @SchemaName + '''''' [SchemaName]
                                                        , * 
                                                    FROM
                                                        ['' + @SchemaName + ''].['' + @TabName + '']'' + 
                                            
                                                 CASE WHEN     @PEIDField IS NOT NULL and len(@plist) > 0 
                                                                THEN '' WHERE ProjectExternalID = ''''''+ @plist + '''''''' 
                                                        else '' '' 
                                                        
                                                 END + 
                                                
                                                
                                                 CASE WHEN @PEIDField IS NOT NULL OR @CEIDField IS NOT NULL 
                                                     THEN '' ORDER BY '' + 
                                                        CASE 
                                                            WHEN @PEIDField IS NOT NULL 
                                                            THEN @PEIDField 
                                                            
                                                            ELSE '''' 
                                                        END +
                                                        CASE 
                                                            WHEN @CEIDField IS NOT NULL 
                                                            THEN 
                                                                CASE 
                                                                    WHEN @PEIDField IS NOT NULL 
                                                                    THEN '' , '' 
                                                                    
                                                                    ELSE '''' 
                                                                END + @CEIDField 
                                                            
                                                            ELSE '''' 
                                                        END 
                                                    
                                                    ELSE '''' 
                                                END
                                                
                                            EXEC (@SQL) 
                                        END

                                    SET @Counter = @Counter + 1
                                END
                        END
                    ELSE
                        PRINT ''No Tables imported for this prefix or prefix name is not correct.''
        
                '
			SET @SQL = 
				  @SQL1
				+ @SQL2
				+ @SQL3
				+ @SQL4

            EXEC (@SQL)
        END
    END

GO
