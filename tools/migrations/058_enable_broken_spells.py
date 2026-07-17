import mariadb


def migration_name():
    return "Enable 33 spells that shipped commented-out with placeholder family/jobs"


def check_preconditions(cur):
    return


# 33 spells in spell_list.sql shipped as `-- INSERT ... ,?,` — the `?` in the
# family column made the row unparseable, so they were commented out and
# nobody could ever learn them. Companion to migration 057 (Inundation).
#
# Groups: 18 BLU (jobs blob already had BLU byte set), 8 Storm II (SCH 65
# added), 4 RDM/SCH enfeeble+dark (Aspir III / Distract III / Frazzle III /
# Addle II), 1 Atomos (SMN 75, blob already had SMN byte), Full Cure
# (WHM 99), Refresh III (RDM/SCH 78, RUN 65).
#
# Framework registrations added in the same change to
# enhancing_spell.lua (Storm II tier-2 entries) and enfeebling_spell.lua
# (Addle II). Scripts stubbed for Storm II / Addle II / Atomos / Full Cure.
#
# Element / skill numeric constants match spell_list.sql SET @-vars:
#   ELEMENT: NONE=0 FIRE=1 ICE=2 WIND=3 EARTH=4 THUNDER=5 WATER=6 LIGHT=7 DARK=8
#   SKILL:   HEALING=33 ENHANCING=34 ENFEEBLING=35 DARK=37 SUMMONING=38 BLUE=43
#
# Idempotent via REPLACE INTO; needs_to_run guards on group value.

