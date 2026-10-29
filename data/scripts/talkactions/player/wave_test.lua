-- /wavetest  - włącza/wyłącza diagnostykę czarów obszarowych dla Twojej postaci.
-- Po włączeniu przy każdym czarze dostajesz:
--   [czar] formuła: lvl, ml, min-max      -> silnik policzył obrażenia
--   [trafienie] cel: wartość (typ)         -> obrażenia doszły do celu
-- Brak linii "formuła" = błąd w skrypcie czaru; jest "formuła", brak "trafienie" = czar nie złapał celu
-- (kierunek fali, strefa PZ, cel nieatakowalny/nieśmiertelny).

SpellDebug = SpellDebug or { players = {}, count = 0 }

local TYPES = {
	[COMBAT_PHYSICALDAMAGE] = "fizyczne",
	[COMBAT_ENERGYDAMAGE] = "energia",
	[COMBAT_EARTHDAMAGE] = "ziemia",
	[COMBAT_FIREDAMAGE] = "ogień",
	[COMBAT_ICEDAMAGE] = "lód",
	[COMBAT_HOLYDAMAGE] = "święte",
	[COMBAT_DEATHDAMAGE] = "śmierć",
}

function SpellDebug.report(player, spellName, level, maglevel, min, max)
	if not player or SpellDebug.count == 0 or not SpellDebug.players[player:getId()] then
		return
	end
	player:sendTextMessage(MESSAGE_STATUS, string.format("[%s] formuła: lvl %d, ml %d -> %d-%d", spellName, level, maglevel, math.floor(min), math.floor(max)))
end

local talk = TalkAction("/wavetest")

function talk.onSay(player, words, param)
	local id = player:getId()
	if SpellDebug.players[id] then
		SpellDebug.players[id] = nil
		SpellDebug.count = math.max(0, SpellDebug.count - 1)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Diagnostyka czarów: WYŁĄCZONA.")
	else
		SpellDebug.players[id] = true
		SpellDebug.count = SpellDebug.count + 1
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Diagnostyka czarów: WŁĄCZONA. Rzuć falę w potwora/dummy i wklej Claude co pokazało się w oknie Server Log.")
	end
	return false
end

talk:groupType("normal")
talk:register()

local cb = EventCallback("CreatureOnCombatWaveTest")

function cb.creatureOnCombat(caster, target, primaryValue, primaryType, secondaryValue, secondaryType, origin)
	if SpellDebug.count > 0 and caster and target then
		local player = caster:getPlayer()
		if player and SpellDebug.players[player:getId()] then
			player:sendTextMessage(MESSAGE_STATUS, string.format("[trafienie] %s: %d (%s)%s", target:getName(), math.abs(primaryValue or 0), TYPES[primaryType] or tostring(primaryType), (secondaryValue and secondaryValue ~= 0) and (" + " .. math.abs(secondaryValue)) or ""))
		end
	end
	return primaryValue, primaryType, secondaryValue, secondaryType
end

cb:register()
