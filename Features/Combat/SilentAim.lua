--[[
    LarpSec - Prison Life v1
    Features/Combat/SilentAim.lua
]]

local Services = require(script.Parent.Parent.Parent.Core.Services)
local RunService = Services.RunService
local Players = Services.Players
local Camera = Services.Camera
local LocalPlayer = Services.LocalPlayer

local SilentAim = {}
SilentAim.Enabled = false
SilentAim.Config = nil
SilentAim.FOVCircle = nil
SilentAim.Connections = {}
SilentAim.Target = nil

local function createFOV()
    local circle = Drawing and Drawing.new("Circle")
    if not circle then return nil end
    circle.Thickness = 1.5
    circle.NumSides = 64
    circle.Radius = 120
    circle.Filled = false
    circle.Visible = false
    circle.ZIndex = 10
    return circle
end

function SilentAim:Init(config)
    self.Config = config
    self.FOVCircle = createFOV()
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        self:Update()
    end))
end

function SilentAim:IsValidTarget(player)
    if player == LocalPlayer then return false end
    if not Services.IsAlive(player) then return false end
    local team = Services.GetTeam(player)
    local filter = self.Config.TeamFilter
    if not filter[team] then return false end
    local root = Services.GetRoot(player)
    if not root then return false end
    local _, onScreen = Services.WorldToScreen(root.Position)
    return onScreen
end

function SilentAim:GetClosest()
    local closest, closestDist = nil, self.Config.FOV
    local mousePos = Services.UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if self:IsValidTarget(player) then
            local part = player.Character:FindFirstChild(self.Config.TargetPart) or Services.GetRoot(player)
            if part then
                local screen, onScreen = Services.WorldToScreen(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

function SilentAim:Update()
    if not self.FOVCircle then return end
    local cfg = self.Config
    self.FOVCircle.Visible = self.Enabled and cfg.FOVVisible
    if not self.Enabled then
        self.Target = nil
        return
    end

    local mouse = Services.UserInputService:GetMouseLocation()
    self.FOVCircle.Position = mouse
    self.FOVCircle.Radius = cfg.FOV

    if cfg.Rainbow then
        local h = (tick() * 0.3) % 1
        self.FOVCircle.Color = Color3.fromHSV(h, 1, 1)
    else
        local c = cfg.FOVColor
        self.FOVCircle.Color = Color3.fromHSV(c.H, c.S, c.V)
    end

    self.Target = self:GetClosest()
end

function SilentAim:GetAimPosition()
    if not self.Enabled or not self.Target then return nil end
    if math.random(1, 100) > self.Config.Hitchance then return nil end
    local part = self.Target.Character and self.Target.Character:FindFirstChild(self.Config.TargetPart)
    if not part then
        part = Services.GetRoot(self.Target)
    end
    if not part then return nil end
    local pos = part.Position
    local vel = part.AssemblyLinearVelocity or Vector3.zero
    pos = pos + vel * (self.Config.Prediction or 0.12)
    return pos
end

function SilentAim:SetEnabled(v)
    self.Enabled = v
end

function SilentAim:Destroy()
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
    if self.FOVCircle then
        pcall(function() self.FOVCircle:Remove() end)
    end
end

return SilentAim
