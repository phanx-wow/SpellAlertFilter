------------------------------------------------------------------------
-- SpellAlertFilter
--	Hides annoying spell alert graphics.
-- Copyright (c) 2014 Phanx <addons@phanx.net>. All rights reserved.
------------------------------------------------------------------------

local L = setmetatable({}, { __index = function(L, k)
	local v = tostring(k)
	L[k] = v
	return v
end })

if GetLocale() == "deDE" then
	L["%d (%s) will no longer be hidden."] = "%d (%s) wird nicht mehr versteckt."
	L["%d (%s) will now be hidden."] = "%d (%s) wird jetzt versteckt."
	L["%d spell alerts are being hidden."] = "Momentan sind %d Zauberwarnmeldungen versteckt."
	L["All spell alerts have been removed from the filter list."] = "Alle Zauberwarnmeldungen wurden aus der Verstecksliste entfernt."
	L["disabled"] = "deaktiviert"
	L["enabled"] = "aktiviert"
	L["Setup mode is now %s."] = "Der Konfigurationsmodus ist jetzt %s."
elseif GetLocale():match("^es") then
	L["%d (%s) will no longer be hidden."] = "%d (%s) ya no se oculta."
	L["%d (%s) will now be hidden."] = "%d (%s) ahora se oculta."
	L["%d spell alerts are being hidden."] = "%d alertas de hechizos se ocultan actualmente."
	L["All spell alerts have been removed from the filter list."] = "Todos hechizos se han eliminados por la lista para ocultar."
	L["disabled"] = "desactivado"
	L["enabled"] = "activado"
	L["Setup mode is now %s."] = "El modo de configuración está ahora %s."
end

L["enabled"] = "|cff7fff7f" .. L["enabled"] .. "|r"
L["disabled"] = "|cffff7f7f" .. L["disabled"] .. "|r"

------------------------------------------------------------------------

local setupMode

SpellAlertFilter = {
	[170588] = true, -- Maelstrom Weapon 1/5
	[170587] = true, -- Maelstrom Weapon 2/5
	[170586] = true, -- Maelstrom Weapon 3/5
	[170585] = true, -- Maelstrom Weapon 4/5
}

SpellActivationOverlayFrame:SetScript("OnEvent", function(self, event, spellID, ...)
	if event == "SPELL_ACTIVATION_OVERLAY_SHOW" and SpellAlertFilter[spellID] then
		return
	end
	if setupMode then
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format("%d (%s)", spellID, GetSpellInfo(spellID or UNKNOWN)))
	end
	SpellActivationOverlay_OnEvent(self, event, spellID, ...)
end)

------------------------------------------------------------------------

local options = {
	list = function()
		local t = {}
		for id in pairs(SpellAlertFilter) do
			tinsert(id)
		end
		sort(t)
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format(L["%d spell alerts are being hidden."], #t))
		for i = 1, #t do
			local spellID = t[i]
			DEFAULT_CHAT_FRAME:AddMessage("   " .. format(L["%d (%s)"], spellID, GetSpellInfo(spellID) or UNKNOWN))
		end
	end,
	reset = function()
		for id in pairs(SpellAlertFilter) do
			SpellAlertFilter[id] = nil
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. L["All spell alerts have been removed from the filter list."])
	end,
	setup = function()
		setupMode = not setupMode
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format(L["Setup mode is now %s."], setupMode and L["enabled"] or L["disabled"]))
	end,
}

SLASH_SPELLALERTFILTER1 = "/saf"

SlashCmdList.SPELLALERTFILTER = function(cmd)
	cmd = strtrim(strlower(cmd or ""))
	if options[cmd] then
		options[cmd]()
	elseif strmatch(cmd, "^%d+") then
		local spellID = tonumber(cmd)
		if SpellAlertFilter[spellID] then
			SpellAlertFilter[spellID] = nil
			DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format(L["%d (%s) will no longer be hidden."], spellID, GetSpellInfo(spellID) or UNKNOWN))
		else
			SpellAlertFilter[spellID] = true
			DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format(L["%d (%s) will now be hidden."], spellID, GetSpellInfo(spellID) or UNKNOWN))
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. L["Use /saf with the following commands:"])
		DEFAULT_CHAT_FRAME:AddMessage("   12345 - Add/remove spell ID 123456 to/from the filter list.")
		DEFAULT_CHAT_FRAME:AddMessage("   list - List the spell alerts currently on the filter list.")
		DEFAULT_CHAT_FRAME:AddMessage("   reset - Remove all spell alerts from the filter list.")
		DEFAULT_CHAT_FRAME:AddMessage("   setup - Show a message in the chat frame with the related spell ID whenever a spell alert is displayed.")
	end
end