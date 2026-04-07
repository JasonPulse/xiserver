SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for blue_traits
-- ----------------------------
DROP TABLE IF EXISTS `blue_traits`;
CREATE TABLE `blue_traits` (
  `trait_category` smallint(2) unsigned NOT NULL,
  `trait_points_needed` smallint(2) unsigned NOT NULL,
  `traitid` tinyint(3) unsigned NOT NULL,
  `modifier` smallint(5) unsigned NOT NULL,
  `value` smallint(5) NOT NULL,
  `tier` tinyint(3) unsigned NOT NULL,
  `job_points_only` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`trait_category`,`trait_points_needed`,`modifier`,`tier`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

insert into `blue_spell_mods`
(
    `trait_category`, `trait_points_needed`, `traitid`, `modifier`, `value`, `tier`, `job_points_only`
)
VALUES
    (1,2,32,230,8,1,0),     -- Beast Killer (1)
    (1,4,32,230,10,2,0),    -- Beast Killer (2)
    (1,6,32,230,12,3,0),    -- Beast Killer (3)
    (2,2,9,370,1,1,0),      -- Auto Regen (1)
    (2,4,9,370,2,2,1),      -- Auto Regen (2) (JP only)
    (2,6,9,370,3,3,1),      -- Auto Regen (3) (JP only)
    (3,2,35,227,8,1,0),     -- Lizard Killer (1)
    (3,4,35,227,10,2,0),    -- Lizard Killer (2)
    (3,6,35,227,12,3,1),    -- Lizard Killer (3) (JP only)
    (4,2,24,295,3,1,0),     -- Clear Mind (1)
    (4,4,24,295,6,2,0),     -- Clear Mind (2)
    (4,6,24,295,9,3,0),     -- Clear Mind (3)
    (4,6,24,71,1,3,0),      -- Clear Mind (3)
    (4,8,24,295,12,4,0),    -- Clear Mind (4)
    (4,8,24,71,1,4,0),      -- Clear Mind (4)
    (4,10,24,295,12,5,1),   -- Clear Mind (5) (JP only)
    (4,10,24,71,2,5,1),     -- Clear Mind (5) (JP only)
    (4,12,24,295,12,6,1),   -- Clear Mind (6) (JP only)
    (4,12,24,71,3,6,1),     -- Clear Mind (6) (JP only)
    (5,2,48,240,10,1,0),    -- Resist Sleep (1)
    (5,4,48,240,15,2,0),    -- Resist Sleep (2)
    (5,6,48,240,20,3,1),    -- Resist Sleep (3) (JP only)
    (5,8,48,240,25,4,1),    -- Resist Sleep (4) (JP only)
    (6,2,5,28,20,1,0),      -- Magic Attack Bonus (1)
    (6,4,5,28,24,2,0),      -- Magic Attack Bonus (2)
    (6,6,5,28,28,3,0),      -- Magic Attack Bonus (3)
    (6,8,5,28,32,4,0),      -- Magic Attack Bonus (4)
    (6,10,5,28,36,5,1),     -- Magic Attack Bonus (5) (JP only)
    (6,12,5,28,50,6,1),     -- Magic Attack Bonus (6) (JP only)
    (7,2,39,231,8,1,0),     -- Undead Killer (1)
    (7,4,39,231,10,2,1),    -- Undead Killer (2) (JP only)
    (7,6,39,231,12,3,1),    -- Undead Killer (3) (JP only)
    (8,2,3,23,10,1,0),      -- Attack Bonus (1)
    (8,2,3,24,10,1,0),      -- Attack Bonus (1)
    (8,4,3,23,22,2,0),      -- Attack Bonus (2)
    (8,4,3,24,22,2,0),      -- Attack Bonus (2)
    (8,6,3,23,35,3,0),      -- Attack Bonus (3)
    (8,6,3,24,35,3,0),      -- Attack Bonus (3)
    (8,8,3,23,48,4,0),      -- Attack Bonus (4)
    (8,8,3,24,48,4,0),      -- Attack Bonus (4)
    (8,10,3,23,60,5,1),     -- Attack Bonus (5) (JP only)
    (8,10,3,24,60,5,1),     -- Attack Bonus (5) (JP only)
    (8,12,3,23,72,6,1),     -- Attack Bonus (6) (JP only)
    (8,12,3,24,72,6,1),     -- Attack Bonus (6) (JP only)
    (9,2,11,359,25,1,0),    -- Rapid Shot (1)
    (9,4,11,359,30,2,1),    -- Rapid Shot (2) (JP only)
    (9,6,11,359,35,3,1),    -- Rapid Shot (3) (JP only) -- Value is guessed
    (10,2,8,5,10,1,0),      -- Max MP Boost (1)
    (10,4,8,5,20,2,0),      -- Max MP Boost (2)
    (11,2,4,1,10,1,0),      -- Defense Bonus (1)
    (11,4,4,1,22,2,0),      -- Defense Bonus (2)
    (11,6,4,1,35,3,0),      -- Defense Bonus (3)
    (11,8,4,1,48,4,0),      -- Defense Bonus (4)
    (11,10,4,1,60,5,1),     -- Defense Bonus (5)
    (11,12,4,1,72,6,1),     -- Defense Bonus (6)
    (12,2,33,229,8,1,0),    -- Plantoid Killer (1)
    (12,4,33,229,10,2,0),   -- Plantoid Killer (2)
    (12,6,33,229,12,3,1),   -- Plantoid Killer (3) (JP only)
    (13,2,6,29,10,1,0),     -- Magic Defense Bonus (1)
    (13,4,6,29,12,2,0),     -- Magic Defense Bonus (2)
    (13,6,6,29,14,3,0),     -- Magic Defense Bonus (3)
    (13,8,6,29,16,4,1),     -- Magic Defense Bonus (4) (JP only)
    (13,10,6,29,18,5,1),    -- Magic Defense Bonus (5) (JP only)
    (14,2,10,369,1,1,0),    -- Auto Refresh (1) -- Only tier available to BLU
    (15,2,7,1095,30,1,0),   -- Max HP Boost (1)
    (15,4,7,1095,60,2,0),   -- Max HP Boost (2)
    (15,6,7,1095,120,3,0),  -- Max HP Boost (3)
    (15,8,7,1095,180,4,0),  -- Max HP Boost (4)
    (15,10,7,1095,240,5,1), -- Max HP Boost (5) (JP only)
    (15,12,7,1095,280,6,1), -- Max HP Boost (6) (JP only)
    (16,2,1,25,10,1,0),     -- Accuracy Bonus (1)
    (16,2,1,26,10,1,0),     -- Accuracy Bonus (1)
    (16,4,1,25,22,2,0),     -- Accuracy Bonus (2)
    (16,4,1,26,22,2,0),     -- Accuracy Bonus (2)
    (16,6,1,25,35,3,0),     -- Accuracy Bonus (3)
    (16,6,1,26,35,3,0),     -- Accuracy Bonus (3)
    (16,8,1,25,48,4,0),     -- Accuracy Bonus (4)
    (16,8,1,26,48,4,0),     -- Accuracy Bonus (4)
    (16,10,1,25,60,5,1),    -- Accuracy Bonus (5) (JP only)
    (16,10,1,26,60,5,1),    -- Accuracy Bonus (5) (JP only)
    (16,12,1,25,73,6,1),    -- Accuracy Bonus (6) (JP only)
    (16,12,1,26,73,6,1),    -- Accuracy Bonus (6) (JP only)
    (17,2,13,296,25,1,0),   -- Conserve MP (1)
    (17,4,13,296,28,2,0),   -- Conserve MP (2)
    (17,6,13,296,31,3,0),   -- Conserve MP (3)
    (17,8,13,296,34,4,1),   -- Conserve MP (4) (JP only)
    (17,10,13,296,37,5,1),  -- Conserve MP (5) (JP only)
    (18,2,2,68,10,1,0),     -- Evasion Bonus (1)
    (18,4,2,68,22,2,0),     -- Evasion Bonus (2)
    (18,6,2,68,35,3,0),     -- Evasion Bonus (3)
    (18,8,2,68,48,4,1),     -- Evasion Bonus (4)
    (18,10,2,68,60,5,1),    -- Evasion Bonus (5)
    (19,2,58,249,10,1,0),   -- Resist Gravity (1)
    (19,3,58,249,15,2,1),   -- Resist Gravity (2) (JP only)
    (19,4,58,249,20,3,1),   -- Resist Gravity (3) (JP only)
    (20,2,14,73,10,1,0),    -- Store TP (1)
    (20,4,14,73,15,2,0),    -- Store TP (2)
    (20,6,14,73,20,3,0),    -- Store TP (3)
    (20,8,14,73,25,4,1),    -- Store TP (4) (JP onry)
    (20,10,14,73,30,5,1),   -- Store TP (5) (JP onry)
    (21,2,17,291,10,1,0),   -- Counter (1)
    (21,4,17,291,12,2,0),   -- Counter (2)
    (21,6,17,291,14,3,1),   -- Counter (3) (JP only)
    (21,8,17,291,16,4,1),   -- Counter (4) (JP only)
    (22,2,12,170,5,0,0),    -- Fast Cast (0) (Zero, weaker than /RDM.)
    (22,4,12,170,10,1,0),   -- Fast Cast (1)
    (22,6,12,170,15,2,0),   -- Fast Cast (2)
    (22,8,12,170,20,3,1),   -- Fast Cast (3) (JP only)
    (22,10,12,170,25,4,1),  -- Fast Cast (4) (JP only)
    (23,2,106,174,8,1,0),   -- Skillchain Bonus (1)
    (23,3,106,174,12,2,0),  -- Skillchain Bonus (2)
    (23,4,106,174,16,3,0),  -- Skillchain Bonus (3)
    (23,5,106,174,20,4,1),  -- Skillchain Bonus (4) (JP only)
    (23,6,106,174,23,5,1),  -- Skillchain Bonus (5) (JP only)
    (24,2,15,288,7,0,0),    -- Double Attack (0) -- Tier Zero because this is weaker than WAR double attack (1). It is BLU exclusive
    (24,4,16,302,5,1,0),    -- Triple Attack (1)
    (25,2,18,259,10,1,0),   -- Dual Wield (1)
    (25,4,18,259,15,2,0),   -- Dual Wield (2)
    (25,6,18,259,25,3,0),   -- Dual Wield (3)
    (25,8,18,259,30,4,0),   -- Dual Wield (4)
    (25,10,18,259,35,5,1),  -- Dual Wield (5) (JP only)
    (25,12,18,259,40,6,1),  -- Dual Wield (6) (JP only)
    (26,2,70,306,15,1,0),   -- Zanshin (1)
    (27,2,110,487,5,1,0),   -- Magic Burst Bonus (1)
    (27,3,110,487,7,2,0),   -- Magic Burst Bonus (2)
    (27,4,110,487,9,3,0),   -- Magic Burst Bonus (3)
    (27,5,110,487,11,4,1),  -- Magic Burst Bonus (4)
    (27,6,110,487,13,5,1),  -- Magic Burst Bonus (5)
    (28,2,20,897,1,1,0),    -- Gilfinder (1)
    (28,3,19,303,1,2,0)    -- Treasure Hunter (1)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `traitid` = IF(`traitid` <> VALUES(`traitid`), VALUES(`traitid`), `traitid`),
    `job_points_only` = IF(`job_points_only` <> VALUES(`job_points_only`), VALUES(`job_points_only`), `job_points_only`)
;
