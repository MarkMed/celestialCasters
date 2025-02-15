function init()
    -- Configurar animación de llamas y efecto visual
    animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
    animator.setParticleEmitterActive("flames", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=BF3300=0.25"))
    animator.playSound("burn", -1)

    script.setUpdateDelta(5)
    -- Extraer valores desde el archivo JSON (o usar valores por defecto)
    self.tickDamagePercentage = config.getParameter("tickDamagePercentage", 0.025) -- Daño por tick
    self.tickTime = config.getParameter("tickTime", 1.0) -- Intervalo entre ticks
    -- Inicializar temporizador de daño
    self.tickTimer = self.tickTime

end

function update(dt)

    -- Si el efecto de estado sigue activo y el jugador toca agua, se apaga
    if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
        effect.expire()
    end

    -- Aplicar daño en intervalos de `tickTime`
    self.tickTimer = self.tickTimer - dt
    if self.tickTimer <= 0 then
        self.tickTimer = self.tickTime
        status.applySelfDamageRequest({
            damageType = "IgnoresDef",
            damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
            damageSourceKind = "fire",
            sourceEntityId = entity.id()
        })
    end
end

function uninit()
  -- Apagar sonido de quemado al finalizar el efecto
  animator.stopAllSounds("burn")

end
