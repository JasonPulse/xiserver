import mariadb


def migration_name():
    return "[disabled] char_storage satchel default to 0 (superseded by 050)"


def check_preconditions(cur):
    return


# This migration was originally from upstream LSB (commit 8eae83e2d5 —
# "Tie initial satchel to OTP") and lowers the satchel column's DEFAULT
# from 30 back to 0 so that the OTP-grant flow gates capacity.
#
# We keep locker/satchel/sack at DEFAULT 30 for new characters on this
# private server (see sql/char_storage.sql header comment). Leaving the
# upstream migration enabled would silently revert that intent on every
# `dbtool update`, breaking new-character provisioning.
#
# Migration 050 supersedes this one and backfills existing characters.
def needs_to_run(cur):
    return False


def migrate(cur, db):
    pass
