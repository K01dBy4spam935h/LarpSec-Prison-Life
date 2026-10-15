--[[
    LarpSec - Prison Life v1
    Features/Combat/GunHook.lua
    PL ShootEvent: FireServer(bullets, gun)
    bullet = { RayObject, Distance, Cframe, Hit }
    SilentAim.Target is the Hit BasePart
]]

local Services = require("Core/Services.lua")
local SilentAim = require("Features/Combat/SilentAim.lua")

local GunHook = {}
GunHook.Hooked = false

function GunHook:Init()
    if self.Hooked then return end
    if not (hookmetamethod and getnamecallmethod and checkcaller and newcclosure) then
        warn("[LarpSec] GunHook: missing hookmetamethod — silent aim off")
        return
    end

    local ShootEvent = Services.ReplicatedStorage:FindFirstChild("ShootEvent")

    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer"
            and not checkcaller()
            and SilentAim.Enabled
            and SilentAim.Target
            and SilentAim:ShouldHit()
            and (self == ShootEvent or (typeof(self) == "Instance" and self.Name == "ShootEvent"))
        then
            local bullets, gun = ...
            if type(bullets) == "table" then
                local hitPart = SilentAim.Target
                for _, bullet in next, bullets do
                    if type(bullet) == "table" then
                        bullet.Cframe = hitPart.CFrame
                        bullet.Hit = hitPart
                    end
                end
                return old(self, bullets, gun)
            end
        end
        return old(self, ...)
    end))

    self.Hooked = true
end

function GunHook:Destroy()
end

return GunHook
