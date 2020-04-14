-----------------------------------
-- Ability: Dancer's Roll
-- Grants Regen status to party members within area of effect
-- Optimal Job: Dancer
-- Lucky Number: 3
-- Unlucky Number: 7
-- Level: 61
--
-- Die Roll    |No DNC              |With DNC
-- --------    ----------           ----------
-- 1           |3HP/Tick            |6HP/Tick
-- 2           |4HP/Tick            |7HP/Tick
-- 3           |11HP/Tick           |14HP/Tick
-- 4           |4HP/Tick            |7HP/Tick
-- 5           |5HP/Tick            |8HP/Tick
-- 6           |6HP/Tick            |9HP/Tick
-- 7           |1HP/Tick            |4HP/Tick
-- 8           |7HP/Tick            |10HP/Tick
-- 9           |8HP/Tick            |11HP/Tick
-- 10          |8HP/Tick            |11HP/Tick
-- 11          |14HP/Tick           |17HP/Tick
-- 12+         |-3HP/Tick           |-3hp(regen)/Tick
-- A bust will cause a regen effect on you to be reduced by 4, it will not drain HP from you if no regen effect is active.
-----------------------------------
require("scripts/globals/settings")
require("scripts/globals/ability")
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------

function onAbilityCheck(player,target,ability)
    ability:setRange(ability:getRange() + player:getMod(tpz.mod.ROLL_RANGE))

    if player:hasStatusEffect(tpz.effect.DANCERS_ROLL) then
        return tpz.msg.basic.ROLL_ALREADY_ACTIVE,0
    elseif atMaxCorsairBusts(player) then
        return tpz.msg.basic.CANNOT_PERFORM,0
    else
        return 0,0
    end
end

function onUseAbility(caster,target,ability,action)
    if caster:getID() == target:getID() then
        corsairSetup(caster, ability, action, tpz.effect.DANCERS_ROLL, tpz.job.DNC)
    end

    local total = caster:getLocalVar("corsairRollTotal")

    return applyRoll(caster,target,ability,action,total)
end

function applyRoll(caster,target,ability,action,total)
    local duration = 300 + caster:getMerit(tpz.merit.WINNING_STREAK) + caster:getMod(tpz.mod.PHANTOM_DURATION)
    local effectpowers = {3, 4, 11, 4, 5, 6, 1, 7, 8, 8, 14, 3}
    local effectpower = effectpowers[total]
    if caster:getLocalVar("corsairRollBonus") == 1 and total < 12 then
        effectpower = effectpower + 3
    end
    -- Apply Additional Phantom Roll+ Buff
    -- local phantomBase = 2 -- Base increment buff
    -- local effectpower = effectpower + (phantomBase * phantombuffMultiple(caster))

    -- Check if COR Main or Sub
    if caster:getMainJob() == tpz.job.COR and caster:getMainLvl() < target:getMainLvl() then
        effectpower = effectpower * (caster:getMainLvl() / target:getMainLvl())
    elseif caster:getSubJob() == tpz.job.COR and caster:getSubLvl() < target:getMainLvl() then
        effectpower = effectpower * (caster:getSubLvl() / target:getMainLvl())
    end

    if not target:addCorsairRoll(caster:getMainJob(), caster:getMerit(tpz.merit.BUST_DURATION), tpz.effect.DANCERS_ROLL, effectpower, 0, duration, caster:getID(), total, tpz.mod.REGEN) then
        ability:setMsg(tpz.msg.basic.ROLL_MAIN_FAIL)
    elseif total > 11 then
        ability:setMsg(tpz.msg.basic.DOUBLEUP_BUST)
    end

    return total
end
