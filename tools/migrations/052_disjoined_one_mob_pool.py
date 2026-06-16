import mariadb


def migration_name():
    return "Add Disjoined_One mob_pool 7501 + fix mob_groups row to reference it (ROV 2-39)"


def check_preconditions(cur):
    return


# ROV 2-39 Both Paths Taken needs Disjoined One to spawn with proper stats
# before the mission's onMobDeath handler can finish the fight. The fork
# had `mob_groups` row (5, 0, 36, 'Disjoined_One', ...) with poolId=0 and
# HP=0, meaning the entity could spawn but had no stat backing.
#
# This migration:
#   1. Inserts a new `mob_pools` row 7501 modelled on Sempurne (pool 4914)
#      — same family (475, humanoid ROV boss), same model/animation set.
#   2. Updates the existing `mob_groups` row for Disjoined_One in zone 36
#      to reference pool 7501 and set HP=20000 (matches Metus / Sempurne).
#
# Idempotent: both writes use INSERT ... ON DUPLICATE / UPDATE WHERE so a
# re-run is safe.
def needs_to_run(cur):
    cur.execute("SELECT COUNT(*) FROM mob_pools WHERE poolid = 7501;")
    pool_row = cur.fetchone()
    if pool_row is None or pool_row[0] == 0:
        return True

    cur.execute(
        "SELECT COUNT(*) FROM mob_groups "
        "WHERE groupid = 5 AND zoneid = 36 AND poolid = 7501 AND HP = 20000;"
    )
    group_row = cur.fetchone()
    return group_row is None or group_row[0] == 0


def migrate(cur, db):
    try:
        cur.execute(
            "INSERT INTO mob_pools "
            "(poolid, name, packet_name, familyid, modelid, mJob, sJob, cmbSkill, "
            " cmbDelay, cmbDmgMult, behavior, aggro, true_detection, links, mobType, "
            " immunity, name_prefix, flag, entityFlags, animationsub, hasSpellScript, "
            " spellList, namevis, roamflag, skill_list_id, resist_id, modelSize, "
            " modelHitboxSize) "
            "VALUES (7501, 'Disjoined_One', 'Disjoined_One', 475, "
            "0x00003F0900000000000000000000000000000000, "
            "1, 4, 12, 240, 100, 0, 1, 1, 0, 2, 0, 0, 3, 153, 5, 0, 0, 0, 0, 475, 475, 0, 75) "
            "ON DUPLICATE KEY UPDATE poolid = poolid;"
        )

        cur.execute(
            "UPDATE mob_groups "
            "SET poolid = 7501, HP = 20000 "
            "WHERE groupid = 5 AND zoneid = 36 AND name = 'Disjoined_One';"
        )

        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
