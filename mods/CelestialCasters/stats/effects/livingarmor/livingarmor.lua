require "/stats/effects/basicStatusEffects.lua"

function init()
    animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
    animator.setParticleEmitterActive("drips", true)
    effect.setParentDirectives(config.getParameter("colorWrap", "fade=33FF33=0.2"))

    script.setUpdateDelta(5)
	BasicStatusEffects.Healing.init(config)
	BasicStatusEffects.ArmorModify.init(config)
end

function update(dt)
	
	BasicStatusEffects.Healing.update(dt)
	-- basicStatusEffects.armor.update(dt) Bueno para hacer efectos que escalan
end

function uninit()

end