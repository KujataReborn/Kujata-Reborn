-----------------------------------------
-- Spell: Sage Etude
-- Static INT Boost, BRD 66
-----------------------------------------
require("scripts/globals/status")
require("scripts/globals/magic")
require("scripts/globals/msg")
-----------------------------------------

function onMagicCastingCheck(caster,target,spell)
    return 0
end

function onSpellCast(caster,target,spell)
    local sLvl = caster:getSkillLevel(tpz.skill.SINGING) -- Gets skill level of Singing
    local iLvl = caster:getWeaponSkillLevel(tpz.slot.RANGED)
    local skill = sLvl + iLvl

    local power = 0
    if skill <= 416 then
        power = 12
    elseif skill >= 417 and skill <= 445 then
        power = 13
    elseif skill >= 446 and skill <= 474 then
        power = 14
    elseif skill >= 475 then
        power = 15
    end

    local iBoost = caster:getMod(tpz.mod.ETUDE_EFFECT) + caster:getMod(tpz.mod.ALL_SONGS_EFFECT)
    power = power + iBoost

    if caster:hasStatusEffect(tpz.effect.SOUL_VOICE) then
        power = power * 2
    -- elseif caster:hasStatusEffect(tpz.effect.MARCATO) then
        -- power = power * 1.5
        -- caster:delStatusEffect(tpz.effect.MARCATO)
    end

    local duration = 120
    duration = duration * ((iBoost * 0.1) + (caster:getMod(tpz.mod.SONG_DURATION_BONUS) / 100) + 1)

    if caster:hasStatusEffect(tpz.effect.TROUBADOUR) then
        duration = duration * 2
    end

    if not target:addBardSong(caster, tpz.effect.ETUDE, power, 10, duration, caster:getID(), tpz.mod.INT, 2) then
        spell:setMsg(tpz.msg.basic.MAGIC_NO_EFFECT)
    end

    return tpz.effect.ETUDE
end
