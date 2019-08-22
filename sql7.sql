USE edu
GO

DECLARE dcursor CURSOR FORWARD_ONLY STATIC
FOR SELECT * FROM department
OPEN dcursor
SELECT CURSOR_STATUS('global', 'dcursor') AS 'cursor打开状态'
SELECT @@CURSOR_ROWS AS 'cursor内数据条数'
FETCH NEXT FROM dcursor
WHILE @@FETCH_STATUS = 0
    FETCH NEXT FROM dcursor
CLOSE dcursor
DEALLOCATE dcursor
GO

DECLARE scursor CURSOR SCROLL
FOR SELECT * FROM student
OPEN scursor
FETCH FIRST FROM scursor
FETCH LAST FROM scursor
FETCH ABSOLUTE 3 FROM scursor
FETCH ABSOLUTE -3 FROM scursor
CLOSE scursor
DEALLOCATE scursor
GO

CREATE PROC noscore
AS 
BEGIN
	DECLARE @sno char(8), @sname char(8), @cname char(20)
	DECLARE ccursor CURSOR
	FOR 
		SELECT student.sno, sname, cname
		FROM student_course, student, course
		WHERE student.sno = student_course.sno and course.cno = student_course.cno and score IS NULL
	OPEN ccursor
	FETCH NEXT FROM ccursor INTO @sno, @sname, @cname
	WHILE @@fetch_status = 0
	BEGIN	
		PRINT @sno + @sname + @cname + '成绩未登录'
		FETCH NEXT FROM ccursor INTO @sno, @sname, @cname
	END
	CLOSE ccursor
	DEALLOCATE ccursor
END
GO
EXEC noscore
GO
DROP PROC noscore
GO

CREATE PROC printgrade @cno char(10)
AS 
BEGIN
	DECLARE @sno char(8), @sname char(8), @cname char(20), @score tinyint
	DECLARE ccursor CURSOR STATIC
	FOR 
		SELECT student.sno, sname, cname, score
		FROM student_course, student, course
		WHERE student.sno = student_course.sno and course.cno = student_course.cno and course.cno = @cno
	OPEN ccursor
	FETCH NEXT FROM ccursor INTO @sno, @sname, @cname, @score
	IF @@fetch_status = -1
		PRINT '输入错误，没有该课程号！'
	ELSE
		BEGIN
			PRINT '课程号:' + @cno + '课程名:' + @cname
			PRINT '------------------------------------'
			WHILE @@fetch_status = 0
			BEGIN	
				PRINT @sno + '    ' + @sname + '    ' + COALESCE(CONVERT(varchar(3), @score), '成绩未登录')
				FETCH NEXT FROM ccursor INTO @sno, @sname, @cname, @score
			END
			PRINT CHAR(10) + @cname + '选修人数为' + CONVERT(varchar(5), @@CURSOR_ROWS)
		END
	CLOSE ccursor
	DEALLOCATE ccursor
END
GO
EXEC printgrade 2
GO
DROP PROC printgrade
GO