-- Options.lua
-- Custom settings frame that attaches to Baganator's settings dialog
local addon = BaganatorUnofficialTweaksAddon
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
-- Set this to false to hide the font size slider
local SHOW_FONT_SIZE_SLIDER = false
-- Create the main settings frame
local function CreateSettingsFrame()
	local frame = CreateFrame("Frame", "BaganatorTweaksSettingsFrame", UIParent, "BackdropTemplate")
	frame:SetSize(350, 310)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:Hide()
	-- Backdrop
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		tile = true,
		tileSize = 32,
		edgeSize = 2,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	frame:SetBackdropColor(0, 0, 0, 1)
	frame:SetBackdropBorderColor(0, 0, 0, 1) -- Black border
	-- Title bar
	local titleBar = CreateFrame("Frame", nil, frame)
	titleBar:SetSize(frame:GetWidth() - 16, 30)
	titleBar:SetPoint("TOP", 0, 12)
	titleBar:EnableMouse(true)
	titleBar:RegisterForDrag("LeftButton")
	titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
	titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
	local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("CENTER", 0, -10)
	title:SetText("Baganator Unofficial Tweaks")
	-- Close button
	local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", -5, -5)
	closeBtn:SetScript("OnClick", function() frame:Hide() end)
	local yOffset = -40
	-- Font Settings Header
	local fontHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	fontHeader:SetPoint("TOPLEFT", 20, yOffset)
	fontHeader:SetText("Font Settings")
	yOffset = yOffset - 25
	-- Font Enable Checkbox
	local fontEnableCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
	fontEnableCheck:SetPoint("TOPLEFT", 35, yOffset)
	fontEnableCheck.Text:SetText("Enable Font Customization |cffff0000(*Modifies Blizz Font too)|r")
	fontEnableCheck.Text:SetTextColor(1, 1, 1, 1) -- White
	fontEnableCheck:SetScript("OnClick", function(self)
		addon.db.profile.font.enabled = self:GetChecked()
		if addon.modules.FontModule then
			addon.modules.FontModule:ReapplyAllFonts()
		end

		frame:UpdateControls()
	end)
	fontEnableCheck:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Font Customization", 1, 1, 1, 1, true)
		GameTooltip:AddLine("This will modify the following fonts:", 1, 0.82, 0, true)
		GameTooltip:AddLine("Baganator item count/text", 1, 1, 1, true)
		GameTooltip:AddLine("Blizzard action bar hotkeys", 1, 1, 1, true)
		GameTooltip:AddLine("Vendor currency displays", 1, 1, 1, true)
		GameTooltip:AddLine("Various UI number fonts", 1, 1, 1, true)
		GameTooltip:Show()
	end)
	fontEnableCheck:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	frame.fontEnableCheck = fontEnableCheck
	yOffset = yOffset - 30
	-- Font Dropdown
	local fontLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	fontLabel:SetPoint("TOPLEFT", 35, yOffset)
	fontLabel:SetText("Font:")
	fontLabel:SetTextColor(1, 1, 1, 1) -- White
	-- Custom button instead of UIDropDownMenu for scrolling support
	local fontButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	fontButton:SetPoint("TOPLEFT", 110, yOffset + 5)
	fontButton:SetSize(200, 22)
	fontButton:SetText(addon.db.profile.font.fontName or "Friz Quadrata TT")
	fontButton:SetScript("OnClick", function(self)
		if frame.fontMenu and frame.fontMenu:IsShown() then
			frame.fontMenu:Hide()
		else
			frame:ShowFontMenu(self)
		end
	end)
	frame.fontButton = fontButton
	yOffset = yOffset - 35
	-- Font Size Slider (can be disabled by setting SHOW_FONT_SIZE_SLIDER = false)
	if SHOW_FONT_SIZE_SLIDER then
		local sizeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		sizeLabel:SetPoint("TOPLEFT", 35, yOffset)
		sizeLabel:SetText("Font Size:")
		sizeLabel:SetTextColor(1, 1, 1, 1) -- White
		local sizeSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
		sizeSlider:SetPoint("TOPLEFT", 120, yOffset)
		sizeSlider:SetMinMaxValues(6, 24)
		sizeSlider:SetValueStep(1)
		sizeSlider:SetObeyStepOnDrag(true)
		sizeSlider:SetWidth(200)
		sizeSlider.Low:SetText("6")
		sizeSlider.High:SetText("24")
		sizeSlider:SetScript("OnValueChanged", function(self, value)
			addon.db.profile.font.fontSize = value
			sizeSlider.Value:SetText(value)
			if addon.modules.FontModule then
				addon.modules.FontModule:ReapplyAllFonts()
			end
		end)
		sizeSlider.Value = sizeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		sizeSlider.Value:SetPoint("TOP", sizeSlider, "BOTTOM", 0, 0)
		frame.sizeSlider = sizeSlider
		yOffset = yOffset - 40
	else
		-- Slider disabled - ensure fontSize has a default value
		if not addon.db.profile.font.fontSize then
			addon.db.profile.font.fontSize = 12
		end

		frame.sizeSlider = nil
	end

	-- Font Outline Dropdown
	local outlineLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	outlineLabel:SetPoint("TOPLEFT", 35, yOffset)
	outlineLabel:SetText("Outline:")
	outlineLabel:SetTextColor(1, 1, 1, 1) -- White
	local outlineDropdown = CreateFrame("Frame", "BaganatorTweaksOutlineDropdown", frame, "UIDropDownMenuTemplate")
	outlineDropdown:SetPoint("TOPLEFT", 95, yOffset + 5)
	UIDropDownMenu_SetWidth(outlineDropdown, 180)
	local outlineOptions = {
		{ value = "", text = "None" },
		{ value = "OUTLINE", text = "Normal Outline" },
		{ value = "THICKOUTLINE", text = "Thick Outline" },
		{ value = "MONOCHROME", text = "Monochrome" },
	}
	UIDropDownMenu_Initialize(outlineDropdown, function(self, level)
		for _, opt in ipairs(outlineOptions) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = opt.text
			info.func = function()
				addon.db.profile.font.fontFlags = opt.value
				UIDropDownMenu_SetText(outlineDropdown, opt.text)
				if addon.modules.FontModule then
					addon.modules.FontModule:ReapplyAllFonts()
				end
			end
			info.checked = (addon.db.profile.font.fontFlags == opt.value)
			UIDropDownMenu_AddButton(info, level)
		end
	end)
	frame.outlineDropdown = outlineDropdown
	yOffset = yOffset - 45
	-- Ignore Slots Header
	local ignoreHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	ignoreHeader:SetPoint("TOPLEFT", 20, yOffset)
	ignoreHeader:SetText("Account-Wide Ignore Slots")
	yOffset = yOffset - 25
	-- Ignore Slots Enable
	local ignoreSlotsCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
	ignoreSlotsCheck:SetPoint("TOPLEFT", 35, yOffset)
	ignoreSlotsCheck.Text:SetText("Enable Account-Wide Sync")
	ignoreSlotsCheck.Text:SetTextColor(1, 1, 1, 1) -- White
	ignoreSlotsCheck:SetScript("OnClick", function(self)
		addon.db.profile.ignoreSlots.enabled = self:GetChecked()
		if addon.db.profile.ignoreSlots.enabled and addon.modules.IgnoreSlotsModule then
			addon.modules.IgnoreSlotsModule:ApplyToAllCharacters()
		end

		frame:UpdateControls()
	end)
	frame.ignoreSlotsCheck = ignoreSlotsCheck
	yOffset = yOffset - 30
	-- Character Toggle
	local charCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
	charCheck:SetPoint("TOPLEFT", 35, yOffset)
	charCheck.Text:SetText("Sync This Character (" .. UnitName("player") .. ")")
	charCheck.Text:SetTextColor(1, 1, 1, 1) -- White
	charCheck:SetScript("OnClick", function(self)
		if addon.modules.IgnoreSlotsModule then
			addon.modules.IgnoreSlotsModule:ToggleCurrentCharacter(self:GetChecked())
		end
	end)
	frame.charCheck = charCheck
	yOffset = yOffset - 30
	-- Ignored Slots Slider
	local slotsLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	slotsLabel:SetPoint("TOPLEFT", 35, yOffset)
	slotsLabel:SetText("Bag Slots:")
	slotsLabel:SetTextColor(1, 1, 1, 1) -- White
	local slotsSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
	slotsSlider:SetPoint("TOPLEFT", 110, yOffset)
	slotsSlider:SetMinMaxValues(0, 100)
	slotsSlider:SetValueStep(1)
	slotsSlider:SetObeyStepOnDrag(true)
	slotsSlider:SetWidth(200)
	slotsSlider.Low:SetText("0")
	slotsSlider.High:SetText("100")
	slotsSlider:SetScript("OnValueChanged", function(self, value)
		addon.db.profile.ignoreSlots.ignoredSlots = value
		slotsSlider.Value:SetText(value)
		if addon.modules.IgnoreSlotsModule then
			addon.modules.IgnoreSlotsModule:ApplyToAllCharacters(value)
		end
	end)
	slotsSlider.Value = slotsSlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	slotsSlider.Value:SetPoint("TOP", slotsSlider, "BOTTOM", 0, 0)
	slotsSlider.Value:SetTextColor(1, 1, 1, 1) -- White
	frame.slotsSlider = slotsSlider
	-- Custom Font Menu (Scrollable) - Based on RandomMountBuddy pattern
	frame.ShowFontMenu = function(self, anchorFrame)
		if not self.fontMenu then
			self:CreateFontMenu()
		end

		-- Position near the button
		self.fontMenu:ClearAllPoints()
		self.fontMenu:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -2)
		self.fontMenu:Show()
		self.fontMenuBlocker:Show()
	end
	frame.CreateFontMenu = function(self)
		-- Visual constants (mount browser style)
		local MENU_VISUAL = {
			BG_COLOR = { r = 0.1, g = 0.1, b = 0.1, a = 0.95 },
			BORDER_COLOR = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
			BUTTON_DEFAULT = { r = 0.2, g = 0.2, b = 0.2, a = 0 },
			BUTTON_HOVER = { r = 0.3, g = 0.3, b = 0.3, a = 1 },
			TEXT_DEFAULT = { r = 1, g = 1, b = 1, a = 1 },
			TEXT_HOVER = { r = 1, g = 1, b = 0, a = 1 },
			TEXT_HEADER = { r = 1, g = 0.82, b = 0, a = 1 },
		}
		-- Get font list
		local function GetFontList()
			local fonts = {}
			if LSM then
				local fontList = LSM:List("font")
				for _, fontName in ipairs(fontList) do
					table.insert(fonts, fontName)
				end

				table.sort(fonts)
			else
				table.insert(fonts, "Friz Quadrata TT")
			end

			return fonts
		end

		-- Blocker frame to catch outside clicks
		local blocker = CreateFrame("Frame", nil, UIParent)
		blocker:SetFrameStrata("FULLSCREEN_DIALOG")
		blocker:SetFrameLevel(100)
		blocker:SetAllPoints(UIParent)
		blocker:EnableMouse(true)
		blocker:SetScript("OnMouseDown", function()
			self.fontMenu:Hide()
			blocker:Hide()
		end)
		blocker:Hide()
		self.fontMenuBlocker = blocker
		-- Menu frame with professional backdrop
		local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
		menu:SetFrameStrata("FULLSCREEN_DIALOG")
		menu:SetFrameLevel(101)
		menu:SetSize(280, 400)
		-- Tooltip-style backdrop (mount browser quality)
		menu:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		menu:SetBackdropColor(
			MENU_VISUAL.BG_COLOR.r,
			MENU_VISUAL.BG_COLOR.g,
			MENU_VISUAL.BG_COLOR.b,
			MENU_VISUAL.BG_COLOR.a
		)
		menu:SetBackdropBorderColor(
			MENU_VISUAL.BORDER_COLOR.r,
			MENU_VISUAL.BORDER_COLOR.g,
			MENU_VISUAL.BORDER_COLOR.b,
			MENU_VISUAL.BORDER_COLOR.a
		)
		menu:Hide()
		-- Header
		local header = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		header:SetPoint("TOPLEFT", 12, -8)
		header:SetText("Select Font")
		header:SetTextColor(
			MENU_VISUAL.TEXT_HEADER.r,
			MENU_VISUAL.TEXT_HEADER.g,
			MENU_VISUAL.TEXT_HEADER.b,
			MENU_VISUAL.TEXT_HEADER.a
		)
		-- Separator line
		local separator = menu:CreateTexture(nil, "ARTWORK")
		separator:SetColorTexture(0.4, 0.4, 0.4, 1)
		separator:SetHeight(1)
		separator:SetPoint("LEFT", menu, "LEFT", 12, -28)
		separator:SetPoint("RIGHT", menu, "RIGHT", -12, -28)
		-- ScrollFrame
		local scrollFrame = CreateFrame("ScrollFrame", nil, menu, "UIPanelScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", 12, -34)
		scrollFrame:SetPoint("BOTTOMRIGHT", -28, 12)
		-- Scroll child
		local scrollChild = CreateFrame("Frame", nil, scrollFrame)
		scrollChild:SetSize(240, 1)
		scrollFrame:SetScrollChild(scrollChild)
		-- Populate with styled font buttons
		local fonts = GetFontList()
		local yOffset = 0
		for i, fontName in ipairs(fonts) do
			local btn = CreateFrame("Button", nil, scrollChild)
			btn:SetSize(240, 22)
			btn:SetPoint("TOPLEFT", 0, -yOffset)
			-- Background texture for hover effect
			btn.bg = btn:CreateTexture(nil, "BACKGROUND")
			btn.bg:SetAllPoints()
			btn.bg:SetColorTexture(
				MENU_VISUAL.BUTTON_DEFAULT.r,
				MENU_VISUAL.BUTTON_DEFAULT.g,
				MENU_VISUAL.BUTTON_DEFAULT.b,
				MENU_VISUAL.BUTTON_DEFAULT.a
			)
			-- Button text with font preview
			btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			btn.text:SetPoint("LEFT", 8, 0)
			btn.text:SetText(fontName)
			btn.text:SetJustifyH("LEFT")
			btn.text:SetTextColor(
				MENU_VISUAL.TEXT_DEFAULT.r,
				MENU_VISUAL.TEXT_DEFAULT.g,
				MENU_VISUAL.TEXT_DEFAULT.b,
				MENU_VISUAL.TEXT_DEFAULT.a
			)
			-- Apply the actual font for preview (SharedMedia integration)
			if LSM then
				local success, fontPath = pcall(LSM.Fetch, LSM, "font", fontName)
				if success and fontPath then
					btn.text:SetFont(fontPath, 12, "OUTLINE")
				end
			end

			-- Highlight texture (shimmer effect)
			btn:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
			-- Smooth hover transitions
			btn:SetScript("OnEnter", function(self)
				self.bg:SetColorTexture(
					MENU_VISUAL.BUTTON_HOVER.r,
					MENU_VISUAL.BUTTON_HOVER.g,
					MENU_VISUAL.BUTTON_HOVER.b,
					MENU_VISUAL.BUTTON_HOVER.a
				)
				self.text:SetTextColor(
					MENU_VISUAL.TEXT_HOVER.r,
					MENU_VISUAL.TEXT_HOVER.g,
					MENU_VISUAL.TEXT_HOVER.b,
					MENU_VISUAL.TEXT_HOVER.a
				)
			end)
			btn:SetScript("OnLeave", function(self)
				self.bg:SetColorTexture(
					MENU_VISUAL.BUTTON_DEFAULT.r,
					MENU_VISUAL.BUTTON_DEFAULT.g,
					MENU_VISUAL.BUTTON_DEFAULT.b,
					MENU_VISUAL.BUTTON_DEFAULT.a
				)
				self.text:SetTextColor(
					MENU_VISUAL.TEXT_DEFAULT.r,
					MENU_VISUAL.TEXT_DEFAULT.g,
					MENU_VISUAL.TEXT_DEFAULT.b,
					MENU_VISUAL.TEXT_DEFAULT.a
				)
			end)
			-- Click handler
			btn:SetScript("OnClick", function()
				addon.db.profile.font.fontName = fontName
				self.fontButton:SetText(fontName)
				if addon.modules.FontModule then
					addon.modules.FontModule:OnFontChanged()
				end

				menu:Hide()
				blocker:Hide()
			end)
			yOffset = yOffset + 24
		end

		-- Set scroll child height to enable scrolling
		scrollChild:SetHeight(math.max(yOffset, 1))
		self.fontMenu = menu
	end
	-- Update controls based on settings
	frame.UpdateControls = function(self)
		local fontEnabled = addon.db.profile.font.enabled
		self.fontButton:SetAlpha(fontEnabled and 1 or 0.5)
		self.fontButton:SetEnabled(fontEnabled)
		-- Safe access to sizeSlider (might not exist if SHOW_FONT_SIZE_SLIDER = false)
		if self.sizeSlider then
			self.sizeSlider:SetEnabled(fontEnabled)
		end

		outlineDropdown:SetAlpha(fontEnabled and 1 or 0.5)
		local ignoreSlotsEnabled = addon.db.profile.ignoreSlots.enabled
		charCheck:SetEnabled(ignoreSlotsEnabled)
		slotsSlider:SetEnabled(ignoreSlotsEnabled)
	end
	-- Refresh values from settings
	frame.Refresh = function(self)
		fontEnableCheck:SetChecked(addon.db.profile.font.enabled)
		self.fontButton:SetText(addon.db.profile.font.fontName or "Friz Quadrata TT")
		-- Safe access to sizeSlider (might not exist if SHOW_FONT_SIZE_SLIDER = false)
		if self.sizeSlider then
			self.sizeSlider:SetValue(addon.db.profile.font.fontSize or 12)
			self.sizeSlider.Value:SetText(addon.db.profile.font.fontSize or 12)
		end

		local currentFlags = addon.db.profile.font.fontFlags
		for _, opt in ipairs(outlineOptions) do
			if opt.value == currentFlags then
				UIDropDownMenu_SetText(outlineDropdown, opt.text)
				break
			end
		end

		ignoreSlotsCheck:SetChecked(addon.db.profile.ignoreSlots.enabled)
		if addon.modules.IgnoreSlotsModule then
			charCheck:SetChecked(not addon.modules.IgnoreSlotsModule:IsCurrentCharacterExcluded())
		end

		slotsSlider:SetValue(addon.db.profile.ignoreSlots.ignoredSlots)
		slotsSlider.Value:SetText(addon.db.profile.ignoreSlots.ignoredSlots)
		self:UpdateControls()
	end
	frame:SetScript("OnShow", function(self)
		self:Refresh()
	end)
	return frame
