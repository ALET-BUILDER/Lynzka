--[[
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║          ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗        ║
║          ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝        ║
║          ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗        ║
║          ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║        ║
║          ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║        ║
║          ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝        ║
║                                                              ║
║                    H U B  v1.0.0                            ║
║              [ RightShift to Toggle Menu ]                  ║
╚══════════════════════════════════════════════════════════════╝

    Author  : NexusHub
    Keybind : RightShift
    Themes  : Dark · Aqua · Rose · Light
    Features: Combat · Movement · Visual · Misc · Settings
]]

-- ══════════════════════════════════════
--              SERVICES
-- ══════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService       = game:GetService("GuiService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Camera       = Workspace.CurrentCamera

-- ══════════════════════════════════════
--              THEME CONFIG
-- ══════════════════════════════════════
local Themes = {
    Dark = {
        Bg          = Color3.fromRGB(12, 12, 18),
        BgSecondary = Color3.fromRGB(18, 18, 28),
        BgTertiary  = Color3.fromRGB(24, 24, 38),
        Accent      = Color3.fromRGB(99, 102, 241),
        AccentHover = Color3.fromRGB(129, 132, 255),
        AccentGlow  = Color3.fromRGB(99, 102, 241),
        Text        = Color3.fromRGB(240, 240, 255),
        TextSub     = Color3.fromRGB(140, 140, 180),
        TextMuted   = Color3.fromRGB(80, 80, 120),
        Border      = Color3.fromRGB(40, 40, 65),
        Toggle      = Color3.fromRGB(34, 197, 94),
        ToggleBg    = Color3.fromRGB(30, 30, 50),
        Danger      = Color3.fromRGB(239, 68, 68),
    },
    Aqua = {
        Bg          = Color3.fromRGB(8, 16, 22),
        BgSecondary = Color3.fromRGB(10, 22, 32),
        BgTertiary  = Color3.fromRGB(14, 28, 42),
        Accent      = Color3.fromRGB(0, 200, 220),
        AccentHover = Color3.fromRGB(0, 230, 255),
        AccentGlow  = Color3.fromRGB(0, 180, 200),
        Text        = Color3.fromRGB(220, 255, 255),
        TextSub     = Color3.fromRGB(120, 200, 220),
        TextMuted   = Color3.fromRGB(60, 120, 140),
        Border      = Color3.fromRGB(20, 60, 80),
        Toggle      = Color3.fromRGB(0, 210, 180),
        ToggleBg    = Color3.fromRGB(10, 30, 40),
        Danger      = Color3.fromRGB(255, 80, 100),
    },
    Rose = {
        Bg          = Color3.fromRGB(18, 10, 14),
        BgSecondary = Color3.fromRGB(26, 14, 20),
        BgTertiary  = Color3.fromRGB(34, 18, 26),
        Accent      = Color3.fromRGB(244, 63, 94),
        AccentHover = Color3.fromRGB(255, 100, 130),
        AccentGlow  = Color3.fromRGB(220, 40, 80),
        Text        = Color3.fromRGB(255, 230, 235),
        TextSub     = Color3.fromRGB(200, 140, 160),
        TextMuted   = Color3.fromRGB(120, 70, 90),
        Border      = Color3.fromRGB(60, 25, 40),
        Toggle      = Color3.fromRGB(251, 113, 133),
        ToggleBg    = Color3.fromRGB(40, 15, 25),
        Danger      = Color3.fromRGB(100, 220, 100),
    },
    Light = {
        Bg          = Color3.fromRGB(245, 245, 250),
        BgSecondary = Color3.fromRGB(235, 235, 245),
        BgTertiary  = Color3.fromRGB(225, 225, 240),
        Accent      = Color3.fromRGB(99, 102, 241),
        AccentHover = Color3.fromRGB(79, 82, 220),
        AccentGlow  = Color3.fromRGB(99, 102, 241),
        Text        = Color3.fromRGB(20, 20, 40),
        TextSub     = Color3.fromRGB(80, 80, 120),
        TextMuted   = Color3.fromRGB(150, 150, 190),
        Border      = Color3.fromRGB(200, 200, 220),
        Toggle      = Color3.fromRGB(34, 197, 94),
        ToggleBg    = Color3.fromRGB(210, 210, 235),
        Danger      = Color3.fromRGB(239, 68, 68),
    },
}

-- ══════════════════════════════════════
--           GLOBAL STATE
-- ══════════════════════════════════════
local Config = {
    Theme        = "Dark",
    Transparent  = false,
    TranspAmount = 0.15,
    MenuVisible  = true,
    CurrentTab   = "Combat",
}

local T = Themes[Config.Theme] -- shorthand, updated on theme change

local FeatureStates = {
    -- Combat
    Aimbot        = false,
    SilentAim     = false,
    Triggerbot    = false,
    AimbotFOV     = 120,
    AimbotSmooth  = 0.3,
    -- Movement
    SpeedHack     = false,
    SpeedValue    = 28,
    Fly           = false,
    FlySpeed      = 50,
    Noclip        = false,
    InfJump       = false,
    AntiKnockback = false,
    -- Visual
    ESP           = false,
    ESPBox        = false,
    ESPHealth     = false,
    ESPName       = false,
    ESPDistance   = false,
    Fullbright    = false,
    RemoveEffects = false,
    -- Misc
    InfStamina    = false,
    AutoFarm      = false,
    AutoRejoin    = false,
    NameProtect   = false,
    AntiAFK       = false,
    ChatBypass    = false,
}

-- Internal loops
local Loops = {}
local Connections = {}

-- ══════════════════════════════════════
--           UTILITY FUNCTIONS
-- ══════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t or 0.25, style, dir), props)
end

