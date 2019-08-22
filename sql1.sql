USE edu
GO

-- 1
SELECT dtel
FROM department
WHERE dname = '软件学院'

-- 2
SELECT tname, birthday
FROM teacher
WHERE sex = '男'
ORDER BY 2 DESC

-- 3
SELECT tname, title, teacher_course.*
FROM teacher, teacher_course
WHERE teacher.tno = teacher_course.tno

-- 4
SELECT course.cno, cname, COUNT(*) AS '选修人数'
FROM student_course, course
WHERE student_course.cno = course.cno
GROUP BY course.cno, cname

-- 5
SELECT student.*
FROM department, student
WHERE student.dno = department.dno
	AND dname = '软件学院'

-- 6
SELECT student.*
FROM department, student
WHERE student.dno = department.dno
	AND dname = '教育学院'
	AND birthday < (
		SELECT MAX(birthday)
		FROM student, department
		WHERE student.dno = department.dno
			AND dname = '数信学院'
	)

-- 7
SELECT tname, dname
FROM department, teacher
WHERE tno NOT IN (
		SELECT tno
		FROM teacher_course
	)
	AND teacher.dno = department.dno

-- 8
SELECT title, COUNT(*)
FROM department, teacher
WHERE dname = '软件学院'
	AND teacher.dno = department.dno
GROUP BY title

-- 9
SELECT *
FROM student
WHERE sno IN (
	SELECT sno
	FROM student_course
	GROUP BY sno
	HAVING COUNT(cno) >= 3
)

-- 10
SELECT sno AS '编号', sname AS '姓名', '学生' AS '类别'
FROM student
WHERE sex = '女'
	AND year(getdate()) - year(birthday) < 23
UNION
SELECT tno, tname, '教师'
FROM teacher
WHERE sex = '女'
	AND year(getdate()) - year(birthday) < 30

-- 11
SELECT '90~100' AS '分数段类型', COUNT(*) AS 人数
FROM student_course
WHERE score >= 90
UNION
SELECT '80~89', COUNT(*)
FROM student_course
WHERE score >= 80
	AND score < 90
UNION
SELECT '70~79', COUNT(*)
FROM student_course
WHERE score >= 70
	AND score < 80
UNION
SELECT '60~69', COUNT(*)
FROM student_course
WHERE score >= 60
	AND score < 70
UNION
SELECT '60 以下', COUNT(*)
FROM student_course
WHERE score < 60
ORDER BY 1 DESC

-- 12
SELECT cname, AVG(score)
FROM student, student_course, course, department
WHERE student.sno = student_course.sno
	AND student_course.cno = course.cno
	AND student.dno = department.dno
	AND dname = '软件学院'
GROUP BY dname,cname
