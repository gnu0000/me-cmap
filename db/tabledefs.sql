CREATE TABLE familyacct (
   acct        mediumtext,
   postDate    datetime DEFAULT NULL,
   checkNum    mediumtext,
   description mediumtext,
   debit       decimal(12,2) DEFAULT NULL,
   credit      decimal(12,2) DEFAULT NULL,
   status      tinytext,
   balance     decimal(12,2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE creditline (
   acct        mediumtext,
   postDate    datetime DEFAULT NULL,
   checkNum    mediumtext,
   description mediumtext,
   debit       decimal(12,2) DEFAULT NULL,
   credit      decimal(12,2) DEFAULT NULL,
   status      tinytext,
   balance     decimal(12,2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE cornychecking (
   acct        mediumtext,
   postDate    datetime DEFAULT NULL,
   checkNum    mediumtext,
   description mediumtext,
   debit       decimal(12,2) DEFAULT NULL,
   credit      decimal(12,2) DEFAULT NULL,
   status      tinytext,
   balance     decimal(12,2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE craigchecking (
   acct        mediumtext,
   postDate    datetime DEFAULT NULL,
   checkNum    mediumtext,
   description mediumtext,
   debit       decimal(12,2) DEFAULT NULL,
   credit      decimal(12,2) DEFAULT NULL,
   status      tinytext,
   balance     decimal(12,2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE craigsavings (
   acct        mediumtext,
   postDate    datetime DEFAULT NULL,
   checkNum    mediumtext,
   description mediumtext,
   debit       decimal(12,2) DEFAULT NULL,
   credit      decimal(12,2) DEFAULT NULL,
   status      tinytext,
   balance     decimal(12,2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE mortgage (
   acct        mediumtext,
   postDate    datetime DEFAULT NULL,
   checkNum    mediumtext,
   description mediumtext,
   debit       decimal(12,2) DEFAULT NULL,
   credit      decimal(12,2) DEFAULT NULL,
   status      tinytext,
   balance     decimal(12,2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE rentalchecking (
   acct        mediumtext,
   postDate    datetime DEFAULT NULL,
   checkNum    mediumtext,
   description mediumtext,
   debit       decimal(12,2) DEFAULT NULL,
   credit      decimal(12,2) DEFAULT NULL,
   status      tinytext,
   balance     decimal(12,2) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE stops (
   id          INT AUTO_INCREMENT PRIMARY KEY,
   Begin       datetime DEFAULT NULL      ,
   End         datetime DEFAULT NULL      ,
   Lat         decimal(16,13) DEFAULT NULL,
   Lon         decimal(16,13) DEFAULT NULL,
   Location    varchar(255)               ,
   Description varchar(255)               
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE positions (
   id          INT AUTO_INCREMENT PRIMARY KEY,
   isstop      TINYINT(1)                 ,
   time        datetime DEFAULT NULL      ,
   duration    varchar(255)               ,
   lat         decimal(16,13) DEFAULT NULL,
   lon         decimal(16,13) DEFAULT NULL,
   heading     varchar(255)               ,
   speed       smallint                   ,
   elevation   smallint                   ,
   location    varchar(255)               ,
   description varchar(255)               
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



===============================================

CREATE TABLE cornychecking  ( acct mediumtext, postDate datetime DEFAULT NULL, checkNum mediumtext, description mediumtext, debit decimal(12,2) DEFAULT NULL, credit decimal(12,2) DEFAULT NULL, status tinytext, balance decimal(12,2) DEFAULT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE craigchecking  ( acct mediumtext, postDate datetime DEFAULT NULL, checkNum mediumtext, description mediumtext, debit decimal(12,2) DEFAULT NULL, credit decimal(12,2) DEFAULT NULL, status tinytext, balance decimal(12,2) DEFAULT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE craigsavings   ( acct mediumtext, postDate datetime DEFAULT NULL, checkNum mediumtext, description mediumtext, debit decimal(12,2) DEFAULT NULL, credit decimal(12,2) DEFAULT NULL, status tinytext, balance decimal(12,2) DEFAULT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE creditline     ( acct mediumtext, postDate datetime DEFAULT NULL, checkNum mediumtext, description mediumtext, debit decimal(12,2) DEFAULT NULL, credit decimal(12,2) DEFAULT NULL, status tinytext, balance decimal(12,2) DEFAULT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE familyacct     ( acct mediumtext, postDate datetime DEFAULT NULL, checkNum mediumtext, description mediumtext, debit decimal(12,2) DEFAULT NULL, credit decimal(12,2) DEFAULT NULL, status tinytext, balance decimal(12,2) DEFAULT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE mortgage       ( acct mediumtext, postDate datetime DEFAULT NULL, checkNum mediumtext, description mediumtext, debit decimal(12,2) DEFAULT NULL, credit decimal(12,2) DEFAULT NULL, status tinytext, balance decimal(12,2) DEFAULT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE rentalchecking ( acct mediumtext, postDate datetime DEFAULT NULL, checkNum mediumtext, description mediumtext, debit decimal(12,2) DEFAULT NULL, credit decimal(12,2) DEFAULT NULL, status tinytext, balance decimal(12,2) DEFAULT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8;
