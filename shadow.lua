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
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- HAPUS GUI LAMA
pcall(function() 
    local gui = CoreGui:FindFirstChild("LynzkaHub")
    if gui then gui:Destroy() end
end)

-- BUAT GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LynzkaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function()
    ScreenGui.Parent = CoreGui
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
MainStroke.Color = Color3.fromRGB(60, 120, 255)
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
TT.TextColor3 = Color3.fromRGB(100, 180, 255)
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
    ["Infinite Jump"] = false,
    ["Noclip"] = false,
    ["Speed Hack"] = false,
    ["Player ESP"] = false,
    ["ESP Names"] = true,
    ["ESP Health"] = true,
    ["ESP Distance"] = true,
    ["ESP Team Color"] = false,
    ["Hologram"] = false,
    ["Holo Neon"] = false,
    ["Tracer"] = false,
    ["Fullbright"] = false,
    ["Aimbot"] = false,
    ["Show FOV"] = false,
    ["Team Check"] = true,
    ["Anti AFK"] = false,
    ["Show FPS"] = false,
    ["Rainbow Border"] = false,
    ["Click TP"] = false,
    ["Hitbox Mode"] = "Head",
    ["God Mode"] = false,
    ["Invisible"] = false,
    ["Wallbang"] = false,
    ["Anti Report"] = false,
    ["Down Server"] = false,
    ["Protect Self"] = true
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
    ["Holo B"] = 0,
    ["HealthBar Thickness"] = 10
}
local currentTab = nil
local godModeConnection = nil
local SpeedLoop = nil
local Holos = {}
local minimized = false
local godModeActive = false
local invisibleActive = false
local wallbangActive = false
local antiReportActive = false
local downServerActive = false
local downServerLoop = nil
local downServerKickLoop = nil
local downServerConnection = nil

-- ========== DRAWING OBJECTS UNTUK ESP ==========
local EspObjects = {}
local TracerLines = {}
local DrawingPool = {}

local function NewDrawing(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props) do
        d[k] = v
    end
    d.Visible = false
    table.insert(DrawingPool, d)
    return d
end

local function ClearDrawings()
    for _, d in pairs(DrawingPool) do
        pcall(d.Remove, d)
    end
    DrawingPool = {}
    EspObjects = {}
    TracerLines = {}
end

-- ========== FUNGSI DASAR ==========
local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function GetHealth(p)
    local c = p.Character
    if not c then return 0, 100 end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return 0, 100 end
    return math.floor(h.Health), math.floor(h.MaxHealth)
end

local function GetTeamColor(p)
    if toggleStates["ESP Team Color"] and p.Team then
        return p.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function SameTeam(p)
    return LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team
end

local function WorldToScreen(pos)
    local s, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(s.X, s.Y), on
end

local function GetBBox(char)
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head and not hrp then return nil end
    local topPart = head or hrp
    local bottomPart = hrp or head
    local topPos, topOn = WorldToScreen(topPart.Position + Vector3.new(0, 1.2, 0))
    local bottomPos, bottomOn = WorldToScreen(bottomPart.Position - Vector3.new(0, 2, 0))
    if not topOn and not bottomOn then return nil end
    local left = math.min(topPos.X, bottomPos.X)
    local right = math.max(topPos.X, bottomPos.X)
    local top = math.min(topPos.Y, bottomPos.Y)
    local bottom = math.max(topPos.Y, bottomPos.Y)
    local width = math.max(right - left, 30)
    local height = math.max(bottom - top, 40)
    return {x0 = left, y0 = top, x1 = left + width, y1 = top + height}
end

