-----------------------------------
-- VW Op. 054: Elshimo List
-----------------------------------
-- Log ID: 5, Quest ID: 101
-- Hildegard : Kazham (F-8)
-----------------------------------
-- Voidwatch Op — retail targeted Holy Moly / Neith / Ildebrann Tier I
-- NMs across Elshimo Region. VW not yet implemented; stub accepts and
-- immediately completes until VW Lite is built.
-----------------------------------
local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_054_ELSHIMO_LIST)

quest.reward =
{
    fame     = 20,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.VOIDWATCH_OPS_BORDER_CROSSING)
        end,

        [xi.zone.KAZHAM] =
        {
            ['Hildegard'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(301)
                end,
            },

            onEventFinish =
            {
                [301] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
