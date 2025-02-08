-- ignoreEnemies.lua

function init()
	-- Configuración inicial del proyectil
	self.statusEffectsAlly = config.getParameter("statusEffectsAlly", {})
  end
  
  function update(dt)
	-- Obtener entidades en proximidad
	local nearbyEntities = world.entityQuery(mcontroller.position(), 1.0, {
		withoutEntityId = entity.id(),
		includedTypes = {"npc", "player"}
	  })
	
	  for _, entityId in ipairs(nearbyEntities) do
		-- Verificar si la entidad es un NPC aliado
		if (world.entityType(entityId) == "npc" or world.entityType(entityId) == "player") and not world.entityCanDamage(entityId, entity.id()) then
		  -- Aplicar cada efecto de estado definido en statusEffectsAlly
		  for _, effect in ipairs(self.statusEffectsAlly) do
			world.sendEntityMessage(entityId, "applyStatusEffect", effect.effect, effect.duration, entity.id())
		  end
		end
	  end
  end