--[[
    LarpSec - Prison Life v1
    Features/Combat/GunHook.lua
    Hooks shooting remotes / mouse hit for silent aim
]]

local Services = require(script.Parent.Parent.Parent.Core.Services)
local SilentAim = require(script.Parent.SilentAim)

local GunHook = {}
GunHook.Connections = {}
GunHook.OldNamecall = nil

function GunHook:Init()
    -- Hook __namecall for FireServer on gun remotes
    if hookmetamethod and getnamecallmethod and checkcaller then
        local old
        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and method == "FireServer" then
                local args = { ... }
                local aimPos = SilentAim:GetAimPosition()
                if aimPos and SilentAim.Enabled then
                    -- Common PL gun remote argument shapes
                    if typeof(args[1]) == "table" then
                        -- table of shot data
                        for i, shot in ipairs(args[1]) do
                            if type(shot) == "table" then
                                if shot.Hit then
                                    local target = SilentAim.Target
                                    if target and target.Character then
                                        local part = target.Character:FindFirstChild(SilentAim.Config.TargetPart) or Services.GetRoot(target)
                                        if part then
                                            shot.Hit = part
                                        end
                                    end
                                end
                                if shot.Cframe or shot.CFrame then
                                    shot.Cframe = CFrame.new(aimPos)
                                    shot.CFrame = CFrame.new(aimPos)
                                end
                                if shot.RayObject then
                                    local origin = Services.Camera.CFrame.Position
                                    shot.RayObject = Ray.new(origin, (aimPos - origin).Unit * 1000)
                                end
                            end
                        end
                    elseif typeof(args[1]) == "CFrame" then
                        args[1] = CFrame.new(aimPos)
                    elseif typeof(args[1]) == "Vector3" then
                        args[1] = aimPos
                    end
                    return old(self, unpack(args))
                end
            end
            return old(self, ...)
        end))
        self.OldNamecall = old
    end

    -- Also redirect Mouse.Hit when silent aim is active (legacy guns)
    pcall(function()
        local mt = getrawmetatable(game)
        if mt and setreadonly then
            setreadonly(mt, false)
            local oldIndex = mt.__index
            mt.__index = newcclosure(function(t, k)
                if t == Services.Mouse and (k == "Hit" or k == "Target") and SilentAim.Enabled then
                    local aimPos = SilentAim:GetAimPosition()
                    if aimPos then
                        if k == "Hit" then
                            return CFrame.new(aimPos)
                        end
                        local target = SilentAim.Target
                        if target and target.Character then
                            return target.Character:FindFirstChild(SilentAim.Config.TargetPart) or Services.GetRoot(target)
                        end
                    end
                end
                return oldIndex(t, k)
            end)
            setreadonly(mt, true)
        end
    end)
end

function GunHook:Destroy()
    -- cannot cleanly restore hookmetamethod in most executors
end

return GunHook
