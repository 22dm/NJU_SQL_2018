CREATE DATABASE cms
  ON PRIMARY
  ( NAME = 'cms_data',
    FILENAME = 'c:\cms_data.mdf' ,
    SIZE = 30 MB ,
    MAXSIZE = 600 MB ,
    FILEGROWTH = 10%)
  LOG ON
  ( NAME = 'cms_log',
    FILENAME = 'c:\cms_log.ldf' ,
    SIZE = 30 MB ,
    MAXSIZE = 600 MB ,
    FILEGROWTH = 10%
    )
GO

USE cms
GO

CREATE TABLE student
(
  sno        char(16) NOT NULL PRIMARY KEY,
  sname      char(30) NOT NULL,
  sex        char(3)  NOT NULL CHECK (sex in ('男', '女')),
  birthday   datetime NOT NULL,
  department char(30) NOT NULL,
)
GO

CREATE TABLE course
(
  cno    char(10) NOT NULL PRIMARY KEY,
  cname  char(30) NOT NULL,
  slimit int      NOT NULL CHECK (slimit > 0),
  tname  char(30) NOT NULL,
)
GO

CREATE TABLE student_course
(
  sno char(16) NOT NULL,
  cno char(10) NOT NULL,
  constraint PK_sc primary key (sno, cno)
)
GO

CREATE TABLE classroom
(
  rno  char(20) NOT NULL PRIMARY KEY,
  size int      NOT NULL CHECK (size > 0),
)
GO

CREATE TABLE course_time
(
  cno  char(10) NOT NULL,
  rno  char(20) NOT NULL,
  wk   tinyint  NOT NULL CHECK (wk >= 1),
  dy   tinyint  NOT NULL CHECK (dy >= 1 AND dy <= 5),
  stn  tinyint  NOT NULL CHECK (stn >= 1),
  lenn tinyint  NOT NULL CHECK (lenn >= 1),
)
GO

CREATE TABLE help
(
  command char(50) PRIMARY KEY,
  para    char(100),
  usage   char(100) NOT NULL,
)
GO

CREATE TABLE n_time
(
  n    tinyint PRIMARY KEY CHECK (n >= 1),
  time char(20) NOT NULL,
)
GO
 