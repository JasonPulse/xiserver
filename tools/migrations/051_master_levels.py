import mariadb


def migration_name():
    return "Add master_level + exemplar_points columns to char_stats (Master Levels system)"


def check_preconditions(cur):
    return


# Adds the two columns Master Levels needs onto existing databases.
#
# `master_level`    tinyint(3) unsigned NOT NULL DEFAULT 0
# `exemplar_points` int(10)    unsigned NOT NULL DEFAULT 0
#
# Existing characters get master_level=0, exemplar_points=0 — i.e. they have
# not yet started earning toward ML. The Lua/C++ side reads/writes these
# values; this migration is purely additive.
def needs_to_run(cur):
    cur.execute(
        "SELECT COUNT(*) FROM information_schema.columns "
        "WHERE table_schema = DATABASE() "
        "AND table_name = 'char_stats' "
        "AND column_name IN ('master_level', 'exemplar_points');"
    )
    row = cur.fetchone()
    return row is None or row[0] < 2


def migrate(cur, db):
    try:
        cur.execute(
            "ALTER TABLE char_stats "
            "ADD COLUMN IF NOT EXISTS `master_level` tinyint(3) unsigned NOT NULL DEFAULT '0' AFTER `pet_mp`, "
            "ADD COLUMN IF NOT EXISTS `exemplar_points` int(10) unsigned NOT NULL DEFAULT '0' AFTER `master_level`;"
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
