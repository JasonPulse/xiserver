-----------------------------------
-- Area: Mog_Garden
-----------------------------------
zones = zones or {}

zones[xi.zone.MOG_GARDEN] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        NOT_HAVE_ENOUGH_GIL           = 6396, -- You do not have enough gil.
        ITEM_OBTAINEDX                = 6400, -- You obtain <number> <item>!
        NOTHING_OUT_OF_ORDINARY       = 6405, -- There is nothing out of the ordinary here.
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
        FISHING_MESSAGE_OFFSET        = 7227, -- You can't fish here.
        FURROW_MIN_RANK               = 7331, -- This furrow must be at least rank <number> before it can be of any use.
        FURROW_EMPTY                  = 7332, -- This furrow is rank <number>, but is devoid of both seeds and fertilizer.
        GROVE_MIN_RANK                = 7363, -- This grove must be at least rank <number> before it can be of any use.
        GROVE_RANK_AND_USES           = 7364, -- This grove of trees is rank <number>. You can harvest from it <number> more time[/s].
        GROVE_NOTHING_TO_DO           = 7367, -- There seems to be no reason to work on this grove, for the trees are well pruned and devoid of weeds.
        VEIN_MIN_RANK                 = 7378, -- This vein must be at least rank <number> before it can eb of any use.
        VEIN_RANK_AND_USES            = 7379, -- This mineral vein is rank <number>. It seems possible to obtain something from it <number> more time[/s].
        VEIN_BEST_TO_STOP             = 7382, -- It would probably be best to stop for now.
        POND_RANK                     = 7392, -- The net that sits in the middle of this pond is rank <number>.
        NET_TOO_LIGHT                 = 7394, -- It seems too light to have anything caught in it. Perhaps it is best to wait a while longer.
        COAST_RANK                    = 7404, -- This net is rank <number>.
        STARS_ON_KEYITEM              = 7515, -- <number> star[/s] on your <item> [has/have] come aglow. A total of <number> star[/s] twinkle[s/] softly inside your <item>.
        ACTION_DONE_AGAIN             = 7538, -- You have successfully performed that action <number> time[/s], and may do so again <number> more time[/s].
        ACTION_DONE_NO_MORE           = 7539, -- You have successfully performed that action <number> time[/s], and may no longer do so again.
        GARDEN_TALLY_GATHERS          = 7545, -- You have visited a total of <number> day[/s]. You have gathered from your furrow <number> time[/s]. ... grove ... veins ...
        GARDEN_TALLY_FISHINGS         = 7546, -- You have fished from the pond <number> time[/s]. You have fished from the coast <number> time[/s].
        MOGLOCKER_MESSAGE_OFFSET      = 7531, -- Your particular paid period of Mog Locker patronage has been extended until the following time, kupo! Earth Time: #/#/# at #:#:#.
        RETRIEVE_DIALOG_ID            = 8582, -- You retrieve <item> from the porter moogle's care.
    },
    mob =
    {
    },
    npc =
    {
        GREEN_THUMB_MOOGLE = GetFirstID('Green_Thumb_Moogle'),
        MOG_DINGHY         = GetFirstID('Mog_Dinghy'),
        PORTER_MOOGLE      = GetFirstID('Porter_Moogle'),

        -- First entity of each gathering family. Every rank tier of the grove and the
        -- vein is a PAIR of entities, one per gathering action, and the four pairs are
        -- contiguous in npc_list.sql (grove 17924131 to 17924138, vein 17924139 to
        -- 17924146), so tier and action both fall out of the offset from these bases.
        -- See the node registry in scripts/globals/mog_garden.lua.
        ARBOREAL_GROVE     = GetFirstID('Arboreal_Grove'),
        MINERAL_VEIN       = GetFirstID('Mineral_Vein'),
    },
}

return zones[xi.zone.MOG_GARDEN]
