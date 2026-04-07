SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `exp_base`
--

DROP TABLE IF EXISTS `exp_base`;

CREATE TABLE IF NOT EXISTS `exp_base` (
  `level` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `exp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`level`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=9;

--
-- Contenu de la table `exp_base`
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

insert into `exp_base`
(
    `level`, `exp`
)
VALUES
    (1,0),
    (2,500),
    (3,750),
    (4,1000),
    (5,1250),
    (6,1500),
    (7,1750),
    (8,2000),
    (9,2200),
    (10,2400),
    (11,2600),
    (12,2800),
    (13,3000),
    (14,3200),
    (15,3400),
    (16,3600),
    (17,3800),
    (18,4000),
    (19,4200),
    (20,4400),
    (21,4600),
    (22,4800),
    (23,5000),
    (24,5100),
    (25,5200),
    (26,5300),
    (27,5400),
    (28,5500),
    (29,5600),
    (30,5700),
    (31,5800),
    (32,5900),
    (33,6000),
    (34,6100),
    (35,6200),
    (36,6300),
    (37,6400),
    (38,6500),
    (39,6600),
    (40,6700),
    (41,6800),
    (42,6900),
    (43,7000),
    (44,7100),
    (45,7200),
    (46,7300),
    (47,7400),
    (48,7500),
    (49,7600),
    (50,7700),
    (51,7800),
    (52,8000),
    (53,9200),
    (54,10400),
    (55,11600),
    (56,12800),
    (57,14000),
    (58,15200),
    (59,16400),
    (60,17600),
    (61,18800),
    (62,20000),
    (63,21500),
    (64,23000),
    (65,24500),
    (66,26000),
    (67,27500),
    (68,29000),
    (69,30500),
    (70,32000),
    (71,34000),
    (72,36000),
    (73,38000),
    (74,40000),
    (75,42000),
    (76,44000),
    (77,44500),
    (78,45000),
    (79,45500),
    (80,46000),
    (81,46500),
    (82,47000),
    (83,47500),
    (84,48000),
    (85,48500),
    (86,49000),
    (87,49500),
    (88,50000),
    (89,50500),
    (90,51000),
    (91,51500),
    (92,52000),
    (93,52500),
    (94,53000),
    (95,53500),
    (96,54000),
    (97,54500),
    (98,55000),
    (99,55500),
    (100,56000)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `exp` = IF(`exp` <> VALUES(`exp`), VALUES(`exp`), `exp`)
;
