require "/stats/effects/basicStatusEffects.lua"
function init()
    animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
    animator.setParticleEmitterActive("drips", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=33FF33=0.1"))

    script.setUpdateDelta(5)
    -- Extraer valores desde el archivo JSON (o usar valores por defecto)
    
    
    BasicStatusEffects.DamagePerTick.init(config)
    BasicStatusEffects.Healing.init(config)

    self.tickTimer = self.tickTime
end

function update(dt)
    
    BasicStatusEffects.DamagePerTick.update(dt)
    BasicStatusEffects.Healing.update(dt)

    -- effect.setParentDirectives(string.format("fade=00AA00=%.1f", self.tickTimer * 0.4))
end

function uninit()

end
