require "/scripts/vec2.lua"
require "/scripts/util.lua"

CloudExplosion = WeaponAbility:new()

-- Inicialización de la habilidad
function CloudExplosion:init()
	storage.projectiles = {} -- NO Almacena las referencias a los proyectiles generados
    
    self.elementalType = self.elementalType or self.weapon.elementalType -- Determina el tipo elemental de la explosión
    self.baseDamageFactor = config.getParameter("baseDamageFactor", 1.0) -- Factor de daño base configurado
    self.stances = config.getParameter("stances", self.stances) -- Obtiene las posturas de la habilidad desde la configuración
    
    activeItem.setCursor("/cursors/reticle0.cursor") -- Establece el cursor inicial
    self.weapon:setStance(self.stances.idle) -- Configura la postura inicial del arma
    
    -- Define la función a ejecutar al salir de la habilidad
    self.weapon.onLeaveAbility = function()
        self:reset()
    end
end

-- Actualización en cada frame
function CloudExplosion:update(dt, fireMode, shiftHeld)
    WeaponAbility.update(self, dt, fireMode, shiftHeld) -- Llama a la actualización base de la habilidad
    self:updateProjectiles() -- Actualiza el estado de los proyectiles existentes
    
    world.debugPoint(self:focusPosition(), "blue") -- Muestra un punto de depuración en la posición de enfoque
    
    -- Comprueba si se puede activar la habilidad
    if self.fireMode == (self.activatingFireMode or self.abilitySlot)
        and not self.weapon.currentAbility
        and not status.resourceLocked("energy") then
        
        self:setState(self.charge) -- Cambia el estado a "carga"
    end
end

-- Estado de carga de la habilidad
function CloudExplosion:charge()
    self.weapon:setStance(self.stances.charge) -- Cambia la postura del arma a "cargando"
    animator.playSound(self.elementalType.."charge") -- Reproduce sonido de carga
    animator.setAnimationState("charge", "charge") -- Cambia la animación a "cargando"
    animator.setParticleEmitterActive(self.elementalType .. "charge", true) -- Activa partículas de carga
    activeItem.setCursor("/cursors/charge2.cursor") -- Cambia el cursor de carga
    
    local chargeTimer = self.stances.charge.duration * (1+status.stat("focalCastTimeMult")) -- Calcula duración de carga
    
    while chargeTimer > 0 and self.fireMode == (self.activatingFireMode or self.abilitySlot) do
        chargeTimer = chargeTimer - self.dt
        mcontroller.controlModifiers({runningSuppressed=true}) -- Impide correr mientras se carga
        coroutine.yield()
    end
    
    animator.stopAllSounds(self.elementalType.."charge") -- Detiene sonido de carga
    
    if chargeTimer <= 0 then
        self:setState(self.charged) -- Si la carga completa, pasa a "cargado"
    else
        animator.playSound(self.elementalType.."discharge") -- Si se cancela, reproduce sonido de descarga
        self:setState(self.cooldown) -- Pasa a estado de enfriamiento
    end
end

-- Estado de habilidad completamente cargada
function CloudExplosion:charged()
    self.weapon:setStance(self.stances.charged)
    animator.playSound(self.elementalType.."fullcharge")
    animator.playSound(self.elementalType.."chargedloop", -1)
    animator.setParticleEmitterActive(self.elementalType .. "charge", true)
    
    local targetValid
    while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
        targetValid = self:targetValid(activeItem.ownerAimPosition()) -- Valida el objetivo
        activeItem.setCursor(targetValid and "/cursors/chargeready.cursor" or "/cursors/chargeinvalid.cursor")
        mcontroller.controlModifiers({runningSuppressed=true})
        coroutine.yield()
    end
    
    self:setState(self.discharge) -- Cambia a estado de disparo
end

-- Estado de disparo de la habilidad
function CloudExplosion:discharge()
    self.weapon:setStance(self.stances.discharge)
    activeItem.setCursor("/cursors/reticle0.cursor")
    
    -- Si el objetivo es válido y se tiene energía suficiente, se dispara la explosión
    if self:targetValid(activeItem.ownerAimPosition()) and status.overConsumeResource("energy", self.energyCost * self.baseDamageFactor) then
        animator.playSound(self.elementalType.."activate")
        self:createProjectiles()
    else
        animator.playSound(self.elementalType.."discharge")
        self:setState(self.cooldown)
        return
    end
    
    util.wait(self.stances.discharge.duration, function(dt)
        status.setResourcePercentage("energyRegenBlock", 1.0) -- Bloquea la regeneración de energía por un momento
    end)
    
    while #storage.projectiles > 0 do
        if self.fireMode == (self.activatingFireMode or self.abilitySlot) and self.lastFireMode ~= self.fireMode then
            self:killProjectiles() -- Si se vuelve a activar, destruye los proyectiles activos
        end
        self.lastFireMode = self.fireMode
        coroutine.yield()
    end
    
    animator.stopAllSounds(self.elementalType.."chargedloop")
    self:setState(self.cooldown)
