-----------------------------------
-- Ability: Scholar's Roll
-- Enhances Conserve MP effect for party members within area of effect
-- Optimal Job: Scholar
-- Lucky Number: 2
-- Unlucky Number: 6
-- Level: 64
--
-- Die Roll |No SCH     |With SCH
-- -------- --------    -----------
-- 1        |+2%        |+5%
-- 2        |+10%       |+13%
-- 3        |+3%        |+6%
-- 4        |+4%        |+7%
-- 5        |+4%        |+7%
-- 6        |+1%        |+4%
-- 7        |+5%        |+8%
-- 8        |+6%        |+9%
-- 9        |+7%        |+10%
-- 10       |+7%        |+10%
-- 11       |+12%       |+15%
-- Bust     |-3%        |-3%
-----------------------------------
require("scripts/globals/settings")
require("scripts/globals/ability")
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------

function onAbilityCheck(player,target,ability)
    ability:setRange(ability:getRange() + player:getMod(tpz.mod.ROLL_RANGE))

    if player:hasStatusEffect(tpz.effect.SCHOLARS_ROLL) then
        return tpz.msg.basic.ROLL_ALREADY_ACTIVE,0
    elseif atMaxCorsairBusts(player) then
        return tpz.msg.basic.CANNOT_PERFORM,0
    else
        return 0,0
    end
end

function onUseAbility(caster,target,ability,action)
    if caster:getID() == target:getID() then
        corsairSetup(caster, ability, action, tpz.effect.SCHOLARS_ROLL, tpz.job.SCH)
    end

    local total = caster:getLocalVar("corsairRollTotal")

    return applyRoll(caster,target,ability,action,total)
end

function applyRoll(caster,target,ability,action,total)
    local duration = 300 + caster:getMerit(tpz.merit.WINNING_STREAK) + caster:getMod(tpz.mod.PHANTOM_DURATION)
    local effectpowers = {2, 10, 3, 4, 4, 1, 5, 6, 7, 7, 14, 4}
    local effectpower = effectpowers[total]
    if caster:getLocalVar("corsairRollBonus") == 1 and total < 12 then
        effectpower = effectpower + 3
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

    if not target:addCorsairRoll(caster:getMainJob(), caster:getMerit(tpz.merit.BUST_DURATION), tpz.effect.SCHOLARS_ROLL, effectpower, 0, duration, caster:getID(), total, tpz.mod.CONSERVE_MP) then
        ability:setMsg(tpz.msg.basic.ROLL_MAIN_FAIL)
    elseif total > 11 then
        ability:setMsg(tpz.msg.basic.DOUBLEUP_BUST)
    end

    return total
end
