-----------------------------------
-- Area: Mog Garden (280)
-- Default actions
-----------------------------------
-- The five Monster Rearing pens (17924233 through 17924237) have a single byte
-- 0x01 in npc_list's `name` column, so luautils::OnEntityLoad skips them: it
-- refuses to build a script path out of a non-printable name. There is no
-- npcs/*.lua that can ever match them.
--
-- The interaction framework keys on npc:getName() regardless, and OnTrigger
-- calls into it whether or not a file was cached, so the pens are reachable
-- under that one-byte key. xi.monsterRearing tells the five apart by entity id.
-- The zone's twelve PlantFurn placeholders share the same name, which is why
-- the handler returns early for any id that is not a pen.
-----------------------------------
require('scripts/globals/monster_rearing')
-----------------------------------

local rearingPen =
{
    onTrigger = function(player, npc)
        xi.monsterRearing.penOnTrigger(player, npc)
    end,

    onTrade = function(player, npc, trade)
        xi.monsterRearing.penOnTrade(player, npc, trade)
    end,
}

return
{
    ['\1'] = rearingPen,

    -- The pen care events are 1076 through 1080. They are keyed here rather
    -- than on the entity because onEventFinish is a zone-wide handler.
    onEventUpdate =
    {
        [1076] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventUpdate(player, csid, option)
        end,

        [1077] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventUpdate(player, csid, option)
        end,

        [1078] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventUpdate(player, csid, option)
        end,

        [1079] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventUpdate(player, csid, option)
        end,

        [1080] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventUpdate(player, csid, option)
        end,
    },

    onEventFinish =
    {
        [1076] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventFinish(player, csid, option)
        end,

        [1077] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventFinish(player, csid, option)
        end,

        [1078] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventFinish(player, csid, option)
        end,

        [1079] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventFinish(player, csid, option)
        end,

        [1080] = function(player, csid, option, npc)
            xi.monsterRearing.penOnEventFinish(player, csid, option)
        end,
    },
}
