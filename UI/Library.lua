--[[
    LarpSec - Prison Life v1
    UI/Library.lua
    Custom Rayfield-inspired UI framework (no external loadstring)
]]

local Services = require(script.Parent.Parent.Core.Services)
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local Players = Services.Players
local CoreGui = Services.CoreGui

local Library = {}
Library.__index = Library

local ACCENT = Color3.fromRGB(0, 200, 255)
local BG = Color3.fromRGB(20, 20, 22)
local BG2 = Color3.fromRGB(28, 28, 32)
local BORDER = Color3.fromRGB(45, 45, 50)
local TEXT = Color3.fromRGB(230, 230, 235)
local TEXT_DIM = Color3.fromRGB(140, 140, 150)

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or BORDER
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

function Library.new(title)
    local self = setmetatable({}, Library)
    self.Accent = ACCENT
    self.Font = Enum.Font.Gotham
    self.FontMedium = Enum.Font.GothamMedium
    self.Tabs = {}
    self.CurrentTab = nil
    self.Minimized = false
    self.Connections = {}
    self.Open = true

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "LarpSec_PrisonLife"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    pcall(function()
        gui.Parent = CoreGui
    end)
    if not gui.Parent then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    self.Gui = gui

    -- Main Window
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 580, 0, 420)
    main.Position = UDim2.new(0.5, -290, 0.5, -210)
    main.BackgroundColor3 = BG
    main.BackgroundTransparency = 0.12
    main.BorderSizePixel = 0
    main.Parent = gui
    corner(main, 10)
    stroke(main, BORDER, 1.5)
    self.Main = main

    -- Top Bar
    local top = Instance.new("Frame")
    top.Name = "TopBar"
    top.Size = UDim2.new(1, 0, 0, 42)
    top.BackgroundColor3 = BG2
    top.BackgroundTransparency = 0.2
    top.BorderSizePixel = 0
    top.Parent = main
    corner(top, 10)

    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 12)
    topFix.Position = UDim2.new(0, 0, 1, -12)
    topFix.BackgroundColor3 = BG2
    topFix.BackgroundTransparency = 0.2
    topFix.BorderSizePixel = 0
    topFix.Parent = top

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "Title"
    titleLbl.Size = UDim2.new(1, -100, 1, 0)
    titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = self.FontMedium
    titleLbl.TextSize = 16
    titleLbl.TextColor3 = TEXT
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Text = title or "LarpSec - Prison Life v1"
    titleLbl.Parent = top
    self.TitleLabel = titleLbl

    -- Minimize
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "Minimize"
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -68, 0.5, -14)
    minBtn.BackgroundColor3 = BG
    minBtn.BackgroundTransparency = 0.4
    minBtn.BorderSizePixel = 0
    minBtn.Font = self.Font
    minBtn.TextSize = 14
    minBtn.TextColor3 = TEXT_DIM
    minBtn.Text = "—"
    minBtn.AutoButtonColor = false
    minBtn.Parent = top
    corner(minBtn, 6)

    -- Close
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
    closeBtn.BackgroundColor3 = BG
    closeBtn.BackgroundTransparency = 0.4
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = self.Font
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = TEXT_DIM
    closeBtn.Text = "✕"
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = top
    corner(closeBtn, 6)

    minBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 580, 0, 42)
            }):Play()
        else
            TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 580, 0, 420)
            }):Play()
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        self:Unload()
    end)

    -- Dragging
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    top.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 130, 1, -50)
    sidebar.Position = UDim2.new(0, 8, 0, 48)
    sidebar.BackgroundColor3 = BG2
    sidebar.BackgroundTransparency = 0.3
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    corner(sidebar, 8)
    stroke(sidebar, BORDER, 1)
    self.Sidebar = sidebar

    local sideList = Instance.new("UIListLayout")
    sideList.Padding = UDim.new(0, 4)
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList.Parent = sidebar
    padding(sidebar, 8, 8, 6, 6)

    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -154, 1, -56)
    content.Position = UDim2.new(0, 146, 0, 50)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.Parent = main
    self.Content = content

    return self
end

function Library:SetAccent(color)
    self.Accent = color
end

