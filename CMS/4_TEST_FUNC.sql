USE cms
GO

-- 列出命令帮助列表
-- command_help
EXEC command_help
GO

-- 添加学生
-- add_student 学号, 姓名, 性别, 出生日期, 院系
EXEC add_student '12350', '伊藤诚', '男', '2005-10-16', '数学系'
GO

-- 添加教室
-- add_room 教室编号, 人数限制
EXEC add_room '106', 15
GO

-- 添加课程
-- add_course 课程编号, 课程名, 人数限制, 教师姓名
EXEC add_course '10007', '校园偶像', 10, '矢泽妮可'
GO

-- 添加课程时间
-- add_course_time 课程编号, 教室编号, 周次, 星期, 起始节次, 时长
-- 10007 这门课 1-18 周，每周四 5-6 节，在 103 教室
DECLARE @i tinyint
SET @i = 1
WHILE @i <= 18
BEGIN
  EXEC add_course_time '10007', '103', @i, 4, 5, 2
  SET @i = @i + 1
END
GO

-- 错误输入示例（教室空间不足）
-- 10005 号课程限额 10 人，101 教室可容纳 3 人，添加失败
EXEC add_course_time '10005', '101', 1, 5, 5, 3
GO

-- 错误输入示例（教室不存在）
-- 999 教室不存在，添加失败
EXEC add_course_time '10003', '999', 1, 1, 2, 3
GO

-- 错误输入示例（时间冲突）
-- 10000 每周三 5-6 节使用 102 教室，如果 10003 每周三 4-5 节使用同一教室，添加失败
EXEC add_course_time '10003', '102', 1, 3, 4, 2
GO

-- 学生选课
-- join_class 学号, 课程号
EXEC join_class '12350', '10000'
GO

-- 错误输入示例（选课人数已满）
-- '10000' 课程限额 3 人，已经选满 3 人
EXEC join_class '12349', '10000'
GO

-- 错误输入示例（时间冲突）
-- '10000' 与 10003 号课程时间冲突，12345 学生已选 10000 课程
EXEC join_class '12345', '10003'
GO

-- 列出所有学生
-- list_all_students
EXEC list_all_students
GO

-- 列出所有课程（包括已选人数）
-- list_all_courses
EXEC list_all_courses
GO

-- 列出某学生的课程
-- list_student_courses 课程编号
EXEC list_student_courses '12346'
GO

-- 列出某课程的学生
-- list_class_students 课程编号
EXEC list_class_students '10000'
GO

-- 学生退课
-- quit_class 学号, 课程号
EXEC quit_class '12350', '10000'
GO

-- 删除一门课程（同时删除该课程相关的学生选课信息与时间信息）
-- delete_course 课程编号
EXEC delete_course '10007'
GO

-- 列出某课程所有时间信息
-- list_course_time 课程编号
EXEC list_course_time '10000'
GO

-- 列出某教室所有时间信息
-- list_room_time 教室编号
EXEC list_room_time '102'
GO

-- 列出某学生所有时间信息
-- list_student_time 学号
EXEC list_student_time '12345'
GO

-- 列出某时间段空闲教室
-- list_unused_room 周次, 星期, 起始节次, 时长
EXEC list_unused_room 1, 3, 4, 2
GO

-- 列出某时间段使用中教室
-- list_used_room 周次, 星期, 起始节次, 时长
EXEC list_used_room 1, 3, 4, 2
GO

-- 列出某学生课表
-- print_student_course_table 学号, 周次
EXEC print_student_course_table '12346', 1
GO

-- 列出某教室课表
-- print_room_course_table 教室编号, 周次
EXEC print_room_course_table '103', 1
GO