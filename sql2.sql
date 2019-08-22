USE edu
GO

-- 1.1
SELECT student.sno,sname,dname,cname,score
FROM student,student_course,department,course
WHERE student.sno=student_course.sno and student_course.cno=course.cno and student.dno = department.dno and score < 60
GO

-- 1.2
SELECT student.sno, sname, AVG(score)平均成绩
FROM student,student_course
WHERE student.sno = student_course.sno
GROUP BY student.sno, student.sname
GO

-- 2.1
UPDATE teacher
SET tel = '83421236'
WHERE tname = '王英'
GO

-- 2.2
UPDATE teacher_course
SET classroom = 'D403'
FROM course,teacher_course
WHERE course.cno=teacher_course.cno and cname = '数据结构'
GO

-- 2.3
UPDATE student_course
SET score += 5
FROM course,student_course
WHERE course.cno=student_course.cno and cname = '数据库原理' and score < 70
GO

-- 2.4
DELETE
FROM student_course
WHERE score IS NULL
GO

-- 2.5
UPDATE student
SET birthday = DATEADD(year,-1,birthday)
WHERE year(getdate()) - year(birthday) < 18
GO

-- 3.1
CREATE INDEX DNAME_INDX
ON department(dname)
GO

-- 3.2
CREATE INDEX TITLE_BIRTHDAY_INX
ON teacher(title ASC,birthday DESC)
GO

-- 3.3
EXEC sp_rename 'department.DNAME_INDX','DNAME_INX'
GO