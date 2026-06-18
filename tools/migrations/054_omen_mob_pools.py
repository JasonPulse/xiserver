import mariadb


def migration_name():
    return "Add Omen Caturae + Glassy mob_pools + fix mob_groups poolId / HP (Reisenjima Henge zone 292)"


def check_preconditions(cur):
    return


# Reisenjima Henge (zone 292) had 9 Omen boss `mob_groups` rows with
# poolId=0 + HP=0: 6 Caturae (Fu/Kyou/Kei/Gin/Kin/Ou) + 3 Glassys
# (Thinker/Craver/Gorger). Bosses couldn't spawn with proper stats.
#
# This migration adds 9 new `mob_pools` rows (7502-7510) using the
# Sempurne (4914) template for Caturae humanoid forms and family 168 for
# the Glassy mid-bosses. Then updates the 9 `mob_groups` rows to
# reference the new pools and set HP per Omen tier (Caturae 50k except
# Ou final boss 80k; Glassys 30k).
#
# Idempotent: pools use INSERT ... ON DUPLICATE; mob_groups updates use
# WHERE poolid=0 guards.
_POOLS = [
    (7502, 'Fu',             475),
    (7503, 'Kyou',           475),
    (7504, 'Kei',            475),
    (7505, 'Gin',            475),
    (7506, 'Kin',            475),
    (7507, 'Ou',             475),
    (7508, 'Glassy_Thinker', 168),
    (7509, 'Glassy_Craver',  168),
    (7510, 'Glassy_Gorger',  168),
]

_GROUPS = [
    # (groupid, poolid, hp)
    (9,  7508, 30000),
    (10, 7509, 30000),
    (11, 7510, 30000),
    (52, 7506, 50000),
    (53, 7505, 50000),
    (54, 7504, 50000),
    (55, 7503, 50000),
    (56, 7502, 50000),
    (73, 7507, 80000),
]


def needs_to_run(cur):
    cur.execute("SELECT COUNT(*) FROM mob_pools WHERE poolid BETWEEN 7502 AND 7510;")
    pool_row = cur.fetchone()
    if pool_row is None or pool_row[0] < len(_POOLS):
        return True

    cur.execute(
        "SELECT COUNT(*) FROM mob_groups "
        "WHERE zoneid = 292 AND groupid IN (9,10,11,52,53,54,55,56,73) AND poolid = 0;"
    )
    group_row = cur.fetchone()
    return group_row is not None and group_row[0] > 0


def migrate(cur, db):
    try:
        for poolid, name, family in _POOLS:
            # Caturae (family 475) get the Sempurne humanoid template; Glassys
            # (family 168) get a slightly smaller hitbox.
            hitbox = 75 if family == 475 else 50
            cur.execute(
                "INSERT INTO mob_pools "
                "(poolid, name, packet_name, familyid, modelid, mJob, sJob, cmbSkill, "
                " cmbDelay, cmbDmgMult, behavior, aggro, true_detection, links, mobType, "
                " immunity, name_prefix, flag, entityFlags, animationsub, hasSpellScript, "
                " spellList, namevis, roamflag, skill_list_id, resist_id, modelSize, "
                " modelHitboxSize) "
                "VALUES (%s, %s, %s, %s, "
                "0x00003F0900000000000000000000000000000000, "
                "1, 4, 12, 240, 100, 0, 1, 1, 0, 2, 0, 0, 3, 153, 5, 0, 0, 0, 0, %s, %s, 0, %s) "
                "ON DUPLICATE KEY UPDATE poolid = poolid;",
                (poolid, name, name, family, family, family, hitbox)
            )

        for groupid, poolid, hp in _GROUPS:
            cur.execute(
                "UPDATE mob_groups SET poolid = %s, HP = %s "
                "WHERE zoneid = 292 AND groupid = %s AND poolid = 0;",
                (poolid, hp, groupid)
            )

        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
