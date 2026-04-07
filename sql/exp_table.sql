SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `exp_table`
--

DROP TABLE IF EXISTS `exp_table`;

CREATE TABLE IF NOT EXISTS `exp_table` (
  `level` tinyint(2) NOT NULL,
  `r1` smallint(4) unsigned NOT NULL DEFAULT '0',  -- 1 to 5
  `r2` smallint(4) unsigned NOT NULL DEFAULT '0',  -- 6 to 10
  `r3` smallint(4) unsigned NOT NULL DEFAULT '0',  -- 11 to 15
  `r4` smallint(4) unsigned NOT NULL DEFAULT '0',  -- 16 to 20
  `r5` smallint(4) unsigned NOT NULL DEFAULT '0',  -- 21 to 25
  `r6` smallint(4) unsigned NOT NULL DEFAULT '0',  -- 26 to 30
  `r7` smallint(4) unsigned NOT NULL DEFAULT '0',  -- 31 to 35
  `r8` smallint(4) unsigned NOT NULL DEFAULT '0',  -- 36 to 40
  `r9` smallint(4) unsigned NOT NULL DEFAULT '0',  -- 41 to 45
  `r10` smallint(4) unsigned NOT NULL DEFAULT '0', -- 46 to 50
  `r11` smallint(4) unsigned NOT NULL DEFAULT '0', -- 51 to 55
  `r12` smallint(4) unsigned NOT NULL DEFAULT '0', -- 56 to 60
  `r13` smallint(4) unsigned NOT NULL DEFAULT '0', -- 61 to 65
  `r14` smallint(4) unsigned NOT NULL DEFAULT '0', -- 66 to 70
  `r15` smallint(4) unsigned NOT NULL DEFAULT '0', -- 71 to 75
  `r16` smallint(4) unsigned NOT NULL DEFAULT '0', -- 76 to 80
  `r17` smallint(4) unsigned NOT NULL DEFAULT '0', -- 81 to 85
  `r18` smallint(4) unsigned NOT NULL DEFAULT '0', -- 86 to 90
  `r19` smallint(4) unsigned NOT NULL DEFAULT '0', -- 91 to 95
  `r20` smallint(4) unsigned NOT NULL DEFAULT '0', -- 96 to 99
  PRIMARY KEY (`level`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=65;

--
-- Contenu de la table `exp_table`
--

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

insert into `exp_table`
(
    `level`, `r1`, `r2`, `r3`, `r4`, `r5`, `r6`, `r7`, `r8`, `r9`, `r10`,
    `r11`, `r12`, `r13`, `r14`, `r15`, `r16`, `r17`, `r18`, `r19`, `r20`
)
VALUES
    (15,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,1500),
    (14,800,800,800,800,800,800,800,800,800,800,800,800,720,720,720,720,720,720,720,1500),
    (13,800,800,800,800,800,800,720,720,720,720,720,720,630,630,630,630,630,630,630,1500),
    (12,720,720,720,720,720,720,630,630,630,630,630,630,580,580,580,580,580,580,580,1400),
    (11,630,630,630,630,630,630,580,580,580,580,580,580,530,530,530,530,530,530,530,1300),
    (10,580,580,580,580,580,580,530,530,530,530,530,530,480,480,480,480,480,480,480,1200),
    (9,720,720,720,720,720,720,600,600,600,600,530,480,440,440,440,400,400,400,400,1100),
    (8,600,600,600,600,600,600,550,550,550,530,480,430,400,400,400,380,380,380,380,1000),
    (7,550,550,550,550,550,550,500,500,500,470,430,380,360,360,360,340,340,340,340,900),
    (6,450,450,450,450,450,450,450,450,450,400,370,330,320,320,320,300,300,300,300,800),
    (5,350,350,350,350,350,350,400,400,400,340,310,280,280,280,280,260,260,260,260,700),
    (4,310,310,310,310,310,310,300,300,300,310,280,280,280,280,260,260,240,240,240,600),
    (3,260,260,260,260,260,260,300,300,300,300,300,300,300,300,300,320,320,320,320,500),
    (2,240,240,240,240,240,240,250,250,250,250,250,260,260,260,260,280,280,280,280,400),
    (1,220,220,220,220,220,220,225,225,225,225,225,230,230,230,230,240,240,240,240,300),
    (0,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200),
    (-1,180,180,180,180,180,180,186,192,192,192,192,192,192,192,195,195,195,195,195,195),
    (-2,160,160,160,160,160,160,172,172,180,180,186,186,186,186,190,190,190,190,190,190),
    (-3,140,140,150,150,150,150,160,160,170,170,180,180,180,180,184,184,184,184,184,185),
    (-4,130,130,140,140,140,140,150,152,160,160,170,170,172,172,180,180,180,180,180,180),
    (-5,120,120,130,130,130,130,140,146,152,152,160,160,166,166,172,172,172,172,172,172),
    (-6,100,100,120,120,120,120,130,140,146,146,152,152,160,160,166,166,166,166,166,166),
    (-7,0,80,110,110,110,110,120,130,140,140,146,146,152,154,160,160,160,160,160,160),
    (-8,0,60,90,90,100,100,110,120,130,132,140,140,146,150,155,155,155,155,155,155),
    (-9,0,0,80,80,80,80,100,110,120,126,132,132,140,144,150,150,150,150,150,150),
    (-10,0,0,0,0,80,80,80,100,110,120,126,126,132,140,145,145,145,145,145,145),
    (-11,0,0,0,0,0,0,60,80,100,110,120,120,126,132,140,140,140,140,140,140),
    (-12,0,0,0,0,0,0,0,60,80,100,110,112,120,126,132,132,132,132,132,132),
    (-13,0,0,0,0,0,0,0,0,60,80,100,106,112,120,126,126,126,126,126,126),
    (-14,0,0,0,0,0,0,0,0,0,60,90,100,106,112,120,120,120,120,120,120),
    (-15,0,0,0,0,0,0,0,0,0,0,80,90,100,106,112,112,112,112,112,112),
    (-16,0,0,0,0,0,0,0,0,0,0,0,80,80,100,106,106,106,106,106,106),
    (-17,0,0,0,0,0,0,0,0,0,0,0,0,60,80,100,100,100,100,100,100),
    (-18,0,0,0,0,0,0,0,0,0,0,0,0,0,60,90,90,90,90,90,90),
    (-19,0,0,0,0,0,0,0,0,0,0,0,0,0,0,80,80,80,80,80,80),
    (-20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,60,70,70,70,70,70),
    (-21,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,60,60,60,60,60),
    (-22,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,55,55,55,55,55),
    (-23,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,50,50,50,50,50),
    (-24,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,48,48,48,48,48),
    (-25,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,45,45,45,45,45),
    (-26,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,42,42,42,42,42),
    (-27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,40,40,40,40,40),
    (-28,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,38,38,38,38,38),
    (-29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,36,36,36,36,36),
    (-30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,34,34,34,34,34),
    (-31,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,32,32,32,32),
    (-32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,30,30,30,30,30),
    (-33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,28,28,28,28,28),
    (-34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,26,26,26,26,26),
    (-35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,24,24,24,24,24),
    (-36,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,22,22,22,22),
    (-37,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,20,20,20,20),
    (-38,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19,19,19,19,19),
    (-39,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,18,18,18,18,18),
    (-40,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,17,17,17,17,17),
    (-41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,16),
    (-42,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,15,15,15,15),
    (-43,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,14,14,14,14),
    (-44,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `r1` = IF(`r1` <> VALUES(`r1`), VALUES(`r1`), `r1`),
    `r2` = IF(`r2` <> VALUES(`r2`), VALUES(`r2`), `r2`),
    `r3` = IF(`r3` <> VALUES(`r3`), VALUES(`r3`), `r3`),
    `r4` = IF(`r4` <> VALUES(`r4`), VALUES(`r4`), `r4`),
    `r5` = IF(`r5` <> VALUES(`r5`), VALUES(`r5`), `r5`),
    `r6` = IF(`r6` <> VALUES(`r6`), VALUES(`r6`), `r6`),
    `r7` = IF(`r7` <> VALUES(`r7`), VALUES(`r7`), `r7`),
    `r8` = IF(`r8` <> VALUES(`r8`), VALUES(`r8`), `r8`),
    `r9` = IF(`r9` <> VALUES(`r9`), VALUES(`r9`), `r9`),
    `r10` = IF(`r10` <> VALUES(`r10`), VALUES(`r10`), `r10`),
    `r11` = IF(`r11` <> VALUES(`r11`), VALUES(`r11`), `r11`),
    `r12` = IF(`r12` <> VALUES(`r12`), VALUES(`r12`), `r12`),
    `r13` = IF(`r13` <> VALUES(`r13`), VALUES(`r13`), `r13`),
    `r14` = IF(`r14` <> VALUES(`r14`), VALUES(`r14`), `r14`),
    `r15` = IF(`r15` <> VALUES(`r15`), VALUES(`r15`), `r15`),
    `r16` = IF(`r16` <> VALUES(`r16`), VALUES(`r16`), `r16`),
    `r17` = IF(`r17` <> VALUES(`r17`), VALUES(`r17`), `r17`),
    `r18` = IF(`r18` <> VALUES(`r18`), VALUES(`r18`), `r18`),
    `r19` = IF(`r19` <> VALUES(`r19`), VALUES(`r19`), `r19`),
    `r20` = IF(`r20` <> VALUES(`r20`), VALUES(`r20`), `r20`)
;
