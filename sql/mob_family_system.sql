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
-- Table structure for table `mob_family_system`
--

DROP TABLE IF EXISTS `mob_family_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mob_family_system` (
  `familyID` smallint(4) unsigned NOT NULL,
  `family` tinytext,
  `superFamilyID` smallint(4) unsigned NOT NULL DEFAULT 0,
  `superFamily` tinytext,
  `ecosystemID` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `ecosystem` tinytext,
  `speed` tinyint(3) unsigned NOT NULL DEFAULT 40,
  `HP` tinyint(3) unsigned NOT NULL DEFAULT 100,
  `MP` tinyint(3) unsigned NOT NULL DEFAULT 100,
  `STR` smallint(4) unsigned NOT NULL DEFAULT 3,
  `DEX` smallint(4) unsigned NOT NULL DEFAULT 3,
  `VIT` smallint(4) unsigned NOT NULL DEFAULT 3,
  `AGI` smallint(4) unsigned NOT NULL DEFAULT 3,
  `INT` smallint(4) unsigned NOT NULL DEFAULT 3,
  `MND` smallint(4) unsigned NOT NULL DEFAULT 3,
  `CHR` smallint(4) unsigned NOT NULL DEFAULT 3,
  `ATT` smallint(4) unsigned NOT NULL DEFAULT 3,
  `DEF` smallint(4) unsigned NOT NULL DEFAULT 3,
  `ACC` smallint(4) unsigned NOT NULL DEFAULT 3,
  `EVA` smallint(4) unsigned NOT NULL DEFAULT 3,
  `Element` float NOT NULL DEFAULT 0,
  `detects` smallint(5) NOT NULL DEFAULT 0,
  `charmable` tinyint(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`familyID`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=128;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mob_family_system`
--

-- "family, superFamily, ecosystem" relationship: Korrigan, Mandragora, Plantoid
-- Nothing is enforced so it is possible to use completely unrelated values
LOCK TABLES `mob_family_system` WRITE;
/*!40000 ALTER TABLE `mob_family_system` DISABLE KEYS */;

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

insert into `mob_family_system`
(
    `familyID`, `family`, `superFamilyID`, `superFamily`,
    `ecosystemID`, `ecosystem`, `speed`,
    `HP`, `MP`, `STR`, `DEX`, `VIT`, `AGI`, `INT`, `MND`, `CHR`, `ATT`,
    `DEF`, `ACC`, `EVA`, `Element`, `detects`, `charmable`
)
VALUES
    (1,'Acrolith',1,'Acrolith',3,'Arcana',40,90,90,1,3,4,3,6,6,5,1,3,1,3,0.0,34,0),
    (2,'Adamantoise',2,'Adamantoise',14,'Lizard',30,120,90,2,4,1,4,1,1,1,1,2,1,3,4.0,2,0),
    (3,'Aern',3,'Aern',15,'Luminian',40,120,140,2,2,3,3,1,1,1,1,3,1,3,0.0,3,0),
    (4,'Ahriman',4,'Ahriman',9,'Demon',40,87,140,2,3,4,4,1,2,2,1,3,1,3,8.0,3,0),
    (5,'Amoeban',192,'Amoeban',21,'Voragean',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,32,0),
    (6,'Amphiptere',5,'Amphiptere',8,'Bird',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,1,0),
    (7,'Animated_Weapon',6,'Evil_Weapon',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
-- 8 Free
-- 9 Free
-- 10 Free
-- 11 Free
-- 12 Free
-- 13 Free
-- 14 Free
-- 15 Free
-- 16 Free
-- 17 Free
-- 18 Free
-- 19 Free
-- 20 Free
-- 21 Free
-- 22 Free
-- 23 Free
-- 24 Free
    (25,'Antica',7,'Antica',7,'Beastmen',40,116,140,1,3,5,4,6,2,1,1,3,1,3,8.0,258,0),
    (26,'Antlion',8,'Antlion',20,'Vermin',40,120,125,4,4,4,4,4,4,4,1,3,1,3,8.0,2,1),
    (27,'Apkallu',9,'Apkallu',8,'Bird',40,105,90,4,3,5,4,4,4,4,1,3,1,2,6.0,3,0),
    (28,'Automaton-Harlequin',10,'Automaton',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (29,'Automaton-Sharpshot',10,'Automaton',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (30,'Automaton-Stormwaker',10,'Automaton',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (31,'Automaton-Valoredge',10,'Automaton',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (32,'Avatar-Atomos',11,'Atomos',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (33,'Avatar-Alexander',12,'Alexander',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (34,'Avatar-Carbuncle',13,'Carbuncle',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (35,'Avatar-Diabolos',14,'Diabolos',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (36,'Avatar-Fenrir',15,'Fenrir',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (37,'Avatar-Garuda',16,'Garuda',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (38,'Avatar-Ifrit',17,'Ifrit',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (39,'Monoceros',18,'Monoceros',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (40,'Avatar-Leviathan',19,'Leviathan',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (41,'Avatar-Odin',20,'Odin',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (42,'Avatar-Odin',20,'Odin',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (43,'Avatar-Ramuh',21,'Ramuh',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (44,'Avatar-Shiva',22,'Shiva',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (45,'Avatar-Titan',23,'Titan',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (46,'Bat',24,'Bat',8,'Bird',40,95,120,4,4,5,3,4,4,4,1,3,1,3,3.0,2,1),
    (47,'Bat_Trio',24,'Bat_Trio',8,'Bird',40,87,120,4,4,5,3,4,4,4,1,3,1,3,3.0,2,1),
    (48,'Bee',25,'Bee',20,'Vermin',40,87,120,5,4,4,3,4,4,4,1,3,1,3,3.0,257,1),
    (49,'Beetle',26,'Beetle',20,'Vermin',40,117,110,3,3,2,5,5,5,5,1,2,1,3,4.0,257,1),
    (51,'Behemoth',27,'Behemoth',6,'Beast',40,110,90,3,3,3,3,3,3,3,1,3,1,3,6.0,1,0),
    (52,'Ghost-Bhoot',28,'Ghost',19,'Undead',40,70,140,6,3,6,3,1,5,4,1,3,1,3,2.0,6,0),
    (53,'Grimoire',29,'Grimoire',3,'Arcana',40,90,90,1,3,4,3,6,6,5,1,3,1,3,0.0,2,0),
    (54,'Biotechnological',30,'Biotech',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,3,0),
    (55,'Bird',31,'Bird',8,'Bird',40,106,120,4,4,5,3,4,4,4,1,4,1,3,1.0,2,1),
    (56,'Bomb',32,'Bomb',3,'Arcana',40,97,140,6,3,4,3,1,5,4,1,3,1,3,1.0,33,0),
    (57,'Buffalo',33,'Buffalo',6,'Beast',40,130,120,4,4,4,4,4,4,4,1,3,1,3,2.0,1,0),
    (58,'Bugard',34,'Bugard',14,'Lizard',40,115,110,4,4,4,4,4,4,4,1,3,1,3,1.0,2,0),
    (59,'Bugbear',35,'Bugbear',7,'Beastmen',40,125,90,3,2,5,2,6,4,5,1,2,1,3,5.0,1,0),
    (60,'CaitSith',36,'CaitSith',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,1,0),
    (61,'Cardian',37,'Cardian',3,'Arcana',40,109,140,1,3,4,5,1,1,3,1,3,1,3,6.0,34,0),
    (62,'Cerberus',38,'Cerberus',6,'Beast',80,100,90,1,1,3,1,1,1,2,1,3,1,3,1.0,2,0),
    (63,'Chariot',39,'Chariot',4,'ArchaicMachine',40,90,90,1,3,4,3,6,6,5,1,3,1,3,0.0,34,0),
    (64,'Chigoe',40,'Chigoe',20,'Vermin',40,120,90,3,2,1,6,6,4,5,1,3,1,3,4.0,3,0),
    (65,'Clionid',41,'Clionid',21,'Voragean',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,4,0),
    (66,'Slime-Clot',42,'Slime',1,'Amorph',40,100,120,4,4,4,5,4,3,4,1,3,1,3,6.0,258,1),
    (67,'Slime-GlutinousClot',42,'Slime',1,'Amorph',40,100,120,4,4,4,5,4,3,4,1,3,1,3,6.0,290,0),
    (68,'Bomb-Cluster',191,'Bomb-Cluster',3,'Arcana',40,95,140,6,3,4,4,1,5,4,1,3,1,3,1.0,33,0),
-- 69 Free
    (70,'Cockatrice',43,'Cockatrice',8,'Bird',40,118,140,4,5,3,4,4,4,4,1,2,1,3,4.0,1,0),
    (71,'Coeurl',44,'Coeurl',6,'Beast',60,94,90,4,3,5,4,3,5,4,1,3,1,3,5.0,257,1),
    (72,'Colibri',45,'Colibri',8,'Bird',50,90,140,5,5,5,5,1,1,1,1,3,1,4,3.0,1,1),
    (73,'Corpselights',46,'Corpselights',19,'Undead',40,100,120,3,3,4,2,3,3,3,1,4,1,5,8.0,6,0),
    (74,'Corse',47,'Corse',19,'Undead',40,111,140,1,3,3,5,1,5,1,1,3,1,3,8.0,6,0),
-- 75 Free
-- 76 Free
    (77,'Crab',48,'Crab',2,'Aquan',40,108,120,4,4,3,5,4,4,4,1,3,1,3,6.0,2,1),
    (78,'Craver',49,'Craver',12,'Empty',40,120,90,1,3,1,3,6,6,5,1,3,1,3,0.0,2,0),
    (79,'Crawler',63,'Crawler',20,'Vermin',40,105,120,4,4,3,5,4,4,4,1,5,1,3,4.0,2,1),
    (80,'Dhalmel',51,'Dhalmel',6,'Beast',40,110,120,3,4,4,5,4,4,5,1,3,1,3,4.0,257,1),
    (81,'Diremite',52,'Diremite',20,'Vermin',40,86,90,4,4,4,4,4,4,4,1,3,1,3,3.0,2,1),
    (82,'Bomb-Djinn',32,'Bomb',3,'Arcana',40,70,140,6,3,6,3,1,5,4,1,3,1,3,1.0,33,0),
-- 83 Free
    (84,'Doll-SightMagicAggro',53,'Doll',3,'Arcana',40,108,90,1,3,3,5,6,6,5,1,3,1,3,2.0,33,0),
    (85,'Doll-MagicAggro',53,'Doll',3,'Arcana',40,108,90,1,3,3,5,6,6,5,1,3,1,3,2.0,32,0),
    (86,'Doomed',54,'Doomed',19,'Undead',40,110,120,1,3,3,4,3,6,5,1,3,1,3,8.0,6,0),
    (87,'Dragon',55,'Dragon',10,'Dragon',30,125,90,1,3,3,3,3,3,1,1,3,1,3,8.0,2,0),
-- 88 Free
    (89,'Draugar',56,'Skeleton',19,'Undead',40,90,140,1,3,4,4,1,5,4,1,3,1,3,8.0,6,0),
    (90,'Dvergr',57,'Dvergr',9,'Demon',40,90,140,6,3,3,3,1,5,4,1,3,1,3,0.0,1,0),
    (91,'Dvergr_Skull',58,'Dvergr_Skull',9,'Demon',40,92,140,6,3,3,3,1,5,4,1,3,1,3,0.0,7,0),
    (92,'DynamisStatue-Goblin',59,'Statue',0,'Unclassified',20,30,120,1,1,4,1,3,3,1,1,3,1,3,0.0,1,0),
    (93,'DynamisStatue-Orc',59,'Statue',0,'Unclassified',20,30,100,1,2,1,1,5,3,3,1,3,1,3,0.0,1,0),
    (94,'DynamisStatue-Quadav',59,'Statue',0,'Unclassified',20,30,110,1,1,3,2,4,3,3,1,3,1,3,0.0,1,0),
    (95,'DynamisStatue-Yagudo',59,'Statue',0,'Unclassified',20,30,120,1,2,5,1,3,4,2,1,3,1,3,0.0,1,0),
    (97,'Lizard-Ice',60,'Lizard',14,'Lizard',40,92,120,4,3,5,4,4,4,4,1,3,1,3,5.0,2,0),
    (98,'Eft',61,'Eft',14,'Lizard',40,115,90,4,4,4,4,4,4,4,1,3,1,3,1.0,2,1),
    (99,'Elemental-Air',62,'Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,3.0,32,0),
    (100,'Elemental-Dark',62,'Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,8.0,32,0),
    (101,'Elemental-Earth',62,'Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,4.0,32,0),
    (102,'Elemental-Fire',62,'Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,1.0,32,0),
    (103,'Elemental-Ice',62,'Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,2.0,32,0),
    (104,'Elemental-Light',62,'Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,7.0,32,0),
    (105,'Elemental-Lightning',62,'Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,5.0,32,0),
    (106,'Elemental-Water',62,'Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,6.0,32,0),
    (107,'Eruca',63,'Crawler',20,'Vermin',40,92,120,1,3,4,3,3,6,5,1,5,1,3,1.0,258,1),
-- 108 Free
    (109,'Euvhi',64,'Euvhi',15,'Luminian',40,100,140,1,3,4,4,1,5,4,1,3,1,3,0.0,2,0),
    (110,'Evil_Weapon',6,'Evil_Weapon',3,'Arcana',40,105,120,1,3,4,3,3,3,4,1,5,1,3,3.0,34,0),
    (111,'Toad',112,'frog-toad',2,'Aquan',40,70,140,5,5,5,1,1,6,3,1,3,1,3,6.0,2,0),
    (112,'Flan',65,'Flan',1,'Amorph',40,70,140,5,4,4,4,3,5,3,1,3,1,3,6.0,193,0),
    (113,'Fly',66,'Fly',20,'Vermin',40,92,90,5,4,4,3,4,4,4,1,3,1,3,3.0,2,1),
    (114,'Flytrap',67,'Flytrap',17,'Plantoid',40,90,90,4,4,4,4,4,4,4,1,3,1,3,3.0,2,1),
    (115,'Fomor',68,'Shadow',19,'Undead',40,105,90,2,5,4,4,2,3,4,1,3,1,3,8.0,6,0),
    (116,'Funguar',69,'Funguar',17,'Plantoid',40,102,110,3,4,4,4,5,4,4,1,3,1,3,8.0,2,1),
-- 117 Free
    (118,'Gargouille',70,'Gargouille',9,'Demon',40,100,120,3,3,3,3,3,3,3,1,3,1,3,2.0,259,0),
-- TODO: Do Gear/Gear-Triple have an element/drop crystals?
    (119,'Gear',71,'Gear',4,'ArchaicMachine',40,90,90,1,3,4,5,6,6,5,1,3,1,5,0.0,35,0),
    (120,'Gear-Triple',71,'Gear',4,'ArchaicMachine',40,90,90,1,3,4,5,6,6,5,1,3,1,5,0.0,35,0),
    (121,'Ghost',28,'Ghost',19,'Undead',40,104,140,6,3,4,4,1,5,4,1,3,1,3,2.0,6,0),
    (122,'Ghrah',72,'Ghrah',16,'Luminion',40,120,140,1,1,3,3,1,3,3,1,3,1,3,7.0,2,0),
-- 123 Free
-- 124 Free
    (125,'Greater_Bird',73,'Greater_Bird',8,'Bird',40,130,120,3,3,3,3,3,3,3,1,2,1,3,7.0,1,0),
    (126,'Gigas',74,'Gigas',7,'Beastmen',40,125,100,1,2,1,5,6,4,3,1,3,1,3,2.0,1,0),
-- 127 Free
-- 128 Free
-- 129 Free
-- 130 Free
    (131,'Gnat',75,'Gnat',20,'Vermin',40,90,120,4,1,4,2,3,6,6,1,3,1,3,8.0,1,0),
    (132,'Gnole',76,'Gnole',6,'Beast',40,120,90,3,2,1,6,6,4,5,1,3,1,3,8.0,257,0),
    (133,'Goblin',77,'Goblin',7,'Beastmen',40,91,120,1,3,5,3,4,4,4,1,3,1,3,1.0,1,0),
    (134,'Promathia',78,'Supreme_Being',0,'Unclassified',40,120,140,1,1,1,1,1,1,1,1,1,1,1,0.0,3,0),
    (135,'Golem',79,'Golem',3,'Arcana',40,130,130,2,3,3,5,3,6,5,1,2,1,3,7.0,33,0),
    (136,'Goobbue',80,'Goobbue',17,'Plantoid',40,112,90,3,4,2,4,4,4,4,1,3,1,3,6.0,2,0),
    (137,'Gorger',81,'Gorger',12,'Empty',40,112,90,1,3,2,3,6,6,5,1,3,1,3,0.0,280,0),
    (138,'Gorger',81,'Gorger',12,'Empty',40,112,90,1,3,2,3,6,6,5,1,3,1,3,0.0,1,0),
    (139,'Hecteyes',82,'Hecteyes',1,'Amorph',40,87,140,5,4,4,4,3,4,4,1,3,1,3,8.0,2,1),
    (140,'Hippogryph',83,'Hippogryph',8,'Bird',60,90,140,4,4,4,4,4,4,4,1,3,1,1,7.0,1,0),
    (141,'Hippogryph-High_Res',83,'Hippogryph',8,'Bird',60,90,140,4,4,4,4,4,4,4,1,3,1,1,7.0,1,0),
    (142,'Hound',84,'Hound',19,'Undead',40,102,120,1,3,4,4,4,5,6,1,5,1,3,8.0,6,0),
    (143,'Hound',84,'Hound',19,'Undead',40,102,120,1,3,4,4,4,5,6,1,5,1,3,8.0,6,0),
    (144,'Hpemde',85,'Hpemde',15,'Luminian',40,90,120,7,1,4,4,4,6,6,1,3,1,3,0.0,2,0),
    (145,'Humanoid-Elvaan',86,'Humanoid',13,'Humanoid',40,100,90,2,5,3,6,6,2,4,1,3,1,3,0.0,1,0),
    (146,'Humanoid-Galka',86,'Humanoid',13,'Humanoid',40,120,100,3,4,1,5,5,4,6,1,3,1,3,0.0,1,0),
    (147,'Humanoid-Galka',86,'Humanoid',13,'Humanoid',40,120,100,3,4,1,5,5,4,6,1,3,1,3,0.0,1,0),
    (148,'Humanoid-Galka',86,'Humanoid',13,'Humanoid',40,120,100,3,4,1,5,5,4,6,1,3,1,3,0.0,1,0),
    (149,'Humanoid-Hume',86,'Humanoid',13,'Humanoid',40,90,110,4,4,4,4,4,4,3,1,3,1,3,0.0,1,0),
    (150,'Humanoid-Hume',86,'Humanoid',13,'Humanoid',64,90,110,4,4,4,4,4,4,4,1,3,1,3,0.0,1,0),
    (151,'Humanoid-Mithra',86,'Humanoid',13,'Humanoid',40,80,110,5,1,5,2,4,5,6,1,3,1,3,0.0,1,0),
    (152,'Humanoid-Mithra',86,'Humanoid',13,'Humanoid',40,80,110,5,1,5,2,4,5,6,1,3,1,3,0.0,1,0),
    (153,'Humanoid-Tarutaru',86,'Humanoid',13,'Humanoid',40,70,140,6,4,5,3,1,5,4,1,3,1,3,0.0,1,0),
    (154,'Humanoid-Tarutaru',86,'Humanoid',13,'Humanoid',40,70,140,6,4,5,3,1,5,4,1,3,1,3,0.0,1,0),

-- Hybrid Elemental are supposed to be 2 element each so 4 family.. this having 8 makes no sense
    (155,'HybridElemental-Air',87,'Hybrid_Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,32,0),
    (156,'HybridElemental-Dark',87,'Hybrid_Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,32,0),
    (157,'HybridElemental-Earth',87,'Hybrid_Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,32,0),
    (158,'HybridElemental-Fire',87,'Hybrid_Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,32,0),
    (159,'HybridElemental-Ice',87,'Hybrid_Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,32,0),
    (160,'HybridElemental-Light',87,'Hybrid_Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,32,0),
    (161,'HybridElemental-Lightning',87,'Hybrid_Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,32,0),
    (162,'HybridElemental-Water',87,'Hybrid_Elemental',11,'Elemental',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,32,0),

    (163,'Hydra',88,'Hydra',10,'Dragon',40,90,90,2,3,1,2,1,5,3,1,2,1,3,6.0,2,0),
    (164,'Hydra',88,'Hydra',10,'Dragon',40,90,90,2,3,1,2,1,5,3,1,2,1,3,6.0,2,0),
    (165,'Imp',89,'Imp',9,'Demon',50,70,140,6,3,4,3,1,5,4,1,3,1,5,8.0,3,0),
    (166,'Imp',89,'Imp',9,'Demon',50,70,140,6,3,4,3,1,5,4,1,3,1,5,8.0,3,0),
    (167,'Karakul',90,'Sheep',6,'Beast',40,90,110,3,4,4,4,5,4,4,1,3,1,3,4.0,1,1),
    (168,'Khimaira',91,'Khimaira',3,'Arcana',40,90,90,4,3,3,3,4,6,5,1,3,1,3,5.0,3,0),
    (169,'Kindred',92,'Kindred',9,'Demon',50,110,140,1,2,4,4,1,2,4,1,3,1,3,8.0,257,0),
    (170,'Ladybug',93,'Ladybug',20,'Vermin',40,87,120,4,1,4,2,3,6,6,1,3,1,3,3.0,257,1),
    (171,'Lamiae',94,'Lamiae-Merrow',7,'Beastmen',40,100,140,3,3,2,4,1,2,2,1,3,1,3,8.0,1,0),
    (172,'Leech',95,'Leech',1,'Amorph',40,90,90,4,4,5,4,3,4,4,1,3,1,3,6.0,2,1),
    (173,'Limule',96,'Limule',21,'Voragean',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (174,'Lizard',60,'Lizard',14,'Lizard',40,92,120,4,3,5,4,4,4,4,1,3,1,3,1.0,2,1),
    (175,'Magic_Pot',97,'Magic_Pot',3,'Arcana',40,80,140,3,3,4,5,1,1,3,1,3,1,3,7.0,32,0),
    (176,'Mamool_Ja',98,'Mamool_Ja',7,'Beastmen',40,100,120,2,4,3,3,3,3,3,1,3,1,2,3.0,1,0),
    (177,'Mamool_Ja-Knight',98,'Mamool_Ja',7,'Beastmen',40,120,120,2,4,3,3,3,3,3,1,3,1,3,3.0,1,0),
    (178,'Mandragora',99,'Mandragora',17,'Plantoid',40,107,120,5,3,4,4,4,4,4,1,3,1,2,4.0,2,1),
    (179,'Manticore',100,'Manticore',6,'Beast',50,140,130,2,5,2,5,4,4,5,1,3,1,3,3.0,257,0),
    (180,'Marid',101,'Marid',6,'Beast',40,150,90,3,5,1,6,3,3,4,1,3,1,3,4.0,257,0),
    (181,'MemoryReceptacle',0,'undefined',12,'Empty',0,200,0,1,3,5,4,2,2,5,1,3,1,3,0.0,256,0),
    (182,'Merrow',94,'Lamiae-Merrow',7,'Beastmen',40,100,120,3,3,2,4,3,3,2,1,3,1,3,6.0,1,0),
    (183,'Mimic',102,'Mimic',3,'Arcana',0,90,90,1,3,2,2,6,6,5,1,3,1,3,7.0,34,0),
    (184,'Moblin',77,'Goblin',7,'Beastmen',40,92,140,1,1,4,3,1,1,3,1,3,1,3,5.0,1,0),
    (185,'Moogle',50,'Moogle',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (186,'Morbol',103,'Morbol',17,'Plantoid',40,140,100,4,2,4,4,4,5,4,1,3,1,3,4.0,2,0),
    (187,'Murex',104,'Murex',21,'Voragean',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,160,0),
    (188,'Opo-opo',105,'Opo-opo',6,'Beast',40,110,90,5,2,5,2,6,6,2,1,3,1,3,5.0,257,1),
    (189,'Orc',106,'Orc',7,'Beastmen',40,108,100,2,3,4,4,7,4,3,1,3,1,3,1.0,257,0),
    (190,'Orc-Warmachine',106,'Orc',7,'Beastmen',40,123,100,4,6,4,3,5,1,3,1,2,1,3,1.0,257,0),
    (191,'Orobon',107,'Orobon',2,'Aquan',40,90,90,1,4,2,4,4,4,4,1,3,1,3,6.0,2,0),
    (192,'Peiste',108,'Peiste',14,'Lizard',40,90,90,1,3,4,3,6,6,5,1,3,1,3,6.0,1,0),
    (193,'Wyvern-Pet',109,'Wyvern',10,'Dragon',40,70,90,4,2,3,4,6,3,3,1,3,1,3,0.0,1,0),
    (194,'Phuabo',110,'Phuabo',15,'Luminian',70,90,140,1,3,4,1,1,5,4,1,3,1,3,0.0,2,0),
    (195,'Pixie',111,'Pixie',18,'Fairy',40,90,100,4,6,4,5,5,1,3,1,3,1,3,3.0,1,0),
    (196,'Poroggo',112,'frog-toad',7,'Beastmen',40,70,140,5,5,5,1,1,6,3,1,3,1,3,6.0,2,0),
    (197,'Pugil',113,'Pugil',2,'Aquan',40,90,90,4,4,4,3,4,4,5,1,3,1,4,6.0,2,1),
    (198,'Puk',114,'Puk',10,'Dragon',40,93,90,1,3,5,2,6,6,2,1,3,1,4,3.0,3,1),
    (199,'Qiqirn',115,'Qiqirn',7,'Beastmen',40,88,140,4,5,3,1,1,4,4,1,3,1,3,4.0,257,0),
-- 200 Free
-- 201 Free
    (202,'Quadav',116,'Quadav',7,'Beastmen',40,112,110,2,3,4,4,4,5,3,1,3,1,3,6.0,258,0),
    (203,'Qutrub',117,'Qutrub',19,'Undead',40,100,140,1,3,3,5,1,5,4,1,3,1,3,8.0,7,0),
-- 204 Free
-- 205 Free
    (206,'Rabbit',118,'Rabbit',6,'Beast',40,96,120,4,3,4,4,4,4,4,1,3,1,3,4.0,257,1),
    (207,'Rafflesia',119,'Rafflesia',17,'Plantoid',40,90,90,1,3,4,3,6,6,5,1,3,1,3,4.0,2,0),
    (208,'Ram',120,'Ram',6,'Beast',40,120,100,3,4,3,4,4,4,4,1,3,1,3,4.0,257,0),
    (209,'Rampart',121,'Rampart',4,'ArchaicMachine',40,90,90,1,3,4,3,6,6,5,1,3,1,3,5.0,34,0),
    (210,'Raptor',122,'Raptor',14,'Lizard',50,95,120,4,4,5,3,4,4,4,1,3,1,3,1.0,258,1),
    (211,'Ruszor',123,'Ruszor',2,'Aquan',40,100,120,3,3,3,3,3,3,3,1,3,1,3,2.0,1,0),
    (212,'Sabotender',124,'Sabotender',17,'Plantoid',40,100,90,3,5,5,3,5,5,3,1,3,1,3,6.0,2,1),
    (213,'Sahagin',125,'Sahagin',7,'Beastmen',40,107,110,2,2,5,2,2,5,4,1,3,1,3,6.0,2,0),
    (214,'Sandworm',126,'Sandworm',1,'Amorph',40,130,180,1,3,4,3,6,6,5,1,3,1,3,4.0,2,0),
    (215,'Sandworm',126,'Sandworm',1,'Amorph',40,130,180,1,3,4,3,6,6,5,1,3,1,3,4.0,2,0),
    (216,'Sapling',127,'Sapling',17,'Plantoid',40,85,120,4,4,3,4,4,4,5,1,3,1,3,4.0,2,1),
    (217,'Scorpion',128,'Scorpion',20,'Vermin',40,105,120,3,5,4,4,4,4,4,1,3,1,3,4.0,258,1),
    (218,'Sea_Monk',129,'Sea_Monk',2,'Aquan',40,110,140,3,5,4,4,4,4,4,1,3,1,3,6.0,2,1),
    (219,'Sea_Monk',129,'Sea_Monk',2,'Aquan',40,110,140,3,5,4,4,4,4,4,1,3,1,3,6.0,2,1),
    (220,'Seether',130,'Seether',12,'Empty',50,117,90,1,3,2,4,6,6,5,1,3,1,3,0.0,272,0),
    (221,'Shadow',68,'Shadow',19,'Undead',40,100,90,2,5,3,3,6,2,4,1,3,1,3,8.0,6,0),
-- 222 Free
-- 223 Free
    (224,'ShadowLord',0,'undefined',0,'Unclassified',40,120,140,1,1,1,1,1,1,1,1,1,1,1,8.0,1,0),
    (225,'ShadowLord',0,'undefined',0,'Unclassified',40,120,140,1,1,1,1,1,1,1,1,1,1,1,8.0,1,0),
    (226,'Sheep',90,'Sheep',6,'Beast',40,120,110,3,4,4,4,5,4,4,1,3,1,3,4.0,257,1),
    (227,'Skeleton',56,'Skeleton',19,'Undead',40,95,140,1,3,4,4,1,5,1,1,3,1,3,4.0,6,0),
    (228,'Slime-DragonQuest',42,'Slime',1,'Amorph',40,100,120,4,4,4,5,4,3,4,1,3,1,3,6.0,258,1),
    (229,'Slime',42,'Slime',1,'Amorph',40,100,120,4,4,4,5,4,3,4,1,3,1,3,6.0,258,1),
-- 230 Free
    (231,'Slug',131,'Slug',1,'Amorph',40,90,90,1,3,4,3,6,6,5,1,3,1,3,6.0,2,1),
    (232,'Bomb-Snoll',32,'Bomb',3,'Arcana',40,89,140,6,3,6,3,1,5,4,1,3,1,3,2.0,33,0),
    (233,'Soulflayer',132,'Psychodemon',9,'Demon',40,100,140,6,3,5,6,1,5,4,1,3,1,3,6.0,482,0),
    (234,'Spheroid',133,'Spheroid',3,'Arcana',40,90,90,1,3,7,1,6,6,5,1,3,1,3,5.0,34,0),
    (235,'Spider',134,'Spider',20,'Vermin',40,87,130,5,2,5,4,3,3,6,1,3,1,3,4.0,2,1),
    (236,'Structure',0,'undefined',0,'Unclassified',64,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (237,'Structure',0,'undefined',0,'Unclassified',255,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,1,0),
    (238,'Structure',0,'undefined',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (239,'Structure',0,'undefined',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (240,'Tauri',135,'Tauri',9,'Demon',40,123,130,1,3,5,5,3,6,5,1,3,1,2,8.0,1,0),
    (241,'Thinker',136,'Thinker',12,'Empty',50,132,90,1,3,2,4,6,6,5,1,3,1,3,0.0,1,0),
    (242,'Tiger',137,'Tiger',6,'Beast',60,111,120,4,3,4,4,6,4,4,1,3,1,3,5.0,257,1),
    (243,'Tonberry',138,'Tonberry',7,'Beastmen',40,87,140,3,1,3,2,1,5,2,1,3,1,3,7.0,1,0),
    (244,'Tonberry',138,'Tonberry',7,'Beastmen',40,87,140,3,1,3,2,1,5,2,1,3,1,3,7.0,1,0),
    (245,'Treant',139,'Treant',17,'Plantoid',40,120,120,4,4,3,4,4,4,5,1,3,1,3,4.0,2,0),
    (246,'Troll',140,'Troll',7,'Beastmen',40,120,120,1,2,2,5,3,3,3,1,2,1,3,1.0,1,0),
    (247,'Tubes',0,'undefined',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (248,'Turret-Orc',141,'Siege_Engine',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,1,0),
    (249,'Turret-Quadav',141,'Siege_Engine',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,1,0),
    (250,'Turret-Yagudo',141,'Siege_Engine',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,1,0),
    (251,'Uragnite',142,'Uragnite',2,'Aquan',40,120,90,4,4,4,4,4,4,4,1,3,1,3,6.0,2,1),
-- 252 Free
    (253,'Wamoura',144,'Wamoura',20,'Vermin',40,90,90,5,5,1,5,5,5,5,1,3,1,3,1.0,34,0),
    (254,'Wamouracampa',144,'Wamoura',20,'Vermin',45,90,90,5,5,1,5,5,5,5,1,3,1,3,1.0,2,0),
    (255,'Wanderer',145,'Wanderer',12,'Empty',40,110,90,1,3,5,5,6,6,5,1,3,1,3,0.0,2,0),
    (256,'Weeper',146,'Weeper',12,'Empty',50,110,90,2,2,5,5,6,6,5,1,3,1,3,0.0,257,0),
    (257,'Wivre',147,'Wivre',14,'Lizard',40,140,90,1,5,1,6,5,5,4,1,3,1,3,4.0,259,0),
    (258,'Worm',148,'Worm',1,'Amorph',0,70,200,4,3,5,4,3,4,4,1,3,1,5,4.0,2,1),
    (259,'Wyrm-Ouryu',149,'Wyrm',10,'Dragon',40,120,90,4,1,3,2,2,3,1,1,3,1,3,3.0,1,0),
    (260,'Wyrm-Fafnir',149,'Wyrm',10,'Dragon',40,120,90,4,1,3,2,2,3,1,1,3,1,3,1.0,1,0),
    (261,'Wyrm-Cynoprosopi',149,'Wyrm',10,'Dragon',40,120,90,4,1,3,2,2,3,1,1,3,1,3,2.0,1,0),
    (262,'Wyrm',149,'Wyrm',10,'Dragon',40,120,90,4,1,3,2,2,3,1,1,3,1,3,1.0,1,0),
    (263,'Wyrm-Nidhogg',149,'Wyrm',10,'Dragon',40,120,90,4,1,3,2,2,3,1,1,3,1,3,1.0,1,0),
    (264,'Wyrm',149,'Wyrm',10,'Dragon',40,120,90,4,1,3,2,2,3,1,1,3,1,3,1.0,1,0),
    (265,'Wyvern-Simorg',109,'Wyvern',10,'Dragon',50,115,90,4,2,3,4,6,3,3,1,3,1,3,2.0,1,0),
    (266,'Wyvern',109,'Wyvern',10,'Dragon',75,115,90,4,2,3,4,6,3,3,1,3,1,3,3.0,1,0),
    (267,'Wyvern-Guivre',109,'Wyvern',10,'Dragon',50,115,90,4,2,3,4,6,3,3,1,3,1,3,7.0,257,0),
    (268,'Wyvern-Undead',109,'Wyvern',10,'Dragon',40,109,90,4,2,3,4,6,3,3,1,3,1,3,8.0,1,0),
    (269,'Xzomit',150,'Xzomit',15,'Luminian',50,100,110,3,2,4,6,4,5,1,1,3,1,3,0.0,1,0),
    (270,'Yagudo',151,'Yagudo',7,'Beastmen',40,85,120,2,2,3,3,4,5,3,1,3,1,3,3.0,1,0),
    (271,'Yovra',152,'Yovra',15,'Luminian',40,80,140,2,3,4,5,5,5,5,1,3,1,5,0.0,2,0),
    (272,'Zdei',97,'Magic_Pot',16,'Luminion',40,100,140,6,3,4,4,1,3,4,1,3,1,3,0.0,1,0),
    (273,'Scorpion-Serket',128,'Scorpion',20,'Vermin',40,90,120,3,5,4,4,4,4,4,1,3,1,3,4.0,258,0),
    (274,'Scorpion-KingV',128,'Scorpion',20,'Vermin',40,90,120,3,5,4,4,4,4,4,1,3,1,3,4.0,2,0),
-- 275 Free
    (276,'Worm-BigWorm',148,'Worm',1,'Amorph',0,70,180,6,3,5,4,1,2,4,1,3,1,5,4.0,2,0),
    (277,'Adamantoise-Genbu',2,'Adamantoise',14,'Lizard',30,120,90,2,4,1,4,1,1,1,1,2,1,3,6.0,1,0),
    (278,'Wyvern-Seiryu',109,'Wyvern',10,'Dragon',60,109,90,1,2,1,3,6,3,3,1,3,1,3,7.0,1,0),
    (279,'Tiger-Byakko',137,'Tiger',6,'Beast',60,111,120,4,3,4,4,6,4,4,1,3,1,3,5.0,1,0),
    (280,'Greater_Bird-Suzaku',73,'Greater_Bird',8,'Bird',60,130,120,3,3,3,3,3,3,3,1,2,1,3,7.0,1,0),
    (281,'Manticore-Kirin',100,'Manticore',6,'Beast',60,140,130,2,5,2,5,4,4,5,1,3,1,3,3.0,272,0),
    (282,'Kuluu-Grav_iton',138,'Tonberry',7,'Beastmen',40,91,140,3,1,3,2,1,5,4,1,3,1,2,7.0,1,0),
-- 284 Free
    (285,'Mamool_Ja',98,'Mamool_Ja',7,'Beastmen',40,112,120,2,4,3,3,4,4,3,1,3,1,3,3.0,1,0),
    (286,'Puk-Vulpangue',114,'Puk',10,'Dragon',40,100,90,6,4,5,3,6,6,5,1,2,1,4,3.0,3,0),
    (287,'Colibri-Chamrosh',45,'Colibri',8,'Bird',60,80,140,5,5,5,5,1,1,1,1,3,1,4,3.0,2,0),
    (288,'Qiqirn-Cheese_Hoarder',115,'Qiqirn',7,'Beastmen',40,90,140,4,5,3,1,1,4,4,1,3,1,3,4.0,272,0),
    (289,'Wamouracampa-BrassBorer',144,'Wamoura',20,'Vermin',40,90,90,5,5,1,5,5,5,5,1,3,1,3,1.0,2,0),
    (290,'Slime-Claret',42,'Slime',1,'Amorph',40,100,120,4,4,4,5,4,3,4,1,3,1,3,6.0,2,0),
    (291,'Ob',10,'Automaton',0,'Unclassified',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
    (292,'Velionis',56,'Skeleton',19,'Undead',40,90,140,1,3,4,3,1,5,4,1,3,1,3,8.0,6,0),
    (293,'Chigoe-Chigre',40,'Chigoe',20,'Vermin',40,120,90,6,6,1,6,6,4,5,1,3,1,3,4.0,3,0),
    (294,'Apkallu-Small',9,'Apkallu',8,'Bird',40,120,90,4,3,5,4,4,4,4,1,3,1,2,6.0,3,0),
    (295,'IrizIma',101,'Marid',6,'Beast',24,90,90,1,3,4,3,6,6,5,1,3,1,3,4.0,257,0),
    (296,'Morbol-LividrootAmoo',103,'Morbol',17,'Plantoid',40,120,100,4,2,4,4,4,5,4,1,3,1,3,4.0,2,0),
    (297,'Poroggo-IririSamariri',112,'frog-toad',7,'Beastmen',40,70,140,5,5,5,1,1,6,3,1,3,1,3,6.0,2,0),
    (298,'Dragon-Anantaboga',55,'Dragon',10,'Dragon',40,120,90,1,3,3,3,3,3,1,1,3,1,3,8.0,2,0),
    (299,'Botuli',153,'Botuli',1,'Amorph',40,70,140,6,3,6,3,1,5,4,1,3,1,3,6.0,129,0),
    (300,'Bomb-Reacton',32,'Bomb',3,'Arcana',40,70,140,6,3,4,3,1,5,4,1,3,1,3,1.0,33,0),
    (301,'Imp-Verdelet',89,'Imp',9,'Demon',70,65,140,6,3,3,3,1,5,4,1,3,1,3,8.0,1,0),
    (302,'Acrolith-Wulgaru',1,'Acrolith',3,'Arcana',40,90,90,1,3,4,3,6,6,5,1,3,1,3,0.0,2,0),
-- 303 Free
-- 304 Free
    (305,'Mamool_Ja-GotohZhaTheRe',98,'Mamool_Ja',7,'Beastmen',40,100,120,2,4,3,3,3,3,3,1,3,1,3,3.0,272,0),
    (306,'Wivre-Dea',147,'Wivre',14,'Lizard',43,120,90,2,5,1,6,6,3,3,1,3,1,3,4.0,4,0),
    (307,'Wamoura-Achamoth',144,'Wamoura',20,'Vermin',40,90,90,1,3,4,3,6,6,5,1,3,1,3,1.0,34,0),
    (308,'Troll-Khromasoul',140,'Troll',7,'Beastmen',40,120,120,1,2,2,5,3,3,3,1,3,1,3,1.0,48,0),
    (309,'Vampyr',143,'Vampyr',19,'Undead',40,100,120,1,3,3,4,3,6,6,1,3,1,3,8.0,7,0),
    (310,'ExperimentalLa',94,'Lamiae',7,'Beastmen',40,100,140,3,3,3,1,1,2,2,1,3,1,3,8.0,1,0),
    (311,'Soulflayer-MahjlaefThePai',132,'Psychodemon',9,'Demon',40,100,140,6,3,5,6,1,5,4,1,3,1,3,6.0,168,0),
    (312,'Orobon-Nuhn',107,'Orobon',2,'Aquan',40,90,90,1,4,2,4,4,4,4,1,3,1,3,6.0,2,0),
    (313,'Hydra-Tinnin',88,'Hydra',10,'Dragon',40,90,90,2,3,1,2,1,5,3,1,3,1,3,6.0,2,0),
    (314,'Cerberus-Sarameya',38,'Cerberus',6,'Beast',40,90,90,1,1,3,1,1,1,2,1,3,1,3,1.0,3,0),
    (315,'Khimaira-Tyger',91,'Khimaira',3,'Arcana',40,90,90,4,3,3,3,4,6,5,1,3,1,3,5.0,3,0),
    (316,'Dvergr-Pandemonium',57,'Dvergr',9,'Demon',40,100,140,6,3,3,3,1,5,4,1,3,1,3,0.0,1,0),
    (319,'Avatar-Shiva',22,'Shiva',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (320,'Avatar-Ramuh',21,'Ramuh',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (321,'Avatar-Titan',23,'Titan',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (322,'Avatar-Ifrit',17,'Ifrit',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (323,'Avatar-Leviathan',19,'Leviathan',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (324,'Avatar-Garuda',16,'Garuda',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (325,'Avatar-Fenrir',15,'Fenrir',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (326,'Troll-Gurfurlur',140,'Troll',7,'Beastmen',40,120,120,1,2,2,5,3,3,3,1,2,1,3,1.0,272,0),
    (327,'Goblin',77,'Goblin',7,'Beastmen',40,91,120,2,3,5,3,3,3,1,1,3,1,3,1.0,1,0),
-- 328 Free
    (329,'AbsoluteVirtue',3,'Aern',15,'Luminian',40,120,140,4,2,3,2,4,1,1,1,3,1,3,0.0,3,0),
    (330,'Adamantoise-PetGenbu',2,'Adamantoise',14,'Lizard',30,120,90,2,4,1,4,1,1,1,1,2,1,3,6.0,2,0),
    (331,'Wyvern-PetSeiryu',109,'Wyvern',10,'Dragon',60,109,90,1,2,1,3,6,3,3,1,3,1,3,7.0,1,0),
    (332,'Tiger-PetByakko',137,'Tiger',6,'Beast',60,111,120,4,3,4,4,6,4,4,1,3,1,3,5.0,2,0),
    (333,'Greater_Bird-PetSuzaku',73,'Greater_Bird',8,'Bird',60,130,120,3,3,3,3,3,3,3,1,2,1,3,7.0,1,0),
-- 334 Free
    (335,'Maat',0,'Maat',13,'Humanoid',40,90,110,4,4,4,4,4,4,4,1,3,1,3,0.0,3,0),
    (336,'Tonberry-ZM4',138,'Tonberry',7,'Beastmen',40,91,140,3,1,3,2,1,5,4,1,3,1,2,7.0,1,0),
-- 337 Free
    (338,'Twitherym',154,'Moth',20,'Vermin',40,92,90,1,3,4,3,6,6,5,1,3,1,3,3.0,1,1),
    (339,'Chapuli',155,'Chapuli',20,'Vermin',40,105,120,3,3,4,3,3,6,5,1,5,1,3,4.0,1,1),
    (340,'Mantid',156,'Mantid',20,'Vermin',40,105,120,3,3,4,3,3,6,5,1,5,1,3,4.0,1,0),
    (341,'Blossom',0,'undefined',0,'Unclassified',0,130,180,1,3,4,3,6,6,5,1,3,1,3,4.0,2,0),
    (342,'Velkk',157,'Velkk',7,'Beastmen',40,116,140,1,3,1,2,2,3,3,1,3,1,3,8.0,257,0),
    (343,'Heartwing',158,'Heartwing',11,'Elemental',40,90,90,1,3,4,3,6,6,5,1,3,1,3,5.0,288,0),
    (344,'Cracklaw',159,'Cracklaw',2,'Aquan',40,108,120,4,3,1,5,3,3,4,1,3,1,3,6.0,2,0),
    (345,'Acuex',160,'Acuex',1,'Amorph',40,100,120,1,3,3,4,3,6,1,1,3,1,3,6.0,2,0),
    (346,'Obstacle-Knotted_Root',0,'undefned',1,'Obstacle',0,70,200,4,3,6,4,3,4,4,1,3,1,3,4.0,2,0),
    (347,'Marolith',161,'Marolith',3,'Arcana',40,130,130,2,3,3,3,3,6,5,1,3,1,3,7.0,33,0),
    (348,'Matamata',162,'Matamata',14,'Lizard',30,120,90,2,5,1,6,6,4,3,1,3,1,4,1.0,3,0),
    (349,'Geyser',0,'undefned',0,'Unclassified',0,130,180,1,3,4,3,6,6,5,1,3,1,3,4.0,2,0),
    (350,'Iron_Giant',163,'Iron_Giant',3,'Arcana',40,130,130,2,3,3,3,3,6,5,1,3,1,3,7.0,3,0),
    (351,'Zilart',164,'Zilart',13,'Humanoid',40,90,110,3,3,2,3,2,2,3,1,3,1,3,0.0,3,0),
    (352,'ArkAngel-EV',165,'Crystal_Warrior',13,'Humanoid',40,100,90,2,5,3,6,6,2,4,1,3,1,3,0.0,1,0),
    (353,'ArkAngel-GK',165,'Crystal_Warrior',13,'Humanoid',60,120,100,3,4,1,5,5,4,6,1,3,1,3,0.0,1,0),
    (354,'ArkAngel-HM',165,'Crystal_Warrior',13,'Humanoid',60,90,110,3,3,2,3,2,2,3,1,3,1,3,0.0,1,0),
    (355,'ArkAngel-MR',165,'Crystal_Warrior',13,'Humanoid',40,80,110,5,1,5,2,4,5,6,1,3,1,3,0.0,1,0),
    (356,'ArkAngel-TT',165,'Crystal_Warrior',13,'Humanoid',40,70,140,6,4,5,3,1,5,4,1,3,1,3,0.0,1,0),
    (357,'Antlion-Ambush',8,'Antlion',20,'Vermin',40,125,125,4,4,4,4,4,4,4,1,3,1,3,8.0,2,0),
    (358,'Kindred',92,'Kindred',9,'Demon',70,110,140,1,2,4,4,1,2,4,1,3,1,3,8.0,257,0),
    (359,'Fomor',68,'Shadow',19,'Undead',40,105,90,2,5,4,4,2,3,4,1,3,1,3,8.0,6,0),
    (360,'Fomor-ToAU',68,'Shadow',19,'Undead',40,105,90,2,5,4,4,2,3,4,1,3,1,3,8.0,198,0),
    (361,'DynamisLord',0,'undefined',0,'Unclassified',40,120,140,1,1,1,1,1,1,1,1,1,1,1,8.0,1,0),
    (362,'Sabotender-Florido',124,'Sabotender',17,'Plantoid',50,100,90,3,5,5,3,5,5,3,1,3,1,3,6.0,2,0),
    (363,'Automaton_Harlequin',10,'Automaton',0,'Unclassified',40,115,100,6,6,4,6,4,4,3,1,1,1,1,0.0,2,0),
    (364,'Automaton_Valoredge',10,'Automaton',0,'Unclassified',40,155,0,6,5,6,4,4,5,5,1,1,1,1,0.0,2,0),
    (365,'Automaton_Sharpshot',10,'Automaton',0,'Unclassified',40,115,0,4,5,4,6,5,5,6,1,1,1,1,0.0,2,0),
    (366,'Automaton_Stormwaker',10,'Automaton',0,'Unclassified',40,90,110,5,5,5,4,5,6,5,1,1,1,1,0.0,2,0),
-- 367 Free
-- 398 Free
    (369,'Leech',95,'Leech',1,'Amorph',40,90,90,4,4,5,4,3,4,4,1,3,1,3,6.0,258,1),
    (371,'Marid',101,'Marid',6,'Beast',40,150,90,3,5,1,6,3,3,4,1,3,1,3,4.0,257,0),
-- 372 Free
    (373,'Goblin-Armored',77,'Goblin',7,'Beastmen',40,91,120,1,3,5,3,4,4,4,1,3,1,3,5.0,1,0),
-- 374 Free
-- 375 Free
-- 376 Free
-- 377 Free
    (378,'Avatar-Diabolos',14,'Diabolos',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,1,0),
    (379,'Pet-Carbuncle',13,'Carbuncle',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (380,'Pet-Diabolos',14,'Diabolos',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (381,'Pet-Fenrir',15,'Fenrir',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (382,'Pet-Garuda',16,'Garuda',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (383,'Pet-Ifrit',17,'Ifrit',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (384,'Pet-Leviathan',19,'Leviathan',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (385,'Pet-Odin',20,'Odin',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (386,'Pet-Ramuh',21,'Ramuh',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (387,'Pet-Shiva',22,'Shiva',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (388,'Pet-Titan',23,'Titan',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (389,'Pet-Alexander',12,'Alexander',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0),
    (390,'Ladybug-DUP',93,'Ladybug',20,'Vermin',40,87,120,4,1,4,2,3,6,6,1,3,1,3,3.0,257,1),
    (391,'Wyrm-Vrtra',149,'Wyrm',10,'Dragon',40,120,90,4,1,3,2,2,3,1,1,3,1,3,8.0,3,0),
    (392,'Wyrm-Jormungand',149,'Wyrm',10,'Dragon',40,120,90,4,1,3,2,2,3,1,1,3,1,3,5.0,3,0),
    (393,'Wyrm-Tiamat',149,'Wyrm',10,'Dragon',40,120,90,4,1,3,2,2,3,1,1,3,1,3,1.0,1,0),
    (394,'Humanoid-Hume',86,'Humanoid',13,'Humanoid',64,90,110,4,4,4,4,4,4,4,1,3,1,3,0.0,1,0),
-- 395 Free
-- 396 Free
-- 397 Free
    (398,'Sheep-Slumbering_Samwell',90,'Sheep',6,'Beast',40,120,110,3,4,4,4,5,4,4,1,3,1,3,4.0,1,0),
-- 399 Free
-- 400 Free
-- 401 Free
    (402,'Scorpion-Aqrabuamelu',128,'Scorpion',20,'Vermin',40,90,120,3,5,4,4,4,4,4,1,3,1,3,4.0,258,0),
-- 403 Free
    (404,'Rabbit-Cure',118,'Rabbit',6,'Beast',40,96,120,4,3,4,4,4,4,4,1,3,1,3,4.0,257,1),
-- 406 Free
-- 407 Free
-- 408 Free
-- 409 Free
    (410,'Goblin-Seed',77,'Goblin',7,'Beastmen',40,91,120,1,3,5,3,4,4,4,1,3,1,3,1.0,257,0),
    (435,'Giant_Gnat',75,'Gnat',20,'Vermin',40,90,120,4,1,4,2,3,6,6,1,3,1,3,8.0,1,0),
    (436,'Gnat-Bloodlapper',75,'Gnat',20,'Vermin',40,90,120,4,1,4,2,3,6,6,1,3,1,3,8.0,1,0),
    (437,'Sapling-Ghillie_Dhu',127,'Sapling',17,'Plantoid',40,90,120,4,4,3,4,4,4,5,1,3,1,3,4.0,1,0),
-- 438 Free
    (444,'Larzos',68,'Shadow',13,'Humanoid',40,90,110,4,3,4,4,3,3,3,1,3,1,3,0.0,1,0),
    (445,'Portia',68,'Shadow',13,'Humanoid',40,90,110,4,3,4,4,3,3,3,1,3,1,3,0.0,1,0),
    (446,'Ragelise',68,'Shadow',13,'Humanoid',40,90,110,4,3,4,4,3,3,3,1,3,1,3,0.0,1,0),
    (447,'Dullahan',166,'Dullahan',19,'Undead',40,70,140,6,3,6,3,1,5,4,1,3,1,3,2.0,6,0),

-- Per multiple sources, Flutterini are Twitherym that have grown exceptionally large and left their swarm
    (448,'Fluturini',154,'Moth',20,'Vermin',40,92,90,1,3,4,3,6,6,5,1,3,1,3,3.0,1,0),

    (449,'Bahamut',149,'Wyrm',5,'Avatar',40,120,90,1,3,1,3,6,3,1,1,3,1,3,3.0,1,0),
    (450,'Caturae',167,'Caturae',3,'Arcana',40,90,90,1,3,4,3,6,6,5,1,3,1,3,0.0,1,0),
    (451,'Pteraketos',168,'Pteraketos',2,'Aquan',40,120,140,6,5,4,5,3,3,4,1,4,1,2,6.0,2,0),
    (452,'Rockfin',169,'Rockfin',2,'Aquan',40,120,140,6,5,4,5,3,3,4,1,4,1,2,6.0,2,0),
    (453,'Belladonna',193,'Belladonna',17,'Plantoid',40,90,90,1,3,4,3,6,6,5,1,3,1,3,4.0,2,0),
    (454,'Tulfaire',170,'Tulfaire',8,'Bird',40,106,120,1,3,5,3,3,3,5,1,3,1,3,1.0,3,0),
    (455,'Leafkin',171,'Leafkin',17,'Plantoid',40,90,90,1,3,4,3,6,6,2,1,3,1,3,3.0,1,0),
    (456,'Bztavian',172,'Bztavian',20,'Vermin',40,87,120,1,3,3,2,3,3,5,1,3,1,3,3.0,2,0),
    (457,'Cehuetzi',173,'Cehuetzi',6,'Beast',60,111,120,1,1,4,2,3,6,5,1,3,1,3,5.0,2,0),
    (458,'Raaz',174,'Raaz',6,'Beast',60,111,120,1,1,4,2,3,6,5,1,3,1,3,5.0,2,0),
    (459,'Yztarg',175,'Yztarg',6,'Beast',40,110,90,1,3,4,3,6,6,1,1,3,1,3,5.0,269,0),
    (460,'Waktza',176,'Waktza',8,'Bird',40,106,120,1,3,5,3,3,3,5,1,3,1,3,1.0,256,0),
    (461,'Gabbrath',177,'Gabbrath',14,'Lizard',30,120,90,2,5,1,6,6,4,3,1,3,1,4,4.0,256,0),
    (462,'Provenance_Watcher',78,'Supreme_Being',10,'Dragon',40,120,90,1,3,1,3,6,3,1,1,3,1,3,1.0,2,0),
    (463,'Panopt',178,'Panopt',17,'Plantoid',40,90,90,1,3,4,3,6,6,2,1,3,1,3,3.0,3,0),
    (464,'Snapweed',179,'Snapweed',17,'Plantoid',40,90,90,1,3,4,3,6,6,5,1,3,1,3,4.0,258,0),
    (465,'Yggdreant',180,'Yggdreant',17,'Plantoid',40,120,120,1,2,1,2,3,1,3,1,3,1,3,4.0,2,0),
    (467,'Gallu',181,'Gallu',9,'Demon',70,110,140,1,2,4,4,1,2,4,1,3,1,3,8.0,2,0),
    (468,'Umbril',182,'Umbril',11,'Elemental',40,90,90,1,3,4,3,6,6,5,1,3,1,3,0.0,33,0),
    (469,'Lamiae-Medusa',94,'Lamiae',7,'Beastmen',40,100,140,3,3,2,4,1,2,2,1,3,1,3,8.0,1,0),
    (470,'Zilant',183,'Zilant',10,'Dragon',40,120,90,1,3,1,3,6,3,1,1,3,1,3,3.0,2,0),
    (471,'Harpeia',184,'Harpeia',8,'Bird',60,130,120,1,3,4,3,4,4,5,1,3,1,2,7.0,2,0),
    (472,'Naraka',185,'Naraka',19,'Undead',40,70,140,6,3,6,3,1,5,4,1,3,1,3,2.0,6,0),
    (473,'Lady_Lilith',86,'Humanoid',13,'Humanoid',40,90,110,3,3,2,3,2,2,3,1,3,1,3,0.0,1,0),
    (474,'Lilith_Ascendant',78,'Supreme_Being',0,'Unclassified',40,120,140,1,1,1,1,1,1,1,1,1,1,1,8.0,1,0),

-- Believe it or not demon killer can proc on Shinryu in retail, and dragon killer won't. CONFIRMED. Crazy!
    (475,'Shinryu',78,'Supreme_Being',10,'Demon',50,115,90,1,2,1,3,6,3,3,1,3,1,3,7.0,1,0),
    (476,'Prishe',86,'Humanoid',13,'Humanoid',40,100,90,2,5,3,6,6,2,4,1,3,1,3,0.0,1,0),
    (477,'Selh''teus',186,'Kuluu',13,'Humanoid',40,90,110,3,3,2,3,2,2,3,1,3,1,3,0.0,1,0),
    (478,'Promathia-Metus',78,'Supreme_Being',0,'Unclassified',40,120,140,1,1,1,1,1,1,1,1,1,1,1,0.0,3,0),
-- 479 Free
    (480,'Zeid',86,'Humanoid',13,'Humanoid',40,120,100,3,4,1,5,5,4,6,1,3,1,3,0.0,6,0),
    (481,'Ajido-Marujido',86,'Humanoid',13,'Humanoid',40,70,140,6,4,5,3,1,5,4,1,3,1,3,0.0,3,0),
    (482,'Volker',86,'Humanoid',13,'Humanoid',40,90,110,4,4,4,4,4,4,4,1,3,1,3,0.0,1,0),
    (483,'Trion',86,'Humanoid',13,'Humanoid',40,100,90,2,5,3,6,6,2,4,1,3,1,3,0.0,3,0),
    (484,'Lilisette',86,'Humanoid',13,'Humanoid',40,90,110,3,3,2,3,2,2,3,1,3,1,3,0.0,1,0),
    (485,'Hadesv1',86,'Humanoid',13,'Humanoid',40,100,90,2,5,3,6,6,2,4,1,3,1,3,0.0,3,0),
    (486,'Arciela',86,'Humanoid',13,'Humanoid',40,90,110,3,3,2,3,2,2,3,1,3,1,3,0.0,3,0),
    (487,'Hadesv2',78,'Supreme_Being',9,'Demon',40,90,140,6,3,3,3,1,5,4,1,3,1,3,0.0,3,0),
    (488,'Theodor',86,'Humanoid',13,'Humanoid',40,90,110,3,3,2,3,2,2,3,1,3,1,3,0.0,3,0),
    (489,'Darrcuiln',0,'undefined',6,'Beast',60,111,120,1,1,4,2,3,6,5,1,3,1,3,5.0,256,0),
    (490,'Plovid',187,'Plovid',1,'Amorph',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,3,0),
    (491,'Morimar',86,'Humanoid',13,'Humanoid',40,90,110,3,3,2,3,2,2,3,1,3,1,3,0.0,3,0),
    (492,'Defiant-Balamor',188,'Defiant',9,'Demon',40,90,140,6,3,3,3,1,5,4,1,3,1,3,0.0,6,0),
    (493,'Macuil',189,'Macuil',11,'Elemental',40,90,140,6,3,3,3,1,5,4,1,3,1,3,0.0,3,0),
-- 494 Free
    (495,'Astral_Flow_Pet',0,'Astral_Flow_Pet',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,2,0),
-- 496 Free
    (497,'Cloud_of_Darkness',78,'Supreme_Being',0,'Unclassified',40,120,140,1,1,1,1,1,1,1,1,1,1,1,0.0,3,0),
-- 498 Free
    (499,'Wanderer-Stray',145,'Wanderer',12,'Empty',40,20,90,1,3,5,5,6,6,5,1,3,1,3,0.0,2,0),
    (500,'Golem-Mokkurkalfi',79,'Golem',3,'Arcana',40,130,130,2,3,3,5,3,6,5,1,2,1,3,7.0,34,0),
-- 501 Free
-- 502 Free
    (503,'Mammet',86,'Humanoid',3,'Arcana',40,90,110,3,3,2,3,2,2,3,1,3,1,3,0.0,2,0),
    (504,'Luopan',0,'undefined',0,'Unclassified',40,150,120,1,3,4,3,3,3,4,1,5,1,3,0.0,2,0),
    (505,'Fungi',0,'undefined',0,'Unclassified',0,130,180,1,3,4,3,6,6,5,1,3,1,3,4.0,2,0),
    (506,'Meeble',190,'Meeble',7,'Beastmen',40,125,90,3,2,5,2,6,4,5,1,2,1,3,5.0,1,0),
    (507,'Quasilumin',15,'Luminian',0,'Unclassified',25,100,100,5,5,5,5,5,5,5,5,5,5,5,0.0,2,0),

    (411,'Pet-Siren',16,'Siren',5,'Avatar',40,100,120,3,3,3,3,3,3,3,1,3,1,3,0.0,41,0)

-- Family IDs 10,22,50,96,317-318,405,412-434,439-443 available for use
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `family` = IF(`family` <> VALUES(`family`), VALUES(`family`), `family`),
    `superFamilyID` = IF(`superFamilyID` <> VALUES(`superFamilyID`), VALUES(`superFamilyID`), `superFamilyID`),
    `superFamily` = IF(`superFamily` <> VALUES(`superFamily`), VALUES(`superFamily`), `superFamily`),
    `ecosystemID` = IF(`ecosystemID` <> VALUES(`ecosystemID`), VALUES(`ecosystemID`), `ecosystemID`),
    `ecosystem` = IF(`ecosystem` <> VALUES(`ecosystem`), VALUES(`ecosystem`), `ecosystem`),
    `speed` = IF(`speed` <> VALUES(`speed`), VALUES(`speed`), `speed`),
    `HP` = IF(`HP` <> VALUES(`HP`), VALUES(`HP`), `HP`),
    `MP` = IF(`MP` <> VALUES(`MP`), VALUES(`MP`), `MP`),
    `STR` = IF(`STR` <> VALUES(`STR`), VALUES(`STR`), `STR`),
    `DEX` = IF(`DEX` <> VALUES(`DEX`), VALUES(`DEX`), `DEX`),
    `VIT` = IF(`VIT` <> VALUES(`VIT`), VALUES(`VIT`), `VIT`),
    `AGI` = IF(`AGI` <> VALUES(`AGI`), VALUES(`AGI`), `AGI`),
    `INT` = IF(`INT` <> VALUES(`INT`), VALUES(`INT`), `INT`),
    `MND` = IF(`MND` <> VALUES(`MND`), VALUES(`MND`), `MND`),
    `CHR` = IF(`CHR` <> VALUES(`CHR`), VALUES(`CHR`), `CHR`),
    `ATT` = IF(`ATT` <> VALUES(`ATT`), VALUES(`ATT`), `ATT`),
    `DEF` = IF(`DEF` <> VALUES(`DEF`), VALUES(`DEF`), `DEF`),
    `ACC` = IF(`ACC` <> VALUES(`ACC`), VALUES(`ACC`), `ACC`),
    `EVA` = IF(`EVA` <> VALUES(`EVA`), VALUES(`EVA`), `EVA`),
    `Element` = IF(`Element` <> VALUES(`Element`), VALUES(`Element`), `Element`),
    `detects` = IF(`detects` <> VALUES(`detects`), VALUES(`detects`), `detects`),
    `charmable` = IF(`charmable` <> VALUES(`charmable`), VALUES(`charmable`), `charmable`)
;

/*!40000 ALTER TABLE `mob_family_system` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