local function Make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function RoundFrame(parent, radius)
    local c = Make("UICorner", { CornerRadius = UDim.new(0, radius or 10) })
    c.Parent = parent
    return c
end

local function AddStroke(parent, color, thickness, trans)
    local s = Make("UIStroke", {
        Color        = color or Color3.fromRGB(255,255,255),
        Thickness    = thickness or 1,
        Transparency = trans or 0.8,
    })
    s.Parent = parent
    return s
end

-- ══════════════════════════════════════
--           NOTIFICATION SYSTEM
-- ══════════════════════════════════════
local NotifContainer = nil

local function InitNotifications(screenGui)
    NotifContainer = Make("Frame", {
        Name              = "Notifications",
        Size              = UDim2.new(0, 300, 1, 0),
        Position          = UDim2.new(1, -310, 0, 0),
        BackgroundTransparency = 1,
        ZIndex            = 9999,
    }, screenGui)

    Make("UIListLayout", {
        SortOrder        = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding          = UDim.new(0, 8),
    }, NotifContainer)

    Make("UIPadding", {
        PaddingBottom = UDim.new(0, 16),
    }, NotifContainer)
end

local function Notify(title, message, notifType, duration)
    if not NotifContainer then return end
    duration = duration or 3.5
    notifType = notifType or "info" -- info | success | warning | error

    local iconMap = {
        info    = "⬡",
        success = "✓",
        warning = "⚠",
        error   = "✕",
    }
    local colorMap = {
        info    = Color3.fromRGB(99, 102, 241),
        success = Color3.fromRGB(34, 197, 94),
        warning = Color3.fromRGB(251, 191, 36),
        error   = Color3.fromRGB(239, 68, 68),
    }
    local accent = colorMap[notifType] or colorMap.info

    -- Container card
    local card = Make("Frame", {
        Name                  = "NotifCard",
        Size                  = UDim2.new(1, 0, 0, 64),
        BackgroundColor3      = T.BgSecondary,
        BackgroundTransparency = Config.Transparent and 0.25 or 0,
        ClipsDescendants      = true,
        ZIndex                = 9999,
        LayoutOrder           = tick(),
    }, NotifContainer)
    RoundFrame(card, 10)
    AddStroke(card, T.Border, 1, 0.5)

    -- Accent bar kiri
    local bar = Make("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        ZIndex           = 10000,
    }, card)

    -- Icon circle
    local iconBg = Make("Frame", {
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.8,
        BorderSizePixel  = 0,
        ZIndex           = 10000,
    }, card)
    RoundFrame(iconBg, 8)

    Make("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = iconMap[notifType] or "⬡",
        TextColor3       = accent,
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        ZIndex           = 10001,
    }, iconBg)

    -- Title
    Make("TextLabel", {
        Size             = UDim2.new(1, -65, 0, 18),
        Position         = UDim2.new(0, 56, 0, 10),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = T.Text,
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 10000,
    }, card)

    -- Message
    Make("TextLabel", {
        Size             = UDim2.new(1, -65, 0, 22),
        Position         = UDim2.new(0, 56, 0, 30),
        BackgroundTransparency = 1,
        Text             = message,
        TextColor3       = T.TextSub,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 10000,
    }, card)

    -- Progress bar
    local prog = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        ZIndex           = 10001,
    }, card)

    -- Animate in
    card.Position = UDim2.new(1, 10, 0, 0)
    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.4, Enum.EasingStyle.Back):Play()

    -- Progress countdown
    Tween(prog, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear):Play()

    -- Animate out
    task.delay(duration, function()
        pcall(function()
            Tween(card, { Position = UDim2.new(1, 10, 0, 0) }, 0.35, Enum.EasingStyle.Quart):Play()
            task.delay(0.4, function() pcall(function() card:Destroy() end) end)
        end)
    end)
end

