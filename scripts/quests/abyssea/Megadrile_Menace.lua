-----------------------------------
-- Megadrile Menace
-----------------------------------
-- !addquest 8 165
-----------------------------------
local tahrongiID = zones[xi.zone.TAHRONGI_CANYON]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.MEGADRILE_MENACE)

quest.reward = { }

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                xi.abyssea.getHeldTraverserStones(player) >= 1 and
                player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.DAWN_OF_DEATH) >= xi.questStatus.QUEST_ACCEPTED
        end,

        -- WRONG ZONE, fixed (both sections). bg-wiki: "Examine the Cavernous Maw
        -- in TAHRONGI CANYON at (H-12)" / "Exit Abyssea - Tahrongi for a cutscene
        -- that finishes the quest." `xi-dat csid 102 38` reports "not found in
        -- zone 102" -- csids 38/39 exist only in zone 117 on 0x01075275
        -- (17257077, Tahrongi Canyon). The file's own line 6 already declares
        -- `local tahrongiID` and line 36 messages through it, so the data always
        -- said Tahrongi.
        -- Two live consequences of the misfile: the stray ['Cavernous_Maw'] binding
        -- competed with A_Goldstruck_Gigas on LA THEINE's maw under an identical
        -- check, and performNextAction alternates between equal-priority actions --
        -- so every other click there fired nonexistent event 38. And completion was
        -- unreachable, since the onZoneIn(39) reward section sat in the wrong zone.
        [xi.zone.TAHRONGI_CANYON] =
        {
            ['Cavernous_Maw'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(38)
                end,
            },

            onEventFinish =
            {
                [38] = function(player, csid, option, npc)
                    quest:begin(player)
                    player:addCurrency('cruor', 50)
                    player:messageSpecial(tahrongiID.text.CRUOR_OBTAINED, 50, player:getCurrency('cruor'))
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and player:hasTitle(xi.title.GLAVOID_STAMPEDER)
        end,

        [xi.zone.TAHRONGI_CANYON] =
        {
            onZoneIn = function(player, prevZone)
                return 39
            end,

            onEventUpdate =
            {
                [39] = function(player, csid, option, npc)
                    if option == 1 then
                        player:updateEvent(xi.abyssea.getZoneKIReward(player))
                    end
                end,
            },

            onEventFinish =
            {
                [39] = function(player, csid, option, npc)
                    -- NOTE: Give the key item prior to completing the quest so that we reward the correct
                    -- KI!  If we complete first, it'll adjust the total completed count, and be off by one!
                    npcUtil.giveKeyItem(player, xi.abyssea.getZoneKIReward(player))
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
