--[[
    LarpSec - Prison Life v1
    Features/Utility/GunGrabber.lua
    Uses workspace.Remote.ItemHandler:InvokeServer(ITEMPICKUP) — no TP
]]

local Services = require("Core/Services.lua")
local Workspace = Services.Workspace
local LocalPlayer = Services.LocalPlayer

local GunGrabber = {}

local function resolvePickup(gunName)
    local items = Workspace:FindFirstChild("Prison_ITEMS")
    if not items then return nil end

    local giver = items:FindFirstChild("giver")
    if giver then
        local gun = giver:FindFirstChild(gunName)
        if gun and gun:FindFirstChild("ITEMPICKUP") then
            return gun.ITEMPICKUP
        end
        -- fuzzy
        for _, child in ipairs(giver:GetChildren()) do
            if child.Name:lower():find(gunName:lower(), 1, true) and child:FindFirstChild("ITEMPICKUP") then
                return child.ITEMPICKUP
            end
        end
    end

    local single = items:FindFirstChild("single")
    if single then
        local gun = single:FindFirstChild(gunName)
        if gun and gun:FindFirstChild("ITEMPICKUP") then
            return gun.ITEMPICKUP
        end
    end
    return nil
end

function GunGrabber:GetGunList()
    local list = {}
    local items = Workspace:FindFirstChild("Prison_ITEMS")
    if items and items:FindFirstChild("giver") then
        for _, child in ipairs(items.giver:GetChildren()) do
            if child:FindFirstChild("ITEMPICKUP") then
                table.insert(list, child.Name)
            end
        end
    end
    if #list == 0 then
        list = { "M9", "Remington 870", "AK-47", "MP5", "M4A1" }
    end
    table.sort(list)
    return list
end

function GunGrabber:Grab(gunName)
    local pickup = resolvePickup(gunName)
    if not pickup then
        return false, "pickup not found for " .. tostring(gunName)
    end

    local remote = Workspace:FindFirstChild("Remote")
    local handler = remote and remote:FindFirstChild("ItemHandler")
    if not handler then
        return false, "ItemHandler missing"
    end

    local ok, err = pcall(function()
        handler:InvokeServer(pickup)
    end)
    if not ok then
        return false, tostring(err)
    end
    return true
end

function GunGrabber:Return()
    -- no-op: ItemHandler path doesn't TP
    return true
end

return GunGrabber
