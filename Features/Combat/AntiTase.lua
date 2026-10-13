--[[
    LarpSec - Prison Life v1
    Features/Combat/AntiTase.lua
    Blocks taser stun by intercepting the remote / effect
]]

local Services = require("Core/Services.lua")
local RunService = Services.RunService
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer = Services.LocalPlayer

local AntiTase = {}
AntiTase.Enabled = false
AntiTase.Connections = {}
AntiTase.Hooks = {}

local function findTaseRemote()
    local candidates = {
        function() return ReplicatedStorage:FindFirstChild("GunRemotes") and ReplicatedStorage.GunRemotes:FindFirstChild("PlayerTased") end,
        function() return ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Tase") end,
        function() return ReplicatedStorage:FindFirstChild("PlayerTased") end,
        function() return workspace:FindFirstChild("Remote") and workspace.Remote:FindFirstChild("taseEvent") end,
    }
    for _, fn in ipairs(candidates) do
        local ok, remote = pcall(fn)
        if ok and remote then return remote end
    end
    return nil
end

function AntiTase:Init()
    -- Continuously clear stun effects and restore movement
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        -- Clear common stun values
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BoolValue") and (v.Name:lower():find("tase") or v.Name:lower():find("stun") or v.Name:lower():find("ragdoll")) then
                v.Value = false
            end
            if v:IsA("NumberValue") and (v.Name:lower():find("tase") or v.Name:lower():find("stun")) then
                v.Value = 0
            end
        end

        -- Restore platform stand / sit
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
        if hum.Sit then
            hum.Sit = false
        end

        -- Keep walkspeed from being zeroed by tase
        if hum.WalkSpeed < 1 and self.Enabled then
            hum.WalkSpeed = 16
        end
    end))

    -- Attempt to neutralize the remote
    task.spawn(function()
        local remote = findTaseRemote()
        if remote and typeof(remote) == "Instance" then
            if getconnections then
                pcall(function()
                    for _, conn in ipairs(getconnections(remote.OnClientEvent)) do
                        conn:Disable()
                    end
                end)
            end
            -- Replace with dummy so fires do nothing
            pcall(function()
                local parent = remote.Parent
                local name = remote.Name
                remote:Destroy()
                local dummy = Instance.new("RemoteEvent")
                dummy.Name = name
                dummy.Parent = parent
            end)
        end
    end)

    -- Character respawn re-apply
    table.insert(self.Connections, LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if self.Enabled then
            -- re-hook on new character if needed
        end
    end))
end

function AntiTase:SetEnabled(v)
    self.Enabled = v
end

function AntiTase:Destroy()
    self.Enabled = false
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
end

return AntiTase
