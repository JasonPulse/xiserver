-----------------------------------
-- Area: Escha_ZiTah
-----------------------------------
zones = zones or {}

zones[xi.zone.ESCHA_ZITAH] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        ITEMS_OBTAINED                = 6400, -- You obtain <number> <item>!
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
    },
    -- Geas Fete notorious monsters (pop entity ids from mob_spawn_points).
    -- xi.geasFete.popBoss resolves these by mobName; without them every Escha
    -- NM pop failed with "no entity id for <mob> in zone 288".
    mob =
    {
        Wepwawet      = 17957298,
        Aglaophotis   = 17957304,
        Vyala         = 17957331,
        Lustful_Lydia = 17957301,
        Tangata_Manu  = 17957307,
        Vidala        = 17957310,
        Gestalt       = 17957313,
        Angrboda      = 17957316,
        Cunnast       = 17957319,
        Revetaur      = 17957322,
        Ferrodon      = 17957325,
        Gulltop       = 17957328,
        Blazewing     = 17957334,
        Pazuzu        = 17957346,
        Wrathare      = 17957349,
        Ionos         = 17957352,
        Sensual_Sandy = 17957355,
        Nosoi         = 17957358,
        Brittlis      = 17957361,
        Kamohoalii    = 17957364,
        Umdhlebi      = 17957367,
        Fleetstalker  = 17957370,
        Shockmaw      = 17957373,
        Urmahlullu    = 17957376,
        Alpluachra    = 17957343,
    },
    npc =
    {
    },
}

return zones[xi.zone.ESCHA_ZITAH]
