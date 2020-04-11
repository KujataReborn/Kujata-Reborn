-----------------------------------
-- Ability: Earth Shot
-- Consumes a Earth Card to enhance earth-based debuffs. Deals earth-based magic damage
-- Rasp Effect: Enhanced DoT and DEX-, Slow Effect +10%
-----------------------------------
require("scripts/globals/ability")
require("scripts/globals/magic")
require("scripts/globals/status")
-----------------------------------

function onAbilityCheck(player, target, ability)
    if player:getWeaponSkillType(tpz.slot.RANGED) ~= tpz.skill.MARKSMANSHIP or player:getWeaponSkillType(tpz.slot.AMMO) ~= tpz.skill.MARKSMANSHIP then
        return 216, 0 -- You do not have an appropriate ranged weapon equipped.
    end

    if player:hasItem(2179, 0) then -- Earth Card
        return 0, 0
    else
        return 71, 0 -- <name> cannot perform that action.
    end
end

function onUseAbility(player, target, ability, action)
    local params = {}
    params.includemab = true
    local dmg = (2 * (player:getRangedDmg() + player:getAmmoDmg()) + player:getMod(tpz.mod.QUICK_DRAW_DMG)) * (1 + player:getMod(tpz.mod.QUICK_DRAW_DMG_PERCENT) / 100)
    dmg  = addBonusesAbility(player, tpz.magic.ele.EARTH, target, dmg, params)
    local bonusAcc = player:getStat(tpz.mod.AGI) / 2 + player:getMerit(tpz.merit.QUICK_DRAW_ACCURACY) + player:getMod(tpz.mod.QUICK_DRAW_MACC)
    dmg = dmg * applyResistanceAbility(player, target, tpz.magic.ele.EARTH, tpz.skill.NONE, bonusAcc)
    dmg = adjustForTarget(target, dmg, tpz.magic.ele.EARTH)

    params.targetTPMult = 0 -- Quick Draw does not feed TP
    dmg = takeAbilityDamage(target, player, params, true, dmg, tpz.attackType.MAGICAL, tpz.damageType.EARTH, tpz.slot.RANGED, 1, 0, 0, 0, action, nil)

    if dmg > 0 then
        local effects = {}

        local rasp = target:getStatusEffect(tpz.effect.RASP)
        if rasp ~= nil then
            table.insert(effects, rasp)
        end

        local slow = target:getStatusEffect(tpz.effect.SLOW)
        if slow ~= nil then
            table.insert(effects, slow)
        end

        local threnody = target:getStatusEffect(tpz.effect.THRENODY)
        if threnody ~= nil and threnody:getSubPower() == tpz.mod.THUNDERRES then
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

            if effectId == tpz.effect.RASP then
                power = math.floor(power * 1.2)
            elseif effectId == tpz.effect.SLOW then
                power = math.floor(power * 1.1)
            elseif effectId == tpz.effect.THRENODY then
                power = math.floor(power * 1.5)
            end

            target:delStatusEffectSilent(effectId)
            target:addStatusEffect(effectId, power, tick, duration, subId, subpower, tier)

            local newEffect = target:getStatusEffect(effectId)
            newEffect:setStartTime(startTime)
        end
    end

    target:updateClaim(player)

    player:delItem(2179, 1) -- Earth Card

    return dmg
end
