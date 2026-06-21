--[[
    ╔══════════════════════════════════════════╗
    ║      🔥 LYNZKA HUB v3.0 🔥             ║
    ║   Press INSERT to toggle menu           ║
    ╚══════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- HAPUS GUI LAMA
pcall(function() 
    local gui = game:GetService("CoreGui"):FindFirstChild("LynzkaHub")
    if gui then gui:Destroy() end
end)

-- BUAT GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LynzkaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ========== MAIN FRAME ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 410)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -205)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(110, 60, 255)
MainStroke.Thickness = 2

-- ========== DRAG ==========
local drag = {dragging = false, start = nil, origin = nil}
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag.dragging = true
        drag.start = i.Position
        drag.origin = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag.dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag.dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - drag.start
        MainFrame.Position = UDim2.new(
            drag.origin.X.Scale,
            drag.origin.X.Offset + d.X,
            drag.origin.Y.Scale,
            drag.origin.Y.Offset + d.Y
        )
    end
end)

-- ========== TITLE ==========
local TT = Instance.new("TextLabel")
TT.Text = "🔥 LYNZKA HUB v3.0"
TT.Size = UDim2.new(1, -100, 1, 0)
TT.Position = UDim2.new(0, 14, 0, 0)
TT.BackgroundTransparency = 1
TT.TextColor3 = Color3.fromRGB(190, 140, 255)
TT.Font = Enum.Font.GothamBold
TT.TextSize = 16
TT.TextXAlignment = Enum.TextXAlignment.Left
TT.Parent = TitleBar

-- ========== BUTTONS ==========
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 38, 0, 38)
CloseBtn.Position = UDim2.new(1, -38, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "—"
MinBtn.Size = UDim2.new(0, 38, 0, 38)
MinBtn.Position = UDim2.new(1, -76, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 210, 60)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = TitleBar

-- ========== TAB PANEL ==========
local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 135, 1, -44)
TabPanel.Position = UDim2.new(0, 5, 0, 42)
TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TabPanel.BorderSizePixel = 0
TabPanel.Parent = MainFrame
Instance.new("UICorner", TabPanel).CornerRadius = UDim.new(0, 8)

local TL = Instance.new("UIListLayout", TabPanel)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.Padding = UDim.new(0, 3)

local TP2 = Instance.new("UIPadding", TabPanel)
TP2.PaddingTop = UDim.new(0, 6)
TP2.PaddingLeft = UDim.new(0, 5)
TP2.PaddingRight = UDim.new(0, 5)

-- ========== CONTENT PANEL ==========
local ContentPanel = Instance.new("Frame")
ContentPanel.Size = UDim2.new(1, -152, 1, -48)
ContentPanel.Position = UDim2.new(0, 146, 0, 42)
ContentPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
ContentPanel.BorderSizePixel = 0
ContentPanel.ClipsDescendants = true
ContentPanel.Parent = MainFrame
Instance.new("UICorner", ContentPanel).CornerRadius = UDim.new(0, 8)

-- ========== VARIABLES ==========
local tabs = {}
local pages = {}
local toggleStates = {
    -- Player
    ["Infinite Jump"] = false,
    ["Noclip"] = false,
    ["Speed Hack"] = false,
    -- Visual
    ["Player ESP"] = false,
    ["ESP Names"] = true,
    ["ESP Health"] = true,
    ["ESP Health Bar"] = true,
    ["ESP Distance"] = true,
    ["Hologram"] = false,
    ["Holo Neon"] = false,
    ["Tracer"] = false,
    ["Fullbright"] = false,
    -- Combat
    ["Aimbot"] = false,
    ["Show FOV"] = false,
    ["Team Check"] = true,
    -- Misc
    ["Anti AFK"] = false,
    ["Show FPS"] = false,
    ["Rainbow Border"] = false,
    ["Click TP"] = false,
    ["Hitbox Mode"] = "Head"
}
local sliderValues = {
    ["WalkSpeed"] = 16,
    ["JumpPower"] = 50,
    ["Speed Value"] = 5,
    ["Gravity"] = 196,
    ["FOV"] = 70,
    ["Aimbot FOV"] = 500,
    ["Holo R"] = 0,
    ["Holo G"] = 255,
    ["Holo B"] = 0
}
local currentTab = nil
local isGodMode = false
local godModeConnection = nil
local SpeedLoop = nil
local Holos = {}
local Tracers = {}
local espCache = {}
local minimized = false
local espHolder = Instance.new("Folder", ScreenGui)
espHolder.Name = "ESP"

