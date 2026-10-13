--[[
    LarpSec - Prison Life v1
    Features/Visuals/World.lua
    Fullbright + FPS Booster
]]

local Services = require(script.Parent.Parent.Parent.Core.Services)
local Lighting = Services.Lighting
local Workspace = Services.Workspace

local World = {}
World.Fullbright = false
World.FPSBooster = false
World.Original = {}
World.Connections = {}

function World:Init()
    self.Original.Brightness = Lighting.Brightness
    self.Original.ClockTime = Lighting.ClockTime
    self.Original.FogEnd = Lighting.FogEnd
    self.Original.GlobalShadows = Lighting.GlobalShadows
    self.Original.OutdoorAmbient = Lighting.OutdoorAmbient
    self.Original.Ambient = Lighting.Ambient
end

function World:SetFullbright(v)
    self.Fullbright = v
    if v then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = self.Original.Brightness
        Lighting.ClockTime = self.Original.ClockTime
        Lighting.FogEnd = self.Original.FogEnd
        Lighting.GlobalShadows = self.Original.GlobalShadows
        Lighting.OutdoorAmbient = self.Original.OutdoorAmbient
        Lighting.Ambient = self.Original.Ambient
    end
end

function World:SetFPSBooster(v)
    self.FPSBooster = v
    if v then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj.Enabled = false
                end
                if obj:IsA("Explosion") then
                    obj:Destroy()
                end
            end
        end)
        -- Reduce post effects
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect")
                or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
                effect.Enabled = false
            end
        end
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end
end

function World:Destroy()
    self:SetFullbright(false)
    self:SetFPSBooster(false)
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
end

return World
