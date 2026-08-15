-----------------------------------
-- Fully Mental Alchemist
-----------------------------------
-- Log ID: 1, Quest ID: 88
-- Titus    : Bastok Mines (L-7), 2nd floor of the Alchemy Guild
-- Riverbed : Grauberg [S] (F-13)
-----------------------------------
-- Retail (bg-wiki "Fully Mental Alchemist"):
--   1. Speak to Titus -> {KI} Prospector's pan and {KI} Corked ampoule.
--   2. Go to Grauberg [S] and find the Riverbed at (F-13).
--   3. Examine it: pick a scoop size (sizable / moderate / small), then a wash
--      (vigorously / thoroughly / gently). Repeat until "Wash carefully to
--      extract gold" appears.
--   4. Choose it for 3-11 random grains. Repeat until 20 grains or more, which
--      yields {KI} Ampoule of gold dust. LEAVING GRAUBERG [S] LOSES ALL PROGRESS.
--   5. Speak to Titus -> Trainee Sword.
-- Fame Bastok 1. No title, not repeatable.
--
-- CSIDs decoded, not guessed. Titus is entity 17735712 (npc_list:27380);
-- (17735712-16777216) = 958496, 958496//4096 = 234 rem 32 -> Bastok Mines,
-- 0x010EA020. Read against `xi-dat dialog 234`:
--   587 -> the offer, two prompts, granting both key items. 14158 "Ahhh, the
--          pain! The sheer agony! Here I stand on the verge of the single
--          greatest breakthrough in the long and storied history of the
--          alchemical arts", 14160 "Am I right? / Uh...you're right. / Couldn't
--          be more wrong.", 14164 "the mountainous crags that lie beyond
--          Gustaberg: the area they call Grauberg", 14167 "What say you? / Leave
--          it to me! / I say do your own work.", 14170 "Take this
--          ${keyitem-singular: 0} and retrieve the magical gold dust I seek.",
--          14171 "twenty grains should do the trick", 14172 "Bring them back
--          here in this ${keyitem-singular: 0}"
--   588 -> 14173 "My adventuring friend! Have you managed to secure the enchanted
--          gold dust I seek?", 14174 "How to get to Grauberg, you ask? ...the
--          path leading there has been obstructed"
--   589 -> 14175 "Wait, could it be!? ...You've returned triumphant with the
--          ingredient I seek!", 14176 "Spectacular! So pure, and simply oozing
--          with magical energy!" -- the Trainee Sword.
-- The Riverbed is entity 17142570 (npc_list:10043); (17142570-16777216) =
-- 365354, 365354//4096 = 89 rem 810 -> Grauberg [S], 0x0105932A. csidmsg
-- 89 17142570 -> 24 -> 7924-7938, and every bg-wiki bullet is present verbatim:
--   7925 "Pan for gold using your ${keyitem-singular: 0}?"
--   7926 "How much sediment will you scoop? / A sizable portion. / A moderate
--        portion. / A small portion. / Do nothing."
--   7930 "Submerge your pan in the stream and... / Wash carefully to extract
--        gold. / Wash vigorously. / Wash thoroughly. / Wash gently."
--   7935-7938 the filter results
--   7939 "${name-player} successfully retrieved ${number: 0} grain/grains of gold
--        and placed them in his/her ${keyitem-singular: 1}. (Total: ${number: 2})"
--   7940 "If you leave the area before acquiring a minimum of ${number: 0}
--        grains, you will lose all the gold dust you have acquired."
-- 7939 and 7940 are now named in scripts/zones/Grauberg_[S]/IDs.lua.
--
-- THE OLD STUB'S CSIDS DO NOT EXIST: `xi-dat csid 234 900` returns nothing, and
-- the same for 901/902. The stub also replaced the entire pan/wash loop with
-- "zone into Grauberg [S] once -> free Ampoule of gold dust."
--
-- ENTITY AMBIGUITY, resolved: there are two NPCs named 'Titus' in zone 234.
-- 17735712 (index 32, status 0) owns csids 123/587/588/589; 17735819 (index 139,
-- status 6) owns no events at all. This quest is wired to 17735712, and every
-- handler is gated on that entity id. There is a third 'Titus', 17670750, but it
-- decodes to zone 218 (Abyssea) and is irrelevant here.
--
-- COEXISTENCE: scripts/zones/Bastok_Mines/npcs/Titus.lua already exists and
-- routes this same entity into xi.crafting.oldImageSupportOnTrigger /
-- ...OnEventFinish, which is csid 123 (Alchemy Guild image support). That file is
-- deliberately left alone. While this quest is AVAILABLE or ACCEPTED its sections
-- claim Titus at Action.Priority.Progress, so the quest is offered; once it is
-- COMPLETED no section matches and image support resumes, which is the retail
-- behaviour for a guild NPC that also carries a quest.
--
-- bg-wiki lists no fame, so the stub's 30 is gone. Trainee Sword is retail.
--
-- The grain count lives in a LOCAL var, not a quest var, on purpose: local vars
-- are cleared on zone out, so "leaving Grauberg [S] loses all progress" falls out
-- of the storage choice rather than needing a zone-exit hook.
--
-- NEEDS AN IN-GAME PROBE: csid 24 is a single program covering the whole
-- scoop-then-wash loop, and which `option` value corresponds to "Wash carefully
-- to extract gold" is not decoded -- retail only offers that choice on some
-- iterations. So a completed pan awards grains rather than gating on that exact
-- option. The 3-11 grain spread, the 20-grain threshold and the progress loss are
-- all faithful; the sub-menu branch is the part to confirm with !cs 24.
-----------------------------------
local grauberg = zones[xi.zone.GRAUBERG_S]

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.FULLY_MENTAL_ALCHEMIST)

