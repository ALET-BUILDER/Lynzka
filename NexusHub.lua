--[[
    ╔═══════════════════════════════════════════════════╗
    ║              N E X U S   H U B                   ║
    ║                  v2.0.0                          ║
    ║   Toggle : RightShift  |  Drag : Watermark       ║
    ║   Themes : Dark · Aqua · Rose · Light            ║
    ╚═══════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════
--              SERVICES
-- ═══════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService       = game:GetService("GuiService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local TeleportService  = game:GetService("TeleportService")

local LP    = Players.LocalPlayer
local PGui  = LP:WaitForChild("PlayerGui")
local Cam   = Workspace.CurrentCamera

-- ═══════════════════════════════════════
--              THEMES
-- ═══════════════════════════════════════
local Themes = {
    Dark = {
        Win       = Color3.fromRGB(14, 14, 20),
        Sidebar   = Color3.fromRGB(10, 10, 15),
        Header    = Color3.fromRGB(18, 18, 26),
        Card      = Color3.fromRGB(20, 20, 30),
        CardHov   = Color3.fromRGB(26, 26, 40),
        Accent    = Color3.fromRGB(110, 86, 255),
        AccentDim = Color3.fromRGB(60, 46, 160),
        Text      = Color3.fromRGB(240, 240, 255),
        TextSub   = Color3.fromRGB(150, 150, 190),
        TextDim   = Color3.fromRGB(70, 70, 110),
        Border    = Color3.fromRGB(35, 35, 55),
        Toggle    = Color3.fromRGB(110, 86, 255),
        TogOff    = Color3.fromRGB(35, 35, 55),
        SliderFg  = Color3.fromRGB(110, 86, 255),
        SliderBg  = Color3.fromRGB(30, 30, 48),
        Notif     = Color3.fromRGB(18, 18, 26),
        TabAct    = Color3.fromRGB(110, 86, 255),
        TabInact  = Color3.fromRGB(0, 0, 0),
    },
    Aqua = {
        Win       = Color3.fromRGB(8, 15, 22),
        Sidebar   = Color3.fromRGB(6, 11, 17),
        Header    = Color3.fromRGB(10, 20, 30),
        Card      = Color3.fromRGB(12, 22, 34),
        CardHov   = Color3.fromRGB(16, 30, 46),
        Accent    = Color3.fromRGB(0, 210, 220),
        AccentDim = Color3.fromRGB(0, 100, 110),
        Text      = Color3.fromRGB(210, 255, 255),
        TextSub   = Color3.fromRGB(100, 190, 210),
        TextDim   = Color3.fromRGB(40, 100, 120),
        Border    = Color3.fromRGB(20, 55, 75),
        Toggle    = Color3.fromRGB(0, 210, 220),
        TogOff    = Color3.fromRGB(20, 55, 75),
        SliderFg  = Color3.fromRGB(0, 210, 220),
        SliderBg  = Color3.fromRGB(15, 45, 60),
        Notif     = Color3.fromRGB(10, 20, 30),
        TabAct    = Color3.fromRGB(0, 210, 220),
        TabInact  = Color3.fromRGB(0, 0, 0),
    },
    Rose = {
        Win       = Color3.fromRGB(18, 10, 14),
        Sidebar   = Color3.fromRGB(13, 7, 10),
        Header    = Color3.fromRGB(24, 13, 18),
        Card      = Color3.fromRGB(28, 15, 22),
        CardHov   = Color3.fromRGB(38, 20, 30),
        Accent    = Color3.fromRGB(240, 60, 100),
        AccentDim = Color3.fromRGB(120, 30, 55),
        Text      = Color3.fromRGB(255, 225, 235),
        TextSub   = Color3.fromRGB(200, 130, 155),
        TextDim   = Color3.fromRGB(100, 55, 75),
        Border    = Color3.fromRGB(60, 25, 40),
        Toggle    = Color3.fromRGB(240, 60, 100),
        TogOff    = Color3.fromRGB(60, 25, 40),
        SliderFg  = Color3.fromRGB(240, 60, 100),
        SliderBg  = Color3.fromRGB(50, 20, 35),
        Notif     = Color3.fromRGB(24, 13, 18),
        TabAct    = Color3.fromRGB(240, 60, 100),
        TabInact  = Color3.fromRGB(0, 0, 0),
    },
    Light = {
        Win       = Color3.fromRGB(242, 242, 250),
        Sidebar   = Color3.fromRGB(230, 230, 242),
        Header    = Color3.fromRGB(250, 250, 255),
        Card      = Color3.fromRGB(255, 255, 255),
        CardHov   = Color3.fromRGB(235, 235, 248),
        Accent    = Color3.fromRGB(99, 76, 230),
        AccentDim = Color3.fromRGB(180, 170, 240),
        Text      = Color3.fromRGB(20, 20, 40),
        TextSub   = Color3.fromRGB(90, 90, 130),
        TextDim   = Color3.fromRGB(170, 170, 200),
        Border    = Color3.fromRGB(210, 210, 228),
        Toggle    = Color3.fromRGB(99, 76, 230),
        TogOff    = Color3.fromRGB(200, 200, 220),
        SliderFg  = Color3.fromRGB(99, 76, 230),
        SliderBg  = Color3.fromRGB(215, 215, 232),
        Notif     = Color3.fromRGB(255, 255, 255),
        TabAct    = Color3.fromRGB(99, 76, 230),
        TabInact  = Color3.fromRGB(0, 0, 0),
    },
}

-- ═══════════════════════════════════════
--             STATE
-- ═══════════════════════════════════════
local Cfg = {
    Theme      = "Dark",
    Transparen = false,
    MenuOpen   = true,
    ActiveTab  = nil,
}
local T = Themes[Cfg.Theme]

local Features = {
    SpeedHack=false, SpeedVal=28,
    Fly=false, FlySpeed=60,
    Noclip=false,
    InfJump=false,
    AntiKB=false,
    Aimbot=false, AimbotFOV=120, AimbotSmooth=5,
    SilentAim=false,
    Triggerbot=false,
    ESP=false, ESPBox=false, ESPHealth=false, ESPName=false, ESPDist=false,
    Fullbright=false,
    RemoveFX=false,
    InfStamina=false,
    NameProtect=false,
    AntiAFK=false,
    AutoRejoin=false,
}

local Loops = {}
local Conns = {}

-- ═══════════════════════════════════════
--           CORE HELPERS
-- ═══════════════════════════════════════
local function Tw(obj, goals, t, sty, dir)
    return TweenService:Create(obj,
        TweenInfo.new(t or .22, sty or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        goals)
end

local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end

local function Corner(p, r)
    return New("UICorner",{CornerRadius=UDim.new(0,r or 8)},p)
end

local function Stroke(p, col, thick, tr)
    return New("UIStroke",{Color=col or T.Border,Thickness=thick or 1,Transparency=tr or 0},p)
end

local function ListLayout(p, dir, pad, ha, va)
    return New("UIListLayout",{
        FillDirection = dir or Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, pad or 0),
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va or Enum.VerticalAlignment.Top,
        SortOrder           = Enum.SortOrder.LayoutOrder,
    }, p)
end

local function Pad(p, l,r,t,b)
    return New("UIPadding",{
        PaddingLeft   = UDim.new(0,l or 0),
        PaddingRight  = UDim.new(0,r or 0),
        PaddingTop    = UDim.new(0,t or 0),
        PaddingBottom = UDim.new(0,b or 0),
    }, p)
end

-- ═══════════════════════════════════════
--         NOTIFICATION SYSTEM
-- ═══════════════════════════════════════
local NotifHolder = nil

local function InitNotifs(sg)
    NotifHolder = New("Frame",{
        Name="NotifHolder",
        Size=UDim2.new(0,310,1,0),
        Position=UDim2.new(1,-320,0,0),
        BackgroundTransparency=1,
        ZIndex=9999,
    },sg)
    ListLayout(NotifHolder, Enum.FillDirection.Vertical, 8,
        Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
    Pad(NotifHolder,0,0,0,18)
end

local NotifColors = {
    success = Color3.fromRGB(34,197,94),
    warning = Color3.fromRGB(250,176,5),
    error   = Color3.fromRGB(240,68,68),
    info    = T.Accent,
}

local function Notif(title, msg, kind, dur)
    if not NotifHolder then return end
    dur  = dur  or 3.5
    kind = kind or "info"

    local accent = NotifColors[kind] or T.Accent

    -- Card
    local card = New("Frame",{
        Size                  = UDim2.new(1,0,0,70),
        BackgroundColor3      = T.Notif,
        BackgroundTransparency= 0,
        ClipsDescendants      = true,
        ZIndex                = 9999,
        LayoutOrder           = -tick(),
    },NotifHolder)
    Corner(card,10)
    Stroke(card,T.Border,1,0)

    -- Left accent bar
    New("Frame",{
        Size            =UDim2.new(0,3,1,0),
        BackgroundColor3=accent,
        BorderSizePixel =0,
        ZIndex          =10000,
    },card)

    -- Icon bg
    local ibg = New("Frame",{
        Size            =UDim2.new(0,34,0,34),
        Position        =UDim2.new(0,14,0.5,0),
        AnchorPoint     =Vector2.new(0,0.5),
        BackgroundColor3=accent,
        BackgroundTransparency=0.82,
        BorderSizePixel =0,
        ZIndex          =10000,
    },card)
    Corner(ibg,8)

    local iconMap={success="check",warning="alert",error="x",info="i"}
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=iconMap[kind] or "i",
        TextColor3=accent,
        Font=Enum.Font.GothamBlack,
        TextSize=13,
        ZIndex=10001,
    },ibg)

    -- Title
    New("TextLabel",{
        Size=UDim2.new(1,-60,0,18),
        Position=UDim2.new(0,58,0,10),
        BackgroundTransparency=1,
        Text=title,
        TextColor3=T.Text,
        Font=Enum.Font.GothamBold,
        TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=10000,
    },card)

    -- Message
    New("TextLabel",{
        Size=UDim2.new(1,-60,0,20),
        Position=UDim2.new(0,58,0,30),
        BackgroundTransparency=1,
        Text=msg,
        TextColor3=T.TextSub,
        Font=Enum.Font.Gotham,
        TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,
        ZIndex=10000,
    },card)

    -- Progress bar
    local pb = New("Frame",{
        Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=accent,
        BorderSizePixel=0,
        ZIndex=10001,
    },card)

    -- Slide in
    card.Position = UDim2.new(1,15,0,0)
    Tw(card,{Position=UDim2.new(0,0,0,0)},0.38,Enum.EasingStyle.Back):Play()
    Tw(pb,{Size=UDim2.new(0,0,0,2)},dur,Enum.EasingStyle.Linear):Play()

    task.delay(dur, function()
        pcall(function()
            Tw(card,{Position=UDim2.new(1,15,0,0)},0.3,Enum.EasingStyle.Quart):Play()
            task.delay(0.32,function() pcall(function() card:Destroy() end) end)
        end)
    end)
end

-- ═══════════════════════════════════════
--      COMPONENT: SECTION LABEL
-- ═══════════════════════════════════════
local function MkSection(parent, label)
    local wrap = New("Frame",{
        Size=UDim2.new(1,0,0,26),
        BackgroundTransparency=1,
    },parent)

    New("TextLabel",{
        Size=UDim2.new(1,-8,1,0),
        Position=UDim2.new(0,4,0,0),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=T.Accent,
        Font=Enum.Font.GothamBlack,
        TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,
    },wrap)

    New("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=T.Border,
        BorderSizePixel=0,
    },wrap)
    return wrap
end

-- ═══════════════════════════════════════
--      COMPONENT: TOGGLE
-- ═══════════════════════════════════════
local function MkToggle(parent, label, sub, featKey, cb)
    local h = sub and 56 or 44
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,h),
        BackgroundColor3=T.Card,
        BorderSizePixel=0,
    },parent)
    Corner(row,8)
    Stroke(row,T.Border,1,0)

    New("TextLabel",{
        Size=UDim2.new(1,-64,0,16),
        Position=UDim2.new(0,12,0,sub and 9 or 14),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=T.Text,
        Font=Enum.Font.GothamBold,
        TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,
    },row)

    if sub then
        New("TextLabel",{
            Size=UDim2.new(1,-64,0,13),
            Position=UDim2.new(0,12,0,27),
            BackgroundTransparency=1,
            Text=sub,
            TextColor3=T.TextDim,
            Font=Enum.Font.Gotham,
            TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)
    end

    -- Pill
    local pill = New("Frame",{
        Size=UDim2.new(0,42,0,22),
        Position=UDim2.new(1,-52,0.5,0),
        AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=T.TogOff,
        BorderSizePixel=0,
    },row)
    Corner(pill,11)

    local knob = New("Frame",{
        Size=UDim2.new(0,16,0,16),
        Position=UDim2.new(0,3,0.5,0),
        AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=T.TextDim,
        BorderSizePixel=0,
    },pill)
    Corner(knob,8)

    local state = Features[featKey] or false

    local function setVisual(on, instant)
        local t = instant and 0 or .2
        if on then
            Tw(pill, {BackgroundColor3=T.Toggle}, t):Play()
            Tw(knob, {BackgroundColor3=Color3.fromRGB(255,255,255), Position=UDim2.new(0,23,0.5,0)}, t):Play()
        else
            Tw(pill, {BackgroundColor3=T.TogOff}, t):Play()
            Tw(knob, {BackgroundColor3=T.TextDim,  Position=UDim2.new(0,3,0.5,0)}, t):Play()
        end
    end
    setVisual(state, true)

    local btn = New("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="", ZIndex=5,
        AutoButtonColor=false,
    },row)

    btn.MouseEnter:Connect(function()
        Tw(row,{BackgroundColor3=T.CardHov},.14):Play()
    end)
    btn.MouseLeave:Connect(function()
        Tw(row,{BackgroundColor3=T.Card},.14):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        state = not state
        Features[featKey] = state
        setVisual(state)
        Tw(knob,{Size=UDim2.new(0,19,0,19)},.08):Play()
        task.delay(.09,function() Tw(knob,{Size=UDim2.new(0,16,0,16)},.08):Play() end)
        if cb then pcall(cb, state) end
    end)

    return row, function(v) state=v; Features[featKey]=v; setVisual(v) end
