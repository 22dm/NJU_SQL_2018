USE edu
GO

--CREATE INDEX SBIRTHDAY_IDX
--ON student(birthday)
--GO

--CREATE INDEX DTEL_HOME_IDX
--ON department(dtel,dhome DESC)
--GO

SELECT *
FROM sys.indexes
WHERE name = 'SBIRTHDAY_IDX' OR name = 'DTEL_HOME_IDX'
GO

EXEC sp_helpindex student
EXEC sp_helpindex department
GO

CREATE VIEW view_female_teacher
AS 
SELECT * from teacher
WHERE sex='女'
GO

CREATE VIEW view_dept_num
AS
SELECT department.dno, dname, ISNULL(dnum.count,0)'总人数'
FROM department
LEFT JOIN (
SELECT dno, COUNT(*) count
FROM student
GROUP BY dno)
AS dnum
ON department.dno = dnum.dno
GO

CREATE VIEW KCCJ_VIEW
AS
SELECT sno, course.cno, cname, score
FROM student_course, course
WHERE student_course.cno = course.cno
GO

SELECT AVG(year(getdate()) - year(birthday))
FROM view_female_teacher
GO

SELECT *
FROM view_dept_num
WHERE 总人数 = 0
GO

SELECT student.sno, sname, cno, cname
FROM student,KCCJ_VIEW
WHERE student.sno = KCCJ_VIEW.sno and KCCJ_VIEW.score is null
go

Insert into view_female_teacher
Values('836052','何星语','女','1985-06-5','1','副教授','浙江宁波','66000','15198789733','xingyuhe@gmail.com')
go

UPDATE view_dept_num
SET 总人数 = 2
WHERE dname='神秘学院'
go

UPDATE KCCJ_VIEW
SET score = 90
FROM KCCJ_VIEW, student
WHERE cname = '计算机导论' and KCCJ_VIEW.sno = student.sno and sname = '张三'
go

