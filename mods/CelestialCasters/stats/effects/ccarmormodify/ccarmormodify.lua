require "/stats/effects/basicStatusEffects.lua"

function init()
    animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
    animator.setParticleEmitterActive("drips", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=e0e0e0=0.2"))
    
    BasicStatusEffects.ArmorModify.init(config)
    BasicStatusEffects.MovementSpeedModify.init(config)
    BasicStatusEffects.JumpModify.init(config)
end

function update(dt)
    BasicStatusEffects.MovementSpeedModify.update(dt)
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
