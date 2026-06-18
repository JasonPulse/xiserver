import mariadb


def migration_name():
    return "Author Sinister Reign + Lilith drop tables (dropids 3412-3420)"


def check_preconditions(cur):
    return


# Closes the boss-fight reward loop for content shipped earlier this
# session. Sinister Reign + Lilith mob_groups were authored but dropid
# stayed at 0 — bosses spawned with proper stats but dropped nothing.
#
# 9 new dropIds (3412-3420) cover:
#   3412 Lilith Ascendant (Daybreak / Malignance gear)
#   3413 August           (Cipher: August + Founder's gear)
#   3414 Rosulatia        (Cipher: Rosulatia + Nobility/Serenity)
#   3415 Ingrid           (Cipher: Ingrid II + Dampening Tam/Malevolence)
#   3416 Sajj'aka         (Brilliance/Divinity + Jumalik gear)
#   3417 Morimar          (Brutality/Ferocity + Lilitu Headpiece)
#   3418 Teodor           (Rubicundity + Samnuha Coat/Tights)
#   3419 Arciela / Ygnas  (Enticer's Pants/Ochu/Witching Robe/Taming Sari)
#   3420 Darrcuiln        (Amm Greaves/Fleshcarvers)
#
# Idempotent: droplist INSERTs use WHERE NOT EXISTS guard; mob_groups
# updates only fire when dropid is still 0.
_DROPS = [
    # (dropid, dropType, groupId, groupRate, itemId, itemRate)
    # 3412 Lilith Ascendant
    (3412, 0, 0, 1000, 22040, 1),    # Daybreak URARE
    (3412, 0, 0, 1000, 21635, 10),   # Malignance Sword VRARE
    (3412, 0, 0, 1000, 22087, 10),   # Malignance Pole VRARE
    (3412, 0, 0, 1000, 23732, 50),   # Malignance Chapeau RARE
    (3412, 0, 0, 1000, 23733, 50),   # Malignance Tabard RARE
    (3412, 0, 0, 1000, 23734, 50),   # Malignance Gloves RARE
    # 3413 August
    (3413, 0, 0, 1000, 10175, 1000), # Cipher August ALWAYS
    (3413, 0, 0, 1000, 27764, 150),  # Founders Corona COMMON
    (3413, 0, 0, 1000, 27910, 150),  # Founders Breastplate COMMON
    (3413, 0, 0, 1000, 28049, 150),  # Founders Gauntlets COMMON
    (3413, 0, 0, 1000, 28191, 150),  # Founders Hose COMMON
    (3413, 0, 0, 1000, 28330, 150),  # Founders Greaves COMMON
    # 3414 Rosulatia
    (3414, 0, 0, 1000, 10176, 1000), # Cipher Rosulatia ALWAYS
    (3414, 0, 0, 1000, 21214, 50),   # Nobility RARE
    (3414, 0, 0, 1000, 21148, 50),   # Serenity RARE
    # 3415 Ingrid
    (3415, 0, 0, 1000, 10174, 1000), # Cipher Ingrid II ALWAYS
    (3415, 0, 0, 1000, 25630, 150),  # Dampening Tam COMMON
    (3415, 0, 0, 1000, 20595, 50),   # Malevolence RARE
    # 3416 Sajj'aka
    (3416, 0, 0, 1000, 20705, 50),   # Brilliance RARE
    (3416, 0, 0, 1000, 21088, 50),   # Divinity RARE
    (3416, 0, 0, 1000, 25603, 150),  # Jumalik Helm COMMON
    (3416, 0, 0, 1000, 26972, 150),  # Jumalik Mail COMMON
    # 3417 Morimar
    (3417, 0, 0, 1000, 20891, 50),   # Brutality RARE
    (3417, 0, 0, 1000, 20844, 50),   # Ferocity RARE
    (3417, 0, 0, 1000, 25631, 150),  # Lilitu Headpiece COMMON
    # 3418 Teodor
    (3418, 0, 0, 1000, 21089, 50),   # Rubicundity RARE
    (3418, 0, 0, 1000, 26973, 150),  # Samnuha Coat COMMON
    (3418, 0, 0, 1000, 27295, 150),  # Samnuha Tights COMMON
    # 3419 Arciela / Ygnas
    (3419, 0, 0, 1000, 27323, 150),  # Enticer's Pants COMMON
    (3419, 0, 0, 1000, 20978, 50),   # Ochu RARE
    (3419, 0, 0, 1000, 25705, 50),   # Witching Robe RARE
    (3419, 0, 0, 1000, 20596, 50),   # Taming Sari RARE
    # 3420 Darrcuiln
    (3420, 0, 0, 1000, 27491, 150),  # Amm Greaves COMMON
    (3420, 0, 0, 1000, 20517, 50),   # Fleshcarvers RARE
]

# (groupid, zoneid, dropid)
_GROUP_DROPIDS = [
    (57, 182, 3412),  # Lilith Ascendant
    (65, 259, 3413),  # August
    (56, 259, 3414),  # Rosulatia
    (54, 259, 3415),  # Ingrid
    (64, 259, 3416),  # Sajj'aka
    (55, 259, 3417),  # Morimar
    (46, 259, 3418),  # Teodor
    (26, 259, 3419),  # Arciela
    (52, 259, 3419),  # Ygnas (shares with Arciela)
    (53, 259, 3420),  # Darrcuiln
]


def needs_to_run(cur):
    cur.execute("SELECT COUNT(*) FROM mob_droplist WHERE dropId BETWEEN 3412 AND 3420;")
    drop_row = cur.fetchone()
    if drop_row is None or drop_row[0] < len(_DROPS):
        return True

    placeholders = ','.join(['(%s,%s)'] * len(_GROUP_DROPIDS))
    pairs = []
    for groupid, zoneid, _ in _GROUP_DROPIDS:
        pairs.append(groupid)
        pairs.append(zoneid)
    cur.execute(
        "SELECT COUNT(*) FROM mob_groups "
        f"WHERE (groupid, zoneid) IN ({placeholders}) AND dropid = 0;",
        tuple(pairs)
    )
    group_row = cur.fetchone()
    return group_row is not None and group_row[0] > 0


def migrate(cur, db):
    try:
        for drop in _DROPS:
            cur.execute(
                "INSERT INTO mob_droplist (dropId, dropType, groupId, groupRate, itemId, itemRate) "
                "SELECT %s, %s, %s, %s, %s, %s FROM DUAL "
                "WHERE NOT EXISTS ("
                "  SELECT 1 FROM mob_droplist "
                "  WHERE dropId = %s AND itemId = %s AND itemRate = %s"
                ");",
                (drop[0], drop[1], drop[2], drop[3], drop[4], drop[5],
                 drop[0], drop[4], drop[5])
            )

        for groupid, zoneid, dropid in _GROUP_DROPIDS:
            cur.execute(
                "UPDATE mob_groups SET dropid = %s "
                "WHERE groupid = %s AND zoneid = %s AND dropid = 0;",
                (dropid, groupid, zoneid)
            )

        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