end

-- ═══════════════════════════════════════
--      COMPONENT: SLIDER
-- ═══════════════════════════════════════
local function MkSlider(parent, label, mn, mx, def, sfx, cb)
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,60),
        BackgroundColor3=T.Card,
        BorderSizePixel=0,
    },parent)
    Corner(row,8)
    Stroke(row,T.Border,1,0)

    New("TextLabel",{
        Size=UDim2.new(1,-80,0,16),
        Position=UDim2.new(0,12,0,10),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=T.Text,
        Font=Enum.Font.GothamBold,
        TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,
    },row)

    local valLbl = New("TextLabel",{
        Size=UDim2.new(0,64,0,16),
        Position=UDim2.new(1,-76,0,10),
        BackgroundTransparency=1,
        Text=tostring(def)..(sfx or ""),
        TextColor3=T.Accent,
        Font=Enum.Font.GothamBold,
        TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Right,
    },row)

    -- Track bg
    local track = New("Frame",{
        Size=UDim2.new(1,-24,0,5),
        Position=UDim2.new(0,12,0,38),
        BackgroundColor3=T.SliderBg,
        BorderSizePixel=0,
    },row)
    Corner(track,3)

    local pct0 = (def-mn)/(mx-mn)
    local fill = New("Frame",{
        Size=UDim2.new(pct0,0,1,0),
        BackgroundColor3=T.SliderFg,
        BorderSizePixel=0,
    },track)
    Corner(fill,3)

    local thumb = New("Frame",{
        Size=UDim2.new(0,14,0,14),
        Position=UDim2.new(pct0,-7,0.5,0),
        AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=Color3.fromRGB(255,255,255),
        BorderSizePixel=0,
        ZIndex=5,
    },track)
    Corner(thumb,7)

    local dragging = false
    local val = def

    local function update(x)
        local ap = track.AbsolutePosition.X
        local as = track.AbsoluteSize.X
        local r  = math.clamp((x-ap)/as,0,1)
        val = math.floor(mn + r*(mx-mn))
        valLbl.Text = tostring(val)..(sfx or "")
        Tw(fill, {Size=UDim2.new(r,0,1,0)}, .05):Play()
        Tw(thumb,{Position=UDim2.new(r,-7,0.5,0)}, .05):Play()
        if cb then pcall(cb,val) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    return row
