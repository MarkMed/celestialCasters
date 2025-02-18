function init()
    animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
    animator.setParticleEmitterActive("drips", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=33FF33=0.1"))

    script.setUpdateDelta(5)
    -- Extraer valores desde el archivo JSON (o usar valores por defecto)
    self.tickDamagePercentage = config.getParameter("tickDamagePercentage", 0.025) -- Daño por tick
    self.tickTime = config.getParameter("tickTime", 1.0) -- Intervalo entre ticks
    self.healing = config.getParameter("healing", 1) -- Healing per tick

    self.tickTimer = self.tickTime
end

function update(dt)
    -- Si el efecto de estado sigue activo y el jugador toca agua, se apaga
    -- if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
    --     effect.expire()
    -- end

    self.tickTimer = self.tickTimer - dt
    
    if self.healing > 0 then
      status.modifyResourcePercentage("health", self.healing * dt)
    else
      if self.tickTimer <= 0 then
        self.tickTimer = self.tickTime
        status.applySelfDamageRequest({
            damageType = "IgnoresDef",
            damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
            damageSourceKind = "poison",
            sourceEntityId = entity.id()
        })
      end
    end

    -- effect.setParentDirectives(string.format("fade=00AA00=%.1f", self.tickTimer * 0.4))
end

function uninit()

end
