-- MySQL dump 10.16  Distrib 10.1.38-MariaDB, for Win32 (AMD64)
--
-- Host: localhost    Database: dspdb
-- ------------------------------------------------------
-- Server version    10.1.38-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `fishing_rod`
--

DROP TABLE IF EXISTS `fishing_rod`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fishing_rod` (
  `rodid` int(10) unsigned NOT NULL,
  `name` varchar(64) NOT NULL,
  `material` tinyint(2) unsigned NOT NULL,
  `size_type` tinyint(3) unsigned NOT NULL,
  `flags` int(11) unsigned NOT NULL DEFAULT '0',
  `min_rank` smallint(5) unsigned NOT NULL DEFAULT '0',
  `max_rank` smallint(5) unsigned NOT NULL DEFAULT '0',
  `fish_attack` tinyint(3) unsigned NOT NULL,
  `lgd_bonus_attack` tinyint(3) unsigned NOT NULL,
  `fish_recovery` tinyint(3) unsigned NOT NULL,
  `fish_time` tinyint(3) unsigned NOT NULL,
  `lgd_bonus_time` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `sm_delay_bonus` tinyint(2) unsigned NOT NULL,
  `sm_move_bonus` tinyint(2) unsigned NOT NULL,
  `lg_delay_bonus` tinyint(2) unsigned NOT NULL,
  `lg_move_bonus` tinyint(2) unsigned NOT NULL,
  `multiplier` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `breakable` tinyint(2) unsigned NOT NULL DEFAULT '1',
  `broken_rodid` int(10) unsigned NOT NULL,
  `mmm` tinyint(2) unsigned NOT NULL,
  `legendary` tinyint(2) unsigned NOT NULL,
  `rating` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`rodid`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fishing_rod`
--

LOCK TABLES `fishing_rod` WRITE;
/*!40000 ALTER TABLE `fishing_rod` DISABLE KEYS */;

-- SINCE THE TABLE IS DROPPED AND RE-CREATED EVERY TIME, THERE WILL NEVER BE ANY "UPDATES" done but leave the merge pattern
    -- WITH DDL Sync
        -- If you implement a way to handle syncing DDL changes to the table(s) then 
        -- the script could be fully incremental and even faster
        -- as you don't need to drop the table at all and wouldn't need to re-insert every row
    
    -- WITHOUT DDL Sync
        -- Without adding extra steps OR scripts to deal with DDL sync's / changes
        -- we will leave the "drop/create" pattern and 
        -- adjust to the "multi value insert & merge" statement pattern.
        -- In addition, we will batch the inserts to attempt to handle
        -- "max_allowed_packet" Database setting & overflow potential
            -- if this overflow occurs you will receive an error like:
                -- ER_NET_PACKET_TOO_LARGE 
                -- or 
                -- "Lost connection to MySQL server during query".
            -- If this happens, you can structure the inserts to have "less" VALUES() and more batches etc....

