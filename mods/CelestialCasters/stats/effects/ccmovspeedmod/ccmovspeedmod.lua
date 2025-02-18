function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives(config.getParameter("colorWrap", "fade=00BBFF=0.15"))
  effect.addStatModifierGroup({
    
    {
      stat = "jumpModifier",
      amount = config.getParameter("jumpModifier", 1)
    }
  })
end

function update(dt)
  mcontroller.controlModifiers({
        groundMovementModifier = config.getParameter("groundMovementModifier", 1),
        speedModifier = config.getParameter("speedModifier", 1),
        airJumpModifier = config.getParameter("airJumpModifier", 1)
    })
end

function uninit()

end
