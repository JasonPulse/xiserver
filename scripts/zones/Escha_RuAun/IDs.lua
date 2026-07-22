-----------------------------------
-- Area: Escha_RuAun
-----------------------------------
zones = zones or {}

zones[xi.zone.ESCHA_RUAUN] =
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
    },
    -- Geas Fete notorious monsters (pop entity ids from mob_spawn_points,
    -- zone-289 range). Resolved by xi.geasFete.popBoss via mobName; the empty
    -- table made every Escha-Ru'Aun NM pop fail with "no entity id".
    mob =
    {
        Byakko         = 17961559,
        Genbu          = 17961562,
        Seiryu         = 17961565,
        Suzaku         = 17961568,
        Kirin          = 17961571,
        Ark_Angel_HM   = 17961592,
        Ark_Angel_TT   = 17961595,
        Ark_Angel_MR   = 17961598,
        Ark_Angel_EV   = 17961607,
        Ark_Angel_GK   = 17961610,
        Bia            = 17961379,
        Ruea           = 17961382,
        Ma             = 17961385,
        Khon           = 17961388,
        Khun           = 17961394,
        Met            = 17961391,
        Wasserspeier   = 17961397,
        Emputa         = 17961400,
        Peirithoos     = 17961403,
        Asida          = 17961406,
        Tenodera       = 17961409,
        Sava_Savanovic = 17961412,
        Palila         = 17961415,
        Hanbi          = 17961436,
        Yilan          = 17961451,
        Amymone        = 17961460,
        Naphula        = 17961472,
        Kammavaca      = 17961481,
        Pakecet        = 17961496,
        Duke_Vepar     = 17961529,
        Viava          = 17961535, -- SQL mob name 'Virava'
    },
    npc =
    {
    },
}

return zones[xi.zone.ESCHA_RUAUN]
