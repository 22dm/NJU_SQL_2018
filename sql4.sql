USE UNIVERSITY
GO

CREATE RULE entime_date_rule
AS @entime >= '2017-01-01' AND @entime <= getdate()
GO

EXEC sp_helptext entime_date_rule
GO

CREATE RULE sex_rule
AS @sex IN ('男', '女')
GO

CREATE RULE telphone_rule
AS @tel LIKE '^[0-9]{9}$'
GO

EXEC sp_bindrule entime_date_rule, 'student.entime'
INSERT INTO student
VALUES ('20101031','张华','男',NULL,'1989-03-15 ',NULL,'1',NULL,'2010-9-1','河北省沧州市',NULL)
GO

INSERT INTO department
VALUES ('6','航空学院','河北省石家庄市裕华区南二环东路号','50024','88100')
EXEC sp_bindrule telphone_rule, 'department.dtel'
INSERT INTO department
VALUES ('7','航海学院','河北省石家庄市裕华区南二环东路号','50024','88200')
GO

EXEC sp_unbindrule 'student.entime'
EXEC sp_unbindrule 'department.dtel'
GO

CREATE DEFAULT entime_defa
AS '2017-09-01'
GO
EXEC sp_bindefault entime_defa, 'student.entime'
GO

ALTER TABLE student
DROP CONSTRAINT fk_dno
GO
ALTER TABLE student
ADD CONSTRAINT fk_dno
FOREIGN KEY (dno) REFERENCES department(dno)
ON UPDATE CASCADE
ON DELETE CASCADE
GO
UPDATE department
SET dno = 8
WHERE dname = '数信学院'
GO
SELECT *
FROM student
GO
DELETE
FROM department
WHERE dname = '法政学院'
GO
SELECT *
FROM student
GO

SELECT sno, sname
FROM student
GO
 
-- 最普通的表扫描

CREATE INDEX idx_sname
ON student(sname)
SELECT sno, sname
FROM student
GO
 
-- 尽管sname有索引，但sno没有，所以还是普通的表扫描。

SELECT sname
FROM student
WHERE sname LIKE '张%'
GO
 
-- sname有索引，所以是索引查找。

ALTER TABLE student
ADD PRIMARY KEY(sno)
SELECT sno, sname, birthday
FROM student
GO
 
-- sno也有主键索引了，所以现在是聚类索引扫描。


SELECT sno, sname, birthday
FROM student
WHERE sno = '20101006'
GO
 
-- 同上。

SELECT sno, sname, (year(entime) - year(birthday)) AS '入学年龄'
FROM student
GO
 
-- 同上。

SELECT department.dno, ISNULL(dnum.count,0)'人数'
FROM department
LEFT JOIN (
SELECT dno, COUNT(*) count
FROM student
GROUP BY dno)
AS dnum
ON department.dno = dnum.dno
GO
 
-- 为了处理count为0的情况，需要多一些步骤。

SELECT ckey1, COUNT(*)'总数'
FROM testtable
GROUP BY ckey1
GO
 
-- 普通的扫描并计数。

select sno,sname,dname
from student inner join department on student.dno = department.dno
GO

select sno,sname,dname
from department inner join student on department.dno = student.dno
GO
 
-- 一样，因为两条语句的执行原理完全相同。
