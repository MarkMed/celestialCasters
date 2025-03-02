BasicStatusEffects = {}

-- Healing
BasicStatusEffects.Healing = {
    isInstant = false,
    healAmount = 30,
    healingRate = 0
}
function BasicStatusEffects.Healing.init(config, currentStatus)
    BasicStatusEffects.Healing.isInstant = config.getParameter("isInstant", false)
    BasicStatusEffects.Healing.healAmount = config.getParameter("healAmount", 30)
    if BasicStatusEffects.Healing.isInstant then
        BasicStatusEffects.Healing.addHealth(BasicStatusEffects.Healing.healAmount, currentStatus)
    else
        local maxHealth = currentStatus.resourceMax("health")
        local healthPercentage = maxHealth / 100
        BasicStatusEffects.Healing.healingRate = (healthPercentage * BasicStatusEffects.Healing.healAmount)/(effect.duration() or 1)
    end
end
function BasicStatusEffects.Healing.update(dt, currentStatus)
    if not BasicStatusEffects.Healing.isInstant then
        BasicStatusEffects.Healing.addHealth(BasicStatusEffects.Healing.healingRate * dt, currentStatus)
    end
end
function BasicStatusEffects.Healing.addHealth(healAmount, currentStatus)
    currentStatus.modifyResource("health", healAmount)
end

-- Armor Modify
BasicStatusEffects.ArmorModify = {
    armorAmount = 10
}
function BasicStatusEffects.ArmorModify.init(config)
    BasicStatusEffects.ArmorModify.armorAmount = config.getParameter("armorAmount", 10)
    BasicStatusEffects.ArmorModify.modifyArmor(BasicStatusEffects.ArmorModify.armorAmount)
end
function BasicStatusEffects.ArmorModify.modifyArmor(armorAmount)
    effect.addStatModifierGroup({{
        stat = "protection",
        amount = armorAmount
    }})
end