end

-- Register Options
addon.RegisterOptions = function(self)
	-- Create our custom settings frame
	self.settingsFrame = CreateSettingsFrame()
	-- Baganator is already loaded and verified at this point (called from WaitForBaganator)
	-- Hook into Baganator's ShowCustomise event
	if _G.Baganator and Baganator.CallbackRegistry then
		Baganator.CallbackRegistry:RegisterCallback("ShowCustomise", function()
			-- The frame is created during this callback, so wait a tiny bit
			C_Timer.After(0.1, function()
				-- Find the VISIBLE BaganatorCustomiseDialogFrame (not random)
				local baganatorFrame = nil
				for name, frame in pairs(_G) do
					-- Match main frame only (ends with skin like "elvui" or "blizzard")
					-- Pattern: BaganatorCustomiseDialogFrame + lowercase letters only (skin name)
					if type(name) == "string" and name:match("^BaganatorCustomiseDialogFrame[a-z]+$") then
						if frame.GetObjectType and frame:IsShown() then
							-- Found the visible one!
							baganatorFrame = frame
							break
						end
					end
				end

				if baganatorFrame then
					-- Position our frame relative to the visible Baganator frame
					self.settingsFrame:ClearAllPoints()
					self.settingsFrame:SetPoint("LEFT", baganatorFrame, "TOPRIGHT", 40, -155)
					self.settingsFrame:Show()
					-- Hook to hide when Baganator's closes
					-- Re-hook every time since the frame changes when theme changes
					baganatorFrame:HookScript("OnHide", function()
						self.settingsFrame:Hide()
					end)
				end
			end)
		end)
	end

	-- Register a simple button in Blizzard settings
	local panel = CreateFrame("Frame")
	panel.name = "Baganator Unofficial Tweaks"
	local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btn:SetSize(150, 30)
	btn:SetPoint("CENTER")
	btn:SetText("Open Settings")
	btn:SetScript("OnClick", function()
		self.settingsFrame:Show()
	end)
	if Settings and Settings.RegisterCanvasLayoutCategory then
		local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
		Settings.RegisterAddOnCategory(category)
		self.optionsCategoryID = category:GetID()
	end
end