-- ══════════════════════════════════════
--         TOGGLE COMPONENT
-- ══════════════════════════════════════
local function CreateToggle(parent, labelText, subText, featureKey, callback)
    local row = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, subText and 54 or 44),
        BackgroundColor3 = T.BgTertiary,
        BackgroundTransparency = Config.Transparent and 0.3 or 0,
        BorderSizePixel  = 0,
    }, parent)
    RoundFrame(row, 8)
    AddStroke(row, T.Border, 1, 0.6)

    -- Label
    Make("TextLabel", {
        Size             = UDim2.new(1, -70, 0, 18),
        Position         = UDim2.new(0, 12, 0, subText and 8 or 13),
        BackgroundTransparency = 1,
        Text             = labelText,
        TextColor3       = T.Text,
        Font             = Enum.Font.GothamMedium,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, row)

    if subText then
        Make("TextLabel", {
            Size             = UDim2.new(1, -70, 0, 14),
            Position         = UDim2.new(0, 12, 0, 28),
            BackgroundTransparency = 1,
            Text             = subText,
            TextColor3       = T.TextMuted,
            Font             = Enum.Font.Gotham,
            TextSize         = 10,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, row)
    end

    -- Toggle pill
    local pillBg = Make("Frame", {
        Size             = UDim2.new(0, 44, 0, 24),
        Position         = UDim2.new(1, -54, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = T.ToggleBg,
        BorderSizePixel  = 0,
    }, row)
    RoundFrame(pillBg, 12)

    local knob = Make("Frame", {
        Size             = UDim2.new(0, 18, 0, 18),
        Position         = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = T.TextMuted,
        BorderSizePixel  = 0,
    }, pillBg)
    RoundFrame(knob, 9)

    local state = FeatureStates[featureKey] or false

    local function updateVisual(on, instant)
        local t = instant and 0 or 0.22
        if on then
            Tween(pillBg, { BackgroundColor3 = T.Toggle }, t):Play()
            Tween(knob,   { BackgroundColor3 = Color3.fromRGB(255,255,255),
                            Position = UDim2.new(0, 23, 0.5, 0) }, t):Play()
        else
            Tween(pillBg, { BackgroundColor3 = T.ToggleBg }, t):Play()
            Tween(knob,   { BackgroundColor3 = T.TextMuted,
                            Position = UDim2.new(0, 3, 0.5, 0) }, t):Play()
        end
    end

    updateVisual(state, true)

    -- Hover effect
    local btn = Make("TextButton", {
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                  = "",
        ZIndex                = 5,
    }, row)

    btn.MouseEnter:Connect(function()
        Tween(row, { BackgroundColor3 = T.BgSecondary }, 0.15):Play()
    end)
    btn.MouseLeave:Connect(function()
        Tween(row, { BackgroundColor3 = T.BgTertiary }, 0.15):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        state = not state
        FeatureStates[featureKey] = state
        updateVisual(state)
        -- Click ripple on knob
        Tween(knob, { Size = UDim2.new(0, 20, 0, 20) }, 0.1):Play()
        task.delay(0.1, function()
            Tween(knob, { Size = UDim2.new(0, 18, 0, 18) }, 0.1):Play()
        end)
        if callback then pcall(callback, state) end
    end)

    return row, function(v) state = v; FeatureStates[featureKey] = v; updateVisual(v) end
end

-- ══════════════════════════════════════
--         SLIDER COMPONENT
-- ══════════════════════════════════════
local function CreateSlider(parent, labelText, min, max, default, suffix, callback)
    local row = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = T.BgTertiary,
        BackgroundTransparency = Config.Transparent and 0.3 or 0,
        BorderSizePixel  = 0,
    }, parent)
    RoundFrame(row, 8)
    AddStroke(row, T.Border, 1, 0.6)

    local valLabel = Make("TextLabel", {
        Size             = UDim2.new(0, 50, 0, 14),
        Position         = UDim2.new(1, -58, 0, 10),
        BackgroundTransparency = 1,
        Text             = tostring(default) .. (suffix or ""),
        TextColor3       = T.Accent,
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Right,
    }, row)

    Make("TextLabel", {
        Size             = UDim2.new(1, -70, 0, 14),
        Position         = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1,
        Text             = labelText,
        TextColor3       = T.Text,
        Font             = Enum.Font.GothamMedium,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, row)

    -- Track
    local track = Make("Frame", {
        Size             = UDim2.new(1, -24, 0, 6),
        Position         = UDim2.new(0, 12, 0, 38),
        BackgroundColor3 = T.ToggleBg,
        BorderSizePixel  = 0,
    }, row)
    RoundFrame(track, 3)

    local pct = (default - min) / (max - min)

    local fill = Make("Frame", {
        Size             = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
    }, track)
    RoundFrame(fill, 3)

    local thumb = Make("Frame", {
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = UDim2.new(pct, -8, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, track)
    RoundFrame(thumb, 8)

    local value = default
    local dragging = false

    local function updateSlider(x)
        local trackPos  = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local rel = math.clamp((x - trackPos) / trackSize, 0, 1)
        value = math.floor(min + rel * (max - min))
        valLabel.Text = tostring(value) .. (suffix or "")
        Tween(fill,  { Size     = UDim2.new(rel, 0, 1, 0) }, 0.05):Play()
        Tween(thumb, { Position = UDim2.new(rel, -8, 0.5, 0) }, 0.05):Play()
        if callback then pcall(callback, value) end
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(inp.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return row
end

-- ══════════════════════════════════════
--         BUTTON COMPONENT
-- ══════════════════════════════════════
local function CreateButton(parent, labelText, subText, variant, callback)
    -- variant: "default" | "danger" | "accent"
    local accent = variant == "danger" and T.Danger
                or variant == "accent"  and T.Accent
                or T.BgTertiary

    local row = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, subText and 54 or 44),
        BackgroundColor3 = T.BgTertiary,
        BackgroundTransparency = Config.Transparent and 0.3 or 0,
        BorderSizePixel  = 0,
    }, parent)
    RoundFrame(row, 8)
    AddStroke(row, variant == "default" and T.Border or accent, 1, variant == "default" and 0.6 or 0.3)

    local icon = Make("Frame", {
        Size             = UDim2.new(0, 3, 0.7, 0),
        Position         = UDim2.new(0, 0, 0.15, 0),
        BackgroundColor3 = accent == T.BgTertiary and T.Accent or accent,
        BorderSizePixel  = 0,
    }, row)
    RoundFrame(icon, 2)

    Make("TextLabel", {
        Size             = UDim2.new(1, -70, 0, 18),
        Position         = UDim2.new(0, 12, 0, subText and 8 or 13),
        BackgroundTransparency = 1,
        Text             = labelText,
        TextColor3       = variant == "danger" and T.Danger
                        or variant == "accent"  and T.Accent
                        or T.Text,
        Font             = Enum.Font.GothamMedium,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, row)

    if subText then
        Make("TextLabel", {
            Size             = UDim2.new(1, -70, 0, 14),
            Position         = UDim2.new(0, 12, 0, 28),
            BackgroundTransparency = 1,
            Text             = subText,
            TextColor3       = T.TextMuted,
            Font             = Enum.Font.Gotham,
            TextSize         = 10,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, row)
    end

    -- Arrow icon
    Make("TextLabel", {
        Size             = UDim2.new(0, 30, 1, 0),
        Position         = UDim2.new(1, -36, 0, 0),
        BackgroundTransparency = 1,
        Text             = "›",
        TextColor3       = T.TextMuted,
        Font             = Enum.Font.GothamBold,
        TextSize         = 20,
    }, row)

    local btn = Make("TextButton", {
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                  = "",
        ZIndex                = 5,
    }, row)

    btn.MouseEnter:Connect(function()
        Tween(row, { BackgroundColor3 = T.BgSecondary }, 0.15):Play()
    end)
    btn.MouseLeave:Connect(function()
        Tween(row, { BackgroundColor3 = T.BgTertiary }, 0.15):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        -- Click flash
        local flash = Make("Frame", {
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundColor3      = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.85,
            ZIndex                = 6,
        }, row)
        RoundFrame(flash, 8)
        Tween(flash, { BackgroundTransparency = 1 }, 0.3):Play()
        task.delay(0.35, function() pcall(function() flash:Destroy() end) end)
        if callback then pcall(callback) end
    end)

    return row
end

-- ══════════════════════════════════════
--       SECTION LABEL COMPONENT
-- ══════════════════════════════════════
local function CreateSection(parent, text)
    local row = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
    }, parent)

    Make("TextLabel", {
        Size             = UDim2.new(0, 0, 1, 0),
        AutomaticSize    = Enum.AutomaticSize.X,
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text             = text:upper(),
        TextColor3       = T.Accent,
        Font             = Enum.Font.GothamBold,
        TextSize         = 10,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, row)

    local line = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
    }, row)

    return row
end

-- ══════════════════════════════════════
--         THEME SELECTOR COMPONENT
-- ══════════════════════════════════════
local function CreateThemeSelector(parent, onThemeChange)
    local wrapper = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = T.BgTertiary,
        BackgroundTransparency = Config.Transparent and 0.3 or 0,
        BorderSizePixel  = 0,
    }, parent)
    RoundFrame(wrapper, 8)
    AddStroke(wrapper, T.Border, 1, 0.6)

    Make("TextLabel", {
        Size             = UDim2.new(1, -12, 0, 16),
        Position         = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text             = "Theme",
        TextColor3       = T.Text,
        Font             = Enum.Font.GothamMedium,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, wrapper)

    local btnRow = Make("Frame", {
        Size             = UDim2.new(1, -24, 0, 22),
        Position         = UDim2.new(0, 12, 0, 26),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
    }, wrapper)

    Make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, 6),
    }, btnRow)

    local themeColors = {
        Dark  = Color3.fromRGB(99, 102, 241),
        Aqua  = Color3.fromRGB(0, 200, 220),
        Rose  = Color3.fromRGB(244, 63, 94),
        Light = Color3.fromRGB(200, 200, 220),
    }

    local themeOrder = {"Dark", "Aqua", "Rose", "Light"}

    for _, name in ipairs(themeOrder) do
        local isActive = Config.Theme == name
        local pill = Make("TextButton", {
            Size             = UDim2.new(0, 58, 1, 0),
            BackgroundColor3 = isActive and themeColors[name] or T.ToggleBg,
            BackgroundTransparency = isActive and 0 or 0.3,
            Text             = name,
            TextColor3       = isActive and Color3.fromRGB(255,255,255) or T.TextSub,
            Font             = Enum.Font.GothamBold,
            TextSize         = 10,
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
        }, btnRow)
        RoundFrame(pill, 5)

        pill.MouseButton1Click:Connect(function()
            Config.Theme = name
            if onThemeChange then pcall(onThemeChange, name) end
            Notify("Theme", "Switched to " .. name .. " theme", "info", 2.5)
        end)
    end

    return wrapper
