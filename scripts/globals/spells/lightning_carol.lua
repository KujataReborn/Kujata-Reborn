-----------------------------------------
-- Spell: Lightning Carol
-- Increases lightning resistance for party members within the area of effect.
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

    local power = 20
    if skill > 200 then
        power = power + math.floor((skill - 200) / 10)
    end
    power = math.min(power,40)

    local iBoost = caster:getMod(tpz.mod.CAROL_EFFECT) + caster:getMod(tpz.mod.ALL_SONGS_EFFECT)
    power = power + iBoost * 5

    if caster:hasStatusEffect(tpz.effect.SOUL_VOICE) then
        power = power * 2
    -- elseif (caster:hasStatusEffect(tpz.effect.MARCATO)) then
        -- power = power * 1.5
        -- caster:delStatusEffect(tpz.effect.MARCATO)
    end

    local duration = 120
    duration = duration * ((iBoost * 0.1) + (caster:getMod(tpz.mod.SONG_DURATION_BONUS) / 100) + 1)

    if caster:hasStatusEffect(tpz.effect.TROUBADOUR) then
        duration = duration * 2
    end

    if not target:addBardSong(caster, tpz.effect.CAROL, power, 0, duration, caster:getID(), tpz.magic.ele.LIGHTNING, 1) then
        spell:setMsg(tpz.msg.basic.MAGIC_NO_EFFECT)
    end

    return tpz.effect.CAROL
end