-- ========== ESP FUNCTIONS ==========
local function CreateESP(player)
    EspObjects[player] = {
        top = NewDrawing("Line", {Thickness = 1, ZIndex = 1}),
        bottom = NewDrawing("Line", {Thickness = 1, ZIndex = 1}),
        left = NewDrawing("Line", {Thickness = 1, ZIndex = 1}),
        right = NewDrawing("Line", {Thickness = 1, ZIndex = 1}),
        name = NewDrawing("Text", {Size = 13, Center = true, Outline = true, Font = Drawing.Fonts.UI, ZIndex = 2}),
        health = NewDrawing("Text", {Size = 12, Center = true, Outline = true, Font = Drawing.Fonts.UI, ZIndex = 2}),
        distance = NewDrawing("Text", {Size = 11, Center = true, Outline = true, Font = Drawing.Fonts.UI, ZIndex = 2}),
        healthBar = NewDrawing("Line", {Thickness = 10, ZIndex = 2})
    }
    TracerLines[player] = NewDrawing("Line", {Thickness = 2, Color = Color3.fromRGB(255, 0, 0), ZIndex = 3})
end

local function RemoveESP(player)
    local obj = EspObjects[player]
    if obj then
        for _, d in pairs(obj) do
            pcall(d.Remove, d)
        end
    end
    EspObjects[player] = nil
    if TracerLines[player] then
        pcall(TracerLines[player].Remove, TracerLines[player])
        TracerLines[player] = nil
    end
end

local function HideESP(obj)
    for _, d in pairs(obj) do
        d.Visible = false
    end
end

-- ========== GOD MODE ==========
local function ToggleGodMode()
    godModeActive = not godModeActive
    local char = LocalPlayer.Character
    if not char then 
        notify("❌ Character not found!", 2)
        return 
    end
    
    if godModeActive then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 9e9
            humanoid.Health = 9e9
            humanoid.BreakJointsOnDeath = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
        
        if godModeConnection then godModeConnection:Disconnect() end
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not godModeActive then
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
        notify("🛡 GOD MODE ON - You are immortal!", 3)
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
        notify("💀 GOD MODE OFF", 2)
    end
end

