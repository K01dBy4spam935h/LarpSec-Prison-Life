--[[
    LarpSec - Prison Life v1
    Main.lua
    Entry point: wires config, features, UI
]]

local Services = require("Core/Services.lua")
local ConfigManager = require("Config/Manager.lua")
local Library = require("UI/Library.lua")

local SilentAim = require("Features/Combat/SilentAim.lua")
local Aimbot = require("Features/Combat/Aimbot.lua")
local Hitbox = require("Features/Combat/Hitbox.lua")
local AntiTase = require("Features/Combat/AntiTase.lua")
local GunHook = require("Features/Combat/GunHook.lua")

local ESP = require("Features/Visuals/ESP.lua")
local World = require("Features/Visuals/World.lua")

local Movement = require("Features/Player/Movement.lua")

local HUD = require("Features/Utility/HUD.lua")
local GunGrabber = require("Features/Utility/GunGrabber.lua")

-- Init config
ConfigManager:Init()
local CFG = ConfigManager:Get()

-- Init systems
SilentAim:Init(CFG.Combat.SilentAim)
Aimbot:Init(CFG.Combat.Aimbot)
Hitbox:Init(CFG.Combat.HitboxExpander)
AntiTase:Init()
GunHook:Init()

ESP:Init(CFG.Visuals.ESP)
World:Init()

Movement:Init(CFG.Player)

HUD:Init(CFG.Utility)
-- Apply saved HUD toggles
HUD:SetFPS(CFG.Utility.FPSHUD.Enabled)
HUD:SetPing(CFG.Utility.PingHUD.Enabled)

-- Apply saved states on load
SilentAim:SetEnabled(CFG.Combat.SilentAim.Enabled)
Aimbot:SetEnabled(CFG.Combat.Aimbot.Enabled)
Hitbox:SetEnabled(CFG.Combat.HitboxExpander.Enabled)
AntiTase:SetEnabled(CFG.Combat.AntiTase.Enabled)
World:SetFullbright(CFG.Visuals.Fullbright)
World:SetFPSBooster(CFG.Visuals.FPSBooster)
Movement:SetSpeed(CFG.Player.Speed.Enabled)
Movement:SetJump(CFG.Player.JumpPower.Enabled)
Movement:SetInfJump(CFG.Player.InfiniteJump)
Movement:SetNoclip(CFG.Player.Noclip)
Movement:SetFly(CFG.Player.Fly.Enabled)
Movement:SetVehicleFly(CFG.Player.VehicleFly.Enabled)
Movement:SetInvis(CFG.Player.Invisibility)

-- Build UI
local UI = Library.new("LarpSec · Prison Life v1")
UI:SetAccent(Color3.fromRGB(CFG.Settings.UIAccent.R, CFG.Settings.UIAccent.G, CFG.Settings.UIAccent.B))

-- ========== COMBAT TAB ==========
local combatTab = UI:CreateTab("Combat")
UI:CreateSection(combatTab, "Silent Aim")
UI:CreateToggle(combatTab, "Enabled", CFG.Combat.SilentAim.Enabled, function(v)
    CFG.Combat.SilentAim.Enabled = v
    SilentAim:SetEnabled(v)
end)
UI:CreateSlider(combatTab, "FOV", 20, 400, CFG.Combat.SilentAim.FOV, function(v)
    CFG.Combat.SilentAim.FOV = v
end)
UI:CreateSlider(combatTab, "Hitchance %", 1, 100, CFG.Combat.SilentAim.Hitchance, function(v)
    CFG.Combat.SilentAim.Hitchance = v
end)
UI:CreateToggle(combatTab, "Show FOV", CFG.Combat.SilentAim.FOVVisible, function(v)
    CFG.Combat.SilentAim.FOVVisible = v
end)
UI:CreateToggle(combatTab, "Rainbow FOV", CFG.Combat.SilentAim.Rainbow, function(v)
    CFG.Combat.SilentAim.Rainbow = v
end)
UI:CreateColorCanvas(combatTab, "FOV Color", CFG.Combat.SilentAim.FOVColor, function(hsv)
    CFG.Combat.SilentAim.FOVColor = hsv
end)
UI:CreateDropdown(combatTab, "Target Part", {"Head", "Torso", "HumanoidRootPart"}, CFG.Combat.SilentAim.TargetPart, function(v)
    CFG.Combat.SilentAim.TargetPart = v
end)
UI:CreateSection(combatTab, "Silent Aim Teams")
UI:CreateToggle(combatTab, "Target Guards", CFG.Combat.SilentAim.TeamFilter.Guards, function(v)
    CFG.Combat.SilentAim.TeamFilter.Guards = v
end)
UI:CreateToggle(combatTab, "Target Inmates", CFG.Combat.SilentAim.TeamFilter.Inmates, function(v)
    CFG.Combat.SilentAim.TeamFilter.Inmates = v
end)
UI:CreateToggle(combatTab, "Target Criminals", CFG.Combat.SilentAim.TeamFilter.Criminals, function(v)
    CFG.Combat.SilentAim.TeamFilter.Criminals = v
end)

