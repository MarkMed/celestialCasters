function init()
    animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
    animator.setParticleEmitterActive("icetrail", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=00BBFF=0.15"))

    script.setUpdateDelta(5)
    -- Extraer valores desde el archivo JSON (o usar valores por defecto)
    self.tickDamagePercentage = config.getParameter("tickDamagePercentage", 0.025) -- Daño por tick
    self.tickTime = config.getParameter("tickTime", 1.0) -- Intervalo entre ticks
    -- Inicializar temporizador de daño
    self.tickTimer = self.tickTime

    effect.addStatModifierGroup({
      {
        stat = "jumpModifier",
        amount = config.getParameter("jumpModifier", -0.15)
      },
      {
          stat = "protection",
          amount = config.getParameter("extraArmorAmount", 0)
      }
    })
end

function update(dt)

    -- Damage per tick in X seconds
    self.tickTimer = self.tickTimer - dt
    if self.tickTimer <= 0 then
        self.tickTimer = self.tickTime
        status.applySelfDamageRequest({
            damageType = "IgnoresDef",
            damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
            damageSourceKind = "ice",
            sourceEntityId = entity.id()
        })
    end
    -- AUMENTA CON EL TIEMPO!!!!!!!
    -- effect.addStatModifierGroup({
    --   {
    --     stat = "protection",
    --     amount = config.getParameter("extraArmorAmount", 0) -- 10 default extra armor?
    --   } -- effect.addStatModifierGroup({{stat = "fireResistance", amount = 0.25}, {stat = "fireStatusImmunity", amount = 1}})
    -- })

    mcontroller.controlModifiers({
        groundMovementModifier = config.getParameter("groundMovementModifier", 0.3),
        speedModifier = config.getParameter("speedModifier", 0.75),
        airJumpModifier = config.getParameter("airJumpModifier", 0.85)
    })
end

function uninit()

end
