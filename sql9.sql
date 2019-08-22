USE edu
GO

CREATE FUNCTION SCORE2GRADE(@score tinyint)
RETURNS char(10) AS
BEGIN
	DECLARE @grade char(10)
	SET @grade =
	CASE
		WHEN @score >= 85 THEN '优秀'
		WHEN @score >= 60 THEN '及格'
		ELSE '不及格'
	END
	RETURN @grade
END
GO

SELECT dbo.SCORE2GRADE(100)
GO

DROP FUNCTION SCORE2GRADE
GO

CREATE PROC printgrade @sno char(10)
AS 
BEGIN
	DECLARE @sname char(8), @cname char(20), @score tinyint
	DECLARE ccursor CURSOR STATIC
	FOR 
		SELECT cname, score
		FROM student_course, course
		WHERE student_course.sno = @sno and course.cno = student_course.cno
	OPEN ccursor
	FETCH NEXT FROM ccursor INTO @cname, @score
	BEGIN
		WHILE @@fetch_status = 0
		BEGIN	
			PRINT @cname + COALESCE(CONVERT(varchar(3), @score), '成绩未登录')
			FETCH NEXT FROM ccursor INTO @cname, @score
		END
		SELECT @sname = sname FROM student WHERE sno = @sno
		PRINT '姓名: ' + @sname
		PRINT '学号: ' + @sno
		PRINT '选修课程数: ' + CONVERT(varchar(5), @@CURSOR_ROWS)
	END
	CLOSE ccursor
	DEALLOCATE ccursor
END
GO

EXEC printgrade 20101010
GO

DROP PROC printgrade
GO