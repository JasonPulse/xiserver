import mariadb


def migration_name():
    return "Set Lilith mob_groups HP for WotG 51 Maiden of the Dusk"


def check_preconditions(cur):
    return


# WotG 51 Maiden of the Dusk needs Lady Lilith + Lilith Ascendant to have
# non-zero HP. The fork had both `mob_groups` rows (56/57 in zone 182) with
# HP=0 — so the mobs would spawn with default/zero HP and either crash or
# die in one hit. mob_pools 2316 (Lady Lilith) + 2416 (Lilith Ascendant)
# already exist with proper stats; only the per-group HP override was
# missing.
#
# Sets:
#   group 56 Lady_Lilith (phase 1) → HP 9800
#   group 57 Lilith_Ascendant (phase 2) → HP 17000
# (Per bg-wiki Lilith page — Lady Lilith ~9.8k, Ascendant ~17k.)
#
# Idempotent: UPDATE only changes the row if HP is still 0.
def needs_to_run(cur):
    cur.execute(
        "SELECT COUNT(*) FROM mob_groups "
        "WHERE zoneid = 182 "
        "AND groupid IN (56, 57) "
        "AND HP = 0;"
    )
    row = cur.fetchone()
    return row is not None and row[0] > 0


def migrate(cur, db):
    try:
        cur.execute(
            "UPDATE mob_groups SET HP = 9800 "
            "WHERE groupid = 56 AND zoneid = 182 AND name = 'Lady_Lilith' AND HP = 0;"
        )
        cur.execute(
            "UPDATE mob_groups SET HP = 17000 "
            "WHERE groupid = 57 AND zoneid = 182 AND name = 'Lilith_Ascendant' AND HP = 0;"
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