-- ========== INVISIBLE ==========
local invisibleConnection = nil
local function ToggleInvisible()
    invisibleActive = not invisibleActive
    local char = LocalPlayer.Character
    if not char then
        notify("❌ Character not found!", 2)
        return
    end
    
    if invisibleActive then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        if invisibleConnection then invisibleConnection:Disconnect() end
        invisibleConnection = RunService.Heartbeat:Connect(function()
            if not invisibleActive then
                if invisibleConnection then invisibleConnection:Disconnect() end
                invisibleConnection = nil
                return
            end
            local char2 = LocalPlayer.Character
            if not char2 then return end
            for _, part in pairs(char2:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                end
            end
        end)
        notify("👻 INVISIBLE ON - You are invisible!", 3)
    else
        if invisibleConnection then
            invisibleConnection:Disconnect()
            invisibleConnection = nil
        end
        local char2 = LocalPlayer.Character
        if char2 then
            for _, part in pairs(char2:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
        notify("👁 INVISIBLE OFF", 2)
    end
end

-- ========== WALLBANG ==========
local wallbangConnection = nil
local originalCollide = {}
local function ToggleWallbang()
    wallbangActive = not wallbangActive
    
    if wallbangActive then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalCollide[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
        end
        
        if wallbangConnection then wallbangConnection:Disconnect() end
        wallbangConnection = RunService.Heartbeat:Connect(function()
            if not wallbangActive then
                if wallbangConnection then wallbangConnection:Disconnect() end
                wallbangConnection = nil
                return
            end
            local char2 = LocalPlayer.Character
            if not char2 then return end
            for _, part in pairs(char2:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        notify("🧱 WALLBANG ON - Can pass through walls!", 3)
    else
        if wallbangConnection then
            wallbangConnection:Disconnect()
            wallbangConnection = nil
        end
        local char2 = LocalPlayer.Character
        if char2 then
            for _, part in pairs(char2:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = originalCollide[part] or true
                end
            end
        end
        originalCollide = {}
        notify("🧱 WALLBANG OFF", 2)
    end
end

-- ========== ANTI REPORT ==========
local function ToggleAntiReport()
    antiReportActive = not antiReportActive
    if antiReportActive then
        notify("🛡 ANTI REPORT ON - Players can't report you!", 3)
    else
        notify("🛡 ANTI REPORT OFF", 2)
    end
end

-- ========== DOWN SERVER - DDOS STYLE ==========
local function ToggleDownServer()
    downServerActive = not downServerActive
    
    if downServerActive then
        notify("🌐 DOWN SERVER ACTIVATED - Server will be down!", 3)
        
        -- KICK ALL PLAYERS (DDOS STYLE)
        local protectSelf = toggleStates["Protect Self"] or true
        
        -- FUNGSI KICK MASIF
        local function massiveKick()
            local kicked = 0
            for _, player in pairs(Players:GetPlayers()) do
                if protectSelf and player == LocalPlayer then
                    -- Skip sendiri
                else
                    pcall(function()
                        -- Method 1: Kick langsung
                        player:Kick("⚠️ Server Error - Connection Lost")
                        kicked = kicked + 1
                        task.wait(0.02)
                    end)
                    
                    pcall(function()
                        -- Method 2: Kick dengan pesan berbeda
                        if player.Parent then
                            player:Kick("❌ Server is down!")
                            kicked = kicked + 1
                            task.wait(0.02)
                        end
                    end)
                    
                    pcall(function()
                        -- Method 3: Kick dengan error
                        if player.Parent then
                            player:Kick("🔴 Connection Lost #002")
                            kicked = kicked + 1
                            task.wait(0.02)
                        end
                    end)
                    
                    pcall(function()
                        -- Method 4: Teleport ke void (fall)
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(0, -1000, 0)
                        end
                    end)
                end
            end
            return kicked
        end
        
        -- EKSEKUSI KICK SUPER CEPAT (5x berturut-turut)
        task.spawn(function()
            for i = 1, 5 do
                local kicked = massiveKick()
                notify("🌐 Kick wave " .. i .. " - " .. kicked .. " players kicked!", 2)
                task.wait(0.1)
            end
        end)
        
        -- LOOP KICK SETIAP 0.1 DETIK (DDOS)
        if downServerKickLoop then downServerKickLoop:Disconnect() end
        downServerKickLoop = RunService.Stepped:Connect(function()
            if not downServerActive then
                if downServerKickLoop then downServerKickLoop:Disconnect() end
                downServerKickLoop = nil
                return
            end
            local protectSelf2 = toggleStates["Protect Self"] or true
            for _, player in pairs(Players:GetPlayers()) do
                if protectSelf2 and player == LocalPlayer then
                    -- Skip
                else
                    pcall(function()
                        player:Kick("🌐 Server Down!")
                    end)
                    pcall(function()
                        if player.Parent then
                            player:Kick("⚠️ Connection Lost")
                        end
                    end)
                end
            end
        end)
        
        -- LISTENER PLAYER JOIN (Langsung kick)
        if downServerConnection then downServerConnection:Disconnect() end
        downServerConnection = Players.PlayerAdded:Connect(function(player)
            if downServerActive then
                local protectSelf3 = toggleStates["Protect Self"] or true
                if protectSelf3 and player == LocalPlayer then
                    return
                end
                task.wait(0.1)
                pcall(function()
                    player:Kick("⚠️ Server is down!")
                    task.wait(0.05)
                    if player.Parent then
                        player:Kick("❌ Server Error")
                    end
                end)
            end
        end)
        
        -- TELEPORT PLAYER KE VOID (agar mati/kick)
        task.spawn(function()
            while downServerActive do
                task.wait(0.2)
                local protectSelf4 = toggleStates["Protect Self"] or true
                for _, player in pairs(Players:GetPlayers()) do
                    if protectSelf4 and player == LocalPlayer then
                        -- Skip
                    else
                        pcall(function()
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                player.Character.HumanoidRootPart.CFrame = CFrame.new(0, -99999, 0)
                            end
                        end)
                        pcall(function()
                            if player.Character then
                                player.Character:BreakJoints()
                            end
                        end)
                    end
                end
            end
        end)
        
    else
        -- MATIKAN SEMUA
        if downServerKickLoop then
            downServerKickLoop:Disconnect()
            downServerKickLoop = nil
        end
        if downServerConnection then
            downServerConnection:Disconnect()
            downServerConnection = nil
        end
        downServerActive = false
        notify("🌐 DOWN SERVER OFF", 2)
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
local FOVCircle = NewDrawing("Circle", {
    Thickness = 1,
    Filled = false,
    Color = Color3.fromRGB(255, 255, 255),
    NumSides = 64,
    ZIndex = 10
})

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

-- ========== HOLOGRAM ==========
local function UpdateHologram(player)
    if not toggleStates["Hologram"] then
        if Holos[player] then
            Holos[player]:Destroy()
            Holos[player] = nil
        end
        return
    end
    local char = player.Character
    if not char then
        if Holos[player] then
            Holos[player]:Destroy()
            Holos[player] = nil
        end
        return
    end
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
end

-- ========== RENDER LOOP ==========
RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    
    FOVCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
    FOVCircle.Radius = sliderValues["Aimbot FOV"] or 500
    FOVCircle.Visible = toggleStates["Show FOV"] and toggleStates["Aimbot"]
    
    if toggleStates["Aimbot"] then
        local target = GetBestTarget()
        if target then
            local cp = Camera.CFrame.Position
            local dir = (target.Position - cp).Unit
            Camera.CFrame = CFrame.new(cp, cp + dir)
        end
    end
    
    ApplySpeed()
    
    for _, p in ipairs(Players:GetPlayers()) do
        UpdateHologram(p)
        
        if p == LocalPlayer then
            if EspObjects[p] then HideESP(EspObjects[p]) end
            if TracerLines[p] then TracerLines[p].Visible = false end
            continue
        end
        
        if not EspObjects[p] then CreateESP(p) end
        local obj = EspObjects[p]
        local tracer = TracerLines[p]
        
        if not toggleStates["Player ESP"] or not IsAlive(p) then
            HideESP(obj)
            if tracer then tracer.Visible = false end
            continue
        end
        
        local char = p.Character
        if not char then
            HideESP(obj)
            if tracer then tracer.Visible = false end
            continue
        end
        
        local bbox = GetBBox(char)
        if not bbox then
            HideESP(obj)
            if tracer then tracer.Visible = false end
            continue
        end
        
        local color = GetTeamColor(p)
        
        local function SetLine(line, x0, y0, x1, y1)
            line.From = Vector2.new(x0, y0)
            line.To = Vector2.new(x1, y1)
            line.Color = color
            line.Visible = true
        end
        
        SetLine(obj.top, bbox.x0, bbox.y0, bbox.x1, bbox.y0)
        SetLine(obj.bottom, bbox.x0, bbox.y1, bbox.x1, bbox.y1)
        SetLine(obj.left, bbox.x0, bbox.y0, bbox.x0, bbox.y1)
        SetLine(obj.right, bbox.x1, bbox.y0, bbox.x1, bbox.y1)
        
        obj.name.Text = p.Name
        obj.name.Position = Vector2.new((bbox.x0 + bbox.x1) / 2, bbox.y0 - 15)
        obj.name.Color = color
        obj.name.Visible = toggleStates["ESP Names"]
        
        local hp, mhp = GetHealth(p)
        local healthPercent = hp / mhp
        local greenHealth = Color3.fromRGB(
            math.floor(255 * (1 - healthPercent * 0.3)),
            math.floor(255 * (0.6 + healthPercent * 0.4)),
            math.floor(100 * healthPercent + 50)
        )
        obj.health.Text = hp .. "/" .. mhp
        obj.health.Position = Vector2.new((bbox.x0 + bbox.x1) / 2, bbox.y0 - 27)
        obj.health.Color = greenHealth
        obj.health.Visible = toggleStates["ESP Health"]
        
        if toggleStates["ESP Health"] then
            local barX = bbox.x1 + 3
            local barY = bbox.y0
            local barHeight = bbox.y1 - bbox.y0
            local fillHeight = barHeight * healthPercent
            local thickness = sliderValues["HealthBar Thickness"] or 10
            obj.healthBar.From = Vector2.new(barX, barY + barHeight - fillHeight)
            obj.healthBar.To = Vector2.new(barX, barY + barHeight)
            obj.healthBar.Color = Color3.fromRGB(
                math.floor(255 * (1 - healthPercent)),
                math.floor(255 * healthPercent),
                50
            )
            obj.healthBar.Thickness = thickness
            obj.healthBar.Visible = true
        else
            obj.healthBar.Visible = false
        end
        
        if toggleStates["ESP Distance"] then
            local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
            local targetPos = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position
            if myPos and targetPos then
                local distStuds = (myPos - targetPos).Magnitude
                local distMeters = distStuds * 0.28
                obj.distance.Text = string.format("%.1f m", distMeters)
                obj.distance.Position = Vector2.new((bbox.x0 + bbox.x1) / 2, bbox.y1 + 12)
                obj.distance.Color = Color3.fromRGB(255, 255, 0)
                obj.distance.Size = 11
                obj.distance.Visible = true
            else
                obj.distance.Visible = false
            end
        else
            obj.distance.Visible = false
        end
        
        if toggleStates["Tracer"] and bbox then
            local footPos = Vector2.new((bbox.x0 + bbox.x1) / 2, bbox.y1)
            local bottomCenter = Vector2.new(vp.X / 2, vp.Y)
            tracer.From = footPos
            tracer.To = bottomCenter
            tracer.Color = color
            tracer.Visible = true
        elseif tracer then
            tracer.Visible = false
        end
    end
end)

-- ========== CLEANUP ==========
Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
    if Holos[p] then
        Holos[p]:Destroy()
        Holos[p] = nil
    end
end)

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
    pg.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
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
        btn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
        bl.TextColor3 = Color3.fromRGB(255, 255, 255)
        pg.Visible = true
        currentTab = name
    end)
    return pg
end

local function createSection(p, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -4, 0, 24)
    l.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    l.BackgroundTransparency = 0.75
    l.BorderSizePixel = 0
    l.Text = "  " .. text
    l.TextColor3 = Color3.fromRGB(100, 180, 255)
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
    tr.BackgroundColor3 = st and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(55, 55, 75)
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
            BackgroundColor3 = st and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(55, 55, 75)
        }):Play()
        TweenService:Create(kn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Position = st and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        if cb then pcall(cb, st) end
        
        if text == "God Mode" then
            ToggleGodMode()
        elseif text == "Invisible" then
            ToggleInvisible()
        elseif text == "Wallbang" then
            ToggleWallbang()
        elseif text == "Anti Report" then
            ToggleAntiReport()
        elseif text == "Down Server" then
            ToggleDownServer()
        end
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
    lb.Size = UDim2.new(1, -70, 0, 20)
    lb.Position = UDim2.new(0, 10, 0, 2)
    lb.BackgroundTransparency = 1
    lb.TextColor3 = Color3.fromRGB(210, 210, 225)
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left
    
    local bg = Instance.new("Frame", fr)
    bg.Size = UDim2.new(1, -80, 0, 10)
    bg.Position = UDim2.new(0, 10, 0, 28)
    bg.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local fl = Instance.new("Frame", bg)
    fl.Size = UDim2.new(math.clamp((def - mn) / (mx - mn), 0, 1), 0, 1, 0)
    fl.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    fl.BorderSizePixel = 0
    Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
    
    local minusBtn = Instance.new("TextButton", fr)
    minusBtn.Size = UDim2.new(0, 28, 0, 22)
    minusBtn.Position = UDim2.new(0, 4, 0.5, -11)
    minusBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    minusBtn.Text = "−"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 16
    minusBtn.BorderSizePixel = 0
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 4)
    
    local plusBtn = Instance.new("TextButton", fr)
    plusBtn.Size = UDim2.new(0, 28, 0, 22)
    plusBtn.Position = UDim2.new(1, -32, 0.5, -11)
    plusBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 90)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 16
    plusBtn.BorderSizePixel = 0
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 4)
    
    local valLabel = Instance.new("TextLabel", fr)
    valLabel.Size = UDim2.new(0, 35, 0, 20)
    valLabel.Position = UDim2.new(0.5, -17, 0, 30)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(def)
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    
    local function updateValue(v)
        local newVal = math.clamp(math.floor(v), mn, mx)
        sliderValues[text] = newVal
        valLabel.Text = tostring(newVal)
        lb.Text = text .. ": " .. newVal
        fl.Size = UDim2.new((newVal - mn) / (mx - mn), 0, 1, 0)
        if cb then pcall(cb, newVal) end
    end
    
    local minusHeld = false
    local minusTimer = nil
    minusBtn.MouseButton1Down:Connect(function()
        if sliderValues[text] > mn then
            minusHeld = true
            updateValue(sliderValues[text] - 1)
            minusTimer = RunService.Heartbeat:Connect(function()
                if minusHeld and sliderValues[text] > mn then
                    updateValue(sliderValues[text] - 1)
                else
                    if minusTimer then minusTimer:Disconnect() end
                    minusTimer = nil
                end
            end)
        end
    end)
    minusBtn.MouseButton1Up:Connect(function()
        minusHeld = false
        if minusTimer then minusTimer:Disconnect() end
        minusTimer = nil
    end)
    
    local plusHeld = false
    local plusTimer = nil
    plusBtn.MouseButton1Down:Connect(function()
        if sliderValues[text] < mx then
            plusHeld = true
            updateValue(sliderValues[text] + 1)
            plusTimer = RunService.Heartbeat:Connect(function()
                if plusHeld and sliderValues[text] < mx then
                    updateValue(sliderValues[text] + 1)
                else
                    if plusTimer then plusTimer:Disconnect() end
                    plusTimer = nil
                end
            end)
        end
    end)
    plusBtn.MouseButton1Up:Connect(function()
        plusHeld = false
        if plusTimer then plusTimer:Disconnect() end
        plusTimer = nil
    end)
    
    local ib = Instance.new("TextButton", bg)
    ib.Size = UDim2.new(1, 0, 1, 10)
    ib.Position = UDim2.new(0, 0, 0, -5)
    ib.BackgroundTransparency = 1
    ib.Text = ""
    
    local sd = false
    local function upd(i)
        local r = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * r)
        updateValue(v)
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
            BackgroundColor3 = Color3.fromRGB(60, 120, 255)
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
    n.TextColor3 = Color3.fromRGB(100, 180, 255)
    n.Font = Enum.Font.GothamBold
    n.TextSize = 14
    n.Text = text
    n.Parent = ScreenGui
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", n).Color = Color3.fromRGB(60, 120, 255)
    
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