-- ========== FUNGSI UI ==========
local function createTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.LayoutOrder = order or 0
    btn.Size = UDim2.new(1, 0, 0, 33)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = TabPanel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local bl = Instance.new("TextLabel", btn)
    bl.Text = icon .. "  " .. name
    bl.Size = UDim2.new(1, 0, 1, 0)
    bl.Position = UDim2.new(0, 10, 0, 0)
    bl.BackgroundTransparency = 1
    bl.TextColor3 = Color3.fromRGB(175, 175, 200)
    bl.Font = Enum.Font.GothamSemibold
    bl.TextSize = 13
    bl.TextXAlignment = Enum.TextXAlignment.Left
    
    local pg = Instance.new("ScrollingFrame")
    pg.Name = name .. "_Page"
    pg.Size = UDim2.new(1, -10, 1, -10)
    pg.Position = UDim2.new(0, 5, 0, 5)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = Color3.fromRGB(110, 60, 255)
    pg.CanvasSize = UDim2.new(0, 0, 0, 0)
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false
    pg.Parent = ContentPanel
    
    local pl = Instance.new("UIListLayout", pg)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 4)
    Instance.new("UIPadding", pg).PaddingBottom = UDim.new(0, 6)
    
    tabs[name] = {btn = btn, label = bl}
    pages[name] = pg
    
    btn.MouseButton1Click:Connect(function()
        for n, t in pairs(tabs) do
            t.btn.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
            t.label.TextColor3 = Color3.fromRGB(175, 175, 200)
            pages[n].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(90, 45, 210)
        bl.TextColor3 = Color3.fromRGB(255, 255, 255)
        pg.Visible = true
        currentTab = name
    end)
    return pg
end

local function createSection(p, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -4, 0, 24)
    l.BackgroundColor3 = Color3.fromRGB(90, 45, 210)
    l.BackgroundTransparency = 0.75
    l.BorderSizePixel = 0
    l.Text = "  " .. text
    l.TextColor3 = Color3.fromRGB(190, 160, 255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = p
    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 5)
end

local function createToggle(p, text, def, cb)
    local st = def or false
    toggleStates[text] = st
    
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(1, -4, 0, 32)
    fr.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    fr.BorderSizePixel = 0
    fr.Parent = p
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 6)
    
    local lb = Instance.new("TextLabel", fr)
    lb.Text = text
    lb.Size = UDim2.new(1, -60, 1, 0)
    lb.Position = UDim2.new(0, 10, 0, 0)
    lb.BackgroundTransparency = 1
    lb.TextColor3 = Color3.fromRGB(210, 210, 225)
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 13
    lb.TextXAlignment = Enum.TextXAlignment.Left
    
    local tr = Instance.new("Frame", fr)
    tr.Size = UDim2.new(0, 42, 0, 22)
    tr.Position = UDim2.new(1, -52, 0.5, -11)
    tr.BackgroundColor3 = st and Color3.fromRGB(90, 45, 210) or Color3.fromRGB(55, 55, 75)
    tr.BorderSizePixel = 0
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)
    
    local kn = Instance.new("Frame", tr)
    kn.Size = UDim2.new(0, 16, 0, 16)
    kn.Position = st and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kn.BorderSizePixel = 0
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    
    local bt = Instance.new("TextButton", fr)
    bt.Size = UDim2.new(1, 0, 1, 0)
    bt.BackgroundTransparency = 1
    bt.Text = ""
    
    bt.MouseButton1Click:Connect(function()
        st = not st
        toggleStates[text] = st
        TweenService:Create(tr, TweenInfo.new(0.2), {
            BackgroundColor3 = st and Color3.fromRGB(90, 45, 210) or Color3.fromRGB(55, 55, 75)
        }):Play()
        TweenService:Create(kn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Position = st and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        if cb then pcall(cb, st) end
    end)
end

local function createSlider(p, text, mn, mx, def, cb)
    sliderValues[text] = def
    
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(1, -4, 0, 48)
    fr.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    fr.BorderSizePixel = 0
    fr.Parent = p
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 6)
    
    local lb = Instance.new("TextLabel", fr)
    lb.Text = text .. ": " .. def
    lb.Size = UDim2.new(1, -10, 0, 20)
    lb.Position = UDim2.new(0, 10, 0, 2)
    lb.BackgroundTransparency = 1
    lb.TextColor3 = Color3.fromRGB(210, 210, 225)
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left
    
    local bg = Instance.new("Frame", fr)
    bg.Size = UDim2.new(1, -20, 0, 10)
    bg.Position = UDim2.new(0, 10, 0, 28)
    bg.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local fl = Instance.new("Frame", bg)
    fl.Size = UDim2.new(math.clamp((def - mn) / (mx - mn), 0, 1), 0, 1, 0)
    fl.BackgroundColor3 = Color3.fromRGB(110, 60, 255)
    fl.BorderSizePixel = 0
    Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
    
    local ib = Instance.new("TextButton", bg)
    ib.Size = UDim2.new(1, 0, 1, 10)
    ib.Position = UDim2.new(0, 0, 0, -5)
    ib.BackgroundTransparency = 1
    ib.Text = ""
    
    local sd = false
    local function upd(i)
        local r = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * r)
        sliderValues[text] = v
        fl.Size = UDim2.new(r, 0, 1, 0)
        lb.Text = text .. ": " .. v
        if cb then pcall(cb, v) end
    end
    
    ib.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sd = true
            upd(i)
        end
    end)
    ib.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sd = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sd and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i)
        end
    end)
