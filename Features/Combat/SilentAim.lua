--[[
    LarpSec - Prison Life v1
    Features/Combat/SilentAim.lua
    Target is the HitPart (BasePart), not the Player — matches PL ShootEvent format
]]

local Services = require("Core/Services.lua")
local RunService = Services.RunService
local Players = Services.Players
local Camera = Services.Camera
local LocalPlayer = Services.LocalPlayer
local UserInputService = Services.UserInputService

local SilentAim = {}
SilentAim.Enabled = false
SilentAim.Config = nil
SilentAim.FOVCircle = nil
SilentAim.Connections = {}
SilentAim.Target = nil -- BasePart (Head / Torso / etc.)

local function createFOV()
    if not Drawing then return nil end
    local ok, circle = pcall(Drawing.new, "Circle")
    if not ok or not circle then return nil end
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
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        self:Update()
    end))
end

function SilentAim:IsValidPlayer(player)
    if player == LocalPlayer then return false end
    if not Services.IsAlive(player) then return false end
    local char = player.Character
    if not char or char:FindFirstChildOfClass("ForceField") then return false end
    local team = Services.GetTeam(player)
    local filter = self.Config.TeamFilter
    if not filter[team] then return false end
    return true
end

function SilentAim:GetClosestPart()
    local closestPart, closestDist = nil, self.Config.FOV or 120
    local mousePos = UserInputService:GetMouseLocation()
    local partName = self.Config.TargetPart or "Head"

    for _, player in ipairs(Players:GetPlayers()) do
        if self:IsValidPlayer(player) then
            local char = player.Character
            local part = char and (char:FindFirstChild(partName) or char:FindFirstChild("Head") or Services.GetRoot(player))
            if part then
                local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPart = part
                    end
                end
            end
        end
    end
    return closestPart
end

function SilentAim:Update()
    local cfg = self.Config
    if not cfg then return end

    if self.FOVCircle then
        self.FOVCircle.Visible = self.Enabled and cfg.FOVVisible
        if self.Enabled then
            self.FOVCircle.Position = UserInputService:GetMouseLocation()
            self.FOVCircle.Radius = cfg.FOV
            if cfg.Rainbow then
                self.FOVCircle.Color = Color3.fromHSV((tick() * 0.3) % 1, 1, 1)
            else
                local c = cfg.FOVColor
                self.FOVCircle.Color = Color3.fromHSV(c.H, c.S, c.V)
            end
        end
    end

    if not self.Enabled then
        self.Target = nil
        return
    end

    self.Target = self:GetClosestPart()
end

-- hitchance gate used by GunHook
function SilentAim:ShouldHit()
    if not self.Enabled or not self.Target then return false end
    local hc = self.Config.Hitchance or 100
    if hc >= 100 then return true end
    return math.random(1, 100) <= hc
end

function SilentAim:SetEnabled(v)
    self.Enabled = v
    if not v then self.Target = nil end
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
