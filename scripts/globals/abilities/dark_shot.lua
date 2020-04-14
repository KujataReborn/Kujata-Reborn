-----------------------------------
-- Ability: Dark Shot
-- Consumes a Dark Card to enhance dark-based debuffs. Additional effect: Dark-based Dispel
-- Bio Effect: Attack Down Effect +5% and DoT + 3
-----------------------------------
require("scripts/globals/magic")
require("scripts/globals/status")
-----------------------------------

function onAbilityCheck(player, target, ability)
    if player:getWeaponSkillType(tpz.slot.RANGED) ~= tpz.skill.MARKSMANSHIP or player:getWeaponSkillType(tpz.slot.AMMO) ~= tpz.skill.MARKSMANSHIP then
        return 216, 0 -- You do not have an appropriate ranged weapon equipped.
    end

    if player:hasItem(2974, 0) then -- Dark Card
        return 0, 0
    else
        return 71, 0 -- <name> cannot perform that action.
    end
end

function onUseAbility(player, target, ability)
    local duration = 60
    local bonusAcc = player:getStat(tpz.mod.AGI) / 2 + player:getMerit(tpz.merit.QUICK_DRAW_ACCURACY) + player:getMod(tpz.mod.QUICK_DRAW_MACC)
    local resist = applyResistanceAbility(player, target, tpz.magic.ele.DARK, tpz.skill.NONE, bonusAcc)

    if resist < 0.25 then
        ability:setMsg(tpz.msg.basic.JA_MISS_2) -- resist message

        return 0
    end

    duration = duration * resist

    local effects = {}

    local bio = target:getStatusEffect(tpz.effect.BIO)
    if bio ~= nil then
        table.insert(effects, bio)
    end

    local blind = target:getStatusEffect(tpz.effect.BLINDNESS)
    if blind ~= nil then
        table.insert(effects, blind)
    end

    local threnody = target:getStatusEffect(tpz.effect.THRENODY)
    if threnody ~= nil and threnody:getSubPower() == tpz.mod.LIGHTRES then
        table.insert(effects, threnody)
    end

    if #effects > 0 then
        local effect = effects[math.random(#effects)]
        local duration = effect:getDuration()
        local startTime = effect:getStartTime()
        local tick = effect:getTick()
        local power = effect:getPower()
        local subpower = effect:getSubPower()
        local tier = effect:getTier()
        local effectId = effect:getType()
        local subId = effect:getSubType()

        if effectId == tpz.effect.BIO then
            power = power + 3 -- Damage over time
            subpower = subpower + 5 -- Attack down
            tier = tier + 1
        elseif effectId == tpz.effect.BLINDNESS then
            power = math.floor(power * 1.1)
        elseif effectId == tpz.effect.THRENODY then
            power = math.floor(power * 1.5)
        end

        target:delStatusEffectSilent(effectId)
        target:addStatusEffect(effectId, power, tick, duration, subId, subpower, tier)

        local newEffect = target:getStatusEffect(effectId)
        newEffect:setStartTime(startTime)
    end

    ability:setMsg(tpz.msg.basic.JA_REMOVE_EFFECT_2)

    local dispelledEffect = target:dispelStatusEffect()
    if dispelledEffect == tpz.effect.NONE then
        ability:setMsg(tpz.msg.basic.JA_NO_EFFECT_2)
    end

    target:updateClaim(player)

    player:delItem(2183, 1) -- Dark Card

    return dispelledEffect
end
