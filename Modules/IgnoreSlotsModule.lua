-- Modules/IgnoreSlotsModule.lua
-- Handles account-wide sync of ignored bag slots for sorting
local addon = BaganatorUnofficialTweaksAddon
local IgnoreSlotsModule = {}
addon.modules.IgnoreSlotsModule = IgnoreSlotsModule
function IgnoreSlotsModule:Initialize()
	self:InitializeCharacter()
	-- addon:ModulePrint("Ignore Slots Module",
	-- 	"Initialized with " .. addon.db.profile.ignoreSlots.ignoredSlots .. " ignored slots")
end

-- Get current character name
function IgnoreSlotsModule:GetCharacterName()
	local realm = GetRealmName():gsub("%s+", "")
	return UnitName("player") .. "-" .. realm
end

-- Update all characters with the current value
function IgnoreSlotsModule:ApplyToAllCharacters(value)
	if not addon.db.profile.ignoreSlots.enabled then
		return
	end

	value = value or addon.db.profile.ignoreSlots.ignoredSlots
	---@diagnostic disable-next-line: undefined-field
	if not BAGANATOR_CONFIG or not BAGANATOR_CONFIG.CharacterSpecific then
		return
	end

	-- Initialize if needed
	---@diagnostic disable-next-line: undefined-field
	if not BAGANATOR_CONFIG.CharacterSpecific.sort_ignore_slots_count_2 then
		---@diagnostic disable-next-line: undefined-field
		BAGANATOR_CONFIG.CharacterSpecific.sort_ignore_slots_count_2 = {}
	end

	---@diagnostic disable-next-line: undefined-field
	local charTable = BAGANATOR_CONFIG.CharacterSpecific.sort_ignore_slots_count_2
	local excludedChars = addon.db.profile.ignoreSlots.excludedCharacters
	-- Update ALL characters except excluded ones
	for charName, _ in pairs(charTable) do
		if not excludedChars[charName] then
			charTable[charName] = value
		end
	end

	-- Trigger refresh for current character
	self:TriggerBaganatorRefresh()
end

-- Initialize character in Baganator's config
function IgnoreSlotsModule:InitializeCharacter()
	if not addon.db.profile.ignoreSlots.enabled then
		return
	end

	---@diagnostic disable-next-line: undefined-field
	if not BAGANATOR_CONFIG or not BAGANATOR_CONFIG.CharacterSpecific then
		return
	end

	local charName = self:GetCharacterName()
	---@diagnostic disable-next-line: undefined-field
	if not BAGANATOR_CONFIG.CharacterSpecific.sort_ignore_slots_count_2 then
		---@diagnostic disable-next-line: undefined-field
		BAGANATOR_CONFIG.CharacterSpecific.sort_ignore_slots_count_2 = {}
	end

	---@diagnostic disable-next-line: undefined-field
	local charTable = BAGANATOR_CONFIG.CharacterSpecific.sort_ignore_slots_count_2
	local isExcluded = addon.db.profile.ignoreSlots.excludedCharacters[charName]
	if not isExcluded then
		local oldValue = charTable[charName]
		charTable[charName] = addon.db.profile.ignoreSlots.ignoredSlots
		-- if oldValue == nil then
		-- 	addon:ModulePrint("Ignore Slots", "New character initialized")
		-- end
		self:TriggerBaganatorRefresh()
	end
end

-- Trigger Baganator's refresh
function IgnoreSlotsModule:TriggerBaganatorRefresh()
	local addonTable = _G.Baganator
	if addonTable and addonTable.CallbackRegistry then
		addonTable.CallbackRegistry:TriggerEvent("SettingChanged", "sort_ignore_slots_count_2")
		C_Timer.After(0.1, function()
			if addonTable.CallbackRegistry then
				addonTable.CallbackRegistry:TriggerEvent("SettingChanged", "sort_ignore_slots_count_2")
				addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {})
			end
		end)
	end
end

-- Toggle current character's exclusion
function IgnoreSlotsModule:ToggleCurrentCharacter(enabled)
	local charName = self:GetCharacterName()
	if enabled then
		addon.db.profile.ignoreSlots.excludedCharacters[charName] = nil
		self:ApplyToAllCharacters()
		addon:ModulePrint("Ignore Slots", "This character will sync")
	else
		addon.db.profile.ignoreSlots.excludedCharacters[charName] = true
		addon:ModulePrint("Ignore Slots", "This character excluded from sync")
	end
end

-- Check if current character is excluded
function IgnoreSlotsModule:IsCurrentCharacterExcluded()
	local charName = self:GetCharacterName()
	return addon.db.profile.ignoreSlots.excludedCharacters[charName] == true
end
