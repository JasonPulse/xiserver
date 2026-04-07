SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `item_mods_pet`
--

DROP TABLE IF EXISTS `guilds`;

CREATE TABLE IF NOT EXISTS `guilds` (
  `id` tinyint(1) unsigned NOT NULL,
  `points_name` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=13 PACK_KEYS=1;

LOCK TABLES `guilds` WRITE;

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

insert into `guilds`
(
    `id`, `points_name`
)
VALUES
    (0,'guild_fishing'),
    (1,'guild_woodworking'),
    (2,'guild_smithing'),
    (3,'guild_goldsmithing'),
    (4,'guild_weaving'),
    (5,'guild_leathercraft'),
    (6,'guild_bonecraft'),
    (7,'guild_alchemy'),
    (8,'guild_cooking')
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `points_name` = IF(`points_name` <> VALUES(`points_name`), VALUES(`points_name`), `points_name`)
;

UNLOCK TABLES;