UI:CreateSection(combatTab, "Aimbot (RMB)")
UI:CreateToggle(combatTab, "Enabled", CFG.Combat.Aimbot.Enabled, function(v)
    CFG.Combat.Aimbot.Enabled = v
    Aimbot:SetEnabled(v)
end)
UI:CreateSlider(combatTab, "Aimbot FOV", 20, 500, CFG.Combat.Aimbot.FOV, function(v)
    CFG.Combat.Aimbot.FOV = v
end)
UI:CreateSlider(combatTab, "Smoothness", 5, 100, math.floor((CFG.Combat.Aimbot.Smoothness or 0.25) * 100), function(v)
    CFG.Combat.Aimbot.Smoothness = v / 100
end)
UI:CreateToggle(combatTab, "Show FOV", CFG.Combat.Aimbot.FOVVisible, function(v)
    CFG.Combat.Aimbot.FOVVisible = v
end)
UI:CreateToggle(combatTab, "Rainbow FOV", CFG.Combat.Aimbot.Rainbow, function(v)
    CFG.Combat.Aimbot.Rainbow = v
end)
UI:CreateColorCanvas(combatTab, "FOV Color", CFG.Combat.Aimbot.FOVColor, function(hsv)
    CFG.Combat.Aimbot.FOVColor = hsv
end)
UI:CreateSection(combatTab, "Aimbot Teams")
UI:CreateToggle(combatTab, "Target Guards", CFG.Combat.Aimbot.TeamFilter.Guards, function(v)
    CFG.Combat.Aimbot.TeamFilter.Guards = v
end)
UI:CreateToggle(combatTab, "Target Inmates", CFG.Combat.Aimbot.TeamFilter.Inmates, function(v)
    CFG.Combat.Aimbot.TeamFilter.Inmates = v
end)
UI:CreateToggle(combatTab, "Target Criminals", CFG.Combat.Aimbot.TeamFilter.Criminals, function(v)
    CFG.Combat.Aimbot.TeamFilter.Criminals = v
end)

UI:CreateSection(combatTab, "Hitbox Expander")
UI:CreateToggle(combatTab, "Enabled", CFG.Combat.HitboxExpander.Enabled, function(v)
    CFG.Combat.HitboxExpander.Enabled = v
    Hitbox:SetEnabled(v)
end)
UI:CreateSlider(combatTab, "Size", 2, 30, CFG.Combat.HitboxExpander.Size, function(v)
    CFG.Combat.HitboxExpander.Size = v
end)
UI:CreateSlider(combatTab, "Transparency", 0, 100, math.floor((CFG.Combat.HitboxExpander.Transparency or 0.6) * 100), function(v)
    CFG.Combat.HitboxExpander.Transparency = v / 100
end)
UI:CreateToggle(combatTab, "Show Visuals", CFG.Combat.HitboxExpander.ShowVisual, function(v)
    CFG.Combat.HitboxExpander.ShowVisual = v
end)
UI:CreateToggle(combatTab, "Hitbox Guards", CFG.Combat.HitboxExpander.TeamFilter.Guards, function(v)
    CFG.Combat.HitboxExpander.TeamFilter.Guards = v
end)
UI:CreateToggle(combatTab, "Hitbox Inmates", CFG.Combat.HitboxExpander.TeamFilter.Inmates, function(v)
    CFG.Combat.HitboxExpander.TeamFilter.Inmates = v
end)
UI:CreateToggle(combatTab, "Hitbox Criminals", CFG.Combat.HitboxExpander.TeamFilter.Criminals, function(v)
    CFG.Combat.HitboxExpander.TeamFilter.Criminals = v
end)

