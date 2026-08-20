-----------------------------------
-- Hyper Active
-----------------------------------
-- Log ID: 1, Quest ID: 80
-- Raibaht     : Metalworks (G-8)
-- Cermet Door : Lower Delkfutt's Tower basement (I-6) -- the UNNAMED one, _543
-- Chandraj    : Lower Delkfutt's Tower, same spot
-- Street Lamps: Lower Jeuno
-----------------------------------
-- Retail (bg-wiki "Hyper Active"), previous quest Teak Me to the Stars:
--   1. Speak to Raibaht -> {KI} Molybdenum box.
--   2. Go to the Lower Delkfutt's Tower basement (needs the Delkfutt Key).
--   3. At (I-6) touch the Cermet Door -> pops Orna plus two Fomorian Spear.
--   4. Kill Orna (the other two depop), then touch the Cermet Door again.
--   5. Go to Lower Jeuno and inspect Street Lamps until you find
--      {KI} Hyper altimeter.
--   6. Return to Raibaht. Reward 3,000 gil. Fame Bastok 4.
--
-- CSIDs decoded, not guessed. Raibaht is entity 17748012 (npc_list:28596);
-- (17748012-16777216) = 970796, 970796//4096 = 237 rem 44 -> Metalworks,
-- 0x010ED02C. Read against `xi-dat dialog 237`:
--   501 -> 7525, his generic idle.
--   866 -> the offer. `xi-dat csid 237 866` puts a 524-byte program on the
--          named-but-invisible holder DIRECTOR 0x010ED0A3, with 1-byte stubs on
--          Raibaht and on _6l5 'Door:Cid's Lab' 0x010ED04E. DIRECTOR's data table
--          holds 9946-9952: 9946 "The chief asked an adventurer to bring him a
--          highly advanced altimeter from Jeuno.", 9947 "the adventurer was
--          ...arrested for attempting to transport the restricted item", 9948
--          "he has been ordered to defeat an unknown beast in Delkfutt's Tower",
--          9950 "You may use this ${keyitem-singular: 2}. If you put the
--          ${keyitem-singular: 1} in it, the Ducal Guard and the customs
--          officials ...should not find the item.", 9951 "Accept the job? / Yes.
--          / No."
--   872 -> a 33-byte program directly on Raibaht -> 9953 "The adventurer we seek
--          has been ordered to travel to Delkfutt's Tower and defeat a monster
--          known as Orna.", 9954 "Find that man and have him tell you where he
--          hid the ${keyitem-singular: 1}."
--   867 -> a 59-byte program on Raibaht, resolved through his own data table:
--          it references 0x8044/0x8045 -> data[0x44] = 9955, data[0x45] = 9956.
--          9955 "With this, the chief will be able to improve on his current
--          theories", 9956 "Again, it is not much, but please accept this reward
--          for your services." -- the 3,000 gil.
--   26  -> Chandraj, the arrested adventurer. `xi-dat csid 184 26` puts a
--          608-byte program on DIRECTOR 0x010B8144 plus a 13-byte stub on
--          0x010B8147 = Chandraj (17531207 -> 753991//4096 = 184 rem 327). The
--          program references entity 47810B01 throughout and pulls data indices
--          0x13,0x14,0x15,0x16,0x18,0x19,0x1A, which DIRECTOR's table maps to
--          7515-7521: 7515 "W-were y-you the one th-th-that defeated the
--          hi-hideous b-b-b-b-beast?", 7518 "R-R-Raibaht s-s-s-sent you? You
--          w-w-want to know wh-wh-where I hid th-the alti-ti-ti-timeter?", 7519
--          "B-b-b-but without ${keyitem-article: 2}, you'll n-n-never get i-i-it
--          out of J-Jeuno." (the Molybdenum box gate), 7520 "ch-ch-check the
--          s-streetlamps in L-L-L-Lower J-Jeuno. Th-that's where I-I hid th-the
--          altimeter."
--
-- WRONG CERMET DOOR IN THE STUB -- this is the important find. Zone 184 has seven
-- Cermet Doors. The Hyper Active door is the UNNAMED '_543' (17531159, at
-- 500.870 / 19.343 / 91.976) -- 8.5 units from Orna's spawn point
-- (507.288 / 23.707 / 97.632), with Chandraj (17531207, status 6) standing
-- between them. That is the (I-6) basement group, and _543 has no script.
-- The NAMED 'Cermet_Door' (17531158, at 520.437 / 13.333 / 20.025) is the
-- up-warp to Upper Delkfutt's Tower, already scripted at
-- scripts/zones/Lower_Delkfutts_Tower/npcs/Cermet_Door.lua:11 firing csid 20
-- ("Open the door? / Yes. / No.") and doing a setPos. It is left untouched.
--
-- Mob data verified present and healthy:
--   Orna           17531122, mob_spawn_points.sql:64519, at 507.288/23.707/97.632
--                  mob_groups.sql:12705 (27, 3055, 184, 'Orna', ...) poolid 3055,
--                  respawn 0 = pop-only
--   Fomorian Spear 17531123 / 17531124, spawn points :64520-64521
--                  mob_groups.sql:12706 poolid 1379
--
-- _543 owns no csid at all -- only the 65535 sentinel -- so the pop is a
-- server-side spawn plus the system message 7523 "A bloodthirsty monster has
-- appeared!", which is now named in Lower_Delkfutts_Tower/IDs.lua. Likewise
-- `xi-dat search 245 "altimeter"` returns zero hits and the Lower Jeuno lamp
-- csids 120-131 belong entirely to the separate lamp-lighting quest, so the
-- altimeter find is eventless too: a plain key-item grant on lamp trigger.
-- Neither is an undecoded id; both are genuinely event-free.
--
-- The old stub invented 502/503 on Raibaht, skipped Orna and Chandraj entirely
-- with a zone-in flag, and hardcoded the altimeter into '_l00' -- so the "search
-- the lamps" step was a single guaranteed click on one specific lamp. It also
-- carried a fame of 40 that bg-wiki does not list.
--
-- STILL SIMPLIFIED: which lamp holds the altimeter is randomised per player and
-- persisted, so the search is real, but retail's exact lamp-selection rule is
-- unknown. 3,000 gil is retail.
-----------------------------------
local delkfuttID = zones[xi.zone.LOWER_DELKFUTTS_TOWER]

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.HYPER_ACTIVE)

