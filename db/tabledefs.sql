
# tables for cmap
# currentlty, only positions is used by the cmap app.
# I can derive the stops more accurately from the 
#position data that the existing stops

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


# tables for gmap
# data from google user data dump
# just plots using destinations and waypoints

CREATE TABLE craigpos (
   id          INT AUTO_INCREMENT PRIMARY KEY,
   isstop      TINYINT(1)                 ,
   time        datetime DEFAULT NULL      ,
   duration    varchar(255)               ,
   lat         decimal(16,13) DEFAULT NULL,
   lon         decimal(16,13) DEFAULT NULL,
   location    varchar(255)               ,
   description varchar(255)               
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


# tables for gmap2
# data from google user data dump
# uses google directions so that waypoints follow the roads

CREATE TABLE places (
   id          INT AUTO_INCREMENT PRIMARY KEY,
   time        datetime DEFAULT NULL      ,
   duration    varchar(255)               ,
   lat         decimal(16,13) DEFAULT NULL,
   lng         decimal(16,13) DEFAULT NULL,
   address    varchar(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE paths (
   id          INT AUTO_INCREMENT PRIMARY KEY,
   starttime   datetime DEFAULT NULL      ,
   endtime     datetime DEFAULT NULL      ,
   startlat    decimal(16,13) DEFAULT NULL,
   startlng    decimal(16,13) DEFAULT NULL,
   endlat      decimal(16,13) DEFAULT NULL,
   endlng      decimal(16,13) DEFAULT NULL,
   mode        varchar(255)               
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE waypoints (
   id     INT AUTO_INCREMENT PRIMARY KEY,
   pathid INT,
   lat    decimal(16,13) DEFAULT NULL,
   lng    decimal(16,13) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



