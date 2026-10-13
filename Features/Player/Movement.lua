--[[
    LarpSec - Prison Life v1
    Features/Player/Movement.lua
    Speed (CFrame method for AC bypass), Jump, InfJump, Noclip, Fly, VehicleFly, Invis
]]

local Services = require("Core/Services.lua")
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local Players = Services.Players
local LocalPlayer = Services.LocalPlayer
local Workspace = Services.Workspace

local Movement = {}
Movement.Config = nil
Movement.Connections = {}
Movement.SpeedOn = false
Movement.JumpOn = false
Movement.InfJump = false
Movement.Noclip = false
Movement.FlyOn = false
Movement.VehicleFlyOn = false
Movement.InvisOn = false
Movement.BodyVel = nil
Movement.BodyGyro = nil
Movement.Keys = { W = false, A = false, S = false, D = false, Space = false, Ctrl = false }

local function getRoot()
    return Services.GetRoot(LocalPlayer)
end

local function getHum()
    return Services.GetHumanoid(LocalPlayer)
end

function Movement:Init(config)
    self.Config = config

    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then self.Keys.W = true end
        if input.KeyCode == Enum.KeyCode.A then self.Keys.A = true end
        if input.KeyCode == Enum.KeyCode.S then self.Keys.S = true end
        if input.KeyCode == Enum.KeyCode.D then self.Keys.D = true end
        if input.KeyCode == Enum.KeyCode.Space then
            self.Keys.Space = true
            if self.InfJump then
                local hum = getHum()
                local root = getRoot()
                if hum and root then
                    root.Velocity = Vector3.new(root.Velocity.X, hum.JumpPower > 0 and hum.JumpPower or 50, root.Velocity.Z)
                end
            end
        end
        if input.KeyCode == Enum.KeyCode.LeftControl then self.Keys.Ctrl = true end
    end))

    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then self.Keys.W = false end
        if input.KeyCode == Enum.KeyCode.A then self.Keys.A = false end
        if input.KeyCode == Enum.KeyCode.S then self.Keys.S = false end
        if input.KeyCode == Enum.KeyCode.D then self.Keys.D = false end
        if input.KeyCode == Enum.KeyCode.Space then self.Keys.Space = false end
        if input.KeyCode == Enum.KeyCode.LeftControl then self.Keys.Ctrl = false end
    end))

    table.insert(self.Connections, RunService.Heartbeat:Connect(function(dt)
        self:Tick(dt)
    end))

    table.insert(self.Connections, RunService.Stepped:Connect(function()
        if self.Noclip then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end))
end

function Movement:Tick(dt)
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end

    -- Speed via CFrame (safer than WalkSpeed property for PL detectors)
    if self.SpeedOn and not self.FlyOn then
        local cam = Workspace.CurrentCamera
        local dir = Vector3.zero
        if self.Keys.W then dir = dir + cam.CFrame.LookVector end
        if self.Keys.S then dir = dir - cam.CFrame.LookVector end
        if self.Keys.A then dir = dir - cam.CFrame.RightVector end
        if self.Keys.D then dir = dir + cam.CFrame.RightVector end
        dir = Vector3.new(dir.X, 0, dir.Z)
        if dir.Magnitude > 0 then
            dir = dir.Unit
            local speed = self.Config.Speed.Value or 28
            -- slight variance to look less robotic
            speed = speed * (0.97 + math.random() * 0.06)
            root.CFrame = root.CFrame + dir * speed * dt
        end
    end

    -- Jump power
    if self.JumpOn then
        hum.JumpPower = self.Config.JumpPower.Value or 60
        hum.JumpHeight = (self.Config.JumpPower.Value or 60) / 7.5
    end

    -- Fly
    if self.FlyOn then
        self:DoFly(dt)
    end

    -- Vehicle Fly
    if self.VehicleFlyOn then
        self:DoVehicleFly(dt)
    end

    -- Invisibility (client sided)
    if self.InvisOn then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.LocalTransparencyModifier = 1
            end
        end
    end
