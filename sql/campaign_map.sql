-- MySQL dump 10.16  Distrib 10.2.8-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: dspdb
-- ------------------------------------------------------
-- Server version    10.2.8-MariaDB

--
-- Table structure for table `campaign_map`
--

DROP TABLE IF EXISTS `campaign_map`;

CREATE TABLE `campaign_map` (
  `id` tinyint(2) unsigned NOT NULL,
  `zoneid` smallint(3) unsigned NOT NULL DEFAULT 0,
  `isbattle` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `nation` tinyint(2) unsigned NOT NULL DEFAULT 8,
  `heroism` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `influence_sandoria` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `influence_bastok` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `influence_windurst` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `influence_beastman` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `current_fortifications` smallint(4) unsigned NOT NULL DEFAULT 0,
  `current_resources` smallint(4) unsigned NOT NULL DEFAULT 0,
  `max_fortifications` smallint(4) unsigned NOT NULL DEFAULT 0,
  `max_resources` smallint(4) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `campaign_map`
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

insert into `campaign_map`
(
    `id`, `zoneid`, `isbattle`, `nation`, `heroism`,
    `influence_sandoria`, `influence_bastok`,
    `influence_windurst`, `influence_beastman`,
    `current_fortifications`, `current_resources`,
    `max_fortifications`, `max_resources`
)
VALUES
    (0,80,0,2,0,0,0,0,0,0,0,0,0),
    (1,81,0,8,0,0,0,0,0,0,0,0,0),
    (2,82,0,8,0,0,0,0,0,0,0,0,0),
    (3,83,0,8,0,0,0,0,0,0,0,0,0),
    (4,84,0,8,0,0,0,0,0,0,0,0,0),
    (5,85,0,8,0,0,0,0,0,0,0,0,0),
    (6,175,0,8,0,0,0,0,0,0,0,0,0),
    (7,87,0,4,0,0,0,0,0,0,0,0,0),
    (8,88,0,8,0,0,0,0,0,0,0,0,0),
    (9,89,0,8,0,0,0,0,0,0,0,0,0),
    (10,90,0,8,0,0,0,0,0,0,0,0,0),
    (11,91,0,8,0,0,0,0,0,0,0,0,0),
    (12,92,0,8,0,0,0,0,0,0,0,0,0),
    (13,171,0,8,0,0,0,0,0,0,0,0,0),
    (14,94,0,6,0,0,0,0,0,0,0,0,0),
    (15,95,0,8,0,0,0,0,0,0,0,0,0),
    (16,96,0,8,0,0,0,0,0,0,0,0,0),
    (17,97,0,8,0,0,0,0,0,0,0,0,0),
    (18,98,0,8,0,0,0,0,0,0,0,0,0),
    (19,99,0,8,0,0,0,0,0,0,0,0,0),
    (20,164,0,8,0,0,0,0,0,0,0,0,0),
    (21,136,0,8,0,0,0,0,0,0,0,0,0),
    (22,137,0,8,0,0,0,0,0,0,0,0,0),
    (23,138,0,8,0,0,0,0,0,0,0,0,0),
    (24,155,0,8,0,0,0,0,0,0,0,0,0),
    (25,156,0,8,0,0,0,0,0,0,0,0,0)
-- Dump completed on 2018-06-09 16:59:58
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `zoneid` = IF(`zoneid` <> VALUES(`zoneid`), VALUES(`zoneid`), `zoneid`),
    `isbattle` = IF(`isbattle` <> VALUES(`isbattle`), VALUES(`isbattle`), `isbattle`),
    `nation` = IF(`nation` <> VALUES(`nation`), VALUES(`nation`), `nation`),
    `heroism` = IF(`heroism` <> VALUES(`heroism`), VALUES(`heroism`), `heroism`),
    `influence_sandoria` = IF(`influence_sandoria` <> VALUES(`influence_sandoria`), VALUES(`influence_sandoria`), `influence_sandoria`),
    `influence_bastok` = IF(`influence_bastok` <> VALUES(`influence_bastok`), VALUES(`influence_bastok`), `influence_bastok`),
    `influence_windurst` = IF(`influence_windurst` <> VALUES(`influence_windurst`), VALUES(`influence_windurst`), `influence_windurst`),
    `influence_beastman` = IF(`influence_beastman` <> VALUES(`influence_beastman`), VALUES(`influence_beastman`), `influence_beastman`),
    `current_fortifications` = IF(`current_fortifications` <> VALUES(`current_fortifications`), VALUES(`current_fortifications`), `current_fortifications`),
    `current_resources` = IF(`current_resources` <> VALUES(`current_resources`), VALUES(`current_resources`), `current_resources`),
    `max_fortifications` = IF(`max_fortifications` <> VALUES(`max_fortifications`), VALUES(`max_fortifications`), `max_fortifications`),
    `max_resources` = IF(`max_resources` <> VALUES(`max_resources`), VALUES(`max_resources`), `max_resources`)
;