function Library:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Elements = {}

    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = BG
    btn.BackgroundTransparency = 0.5
    btn.BorderSizePixel = 0
    btn.Font = self.Font
    btn.TextSize = 13
    btn.TextColor3 = TEXT_DIM
    btn.Text = name
    btn.AutoButtonColor = false
    btn.LayoutOrder = #self.Tabs + 1
    btn.Parent = self.Sidebar
    corner(btn, 6)

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "_Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = self.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = self.Content

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page
    padding(page, 4, 8, 4, 8)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 16)
    end)

    tab.Button = btn
    tab.Page = page

    btn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    return tab
end

function Library:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Page.Visible = false
        TweenService:Create(t.Button, TweenInfo.new(0.15), {
            BackgroundColor3 = BG,
            BackgroundTransparency = 0.5,
            TextColor3 = TEXT_DIM
        }):Play()
    end
    tab.Page.Visible = true
    TweenService:Create(tab.Button, TweenInfo.new(0.15), {
        BackgroundColor3 = self.Accent,
        BackgroundTransparency = 0.7,
        TextColor3 = TEXT
    }):Play()
    self.CurrentTab = tab
end

function Library:CreateSection(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Page or parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = self.FontMedium
    lbl.TextSize = 13
    lbl.TextColor3 = self.Accent
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = frame
    return frame
end

function Library:CreateToggle(parent, text, default, callback)
    local page = parent.Page or parent
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = BG2
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.Parent = page
    corner(frame, 6)
    stroke(frame, BORDER, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = self.Font
    lbl.TextSize = 13
    lbl.TextColor3 = TEXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 38, 0, 20)
    track.Position = UDim2.new(1, -48, 0.5, -10)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    track.BorderSizePixel = 0
    track.Parent = frame
    corner(track, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = TEXT_DIM
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 8)

    local state = default or false
    local function set(val, fire)
        state = val
        if state then
            TweenService:Create(track, TweenInfo.new(0.2), { BackgroundColor3 = self.Accent }):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -18, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40, 40, 48) }):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = TEXT_DIM
            }):Play()
        end
        if fire and callback then
            callback(state)
        end
    end
    set(state, false)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function()
        set(not state, true)
    end)

    return {
        Set = function(_, v) set(v, true) end,
        Get = function() return state end,
        Frame = frame,
    }
end

function Library:CreateSlider(parent, text, min, max, default, callback)
    local page = parent.Page or parent
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = BG2
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.Parent = page
    corner(frame, 6)
    stroke(frame, BORDER, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Font = self.Font
    lbl.TextSize = 13
    lbl.TextColor3 = TEXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 56, 0, 22)
    valLbl.Position = UDim2.new(1, -64, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = self.Font
    valLbl.TextSize = 12
    valLbl.TextColor3 = self.Accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = tostring(default)
    valLbl.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    track.BorderSizePixel = 0
    track.Parent = frame
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = self.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)

    local value = default or min
    local dragging = false

    local function update(pct, fire)
        pct = math.clamp(pct, 0, 1)
        value = math.floor(min + (max - min) * pct + 0.5)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        valLbl.Text = tostring(value)
        if fire and callback then
            callback(value)
        end
    end
    update((default - min) / (max - min), false)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pct = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            update(pct, true)
        end
    end)
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pct = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            update(pct, true)
        end
    end)

    return {
        Set = function(_, v)
            local pct = (v - min) / (max - min)
            update(pct, true)
        end,
        Get = function() return value end,
        Frame = frame,
    }
end

function Library:CreateButton(parent, text, callback)
    local page = parent.Page or parent
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = BG2
    btn.BackgroundTransparency = 0.25
    btn.BorderSizePixel = 0
    btn.Font = self.Font
    btn.TextSize = 13
    btn.TextColor3 = TEXT
    btn.Text = text
    btn.AutoButtonColor = false
    btn.Parent = page
    corner(btn, 6)
    stroke(btn, BORDER, 1)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(40, 40, 48) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = BG2 }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = self.Accent }):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = BG2 }):Play()
        end)
        if callback then callback() end
    end)
    return btn
end

