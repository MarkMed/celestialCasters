function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives(config.getParameter("colorWrap", "fade=00BBFF=0.15"))
  effect.addStatModifierGroup({
    
    {
      stat = "jumpModifier",
      amount = config.getParameter("jumpModifier", -0.15)
    }
  })
end

function update(dt)
  mcontroller.controlModifiers({
        groundMovementModifier = config.getParameter("groundMovementModifier", 0.3),
        speedModifier = config.getParameter("speedModifier", 0.75),
        airJumpModifier = config.getParameter("airJumpModifier", 0.85)
    })
end

function uninit()

end
