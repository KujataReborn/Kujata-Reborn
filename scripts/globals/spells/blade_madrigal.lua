-----------------------------------------
-- Spell: Blade Madrigal
-- Increases accuracy for party members within the area of effect.
-----------------------------------------
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------------

function onMagicCastingCheck(caster,target,spell)
    return 0
end

function onSpellCast(caster,target,spell)
    local sLvl = caster:getSkillLevel(tpz.skill.SINGING) -- Gets skill level of Singing
    local iLvl = caster:getWeaponSkillLevel(tpz.slot.RANGED)

    local power = 20
    if sLvl + iLvl > 340 then
        power = power + math.floor((sLvl + iLvl - 320) / 18)
    end
    power = math.min(power,30) -- Cap before bonuses

    local iBoost = caster:getMod(tpz.mod.MADRIGAL_EFFECT) + caster:getMod(tpz.mod.ALL_SONGS_EFFECT)
    if iBoost > 0 then
        power = power + 1 + (iBoost - 1) * 3
    end

    power =  power + caster:getMerit(tpz.merit.MADRIGAL_EFFECT)

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

    if not target:addBardSong(caster, tpz.effect.MADRIGAL, power, 0, duration, caster:getID(), 0, 2) then
        spell:setMsg(tpz.msg.basic.MAGIC_NO_EFFECT)
    end

    return tpz.effect.MADRIGAL
end
