require "/stats/effects/basicStatusEffects.lua"
function init()
	self.isInstant = config.getParameter("isInstant", false)
	animator.setParticleEmitterOffsetRegion("cchealing", mcontroller.boundBox())
	animator.setParticleEmitterEmissionRate("cchealing", config.getParameter("emissionRate", 3))
	animator.setParticleEmitterActive("cchealing", true)
    effect.setParentDirectives("fade=FFFFFF=0.1")
  
	script.setUpdateDelta(5)
	
	BasicStatusEffects.Healing.init(config, status)
  end
  
  function update(dt)
	BasicStatusEffects.Healing.update(dt, status)
  end
  
  function uninit()
	
  end