function Library:CreateDropdown(parent, text, options, default, callback)
    local page = parent.Page or parent
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = BG2
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    frame.Parent = page
    corner(frame, 6)
    stroke(frame, BORDER, 1)
    frame.ZIndex = 5

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.45, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = self.Font
    lbl.TextSize = 13
    lbl.TextColor3 = TEXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = frame

    local selected = default or (options[1] or "")
    local open = false

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.5, -16, 0, 26)
    dropBtn.Position = UDim2.new(0.5, 0, 0.5, -13)
    dropBtn.BackgroundColor3 = BG
    dropBtn.BackgroundTransparency = 0.3
    dropBtn.BorderSizePixel = 0
    dropBtn.Font = self.Font
    dropBtn.TextSize = 12
    dropBtn.TextColor3 = TEXT
    dropBtn.Text = selected .. "  ▼"
    dropBtn.AutoButtonColor = false
    dropBtn.Parent = frame
    corner(dropBtn, 5)

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.5, -16, 0, 0)
    listFrame.Position = UDim2.new(0.5, 0, 1, 2)
    listFrame.BackgroundColor3 = BG
    listFrame.BackgroundTransparency = 0.05
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ClipsDescendants = true
    listFrame.ZIndex = 20
    listFrame.Parent = frame
    corner(listFrame, 6)
    stroke(listFrame, BORDER, 1)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.BackgroundColor3 = BG2
        optBtn.BackgroundTransparency = 0.4
        optBtn.BorderSizePixel = 0
        optBtn.Font = self.Font
        optBtn.TextSize = 12
        optBtn.TextColor3 = TEXT
        optBtn.Text = opt
        optBtn.AutoButtonColor = false
        optBtn.LayoutOrder = i
        optBtn.ZIndex = 21
        optBtn.Parent = listFrame
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            dropBtn.Text = selected .. "  ▼"
            open = false
            listFrame.Visible = false
            listFrame.Size = UDim2.new(0.5, -16, 0, 0)
            if callback then callback(selected) end
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            listFrame.Visible = true
            local h = #options * 28
            TweenService:Create(listFrame, TweenInfo.new(0.15), {
                Size = UDim2.new(0.5, -16, 0, h)
            }):Play()
        else
            TweenService:Create(listFrame, TweenInfo.new(0.12), {
                Size = UDim2.new(0.5, -16, 0, 0)
            }):Play()
            task.delay(0.12, function()
                listFrame.Visible = false
            end)
        end
    end)

    return {
        Set = function(_, v)
            selected = v
            dropBtn.Text = selected .. "  ▼"
        end,
        Get = function() return selected end,
        Frame = frame,
    }
end

function Library:CreateColorCanvas(parent, text, defaultHSV, callback)
    local page = parent.Page or parent
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = BG2
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.Parent = page
    corner(frame, 6)
    stroke(frame, BORDER, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = self.Font
    lbl.TextSize = 13
    lbl.TextColor3 = TEXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = frame

    local hsv = defaultHSV or { H = 0.55, S = 1, V = 1 }
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 48, 0, 22)
    preview.Position = UDim2.new(1, -60, 0.5, -11)
    preview.BackgroundColor3 = Color3.fromHSV(hsv.H, hsv.S, hsv.V)
    preview.BorderSizePixel = 0
    preview.Parent = frame
    corner(preview, 5)
    stroke(preview, BORDER, 1)

    local hues = { 0, 0.08, 0.16, 0.33, 0.5, 0.66, 0.83, 1 }
    local idx = 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function()
        idx = idx % #hues + 1
        hsv.H = hues[idx]
        preview.BackgroundColor3 = Color3.fromHSV(hsv.H, hsv.S, hsv.V)
        if callback then callback(hsv) end
    end)

    return {
        Set = function(_, h)
            hsv = h
            preview.BackgroundColor3 = Color3.fromHSV(hsv.H, hsv.S, hsv.V)
        end,
        Get = function() return hsv end,
        Frame = frame,
    }
end

function Library:CreateLabel(parent, text)
    local page = parent.Page or parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Font = self.Font
    lbl.TextSize = 12
    lbl.TextColor3 = TEXT_DIM
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = page
    return lbl
end

function Library:Unload()
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if self.Gui then
        self.Gui:Destroy()
    end
    self.Open = false
end

return Library
