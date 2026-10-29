-- /resetspells          -> zdejmuje Tobie wszystkie cooldowny czarów (także Avatara, 1-2 h)
-- /resetspells Nick     -> to samo innej postaci (konto GM/GOD)
-- Serwer treningowy: żeby ćwiczyć rotacje z Avatarem bez czekania godzin.
local talk = TalkAction("/resetspells")

function talk.onSay(player, words, param)
	local isStaff = player:getGroup():getId() >= GROUP_TYPE_GAMEMASTER or player:getAccountType() >= ACCOUNT_TYPE_GAMEMASTER
	local target = player
	param = param:trim()
	if param ~= "" then
		if not isStaff then
			player:sendCancelMessage("Tylko konto GM/GOD moze resetowac cooldowny innym.")
			return true
		end
		target = Player(param)
		if not target then
			player:sendCancelMessage("Gracz " .. param .. " nie jest online.")
			return true
		end
	end
	if player:isPzLocked() and not isStaff then
		player:sendCancelMessage("Nie w trakcie walki.")
		return true
	end

	target:removeCondition(CONDITION_SPELLCOOLDOWN)
	target:removeCondition(CONDITION_SPELLGROUPCOOLDOWN)
	for i = 0, 1023 do
		target:removeCondition(CONDITION_SPELLCOOLDOWN, CONDITIONID_DEFAULT, i)
	end
	for g = 0, 16 do
		target:removeCondition(CONDITION_SPELLGROUPCOOLDOWN, CONDITIONID_DEFAULT, g)
	end
	target:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Cooldowny czarow zresetowane (takze Avatar).")
	if target ~= player then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Zresetowano cooldowny: " .. target:getName())
	end
	return true
end

talk:separator(" ")
talk:groupType("normal")
talk:register()
