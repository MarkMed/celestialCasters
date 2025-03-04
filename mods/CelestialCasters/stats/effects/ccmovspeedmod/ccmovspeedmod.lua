require "/stats/effects/basicStatusEffects.lua"

function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives(config.getParameter("colorWrap", "fade=00BBFF=0.15"))
  BasicStatusEffects.MovementSpeedModify.init(config)
end

function update(dt)
  BasicStatusEffects.MovementSpeedModify.update(dt)
end

function uninit()

end
