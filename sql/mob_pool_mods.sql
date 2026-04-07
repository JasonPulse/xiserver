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
-- Table structure for table `mob_pool_mods`
--

DROP TABLE IF EXISTS `mob_pool_mods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mob_pool_mods` (
  `poolid` smallint(5) unsigned NOT NULL,
  `modid` smallint(5) unsigned NOT NULL,
  `value` smallint(5) NOT NULL DEFAULT '0',
  `is_mob_mod` boolean NOT NULL DEFAULT '0',
  PRIMARY KEY (`poolid`,`modid`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=13 PACK_KEYS=1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mob_pool_mods`
--

LOCK TABLES `mob_pool_mods` WRITE;
/*!40000 ALTER TABLE `mob_pool_mods` DISABLE KEYS */;

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

insert into `mob_pool_mods`
(
    `poolid`, `modid`, `value`, `is_mob_mod`
)
VALUES
-- Absolute Virtue
    (21,29,100,0), -- MDEF: 100

-- Adamantoise
    (44,368,150,0), -- REGAIN: 150

-- Agas
    (60,370,20,0), -- REGEN: 20

-- Animated Shield
    (154,163,-1250,0), -- DMGMAGIC: -1250

-- Aspidochelone
    (268,368,150,0), -- REGAIN: 150
    (268,370,50,0),  -- REGEN: 50

-- Aura Statue
    (289,4,4,1), -- SIGHT_RANGE: 4

-- Battle Bugard
    (370,28,5,1), -- EXP_BONUS: 5

-- Biast
    (410,236,20,0), -- HUMANOID_KILLER: 20

-- Bladmall
    (444,23,23,1), -- IMMUNITY: 23

-- Bloodlapper
    (459,23,50,0),  -- ATT: 50
    (459,73,25,0),  -- STORETP: 25
    (459,430,20,0), -- QUAD_ATTACK: 20

-- Bugbby
    (559,62,-50,0),   -- ATTP: -50
-- Byakko
    (592,3,100,1),  -- MP_BASE: 100
    (592,68,15,0),  -- EVA: 15
    (592,302,45,0), -- TRIPLE_ATTACK: 45

-- Cargo Crab Colin
    (639,63,25,0), -- DEFP: 25

-- Cerberus
    (680,1,322,0),   -- DEF: 322
    (680,31,200,0),  -- MEVA: 200
    (680,251,-50,0), -- STUNRES: -50

-- Citipati
    (733,302,5,0), -- TRIPLE_ATTACK: 5

-- Colorful Treant
    (768,28,5,1), -- EXP_BONUS: 5

-- Colossus
    (770,4,4,1), -- SIGHT_RANGE: 4

-- Darksteel Golem
    (906,4,4,1), -- SIGHT_RANGE: 4

-- Dea
    (930,370,15,0), -- REGEN: 15

-- Defender
    (955,28,-100,1), -- EXP_BONUS: -100

-- Defoliate Treant
    (958,28,5,1), -- EXP_BONUS: 5

-- Demonic Rose
    (978,28,23,1), -- EXP_BONUS: 23

-- Demonic Tiphia
    (979,8,60,1), -- HEAL_CHANCE: 60
    (979,9,60,1), -- HP_HEAL_CHANCE: 60

-- Detector
    (1013,28,-100,1), -- EXP_BONUS: -100

-- Effigy Prototype
    (1178,163,-1000,0), -- DMGMAGIC: -1000

-- Enkidu
    (1234,4,4,1), -- SIGHT_RANGE: 4

-- Exoplates
    (1270,39,-1,1), -- SHARE_POS: -1

-- Fafnir
    (1280,368,70,0), -- REGAIN: 70

-- Faust
    (1306,4,30,1), -- SIGHT_RANGE: 30

-- Frostmane
    (1429,28,10,1), -- EXP_BONUS: 10

-- Gambilox Wanderling
    (1456,368,20,0), -- REGAIN: 20

-- Gargantua
    (1461,4,4,1), -- SIGHT_RANGE: 4

-- Genbu
    (1491,3,100,1), -- MP_BASE: 100

-- Gladiatorial Weapon
    (1620,5,18,1),   -- SOUND_RANGE: 18
    (1620,72,22,1),  -- MAGIC_RANGE: 22

-- Goblin Digger Near
    (1648,17,1,1),  -- NO_DESPAWN: 1
    (1648,224,5,0), -- VERMIN_KILLER: 5

-- Goblin Freelance
    (1663,29,3,1), -- ASSIST: 3

-- Goblin Swordsman
    (1719,29,2,1), -- ASSIST: 2

-- Golden-Tongued Culberry
    (1750,56,1,1), -- HP_STANDBACK: 1

-- Goliath
    (1754,4,4,1), -- SIGHT_RANGE: 4

-- Gration
    (1792,368,70,0), -- REGAIN: 70

-- Greater Manticore
    (1806,28,10,1), -- EXP_BONUS: 10

-- Hydras Hound
    (2032,34,20,1),  -- MAGIC_COOL: 20
    (2032,35,0,1),   -- STANDBACK_COOL: 0
    (2032,244,15,0), -- SILENCERES: 15

-- Icon Prototype
    (2047,163,-1000,0), -- DMGMAGIC: -1000

-- Intulo
    (2083,29,25,0), -- MDEF: 25

-- Kaiser Behemoth S
    (2180,3,100,1), -- MP_BASE: 100

-- King Arthro
    (2254,407,100,0), -- UFASTCAST: 100

-- King Behemoth
    (2255,3,100,1),  -- MP_BASE: 100
    (2255,34,60,1),  -- MAGIC_COOL: 60
    (2255,368,70,0), -- REGAIN: 70

-- King Vinegarroon
    (2262,370,125,0), -- REGEN: 125

-- Kirin
    (2265,368,150,0), -- REGAIN: 150
    (2265,370,50,0),  -- REGEN: 50

-- Knight Crab
    (2271,64,15,0),  -- COMBAT_SKILLUP_RATE: 15
    (2271,65,15,0),  -- MAGIC_SKILLUP_RATE: 15
    (2271,165,15,0), -- CRITHITRATE: 15

-- Ladon
    (2314,28,23,1), -- EXP_BONUS: 23

-- Maats Avatar
    (2461,61,25,1), -- HP_SCALE: 25

-- Maats Pet
    (2462,61,25,1), -- HP_SCALE: 25

-- Maats Wyvern
    (2463,61,20,1), -- HP_SCALE: 20

-- Mammet-19 Epsilon
    (2499,240,90,0), -- SLEEPRES: 90

-- Minotaur
    (2675,4,25,1), -- SIGHT_RANGE: 25

-- Morbolger
    (2742,37,1,1), -- ALWAYS_AGGRO: 1

-- Morbol Menace
    (2745,28,23,1), -- EXP_BONUS: 23

-- Morion Worm
    (2748,370,5,0), -- REGEN: 5

-- Mythril Golem
    (2793,4,4,1), -- SIGHT_RANGE: 4

-- Nidhogg
    (2840,368,70,0), -- REGAIN: 70
    (2840,370,50,0), -- REGEN: 50

-- Nunyunuwi
    (2922,370,100,0), -- REGEN: 100

-- Ore Golem
    (3051,4,4,1), -- SIGHT_RANGE: 4

-- Parata
    (3099,23,23,1), -- IMMUNITY: 23

-- Polar Hare
    (3168,28,10,1), -- EXP_BONUS: 10

-- Proto-Omega
    (3208,370,20,0), -- REGEN: 20

-- Qiqirn Archaeologist
    (3245,56,1,1), -- HP_STANDBACK: 1

-- Qiqirn Enterpriser
    (3252,56,1,1), -- HP_STANDBACK: 1

-- Qiqirn Mercenary
    (3257,56,1,1), -- HP_STANDBACK: 1

-- Qiqirn Pecheur
    (3262,56,1,1), -- HP_STANDBACK: 1

-- Qiqirn Rock Hound
    (3264,56,1,1), -- HP_STANDBACK: 1

-- Qiqirn Trailer
    (3265,56,1,1), -- HP_STANDBACK: 1

-- Qiqirn Volcanist
    (3268,56,1,1), -- HP_STANDBACK: 1

-- Race Runner
    (3301,29,100,0), -- MDEF: 100

-- Rock Golem
    (3379,4,4,1), -- SIGHT_RANGE: 4

-- Seiryu
    (3540,3,100,1), -- MP_BASE: 100

-- Serket
    (3549,370,50,0), -- REGEN: 50

-- Slave Globe
    (3667,28,-100,1), -- EXP_BONUS: -100

-- Snoll Tzar
    (3684,3,30,1), -- MP_BASE: 30

-- Statue Prototype
    (3759,163,-1000,0), -- DMGMAGIC: -1000

-- Stone Golem
    (3781,4,4,1), -- SIGHT_RANGE: 4

-- Stray
    (3784,2,-1,1),    -- GIL_MAX: -1
    (3784,28,-100,1), -- EXP_BONUS: -100

-- Stubborn Dredvodd
    (3796,21,97,1), -- PET_SPELL_LIST: 97

-- Suzaku
    (3816,3,100,1), -- MP_BASE: 100

-- Swashstox Beadblinker
    (3824,29,2,1), -- ASSIST: 2

-- Tavnazian Ram
    (3853,28,23,1), -- EXP_BONUS: 23

-- Tiny Mandragora
    (3924,91,1,1), -- H2H_SINGLE_SWING: 1

-- Tombstone Prototype
    (3941,163,-1000,0), -- DMGMAGIC: -1000

-- Tuchulcha
    (4046,23,6191,1), -- IMMUNITY: 6191

-- Ullikummi
    (4082,4,4,1), -- SIGHT_RANGE: 4

-- Vanguard_Armorer
    (4136,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Assassin
    (4137,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Backstabber
    (4138,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Beasttender
    (4139,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Bugler
    (4140,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Chanter
    (4141,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Defender
    (4143,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Drakekeeper
    (4146,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Enchanter
    (4147,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Exemplar
    (4148,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Footsoldier
    (4150,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Gutslasher
    (4152,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Hatamoto
    (4153,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Hawker
    (4154,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Hitman
    (4155,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Impaler
    (4156,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Inciter
    (4157,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Kusa
    (4158,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Liberator
    (4159,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Maestro
    (4160,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Minstrel
    (4164,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Neckchopper
    (4165,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Ogresoother
    (4167,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Partisan
    (4169,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Pathfinder
    (4170,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Persecutor
    (4171,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Pillager
    (4172,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Protector
    (4177,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Purloiner
    (4178,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Ronin
    (4179,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Skirmisher
    (4183,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Smithy
    (4184,75,3,1), -- CAN_PARRY: 3

-- Vanguards Crow
    (4186,34,20,1),  -- MAGIC_COOL: 20
    (4186,35,0,1),   -- STANDBACK_COOL: 0
    (4186,244,15,0), -- SILENCERES: 15

-- Vanguards Hecteyes
    (4187,34,20,1),  -- MAGIC_COOL: 20
    (4187,35,0,1),   -- STANDBACK_COOL: 0
    (4187,244,15,0), -- SILENCERES: 15

-- Vanguards Scorpion
    (4188,34,20,1),  -- MAGIC_COOL: 20
    (4188,35,0,1),   -- STANDBACK_COOL: 0
    (4188,244,15,0), -- SILENCERES: 15

-- Vanguards Slime
    (4189,34,20,1),  -- MAGIC_COOL: 20
    (4189,35,0,1),   -- STANDBACK_COOL: 0
    (4189,244,15,0), -- SILENCERES: 15

-- Vanguard_Tinkerer
    (4192,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Trooper
    (4193,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Vexer
    (4195,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Vigilante
    (4196,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Vindicator
    (4197,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Visionary
    (4198,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Welldigger
    (4199,75,3,1), -- CAN_PARRY: 3

-- Vanguard_Dragontamer
    (4649,75,3,1), -- CAN_PARRY: 3

-- Variable Hare
    (4204,28,10,1), -- EXP_BONUS: 10

-- Verglas Golem
    (4222,4,4,1), -- SIGHT_RANGE: 4

-- Virulent Peiste
    (4238,28,5,1), -- EXP_BONUS: 5

-- Woodland Sage
    (4361,5,16,1),   -- SOUND_RANGE: 16
    (4361,288,55,0), -- DOUBLE_ATTACK: 55

-- Zipacna
    (4504,4,30,1), -- SIGHT_RANGE: 30

-- Genbu Pet
    (4670,3,100,1), -- MP_BASE: 100

-- Seiryu Pet
    (4671,3,100,1), -- MP_BASE: 100

-- Byakko Pet
    (4672,3,100,1), -- MP_BASE: 100

-- Suzaku Pet
    (4673,3,100,1), -- MP_BASE: 100

-- Maat Blm
    (4836,62,1,1), -- NO_STANDBACK: 1

-- Maat Rng
    (4837,62,1,1), -- NO_STANDBACK: 1

-- Maat Bst
    (4932,30,1017,1), -- SPECIAL_SKILL: 1017
    (4932,33,50,1),   -- SPECIAL_COOL: 50

-- Maat Nin
    (5403,62,1,1), -- NO_STANDBACK: 1

-- Maat Pld
    (5408,30,1036,1), -- SPECIAL_SKILL: 1036
    (5408,33,50,1),   -- SPECIAL_COOL: 50
    (5408,58,40,1),   -- SPECIAL_DELAY: 40

-- Maat Drk
    (5409,30,1036,1), -- SPECIAL_SKILL: 1036
    (5409,33,50,1),   -- SPECIAL_COOL: 50
    (5409,58,40,1),   -- SPECIAL_DELAY: 40

-- Trust: Shikaree Z
    (5915,6,100,0),      -- MPP: 100

-- Trust: Lehko
    (5922,6,150,0),      -- MPP: 150

-- Trust: Fablinix
    (5932,6,250,0),    -- MPP: 250

-- Trust: Karaha-Baruha
    (5936,3,-10,0), -- HPP: -10
    (5936,6,20,0), -- MPP: 20

-- Trust: Areuhat
    (5939,1046,30,0), -- ENHANCES_BLOOD_RAGE: 30
    (5939,234,8,0),  -- DEMON_KILLER: 8

-- Trust: Ferreous Coffin
    (5944,3,-10,0),      -- HPP: -10
    (5944,6,35,0),       -- MPP: 35

-- Trust: Rahal
    (5951,233,8,0), -- DRAGON_KILLER: 8

-- Trust: Prishe II
    (6011,165,25,0),     -- CRITHITRATE: 25

-- Trust: Shantotto II
    (6019,3,-10,0),      -- HPP: -10

-- Kaiser Behemoth (Apollyon NW)
    (6732,3,100,1) -- MP_BASE: 100
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `value` = IF(`value` <> VALUES(`value`), VALUES(`value`), `value`),
    `is_mob_mod` = IF(`is_mob_mod` <> VALUES(`is_mob_mod`), VALUES(`is_mob_mod`), `is_mob_mod`)
;

/*!40000 ALTER TABLE `mob_pool_mods` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
