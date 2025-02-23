
function update(dt)
    -- mcontroller.controlModifiers({
    --     airJumpModifier = 0.9
    -- })
end

function init()
    animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
    animator.setParticleEmitterActive("drips", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=e0e0e0=0.2"))
    
    -- status.setResource("energyRegenBlock", 1.0) -- prevents energy regen
    self.armorAmount = config.getParameter("extraArmorAmount", 10)
    self.jumpModifier = config.getParameter("jumpModifier", -0.1)
    modifyArmor(self.armorAmount, self.jumpModifier)
end

function uninit()
    -- if genericStatHandler then
    -- 	effect.removeStatModifierGroup(genericStatHandler)
    -- else
    -- 	sb.logInfo("genericStatFxApplier.lua:uninit()::%s::%s",entity.entityType(),status.activeUniqueStatusEffectSummary())
    -- end
    -- genericStatHandler=nil
    -- if oldUninitStatApplier then oldUninitStatApplier() end
end

function modifyArmor(armorAmount, jumpModifier)
    effect.addStatModifierGroup({
        {
            stat = "jumpModifier",
            amount = jumpModifier
        },
        {
            stat = "protection",
            amount = armorAmount
        }
    })
end