quest.reward =
{
    item = xi.item.TRAINEE_SWORD,
}

local titus         = 17735712
local grainsNeeded  = 20
local grainsPerPan  = { 3, 11 }

local function isTitus(npc)
    return npc ~= nil and npc:getID() == titus
end

quest.sections =
{
    -- Offer.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.BASTOK) >= 1
        end,

        [xi.zone.BASTOK_MINES] =
        {
            ['Titus'] =
            {
                onTrigger = function(player, npc)
                    if not isTitus(npc) then
                        return
                    end

                    return quest:progressEvent(587, { [0] = xi.ki.PROSPECTORS_PAN, [1] = xi.ki.CORKED_AMPOULE })
                end,
            },

            onEventFinish =
            {
                -- 14167 "What say you? / Leave it to me! / I say do your own
                -- work." -- option 0 accepts.
                [587] = function(player, csid, option, npc)
                    if option ~= 0 or not isTitus(npc) then
                        return
                    end

                    quest:begin(player)
                    npcUtil.giveKeyItem(player, { xi.ki.PROSPECTORS_PAN, xi.ki.CORKED_AMPOULE })
                end,
            },
        },
    },

    -- Panning.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                not player:hasKeyItem(xi.ki.AMPOULE_OF_GOLD_DUST)
        end,

        [xi.zone.BASTOK_MINES] =
        {
            ['Titus'] =
            {
                onTrigger = function(player, npc)
                    if not isTitus(npc) then
                        return
                    end

                    return quest:event(588, { [0] = xi.ki.CORKED_AMPOULE })
                end,
            },
        },

        [xi.zone.GRAUBERG_S] =
        {
            ['Riverbed'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.PROSPECTORS_PAN) then
                        return
                    end

                    return quest:progressEvent(24, { [0] = xi.ki.PROSPECTORS_PAN, [1] = xi.ki.CORKED_AMPOULE, [2] = grainsNeeded })
                end,
            },

            onEventFinish =
            {
                [24] = function(player, csid, option, npc)
                    -- "Do nothing" and the non-extracting washes leave the count
                    -- alone.
                    if option == 0 then
                        return
                    end

                    local grains = player:getLocalVar('goldDustGrains') +
                        math.random(grainsPerPan[1], grainsPerPan[2])

                    player:setLocalVar('goldDustGrains', grains)
                    player:messageSpecial(grauberg.text.GOLD_GRAINS_RETRIEVED, grains, xi.ki.CORKED_AMPOULE, grains)

                    if grains < grainsNeeded then
                        player:messageSpecial(grauberg.text.LEAVE_AREA_LOSE_GOLD_DUST, grainsNeeded)
                        return
                    end

                    if npcUtil.giveKeyItem(player, xi.ki.AMPOULE_OF_GOLD_DUST) then
                        player:delKeyItem(xi.ki.CORKED_AMPOULE)
                        player:setLocalVar('goldDustGrains', 0)
                    end
                end,
            },
        },
    },

    -- Turn-in.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:hasKeyItem(xi.ki.AMPOULE_OF_GOLD_DUST)
        end,

        [xi.zone.BASTOK_MINES] =
        {
            ['Titus'] =
            {
                onTrigger = function(player, npc)
                    if not isTitus(npc) then
                        return
                    end

                    return quest:progressEvent(589)
                end,
            },

            onEventFinish =
            {
                [589] = function(player, csid, option, npc)
                    if not isTitus(npc) then
                        return
                    end

                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.AMPOULE_OF_GOLD_DUST)
                        player:delKeyItem(xi.ki.PROSPECTORS_PAN)
                    end
                end,
            },
        },
    },
}

return quest
