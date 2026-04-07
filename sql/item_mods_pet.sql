SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Structure de la table `item_mods_pet`
--

DROP TABLE IF EXISTS `item_mods_pet`;
CREATE TABLE IF NOT EXISTS `item_mods_pet` (
 `itemId` smallint(5) unsigned NOT NULL,
 `modId` smallint(5) unsigned NOT NULL,
 `value` smallint(5) NOT NULL DEFAULT '0',
 `petType` tinyint(3) unsigned NOT NULL DEFAULT '0',
 PRIMARY KEY (`itemId`,`modId`,`petType`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci AVG_ROW_LENGTH=13 PACK_KEYS=1;

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

insert into `item_mods_pet`
(
    `itemId`, `modId`, `value`, `petType`
)
VALUES
-- (Please keep item ID sequential)
-- Charivari Earring
    (10296,25,3,3), -- Automaton - ACC: 3
    (10296,26,3,3), -- Automaton - RACC: 3
    (10296,30,3,3), -- Automaton - MACC: 3

-- Sabong Earring
    (10299,288,2,0), -- All Pets - DOUBLE_ATTACK: 2

-- Shedir Crackows
    (10370,28,3,1),  -- Avatar - MATT: 3
    (10370,30,3,1),  -- Avatar - MACC: 3
    (10370,126,3,1), -- Avatar - BP_DAMAGE: 3

-- Murzim Zucchetto
    (10440,384,600,3), -- Automaton - HASTE_GEAR: 600

-- Tethyan Cuffs +1
    (10530,28,5,1), -- Avatar - MATT: 5

-- Tethyan Cuffs +2
    (10531,28,5,1), -- Avatar - MATT: 5

-- Tethyan Cuffs +3
    (10532,28,5,1), -- Avatar - MATT: 5

-- Auspex Gages
    (10537,23,9,1),  -- Avatar - ATT: 9
    (10537,126,4,1), -- Avatar - BP_DAMAGE: 4

-- Spurrina Gages
    (10542,23,12,1), -- Avatar - ATT: 12
    (10542,126,5,1), -- Avatar - BP_DAMAGE: 5

-- Summoners Horn +2
    (10664,28,4,1),  -- Avatar - MATT: 4
    (10664,346,3,1), -- Avatar - PERPETUATION_REDUCTION: 3

-- Summoners Doublet +2
    (10684,165,6,1), -- Avatar - CRITHITRATE: 6
    (10684,346,3,1), -- Avatar - PERPETUATION_REDUCTION: 3

-- Summoners Spats +2
    (10724,30,5,1), -- Avatar - MACC: 5

-- Summoners Pigaches +2
    (10744,562,5,1), -- Avatar - MAGIC_CRITHITRATE: 5

-- Moepapa Stone
    (10817,384,500,0), -- All Pets - HASTE_GEAR: 500

-- Muzzling Collar
    (10914,27,-2,0), -- All Pets - ENMITY: -2

-- Muzzling Collar +1
    (10915,27,-3,0), -- All Pets - ENMITY: -3

-- Oneiros Cappa
    (10972,161,-300,0), -- All Pets - DMGPHYS: -300
    (10972,164,-300,0), -- All Pets - DMGRANGE: -300

-- Esper Earring
    (11052,126,3,1), -- Avatar - BP_DAMAGE: 3

-- Ferine Cabasset +2
    (11072,1155,20,0), -- All Pets - ENHANCES_MONSTER_CORRELATION: 20

-- Callers Doublet +2
    (11098,126,10,1), -- Avatar - BP_DAMAGE: 10

-- Callers Bracers +2
    (11118,25,15,1), -- Avatar - ACC: 15

-- Callers Spats +2
    (11138,345,500,1), -- Avatar - TP_BONUS: 500

-- Callers Pigaches +2
    (11158,30,5,1), -- Avatar - MACC: 5

-- Ferine Cabasset +1
    (11172,1155,10,0), -- All Pets - ENHANCES_MONSTER_CORRELATION: 10

-- Callers Doublet +1
    (11198,126,5,1), -- Avatar - BP_DAMAGE: 5

-- Callers Bracers +1
    (11218,25,10,1), -- Avatar - ACC: 10

-- Callers Spats +1
    (11238,345,250,1), -- Avatar - TP_BONUS: 250

-- Callers Pigaches +1
    (11258,30,5,1), -- Avatar - MACC: 5

-- Cirque Scarpe +1
    (11261,12,10,3), -- Automaton - INT: 10
    (11261,13,10,3), -- Automaton - MND: 10

-- Puppetry Tobe +1
    (11297,2,20,4), -- Harlequin - HP: 20
    (11297,2,24,5), -- Valoredge - HP: 24
    (11297,2,18,6), -- Sharpshot - HP: 18
    (11297,2,16,7), -- Stormwaker - HP: 16
    (11297,5,20,4), -- Harlequin - MP: 20
    (11297,5,24,7), -- Stormwaker - MP: 24

-- Pantin Tobe
    (11298,25,10,3), -- Automaton - ACC: 10

-- Pantin Tobe +1
    (11299,25,10,3), -- Automaton - ACC: 10

-- Aegas Doublet
    (11338,25,3,0),  -- All Pets - ACC: 3
    (11338,289,3,0), -- All Pets - SUBTLE_BLOW: 3

-- Pantin Babouches
    (11388,28,5,3), -- Automaton - MATT: 5

-- Pantin Babouches +1
    (11389,28,5,3), -- Automaton - MATT: 5

-- Koschei Crackows
    (11392,23,5,1), -- Avatar - ATT: 5
    (11392,1,10,1), -- Avatar - DEF: 10

-- Puppetry Taj +1
    (11470,71,3,3), -- Automaton - MPHEAL: 3
    (11470,72,3,3), -- Automaton - HPHEAL: 3

-- Pantin Taj
    (11471,370,1,3), -- Automaton - REGEN: 1

-- Pantin Taj +1
    (11472,370,1,3), -- Automaton - REGEN: 1

-- Spurrer Beret
    (11497,384,500,0), -- All Pets - HASTE_GEAR: 500

-- Fidelity Mantle
    (11531,73,3,0), -- All Pets - STORETP: 3

-- Ferine Mantle
    (11555,25,10,0), -- All Pets - ACC: 10

-- Tiresias Cape
    (11564,28,1,1), -- Avatar - MATT: 1

-- Karagoz Mantle
    (11571,25,12,3), -- Automaton - ACC: 12

-- Eidolon Pendant
    (11612,28,2,1), -- Avatar - MATT: 2

-- Ferine Necklace
    (11617,288,2,0), -- All Pets - DOUBLE_ATTACK: 2

-- Callers Pendant
    (11619,368,25,1), -- Avatar - REGAIN: 25

-- Ferine Earring
    (11711,25,3,0), -- All Pets - ACC: 3

-- Mujin Obi
    (11776,23,10,1), -- Avatar - ATT: 10

-- Cirque Earring
    (11720,23,2,3), -- Automaton - ATT: 2
    (11720,24,3,3), -- Automaton - RATT: 3
    (11720,28,3,3), -- Automaton - MATT: 3

-- Callers Sash
    (11739,27,2,1), -- Avatar - ENMITY: 2
    (11739,28,2,1), -- Avatar - MATT: 2

-- Ngen Seraweels
    (11987,126,5,1), -- Avatar - BP_DAMAGE: 5
    (11987,370,1,1), -- Avatar - REGEN: 1

-- Evokers Horn
    (12520,27,-3,1), -- Avatar - ENMITY: -3

-- Drachen Mail
    (12649,370,1,2), -- Wyvern - REGEN: 1

-- Evokers Doublet
    (12650,27,-2,1), -- Avatar - ENMITY: -2

-- Drachen Finger Gauntlets
    (13974,25,5,2), -- Wyvern - ACC: 5

-- Evokers Bracers
    (13975,27,-2,1), -- Avatar - ENMITY: -2

-- Evokers Pigaches
    (14103,27,-2,1), -- Avatar - ENMITY: -2
    (14103,68,5,1),  -- Avatar - EVA: 5

-- Drachen Brais
    (14227,3,10,2), -- Wyvern - HPP: 10

-- Evokers Spats
    (14228,25,10,1), -- Avatar - ACC: 10
    (14228,27,-2,1), -- Avatar - ENMITY: -2

-- Wyvern Mail
    (14405,2,65,2),  -- Wyvern - HP: 65
    (14405,72,65,2), -- Wyvern - HPHEAL: 65

-- Yinyang Robe
    (14468,27,5,1), -- Avatar - ENMITY: 5

-- Drachen Mail +1
    (14486,370,1,2), -- Wyvern - REGEN: 1

-- Summoners Doublet +1
    (14514,165,4,1), -- Avatar - CRITHITRATE: 4

-- Puppetry Tobe
    (14523,2,20,4), -- Harlequin - HP: 20
    (14523,2,24,5), -- Valoredge - HP: 24
    (14523,2,18,6), -- Sharpshot - HP: 18
    (14523,2,16,7), -- Stormwaker - HP: 16
    (14523,5,20,4), -- Harlequin - MP: 20
    (14523,5,24,7), -- Stormwaker - MP: 24

-- Ostreger Mitts
    (14872,2,10,2), -- Wyvern - HP: 10

-- Drachen Finger Gauntlets +1
    (14903,25,5,2), -- Wyvern - ACC: 5

-- Evokers Bracers +1
    (14904,27,-2,1), -- Avatar - ENMITY: -2

-- Summoners Bracers +1
    (14923,25,7,1),  -- Avatar - ACC: 7

-- Beast Bazubands
    (14958,63,5,0), -- All Pets - DEFP: 5

-- Pantin Dastanas
    (15031,384,300,3), -- Automaton - HASTE_GEAR: 300

-- Pantin Dastanas +1
    (15032,384,300,3), -- Automaton - HASTE_GEAR: 300

-- Summoners Doublet
    (15101,165,3,1), -- Avatar - CRITHITRATE: 3

-- Summoners Bracers
    (15116,25,7,1), -- Avatar - ACC: 7

-- Summoners Pigaches
    (15146,23,7,1),   -- Avatar - ATT: 7
    (15146,357,-2,1), -- Avatar - BP_DELAY: -2

-- Evokers Horn +1
    (15239,27,-3,1), -- Avatar - ENMITY: -3

-- Puppetry Taj
    (15267,71,3,3), -- Automaton - MPHEAL: 3
    (15267,72,3,3), -- Automaton - HPHEAL: 3

-- Evokers Pigaches +1
    (15366,27,-4,1), -- Avatar - ENMITY: -4
    (15366,68,5,1),  -- Avatar - EVA: 5

-- Falconers Hose
    (15367,2,30,2), -- Wyvern - HP: 30

-- Drachen Brais +1
    (15574,3,15,2), -- Wyvern - HPP: 15

-- Evokers Spats +1
    (15575,25,14,1), -- Avatar - ACC: 14
    (15575,27,-2,1), -- Avatar - ENMITY: -2

-- Summoners Spats +1
    (15594,27,2,1), -- Avatar - ENMITY: 2

-- Puppetry Churidars
    (15602,168,10,3), -- Automaton - SPELLINTERRUPT: 10
    (15602,374,5,3),  -- Automaton - CURE_POTENCY: 5

-- Askar Dirs
    (15647,1,10,0), -- All Pets - DEF: 10

-- Goliard Trews
    (15649,1,10,0), -- All Pets - DEF: 10

-- Homam Gambieras
    (15661,2,50,2), -- Wyvern - HP: 50

-- Summoners Pigaches +1
    (15679,23,7,1),   -- Avatar - ATT: 7
    (15679,27,2,1),   -- Avatar - ENMITY: 2
    (15679,357,-2,1), -- Avatar - BP_DELAY: -2

-- Primal Belt
    (15910,1,5,0),  -- All Pets - DEF: 5
    (15910,27,3,0), -- All Pets - ENMITY: 3

-- Selemnus Belt
    (15944,163,-700,0), -- All Pets - DMGMAGIC: -700

-- Pallass Shield
    (16173,1,10,0), -- All Pets - DEF: 10

-- Pantin Cape
    (16245,23,15,3), -- Automaton - ATT: 15

-- Chanoixs Gorget
    (16270,2,50,2), -- Wyvern - HP: 50

-- Shepherds Chain
    (16297,161,-200,0), -- All Pets - DMGPHYS: -200
    (16297,164,-200,0), -- All Pets - DMGRANGE: -200

-- Puppetry Churidars +1
    (16351,168,10,3), -- Automaton - SPELLINTERRUPT: 10
    (16351,374,5,3),  -- Automaton - CURE_POTENCY: 5

-- Pantin Churidars
    (16352,30,5,3), -- Automaton - MACC: 5

-- Pantin Churidars +1
    (16353,30,7,3), -- Automaton - MACC: 7

-- Herders Subligar
    (16368,25,10,0), -- All Pets - ACC: 10

-- Glyph Axe
    (16654,368,10,0), -- All Pets - REGAIN: 10

-- Draconis Lance
    (16843,23,10,2), -- Wyvern - ATT: 10
    (16843,25,10,2), -- Wyvern - ACC: 10

-- Wyvern Perch
    (17579,2,50,2), -- Wyvern - HP: 50

-- Animator +1
    (17857,2,50,4), -- Harlequin - HP: 50
    (17857,2,60,5), -- Valoredge - HP: 60
    (17857,2,45,6), -- Sharpshot - HP: 45
    (17857,2,40,7), -- Stormwaker - HP: 40
    (17857,5,50,4), -- Harlequin - MP: 50
    (17857,5,60,7), -- Stormwaker - MP: 60

-- Lion Tamer
    (17961,1,10,0), -- All Pets - DEF: 10

-- Ravanas Axe
    (18547,370,3,0), -- All Pets - REGEN: 3

-- Adaman Sainti
    (18745,3,1,3), -- Automaton - HPP: 1

-- Gem Sainti
    (18746,3,2,3), -- Automaton - HPP: 2

-- Marotte Claws
    (18778,369,1,3), -- Automaton - REFRESH: 1
    (18778,370,1,3), -- Automaton - REGEN: 1

-- Burattinaios
    (18780,368,10,3), -- Automaton - REGAIN: 10

-- Buzbaz Sainti
    (18791,2,30,3), -- Automaton - HP: 30
    (18791,23,9,3), -- Automaton - ATT: 9
    (18791,24,9,3), -- Automaton - RATT: 9

-- Buzbaz Sainti +1
    (18792,2,40,3),  -- Automaton - HP: 40
    (18792,23,10,3), -- Automaton - ATT: 10
    (18792,24,10,3), -- Automaton - RATT: 10

-- Aymur
    (18999,23,40,0), -- All Pets - ATT: 40

-- Nirvana
    (19005,28,20,1), -- Avatar - MATT: 20

-- Aymur
    (19068,23,50,0), -- All Pets - ATT: 50

-- Nirvana
    (19074,28,25,1), -- Avatar - MATT: 25

-- Aymur
    (19088,23,60,0), -- All Pets - ATT: 60

-- Nirvana
    (19094,28,30,1), -- Avatar - MATT: 30

-- Aymur
    (19620,23,70,0), -- All Pets - ATT: 70

-- Nirvana
    (19626,28,35,1), -- Avatar - MATT: 35

-- Aymur
    (19718,23,70,0), -- All Pets - ATT: 70

-- Nirvana
    (19724,28,35,1), -- Avatar - MATT: 35

-- Esper Stone
    (19772,28,1,1), -- Avatar - MATT: 1

-- Aymur
    (19827,23,80,0), -- All Pets - ATT: 80

-- Nirvana
    (19833,28,40,1), -- Avatar - MATT: 40

-- Aymur
    (19956,23,80,0), -- All Pets - ATT: 80

-- Nirvana
    (19962,28,40,1), -- Avatar - MATT: 40

-- Denouements
    (20516,369,4,3), -- Automaton - REFRESH: 4
    (20516,370,4,3), -- Automaton - REGEN: 4

-- Ohtas
    (20535,368,10,3), -- Automaton - REGAIN: 10
    (20535,369,1,3),  -- Automaton - REFRESH: 1

-- Tinhaspa
    (20536,23,15,3), -- Automaton - ATT: 15
    (20536,24,15,3), -- Automaton - RATT: 15
    (20536,28,15,3), -- Automaton - MATT: 15

-- Rigor Baghnakhs
    (20549,25,20,3), -- Automaton - ACC: 20
    (20549,26,20,3), -- Automaton - RACC: 20
    (20549,30,20,3), -- Automaton - MACC: 20

-- Aymur
    (20792,23,80,0), -- All Pets - ATT: 80

-- Aymur
    (20793,23,80,0), -- All Pets - ATT: 80

-- Anahera Tabar
    (20822,27,6,0),  -- All Pets - ENMITY: 6
    (20822,68,40,0), -- All Pets - EVA: 40

-- Aalak Axe
    (20831,288,2,0), -- All Pets - DOUBLE_ATTACK: 2

-- Aalak Axe +1
    (20832,288,3,0) -- All Pets - DOUBLE_ATTACK: 3
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `value` = IF(`value` <> VALUES(`value`), VALUES(`value`), `value`)
;

insert into `item_mods_pet`
(
    `itemId`, `modId`, `value`, `petType`
)
VALUES
-- Pelagos Lance
    (20944,161,300,2), -- Wyvern - DMGPHYS: 300
    (20944,370,2,2),   -- Wyvern - REGEN: 2

-- Nirvana
    (21141,126,40,1), -- Avatar - BP_DAMAGE: 40

-- Nirvana
    (21142,126,40,1), -- Avatar - BP_DAMAGE: 40

-- Marquetry Staff
    (21155,28,110,1), -- Avatar - MATT: 110
    (21155,30,35,1),  -- Avatar - MACC: 35
    (21155,126,3,1),  -- Avatar - BP_DAMAGE: 3

-- Frazil Staff
    (21167,27,10,1),  -- Avatar - ENMITY: 10
    (21167,28,120,1), -- Avatar - MATT: 120
    (21167,30,20,1),  -- Avatar - MACC: 20

-- Eminent Pole
    (21183,28,108,1), -- Avatar - MATT: 108

-- Esper Stone +1
    (21361,28,6,0), -- All Pets - MATT: 6

-- Dunna
    (21372,160,-500,8), -- Luopan - DMG: -500

-- Magneto
-- TODO: Retail testing needed to confirm the hidden automaton stat bonuses (if any)
--     (21375,8,77,3),  -- Automaton - STR: 77
--     (21375,9,77,3),  -- Automaton - DEX: 77
--     (21375,10,77,3), -- Automaton - VIT: 77
--     (21375,11,77,3), -- Automaton - AGI: 77
--     (21375,12,77,3), -- Automaton - INT: 77
--     (21375,13,77,3), -- Automaton - MND: 77
--     (21375,14,77,3), -- Automaton - CHR: 77

-- Animator Z
-- TODO: Retail testing needed to confirm the hidden automaton stat bonuses (if any)
--     (21392,8,89,3),  -- Automaton - STR: 89
--     (21392,9,89,3),  -- Automaton - DEX: 89
--     (21392,10,89,3), -- Automaton - VIT: 89
--     (21392,11,89,3), -- Automaton - AGI: 89
--     (21392,12,89,3), -- Automaton - INT: 89
--     (21392,13,89,3), -- Automaton - MND: 89
--     (21392,14,89,3), -- Automaton - CHR: 89

-- Hesperiidae
    (21430,25,10,0), -- All Pets - ACC: 10
    (21430,26,10,0), -- All Pets - RACC: 10
    (21430,30,10,0), -- All Pets - MACC: 10

-- Epitaph
    (21432,126,16,1), -- Avatar - BP_DAMAGE: 16

-- Neo Animator
-- TODO: Retail testing needed to confirm the hidden automaton stat bonuses (if any)
--     (21433,8,89,3),   -- Automaton - STR: 89
--     (21433,9,89,3),   -- Automaton - DEX: 89
--     (21433,10,89,3),  -- Automaton - VIT: 89
--     (21433,11,89,3),  -- Automaton - AGI: 89
--     (21433,12,89,3),  -- Automaton - INT: 89
--     (21433,13,89,3),  -- Automaton - MND: 89
--     (21433,14,89,3),  -- Automaton - CHR: 89
    (21433,366,10,3), -- Automaton - MAIN_DMG_RATING: 10

-- Divinator
    (21452,8,89,3),   -- Automaton - STR: 89
    (21452,9,89,3),   -- Automaton - DEX: 89
    (21452,10,89,3),  -- Automaton - VIT: 89
    (21452,11,89,3),  -- Automaton - AGI: 89
    (21452,12,89,3),  -- Automaton - INT: 89
    (21452,13,89,3),  -- Automaton - MND: 89
    (21452,14,89,3),  -- Automaton - CHR: 89

-- Eminent Animator
    (21453,8,77,3),   -- Automaton - STR: 77
    (21453,9,77,3),   -- Automaton - DEX: 77
    (21453,10,77,3),  -- Automaton - VIT: 77
    (21453,11,77,3),  -- Automaton - AGI: 77
    (21453,12,77,3),  -- Automaton - INT: 77
    (21453,13,77,3),  -- Automaton - MND: 77
    (21453,14,77,3),  -- Automaton - CHR: 77

-- Forefront Animator
    (21454,8,46,3),   -- Automaton - STR: 46
    (21454,9,46,3),   -- Automaton - DEX: 46
    (21454,10,46,3),  -- Automaton - VIT: 46
    (21454,11,46,3),  -- Automaton - AGI: 46
    (21454,12,46,3),  -- Automaton - INT: 46
    (21454,13,46,3),  -- Automaton - MND: 46
    (21454,14,46,3),  -- Automaton - CHR: 46

-- Alternator
    (21455,8,70,3),   -- Automaton - STR: 70
    (21455,9,70,3),   -- Automaton - DEX: 70
    (21455,10,70,3),  -- Automaton - VIT: 70
    (21455,11,70,3),  -- Automaton - AGI: 70
    (21455,12,70,3),  -- Automaton - INT: 70
    (21455,13,70,3),  -- Automaton - MND: 70
    (21455,14,70,3),  -- Automaton - CHR: 70

-- Animator P
    (21456,8,104,3),   -- Automaton - STR: 104
    (21456,9,104,3),   -- Automaton - DEX: 104
    (21456,10,104,3),  -- Automaton - VIT: 104
    (21456,11,104,3),  -- Automaton - AGI: 104
    (21456,12,104,3),  -- Automaton - INT: 104
    (21456,13,104,3),  -- Automaton - MND: 104
    (21456,14,104,3),  -- Automaton - CHR: 104

-- Animator P +1
    (21457,8,109,3),   -- Automaton - STR: 109
    (21457,9,109,3),   -- Automaton - DEX: 109
    (21457,10,109,3),  -- Automaton - VIT: 109
    (21457,11,109,3),  -- Automaton - AGI: 109
    (21457,12,109,3),  -- Automaton - INT: 109
    (21457,13,109,3),  -- Automaton - MND: 109
    (21457,14,109,3),  -- Automaton - CHR: 109

-- Animator P II
    (21458,8,104,3),   -- Automaton - STR: 104
    (21458,9,104,3),   -- Automaton - DEX: 104
    (21458,10,104,3),  -- Automaton - VIT: 104
    (21458,11,104,3),  -- Automaton - AGI: 104
    (21458,12,104,3),  -- Automaton - INT: 104
    (21458,13,104,3),  -- Automaton - MND: 104
    (21458,14,104,3),  -- Automaton - CHR: 104

-- Animator P II +1
    (21459,8,109,3),   -- Automaton - STR: 109
    (21459,9,109,3),   -- Automaton - DEX: 109
    (21459,10,109,3),  -- Automaton - VIT: 109
    (21459,11,109,3),  -- Automaton - AGI: 109
    (21459,12,109,3),  -- Automaton - INT: 109
    (21459,13,109,3),  -- Automaton - MND: 109
    (21459,14,109,3),  -- Automaton - CHR: 109

-- Arasy Sainti
    (21504,25,10,3), -- Automaton - ACC: 10
    (21504,30,10,3), -- Automaton - MACC: 10

-- Arasy Sainti +1
    (21505,25,15,3), -- Automaton - ACC: 15
    (21505,30,15,3), -- Automaton - MACC: 15

-- Xiucoatl
    (21526,25,50,3), -- Automaton - ACC: 50
    (21526,26,50,3), -- Automaton - RACC: 50
    (21526,30,50,3), -- Automaton - MACC: 50

-- Sakpatas Fists
    (21527,8,20,3),  -- Automaton - STR: 20
    (21527,9,20,3),  -- Automaton - DEX: 20
    (21527,10,20,3), -- Automaton - VIT: 20
    (21527,11,20,3), -- Automaton - AGI: 20
    (21527,12,20,3), -- Automaton - INT: 20
    (21527,13,20,3), -- Automaton - MND: 20
    (21527,14,20,3), -- Automaton - CHR: 20
    (21527,25,50,3), -- Automaton - ACC: 50
    (21527,26,50,3), -- Automaton - RACC: 50
    (21527,30,50,3), -- Automaton - MACC: 50

-- Dragon Fangs
    (21528,25,40,0), -- All Pets - ACC: 40
    (21528,26,40,0), -- All Pets - RACC: 40
    (21528,30,40,0), -- All Pets - MACC: 40

-- Premium Heart
    (21529,25,40,0), -- All Pets - ACC: 40
    (21529,26,40,0), -- All Pets - RACC: 40
    (21529,30,40,0), -- All Pets - MACC: 40

-- Arasy Tabar
    (21704,25,10,0), -- All Pets - ACC: 10

-- Arasy Tabar +1
    (21705,25,15,0), -- All Pets - ACC: 15

-- Monster Axe
    (21715,25,30,0), -- All Pets - ACC: 30
    (21715,26,30,0), -- All Pets - RACC: 30
    (21715,30,30,0), -- All Pets - MACC: 30

-- Ankusa Axe
    (21716,25,40,0), -- All Pets - ACC: 40
    (21716,26,40,0), -- All Pets - RACC: 40
    (21716,30,40,0), -- All Pets - MACC: 40

-- Pangu
    (21717,25,50,0), -- All Pets - ACC: 50
    (21717,26,50,0), -- All Pets - RACC: 50
    (21717,30,50,0), -- All Pets - MACC: 50

-- Aymur
    (21751,23,80,0), -- All Pets - ATT: 80

-- Arasy Lance
    (21865,370,5,2), -- Wyvern - REGEN: 5

-- Arasy Lance +1
    (21866,370,8,2), -- Wyvern - REGEN: 8

-- Arasy Rod
    (22015,30,10,1), -- Avatar - MACC: 10

-- Arasy Rod +1
    (22016,30,15,1), -- Avatar - MACC: 15

-- Grioavolr
    (22054,28,115,1), -- Avatar - MATT: 115
    (22054,30,35,1),  -- Avatar - MACC: 35

-- Nirvana
    (22063,126,40,1), -- Avatar - BP_DAMAGE: 40

-- Arasy Staff
    (22074,126,3,1), -- Avatar - BP_DAMAGE: 3

-- Arasy Staff +1
    (22075,126,5,1), -- Avatar - BP_DAMAGE: 5

-- Draumstafir
    (22096,25,50,1), -- Avatar - ACC: 50
    (22096,26,50,1), -- Avatar - RACC: 50
    (22096,30,50,1), -- Avatar - MACC: 50

-- Elan Strap
    (22210,126,3,1), -- Avatar - BP_DAMAGE: 3

-- Elan Strap +1
    (22211,126,5,1), -- Avatar - BP_DAMAGE: 5

-- Eminent Animator II
    (22260,8,46,3),   -- Automaton - STR: 46
    (22260,9,46,3),   -- Automaton - DEX: 46
    (22260,10,46,3),  -- Automaton - VIT: 46
    (22260,11,46,3),  -- Automaton - AGI: 46
    (22260,12,46,3),  -- Automaton - INT: 46
    (22260,13,46,3),  -- Automaton - MND: 46
    (22260,14,46,3),  -- Automaton - CHR: 46

-- Divinator II
    (22261,8,89,3),   -- Automaton - STR: 89
    (22261,9,89,3),   -- Automaton - DEX: 89
    (22261,10,89,3),  -- Automaton - VIT: 89
    (22261,11,89,3),  -- Automaton - AGI: 89
    (22261,12,89,3),  -- Automaton - INT: 89
    (22261,13,89,3),  -- Automaton - MND: 89
    (22261,14,89,3),  -- Automaton - CHR: 89

-- Totemic Helm +2
    (23048,25,30,0), -- Pet: ACC: 30

-- Foire Taj +2
    (23057,25,31,3),   -- Automaton - ACC: 31
    (23057,369,1,3),   -- Automaton - REFRESH: 1
    (23057,370,3,3),   -- Automaton - REGEN: 3
    (23057,384,600,3), -- Automaton - HASTE_GEAR: 600

-- Ankusa Helm +2
    (23071,384,500,0), -- All Pets - HASTE_GEAR: 5%

-- Glyphic Horn +2
    (23077,23,47,1), -- Avatar: ATT: 47
    (23077,28,53,1), -- Avatar: MATT: 53

-- Pitre Taj +2
    (23080,23,47,3), -- Automaton: ATT: 47
    (23080,24,47,3), -- Automaton: RATT: 47
    (23080,25,27,3), -- Automaton: ACC: 27
    (23080,26,27,3), -- Automaton: RACC: 27
    (23080,369,4,3), -- Automaton: REFRESH: 4
    (23080,370,4,3), -- Automaton: REGEN: 4

-- Bagua Galero +2
    (23083,2,500,8), -- Luopan - HP: 500

-- Nukumi Cabasset +2
    (23093,25,51,0), -- Pet: ACC: 51
    (23093,26,51,0), -- Pet: RACC: 51
    (23093,30,51,0), -- Pet: MACC: 51
    (23093,1155,26,0), -- All Pets - ENHANCES_MONSTER_CORRELATION: 26

-- Peltast's Mezail +2
    (23098,25,51,2),  -- Wyvern - ACC: 51
    (23098,30,51,2),  -- Wyvern - MACC: 51
    (23098,480,16,2), -- Wyvern - ABSORB_DMG_CHANCE: 16

-- Beckoner's Horn +2
    (23099,25,51,1), -- Avatar - ACC: 51
    (23099,26,51,1), -- Avatar - RACC: 51
    (23099,30,51,1), -- Avatar - MACC: 51

-- Karagoz cappello +2
    (23102,25,51,3),   -- Automaton: ACC: 51
    (23102,26,51,3),   -- Automaton: RACC: 51
    (23102,30,51,3),   -- Automaton: MACC: 51
    (23102,995,575,3), -- Automaton: PET_TP_BONUS: 575

-- Azimuth Hood +2
    (23105,370,4,8), -- Luopan: REGEN: 4

-- Vishap Mail +2
    (23120,370,10,2), -- Wyvern - REGEN: 10

-- Convokers Doublet +2
    (23121,25,35,1),  -- Avatar - ACC: 35
    (23121,30,35,1),  -- Avatar - MACC: 35
    (23121,126,14,1), -- Avatar - BP_DAMAGE: 14

-- Foire Tobe +2
    (23124,2,165,3),   -- Automaton - HP: 165
    (23124,5,165,3),   -- Automaton - MP: 165
    (23124,384,400,3), -- Automaton - HASTE_GEAR: 400

-- Ankusa jackcoat +2
    (23138,288,3,0),   -- Pet: DOUBLE_ATTACK: 3
    (23138,384,600,0), -- Pet: HASTE_GEAR: 6%

-- Glyphic Doublet +2
    (23144,165,16,1), -- Avatar: CRITHITRATE: 16
    (23144,288,10,1), -- Avatar: DOUBLE_ATTACK: 10

-- Pitre Tobe +2
    (23147,23,50,3), -- Automaton: ATT: 50
    (23147,24,50,3), -- Automaton: RATT: 50
    (23147,25,40,3), -- Automaton: ACC: 40
    (23147,26,40,3), -- Automaton: RACC: 40
    (23147,73,14,3), -- Automaton: STORETP: 14

-- Nukumi Gausape +2
    (23160,25,54,0), -- Pet: ACC: 54
    (23160,26,54,0), -- Pet: RACC: 54
    (23160,30,54,0), -- Pet: MACC: 54

-- Peltast's plackart +2
    (23165,25,54,2), -- Wyvern: ACC: 54
    (23165,30,54,2), -- Wyvern: MACC: 54
-- TODO: Wyvern: Grants food effect

-- Beckoner's Doublet +2
    (23166,25,54,1),  -- Avatar: ACC: 54
    (23166,26,54,1),  -- Avatar: RACC: 54
    (23166,30,54,1),  -- Avatar: MACC: 54
    (23166,126,12,1), -- Avatar: BP_DAMAGE: 12

-- Karagoz Farsetto +2
    (23169,25,54,3),   -- Automaton: ACC: 54
    (23169,26,54,3),   -- Automaton: RACC: 54
    (23169,30,54,3),   -- Automaton: MACC: 54

-- Foire Dastanas +2
    (23191,25,32,3),   -- Automaton - ACC: 32
    (23191,384,500,3), -- Automaton - HASTE_GEAR: 500

-- Geomancy Mitaines +2
    (23195,160,-1200,8), -- Luopan - DMG: -1200

-- Ankusa Gloves +2
    (23205,161,-500,0), -- Pet: DMGPHYS: -5%
    (23205,164,-500,0), -- Pet: DMGRANGE -5%

-- Pteroslaver finger gauntlets +2
    (23210,163,-1000,2), -- Wyvern: DMGMAGIC: -1000

-- Glyphic Bracers +2
    (23211,25,42,1),   -- Avatar: ACC: 42
    (23211,384,600,1), -- Avatar: HASTE_GEAR: 6%

-- Pitre Dastanas +2
    (23214,289,10,3),  -- Automaton: SUBTLE_BLOW: 10
    (23214,384,600,3), -- Automaton: HASTE_GEAR: 6%

-- Beckoner's Bracers +2
    (23227,25,52,0), -- Pet: ACC: 52
    (23227,26,52,0), -- Pet: RACC: 52
    (23227,30,52,0), -- Pet: MACC: 52

-- Peltast's vambraces +2
    (23232,25,52,2), -- Wyvern: ACC: 52
    (23232,30,52,2), -- Wyvern: MACC: 52

-- Beckoner's Bracers +2
    (23233,25,52,1), -- Avatar: ACC: 52
    (23233,26,52,1), -- Avatar: RACC: 52
    (23233,30,52,1), -- Avatar: MACC: 52
    (23233,126,8,1), -- Avatar: BP_DAMAGE: 8

-- Karagoz Guanti +2
    (23236,8,21,3),  -- Automaton: STR: 21
    (23236,9,21,3),  -- Automaton: DEX: 21
    (23236,10,21,3), -- Automaton: AGI: 21
    (23236,25,52,3), -- Automaton: ACC: 52
    (23236,26,52,3), -- Automaton: RACC: 52
    (23236,30,52,3), -- Automaton: MACC: 52

-- Totemic Trousers +2
    (23249,23,30,0), -- Pet: ATT: 30

-- Vishap Brais +2
    (23254,3,25,2), -- Wyvern - HPP: 25

-- Foire Churidars +2
    (23258,5,75,3),     -- Automaton - MP: 75
    (23258,160,-300,3), -- Automaton - DMG: -300
    (23258,374,14,3),   -- Automaton - CURE_POTENCY: 14
    (23258,384,400,3),  -- Automaton - HASTE_GEAR: 400

-- Ankusa Trousers +2
    (23272,73,4,0),    -- Pet: STORETP: 4
    (23272,384,500,0), -- Pet: HASTE_GEAR: 5%

-- Pteroslaver brais +2
    (23277,161,-1000,2), -- Wyvern: DMGPHYS: -10%
    (23277,164,-1000,2), -- Wyvern: DMGRANGE -10%

-- Pteroslaver brais +2
    (23278,28,44,1), -- Avatar: MATT: 44
    (23278,30,35,1), -- Avatar: MACC: 35

-- Pitre Churidars +2
    (23281,28,44,3), -- Automaton: MATT: 44
    (23281,30,38,3), -- Automaton: MACC: 38
    (23281,170,9,3), -- Automaton: FASTCAST: 9

-- Nukumi Quijotes +2
    (23294,25,53,0), -- Pet: ACC: 53
    (23294,26,53,0), -- Pet: RACC: 53
    (23294,30,53,0), -- Pet: MACC: 53

-- Peltast's cuissots +2
    (23299,25,53,2), -- Wyvern: ACC: 53
    (23299,30,53,2), -- Wyvern: MACC: 53

-- Beckoner's spats +2
    (23300,25,53,1), -- Avatar: ACC: 53
    (23300,26,53,1), -- Avatar: RACC: 53
    (23300,30,53,1), -- Avatar: MACC: 53

-- Karagoz pantaloni +2
    (23303,25,53,3), -- Automaton: ACC: 53
    (23303,26,53,3), -- Automaton: RACC: 53
    (23303,30,53,3), -- Automaton: MACC: 53

-- Totemic Gaiters +2
    (23316,23,20,0), -- Pet: ATT: 20
    (23316,25,20,0), -- Pet: ACC: 20

-- Convokers Pigaches +2
    (23322,23,30,1), -- Avatar: ACC: 30 
    (23322,30,30,1), -- Avatar: MACC: 30
    (23322,68,30,1), -- Avatar: EVA: 30
    (23322,126,8,1), -- Avatar: BP_DAMAGE: 8 

-- Foire Babouches +2
    (23325,28,20,3),   -- Automaton - MATT: 20
    (23325,30,40,3),   -- Automaton - MACC: 40
    (23325,384,400,3), -- Automaton - HASTE_GEAR: 400

-- Ankusa Gaiters +2
    (23339,68,28,0),    -- Pet: EVA: 28
    (23339,161,-400,0), -- Pet: DMGPHYS: -4%
    (23339,164,-400,0), -- Pet: DMGRANGE -4%

-- Pteroslaver greaves +2
    (23344,2,260,2), -- Wyvern: HP: 260
    (23344,370,7,2), -- Wyvern: REGEN: 7

-- Glyphic pigaches +2
    (23345,23,74,1),  -- Avatar: ATT: 74
    (23345,25,26,1),  -- Avatar: ACC: 26
    (23345,562,11,1), -- Avatar: MAGIC_CRITHITRATE: 11

-- Pitre Babouches +2
    (23348,28,50,3), -- Automaton: MATT: 50
    (23348,30,33,3), -- Automaton: MACC: 33

-- Bagua Sandals +2
    (23351,370,4,8), -- Luopan - REGEN: 4

-- Nukumi Ocreae +2
    (23361,25,50,0), -- Pet: ACC: 50
    (23361,26,50,0), -- Pet: RACC: 50
    (23361,30,50,0) -- Pet: MACC: 50
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `value` = IF(`value` <> VALUES(`value`), VALUES(`value`), `value`)
;

insert into `item_mods_pet`
(
    `itemId`, `modId`, `value`, `petType`
)
VALUES
-- Peltast's schynbalds +2
    (23366,25,50,2), -- Wyvern: ACC:  50
    (23366,30,50,2), -- Wyvern: MACC: 50

-- Beckoner's pigaches +2
    (23367,25,50,1), -- Avatar: ACC:  50
    (23367,26,50,1), -- Avatar: RACC: 50
    (23367,30,50,1), -- Avatar: MACC: 50
    (23367,126,8,1), -- Avatar: BP_DAMAGE: 8

-- Karagoz Scarpe +2
    (23370,12,25,3), -- Automaton: INT:  25
    (23370,13,25,3), -- Automaton: MND:  25
    (23370,25,50,3), -- Automaton: ACC:  50
    (23370,26,50,3), -- Automaton: RACC: 50
    (23370,30,50,3), -- Automaton: MACC: 50

-- Totemic Helm +3
    (23383,25,40,0), -- Pet: ACC: 40

-- Foire Taj +3
    (23392,25,41,3),   -- Automaton - ACC: 41
    (23392,369,2,3),   -- Automaton - REFRESH: 2
    (23392,370,6,3),   -- Automaton - REGEN: 6
    (23392,384,700,3), -- Automaton - HASTE_GEAR: 700

-- Bagua Galero +3
    (23418,2,600,8), -- Luopan - HP: 600

-- Vishap Mail +3
    (23455,370,15,2), -- Wyvern - REGEN: 15

-- Convokers Doublet +3
    (23456,25,45,1),  -- Avatar - ACC: 45
    (23456,30,45,1),  -- Avatar - MACC: 45
    (23456,126,16,1), -- Avatar - BP_DAMAGE: 16

-- Foire Tobe +3
    (23459,2,220,3),   -- Automaton - HP: 220
    (23459,5,220,3),   -- Automaton - MP: 220
    (23459,384,500,3), -- Automaton - HASTE_GEAR: 500

-- Foire Dastanas +3
    (23526,25,42,3),   -- Automaton - ACC: 42
    (23526,384,500,3), -- Automaton - HASTE_GEAR: 500

-- Geomancy Mitaines +3
    (23530,160,-1300,8), -- Luopan - DMG: -1300

-- Totemic Trousers +3
    (23584,23,40,0), -- Pet: ATT: 40

-- Vishap Brais +3
    (23589,3,27,2), -- Wyvern - HPP: 27

-- Foire Churidars +3
    (23593,5,75,3),     -- Automaton - MP: 75
    (23593,160,-600,3), -- Automaton - DMG: -600
    (23593,374,14,3),   -- Automaton - CURE_POTENCY: 14
    (23593,384,600,3),  -- Automaton - HASTE_GEAR: 600

-- Foire Babouches +3
    (23660,28,25,3),   -- Automaton - MATT: 25
    (23660,30,50,3),   -- Automaton - MACC: 50
    (23660,384,500,3), -- Automaton - HASTE_GEAR: 500

-- Ankusa Gaiters +3
    (23674,68,38,0),    -- All Pets - EVA: 38
    (23674,161,-500,0), -- All Pets - DMGPHYS: -500
    (23674,164,-500,0), -- All Pets - DMGRANGE: -500

-- Pteroslaver Greaves +3
    (23679,2,290,2),  -- Wyvern - HP: 290
    (23679,370,10,2), -- Wyvern - REGEN: 10

-- Glyphic Pigaches +3
    (23680,23,89,1),  -- Avatar - ATT: 89
    (23680,25,36,1),  -- Avatar - ACC: 36
    (23680,562,13,1), -- Avatar - MAGIC_CRITHITRATE: 13

-- Pitre Babouches +3
    (23683,28,57,3), -- Automaton - MATT: 57
    (23683,30,43,3), -- Automaton - MACC: 43

-- Bagua Sandals +3
    (23686,370,5,8), -- Luopan - REGEN: 5

-- Gletis Mask (Checked)
    (23756,25,50,0), -- All Pets - ACC: 50
    (23756,26,50,0), -- All Pets - RACC: 50
    (23756,30,50,0), -- All Pets - MACC: 50

-- Mpacas Cap (Checked)
    (23758,25,50,0), -- All Pets - ACC: 50
    (23758,26,50,0), -- All Pets - RACC: 50
    (23758,30,50,0), -- All Pets - MACC: 50

-- Bunzis Hat (Checked)
    (23760,25,50,0), -- All Pets - ACC: 50
    (23760,26,50,0), -- All Pets - RACC: 50
    (23760,30,50,0), -- All Pets - MACC: 50

-- Nyame Helm (Checked)
    (23761,25,50,0), -- All Pets - ACC: 50
    (23761,26,50,0), -- All Pets - RACC: 50
    (23761,30,50,0), -- All Pets - MACC: 50

-- Gletis Cuirass (Checked)
    (23763,25,50,0), -- All Pets - ACC: 50
    (23763,26,50,0), -- All Pets - RACC: 50
    (23763,30,50,0), -- All Pets - MACC: 50

-- Mpacas Doublet (Checked)
    (23765,25,50,0), -- All Pets - ACC: 50
    (23765,26,50,0), -- All Pets - RACC: 50
    (23765,30,50,0), -- All Pets - MACC: 50

-- Bunzis Robe (Checked)
    (23767,25,50,0), -- All Pets - ACC: 50
    (23767,26,50,0), -- All Pets - RACC: 50
    (23767,30,50,0), -- All Pets - MACC: 50

-- Nyame Mail (Checked)
    (23768,25,50,0), -- All Pets - ACC: 50
    (23768,26,50,0), -- All Pets - RACC: 50
    (23768,30,50,0), -- All Pets - MACC: 50

-- Gletis Gauntlets (Checked)
    (23770,25,50,0),    -- All Pets - ACC: 50
    (23770,26,50,0),    -- All Pets - RACC: 50
    (23770,30,50,0),    -- All Pets - MACC: 50
    (23770,160,-800,0), -- All Pets - DMG: -800

-- Mpacas Gloves (Checked)
    (23772,25,50,0),  -- All Pets - ACC: 50
    (23772,26,50,0),  -- All Pets - RACC: 50
    (23772,30,50,0),  -- All Pets - MACC: 50
    (23772,840,10,3), -- Automaton - ALL_WSDMG_ALL_HITS: 10

-- Bunzis Gloves (Checked)
    (23774,25,50,0), -- All Pets - ACC: 50
    (23774,26,50,0), -- All Pets - RACC: 50
    (23774,30,50,0), -- All Pets - MACC: 50

-- Nyame Gauntlets (Checked)
    (23775,25,50,0), -- All Pets - ACC: 50
    (23775,26,50,0), -- All Pets - RACC: 50
    (23775,30,50,0), -- All Pets - MACC: 50

-- Gletis Breeches (Checked)
    (23777,25,50,0), -- All Pets - ACC: 50
    (23777,26,50,0), -- All Pets - RACC: 50
    (23777,30,50,0), -- All Pets - MACC: 50

-- Mpacas Hose (Checked)
    (23779,25,50,0), -- All Pets - ACC: 50
    (23779,26,50,0), -- All Pets - RACC: 50
    (23779,30,50,0), -- All Pets - MACC: 50

-- Bunzis Pants (Checked)
    (23781,25,50,0), -- All Pets - ACC: 50
    (23781,26,50,0), -- All Pets - RACC: 50
    (23781,30,50,0), -- All Pets - MACC: 50

-- Nyame Flanchard (Checked)
    (23782,25,50,0), -- All Pets - ACC: 50
    (23782,26,50,0), -- All Pets - RACC: 50
    (23782,30,50,0), -- All Pets - MACC: 50

-- Gletis Boots (Checked)
    (23784,25,50,0), -- All Pets - ACC: 50
    (23784,26,50,0), -- All Pets - RACC: 50
    (23784,30,50,0), -- All Pets - MACC: 50
-- TODO: Summoned Pet: Lvl +1

-- Mpacas Boots (Checked)
    (23786,25,50,0), -- All Pets - ACC: 50
    (23786,26,50,0), -- All Pets - RACC: 50
    (23786,30,50,0), -- All Pets - MACC: 50

-- Bunzis Sabots (Checked)
    (23788,25,50,0), -- All Pets - ACC: 50
    (23788,26,50,0), -- All Pets - RACC: 50
    (23788,30,50,0), -- All Pets - MACC: 50
-- TODO: Avatar: Lvl +1

-- Nyame Sollerets (Checked)
    (23789,25,50,0), -- All Pets - ACC: 50
    (23789,26,50,0), -- All Pets - RACC: 50
    (23789,30,50,0), -- All Pets - MACC: 50

-- Beastmaster Collar
    (25465,25,15,0), -- All Pets - ACC: 15
    (25465,26,15,0), -- All Pets - RACC: 15
    (25465,30,15,0), -- All Pets - MACC: 15

-- Beastmaster Collar +1
    (25466,25,20,0), -- All Pets - ACC: 20
    (25466,26,20,0), -- All Pets - RACC: 20
    (25466,30,20,0), -- All Pets - MACC: 20

-- Beastmaster Collar +2
    (25467,25,25,0), -- All Pets - ACC: 25
    (25467,26,25,0), -- All Pets - RACC: 25
    (25467,30,25,0), -- All Pets - MACC: 25

-- Summoners Collar
    (25501,25,15,1), -- Avatar - ACC: 15
    (25501,26,15,1), -- Avatar - RACC: 15
    (25501,30,15,1), -- Avatar - MACC: 15

-- Summoners Collar +1
    (25502,25,20,1), -- Avatar - ACC: 20
    (25502,26,20,1), -- Avatar - RACC: 20
    (25502,30,20,1), -- Avatar - MACC: 20

-- Summoners Collar +2
    (25503,25,25,1), -- Avatar - ACC: 25
    (25503,26,25,1), -- Avatar - RACC: 25
    (25503,30,25,1), -- Avatar - MACC: 25

-- Puppetmasters Collar
    (25519,25,15,3), -- Automaton - ACC: 15
    (25519,26,15,3), -- Automaton - RACC: 15
    (25519,30,15,3), -- Automaton - MACC: 15

-- Puppetmasters Collar +1
    (25520,25,20,3), -- Automaton - ACC: 20
    (25520,26,20,3), -- Automaton - RACC: 20
    (25520,30,20,3), -- Automaton - MACC: 20

-- Puppetmasters Collar +2
    (25521,25,25,3), -- Automaton - ACC: 25
    (25521,26,25,3), -- Automaton - RACC: 25
    (25521,30,25,3), -- Automaton - MACC: 25

-- Heyoka Cap
    (25563,25,40,0),   -- All Pets - ACC: 40
    (25563,26,40,0),   -- All Pets - RACC: 40
    (25563,27,8,0),    -- All Pets - ENMITY: 8
    (25563,384,600,0), -- All Pets - HASTE_GEAR: 600

-- Heyoka Cap +1
    (25564,25,50,0),   -- All Pets - ACC: 50
    (25564,26,50,0),   -- All Pets - RACC: 50
    (25564,27,10,0),   -- All Pets - ENMITY: 10
    (25564,384,600,0), -- All Pets - HASTE_GEAR: 600

-- Baayami Hat
    (25565,368,3,1), -- Avatar - REGAIN: 3

-- Baayami Hat +1
    (25566,368,4,1), -- Avatar - REGAIN: 4

-- Cath Palug Crown (Checked)
    (25593,25,38,1),  -- Avatar - ACC: 38
    (25593,26,38,1),  -- Avatar - RACC: 38
    (25593,28,38,1),  -- Avatar - MATT: 38
    (25593,30,38,1),  -- Avatar - MACC: 38
    (25593,126,10,1), -- Avatar - BP_DAMAGE: 10

-- Emicho Haubert +1 (Checked)
    (25683,28,35,0),    -- All Pets - MATT: 35
    (25683,160,-400,0), -- All Pets - DMG: -400

-- Shulmanu Collar (Checked)
    (26026,23,20,0), -- All Pets - ATT: 20
    (26026,25,20,0), -- All Pets - ACC: 20
    (26026,288,5,0), -- All Pets - DOUBLE_ATTACK: 5

-- Lugalbanda Earring (Checked)
    (26082,25,15,1),  -- Avatar - ACC: 15
    (26082,26,15,1),  -- Avatar - RACC: 15
    (26082,30,15,1),  -- Avatar - MACC: 15
    (26082,126,10,1), -- Avatar - BP_DAMAGE: 10

-- Thurandaut Ring +1 (Checked)
    (26201,23,23,0),    -- All Pets - ATT: 23
    (26201,24,23,0),    -- All Pets - RATT: 23
    (26201,25,22,0),    -- All Pets - ACC: 22
    (26201,26,22,0),    -- All Pets - RACC: 22
    (26201,160,-400,0), -- All Pets - DMG: -400
    (26201,384,400,0),  -- All Pets - HASTE_GEAR: 400

-- Scintillating Cape (Checked)
    (26241,23,16,0), -- All Pets - ATT: 16
    (26241,28,16,0), -- All Pets - MATT: 16
    (26241,165,3,0), -- All Pets - CRITHITRATE: 3

-- Campestress Cape
    (26260,126,5,1), -- Avatar - BP_DAMAGE: 5

-- Ankusa Helm
    (26640,384,300,0), -- Pet: HASTE_GEAR: 3%

-- Ankusa Helm +1
    (26641,384,400,0), -- Pet: HASTE_GEAR: 4%

-- Glyphic Horn
    (26652,28,20,1), -- Avatar - MATT: 20

-- Glyphic Horn +1
    (26653,28,23,1), -- Avatar - MATT: 23

-- Pitre Taj
    (26658,369,2,3), -- Automaton - REFRESH: 2
    (26658,370,3,3), -- Automaton - REGEN: 3

-- Pitre Taj +1
    (26659,369,3,3), -- Automaton - REFRESH: 3
    (26659,370,3,3), -- Automaton - REGEN: 3

-- Apogee Crown +1
    (26677,2,110,1), -- Avatar - HP: 110
    (26677,25,35,1), -- Avatar - ACC: 35
    (26677,27,10,1), -- Avatar - ENMITY: 10

-- Nukumi Cabasset
    (26756,1155,22,0), -- All Pets - ENHANCES_MONSTER_CORRELATION: 22

-- Nukumi Cabasset +1
    (26757,1155,24,0), -- All Pets - ENHANCES_MONSTER_CORRELATION: 24

-- Karagoz Capello
    (26774,345,525,3), -- Automaton - TP_BONUS: 525

-- Karagoz Capello +1
    (26775,345,550,3), -- Automaton - TP_BONUS: 550

-- Ankusa Jackcoat
    (26816,384,400,0), -- Pet: HASTE_GEAR: 4%

-- Ankusa Jackcoat +1
    (26817,384,500,0), -- Pet: HASTE_GEAR: 5%

-- Glyphic Doublet
    (26828,165,8,1), -- Avatar - CRITHITRATE: 8

-- Glyphic Doublet +1
    (26829,165,12,1), -- Avatar - CRITHITRATE: 12

-- Pitre Tobe
    (26834,25,18,3), -- Automaton - ACC: 18
    (26834,26,18,3), -- Automaton - RACC: 18
    (26834,73,12,3), -- Automaton - STORETP: 12

-- Pitre Tobe +1
    (26835,25,21,3), -- Automaton - ACC: 21
    (26835,26,21,3), -- Automaton - RACC: 21
    (26835,73,13,3), -- Automaton - STORETP: 13

-- Apogee Dalmatica +1 (Checked)
    (26853,2,160,1), -- Avatar - HP: 160

-- Shomonjijoe +1
    (26888,27,14,1), -- Avatar - ENMITY: 14

-- Beckoners Doublet
    (26926,126,10,1), -- Avatar - BP_DAMAGE: 10

-- Beckoners Doublet +1
    (26927,126,11,1), -- Avatar - BP_DAMAGE: 11

-- Ankusa Gloves
    (26992,161,-300,0), -- Pet: DMGPHYS: -3%
    (26992,164,-300,0), -- Pet: DMGRANGE -3%

-- Ankusa Gloves +1
    (26993,161,-400,0), -- Pet: DMGPHYS: -4%
    (26993,164,-400,0), -- Pet: DMGRANGE -4%

-- Glyphic Bracers
    (27004,25,20,1),   -- Avatar - ACC: 20
    (27004,384,200,1), -- Avatar - HASTE_GEAR: 200

-- Glyphic Bracers +1
    (27005,25,28,1),   -- Avatar - ACC: 28
    (27005,384,300,1), -- Avatar - HASTE_GEAR: 300

-- Pitre Dastanas
    (27010,289,7,3),   -- Automaton - SUBTLE_BLOW: 7
    (27010,384,400,3), -- Automaton - HASTE_GEAR: 400

-- Pitre Dastanas +1
    (27011,289,9,3),   -- Automaton - SUBTLE_BLOW: 9
    (27011,384,500,3), -- Automaton - HASTE_GEAR: 500

-- Crushers Gauntlets
    (27044,2,50,2), -- Wyvern - HP: 50

-- Beckoners Bracers
    (27080,25,20,1), -- Avatar - ACC: 20

-- Beckoners Bracers +1
    (27081,25,30,1), -- Avatar - ACC: 30

-- Karagoz Guanti
    (27086,8,13,3),  -- Automaton - STR: 13
    (27086,9,13,3),  -- Automaton - DEX: 13
    (27086,11,13,3), -- Automaton - AGI: 13

-- Karagoz Guanti +1
    (27087,8,16,3),  -- Automaton - STR: 16
    (27087,9,16,3),  -- Automaton - DEX: 16
    (27087,11,16,3), -- Automaton - AGI: 16

-- Asteria Mitts
    (27106,28,25,1), -- Avatar - MATT: 25

-- Asteria Mitts +1
    (27107,28,26,1), -- Avatar - MATT: 26

-- Lamassu Mitts
    (27108,28,25,1), -- Avatar - MATT: 25

-- Lamassu Mitts +1
    (27109,28,26,1), -- Avatar - MATT: 26

-- Ankusa Trousers
    (27168,384,300,0), -- Pet: HASTE_GEAR: 3%

-- Ankusa Trousers +1
    (27169,384,400,0), -- Pet: HASTE_GEAR: 4%

-- Glyphic Spats
    (27180,30,10,1), -- Avatar - MACC: 10

-- Glyphic Spats +1
    (27181,30,13,1), -- Avatar - MACC: 13

-- Pitre Churidars
    (27186,30,15,3), -- Automaton - MACC: 15
    (27186,170,7,3), -- Automaton - FASTCAST: 7

-- Pitre Churidars +1
    (27187,30,18,3), -- Automaton - MACC: 18
    (27187,170,8,3), -- Automaton - FASTCAST: 8

-- Avatara Slops
    (27221,27,4,1),  -- Avatar - ENMITY: 4
    (27221,126,7,1), -- Avatar - BP_DAMAGE: 7

-- Beckoners Spats
    (27265,345,550,1), -- Avatar - TP_BONUS: 550

-- Beckoners Spats +1
    (27266,345,600,1), -- Avatar - TP_BONUS: 600

-- Emicho Hose +1 (Checked)
    (27299,3,21,2), -- Wyvern - HPP: 21
    (27299,165,5,0), -- Wyvern - CRITHITRATE: 5
    (27299,288,5,0), -- All Pets - DOUBLE_ATTACK: 5

-- Ankusa Gaiters
    (27344,68,15,0),    -- Pet: EVA: 15
    (27344,161,-300,0), -- Pet: DMGPHYS: -3%
    (27344,164,-300,0), -- Pet: DMGRANGE -3%

-- Ankusa Gaiters +1
    (27345,68,18,0),    -- Pet: EVA: 18
    (27345,161,-300,0), -- Pet: DMGPHYS: -3%
    (27345,164,-300,0), -- Pet: DMGRANGE -3%

-- Glyphic Pigaches
    (27356,23,28,1), -- Avatar - ATT: 28
    (27356,562,7,1), -- Avatar - MAGIC_CRITHITRATE: 7

-- Glyphic Pigaches +1
    (27357,23,28,1), -- Avatar - ATT: 28
    (27357,562,9,1), -- Avatar - MAGIC_CRITHITRATE: 9

-- Pitre Babouches
    (27362,28,15,3), -- Automaton - MATT: 15
    (27362,30,12,3), -- Automaton - MACC: 12

-- Pitre Babouches +1
    (27363,28,18,3), -- Automaton - MATT: 18
    (27363,30,15,3), -- Automaton - MACC: 15

-- Bagua Sandals
    (27368,370,2,8), -- Luopan - REGEN: 2

-- Bagua Sandals +1
    (27369,370,3,8), -- Luopan - REGEN: 3

-- Beckoners Pigaches
    (27439,30,17,1), -- Avatar - MACC: 17

-- Beckoners Pigaches +1
    (27440,30,27,1), -- Avatar - MACC: 27

-- Karagoz Scarpe
    (27445,12,17,3), -- Automaton - INT: 17
    (27445,13,17,3), -- Automaton - MND: 17

-- Karagoz Scarpe +1
    (27446,12,20,3), -- Automaton - INT: 20
    (27446,13,20,3), -- Automaton - MND: 20

-- Emicho Gambieras +1 (Checked)
    (27470,480,6,2), -- Wyvern - ABSORB_DMG_CHANCE: 6

-- Totemic Helm
    (27671,25,20,0), -- Pet: ACC: 20

-- Convokers Horn
    (27677,27,4,1), -- Avatar - ENMITY: 4

-- Foire Taj
    (27680,71,6,3),    -- Automaton - MPHEAL: 6
    (27680,72,6,3),    -- Automaton - HPHEAL: 6
    (27680,384,500,3), -- Automaton - HASTE_GEAR: 500

-- Totemic Helm +1
    (27692,25,20,0), -- Pet: ACC: 20

-- Convokers Horn +1
    (27698,27,4,1), -- Avatar - ENMITY: 4

-- Foire Taj +1
    (27701,71,8,3),    -- Automaton - MPHEAL: 8
    (27701,72,8,3),    -- Automaton - HPHEAL: 8
    (27701,384,500,3), -- Automaton - HASTE_GEAR: 500

-- Vishap Mail
    (27820,370,2,2), -- Wyvern - REGEN: 2

-- Convokers Doublet
    (27821,126,11,1), -- Avatar - BP_DAMAGE: 11

-- Foire Tobe
    (27824,2,85,3),    -- Automaton - HP: 85
    (27824,5,85,3),    -- Automaton - MP: 85
    (27824,384,300,3), -- Automaton - HASTE_GEAR: 300

-- Vishap Mail +1
    (27841,370,3,2), -- Wyvern - REGEN: 3

-- Convokers Doublet +1
    (27842,126,12,1), -- Avatar - BP_DAMAGE: 12

-- Foire Tobe +1
    (27845,2,110,3),   -- Automaton - HP: 110
    (27845,5,110,3),   -- Automaton - MP: 110
    (27845,384,300,3), -- Automaton - HASTE_GEAR: 300

-- Totemic Gloves
    (27951,384,300,0), -- Pet: HASTE_GEAR: 3%

-- Convokers Bracers
    (27957,27,5,1), -- Avatar - ENMITY: 5

-- Foire Dastanas
    (27960,384,300,3), -- Automaton - HASTE_GEAR: 300

-- Totemic Gloves
    (27972,384,300,0), -- Pet: HASTE_GEAR: 3%

-- Convokers Bracers +1
    (27978,27,5,1), -- Avatar - ENMITY: 5

-- Foire Dastanas +1
    (27981,384,400,3), -- Automaton - HASTE_GEAR: 400

-- Geomancy Mitaines +1
    (27985,160,-1100,8), -- Luopan - DMG: -1100

-- Regimen Mittens
    (28025,25,20,0),   -- All Pets - ACC: 20
    (28025,26,20,0),   -- All Pets - RACC: 20
    (28025,30,20,0),   -- All Pets - MACC: 20
    (28025,384,600,0), -- All Pets - HASTE_GEAR: 600

-- Geomancy Mitaines
    (28066,160,-1000,8), -- Luopan - DMG: -1000

-- Totemic Trousers
    (28098,23,20,0), -- Pet: ATT: 20

-- Vishap Brais
    (28103,3,20,2), -- Wyvern - HPP: 20

-- Convokers Spats
    (28104,25,20,1), -- Avatar - ACC: 20
    (28104,27,4,1),  -- Avatar - ENMITY: 4

-- Foire Churidars
    (28107,5,40,3),    -- Automaton - MP: 40
    (28107,374,10,3),  -- Automaton - CURE_POTENCY: 10
    (28107,384,300,3), -- Automaton - HASTE_GEAR: 300

-- Totemic Trousers +1
    (28119,23,20,0), -- All Pets - ATT: 20

-- Vishap Brais +1
    (28124,3,23,2), -- Wyvern - HPP: 23

-- Convokers Spats +1
    (28125,25,20,1), -- Avatar - ACC: 20
    (28125,27,4,1),  -- Avatar - ENMITY: 4

-- Foire Churidars +1
    (28128,5,50,3),    -- Automaton - MP: 50
    (28128,374,12,3),  -- Automaton - CURE_POTENCY: 12
    (28128,384,300,3), -- Automaton - HASTE_GEAR: 300

-- Wisent Kecks
    (28141,23,10,0),   -- All Pets - ATT: 10
    (28141,24,10,0),   -- All Pets - RATT: 10
    (28141,25,20,0),   -- All Pets - ACC: 20
    (28141,26,20,0),   -- All Pets - RACC: 20
    (28141,68,20,0),   -- All Pets - EVA: 20
    (28141,384,300,0), -- All Pets - HASTE_GEAR: 300

-- Marduks Crackows +1
    (28211,23,15,1),   -- Avatar - ATT: 15
    (28211,384,200,1), -- Avatar - HASTE_GEAR: 200

-- Kers Sollerets
    (28213,23,13,2), -- Wyvern - ATT: 13

-- Sigyns Jambeaux
    (28214,68,5,0), -- All Pets - EVA: 5

-- Idis Ledelsens
    (28219,68,2,0), -- All Pets - EVA: 2

-- Totemic Gaiters
    (28231,23,10,0), -- All Pets - ATT: 10
    (28231,25,10,0), -- All Pets - ACC: 10

-- Convokers Pigaches
    (28237,27,5,1),  -- Avatar - ENMITY: 5
    (28237,68,20,1), -- Avatar - EVA: 20
    (28237,126,5,1), -- Avatar - BP_DAMAGE: 5

-- Foire Babouches
    (28240,384,300,3), -- Automaton - HASTE_GEAR: 300

-- Totemic Gaiters +1
    (28252,23,10,0), -- All Pets - ATT: 10
    (28252,25,10,0), -- All Pets - ACC: 10

-- Convokers Pigaches +1
    (28258,27,5,1),  -- Avatar - ENMITY: 5
    (28258,68,20,1), -- Avatar - EVA: 20
    (28258,126,6,1), -- Avatar - BP_DAMAGE: 6

-- Foire Babouches +1
    (28261,384,300,3), -- Automaton - HASTE_GEAR: 300

-- Eidolon Pendant +1
    (28356,28,5,1), -- Avatar - MATT: 5

-- Incarnation Sash (Checked)
    (28418,25,15,0), -- All Pets - ACC: 15
    (28418,26,15,0), -- All Pets - RACC: 15
    (28418,30,15,0), -- All Pets - MACC: 15
    (28418,288,4,0), -- All Pets - DOUBLE_ATTACK: 4

-- Ukko Sash
    (28432,25,15,3),   -- Automaton - ACC: 15
    (28432,26,15,3),   -- Automaton - RACC: 15
    (28432,30,15,3),   -- Automaton - MACC: 15
    (28432,170,5,3),   -- Automaton - FASTCAST: 5
    (28432,384,500,3), -- Automaton - HASTE_GEAR: 500

-- Handlers Earring (Checked)
    (28490,161,-300,0), -- All Pets - DMGPHYS: -300
    (28490,164,-300,0), -- All Pets - DMGRANGE: -300

-- Handlers Earring +1 (Checked)
    (28491,161,-400,0), -- All Pets - DMGPHYS: -400
    (28491,164,-400,0), -- All Pets - DMGRANGE: -400

-- Rimeice Earring
    (28495,27,5,0),    -- All Pets - ENMITY: 5
    (28495,160,100,0), -- All Pets - DMG: 100
    (28495,384,300,0), -- All Pets - HASTE_GEAR: 300

-- Karagoz Mantle +1
    (28588,23,15,3), -- Automaton - ATT: 15
    (28588,25,15,3), -- Automaton - ACC: 15
    (28588,68,10,3), -- Automaton - EVA: 10

-- Samanisi Cape
    (28605,25,7,1), -- Avatar - ACC: 7
    (28605,30,7,1), -- Avatar - MACC: 7

-- Refraction Cape
    (28643,12,8,3), -- Automaton - INT: 8
    (28643,13,8,3), -- Automaton - MND: 8
    (28643,30,3,3) -- Automaton - MACC: 3
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `value` = IF(`value` <> VALUES(`value`), VALUES(`value`), `value`)
;