end

-- ══════════════════════════════════════
--         TRANSPARENCY TOGGLE
-- ══════════════════════════════════════
local function CreateTransparencyToggle(parent, mainFrame)
    local row, setter = CreateToggle(parent, "Blur / Transparent", "Frosted glass background", "___transparent", function(val)
        Config.Transparent = val
        -- Apply to main frame
        Tween(mainFrame, {
            BackgroundTransparency = val and Config.TranspAmount or 0
        }, 0.4):Play()
        Notify("Appearance", val and "Transparent mode ON" or "Transparent mode OFF", "info", 2)
    end)
    return row
end

-- ══════════════════════════════════════
--           FEATURE CALLBACKS
-- ══════════════════════════════════════
local function onSpeedHack(val)
    if val then
        Loops.SpeedHack = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = FeatureStates.SpeedValue end
            end)
        end)
        Notify("Movement", "Speed hack enabled · " .. FeatureStates.SpeedValue .. " WS", "success")
    else
        if Loops.SpeedHack then
            Loops.SpeedHack:Disconnect()
            Loops.SpeedHack = nil
        end
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end)
        Notify("Movement", "Speed hack disabled", "warning")
    end
end

local function onFly(val)
    if val then
        Notify("Movement", "Fly enabled · Hold Space/Ctrl", "success")
        -- Basic fly impl
        local flyConn
        local bv, bg

        pcall(function()
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = true end

            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            bv.Parent   = hrp

            flyConn = RunService.Heartbeat:Connect(function()
                if not FeatureStates.Fly then
                    pcall(function() bv:Destroy() end)
                    if hum then hum.PlatformStand = false end
                    flyConn:Disconnect()
                    return
                end
                local cam   = Camera
                local speed = FeatureStates.FlySpeed
                local cf    = cam.CFrame
                local dir   = Vector3.zero

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end

                bv.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
            end)
            Loops.Fly = flyConn
        end)
    else
        if Loops.Fly then pcall(function() Loops.Fly:Disconnect() end) Loops.Fly = nil end
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv2 = hrp:FindFirstChildOfClass("BodyVelocity")
                if bv2 then bv2:Destroy() end
            end
        end)
        Notify("Movement", "Fly disabled", "warning")
    end