end

local function createButton(p, text, cb)
    local bt = Instance.new("TextButton")
    bt.Size = UDim2.new(1, -4, 0, 32)
    bt.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    bt.BorderSizePixel = 0
    bt.Text = text
    bt.TextColor3 = Color3.fromRGB(210, 210, 225)
    bt.Font = Enum.Font.Gotham
    bt.TextSize = 13
    bt.Parent = p
    Instance.new("UICorner", bt).CornerRadius = UDim.new(0, 6)
    
    bt.MouseButton1Click:Connect(function()
        TweenService:Create(bt, TweenInfo.new(0.08), {
            BackgroundColor3 = Color3.fromRGB(90, 45, 210)
        }):Play()
        task.delay(0.15, function()
            TweenService:Create(bt, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(28, 28, 42)
            }):Play()
        end)
        if cb then pcall(cb) end
    end)
    return bt
end

local function notify(text, duration)
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0, 320, 0, 42)
    n.Position = UDim2.new(0.5, -160, 1, 10)
    n.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    n.TextColor3 = Color3.fromRGB(190, 150, 255)
    n.Font = Enum.Font.GothamBold
    n.TextSize = 14
    n.Text = text
    n.Parent = ScreenGui
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", n).Color = Color3.fromRGB(110, 60, 255)
    
    TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -160, 1, -55)
    }):Play()
    
    task.delay(duration or 3, function()
        TweenService:Create(n, TweenInfo.new(0.4), {
            Position = UDim2.new(0.5, -160, 1, 50)
        }):Play()
        task.delay(0.5, function() n:Destroy() end)
    end)
end

-- ========== GOD MODE ==========
local function ToggleGodMode()
    isGodMode = not isGodMode
    local char = LocalPlayer.Character
    if not char then return end
    
    if isGodMode then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 9e9
            humanoid.Health = 9e9
            humanoid.BreakJointsOnDeath = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
        
        if godModeConnection then godModeConnection:Disconnect() end
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not isGodMode then
                if godModeConnection then godModeConnection:Disconnect() end
                godModeConnection = nil
                return
            end
            local char2 = LocalPlayer.Character
            if not char2 then return end
            local h = char2:FindFirstChildOfClass("Humanoid")
            if h then
                h.MaxHealth = 9e9
                h.Health = 9e9
                h.BreakJointsOnDeath = false
                h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
        end)
        notify("🛡 God Mode ON", 2)
    else
        if godModeConnection then
            godModeConnection:Disconnect()
            godModeConnection = nil
        end
        local char2 = LocalPlayer.Character
        if char2 then
            local h = char2:FindFirstChildOfClass("Humanoid")
            if h then
                h.MaxHealth = 100
                h.Health = 100
                h.BreakJointsOnDeath = true
                h:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        end
        notify("💀 God Mode OFF", 2)
    end
end