end

-- ═══════════════════════════════════════
--      COMPONENT: BUTTON
-- ═══════════════════════════════════════
local function MkButton(parent, label, sub, variant, cb)
    -- variant: "default"|"danger"|"accent"
    local h = sub and 54 or 44
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,h),
        BackgroundColor3=T.Card,
        BorderSizePixel=0,
    },parent)
    Corner(row,8)
    local bcolor = variant=="danger" and Color3.fromRGB(240,68,68)
               or  variant=="accent" and T.Accent
               or  T.Border
    Stroke(row,bcolor,1, variant=="default" and 0 or 0)

    -- Left accent sliver
    New("Frame",{
        Size=UDim2.new(0,3,0.65,0),
        Position=UDim2.new(0,0,0.175,0),
        BackgroundColor3=bcolor==T.Border and T.Accent or bcolor,
        BorderSizePixel=0,
    },row)

    local textColor = variant=="danger" and Color3.fromRGB(240,68,68)
                   or variant=="accent" and T.Accent
                   or T.Text
    New("TextLabel",{
        Size=UDim2.new(1,-50,0,16),
        Position=UDim2.new(0,12,0,sub and 9 or 14),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=textColor,
        Font=Enum.Font.GothamBold,
        TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,
    },row)

    if sub then
        New("TextLabel",{
            Size=UDim2.new(1,-50,0,13),
            Position=UDim2.new(0,12,0,27),
            BackgroundTransparency=1,
            Text=sub,
            TextColor3=T.TextDim,
            Font=Enum.Font.Gotham,
            TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
        },row)
    end

    -- Arrow
    New("TextLabel",{
        Size=UDim2.new(0,28,1,0),
        Position=UDim2.new(1,-34,0,0),
        BackgroundTransparency=1,
        Text=">",
        TextColor3=T.TextDim,
        Font=Enum.Font.GothamBold,
        TextSize=16,
    },row)

    local btn = New("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="", ZIndex=5,
        AutoButtonColor=false,
    },row)
    btn.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=T.CardHov},.14):Play() end)
    btn.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=T.Card},.14):Play() end)
    btn.MouseButton1Click:Connect(function()
        local fl=New("Frame",{
            Size=UDim2.new(1,0,1,0),
            BackgroundColor3=Color3.fromRGB(255,255,255),
            BackgroundTransparency=0.88,
            ZIndex=6,
        },row)
        Corner(fl,8)
        Tw(fl,{BackgroundTransparency=1},.28):Play()
        task.delay(.3,function() pcall(function() fl:Destroy() end) end)
        if cb then pcall(cb) end
    end)
    return row
