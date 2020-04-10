-----------------------------------
-- Ability: Beast Roll
-- Enhances pet attacks for party members within area of effect
-- Optimal Job: Beastmaster
-- Lucky Number: 4
-- Unlucky Number: 8
-- Level: 34
--
-- Die Roll |No BST     |With BST
-- -------- --------    -----------
-- 1        |+5%        |+13%
-- 2        |+6%        |+14%
-- 3        |+7%        |+15%
-- 4        |+19%       |+27%
-- 5        |+8%        |+16%
-- 6        |+9%        |+17%
-- 7        |+12%       |+20%
-- 8        |+2%        |+10%
-- 9        |+13%       |+21%
-- 10       |+14%       |+22%
-- 11       |+23%       |+31%
-- Bust     |-8         |-8
-----------------------------------
require("scripts/globals/settings")
require("scripts/globals/ability")
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------

function onAbilityCheck(player,target,ability)
    ability:setRange(ability:getRange() + player:getMod(tpz.mod.ROLL_RANGE))

    if player:hasStatusEffect(tpz.effect.BEAST_ROLL) then
        return tpz.msg.basic.ROLL_ALREADY_ACTIVE,0
    elseif atMaxCorsairBusts(player) then
        return tpz.msg.basic.CANNOT_PERFORM,0
    else
        return 0,0
    end
end

function onUseAbility(caster,target,ability,action)
    if caster:getID() == target:getID() then
        corsairSetup(caster, ability, action, tpz.effect.BEAST_ROLL, tpz.job.BST)
    end

    local total = caster:getLocalVar("corsairRollTotal")

    return applyRoll(caster,target,ability,action,total)
end

function applyRoll(caster,target,ability,action,total)
    local duration = 300 + caster:getMerit(tpz.merit.WINNING_STREAK) + caster:getMod(tpz.mod.PHANTOM_DURATION)
    local effectpowers = {4, 5, 7, 19, 8, 9, 11, 2, 13, 14, 23, 8}
    local effectpower = effectpowers[total]
    if caster:getLocalVar("corsairRollBonus") == 1 and total < 12 then
        effectpower = effectpower + 8
    end

    -- Apply Additional Phantom Roll+ Buff
    -- local phantomBase = 3 -- Base increment buff
    -- local effectpower = effectpower + (phantomBase * phantombuffMultiple(caster))

    -- Check if COR Main or Sub
    if caster:getMainJob() == tpz.job.COR and caster:getMainLvl() < target:getMainLvl() then
        effectpower = effectpower * (caster:getMainLvl() / target:getMainLvl())
    elseif caster:getSubJob() == tpz.job.COR and caster:getSubLvl() < target:getMainLvl() then
        effectpower = effectpower * (caster:getSubLvl() / target:getMainLvl())
    end

    if not target:addCorsairRoll(caster:getMainJob(), caster:getMerit(tpz.merit.BUST_DURATION), tpz.effect.BEAST_ROLL, effectpower, 0, duration, caster:getID(), total, MOD_PET_ATTP) then
        ability:setMsg(tpz.msg.basic.ROLL_MAIN_FAIL)
    elseif total > 11 then
        ability:setMsg(tpz.msg.basic.DOUBLEUP_BUST)
    end

    return total
end
