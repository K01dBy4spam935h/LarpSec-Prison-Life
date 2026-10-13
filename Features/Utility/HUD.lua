--[[
    LarpSec - Prison Life v1
    Features/Utility/HUD.lua
    Draggable FPS + Ping boxes (ping mimics Roblox official)
]]

local Services = require("Core/Services.lua")
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local Players = Services.Players
local CoreGui = Services.CoreGui
local Stats = Services.Stats

local HUD = {}
HUD.Connections = {}
HUD.FPSFrame = nil
HUD.PingFrame = nil
HUD.FPSEnabled = true
HUD.PingEnabled = true
HUD.FPSLabel = nil
HUD.PingLabel = nil

local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function createBox(name, pos, parent)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(0, 90, 0, 28)
    frame.Position = pos
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = frame

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(45, 45, 50)
    s.Thickness = 1
    s.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(230, 230, 235)
    lbl.Text = name
    lbl.Parent = frame

    makeDraggable(frame)
    return frame, lbl
end

function HUD:Init(config)
    local gui = Instance.new("ScreenGui")
    gui.Name = "LarpSec_HUD"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    self.Gui = gui

    local fpsPos = UDim2.new(0, (config.FPSHUD and config.FPSHUD.Position.X) or 20, 0, (config.FPSHUD and config.FPSHUD.Position.Y) or 20)
    local pingPos = UDim2.new(0, (config.PingHUD and config.PingHUD.Position.X) or 20, 0, (config.PingHUD and config.PingHUD.Position.Y) or 56)

    self.FPSFrame, self.FPSLabel = createBox("FPS", fpsPos, gui)
    self.PingFrame, self.PingLabel = createBox("Ping", pingPos, gui)

    local frames = {}
    local last = tick()
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        local now = tick()
        table.insert(frames, now)
        while frames[1] and now - frames[1] > 1 do
            table.remove(frames, 1)
        end
        local fps = #frames
        if self.FPSEnabled and self.FPSLabel then
            self.FPSLabel.Text = fps .. " FPS"
            if fps >= 55 then
                self.FPSLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
            elseif fps >= 30 then
                self.FPSLabel.TextColor3 = Color3.fromRGB(230, 200, 60)
            else
                self.FPSLabel.TextColor3 = Color3.fromRGB(230, 80, 80)
            end
        end

        -- Official-style ping (Data Ping from Stats)
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if self.PingEnabled and self.PingLabel then
            self.PingLabel.Text = ping .. " ms"
            if ping < 80 then
                self.PingLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
            elseif ping < 150 then
                self.PingLabel.TextColor3 = Color3.fromRGB(230, 200, 60)
            else
                self.PingLabel.TextColor3 = Color3.fromRGB(230, 80, 80)
            end
        end
    end))
end

function HUD:SetFPS(v)
    self.FPSEnabled = v
    if self.FPSFrame then self.FPSFrame.Visible = v end
end

function HUD:SetPing(v)
    self.PingEnabled = v
    if self.PingFrame then self.PingFrame.Visible = v end
end

function HUD:Destroy()
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
    if self.Gui then self.Gui:Destroy() end
end

return HUD