_SPELLS = [
    # (spellid, name, jobs_hex, group, family, element, zonemisc, validTargets,
    #  skill, mpCost, castTime, recastTime, message, magicBurstMessage,
    #  animation, animationTime, AOE, base, multiplier, CE, VE, requirements,
    #  spell_range, radius, content_tag)

    # BLU spells (group=3 BLUE, skill=43). Original values from SQL preserved.
    (700, 'natures_meditation',    '00000000000000000000000000000063000000000000', 3, 0, 1, 0, 1, 43,  38,  500, 60000, 230,  0, 907, 2000, 6, 0, 1.00, 0,   0, 0,   0,   0, 'ABYSSEA'),
    (701, 'tempestuous_upheaval',  '00000000000000000000000000000063000000000000', 3, 0, 3, 0, 4, 43, 133,  500,  7000,   2,  0, 908, 4000, 1, 0, 1.00, 0,   0, 0, 100, 100, 'ABYSSEA'),
    (702, 'rending_deluge',        '00000000000000000000000000000063000000000000', 3, 0, 6, 0, 4, 43, 118, 1500, 30000,   2,  0, 909, 4000, 2, 0, 1.00, 0,   0, 0, 100, 100, 'ABYSSEA'),
    (703, 'embalming_earth',       '00000000000000000000000000000063000000000000', 3, 0, 4, 0, 4, 43,  57,  500, 30000,   2,  0, 910, 4000, 1, 0, 1.00, 0,   0, 0, 100, 100, 'ABYSSEA'),
    (704, 'paralyzing_triad',      '00000000000000000000000000000063000000000000', 3, 0, 0, 0, 4, 43,  33,  500, 30000,   2,  0, 911, 4000, 0, 0, 1.00, 0,   0, 0,  50,   0, 'ABYSSEA'),
    (705, 'foul_waters',           '00000000000000000000000000000063000000000000', 3, 0, 6, 0, 4, 43,  76, 4500, 30000,   2,  0, 912, 4000, 1, 0, 1.00, 0,   0, 0,  50,  50, 'ABYSSEA'),
    (706, 'glutinous_dart',        '00000000000000000000000000000063000000000000', 3, 0, 0, 0, 4, 43,  16, 1000, 10000,   2,  0, 913, 4000, 0, 0, 1.00, 0,   0, 0, 200,   0, 'ABYSSEA'),
    (707, 'retinal_glare',         '00000000000000000000000000000063000000000000', 3, 0, 7, 0, 4, 43,  26, 1000, 30000,   2,  0, 914, 4000, 2, 0, 1.00, 0,   0, 0,  50,  50, 'ABYSSEA'),
    (708, 'subduction',            '00000000000000000000000000000063000000000000', 3, 0, 3, 0, 4, 43,  27,  500, 30000,   2, 252, 925, 4000, 1, 0, 1.00, 0,   0, 0, 100, 100, 'ABYSSEA'),
    (709, 'thrashing_assault',     '00000000000000000000000000000063000000000000', 3, 0, 0, 0, 4, 43,  99,  500, 30000,   2,   0, 926, 4000, 0, 0, 1.00, 0,   0, 0,  50,   0, 'ABYSSEA'),
    (710, 'erratic_flutter',       '00000000000000000000000000000063000000000000', 3, 0, 3, 0, 1, 43,  63,  500, 30000, 230,   0, 937, 4000, 6, 0, 1.00, 0,   0, 0,   0,   0, 'ABYSSEA'),
    (711, 'restoral',              '00000000000000000000000000000063000000000000', 3, 0, 7, 0, 3, 43, 127, 2500, 22500,   7,   0, 940, 4000, 0, 0, 1.00, 0,   0, 0,   0,   0, 'ABYSSEA'),
    (712, 'rail_cannon',           '00000000000000000000000000000063000000000000', 3, 0, 7, 0, 4, 43, 200,  500, 22000,   2,   0, 941, 4000, 0, 0, 1.00, 0,   0, 0, 200,   0, 'ABYSSEA'),
    (713, 'diffusion_ray',         '00000000000000000000000000000063000000000000', 3, 0, 7, 0, 4, 43, 238,  500, 22000,   2,   0, 942, 4000, 1, 0, 1.00, 0,   0, 0, 100, 100, 'ABYSSEA'),
    (714, 'sinker_drill',          '00000000000000000000000000000063000000000000', 3, 0, 0, 0, 4, 43,  91,  500, 22000,   2,   0, 943, 4000, 0, 0, 1.00, 0,   0, 0,  50,   0, 'ABYSSEA'),
    (744, 'droning_whirlwind',     '00000000000000000000000000000060000000000000', 3, 0, 3, 0, 4, 43,  76, 3000, 30000,   2,   0, 915, 4000, 1, 0, 1.00, 0,   0, 16, 100, 100, 'SOA'),
    (745, 'carcharian_verve',      '00000000000000000000000000000060000000000000', 3, 0, 6, 0, 3, 43,  52, 3000, 30000,   2,   0, 916, 4000, 0, 0, 1.00, 0,   0, 16,   0,   0, 'SOA'),
    (746, 'blistering_roar',       '00000000000000000000000000000060000000000000', 3, 0, 8, 0, 4, 43,  28, 3000, 30000,   2,   0, 917, 4000, 1, 0, 1.00, 0,   0, 16, 100, 100, 'SOA'),

    # Atomos (SMN 75). jobs blob byte 14 (SMN) = 0x4B.
    (847, 'atomos',                '00000000000000000000000000004B00000000000000', 5, 0, 8, 128, 4, 38, 100, 1000, 60000, 0, 0, 288, 1000, 0, 0, 1.00, 0, 0, 0, 200, 0, 'SOA'),

    # Storm II family — SCH 65 (Addendum: Black). group=6 WHITE, skill=34 ENHANCING.
    # jobs blob byte 19 (SCH) = 0x41.
    (857, 'sandstorm_ii',    '00000000000000000000000000000000000000410000', 6, 0, 4, 0, 3, 34, 30, 2000, 18000, 230, 0, 974, 4000, 4, 0, 1.00, 1, 300, 0, 200, 0, 'SOA'),
    (858, 'rainstorm_ii',    '00000000000000000000000000000000000000410000', 6, 0, 6, 0, 3, 34, 30, 2000, 18000, 230, 0, 774, 4000, 4, 0, 1.00, 1, 300, 0, 200, 0, 'SOA'),
    (859, 'windstorm_ii',    '00000000000000000000000000000000000000410000', 6, 0, 3, 0, 3, 34, 30, 2000, 18000, 230, 0, 973, 4000, 4, 0, 1.00, 1, 300, 0, 200, 0, 'SOA'),
    (860, 'firestorm_ii',    '00000000000000000000000000000000000000410000', 6, 0, 1, 0, 3, 34, 30, 2000, 18000, 230, 0, 971, 4000, 4, 0, 1.00, 1, 300, 0, 200, 0, 'SOA'),
    (861, 'hailstorm_ii',    '00000000000000000000000000000000000000410000', 6, 0, 2, 0, 3, 34, 30, 2000, 18000, 230, 0, 972, 4000, 4, 0, 1.00, 1, 300, 0, 200, 0, 'SOA'),
    (862, 'thunderstorm_ii', '00000000000000000000000000000000000000410000', 6, 0, 5, 0, 3, 34, 30, 2000, 18000, 230, 0, 975, 4000, 4, 0, 1.00, 1, 300, 0, 200, 0, 'SOA'),
    (863, 'voidstorm_ii',    '00000000000000000000000000000000000000410000', 6, 0, 8, 0, 3, 34, 30, 2000, 18000, 230, 0, 976, 4000, 4, 0, 1.00, 1, 300, 0, 200, 0, 'SOA'),
    (864, 'aurorastorm_ii',  '00000000000000000000000000000000000000410000', 6, 0, 7, 0, 3, 34, 30, 2000, 18000, 230, 0, 977, 4000, 4, 0, 1.00, 1, 300, 0, 200, 0, 'SOA'),

    # Aspir III (BLM 78, DRK 82, SCH 82). group=2 BLACK, family=68, skill=37 DARK.
    # jobs blob: byte 3 (BLM) = 0x4E, byte 7 (DRK) = 0x52, byte 19 (SCH) = 0x52.
    (881, 'aspir_iii',    '0000004E000000520000000000000000000000520000', 2,  68, 8, 0, 4, 37, 25, 3000, 90000, 228, 275, 288, 2000, 0, 0, 1.00, 320, 0, 0, 200, 0, 'SOA'),

    # Distract / Frazzle III / Addle II — RDM 89, SCH 89. group=2, skill=35 ENFEEBLING.
    # jobs blob: byte 4 (RDM) = 0x59, byte 19 (SCH) = 0x59.
    (882, 'distract_iii', '00000000590000000000000000000000000000590000', 2, 154, 2, 0, 4, 35, 68, 3000, 10000, 0, 0, 934, 4000, 0, 0, 1.00, 1, 320, 0, 200, 0, 'SOA'),
    (883, 'frazzle_iii',  '00000000590000000000000000000000000000590000', 2, 155, 8, 0, 4, 35, 74, 3000, 10000, 0, 0, 936, 4000, 0, 0, 1.00, 1, 320, 0, 200, 0, 'SOA'),
    (884, 'addle_ii',     '00000000590000000000000000000000000000590000', 2, 156, 1, 0, 4, 35, 45, 3000, 10000, 0, 0, 935, 4000, 0, 0, 1.00, 1, 320, 0, 200, 0, 'SOA'),

    # Full Cure (WHM 99). skill=33 HEALING. Restores full HP; script strips key debuffs.
    # jobs blob byte 2 (WHM) = 0x63.
    (893, 'full_cure',    '00006300000000000000000000000000000000000000', 6,   1, 7, 0, 3, 33, 200, 10000, 90000, 7, 7, 5, 2000, 0, 0, 1.00, 0, 0, 0, 200, 0, 'SOA'),

    # Refresh III (RDM 78, SCH 78, RUN 65). group=6 WHITE, family=29, skill=34.
    # jobs blob: byte 4 (RDM) = 0x4E, byte 19 (SCH) = 0x4E, byte 21 (RUN) = 0x41.
    (894, 'refresh_iii',  '000000004E00000000000000000000000000004E0041', 6,  29, 7, 0, 3, 34, 90, 5000, 32000, 0, 0, 118, 2000, 0, 0, 1.00, 1, 165, 0, 200, 0, 'SOA'),
]


def needs_to_run(cur):
    ids = ",".join(str(s[0]) for s in _SPELLS)
    cur.execute(f"SELECT spellid, `group` FROM spell_list WHERE spellid IN ({ids});")
    got = {row[0]: row[1] for row in cur.fetchall()}
    for s in _SPELLS:
        sid, group = s[0], s[3]
        if got.get(sid) != group:
            return True
    return False


def migrate(cur, db):
    sql = (
        "REPLACE INTO spell_list "
        "(spellid, name, jobs, `group`, family, element, zonemisc, validTargets, "
        " skill, mpCost, castTime, recastTime, message, magicBurstMessage, "
        " animation, animationTime, AOE, base, multiplier, CE, VE, requirements, "
        " spell_range, radius, content_tag) VALUES "
        "(%s, %s, UNHEX(%s), %s, %s, %s, %s, %s, "
        " %s, %s, %s, %s, %s, %s, "
        " %s, %s, %s, %s, %s, %s, %s, %s, "
        " %s, %s, %s);"
    )
    try:
        for spell in _SPELLS:
            cur.execute(sql, spell)
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