end

function Movement:DoFly(dt)
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end

    hum.PlatformStand = true

    if not self.BodyVel or not self.BodyVel.Parent then
        self.BodyVel = Instance.new("BodyVelocity")
        self.BodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        self.BodyVel.Velocity = Vector3.zero
        self.BodyVel.Parent = root
    end
    if not self.BodyGyro or not self.BodyGyro.Parent then
        self.BodyGyro = Instance.new("BodyGyro")
        self.BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        self.BodyGyro.P = 9e4
        self.BodyGyro.Parent = root
    end

    local cam = Workspace.CurrentCamera
    self.BodyGyro.CFrame = cam.CFrame

    local dir = Vector3.zero
    if self.Keys.W then dir = dir + cam.CFrame.LookVector end
    if self.Keys.S then dir = dir - cam.CFrame.LookVector end
    if self.Keys.A then dir = dir - cam.CFrame.RightVector end
    if self.Keys.D then dir = dir + cam.CFrame.RightVector end
    if self.Keys.Space then dir = dir + Vector3.new(0, 1, 0) end
    if self.Keys.Ctrl then dir = dir - Vector3.new(0, 1, 0) end

    local speed = self.Config.Fly.Speed or 50
    if dir.Magnitude > 0 then
        self.BodyVel.Velocity = dir.Unit * speed
    else
        self.BodyVel.Velocity = Vector3.zero
    end
end

function Movement:StopFly()
    local hum = getHum()
    if hum then hum.PlatformStand = false end
    if self.BodyVel then self.BodyVel:Destroy() self.BodyVel = nil end
    if self.BodyGyro then self.BodyGyro:Destroy() self.BodyGyro = nil end
end

function Movement:DoVehicleFly(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = getHum()
    if not hum or not hum.SeatPart then return end
    local seat = hum.SeatPart
    local vehicle = seat:FindFirstAncestorOfClass("Model") or seat.Parent
    if not vehicle then return end
    local primary = vehicle.PrimaryPart or vehicle:FindFirstChild("Chassis") or vehicle:FindFirstChildWhichIsA("BasePart")
    if not primary then return end

    local cam = Workspace.CurrentCamera
    local dir = Vector3.zero
    if self.Keys.W then dir = dir + cam.CFrame.LookVector end
    if self.Keys.S then dir = dir - cam.CFrame.LookVector end
    if self.Keys.A then dir = dir - cam.CFrame.RightVector end
    if self.Keys.D then dir = dir + cam.CFrame.RightVector end
    if self.Keys.Space then dir = dir + Vector3.new(0, 1, 0) end
    if self.Keys.Ctrl then dir = dir - Vector3.new(0, 1, 0) end

    local speed = self.Config.VehicleFly.Speed or 80
    if dir.Magnitude > 0 then
        primary.AssemblyLinearVelocity = dir.Unit * speed
        primary.CFrame = CFrame.lookAt(primary.Position, primary.Position + dir)
    end
end

function Movement:SetSpeed(v)
    self.SpeedOn = v
end

function Movement:SetJump(v)
    self.JumpOn = v
    if not v then
        local hum = getHum()
        if hum then
            hum.JumpPower = 50
            hum.JumpHeight = 7.2
        end
    end
end

function Movement:SetInfJump(v)
    self.InfJump = v
end

function Movement:SetNoclip(v)
    self.Noclip = v
    if not v then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

function Movement:SetFly(v)
    self.FlyOn = v
    if not v then
        self:StopFly()
    end
end

function Movement:SetVehicleFly(v)
    self.VehicleFlyOn = v
end

function Movement:SetInvis(v)
    self.InvisOn = v
    if not v then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.LocalTransparencyModifier = 0
                end
            end
        end
    end
end

function Movement:Destroy()
    self:SetFly(false)
    self:SetNoclip(false)
    self:SetSpeed(false)
    self:SetInvis(false)
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
end

return Movement
