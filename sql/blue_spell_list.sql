SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for blue_spell_list
-- ----------------------------
DROP TABLE IF EXISTS `blue_spell_list`;

CREATE TABLE `blue_spell_list` (
  `spellid` smallint(3) NOT NULL,
  `mob_skill_id` smallint(4) unsigned NOT NULL,
  `set_points` smallint(2) NOT NULL,
  `trait_category` smallint(2) NOT NULL,
  `trait_category_weight` smallint(2) NOT NULL,
  `primary_sc` smallint(2) NOT NULL,
  `secondary_sc` smallint(2) NOT NULL,
  `tertiary_sc` smallint(2) NOT NULL,
  PRIMARY KEY (`spellid`,`mob_skill_id`)
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

insert into `blue_spell_list`
(
    `spellid`, `mob_skill_id`, `set_points`, `trait_category`,
    `trait_category_weight`, `primary_sc`, `secondary_sc`, `tertiary_sc`
)
VALUES
    (513,1572,3,4,1,0,0,0), -- Venom Shell
    (515,462,5,4,1,0,0,0), -- Maelstrom
    (517,448,1,10,1,0,0,0), -- Metallic Body
    (519,452,3,18,1,1,4,0), -- Screwdriver
    (521,421,4,0,1,0,0,0), -- MP Drainkiss
    (522,437,2,0,1,0,0,0), -- Death Ray
    (524,426,2,0,1,0,0,0), -- Sandspin
    (527,513,3,7,1,6,0,0), -- Smite of Rage
    (529,683,2,7,1,3,0,0), -- Bludgeon
    (530,569,4,0,1,0,0,0), -- Refueling
    (531,676,3,13,1,0,0,0), -- Ice Break
    (532,535,4,0,1,0,0,0), -- Blitzstrahl
    (533,509,3,14,2,0,0,0), -- Self-Destruct
    (534,523,4,10,1,0,0,0), -- Mysterious Light
    (535,1646,1,14,1,0,0,0), -- Cold Wave
    (536,466,1,4,1,0,0,0), -- Poison Breath
    (537,489,2,14,1,0,0,0), -- Stinking Gas
    (538,530,4,6,1,0,0,0), -- Memento Mori
    (539,475,3,11,1,2,5,0), -- Terror Touch
    (540,1778,4,8,1,4,6,0), -- Spinal Cleave
    (541,485,2,0,1,0,0,0), -- Blood Saber
    (542,433,2,0,1,0,0,0), -- Digest
    (543,279,2,12,1,7,0,0), -- Mandibular Bite
    (544,659,2,6,1,0,0,0), -- Cursed Sphere
    (545,810,4,20,1,2,0,0), -- Sickle Slash
    (547,346,1,0,1,0,0,0), -- Cocoon
    (548,364,3,4,1,0,0,0), -- Filamented Hold
    (549,335,1,5,1,0,0,0), -- Pollen
    (551,338,1,12,1,5,0,0), -- Power Attack
    (554,353,5,8,1,2,5,0), -- Death Scissors
    (555,791,3,13,1,0,0,0), -- Magnetite Cloud
    (557,549,4,6,1,0,0,0), -- Eyes On Me
    (560,1711,3,16,1,7,0,0), -- Frenetic Rip
    (561,501,3,14,2,0,0,0), -- Frightful Roar
    (563,560,3,10,1,0,0,0), -- Hecatomb Wave
    (564,645,4,15,1,8,0,0), -- Body Slam
    (565,821,4,0,1,0,0,0), -- Radiant Breath
    (567,622,2,0,1,1,0,0), -- Helldive
    (569,395,4,9,1,8,0,0), -- Jet Stream
    (570,394,2,0,1,0,0,0), -- Blood Drain
    (572,410,1,6,1,0,0,0), -- Sound Blast
    (573,1701,3,4,1,0,0,0), -- Feather Tickle
    (574,402,2,19,1,0,0,0), -- Feather Barrier
    (575,577,4,0,1,0,0,0),  -- Jettatura
    (576,1713,3,5,1,0,0,0), -- Yawn
    (577,257,2,3,1,6,0,0), -- Foot Kick
    (578,323,3,5,1,0,0,0), -- Wild Carrot
    (579,1707,4,14,3,0,0,0), -- Voracious Trunk
    (581,287,4,2,1,0,0,0), -- Healing Breeze
    (582,653,2,17,1,0,0,0), -- Chaotic Eye
    (584,264,2,2,1,0,0,0), -- Sheep Song
    (585,266,4,3,1,12,0,0), -- Ram Charge
    (587,273,2,3,1,4,0,0), -- Claw Cyclone
    (588,497,2,4,1,0,0,0), -- Lowing
    (589,255,5,16,1,1,8,0), -- Dimensional Death
    (591,800,4,6,1,0,0,0), -- Heat Breath
    (592,292,2,0,1,0,0,0), -- Blank Gaze
    (593,295,3,5,1,0,0,0), -- Magic Fruit
    (594,584,3,8,1,3,8,0), -- Uppercut
    (595,322,5,1,1,0,0,0), -- 1000 Needles
    (596,329,2,0,1,3,0,0), -- Pinecone Bomb
    (597,687,2,1,1,5,0,0), -- Sprout Smack
    (598,434,4,4,1,0,0,0), -- Soporific
    (599,310,2,0,1,2,0,0), -- Queasyshroom
    (603,302,3,1,1,1,0,0), -- Wild Oats
    (604,319,5,22,1,0,0,0), -- Bad Breath
    (605,516,3,0,1,0,0,0), -- Geist Wall
    (606,386,2,4,1,0,0,0), -- Awful Eye
    (608,377,3,17,1,0,0,0), -- Frost Breath
    (610,372,4,0,1,0,0,0), -- Infrasonics
    (611,1384,5,16,1,10,0,0), -- Disseverment
    (612,1441,4,14,4,0,0,0), -- Actinic Burst
    (613,1463,5,6,1,0,0,0), -- Reactor Cool
    (614,1352,3,11,1,0,0,0), -- Saline Coat
    (615,1358,5,14,4,0,0,0), -- Plasma Charge
    (616,1366,5,8,1,0,0,0), -- Temporal Shift
    (617,1447,3,11,1,9,0,0), -- Vertical Cleave
    (618,638,2,0,1,0,0,0), -- Blastbomb
    (620,609,3,8,1,8,0,0), -- Battle Dance
    (621,1727,2,4,1,0,0,0), -- Sandspray
    (622,665,2,11,1,7,0,0), -- Grand Slam
    (623,612,3,0,1,8,0,0), -- Head Butt
    (626,591,3,0,1,0,0,0), -- Bomb Toss
    (628,1081,3,15,1,8,0,0), -- Frypan
    (629,360,3,15,1,0,0,0), -- Flying Hip Press
    (631,777,3,9,1,5,0,0), -- Hydro Shot
    (632,1897,3,0,1,0,0,0), -- Diamondhide
    (633,1745,5,21,1,0,0,0), -- Enervation
    (634,785,5,14,2,0,0,0), -- Light of Penance
    (636,1734,4,4,1,0,0,0), -- Warm-Up
    (637,1733,5,17,1,0,0,0), -- Firespit
    (638,617,3,9,1,1,0,0), -- Feather Storm
    (640,1771,4,20,1,5,0,0), -- Tail Slap
    (641,1753,5,18,1,6,0,0), -- Hysteric Barrage
--     (641,1766,5,18,1,6,0,0), -- Hysteric Barrage
    (642,1821,3,0,1,0,0,0), -- Amplification
    (643,1818,3,0,1,11,0,0), -- Cannonball
    (644,1963,4,4,1,0,0,0), -- Mind Blast
    (645,1955,4,5,1,0,0,0), -- Exuviation
    (646,1958,4,6,1,0,0,0), -- Magic Hammer
    (647,1722,2,17,1,0,0,0), -- Zephyr Mantle
    (648,2153,1,19,1,0,0,0), -- Regurgitation
    (650,2163,2,1,1,7,6,0), -- Seedspray
    (651,2185,4,4,1,0,0,0), -- Corrosive Ooze
    (652,2181,3,12,1,1,0,0), -- Spiral Spin
    (653,2176,2,21,1,3,8,0), -- Asuran Claws
    (654,2436,4,22,1,12,0,0), -- Sub-Zero Smash
    (655,2423,3,0,1,0,0,0), -- Triumphant Roar
    (656,2562,3,24,1,0,0,0), -- Acrid Stream
    (657,2564,3,25,1,0,0,0), -- Blazing Bound
    (658,2173,4,0,1,0,0,0), -- Plenilune Embrace
    (658,2174,4,0,1,0,0,0), -- Plenilune Embrace
    (659,2101,4,24,1,0,0,0), -- Demoralizing Roar
    (660,2161,3,27,1,0,0,0), -- Cimicine Discharge
    (661,1782,5,25,1,0,0,0), -- Animating Wail
    (662,525,3,0,1,0,0,0), -- Battery Charge
    (663,331,4,27,1,0,0,0), -- Leafstorm
    (664,461,2,0,1,0,0,0), -- Regeneration
    (665,336,1,26,1,11,0,0), -- Final Sting
    (666,590,3,23,1,11,8,0), -- Goblin Rush
    (667,388,2,16,1,0,0,0), -- Vanity Dive
    (668,555,3,10,1,0,0,0), -- Magic Barrier
    (669,514,2,26,1,4,6,0), -- Whirl of Rage
    (670,2629,4,23,1,9,1,0), -- Benthic Typhoon
    (671,1220,4,22,1,0,0,0), -- Auroral Drape
    (672,2631,5,13,1,0,0,0), -- Osmosis
    (673,741,4,25,1,10,4,0), -- Quadratic Continuum
    (674,580,1,20,1,0,0,0), -- Fantod
    (675,1817,3,8,1,0,0,0), -- Thermal Pulse
    (677,1230,3,24,1,2,4,0), -- Empty Thrash
    (678,301,3,6,1,0,0,0), -- Dream Flower
    (679,1255,3,18,1,0,0,0), -- Occultation
    (680,483,4,28,1,0,0,0), -- Charged Whisker
    (681,1245,5,14,4,0,0,0), -- Winds of Promyvion
    (682,2154,2,25,1,3,6,0), -- Delta Thrust
    (683,920,4,28,1,0,0,0), -- Everyones Grudge
    (684,2431,4,27,1,0,0,0), -- Reaving Wind
    (685,1703,3,15,1,0,0,0), -- Barrier Tusk
    (686,502,4,25,1,0,0,0), -- Mortal Ray
    (687,1959,2,17,1,0,0,0), -- Water Bomb
    (688,675,2,24,1,12,1,0), -- Heavy Strike
    (689,2421,3,21,1,0,0,0), -- Dark Orb
    (690,1724,5,2,1,0,0,0), -- White Wind
    (692,2178,4,20,1,6,0,0), -- Sudden Lunge
    (693,1149,5,23,1,3,4,8), -- Quadrastrike
    (694,1354,3,10,1,0,0,0), -- Vapor Spray
    (695,820,4,15,1,0,0,0), -- Thunder Breath
    (696,2201,5,21,1,0,0,0), -- Orcish Counterstance
    (697,1824,4,28,1,9,0,0), -- Amorphic Spikes
    (698,644,2,22,1,0,0,0), -- Wind breath
    (699,253,2,25,1,10,4,0), -- Barbed Crescent
--     (700,2945,6,16,8,0,0,0), -- Natures Meditation
--     (701,2950,6,18,8,0,0,0), -- Tempestuous Upheaval
--     (702,2958,6,13,8,0,0,0), -- Rending Deluge
--     (703,2967,6,8,8,0,0,0), -- Embalming Earth
--     (704,2970,6,23,8,9,0,0), -- Paralyzing Triad
--     (705,2974,4,29,8,0,0,0), -- Foul Waters
--     (706,2988,2,15,8,12,0,0), -- Glutinous Dart
--     (707,3030,5,17,8,0,0,0), -- Retinal Glare
--     (708,2930,6,24,8,0,0,0), -- Subduction
--     (709,256,7,24,3,11,0,0), -- Thrashing Assault
--     (710,1952,4,17,2,0,0,0), -- Erratic Flutter
--     (711,256,0,0,0,0,0,0), -- Restoral
--     (712,256,0,0,0,0,0,0), -- Rail Cannon
--     (713,2054,0,0,0,0,0,0), -- Diffusion Ray
--     (714,2073,0,0,0,9,5,0), -- Sinker Drill
--     (723,0,0,0,0,12,10,0), -- Saurian Slide
    (736,629,0,0,0,0,0,0), -- Thunderbolt
    (737,807,0,0,0,0,0,0), -- Harden Shell
    (738,1305,0,0,0,0,0,0), -- Absolute Terror
    (739,1790,0,0,0,0,0,0), -- Gates of Hades
    (740,2024,0,0,0,13,12,0), -- Tourbillion
    (741,1831,0,0,0,0,0,0), -- Pyric Bulwark
    (742,2118,0,0,0,14,9,0), -- Bilgestorm
    (743,2106,0,0,0,14,10,0), -- Bloodrake
    (744,3005,0,0,0,0,0,0), -- Droning Whirlwind
    (745,3014,0,0,0,0,0,0), -- Carcharian Verve
    (746,3020,0,0,0,0,0,0) -- Blistering Roar
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `set_points` = IF(`set_points` <> VALUES(`set_points`), VALUES(`set_points`), `set_points`),
    `trait_category` = IF(`trait_category` <> VALUES(`trait_category`), VALUES(`trait_category`), `trait_category`),
    `trait_category_weight` = IF(`trait_category_weight` <> VALUES(`trait_category_weight`), VALUES(`trait_category_weight`), `trait_category_weight`),
    `primary_sc` = IF(`primary_sc` <> VALUES(`primary_sc`), VALUES(`primary_sc`), `primary_sc`),
    `secondary_sc` = IF(`secondary_sc` <> VALUES(`secondary_sc`), VALUES(`secondary_sc`), `secondary_sc`),
    `tertiary_sc` = IF(`tertiary_sc` <> VALUES(`tertiary_sc`), VALUES(`tertiary_sc`), `tertiary_sc`)
;
