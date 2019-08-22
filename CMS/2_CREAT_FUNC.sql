USE cms
GO

CREATE PROCEDURE command_help
AS
BEGIN
  SELECT command AS '命令',para AS '参数', usage AS '说明'
  FROM help
END
GO

CREATE PROCEDURE list_all_students
AS
BEGIN
  SELECT sno AS '学号', sname AS '姓名', sex AS '性别', birthday AS '出生日期', department AS '院系'
  FROM student
END
GO

CREATE PROCEDURE list_all_courses
AS
BEGIN
  SELECT course.cno AS '课程编号', cname AS '课程名',tname AS '教师姓名', slimit AS '限额', ISNULL(num.count, 0) '已选人数'
  FROM course
         LEFT JOIN (
    SELECT cno, COUNT(*) count
    FROM student_course
    GROUP BY cno)
    AS num
                   ON course.cno = num.cno
END
GO

CREATE PROCEDURE list_class_students(@cno char(10))
AS
BEGIN
  SELECT student.sno AS '学号', sname AS '姓名', sex AS '性别', birthday AS '出生日期', department AS '院系'
  FROM student,
       student_course
  WHERE student_course.sno = student.sno
    AND student_course.cno = @cno
END
GO

CREATE PROCEDURE list_student_courses(@sno char(16))
AS
BEGIN
  SELECT course.cno AS '课程编号', cname AS '课程名'
  FROM course,
       student_course
  WHERE student_course.sno = @sno
    AND student_course.cno = course.cno
END
GO

CREATE PROCEDURE add_student(@sno char(16),
                             @sname char(30),
                             @sex char(3),
                             @birthday datetime,
                             @department char(30))
AS
BEGIN
  INSERT INTO student (sno, sname, sex, birthday, department)
  VALUES (@sno, @sname, @sex, @birthday, @department)
  IF @@Rowcount = 1
    PRINT '成功添加学生 ' + RTRIM(@sname) + '，学号 ' + RTRIM(@sno)
END
GO

CREATE PROCEDURE add_course(@cno char(10),
                            @cname char(30),
                            @slimit int,
                            @tname char(30))
AS
BEGIN
  INSERT INTO course (cno, cname, slimit, tname)
  VALUES (@cno, @cname, @slimit, @tname)
  IF @@Rowcount = 1
    PRINT '成功添加课程 ' + RTRIM(@cname) + '，编号 ' + RTRIM(@cno)
END
GO

CREATE PROCEDURE delete_course(@cno char(10))
AS
BEGIN
  DECLARE @cname char(30)
  SELECT @cname = cname
  FROM course
  WHERE cno = @cno
  DELETE
  FROM course
  WHERE cno = @cno
  IF @@Rowcount = 1
    PRINT '成功删除课程 ' + RTRIM(@cname) + '，编号 ' + RTRIM(@cno)
END
GO

CREATE PROCEDURE add_room(@rno char(20),
                          @size int)
AS
BEGIN
  INSERT INTO classroom (rno, size)
  VALUES (@rno, @size)
  IF @@Rowcount = 1
    PRINT '成功添加教室 ' + RTRIM(@rno) + '，限额 ' + RTRIM(@size) + ' 人'
END
GO

CREATE PROCEDURE join_class(@sno char(16),
                            @cno char(10))
AS
BEGIN
  INSERT INTO student_course (sno, cno)
  VALUES (@sno, @cno)
  IF @@Rowcount = 1
    PRINT '成功选中课程 ' + RTRIM(@cno)
END
GO

CREATE PROCEDURE quit_class(@sno char(16),
                            @cno char(10))
AS
BEGIN
  DELETE
  FROM student_course
  WHERE sno = @sno
    AND cno = @cno
  IF @@Rowcount = 1
    PRINT '成功退选课程 ' + RTRIM(@cno)
END
GO

CREATE TRIGGER join_class_time_conflict
  ON student_course
  AFTER INSERT
  AS
