local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

-- Vocation Adjustment: base power 225, scales with magic level + shielding.
function onGetFormulaValues(player, level, magicLevel, basePower)
	local min, max = calculateKnightHealing(player, magicLevel, basePower, 8.0, 15.9, 2.5, 2)
	local s = WheelCompat and WheelCompat.knightHealScale(player) or 1
	return min * s, max * s
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:group("healing")
spell:id(239)
spell:name("Fair Wound Cleansing")
spell:words("exura med ico")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_FAIR_WOUND_CLEANSING)
spell:level(300)
spell:mana(135) -- balance 07.2026: 90 -> 135
spell:basePower(225)
spell:isPremium(true)
spell:isSelfTarget(true)
spell:cooldown(1000)
spell:groupCooldown(2 * 1000) -- Phase A rebalance: 1s -> 2s
spell:isAggressive(false)
spell:vocation("knight;true", "elite knight;true")
spell:register()