-- ========== SPEED HACK ==========
local function ApplySpeed()
    if not toggleStates["Speed Hack"] then
        if SpeedLoop then
            SpeedLoop:Disconnect()
            SpeedLoop = nil
        end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
        return
    end
    
    local ws = 16
    local val = sliderValues["Speed Value"] or 0
    if val > 0 then
        ws = 16 + (val * 6)
    elseif val < 0 then
        ws = 16 + (val * 2.5)
    end
    ws = math.clamp(ws, 8, 120)
    
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = ws
        if SpeedLoop then SpeedLoop:Disconnect() end
        SpeedLoop = RunService.Heartbeat:Connect(function()
            if toggleStates["Speed Hack"] and hum and hum.Parent then
                if hum.WalkSpeed ~= ws then
                    hum.WalkSpeed = ws
                end
            else
                if SpeedLoop then SpeedLoop:Disconnect() end
                SpeedLoop = nil
            end
        end)
    end
end

-- ========== AIMBOT ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.NumSides = 64
FOVCircle.Visible = false
FOVCircle.ZIndex = 10

local function GetBestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestDist = nil, sliderValues["Aimbot FOV"] or 500
    local hitboxMode = toggleStates["Hitbox Mode"] or "Head"
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if toggleStates["Team Check"] and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then continue end
        
        local targetParts = {}
        if hitboxMode == "Head" then
            targetParts = {char:FindFirstChild("Head")}
        elseif hitboxMode == "Neck" then
            targetParts = {char:FindFirstChild("Neck") or char:FindFirstChild("UpperTorso")}
        elseif hitboxMode == "UpperTorso" then
            targetParts = {char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")}
        elseif hitboxMode == "LowerTorso" then
            targetParts = {char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")}
        elseif hitboxMode == "All" then
            targetParts = {
                char:FindFirstChild("Head"),
                char:FindFirstChild("Neck"),
                char:FindFirstChild("UpperTorso"),
                char:FindFirstChild("LowerTorso"),
                char:FindFirstChild("HumanoidRootPart")
            }
        else
            targetParts = {char:FindFirstChild("Head")}
        end
        
        local bestPart = nil
        local bestPartDist = sliderValues["Aimbot FOV"] or 500
        for _, pt in ipairs(targetParts) do
            if pt then
                local s, on = Camera:WorldToViewportPoint(pt.Position)
                if on then
                    local d = (Vector2.new(s.X, s.Y) - center).Magnitude
                    if d < bestPartDist then
                        bestPartDist = d
                        bestPart = pt
                    end
                end
            end
        end
        if bestPart and bestPartDist < bestDist then
            bestDist = bestPartDist
            best = bestPart
        end
    end
    return best
end

-- ========== RENDER LOOP ==========
RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    
    -- FOV Circle
    FOVCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
    FOVCircle.Radius = sliderValues["Aimbot FOV"] or 500
    FOVCircle.Visible = toggleStates["Show FOV"] and toggleStates["Aimbot"]
    
    -- Aimbot
    if toggleStates["Aimbot"] then
        local target = GetBestTarget()
        if target then
            local cp = Camera.CFrame.Position
            local dir = (target.Position - cp).Unit
            Camera.CFrame = CFrame.new(cp, cp + dir)
        end
    end
    
    -- Speed
    ApplySpeed()
    
    -- ESP, Hologram, Tracer untuk semua player
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            if espCache[player] then
                espCache[player].bb.Enabled = false
                espCache[player].hl.Enabled = false
            end
            continue
        end
        
        local char = player.Character
        if not char then
            if Holos[player] then
                Holos[player]:Destroy()
                Holos[player] = nil
            end
            if espCache[player] then
                espCache[player].bb.Enabled = false
                espCache[player].hl.Enabled = false
            end
            if Tracers[player] then
                Tracers[player].Visible = false
            end
            continue
        end
        
        -- Cek apakah player masih alive
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            if Holos[player] then
                Holos[player]:Destroy()
                Holos[player] = nil
            end
            if espCache[player] then
                espCache[player].bb.Enabled = false
                espCache[player].hl.Enabled = false
            end
            if Tracers[player] then
                Tracers[player].Visible = false
            end
            continue
        end
        
        -- ===== HOLOGRAM =====
        if toggleStates["Hologram"] then
            if not Holos[player] then
                local hl = Instance.new("Highlight")
                hl.Name = "LYNZKA_HOLO"
                hl.Parent = char
                hl.Adornee = char
                hl.FillTransparency = 0.6
                hl.OutlineTransparency = 0.2
                Holos[player] = hl
            end
            local col = Color3.fromRGB(
                sliderValues["Holo R"] or 0,
                sliderValues["Holo G"] or 255,
                sliderValues["Holo B"] or 0
            )
            if toggleStates["Holo Neon"] then
                local hue = (tick() * 0.5) % 1
                col = Color3.fromHSV(hue, 1, 1)
            end
            Holos[player].FillColor = col
            Holos[player].OutlineColor = col
        else
            if Holos[player] then
                Holos[player]:Destroy()
                Holos[player] = nil
            end
        end
        
        -- ===== ESP =====
        if not espCache[player] then
            local folder = Instance.new("Folder", espHolder)
            folder.Name = player.Name
            
            local bb = Instance.new("BillboardGui", folder)
            bb.Size = UDim2.new(0, 220, 0, 100)
            bb.StudsOffset = Vector3.new(0, 3.5, 0)
            bb.AlwaysOnTop = true
            bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            -- Nama
            local nameL = Instance.new("TextLabel", bb)
            nameL.Size = UDim2.new(1, 0, 0, 20)
            nameL.Position = UDim2.new(0, 0, 0, 0)
            nameL.BackgroundTransparency = 1
            nameL.TextColor3 = Color3.fromRGB(255, 120, 255)
            nameL.Font = Enum.Font.GothamBold
            nameL.TextSize = 14
            nameL.TextStrokeTransparency = 0.3
            nameL.Text = player.DisplayName
            
            -- Health Text
            local healthL = Instance.new("TextLabel", bb)
            healthL.Size = UDim2.new(1, 0, 0, 16)
            healthL.Position = UDim2.new(0, 0, 0, 22)
            healthL.BackgroundTransparency = 1
            healthL.TextColor3 = Color3.fromRGB(0, 255, 100)
            healthL.Font = Enum.Font.Gotham
            healthL.TextSize = 11
            healthL.TextStrokeTransparency = 0.3
            
            -- Health Bar Background
            local barBg = Instance.new("Frame", bb)
            barBg.Size = UDim2.new(0.8, 0, 0, 8)
            barBg.Position = UDim2.new(0.1, 0, 0, 40)
            barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            barBg.BorderSizePixel = 0
            Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)
            
            -- Health Bar Fill
            local barFill = Instance.new("Frame", barBg)
            barFill.Size = UDim2.new(1, 0, 1, 0)
            barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 50)
            barFill.BorderSizePixel = 0
            Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 4)
            
            -- Distance
            local distL = Instance.new("TextLabel", bb)
            distL.Size = UDim2.new(1, 0, 0, 16)
            distL.Position = UDim2.new(0, 0, 0, 50)
            distL.BackgroundTransparency = 1
            distL.TextColor3 = Color3.fromRGB(255, 255, 100)
            distL.Font = Enum.Font.Gotham
            distL.TextSize = 11
            distL.TextStrokeTransparency = 0.3
            
            -- Highlight
            local hl = Instance.new("Highlight", folder)
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0.1
            hl.OutlineColor = Color3.fromRGB(180, 100, 255)
            hl.FillColor = Color3.fromRGB(130, 60, 255)
            
            espCache[player] = {
                folder = folder,
                bb = bb,
                nameL = nameL,
                healthL = healthL,
                barBg = barBg,
                barFill = barFill,
                distL = distL,
                hl = hl
            }
        end
        
        local e = espCache[player]
        if not e then continue end
        
        local showESP = toggleStates["Player ESP"]
        
        -- ===== TRACER =====
        if toggleStates["Tracer"] and showESP and char and char:FindFirstChild("HumanoidRootPart") then
            if not Tracers[player] then
                local tracer = Drawing.new("Line")
                tracer.Thickness = 2
                tracer.Color = Color3.fromRGB(255, 0, 0)
                tracer.Visible = false
                tracer.ZIndex = 3
                Tracers[player] = tracer
            end
            local tracer = Tracers[player]
            if tracer then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos, on = Camera:WorldToViewportPoint(root.Position)
                    if on then
                        tracer.From = Vector2.new(pos.X, pos.Y)
                        tracer.To = Vector2.new(vp.X / 2, vp.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                end
            end
        else
            if Tracers[player] then
                Tracers[player].Visible = false
            end
        end
        
        -- ===== SHOW ESP =====
        if showESP and char and char:FindFirstChild("HumanoidRootPart") then
            e.bb.Adornee = char:FindFirstChild("Head") or char.HumanoidRootPart
            e.bb.Enabled = true
            e.hl.Adornee = char
            e.hl.Enabled = true
            
            -- Names
            e.nameL.Visible = toggleStates["ESP Names"] ~= false
            e.nameL.Text = player.DisplayName
            
            -- Health dengan Progress Bar
            if toggleStates["ESP Health"] then
                local hp = hum.Health
                local mhp = hum.MaxHealth
                local pct = math.clamp(hp / mhp, 0, 1)
                
                -- Health Text
                e.healthL.Visible = true
                e.healthL.Text = math.floor(hp) .. "/" .. math.floor(mhp)
                
                -- Health Bar Color (Hijau -> Kuning -> Merah)
                local r = math.floor(255 * (1 - pct))
                local g = math.floor(255 * pct)
                e.barFill.BackgroundColor3 = Color3.fromRGB(r, g, 50)
                
                -- Health Bar Fill
                e.barBg.Visible = toggleStates["ESP Health Bar"] ~= false
                e.barFill.Size = UDim2.new(pct, 0, 1, 0)
                
                -- Highlight Color sesuai health
                e.hl.FillColor = Color3.fromRGB(255 * (1 - pct), 255 * pct, 50)
                e.hl.OutlineColor = Color3.fromRGB(255 * (1 - pct), 255 * pct, 80)
            else
                e.healthL.Visible = false
                e.barBg.Visible = false
            end
            
            -- Distance
            if toggleStates["ESP Distance"] then
                local myC = LocalPlayer.Character
                if myC and myC:FindFirstChild("HumanoidRootPart") then
                    local dist = (myC.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    e.distL.Text = math.floor(dist * 0.28) .. " m"
                    e.distL.Visible = true
                else
                    e.distL.Visible = false
                end
            else
                e.distL.Visible = false
            end
        else
            e.bb.Enabled = false
            e.hl.Enabled = false
        end
    end
end)

-- ========== CLEANUP ==========
Players.PlayerRemoving:Connect(function(p)
    if espCache[p] then
        espCache[p].folder:Destroy()
        espCache[p] = nil
    end
    if Holos[p] then
        Holos[p]:Destroy()
        Holos[p] = nil
    end
    if Tracers[p] then
        Tracers[p].Visible = false
        Tracers[p] = nil
    end
end)

-- ========== BUILD UI ==========
-- Player Tab
local playerPage = createTab("Player", "🏃", 1)

createSection(playerPage, "Movement")
createSlider(playerPage, "WalkSpeed", 16, 500, 16, function(v)
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
    end
end)
createSlider(playerPage, "JumpPower", 50, 500, 50, function(v)
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").JumpPower = v
        char:FindFirstChildOfClass("Humanoid").UseJumpPower = true
    end
end)
createToggle(playerPage, "Infinite Jump", false)
createToggle(playerPage, "Noclip", false)

createSection(playerPage, "Speed Hack")
createToggle(playerPage, "Speed Hack", false)
createSlider(playerPage, "Speed Value", -10, 10, 5)

createSection(playerPage, "🛡 God Mode")
createButton(playerPage, "🛡 Toggle God Mode", ToggleGodMode)

createSection(playerPage, "Character")
createSlider(playerPage, "Gravity", 0, 400, 196, function(v) workspace.Gravity = v end)
createButton(playerPage, "🔄 Reset Character", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").Health = 0
    end
end)
createButton(playerPage, "❄ Freeze / Unfreeze", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Anchored = not char.HumanoidRootPart.Anchored
    end
end)

-- Visual Tab
local visualPage = createTab("Visual", "👁", 2)

createSection(visualPage, "ESP System")
createToggle(visualPage, "Player ESP", false)
createToggle(visualPage, "ESP Names", true)
createToggle(visualPage, "ESP Health", true)
createToggle(visualPage, "ESP Health Bar", true)
createToggle(visualPage, "ESP Distance", true)

createSection(visualPage, "Hologram")
createToggle(visualPage, "Hologram", false)
createToggle(visualPage, "Holo Neon", false)
createSlider(visualPage, "Holo R", 0, 255, 0)
createSlider(visualPage, "Holo G", 0, 255, 255)
createSlider(visualPage, "Holo B", 0, 255, 0)

createSection(visualPage, "Antena (Tracer)")
createToggle(visualPage, "Tracer", false)

createSection(visualPage, "World")
createToggle(visualPage, "Fullbright", false, function(s)
    if s then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)
createSlider(visualPage, "FOV", 30, 120, 70, function(v) Camera.FieldOfView = v end)

-- Combat Tab
local combatPage = createTab("Combat", "⚔", 3)

createSection(combatPage, "Aimbot")
createToggle(combatPage, "Aimbot", false)
createToggle(combatPage, "Show FOV", false)
createToggle(combatPage, "Team Check", true)
createSlider(combatPage, "Aimbot FOV", 50, 900, 500)

createSection(combatPage, "Hitbox Mode")
local hitboxFrame = Instance.new("Frame", combatPage)
hitboxFrame.Size = UDim2.new(1, -4, 0, 0)
hitboxFrame.AutomaticSize = Enum.AutomaticSize.Y
hitboxFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
hitboxFrame.BorderSizePixel = 0
Instance.new("UICorner", hitboxFrame).CornerRadius = UDim.new(0, 6)

local hitboxLayout = Instance.new("UIGridLayout", hitboxFrame)
hitboxLayout.CellSize = UDim2.new(0.45, -4, 0, 28)
hitboxLayout.CellPadding = UDim2.new(0, 4, 0, 4)
hitboxLayout.SortOrder = Enum.SortOrder.LayoutOrder

local hitboxOptions = {"Head", "Neck", "UpperTorso", "LowerTorso", "All"}
local hitboxNames = {"Kepala", "Leher", "Badan", "Kaki", "All Lock"}
local hitboxButtons = {}

for i, opt in ipairs(hitboxOptions) do
    local btn = Instance.new("TextButton", hitboxFrame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    btn.Text = hitboxNames[i]
    btn.TextColor3 = Color3.fromRGB(180, 180, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    hitboxButtons[opt] = btn
    
    btn.MouseButton1Click:Connect(function()
        toggleStates["Hitbox Mode"] = opt
        for _, b in pairs(hitboxButtons) do
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
            b.TextColor3 = Color3.fromRGB(180, 180, 255)
        end
        btn.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end
hitboxButtons["Head"].BackgroundColor3 = Color3.fromRGB(90, 130, 255)
hitboxButtons["Head"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- Teleport Tab
local tpPage = createTab("Teleport", "📍", 4)

createSection(tpPage, "Quick Teleport")
createButton(tpPage, "⚡ TP to Nearest Player", function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local best, bestD = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            if d < bestD then best, bestD = p, d end
        end
    end
    if best then
        char.HumanoidRootPart.CFrame = best.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        notify("Teleported to " .. best.Name, 2)
    end
end)
createToggle(tpPage, "Click TP", false)

createSection(tpPage, "Coordinate TP")
createButton(tpPage, "📌 Map Center (0, 150, 0)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 150, 0)
    end
end)
createButton(tpPage, "📌 Highest Point (0, 1000, 0)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 1000, 0)
    end
end)
createButton(tpPage, "🏠 Spawn Point", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            char.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
        else
            char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
        notify("🏠 Teleported to spawn!", 2)
    end
end)

createSection(tpPage, "Player List")
local plCount = Instance.new("TextLabel", tpPage)
plCount.Size = UDim2.new(1, -4, 0, 22)
plCount.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
plCount.BackgroundTransparency = 0.5
plCount.BorderSizePixel = 0
plCount.TextColor3 = Color3.fromRGB(140, 140, 170)
plCount.Font = Enum.Font.Gotham
plCount.TextSize = 11
plCount.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", plCount).CornerRadius = UDim.new(0, 5)

local plBox = Instance.new("Frame", tpPage)
plBox.Size = UDim2.new(1, -4, 0, 0)
plBox.BackgroundTransparency = 1
plBox.AutomaticSize = Enum.AutomaticSize.Y
local plL = Instance.new("UIListLayout", plBox)
plL.SortOrder = Enum.SortOrder.LayoutOrder
plL.Padding = UDim.new(0, 3)

local function refreshPlayers()
    for _, c in pairs(plBox:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then count = count + 1 end
    end
    plCount.Text = "  Players: " .. count .. " / " .. Players.MaxPlayers
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            createButton(plBox, "→ " .. p.DisplayName, function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                    notify("Teleported to " .. p.Name, 2)
                end
            end)
        end
    end
end
refreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(refreshPlayers)

-- Misc Tab
local miscPage = createTab("Misc", "⚙", 5)

createSection(miscPage, "Tools")
createToggle(miscPage, "Anti AFK", false, function(s)
    if s then
        spawn(function()
            while toggleStates["Anti AFK"] do
                pcall(function()
                    local vim = game:GetService("VirtualUser")
                    vim:CaptureController()
                    vim:ClickButton2(Vector2.new())
                end)
                wait(60)
            end
        end)
    end
end)
createToggle(miscPage, "Show FPS", false)

createSection(miscPage, "Server")
createButton(miscPage, "🔁 Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
createButton(miscPage, "🔀 Server Hop", function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local data = Http:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if data and data.data then
            for _, sv in pairs(data.data) do
                if sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer)
                    break
                end
            end
        end
    end)
end)

-- Settings Tab
local settingsPage = createTab("Settings", "🔧", 6)

createSection(settingsPage, "Hub Settings")
createToggle(settingsPage, "Rainbow Border", false)
createButton(settingsPage, "📐 Center GUI", function()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -280, 0.5, -205)
    }):Play()
end)
createButton(settingsPage, "🗑 Close Hub", function() ScreenGui:Destroy() end)

-- ========== FIRST TAB ==========
tabs["Player"].btn.BackgroundColor3 = Color3.fromRGB(90, 45, 210)
tabs["Player"].label.TextColor3 = Color3.fromRGB(255, 255, 255)
pages["Player"].Visible = true
currentTab = "Player"

-- ========== BUTTON EVENTS ==========
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 560, 0, 0),
        Position = UDim2.new(0.5, -280, 0.5, 0)
    }):Play()
    task.delay(0.35, function() ScreenGui:Destroy() end)