BEGIN
  DECLARE @cno char(10), @cname char(30), @sno char(16)
  SELECT @cno = cno, @sno = sno FROM inserted
  DECLARE @wk tinyint,@dy tinyint,@stn tinyint, @lenn tinyint
  DECLARE rcursor CURSOR
    FOR
    SELECT wk, dy, stn, lenn
    FROM course_time
    WHERE cno = @cno
  OPEN rcursor
  FETCH NEXT FROM rcursor INTO @wk, @dy, @stn, @lenn
  WHILE @@fetch_status = 0
  BEGIN
    IF EXISTS(
        SELECT cname
        FROM course_time,
             student_course,
             course
        WHERE course_time.cno = student_course.cno
          AND course.cno = course_time.cno
          AND sno = @sno
          AND wk = @wk
          AND dy = @dy
          AND ((stn < @stn AND @stn - stn < lenn) OR
               (@stn < stn AND stn - @stn < @lenn))
      )
      BEGIN
        SELECT @cname = cname
        FROM course_time,
             student_course,
             course
        WHERE course_time.cno = student_course.cno
          AND course.cno = course_time.cno
          AND sno = @sno
          AND wk = @wk
          AND dy = @dy
          AND ((stn < @stn AND @stn - stn < lenn) OR
               (@stn < stn AND stn - @stn < @lenn))
        PRINT '选课失败，与 ' + RTRIM(@cname) + ' 时间冲突'
        ROLLBACK TRANSACTION
        BREAK
      END
    FETCH NEXT FROM rcursor INTO @wk, @dy, @stn, @lenn
  END
  CLOSE rcursor
  DEALLOCATE rcursor
END
GO

CREATE TRIGGER check_course_slimit
  ON student_course
  AFTER INSERT
  AS
BEGIN
  DECLARE @cno char(10), @people int, @slimit int
  SELECT @cno = cno FROM inserted
  SELECT @people = COUNT(*)
  FROM student_course
  WHERE cno = @cno
  SELECT @slimit = slimit
  FROM course
  WHERE cno = @cno
  IF @people > @slimit
    BEGIN
      PRINT '选课失败，选课人数已达上限'
      ROLLBACK TRANSACTION
    END
END
GO

CREATE TRIGGER remove_course
  ON course
  AFTER DELETE
  AS
BEGIN
  DECLARE @cno char(10)
  SELECT @cno = cno FROM deleted
  DELETE FROM course_time WHERE cno = @cno
  DELETE FROM student_course WHERE cno = @cno
END
GO

CREATE TRIGGER check_room_exist
  ON course_time
  AFTER INSERT
  AS
BEGIN
  DECLARE @rno char(10)
  SELECT @rno = rno FROM inserted
  IF NOT EXISTS(SELECT * FROM classroom WHERE rno = @rno)
    BEGIN
      PRINT '教室 ' + rtrim(@rno) + ' 不存在'
      ROLLBACK TRANSACTION
    END
END
GO

CREATE TRIGGER check_room_size
  ON course_time
  AFTER INSERT
  AS
BEGIN
  DECLARE @slimit int, @size int
  SELECT @slimit = slimit, @size = size
  FROM inserted,
       course,
       classroom
  WHERE inserted.cno = course.cno
    AND inserted.rno = classroom.rno
  IF @slimit > @size
    BEGIN
      PRINT '添加失败，教室大小不足'
      ROLLBACK TRANSACTION
    END
END
GO

CREATE TRIGGER check_room_time
  ON course_time
  AFTER INSERT
  AS
BEGIN
  DECLARE @rno char(20),@wk tinyint,@dy tinyint,@stn tinyint,@lenn tinyint
  SELECT @rno = rno, @wk = wk, @dy = dy, @stn = stn, @lenn = lenn
  FROM inserted
  IF EXISTS(SELECT rno FROM get_used_room(@wk, @dy, @stn, @lenn) WHERE rno = @rno)
    BEGIN
      PRINT '添加失败，时间冲突'
      ROLLBACK TRANSACTION
    END
END
GO

CREATE PROCEDURE add_course_time(@cno char(10),
                                 @rno char(20),
                                 @wk tinyint,
                                 @dy tinyint,
                                 @stn tinyint,
                                 @lenn tinyint)
AS
BEGIN
  INSERT course_time (cno, rno, wk, dy, stn, lenn) VALUES (@cno, @rno, @wk, @dy, @stn, @lenn)
  IF @@Rowcount = 1
    PRINT '成功添加时间段'
END
GO


CREATE PROCEDURE list_course_time(@cno char(10))
AS
BEGIN
  SELECT rno AS '教室编号', wk AS '周次', dy AS '星期', stn AS '起始节次', lenn AS '持续时长'
  FROM course_time
  WHERE cno = @cno
END
GO

CREATE PROCEDURE list_room_time(@rno char(20))
AS
BEGIN
  SELECT course.cno AS '课程编号', cname AS '课程名', wk AS '周次', dy AS '星期', stn AS '起始节次', lenn AS '持续时长'
  FROM course_time,
       course
  WHERE rno = @rno
    AND course.cno = course_time.cno