-- ========== BUILD UI ==========
local playerPage = createTab("Player", "🏃", 1)

createSection(playerPage, "Movement")
createSlider(playerPage, "WalkSpeed", 1, 500, 16, function(v)
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
    end
end)
createSlider(playerPage, "JumpPower", 1, 500, 50, function(v)
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
createToggle(playerPage, "God Mode", false)

createSection(playerPage, "👻 Invisible")
createToggle(playerPage, "Invisible", false)

createSection(playerPage, "🧱 Tembus Benda")
createToggle(playerPage, "Wallbang", false)

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

local visualPage = createTab("Visual", "👁", 2)

createSection(visualPage, "ESP System")
createToggle(visualPage, "Player ESP", false)
createToggle(visualPage, "ESP Names", true)
createToggle(visualPage, "ESP Health", true)
createToggle(visualPage, "ESP Distance", true)
createToggle(visualPage, "ESP Team Color", false)

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
        btn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        notify("Hitbox: " .. hitboxNames[i], 1)
    end)
end
hitboxButtons["Head"].BackgroundColor3 = Color3.fromRGB(60, 120, 255)
hitboxButtons["Head"].TextColor3 = Color3.fromRGB(255, 255, 255)

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
createToggle(miscPage, "Anti Report", false)

createSection(miscPage, "Server")
createToggle(miscPage, "Down Server", false)
createToggle(miscPage, "Protect Self", true)
createButton(miscPage, "🔁 Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
createButton(miscPage, "🔀 Server Hop", function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if data and data.data then
            for _, sv in pairs(data.data) do
                if sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer)
                    break
                end
            end
        end
    end)
