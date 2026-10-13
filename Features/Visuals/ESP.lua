--[[
    LarpSec - Prison Life v1
    Features/Visuals/ESP.lua
    Boxes, Chams, Names, Distance, Tracers with team colors
]]

local Services = require("Core/Services.lua")
local RunService = Services.RunService
local Players = Services.Players
local Camera = Services.Camera
local LocalPlayer = Services.LocalPlayer
local CoreGui = Services.CoreGui

local ESP = {}
ESP.Config = nil
ESP.Connections = {}
ESP.Drawings = {} -- [player] = { box, name, dist, tracer, chams }
ESP.Billboards = {}

local function newDrawing(class)
    if not Drawing then return nil end
    local ok, d = pcall(Drawing.new, class)
    return ok and d or nil
end

function ESP:Init(config)
    self.Config = config
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        self:Update()
    end))
    table.insert(self.Connections, Players.PlayerRemoving:Connect(function(p)
        self:RemovePlayer(p)
    end))
end

function ESP:RemovePlayer(player)
    if self.Drawings[player] then
        for _, d in pairs(self.Drawings[player]) do
            pcall(function()
                if typeof(d) == "Instance" then
                    d:Destroy()
                else
                    d:Remove()
                end
            end)
        end
        self.Drawings[player] = nil
    end
    if self.Billboards[player] then
        pcall(function() self.Billboards[player]:Destroy() end)
        self.Billboards[player] = nil
    end
end

function ESP:EnsureDrawings(player)
    if self.Drawings[player] then return self.Drawings[player] end
    local t = {}
    t.box = newDrawing("Square")
    if t.box then
        t.box.Thickness = 1.5
        t.box.Filled = false
        t.box.Visible = false
    end
    t.name = newDrawing("Text")
    if t.name then
        t.name.Size = 14
        t.name.Center = true
        t.name.Outline = true
        t.name.Visible = false
    end
    t.dist = newDrawing("Text")
    if t.dist then
        t.dist.Size = 12
        t.dist.Center = true
        t.dist.Outline = true
        t.dist.Visible = false
    end
    t.tracer = newDrawing("Line")
    if t.tracer then
        t.tracer.Thickness = 1.2
        t.tracer.Visible = false
    end
    self.Drawings[player] = t
    return t
end

function ESP:UpdateChams(player, teamColor)
    local char = player.Character
    if not char then return end
    if not self.Config.Chams then
        local hl = char:FindFirstChild("LarpSec_Chams")
        if hl then hl:Destroy() end
        return
    end
    local hl = char:FindFirstChild("LarpSec_Chams")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "LarpSec_Chams"
        hl.FillTransparency = 0.55
        hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end
    hl.FillColor = teamColor
    hl.OutlineColor = teamColor
    hl.Enabled = true
end

function ESP:Update()
    local cfg = self.Config
    local any = cfg.Boxes or cfg.Chams or cfg.Names or cfg.Distance or cfg.Tracers
    if not any then
        for p in pairs(self.Drawings) do
            self:RemovePlayer(p)
        end
        return
    end

    local mousePos = Services.UserInputService:GetMouseLocation()
    local viewport = Camera.ViewportSize
    local tracerOrigin
    if cfg.TracerOrigin == "Mouse" then
        tracerOrigin = mousePos
    elseif cfg.TracerOrigin == "Center" then
        tracerOrigin = Vector2.new(viewport.X / 2, viewport.Y / 2)
    else
        tracerOrigin = Vector2.new(viewport.X / 2, viewport.Y)
    end

    local myRoot = Services.GetRoot(LocalPlayer)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local team = Services.GetTeam(player)
        if not cfg.TeamFilter[team] then
            self:RemovePlayer(player)
            continue
        end
        if not Services.IsAlive(player) then
            self:RemovePlayer(player)
            continue
        end

        local root = Services.GetRoot(player)
        local head = player.Character and player.Character:FindFirstChild("Head")
        if not root then
            self:RemovePlayer(player)
            continue
        end

        local teamColor = Services.TeamColor(team)
        local drawings = self:EnsureDrawings(player)

        -- Distance check
        local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
        if dist > (cfg.MaxDistance or 2000) then
            for _, d in pairs(drawings) do
                if d and d.Visible ~= nil then d.Visible = false end
            end
            continue
        end

        local headPos = head and head.Position or (root.Position + Vector3.new(0, 2, 0))
        local footPos = root.Position - Vector3.new(0, 3, 0)
        local screenHead, onHead = Services.WorldToScreen(headPos)
        local screenFoot, onFoot = Services.WorldToScreen(footPos)
        local screenRoot, onRoot = Services.WorldToScreen(root.Position)

        -- Chams
        self:UpdateChams(player, teamColor)

        -- Box
        if drawings.box then
            if cfg.Boxes and (onHead or onFoot) then
                local height = math.abs(screenHead.Y - screenFoot.Y)
                local width = height * 0.55
                drawings.box.Size = Vector2.new(width, height)
                drawings.box.Position = Vector2.new(screenHead.X - width / 2, screenHead.Y)
                drawings.box.Color = teamColor
                drawings.box.Visible = true
            else
                drawings.box.Visible = false
            end
        end

        -- Name
        if drawings.name then
            if cfg.Names and onHead then
                local display
                if cfg.NameOrigin == "Username" then
                    display = player.Name
                else
                    display = player.DisplayName ~= player.Name and player.DisplayName or player.Name
                end
                drawings.name.Text = display
                drawings.name.Position = Vector2.new(screenHead.X, screenHead.Y - 18)
                drawings.name.Color = teamColor
                drawings.name.Visible = true
            else
                drawings.name.Visible = false
            end
        end

        -- Distance
        if drawings.dist then
            if cfg.Distance and onFoot then
                drawings.dist.Text = math.floor(dist) .. " studs"
                drawings.dist.Position = Vector2.new(screenFoot.X, screenFoot.Y + 4)
                drawings.dist.Color = teamColor
                drawings.dist.Visible = true
            else
                drawings.dist.Visible = false
            end
        end

        -- Tracer
        if drawings.tracer then
            if cfg.Tracers and onRoot then
                drawings.tracer.From = tracerOrigin
                drawings.tracer.To = Vector2.new(screenRoot.X, screenRoot.Y)
                drawings.tracer.Color = teamColor
                drawings.tracer.Visible = true
            else
                drawings.tracer.Visible = false
            end
        end
    end
end

function ESP:Destroy()
    for p in pairs(self.Drawings) do
        self:RemovePlayer(p)
    end
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
end

return ESP
