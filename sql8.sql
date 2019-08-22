USE edu
GO

CREATE TRIGGER trigger_department 
ON department AFTER UPDATE
AS IF UPDATE(dno)
	BEGIN
		DECLARE @olddno char(6), @newdno char(6)
		SELECT @olddno = dno FROM deleted
		SELECT @newdno = dno FROM inserted
		UPDATE student SET dno = @newdno WHERE dno = @olddno
    END
GO

CREATE TRIGGER trigger_course ON student_course
INSTEAD OF INSERT AS
SET NOCOUNT ON
Declare @cno char(10), @selected int, @stulimits int
SELECT @cno = cno FROM inserted
SELECT @selected = COUNT(*) FROM student_course WHERE cno = @cno
SELECT @stulimits = stulimits FROM course WHERE cno = @cno
IF @selected >= @stulimits
	PRINT '人数已到上限，无法选修'
ELSE
	INSERT INTO student_course SELECT * FROM inserted
GO

CREATE TRIGGER trigger_course_sno_cno 
ON student_course AFTER UPDATE
AS
DECLARE @sno char(8), @cno char(10)
SELECT @sno = sno, @cno = cno FROM inserted
IF NOT EXISTS (SELECT * FROM student WHERE sno = @sno) OR NOT EXISTS (SELECT * FROM course WHERE cno = @cno)
BEGIN
	PRINT '不允许插入'
	ROLLBACK TRANSACTION
END
GO

CREATE TRIGGER trigger_course_update_sno_cno
ON student_course AFTER INSERT
AS
IF UPDATE(sno) OR UPDATE(cno)
BEGIN
	PRINT '不允许修改'
	ROLLBACK TRANSACTION
END
GO

CREATE TRIGGER trigger_course_score
ON student_course AFTER INSERT
AS
DECLARE @score tinyint
SELECT @score = score FROM inserted
IF @score IS NOT NULL AND (@score < 0 OR @score > 100)
BEGIN
	PRINT '不允许插入'
	ROLLBACK TRANSACTION
END
GO