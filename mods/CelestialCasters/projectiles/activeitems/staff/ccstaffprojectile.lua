require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()

    self.controlMovement = config.getParameter("controlMovement")
    self.controlRotation = config.getParameter("controlRotation")
    self.rotationSpeed = 0
    self.timedActions = config.getParameter("timedActions", {})

    -- Obtener efectos desde la configuración del proyectil
    self.statusEffectsAlly = config.getParameter("statusEffectsAlly", {})
    self.statusEffectsEnemy = config.getParameter("statusEffectsEnemy", {})

    self.aimPosition = mcontroller.position()

    message.setHandler("updateProjectile", function(_, _, aimPosition)
        self.aimPosition = aimPosition
        return entity.id()
    end)

    message.setHandler("kill", function()
        projectile.die()
    end)
end

function update(dt)
    if self.aimPosition then
        if self.controlMovement then
            controlTo(self.aimPosition)
        end

        if self.controlRotation then
            rotateTo(self.aimPosition, dt)
        end

        for _, action in pairs(self.timedActions) do
            processTimedAction(action, dt)
        end
    end

    applyEffects()
end

function control(direction)
    mcontroller.approachVelocity(vec2.mul(vec2.norm(direction), self.controlMovement.maxSpeed),
        self.controlMovement.controlForce)
end

function controlTo(position)
    local offset = world.distance(position, mcontroller.position())
    mcontroller.approachVelocity(vec2.mul(vec2.norm(offset), self.controlMovement.maxSpeed),
        self.controlMovement.controlForce)
end

function rotateTo(position, dt)
    local vectorTo = world.distance(position, mcontroller.position())
    local angleTo = vec2.angle(vectorTo)
    if self.controlRotation.maxSpeed then
        local currentRotation = mcontroller.rotation()
        local angleDiff = util.angleDiff(currentRotation, angleTo)
        local diffSign = angleDiff > 0 and 1 or -1

        local targetSpeed = math.max(0.1, math.min(1, math.abs(angleDiff) / 0.5)) * self.controlRotation.maxSpeed
        local acceleration = diffSign * self.controlRotation.controlForce * dt
        self.rotationSpeed = math.max(-targetSpeed, math.min(targetSpeed, self.rotationSpeed + acceleration))
        self.rotationSpeed = self.rotationSpeed - self.rotationSpeed * self.controlRotation.friction * dt

        mcontroller.setRotation(currentRotation + self.rotationSpeed * dt)
    else
        mcontroller.setRotation(angleTo)
    end
end

function processTimedAction(action, dt)
    if action.complete then
        return
    elseif action.delayTime then
        action.delayTime = action.delayTime - dt
        if action.delayTime <= 0 then
            action.delayTime = nil
        end
    elseif action.loopTime then
        action.loopTimer = action.loopTimer or 0
        action.loopTimer = math.max(0, action.loopTimer - dt)
        if action.loopTimer == 0 then
            projectile.processAction(action)
            action.loopTimer = action.loopTime
            if action.loopTimeVariance then
                action.loopTimer = action.loopTimer + (2 * math.random() - 1) * action.loopTimeVariance
            end
        end
    else
        projectile.processAction(action)
        action.complete = true
    end
end
function applyEffects()
    --   local nearbyEntities = world.entityQuery(mcontroller.position(), 1.0, {
    --     withoutEntityId = entity.id(),
    --     includedTypes = {"npc", "player", "monster"}
    --   })

    --   for _, entityId in ipairs(nearbyEntities) do
    --     -- if world.entityCanDamage(entity.id(), entityId) then
    --       if self.damageAmount > 0 then
    --         world.sendEntityMessage(entityId, "applyStatusEffect", "damage", self.damageAmount, entity.id())
    --       end
    --       for _, debuffToApply in ipairs(self.statusEffectsEnemy) do
    --         world.sendEntityMessage(entityId, "applyStatusEffect", debuffToApply.effect, debuffToApply.duration, entity.id())
    --       end
    --     -- else
    --       for _, buffToApply in ipairs(self.statusEffectsAlly) do
    --         world.sendEntityMessage(entityId, "applyStatusEffect", buffToApply.effect, buffToApply.duration, entity.id())
    --       end
    --     -- end
    --   end
    local nearbyEntities = world.entityQuery(mcontroller.position(), 0.5, {
        withoutEntityId = entity.id(),
        includedTypes = {"creature"}
    })

    for _, entityId in ipairs(nearbyEntities) do
        -- Verificar si la entidad es un NPC aliado???
		-- world.entityCanDamage(attackerId, targetId)
		-- world.entityCanDamage(entityId, entity.id())

        if world.entityCanDamage(entityId, entity.id())
		-- projectile damageTeam == friendly => entityCanDamage detectará a los enemigos automáticamente
		then
            -- a los que puede dañar, aplicar cada statusEffect definido en statusEffectsEnemy
			applyEnemyEffects(entityId)
        else
			-- si projectile NO puede dañar al objetivo, es porque no es enemigo
			-- Aplicar cada efecto de estado definido en statusEffectsAlly
            applyAllyEffects(entityId)
        end
		if(config.getParameter("bounces") == 0)
		then
			projectile.die()
		end    
    end
end

function applyEnemyEffects(entityId)
    for _, debuffToApply in ipairs(self.statusEffectsEnemy) do
        local duration = debuffToApply.duration or config.getParameter("defaultDuration", 5)
        world.sendEntityMessage(entityId, "applyStatusEffect", debuffToApply.effect, duration, entity.id())
    end
end

function applyAllyEffects(entityId)
    for _, buffToApply in ipairs(self.statusEffectsAlly) do
        local duration = buffToApply.duration or config.getParameter("defaultDuration", 5)
        world.sendEntityMessage(entityId, "applyStatusEffect", buffToApply.effect, duration, entity.id())
    end
end