end

local function onNoclip(val)
    if val then
        Loops.Noclip = RunService.Stepped:Connect(function()
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        end)
        Notify("Movement", "Noclip enabled", "success")
    else
        if Loops.Noclip then Loops.Noclip:Disconnect() Loops.Noclip = nil end
        Notify("Movement", "Noclip disabled", "warning")
    end
end

local function onInfJump(val)
    if val then
        Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            pcall(function()
                local char = LocalPlayer.Character
                local hum  = char and char:FindFirstChild("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end)
        Notify("Movement", "Infinite jump enabled", "success")
    else
        if Connections.InfJump then Connections.InfJump:Disconnect() Connections.InfJump = nil end
        Notify("Movement", "Infinite jump disabled", "warning")
    end
end

local function onFullbright(val)
    pcall(function()
        if val then
            Lighting.Brightness    = 2
            Lighting.ClockTime     = 14
            Lighting.FogEnd        = 1e6
            Lighting.GlobalShadows = false
            Notify("Visual", "Fullbright enabled", "success")
        else
            Lighting.Brightness    = 1
            Lighting.ClockTime     = 14
            Lighting.FogEnd        = 1e4
            Lighting.GlobalShadows = true
            Notify("Visual", "Fullbright disabled", "warning")
        end
    end)
end

local function onNameProtect(val)
    pcall(function()
        if val then
            LocalPlayer.DisplayName = "???"
            Notify("Misc", "Name protect ON · Hidden as ???", "success")
        else
            Notify("Misc", "Name protect OFF", "warning")
        end
    end)
end

local function onAntiAFK(val)
    if val then
        Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, "LeftShift", false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, "LeftShift", false, game)
            end)
        end)
        Notify("Misc", "Anti-AFK enabled", "success")
    else
        if Connections.AntiAFK then Connections.AntiAFK:Disconnect() Connections.AntiAFK = nil end
        Notify("Misc", "Anti-AFK disabled", "warning")
    end
end

