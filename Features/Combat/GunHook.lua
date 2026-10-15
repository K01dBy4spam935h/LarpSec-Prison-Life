--[[
    LarpSec - Prison Life v1
    Features/Combat/GunHook.lua
    Modern PL silent aim: hook local castRay (getgc + hookfunction)
    ShootEvent rewrite is outdated and zeros damage.
]]

local Services = require("Core/Services.lua")
local SilentAim = require("Features/Combat/SilentAim.lua")

local GunHook = {}
GunHook.Hooked = false
GunHook.OrigCastRay = nil

local function findCastRay()
    if not getgc then return nil end
    for _, fn in ipairs(getgc(true)) do
        if type(fn) == "function" then
            local ok, info = pcall(function()
                return debug.getinfo(fn, "nS")
            end)
            if ok and info and info.name == "castRay" then
                return fn
            end
        end
    end
    -- filtergc path (some executors)
    if filtergc then
        local ok, list = pcall(filtergc, "function", { Name = "castRay" }, true)
        if ok and type(list) == "function" then
            return list
        end
        if ok and type(list) == "table" and type(list[1]) == "function" then
            return list[1]
        end
    end
    return nil
end

function GunHook:Init()
    if self.Hooked then return end
    if not hookfunction then
        warn("[LarpSec] GunHook: no hookfunction — silent aim unavailable")
        return
    end

    local function tryHook()
        local castRay = findCastRay()
        if not castRay then return false end

        local orig
        orig = hookfunction(castRay, function(startPos, targetPos, ...)
            if not SilentAim.Enabled then
                return orig(startPos, targetPos, ...)
            end

            local hitPart = SilentAim.Target
            if not hitPart or not hitPart.Parent then
                return orig(startPos, targetPos, ...)
            end

            if not SilentAim:ShouldHit() then
                return orig(startPos, targetPos, ...)
            end

            -- Redirect ray result to target part (castRay returns part, position)
            return hitPart, hitPart.Position
        end)

        self.OrigCastRay = orig
        self.Hooked = true
        print("[LarpSec] castRay hooked")
        return true
    end

    if not tryHook() then
        task.spawn(function()
            for _ = 1, 40 do
                task.wait(0.5)
                if tryHook() then return end
            end
            warn("[LarpSec] castRay not found — equip a gun once, then re-toggle Silent Aim")
        end)
    end
end

function GunHook:Destroy()
end

return GunHook