END
GO

CREATE PROCEDURE list_student_time(@sno char(16))
AS
BEGIN
  SELECT cname AS '课程名', rno AS '教室编号', wk AS '周次', dy AS '星期', stn AS '起始节次', lenn AS '持续时长'
  FROM course_time,
       student_course,
       course
  WHERE course_time.cno = student_course.cno
    AND course_time.cno = course.cno
    AND student_course.sno = @sno
end
GO

CREATE FUNCTION get_unused_room(@wk tinyint,
                                @dy tinyint,
                                @stn tinyint,
                                @lenn tinyint)
  RETURNS @res TABLE
               (
                 rno  char(20),
                 size int
               )
AS
BEGIN
  DECLARE @rno char(20), @count int
  DECLARE rcursor CURSOR
    FOR
    SELECT rno FROM classroom
  OPEN rcursor
  FETCH NEXT FROM rcursor INTO @rno
  WHILE @@fetch_status = 0
  BEGIN
    SELECT @count = COUNT(*)
    FROM course_time
    WHERE rno = @rno
      AND wk = @wk
      AND dy = @dy
      AND ((stn < @stn AND @stn - stn < lenn) OR
           (@stn < stn AND stn - @stn < @lenn))
    IF @count = 0
      INSERT INTO @res
      SELECT *
      FROM classroom
      WHERE rno = @rno
    FETCH NEXT FROM rcursor INTO @rno
  END
  CLOSE rcursor
  DEALLOCATE rcursor
  RETURN
end
GO

CREATE FUNCTION get_used_room(@wk tinyint,
                              @dy tinyint,
                              @stn tinyint,
                              @lenn tinyint)
  RETURNS @res TABLE
               (
                 rno  char(20),
                 size int
               )
AS
BEGIN
  INSERT INTO @res
  SELECT *
  FROM classroom
  DECLARE @rno char(20), @count int
  DECLARE rcursor CURSOR
    FOR
    SELECT rno FROM classroom
  OPEN rcursor
  FETCH NEXT FROM rcursor INTO @rno
  WHILE @@fetch_status = 0
  BEGIN
    SELECT @count = COUNT(*)
    FROM course_time
    WHERE rno = @rno
      AND wk = @wk
      AND dy = @dy
      AND ((stn < @stn AND @stn - stn < lenn) OR
           (@stn < stn AND stn - @stn < @lenn))
    IF @count = 0
      DELETE
      FROM @res
      WHERE rno = @rno
    FETCH NEXT FROM rcursor INTO @rno
  END
  CLOSE rcursor
  DEALLOCATE rcursor
  RETURN
end
GO

CREATE PROCEDURE list_unused_room(@wk tinyint,
                                  @dy tinyint,
                                  @stn tinyint,
                                  @lenn tinyint)
AS
BEGIN
  SELECT rno AS '教室编号', size AS '可容纳人数'
  FROM get_unused_room(@wk, @dy, @stn, @lenn)
END
GO

CREATE PROCEDURE list_used_room(@wk tinyint,
                                @dy tinyint,
                                @stn tinyint,
                                @lenn tinyint)
AS
SELECT rno AS '教室编号'
FROM get_used_room(@wk, @dy, @stn, @lenn)
GO

