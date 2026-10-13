--[[
    LarpSec - Prison Life v1
    Config/Defaults.lua
    Default configuration values for every feature
]]

return {
    Combat = {
        SilentAim = {
            Enabled = false,
            TeamFilter = { Guards = true, Inmates = true, Criminals = true },
            Hitchance = 100,
            FOV = 120,
            FOVVisible = true,
            FOVColor = { H = 0.55, S = 1, V = 1 },
            Rainbow = false,
            TargetPart = "Head",
            Prediction = 0.12,
        },
        Aimbot = {
            Enabled = false,
            TeamFilter = { Guards = true, Inmates = true, Criminals = true },
            FOV = 150,
            FOVVisible = true,
            FOVColor = { H = 0.08, S = 1, V = 1 },
            Rainbow = false,
            Smoothness = 0.25,
            TargetPart = "Head",
            Key = Enum.UserInputType.MouseButton2,
        },
        HitboxExpander = {
            Enabled = false,
            Size = 8,
            Transparency = 0.6,
            TeamFilter = { Guards = true, Inmates = true, Criminals = true },
            ShowVisual = true,
        },
        AntiTase = {
            Enabled = false,
        },
    },

    Visuals = {
        ESP = {
            Boxes = false,
            Chams = false,
            Names = false,
            Distance = false,
            Tracers = false,
            NameOrigin = "DisplayName", -- "DisplayName" or "Username"
            TeamFilter = { Guards = true, Inmates = true, Criminals = true },
            MaxDistance = 2000,
            TracerOrigin = "Bottom", -- "Bottom", "Center", "Mouse"
        },
        Fullbright = false,
        FPSBooster = false,
    },

    Player = {
        Speed = {
            Enabled = false,
            Value = 28,
            Method = "CFrame", -- "CFrame" is safer than WalkSpeed for PL
        },
        JumpPower = {
            Enabled = false,
            Value = 60,
        },
        InfiniteJump = false,
        Noclip = false,
        Fly = {
            Enabled = false,
            Speed = 50,
            Method = "BodyVelocity",
        },
        VehicleFly = {
            Enabled = false,
            Speed = 80,
        },
        Invisibility = false,
    },

    Utility = {
        FPSHUD = {
            Enabled = true,
            Position = { X = 20, Y = 20 },
        },
        PingHUD = {
            Enabled = true,
            Position = { X = 20, Y = 60 },
        },
        GunGrabber = {
            Selected = "AK-47",
            ReturnPos = nil,
        },
    },

    Settings = {
        UIAccent = { R = 0, G = 200, B = 255 },
        UIFont = "Gotham",
        ConfigName = "default",
    },
}