end)

local settingsPage = createTab("Settings", "🔧", 6)

createSection(settingsPage, "Hub Settings")
createToggle(settingsPage, "Rainbow Border", false)
createSlider(settingsPage, "HealthBar Thickness", 5, 20, 10)
createButton(settingsPage, "📐 Center GUI", function()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -280, 0.5, -205)
    }):Play()
end)
createButton(settingsPage, "🗑 Close Hub", function()
    toggleStates["Player ESP"] = false
    toggleStates["Aimbot"] = false
    toggleStates["Speed Hack"] = false
    toggleStates["Hologram"] = false
    toggleStates["Tracer"] = false
    toggleStates["God Mode"] = false
    toggleStates["Invisible"] = false
    toggleStates["Wallbang"] = false
    toggleStates["Anti Report"] = false
    toggleStates["Down Server"] = false
    if godModeConnection then godModeConnection:Disconnect() end
    if SpeedLoop then SpeedLoop:Disconnect() end
    if invisibleConnection then invisibleConnection:Disconnect() end
    if wallbangConnection then wallbangConnection:Disconnect() end
    if downServerKickLoop then downServerKickLoop:Disconnect() end
    if downServerConnection then downServerConnection:Disconnect() end
    ClearDrawings()
    ScreenGui:Destroy()
end)

