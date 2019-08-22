USE edu
GO

SELECT student.sno, sname, AVG(score) AS '平均成绩'
FROM student, student_course
WHERE student.sno = student_course.sno
GROUP BY student.sno, sname
HAVING AVG(score) >= 60
GO

SELECT COUNT(*) AS '人数'
FROM teacher
WHERE tname LIKE '李%'
GO

SELECT student.*
FROM student, student_course, teacher_course, teacher
WHERE student.sno = student_course.sno
	AND student_course.cno = teacher_course.cno
	AND teacher_course.tno = teacher.tno
	AND tname = '董青'
GO


SELECT *
FROM student
WHERE sno IN (
	SELECT student.sno
	FROM student, student_course
	WHERE student.sno = student_course.sno
	GROUP BY student.sno
	HAVING COUNT(*) < (SELECT COUNT(*) FROM course)
)
GO

SELECT student.sno, sname, AVG(score) AS '平均成绩'
FROM student, student_course
WHERE student.sno = student_course.sno
GROUP BY student.sno, sname
HAVING COUNT(CASE WHEN score < 60 THEN 1 END) >= 2
GO

SELECT course.cno, cname, COUNT(*) AS '总人数'
FROM student_course, course
WHERE course.cno = student_course.cno
GROUP BY course.cno, cname
GO

SELECT sname, score
FROM student, student_course, course
WHERE course.cno = student_course.cno
	AND student.sno = student_course.sno
	AND cname = 'c++程序设计'
	AND score < 60
GO

SELECT course.cno, cname, COUNT(*) AS '总人数'
FROM student_course, course
WHERE course.cno = student_course.cno
GROUP BY course.cno, cname
HAVING COUNT(*) >= 3
ORDER BY COUNT(*) DESC
GO

SELECT *
FROM student
WHERE MONTH(GETDATE()) - MONTH(birthday) = 1
GO

SELECT course.cno, cname, COUNT(*) AS '总人数',
	COUNT(CASE WHEN sex = '男' THEN 1 END) AS '男生人数',
	COUNT(CASE WHEN sex = '女' THEN 1 END) AS '女生人数'
FROM student_course, course, student
WHERE course.cno = student_course.cno
	AND student.sno = student_course.sno
GROUP BY course.cno, cname
GO