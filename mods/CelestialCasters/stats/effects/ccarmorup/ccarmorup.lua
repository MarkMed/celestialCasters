
function update(dt)
    mcontroller.controlModifiers({
        airJumpModifier = 0.9
    })
end

function init()
    animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
    animator.setParticleEmitterActive("drips", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=e0e0e0=0.2"))
    
    -- status.setResource("energyRegenBlock", 1.0) -- prevents energy regen

    effect.addStatModifierGroup({
        {
            stat = "jumpModifier",
            amount = -0.1
        },
        {
            stat = "protection",
            amount = config.getParameter("extraArmorAmount", 10) -- 10 default extra armor?
        }
        -- effect.addStatModifierGroup({{stat = "fireResistance", amount = 0.25}, {stat = "fireStatusImmunity", amount = 1}})
    })
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
