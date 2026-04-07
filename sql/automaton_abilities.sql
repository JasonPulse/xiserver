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
-- Table structure for table `automaton_abilities`
--

DROP TABLE IF EXISTS `automaton_abilities`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automaton_abilities` (
  `abilityid` smallint(4) unsigned NOT NULL,
  `abilityname` varchar(40) CHARACTER SET latin1 NOT NULL,
  `reqframe` smallint(3) unsigned NOT NULL DEFAULT '0',
  `skilllevel` smallint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`abilityid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=14;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automaton_spells`
--

LOCK TABLES `automaton_abilities` WRITE;
/*!40000 ALTER TABLE `automaton_abilities` DISABLE KEYS */;

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

insert into `automaton_abilities`
(
    `abilityId`, `abilityname`, `reqframe`, `skilllevel`
)
VALUES
    (1940,'chimera_ripper',21,0),
    (1941,'string_clipper',21,0),
    (1942,'arcuballista',22,0),
    (1943,'slapstick',23,0),
    (1944,'shield_bash',21,0),
    (1945,'provoke',0,0),
    (1946,'shock_absorber',0,0),
    (1947,'flashbulb',0,0),
    (1948,'mana_converter',0,0),
    (1949,'ranged_attack',22,0),
    (2021,'eraser',0,0),
    (2031,'reactive_shield',0,0),
    (2065,'cannibal_blade',21,150),
    (2066,'daze',22,150),
    (2067,'knockout',23,145),
    (2068,'economizer',0,0),
    (2132,'replicator',0,0),
    (2299,'bone_crusher',21,245),
    (2300,'armor_piercer',22,245),
    (2301,'magic_mortar',23,225),
    (2743,'string_shredder',21,324),
    (2744,'armor_shatterer',22,324),
    (2745,'heat_capacitor',0,0),
    (2746,'barrage_turbine',22,0),
    (2747,'disruptor',0,0)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `abilityname` = IF(`abilityname` <> VALUES(`abilityname`), VALUES(`abilityname`), `abilityname`),
    `reqframe` = IF(`reqframe` <> VALUES(`reqframe`), VALUES(`reqframe`), `reqframe`),
    `skilllevel` = IF(`skilllevel` <> VALUES(`skilllevel`), VALUES(`skilllevel`), `skilllevel`)
;

/*!40000 ALTER TABLE `automaton_abilities` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
