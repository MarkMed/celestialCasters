function update(dt)
  mcontroller.controlModifiers({
      airJumpModifier = 0.9
    })
end
local oldInitStatApplier=init
local oldUninitStatApplier=uninit

function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=e0e0e0=0.3")
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.1}
  })
	if not genericStatHandler then
		genericStatHandler=effect.addStatModifierGroup(config.getParameter("stats",{}))
	else
		effect.setStatModifierGroup(genericStatHandler,config.getParameter("stats",{}))
	end
	if oldInitStatApplier then oldInitStatApplier() end
  
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
