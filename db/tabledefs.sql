# currentlty, only positions is used by the app.
# I can derive the stops more accurately from the
# position data that the existing stops data


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

