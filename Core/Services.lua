--[[
    LarpSec - Prison Life v1
    Core/Services.lua
    Shared service references and utility helpers
]]

local Services = {}

Services.Players = game:GetService("Players")
Services.RunService = game:GetService("RunService")
Services.UserInputService = game:GetService("UserInputService")
Services.TweenService = game:GetService("TweenService")
Services.HttpService = game:GetService("HttpService")
Services.Lighting = game:GetService("Lighting")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Workspace = game:GetService("Workspace")
Services.CoreGui = game:GetService("CoreGui")
Services.Stats = game:GetService("Stats")
Services.GuiService = game:GetService("GuiService")
Services.TextService = game:GetService("TextService")
Services.Debris = game:GetService("Debris")

Services.LocalPlayer = Services.Players.LocalPlayer
Services.Camera = Services.Workspace.CurrentCamera
Services.Mouse = Services.LocalPlayer:GetMouse()

function Services.GetCharacter(player)
    player = player or Services.LocalPlayer
    return player and player.Character
end

function Services.GetHumanoid(player)
    local char = Services.GetCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Services.GetRoot(player)
    local char = Services.GetCharacter(player)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

function Services.GetTeam(player)
    player = player or Services.LocalPlayer
    if not player then return "Unknown" end
    local team = player.Team
    if team then
        local name = team.Name:lower()
        if name:find("guard") or name:find("police") then
            return "Guards"
        elseif name:find("inmate") or name:find("prisoner") then
            return "Inmates"
        elseif name:find("criminal") or name:find("citizen") then
            return "Criminals"
        end
        return team.Name
    end
    return "Unknown"
end

function Services.TeamColor(teamName)
    if teamName == "Guards" then
        return Color3.fromRGB(0, 120, 255)
    elseif teamName == "Inmates" then
        return Color3.fromRGB(255, 140, 0)
    elseif teamName == "Criminals" then
        return Color3.fromRGB(220, 40, 40)
    end
    return Color3.fromRGB(200, 200, 200)
end

function Services.IsAlive(player)
    local hum = Services.GetHumanoid(player)
    return hum and hum.Health > 0
end

function Services.WorldToScreen(worldPos)
    local screen, onScreen = Services.Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(screen.X, screen.Y), onScreen, screen.Z
end

function Services.GetPing()
    local ok, ping = pcall(function()
        return math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    return ok and ping or 0
end

function Services.GetFPS()
    return math.floor(1 / Services.RunService.RenderStepped:Wait())
end

return Services
