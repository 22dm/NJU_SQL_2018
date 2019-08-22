USE edu
GO

SELECT sno, sname
FROM student
WHERE RIGHT(sno, 1) % 2 = 0
GO

SELECT sno, sname, birthday
FROM student
WHERE RIGHT(CONVERT(varchar(8),birthday,112),4) IN (
SELECT RIGHT(CONVERT(varchar(8),birthday,112),4)
FROM student
GROUP BY RIGHT(CONVERT(varchar(8),birthday,112),4)
HAVING count(*) > 1)
ORDER BY MONTH(birthday), DAY(birthday), YEAR(birthday)
GO

SELECT RTRIM(cname) + '最高分是' + CONVERT(varchar(3), MAX(score))
FROM student_course, course
WHERE student_course.cno = course.cno
GROUP BY cname
GO

DECLARE @a int, @b int, @c int, @n int
SET @n = 100
WHILE @n < 1000 BEGIN
  SET @a = @n / 100
  SET @b = @n / 10 % 10
  SET @c = @n % 10
  IF @a * @a * @a + @b * @b * @b + @c * @c * @c = @n
      PRINT @n
  SET @n = @n + 1
END
GO

EXEC sp_addtype id_type, 'Varchar(10)'
GO

CREATE TABLE employee
(
  EmployeeID id_type NOT NULL PRIMARY KEY,
  Name char(10) NOT NULL,
  Birthday datetime NOT NULL,
  Sex char(2) NOT NULL DEFAULT '男',
  PhoneNumber char(12),
  DepartmentID char(3) NOT NULL,
)
GO

CREATE FUNCTION Sno2Avgscore(@sno_in char(10))
RETURNS real AS
BEGIN
  RETURN(SELECT AVG(score)
  FROM student_course
  WHERE sno = @sno_in)
END
GO

SELECT dbo.Sno2Avgscore('20101010')
GO

CREATE FUNCTION stusameyear(@year_in int)
RETURNS TABLE AS
RETURN(SELECT dname, COUNT(*) 'rs'
FROM student, department
WHERE student.dno = department.dno AND YEAR(student.birthday) = @year_in
GROUP BY dname)
GO

SELECT *
FROM dbo.stusameyear(1989)
GO

CREATE FUNCTION infobynamestr(@namestr varchar(100))
returns @res TABLE
(sno nchar(8),
  sname nchar(8),
  sex nchar(2),
  birthday datetime)
AS
BEGIN
  INSERT @res
  SELECT sno, sname, sex, birthday
  FROM student
  WHERE CHARINDEX(RTRIM(sname), @namestr) > 0
  RETURN
END
GO

SELECT *
FROM dbo.infobynamestr('张小兵,李燕,上官青')
GO
