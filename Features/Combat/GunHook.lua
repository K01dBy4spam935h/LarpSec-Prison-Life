--[[
    LarpSec - Prison Life v1
    Features/Combat/GunHook.lua
    Hooks ReplicatedStorage.ShootEvent for silent aim (Prison Life bullet table format)
]]

local Services = require("Core/Services.lua")
local SilentAim = require("Features/Combat/SilentAim.lua")

local GunHook = {}
GunHook.OldNamecall = nil
GunHook.Hooked = false

local function resolveShootEvent()
    local rs = Services.ReplicatedStorage
    local candidates = {
        rs:FindFirstChild("ShootEvent"),
        rs:FindFirstChild("GunRemotes") and rs.GunRemotes:FindFirstChild("ShootEvent"),
        rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("ShootEvent"),
    }
    for _, r in ipairs(candidates) do
        if r and r:IsA("RemoteEvent") then
            return r
        end
    end
    return rs:FindFirstChild("ShootEvent")
end

function GunHook:Init()
    if self.Hooked then return end
    if not (hookmetamethod and getnamecallmethod and checkcaller and newcclosure) then
        warn("[LarpSec] GunHook: executor missing hookmetamethod — silent aim disabled")
        return
    end

    local shootEvent = resolveShootEvent()

    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and method == "FireServer" then
            local isShoot = (shootEvent and self == shootEvent)
                or (typeof(self) == "Instance" and self.Name == "ShootEvent" and self:IsA("RemoteEvent"))

            if isShoot and SilentAim.Enabled then
                local args = { ... }
                local bullets = args[1]
                local target = SilentAim.Target
                local aimPos = SilentAim:GetAimPosition()

                if target and target.Character and aimPos and type(bullets) == "table" then
                    local part = target.Character:FindFirstChild(SilentAim.Config.TargetPart)
                        or target.Character:FindFirstChild("Head")
                        or Services.GetRoot(target)

                    if part then
                        for _, bullet in pairs(bullets) do
                            if type(bullet) == "table" then
                                bullet.Cframe = part.CFrame
                                bullet.CFrame = part.CFrame
                                bullet.Hit = part
                                if bullet.RayObject then
                                    local origin = Services.Camera.CFrame.Position
                                    bullet.RayObject = Ray.new(origin, (part.Position - origin).Unit * 2000)
                                end
                                if bullet.Distance then
                                    bullet.Distance = (part.Position - Services.Camera.CFrame.Position).Magnitude
                                end
                            end
                        end
                        return old(self, bullets, select(2, ...))
                    end
                end
            end
        end
        return old(self, ...)
    end))

    self.OldNamecall = old
    self.Hooked = true
end

function GunHook:Destroy()
end

return GunHook