end

-- Estado de enfriamiento después del disparo
function CloudExplosion:cooldown()
    self.weapon:setStance(self.stances.cooldown)
    animator.setAnimationState("charge", "discharge")
    animator.setParticleEmitterActive(self.elementalType .. "charge", false)
    activeItem.setCursor("/cursors/reticle0.cursor")
    
    util.wait(self.stances.cooldown.duration, function() end)
end

-- Valida si el objetivo está dentro del rango permitido
function CloudExplosion:targetValid(aimPos)
    local focusPos = self:focusPosition()
    return world.magnitude(focusPos, aimPos) <= (self.maxCastRange*(1+status.stat("focalRangeMult")))
        and not world.lineTileCollision(mcontroller.position(), focusPos)
        and not world.lineTileCollision(focusPos, aimPos)
end

-- Crea los proyectiles de la explosión de gas
function CloudExplosion:createProjectiles()
	local aimPosition = activeItem.ownerAimPosition()
	local fireDirection = world.distance(aimPosition, self:focusPosition())[1] > 0 and 1 or -1
	local pOffset = {fireDirection * (self.projectileDistance or 0), 0}
	local basePos = activeItem.ownerAimPosition()

	local pCount = self.projectileCount or 1
	-- bonus projectiles
	local bonus=status.stat("focalProjectileCountBonus")
	local flooredBonus=math.floor(bonus)
	if bonus~=flooredBonus then bonus=flooredBonus+(((math.random()<(bonus-flooredBonus)) and 1) or 0) end
	local singleMultiplier=1+(((pCount==1) and 0.1*bonus) or 0)
	pCount=((self.disableProjectileCountBonus and 0) or bonus)+pCount
	local pParams = copy(self.projectileParameters)

	pParams.power = singleMultiplier * self.baseDamageFactor * pParams.baseDamage * config.getParameter("damageLevelMultiplier") / pCount
	pParams.powerMultiplier = activeItem.ownerPowerMultiplier()

	for _ = 1, pCount do
		local projectileId = world.spawnProjectile(
			self.projectileType,
			vec2.add(basePos, pOffset),
			activeItem.ownerEntityId(),
			pOffset,
			false,
			pParams
		)

		if projectileId then
			table.insert(storage.projectiles, projectileId)
			world.sendEntityMessage(projectileId, "updateProjectile", aimPosition)
		end

		pOffset = vec2.rotate(pOffset, (2 * math.pi) / pCount)
	end
end

function CloudExplosion:focusPosition()
	return vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("stone", "focalPoint")))
end

-- Actualiza la posición de los proyectiles
-- give all projectiles a new aim position and let those projectiles return one or
-- more entity ids for projectiles we should now be tracking
function CloudExplosion:updateProjectiles()
	local aimPosition = activeItem.ownerAimPosition()
	local newProjectiles = {}
	for _, projectileId in pairs(storage.projectiles) do
		if world.entityExists(projectileId) then
			local projectileResponse = world.sendEntityMessage(projectileId, "updateProjectile", aimPosition)
			if projectileResponse:finished() then
				local newIds = projectileResponse:result()
				if type(newIds) ~= "table" then
					newIds = {newIds}
				end
				for _, newId in pairs(newIds) do
					table.insert(newProjectiles, newId)
				end
			end
		end
	end
	storage.projectiles = newProjectiles
end

-- Elimina los proyectiles activos
function CloudExplosion:killProjectiles() -- when click it end the casting?
	for _, projectileId in pairs(storage.projectiles) do
		if world.entityExists(projectileId) then
			world.sendEntityMessage(projectileId, "kill")
		end
	end
end

-- Resetea la habilidad
function CloudExplosion:reset()
	self.weapon:setStance(self.stances.idle)
	animator.stopAllSounds(self.elementalType.."chargedloop")
	animator.stopAllSounds(self.elementalType.."fullcharge")
	animator.setAnimationState("charge", "idle")
	animator.setParticleEmitterActive(self.elementalType .. "charge", false)
	activeItem.setCursor("/cursors/reticle0.cursor")
end

-- Llamado al finalizar la habilidad
function CloudExplosion:uninit(weaponUninit)
	self:reset()
	if weaponUninit then
		self:killProjectiles()
	end
end
