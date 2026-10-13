--[[
    LarpSec - Prison Life v1
    Config/Manager.lua
    Multi-config save/load system using writefile/readfile
]]

local HttpService = game:GetService("HttpService")
local Defaults = require(script.Parent.Defaults)

local Manager = {}
Manager.Current = nil
Manager.Folder = "LarpSec_PrisonLife"
Manager.Configs = {}

local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local n = {}
    for k, v in pairs(t) do
        n[k] = deepCopy(v)
    end
    return n
end

local function deepMerge(base, override)
    for k, v in pairs(override) do
        if type(v) == "table" and type(base[k]) == "table" then
            deepMerge(base[k], v)
        else
            base[k] = v
        end
    end
    return base
end

function Manager:Init()
    if not isfolder then
        self.Current = deepCopy(Defaults)
        return
    end
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    self:RefreshList()
    if isfile(self.Folder .. "/default.json") then
        self:Load("default")
    else
        self.Current = deepCopy(Defaults)
        self:Save("default")
    end
end

function Manager:RefreshList()
    self.Configs = {}
    if not isfolder then return end
    local ok, files = pcall(listfiles, self.Folder)
    if not ok then return end
    for _, path in ipairs(files) do
        local name = path:match("([^/\\]+)%.json$")
        if name then
            table.insert(self.Configs, name)
        end
    end
    table.sort(self.Configs)
end

function Manager:Save(name)
    name = name or (self.Current and self.Current.Settings and self.Current.Settings.ConfigName) or "default"
    if not self.Current then
        self.Current = deepCopy(Defaults)
    end
    self.Current.Settings.ConfigName = name
    if writefile then
        local encoded = HttpService:JSONEncode(self.Current)
        writefile(self.Folder .. "/" .. name .. ".json", encoded)
    end
    self:RefreshList()
    return true
end

function Manager:Load(name)
    name = name or "default"
    if not isfile or not isfile(self.Folder .. "/" .. name .. ".json") then
        self.Current = deepCopy(Defaults)
        self.Current.Settings.ConfigName = name
        return false
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(self.Folder .. "/" .. name .. ".json"))
    end)
    if ok and type(data) == "table" then
        self.Current = deepMerge(deepCopy(Defaults), data)
        self.Current.Settings.ConfigName = name
        return true
    end
    self.Current = deepCopy(Defaults)
    return false
end

function Manager:Delete(name)
    if not name or name == "default" then return false end
    if isfile and isfile(self.Folder .. "/" .. name .. ".json") then
        delfile(self.Folder .. "/" .. name .. ".json")
        self:RefreshList()
        return true
    end
    return false
end

function Manager:Get()
    if not self.Current then
        self.Current = deepCopy(Defaults)
    end
    return self.Current
end

function Manager:Reset()
    self.Current = deepCopy(Defaults)
    return self.Current
end

return Manager
