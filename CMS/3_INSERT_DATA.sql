USE cms
GO

EXEC add_student '12345', '雷姆', '女', '2012-02-02', '数学系'
EXEC add_student '12346', '五更琉璃', '女', '2008-04-20', '数学系'
EXEC add_student '12347', '和泉纱雾', '女', '2013-12-10', '数学系'
EXEC add_student '12348', '宫内莲华', '女', '2010-12-03', '数学系'
EXEC add_student '12349', '小鸟游六花', '女', '2011-06-12', '数学系'
GO

EXEC add_room '101', 3
EXEC add_room '102', 5
EXEC add_room '103', 10
EXEC add_room '104', 5
EXEC add_room '105', 8
GO

EXEC add_course '10000', '新型男性服饰文化研究', 3, '秀吉&阿福'
EXEC add_course '10001', '咖啡店的经营之道', 6, '香风智乃'
EXEC add_course '10002', '路人女主的自我修养', 3, '加藤惠'
EXEC add_course '10003', '完美轮回', 4, '古手梨花&冈部仑太郎&菜月昴'
EXEC add_course '10005', '无良夫妻行骗指南', 10, '赫萝'
GO

DECLARE @i tinyint
SET @i = 1
WHILE @i <= 18
BEGIN
  EXEC add_course_time '10000', '101', @i, 1, 1, 2
  EXEC add_course_time '10000', '102', @i, 3, 5, 2
  EXEC add_course_time '10001', '105', @i, 4, 5, 4
  EXEC add_course_time '10002', '104', @i, 2, 3, 2
  EXEC add_course_time '10002', '104', @i, 4, 5, 2
  EXEC add_course_time '10003', '103', @i, 3, 4, 2
  IF @i % 2 = 0
    EXEC add_course_time '10005', '103', @i, 5, 1, 4
  ELSE
    EXEC add_course_time '10003', '103', @i, 5, 3, 2
  SET @i = @i + 1
END
GO

EXEC join_class '12345', '10000'
EXEC join_class '12345', '10001'
EXEC join_class '12345', '10005'
EXEC join_class '12346', '10002'
EXEC join_class '12346', '10003'
EXEC join_class '12346', '10005'
EXEC join_class '12347', '10005'
EXEC join_class '12347', '10001'
EXEC join_class '12348', '10000'
EXEC join_class '12349', '10005'
GO

INSERT INTO n_time (n, time)
VALUES (1, ' 8:00 -  8:50'),
       (2, ' 9:00 -  9:50'),
       (3, '10:10 - 11:00'),
       (4, '11:10 - 12:00'),
       (5, '14:00 - 14:50'),
       (6, '15:00 - 15:50'),
       (7, '16:10 - 17:00'),
       (8, '17:10 - 18:00'),
       (9, '18:30 - 19:20'),
       (10, '19:30 - 20:20'),
       (11, '20:30 - 21:20')
GO

INSERT INTO help (command, para, usage)
VALUES ('command_help', NULL, '打印本列表'),
       ('add_student', '学号, 姓名, 性别, 出生日期, 院系', '添加学生'),
       ('add_room', '教室编号, 人数限制', '添加教室'),
       ('add_course', '课程编号, 课程名, 人数限制, 教师姓名', '添加课程'),
       ('delete_course', '课程编号', '删除一门课程'),
       ('add_course_time', '课程编号, 教室编号, 周次, 星期, 起始节次, 时长', '添加课程时间'),
       ('join_class', '学号, 课程号', '学生选课'),
       ('quit_class', '学号, 课程号', '学生退课'),
       ('list_all_students', NULL, '列出所有学生'),
       ('list_all_courses', NULL, '列出所有课程'),
       ('list_student_courses', NULL, '列出某学生的课程'),
       ('list_class_students', NULL, '列出某课程的学生'),
       ('list_course_time', '课程编号', '列出某课程所有时间信息'),
       ('list_room_time', '教室编号', '列出某教室所有时间信息'),
       ('list_student_time', '学号', '列出某学生所有时间信息'),
       ('list_unused_room', '周次, 星期, 起始节次, 时长', '列出某时间段空闲教室'),
       ('list_used_room', '周次, 星期, 起始节次, 时长', '列出某时间段使用中教室'),
       ('print_student_course_table', '学号, 周次', '可视化列出某学生课表'),
       ('print_room_course_table', '教室编号, 周次', '可视化列出某教室课表')
GO