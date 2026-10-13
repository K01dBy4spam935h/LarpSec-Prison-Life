--[[
    LarpSec - Prison Life v1
    Loader.lua
    Single loadstring entry. Host the PrisonLife folder on GitHub/raw and point BASE_URL at it.

    Usage:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/PrisonLife/Loader.lua"))()
]]

local BASE_URL = "https://raw.githubusercontent.com/K01dBy4spam935h/LarpSec-Prison-Life/refs/heads/main/"

-- In-memory module cache so require() works without filesystem
local cache = {}
local loading = {}

local function fetch(path)
    local url = BASE_URL .. path
    local ok, src = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not src or src == "" then
        error("[LarpSec] Failed to fetch: " .. path)
    end
    return src
end

local function loadModule(path)
    if cache[path] then return cache[path] end
    if loading[path] then
        error("[LarpSec] Circular require: " .. path)
    end
    loading[path] = true
    local src = fetch(path)
    local fn, err = loadstring(src, "@" .. path)
    if not fn then
        loading[path] = nil
        error("[LarpSec] Compile error in " .. path .. ": " .. tostring(err))
    end
    -- Custom environment with relative require
    local env = setmetatable({
        script = {
            Parent = {
                Parent = {
                    Parent = nil, -- filled per path
                }
            }
        },
        require = function(mod)
            -- Support both string paths and faux script.Parent chains
            if type(mod) == "string" then
                return loadModule(mod)
            end
            error("[LarpSec] Unsupported require target")
        end,
    }, { __index = getfenv() or _G })

    -- Rewrite relative requires used in the codebase
    -- Our modules use: require(script.Parent.X) style — we intercept via a path map
    setfenv(fn, env)
    local result = fn()
    cache[path] = result
    loading[path] = nil
    return result
end

-- Path map matching the require(script.Parent...) style used in modules
local modules = {
    ["Core/Services.lua"] = true,
    ["Config/Defaults.lua"] = true,
    ["Config/Manager.lua"] = true,
    ["UI/Library.lua"] = true,
    ["Features/Combat/SilentAim.lua"] = true,
    ["Features/Combat/Aimbot.lua"] = true,
    ["Features/Combat/Hitbox.lua"] = true,
    ["Features/Combat/AntiTase.lua"] = true,
    ["Features/Combat/GunHook.lua"] = true,
    ["Features/Visuals/ESP.lua"] = true,
    ["Features/Visuals/World.lua"] = true,
    ["Features/Player/Movement.lua"] = true,
    ["Features/Utility/HUD.lua"] = true,
    ["Features/Utility/GunGrabber.lua"] = true,
    ["Main.lua"] = true,
}

-- Because modules use require(script.Parent...), we provide a smarter loader
-- that resolves relative to the current file path.
local function makeRequire(currentPath)
    return function(target)
        if type(target) == "string" then
            return loadModule(target)
        end
        -- Fallback: treat as already-resolved by our rewritten Main
        error("[LarpSec] require() needs a string path in loadstring mode")
    end
end

-- Preload everything with correct relative resolution by rewriting source on the fly
local function fetchAndRewrite(path)
    local src = fetch(path)
    -- Replace require(script.Parent.Parent.Parent.Core.Services) style with string requires
    src = src:gsub('require%(script%.Parent%.Parent%.Parent%.Core%.Services%)', 'require("Core/Services.lua")')
    src = src:gsub('require%(script%.Parent%.Parent%.Parent%.Config%.Defaults%)', 'require("Config/Defaults.lua")')
    src = src:gsub('require%(script%.Parent%.Defaults%)', 'require("Config/Defaults.lua")')
    src = src:gsub('require%(script%.Parent%.Parent%.Parent%.Core%.Services%)', 'require("Core/Services.lua")')
    src = src:gsub('require%(script%.Parent%.SilentAim%)', 'require("Features/Combat/SilentAim.lua")')
    src = src:gsub('require%(script%.Core%.Services%)', 'require("Core/Services.lua")')
    src = src:gsub('require%(script%.Config%.Manager%)', 'require("Config/Manager.lua")')
    src = src:gsub('require%(script%.UI%.Library%)', 'require("UI/Library.lua")')
    src = src:gsub('require%(script%.Features%.Combat%.SilentAim%)', 'require("Features/Combat/SilentAim.lua")')
    src = src:gsub('require%(script%.Features%.Combat%.Aimbot%)', 'require("Features/Combat/Aimbot.lua")')
    src = src:gsub('require%(script%.Features%.Combat%.Hitbox%)', 'require("Features/Combat/Hitbox.lua")')
    src = src:gsub('require%(script%.Features%.Combat%.AntiTase%)', 'require("Features/Combat/AntiTase.lua")')
    src = src:gsub('require%(script%.Features%.Combat%.GunHook%)', 'require("Features/Combat/GunHook.lua")')
    src = src:gsub('require%(script%.Features%.Visuals%.ESP%)', 'require("Features/Visuals/ESP.lua")')
    src = src:gsub('require%(script%.Features%.Visuals%.World%)', 'require("Features/Visuals/World.lua")')
    src = src:gsub('require%(script%.Features%.Player%.Movement%)', 'require("Features/Player/Movement.lua")')
    src = src:gsub('require%(script%.Features%.Utility%.HUD%)', 'require("Features/Utility/HUD.lua")')
    src = src:gsub('require%(script%.Features%.Utility%.GunGrabber%)', 'require("Features/Utility/GunGrabber.lua")')
    return src
end

local function loadRewritten(path)
    if cache[path] ~= nil then return cache[path] end
    if loading[path] then error("circular " .. path) end
    loading[path] = true
    local src = fetchAndRewrite(path)
    local fn, err = loadstring(src, "@LarpSec/" .. path)
    if not fn then
        loading[path] = nil
        error("[LarpSec] " .. path .. " :: " .. tostring(err))
    end
    local env = setmetatable({
        require = function(p)
            if type(p) ~= "string" then error("bad require") end
            return loadRewritten(p)
        end,
    }, { __index = getfenv and getfenv() or _ENV or _G })
    if setfenv then setfenv(fn, env) end
    local ok, result = pcall(fn)
    loading[path] = nil
    if not ok then error("[LarpSec] runtime " .. path .. ": " .. tostring(result)) end
    cache[path] = result
    return result
end

-- Boot
loadRewritten("Main.lua")
print("[LarpSec] Prison Life v1 — loadstring boot complete.")
