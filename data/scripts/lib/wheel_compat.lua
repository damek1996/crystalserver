-- Zgodność skryptów czarów z silnikiem PRZED i PO przebudowie z poprawkami koła (07.2026).
-- Nowy silnik rejestruje WHEEL_ENGINE_REBALANCE = 202607; stary go nie ma.
-- Na starym exe skrypty same korygują wartości, które siedzą w C++; po przebudowie korekty się wyłączają.
WheelCompat = WheelCompat or {}

function WheelCompat.enginePatched()
	return (rawget(_G, "WHEEL_ENGINE_REBALANCE") or 0) >= 202607
end

-- stopień augmentu czaru z koła: 0 = brak, 1 = I, 2 = II
function WheelCompat.grade(player, spellName)
	if not player or not player.upgradeSpellsWOD then
		return 0
	end
	local ok, grade = pcall(player.upgradeSpellsWOD, player, spellName)
	return (ok and tonumber(grade)) or 0
end

-- mnożnik, gdy stary silnik ma inne % augmentu niż obecna Tibia
-- oldPct/newPct = łączny bonus % dla danego stopnia (np. 25 -> 20)
function WheelCompat.scale(player, spellName, byGrade)
	if WheelCompat.enginePatched() then
		return 1
	end
	local g = WheelCompat.grade(player, spellName)
	local entry = byGrade[g]
	if not entry then
		return 1
	end
	return (100 + entry[2]) / (100 + entry[1])
end

-- stary silnik dodawał "+10% szansy na kryta" z koła jako +0,1% - tu dorzucamy brakującą szansę
function WheelCompat.extraCrit(player, spellName, minGrade, chancePct, min, max)
	if WheelCompat.enginePatched() or WheelCompat.grade(player, spellName) < minGrade then
		return min, max
	end
	if math.random(1, 100) <= chancePct then
		local extra = player:getSkillLevel(SKILL_CRITICAL_HIT_DAMAGE) / 10000
		return min * (1 + extra), max * (1 + extra)
	end
	return min, max
end

-- Battle Healing (Knight): z tarczą +30% -> +20%. Stary exe daje 30%, więc leczenie * 1.2/1.3.
function WheelCompat.knightHealScale(player)
	if WheelCompat.enginePatched() or not player or player:revelationStageWOD("Battle Healing") == 0 then
		return 1
	end
	for _, slot in ipairs({ CONST_SLOT_LEFT, CONST_SLOT_RIGHT }) do
		local item = player:getSlotItem(slot)
		if item and item:getType():getWeaponType() == WEAPON_SHIELD then
			return 1.2 / 1.3
		end
	end
	return 1
end
