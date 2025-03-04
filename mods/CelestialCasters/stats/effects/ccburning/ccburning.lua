require "/stats/effects/basicStatusEffects.lua"

function init()
    -- Configurar animación de llamas y efecto visual
    animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
    animator.setParticleEmitterActive("flames", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=BF3300=0.25"))
    animator.playSound("burn", -1)

    script.setUpdateDelta(5)
    
    BasicStatusEffects.DamageModify.init(config)
    BasicStatusEffects.DamagePerTick.init(config)

end

function update(dt)

    -- Si el efecto de estado sigue activo y el jugador toca agua, se apaga
    if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
        effect.expire()
    end

   BasicStatusEffects.DamagePerTick.update(dt)
end

function uninit()
  -- Apagar sonido de quemado al finalizar el efecto
  animator.stopAllSounds("burn")

end
