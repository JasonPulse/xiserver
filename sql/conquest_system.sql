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
-- Table structure for table `conquest_system`
--

DROP TABLE IF EXISTS `conquest_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conquest_system` (
  `region_id` tinyint(2) NOT NULL DEFAULT '0',
  `region_control` tinyint(2) NOT NULL DEFAULT '0',
  `region_control_prev` tinyint(2) NOT NULL DEFAULT '0',
  `sandoria_influence` int(10) NOT NULL DEFAULT '0',
  `bastok_influence` int(10) NOT NULL DEFAULT '0',
  `windurst_influence` int(10) NOT NULL DEFAULT '0',
  `beastmen_influence` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`region_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conquest_system`
--

LOCK TABLES `conquest_system` WRITE;
/*!40000 ALTER TABLE `conquest_system` DISABLE KEYS */;

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

insert into `conquest_system`
(
    `region_id`, `region_control`, `region_control_prev`,
    `sandoria_influence`, `bastok_influence`, `windurst_influence`, `beastmen_influence`
)
VALUES
    (0,0,1,5000,0,0,0),
    (1,0,1,1500,1500,0,1000),
    (2,0,1,3000,0,0,2000),
    (3,1,1,0,5000,0,0),
    (4,1,0,0,3000,0,2000),
    (5,2,0,0,0,5000,0),
    (6,2,0,0,0,4000,1000),
    (7,2,0,0,0,3000,2000),
    (8,3,0,0,0,0,5000),
    (9,3,3,0,0,0,5000),
    (10,2,3,2000,750,750,1500),
    (11,3,3,0,0,0,5000),
    (12,3,3,0,0,0,5000),
    (13,3,3,0,0,0,5000),
    (14,3,3,0,0,0,5000),
    (15,3,3,0,0,0,5000),
    (16,3,3,0,0,0,5000),
    (17,3,3,0,0,0,5000),
    (18,3,3,0,0,0,5000)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `region_control` = IF(`region_control` <> VALUES(`region_control`), VALUES(`region_control`), `region_control`),
    `region_control_prev` = IF(`region_control_prev` <> VALUES(`region_control_prev`), VALUES(`region_control_prev`), `region_control_prev`),
    `sandoria_influence` = IF(`sandoria_influence` <> VALUES(`sandoria_influence`), VALUES(`sandoria_influence`), `sandoria_influence`),
    `bastok_influence` = IF(`bastok_influence` <> VALUES(`bastok_influence`), VALUES(`bastok_influence`), `bastok_influence`),
    `windurst_influence` = IF(`windurst_influence` <> VALUES(`windurst_influence`), VALUES(`windurst_influence`), `windurst_influence`),
    `beastmen_influence` = IF(`beastmen_influence` <> VALUES(`beastmen_influence`), VALUES(`beastmen_influence`), `beastmen_influence`)
;

/*!40000 ALTER TABLE `conquest_system` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
