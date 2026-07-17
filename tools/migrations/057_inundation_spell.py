import mariadb


def migration_name():
    return "Enable Inundation spell (id 879) — was commented out with placeholder level"


def check_preconditions(cur):
    return


# spell_list row 879 (Inundation) shipped in the base SQL as a stub commented
# out with `?` for the level column and 0x00...00 for the jobs blob (all zeros
# = no job can learn). Uncommented + populated so the RDM 64 / WHM 65 / PLD 65
# / SCH 65 learn path works. Values match the enfeebling_spell.lua entry that
# was already wired.
#
# jobs blob layout: 22 bytes, byte N holds the learn level for job (N+1).
# Byte order: WAR(0) MNK(1) WHM(2) BLM(3) RDM(4) THF(5) PLD(6) DRK(7) BST(8)
# BRD(9) RNG(10) SAM(11) NIN(12) DRG(13) SMN(14) BLU(15) COR(16) PUP(17)
# DNC(18) SCH(19) GEO(20) RUN(21). Zero = cannot learn.
_JOBS_BLOB = bytes([
    0x00, 0x00,        # WAR, MNK
    0x41,              # WHM = 65
    0x00,              # BLM
    0x40,              # RDM = 64
    0x00,              # THF
    0x41,              # PLD = 65
    0x00, 0x00, 0x00,  # DRK, BST, BRD
    0x00, 0x00, 0x00,  # RNG, SAM, NIN
    0x00, 0x00, 0x00,  # DRG, SMN, BLU
    0x00, 0x00, 0x00,  # COR, PUP, DNC
    0x41,              # SCH = 65
    0x00, 0x00,        # GEO, RUN
])


def needs_to_run(cur):
    cur.execute("SELECT COUNT(*) FROM spell_list WHERE spellid = 879;")
    row = cur.fetchone()
    if row is None or row[0] == 0:
        return True

    cur.execute("SELECT `group` FROM spell_list WHERE spellid = 879;")
    row = cur.fetchone()
    return row is None or row[0] != 6


def migrate(cur, db):
    try:
        cur.execute(
            "REPLACE INTO spell_list "
            "(spellid, name, jobs, `group`, family, element, zonemisc, validTargets, "
            " skill, mpCost, castTime, recastTime, message, magicBurstMessage, "
            " animation, animationTime, AOE, base, multiplier, CE, VE, requirements, "
            " spell_range, radius, content_tag) VALUES "
            "(879, 'inundation', %s, 6, 0, 7, 0, 4, "
            " 35, 24, 2000, 60000, 0, 0, "
            " 288, 1000, 0, 0, 1.00, 1, 176, 0, "
            " 200, 0, NULL);",
            (_JOBS_BLOB,)
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
