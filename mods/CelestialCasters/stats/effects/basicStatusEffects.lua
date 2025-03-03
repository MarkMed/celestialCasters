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
        local healthPercentage = maxHealth / 100 --eg: 340 hp -> 1% = 3.4 -> healing 20% will heal 68 hp
        BasicStatusEffects.Healing.healingRate = (healthPercentage * BasicStatusEffects.Healing.healAmount)/(effect.duration() or 1)
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

-- Armor Modify
BasicStatusEffects.ArmorModify = {
    armorAmount = 0
}
function BasicStatusEffects.ArmorModify.init(config)
    BasicStatusEffects.ArmorModify.armorAmount = config.getParameter("armorAmount", 0)
    BasicStatusEffects.ArmorModify.modifyArmor(BasicStatusEffects.ArmorModify.armorAmount)
end
function BasicStatusEffects.ArmorModify.modifyArmor(armorAmount)
    effect.addStatModifierGroup({{
        stat = "protection",
        amount = armorAmount
    }})
end

-- Movement Speed Modify
BasicStatusEffects.MovementSpeedModify = {
    groundMovementModifier = 1,
    speedModifier = 1,
    airJumpModifier = 1,
    jumpModifier = 1
}
function BasicStatusEffects.MovementSpeedModify.init(config)
    BasicStatusEffects.MovementSpeedModify.groundMovementModifier = config.getParameter("groundMovementModifier", 1)
    BasicStatusEffects.MovementSpeedModify.speedModifier = config.getParameter("speedModifier", 1)
    BasicStatusEffects.MovementSpeedModify.airJumpModifier = config.getParameter("airJumpModifier", 1)
    BasicStatusEffects.MovementSpeedModify.jumpModifier = config.getParameter("jumpModifier", 1)
    effect.addStatModifierGroup({
        {
          stat = "jumpModifier",
          amount = BasicStatusEffects.MovementSpeedModify.jumpModifier
        }
      })
end
function BasicStatusEffects.MovementSpeedModify.update(dt)
    mcontroller.controlModifiers({
        groundMovementModifier = BasicStatusEffects.MovementSpeedModify.groundMovementModifier,
        speedModifier = BasicStatusEffects.MovementSpeedModify.speedModifier,
        airJumpModifier = BasicStatusEffects.MovementSpeedModify.airJumpModifier
    })
end
