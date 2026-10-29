local condition = Condition(CONDITION_OUTFIT)
condition:setOutfit({ lookType = 1594 }) -- Avatar of Light lookType

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	if not creature or not creature:isPlayer() then
		return false
	end

	local grade = creature:revelationStageWOD("Avatar of Light")
	if grade == 0 then
		creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Avatar of Light: brak rewelacji w kole. Potrzebujesz co najmniej 250 punktow w domenie z Avatarem (1. stopien rewelacji).")
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local duration = 15000
	condition:setTicks(duration)
	creature:getPosition():sendMagicEffect(CONST_ME_AVATAR_APPEAR)
	creature:addCondition(condition)
	creature:avatarTimer((os.time() * 1000) + duration)
	creature:reloadData()
	local reduction = (grade >= 3 and 15) or (grade >= 2 and 10) or 5
	creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Avatar of Light (stopien %d): przez 15 s kazdy atak jest krytyczny, +%d%% obrazen krytycznych, -%d%% otrzymywanych obrazen.", grade, reduction, reduction))

	addEvent(function(cid)
		local c = Creature(cid)
		if c then
			c:reloadData()
		end
	end, duration, creature:getId())

	return true
end

spell:group("support")
spell:id(265)
spell:name("Avatar of Light")
spell:words("uteta res sac")
spell:level(300)
spell:mana(1500)
spell:isPremium(true)
spell:cooldown(2 * 60 * 60 * 1000) -- Default cooldown = 2 hours
spell:groupCooldown(2 * 1000)
spell:vocation("paladin;true", "royal paladin;true")
spell:hasParams(true)
spell:isAggressive(false)

spell:register()
