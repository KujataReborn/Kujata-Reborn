-----------------------------------------
-- Spell: Shellra
-----------------------------------------
require("scripts/globals/status")
require("scripts/globals/magic")
require("scripts/globals/msg")
-----------------------------------------

function onMagicCastingCheck(caster,target,spell)
    return 0
end

function onSpellCast(caster,target,spell)
    local power = 62
    local meritBonus = caster:getMerit(tpz.merit.SHELLRA_V)
    if (meritBonus > 0) then -- certain mobs can cast this spell, so don't apply the -2 for having 0 merits.
        power = power + meritBonus - 2
    end
    power = power * 100 / 256 -- doing it this way because otherwise the merit power would have to be 0.78125.

    local duration = calculateDuration(1800, spell:getSkillType(), spell:getSpellGroup(), caster, target, false)
    duration = calculateDurationForLvl(duration, 75, target:getMainLvl())

    local typeEffect = tpz.effect.SHELL
    if (target:addStatusEffect(typeEffect, power, 0, duration)) then
        spell:setMsg(tpz.msg.basic.MAGIC_GAIN_EFFECT)
    else
        spell:setMsg(tpz.msg.basic.MAGIC_NO_EFFECT) -- no effect
    end

    return typeEffect
end
