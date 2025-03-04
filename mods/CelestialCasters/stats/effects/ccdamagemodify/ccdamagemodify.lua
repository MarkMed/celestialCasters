require "/stats/effects/basicStatusEffects.lua"
function init()

  local enableParticles = config.getParameter("particles", true)
  animator.setParticleEmitterOffsetRegion("embers", mcontroller.boundBox())
  animator.setParticleEmitterActive("embers", enableParticles)

  BasicStatusEffects.DamageModify.init(config)
end


function update(dt)
  
end

function uninit()

end
