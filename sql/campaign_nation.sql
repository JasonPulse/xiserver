-- MySQL dump 10.16  Distrib 10.2.8-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: dspdb
-- ------------------------------------------------------
-- Server version    10.2.8-MariaDB

--
-- Table structure for table `campaign_nation`
--

DROP TABLE IF EXISTS `campaign_nation`;

CREATE TABLE `campaign_nation` (
  `id` tinyint(2) unsigned NOT NULL,
  `reconnaissance` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `morale` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `prosperity` tinyint(2) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `campaign_nation`
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

insert into `campaign_nation`
(
    `id`, `reconnaissance`, `morale`, `prosperity`
)
VALUES
    (0,0,0,0), -- Sandoria
    (1,0,0,0), -- Bastok
    (2,0,0,0), -- Windurst
    (3,0,0,0), -- Orcish
    (4,0,0,0), -- Quadav
    (5,0,0,0), -- Yagudio
    (6,0,0,0) -- Kindred
-- Dump completed on 2018-06-09 17:04:32
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `reconnaissance` = IF(`reconnaissance` <> VALUES(`reconnaissance`), VALUES(`reconnaissance`), `reconnaissance`),
    `morale` = IF(`morale` <> VALUES(`morale`), VALUES(`morale`), `morale`),
    `prosperity` = IF(`prosperity` <> VALUES(`prosperity`), VALUES(`prosperity`), `prosperity`)
;
