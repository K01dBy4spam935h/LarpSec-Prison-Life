--[[
    LarpSec - Prison Life v1
    Features/Combat/Hitbox.lua
    Hitbox expander with team-colored visuals
]]

local Services = require("Core/Services.lua")
local RunService = Services.RunService
local Players = Services.Players
local LocalPlayer = Services.LocalPlayer

local Hitbox = {}
Hitbox.Enabled = false
Hitbox.Config = nil
Hitbox.Connections = {}
Hitbox.Visuals = {}
Hitbox.OriginalSizes = {}

function Hitbox:Init(config)
    self.Config = config
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        self:Update()
    end))
    table.insert(self.Connections, Players.PlayerRemoving:Connect(function(p)
        self:CleanupPlayer(p)
    end))
end

function Hitbox:CleanupPlayer(player)
    if self.Visuals[player] then
        for _, v in pairs(self.Visuals[player]) do
            pcall(function() v:Destroy() end)
        end
        self.Visuals[player] = nil
    end
    self.OriginalSizes[player] = nil
end

function Hitbox:IsValid(player)
    if player == LocalPlayer then return false end
    if not Services.IsAlive(player) then return false end
    local team = Services.GetTeam(player)
    return self.Config.TeamFilter[team] == true
end

function Hitbox:Expand(player)
    local char = player.Character
    if not char then return end
    local parts = {"Head", "Torso", "UpperTorso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
                   "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
                   "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg"}
    if not self.OriginalSizes[player] then
        self.OriginalSizes[player] = {}
    end
    if not self.Visuals[player] then
        self.Visuals[player] = {}
    end

    local size = self.Config.Size or 8
    local team = Services.GetTeam(player)
    local color = Services.TeamColor(team)

    for _, name in ipairs(parts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if not self.OriginalSizes[player][name] then
                self.OriginalSizes[player][name] = part.Size
            end
            part.Size = Vector3.new(size, size, size)
            part.Transparency = math.clamp(self.Config.Transparency or 0.6, 0, 1)
            part.CanCollide = false
            part.Massless = true

            if self.Config.ShowVisual then
                if not self.Visuals[player][name] or not self.Visuals[player][name].Parent then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "LarpSec_Hitbox"
                    box.Adornee = part
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Size = part.Size
                    box.Color3 = color
                    box.Transparency = 0.55
                    box.Parent = part
                    self.Visuals[player][name] = box
                else
                    local box = self.Visuals[player][name]
                    box.Size = part.Size
                    box.Color3 = color
                end
            end
        end
    end
end

function Hitbox:Restore(player)
    local char = player.Character
    if not char or not self.OriginalSizes[player] then return end
    for name, size in pairs(self.OriginalSizes[player]) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            part.Size = size
            part.Transparency = 0
        end
    end
    if self.Visuals[player] then
        for _, v in pairs(self.Visuals[player]) do
            pcall(function() v:Destroy() end)
        end
        self.Visuals[player] = {}
    end
end

function Hitbox:Update()
    if not self.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if self.OriginalSizes[player] then
                self:Restore(player)
                self.OriginalSizes[player] = nil
            end
        end
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if self:IsValid(player) then
            self:Expand(player)
        else
            if self.OriginalSizes[player] then
                self:Restore(player)
                self.OriginalSizes[player] = nil
            end
        end
    end
end

function Hitbox:SetEnabled(v)
    self.Enabled = v
    if not v then
        for _, player in ipairs(Players:GetPlayers()) do
            self:Restore(player)
            self.OriginalSizes[player] = nil
        end
    end
end

function Hitbox:Destroy()
    self:SetEnabled(false)
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
end

return Hitbox
