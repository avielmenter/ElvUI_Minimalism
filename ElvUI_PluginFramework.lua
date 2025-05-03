--[[
	This is a framework showing how to create a plugin for ElvUI.
	It creates some default options and inserts a GUI table to the ElvUI Config.
	If you have questions then ask in the Tukui lua section: https://www.tukui.org/forum/viewforum.php?f=10
]]

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local Minimalism = E:NewModule('Minimalism', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

--Default options

local DEFAULT_FADER_OPTIONS = {
	["UseFader"] = false,
	["Delay"] = 0,
	["Smooth"] = 0.33, -- amount of time the fade takes, for some reason
	["MaxAlpha"] = 1,
	["MinAlpha"] = 0
}

P["Minimalism"] = {
	["HideBuffsInCombat"] = false,
	["HideDebuffsInCombat"] = false,
	["BuffsFader"] = DEFAULT_FADER_OPTIONS,
	["HideLFGButton"] = false,
	["HideExpansionButton"] = false,
	["HideTracking"] = false,
	["MinimapButtonsFader"] = DEFAULT_FADER_OPTIONS,
}

function faderSection(sectionOrder, sectionName, onUpdate)
	local section = {
		order = sectionOrder,
		type = "group",
		name = "Fader",
		inline = true,
		args = {
			UseFader = {
				order = 100,
				type = "toggle",
				name = "Use Fader?",
				width = "full",
				get = function(info)
					return E.db.Minimalism[sectionName].UseFader
				end,
				set = function(info, value)
					E.db.Minimalism[sectionName].UseFader = value

					local section = E.Options.args.Minimalism.args[sectionName]
					
					if section ~= nil then
						section.args.Delay.hidden = not value
						section.args.MinAlpha.hidden = not value
						section.args.MaxAlpha.hidden = not value
					end
				end
			},
			Delay = {
				order = 110,
				type = "range",
				name = L["Fade Out Delay"],
				softMax = 3,
				hidden = not E.db.Minimalism[sectionName].UseFader,
				get = function(info)
					return E.db.Minimalism[sectionName].Delay
				end,
				set = function(info, value)
					E.db.Minimalism[sectionName].Delay = value
					onUpdate()
				end
			},
			Smooth = {
				order = 115,
				type = "range",
				name = L["Smooth"],
				min = 0,
				softMax = 1,
				hidden = not E.db.Minimalism[sectionName].UseFader,
				get = function(info)
					return E.db.Minimalism[sectionName].Smooth
				end,
				set = function(info, value)
					E.db.Minimalism[sectionName].Smooth = value
					onUpdate()
				end
			},
			MinAlpha = {
				order = 120,
				type = "range",
				name = L["Min Alpha"],
				max = 1,
				min = 0,
				hidden = not E.db.Minimalism[sectionName].UseFader,
				get = function(info)
					return E.db.Minimalism[sectionName].MinAlpha
				end,
				set = function(info, value)
					E.db.Minimalism[sectionName].MinAlpha = value
					onUpdate()
				end
			},
			MaxAlpha = {
				order = 130,
				type = "range",
				name = L["Max Alpha"],
				max = 1,
				min = 0,
				hidden = not E.db.Minimalism[sectionName].UseFader,
				get = function(info)
					return E.db.Minimalism[sectionName].MaxAlpha
				end,
				set = function(info, value)
					E.db.Minimalism[sectionName].MaxAlpha = value
					onUpdate()
				end
			},
		}
	}

	return section
end

--This function inserts our GUI table into the ElvUI Config. You can read about AceConfig here: http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
function Minimalism:InsertOptions()
	E.Options.args.Minimalism = {
		order = 100,
		type = "group",
		name = "Minimalism",
		args = {
			BuffsOptions = {
				order = 100,
				type = "header",
				name = L["Buffs and Debuffs"],
			},
			HideBuffsInCombat = {
				order = 110,
				type = "toggle",
				name = L["Hide Buffs In Combat"],
				get = function(info)
					return E.db.Minimalism.HideBuffsInCombat
				end,
				set = function(info, value)
					E.db.Minimalism.HideBuffsInCombat = value
					Minimalism:UpdateCombatVisibility() --We changed a setting, call our Update function
				end,
			},
			HideDebuffsInCombat = {
				order = 120,
				type = "toggle",
				name = L["Hide Debuffs In Combat"],
				get = function(info)
					return E.db.Minimalism.HideDebuffsInCombat
				end,
				set = function(info, value)
					E.db.Minimalism.HideDebuffsInCombat = value
					Minimalism:UpdateCombatVisibility() --We changed a setting, call our Update function
				end,
			},
			BuffsFader = faderSection(130, "BuffsFader", function() Minimalism:UpdateCombatVisibility() end),
			BuffsSpacer = {
				order = 199,
				type = "description",
				name = "\n\n\n",
				width = "full"
			},
			CampaignButtonOptions = {
				order = 200,
				type = "header",
				name = L["Minimap Buttons"]
			},
			HideLFGButton = {
				order = 210,
				type = "toggle",
				name = L["Show LFG Icon Only On Hover"],
				width = "double",
				get = function(info)
					return E.db.Minimalism.HideLFGButton
				end,
				set = function(info, value)
					E.db.Minimalism.HideLFGButton = value
					UpdateMinimapButtonVisibility()
				end
			},
			HideExpansionButton = {
				order = 220,
				type = "toggle",
				name = L["Show Expansion Button Only On Hover"],
				width = "double",
				hidden = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE,
				get = function(info)
					return E.db.Minimalism.HideExpansionButton
				end,
				set = function(info, value)
					E.db.Minimalism.HideExpansionButton = value
					UpdateMinimapButtonVisibility()
				end
			},
			HideTracking = {
				order = 230,
				type = "toggle",
				name = L["Show Tracking Only On Hover"],
				width = "double",
				get = function(info)
					return E.db.Minimalism.HideTracking
				end,
				set = function(info, value)
					E.db.Minimalism.HideTracking = value
					UpdateMinimapButtonVisibility()
				end
			},
			MinimapButtonsFader = faderSection(240, "MinimapButtonsFader", UpdateMinimapButtonVisibility);
		}
	}
end

function showOrFadeFrame(frame, faderOptions)
	if (not faderOptions.UseFader) then
		frame:Show()
	elseif (not faderOptions.IsVisible) then
		UIFrameFadeIn(frame, faderOptions.Smooth, faderOptions.MinAlpha, faderOptions.MaxAlpha, faderOptions.Delay)
	end

	faderOptions.IsVisible = true
end

function hideOrFadeFrame(frame, faderOptions)
	if (not faderOptions.UseFader) then
		frame:Hide()
	elseif faderOptions.IsVisible then
		UIFrameFadeOut(frame, faderOptions.Smooth, faderOptions.MaxAlpha, faderOptions.MinAlpha, faderOptions.Delay)
	end

	faderOptions.IsVisible = false
end

function Minimalism:UpdateCombatVisibility()
	local inCombat = UnitAffectingCombat("player")

	local buffsFrame = _G["ElvUIPlayerBuffs"]
	local debuffsFrame = _G["ElvUIPlayerDebuffs"]
	
	if E.db.Minimalism.HideBuffsInCombat and inCombat then
		hideOrFadeFrame(buffsFrame, E.db.Minimalism.BuffsFader)
	else
		showOrFadeFrame(buffsFrame, E.db.Minimalism.BuffsFader)
	end

	if E.db.Minimalism.HideDebuffsInCombat and inCombat then 
		hideOrFadeFrame(debuffsFrame, E.db.Minimalism.BuffsFader)
	else
		showOrFadeFrame(debuffsFrame, E.db.Minimalism.BuffsFader)
	end
end

function UpdateMinimapButtonVisibility()
	local LFGButton = _G["LFGMinimapFrame"]
	local ExpansionButton = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) and _G["ExpansionLandingPageMinimapButton"] or nil
	local TrackingButton = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) and _G.MinimapCluster.Tracking or _G["MiniMapTrackingIcon"]

	local isMouseOver = _G["Minimap"]:IsMouseOver()

	if LFGButton ~= nil then
		if E.db.Minimalism.HideLFGButton and not isMouseOver then
			hideOrFadeFrame(LFGButton, E.db.Minimalism.MinimapButtonsFader)
		else
			showOrFadeFrame(LFGButton, E.db.Minimalism.MinimapButtonsFader)
		end
	end

	if ExpansionButton ~= nil then
		if E.db.Minimalism.HideExpansionButton and not isMouseOver then
			hideOrFadeFrame(ExpansionButton, E.db.Minimalism.MinimapButtonsFader)
		else
			showOrFadeFrame(ExpansionButton, E.db.Minimalism.MinimapButtonsFader)
		end
	end

	if TrackingButton ~= nil then
		if E.db.Minimalism.HideTracking and not isMouseOver then
			hideOrFadeFrame(TrackingButton, E.db.Minimalism.MinimapButtonsFader)
		else
			showOrFadeFrame(TrackingButton, E.db.Minimalism.MinimapButtonsFader)
		end
	end
end

function Minimalism:OnEnteringWorld()
	UpdateMinimapButtonVisibility()
end

function Minimalism:Initialize()
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateCombatVisibility")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateCombatVisibility")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEnteringWorld")			-- needed because some elements we might want to hide load after this function is called

	_G["Minimap"]:HookScript("OnEnter", UpdateMinimapButtonVisibility)
	_G["Minimap"]:HookScript("OnLeave", UpdateMinimapButtonVisibility)

	Minimalism:UpdateCombatVisibility()
	UpdateMinimapButtonVisibility()

	--Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addonName, Minimalism.InsertOptions)
end

E:RegisterModule(Minimalism:GetName()) --Register the module with ElvUI. ElvUI will now call Minimalism:Initialize() when ElvUI is ready to load our plugin.
