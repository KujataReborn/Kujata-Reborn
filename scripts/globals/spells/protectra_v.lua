-----------------------------------------
-- Spell: Protectra V
-----------------------------------------
require("scripts/globals/magic")
require("scripts/globals/msg")
require("scripts/globals/status")
-----------------------------------------

function onMagicCastingCheck(caster, target, spell)
    return 0
end

function onSpellCast(caster, target, spell)
    local power = 175 + meritBonus
    local meritBonus = caster:getMerit(dsp.merit.PROTECTRA_V)
    if (meritBonus > 0) then -- certain mobs can cast this spell, so don't apply the -5 for having 0 merits.
        power = power + meritBonus - 5
    end

    local duration = calculateDuration(1800, spell:getSkillType(), spell:getSpellGroup(), caster, target, false)
    duration = calculateDurationForLvl(duration, 75, target:getMainLvl())

    local typeEffect = tpz.effect.PROTECT
    if target:addStatusEffect(typeEffect, power, 0, duration) then
        spell:setMsg(tpz.msg.basic.MAGIC_GAIN_EFFECT)
    else
        spell:setMsg(tpz.msg.basic.MAGIC_NO_EFFECT) -- no effect
    end

    return typeEffect
end
