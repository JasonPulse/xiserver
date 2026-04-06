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
-- Table structure for table `automaton_spells`
--

DROP TABLE IF EXISTS `automaton_spells`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automaton_spells` (
  `spellid` smallint(4) unsigned NOT NULL,
  `skilllevel` smallint(3) unsigned NOT NULL DEFAULT '0',
  `heads` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `enfeeble` smallint(4) unsigned NOT NULL DEFAULT '0',
  `immunity` smallint(4) unsigned NOT NULL DEFAULT '0',
  `removes` int(6) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`spellid`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=14;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automaton_spells`
--

LOCK TABLES `automaton_spells` WRITE;
/*!40000 ALTER TABLE `automaton_spells` DISABLE KEYS */;

-- SINCE THE TABLE IS DROPPED AND RE-CREATED EVERY TIME, THERE WILL NEVER BE ANY "UPDATES" done
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

insert into `automaton_spells`
(
    `spellid`, `skilllevel`, `heads`, `enfeeble`, `immunity`, `removes`
)
VALUES
    (1,12,31,0,0,136129),
    (2,45,31,0,0,0),
    (3,81,31,0,0,0),
    (4,147,31,0,0,0),
    (5,207,16,0,0,0),
    (6,313,16,0,0,0),
    (14,27,16,0,0,3),
    (15,36,16,0,0,4),
    (16,45,16,0,0,5),
    (17,60,16,0,0,6),
    (18,120,16,0,0,7),
    (19,105,16,0,0,2079),
    (20,90,16,0,0,594974),
    (23,0,61,134,0,0),
    (24,96,61,134,0,0),
    (43,24,24,0,0,0),
    (44,84,24,0,0,0),
    (45,144,24,0,0,0),
    (46,217,24,0,0,0),
    (47,281,16,0,0,0),
    (48,54,24,0,0,0),
    (49,114,24,0,0,0),
    (50,188,24,0,0,0),
    (51,241,24,0,0,0),
    (52,347,24,0,0,0),
    (54,105,8,0,0,0),
    (56,42,61,13,128,0),
    (57,147,24,0,0,0),
    (58,21,61,4,32,0),
    (59,57,61,6,16,0),
    (106,99,8,0,0,0),
    (108,66,16,0,0,0),
    (110,135,16,0,0,0),
    (111,232,16,0,0,0),
    (129,425,16,0,0,0),
    (134,434,16,0,0,0),
    (143,99,16,0,0,0),
    (144,60,40,0,0,0),
    (145,153,40,0,0,0),
    (146,251,40,0,0,0),
    (147,281,40,0,0,0),
    (148,349,32,0,0,0),
    (149,75,40,0,0,0),
    (150,178,40,0,0,0),
    (151,256,40,0,0,0),
    (152,286,40,0,0,0),
    (153,368,32,0,0,0),
    (154,45,40,0,0,0),
    (155,138,40,0,0,0),
    (156,246,40,0,0,0),
    (157,276,40,0,0,0),
    (158,331,32,0,0,0),
    (159,15,40,0,0,0),
    (160,108,40,0,0,0),
    (161,227,40,0,0,0),
    (162,266,40,0,0,0),
    (163,296,32,0,0,0),
    (164,90,40,0,0,0),
    (165,203,40,0,0,0),
    (166,261,40,0,0,0),
    (167,291,40,0,0,0),
    (168,389,32,0,0,0),
    (169,30,40,0,0,0),
    (170,123,40,0,0,0),
    (171,236,40,0,0,0),
    (172,271,40,0,0,0),
    (173,313,32,0,0,0),
    (220,18,61,3,256,0),
    (221,141,57,3,256,0),
    (230,33,61,135,0,0),
    (231,111,61,135,0,0),
    (245,45,32,0,0,0),
    (247,78,32,0,0,0),
    (248,331,32,0,0,0),
    (254,27,61,5,64,0),
    (260,105,8,0,0,0),
    (270,120,32,140,0,0),
    (277,256,32,0,0,0),
    (286,337,61,21,0,0),
    (477,337,16,0,0,0),
    (511,410,8,0,0,0),
    (847,368,32,0,0,0)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    IF(`spellid` <> VALUES(`spellid`), VALUES(`spellid`), `spellid`),
    IF(`skilllevel` <> VALUES(`skilllevel`), VALUES(`skilllevel`), `skilllevel`),
    IF(`heads` <> VALUES(`heads`), VALUES(`heads`), `heads`),
    IF(`enfeeble` <> VALUES(`enfeeble`), VALUES(`enfeeble`), `enfeeble`)
    IF(`immunity` <> VALUES(`immunity`), VALUES(`immunity`), `immunity`)
    IF(`removes` <> VALUES(`removes`), VALUES(`removes`), `removes`)
;

/*!40000 ALTER TABLE `automaton_spells` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
