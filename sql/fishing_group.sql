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
-- Table structure for table `fishing_group`
--

DROP TABLE IF EXISTS `fishing_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fishing_group` (
  `groupid` int(10) unsigned NOT NULL,
  `fishid` int(10) unsigned NOT NULL,
  `rarity` smallint(5) unsigned NOT NULL DEFAULT '0',
  `pool_size` smallint(5) unsigned NOT NULL DEFAULT '0',
  `restock_rate` smallint(5) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`groupid`,`fishid`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fishing_group`
--

LOCK TABLES `fishing_group` WRITE;
/*!40000 ALTER TABLE `fishing_group` DISABLE KEYS */;

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

insert into `fishing_group`
(
    `groupid`, `fishid`, `rarity`, `pool_size`, `restock_rate`
)
VALUES
-- East Sarutabaruta, Lake Tepokalipuka
    (1,90,900,300,9),       -- Rusty Bucket
    (1,4401,1000,1000,36),  -- Moat Carp
    (1,4462,550,160,5),     -- Monke Onke
    (1,4464,1000,500,15),   -- Pipira
    (1,4472,1000,500,15),   -- Crayfish
    (1,4473,450,245,5),     -- Crescent Fish
    (1,14117,500,300,9),    -- Rusty Leggings
    (1,14242,500,300,9),    -- Rusty Subligar

-- East Sarutabaruta, Seaside
    (2,90,900,300,9),       -- Rusty Bucket
    (2,624,1000,300,9),     -- Clump Of Pamtam Kelp
    (2,4360,1000,500,15),   -- Bastore Sardine
    (2,4383,800,290,7),     -- Gold Lobster
    (2,4399,650,275,6),     -- Bluetail
    (2,4461,250,230,6),     -- Bastore Bream
    (2,4471,750,145,4),     -- Bladefish
    (2,4481,1000,500,15),   -- Ogre Eel
    (2,4514,1000,500,15),   -- Quus
    (2,14117,500,300,9),    -- Rusty Leggings
    (2,14242,500,300,9),    -- Rusty Subligar

-- East Sarutabaruta, Other Waterside (south) / East Sarutabaruta, Other Waterside (west) / East Sarutabaruta, Other Waterside (rivers)
    (3,4472,1000,500,15),   -- Crayfish
    (3,14242,500,300,9),    -- Rusty Subligar

-- Port Windurst, Whole Zone
    (4,591,1000,300,9),     -- Ripped Cap
    (4,624,1000,300,9),     -- Clump Of Pamtam Kelp
    (4,4360,1000,500,15),   -- Bastore Sardine
    (4,4461,250,230,6),     -- Bastore Bream
    (4,4514,1000,500,15),   -- Quus
    (4,14117,500,300,9),    -- Rusty Leggings
    (4,14242,500,300,9),    -- Rusty Subligar
    (4,65535,1000,300,9),   -- Gil

-- Bastok Markets, North Side
    (5,90,900,300,9),       -- Rusty Bucket
    (5,4401,1000,1000,36),  -- Moat Carp
    (5,4426,1000,500,15),   -- Tricolored Carp
    (5,4427,750,275,6),     -- Gold Carp
    (5,4429,800,290,7),     -- Black Eel
    (5,4472,1000,500,15),   -- Crayfish
    (5,13454,800,300,9),    -- Copper Ring
    (5,14117,500,300,9),    -- Rusty Leggings
    (5,14242,500,300,9),    -- Rusty Subligar

-- Bastok Markets, South Side
    (6,90,900,300,9),       -- Rusty Bucket
    (6,4401,1000,1000,36),  -- Moat Carp
    (6,4428,1000,500,15),   -- Dark Bass
    (6,4429,800,290,7),     -- Black Eel
    (6,4469,900,190,6),     -- Giant Catfish
    (6,13454,800,300,9),    -- Copper Ring
    (6,14117,500,300,9),    -- Rusty Leggings
    (6,14242,500,300,9),    -- Rusty Subligar

-- Port Bastok, Whole Zone
    (7,90,900,300,9),       -- Rusty Bucket
    (7,4360,1000,500,15),   -- Bastore Sardine
    (7,4385,1000,500,15),   -- Zafmlug Bass
    (7,4443,1000,500,15),   -- Cobalt Jellyfish
    (7,4461,250,230,6),     -- Bastore Bream
    (7,4514,1000,500,15),   -- Quus
    (7,14117,500,300,9),    -- Rusty Leggings
    (7,14242,500,300,9),    -- Rusty Subligar

-- Bastok Mines, Whole Zone
    (8,90,900,300,9),       -- Rusty Bucket
    (8,4472,1000,500,15),   -- Crayfish
    (8,4515,1000,500,15),   -- Copper Frog
    (8,13454,800,300,9),    -- Copper Ring
    (8,14117,500,300,9),    -- Rusty Leggings
    (8,14242,500,300,9),    -- Rusty Subligar

-- Northern San d'Oria, Whole Zone
    (9,4401,1000,1000,36),  -- Moat Carp
    (9,4426,1000,500,15),   -- Tricolored Carp
    (9,4427,750,275,6),     -- Gold Carp
    (9,4472,1000,500,15),   -- Crayfish
    (9,13454,800,300,9),    -- Copper Ring
    (9,14117,500,300,9),    -- Rusty Leggings
    (9,14242,500,300,9),    -- Rusty Subligar

-- Port San d'Oria, Whole Zone
    (10,90,900,300,9),      -- Rusty Bucket
    (10,4401,1000,1000,36), -- Moat Carp
    (10,4426,1000,500,15),  -- Tricolored Carp
    (10,4427,750,275,6),    -- Gold Carp
    (10,4469,900,190,6),    -- Giant Catfish
    (10,4472,1000,500,15),  -- Crayfish
    (10,14117,500,300,9),   -- Rusty Leggings
    (10,14242,500,300,9),   -- Rusty Subligar

-- Windurst Waters, Whole Zone / Windurst Walls, Whole Zone / Windurst Woods, Whole Zone
    (11,90,900,300,9),      -- Rusty Bucket
    (11,4401,1000,1000,36), -- Moat Carp
    (11,4427,750,275,6),    -- Gold Carp
    (11,4464,1000,500,15),  -- Pipira
    (11,4472,1000,500,15),  -- Crayfish
    (11,14117,500,300,9),   -- Rusty Leggings
    (11,14242,500,300,9),   -- Rusty Subligar

-- Heavens Tower, Whole Zone
    (12,13454,800,300,9),   -- Copper Ring
    (12,13456,300,275,6),   -- Silver Ring
    (12,14242,500,300,9),   -- Rusty Subligar

-- Lower Jeuno, Whole Zone
    (13,90,900,300,9),      -- Rusty Bucket
    (13,4360,1000,500,15),  -- Bastore Sardine
    (13,4384,750,215,6),    -- Black Sole
    (13,4403,1000,500,15),  -- Yellow Globe
    (13,4443,1000,500,15),  -- Cobalt Jellyfish
    (13,4482,950,500,15),   -- Nosteau Herring
    (13,4483,1000,500,15),  -- Tiger Cod
    (13,13454,800,300,9),   -- Copper Ring
    (13,14117,500,300,9),   -- Rusty Leggings
    (13,14242,500,300,9),   -- Rusty Subligar

-- Port Jeuno, Whole Zone
    (14,90,900,300,9),      -- Rusty Bucket
    (14,4360,1000,500,15),  -- Bastore Sardine
    (14,4384,750,215,6),    -- Black Sole
    (14,4403,1000,500,15),  -- Yellow Globe
    (14,4443,1000,500,15),  -- Cobalt Jellyfish
    (14,4482,950,500,15),   -- Nosteau Herring
    (14,4483,1000,500,15),  -- Tiger Cod
    (14,13454,800,300,9),   -- Copper Ring
    (14,13456,300,275,6),   -- Silver Ring
    (14,14117,500,300,9),   -- Rusty Leggings
    (14,14242,500,300,9),   -- Rusty Subligar
    (14,16451,80,10,2),     -- Mythril Dagger

-- Bostaunieux Oubliette, Whole Zone
    (15,4472,1000,500,15),  -- Crayfish
    (15,13454,800,300,9),   -- Copper Ring
    (15,14117,500,300,9),   -- Rusty Leggings
    (15,14242,500,300,9),   -- Rusty Subligar
    (15,16537,60,10,2)     -- Mythril Sword
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `rarity` = IF(`rarity` <> VALUES(`rarity`), VALUES(`rarity`), `rarity`),
    `pool_size` = IF(`pool_size` <> VALUES(`pool_size`), VALUES(`pool_size`), `pool_size`),
    `restock_rate` = IF(`restock_rate` <> VALUES(`restock_rate`), VALUES(`restock_rate`), `restock_rate`)
;

insert into `fishing_group`
(
    `groupid`, `fishid`, `rarity`, `pool_size`, `restock_rate`
)
VALUES
-- East Ronfaure, Whole Zone
    (16,688,500,200,6),     -- Arrowwood Log
    (16,4354,1000,500,15),  -- Shining Trout
    (16,4379,1000,500,15),  -- Cheval Salmon
    (16,4426,1000,500,15),  -- Tricolored Carp
    (16,4427,750,275,6),    -- Gold Carp
    (16,4472,1000,500,15),  -- Crayfish
    (16,13454,800,300,9),   -- Copper Ring

-- West Ronfaure, Knightwell
    (17,90,900,300,9),      -- Rusty Bucket
    (17,688,500,200,6),     -- Arrowwood Log
    (17,4401,1000,1000,36), -- Moat Carp
    (17,4402,750,260,5),    -- Red Terrapin
    (17,4469,900,190,6),    -- Giant Catfish
    (17,4472,1000,500,15),  -- Crayfish
    (17,14117,500,300,9),   -- Rusty Leggings

-- Ghelsba Outpost, Pond North / Ghelsba Outpost, Pond South
    (18,4402,750,260,5),    -- Red Terrapin
    (18,4469,900,190,6),    -- Giant Catfish
    (18,4472,1000,500,15),  -- Crayfish

-- Ghelsba Outpost, River
    (19,4354,1000,500,15),  -- Shining Trout
    (19,4379,1000,500,15),  -- Cheval Salmon
    (19,4426,1000,500,15),  -- Tricolored Carp
    (19,4427,750,275,6),    -- Gold Carp
    (19,4472,1000,500,15),  -- Crayfish

-- Yughott Grotto, Whole Zone
    (20,4472,1000,500,15),  -- Crayfish
    (20,12522,200,10,1),    -- Rusty Cap
    (20,13456,300,275,6),   -- Silver Ring
    (20,14117,500,300,9),   -- Rusty Leggings
    (20,16655,400,290,7),   -- Rusty Pick

-- Gusgen Mines, Interior Pool West / Gusgen Mines, Interior Pool Center / Gusgen Mines, Interior Pool East
    (21,90,900,300,9),      -- Rusty Bucket
    (21,4426,1000,500,15),  -- Tricolored Carp
    (21,4427,750,275,6),    -- Gold Carp
    (21,4429,800,290,7),    -- Black Eel
    (21,4472,1000,500,15),  -- Crayfish
    (21,4477,550,145,4),    -- Gavial Fish
    (21,4515,1000,500,15),  -- Copper Frog
    (21,14117,500,300,9),   -- Rusty Leggings
    (21,14242,500,300,9),   -- Rusty Subligar
    (21,16537,60,10,2),     -- Mythril Sword
    (21,16655,400,290,7),   -- Rusty Pick

-- Gusgen Mines, Pool Upper West / Gusgen Mines, Pool Upper East / Gusgen Mines, Pool Lower East
    (22,90,900,300,9),      -- Rusty Bucket
    (22,4426,1000,500,15),  -- Tricolored Carp
    (22,4429,800,290,7),    -- Black Eel
    (22,4472,1000,500,15),  -- Crayfish
    (22,4515,1000,500,15),  -- Copper Frog
    (22,14242,500,300,9),   -- Rusty Subligar
    (22,16537,60,10,2),     -- Mythril Sword
    (22,16655,400,290,7),   -- Rusty Pick

-- La Theine Plateau, Whole Zone
    (23,90,900,300,9),      -- Rusty Bucket
    (23,4401,1000,1000,36), -- Moat Carp
    (23,4402,750,260,5),    -- Red Terrapin
    (23,4428,1000,500,15),  -- Dark Bass
    (23,4469,900,190,6),    -- Giant Catfish
    (23,4472,1000,500,15),  -- Crayfish
    (23,12522,200,10,1),    -- Rusty Cap

-- Ordelle's Caves, Whole Zone
    (24,90,900,300,9),      -- Rusty Bucket
    (24,4472,1000,500,15),  -- Crayfish
    (24,12522,200,10,1),    -- Rusty Cap
    (24,13456,300,275,6),   -- Silver Ring
    (24,14117,500,300,9),   -- Rusty Leggings
    (24,14242,500,300,9),   -- Rusty Subligar

-- Selbina, Whole Zone
    (25,90,900,300,9),      -- Rusty Bucket
    (25,4360,1000,500,15),  -- Bastore Sardine
    (25,4385,1000,500,15),  -- Zafmlug Bass
    (25,4443,1000,500,15),  -- Cobalt Jellyfish
    (25,4500,1000,500,15),  -- Greedie
    (25,4501,1000,500,15),  -- Fat Greedie
    (25,4514,1000,500,15),  -- Quus
    (25,14117,500,300,9),   -- Rusty Leggings
    (25,14242,500,300,9),   -- Rusty Subligar

-- Valkurm Dunes, Whole Zone
    (26,90,900,300,9),      -- Rusty Bucket
    (26,688,500,200,6),     -- Arrowwood Log
    (26,4360,1000,500,15),  -- Bastore Sardine
    (26,4385,1000,500,15),  -- Zafmlug Bass
    (26,4443,1000,500,15),  -- Cobalt Jellyfish
    (26,4484,600,275,6),    -- Shall Shell
    (26,4500,1000,500,15),  -- Greedie
    (26,4514,1000,500,15),  -- Quus
    (26,12522,200,10,1),    -- Rusty Cap
    (26,13456,300,275,6),   -- Silver Ring
    (26,14117,500,300,9),   -- Rusty Leggings
    (26,14242,500,300,9),   -- Rusty Subligar

-- Batallia Downs, North Seaside / Batallia Downs, South Seaside
    (27,4360,1000,500,15),  -- Bastore Sardine
    (27,4384,750,215,6),    -- Black Sole
    (27,4399,650,275,6),    -- Bluetail
    (27,4403,1000,500,15),  -- Yellow Globe
    (27,4443,1000,500,15),  -- Cobalt Jellyfish
    (27,4451,500,245,5),    -- Silver Shark
    (27,4482,950,500,15),   -- Nosteau Herring
    (27,4483,1000,500,15),  -- Tiger Cod
    (27,5128,850,290,7),    -- Cone Calamary
    (27,13456,300,275,6),   -- Silver Ring
    (27,16537,60,10,2),     -- Mythril Sword
    (27,16606,400,300,9),   -- Rusty Greatsword
    (27,16655,400,290,7),   -- Rusty Pick

-- Carpenters' Landing, South Landing / Carpenters' Landing, North Landing
    (28,90,900,300,9),      -- Rusty Bucket
    (28,688,500,200,6),     -- Arrowwood Log
    (28,4354,1000,500,15),  -- Shining Trout
    (28,4428,1000,500,15),  -- Dark Bass
    (28,4472,1000,500,15),  -- Crayfish
    (28,5126,1000,500,15),  -- Muddy Siredont
    (28,14117,500,300,9),   -- Rusty Leggings

-- Carpenters' Landing, Other Waterside South / Carpenters' Landing, Other Waterside Center / Carpenters' Landing, Other Waterside North
    (29,688,500,200,6),     -- Arrowwood Log
    (29,4428,1000,500,15),  -- Dark Bass
    (29,4469,900,190,6),    -- Giant Catfish
    (29,4472,1000,500,15),  -- Crayfish
    (29,5125,1000,500,15),  -- Phanauet Newt
    (29,5126,1000,500,15),  -- Muddy Siredont

-- Carpenters' Landing, Central Landing
    (30,90,900,300,9),      -- Rusty Bucket
    (30,688,500,200,6),     -- Arrowwood Log
    (30,4428,1000,500,15),  -- Dark Bass
    (30,4472,1000,500,15),  -- Crayfish
    (30,5126,1000,500,15),  -- Muddy Siredont

-- Davoi, Basin of a Waterfall
    (31,90,900,300,9),      -- Rusty Bucket
    (31,688,500,200,6),     -- Arrowwood Log
    (31,4402,750,260,5),    -- Red Terrapin
    (31,4426,1000,500,15),  -- Tricolored Carp
    (31,4427,750,275,6),    -- Gold Carp
    (31,4463,500,50,6),     -- Takitaro
    (31,4472,1000,500,15),  -- Crayfish
    (31,12522,200,10,1),    -- Rusty Cap
    (31,16655,400,290,7),   -- Rusty Pick

-- Davoi, Wailing Pond
    (32,90,900,300,9),      -- Rusty Bucket
    (32,12522,200,10,1),    -- Rusty Cap
    (32,14117,500,300,9),   -- Rusty Leggings
    (32,16606,400,300,9),   -- Rusty Greatsword
    (32,16655,400,290,7),   -- Rusty Pick

-- Davoi, Pond
    (33,90,900,300,9),      -- Rusty Bucket
    (33,688,500,200,6),     -- Arrowwood Log
    (33,4401,1000,1000,36), -- Moat Carp
    (33,4402,750,260,5),    -- Red Terrapin
    (33,4428,1000,500,15),  -- Dark Bass
    (33,4469,900,190,6),    -- Giant Catfish
    (33,4472,1000,500,15),  -- Crayfish
    (33,12522,200,10,1),    -- Rusty Cap
    (33,14117,500,300,9),   -- Rusty Leggings
    (33,16655,400,290,7),   -- Rusty Pick

-- Davoi, Other Waterside
    (34,90,900,300,9),      -- Rusty Bucket
    (34,4402,750,260,5),    -- Red Terrapin
    (34,4472,1000,500,15),  -- Crayfish
    (34,14117,500,300,9)   -- Rusty Leggings
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `rarity` = IF(`rarity` <> VALUES(`rarity`), VALUES(`rarity`), `rarity`),
    `pool_size` = IF(`pool_size` <> VALUES(`pool_size`), VALUES(`pool_size`), `pool_size`),
    `restock_rate` = IF(`restock_rate` <> VALUES(`restock_rate`), VALUES(`restock_rate`), `restock_rate`)
;

insert into `fishing_group`
(
    `groupid`, `fishid`, `rarity`, `pool_size`, `restock_rate`
)
VALUES
-- Jugner Forest, Crystalwater Spring
    (35,688,500,200,6),     -- Arrowwood Log
    (35,4402,750,260,5),    -- Red Terrapin
    (35,4472,1000,500,15),  -- Crayfish
    (35,4528,1000,500,15),  -- Crystal Bass
    (35,13456,300,275,6),   -- Silver Ring
    (35,14117,500,300,9),   -- Rusty Leggings
    (35,14242,500,300,9),   -- Rusty Subligar
    (35,16655,400,290,7),   -- Rusty Pick

-- Jugner Forest, Lake Mechieume - Mouth
    (36,90,900,300,9),      -- Rusty Bucket
    (36,688,500,200,6),     -- Arrowwood Log
    (36,4401,1000,1000,36), -- Moat Carp
    (36,4426,1000,500,15),  -- Tricolored Carp
    (36,4427,750,275,6),    -- Gold Carp
    (36,4428,1000,500,15),  -- Dark Bass
    (36,4454,200,115,3),    -- Emperor Fish
    (36,4472,1000,500,15),  -- Crayfish
    (36,12522,200,10,1),    -- Rusty Cap
    (36,13456,300,275,6),   -- Silver Ring
    (36,14117,500,300,9),   -- Rusty Leggings

-- Jugner Forest, Lake Mechieume - Main
    (37,90,900,300,9),      -- Rusty Bucket
    (37,688,500,200,6),     -- Arrowwood Log
    (37,4401,1000,1000,36), -- Moat Carp
    (37,4402,750,260,5),    -- Red Terrapin
    (37,4426,1000,500,15),  -- Tricolored Carp
    (37,4427,750,275,6),    -- Gold Carp
    (37,4428,1000,500,15),  -- Dark Bass
    (37,4469,900,190,6),    -- Giant Catfish
    (37,4472,1000,500,15),  -- Crayfish
    (37,12522,200,10,1),    -- Rusty Cap
    (37,13456,300,275,6),   -- Silver Ring
    (37,14117,500,300,9),   -- Rusty Leggings

-- Jugner Forest, Maidens Spring
    (38,688,500,200,6),     -- Arrowwood Log
    (38,4402,750,260,5),    -- Red Terrapin
    (38,4472,1000,500,15),  -- Crayfish
    (38,13456,300,275,6),   -- Silver Ring
    (38,14117,500,300,9),   -- Rusty Leggings
    (38,14242,500,300,9),   -- Rusty Subligar
    (38,16655,400,290,7),   -- Rusty Pick

-- Jugner Forest, River
    (39,90,900,300,9),      -- Rusty Bucket
    (39,688,500,200,6),     -- Arrowwood Log
    (39,4354,1000,500,15),  -- Shining Trout
    (39,4379,1000,500,15),  -- Cheval Salmon
    (39,4401,1000,1000,36), -- Moat Carp
    (39,4426,1000,500,15),  -- Tricolored Carp
    (39,4427,750,275,6),    -- Gold Carp
    (39,4472,1000,500,15),  -- Crayfish
    (39,14117,500,300,9),   -- Rusty Leggings

-- Tavnazian Safehold, Whole Zone / Mamook, Other Waterside / Dangruf Wadi, Whole Zone
    (40,90,900,300,9),      -- Rusty Bucket
    (40,4472,1000,500,15),  -- Crayfish

-- Korroloka Tunnel, Salt Water
    (41,90,900,300,9),      -- Rusty Bucket
    (41,887,200,50,6),      -- Coral Fragment
    (41,4291,1000,500,15),  -- Sandfish
    (41,4401,1000,1000,36), -- Moat Carp
    (41,4429,800,290,7),    -- Black Eel
    (41,4472,1000,500,15),  -- Crayfish
    (41,4515,1000,500,15),  -- Copper Frog
    (41,12522,200,10,1),    -- Rusty Cap
    (41,14117,500,300,9),   -- Rusty Leggings
    (41,14242,500,300,9),   -- Rusty Subligar
    (41,16606,400,300,9),   -- Rusty Greatsword
    (41,16655,400,290,7),   -- Rusty Pick

-- Korroloka Tunnel, Fresh Water
    (42,90,900,300,9),      -- Rusty Bucket
    (42,887,200,50,6),      -- Coral Fragment
    (42,4514,1000,500,15),  -- Quus
    (42,12522,200,10,1),    -- Rusty Cap
    (42,14117,500,300,9),   -- Rusty Leggings
    (42,14242,500,300,9),   -- Rusty Subligar
    (42,16606,400,300,9),   -- Rusty Greatsword

-- North Gustaberg, Basin of Waterfall
    (43,90,900,300,9),      -- Rusty Bucket
    (43,4426,1000,500,15),  -- Tricolored Carp
    (43,4427,750,275,6),    -- Gold Carp
    (43,4429,800,290,7),    -- Black Eel
    (43,4472,1000,500,15),  -- Crayfish
    (43,4477,550,145,4),    -- Gavial Fish
    (43,4515,1000,500,15),  -- Copper Frog
    (43,14117,500,300,9),   -- Rusty Leggings
    (43,14242,500,300,9),   -- Rusty Subligar

-- North Gustaberg, River
    (44,90,900,300,9),      -- Rusty Bucket
    (44,4426,1000,500,15),  -- Tricolored Carp
    (44,4427,750,275,6),    -- Gold Carp
    (44,4429,800,290,7),    -- Black Eel
    (44,4472,1000,500,15),  -- Crayfish
    (44,4515,1000,500,15),  -- Copper Frog
    (44,14117,500,300,9),   -- Rusty Leggings
    (44,14242,500,300,9),   -- Rusty Subligar

-- Palborough Mines, Whole Zone
    (45,90,900,300,9),      -- Rusty Bucket
    (45,4426,1000,500,15),  -- Tricolored Carp
    (45,4429,800,290,7),    -- Black Eel
    (45,4472,1000,500,15),  -- Crayfish
    (45,4515,1000,500,15),  -- Copper Frog

-- South Gustaberg, Hot Springs
    (46,90,900,300,9),      -- Rusty Bucket
    (46,12522,200,10,1),    -- Rusty Cap
    (46,13456,300,275,6),   -- Silver Ring
    (46,14117,500,300,9),   -- Rusty Leggings
    (46,14242,500,300,9),   -- Rusty Subligar

-- South Gustaberg, Seaside
    (47,4360,1000,500,15),  -- Bastore Sardine
    (47,4383,800,290,7),    -- Gold Lobster
    (47,4385,1000,500,15),  -- Zafmlug Bass
    (47,4443,1000,500,15),  -- Cobalt Jellyfish
    (47,4461,250,230,6),    -- Bastore Bream
    (47,4471,750,145,4),    -- Bladefish
    (47,4481,1000,500,15),  -- Ogre Eel
    (47,4514,1000,500,15),  -- Quus
    (47,14117,500,300,9),   -- Rusty Leggings
    (47,14242,500,300,9),   -- Rusty Subligar

-- Zeruhn Mines, River
    (48,90,900,300,9),      -- Rusty Bucket
    (48,4401,1000,1000,36), -- Moat Carp
    (48,4426,1000,500,15),  -- Tricolored Carp
    (48,4429,800,290,7),    -- Black Eel
    (48,4469,900,190,6),    -- Giant Catfish
    (48,4472,1000,500,15),  -- Crayfish
    (48,4515,1000,500,15),  -- Copper Frog
    (48,14117,500,300,9),   -- Rusty Leggings
    (48,14242,500,300,9),   -- Rusty Subligar

-- Zeruhn Mines, Pool
    (49,90,900,300,9),      -- Rusty Bucket
    (49,4429,800,290,7),    -- Black Eel
    (49,4472,1000,500,15),  -- Crayfish
    (49,4515,1000,500,15),  -- Copper Frog
    (49,14117,500,300,9),   -- Rusty Leggings
    (49,14242,500,300,9),   -- Rusty Subligar

-- Pashhow Marshlands, Whole Zone
    (50,4402,750,260,5),    -- Red Terrapin
    (50,4469,900,190,6),    -- Giant Catfish
    (50,4472,1000,500,15),  -- Crayfish
    (50,4515,1000,500,15),  -- Copper Frog
    (50,12522,200,10,1),    -- Rusty Cap
    (50,13456,300,275,6),   -- Silver Ring
    (50,16655,400,290,7),   -- Rusty Pick

-- Rolanberry Fields, Small Fountain 1
    (51,90,900,300,9),      -- Rusty Bucket
    (51,4401,1000,1000,36), -- Moat Carp
    (51,4402,750,260,5),    -- Red Terrapin
    (51,4472,1000,500,15),  -- Crayfish
    (51,12522,200,10,1),    -- Rusty Cap
    (51,14117,500,300,9),   -- Rusty Leggings
    (51,14242,500,300,9),   -- Rusty Subligar
    (51,16655,400,290,7),   -- Rusty Pick

-- Rolanberry Fields, Fountain of Promises
    (52,90,900,300,9),      -- Rusty Bucket
    (52,4401,1000,1000,36), -- Moat Carp
    (52,4402,750,260,5),    -- Red Terrapin
    (52,4428,1000,500,15),  -- Dark Bass
    (52,4469,900,190,6),    -- Giant Catfish
    (52,4472,1000,500,15),  -- Crayfish
    (52,12316,500,260,5),   -- Fish Scale Shield
    (52,16537,60,10,2),     -- Mythril Sword

-- Rolanberry Fields, Fountain of Partings
    (53,90,900,300,9),      -- Rusty Bucket
    (53,4401,1000,1000,36), -- Moat Carp
    (53,4402,750,260,5),    -- Red Terrapin
    (53,4428,1000,500,15),  -- Dark Bass
    (53,4469,900,190,6),    -- Giant Catfish
    (53,4472,1000,500,15),  -- Crayfish

-- Rolanberry Fields, Small Fountain 2
    (54,90,900,300,9),      -- Rusty Bucket
    (54,4401,1000,1000,36), -- Moat Carp
    (54,4402,750,260,5),    -- Red Terrapin
    (54,4472,1000,500,15),  -- Crayfish
    (54,12522,200,10,1),    -- Rusty Cap
    (54,14117,500,300,9),   -- Rusty Leggings
    (54,14242,500,300,9),   -- Rusty Subligar
    (54,16655,400,290,7)   -- Rusty Pick
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `rarity` = IF(`rarity` <> VALUES(`rarity`), VALUES(`rarity`), `rarity`),
    `pool_size` = IF(`pool_size` <> VALUES(`pool_size`), VALUES(`pool_size`), `pool_size`),
    `restock_rate` = IF(`restock_rate` <> VALUES(`restock_rate`), VALUES(`restock_rate`), `restock_rate`)
;

insert into `fishing_group`
(
    `groupid`, `fishid`, `rarity`, `pool_size`, `restock_rate`
)
VALUES
-- Giddeus, Giddeus Spring
    (55,90,900,300,9),      -- Rusty Bucket
    (55,4426,1000,500,15),  -- Tricolored Carp
    (55,4428,1000,500,15),  -- Dark Bass
    (55,4462,550,160,5),    -- Monke Onke
    (55,4472,1000,500,15),  -- Crayfish
    (55,13456,300,275,6),   -- Silver Ring
    (55,14117,500,300,9),   -- Rusty Leggings

-- Giddeus, Pond - West
    (56,90,900,300,9),      -- Rusty Bucket
    (56,4426,1000,500,15),  -- Tricolored Carp
    (56,4428,1000,500,15),  -- Dark Bass
    (56,4472,1000,500,15),  -- Crayfish
    (56,13456,300,275,6),   -- Silver Ring
    (56,14117,500,300,9),   -- Rusty Leggings

-- Giddeus, Pond - North
    (57,90,900,300,9),      -- Rusty Bucket
    (57,4402,750,260,5),    -- Red Terrapin
    (57,4426,1000,500,15),  -- Tricolored Carp
    (57,4428,1000,500,15),  -- Dark Bass
    (57,4469,900,190,6),    -- Giant Catfish
    (57,4472,1000,500,15),  -- Crayfish
    (57,13456,300,275,6),   -- Silver Ring
    (57,14117,500,300,9),   -- Rusty Leggings

-- Giddeus, Misc Puddles
    (58,90,900,300,9),      -- Rusty Bucket
    (58,4472,1000,500,15),  -- Crayfish
    (58,13456,300,275,6),   -- Silver Ring
    (58,14117,500,300,9),   -- Rusty Leggings

-- West Sarutabaruta, Pond
    (59,90,900,300,9),      -- Rusty Bucket
    (59,4401,1000,1000,36), -- Moat Carp
    (59,4428,1000,500,15),  -- Dark Bass
    (59,4469,900,190,6),    -- Giant Catfish
    (59,4472,1000,500,15),  -- Crayfish
    (59,14242,500,300,9),   -- Rusty Subligar

-- West Sarutabaruta, Seaside
    (60,90,900,300,9),      -- Rusty Bucket
    (60,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (60,4360,1000,500,15),  -- Bastore Sardine
    (60,4383,800,290,7),    -- Gold Lobster
    (60,4399,650,275,6),    -- Bluetail
    (60,4461,250,230,6),    -- Bastore Bream
    (60,4471,750,145,4),    -- Bladefish
    (60,4481,1000,500,15),  -- Ogre Eel
    (60,4514,1000,500,15),  -- Quus
    (60,14117,500,300,9),   -- Rusty Leggings
    (60,14242,500,300,9),   -- Rusty Subligar

-- Bibiki Bay, PI - South Beach
    (61,90,900,300,9),      -- Rusty Bucket
    (61,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (61,887,200,50,6),      -- Coral Fragment
    (61,4314,850,500,15),   -- Bibikibo
    (61,4317,1000,500,15),  -- Trilobite
    (61,4318,100,50,6),     -- Bibiki Urchin
    (61,4443,1000,500,15),  -- Cobalt Jellyfish
    (61,4484,600,275,6),    -- Shall Shell
    (61,4514,1000,500,15),  -- Quus
    (61,5121,700,275,6),    -- Moorish Idol
    (61,5131,900,290,7),    -- Vongola Clam
    (61,12522,200,10,1),    -- Rusty Cap
    (61,14117,500,300,9),   -- Rusty Leggings
    (61,14242,500,300,9),   -- Rusty Subligar

-- Bibiki Bay, PI - North Beach
    (62,90,900,300,9),      -- Rusty Bucket
    (62,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (62,887,200,50,6),      -- Coral Fragment
    (62,4317,1000,500,15),  -- Trilobite
    (62,4318,100,50,6),     -- Bibiki Urchin
    (62,4360,1000,500,15),  -- Bastore Sardine
    (62,4399,650,275,6),    -- Bluetail
    (62,4443,1000,500,15),  -- Cobalt Jellyfish
    (62,4484,600,275,6),    -- Shall Shell
    (62,4514,1000,500,15),  -- Quus
    (62,5121,700,275,6),    -- Moorish Idol
    (62,5131,900,290,7),    -- Vongola Clam
    (62,12522,200,10,1),    -- Rusty Cap
    (62,14117,500,300,9),   -- Rusty Leggings
    (62,14242,500,300,9),   -- Rusty Subligar

-- Bibiki Bay, PI - West Beach / Bibiki Bay, PI - East Beach
    (63,90,900,300,9),      -- Rusty Bucket
    (63,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (63,887,200,50,6),      -- Coral Fragment
    (63,4318,100,50,6),     -- Bibiki Urchin
    (63,4360,1000,500,15),  -- Bastore Sardine
    (63,4399,650,275,6),    -- Bluetail
    (63,4443,1000,500,15),  -- Cobalt Jellyfish
    (63,4484,600,275,6),    -- Shall Shell
    (63,4514,1000,500,15),  -- Quus
    (63,5121,700,275,6),    -- Moorish Idol
    (63,5131,900,290,7),    -- Vongola Clam
    (63,12522,200,10,1),    -- Rusty Cap
    (63,14117,500,300,9),   -- Rusty Leggings
    (63,14242,500,300,9),   -- Rusty Subligar

-- Bibiki Bay, BB - South Seaside
    (64,90,900,300,9),      -- Rusty Bucket
    (64,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (64,4360,1000,500,15),  -- Bastore Sardine
    (64,4385,1000,500,15),  -- Zafmlug Bass
    (64,4443,1000,500,15),  -- Cobalt Jellyfish
    (64,4471,750,145,4),    -- Bladefish
    (64,5128,850,290,7),    -- Cone Calamary
    (64,12522,200,10,1),    -- Rusty Cap
    (64,14117,500,300,9),   -- Rusty Leggings
    (64,14242,500,300,9),   -- Rusty Subligar

-- Bibiki Bay, BB - Other Seaside
    (65,90,900,300,9),      -- Rusty Bucket
    (65,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (65,4360,1000,500,15),  -- Bastore Sardine
    (65,4385,1000,500,15),  -- Zafmlug Bass
    (65,4443,1000,500,15),  -- Cobalt Jellyfish
    (65,5128,850,290,7),    -- Cone Calamary
    (65,12316,500,260,5),   -- Fish Scale Shield
    (65,12522,200,10,1),    -- Rusty Cap
    (65,14117,500,300,9),   -- Rusty Leggings
    (65,14242,500,300,9),   -- Rusty Subligar

-- Buburimu Peninsula, Whole Zone
    (66,90,900,300,9),      -- Rusty Bucket
    (66,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (66,688,500,200,6),     -- Arrowwood Log
    (66,4399,650,275,6),    -- Bluetail
    (66,4403,1000,500,15),  -- Yellow Globe
    (66,4484,600,275,6),    -- Shall Shell
    (66,12522,200,10,1),    -- Rusty Cap
    (66,13454,800,300,9),   -- Copper Ring
    (66,13456,300,275,6),   -- Silver Ring
    (66,14117,500,300,9),   -- Rusty Leggings
    (66,14242,500,300,9),   -- Rusty Subligar
    (66,16655,400,290,7),   -- Rusty Pick

-- Labyrinth of Onzozo, Whole Zone
    (67,887,200,50,6),      -- Coral Fragment
    (67,14117,500,300,9),   -- Rusty Leggings

-- Manaclipper, Dhalmel Rock
    (68,90,900,300,9),      -- Rusty Bucket
    (68,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (68,4305,700,50,6),     -- Ryugu Titan
    (68,4314,850,500,15),   -- Bibikibo
    (68,4317,1000,500,15),  -- Trilobite
    (68,4318,100,50,6),     -- Bibiki Urchin
    (68,4360,1000,500,15),  -- Bastore Sardine
    (68,4385,1000,500,15),  -- Zafmlug Bass
    (68,4399,650,275,6),    -- Bluetail
    (68,4443,1000,500,15),  -- Cobalt Jellyfish
    (68,4471,750,145,4),    -- Bladefish
    (68,4476,500,50,6),     -- Titanictus
    (68,4480,900,400,12),   -- Gugru Tuna
    (68,4485,700,260,5),    -- Noble Lady
    (68,4514,1000,500,15),  -- Quus
    (68,5120,700,20,2),     -- Titanic Sawfish
    (68,5121,700,275,6),    -- Moorish Idol
    (68,5127,700,50,6),     -- Gugrusaurus
    (68,5128,850,290,7),    -- Cone Calamary
    (68,5131,900,290,7),    -- Vongola Clam

-- Mhaura, Whole Zone
    (71,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (71,4360,1000,500,15),  -- Bastore Sardine
    (71,4403,1000,500,15),  -- Yellow Globe
    (71,12522,200,10,1),    -- Rusty Cap
    (71,13454,800,300,9),   -- Copper Ring
    (71,13456,300,275,6),   -- Silver Ring
    (71,14117,500,300,9),   -- Rusty Leggings

-- Phomiuna Aqueducts, Whole Zone / Castle Oztroja, Whole Zone / Ranguemont Pass, Whole Zone
    (72,4472,1000,500,15)  -- Crayfish
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `rarity` = IF(`rarity` <> VALUES(`rarity`), VALUES(`rarity`), `rarity`),
    `pool_size` = IF(`pool_size` <> VALUES(`pool_size`), VALUES(`pool_size`), `pool_size`),
    `restock_rate` = IF(`restock_rate` <> VALUES(`restock_rate`), VALUES(`restock_rate`), `restock_rate`)
;

insert into `fishing_group`
(
    `groupid`, `fishid`, `rarity`, `pool_size`, `restock_rate`
)
VALUES
-- Sauromugue Champaign, Whole Zone
    (73,4384,750,215,6),    -- Black Sole
    (73,4399,650,275,6),    -- Bluetail
    (73,4403,1000,500,15),  -- Yellow Globe
    (73,4451,500,245,5),    -- Silver Shark
    (73,4483,1000,500,15),  -- Tiger Cod
    (73,5128,850,290,7),    -- Cone Calamary
    (73,14117,500,300,9),   -- Rusty Leggings
    (73,14242,500,300,9),   -- Rusty Subligar
    (73,16537,60,10,2),     -- Mythril Sword

-- Beaucedine Glacier, Seaside
    (74,688,500,200,6),     -- Arrowwood Log
    (74,4384,750,215,6),    -- Black Sole
    (74,4399,650,275,6),    -- Bluetail
    (74,4403,1000,500,15),  -- Yellow Globe
    (74,4474,100,115,3),    -- Gigant Squid
    (74,4482,950,500,15),   -- Nosteau Herring
    (74,4483,1000,500,15),  -- Tiger Cod
    (74,5128,850,290,7),    -- Cone Calamary
    (74,13454,800,300,9),   -- Copper Ring
    (74,14242,500,300,9),   -- Rusty Subligar
    (74,16537,60,10,2),     -- Mythril Sword

-- Beaucedine Glacier, Ponds
    (75,688,500,200,6),     -- Arrowwood Log
    (75,4454,200,115,3),    -- Emperor Fish
    (75,4470,900,290,7),    -- Icefish
    (75,13454,800,300,9),   -- Copper Ring
    (75,13456,300,275,6),   -- Silver Ring
    (75,14242,500,300,9),   -- Rusty Subligar
    (75,16451,80,10,2),     -- Mythril Dagger

-- Fei'Yin, Whole Zone
    (76,13454,800,300,9),   -- Copper Ring
    (76,13456,300,275,6),   -- Silver Ring

-- Middle Delkfutt's Tower, Whole Zone / Upper Delkfutt's Tower, Whole Zone / Lower Delkfutt's Tower, Whole Zone
    (77,14117,500,300,9),   -- Rusty Leggings

-- Qufim Island, Northwest Seaside
    (78,4384,750,215,6),    -- Black Sole
    (78,4399,650,275,6),    -- Bluetail
    (78,4403,1000,500,15),  -- Yellow Globe
    (78,4474,100,115,3),    -- Gigant Squid
    (78,4482,950,500,15),   -- Nosteau Herring
    (78,4483,1000,500,15),  -- Tiger Cod
    (78,5128,850,290,7),    -- Cone Calamary
    (78,12316,500,260,5),   -- Fish Scale Shield
    (78,13454,800,300,9),   -- Copper Ring
    (78,13456,300,275,6),   -- Silver Ring
    (78,14117,500,300,9),   -- Rusty Leggings
    (78,14242,500,300,9),   -- Rusty Subligar

-- Qufim Island, Southwest Seaside
    (79,4384,750,215,6),    -- Black Sole
    (79,4399,650,275,6),    -- Bluetail
    (79,4403,1000,500,15),  -- Yellow Globe
    (79,4478,500,130,3),    -- Three Eyed Fish
    (79,4482,950,500,15),   -- Nosteau Herring
    (79,4483,1000,500,15),  -- Tiger Cod
    (79,13454,800,300,9),   -- Copper Ring
    (79,14117,500,300,9),   -- Rusty Leggings
    (79,14242,500,300,9),   -- Rusty Subligar
    (79,16537,60,10,2),     -- Mythril Sword

-- Qufim Island, Other Seaside
    (80,4384,750,215,6),    -- Black Sole
    (80,4399,650,275,6),    -- Bluetail
    (80,4403,1000,500,15),  -- Yellow Globe
    (80,4482,950,500,15),   -- Nosteau Herring
    (80,4483,1000,500,15),  -- Tiger Cod
    (80,13454,800,300,9),   -- Copper Ring
    (80,14117,500,300,9),   -- Rusty Leggings
    (80,14242,500,300,9),   -- Rusty Subligar

-- The Boyahda Tree, Waterfall Basin
    (81,688,500,200,6),     -- Arrowwood Log
    (81,4308,500,50,6),     -- Giant Chirai
    (81,4401,1000,1000,36), -- Moat Carp
    (81,4426,1000,500,15),  -- Tricolored Carp
    (81,4428,1000,500,15),  -- Dark Bass
    (81,4472,1000,500,15),  -- Crayfish
    (81,13454,800,300,9),   -- Copper Ring
    (81,14117,500,300,9),   -- Rusty Leggings

-- The Boyahda Tree, Waterfall Basin - Hidden
    (82,688,500,200,6),     -- Arrowwood Log
    (82,4401,1000,1000,36), -- Moat Carp
    (82,4426,1000,500,15),  -- Tricolored Carp
    (82,4428,1000,500,15),  -- Dark Bass
    (82,4454,200,115,3),    -- Emperor Fish
    (82,4472,1000,500,15),  -- Crayfish
    (82,14117,500,300,9),   -- Rusty Leggings

-- The Boyahda Tree, Other Waterside
    (83,688,500,200,6),     -- Arrowwood Log
    (83,4401,1000,1000,36), -- Moat Carp
    (83,4428,1000,500,15),  -- Dark Bass
    (83,4472,1000,500,15),  -- Crayfish
    (83,14117,500,300,9),   -- Rusty Leggings

-- Dragon's Aery, Whole Zone
    (84,90,900,300,9),      -- Rusty Bucket
    (84,688,500,200,6),     -- Arrowwood Log
    (84,4401,1000,1000,36), -- Moat Carp
    (84,4472,1000,500,15),  -- Crayfish
    (84,4473,450,245,5),    -- Crescent Fish
    (84,13454,800,300,9),   -- Copper Ring
    (84,14117,500,300,9),   -- Rusty Leggings
    (84,16451,80,10,2),     -- Mythril Dagger
    (84,16537,60,10,2),     -- Mythril Sword

-- Ro'Maeve, Whole Zone
    (85,13454,800,300,9),   -- Copper Ring
    (85,13456,300,275,6),   -- Silver Ring

-- The Sanctuary of Zi'Tah, Whole Zone
    (86,688,500,200,6),     -- Arrowwood Log
    (86,4402,750,260,5),    -- Red Terrapin
    (86,4428,1000,500,15),  -- Dark Bass
    (86,4528,1000,500,15),  -- Crystal Bass

-- Eastern Altepa Desert, Whole Zone
    (87,4291,1000,500,15),  -- Sandfish
    (87,4306,900,190,6),    -- Giant Donko
    (87,4401,1000,1000,36), -- Moat Carp
    (87,4472,1000,500,15),  -- Crayfish
    (87,4515,1000,500,15),  -- Copper Frog
    (87,13454,800,300,9),   -- Copper Ring
    (87,16606,400,300,9),   -- Rusty Greatsword

-- Quicksand Caves, Whole Zone
    (88,4309,500,50,6),     -- Cave Cherax
    (88,4472,1000,500,15),  -- Crayfish
    (88,14242,500,300,9),   -- Rusty Subligar

-- Rabao, Whole Zone
    (89,90,900,300,9),      -- Rusty Bucket
    (89,4291,1000,500,15),  -- Sandfish
    (89,4306,900,190,6),    -- Giant Donko
    (89,4401,1000,1000,36), -- Moat Carp
    (89,4472,1000,500,15),  -- Crayfish
    (89,12522,200,10,1),    -- Rusty Cap
    (89,14117,500,300,9),   -- Rusty Leggings

-- Western Altepa Desert, Oasis of Hubol
    (90,4291,1000,500,15),  -- Sandfish
    (90,4306,900,190,6),    -- Giant Donko
    (90,4401,1000,1000,36), -- Moat Carp
    (90,4469,900,190,6),    -- Giant Catfish
    (90,4472,1000,500,15),  -- Crayfish
    (90,4477,550,145,4),    -- Gavial Fish
    (90,12522,200,10,1),    -- Rusty Cap
    (90,14117,500,300,9),   -- Rusty Leggings

-- Western Altepa Desert, Central Spring
    (91,4291,1000,500,15),  -- Sandfish
    (91,4306,900,190,6),    -- Giant Donko
    (91,4401,1000,1000,36), -- Moat Carp
    (91,4469,900,190,6),    -- Giant Catfish
    (91,4472,1000,500,15),  -- Crayfish
    (91,12522,200,10,1),    -- Rusty Cap
    (91,14117,500,300,9),   -- Rusty Leggings

-- Cape Teriggan, Whole Zone
    (92,4360,1000,500,15),  -- Bastore Sardine
    (92,4385,1000,500,15),  -- Zafmlug Bass
    (92,4443,1000,500,15),  -- Cobalt Jellyfish
    (92,4484,600,275,6),    -- Shall Shell
    (92,4500,1000,500,15),  -- Greedie
    (92,4514,1000,500,15),  -- Quus
    (92,14117,500,300,9),   -- Rusty Leggings

-- Kuftal Tunnel, Whole Zone
    (93,90,900,300,9),      -- Rusty Bucket
    (93,4291,1000,500,15),  -- Sandfish
    (93,4306,900,190,6),    -- Giant Donko
    (93,4309,500,50,6),     -- Cave Cherax
    (93,12522,200,10,1),    -- Rusty Cap
    (93,14242,500,300,9)   -- Rusty Subligar
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `rarity` = IF(`rarity` <> VALUES(`rarity`), VALUES(`rarity`), `rarity`),
    `pool_size` = IF(`pool_size` <> VALUES(`pool_size`), VALUES(`pool_size`), `pool_size`),
    `restock_rate` = IF(`restock_rate` <> VALUES(`restock_rate`), VALUES(`restock_rate`), `restock_rate`)
;

insert into `fishing_group`
(
    `groupid`, `fishid`, `rarity`, `pool_size`, `restock_rate`
)
VALUES
-- Kazham, Whole Zone
    (94,90,900,300,9),      -- Rusty Bucket
    (94,591,1000,300,9),    -- Ripped Cap
    (94,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (94,688,500,200,6),     -- Arrowwood Log
    (94,4360,1000,500,15),  -- Bastore Sardine
    (94,4443,1000,500,15),  -- Cobalt Jellyfish
    (94,4514,1000,500,15),  -- Quus
    (94,4580,900,290,7),    -- Coral Butterfly
    (94,13454,800,300,9),   -- Copper Ring
    (94,14117,500,300,9),   -- Rusty Leggings
    (94,14242,500,300,9),   -- Rusty Subligar

-- Norg, Whole Zone
    (95,90,900,300,9),      -- Rusty Bucket
    (95,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (95,4360,1000,500,15),  -- Bastore Sardine
    (95,4403,1000,500,15),  -- Yellow Globe
    (95,4443,1000,500,15),  -- Cobalt Jellyfish
    (95,4514,1000,500,15),  -- Quus
    (95,4580,900,290,7),    -- Coral Butterfly
    (95,13454,800,300,9),   -- Copper Ring
    (95,14117,500,300,9),   -- Rusty Leggings
    (95,14242,500,300,9),   -- Rusty Subligar

-- Sea Serpent Grotto, Other Seaside
    (96,90,900,300,9),      -- Rusty Bucket
    (96,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (96,887,200,50,6),      -- Coral Fragment
    (96,1135,600,50,6),     -- Norg Shell
    (96,4360,1000,500,15),  -- Bastore Sardine
    (96,4443,1000,500,15),  -- Cobalt Jellyfish
    (96,4514,1000,500,15),  -- Quus
    (96,4580,900,290,7),    -- Coral Butterfly

-- Sea Serpent Grotto, Pond Under a Bridge
    (97,90,900,300,9),      -- Rusty Bucket
    (97,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (97,887,200,50,6),      -- Coral Fragment
    (97,1135,600,50,6),     -- Norg Shell
    (97,1210,1000,300,9),   -- Damp Scroll
    (97,4304,450,100,4),    -- Grimmonite
    (97,4360,1000,500,15),  -- Bastore Sardine
    (97,4361,1000,500,15),  -- Nebimonite
    (97,4399,650,275,6),    -- Bluetail
    (97,4443,1000,500,15),  -- Cobalt Jellyfish
    (97,4461,250,230,6),    -- Bastore Bream
    (97,4514,1000,500,15),  -- Quus
    (97,4580,900,290,7),    -- Coral Butterfly
    (97,16606,400,300,9),   -- Rusty Greatsword

-- Sea Serpent Grotto, Interior of Hidden Door - Mythril
    (98,90,900,300,9),      -- Rusty Bucket
    (98,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (98,887,200,50,6),      -- Coral Fragment
    (98,1135,600,50,6),     -- Norg Shell
    (98,4304,450,100,4),    -- Grimmonite
    (98,4360,1000,500,15),  -- Bastore Sardine
    (98,4361,1000,500,15),  -- Nebimonite
    (98,4399,650,275,6),    -- Bluetail
    (98,4443,1000,500,15),  -- Cobalt Jellyfish
    (98,4451,500,245,5),    -- Silver Shark
    (98,4461,250,230,6),    -- Bastore Bream
    (98,4514,1000,500,15),  -- Quus
    (98,4580,900,290,7),    -- Coral Butterfly
    (98,16606,400,300,9),   -- Rusty Greatsword

-- Sea Serpent Grotto, Interior of Hidden Door - Gold
    (99,90,900,300,9),      -- Rusty Bucket
    (99,624,1000,300,9),    -- Clump Of Pamtam Kelp
    (99,4360,1000,500,15),  -- Bastore Sardine
    (99,4443,1000,500,15),  -- Cobalt Jellyfish
    (99,4514,1000,500,15),  -- Quus
    (99,4580,900,290,7),    -- Coral Butterfly

-- Sea Serpent Grotto, Misc Puddles
    (100,90,900,300,9),     -- Rusty Bucket
    (100,624,1000,300,9),   -- Clump Of Pamtam Kelp
    (100,4360,1000,500,15), -- Bastore Sardine
    (100,4443,1000,500,15), -- Cobalt Jellyfish
    (100,4514,1000,500,15), -- Quus

-- Yuhtunga Jungle, Northeast Pond
    (101,90,900,300,9),     -- Rusty Bucket
    (101,688,500,200,6),    -- Arrowwood Log
    (101,4289,1000,500,15), -- Forest Carp
    (101,4290,1000,500,15), -- Elshimo Frog
    (101,4307,500,115,3),   -- Jungle Catfish
    (101,4401,1000,1000,36),-- Moat Carp
    (101,4462,550,160,5),   -- Monke Onke
    (101,4472,1000,500,15), -- Crayfish
    (101,4473,450,245,5),   -- Crescent Fish
    (101,13454,800,300,9),  -- Copper Ring
    (101,14117,500,300,9),  -- Rusty Leggings
    (101,14242,500,300,9),  -- Rusty Subligar

-- Yuhtunga Jungle, Gremini Falls
    (102,90,900,300,9),     -- Rusty Bucket
    (102,688,500,200,6),    -- Arrowwood Log
    (102,4289,1000,500,15), -- Forest Carp
    (102,4290,1000,500,15), -- Elshimo Frog
    (102,4401,1000,1000,36),-- Moat Carp
    (102,4472,1000,500,15), -- Crayfish
    (102,4473,450,245,5),   -- Crescent Fish
    (102,4579,900,290,7),   -- Elshimo Newt
    (102,13454,800,300,9),  -- Copper Ring
    (102,14117,500,300,9),  -- Rusty Leggings
    (102,14242,500,300,9),  -- Rusty Subligar

-- Yuhtunga Jungle, Southwest Pond
    (103,90,900,300,9),     -- Rusty Bucket
    (103,688,500,200,6),    -- Arrowwood Log
    (103,4289,1000,500,15), -- Forest Carp
    (103,4307,500,115,3),   -- Jungle Catfish
    (103,4401,1000,1000,36),-- Moat Carp
    (103,4464,1000,500,15), -- Pipira
    (103,4472,1000,500,15), -- Crayfish
    (103,4579,900,290,7),   -- Elshimo Newt
    (103,13454,800,300,9),  -- Copper Ring
    (103,14117,500,300,9),  -- Rusty Leggings
    (103,14242,500,300,9),  -- Rusty Subligar

-- Yuhtunga Jungle, Southwest Waterfall - South
    (104,90,900,300,9),     -- Rusty Bucket
    (104,688,500,200,6),    -- Arrowwood Log
    (104,4289,1000,500,15), -- Forest Carp
    (104,4401,1000,1000,36),-- Moat Carp
    (104,4464,1000,500,15), -- Pipira
    (104,4472,1000,500,15), -- Crayfish
    (104,4579,900,290,7),   -- Elshimo Newt
    (104,13454,800,300,9),  -- Copper Ring
    (104,14117,500,300,9),  -- Rusty Leggings
    (104,14242,500,300,9),  -- Rusty Subligar

-- Yuhtunga Jungle, Southwest Waterfall - North
    (105,90,900,300,9),     -- Rusty Bucket
    (105,688,500,200,6),    -- Arrowwood Log
    (105,4289,1000,500,15), -- Forest Carp
    (105,4401,1000,1000,36),-- Moat Carp
    (105,4464,1000,500,15), -- Pipira
    (105,4472,1000,500,15), -- Crayfish
    (105,4579,900,290,7),   -- Elshimo Newt
    (105,13454,800,300,9),  -- Copper Ring
    (105,14117,500,300,9),  -- Rusty Leggings
    (105,14242,500,300,9),  -- Rusty Subligar

-- Yuhtunga Jungle, Other Waterside
    (106,90,900,300,9),     -- Rusty Bucket
    (106,4289,1000,500,15), -- Forest Carp
    (106,4290,1000,500,15), -- Elshimo Frog
    (106,4401,1000,1000,36),-- Moat Carp
    (106,4472,1000,500,15), -- Crayfish
    (106,4579,900,290,7),   -- Elshimo Newt
    (106,13454,800,300,9),  -- Copper Ring
    (106,14117,500,300,9),  -- Rusty Leggings

-- Den of Rancor, Pool E-8
    (107,624,1000,300,9),   -- Clump Of Pamtam Kelp
    (107,887,200,50,6),     -- Coral Fragment
    (107,4288,800,260,5),   -- Zebra Eel
    (107,4383,800,290,7),   -- Gold Lobster
    (107,4399,650,275,6),   -- Bluetail
    (107,4443,1000,500,15), -- Cobalt Jellyfish
    (107,4514,1000,500,15), -- Quus
    (107,4580,900,290,7),   -- Coral Butterfly
    (107,12522,200,10,1),   -- Rusty Cap
    (107,14242,500,300,9),  -- Rusty Subligar
    (107,16606,400,300,9),  -- Rusty Greatsword

-- Den of Rancor, Pool F-11
    (108,624,1000,300,9),   -- Clump Of Pamtam Kelp
    (108,887,200,50,6),     -- Coral Fragment
    (108,4305,700,50,6),    -- Ryugu Titan
    (108,4399,650,275,6),   -- Bluetail
    (108,4443,1000,500,15), -- Cobalt Jellyfish
    (108,4514,1000,500,15), -- Quus
    (108,4580,900,290,7),   -- Coral Butterfly
    (108,12316,500,260,5),  -- Fish Scale Shield
    (108,14242,500,300,9),  -- Rusty Subligar
    (108,16606,400,300,9),  -- Rusty Greatsword

-- Den of Rancor, Misc Water
    (109,624,1000,300,9),   -- Clump Of Pamtam Kelp
    (109,4443,1000,500,15), -- Cobalt Jellyfish
    (109,12522,200,10,1)   -- Rusty Cap
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `rarity` = IF(`rarity` <> VALUES(`rarity`), VALUES(`rarity`), `rarity`),
    `pool_size` = IF(`pool_size` <> VALUES(`pool_size`), VALUES(`pool_size`), `pool_size`),
    `restock_rate` = IF(`restock_rate` <> VALUES(`restock_rate`), VALUES(`restock_rate`), `restock_rate`)
;

insert into `fishing_group`
(
    `groupid`, `fishid`, `rarity`, `pool_size`, `restock_rate`
)
VALUES
-- Temple of Uggalepih, Whole Zone
    (110,4401,1000,1000,36),-- Moat Carp
    (110,4472,1000,500,15), -- Crayfish
    (110,13454,800,300,9),  -- Copper Ring

-- Yhoator Jungle, Front of Temple - East Side
    (111,688,500,200,6),    -- Arrowwood Log
    (111,4289,1000,500,15), -- Forest Carp
    (111,4290,1000,500,15), -- Elshimo Frog
    (111,4307,500,115,3),   -- Jungle Catfish
    (111,4401,1000,1000,36),-- Moat Carp
    (111,4464,1000,500,15), -- Pipira
    (111,4472,1000,500,15), -- Crayfish
    (111,13454,800,300,9),  -- Copper Ring
    (111,14242,500,300,9),  -- Rusty Subligar

-- Yhoator Jungle, Front of Temple - West Side
    (112,688,500,200,6),    -- Arrowwood Log
    (112,4289,1000,500,15), -- Forest Carp
    (112,4290,1000,500,15), -- Elshimo Frog
    (112,4307,500,115,3),   -- Jungle Catfish
    (112,4401,1000,1000,36),-- Moat Carp
    (112,4472,1000,500,15), -- Crayfish
    (112,4579,900,290,7),   -- Elshimo Newt
    (112,13454,800,300,9),  -- Copper Ring
    (112,14242,500,300,9),  -- Rusty Subligar

-- Yhoator Jungle, Teardrop Spring
    (113,688,500,200,6),    -- Arrowwood Log
    (113,4289,1000,500,15), -- Forest Carp
    (113,4401,1000,1000,36),-- Moat Carp
    (113,4472,1000,500,15), -- Crayfish
    (113,13456,300,275,6),  -- Silver Ring
    (113,14117,500,300,9),  -- Rusty Leggings
    (113,14242,500,300,9),  -- Rusty Subligar

-- Yhoator Jungle, Underground Pool 1
    (114,688,500,200,6),    -- Arrowwood Log
    (114,4289,1000,500,15), -- Forest Carp
    (114,4307,500,115,3),   -- Jungle Catfish
    (114,4401,1000,1000,36),-- Moat Carp
    (114,4462,550,160,5),   -- Monke Onke
    (114,4472,1000,500,15), -- Crayfish
    (114,13454,800,300,9),  -- Copper Ring
    (114,14242,500,300,9),  -- Rusty Subligar

-- Yhoator Jungle, Bloodlet Spring
    (115,90,900,300,9),     -- Rusty Bucket
    (115,688,500,200,6),    -- Arrowwood Log
    (115,4289,1000,500,15), -- Forest Carp
    (115,4401,1000,1000,36),-- Moat Carp
    (115,4472,1000,500,15), -- Crayfish
    (115,13454,800,300,9),  -- Copper Ring
    (115,14242,500,300,9),  -- Rusty Subligar

-- Yhoator Jungle, Underground Pool 3
    (116,4290,1000,500,15), -- Elshimo Frog
    (116,4579,900,290,7),   -- Elshimo Newt

-- Yhoator Jungle, Underground Pool 2
    (117,688,500,200,6),    -- Arrowwood Log
    (117,4289,1000,500,15), -- Forest Carp
    (117,4290,1000,500,15), -- Elshimo Frog
    (117,4401,1000,1000,36),-- Moat Carp
    (117,4472,1000,500,15), -- Crayfish
    (117,4579,900,290,7),   -- Elshimo Newt
    (117,13454,800,300,9),  -- Copper Ring
    (117,14242,500,300,9),  -- Rusty Subligar

-- Ru'Aun Gardens, Whole Zone / The Shrine of Ru'Avitau, Whole Zone
    (118,4472,1000,500,15), -- Crayfish
    (118,13454,800,300,9),  -- Copper Ring
    (118,13456,300,275,6),  -- Silver Ring

-- Oldton Movalpolos, Whole Zone
    (119,1624,700,300,9),   -- Bugbear Mask
    (119,1638,800,300,9),   -- Moblin Mask
    (119,4313,750,275,6),   -- Blindfish
    (119,4316,500,100,4),   -- Armored Pisces
    (119,4429,800,290,7),   -- Black Eel
    (119,4472,1000,500,15), -- Crayfish
    (119,4515,1000,500,15), -- Copper Frog
    (119,13454,800,300,9),  -- Copper Ring
    (119,16606,400,300,9),  -- Rusty Greatsword
    (119,16655,400,290,7),  -- Rusty Pick

-- Lufaise Meadows, Leremieu Lagoon
    (120,688,500,200,6),    -- Arrowwood Log
    (120,4428,1000,500,15), -- Dark Bass
    (120,4454,200,115,3),   -- Emperor Fish
    (120,5129,850,50,6),    -- Lik
    (120,5130,850,260,5),   -- Tavnazian Goby

-- Lufaise Meadows, Seaside / Misareaux Coast, Seaside
    (121,4443,1000,500,15), -- Cobalt Jellyfish
    (121,4500,1000,500,15), -- Greedie
    (121,4514,1000,500,15), -- Quus

-- Lufaise Meadows, Rafeloux River / Misareaux Coast, Rafeloux River
    (122,688,500,200,6),    -- Arrowwood Log
    (122,4427,750,275,6),   -- Gold Carp
    (122,5130,850,260,5),   -- Tavnazian Goby

-- Misareaux Coast, Cascade Edellaine
    (123,4401,1000,1000,36),-- Moat Carp
    (123,4427,750,275,6),   -- Gold Carp
    (123,4428,1000,500,15), -- Dark Bass
    (123,4463,500,50,6),    -- Takitaro
    (123,5130,850,260,5),   -- Tavnazian Goby
    (123,13456,300,275,6),  -- Silver Ring

-- Aht Urhgan Whitegate, Whole Zone
    (124,2341,1000,300,9),  -- Hydrogauge
    (124,5447,1000,500,15), -- Denizanasi
    (124,5448,850,290,7),   -- Kalamar
    (124,5449,1000,500,15), -- Hamsi
    (124,14242,500,300,9),  -- Rusty Subligar

-- Al Zahbi, Whole Zone
    (125,90,900,300,9),     -- Rusty Bucket
    (125,2341,1000,300,9),  -- Hydrogauge
    (125,4310,1000,500,15), -- Tiny Goldfish
    (125,4401,1000,1000,36),-- Moat Carp
    (125,4472,1000,500,15), -- Crayfish
    (125,5458,800,290,7),   -- Yilanbaligi
    (125,5459,650,275,6),   -- Sazanbaligi
    (125,5460,650,260,5),   -- Kayabaligi
    (125,14117,500,300,9),  -- Rusty Leggings
    (125,14242,500,300,9),  -- Rusty Subligar

-- Bhaflau Thickets, Whole Zone
    (126,90,900,300,9),     -- Rusty Bucket
    (126,4428,1000,500,15), -- Dark Bass
    (126,5137,450,115,3),   -- Turnabaligi
    (126,5458,800,290,7),   -- Yilanbaligi
    (126,5459,650,275,6),   -- Sazanbaligi
    (126,5460,650,260,5),   -- Kayabaligi
    (126,5461,1000,200,6),  -- Alabaligi
    (126,5462,450,230,6),   -- Morinabaligi
    (126,14242,500,300,9),  -- Rusty Subligar

-- Aydeewa Subterrane, Whole Zone
    (127,2216,1000,200,6),  -- Lamp Marimo
    (127,4309,500,50,6),    -- Cave Cherax
    (127,4313,750,275,6),   -- Blindfish
    (127,14117,500,300,9),  -- Rusty Leggings
    (127,14242,500,300,9),  -- Rusty Subligar

-- Mamook, Pond
    (128,90,900,300,9),     -- Rusty Bucket
    (128,5139,600,290,7),   -- Betta
    (128,5458,800,290,7),   -- Yilanbaligi
    (128,5459,650,275,6),   -- Sazanbaligi
    (128,5460,650,260,5),   -- Kayabaligi
    (128,5461,1000,200,6),  -- Alabaligi
    (128,14117,500,300,9),  -- Rusty Leggings
    (128,14242,500,300,9),  -- Rusty Subligar

-- Wajaom Woodlands, Whole Zone
    (129,90,900,300,9),     -- Rusty Bucket
    (129,4428,1000,500,15), -- Dark Bass
    (129,5137,450,115,3),   -- Turnabaligi
    (129,5458,800,290,7),   -- Yilanbaligi
    (129,5459,650,275,6),   -- Sazanbaligi
    (129,5460,650,260,5),   -- Kayabaligi
    (129,5461,1000,200,6),  -- Alabaligi
    (129,5462,450,230,6),   -- Morinabaligi
    (129,14117,500,300,9),  -- Rusty Leggings
    (129,14242,500,300,9),  -- Rusty Subligar

-- Mount Zhayolm, Whole Zone
    (130,5447,1000,500,15), -- Denizanasi
    (130,5448,850,290,7),   -- Kalamar
    (130,5449,1000,500,15), -- Hamsi
    (130,14242,500,300,9),  -- Rusty Subligar

-- Arrapago Reef, Whole Zone
    (131,5135,450,115,3),   -- Rhinochimera
    (131,5453,1000,290,7),  -- Istakoz
    (131,5454,400,230,6),   -- Mercanbaligi
    (131,5455,500,115,3),   -- Ahtapot
    (131,5456,850,275,6),   -- Istiridye
    (131,14117,500,300,9),  -- Rusty Leggings
    (131,14242,500,300,9)  -- Rusty Subligar
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `rarity` = IF(`rarity` <> VALUES(`rarity`), VALUES(`rarity`), `rarity`),
    `pool_size` = IF(`pool_size` <> VALUES(`pool_size`), VALUES(`pool_size`), `pool_size`),
    `restock_rate` = IF(`restock_rate` <> VALUES(`restock_rate`), VALUES(`restock_rate`), `restock_rate`)
;

insert into `fishing_group`
(
    `groupid`, `fishid`, `rarity`, `pool_size`, `restock_rate`
)
VALUES
-- Caedarva Mire, Whole Zone
    (132,4428,1000,500,15), -- Dark Bass
    (132,4472,1000,500,15), -- Crayfish
    (132,5138,450,260,5),   -- Black Ghost
    (132,5463,900,175,5),   -- Yayinbaligi
    (132,5464,800,200,6),   -- Kaplumbaga
    (132,5465,1000,500,15), -- Caedarva Frog
    (132,14117,500,300,9),  -- Rusty Leggings

-- Nashmau, Whole Zone
    (133,2341,1000,300,9),  -- Hydrogauge
    (133,5133,400,100,4),   -- Pterygotus
    (133,5453,1000,290,7),  -- Istakoz
    (133,5454,400,230,6),   -- Mercanbaligi
    (133,5455,500,115,3),   -- Ahtapot
    (133,5456,850,275,6),   -- Istiridye
    (133,14117,500,300,9),  -- Rusty Leggings
    (133,14242,500,300,9),  -- Rusty Subligar

-- Talacca Cove, Whole Zone
    (134,5136,1000,400,12), -- Istavrit
    (134,5453,1000,290,7),  -- Istakoz
    (134,5454,400,230,6),   -- Mercanbaligi
    (134,5455,500,115,3),   -- Ahtapot
    (134,5457,750,215,6),   -- Dil
    (134,14117,500,300,9),  -- Rusty Leggings
    (134,14242,500,300,9),  -- Rusty Subligar

-- Open sea route to Al Zahbi, Whole Zone / Open sea route to Mhaura, Whole Zone
    (135,90,900,300,9),     -- Rusty Bucket
    (135,624,1000,300,9),   -- Clump Of Pamtam Kelp
    (135,4403,1000,500,15), -- Yellow Globe
    (135,4443,1000,500,15), -- Cobalt Jellyfish
    (135,4480,900,400,12),  -- Gugru Tuna
    (135,4485,700,260,5),   -- Noble Lady
    (135,5127,700,50,6),    -- Gugrusaurus
    (135,5132,550,245,5),   -- Gurnard
    (135,5134,500,50,6),    -- Mola Mola
    (135,5141,400,145,4),   -- Veydal Wrasse
    (135,14117,500,300,9),  -- Rusty Leggings

-- Ship bound for Selbina, Whole Zone / Ship bound for Mhaura, Whole Zone
    (136,4305,700,50,6),    -- Ryugu Titan
    (136,4360,1000,500,15), -- Bastore Sardine
    (136,4361,1000,500,15), -- Nebimonite
    (136,4399,650,275,6),   -- Bluetail
    (136,4451,500,245,5),   -- Silver Shark
    (136,4476,500,50,6),    -- Titanictus
    (136,4479,700,160,5),   -- Bhefhel Marlin
    (136,4480,900,400,12),  -- Gugru Tuna
    (136,4485,700,260,5),   -- Noble Lady
    (136,4514,1000,500,15), -- Quus
    (136,5128,850,290,7),   -- Cone Calamary
    (136,14242,500,300,9),  -- Rusty Subligar

-- Ship bound for Selbina (with Pirates), Whole Zone / Ship bound for Mhaura (with Pirates), Whole Zone
    (137,4305,700,50,6),    -- Ryugu Titan
    (137,4360,1000,500,15), -- Bastore Sardine
    (137,4361,1000,500,15), -- Nebimonite
    (137,4399,650,275,6),   -- Bluetail
    (137,4451,500,245,5),   -- Silver Shark
    (137,4475,700,50,6),    -- Sea Zombie
    (137,4476,500,50,6),    -- Titanictus
    (137,4479,700,160,5),   -- Bhefhel Marlin
    (137,4480,900,400,12),  -- Gugru Tuna
    (137,4485,700,260,5),   -- Noble Lady
    (137,4514,1000,500,15), -- Quus
    (137,5127,700,50,6),    -- Gugrusaurus
    (137,5128,850,290,7),   -- Cone Calamary
    (137,14242,500,300,9),  -- Rusty Subligar

-- Silver Sea route to Nashmau, Whole Zone / Silver Sea route to Al Zahbi, Whole Zone
    (138,2341,1000,300,9),  -- Hydrogauge
    (138,5140,500,50,6),    -- Kalkanbaligi
    (138,5448,850,290,7),   -- Kalamar
    (138,5449,1000,500,15), -- Hamsi
    (138,5450,900,190,6),   -- Lakerda
    (138,5451,800,245,5),   -- Kilicbaligi
    (138,5452,550,275,6),   -- Uskumru

-- Phanauet Channel, Whole Zone
    (139,90,900,300,9),     -- Rusty Bucket
    (139,4315,450,50,8),    -- Lungfish
    (139,4319,650,50,8),    -- Tricorn
    (139,4354,1000,500,15), -- Shining Trout
    (139,4402,750,260,5),   -- Red Terrapin
    (139,4426,1000,500,15), -- Tricolored Carp
    (139,4427,750,275,6),   -- Gold Carp
    (139,4428,1000,500,15), -- Dark Bass
    (139,4469,900,190,6),   -- Giant Catfish
    (139,4472,1000,500,15), -- Crayfish
    (139,5125,1000,500,15), -- Phanauet Newt
    (139,5126,1000,500,15) -- Muddy Siredont
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `rarity` = IF(`rarity` <> VALUES(`rarity`), VALUES(`rarity`), `rarity`),
    `pool_size` = IF(`pool_size` <> VALUES(`pool_size`), VALUES(`pool_size`), `pool_size`),
    `restock_rate` = IF(`restock_rate` <> VALUES(`restock_rate`), VALUES(`restock_rate`), `restock_rate`)
;

/*!40000 ALTER TABLE `fishing_group` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-05-02 13:25:28