end

-- ═══════════════════════════════════════
--      COMPONENT: THEME PICKER
-- ═══════════════════════════════════════
local function MkThemePicker(parent, onPick)
    local wrap = New("Frame",{
        Size=UDim2.new(1,0,0,60),
        BackgroundColor3=T.Card,
        BorderSizePixel=0,
    },parent)
    Corner(wrap,8)
    Stroke(wrap,T.Border,1,0)

    New("TextLabel",{
        Size=UDim2.new(1,-12,0,16),
        Position=UDim2.new(0,12,0,8),
        BackgroundTransparency=1,
        Text="Theme",
        TextColor3=T.Text,
        Font=Enum.Font.GothamBold,
        TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,
    },wrap)

    local btnRow = New("Frame",{
        Size=UDim2.new(1,-24,0,22),
        Position=UDim2.new(0,12,0,30),
        BackgroundTransparency=1,
    },wrap)
    ListLayout(btnRow,Enum.FillDirection.Horizontal,6)

    local tCols={
        Dark =Color3.fromRGB(110,86,255),
        Aqua =Color3.fromRGB(0,210,220),
        Rose =Color3.fromRGB(240,60,100),
        Light=Color3.fromRGB(180,180,220),
    }
    local order={"Dark","Aqua","Rose","Light"}
    for _,name in ipairs(order) do
        local active = Cfg.Theme==name
        local p = New("TextButton",{
            Size=UDim2.new(0,62,1,0),
            BackgroundColor3=active and tCols[name] or T.TogOff,
            Text=name,
            TextColor3=active and Color3.fromRGB(255,255,255) or T.TextSub,
            Font=Enum.Font.GothamBold,
            TextSize=10,
            BorderSizePixel=0,
            AutoButtonColor=false,
        },btnRow)
        Corner(p,5)
        p.MouseButton1Click:Connect(function()
            if onPick then onPick(name) end
        end)
    end
    return wrap
end

-- ═══════════════════════════════════════
--         FEATURE CALLBACKS
-- ═══════════════════════════════════════
local function onSpeed(v)
    if v then
        Loops.Speed=RunService.Heartbeat:Connect(function()
            pcall(function()
                local c=LP.Character; if not c then return end
                local h=c:FindFirstChild("Humanoid"); if h then h.WalkSpeed=Features.SpeedVal end
            end)
        end)
        Notif("Movement","Speed Hack enabled · "..Features.SpeedVal.." WS","success")
    else
        if Loops.Speed then Loops.Speed:Disconnect(); Loops.Speed=nil end
        pcall(function()
            local c=LP.Character; local h=c and c:FindFirstChild("Humanoid")
            if h then h.WalkSpeed=16 end
        end)
        Notif("Movement","Speed Hack disabled","warning")
    end
end

local function onFly(v)
    if v then
        local flyConn
        pcall(function()
            local c=LP.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hum=c:FindFirstChild("Humanoid"); if hum then hum.PlatformStand=true end
            local bv=New("BodyVelocity",{MaxForce=Vector3.new(1e5,1e5,1e5),Velocity=Vector3.zero},hrp)
            flyConn=RunService.Heartbeat:Connect(function()
                if not Features.Fly then
                    pcall(function() bv:Destroy() end)
                    if hum then hum.PlatformStand=false end
                    flyConn:Disconnect(); return
                end
                local sp=Features.FlySpeed; local cf=Cam.CFrame; local d=Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then d=d+cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then d=d-cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then d=d-cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then d=d+cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.yAxis end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.yAxis end
                bv.Velocity=d.Magnitude>0 and d.Unit*sp or Vector3.zero
            end)
            Loops.Fly=flyConn
        end)
        Notif("Movement","Fly enabled  ·  WASD + Space/Ctrl","success")
    else
        if Loops.Fly then pcall(function() Loops.Fly:Disconnect() end); Loops.Fly=nil end
        pcall(function()
            local c=LP.Character; if not c then return end
            local hum=c:FindFirstChild("Humanoid"); if hum then hum.PlatformStand=false end
            local hrp=c:FindFirstChild("HumanoidRootPart")
            if hrp then local bv=hrp:FindFirstChildOfClass("BodyVelocity"); if bv then bv:Destroy() end end
        end)
        Notif("Movement","Fly disabled","warning")
    end
end

local function onNoclip(v)
    if v then
        Loops.Noclip=RunService.Stepped:Connect(function()
            pcall(function()
                local c=LP.Character; if not c then return end
                for _,p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end)
        end)
        Notif("Movement","Noclip enabled","success")
    else
        if Loops.Noclip then Loops.Noclip:Disconnect(); Loops.Noclip=nil end
        Notif("Movement","Noclip disabled","warning")
    end
end