UI:CreateSection(combatTab, "Other")
UI:CreateToggle(combatTab, "Anti-Tase", CFG.Combat.AntiTase.Enabled, function(v)
    CFG.Combat.AntiTase.Enabled = v
    AntiTase:SetEnabled(v)
end)

-- ========== VISUALS TAB ==========
local visTab = UI:CreateTab("Visuals")
UI:CreateSection(visTab, "ESP")
UI:CreateToggle(visTab, "Boxes", CFG.Visuals.ESP.Boxes, function(v)
    CFG.Visuals.ESP.Boxes = v
end)
UI:CreateToggle(visTab, "Chams", CFG.Visuals.ESP.Chams, function(v)
    CFG.Visuals.ESP.Chams = v
end)
UI:CreateToggle(visTab, "Names", CFG.Visuals.ESP.Names, function(v)
    CFG.Visuals.ESP.Names = v
end)
UI:CreateDropdown(visTab, "Name Origin", {"DisplayName", "Username"}, CFG.Visuals.ESP.NameOrigin, function(v)
    CFG.Visuals.ESP.NameOrigin = v
end)
UI:CreateToggle(visTab, "Distance", CFG.Visuals.ESP.Distance, function(v)
    CFG.Visuals.ESP.Distance = v
end)
UI:CreateToggle(visTab, "Tracers", CFG.Visuals.ESP.Tracers, function(v)
    CFG.Visuals.ESP.Tracers = v
end)
UI:CreateDropdown(visTab, "Tracer Origin", {"Bottom", "Center", "Mouse"}, CFG.Visuals.ESP.TracerOrigin, function(v)
    CFG.Visuals.ESP.TracerOrigin = v
end)
UI:CreateSlider(visTab, "Max Distance", 100, 5000, CFG.Visuals.ESP.MaxDistance, function(v)
    CFG.Visuals.ESP.MaxDistance = v
end)
UI:CreateSection(visTab, "ESP Teams")
UI:CreateToggle(visTab, "Show Guards", CFG.Visuals.ESP.TeamFilter.Guards, function(v)
    CFG.Visuals.ESP.TeamFilter.Guards = v
end)
UI:CreateToggle(visTab, "Show Inmates", CFG.Visuals.ESP.TeamFilter.Inmates, function(v)
    CFG.Visuals.ESP.TeamFilter.Inmates = v
end)
UI:CreateToggle(visTab, "Show Criminals", CFG.Visuals.ESP.TeamFilter.Criminals, function(v)
    CFG.Visuals.ESP.TeamFilter.Criminals = v
end)

UI:CreateSection(visTab, "World")
UI:CreateToggle(visTab, "Fullbright", CFG.Visuals.Fullbright, function(v)
    CFG.Visuals.Fullbright = v
    World:SetFullbright(v)
end)
UI:CreateToggle(visTab, "FPS Booster", CFG.Visuals.FPSBooster, function(v)
    CFG.Visuals.FPSBooster = v
    World:SetFPSBooster(v)
end)

-- ========== PLAYER TAB ==========
local playerTab = UI:CreateTab("Player")
UI:CreateSection(playerTab, "Speed (CFrame method)")
UI:CreateToggle(playerTab, "Enabled", CFG.Player.Speed.Enabled, function(v)
    CFG.Player.Speed.Enabled = v
    Movement:SetSpeed(v)
end)
UI:CreateSlider(playerTab, "Speed Value", 16, 120, CFG.Player.Speed.Value, function(v)
    CFG.Player.Speed.Value = v
end)

UI:CreateSection(playerTab, "Jump")
UI:CreateToggle(playerTab, "Jump Power", CFG.Player.JumpPower.Enabled, function(v)
    CFG.Player.JumpPower.Enabled = v
    Movement:SetJump(v)
end)
UI:CreateSlider(playerTab, "Jump Value", 50, 200, CFG.Player.JumpPower.Value, function(v)
    CFG.Player.JumpPower.Value = v
end)
UI:CreateToggle(playerTab, "Infinite Jump", CFG.Player.InfiniteJump, function(v)
    CFG.Player.InfiniteJump = v
    Movement:SetInfJump(v)
end)

