-----------------------------------
-- Area: Reisenjima
-----------------------------------
zones = zones or {}

zones[xi.zone.REISENJIMA] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        ITEMS_OBTAINED                = 6400, -- You obtain <number> <item>!
        NOTHING_OUT_OF_ORDINARY       = 6405, -- There is nothing out of the ordinary here.
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
        YOU_HAVE_USED                 = 7617, -- You have used <item>.
    },
    -- Geas Fete notorious monsters (pop entity ids from mob_spawn_points,
    -- Reisenjima range). Resolved by xi.geasFete.popBoss via mobName.
    mob =
    {
        Belphegor              = 17969661,
        Crom_Dubh              = 17969637,
        Kabandha               = 17969664,
        Dazzling_Dolores       = 17969655,
        Golden_Kist            = 17969640,
        Selkit                 = 17969667,
        Sang_Buaya             = 17969670,
        Mauve_Wristed_Gomberry = 17969643, -- SQL mob name 'Mauve-wristed_Gomberry'
        Taelmoth               = 17969658, -- SQL mob name 'Taelmoth_the_Diremaw'
    },
    npc =
    {
    },
}

return zones[xi.zone.REISENJIMA]