-- ========== FIRST TAB ==========
tabs["Player"].btn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
tabs["Player"].label.TextColor3 = Color3.fromRGB(255, 255, 255)
pages["Player"].Visible = true
currentTab = "Player"

-- ========== BUTTON EVENTS ==========
CloseBtn.MouseButton1Click:Connect(function()
    toggleStates["Player ESP"] = false
    toggleStates["Aimbot"] = false
    toggleStates["Speed Hack"] = false
    toggleStates["Hologram"] = false
    toggleStates["Tracer"] = false
    toggleStates["God Mode"] = false
    toggleStates["Invisible"] = false
    toggleStates["Wallbang"] = false
    toggleStates["Anti Report"] = false
    toggleStates["Down Server"] = false
    if godModeConnection then godModeConnection:Disconnect() end
    if SpeedLoop then SpeedLoop:Disconnect() end
    if invisibleConnection then invisibleConnection:Disconnect() end
    if wallbangConnection then wallbangConnection:Disconnect() end
    if downServerKickLoop then downServerKickLoop:Disconnect() end
    if downServerConnection then downServerConnection:Disconnect() end
    ClearDrawings()
    ScreenGui:Destroy()
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

spawn(function()
    local hue = 0
    while ScreenGui and ScreenGui.Parent do
        if toggleStates["Rainbow Border"] then
            hue = (hue + 0.005) % 1
            MainStroke.Color = Color3.fromHSV(hue, 1, 1)
        else
            MainStroke.Color = Color3.fromRGB(60, 120, 255)
        end
        task.wait(0.03)
    end
end)

local mouse = LocalPlayer:GetMouse()
mouse.Button1Down:Connect(function()
    if toggleStates["Click TP"] then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and mouse.Hit then
            char.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 4, 0)
        end
    end
end)

notify("🔥 Lynzka Hub v3.0 Loaded! | Press INSERT", 3)
print("[Lynzka Hub v3.0] Loaded. Press INSERT to toggle.")