-- Core.lua
-- Main addon initialization
local addonNameFromToc, addonTable = ...
BaganatorUnofficialTweaksAddon = addonTable
-- Library initialization
local LibAceAddon = LibStub("AceAddon-3.0")
local LibAceDB = LibStub("AceDB-3.0")
local LibAceConsole = LibStub("AceConsole-3.0")
if not LibAceAddon then
	print("FATAL - AceAddon-3.0 not found!")
	return
end

-- Type annotations for external addon globals
---@class BaganatorConfig
---@field CharacterSpecific table
---@class BaganatorAddon
---@field CallbackRegistry table
---@field API table
_G.BAGANATOR_CONFIG = _G.BAGANATOR_CONFIG or {}
_G.Baganator = _G.Baganator or {}
-- Default database structure
local dbDefaults = {
	profile = {
		font = {
			enabled = true,
			fontName = "Friz Quadrata TT",
			fontSize = 12,
			fontFlags = "OUTLINE",
		},
		ignoreSlots = {
			enabled = true,
			ignoredSlots = 0,
			excludedCharacters = {},
		},
	},
}
-- Initialize the addon
function addonTable:OnInitialize()
	-- Initialize database
	self.db = LibAceDB:New("BaganatorUnofficialTweaksDB", dbDefaults, true)
	-- Migrate old database format if needed
	self:MigrateOldDatabase()
	-- Register chat commands
	LibAceConsole:RegisterChatCommand("but", function(input) self:SlashCommand(input) end)
	LibAceConsole:RegisterChatCommand("baganatortweaks", function(input) self:SlashCommand(input) end)
	-- print("|cff00ffffBaganator Tweaks|r - Loaded v2.0. Type /but to open settings.")
end

function addonTable:OnEnable()
	-- Wait for Baganator to finish loading using events instead of timers
	-- Since Baganator is RequiredDeps, it should already be loaded by PLAYER_LOGIN
	-- but we need to ensure its initialization is complete
	self:WaitForBaganator()
end

function addonTable:WaitForBaganator()
	-- Check if Baganator is ready
	if _G.Baganator and _G.Baganator.CallbackRegistry then
		self:InitializeModules()
		-- Register options after modules are initialized (defined in Options.lua)
		if self.RegisterOptions then
			self:RegisterOptions()
		end
	else
		-- Baganator not ready yet, retry with a short delay
		-- Use retry counter to avoid infinite loops
		self.baganatorRetries = (self.baganatorRetries or 0) + 1
		if self.baganatorRetries < 10 then
			-- Retry after 0.5 seconds
			C_Timer.After(0.5, function()
				self:WaitForBaganator()
			end)
		else
			print("|cff00ffffBaganator Tweaks|r - |cffff0000Warning:|r Baganator not detected after 10 retries!")
		end
	end
end

function addonTable:MigrateOldDatabase()
	-- Migrate from old flat structure to profile-based structure
	if BaganatorUnofficialTweaksDB and not BaganatorUnofficialTweaksDB.profileKeys then
		local oldDB = BaganatorUnofficialTweaksDB
		-- Save old data
		local oldFont = oldDB.font
		local oldIgnoreSlots = oldDB.ignoreSlots or oldDB.ignoredSlots
		local oldEnabled = oldDB.enabled
		local oldExcludedChars = oldDB.excludedCharacters
		-- Clear old database
		BaganatorUnofficialTweaksDB = nil
		-- Reinitialize with Ace3
		self.db = LibAceDB:New("BaganatorUnofficialTweaksDB", dbDefaults, true)
		-- Migrate data if it existed
		if oldFont then
			self.db.profile.font = oldFont
		end

		if oldIgnoreSlots or oldEnabled ~= nil or oldExcludedChars then
			self.db.profile.ignoreSlots.ignoredSlots = oldIgnoreSlots or 0
			self.db.profile.ignoreSlots.enabled = oldEnabled ~= false
			self.db.profile.ignoreSlots.excludedCharacters = oldExcludedChars or {}
		end

		print("|cff00ffffBaganator Tweaks|r - |cff00ff00Migrated old settings to new format.|r")
	end
end

function addonTable:InitializeModules()
	-- Font module
	if self.modules and self.modules.FontModule then
		self.modules.FontModule:Initialize()
	end

	-- Ignore slots module
	if self.modules and self.modules.IgnoreSlotsModule then
		self.modules.IgnoreSlotsModule:Initialize()
	end
end

function addonTable:SlashCommand(input)
	input = input:trim():lower()
	if input == "" or input == "config" or input == "options" then
		-- Show our custom settings frame
		if self.settingsFrame then
			self.settingsFrame:Show()
		end
	elseif input == "font" then
		if self.modules and self.modules.FontModule then
			self.modules.FontModule:ReapplyAllFonts()
			print("|cff00ffffBaganator Tweaks|r - Fonts reapplied.")
		end
	elseif input == "fontdebug" then
		if self.modules and self.modules.FontModule then
			self.modules.FontModule:Debug()
		end
	elseif input == "sync" then
		if self.modules and self.modules.IgnoreSlotsModule then
			self.modules.IgnoreSlotsModule:ApplyToAllCharacters()
			print("|cff00ffffBaganator Tweaks|r - Synced ignore slots to all characters.")
		end
	elseif input == "debug" then
		print("|cff00ffffBaganator Tweaks|r - Debug Info:")
		print("  Hooked: " .. tostring(self.baganatorHooked or false))
		print("  Baganator found: " .. tostring(_G.Baganator ~= nil))
		if _G.Baganator then
			print("  Baganator.API: " .. tostring(_G.Baganator.API ~= nil))
			if _G.Baganator.API then
				print("  Baganator.API.ItemButton: " .. tostring(_G.Baganator.API.ItemButton ~= nil))
			end
		end

		print("  Looking for Baganator frames...")
		for name, frame in pairs(_G) do
			if type(frame) == "table" and name:match("^BAGANATOR_") and name:match("Frame") then
				print("  Found: " .. name)
			end
		end
	else
		print("|cff00ffffBaganator Tweaks|r - Commands:")
		print("  /but - Open settings panel")
		print("  /but config - Open settings panel")
		print("  /but font - Reapply fonts to all buttons")
		print("  /but fontdebug - Detailed font debugging")
		print("  /but sync - Force sync ignore slots")
		print("  /but debug - Show debug information")
	end
end

-- Helper function for modules
function addonTable:ModulePrint(moduleName, message)
	print("|cff00ffffBaganator Tweaks|r - |cff00ff00" .. moduleName .. ":|r " .. message)
end

-- Initialize modules table
addonTable.modules = {}
-- Event frame for initialization
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
	if event == "ADDON_LOADED" and loadedAddon == addonNameFromToc then
		addonTable:OnInitialize()
		eventFrame:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		addonTable:OnEnable()
		eventFrame:UnregisterEvent("PLAYER_LOGIN")
	end
end)