quest.reward =
{
    gil = 3000,
}

local orna         = 17531122
local fomorianSpear = { 17531123, 17531124 }

local lampCount = 12

local function lampName(index)
    return string.format('_l%02d', index)
end

quest.sections =
{
    -- Offer.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.BASTOK) >= 4 and
                player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.TEAK_ME_TO_THE_STARS)
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(866, { [1] = xi.ki.HYPER_ALTIMETER, [2] = xi.ki.MOLYBDENUM_BOX })
                end,
            },

            onEventFinish =
            {
                -- 9951 "Accept the job? / Yes. / No."
                [866] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.MOLYBDENUM_BOX)
                    end
                end,
            },
        },
    },

    -- Orna not yet beaten.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Orna == 0
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] = quest:event(872, { [1] = xi.ki.HYPER_ALTIMETER }),
        },

        [xi.zone.LOWER_DELKFUTTS_TOWER] =
        {
            ['_543'] =
            {
                onTrigger = function(player, npc)
                    if npcUtil.popFromQM(player, npc, { orna, fomorianSpear[1], fomorianSpear[2] }, { hide = 0 }) then
                        return quest:messageSpecial(delkfuttID.text.BLOODTHIRSTY_MONSTER_APPEARED)
                    end

                    return quest:noAction()
                end,
            },

            ['Orna'] =
            {
                onMobDeath = function(mob, player, optParams)
                    quest:setVar(player, 'Orna', 1)
                end,
            },
        },
    },

    -- Orna down: touch the door again for Chandraj, then hunt the lamps.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Orna == 1 and
                not player:hasKeyItem(xi.ki.HYPER_ALTIMETER)
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] = quest:event(872, { [1] = xi.ki.HYPER_ALTIMETER }),
        },

        [xi.zone.LOWER_DELKFUTTS_TOWER] =
        {
            ['_543'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(26, { [1] = xi.ki.HYPER_ALTIMETER, [2] = xi.ki.MOLYBDENUM_BOX })
                end,
            },

            onEventFinish =
            {
                -- 7519 gates on the Molybdenum box, 7520 sends you to the lamps.
                [26] = function(player, csid, option, npc)
                    if player:hasKeyItem(xi.ki.MOLYBDENUM_BOX) then
                        quest:setVar(player, 'Told', 1)
                    end
                end,
            },
        },
    },
}

-- The lamp search. Registered from the table so all twelve behave alike, with the
-- holding lamp chosen once per player and remembered.
local lampSection = quest.sections[3][xi.zone.LOWER_JEUNO]

if lampSection == nil then
    lampSection = {}
    quest.sections[3][xi.zone.LOWER_JEUNO] = lampSection
end

for index = 0, lampCount - 1 do
    lampSection[lampName(index)] =
    {
        onTrigger = function(player, npc)
            if quest:getVar(player, 'Told') ~= 1 then
                return
            end

            local holding = quest:getVar(player, 'Lamp')

            if holding == 0 then
                holding = math.random(1, lampCount)
                quest:setVar(player, 'Lamp', holding)
            end

            if holding ~= index + 1 then
                return quest:messageSpecial(zones[xi.zone.LOWER_JEUNO].text.NOTHING_OUT_OF_ORDINARY)
            end

            return quest:keyItem(xi.ki.HYPER_ALTIMETER)
        end,
    }
end

-- Turn-in.
table.insert(quest.sections,
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED and
            player:hasKeyItem(xi.ki.HYPER_ALTIMETER)
    end,

    [xi.zone.METALWORKS] =
    {
        ['Raibaht'] =
        {
            onTrigger = function(player, npc)
                return quest:progressEvent(867)
            end,
        },

        onEventFinish =
        {
            [867] = function(player, csid, option, npc)
                if quest:complete(player) then
                    player:delKeyItem(xi.ki.HYPER_ALTIMETER)
                    player:delKeyItem(xi.ki.MOLYBDENUM_BOX)
                end
            end,
        },
    },
})

-- Post-completion idle.
table.insert(quest.sections,
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_COMPLETED
    end,

    [xi.zone.METALWORKS] =
    {
        ['Raibaht'] = quest:event(501),
    },
})

return quest
