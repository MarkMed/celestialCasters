require "/stats/effects/basicStatusEffects.lua"

function init()
    animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
    animator.setParticleEmitterActive("icetrail", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=00BBFF=0.15"))

    script.setUpdateDelta(5)
    
    BasicStatusEffects.DamagePerTick.init(config)
    BasicStatusEffects.MovementSpeedModify.init(config)
    BasicStatusEffects.JumpModify.init(config)
    BasicStatusEffects.ArmorModify.init(config)
end

function update(dt)
    BasicStatusEffects.MovementSpeedModify.update(dt)
    BasicStatusEffects.DamagePerTick.update(dt)
end

function uninit()

end
