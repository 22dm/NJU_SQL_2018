CREATE DATABASE STUINFO
  ON PRIMARY
  ( NAME = 'SINFO_data',
    FILENAME = 'C:\DATABASE\SINFO_data.mdf',
    SIZE = 3 MB,
    MAXSIZE = 10 MB ,
    FILEGROWTH = 1 MB
    )
  LOG ON
  ( NAME = 'SINFO_log',
    FILENAME = 'C:\DATABASE\SINFO_log.ldf',
    SIZE = 1 MB,
    MAXSIZE = 5 MB,
    FILEGROWTH = 10%
    )
GO

USE STUINFO
GO

CREATE TABLE STUDENT
(
  STUID    char(8),
  NAME     char(10) NOT NULL,
  SEX      char(2) DEFAULT '男',
  ZY       char(20),
  YX       char(20),
  BIRTHDAY datetime,
  JIGUAN   varchar(30),
  MZ       char(8),
  ZXF      int,
  CONSTRAINT pk_xh PRIMARY KEY (STUID),
  CONSTRAINT ck_xb CHECK (SEX IN ('男', '女'))
)
GO

CREATE TABLE STUSCORE
(
  STUID int,
  CNO   char(5),
  SCORE real,
  BZ    varchar(50),
  CONSTRAINT pk_idcno PRIMARY KEY (STUID, CNO),
  CONSTRAINT ck_score CHECK (SCORE >= 0 AND SCORE <= 100)
)
GO

CREATE TABLE COURSEREG
(
  CNO     char(5) PRIMARY KEY,
  CNAME   char(20) UNIQUE,
  TEACHER char(8),
  ZXS     int,
  XF      int
)
GO

INSERT STUDENT (STUID, NAME, BIRTHDAY, ZXF)
VALUES ('11001', '武大郎', '2001-5-01', 128),
       ('11002', '武二郎', '2001-5-01', 128),
       ('11003', '武三郎', '2001-5-01', 128)
INSERT STUSCORE (STUID, CNO, SCORE)
VALUES ('11001', '10000', 100),
       ('11002', '10000', 100),
       ('11003', '10000', 100)
INSERT COURSEREG (CNO, CNAME)
VALUES ('10000', '第一课'),
       ('10001', '第二课'),
       ('10002', '第三课')
GO

INSERT STUDENT (STUID, NAME, BIRTHDAY, ZXF)
VALUES ('12345', NULL, '2001-5-01', 128)
GO

INSERT STUDENT (STUID, NAME, SEX, BIRTHDAY, ZXF)
VALUES ('12345', '蛇精', '妖', '2001-5-01', 128)
GO

INSERT STUSCORE (STUID, CNO, SCORE)
VALUES ('12345', '10000', 128)
GO