-- ══════════════════════════════════════
--          MAIN GUI BUILDER
-- ══════════════════════════════════════
local function BuildGUI()
    -- Cleanup old
    pcall(function()
        local old = CoreGui:FindFirstChild("NexusHubGui")
        if old then old:Destroy() end
    end)

    local ScreenGui = Make("ScreenGui", {
        Name              = "NexusHubGui",
        ResetOnSpawn      = false,
        ZIndexBehavior    = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset    = true,
        DisplayOrder      = 999,
    })

    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

    -- Init notifications
    InitNotifications(ScreenGui)

    -- ── MAIN WINDOW ──────────────────────────
    local W, H = 420, 540

    local Main = Make("Frame", {
        Name             = "Main",
        Size             = UDim2.new(0, W, 0, H),
        Position         = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = T.Bg,
        BackgroundTransparency = 0,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, ScreenGui)
    RoundFrame(Main, 14)
    AddStroke(Main, T.Border, 1.5, 0.2)

    -- Ambient glow behind window
    local Glow = Make("Frame", {
        Size             = UDim2.new(1, 60, 1, 60),
        Position         = UDim2.new(0, -30, 0, -30),
        BackgroundColor3 = T.AccentGlow,
        BackgroundTransparency = 0.92,
        BorderSizePixel  = 0,
        ZIndex           = -1,
    }, Main)
    RoundFrame(Glow, 20)

    -- Ambient orb top-right
    local Orb = Make("Frame", {
        Size             = UDim2.new(0, 180, 0, 180),
        Position         = UDim2.new(1, -80, 0, -70),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.88,
        BorderSizePixel  = 0,
        ZIndex           = 0,
    }, Main)
    RoundFrame(Orb, 90)

    -- ── TITLEBAR ──────────────────────────────
    local TitleBar = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = T.BgSecondary,
        BackgroundTransparency = 0,
        BorderSizePixel  = 0,
        ZIndex           = 10,
    }, Main)

    -- Accent line under titlebar
    Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
    }, TitleBar)

    -- Logo dot
    local logoDot = Make("Frame", {
        Size             = UDim2.new(0, 10, 0, 10),
        Position         = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
    }, TitleBar)
    RoundFrame(logoDot, 5)

    -- Pulsing effect on logo dot
    local function pulseOrb()
        Tween(logoDot, { BackgroundTransparency = 0.5 }, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
        task.delay(0.8, function()
            Tween(logoDot, { BackgroundTransparency = 0 }, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
            task.delay(0.8, pulseOrb)
        end)
    end
    pulseOrb()

    Make("TextLabel", {
        Size             = UDim2.new(0, 120, 1, 0),
        Position         = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text             = "NEXUS HUB",
        TextColor3       = T.Text,
        Font             = Enum.Font.GothamBlack,
        TextSize         = 15,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, TitleBar)

    Make("TextLabel", {
        Size             = UDim2.new(0, 60, 1, 0),
        Position         = UDim2.new(0, 138, 0, 0),
        BackgroundTransparency = 1,
        Text             = "v1.0.0",
        TextColor3       = T.TextMuted,
        Font             = Enum.Font.GothamBold,
        TextSize         = 10,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, TitleBar)

    -- Keybind hint
    Make("TextLabel", {
        Size             = UDim2.new(0, 140, 1, 0),
        Position         = UDim2.new(0.5, -70, 0, 0),
        BackgroundTransparency = 1,
        Text             = "[ RightShift ]",
        TextColor3       = T.TextMuted,
        Font             = Enum.Font.GothamMedium,
        TextSize         = 10,
        TextXAlignment   = Enum.TextXAlignment.Center,
    }, TitleBar)

    -- Close / minimize buttons
    local CloseBtn = Make("TextButton", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -12, 0.5, 0),
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(239, 68, 68),
        BackgroundTransparency = 0.5,
        Text             = "×",
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Font             = Enum.Font.GothamBold,
        TextSize         = 16,
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
    }, TitleBar)
    RoundFrame(CloseBtn, 8)

    local MinBtn = Make("TextButton", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -46, 0.5, 0),
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(251, 191, 36),
        BackgroundTransparency = 0.5,
        Text             = "−",
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Font             = Enum.Font.GothamBold,
        TextSize         = 16,
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
    }, TitleBar)
    RoundFrame(MinBtn, 8)

    -- ── TAB BAR ───────────────────────────────
    local TabBar = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        Position         = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = T.BgSecondary,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        ClipsDescendants = true,
    }, Main)

    Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
    }, TabBar)

    local TabScroll = Make("ScrollingFrame", {
        Size                  = UDim2.new(1, -16, 1, 0),
        Position              = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        ScrollBarThickness    = 0,
        CanvasSize            = UDim2.new(0, 0, 1, 0),
        AutomaticCanvasSize   = Enum.AutomaticSize.X,
        ScrollingDirection    = Enum.ScrollingDirection.X,
    }, TabBar)

    Make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, 4),
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, TabScroll)

    -- ── CONTENT AREA ──────────────────────────
    local ContentArea = Make("Frame", {
        Size             = UDim2.new(1, 0, 1, -92),
        Position         = UDim2.new(0, 0, 0, 92),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, Main)

    -- ── TAB SYSTEM ────────────────────────────
    local Tabs     = {}
    local TabBtns  = {}
    local TabPages = {}

    local tabDefs = {
        { name = "Combat",   icon = "⚔" },
        { name = "Movement", icon = "⚡" },
        { name = "Visual",   icon = "👁" },
        { name = "Misc",     icon = "⚙" },
        { name = "Settings", icon = "◈" },
    }

    local function switchTab(name)
        Config.CurrentTab = name
        for tname, page in pairs(TabPages) do
            local isActive = tname == name
            page.Visible = isActive
        end
        for tname, btnData in pairs(TabBtns) do
            local isActive = tname == name
            Tween(btnData.btn, {
                BackgroundColor3      = isActive and T.Accent or Color3.fromRGB(0,0,0),
                BackgroundTransparency = isActive and 0 or 1,
                TextColor3            = isActive and Color3.fromRGB(255,255,255) or T.TextSub,
            }, 0.2):Play()
            Tween(btnData.indicator, {
                BackgroundTransparency = isActive and 0 or 1,
            }, 0.2):Play()
        end
    end

    for _, tab in ipairs(tabDefs) do
        -- Tab button
        local btn = Make("TextButton", {
            Size                  = UDim2.new(0, 90, 0, 30),
            BackgroundColor3      = Color3.fromRGB(0,0,0),
            BackgroundTransparency = 1,
            Text                  = tab.icon .. "  " .. tab.name,
            TextColor3            = T.TextSub,
            Font                  = Enum.Font.GothamBold,
            TextSize              = 11,
            BorderSizePixel       = 0,
            AutoButtonColor       = false,
        }, TabScroll)
        RoundFrame(btn, 6)

        -- Active indicator
        local indicator = Make("Frame", {
            Size             = UDim2.new(0.8, 0, 0, 2),
            Position         = UDim2.new(0.1, 0, 1, -1),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
        }, btn)
        RoundFrame(indicator, 1)

        TabBtns[tab.name] = { btn = btn, indicator = indicator }

        -- Tab page (scrollable)
        local page = Make("ScrollingFrame", {
            Name                  = "Page_" .. tab.name,
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            ScrollBarThickness    = 3,
            ScrollBarImageColor3  = T.Accent,
            CanvasSize            = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize   = Enum.AutomaticSize.Y,
            Visible               = false,
        }, ContentArea)

        Make("UIListLayout", {
            Padding   = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)
        Make("UIPadding", {
            PaddingLeft   = UDim.new(0, 12),
            PaddingRight  = UDim.new(0, 12),
            PaddingTop    = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
        }, page)

        TabPages[tab.name] = page

        btn.MouseButton1Click:Connect(function()
            switchTab(tab.name)
        end)
    end

    -- ── POPULATE: COMBAT ──────────────────────
    local combatPage = TabPages["Combat"]
    CreateSection(combatPage, "Aimbot")
    CreateToggle(combatPage, "Aimbot", "Lock onto nearest player",       "Aimbot",     function(v) Notify("Combat", v and "Aimbot ON" or "Aimbot OFF", v and "success" or "warning") end)
    CreateToggle(combatPage, "Silent Aim", "No visible crosshair snap",  "SilentAim",  function(v) Notify("Combat", v and "Silent Aim ON" or "Silent Aim OFF", v and "success" or "warning") end)
    CreateToggle(combatPage, "Triggerbot", "Auto-fire on target",        "Triggerbot", function(v) Notify("Combat", v and "Triggerbot ON" or "Triggerbot OFF", v and "success" or "warning") end)
    CreateSlider(combatPage, "Aimbot FOV",      10, 360, 120, "°",  function(v) FeatureStates.AimbotFOV = v end)
    CreateSlider(combatPage, "Aimbot Smoothness", 1, 20, 5,   "x",  function(v) FeatureStates.AimbotSmooth = v end)

    -- ── POPULATE: MOVEMENT ────────────────────
    local movePage = TabPages["Movement"]
    CreateSection(movePage, "Speed")
    CreateToggle(movePage, "Speed Hack",    "Override walk speed",  "SpeedHack",    onSpeedHack)
    CreateSlider(movePage, "Walk Speed",    16, 200, 28, " WS",     function(v) FeatureStates.SpeedValue = v; if FeatureStates.SpeedHack then pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = v end) end end)
    CreateSection(movePage, "Air")
    CreateToggle(movePage, "Fly",           "Free-flight mode",     "Fly",          onFly)
    CreateSlider(movePage, "Fly Speed",     10, 200, 50, " u/s",   function(v) FeatureStates.FlySpeed = v end)
    CreateSection(movePage, "Physics")
    CreateToggle(movePage, "Noclip",        "Pass through walls",   "Noclip",       onNoclip)
    CreateToggle(movePage, "Infinite Jump", "Jump anytime",         "InfJump",      onInfJump)
    CreateToggle(movePage, "Anti-Knockback","Ignore ragdoll forces","AntiKnockback",function(v) Notify("Movement", v and "Anti-Knockback ON" or "Anti-Knockback OFF", v and "success" or "warning") end)

    -- ── POPULATE: VISUAL ─────────────────────
    local visualPage = TabPages["Visual"]
    CreateSection(visualPage, "ESP")
    CreateToggle(visualPage, "ESP Master",   "Enable entity highlighting",  "ESP",           function(v) Notify("Visual", v and "ESP ON" or "ESP OFF", v and "success" or "warning") end)
    CreateToggle(visualPage, "Box ESP",      "Draw player bounding box",    "ESPBox",        function(v) Notify("Visual", v and "Box ESP ON" or "Box ESP OFF", v and "success" or "warning") end)
    CreateToggle(visualPage, "Health ESP",   "Show HP above players",       "ESPHealth",     function(v) Notify("Visual", v and "Health ESP ON" or "Health ESP OFF", v and "success" or "warning") end)
    CreateToggle(visualPage, "Name ESP",     "Show player usernames",       "ESPName",       function(v) Notify("Visual", v and "Name ESP ON" or "Name ESP OFF", v and "success" or "warning") end)
    CreateToggle(visualPage, "Distance ESP", "Show distance in studs",      "ESPDistance",   function(v) Notify("Visual", v and "Distance ESP ON" or "Distance ESP OFF", v and "success" or "warning") end)
    CreateSection(visualPage, "Lighting")
    CreateToggle(visualPage, "Fullbright",    "Maximum brightness",          "Fullbright",    onFullbright)
    CreateToggle(visualPage, "Remove Effects","Clear fog and blur",          "RemoveEffects", function(v)
        pcall(function()
            for _, fx in ipairs(Lighting:GetChildren()) do
                if fx:IsA("BlurEffect") or fx:IsA("DepthOfFieldEffect") or fx:IsA("SunRaysEffect") then
                    fx.Enabled = not v
                end
            end
        end)
        Notify("Visual", v and "Effects removed" or "Effects restored", v and "success" or "warning")
    end)

    -- ── POPULATE: MISC ────────────────────────
    local miscPage = TabPages["Misc"]
    CreateSection(miscPage, "Player")
    CreateToggle(miscPage, "Infinite Stamina", "Never run out of stamina",    "InfStamina",   function(v)
        if v then
            Loops.InfStamina = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char  = LocalPlayer.Character
                    if not char then return end
                    local stats = char:FindFirstChild("Stats") or LocalPlayer:FindFirstChild("Stats")
                    if stats then
                        local stamina = stats:FindFirstChild("Stamina")
                        if stamina then stamina.Value = stamina.MaxValue or 100 end
                    end
                end)
            end)
            Notify("Misc", "Infinite Stamina ON", "success")
        else
            if Loops.InfStamina then Loops.InfStamina:Disconnect() Loops.InfStamina = nil end
            Notify("Misc", "Infinite Stamina OFF", "warning")
        end
    end)
    CreateToggle(miscPage, "Name Protect",  "Hide your username as ???",  "NameProtect",  onNameProtect)
    CreateToggle(miscPage, "Anti-AFK",      "Prevent idle kick",          "AntiAFK",      onAntiAFK)
    CreateToggle(miscPage, "Chat Bypass",   "Send unicode-hidden chars",  "ChatBypass",   function(v) Notify("Misc", v and "Chat Bypass ON" or "Chat Bypass OFF", v and "success" or "warning") end)
    CreateSection(miscPage, "Server")
    CreateButton(miscPage, "Rejoin Server",  "Reconnect to current server", "default", function()
        Notify("Misc", "Rejoining server…", "info", 2)
        task.delay(1.5, function()
            pcall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            end)
        end)
    end)
    CreateButton(miscPage, "Leave Game",    "Exit to Roblox home", "danger", function()
        Notify("Misc", "Leaving game…", "warning", 1.5)
        task.delay(1, function() pcall(function() game:Shutdown() end) end)
    end)

    -- ── POPULATE: SETTINGS ────────────────────
    local settingsPage = TabPages["Settings"]
    CreateSection(settingsPage, "Appearance")
    CreateThemeSelector(settingsPage, function(themeName)
        T = Themes[themeName]
        -- Full rebuild on theme change for simplicity
        task.delay(0.3, function()
            BuildGUI()
            Notify("Settings", "Theme applied: " .. themeName, "success", 3)
        end)
    end)
    CreateTransparencyToggle(settingsPage, Main)
    CreateSection(settingsPage, "Keybind")
    local _, keySetter = CreateToggle(settingsPage, "RightShift to Toggle", "Press RightShift to show/hide menu", "___keybind", nil)
    keySetter(true)
    CreateSection(settingsPage, "Info")
    CreateButton(settingsPage, "NexusHub v1.0.0", "Made with ♥ — stay safe", "accent", function()
        Notify("NexusHub", "v1.0.0 — All features loaded", "info", 3)
    end)
    CreateButton(settingsPage, "Reset All Features", "Disable every active feature", "danger", function()
        for k in pairs(FeatureStates) do FeatureStates[k] = false end
        for _, loop in pairs(Loops) do pcall(function() loop:Disconnect() end) end
        for _, conn in pairs(Connections) do pcall(function() conn:Disconnect() end) end
        Loops = {}; Connections = {}
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed      = 16
                    hum.PlatformStand  = false
                end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
            Lighting.Brightness    = 1
            Lighting.GlobalShadows = true
        end)
        Notify("Settings", "All features reset", "warning", 3)
    end)

    -- ── DRAGGING ──────────────────────────────
    do
        local dragging, dragStart, startPos = false, nil, nil

        TitleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging  = true
                dragStart = inp.Position
                startPos  = Main.Position
            end
        end)
        TitleBar.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inp.Position - dragStart
                Main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- ── CLOSE / MINIMIZE ─────────────────────
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, { Size = UDim2.new(0, W, 0, 0), BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        task.delay(0.4, function()
            pcall(function() ScreenGui:Destroy() end)
        end)
    end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, { Size = UDim2.new(0, W, 0, 52) }, 0.35, Enum.EasingStyle.Back):Play()
        else
            Tween(Main, { Size = UDim2.new(0, W, 0, H)  }, 0.35, Enum.EasingStyle.Back):Play()
        end
    end)

    -- ── KEYBIND: RightShift ───────────────────
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.RightShift then
            Config.MenuVisible = not Config.MenuVisible
            if Config.MenuVisible then
                Main.Visible = true
                Main.Size    = UDim2.new(0, W, 0, 0)
                Tween(Main, { Size = UDim2.new(0, W, 0, H) }, 0.4, Enum.EasingStyle.Back):Play()
            else
                Tween(Main, { Size = UDim2.new(0, W, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
                task.delay(0.35, function() Main.Visible = false end)
            end
        end
    end)

    -- Activate default tab
    switchTab("Combat")

    -- Open animation
    Main.Size = UDim2.new(0, W, 0, 0)
    Tween(Main, { Size = UDim2.new(0, W, 0, H) }, 0.5, Enum.EasingStyle.Back):Play()
    task.delay(0.6, function()
        Notify("NexusHub", "Loaded · " .. #tabDefs .. " tabs · RightShift to toggle", "success", 4)
    end)

    return ScreenGui
end

-- ══════════════════════════════════════
--              LAUNCH
-- ══════════════════════════════════════
BuildGUI()

print("╔══════════════════════════════════╗")
print("║      NEXUS HUB v1.0.0 LOADED    ║")
print("║   Toggle: RightShift            ║")
print("║   Themes: Dark Aqua Rose Light  ║")
print("╚══════════════════════════════════╝")
