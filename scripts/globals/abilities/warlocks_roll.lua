-----------------------------------
-- Ability: Warlock's Roll
-- Enhances magic accuracy for party members within area of effect
-- Optimal Job: Red Mage
-- Lucky Number: 4
-- Unlucky Number: 8
-- Level: 46
-- Phantom Roll +1 Value: 1
--
-- Die Roll    |No RDM  |With RDM
-- --------    -------- -----------
-- 1           |+2      |+6
-- 2           |+3      |+7
-- 3           |+4      |+8
-- 4           |+10     |+14
-- 5           |+4      |+8
-- 6           |+5      |+9
-- 7           |+6      |+10
-- 8           |+1      |+5
-- 9           |+7      |+11
-- 10          |+7      |+11
-- 11          |+11     |+15
-- Bust        |-4      |-4
-----------------------------------
require("scripts/globals/settings")
require("scripts/globals/ability")
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------

function onAbilityCheck(player,target,ability)
    ability:setRange(ability:getRange() + player:getMod(tpz.mod.ROLL_RANGE))

    if player:hasStatusEffect(tpz.effect.WARLOCKS_ROLL) then
        return tpz.msg.basic.ROLL_ALREADY_ACTIVE,0
    elseif atMaxCorsairBusts(player) then
        return tpz.msg.basic.CANNOT_PERFORM,0
    else
        return 0,0
    end
end

function onUseAbility(caster,target,ability,action)
    if caster:getID() == target:getID() then
        corsairSetup(caster, ability, action, tpz.effect.WARLOCKS_ROLL, tpz.job.RDM)
    end

    local total = caster:getLocalVar("corsairRollTotal")

    return applyRoll(caster,target,ability,action,total)
end

function applyRoll(caster,target,ability,action,total)
    local duration = 300 + caster:getMerit(tpz.merit.WINNING_STREAK) + caster:getMod(tpz.mod.PHANTOM_DURATION)
    local effectpowers = {2, 3, 4, 10, 4, 5, 6, 1, 7, 7, 11, 4}
    local effectpower = effectpowers[total]
    if caster:getLocalVar("corsairRollBonus") == 1 and total < 12 then
        effectpower = effectpower + 4
    end

    -- Apply Additional Phantom Roll+ Buff
    -- local phantomBase = 1 -- Base increment buff
    -- local effectpower = effectpower + (phantomBase * phantombuffMultiple(caster))

    -- Check if COR Main or Sub
    if caster:getMainJob() == tpz.job.COR and caster:getMainLvl() < target:getMainLvl() then
        effectpower = effectpower * (caster:getMainLvl() / target:getMainLvl())
    elseif caster:getSubJob() == tpz.job.COR and caster:getSubLvl() < target:getMainLvl() then
        effectpower = effectpower * (caster:getSubLvl() / target:getMainLvl())
    end

    if not target:addCorsairRoll(caster:getMainJob(), caster:getMerit(tpz.merit.BUST_DURATION), tpz.effect.WARLOCKS_ROLL, effectpower, 0, duration, caster:getID(), total, tpz.mod.MACC) then
        ability:setMsg(tpz.msg.basic.ROLL_MAIN_FAIL)
    elseif total > 11 then
        ability:setMsg(tpz.msg.basic.DOUBLEUP_BUST)
    end

    return total
end