insert into `fishing_rod`
(
    `rodid`, `name`, `material`, `size_type`, `flags`, `min_rank`, `max_rank`, `fish_attack`,
    `lgd_bonus_attack`, `fish_recovery`, `fish_time`, `lgd_bonus_time`, `sm_delay_bonus`,
    `sm_move_bonus`, `lg_delay_bonus`, `lg_move_bonus`, `multiplier`, `breakable`,
    `broken_rodid`, `mmm`, `legendary`, `rating`
)
VALUES
    (17011,'Ebisu Fishing Rod',1,0,4,1,30,100,50,50,30,10,2,1,1,0,3,0,0,0,1,15),
    (17012,'Judges Rod',1,0,0,1,40,200,100,100,60,30,2,1,1,0,5,0,0,0,1,16),
    (17013,'Goldfish Basket',0,0,8,1,5,100,0,50,20,0,0,0,0,0,0,0,0,0,0,0),
    (17014,'Hume Fishing Rod',0,0,2,1,10,125,0,65,30,0,2,1,0,2,3,1,1832,0,0,6),
    (17015,'Halcyon Rod',1,0,2,1,18,100,0,70,41,0,2,1,0,2,3,1,1833,0,0,9),
    (17380,'Mithran Fishing Rod',0,1,1,8,18,130,0,65,30,0,0,0,1,0,3,1,483,0,0,12),
    (17381,'Composite Fishing Rod',1,1,1,11,24,100,0,70,43,0,0,0,1,0,2,1,473,0,0,13),
    (17382,'Single Hook Fishing Rod',1,1,1,14,22,100,0,80,45,0,0,0,1,0,3,1,472,0,0,11),
    (17383,'Clothespole',0,1,1,12,16,170,0,50,30,0,0,0,1,0,3,1,482,0,0,10),
    (17384,'Carbon Fishing Rod',1,0,0,1,13,100,0,75,43,0,2,1,1,0,4,1,490,0,0,7),
    (17385,'Glass Fiber Fishing Rod',1,0,0,1,12,100,0,80,45,0,2,1,1,0,4,1,491,0,0,8),
    (17386,'Lu Shang\'s Fishing Rod',0,0,0,1,28,110,20,100,40,10,2,1,1,0,2,1,489,0,1,14),
    (17387,'Tarutaru Fishing Rod',0,0,0,1,9,130,0,70,30,0,2,1,1,0,4,1,484,0,0,5),
    (17388,'Fastwater Fishing Rod',0,0,0,1,7,135,0,65,30,0,2,1,1,0,2,1,488,0,0,4),
    (17389,'Bamboo Fishing Rod',0,0,0,1,8,140,0,60,30,0,2,1,1,0,2,1,487,0,0,3),
    (17390,'Yew Fishing Rod',0,0,0,1,6,145,0,55,30,0,2,1,1,0,2,1,486,0,0,2),
    (17391,'Willow Fishing Rod',0,0,0,1,5,150,0,50,30,0,2,1,1,0,2,1,485,0,0,1),
    (19319,'Maze Monger Fishing Rod',1,0,0,1,25,100,0,100,30,0,2,1,1,10,2,1,2526,1,0,0),
    (19320,'Lu Shang\'s Fishing Rod +1',0,0,0,1,28,110,20,100,50,10,2,1,1,0,2,1,9091,0,1,14),
    (19321,'Ebisu Fishing Rod +1',1,0,4,1,30,100,50,50,40,10,2,1,1,0,3,0,0,0,1,15)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `name` = IF(`name` <> VALUES(`name`), VALUES(`name`), `name`),
    `material` = IF(`material` <> VALUES(`material`), VALUES(`material`), `material`),
    `size_type` = IF(`size_type` <> VALUES(`size_type`), VALUES(`size_type`), `size_type`),
    `flags` = IF(`flags` <> VALUES(`flags`), VALUES(`flags`), `flags`),
    `min_rank` = IF(`min_rank` <> VALUES(`min_rank`), VALUES(`min_rank`), `min_rank`),
    `max_rank` = IF(`max_rank` <> VALUES(`max_rank`), VALUES(`max_rank`), `max_rank`),
    `fish_attack` = IF(`fish_attack` <> VALUES(`fish_attack`), VALUES(`fish_attack`), `fish_attack`),
    `lgd_bonus_attack` = IF(`lgd_bonus_attack` <> VALUES(`lgd_bonus_attack`), VALUES(`lgd_bonus_attack`), `lgd_bonus_attack`),
    `fish_recovery` = IF(`fish_recovery` <> VALUES(`fish_recovery`), VALUES(`fish_recovery`), `fish_recovery`),
    `fish_time` = IF(`fish_time` <> VALUES(`fish_time`), VALUES(`fish_time`), `fish_time`),
    `lgd_bonus_time` = IF(`lgd_bonus_time` <> VALUES(`lgd_bonus_time`), VALUES(`lgd_bonus_time`), `lgd_bonus_time`),
    `sm_delay_bonus` = IF(`sm_delay_bonus` <> VALUES(`sm_delay_bonus`), VALUES(`sm_delay_bonus`), `sm_delay_bonus`),
    `sm_move_bonus` = IF(`sm_move_bonus` <> VALUES(`sm_move_bonus`), VALUES(`sm_move_bonus`), `sm_move_bonus`),
    `lg_delay_bonus` = IF(`lg_delay_bonus` <> VALUES(`lg_delay_bonus`), VALUES(`lg_delay_bonus`), `lg_delay_bonus`),
    `lg_move_bonus` = IF(`lg_move_bonus` <> VALUES(`lg_move_bonus`), VALUES(`lg_move_bonus`), `lg_move_bonus`),
    `multiplier` = IF(`multiplier` <> VALUES(`multiplier`), VALUES(`multiplier`), `multiplier`),
    `breakable` = IF(`breakable` <> VALUES(`breakable`), VALUES(`breakable`), `breakable`),
    `broken_rodid` = IF(`broken_rodid` <> VALUES(`broken_rodid`), VALUES(`broken_rodid`), `broken_rodid`),
    `mmm` = IF(`mmm` <> VALUES(`mmm`), VALUES(`mmm`), `mmm`),
    `legendary` = IF(`legendary` <> VALUES(`legendary`), VALUES(`legendary`), `legendary`),
    `rating` = IF(`rating` <> VALUES(`rating`), VALUES(`rating`), `rating`)
;

/*!40000 ALTER TABLE `fishing_rod` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-01  5:11:33
