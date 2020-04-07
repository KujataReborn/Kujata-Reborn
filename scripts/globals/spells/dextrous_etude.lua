-----------------------------------------
-- Spell: Dextrous Etude
-- Static DEX Boost, BRD 32
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
    if skill <= 181 then
        power = 3
    elseif skill >= 182 and skill <= 235 then
        power = 4
    elseif skill >= 236 and skill <= 288 then
        power = 5
    elseif skill >= 289 and skill <= 342 then
        power = 6
    elseif skill >= 343 and skill <= 396 then
        power = 7
    elseif skill >= 397 and skill <= 449 then
        power = 8
    elseif skill >= 450 then
        power = 9
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

    if not target:addBardSong(caster, tpz.effect.ETUDE, power, 0, duration, caster:getID(), tpz.mod.DEX, 1) then
        spell:setMsg(tpz.msg.basic.MAGIC_NO_EFFECT)
    end

    return tpz.effect.ETUDE
end
