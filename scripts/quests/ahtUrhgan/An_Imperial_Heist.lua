-----------------------------------
-- An Imperial Heist
-----------------------------------
-- Log ID: 6, Quest ID: 70
-- Naja Salaheem : Aht Urhgan Whitegate (I-10)
-----------------------------------
-- !! NOT IMPLEMENTED -- DELIBERATELY INERT !!
--
-- This file intentionally registers nothing. `questAvailable` below is false, so
-- no section ever matches and no NPC is claimed at Action.Priority.Progress.
-- Full requirements for the whole arc are in ODIN_MYTHIC_ARC_TODO.md at repo root.
--
-- Mythic chain #1. Unlocks Duties, Tasks, and Deeds -- which is itself inert, so
-- nothing downstream of this quest works either.
--
-- WHY IT IS NOT BUILT:
--   The offer csid has never been decoded. The previous author correctly noticed
--   that csid 200 in this zone is the MHAURA FERRY DEPARTURE cutscene, which
--   Aht_Urhgan_Whitegate/Zone.lua warps on -- that is the original ferry bug --
--   and so used printToPlayer instead of an event. Avoiding the bad csid was
--   right, but a quest cannot be driven by a chat line.
--   Beyond the csid, everything this quest gates is unbuildable: see the three
--   Mythic files and ODIN_MYTHIC_ARC_TODO.md.
--
-- WHAT THE STUB DID, AND WHY IT HAD TO GO:
--   Its onTrigger printed a line and then ran `quest:begin(player)` followed
--   immediately by `quest:complete(player)` -- so merely CLICKING Naja Salaheem
--   while eligible completed the quest, with no event, no prompt and no way to
--   decline. It was dormant only because {KI} Captain Wildcat badge was
--   unobtainable; rebuilding Promotion_Captain.lua made that badge obtainable
--   and so made this handler live. That is why it is being switched off now
--   rather than later.
--   Note it did NOT block Naja: returning no action lets the framework fall
--   through to her own script, so Assault registration still worked. The fault
--   was the silent auto-completion, not a hijack.
--
-- RETAIL REQUIREMENTS (bg-wiki), for whoever builds it:
--   {KI} Captain Wildcat badge (top mercenary rank), {KI} Runic key (Nyzul Isle),
--   and ToAU Mission 48 Eternal Mercenary complete. All three gates were already
--   correct in the stub and are worth keeping when it is rebuilt.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.AN_IMPERIAL_HEIST)

-- Flip to true ONLY together with real, decoded csids and the content below.
local questAvailable = false

quest.sections =
{
    {
        check = function(player, status, vars)
            return questAvailable
        end,
    },
}

return quest
