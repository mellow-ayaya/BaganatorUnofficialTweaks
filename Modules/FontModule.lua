-- Modules/FontModule.lua
-- Handles font customization by modifying NumberFontNormal globally
-- WARNING: This affects ALL addons/UI elements that use NumberFontNormal
local addon = BaganatorUnofficialTweaksAddon
local FontModule = {}
addon.modules.FontModule = FontModule
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
-- Store original font settings to restore if needed
local originalFont, originalSize, originalFlags = NumberFontNormal:GetFont()
function FontModule:Initialize()
	-- if LSM and addon.db.profile.font.fontName then
	-- 	addon:ModulePrint("Font Module", "Using font: " .. addon.db.profile.font.fontName)
	-- end
	self:ApplyFont()
end

-- Get current font settings
function FontModule:GetFontSettings()
	if not addon.db.profile.font.enabled then
		return nil
	end

	if LSM and addon.db.profile.font.fontName then
		local success, path = pcall(LSM.Fetch, LSM, "font", addon.db.profile.font.fontName)
		if success then
			-- Use original font size to preserve default sizing (don't change sizes)
			return path, originalSize, addon.db.profile.font.fontFlags or "OUTLINE"
		end
	end

	return nil
end

-- Apply font to NumberFontNormal
function FontModule:ApplyFont()
	if not addon.db.profile.font.enabled then
		-- Restore original font
		NumberFontNormal:SetFont(originalFont, originalSize, originalFlags)
		-- addon:ModulePrint("Font Module", "Font customization disabled, restored default")
		return
	end

	local fontPath, fontSize, fontFlags = self:GetFontSettings()
	if fontPath then
		NumberFontNormal:SetFont(fontPath, fontSize, fontFlags)
		-- addon:ModulePrint("Font Module", "Applied " .. addon.db.profile.font.fontName .. " to NumberFontNormal")
	else
		addon:ModulePrint("Font Module", "ERROR: Could not load font")
	end
end

-- Called when font settings change
function FontModule:OnFontChanged()
	self:ApplyFont()
	addon:ModulePrint("Font Module", "Font updated")
end

-- For compatibility with slash commands
function FontModule:ReapplyAllFonts()
	self:ApplyFont()
end

-- Debug function
function FontModule:Debug()
	print("|cff00ffffFont Module Debug:|r")
	print("  Enabled:", tostring(addon.db.profile.font.enabled))
	print("  Font Name:", tostring(addon.db.profile.font.fontName))
	print("  Font Size: Using original size (not customizable)")
	print("  Font Flags:", tostring(addon.db.profile.font.fontFlags or "OUTLINE"))
	print("  LSM Available:", tostring(LSM ~= nil))
	local fontPath, fontSize, fontFlags = self:GetFontSettings()
	if fontPath then
		print("  Current font path:", fontPath)
		print("  Current font size:", fontSize)
	else
		print("  ERROR: Could not get font settings")
	end

	print("\n|cff00ffffNumberFontNormal current settings:|r")
	local currentFont, currentSize, currentFlags = NumberFontNormal:GetFont()
	print("  Font:", currentFont)
	print("  Size:", currentSize)
	print("  Flags:", currentFlags or "none")
	print("\n|cff00ffffOriginal NumberFontNormal settings:|r")
	print("  Font:", originalFont)
	print("  Size:", originalSize)
	print("  Flags:", originalFlags or "none")
end
