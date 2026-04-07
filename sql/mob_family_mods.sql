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
-- Table structure for table `mob_family_mods`
--

DROP TABLE IF EXISTS `mob_family_mods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mob_family_mods` (
  `familyid` smallint(5) unsigned NOT NULL,
  `modid` smallint(5) unsigned NOT NULL,
  `value` smallint(5) NOT NULL DEFAULT '0',
  `is_mob_mod` boolean NOT NULL DEFAULT '0',
  PRIMARY KEY (`familyid`,`modid`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=13 PACK_KEYS=1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mob_family_mods`
--

LOCK TABLES `mob_family_mods` WRITE;
/*!40000 ALTER TABLE `mob_family_mods` DISABLE KEYS */;

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

insert into `mob_family_mods`
(
    `familyid`, `modid`, `value`, `is_mob_mod`
)
VALUES
-- Adamantoise
    (2,36,50,1), -- ROAM_COOL: 50
    (2,52,30,1), -- ROAM_RATE: 30
    (2,63,20,0), -- DEFP: 20

-- Ahriman
    (4,7,60,1),   -- GA_CHANCE: 60
    (4,29,20,0),  -- MDEF: 20
    (4,36,40,1),  -- ROAM_COOL: 40
    (4,51,5,1),   -- ROAM_TURNS: 5
    (4,56,-1,1),  -- HP_STANDBACK: -1
    (4,244,20,0), -- SILENCERES: 20

-- Animated Weapon
    (7,3,50,1), -- MP_BASE: 50

-- Antlion
    (26,36,50,1), -- ROAM_COOL: 50
    (26,51,2,1),  -- ROAM_TURNS: 2
    (26,52,30,1), -- ROAM_RATE: 30
    (26,63,20,0), -- DEFP: 20

-- Apkallu
    (27,10,14,1), -- SUBLINK: 14 (Apkallu)

-- Avatar-Atomos
    (32,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Alexander
    (33,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Carbuncle
    (34,3,100,1), -- MP_BASE: 100
    (34,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Diabolos
    (35,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Fenrir
    (36,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Garuda
    (37,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Ifrit
    (38,56,-1,1), -- HP_STANDBACK: -1

-- Monoceros
    (39,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Leviathan
    (40,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Odin
    (41,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Odin
    (42,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Ramuh
    (43,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Shiva
    (44,56,-1,1), -- HP_STANDBACK: -1

-- Avatar-Titan
    (45,56,-1,1), -- HP_STANDBACK: -1

-- Bat
    (46,10,3,1),  -- SUBLINK: 3 (Single Bat, Bat Trio, Vampyr)
    (46,36,35,1), -- ROAM_COOL: 35
    (46,51,3,1),  -- ROAM_TURNS: 3
    (46,52,30,1), -- ROAM_RATE: 30

-- Bat Trio
    (47,10,3,1),   -- SUBLINK: 3 (Single Bat, Bat Trio, Vampyr)
    (47,36,35,1),  -- ROAM_COOL: 35
    (47,51,2,1),   -- ROAM_TURNS: 2
    (47,52,30,1),  -- ROAM_RATE: 30

-- Bee
    (48,36,15,1),  -- ROAM_COOL: 15
    (48,51,2,1),   -- ROAM_TURNS: 2

-- Beetle
    (49,31,15,1), -- ROAM_DISTANCE: 15
    (49,36,60,1), -- ROAM_COOL: 60
    (49,52,30,1), -- ROAM_RATE: 30

-- Behemoth
    (51,36,50,1), -- ROAM_COOL: 50

-- Bhoot
    (52,242,20,0),  -- PARALYZERES: 20

-- Bomb
    (56,36,30,1), -- ROAM_COOL: 30
    (56,51,5,1),  -- ROAM_TURNS: 5
    (56,52,20,1), -- ROAM_RATE: 20

-- Buffalo
    (57,3,50,1),   -- MP_BASE: 50
    (57,36,50,1),  -- ROAM_COOL: 50
    (57,51,4,1),   -- ROAM_TURNS: 4
    (57,52,30,1),  -- ROAM_RATE: 30
    (57,62,10,0),  -- ATTP: 10
    (57,63,20,0),  -- DEFP: 20

-- Bugard
    (58,36,45,1),  -- ROAM_COOL: 45
    (58,51,3,1),   -- ROAM_TURNS: 3
    (58,52,30,1),  -- ROAM_RATE: 30
    (58,62,10,0),  -- ATTP: 10
    (58,63,20,0),  -- DEFP: 20

-- Bugbear
    (59,10,5,1),   -- SUBLINK: 5 (Bugbear, Goblin, Moblin)
    (59,36,50,1),  -- ROAM_COOL: 50
    (59,51,2,1),   -- ROAM_TURNS: 2
    (59,52,30,1),  -- ROAM_RATE: 30
    (59,63,20,0),  -- DEFP: 20

-- Cardian: https://www.bg-wiki.com/ffxi/Category:Cardian
    (61,29,25,0),     -- MDEF: 25
    (61,36,40,1),     -- ROAM_COOL: 40
    (61,51,2,1),      -- ROAM_TURNS: 2
    (61,52,20,1),     -- ROAM_RATE: 20
    (61,389,-2500,0), -- UDMGMAGIC: -2500

-- Cerberus
    (62,36,50,1), -- ROAM_COOL: 50

-- Chariot
    (63,10,15,1), -- SUBLINK: 15 (Chariot, Gear, Rampart)

-- Bomb-Cluster
    (68,36,40,1), -- ROAM_COOL: 40
    (68,51,2,1),  -- ROAM_TURNS: 2
    (68,52,20,1), -- ROAM_RATE: 20

-- Cockatrice
    (70,36,30,1), -- ROAM_COOL: 30
    (70,51,3,1),  -- ROAM_TURNS: 3
    (70,52,30,1), -- ROAM_RATE: 30

-- Coeurl
    (71,31,5,1),  -- ROAM_DISTANCE: 5
    (71,36,55,1), -- ROAM_COOL: 55
    (71,52,30,1), -- ROAM_RATE: 30

-- Colibri
    (72,3,50,1),  -- MP_BASE: 50
    (72,29,10,0), -- MDEF: 10
    (72,51,2,1),  -- ROAM_TURNS: 2
    (72,52,30,1), -- ROAM_RATE: 30
    (72,68,20,0), -- EVA: 20

-- Corse: https://www.bg-wiki.com/ffxi/Category:Corse
    (74,29,25,0),     -- MDEF: 25
    (74,36,50,1),     -- ROAM_COOL: 50
    (74,51,2,1),      -- ROAM_TURNS: 2
    (74,52,30,1),     -- ROAM_RATE: 30
    (74,388,-5000,0), -- UDMGBREATH: -5000
    (74,389,-2500,0), -- UDMGMAGIC: -2500

-- Crab
    (77,36,15,1), -- ROAM_COOL: 15

-- Crawler
    (79,36,55,1),  -- ROAM_COOL: 55
    (79,52,30,1),  -- ROAM_RATE: 30

-- Dhalmel
    (80,36,30,1),  -- ROAM_COOL: 30
    (80,51,2,1),   -- ROAM_TURNS: 2
    (80,52,30,1),  -- ROAM_RATE: 30

-- Diremite
    (81,36,50,1),  -- ROAM_COOL: 50
    (81,51,2,1),   -- ROAM_TURNS: 2

-- Doll
    (84,31,5,1),  -- ROAM_DISTANCE: 5
    (84,36,55,1), -- ROAM_COOL: 55
    (84,52,30,1), -- ROAM_RATE: 30

-- Doll
    (85,31,5,1),  -- ROAM_DISTANCE: 5
    (85,36,55,1), -- ROAM_COOL: 55
    (85,52,30,1), -- ROAM_RATE: 30

-- Doomed
    (86,36,55,1),   -- ROAM_COOL: 55
    (86,52,30,1),   -- ROAM_RATE: 30

-- Dragon
    (87,3,10,1),    -- MP_BASE: 10
    (87,4,18,1),    -- SIGHT_RANGE: 18
    (87,5,10,1),    -- SOUND_RANGE: 10
    (87,36,55,1),   -- ROAM_COOL: 55
    (87,54,1000,1), -- GIL_BONUS: 1000
    (87,62,20,0),   -- ATTP: 20

-- Dynamisstatue-Goblin
    (92,23,2047,1), -- IMMUNITY: 2047
    (92,56,-1,1),   -- HP_STANDBACK: -1
    (92,73,100,0),  -- STORETP: 100

-- Dynamisstatue-Orc
    (93,23,2047,1), -- IMMUNITY: 2047
    (93,56,-1,1),   -- HP_STANDBACK: -1
    (93,73,100,0),  -- STORETP: 100

-- Dynamisstatue-Quadav
    (94,23,2047,1), -- IMMUNITY: 2047
    (94,56,-1,1),   -- HP_STANDBACK: -1
    (94,73,100,0),  -- STORETP: 100

-- Dynamisstatue-Yagudo
    (95,23,2047,1), -- IMMUNITY: 2047
    (95,56,-1,1),   -- HP_STANDBACK: -1
    (95,73,100,0),  -- STORETP: 100

-- Lizard-Ice
    (97,36,60,1), -- ROAM_COOL: 60
    (97,51,4,1),  -- ROAM_TURNS: 4
    (97,52,30,1), -- ROAM_RATE: 30

-- Eft
    (98,36,50,1), -- ROAM_COOL: 50
    (98,51,5,1),  -- ROAM_TURNS: 5
    (98,52,30,1), -- ROAM_RATE: 30

-- Elemental-Air
    (99,51,3,1),  -- ROAM_TURNS: 3
    (99,56,-1,1), -- HP_STANDBACK: -1

-- Elemental-Dark
    (100,51,3,1),  -- ROAM_TURNS: 3
    (100,56,-1,1), -- HP_STANDBACK: -1

-- Elemental-Earth
    (101,51,3,1),  -- ROAM_TURNS: 3
    (101,56,-1,1), -- HP_STANDBACK: -1

-- Elemental-Fire
    (102,51,3,1),  -- ROAM_TURNS: 3
    (102,56,-1,1), -- HP_STANDBACK: -1

-- Elemental-Ice
    (103,51,3,1),  -- ROAM_TURNS: 3
    (103,56,-1,1), -- HP_STANDBACK: -1

-- Elemental-Light
    (104,51,3,1),  -- ROAM_TURNS: 3
    (104,56,-1,1), -- HP_STANDBACK: -1

-- Elemental-Lightning
    (105,51,3,1),  -- ROAM_TURNS: 3
    (105,56,-1,1), -- HP_STANDBACK: -1

-- Elemental-Water
    (106,51,3,1),  -- ROAM_TURNS: 3
    (106,56,-1,1), -- HP_STANDBACK: -1

-- Evil Weapon: https://www.bg-wiki.com/ffxi/Category:Evil_Weapon
    (110,3,50,1),      -- MP_BASE: 50
    (110,36,45,1),     -- ROAM_COOL: 45
    (110,51,3,1),      -- ROAM_TURNS: 3
    (110,52,30,1),     -- ROAM_RATE: 30
    (110,389,-1250,0), -- UDMGMAGIC: -1250

-- Non-Beastmen regular frogs
    (111,62,1,1), -- NO_STANDBACK: 1

-- Flan: https://www.bg-wiki.com/ffxi/Category:Flan
    (112,51,2,1),     -- ROAM_TURNS: 2
    (112,52,30,1),    -- ROAM_RATE: 30
    (112,388,2500,0), -- UDMGBREATH: 2500
    (112,389,2500,0), -- UDMGMAGIC: 2500

-- Fomor
    (115,36,50,1),   -- ROAM_COOL: 50
    (115,51,2,1),    -- ROAM_TURNS: 2
    (115,52,30,1),   -- ROAM_RATE: 30
    (115,54,100,1),  -- GIL_BONUS: 100

-- Funguar
    (116,31,15,1), -- ROAM_DISTANCE: 15
    (116,36,60,1), -- ROAM_COOL: 60
    (116,52,30,1), -- ROAM_RATE: 30

-- Gear
    (119,10,15,1), -- SUBLINK: 15 (Chariot, Gear, Rampart)
    (120,10,15,1), -- SUBLINK: 15 (Chariot, Gear, Rampart)

-- Ghost
    (121,36,50,1),   -- ROAM_COOL: 50
    (121,52,30,1),   -- ROAM_RATE: 30

-- Ghrah: https://www.bg-wiki.com/ffxi/Category:Ghrah
    (122,389,-1250,0), -- UDMGMAGIC: -1250

-- Greater Bird
    (125,36,40,1),   -- ROAM_COOL: 40
    (125,51,2,1),    -- ROAM_TURNS: 2
    (125,52,30,1),   -- ROAM_RATE: 30

-- Gigas
    (126,31,5,1),   -- ROAM_DISTANCE: 5
    (126,36,25,1),  -- ROAM_COOL: 25
    (126,51,2,1),   -- ROAM_TURNS: 2
    (126,52,30,1),  -- ROAM_RATE: 30
    (126,54,180,1), -- GIL_BONUS: 180

-- Goblin
    (133,10,5,1), -- SUBLINK: 5 (Bugbear, Goblin, Moblin)

-- Golem
    (135,4,4,1),   -- SIGHT_RANGE: 4
    (135,31,5,1),  -- ROAM_DISTANCE: 5
    (135,36,55,1), -- ROAM_COOL: 55
    (135,52,30,1), -- ROAM_RATE: 30

-- Goobbue
    (136,31,5,1),   -- ROAM_DISTANCE: 5
    (136,36,60,1),  -- ROAM_COOL: 60
    (136,52,30,1),  -- ROAM_RATE: 30
    (136,62,10,0),  -- ATTP: 10

-- Hecteyes
    (139,36,55,1),   -- ROAM_COOL: 55
    (139,52,30,1),   -- ROAM_RATE: 30
    (139,56,-1,1),   -- HP_STANDBACK: -1
    (139,68,10,0),   -- EVA: 10

-- Hippogryph
    (140,3,50,1),  -- MP_BASE: 50
    (140,36,55,1), -- ROAM_COOL: 55
    (140,51,2,1),  -- ROAM_TURNS: 2

-- Hippogryph-High Res
    (141,3,50,1),  -- MP_BASE: 50
    (141,36,55,1), -- ROAM_COOL: 55
    (141,51,2,1),  -- ROAM_TURNS: 2

-- Hound
    (142,36,50,1),   -- ROAM_COOL: 50
    (142,51,3,1),    -- ROAM_TURNS: 3
    (142,52,30,1),   -- ROAM_RATE: 30

-- Hound
    (143,36,50,1),   -- ROAM_COOL: 50
    (143,51,3,1),    -- ROAM_TURNS: 3
    (143,52,30,1),   -- ROAM_RATE: 30

-- Humanoid-Hume
    (150,4,30,1), -- SIGHT_RANGE: 30

-- Hybridelemental-Air
    (155,51,3,1), -- ROAM_TURNS: 3

-- Hybridelemental-Dark
    (156,51,3,1), -- ROAM_TURNS: 3

-- Hybridelemental-Earth
    (157,51,3,1), -- ROAM_TURNS: 3

-- Hybridelemental-Fire
    (158,51,3,1), -- ROAM_TURNS: 3

-- Hybridelemental-Ice
    (159,51,3,1), -- ROAM_TURNS: 3

-- Hybridelemental-Light
    (160,51,3,1), -- ROAM_TURNS: 3

-- Hybridelemental-Lightning
    (161,51,3,1), -- ROAM_TURNS: 3

-- Hybridelemental-Water
    (162,51,3,1), -- ROAM_TURNS: 3

-- Hydra
    (163,31,5,1),  -- ROAM_DISTANCE: 5
    (163,36,55,1), -- ROAM_COOL: 55

-- Hydra
    (164,31,5,1),  -- ROAM_DISTANCE: 5
    (164,36,55,1), -- ROAM_COOL: 55

-- Imp
    (165,10,13,1), -- SUBLINK: 13 (Imps)
    (165,29,24,0), -- MDEF: 24
    (165,36,50,1), -- ROAM_COOL: 50
    (165,51,3,1),  -- ROAM_TURNS: 3
    (165,56,-1,1), -- HP_STANDBACK: -1
    (165,4,10,1),  -- SIGHT_RANGE: 10
    (165,5,5,1),   -- SOUND_RANGE: 5

-- Imp
    (166,10,13,1), -- SUBLINK: 13 (Imps)
    (166,36,50,1), -- ROAM_COOL: 50
    (166,51,3,1),  -- ROAM_TURNS: 3
    (166,56,-1,1), -- HP_STANDBACK: -1
    (166,4,10,1),  -- SIGHT_RANGE: 10
    (166,5,5,1),   -- SOUND_RANGE: 5

-- Kindred: https://www.bg-wiki.com/ffxi/Category:Demon
    (169,10,1,1),      -- SUBLINK: 1 (Kindred, Tauri)
    (169,11,15,1),     -- LINK_RADIUS: 15
    (169,29,25,0),     -- MDEF: 25
    (169,31,15,1),     -- ROAM_DISTANCE: 15
    (169,36,50,1),     -- ROAM_COOL: 50
    (169,51,3,1),      -- ROAM_TURNS: 3
    (169,54,120,1),    -- GIL_BONUS: 120
    (169,389,-2500,0), -- UDMGMAGIC: -2500

-- Lamiae: https://www.bg-wiki.com/ffxi/Category:Lamiae
    (171,10,10,1),     -- SUBLINK: 10 (Lamiae)
    (171,29,13,0),     -- MDEF: 13
    (171,389,-1250,0), -- UDMGMAGIC: -1250

-- Leech
    (172,31,15,1), -- ROAM_DISTANCE: 15

-- Lizard
    (174,36,60,1), -- ROAM_COOL: 60
    (174,51,4,1),  -- ROAM_TURNS: 4
    (174,52,30,1), -- ROAM_RATE: 30

-- Magic Pot: https://www.bg-wiki.com/ffxi/Category:Magic_Pot
    (175,31,5,1),      -- ROAM_DISTANCE: 5
    (175,36,55,1),     -- ROAM_COOL: 55
    (175,52,30,1),     -- ROAM_RATE: 30
    (175,389,-5000,0), -- UDMGMAGIC: -5000

-- Mamool Ja
    (176,10,8,1),  -- SUBLINK: 8 (Mamool Ja, Sahagin)
    (176,68,10,0), -- EVA: 10

-- Manticore
    (179,31,30,1),  -- ROAM_DISTANCE: 30
    (179,36,60,1),  -- ROAM_COOL: 60
    (179,51,4,1),   -- ROAM_TURNS: 4
    (179,52,30,1),  -- ROAM_RATE: 30
    (179,62,10,0),  -- ATTP: 10

-- Marid
    (180,36,30,1), -- ROAM_COOL: 30
    (180,51,2,1),  -- ROAM_TURNS: 2
    (180,52,30,1), -- ROAM_RATE: 30
    (180,63,20,0), -- DEFP: 20

-- Merrow
    (182,10,10,1), -- SUBLINK: 10 (Lamiae)

-- Moblin
    (184,10,5,1), -- SUBLINK: 5 (Bugbear, Goblin, Moblin)

-- Morbol
    (186,36,30,1), -- ROAM_COOL: 30
    (186,52,30,1), -- ROAM_RATE: 30

-- Opo-Opo
    (188,36,35,1), -- ROAM_COOL: 35
    (188,51,3,1),  -- ROAM_TURNS: 3
    (188,52,20,1), -- ROAM_RATE: 20

-- Orc
    (189,10,2,1), -- SUBLINK: 2 (Orc, Orc Warmachine)

-- Orc-Warmachine
    (190,10,2,1),  -- SUBLINK: 2 (Orc, Orc Warmachine)
    (190,36,50,1), -- ROAM_COOL: 50
    (190,52,30,1), -- ROAM_RATE: 30

-- Wyvern-Pet
    (193,3,40,1), -- MP_BASE: 40

-- Phuabo
    (194,3,50,1), -- MP_BASE: 50

-- Qiqirn
    (199,10,12,1), -- SUBLINK: 12 (Qiqirn)

-- Qutrub
    (203,36,50,1),   -- ROAM_COOL: 50
    (203,51,3,1),    -- ROAM_TURNS: 3
    (203,52,30,1),   -- ROAM_RATE: 30

-- Rabbit
    (206,31,15,1), -- ROAM_DISTANCE: 15
    (206,36,35,1), -- ROAM_COOL: 35
    (206,51,3,1),  -- ROAM_TURNS: 3
    (206,52,30,1), -- ROAM_RATE: 30

-- Rafflesia
    (207,3,50,1), -- MP_BASE: 50

-- Ram
    (208,36,60,1),  -- ROAM_COOL: 60
    (208,52,30,1),  -- ROAM_RATE: 30
    (208,62,10,0),  -- ATTP: 10
    (208,63,20,0),  -- DEFP: 20

-- Rampart
    (209,10,15,1), -- SUBLINK: 15 (Chariot, Gear, Rampart)

-- Raptor
    (210,31,30,1),  -- ROAM_DISTANCE: 30
    (210,36,40,1),  -- ROAM_COOL: 40
    (210,51,3,1),   -- ROAM_TURNS: 3

-- Sabotender
    (212,10,7,1),  -- SUBLINK: 7 (Sabotender)
    (212,36,10,1), -- ROAM_COOL: 10
    (212,52,20,1), -- ROAM_RATE: 20

-- Sahagin
    (213,10,8,1),   -- SUBLINK: 8 (Mamool Ja, Sahagin)
    (213,20,128,0), -- WATER_MEVA: 128

-- Sapling
    (216,10,4,1),  -- SUBLINK: 4 (Sapling, Treant)
    (216,31,20,1), -- ROAM_DISTANCE: 20

-- Scorpion
    (217,23,256,1), -- IMMUNITY: 256
    (217,36,55,1),  -- ROAM_COOL: 55
    (217,52,30,1),  -- ROAM_RATE: 30
    (217,62,20,0),  -- ATTP: 20

-- Sea Monk
    (218,36,30,1), -- ROAM_COOL: 30

-- Sea Monk
    (219,36,30,1), -- ROAM_COOL: 30

-- Shadow
    (221,36,50,1),   -- ROAM_COOL: 50
    (221,51,2,1),    -- ROAM_TURNS: 2
    (221,52,30,1),   -- ROAM_RATE: 30

-- Sheep
    (226,31,15,1), -- ROAM_DISTANCE: 15
    (226,36,60,1), -- ROAM_COOL: 60
    (226,51,5,1),  -- ROAM_TURNS: 5
    (226,52,30,1), -- ROAM_RATE: 30

-- Skeleton
    (227,36,65,1),   -- ROAM_COOL: 65
    (227,51,5,1),    -- ROAM_TURNS: 5
    (227,52,30,1),   -- ROAM_RATE: 30

-- Snoll
    (232,36,40,1), -- ROAM_COOL: 40
    (232,51,2,1),  -- ROAM_TURNS: 2
    (232,52,20,1), -- ROAM_RATE: 20

-- Soulflayer
    (233,10,11,1), -- SUBLINK: 11 (Soulflayers)
    (233,36,50,1), -- ROAM_COOL: 50
    (233,51,3,1),  -- ROAM_TURNS: 3

-- Spheroid
    (234,37,1,1), -- ALWAYS_AGGRO: 1

-- Structure
    (236,4,30,1), -- SIGHT_RANGE: 30

-- Tauri
    (240,10,1,1),   -- SUBLINK: 1 (Kindred, Tauri)
    (240,36,40,1),  -- ROAM_COOL: 40
    (240,51,3,1),   -- ROAM_TURNS: 3
    (240,52,30,1),  -- ROAM_RATE: 30

-- Tiger
    (242,31,15,1),  -- ROAM_DISTANCE: 15
    (242,36,45,1),  -- ROAM_COOL: 45
    (242,51,3,1),   -- ROAM_TURNS: 3
    (242,62,10,0),  -- ATTP: 10

-- Tonberry
    (243,36,25,1), -- ROAM_COOL: 25
    (243,51,5,1),  -- ROAM_TURNS: 5
    (243,52,30,1), -- ROAM_RATE: 30

-- Tonberry
    (244,36,25,1), -- ROAM_COOL: 25
    (244,51,5,1),  -- ROAM_TURNS: 5
    (244,52,30,1), -- ROAM_RATE: 30

-- Treant
    (245,10,4,1),  -- SUBLINK: 4 (Sapling, Treant)
    (245,36,65,1), -- ROAM_COOL: 65
    (245,52,30,1), -- ROAM_RATE: 30
    (245,63,20,0), -- DEFP: 20

-- Troll
    (246,10,9,1), -- SUBLINK: 9 (Trolls)

-- Uragnite
    (251,36,40,1), -- ROAM_COOL: 40
    (251,52,30,1), -- ROAM_RATE: 30

-- Wamoura
    (253,3,50,1), -- MP_BASE: 50
    (253,10,6,1), -- SUBLINK: 6 (Wamoura, Wamouracampa)

-- Wamouracampa
    (254,10,6,1), -- SUBLINK: 6 (Wamouracampa, Brassborer)

-- Wanderer
    (255,3,50,1), -- MP_BASE: 50

-- Wivre
    (257,36,50,1), -- ROAM_COOL: 50
    (257,52,30,1), -- ROAM_RATE: 30

-- Worm
    (258,34,25,1), -- MAGIC_COOL: 25
    (258,36,90,1), -- ROAM_COOL: 90
    (258,52,30,1), -- ROAM_RATE: 30

-- Wyrm-Ouryu
    (259,36,55,1),  -- ROAM_COOL: 55

-- Wyrm-Fafnir
    (260,36,55,1),  -- ROAM_COOL: 55

-- Wyrm-Cynoprosopi
    (261,36,55,1),  -- ROAM_COOL: 55

-- Wyrm
    (262,36,55,1),  -- ROAM_COOL: 55

-- Wyrm-Nidhogg
    (263,36,55,1),  -- ROAM_COOL: 55

-- Wyrm
    (264,36,55,1),  -- ROAM_COOL: 55

-- Wyvern-Simorg
    (265,36,55,1),  -- ROAM_COOL: 55

-- Wyvern
    (266,36,55,1),  -- ROAM_COOL: 55

-- Wyvern-Undead
    (268,36,55,1),  -- ROAM_COOL: 55

-- Yovra
    (271,3,50,1), -- MP_BASE: 50

-- Zdei
    (272,4,10,1),    -- SIGHT_RANGE: 10
    (272,102,60,1),  -- MOBMOD_SIGHT_ANGLE

-- Scorpion-Kingv
    (274,23,256,1), -- IMMUNITY: 256

-- Mamool Ja
    (285,10,8,1),  -- SUBLINK: 8 (Mamool Ja, Sahagin)
    (285,68,10,0), -- EVA: 10

-- Qiqirn-Cheese Hoarder
    (288,10,12,1), -- SUBLINK: 12 (Qiqirn)

-- Wamouracampa-Brassborer
    (289,10,6,1), -- SUBLINK: 6 (Wamoura, Wamouracampa)

-- Apkallu-Small
    (294,10,14,1), -- SUBLINK: 14 (Apkallu)

-- Imp-Verdelet
    (301,10,13,1), -- SUBLINK: 13 (Imps)

-- Wamoura-Achamoth
    (307,10,6,1), -- SUBLINK: 6 (Wamoura, Wamouracampa)

-- Troll-Khromasoul
    (308,10,9,1), -- SUBLINK: 9 (Trolls)

-- Vampyr
    (309,10,3,1),  -- SUBLINK: 3 (Single Bat, Bat Trio, Vampyr)
    (309,36,50,1), -- ROAM_COOL: 50
    (309,51,2,1),  -- ROAM_TURNS: 2
    (309,52,30,1), -- ROAM_RATE: 30

-- Experimentalla
    (310,10,10,1), -- SUBLINK: 10 (Lamiae)

-- Soulflayer-Mahjlaefthepai
    (311,10,11,1), -- SUBLINK: 11 (Soulflayers)

-- Troll-Gurfurlur
    (326,10,9,1), -- SUBLINK: 9 (Trolls)

-- Antlion-Ambush
    (357,63,20,0), -- DEFP: 20

-- Kindred: https://www.bg-wiki.com/ffxi/Category:Demon
    (358,10,1,1),      -- SUBLINK: 1 (Kindred, Tauri)
    (358,11,15,1),     -- LINK_RADIUS: 15
    (358,31,15,1),     -- ROAM_DISTANCE: 15
    (358,36,50,1),     -- ROAM_COOL: 50
    (358,51,3,1),      -- ROAM_TURNS: 3
    (358,54,120,1),    -- GIL_BONUS: 120
    (358,389,-2500,0), -- UDMGMAGIC: -2500

-- Fomor
    (359,36,50,1),   -- ROAM_COOL: 50
    (359,51,2,1),    -- ROAM_TURNS: 2
    (359,52,30,1),   -- ROAM_RATE: 30
    (359,54,100,1),  -- GIL_BONUS: 100

-- Fomor-ToAU
    (360,36,50,1),   -- ROAM_COOL: 50
    (360,51,2,1),    -- ROAM_TURNS: 2
    (360,52,30,1),   -- ROAM_RATE: 30
    (360,54,100,1),  -- GIL_BONUS: 100

-- Sabotender-Florido
    (362,10,7,1), -- SUBLINK: 7 (Sabotender)

-- Leech
    (369,31,15,1), -- ROAM_DISTANCE: 15

-- Humanoid-Hume
    (394,4,30,1),   -- SIGHT_RANGE: 30
    (394,41,988,1), -- TELEPORT_START: 988
    (394,42,989,1), -- TELEPORT_END: 989
    (394,43,2,1),   -- TELEPORT_TYPE: 2

-- Rabbit-Cure
    (404,31,15,1), -- ROAM_DISTANCE: 15
    (404,36,35,1), -- ROAM_COOL: 35
    (404,51,3,1),  -- ROAM_TURNS: 3
    (404,52,30,1), -- ROAM_RATE: 30

-- Lamiae-Medusa
    (469,10,10,1), -- SUBLINK: 10 (Lamiae)

-- Ajido-Marujido
    (481,41,988,1), -- TELEPORT_START: 988
    (481,42,989,1), -- TELEPORT_END: 989

-- Astral Flow Pet
    (495,56,-1,1), -- HP_STANDBACK: -1

-- Apkallu
    (27,4,5,1), -- SIGHT_RANGE: 5

-- Flan
    (112,56,-1,1), -- HP_STANDBACK: -1
    (112,69,1,1)  -- NO_LINK: 1
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `value` = IF(`value` <> VALUES(`value`), VALUES(`value`), `value`),
    `is_mob_mod` = IF(`is_mob_mod` <> VALUES(`is_mob_mod`), VALUES(`is_mob_mod`), `is_mob_mod`)
;

/*!40000 ALTER TABLE `mob_family_mods` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
