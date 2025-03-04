BasicStatusEffects = {}

-- Healing
BasicStatusEffects.Healing = {
    isInstant = false,
    healAmount = 30,
    healingRate = 0
}
function BasicStatusEffects.Healing.init(config)
    BasicStatusEffects.Healing.isInstant = config.getParameter("isInstant", false)
    BasicStatusEffects.Healing.healAmount = config.getParameter("healAmount", 30)
    if BasicStatusEffects.Healing.isInstant then
        BasicStatusEffects.Healing.addHealth(BasicStatusEffects.Healing.healAmount)
    else
        local maxHealth = status.resourceMax("health")
        local healthPercentage = maxHealth / 100 -- eg: 340 hp -> 1% = 3.4 -> healing 20% will heal 68 hp
        BasicStatusEffects.Healing.healingRate = (healthPercentage * BasicStatusEffects.Healing.healAmount) /
                                                     (effect.duration() or 1)
    end
end
function BasicStatusEffects.Healing.update(dt)
    if not BasicStatusEffects.Healing.isInstant then
        BasicStatusEffects.Healing.addHealth(BasicStatusEffects.Healing.healingRate * dt)
    end
end
function BasicStatusEffects.Healing.addHealth(healAmount)
    status.modifyResource("health", healAmount)
end

-- EnergyRegen
BasicStatusEffects.EnergyRegen = {
    energyRegenAmount = 0, -- can be in specific amount or in percentage
    isInstantER = false, -- if true, will instantly replenish energy, if false, will regen energy over time
    allowsPassiveRegen = false, -- if true, will allow passive energy regen even in CD or shooting
    energyRegenRate = 0 -- only for non-instant ER, the amount of energy to regen per second
}
function BasicStatusEffects.EnergyRegen.init(config)
    BasicStatusEffects.EnergyRegen.energyRegenAmount = config.getParameter("energyRegenAmount", 0)
    if not BasicStatusEffects.EnergyRegen.energyRegenAmount == 0 then
        BasicStatusEffects.EnergyRegen.isInstantER = config.getParameter("isInstantER", false)
        BasicStatusEffects.EnergyRegen.allowsPassiveRegen = config.getParameter("allowsPassiveRegen", false)

        if BasicStatusEffects.EnergyRegen.isInstantER then
            -- BasicStatusEffects.Healing.addHealth(-BasicStatusEffects.EnergyRegen.energyRegenAmount) sacrifices health to replenish same amount in energy
            BasicStatusEffects.EnergyRegen.addEnergy(BasicStatusEffects.EnergyRegen.energyRegenAmount)
        else
            local maxEnergy = status.resourceMax("energy")
            local energyPercentage = maxEnergy / 100 -- eg: 340 energy -> 1% = 3.4 -> regen 20% will regen 68 energy
            BasicStatusEffects.EnergyRegen.energyRegenRate = (energyPercentage *
                                                                 BasicStatusEffects.EnergyRegen.energyRegenAmount) /
                                                                 (effect.duration() or 1)
        end

    end
end
function BasicStatusEffects.EnergyRegen.update(dt)
    if (not BasicStatusEffects.EnergyRegen.energyRegenAmount == 0) and (not BasicStatusEffects.EnergyRegen.isInstantER) then
        BasicStatusEffects.EnergyRegen.addEnergy(BasicStatusEffects.EnergyRegen.energyRegenRate * dt)
    end
end
function BasicStatusEffects.EnergyRegen.addEnergy(energyRegen)

    -- removes the energy regen block time, allowing the player to regen energy even in CD or shooting
    if BasicStatusEffects.EnergyRegen.allowsPassiveRegen then
        effect.addStatModifierGroup({{
            stat = "energyRegenBlockTime",
            effectiveMultiplier = 0
        }})
    end
    status.modifyResource("energy", energyRegen)
end

-- Armor Modify
BasicStatusEffects.ArmorModify = {
    -- armorAmount = 1 -- percentage multiplier -> 0.5 = 50% armor, 2 = 200% armor, -2 = -200% armor
    armorAmount = 0
}
function BasicStatusEffects.ArmorModify.init(config)
    BasicStatusEffects.ArmorModify.armorAmount = config.getParameter("armorAmount", 0)
    BasicStatusEffects.ArmorModify.modifyArmor(BasicStatusEffects.ArmorModify.armorAmount)
