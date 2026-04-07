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
-- Table structure for table `fishing_bait`
--

DROP TABLE IF EXISTS `fishing_bait`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fishing_bait` (
  `baitid` int(10) unsigned NOT NULL,
  `name` varchar(64) NOT NULL,
  `type` tinyint(2) unsigned NOT NULL,
  `maxhook` tinyint(2) unsigned NOT NULL,
  `losable` tinyint(2) unsigned NOT NULL DEFAULT '1',
  `flags` int(11) unsigned NOT NULL DEFAULT '0',
  `mmm` tinyint(2) unsigned NOT NULL,
  `rankmod` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`baitid`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fishing_bait`
--

LOCK TABLES `fishing_bait` WRITE;
/*!40000 ALTER TABLE `fishing_bait` DISABLE KEYS */;

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

insert into `fishing_bait`
(
    `baitid`, `name`, `type`, `maxhook`, `losable`, `flags`, `mmm`, `rankmod`
)
VALUES
    (16992,'Slice of Bluetail',0,1,1,0,0,0),
    (16993,'Peeled Crayfish',0,1,1,0,0,0),
    (16994,'Slice of Moat Carp',0,1,1,0,0,0),
    (16995,'Rotten Meat',0,1,1,0,0,0),
    (16996,'Ball of Sardine Paste',0,1,1,0,0,0),
    (16997,'Ball of Crayfish Paste',0,1,1,0,0,0),
    (16998,'Ball of Insect Paste',0,1,1,0,0,0),
    (16999,'Ball of Trout Paste',0,1,1,0,0,0),
    (17000,'Meatball',0,1,1,0,0,0),
    (17001,'Giant Shell Bug',0,1,1,0,0,0),
    (17002,'Robber Rig',1,1,1,72,0,0),
    (17003,'Super Scoop',0,3,1,32,0,0),
    (17004,'Judge Minnow',1,1,1,0,0,0),
    (17005,'Lufaise Fly',0,1,1,0,0,0),
    (17006,'Drill Calamary',0,1,1,0,0,0),
    (17007,'Dwarf Pugil',0,1,1,0,0,0),
    (17008,'Regular Maze Monger Ball',1,1,1,0,1,0),
    (17009,'Large Maze Monger Ball',1,1,1,0,1,0),
    (17010,'Goliath Worm',0,1,1,0,0,0),
    (17392,'Slice of Sardine',0,1,1,0,0,0),
    (17393,'Slice of Cod',0,1,1,0,0,0),
    (17394,'Peeled Lobster',0,1,1,0,0,0),
    (17395,'Lugworm',0,1,1,0,0,0),
    (17396,'Little Worm',0,1,1,0,0,0),
    (17397,'Shell Bug',0,1,1,0,0,0),
    (17398,'Rogue Rig',1,1,1,72,0,0),
    (17399,'Sabiki Rig',1,3,1,0,0,0),
    (17400,'Sinking Minnow',1,1,1,1,0,0),
    (17401,'Lizard Lure',1,1,1,0,0,0),
    (17402,'Shrimp Lure',1,1,1,0,0,0),
    (17403,'Frog Lure',1,1,1,0,0,0),
    (17404,'Worm Lure',1,1,1,0,0,0),
    (17405,'Fly Lure',1,1,1,16,0,0),
    (17406,'Judges Lure',1,1,1,0,0,0),
    (17407,'Minnow',1,1,1,0,0,0),
    (19323,'Maze Monger Minnow',2,1,1,0,1,0),
    (19324,'Dried Squid',2,1,1,0,0,0),
    (19325,'Judge Fly',1,1,1,0,0,0),
    (19326,'Sea Dragon Liver',0,1,1,0,0,0)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `name` = IF(`name` <> VALUES(`name`), VALUES(`name`), `name`),
    `type` = IF(`type` <> VALUES(`type`), VALUES(`type`), `type`),
    `maxhook` = IF(`maxhook` <> VALUES(`maxhook`), VALUES(`maxhook`), `maxhook`),
    `losable` = IF(`losable` <> VALUES(`losable`), VALUES(`losable`), `losable`),
    `flags` = IF(`flags` <> VALUES(`flags`), VALUES(`flags`), `flags`),
    `mmm` = IF(`mmm` <> VALUES(`mmm`), VALUES(`mmm`), `mmm`),
    `rankmod` = IF(`rankmod` <> VALUES(`rankmod`), VALUES(`rankmod`), `rankmod`)
;

/*!40000 ALTER TABLE `fishing_bait` ENABLE KEYS */;
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
