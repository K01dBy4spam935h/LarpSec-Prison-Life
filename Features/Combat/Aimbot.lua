--[[
    LarpSec - Prison Life v1
    Features/Combat/Aimbot.lua
    RMB activated
]]

local Services = require("Core/Services.lua")
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local Players = Services.Players
local Camera = Services.Camera
local LocalPlayer = Services.LocalPlayer

local Aimbot = {}
Aimbot.Enabled = false
Aimbot.Holding = false
Aimbot.Config = nil
Aimbot.FOVCircle = nil
Aimbot.Connections = {}
Aimbot.Target = nil

local function createFOV()
    local circle = Drawing and Drawing.new("Circle")
    if not circle then return nil end
    circle.Thickness = 1.5
    circle.NumSides = 64
    circle.Radius = 150
    circle.Filled = false
    circle.Visible = false
    circle.ZIndex = 9
    return circle
end

function Aimbot:Init(config)
    self.Config = config
    self.FOVCircle = createFOV()

    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == self.Config.Key then
            self.Holding = true
        end
    end))
    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == self.Config.Key then
            self.Holding = false
        end
    end))
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        self:Update()
    end))
end

function Aimbot:IsValidTarget(player)
    if player == LocalPlayer then return false end
    if not Services.IsAlive(player) then return false end
    local team = Services.GetTeam(player)
    local filter = self.Config.TeamFilter
    if not filter[team] then return false end
    local root = Services.GetRoot(player)
    return root ~= nil
end

function Aimbot:GetClosest()
    local closest, closestDist = nil, self.Config.FOV
    local mousePos = UserInputService:GetMouseLocation()
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

function Aimbot:Update()
    if not self.FOVCircle then return end
    local cfg = self.Config
    self.FOVCircle.Visible = self.Enabled and cfg.FOVVisible
    if not self.Enabled then
        self.Target = nil
        return
    end

    local mouse = UserInputService:GetMouseLocation()
    self.FOVCircle.Position = mouse
    self.FOVCircle.Radius = cfg.FOV

    if cfg.Rainbow then
        local h = (tick() * 0.25 + 0.3) % 1
        self.FOVCircle.Color = Color3.fromHSV(h, 1, 1)
    else
        local c = cfg.FOVColor
        self.FOVCircle.Color = Color3.fromHSV(c.H, c.S, c.V)
    end

    if not self.Holding then
        self.Target = nil
        return
    end

    self.Target = self:GetClosest()
    if not self.Target then return end

    local part = self.Target.Character and self.Target.Character:FindFirstChild(cfg.TargetPart)
    if not part then
        part = Services.GetRoot(self.Target)
    end
    if not part then return end

    local goal = CFrame.lookAt(Camera.CFrame.Position, part.Position)
    local smoothness = math.clamp(cfg.Smoothness or 0.25, 0.05, 1)
    Camera.CFrame = Camera.CFrame:Lerp(goal, smoothness)
end

function Aimbot:SetEnabled(v)
    self.Enabled = v
end

function Aimbot:Destroy()
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
    if self.FOVCircle then
        pcall(function() self.FOVCircle:Remove() end)
    end
end

return Aimbot
