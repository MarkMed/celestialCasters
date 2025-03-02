require "/stats/effects/basicStatusEffects.lua"

function init()
    animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
    animator.setParticleEmitterActive("drips", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=33FF33=0.2"))

    script.setUpdateDelta(5)
	BasicStatusEffects.Healing.init(config, status) -- status is a variable assigned by the game engine
	BasicStatusEffects.ArmorModify.init(config) -- effect is a variable assigned by the game engine
end

function update(dt)
	
	BasicStatusEffects.Healing.update(dt, status)
	-- basicStatusEffects.armor.update(dt)
end

function uninit()

end