local function onInfJump(v)
    if v then
        Conns.InfJump=UserInputService.JumpRequest:Connect(function()
            pcall(function()
                local c=LP.Character; local h=c and c:FindFirstChild("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end)
        Notif("Movement","Infinite Jump enabled","success")
    else
        if Conns.InfJump then Conns.InfJump:Disconnect(); Conns.InfJump=nil end
        Notif("Movement","Infinite Jump disabled","warning")
    end
end

local function onFullbright(v)
    pcall(function()
        Lighting.Brightness=v and 2 or 1
        Lighting.ClockTime=14
        Lighting.FogEnd=v and 1e6 or 1e4
        Lighting.GlobalShadows=not v
    end)
    Notif("Visual",v and "Fullbright ON" or "Fullbright OFF",v and "success" or "warning")
end

local function onRemoveFX(v)
    pcall(function()
        for _,fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("BlurEffect") or fx:IsA("DepthOfFieldEffect") or fx:IsA("SunRaysEffect") then
                fx.Enabled=not v
            end
        end
    end)
    Notif("Visual",v and "Effects removed" or "Effects restored",v and "success" or "warning")
end

local function onAntiAFK(v)
    if v then
        Conns.AntiAFK=LP.Idled:Connect(function()
            pcall(function()
                local vim=game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true,"LeftShift",false,game)
                task.wait(.1)
                vim:SendKeyEvent(false,"LeftShift",false,game)
            end)
        end)
        Notif("Misc","Anti-AFK enabled","success")
    else
        if Conns.AntiAFK then Conns.AntiAFK:Disconnect(); Conns.AntiAFK=nil end
        Notif("Misc","Anti-AFK disabled","warning")
    end
end

local function resetAll()
    -- Disable all loops/connections
    for k,v in pairs(Loops) do pcall(function() v:Disconnect() end) end
    for k,v in pairs(Conns) do pcall(function() v:Disconnect() end) end
    Loops={}; Conns={}
    for k in pairs(Features) do
        if type(Features[k])=="boolean" then Features[k]=false end
    end
    pcall(function()
        local c=LP.Character; if not c then return end
        local h=c:FindFirstChild("Humanoid")
        if h then h.WalkSpeed=16; h.PlatformStand=false end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=true end
        end
    end)
    pcall(function()
        Lighting.Brightness=1; Lighting.GlobalShadows=true
        Lighting.FogEnd=1e4
    end)
    Notif("Settings","All features have been reset","warning",4)
end

-- ═══════════════════════════════════════
--            MAIN BUILD
-- ═══════════════════════════════════════
local function Build()
    pcall(function()
        local old=CoreGui:FindFirstChild("NexusHubGui")
        if old then old:Destroy() end
    end)

    local SG = New("ScreenGui",{
        Name="NexusHubGui",
        ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Global,
        IgnoreGuiInset=true,
        DisplayOrder=9999,
    })
    pcall(function() SG.Parent=CoreGui end)
    if not SG.Parent then SG.Parent=PGui end

    InitNotifs(SG)

    -- ─── DIMENSIONS ────────────────────────────
    local W, H = 580, 460
    local SBW  = 158  -- sidebar width

    -- ─── WATERMARK (drag handle + toggle btn) ──
    local WM = New("Frame",{
        Name="Watermark",
        Size=UDim2.new(0,160,0,34),
        Position=UDim2.new(0,16,0,16),
        BackgroundColor3=T.Header,
        BorderSizePixel=0,
        ZIndex=8000,
    },SG)
    Corner(WM,9)
    Stroke(WM,T.Border,1,0)

    New("TextLabel",{
        Size=UDim2.new(1,-44,1,0),
        Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,
        Text="NEXUS HUB",
        TextColor3=T.Accent,
        Font=Enum.Font.GothamBlack,
        TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=8001,
    },WM)

    New("TextLabel",{
        Size=UDim2.new(0,40,1,0),
        Position=UDim2.new(0,93,0,0),
        BackgroundTransparency=1,
        Text="v2.0",
        TextColor3=T.TextDim,
        Font=Enum.Font.GothamMedium,
        TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=8001,
    },WM)

    -- Chevron icon button area
    local chevronBtn = New("TextButton",{
        Size=UDim2.new(0,32,0,32),
        Position=UDim2.new(1,-34,0.5,0),
        AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=T.AccentDim,
        BackgroundTransparency=0.4,
        Text="",
        BorderSizePixel=0,
        ZIndex=8002,
        AutoButtonColor=false,
    },WM)
    Corner(chevronBtn,7)

    -- Draw a simple arrow/chevron with two frames
    local ch1 = New("Frame",{Size=UDim2.new(0,8,0,2),Position=UDim2.new(0.5,-7,0.5,-2),AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=T.Accent,BorderSizePixel=0,Rotation=40,ZIndex=8003},chevronBtn)
    Corner(ch1,1)
    local ch2 = New("Frame",{Size=UDim2.new(0,8,0,2),Position=UDim2.new(0.5,1,0.5,-2),AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=T.Accent,BorderSizePixel=0,Rotation=-40,ZIndex=8003},chevronBtn)
    Corner(ch2,1)

    -- Watermark drag
    do
        local wDragging,wStart,wPos=false,nil,nil
        WM.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                wDragging=true; wStart=i.Position; wPos=WM.Position
            end
        end)
        WM.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then wDragging=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if wDragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-wStart
                WM.Position=UDim2.new(0,wPos.X.Offset+d.X,0,wPos.Y.Offset+d.Y)
            end
        end)
    end

    -- ─── MAIN WINDOW ───────────────────────────
    local Main = New("Frame",{
        Name="Main",
        Size=UDim2.new(0,W,0,H),
        Position=UDim2.new(0.5,-W/2,0.5,-H/2),
        BackgroundColor3=T.Win,
        BorderSizePixel=0,
        ClipsDescendants=true,
        ZIndex=100,
    },SG)
    Corner(Main,12)
    Stroke(Main,T.Border,1.5,0)

    -- ─── SIDEBAR ───────────────────────────────
    local Sidebar = New("Frame",{
        Size=UDim2.new(0,SBW,1,0),
        BackgroundColor3=T.Sidebar,
        BorderSizePixel=0,
        ClipsDescendants=true,
    },Main)

    -- Sidebar top branding
    local Brand = New("Frame",{
        Size=UDim2.new(1,0,0,60),
        BackgroundTransparency=1,
    },Sidebar)

    -- Accent dot animated
    local dot = New("Frame",{
        Size=UDim2.new(0,8,0,8),
        Position=UDim2.new(0,18,0,26),
        AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=T.Accent,
        BorderSizePixel=0,
    },Brand)
    Corner(dot,4)

    local function pulseDot()
        Tw(dot,{BackgroundTransparency=0.6},0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut):Play()
        task.delay(0.7,function()
            Tw(dot,{BackgroundTransparency=0},0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut):Play()
            task.delay(0.7,pulseDot)
        end)
    end
    pulseDot()

    New("TextLabel",{
        Size=UDim2.new(1,-34,0,18),
        Position=UDim2.new(0,30,0,17),
        BackgroundTransparency=1,
        Text="NEXUS HUB",
        TextColor3=T.Text,
        Font=Enum.Font.GothamBlack,
        TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    },Brand)
    New("TextLabel",{
        Size=UDim2.new(1,-34,0,12),
        Position=UDim2.new(0,30,0,36),
        BackgroundTransparency=1,
        Text="v2.0.0",
        TextColor3=T.TextDim,
        Font=Enum.Font.GothamMedium,
        TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,
    },Brand)

    -- Divider
    New("Frame",{
        Size=UDim2.new(1,-24,0,1),
        Position=UDim2.new(0,12,0,60),
        BackgroundColor3=T.Border,
        BorderSizePixel=0,
    },Sidebar)

    -- Tab list
    local TabList = New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-130),
        Position=UDim2.new(0,0,0,68),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
    },Sidebar)
    ListLayout(TabList,Enum.FillDirection.Vertical,2)
    Pad(TabList,8,8,6,6)

    -- Bottom sidebar info
    local sbBot = New("Frame",{
        Size=UDim2.new(1,0,0,60),
        Position=UDim2.new(0,0,1,-60),
        BackgroundTransparency=1,
    },Sidebar)
    New("Frame",{
        Size=UDim2.new(1,-24,0,1),
        Position=UDim2.new(0,12,0,0),
        BackgroundColor3=T.Border,
        BorderSizePixel=0,
    },sbBot)

    -- Player info in sidebar bottom
    local playerName = LP.DisplayName or LP.Name
    New("TextLabel",{
        Size=UDim2.new(1,-16,0,16),
        Position=UDim2.new(0,8,0,10),
        BackgroundTransparency=1,
        Text=playerName,
        TextColor3=T.TextSub,
        Font=Enum.Font.GothamBold,
        TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
    },sbBot)
    New("TextLabel",{
        Size=UDim2.new(1,-16,0,14),
        Position=UDim2.new(0,8,0,26),
        BackgroundTransparency=1,
        Text="RightShift to toggle",
        TextColor3=T.TextDim,
        Font=Enum.Font.Gotham,
        TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,
    },sbBot)

    -- ─── HEADER BAR (right side) ───────────────
    local Header = New("Frame",{
        Size=UDim2.new(1,-SBW,0,46),
        Position=UDim2.new(0,SBW,0,0),
        BackgroundColor3=T.Header,
        BorderSizePixel=0,
    },Main)

    -- Divider bottom of header
    New("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,1,0),
        BackgroundColor3=T.Border,
        BorderSizePixel=0,
    },Header)

    local TabTitle = New("TextLabel",{
        Size=UDim2.new(1,-100,1,0),
        Position=UDim2.new(0,16,0,0),
        BackgroundTransparency=1,
        Text="",
        TextColor3=T.Text,
        Font=Enum.Font.GothamBold,
        TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left,
    },Header)

    -- Window controls: minimize + close
    local function makeCtrlBtn(xOff, col, label)
        local b = New("TextButton",{
            Size=UDim2.new(0,26,0,26),
            Position=UDim2.new(1,xOff,0.5,0),
            AnchorPoint=Vector2.new(1,0.5),
            BackgroundColor3=col,
            BackgroundTransparency=0.45,
            Text=label,
            TextColor3=Color3.fromRGB(255,255,255),
            Font=Enum.Font.GothamBold,
            TextSize=14,
            BorderSizePixel=0,
            AutoButtonColor=false,
            ZIndex=200,
        },Header)
        Corner(b,7)
        b.MouseEnter:Connect(function() Tw(b,{BackgroundTransparency=0},.12):Play() end)
        b.MouseLeave:Connect(function() Tw(b,{BackgroundTransparency=0.45},.12):Play() end)
        return b
    end
    local closeBtn = makeCtrlBtn(-10, Color3.fromRGB(240,68,68),  "x")
    local minBtn   = makeCtrlBtn(-42, Color3.fromRGB(250,176,5),  "-")
    local maxBtn   = makeCtrlBtn(-74, Color3.fromRGB(34,197,94),  "+")

    -- ─── CONTENT AREA ──────────────────────────
    local Content = New("Frame",{
        Size=UDim2.new(1,-SBW,1,-46),
        Position=UDim2.new(0,SBW,0,46),
        BackgroundTransparency=1,
        ClipsDescendants=true,
    },Main)

    -- ─── DRAG (header) ─────────────────────────
    do
        local dg,ds,dp=false,nil,nil
        Header.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dg=true; ds=i.Position; dp=Main.Position
            end
        end)
        Header.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dg and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-ds
                Main.Position=UDim2.new(0,dp.X.Offset+d.X,0,dp.Y.Offset+d.Y)
            end
        end)
    end

    -- ─── WINDOW CONTROLS LOGIC ─────────────────
    local minimized=false
    local fullH=H

    minBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        if minimized then
            Tw(Main,{Size=UDim2.new(0,W,0,46)},0.3,Enum.EasingStyle.Back):Play()
            minBtn.Text="+"
        else
            Tw(Main,{Size=UDim2.new(0,W,0,fullH)},0.3,Enum.EasingStyle.Back):Play()
            minBtn.Text="-"
        end
    end)

    maxBtn.MouseButton1Click:Connect(function()
        -- Toggle between default size and larger
        if fullH==460 then
            fullH=560
        else
            fullH=460
        end
        minimized=false
        minBtn.Text="-"
        Tw(Main,{Size=UDim2.new(0,W,0,fullH)},0.32,Enum.EasingStyle.Back):Play()
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Tw(Main,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In):Play()
        Tw(WM,{BackgroundTransparency=1,Size=UDim2.new(0,0,0,34)},0.3):Play()
        task.delay(0.35,function() pcall(function() SG:Destroy() end) end)
    end)

    -- Chevron (watermark) toggles menu
    local function toggleMenu(show)
        Cfg.MenuOpen=show
        if show then
            Main.Visible=true
            Main.Size=UDim2.new(0,W,0,0)
            Tw(Main,{Size=UDim2.new(0,W,0,fullH)},0.4,Enum.EasingStyle.Back):Play()
            -- rotate chevron down
            Tw(ch1,{Rotation=40},0.2):Play()
            Tw(ch2,{Rotation=-40},0.2):Play()
        else
            Tw(Main,{Size=UDim2.new(0,W,0,0)},0.28,Enum.EasingStyle.Back,Enum.EasingDirection.In):Play()
            task.delay(0.3,function() Main.Visible=false end)
            -- rotate chevron up
            Tw(ch1,{Rotation=-40},0.2):Play()
            Tw(ch2,{Rotation=40},0.2):Play()
        end
    end

    chevronBtn.MouseButton1Click:Connect(function()
        toggleMenu(not Cfg.MenuOpen)
    end)

    UserInputService.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.RightShift then
            toggleMenu(not Cfg.MenuOpen)
        end
    end)

    -- ─── TAB SYSTEM ────────────────────────────
    local TabBtns  = {}
    local TabPages = {}
    local ActiveTab= nil

    local function switchTab(name)
        ActiveTab=name
        TabTitle.Text=name
        for n,pg in pairs(TabPages) do pg.Visible=(n==name) end
        for n,bd in pairs(TabBtns) do
            local on=(n==name)
            Tw(bd.bg,{
                BackgroundColor3=on and T.Accent or Color3.fromRGB(0,0,0),
                BackgroundTransparency=on and 0 or 1,
            },0.18):Play()
            Tw(bd.lbl,{TextColor3=on and Color3.fromRGB(255,255,255) or T.TextSub},0.18):Play()
            Tw(bd.bar,{BackgroundTransparency=on and 0 or 1},0.18):Play()
        end
    end

    local tabDefs = {
        {name="Combat",   icon="CB"},
        {name="Movement", icon="MV"},
        {name="Visual",   icon="VS"},
        {name="Misc",     icon="MC"},
        {name="Settings", icon="ST"},
    }

    for _,td in ipairs(tabDefs) do
        -- Button
        local tbg = New("Frame",{
            Size=UDim2.new(1,0,0,36),
            BackgroundColor3=Color3.fromRGB(0,0,0),
            BackgroundTransparency=1,
            BorderSizePixel=0,
        },TabList)
        Corner(tbg,8)

        -- Active indicator bar (left)
        local tbar = New("Frame",{
            Size=UDim2.new(0,3,0.6,0),
            Position=UDim2.new(0,0,0.2,0),
            BackgroundColor3=T.Accent,
            BackgroundTransparency=1,
            BorderSizePixel=0,
        },tbg)
        Corner(tbar,2)

        -- Icon pill
        local iconPill = New("Frame",{
            Size=UDim2.new(0,26,0,26),
            Position=UDim2.new(0,12,0.5,0),
            AnchorPoint=Vector2.new(0,0.5),
            BackgroundColor3=T.AccentDim,
            BackgroundTransparency=0.5,
            BorderSizePixel=0,
        },tbg)
        Corner(iconPill,6)
        New("TextLabel",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            Text=td.icon,
            TextColor3=T.Accent,
            Font=Enum.Font.GothamBlack,
            TextSize=8,
        },iconPill)

        local tlbl = New("TextLabel",{
            Size=UDim2.new(1,-50,1,0),
            Position=UDim2.new(0,46,0,0),
            BackgroundTransparency=1,
            Text=td.name,
            TextColor3=T.TextSub,
            Font=Enum.Font.GothamBold,
            TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left,
        },tbg)

        local tbtn = New("TextButton",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            Text="", ZIndex=5,
            AutoButtonColor=false,
        },tbg)

        tbtn.MouseEnter:Connect(function()
            if ActiveTab~=td.name then
                Tw(tbg,{BackgroundTransparency=0.85},0.12):Play()
                tbg.BackgroundColor3=T.CardHov
            end
        end)
        tbtn.MouseLeave:Connect(function()
            if ActiveTab~=td.name then
                Tw(tbg,{BackgroundTransparency=1},0.12):Play()
            end
        end)
        tbtn.MouseButton1Click:Connect(function()
            switchTab(td.name)
        end)

        TabBtns[td.name]={bg=tbg,lbl=tlbl,bar=tbar}

        -- Page
        local pg = New("ScrollingFrame",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            BorderSizePixel=0,
            ScrollBarThickness=3,
            ScrollBarImageColor3=T.Accent,
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=false,
        },Content)
        ListLayout(pg,Enum.FillDirection.Vertical,6)
        Pad(pg,12,12,12,12)

        TabPages[td.name]=pg
    end

    -- ─── POPULATE: COMBAT ──────────────────────
    local cp=TabPages["Combat"]
    MkSection(cp,"AIMBOT")
    MkToggle(cp,"Aimbot","Lock camera to nearest target","Aimbot",function(v) Notif("Combat",v and "Aimbot ON" or "Aimbot OFF",v and "success" or "warning") end)
    MkToggle(cp,"Silent Aim","No visible snap","SilentAim",function(v) Notif("Combat",v and "Silent Aim ON" or "Silent Aim OFF",v and "success" or "warning") end)
    MkToggle(cp,"Triggerbot","Auto-fire when on target","Triggerbot",function(v) Notif("Combat",v and "Triggerbot ON" or "Triggerbot OFF",v and "success" or "warning") end)
    MkSlider(cp,"FOV Radius",10,500,120," px",function(v) Features.AimbotFOV=v end)
    MkSlider(cp,"Smoothness",1,20,5,"x",function(v) Features.AimbotSmooth=v end)
    MkSection(cp,"COMBAT")
    MkToggle(cp,"Anti-Knockback","Ignore ragdoll force","AntiKB",function(v) Notif("Combat",v and "Anti-KB ON" or "Anti-KB OFF",v and "success" or "warning") end)

    -- ─── POPULATE: MOVEMENT ────────────────────
    local mp=TabPages["Movement"]
    MkSection(mp,"SPEED")
    MkToggle(mp,"Speed Hack","Override walk speed","SpeedHack",onSpeed)
    MkSlider(mp,"Walk Speed",16,300,28," WS",function(v)
        Features.SpeedVal=v
        if Features.SpeedHack then
            pcall(function() LP.Character.Humanoid.WalkSpeed=v end)
        end
    end)
    MkSection(mp,"AIR")
    MkToggle(mp,"Fly","Free-flight · WASD + Space/Ctrl","Fly",onFly)
    MkSlider(mp,"Fly Speed",10,300,60," u/s",function(v) Features.FlySpeed=v end)
    MkSection(mp,"PHYSICS")
    MkToggle(mp,"Noclip","Phase through parts","Noclip",onNoclip)
    MkToggle(mp,"Infinite Jump","Jump from any state","InfJump",onInfJump)

    -- ─── POPULATE: VISUAL ──────────────────────
    local vp=TabPages["Visual"]
    MkSection(vp,"ESP")
    MkToggle(vp,"ESP Master","Enable player ESP","ESP",function(v) Notif("Visual",v and "ESP ON" or "ESP OFF",v and "success" or "warning") end)
    MkToggle(vp,"Box ESP","Draw bounding box","ESPBox",function(v) Notif("Visual",v and "Box ESP ON" or "Box ESP OFF",v and "success" or "warning") end)
    MkToggle(vp,"Health ESP","Show HP bar","ESPHealth",function(v) Notif("Visual",v and "Health ESP ON" or "Health ESP OFF",v and "success" or "warning") end)
    MkToggle(vp,"Name ESP","Show usernames","ESPName",function(v) Notif("Visual",v and "Name ESP ON" or "Name ESP OFF",v and "success" or "warning") end)
    MkToggle(vp,"Distance ESP","Show stud distance","ESPDist",function(v) Notif("Visual",v and "Dist ESP ON" or "Dist ESP OFF",v and "success" or "warning") end)
    MkSection(vp,"LIGHTING")
    MkToggle(vp,"Fullbright","Maximum scene brightness","Fullbright",onFullbright)
    MkToggle(vp,"Remove Effects","Disable blur and fog","RemoveFX",onRemoveFX)

    -- ─── POPULATE: MISC ────────────────────────
    local mc=TabPages["Misc"]
    MkSection(mc,"PLAYER")
    MkToggle(mc,"Infinite Stamina","Never exhaust","InfStamina",function(v)
        if v then
            Loops.InfStamina=RunService.Heartbeat:Connect(function()
                pcall(function()
                    local c=LP.Character; if not c then return end
                    local st=c:FindFirstChild("Stats") or LP:FindFirstChild("Stats")
                    if st then local s=st:FindFirstChild("Stamina"); if s then s.Value=s.MaxValue or 100 end end
                end)
            end)
            Notif("Misc","Infinite Stamina ON","success")
        else
            if Loops.InfStamina then Loops.InfStamina:Disconnect(); Loops.InfStamina=nil end
            Notif("Misc","Infinite Stamina OFF","warning")
        end
    end)
    MkToggle(mc,"Name Protect","Display as ???","NameProtect",function(v)
        pcall(function() LP.DisplayName=v and "???" or LP.Name end)
        Notif("Misc",v and "Name hidden as ???" or "Name restored",v and "success" or "warning")
    end)
    MkToggle(mc,"Anti-AFK","Prevent idle kick","AntiAFK",onAntiAFK)
    MkSection(mc,"SERVER")
    MkButton(mc,"Rejoin Server","Reconnect to current server","default",function()
        Notif("Misc","Rejoining…","info",2)
        task.delay(1.5,function()
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId) end)
        end)
    end)
    MkButton(mc,"Leave Game","Exit to Roblox home","danger",function()
        Notif("Misc","Leaving game…","warning",1.5)
        task.delay(1,function() pcall(function() game:Shutdown() end) end)
    end)

    -- ─── POPULATE: SETTINGS ────────────────────
    local sp=TabPages["Settings"]
    MkSection(sp,"APPEARANCE")
    MkThemePicker(sp,function(name)
        Cfg.Theme=name
        T=Themes[name]
        task.delay(0.2,function()
            Build()
            Notif("Settings","Theme changed to "..name,"success",3)
        end)
    end)
    MkToggle(sp,"Transparent Window","Frosted glass effect","___tr",function(v)
        Cfg.Transparen=v
        Tw(Main,{BackgroundTransparency=v and 0.15 or 0},0.35):Play()
        Notif("Settings",v and "Transparent ON" or "Transparent OFF","info",2)
    end)
    MkSection(sp,"MANAGEMENT")
    MkButton(sp,"Reset All Features","Disable every active feature","danger",resetAll)
    MkButton(sp,"NexusHub v2.0.0","Running smoothly","accent",function()
        Notif("NexusHub","v2.0.0 · All systems go","info",3)
    end)

    -- ─── OPEN ANIMATION ────────────────────────
    switchTab("Combat")
    Main.Size=UDim2.new(0,W,0,0)
    Tw(Main,{Size=UDim2.new(0,W,0,H)},0.5,Enum.EasingStyle.Back):Play()

    task.delay(0.7,function()
        Notif("NexusHub","Loaded · RightShift to toggle","success",4)
    end)
end

Build()

print("[ NEXUS HUB v2.0.0 ] Loaded")
print("  Toggle  : RightShift")
print("  Minimize: Yellow button (top-right of window)")
print("  Resize  : Green button")
print("  Drag    : Header bar or Watermark")
