--[[
    LarpSec - Prison Life v1
    Loader.lua
    Single loadstring entry.

    Usage:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/K01dBy4spam935h/LarpSec-Prison-Life/main/Loader.lua"))()
]]

local BASE_URL = "https://raw.githubusercontent.com/K01dBy4spam935h/LarpSec-Prison-Life/main/"

local cache = {}
local loading = {}

local function fetch(path)
    local url = BASE_URL .. path
    local ok, src = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not src or src == "" then
        error("[LarpSec] Failed to fetch: " .. path .. " (" .. tostring(src) .. ")")
    end
    if type(src) == "string" and (src:sub(1, 1) == "<" or src:find("404:") or src:find("Not Found")) then
        error("[LarpSec] 404 fetching: " .. path)
    end
    return src
end

local function fetchAndRewrite(path)
    local src = fetch(path)

    local replacements = {
        { 'require%(script%.Parent%.Parent%.Parent%.Core%.Services%)', 'require("Core/Services.lua")' },
        { 'require%(script%.Parent%.Parent%.Core%.Services%)',         'require("Core/Services.lua")' },
        { 'require%(script%.Parent%.Parent%.Parent%.Config%.Defaults%)','require("Config/Defaults.lua")' },
        { 'require%(script%.Parent%.Defaults%)',                       'require("Config/Defaults.lua")' },
        { 'require%(script%.Parent%.SilentAim%)',                      'require("Features/Combat/SilentAim.lua")' },
        { 'require%(script%.Core%.Services%)',                         'require("Core/Services.lua")' },
        { 'require%(script%.Config%.Manager%)',                        'require("Config/Manager.lua")' },
        { 'require%(script%.UI%.Library%)',                            'require("UI/Library.lua")' },
        { 'require%(script%.Features%.Combat%.SilentAim%)',            'require("Features/Combat/SilentAim.lua")' },
        { 'require%(script%.Features%.Combat%.Aimbot%)',               'require("Features/Combat/Aimbot.lua")' },
        { 'require%(script%.Features%.Combat%.Hitbox%)',               'require("Features/Combat/Hitbox.lua")' },
        { 'require%(script%.Features%.Combat%.AntiTase%)',             'require("Features/Combat/AntiTase.lua")' },
        { 'require%(script%.Features%.Combat%.GunHook%)',              'require("Features/Combat/GunHook.lua")' },
        { 'require%(script%.Features%.Visuals%.ESP%)',                 'require("Features/Visuals/ESP.lua")' },
        { 'require%(script%.Features%.Visuals%.World%)',               'require("Features/Visuals/World.lua")' },
        { 'require%(script%.Features%.Player%.Movement%)',             'require("Features/Player/Movement.lua")' },
        { 'require%(script%.Features%.Utility%.HUD%)',                 'require("Features/Utility/HUD.lua")' },
        { 'require%(script%.Features%.Utility%.GunGrabber%)',          'require("Features/Utility/GunGrabber.lua")' },
    }

    for _, pair in ipairs(replacements) do
        src = src:gsub(pair[1], pair[2])
    end

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
        error("[LarpSec] compile " .. path .. " :: " .. tostring(err))
    end

    local env = setmetatable({
        require = function(p)
            if type(p) ~= "string" then
                error("[LarpSec] require expects string path, got " .. type(p))
            end
            return loadRewritten(p)
        end,
    }, { __index = getfenv and getfenv() or _ENV or _G })

    if setfenv then setfenv(fn, env) end

    local ok, result = pcall(fn)
    loading[path] = nil
    if not ok then
        error("[LarpSec] runtime " .. path .. ": " .. tostring(result))
    end
    cache[path] = result
    return result
end

loadRewritten("Main.lua")
print("[LarpSec] Prison Life v1 — loadstring boot complete.")