UI:CreateSection(playerTab, "Movement")
UI:CreateToggle(playerTab, "Noclip", CFG.Player.Noclip, function(v)
    CFG.Player.Noclip = v
    Movement:SetNoclip(v)
end)
UI:CreateToggle(playerTab, "Fly", CFG.Player.Fly.Enabled, function(v)
    CFG.Player.Fly.Enabled = v
    Movement:SetFly(v)
end)
UI:CreateSlider(playerTab, "Fly Speed", 10, 200, CFG.Player.Fly.Speed, function(v)
    CFG.Player.Fly.Speed = v
end)
UI:CreateToggle(playerTab, "Vehicle Fly", CFG.Player.VehicleFly.Enabled, function(v)
    CFG.Player.VehicleFly.Enabled = v
    Movement:SetVehicleFly(v)
end)
UI:CreateSlider(playerTab, "Vehicle Speed", 20, 300, CFG.Player.VehicleFly.Speed, function(v)
    CFG.Player.VehicleFly.Speed = v
end)
UI:CreateToggle(playerTab, "Invisibility (Client)", CFG.Player.Invisibility, function(v)
    CFG.Player.Invisibility = v
    Movement:SetInvis(v)
end)

-- ========== UTILITY TAB ==========
local utilTab = UI:CreateTab("Utility")
UI:CreateSection(utilTab, "HUD")
UI:CreateToggle(utilTab, "FPS Box", CFG.Utility.FPSHUD.Enabled, function(v)
    CFG.Utility.FPSHUD.Enabled = v
    HUD:SetFPS(v)
end)
UI:CreateToggle(utilTab, "Ping Box", CFG.Utility.PingHUD.Enabled, function(v)
    CFG.Utility.PingHUD.Enabled = v
    HUD:SetPing(v)
end)

UI:CreateSection(utilTab, "Gun Grabber")
local gunList = GunGrabber:GetGunList()
UI:CreateDropdown(utilTab, "Gun", gunList, CFG.Utility.GunGrabber.Selected or "AK-47", function(v)
    CFG.Utility.GunGrabber.Selected = v
end)
UI:CreateButton(utilTab, "Grab Gun", function()
    GunGrabber:Grab(CFG.Utility.GunGrabber.Selected or "AK-47")
end)
UI:CreateLabel(utilTab, "Uses ItemHandler — no teleport")

-- ========== SETTINGS TAB ==========
local setTab = UI:CreateTab("Settings")
UI:CreateSection(setTab, "Config")
UI:CreateDropdown(setTab, "Config", (function()
    ConfigManager:RefreshList()
    local list = ConfigManager.Configs
    if #list == 0 then list = {"default"} end
    return list
end)(), CFG.Settings.ConfigName or "default", function(v)
    CFG.Settings.ConfigName = v
end)
UI:CreateButton(setTab, "Save Config", function()
    local name = CFG.Settings.ConfigName or "default"
    ConfigManager:Save(name)
end)
UI:CreateButton(setTab, "Load Config", function()
    local name = CFG.Settings.ConfigName or "default"
    if ConfigManager:Load(name) then
        -- soft reload notice — full live rebind would require UI rebuild
        CFG = ConfigManager:Get()
    end
end)
UI:CreateButton(setTab, "Save As New...", function()
    local name = "cfg_" .. tostring(math.floor(tick()) % 100000)
    CFG.Settings.ConfigName = name
    ConfigManager:Save(name)
end)

UI:CreateSection(setTab, "UI")
UI:CreateColorCanvas(setTab, "Accent Color", {
    H = 0.55, S = 1, V = 1
}, function(hsv)
    local c = Color3.fromHSV(hsv.H, hsv.S, hsv.V)
    CFG.Settings.UIAccent = { R = math.floor(c.R * 255), G = math.floor(c.G * 255), B = math.floor(c.B * 255) }
    UI:SetAccent(c)
end)
UI:CreateDropdown(setTab, "Font", {"Gotham", "GothamMedium", "SourceSans", "Arial"}, CFG.Settings.UIFont or "Gotham", function(v)
    CFG.Settings.UIFont = v
end)

UI:CreateSection(setTab, "Session")
UI:CreateButton(setTab, "Unload LarpSec", function()
    SilentAim:Destroy()
    Aimbot:Destroy()
    Hitbox:Destroy()
    AntiTase:Destroy()
    ESP:Destroy()
    World:Destroy()
    Movement:Destroy()
    HUD:Destroy()
    UI:Unload()
end)

print("[LarpSec] Prison Life v1 loaded.")
