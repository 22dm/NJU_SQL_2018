USE edu
GO

DECLARE @stu_no char(8)
SET @stu_no = (SELECT sno FROM student WHERE sname = '张倩')
GO

DECLARE @grademax int, @grademin int, @gradesum int
SELECT @grademax = MAX(score) , @grademin = MIN(score), @gradesum = SUM(score)
FROM student_course
WHERE cno = '2'
SELECT @grademax, @grademin, @gradesum
GO

DECLARE @rows int
SET @rows = (SELECT COUNT(*) FROM student)
SELECT @rows
GO

DECLARE @malect int, @femalect int
SET @malect = (SELECT COUNT(*) FROM student WHERE sex = '男')
SET @femalect = (SELECT COUNT(*) FROM student WHERE sex = '女')
SELECT @malect '男生', @femalect '女生'
GO

DECLARE @studate datetime
SET @studate = getdate()
SELECT sname, year(@studate) - year(birthday) '年龄'
FROM student
GO

DECLARE @total real, @outstanding real, @outstandingp real
SELECT @total = COUNT(*) , @outstanding = COUNT(CASE WHEN score >= 90 THEN 1 END), @outstandingp = @outstanding / @total * 100
FROM student_course
WHERE cno = '3'
SELECT @total '总人数', @outstanding '优秀人数', @outstandingp '优秀率'
GO

SELECT *
FROM student
SELECT @@ROWCOUNT '记录行数'
GO

DECLARE @dno char(6), @dname char(8), @dhome varchar(40), @dzipcode char(6), @dtel varchar(40)
SELECT @dno = '5', @dname = '大气学院', @dhome = '河北省石家庄市裕华区南二环东路号', @dzipcode = '50024', @dtel = '80788105'
INSERT INTO department
VALUES (@dno, @dname, @dhome, @dzipcode, @dtel)
SELECT *
FROM department
