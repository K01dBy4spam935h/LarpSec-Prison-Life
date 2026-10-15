--[[
    LarpSec - Prison Life v1
    Features/Player/Movement.lua
    Speed (CFrame), Jump, InfJump, Noclip, Fly, VehicleFly, Invis
]]

local Services = require("Core/Services.lua")
local RunService = Services.RunService
local UserInputService = Services.UserInputService
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

local function setCharCollide(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = state
        end
    end
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
                    local power = hum.JumpPower > 0 and hum.JumpPower or 50
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, power, root.AssemblyLinearVelocity.Z)
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

    -- Noclip must run on Stepped (physics step) every frame while enabled
    table.insert(self.Connections, RunService.Stepped:Connect(function()
        if self.Noclip then
            setCharCollide(false)
        end
    end))

    table.insert(self.Connections, RunService.Heartbeat:Connect(function(dt)
        self:Tick(dt)
    end))

    -- re-apply noclip on respawn
    table.insert(self.Connections, LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.15)
        if self.Noclip then setCharCollide(false) end
        if self.InvisOn then self:SetInvis(true) end
    end))
end

function Movement:Tick(dt)
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end

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
            local speed = (self.Config.Speed.Value or 28) * (0.97 + math.random() * 0.06)
            root.CFrame = root.CFrame + dir * speed * dt
        end
    end

    if self.JumpOn then
        local jp = self.Config.JumpPower.Value or 60
        hum.JumpPower = jp
        pcall(function() hum.JumpHeight = jp / 7.5 end)
    end

    if self.FlyOn then
        self:DoFly(dt)
    end

    if self.VehicleFlyOn then
        self:DoVehicleFly(dt)
    end

    if self.InvisOn then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.LocalTransparencyModifier = 1
                end
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
    self.BodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
end

function Movement:StopFly()
    local hum = getHum()
    if hum then hum.PlatformStand = false end
    if self.BodyVel then pcall(function() self.BodyVel:Destroy() end) self.BodyVel = nil end
    if self.BodyGyro then pcall(function() self.BodyGyro:Destroy() end) self.BodyGyro = nil end
end

function Movement:DoVehicleFly(dt)
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
    end
end

function Movement:SetSpeed(v) self.SpeedOn = v end

function Movement:SetJump(v)
    self.JumpOn = v
    if not v then
        local hum = getHum()
        if hum then
            hum.JumpPower = 50
            pcall(function() hum.JumpHeight = 7.2 end)
        end
    end
end

function Movement:SetInfJump(v) self.InfJump = v end

function Movement:SetNoclip(v)
    self.Noclip = v
    if not v then
        setCharCollide(true)
        -- root should stay non-collide usually; force limbs on
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.CanCollide = false end
        end
    else
        setCharCollide(false)
    end
end

function Movement:SetFly(v)
    self.FlyOn = v
    if not v then self:StopFly() end
end

function Movement:SetVehicleFly(v) self.VehicleFlyOn = v end

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
