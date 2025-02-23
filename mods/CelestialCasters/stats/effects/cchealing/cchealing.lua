function init()
	self.isInstant = config.getParameter("isInstant", false)
	animator.setParticleEmitterOffsetRegion("cchealing", mcontroller.boundBox())
	animator.setParticleEmitterEmissionRate("cchealing", config.getParameter("emissionRate", 3))
	animator.setParticleEmitterActive("cchealing", true)
    effect.setParentDirectives("fade=FFFFFF=0.1")
  
	script.setUpdateDelta(5)
  	self.currentHealth = status.resource("health")
	self.maxHealth = status.resourceMax("health")
	self.healthPercentage = self.maxHealth / 100 --eg: 340 hp -> 1% = 3.4 -> healing 20% will heal 68 hp
	self.healAmount = config.getParameter("healAmount", 30)
	if self.isInstant then
		addHealt(self.healAmount)
	else
		self.healingRate = (self.healthPercentage * self.healAmount) / effect.duration()
	end
  end
  
  function update(dt)
	if not self.isInstant then
		addHealt(self.healingRate * dt)
	end
  end
  
  function uninit()
	
  end

  function addHealt(healAmount)
	status.modifyResource("health", healAmount)
  end
  