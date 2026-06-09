import mariadb


def migration_name():
    return "Set char_storage locker/satchel/sack DEFAULT 30 and backfill existing chars"


def check_preconditions(cur):
    return


# This server hands out base locker/satchel/sack capacity (30 each) from
# character creation rather than gating on the retail PlayOnline / OTP
# flow. The schema in sql/char_storage.sql defines DEFAULT '30' for those
# three columns, but a previous run of migration 049 (now disabled) may
# have lowered the live DEFAULT to 0, and any characters that were created
# while the DEFAULT was 0 will still have 0 capacity stored.
#
# This migration:
#   1. Re-enforces DEFAULT '30' for locker / satchel / sack
#   2. Backfills any existing row where a value is below 30
def needs_to_run(cur):
    cur.execute(
        "SELECT 1 FROM information_schema.columns "
        "WHERE table_schema = DATABASE() "
        "AND table_name = 'char_storage' "
        "AND column_name IN ('locker', 'satchel', 'sack') "
        "AND COLUMN_DEFAULT <> '30' "
        "LIMIT 1;"
    )
    if cur.fetchone():
        return True

    cur.execute(
        "SELECT 1 FROM char_storage "
        "WHERE locker < 30 OR satchel < 30 OR sack < 30 LIMIT 1;"
    )
    if cur.fetchone():
        return True

    return False


def migrate(cur, db):
    try:
        cur.execute(
            "ALTER TABLE char_storage "
            "MODIFY locker  tinyint(2) unsigned NOT NULL DEFAULT '30', "
            "MODIFY satchel tinyint(2) unsigned NOT NULL DEFAULT '30', "
            "MODIFY sack    tinyint(2) unsigned NOT NULL DEFAULT '30';"
        )
        cur.execute(
            "UPDATE char_storage SET "
            "locker  = GREATEST(locker, 30), "
            "satchel = GREATEST(satchel, 30), "
            "sack    = GREATEST(sack, 30);"
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
