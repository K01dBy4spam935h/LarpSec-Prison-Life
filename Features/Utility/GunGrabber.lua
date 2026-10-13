--[[
    LarpSec - Prison Life v1
    Features/Utility/GunGrabber.lua
    TP to known gun locations then return
]]

local Services = require("Core/Services.lua")
local LocalPlayer = Services.LocalPlayer

local GunGrabber = {}
GunGrabber.ReturnCFrame = nil

-- Approximate known locations for Prison Life gun pickups
-- Armory (Guard area) and Warehouse (Criminal base)
local GUN_LOCATIONS = {
    ["M9"] = {
        CFrame.new(835, 100, 2265), -- armory approximate
        CFrame.new(838, 100, 2260),
    },
    ["MP5"] = {
        CFrame.new(840, 100, 2268),
    },
    ["Remington 870"] = {
        CFrame.new(842, 100, 2262), -- armory
        CFrame.new(-910, 95, -2050), -- warehouse approximate
    },
    ["M4A1"] = {
        CFrame.new(845, 100, 2270),
    },
    ["AK-47"] = {
        CFrame.new(-915, 95, -2045), -- warehouse
        CFrame.new(-920, 95, -2055),
    },
    ["Revolver"] = {
        CFrame.new(848, 100, 2265),
    },
    ["M700"] = {
        CFrame.new(850, 100, 2268),
        CFrame.new(-918, 95, -2048),
    },
    ["FAL"] = {
        CFrame.new(-922, 95, -2052),
    },
}

-- Also scan workspace for actual tool pickups
local function findNearestGun(gunName)
    local root = Services.GetRoot(LocalPlayer)
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("Part")) then
            local n = obj.Name:lower()
            local target = gunName:lower()
            if n:find(target) or target:find(n) then
                local pos
                if obj:IsA("Model") then
                    pos = obj:GetPivot().Position
                elseif obj:IsA("BasePart") then
                    pos = obj.Position
                elseif obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                    pos = obj.Handle.Position
                end
                if pos then
                    local d = (pos - root.Position).Magnitude
                    if d < bestDist and d < 5000 then
                        bestDist = d
                        best = pos
                    end
                end
            end
        end
    end
    return best
end

function GunGrabber:Grab(gunName)
    local root = Services.GetRoot(LocalPlayer)
    if not root then return false, "No character" end

    self.ReturnCFrame = root.CFrame

    -- Prefer live scan
    local pos = findNearestGun(gunName)
    if not pos then
        local list = GUN_LOCATIONS[gunName]
        if list and #list > 0 then
            pos = list[1].Position or list[1]
        end
    end

    if not pos then
        return false, "Location unknown"
    end

    -- Soft teleport (short steps to reduce detection)
    local start = root.Position
    local steps = 6
    for i = 1, steps do
        local alpha = i / steps
        local mid = start:Lerp(pos + Vector3.new(0, 3, 0), alpha)
        root.CFrame = CFrame.new(mid)
        task.wait(0.03)
    end
    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))

    -- Brief linger so tool can be picked
    task.wait(0.35)

    return true
end

function GunGrabber:Return()
    local root = Services.GetRoot(LocalPlayer)
    if not root or not self.ReturnCFrame then return false end
    local start = root.Position
    local goal = self.ReturnCFrame.Position
    local steps = 6
    for i = 1, steps do
        local alpha = i / steps
        root.CFrame = CFrame.new(start:Lerp(goal, alpha))
        task.wait(0.03)
    end
    root.CFrame = self.ReturnCFrame
    self.ReturnCFrame = nil
    return true
end

function GunGrabber:GetGunList()
    local list = {}
    for name in pairs(GUN_LOCATIONS) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

return GunGrabber
