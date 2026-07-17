import mariadb


def migration_name():
    return "Remove Stellar Arrow (AOE WS) from Semih Lafihna trust rotation"


def check_preconditions(cur):
    return


# Stellar Arrow (mob_skill_id 3489) is AOE — Semih pulls extra aggro from
# nearby mobs and dies. Original mob_skill_lists comments were swapped
# (3489 was labeled "Lux Arrow", 3490 as "Stellar Arrow"), verified against
# mob_skills.mob_skill_aoe: 3489 = stellar_arrow (aoe=1), 3490 = lux_arrow
# (aoe=0).


def needs_to_run(cur):
    cur.execute(
        "SELECT COUNT(*) FROM mob_skill_lists "
        "WHERE skill_list_name = 'TRUST_Semih_Lafihna' AND mob_skill_id = 3489;"
    )
    row = cur.fetchone()
    return row is not None and row[0] > 0


def migrate(cur, db):
    try:
        cur.execute(
            "DELETE FROM mob_skill_lists "
            "WHERE skill_list_name = 'TRUST_Semih_Lafihna' AND mob_skill_id = 3489;"
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
