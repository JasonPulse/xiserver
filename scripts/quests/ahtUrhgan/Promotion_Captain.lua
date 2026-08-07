-----------------------------------
-- Promotion: Captain
-- Abquhbah: !pos 35.5 -6.6 -58 50
-----------------------------------
-- Log ID: 6, Quest ID: 99
--
-- Retail (bg-wiki "Promotion: Captain"):
--   Requires all 50 Assaults completed, Aht Urhgan Mission 48 (Eternal
--   Mercenary), and Promotion: First Lieutenant complete.
--   Abquhbah teaches the massage technique, then the player repeats it on
--   President Naja, choosing <Knead> at each prompt.
--   Rewards the Captain Wildcat badge and the Captain title.
--
-- CSID 5086 decoded from the DAT dumps, not guessed:
--   xi-dat events 50   -> the Whitegate promotion series is a closed run
--                         5000..5086; the nine sibling Promotion_* quests in
--                         this directory already consume every id up to 5085,
--                         leaving 5086 as the only unclaimed id, and Captain
--                         as the only unimplemented promotion.
--   xi-dat search 50 "Knead" -> 14202 '<Knead>...<knead>...', and 14212/14213/
--                         14214 'How do you proceed? ${selection-lines}' with
--                         Knead at option 0/1/2 respectively (the prompt order
--                         is shuffled per attempt), plus 14205 '...give her
--                         poor, tired muscles the same kind of massage!'.
--   Cross-checked that 5086 is referenced nowhere else in scripts/.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.PROMOTION_CAPTAIN)

quest.reward =
{
    keyItem = xi.ki.CAPTAIN_WILDCAT_BADGE,
    title   = xi.title.CAPTAIN,
}

-- Assaults 1..50 are the fifty counted by retail; 51 and 52 are the two Nyzul
-- Isle operations and are deliberately excluded.
local function hasCompletedAllAssaults(player)
    for assaultId = xi.assault.mission.LEUJAOAM_CLEANSING, xi.assault.mission.BELLEROPHONS_BLISS do
        if not player:hasCompletedAssault(assaultId) then
            return false
        end
    end

    return true
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.PROMOTION_FIRST_LIEUTENANT) == xi.questStatus.QUEST_COMPLETED and
                player:hasCompletedMission(xi.mission.log_id.TOAU, xi.mission.id.toau.ETERNAL_MERCENARY) and
                hasCompletedAllAssaults(player)
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Abquhbah'] = quest:progressEvent(5086),

            onEventFinish =
            {
                -- The client drives the whole massage sequence inside 5086 and
                -- allows retries in-event (14218/14219), so the event only
                -- reaches its finish handler once the player has succeeded.
                [5086] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
