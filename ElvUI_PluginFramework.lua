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
P["Minimalism"] = {
	["HideBuffsInCombat"] = false,
	["HideDebuffsInCombat"] = false,
	["HideLFGButton"] = false,
	["HideCampaignButton"] = false,
	["HideTracker"] = false
}

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
				name = "Buffs and Debuffs",
			},
			HideBuffsInCombat = {
				order = 110,
				type = "toggle",
				name = "Hide Buffs In Combat",
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
				name = "Hide Debuffs In Combat",
				get = function(info)
					return E.db.Minimalism.HideDebuffsInCombat
				end,
				set = function(info, value)
					E.db.Minimalism.HideDebuffsInCombat = value
					Minimalism:UpdateCombatVisibility() --We changed a setting, call our Update function
				end,
			},
			CampaignButtonOptions = {
				order = 200,
				type = "header",
				name = "Minimap Buttons"
			},
			HideLFGButton = {
				order = 210,
				type = "toggle",
				name = "Show LFG Icon Only On Hover",
				get = function(info)
					return E.db.Minimalism.HideLFGButton
				end,
				set = function(info, value)
					E.db.Minimalism.HideLFGButton = value
					UpdateMinimapButtonVisibility()
				end
			},
			HideCampaignButton = {
				order = 220,
				type = "toggle",
				name = "Show Campaign Button Only On Hover",
				width = "full",
				hidden = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE,
				get = function(info)
					return E.db.Minimalism.HideCampaignButton
				end,
				set = function(info, value)
					E.db.Minimalism.HideCampaignButton = value
					UpdateMinimapButtonVisibility()
				end
			},
			HideTracker = {
				order = 230,
				type = "toggle",
				name = "Show Tracker Only On Hover",
				hidden = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE,
				get = function(info)
					return E.db.Minimalism.HideTracker
				end,
				set = function(info, value)
					E.db.Minimalism.HideTracker = value
					UpdateMinimapButtonVisibility()
				end
			}
		}
	}
end

function Minimalism:UpdateCombatVisibility()
	local inCombat = UnitAffectingCombat("player")

	local buffsFrame = _G["ElvUIPlayerBuffs"]
	local debuffsFrame = _G["ElvUIPlayerDebuffs"]
	
	if E.db.Minimalism.HideBuffsInCombat and inCombat then
		buffsFrame:Hide()
	else
		buffsFrame:Show()
	end

	if E.db.Minimalism.HideDebuffsInCombat and inCombat then 
		debuffsFrame:Hide()
	else
		debuffsFrame:Show()
	end
end

function UpdateMinimapButtonVisibility()
	local LFGButton = _G["LFGMinimapFrame"]
	local isMouseOver = _G["Minimap"]:IsMouseOver()

	if LFGButton ~= nil then
		if E.db.Minimalism.HideLFGButton and not isMouseOver then
			LFGButton:Hide()
		else
			LFGButton:Show()
		end
	end
	
end


function Minimalism:Initialize()
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateCombatVisibility")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateCombatVisibility")	

	_G["Minimap"]:HookScript("OnEnter", UpdateMinimapButtonVisibility)
	_G["Minimap"]:HookScript("OnLeave", UpdateMinimapButtonVisibility)

	Minimalism:UpdateCombatVisibility()
	UpdateMinimapButtonVisibility()

	--Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addonName, Minimalism.InsertOptions)
end

E:RegisterModule(Minimalism:GetName()) --Register the module with ElvUI. ElvUI will now call Minimalism:Initialize() when ElvUI is ready to load our plugin.