end)

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = minimized and UDim2.new(0, 560, 0, 38) or UDim2.new(0, 560, 0, 410)
    }):Play()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ========== ENGINE ==========
RunService.Stepped:Connect(function()
    if toggleStates["Noclip"] then
        local char = LocalPlayer.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if toggleStates["Infinite Jump"] then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- FPS
local fpsLabel = Instance.new("TextLabel", ScreenGui)
fpsLabel.Size = UDim2.new(0, 110, 0, 28)
fpsLabel.Position = UDim2.new(0, 8, 0, 8)
fpsLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
fpsLabel.BackgroundTransparency = 0.3
fpsLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 14
fpsLabel.Text = "FPS: --"
fpsLabel.Visible = false
Instance.new("UICorner", fpsLabel).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", fpsLabel).Color = Color3.fromRGB(60, 60, 80)

spawn(function()
    local fc, el = 0, 0
    RunService.RenderStepped:Connect(function(dt)
        if toggleStates["Show FPS"] then
            fc = fc + 1
            el = el + dt
        end
    end)
    while ScreenGui and ScreenGui.Parent do
        if toggleStates["Show FPS"] then
            fpsLabel.Visible = true
            task.wait(0.5)
            if el > 0 then
                local fps = math.floor(fc / el)
                fpsLabel.Text = "FPS: " .. fps
                if fps >= 50 then
                    fpsLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
                elseif fps >= 30 then
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 220, 50)
                else
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
                end
            end
            fc = 0
            el = 0
        else
            fpsLabel.Visible = false
            fc = 0
            el = 0
            task.wait(0.5)
        end
    end
end)

-- Rainbow
spawn(function()
    local hue = 0
    while ScreenGui and ScreenGui.Parent do
        if toggleStates["Rainbow Border"] then
            hue = (hue + 0.005) % 1
            MainStroke.Color = Color3.fromHSV(hue, 1, 1)
        else
            MainStroke.Color = Color3.fromRGB(110, 60, 255)
        end
        task.wait(0.03)
    end
end)

-- Click TP
local mouse = LocalPlayer:GetMouse()
mouse.Button1Down:Connect(function()
    if toggleStates["Click TP"] then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and mouse.Hit then
            char.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 4, 0)
        end
    end
end)

-- Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if isGodMode then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then
            h.MaxHealth = 9e9
            h.Health = 9e9
            h.BreakJointsOnDeath = false
            h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
    end
end)

notify("🔥 Lynzka Hub v3.0 Loaded! | Press INSERT", 3)
print("[Lynzka Hub v3.0] Loaded. Press INSERT to toggle.")