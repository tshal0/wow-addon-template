local _, WowAddonTemplate = ...
WowAddonTemplate = LibStub("AceAddon-3.0"):NewAddon(WowAddonTemplate, 
    "WowAddonTemplate", 
    "AceConsole-3.0", 
    "AceEvent-3.0", 
    "AceHook-3.0")
_G.WowAddonTemplate = WowAddonTemplate

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

local defaults = {
    profile = {
        modules = {
            ['*'] = {enabled = true, visible = true},
            moduleB = {enabled = false, visible = true}
        }
    }
}
function WowAddonTemplate:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WowAddonTemplateDB", defaults)
    WowAddonTemplate:Print("Version: {{VERSION}}")
end

function WowAddonTemplate:OnEnable()
end

function WowAddonTemplate:OnDisable() 
end
