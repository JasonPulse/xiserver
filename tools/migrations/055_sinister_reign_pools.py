import mariadb


def migration_name():
    return "Wire Sinister Reign boss mob_pools + fix mob_groups HP (Rala Waterways [U] zone 259)"


def check_preconditions(cur):
    return


# Rala Waterways [U] (zone 259) has 9 Sinister Reign boss `mob_groups`
# rows. Most had poolId already set (Arciela/Darrcuiln/Ingrid/Morimar)
# but HP=0; the rest had poolId=0 + HP=0:
#   - 4 with pools, missing HP: Arciela, Darrcuiln, Ingrid, Morimar
#   - 4 needing existing pools assigned + HP set: Teodor (pool 5986),
#     Rosulatia (5985), August (5984), Ygnas (5998)
#   - 1 needing brand-new pool: Sajj'aka (pool 7511, added in this
#     migration with Sempurne humanoid template)
#
# HP per wave (per session-standard tiering): Wave 1 60k, Wave 2 70k,
# Wave 3 80k (Sajj'aka) / 90k (August final boss).
#
# Idempotent: pool INSERT uses ON DUPLICATE; group UPDATEs use
# WHERE HP = 0 guard so a re-run on already-fixed data is a no-op.
_GROUPS = [
    # (groupid, poolid, hp)
    (26, 5496, 60000),  # Arciela
    (53, 5499, 60000),  # Darrcuiln
    (54, 5512, 60000),  # Ingrid
    (52, 5998, 60000),  # Ygnas (Arciela partner)
    (46, 5986, 70000),  # Teodor
    (55, 5501, 70000),  # Morimar
    (56, 5985, 70000),  # Rosulatia
    (64, 7511, 80000),  # Sajj'aka
    (65, 5984, 90000),  # August (final boss)
]


def needs_to_run(cur):
    cur.execute("SELECT COUNT(*) FROM mob_pools WHERE poolid = 7511;")
    pool_row = cur.fetchone()
    if pool_row is None or pool_row[0] == 0:
        return True

    cur.execute(
        "SELECT COUNT(*) FROM mob_groups "
        "WHERE zoneid = 259 AND groupid IN (26,46,52,53,54,55,56,64,65) AND HP = 0;"
    )
    group_row = cur.fetchone()
    return group_row is not None and group_row[0] > 0


def migrate(cur, db):
    try:
        cur.execute(
            "INSERT INTO mob_pools "
            "(poolid, name, packet_name, familyid, modelid, mJob, sJob, cmbSkill, "
            " cmbDelay, cmbDmgMult, behavior, aggro, true_detection, links, mobType, "
            " immunity, name_prefix, flag, entityFlags, animationsub, hasSpellScript, "
            " spellList, namevis, roamflag, skill_list_id, resist_id, modelSize, "
            " modelHitboxSize) "
            "VALUES (7511, 'Sajjaka', %s, 475, "
            "0x00003F0900000000000000000000000000000000, "
            "1, 4, 12, 240, 100, 0, 1, 1, 0, 2, 0, 0, 3, 153, 5, 0, 0, 0, 0, 475, 475, 0, 75) "
            "ON DUPLICATE KEY UPDATE poolid = poolid;",
            ("Sajj'aka",)
        )

        for groupid, poolid, hp in _GROUPS:
            cur.execute(
                "UPDATE mob_groups SET poolid = %s, HP = %s "
                "WHERE zoneid = 259 AND groupid = %s AND HP = 0;",
                (poolid, hp, groupid)
            )

        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
