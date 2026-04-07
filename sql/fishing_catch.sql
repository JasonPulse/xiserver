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
-- Table structure for table `fishing_catch`
--

DROP TABLE IF EXISTS `fishing_catch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fishing_catch` (
  `zoneid` smallint(5) unsigned NOT NULL,
  `areaid` tinyint(3) unsigned NOT NULL,
  `groupid` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`zoneid`,`areaid`,`groupid`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=27;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fishing_catch`
--

LOCK TABLES `fishing_catch` WRITE;
/*!40000 ALTER TABLE `fishing_catch` DISABLE KEYS */;

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

insert into `fishing_catch`
(
    `zoneid`, `areaid`, `groupid`
)
VALUES
    (1,1,139),     -- Phanauet Channel, Whole Zone
    (2,1,28),      -- Carpenters' Landing, South Landing
    (2,2,29),      -- Carpenters' Landing, Other Waterside South
    (2,3,29),      -- Carpenters' Landing, Other Waterside Center
    (2,4,29),      -- Carpenters' Landing, Other Waterside North
    (2,5,30),      -- Carpenters' Landing, Central Landing
    (2,6,28),      -- Carpenters' Landing, North Landing
    (3,1,68),      -- Manaclipper, Dhalmel Rock
    (4,1,61),      -- Bibiki Bay, PI - South Beach
    (4,2,62),      -- Bibiki Bay, PI - North Beach
    (4,3,63),      -- Bibiki Bay, PI - West Beach
    (4,4,63),      -- Bibiki Bay, PI - East Beach
    (4,5,64),      -- Bibiki Bay, BB - South Seaside
    (4,6,65),      -- Bibiki Bay, BB - Other Seaside
    (11,1,119),    -- Oldton Movalpolos, Whole Zone
    (24,1,120),    -- Lufaise Meadows, Leremieu Lagoon
    (24,2,121),    -- Lufaise Meadows, Seaside
    (24,3,122),    -- Lufaise Meadows, Rafeloux River
    (25,1,123),    -- Misareaux Coast, Cascade Edellaine
    (25,2,121),    -- Misareaux Coast, Seaside
    (25,3,122),    -- Misareaux Coast, Rafeloux River
    (26,1,40),     -- Tavnazian Safehold, Whole Zone
    (27,1,72),     -- Phomiuna Aqueducts, Whole Zone
    (46,1,135),    -- Open sea route to Al Zahbi, Whole Zone
    (47,1,135),    -- Open sea route to Mhaura, Whole Zone
    (48,1,125),    -- Al Zahbi, Whole Zone
    (50,1,124),    -- Aht Urhgan Whitegate, Whole Zone
    (51,1,129),    -- Wajaom Woodlands, Whole Zone
    (52,1,126),    -- Bhaflau Thickets, Whole Zone
    (53,1,133),    -- Nashmau, Whole Zone
    (54,1,131),    -- Arrapago Reef, Whole Zone
    (57,1,134),    -- Talacca Cove, Whole Zone
    (58,1,138),    -- Silver Sea route to Nashmau, Whole Zone
    (59,1,138),    -- Silver Sea route to Al Zahbi, Whole Zone
    (61,1,130),    -- Mount Zhayolm, Whole Zone
    (65,1,128),    -- Mamook, Pond
    (65,2,40),     -- Mamook, Other Waterside
    (68,1,127),    -- Aydeewa Subterrane, Whole Zone
    (79,1,132),    -- Caedarva Mire, Whole Zone
    (100,1,17),    -- West Ronfaure, Knightwell
    (101,1,16),    -- East Ronfaure, Whole Zone
    (102,1,23),    -- La Theine Plateau, Whole Zone
    (103,1,26),    -- Valkurm Dunes, Whole Zone
    (104,1,35),    -- Jugner Forest, Crystalwater Spring
    (104,2,36),    -- Jugner Forest, Lake Mechieume - Mouth
    (104,3,37),    -- Jugner Forest, Lake Mechieume - Main
    (104,4,38),    -- Jugner Forest, Maidens Spring
    (104,5,39),    -- Jugner Forest, River
    (105,1,27),    -- Batallia Downs, North Seaside
    (105,2,27),    -- Batallia Downs, South Seaside
    (106,1,43),    -- North Gustaberg, Basin of Waterfall
    (106,2,44),    -- North Gustaberg, River
    (107,1,46),    -- South Gustaberg, Hot Springs
    (107,2,47),    -- South Gustaberg, Seaside
    (109,1,50),    -- Pashhow Marshlands, Whole Zone
    (110,1,51),    -- Rolanberry Fields, Small Fountain 1
    (110,2,52),    -- Rolanberry Fields, Fountain of Promises
    (110,3,53),    -- Rolanberry Fields, Fountain of Partings
    (110,4,54),    -- Rolanberry Fields, Small Fountain 2
    (111,1,74),    -- Beaucedine Glacier, Seaside
    (111,2,75),    -- Beaucedine Glacier, Ponds
    (113,1,92),    -- Cape Teriggan, Whole Zone
    (114,1,87),    -- Eastern Altepa Desert, Whole Zone
    (115,1,59),    -- West Sarutabaruta, Pond
    (115,2,60),    -- West Sarutabaruta, Seaside
    (116,1,2),     -- East Sarutabaruta, Seaside
    (116,2,3),     -- East Sarutabaruta, Other Waterside (south)
    (116,3,3),     -- East Sarutabaruta, Other Waterside (west)
    (116,4,3),     -- East Sarutabaruta, Other Waterside (rivers)
    (116,5,1),     -- East Sarutabaruta, Lake Tepokalipuka
    (118,1,66),    -- Buburimu Peninsula, Whole Zone
    (120,1,73),    -- Sauromugue Champaign, Whole Zone
    (121,1,86),    -- The Sanctuary of Zi'Tah, Whole Zone
    (122,1,85),    -- Ro'Maeve, Whole Zone
    (123,1,101),   -- Yuhtunga Jungle, Northeast Pond
    (123,2,102),   -- Yuhtunga Jungle, Gremini Falls
    (123,3,103),   -- Yuhtunga Jungle, Southwest Pond
    (123,4,104),   -- Yuhtunga Jungle, Southwest Waterfall - South
    (123,5,105),   -- Yuhtunga Jungle, Southwest Waterfall - North
    (123,6,106),   -- Yuhtunga Jungle, Other Waterside
    (124,1,111),   -- Yhoator Jungle, Front of Temple - East Side
    (124,2,112),   -- Yhoator Jungle, Front of Temple - West Side
    (124,3,113),   -- Yhoator Jungle, Teardrop Spring
    (124,4,114),   -- Yhoator Jungle, Underground Pool 1
    (124,5,115),   -- Yhoator Jungle, Bloodlet Spring
    (124,6,116),   -- Yhoator Jungle, Underground Pool 3
    (124,7,117),   -- Yhoator Jungle, Underground Pool 2
    (125,1,90),    -- Western Altepa Desert, Oasis of Hubol
    (125,2,91),    -- Western Altepa Desert, Central Spring
    (126,1,78),    -- Qufim Island, Northwest Seaside
    (126,2,79),    -- Qufim Island, Southwest Seaside
    (126,3,80),    -- Qufim Island, Other Seaside
    (130,1,118),   -- Ru'Aun Gardens, Whole Zone
    (140,1,18),    -- Ghelsba Outpost, Pond North
    (140,2,18),    -- Ghelsba Outpost, Pond South
    (140,3,19),    -- Ghelsba Outpost, River
    (142,1,20),    -- Yughott Grotto, Whole Zone
    (143,1,45),    -- Palborough Mines, Whole Zone
    (145,1,55),    -- Giddeus, Giddeus Spring
    (145,2,56),    -- Giddeus, Pond - West
    (145,3,57),    -- Giddeus, Pond - North
    (145,4,58),    -- Giddeus, Misc Puddles
    (149,1,31),    -- Davoi, Basin of a Waterfall
    (149,2,32),    -- Davoi, Wailing Pond
    (149,3,33),    -- Davoi, Pond
    (149,4,34),    -- Davoi, Other Waterside
    (151,1,0),     -- Castle Oztroja, PLD AF Fishing Spot
    (151,2,72),    -- Castle Oztroja, Whole Zone
    (153,1,81),    -- The Boyahda Tree, Waterfall Basin
    (153,2,82),    -- The Boyahda Tree, Waterfall Basin - Hidden
    (153,3,83),    -- The Boyahda Tree, Other Waterside
    (154,1,84),    -- Dragon's Aery, Whole Zone
    (157,1,77),    -- Middle Delkfutt's Tower, Whole Zone
    (158,1,77),    -- Upper Delkfutt's Tower, Whole Zone
    (159,1,110),   -- Temple of Uggalepih, Whole Zone
    (160,1,107),   -- Den of Rancor, Pool E-8
    (160,2,108),   -- Den of Rancor, Pool F-11
    (160,3,109),   -- Den of Rancor, Misc Water
    (166,1,72),    -- Ranguemont Pass, Whole Zone
    (167,1,15),    -- Bostaunieux Oubliette, Whole Zone
    (172,1,48),    -- Zeruhn Mines, River
    (172,2,49),    -- Zeruhn Mines, Pool
    (173,1,41),    -- Korroloka Tunnel, Salt Water
    (173,2,42),    -- Korroloka Tunnel, Fresh Water
    (174,1,93),    -- Kuftal Tunnel, Whole Zone
    (176,1,96),    -- Sea Serpent Grotto, Other Seaside
    (176,2,97),    -- Sea Serpent Grotto, Pond Under a Bridge
    (176,3,98),    -- Sea Serpent Grotto, Interior of Hidden Door - Mythril
    (176,4,99),    -- Sea Serpent Grotto, Interior of Hidden Door - Gold
    (176,5,100),   -- Sea Serpent Grotto, Misc Puddles
    (178,1,118),   -- The Shrine of Ru'Avitau, Whole Zone
    (184,1,77),    -- Lower Delkfutt's Tower, Whole Zone
    (191,1,40),    -- Dangruf Wadi, Whole Zone
    (193,1,24),    -- Ordelle's Caves, Whole Zone
    (196,1,22),    -- Gusgen Mines, Pool Upper West
    (196,2,22),    -- Gusgen Mines, Pool Upper East
    (196,3,22),    -- Gusgen Mines, Pool Lower East
    (196,4,21),    -- Gusgen Mines, Interior Pool West
    (196,5,21),    -- Gusgen Mines, Interior Pool Center
    (196,6,21),    -- Gusgen Mines, Interior Pool East
    (204,1,76),    -- Fei'Yin, Whole Zone
    (208,1,88),    -- Quicksand Caves, Whole Zone
    (213,1,67),    -- Labyrinth of Onzozo, Whole Zone
    (220,1,136),   -- Ship bound for Selbina, Whole Zone
    (221,1,136),   -- Ship bound for Mhaura, Whole Zone
    (227,1,137),   -- Ship bound for Selbina (with Pirates), Whole Zone
    (228,1,137),   -- Ship bound for Mhaura (with Pirates), Whole Zone
    (231,1,9),     -- Northern San d'Oria, Whole Zone
    (232,1,10),    -- Port San d'Oria, Whole Zone
    (234,1,8),     -- Bastok Mines, Whole Zone
    (235,1,5),     -- Bastok Markets, North Side
    (235,2,6),     -- Bastok Markets, South Side
    (236,1,7),     -- Port Bastok, Whole Zone
    (238,1,11),    -- Windurst Waters, Whole Zone
    (239,1,11),    -- Windurst Walls, Whole Zone
    (240,1,4),     -- Port Windurst, Whole Zone
    (241,1,11),    -- Windurst Woods, Whole Zone
    (242,1,12),    -- Heavens Tower, Whole Zone
    (245,1,13),    -- Lower Jeuno, Whole Zone
    (246,1,14),    -- Port Jeuno, Whole Zone
    (247,1,89),    -- Rabao, Whole Zone
    (248,1,25),    -- Selbina, Whole Zone
    (249,1,71),    -- Mhaura, Whole Zone
    (250,1,94),    -- Kazham, Whole Zone
    (252,1,95)    -- Norg, Whole Zone
;

/*!40000 ALTER TABLE `fishing_catch` ENABLE KEYS */;
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
