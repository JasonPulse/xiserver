SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for abilities_charges
-- ----------------------------
DROP TABLE IF EXISTS `abilities_charges`;

CREATE TABLE `abilities_charges` (
  `recastId` smallint(5) unsigned NOT NULL,
  `job` tinyint(2) unsigned NOT NULL,
  `level` tinyint(2) unsigned NOT NULL,
  `maxCharges` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `chargeTime` smallint(4) unsigned NOT NULL DEFAULT '0',
  `meritModID` smallint(4) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`recastId`,`job`,`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=56;

-- ----------------------------
-- Records 
-- ----------------------------

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

insert into `abilities_charges`
(
    `recastId`, `job`, `level`, `maxCharges`, `chargeTime`, `meritModID`
)
VALUES
    (102,9,25,3,30,902),
    (195,17,40,2,60,1410),
    (231,20,10,1,240,0),
    (231,20,30,2,120,0),
    (231,20,50,3,80,0),
    (231,20,70,4,60,0),
    (231,20,90,5,48,0)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `maxCharges` = IF(`maxCharges` <> VALUES(`maxCharges`), VALUES(`maxCharges`), `maxCharges`),
    `chargeTime` = IF(`chargeTime` <> VALUES(`chargeTime`), VALUES(`chargeTime`), `chargeTime`),
    `meritModID` = IF(`meritModID` <> VALUES(`meritModID`), VALUES(`meritModID`), `meritModID`)
;
