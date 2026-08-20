-----------------------------------
-- Area: RaKaznar_Turris
-----------------------------------
zones = zones or {}

zones[xi.zone.RAKAZNAR_TURRIS] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
        PARTY_MEMBERS_HAVE_FALLEN     = 8042, -- All party members have fallen in battle. Now leaving the battlefield.
        THE_PARTY_WILL_BE_REMOVED     = 8049, -- If all party members' HP are still zero after # minute[/s], the party will be removed from the battlefield.
    },
    mob =
    {
        -- SoA 5-4 Reckoning: Hades first form + Arciela, five instances
        -- (17911809-17911818). mob_groups 1 (pool 5495 Hadesv1) and 2 (pool 5496).
        HADES_FIRST_FORM  = 17911809,
        ARCIELA_RECKONING = 17911810,

        -- SoA 5-4-1 Abomination: Hades second form + Arciela + Teodor, five
        -- instances (17911819-17911833). The second-form Hades spawns were split
        -- onto mob_groups 9 (pool 5497 hadesV2); Teodor is group 3 (pool 5498).
        HADES_SECOND_FORM   = 17911819,
        ARCIELA_ABOMINATION = 17911820,
        TEODOR_ABOMINATION  = 17911821,
    },
    npc =
    {
    },
}

return zones[xi.zone.RAKAZNAR_TURRIS]
