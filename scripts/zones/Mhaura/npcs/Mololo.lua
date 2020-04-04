-----------------------------------
-- Area: Mhaura
--  NPC: Mololo
-- Guild Merchant NPC: Blacksmithing Guild
-- !pos -64.278 -16.624 34.120 249
-----------------------------------
local ID = require("scripts/zones/Mhaura/IDs")
require("scripts/globals/shop")
require("scripts/globals/crafting")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------

function onTrade(player,npc,trade)
end

function onTrigger(player,npc)
    if (player:sendGuild(532,8,23,2)) then
        player:showText(npc,ID.text.SMITHING_GUILD)
    end
end

function onEventUpdate(player,csid,option)
end

function onEventFinish(player,csid,option)
end