end
function BasicStatusEffects.ArmorModify.modifyArmor(armorAmount)
    effect.addStatModifierGroup({{
        stat = "protection",
        -- effectiveMultiplier = armorAmount -- error while using amount with negative values lower than -205 wtf
        amount = armorAmount
    }})
end

-- Movement Speed Modify
BasicStatusEffects.MovementSpeedModify = {
    groundMovementModifier = 1, -- 0.5 = 50% speed, 2 = 200% speed
    speedModifier = 1, -- 0.5 = 50% speed, 2 = 200% speed
    airJumpModifier = 1 -- 0.5 = 50% speed, 2 = 200% speed
}
function BasicStatusEffects.MovementSpeedModify.init(config)
    BasicStatusEffects.MovementSpeedModify.groundMovementModifier = config.getParameter("groundMovementModifier", 1)
    BasicStatusEffects.MovementSpeedModify.speedModifier = config.getParameter("speedModifier", 1)
    BasicStatusEffects.MovementSpeedModify.airJumpModifier = config.getParameter("airJumpModifier", 1)
end
function BasicStatusEffects.MovementSpeedModify.update(dt)
    mcontroller.controlModifiers({
        groundMovementModifier = BasicStatusEffects.MovementSpeedModify.groundMovementModifier,
        speedModifier = BasicStatusEffects.MovementSpeedModify.speedModifier,
        airJumpModifier = BasicStatusEffects.MovementSpeedModify.airJumpModifier
    })
end

-- Jump Modify
BasicStatusEffects.JumpModify = {
    jumpModifier = 1 -- 0.5 = 50% jump, 2 = 200% jump
}
function BasicStatusEffects.JumpModify.init(config)
    BasicStatusEffects.JumpModify.jumpModifier = config.getParameter("jumpModifier", 1)
    effect.addStatModifierGroup({{
        stat = "jumpModifier",
        amount = BasicStatusEffects.JumpModify.jumpModifier
    }})
end

-- Damage Modify
BasicStatusEffects.DamageModify = {
    damageModifier = 1 -- n power multiplier -> -0.5 = -50% damage, 1 = +100% damage, 0.5 = +50% damage, 2 = +200% damage
}
function BasicStatusEffects.DamageModify.init(config)
    BasicStatusEffects.DamageModify.damageModifier = config.getParameter("damageModifier", 1)
    effect.addStatModifierGroup({{
        stat = "powerMultiplier",
        amount = BasicStatusEffects.DamageModify.damageModifier
    }})
end

-- Damage per tick
BasicStatusEffects.DamagePerTick = {
    tickDamage = 0,
    tickTime = 1,
    tickTimer = 0,
    damageSourceKind = "fire"
}
function BasicStatusEffects.DamagePerTick.init(config)
    BasicStatusEffects.DamagePerTick.tickDamage = config.getParameter("tickDamage", 0) -- damage amount per tick to apply directly to the target
    BasicStatusEffects.DamagePerTick.tickTime = config.getParameter("tickTime", 1) -- number of seconds between ticks -> 1 = 1 tick per second, 0.5 = 2 ticks per second
    BasicStatusEffects.DamagePerTick.tickTimer = BasicStatusEffects.DamagePerTick.tickTime
    BasicStatusEffects.DamagePerTick.damageSourceKind = config.getParameter("damageSourceKind", "fire") -- get the damage source kind from the config or "fire" by default
end
function BasicStatusEffects.DamagePerTick.update(dt)
    BasicStatusEffects.DamagePerTick.tickTimer = BasicStatusEffects.DamagePerTick.tickTimer - dt
    if BasicStatusEffects.DamagePerTick.tickTimer <= 0 then
        BasicStatusEffects.DamagePerTick.tickTimer = BasicStatusEffects.DamagePerTick.tickTime
        status.applySelfDamageRequest({
            damageType = "IgnoresDef",
            damage = BasicStatusEffects.DamagePerTick.tickDamage,
            damageSourceKind = BasicStatusEffects.DamagePerTick.damageSourceKind,
            sourceEntityId = entity.id()
        })
    end
end