CREATE PROCEDURE print_student_course_table(@sno char(16), @wk int)
AS
DECLARE @i int, @j int, @k int, @cname char(30), @stn tinyint, @lenn tinyint, @str nvarchar(100), @time char(20)
Print '+---------------+--------------+--------------+--------------+--------------+--------------+'
Print '|     时 间     |     周一     |     周二     |     周三     |     周四     |     周五     |'
SET @i = 1
WHILE @i <= 11
BEGIN
  SET @j = 0
  WHILE @j < 3
  BEGIN
    IF @j = 0
      set @str = '+---------------+'
    ELSE
      IF @j = 1
        BEGIN
          SELECT @time = time FROM n_time WHERE n = @i
          set @str = '| ' + RTRIM(@time) + ' |'
        END
      ELSE
        set @str = '|               |'
    SET @k = 1
    WHILE @k <= 5
    BEGIN
      DECLARE ccursor CURSOR
        FOR
        SELECT cname, stn, lenn
        FROM course_time,
             student_course,
             course
        WHERE sno = @sno
          AND course_time.cno = student_course.cno
          AND course_time.cno = course.cno
          AND wk = @wk
          AND dy = @k
      OPEN ccursor
      FETCH NEXT FROM ccursor INTO @cname, @stn, @lenn
      IF @@fetch_status = 0
        BEGIN
          WHILE @@fetch_status = 0 AND (@stn > @i OR @stn + @lenn - 1 < @i)
          FETCH NEXT FROM ccursor INTO @cname, @stn, @lenn
          IF @stn = @i
            IF @j = 0
              set @str = @str + '--------------+'
            ELSE
              IF @j = 1
                set @str = @str + ' ' + RTRIM(SUBSTRING(@cname, 1, 6)) +
                           space(12 - DATALENGTH(RTRIM(SUBSTRING(@cname, 1, 6)))) + ' |'
              ELSE
                set @str = @str + ' ' + RTRIM(SUBSTRING(@cname, 7, 6)) +
                           space(12 - DATALENGTH(RTRIM(SUBSTRING(@cname, 7, 6)))) + ' |'
          ELSE
            IF @stn < @i AND @stn + @lenn - 1 >= @i
              set @str = @str + space(14) + '|'
            ELSE
              IF @j = 0
                set @str = @str + '--------------+'
              ELSE
                set @str = @str + space(14) + '|'
        END
      ELSE
        IF @j = 0
          set @str = @str + '--------------+'
        ELSE
          set @str = @str + space(14) + '|'
      CLOSE ccursor
      DEALLOCATE ccursor
      SET @k = @k + 1
    end
    PRINT @str
    SET @j = @j + 1
  end
  SET @i = @i + 1
END
Print '+---------------+--------------+--------------+--------------+--------------+--------------+'
GO

CREATE PROCEDURE print_room_course_table(@rno char(20), @wk int)
AS
DECLARE @i int, @j int, @k int, @cname char(30), @stn tinyint, @lenn tinyint, @str nvarchar(100), @time char(20)
Print '+---------------+--------------+--------------+--------------+--------------+--------------+'
Print '|     时 间     |     周一     |     周二     |     周三     |     周四     |     周五     |'
SET @i = 1
WHILE @i <= 11
BEGIN
  SET @j = 0
  WHILE @j < 3
  BEGIN
    IF @j = 0
      set @str = '+---------------+'
    ELSE
      IF @j = 1
        BEGIN
          SELECT @time = time FROM n_time WHERE n = @i
          set @str = '| ' + RTRIM(@time) + ' |'
        END
      ELSE
        set @str = '|               |'
    SET @k = 1
    WHILE @k <= 5
    BEGIN
      DECLARE ccursor CURSOR
        FOR
        SELECT cname, stn, lenn
        FROM course_time,
             course
        WHERE rno = @rno
          AND course_time.cno = course.cno
          AND wk = @wk
          AND dy = @k
      OPEN ccursor
      FETCH NEXT FROM ccursor INTO @cname, @stn, @lenn
      IF @@fetch_status = 0
        BEGIN
          WHILE @@fetch_status = 0 AND (@stn > @i OR @stn + @lenn - 1 < @i)
          FETCH NEXT FROM ccursor INTO @cname, @stn, @lenn
          IF @stn = @i
            IF @j = 0
              set @str = @str + '--------------+'
            ELSE
              IF @j = 1
                set @str = @str + ' ' + RTRIM(SUBSTRING(@cname, 1, 6)) +
                           space(12 - DATALENGTH(RTRIM(SUBSTRING(@cname, 1, 6)))) + ' |'
              ELSE
                set @str = @str + ' ' + RTRIM(SUBSTRING(@cname, 7, 6)) +
                           space(12 - DATALENGTH(RTRIM(SUBSTRING(@cname, 7, 6)))) + ' |'
          ELSE
            IF @stn < @i AND @stn + @lenn - 1 >= @i
              set @str = @str + space(14) + '|'
            ELSE
              IF @j = 0
                set @str = @str + '--------------+'
              ELSE
                set @str = @str + space(14) + '|'
        END
      ELSE
        IF @j = 0
          set @str = @str + '--------------+'
        ELSE
          set @str = @str + space(14) + '|'
      CLOSE ccursor
      DEALLOCATE ccursor
      SET @k = @k + 1
    end
    PRINT @str
    SET @j = @j + 1
  end
  SET @i = @i + 1
END
Print '+---------------+--------------+--------------+--------------+--------------+--------------+'
GO