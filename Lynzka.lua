--[[
    ╔══════════════════════════════════════════╗
    ║      🔥 GOONSAKEN HUB v3.6 🔥          ║
    ║   Shadow Style - Perfect Toggle        ║
    ╚══════════════════════════════════════════╝
]]

-- ===================== LOADER =====================
local hubLoader = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/ALET-BUILDER/Lynzka/main/Lynzka.lua"))()
]]

if queue_on_teleport then
    queue_on_teleport(hubLoader)
elseif syn and syn.queue_on_teleport then
    syn.queue_on_teleport(hubLoader)
end

-- ===================== SERVICES =====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RNG = Random.new()
local TextChatService = game:GetService("TextChatService")
local chatWindow = TextChatService:WaitForChild("ChatWindowConfiguration")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ===================== VARIABLES =====================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Do1x1PopupsLoop = false
local AntiSlow = false
local hubLoaded = false
local timeforonegen = 2.5
local loopgen = false
local autofixgenerator = false
local infinitestamina = false
local ChargeSpeedLoop = false
local GuestChargeSpeed = 2.833
local timeAhead = 0.2
local ORIGINAL_DASH_SPEED = 60
local isOverrideActive = false
local connection = nil
local hitboxmodificationEnabled = false
local MaxRange = 120
local timebetweenpuzzles = 3
local running = false
local animTrack = nil
local existence = nil
local menuVisible = true

-- ===================== SHADOW STYLE VARIABLES =====================
local godModeActive = false
local godModeConnection = nil
local invisibleActive = false
local invisibleConnection = nil
local wallbangActive = false
local wallbangConnection = nil
local originalTransparency = {}
local SpeedLoop = nil
local JumpLoop = nil

-- ===================== DRAG SYSTEM (SHADOW STYLE) =====================
local catDragData = {
    dragging = false,
    startPos = nil,
    startMouse = nil
}

-- ===================== ESP SYSTEM =====================
local EspObjects = {}
local TracerLines = {}
local DrawingPool = {}
local ESPEnabled = false
local healthBarThickness = 10

local espSettings = {
    Enabled = false,
    ShowNames = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowTeamColor = false,
    ShowTracer = false,
    ShowBox = true,
    ShowHealthBar = true
}

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

local function GetHealth(p)
    local c = p.Character
    if not c then return 0, 100 end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return 0, 100 end
    return math.floor(h.Health), math.floor(h.MaxHealth)
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

local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function GetTeamColor(p)
    if espSettings.ShowTeamColor and p.Team then
        return p.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function CreateESP(player)
    EspObjects[player] = {
        top = NewDrawing("Line", {Thickness = 1, ZIndex = 1}),
        bottom = NewDrawing("Line", {Thickness = 1, ZIndex = 1}),
        left = NewDrawing("Line", {Thickness = 1, ZIndex = 1}),
        right = NewDrawing("Line", {Thickness = 1, ZIndex = 1}),
        name = NewDrawing("Text", {Size = 13, Center = true, Outline = true, Font = Drawing.Fonts.UI, ZIndex = 2}),
        health = NewDrawing("Text", {Size = 12, Center = true, Outline = true, Font = Drawing.Fonts.UI, ZIndex = 2}),
        distance = NewDrawing("Text", {Size = 11, Center = true, Outline = true, Font = Drawing.Fonts.UI, ZIndex = 2}),
        healthBar = NewDrawing("Line", {Thickness = healthBarThickness, ZIndex = 2})
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

local function UpdateHealthBarThickness(thickness)
    healthBarThickness = math.clamp(thickness, 5, 20)
    for _, obj in pairs(EspObjects) do
        if obj and obj.healthBar then
            obj.healthBar.Thickness = healthBarThickness
        end
    end
end

local function UpdateESP(player)
    if player == LocalPlayer then
        if EspObjects[player] then HideESP(EspObjects[player]) end
        if TracerLines[player] then TracerLines[player].Visible = false end
        return
    end
    
    if not EspObjects[player] then CreateESP(player) end
    local obj = EspObjects[player]
    local tracer = TracerLines[player]
    
    if not espSettings.Enabled or not IsAlive(player) then
        HideESP(obj)
        if tracer then tracer.Visible = false end
        return
    end
    
    local char = player.Character
    if not char then
        HideESP(obj)
        if tracer then tracer.Visible = false end
        return
    end
    
    local bbox = GetBBox(char)
    if not bbox then
        HideESP(obj)
        if tracer then tracer.Visible = false end
        return
    end
    
    local color = GetTeamColor(player)
    
    if espSettings.ShowBox then
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
    else
        obj.top.Visible = false
        obj.bottom.Visible = false
        obj.left.Visible = false
        obj.right.Visible = false
    end
    
    if espSettings.ShowNames then
        obj.name.Text = player.Name
        obj.name.Position = Vector2.new((bbox.x0 + bbox.x1) / 2, bbox.y0 - 15)
        obj.name.Color = color
        obj.name.Visible = true
    else
        obj.name.Visible = false
    end
    
    if espSettings.ShowHealth then
        local hp, mhp = GetHealth(player)
        local healthPercent = hp / mhp
        local greenHealth = Color3.fromRGB(
            math.floor(255 * (1 - healthPercent * 0.3)),
            math.floor(255 * (0.6 + healthPercent * 0.4)),
            math.floor(100 * healthPercent + 50)
        )
        obj.health.Text = hp .. "/" .. mhp
        obj.health.Position = Vector2.new((bbox.x0 + bbox.x1) / 2, bbox.y0 - 27)
        obj.health.Color = greenHealth
        obj.health.Visible = true
    else
        obj.health.Visible = false
    end
    
    if espSettings.ShowHealthBar then
        local hp, mhp = GetHealth(player)
        local healthPercent = hp / mhp
        local barX = bbox.x1 + 3
        local barY = bbox.y0
        local barHeight = bbox.y1 - bbox.y0
        local fillHeight = barHeight * healthPercent
        obj.healthBar.From = Vector2.new(barX, barY + barHeight - fillHeight)
        obj.healthBar.To = Vector2.new(barX, barY + barHeight)
        obj.healthBar.Color = Color3.fromRGB(
            math.floor(255 * (1 - healthPercent)),
            math.floor(255 * healthPercent),
            50
        )
        obj.healthBar.Thickness = healthBarThickness
        obj.healthBar.Visible = true
    else
        obj.healthBar.Visible = false
    end
    
    if espSettings.ShowDistance then
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
    
    if espSettings.ShowTracer and bbox then
        local vp = Camera.ViewportSize
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

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        UpdateESP(p)
    end
end)

-- ===================== AIMBOT SYSTEM =====================
local aimbotEnabled = false
local aimbotFOV = 500
local hitboxMode = "Head"
local teamCheck = true
local aimbotConnection = nil
local FOVCircle = nil

local function CreateFOVCircle()
    if FOVCircle then
        pcall(FOVCircle.Remove, FOVCircle)
        FOVCircle = nil
    end
    FOVCircle = NewDrawing("Circle", {
        Thickness = 1,
        Filled = false,
        Color = Color3.fromRGB(255, 255, 255),
        NumSides = 64,
        ZIndex = 10
    })
end

local function GetBestTarget()
    if not aimbotEnabled then return nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestDist = nil, aimbotFOV
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if teamCheck and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then continue end
        
        local targetParts = {}
        if hitboxMode == "Head" then
            targetParts = {char:FindFirstChild("Head")}
        elseif hitboxMode == "Neck" then
            targetParts = {char:FindFirstChild("Neck") or char:FindFirstChild("UpperTorso")}
        elseif hitboxMode == "UpperTorso" then
            targetParts = {char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")}
        elseif hitboxMode == "LowerTorso" then
            targetParts = {char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")}
        else
            targetParts = {char:FindFirstChild("Head")}
        end
        
        local bestPart = nil
        local bestPartDist = aimbotFOV
        
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

local function EnableAimbot()
    if aimbotConnection then return end
    aimbotEnabled = true
    CreateFOVCircle()
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if FOVCircle then
            local vp = Camera.ViewportSize
            FOVCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
            FOVCircle.Radius = aimbotFOV
            FOVCircle.Visible = aimbotEnabled
        end
        
        if aimbotEnabled then
            local target = GetBestTarget()
            if target then
                local cp = Camera.CFrame.Position
                local dir = (target.Position - cp).Unit
                Camera.CFrame = CFrame.new(cp, cp + dir)
            end
        end
    end)
end

local function DisableAimbot()
    aimbotEnabled = false
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    if FOVCircle then
        pcall(FOVCircle.Remove, FOVCircle)
        FOVCircle = nil
    end
end

-- ===================== SHADOW STYLE FUNCTIONS =====================

local function ToggleGodMode()
    godModeActive = not godModeActive
    local char = LocalPlayer.Character
    if not char then return end
    
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
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "🛡 GOD MODE ON", Content = "You are immortal!", Duration = 3 })
        end
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
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "💀 GOD MODE OFF", Content = "You are mortal again!", Duration = 2 })
        end
    end
end

local function ToggleInvisibleShadow()
    invisibleActive = not invisibleActive
    local char = LocalPlayer.Character
    if not char then return end
    
    if invisibleActive then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                originalTransparency[part] = part.Transparency
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
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "👻 INVISIBLE ON", Content = "You are invisible!", Duration = 3 })
        end
    else
        if invisibleConnection then
            invisibleConnection:Disconnect()
            invisibleConnection = nil
        end
        local char2 = LocalPlayer.Character
        if char2 then
            for _, part in pairs(char2:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = originalTransparency[part] or 0
                end
            end
        end
        originalTransparency = {}
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "👁 INVISIBLE OFF", Content = "You are visible again!", Duration = 2 })
        end
    end
end

local function ToggleWallbang()
    wallbangActive = not wallbangActive
    
    if wallbangActive then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
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
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "🧱 WALLBANG ON", Content = "Can pass through walls!", Duration = 3 })
        end
    else
        if wallbangConnection then
            wallbangConnection:Disconnect()
            wallbangConnection = nil
        end
        local char2 = LocalPlayer.Character
        if char2 then
            for _, part in pairs(char2:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "🧱 WALLBANG OFF", Content = "Normal collision restored!", Duration = 2 })
        end
    end
end

-- ===================== FUNCTIONS =====================
local function runEvery(interval, fn)
    task.spawn(function()
        while true do
            local ok, err = pcall(fn)
            if not ok then warn("[runEvery]", err) end
            task.wait(interval)
        end
    end)
end

local Connections = {}

-- ===================== ORIGINAL FUNCTIONS =====================
local executor = getgenv().identifyexecutor and getgenv().identifyexecutor() or "RobloxClientApp"

local function startvoidrushcontrol()
    if isOverrideActive then return end
    isOverrideActive = true
    connection = RunService.RenderStepped:Connect(function()
        Humanoid.WalkSpeed = ORIGINAL_DASH_SPEED
        Humanoid.AutoRotate = false
        local direction = HumanoidRootPart.CFrame.LookVector
        local horizontalDirection = Vector3.new(direction.X, 0, direction.Z).Unit
        Humanoid:Move(horizontalDirection)
    end)
end

local function stopvoidrushcontrol()
    if not isOverrideActive then return end
    isOverrideActive = false
    Humanoid.WalkSpeed = 16
    Humanoid.AutoRotate = true
    Humanoid:Move(Vector3.new(0, 0, 0))
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

local function fireproximityprompt(Obj, Amount, Skip)
    if Obj.ClassName == "ProximityPrompt" then 
        Amount = Amount or 1
        local PromptTime = Obj.HoldDuration
        if Skip then 
            Obj.HoldDuration = 0
        end
        for i = 1, Amount do 
            Obj:InputHoldBegin()
            if not Skip then 
                wait(Obj.HoldDuration)
            end
            Obj:InputHoldEnd()
        end
        Obj.HoldDuration = PromptTime
    else 
        error("userdata<ProximityPrompt> expected")
    end
end

local function NameProtect(toggled)
    while toggled do
        wait()
        local gui = LocalPlayer.PlayerGui
        if not gui then return end
        local currentSurvivors = gui:FindFirstChild("TemporaryUI") 
            and gui.TemporaryUI:FindFirstChild("PlayerInfo") 
            and gui.TemporaryUI.PlayerInfo:FindFirstChild("CurrentSurvivors")
        if currentSurvivors then
            for _, v in pairs(currentSurvivors:GetDescendants()) do
                if v:IsA("TextLabel") and v.Name == "Username" then
                    v.Text = "Protected"
                end
            end
        end
        local tempUI = gui:FindFirstChild("TemporaryUI")
        if tempUI then
            for _, v in pairs(tempUI:GetDescendants()) do
                if v:IsA("TextLabel") and v.Name == "Title3" then
                    v.Text = "Protected"
                end
            end
        end
        local mainPlayers = gui:FindFirstChild("MainUI") 
            and gui.MainUI:FindFirstChild("PlayerListHolder") 
            and gui.MainUI.PlayerListHolder:FindFirstChild("Contents") 
            and gui.MainUI.PlayerListHolder.Contents:FindFirstChild("Players")
        if mainPlayers then
            for _, v in pairs(mainPlayers:GetDescendants()) do
                if v:IsA("TextLabel") and v.Name == "Username" then
                    v.Text = "Protected"
                end
            end
        end
        if tempUI then
            for _, v in pairs(tempUI:GetDescendants()) do
                if v:IsA("TextLabel") and (v.Name == "PlayerName" or v.Name == "PlayerUsername") then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if v.Text == plr.Name then
                            v.Text = "Protected"
                        end
                    end
                end
            end
        end
        local spectatingFolder = workspace:FindFirstChild("Players") 
            and workspace.Players:FindFirstChild("Spectating")
        if spectatingFolder then
            for _, char in pairs(spectatingFolder:GetChildren()) do
                local humanoid = char:FindFirstChildWhichIsA("Humanoid")
                if humanoid then
                    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                end
            end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            local imgLabel = gui:FindFirstChild(plr.Name, true)
            if imgLabel and imgLabel:IsA("ImageLabel") then
                local basicInfo = imgLabel:FindFirstChild("BasicInfo")
                if basicInfo then
                    local nameLabel = basicInfo:FindFirstChild("PlayerName")
                    if nameLabel and nameLabel:IsA("TextLabel") then
                        nameLabel.Text = "Protected"
                    end
                end
            end
        end
    end
end

local multiplierNames = {
    "FallSlowness",
    "Medkit",
    "BloxyColaItem",
    "GuestBlocking",
    "BeheadAbility",
    "GuestChargeEnded"
}

local function enforceMultipliers()
    local character = LocalPlayer.Character
    if not character then return end
    local speedMultipliers = character:FindFirstChild("SpeedMultipliers")
    if not speedMultipliers then return end
    for _, name in ipairs(multiplierNames) do
        local mult = speedMultipliers:FindFirstChild(name)
        if mult then
            mult.Value = 1
        end
    end
end

local function checkAndSetSlowStatus()
    if AntiSlow == false then return end
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:WaitForChild("Humanoid")
    local speedMultipliers = Character:FindFirstChild("SpeedMultipliers")
    if not speedMultipliers then return end
    local slowedStatus = speedMultipliers:FindFirstChild("SlowedStatus")
    if not slowedStatus or not slowedStatus:IsA("NumberValue") then return end
    slowedStatus.Value = 1
    local fovMultipliers = Character:FindFirstChild("FOVMultipliers")
    if not fovMultipliers then return end
    local fovSlowedStatus = fovMultipliers:FindFirstChild("SlowedStatus")
    if not fovSlowedStatus or not fovSlowedStatus:IsA("NumberValue") then return end
    fovSlowedStatus.Value = 1
end

local VIM = game:GetService("VirtualInputManager")

local function Do1x1x1x1Popups()
    runEvery(0.05, function()
        if not Do1x1PopupsLoop then return end
        local tempUI = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
        if not tempUI then return end
        for _, gui in ipairs(tempUI:GetChildren()) do
            if gui.Name == "1x1x1x1Popup" and gui:IsA("GuiObject") then
                local cx = gui.AbsolutePosition.X + (gui.AbsoluteSize.X / 2)
                local cy = gui.AbsolutePosition.Y + (gui.AbsoluteSize.Y / 2) + 50
                VIM:SendMouseButtonEvent(cx, cy, Enum.UserInputType.MouseButton1.Value, true, LocalPlayer.PlayerGui, 1)
                VIM:SendMouseButtonEvent(cx, cy, Enum.UserInputType.MouseButton1.Value, false, LocalPlayer.PlayerGui, 1)
            end
        end
    end)
end

local LMSSongs = {
    ["Burnout"] = "rbxassetid://130101085745481",
    ["Compass"] = "rbxassetid://127298326178102",
    ["Vanity"] = "rbxassetid://137266220091579",
    ["Close To Me"] = "rbxassetid://90022574613230",
    ["Plead"] = "rbxassetid://80564889711353",
    ["Creation Of Hatred"] = "rbxassetid://115884097233860",
}

local GuestSettingsTriggerAnims = {
    "126830014841198", "126355327951215", "121086746534252", "18885909645",
    "98456918873918", "105458270463374", "83829782357897", "125403313786645",
    "118298475669935", "82113744478546", "70371667919898", "99135633258223",
    "97167027849946", "109230267448394", "139835501033932", "126896426760253",
    "109667959938617", "126681776859538", "129976080405072", "121293883585738",
    "81639435858902", "137314737492715", "92173139187970", "106847695270773"
}

local blockingKillers = {}
local GuestSettingsLoop

local function getKillerActiveTriggerAnim(killer)
    local hum = killer:FindFirstChildWhichIsA("Humanoid")
    if hum and hum:FindFirstChild("Animator") then
        for _, track in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
            local animId = track.Animation.AnimationId
            for _, id in ipairs(GuestSettingsTriggerAnims) do
                if string.find(animId, id) then
                    return animId
                end
            end
        end
    end
    return nil
end

local function getPunchCharges()
    local guiObj = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
    if guiObj then
        local abilityContainer = guiObj:FindFirstChild("AbilityContainer", true)
        if abilityContainer and abilityContainer:FindFirstChild("Punch") then
            local punchObj = abilityContainer.Punch:FindFirstChild("Charges")
            if punchObj then
                return tostring(punchObj.Text)
            end
        end
    end
    return nil
end

local function startBlockTp(state)
    if state then return end
    GuestSettingsLoop = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
            if not (killer:IsA("Model") and killer:FindFirstChild("HumanoidRootPart")) then
                blockingKillers[killer] = nil
                continue
            end
            local activeAnim = getKillerActiveTriggerAnim(killer)
            if not activeAnim then
                blockingKillers[killer] = nil
                continue
            end
            if blockingKillers[killer] == activeAnim or getPunchCharges() ~= "0" then
                continue
            end
            blockingKillers[killer] = activeAnim
            local originalCF = char.HumanoidRootPart.CFrame
            ReplicatedStorage.Modules.Network.RemoteEvent:FireServer("UseActorAbility", "Block")
            local killerHRP = killer.HumanoidRootPart
            local function teleportInFront()
                char.HumanoidRootPart.CFrame = CFrame.new(killerHRP.Position + killerHRP.CFrame.LookVector * 2)
            end
            teleportInFront()
            task.spawn(function()
                while true do
                    task.wait(0.05)
                    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then break end
                    teleportInFront()
                    local charges = getPunchCharges()
                    local currentAnim = getKillerActiveTriggerAnim(killer)
                    if charges == "1" or currentAnim ~= activeAnim then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = originalCF
                        end
                        blockingKillers[killer] = nil
                        break
                    end
                end
            end)
        end
    end)
end

local selectedSong = "Burnout"
local soundPlayer = Instance.new("Sound")
soundPlayer.Name = "GoonsakenHub_Sound"
soundPlayer.Parent = Workspace
soundPlayer.Looped = false
soundPlayer.Volume = 5

local function triggerNearestGenerator(shouldLoop)
    while shouldLoop do
        local PuzzleUI = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PuzzleUI", 9999)
        task.wait(timeforonegen + math.random() * 0.5)
        local MapFolder = workspace:FindFirstChild("Map")
            and workspace.Map:FindFirstChild("Ingame")
            and workspace.Map.Ingame:FindFirstChild("Map")
        if MapFolder then
            local closestGenerator, closestDistance = nil, math.huge
            local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
            for _, g in ipairs(MapFolder:GetChildren()) do
                if g.Name == "Generator" and g.Progress.Value < 100 then
                    local distance = (g.Main.Position - playerPosition).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestGenerator = g
                    end
                end
            end
            if closestGenerator then
                closestGenerator.Remotes.RE:FireServer()
            end
        end
    end
end

local function generatorDoAll()
    local function findGenerators()
        local mapFolder = Workspace:FindFirstChild("Map")
        local ingameMap = mapFolder and mapFolder:FindFirstChild("Ingame")
        local map = ingameMap and ingameMap:FindFirstChild("Map")
        local generators = {}
        if map then
            for _, gen in ipairs(map:GetChildren()) do
                if gen.Name == "Generator" and gen:IsA("Model") and gen:FindFirstChild("Progress") and gen.Progress.Value < 100 then
                    local LocalPlayersNearby = false
                    for _, LocalPlayer in ipairs(Players:GetPlayers()) do
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and gen:FindFirstChild("Main") then
                            local dist = (hrp.Position - gen.Main.Position).Magnitude
                            if dist < 25 then
                                LocalPlayersNearby = true
                                break
                            end
                        end
                    end
                    if not LocalPlayersNearby then
                        table.insert(generators, gen)
                    end
                end
            end
        end
        return generators
    end

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local lastPosition = humanoidRootPart.CFrame

    while true do
        local generators = findGenerators()
        if #generators == 0 then break end
        for _, gen in ipairs(generators) do
            if gen:FindFirstChild("Main") and gen:FindFirstChild("Remotes") and gen.Remotes:FindFirstChild("RE") and gen.Remotes:FindFirstChild("RF") then
                local generatorPosition = gen.Positions.Center.Position
                local generatorDirection
                if gen.Instances.Generator:FindFirstChild("Cube") and gen.Instances.Generator.Cube:IsA("BasePart") then
                    local cubePos = gen.Instances.Generator.Cube.Position
                    generatorDirection = (cubePos - generatorPosition).Unit
                else
                    generatorDirection = Vector3.new(0, 0, 1)
                end
                humanoidRootPart.CFrame = CFrame.new(
                    generatorPosition + Vector3.new(0, 0.5, 0),
                    generatorPosition + Vector3.new(generatorDirection.X, 0, generatorDirection.Z)
                )
                task.wait(timebetweenpuzzles / 2)
                local prompt = gen.Main:FindFirstChildOfClass("ProximityPrompt")
                if not prompt then
                    prompt = gen.Main:FindFirstChild("Prompt")
                end
                if prompt then
                    fireproximityprompt(prompt, 1.5, false)
                end
                for _ = 1, 6 do
                    task.wait(2.5)
                    gen.Remotes.RE:FireServer()
                end
                task.wait(timebetweenpuzzles / 5)
                gen.Remotes.RF:InvokeServer("leave")
            end
        end
    end
    humanoidRootPart.CFrame = lastPosition
end

local function createFrontflip()
    return function()
        local FlipCooldown
        local function FortniteFlips()
            if FlipCooldown then return end
            FlipCooldown = true
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
            if not hrp or not humanoid then
                FlipCooldown = false
                return
            end
            local savedTracks = {}
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    savedTracks[#savedTracks + 1] = { track = track, time = track.TimePosition }
                    track:Stop(0)
                end
            end
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)

            local duration = 0.45
            local steps = 120
            local startCFrame = hrp.CFrame
            local forwardVector = startCFrame.LookVector
            local upVector = Vector3.new(0, 1, 0)
            task.spawn(function()
                local startTime = tick()
                for i = 1, steps do
                    local t = i / steps
                    local height = 4 * (t - t ^ 2) * 10
                    local nextPos = startCFrame.Position + forwardVector * (35 * t) + upVector * height
                    local rotation = startCFrame.Rotation * CFrame.Angles(-math.rad(i * (360 / steps)), 0, 0)
                    hrp.CFrame = CFrame.new(nextPos) * rotation
                    local elapsedTime = tick() - startTime
                    local expectedTime = (duration / steps) * i
                    local waitTime = expectedTime - elapsedTime
                    if waitTime > 0 then
                        task.wait(waitTime)
                    end
                end
                hrp.CFrame = CFrame.new(startCFrame.Position + forwardVector * 35) * startCFrame.Rotation
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                if animator then
                    for _, data in ipairs(savedTracks) do
                        local track = data.track
                        track:Play()
                        track.TimePosition = data.time
                    end
                end
                task.wait(0.25)
                FlipCooldown = false
            end)
        end
        UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if gameProcessedEvent then return end
            local focused = UserInputService:GetFocusedTextBox()
            if focused then return end
            if input.KeyCode == Enum.KeyCode.P then
                FortniteFlips()
            end
        end)
        return { Flip = FortniteFlips }
    end
end

local frontflipObj = createFrontflip()()

-- ===================== KILLER EMOTE GUI =====================
function KillerEmoteGUI()
    -- [Killer Emote GUI - shortened for space, keep original]
    local KillerEmoteGUI = Instance.new("ScreenGui", PlayerGui)
    -- ... (keep original code)
end

-- ===================== STATS TRACKER =====================
local function createStatsTracker()
    -- [Stats Tracker - keep original]
    local screenGui = Instance.new("ScreenGui")
    -- ...
    return screenGui
end

-- ===================== TOGGLES =====================
local toggles = {
    StatsTracker = false,
    ESP = false,
    infiniteStamina = false,
    AutoRejoinOnKick = true,
    GodMode = false,
    Invisible = false,
    Wallbang = false
}

local guiRefs = {}

-- ===================== ANIMATIONS =====================
local function startGoon()
    local animationId = "rbxassetid://72042024"
    local function playGoonAnim()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId
        local animTrack = humanoid:LoadAnimation(animation)
        animTrack.Looped = true
        animTrack:Play()
        guiRefs.GoonAnim = animTrack
    end
    playGoonAnim()
    guiRefs.GoonConnection = LocalPlayer.CharacterAdded:Connect(function()
        if toggles.Goon then playGoonAnim() end
    end)
end

local function stopGoon()
    if guiRefs.GoonAnim then
        guiRefs.GoonAnim:Stop()
        guiRefs.GoonAnim = nil
    end
    if guiRefs.GoonConnection then
        guiRefs.GoonConnection:Disconnect()
        guiRefs.GoonConnection = nil
    end
end

local function startLayDown()
    local animationId = "rbxassetid://181526230"
    local skipTime = 0.2
    local function playLayDownAnim()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId
        local animTrack = humanoid:LoadAnimation(animation)
        animTrack.Looped = true
        animTrack:Play()
        animTrack.TimePosition = skipTime
        guiRefs.LayDownAnim = animTrack
    end
    playLayDownAnim()
    guiRefs.LayDownConnection = LocalPlayer.CharacterAdded:Connect(function()
        if toggles.LayDown then playLayDownAnim() end
    end)
end

local function stopLayDown()
    if guiRefs.LayDownAnim then
        guiRefs.LayDownAnim:Stop()
        guiRefs.LayDownAnim = nil
    end
    if guiRefs.LayDownConnection then
        guiRefs.LayDownConnection:Disconnect()
        guiRefs.LayDownConnection = nil
    end
end

-- ===================== GUEST SETTINGS VARIABLES =====================
local GuestSettingsOn = false
local strictRangeOn = false
local looseFacing = true
local detectionRange = 18
local predictiveBlockOn = false
local edgeKillerDelay = 3
local killerInRangeSince = nil
local predictiveCooldown = 0
local flingPunchOn = false
local flingPower = 10000
local hiddenfling = false
local aimPunch = false
local customBlockEnabled = false
local customBlockAnimId = ""
local customPunchEnabled = false
local customPunchAnimId = ""
local lastBlockTime = 0
local lastPunchTime = 0
local lastBlockTpTime = 0
local blockTPEnabled = false
local customChargeEnabled = false
local customChargeAnimId = ""
local blockAnimIds = {"72722244508749", "96959123077498"}
local punchAnimIds = {"87259391926321"}
local chargeAnimIds = {"106014898528300"}

-- ===================== FLUENT UI =====================
local FluentLoaded = false
local success, Fluent = pcall(function()
    return loadstring(game:HttpGet('https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua'))()
end)
if success and Fluent then
    FluentLoaded = true
else
    warn("Fluent failed to load.")
end

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window, Tabs = nil, nil
local statsGui = createStatsTracker()

-- ===================== BUILD FLUENT UI =====================
if FluentLoaded then
    Window = Fluent:CreateWindow({
        Title = "GoonHub",
        SubTitle = "v3.6 - Shadow Style Perfect",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Theme = "Dark",
        MinimizeKeyBind = nil
    })

    Tabs = {
        Player = Window:AddTab({ Title = "Player", Icon = "lucide-circle-user" }),
        Game = Window:AddTab({ Title = "Game", Icon = "lucide-gamepad-2" }),
        ESP = Window:AddTab({ Title = "ESP", Icon = "lucide-eye" }),
        Combat = Window:AddTab({ Title = "Combat", Icon = "lucide-crosshair" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "lucide-anvil" }),
        Blatant = Window:AddTab({ Title = "Blatant", Icon = "lucide-angry" }),
        GuestSettings = Window:AddTab({ Title = "Guest 1337", Icon = "lucide-leaf" }),
        CustomAnimations = Window:AddTab({ Title = "Custom Anims", Icon = "lucide-person-standing" }),
        Discord = Window:AddTab({ Title = "Discord", Icon = "lucide-settings" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "lucide-settings" })
    }

    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("GoonsakenHub")
    SaveManager:SetFolder("GoonsakenHub/Configs")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- ===================== PLAYER TAB =====================
    Tabs.Player:AddSlider("Walkspeed", {
        Title = "Walkspeed Multiplier",
        Default = 1,
        Min = 1,
        Max = 5,
        Rounding = 1,
        Suffix = "x",
        Callback = function(value)
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Parent:FindFirstChild("SpeedMultipliers") then
                    local sprintMult = humanoid.Parent.SpeedMultipliers:FindFirstChild("Sprinting")
                    if sprintMult then sprintMult.Value = value end
                end
            end
        end
    })

    Tabs.Player:AddSlider("JumpPower", {
        Title = "Jump Power",
        Default = 50,
        Min = 1,
        Max = 500,
        Rounding = 0,
        Callback = function(value)
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.JumpPower = value end
            end
        end
    })

    Tabs.Player:AddToggle("Goon", {
        Title = "Goon Animation",
        Default = false,
        Callback = function(state)
            toggles.Goon = state
            if state then startGoon() else stopGoon() end
        end
    })

    Tabs.Player:AddToggle("LayDown", {
        Title = "Lay Down Animation",
        Default = false,
        Callback = function(state)
            toggles.LayDown = state
            if state then startLayDown() else stopLayDown() end
        end
    })

    Tabs.Player:AddButton({
        Title = "Frontflip (Key: P)",
        Callback = function()
            if frontflipObj and frontflipObj.Flip then frontflipObj.Flip() end
        end
    })

    Tabs.Player:AddToggle("AntiSlowness", {
        Title = "Anti Slowness",
        Default = false,
        Callback = function(state)
            AntiSlow = state
        end
    })

    Tabs.Player:AddToggle("VoidRushControl", {
        Title = "Void Rush Control",
        Default = false,
        Callback = function(state)
            if state then startvoidrushcontrol() else stopvoidrushcontrol() end
        end
    })

    Tabs.Player:AddToggle("GodMode", {
        Title = "🛡 God Mode (Immortal)",
        Default = false,
        Callback = function(state)
            toggles.GodMode = state
            ToggleGodMode()
        end
    })

    Tabs.Player:AddToggle("InvisibleShadow", {
        Title = "👻 Invisible (Full Transparent)",
        Default = false,
        Callback = function(state)
            toggles.Invisible = state
            ToggleInvisibleShadow()
        end
    })

    Tabs.Player:AddToggle("Wallbang", {
        Title = "🧱 Wallbang (Tembus Benda)",
        Default = false,
        Callback = function(state)
            toggles.Wallbang = state
            ToggleWallbang()
        end
    })

    Tabs.Player:AddButton({
        Title = "Auto 404 Parry",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NumanTF3/auto-404-parry/refs/heads/main/main.lua"))()
        end
    })

    Tabs.Player:AddButton({
        Title = "Auto Raging Pace Parry",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NumanTF3/auto-raging-pace/refs/heads/main/main.lua"))()
        end
    })

    Tabs.Player:AddButton({
        Title = "Ultra Instinct",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/NumanTF3/forsaken-ultra-instinct/refs/heads/main/main.lua'))()
        end
    })

    Tabs.Player:AddButton({
        Title = "Auto Two Time Backstab",
        Callback = function()
            setclipboard("https://discord.gg/ETTV2g8kxS")
            if Fluent and Fluent.Notify then
                Fluent:Notify({
                    Title = "TwoTime Auto Backstab",
                    Content = "Made by skibisaken. Discord link copied!",
                    Duration = 8
                })
            end
            loadstring(game:HttpGet('https://raw.githubusercontent.com/NumanTF3/two-time-backstab/refs/heads/main/main.lua'))()
        end
    })

    Tabs.Player:AddToggle("HitboxModifier", {
        Title = "Hitbox Modifier",
        Default = false,
        Callback = function(state)
            hitboxmodificationEnabled = state
        end
    })

    Tabs.Player:AddInput("HitboxDetectionDistance", {
        Title = "Hitbox Detection Distance",
        Default = "120",
        Placeholder = "120",
        Numeric = true,
        Callback = function(value)
            local num = tonumber(value)
            if num then MaxRange = num end
        end
    })

    -- ===================== GAME TAB =====================
    Tabs.Game:AddToggle("StatsTrackerToggle", {
        Title = "Stats Tracker",
        Default = false,
        Callback = function(state)
            toggles.StatsTracker = state
            if statsGui then statsGui.Enabled = state end
        end
    })

    Tabs.Game:AddToggle("InfiniteStamina", {
        Title = "Infinite Stamina",
        Default = false,
        Callback = function(value)
            if executor == "Xeno" or executor == "Velocity" or executor == "LX63" or executor == "Solara" then
                if Fluent and Fluent.Notify then
                    Fluent:Notify({
                        Title = "Not Supported",
                        Content = "Infinite Stamina doesn't work on your executor.",
                        Duration = 5,
                        Image = "lucide-leaf",
                    })
                end
                return
            end
            infinitestamina = value
            task.spawn(function()
                while infinitestamina do
                    local Sprinting = ReplicatedStorage.Systems.Character.Game.Sprinting
                    local stamina = require(Sprinting)
                    stamina.StaminaLossDisabled = true
                    task.wait(0.5)
                end
                local Sprinting = ReplicatedStorage.Systems.Character.Game.Sprinting
                local stamina = require(Sprinting)
                stamina.StaminaLossDisabled = false
            end)
        end
    })

    Tabs.Game:AddToggle("AutoRejoinToggle", {
        Title = "Auto Rejoin on Kick",
        Default = true,
        Callback = function(state)
            toggles.AutoRejoinOnKick = state
            if state then
                if not Connections.AutoRejoin then
                    Connections.AutoRejoin = GuiService.ErrorMessageChanged:Connect(function(msg)
                        if msg and msg ~= "" then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
                        end
                    end)
                end
            else
                if Connections.AutoRejoin then
                    Connections.AutoRejoin:Disconnect()
                    Connections.AutoRejoin = nil
                end
            end
        end
    })

    Tabs.Game:AddButton({
        Title = "Rejoin",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end
    })

    Tabs.Game:AddToggle("autofixgen", {
        Title = "Auto Fix Generator",
        Default = false,
        Callback = function(state)
            triggerNearestGenerator(state)
        end
    })

    Tabs.Game:AddSlider("OneGenSpeedValue", {
        Title = "Generator Speed",
        Default = 2.5,
        Min = 2.5,
        Max = 10,
        Rounding = 1,
        Callback = function(value)
            timeforonegen = value
        end
    })

    Tabs.Game:AddToggle("auto1x1x1x1popups", {
        Title = "Auto 1x1x1x1 Popups",
        Default = false,
        Callback = function(state)
            Do1x1PopupsLoop = state
            if state then task.spawn(Do1x1x1x1Popups) end
        end
    })

    -- ===================== ESP TAB =====================
    Tabs.ESP:AddToggle("ESPToggle", {
        Title = "Enable ESP",
        Default = false,
        Callback = function(state)
            espSettings.Enabled = state
            if not state then ClearDrawings() end
        end
    })

    Tabs.ESP:AddToggle("ESPBox", {
        Title = "Show Box",
        Default = true,
        Callback = function(state)
            espSettings.ShowBox = state
        end
    })

    Tabs.ESP:AddToggle("ESPNames", {
        Title = "Show Names",
        Default = true,
        Callback = function(state)
            espSettings.ShowNames = state
        end
    })

    Tabs.ESP:AddToggle("ESPHealth", {
        Title = "Show Health",
        Default = true,
        Callback = function(state)
            espSettings.ShowHealth = state
        end
    })

    Tabs.ESP:AddToggle("ESPHealthBar", {
        Title = "Show Health Bar",
        Default = true,
        Callback = function(state)
            espSettings.ShowHealthBar = state
        end
    })

    Tabs.ESP:AddToggle("ESPDistance", {
        Title = "Show Distance",
        Default = true,
        Callback = function(state)
            espSettings.ShowDistance = state
        end
    })

    Tabs.ESP:AddToggle("ESPTracer", {
        Title = "Show Tracer",
        Default = false,
        Callback = function(state)
            espSettings.ShowTracer = state
        end
    })

    Tabs.ESP:AddToggle("ESPTeamColor", {
        Title = "Team Colors",
        Default = false,
        Callback = function(state)
            espSettings.ShowTeamColor = state
        end
    })

    Tabs.ESP:AddSlider("HealthBarThickness", {
        Title = "Health Bar Thickness",
        Default = 10,
        Min = 5,
        Max = 20,
        Rounding = 0,
        Callback = function(value)
            UpdateHealthBarThickness(value)
        end
    })

    -- ===================== COMBAT TAB =====================
    Tabs.Combat:AddToggle("AimbotToggle", {
        Title = "Aimbot",
        Default = false,
        Callback = function(state)
            if state then EnableAimbot() else DisableAimbot() end
        end
    })

    Tabs.Combat:AddToggle("ShowFOV", {
        Title = "Show FOV Circle",
        Default = false,
        Callback = function(state)
            if FOVCircle then FOVCircle.Visible = state and aimbotEnabled end
        end
    })

    Tabs.Combat:AddToggle("TeamCheck", {
        Title = "Team Check",
        Default = true,
        Callback = function(state)
            teamCheck = state
        end
    })

    Tabs.Combat:AddSlider("AimbotFOV", {
        Title = "Aimbot FOV",
        Default = 500,
        Min = 50,
        Max = 900,
        Rounding = 0,
        Callback = function(value)
            aimbotFOV = value
            if FOVCircle then FOVCircle.Radius = value end
        end
    })

    Tabs.Combat:AddDropdown("HitboxMode", {
        Title = "Hitbox Mode",
        Values = {"Head", "Neck", "UpperTorso", "LowerTorso", "All"},
        Multi = false,
        Default = "Head",
        Callback = function(value)
            hitboxMode = value
        end
    })

    Tabs.Combat:AddToggle("ChanceAimbot", {
        Title = "Chance Aimbot (Legacy)",
        Default = false,
        Callback = function(state)
            if state then
                local aimbotConnection = RunService.Heartbeat:Connect(function()
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Parent then
                        local flintlock = humanoid.Parent:FindFirstChild("Flintlock")
                        if flintlock and flintlock.Transparency == 0 then
                            local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
                            if killersFolder then
                                for _, killerModel in pairs(killersFolder:GetChildren()) do
                                    if killerModel:IsA("Model") and killerModel:FindFirstChild("HumanoidRootPart") then
                                        local hrp = killerModel.HumanoidRootPart
                                        local predictedPos = hrp.Position + hrp.Velocity * timeAhead
                                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                                        if rootPart then
                                            if humanoid then humanoid.AutoRotate = false end
                                            rootPart.CFrame = CFrame.new(rootPart.Position, predictedPos)
                                        end
                                    end
                                end
                            end
                        else
                            if humanoid then humanoid.AutoRotate = true end
                        end
                    end
                end)
                Connections.ChanceAimbot = aimbotConnection
            else
                if Connections.ChanceAimbot then
                    Connections.ChanceAimbot:Disconnect()
                    Connections.ChanceAimbot = nil
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.AutoRotate = true end
                end
            end
        end
    })

    Tabs.Combat:AddSlider("ChanceAimbotPredictionValue", {
        Title = "Chance Aimbot Prediction",
        Default = 0.2,
        Min = 0.1,
        Max = 2,
        Rounding = 1,
        Callback = function(value)
            timeAhead = value
        end
    })

    -- ===================== MISC TAB =====================
    Tabs.Misc:AddButton({
        Title = "Infinite Yield",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end
    })

    Tabs.Misc:AddToggle("NameProtect", {
        Title = "NameProtect",
        Default = false,
        Callback = function(state)
            task.spawn(function() NameProtect(state) end)
        end
    })

    Tabs.Misc:AddButton({
        Title = "FPS Boost",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/NumanTF3/roblox-fpsboost-script/refs/heads/main/main.lua'))()
        end
    })

    Tabs.Misc:AddToggle("OneMoreGame", {
        Title = "ONE MORE GAME!",
        Default = false,
        Callback = function(state)
            if state then
                local folderPath = "GoonsakenHub/Assets"
                local fileName = "onemoregame.webm"
                local fullPath = folderPath .. "/" .. fileName
                local videoUrl = "https://raw.githubusercontent.com/NumanTF3/Goonsaken-Hub/refs/heads/main/onemoregame.webm"

                if not isfolder("GoonsakenHub") then makefolder("GoonsakenHub") end
                if not isfolder(folderPath) then makefolder(folderPath) end

                if not isfile(fullPath) then
                    if Fluent and Fluent.Notify then
                        Fluent:Notify({
                            Title = "Video Loader",
                            Content = "Downloading video asset...",
                            Duration = 5
                        })
                    end
                    local request = http_request or syn.request or request
                    if not request then error("Executor does not support HTTP requests.") end
                    local response = request({
                        Url = videoUrl,
                        Method = "GET"
                    })
                    if response.Success and response.Body then
                        writefile(fullPath, response.Body)
                        if Fluent and Fluent.Notify then
                            Fluent:Notify({
                                Title = "Video Loader",
                                Content = "Video downloaded successfully!",
                                Duration = 5
                            })
                        end
                    else
                        if Fluent and Fluent.Notify then
                            Fluent:Notify({
                                Title = "Video Loader",
                                Content = "Failed to download video.",
                                Duration = 5
                            })
                        end
                        return
                    end
                end

                local videoAsset = getcustomasset(fullPath)
                local SettingsShield = CoreGui:WaitForChild("RobloxGui")
                    :WaitForChild("SettingsClippingShield")
                    :WaitForChild("SettingsShield")

                local videoGui

                local function createVideo()
                    if videoGui then return end
                    videoGui = Instance.new("ScreenGui")
                    videoGui.IgnoreGuiInset = true
                    videoGui.ResetOnSpawn = false
                    videoGui.Parent = PlayerGui
                    local videoFrame = Instance.new("VideoFrame", videoGui)
                    videoFrame.Name = "BackVideo"
                    videoFrame.Size = UDim2.new(1, 0, 1, 0)
                    videoFrame.Position = UDim2.new(0, 0, 0, 0)
                    videoFrame.BackgroundTransparency = 1
                    videoFrame.Video = videoAsset
                    videoFrame.Looped = true
                    videoFrame.Volume = 3
                    videoFrame:Play()
                end

                local function removeVideo()
                    if videoGui then
                        videoGui:Destroy()
                        videoGui = nil
                    end
                end

                _G.SettingsVideoLoop = task.spawn(function()
                    local wasVisible = SettingsShield.Visible
                    while state do
                        local isVisible = SettingsShield.Visible
                        if isVisible and not wasVisible then
                            createVideo()
                        elseif not isVisible and wasVisible then
                            removeVideo()
                        end
                        wasVisible = isVisible
                        task.wait(0.1)
                    end
                    removeVideo()
                end)
            else
                if _G.SettingsVideoLoop then
                    task.cancel(_G.SettingsVideoLoop)
                    _G.SettingsVideoLoop = nil
                end
            end
        end
    })

    Tabs.Misc:AddInput("PlaySoundByID", {
        Title = "Play Sound by ID",
        Placeholder = "Enter Roblox Sound ID",
        Numeric = true,
        Callback = function(input)
            local id = tonumber(input)
            if id then
                soundPlayer.SoundId = "rbxassetid://" .. id
                soundPlayer:Play()
            end
        end
    })

    Tabs.Misc:AddDropdown("ChangeLMSSong", {
        Title = "Change LMS Song",
        Values = {"Burnout", "Compass", "Vanity", "Close To Me", "Plead", "Creation Of Hatred"},
        Multi = false,
        Default = 1,
        Callback = function(value)
            selectedSong = value
        end
    })

    Tabs.Misc:AddButton({
        Title = "Replace LMS Song",
        Callback = function()
            local theme = Workspace:WaitForChild("Themes", 99999)
            if not theme then return end
            local lastSurvivor = theme:WaitForChild("LastSurvivor", 60)
            if not lastSurvivor then return end
            local songId = LMSSongs[selectedSong]
            if songId then
                lastSurvivor.SoundId = songId
                lastSurvivor:Play()
            end
        end
    })

    -- ===================== BLATANT TAB =====================
    Tabs.Blatant:AddButton({
        Title = "Do All Generators",
        Callback = function()
            generatorDoAll()
        end
    })

    Tabs.Blatant:AddSlider("GenSpeedValue", {
        Title = "Generator Speed",
        Default = 3,
        Min = 3,
        Max = 10,
        Rounding = 1,
        Callback = function(value)
            timebetweenpuzzles = value
        end
    })

    -- ===================== GUEST SETTINGS TAB =====================
    Tabs.GuestSettings:AddParagraph({
        Title = "Credit To Skibisaken",
        Content = "this entire tab is from the skibisaken script"
    })

    Tabs.GuestSettings:AddToggle("ChargeSpeedToggle", {
        Title = "Custom Charge Speed",
        Default = false,
        Callback = function(state)
            RunService.Stepped:Connect(function()
                if state then
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local speedMultipliers = character:FindFirstChild("SpeedMultipliers")
                    local mult = speedMultipliers and speedMultipliers:FindFirstChild("Guest1337Charge")
                    if mult and GuestChargeSpeed ~= nil then
                        mult.Value = GuestChargeSpeed
                    end
                end
            end)
        end
    })

    Tabs.GuestSettings:AddSlider("GuestChargeSpeed", {
        Title = "Charge Speed",
        Default = 2.833,
        Min = 2.833,
        Max = 15,
        Rounding = 1,
        Callback = function(value)
            GuestChargeSpeed = value
        end
    })

    Tabs.GuestSettings:AddToggle("GuestSettingsToggle", {
        Title = "Auto Block",
        Default = false,
        Callback = function(value)
            GuestSettingsOn = value
        end
    })

    Tabs.GuestSettings:AddToggle("StrictRangeToggle", {
        Title = "Strict Range",
        Default = false,
        Callback = function(value)
            strictRangeOn = value
        end
    })

    Tabs.GuestSettings:AddDropdown("FacingCheckDropdown", {
        Title = "Facing Check",
        Values = {"Loose", "Strict"},
        Multi = false,
        Default = "Loose",
        Callback = function(option)
            looseFacing = option == "Loose"
        end
    })

    Tabs.GuestSettings:AddInput("DetectionRangeInput", {
        Title = "Detection Range",
        Placeholder = "18",
        Numeric = true,
        Callback = function(text)
            detectionRange = tonumber(text) or detectionRange
        end
    })

    Tabs.GuestSettings:AddToggle("BlockTPToggle", {
        Title = "Block TP",
        Default = false,
        Callback = function(value)
            blockTPEnabled = value
        end
    })

    Tabs.GuestSettings:AddToggle("PredictiveBlockToggle", {
        Title = "Predictive Auto Block",
        Default = false,
        Callback = function(value)
            predictiveBlockOn = value
        end
    })

    Tabs.GuestSettings:AddInput("PredictiveDetectionRange", {
        Title = "Detection Range",
        Placeholder = "10",
        Numeric = true,
        Callback = function(text)
            local num = tonumber(text)
            if num then detectionRange = num end
        end
    })

    Tabs.GuestSettings:AddSlider("EdgeKillerSlider", {
        Title = "Edge Killer Delay",
        Default = 3,
        Min = 0,
        Max = 7,
        Rounding = 1,
        Callback = function(value)
            edgeKillerDelay = value
        end
    })

    Tabs.GuestSettings:AddButton({
        Title = "Load Fake Block",
        Callback = function()
            pcall(function()
                local fakeGui = PlayerGui:FindFirstChild("FakeBlockGui")
                if not fakeGui then
                    loadstring(game:HttpGet("https://pastebin.com/raw/ztnYv27k"))()
                else
                    fakeGui.Enabled = true
                end
            end)
        end
    })

    Tabs.GuestSettings:AddToggle("FlingPunchToggle", {
        Title = "Fling Punch",
        Default = false,
        Callback = function(value)
            flingPunchOn = value
        end
    })

    Tabs.GuestSettings:AddToggle("PunchAimbotToggle", {
        Title = "Punch Aimbot",
        Default = false,
        Callback = function(value)
            aimPunch = value
        end
    })

    local predictionValue = 4
    Tabs.GuestSettings:AddSlider("AimPredictionSlider", {
        Title = "Aim Prediction",
        Default = 4,
        Min = 0,
        Max = 10,
        Rounding = 1,
        Suffix = "studs",
        Callback = function(value)
            predictionValue = value
        end
    })

    Tabs.GuestSettings:AddSlider("FlingPowerSlider", {
        Title = "Fling Power",
        Default = 10000,
        Min = 5000,
        Max = 50000000000000,
        Rounding = 0,
        Callback = function(value)
            flingPower = value
        end
    })

    -- ===================== CUSTOM ANIMATIONS TAB =====================
    Tabs.CustomAnimations:AddInput("CustomBlockAnim", {
        Title = "Custom Block Animation",
        Placeholder = "AnimationId",
        Callback = function(text)
            customBlockAnimId = text
        end
    })

    Tabs.CustomAnimations:AddToggle("EnableCustomBlockAnim", {
        Title = "Enable Custom Block",
        Default = false,
        Callback = function(value)
            customBlockEnabled = value
        end
    })

    Tabs.CustomAnimations:AddInput("CustomPunchAnim", {
        Title = "Custom Punch Animation",
        Placeholder = "AnimationId",
        Callback = function(text)
            customPunchAnimId = text
        end
    })

    Tabs.CustomAnimations:AddToggle("EnableCustomPunchAnim", {
        Title = "Enable Custom Punch",
        Default = false,
        Callback = function(value)
            customPunchEnabled = value
        end
    })

    Tabs.CustomAnimations:AddInput("ChargeAnimID", {
        Title = "Charge Animation ID",
        Placeholder = "Animation ID",
        Callback = function(input)
            customChargeAnimId = input
        end
    })

    Tabs.CustomAnimations:AddToggle("EnableCustomChargeAnim", {
        Title = "Custom Charge Animation",
        Default = false,
        Callback = function(value)
            customChargeEnabled = value
        end
    })

    -- ===================== DISCORD TAB =====================
    Tabs.Discord:AddButton({
        Title = "Copy Discord Invite Link",
        Callback = function()
            setclipboard("https://discord.gg/aXNagEYb2f")
            if Fluent and Fluent.Notify then
                Fluent:Notify({
                    Title = "Copied Discord Invite Link!",
                    Content = "Discord link copied to clipboard!",
                    Duration = 8
                })
            end
        end
    })

    -- ===================== FINALIZE =====================
    Window:SelectTab("Player")
    if Fluent and Fluent.Notify then
        Fluent:Notify({
            Title = "Goonsaken Hub v3.6",
            Content = "Shadow Style - Perfect Toggle!",
            Duration = 8
        })
    end

    hubLoaded = true
end

-- ===================== ORIGINAL AUTO BLOCK LOGIC =====================
local AttackAnimations = {
    "rbxassetid://131430497821198", "rbxassetid://83829782357897", "rbxassetid://126830014841198",
    "rbxassetid://126355327951215", "rbxassetid://121086746534252", "rbxassetid://105458270463374",
    "rbxassetid://127172483138092", "rbxassetid://18885919947", "rbxassetid://18885909645",
    "rbxassetid://87259391926321", "rbxassetid://106014898528300", "rbxassetid://86545133269813",
    "rbxassetid://89448354637442", "rbxassetid://90499469533503", "rbxassetid://116618003477002",
    "rbxassetid://106086955212611", "rbxassetid://107640065977686", "rbxassetid://77124578197357",
    "rbxassetid://101771617803133", "rbxassetid://134958187822107", "rbxassetid://111313169447787",
    "rbxassetid://71685573690338", "rbxassetid://129843313690921", "rbxassetid://97623143664485",
    "rbxassetid://136007065400978", "rbxassetid://86096387000557", "rbxassetid://108807732150251",
    "rbxassetid://138040001965654", "rbxassetid://73502073176819", "rbxassetid://86709774283672",
    "rbxassetid://140703210927645", "rbxassetid://96173857867228", "rbxassetid://121255898612475",
    "rbxassetid://98031287364865", "rbxassetid://119462383658044", "rbxassetid://77448521277146",
    "rbxassetid://103741352379819", "rbxassetid://131696603025265", "rbxassetid://122503338277352",
    "rbxassetid://97648548303678", "rbxassetid://94162446513587", "rbxassetid://84426150435898",
    "rbxassetid://93069721274110", "rbxassetid://114620047310688", "rbxassetid://97433060861952",
    "rbxassetid://82183356141401", "rbxassetid://100592913030351", "rbxassetid://121293883585738",
    "rbxassetid://70447634862911", "rbxassetid://92173139187970", "rbxassetid://106847695270773",
    "rbxassetid://125403313786645", "rbxassetid://81639435858902", "rbxassetid://137314737492715",
    "rbxassetid://120112897026015", "rbxassetid://82113744478546", "rbxassetid://118298475669935",
    "rbxassetid://126681776859538", "rbxassetid://129976080405072", "rbxassetid://109667959938617",
    "rbxassetid://74707328554358", "rbxassetid://133336594357903", "rbxassetid://86204001129974",
    "rbxassetid://124243639579224", "rbxassetid://70371667919898", "rbxassetid://131543461321709",
    "rbxassetid://136323728355613", "rbxassetid://109230267448394"
}

local function fireRemoteBlock()
    ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer("UseActorAbility", "Block")
end

local function isFacing(localRoot, targetRoot)
    if not localRoot or not targetRoot then return false end
    local offset = localRoot.Position - targetRoot.Position
    if offset.Magnitude == 0 then return false end
    local dir = offset.Unit
    local dot = targetRoot.CFrame.LookVector:Dot(dir)
    if looseFacing then
        return dot > -0.3
    else
        return dot > 0
    end
end

local function playCustomAnim(animId, isPunch)
    if not Humanoid then return end
    if not animId or animId == "" then return end
    local now = tick()
    local lastTime = isPunch and lastPunchTime or lastBlockTime
    if now - lastTime < 1 then return end
    for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
        local animNum = tostring(track.Animation.AnimationId):match("%d+")
        if table.find(isPunch and punchAnimIds or blockAnimIds, animNum) then
            track:Stop()
        end
    end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animId
    local success, track = pcall(function()
        return Humanoid:LoadAnimation(anim)
    end)
    if success and track then
        track:Play()
        if isPunch then
            lastPunchTime = now
        else
            lastBlockTime = now
        end
    end
end

-- ===================== MAIN AUTO BLOCK LOOP =====================
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    Humanoid = myChar:FindFirstChildOfClass("Humanoid")

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if not Players:GetPlayerFromCharacter(plr.Character) then return end
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local animTracks = hum and hum:FindFirstChildOfClass("Animator") and hum:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()

            if hrp and myRoot and (hrp.Position - myRoot.Position).Magnitude <= detectionRange then
                for _, track in ipairs(animTracks or {}) do
                    local id = tostring(track.Animation.AnimationId):match("%d+")
                    if table.find(GuestSettingsTriggerAnims, id) then
                        if GuestSettingsOn and (not strictRangeOn or (hrp.Position - myRoot.Position).Magnitude <= detectionRange) then
                            if isFacing(myRoot, hrp) then
                                fireRemoteBlock()
                                if customBlockEnabled and customBlockAnimId ~= "" then
                                    playCustomAnim(customBlockAnimId, false)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if blockTPEnabled and Humanoid and tick() - lastBlockTpTime >= 5 then
        for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if animId == "72722244508749" or animId == "96959123077498" then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local killers = {"c00lkidd", "Jason", "JohnDoe", "1x1x1x1", "Noli"}
                    for _, name in ipairs(killers) do
                        local killer = workspace:FindFirstChild("Players")
                            and workspace.Players:FindFirstChild("Killers")
                            and workspace.Players.Killers:FindFirstChild(name)
                        if not Players:GetPlayerFromCharacter(killer) then return end
                        if killer and killer:FindFirstChild("HumanoidRootPart") then
                            lastBlockTpTime = tick()
                            task.spawn(function()
                                local startTime = tick()
                                while tick() - startTime < 0.5 do
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        local myRoot = LocalPlayer.Character.HumanoidRootPart
                                        local targetHRP = killer.HumanoidRootPart
                                        local direction = targetHRP.CFrame.LookVector
                                        local tpPosition = targetHRP.Position + direction * 6
                                        myRoot.CFrame = CFrame.new(tpPosition)
                                    end
                                    task.wait()
                                end
                            end)
                            break
                        end
                    end
                end
                break
            end
        end
    end

    if predictiveBlockOn and tick() > predictiveCooldown then
        local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChild("Humanoid")

        if killersFolder and myHRP and myHum then
            local killerInRange = false
            for _, killer in ipairs(killersFolder:GetChildren()) do
                if not Players:GetPlayerFromCharacter(killer) then continue end
                local hrp = killer:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (myHRP.Position - hrp.Position).Magnitude
                    if dist <= detectionRange then
                        killerInRange = true
                        break
                    end
                end
            end

            if killerInRange then
                if not killerInRangeSince then
                    killerInRangeSince = tick()
                elseif tick() - killerInRangeSince >= edgeKillerDelay then
                    fireRemoteBlock()
                    predictiveCooldown = tick() + 2
                    killerInRangeSince = nil
                end
            else
                killerInRangeSince = nil
            end
        end
    end

    if GuestSettingsOn then
        local gui = PlayerGui:FindFirstChild("MainUI")
        local punchBtn = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Punch")
        local charges = punchBtn and punchBtn:FindFirstChild("Charges")

        if charges and charges.Text == "1" then
            local killerNames = {"c00lkidd", "Jason", "JohnDoe", "1x1x1x1", "Noli"}
            for _, name in ipairs(killerNames) do
                local killer = workspace:FindFirstChild("Players")
                    and workspace.Players:FindFirstChild("Killers")
                    and workspace.Players.Killers:FindFirstChild(name)
                if not Players:GetPlayerFromCharacter(killer) then return end
                if killer and killer:FindFirstChild("HumanoidRootPart") then
                    local root = killer.HumanoidRootPart
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if root and myRoot and (root.Position - myRoot.Position).Magnitude <= 10 then
                        if aimPunch then
                            local humanoid = myChar:FindFirstChild("Humanoid")
                            if humanoid then humanoid.AutoRotate = false end
                            task.spawn(function()
                                local start = tick()
                                while tick() - start < 2 do
                                    local myRootNow = myChar:FindFirstChild("HumanoidRootPart")
                                    local targetRoot = root and root.Parent and root.Parent:FindFirstChild("HumanoidRootPart")
                                    if myRootNow and targetRoot then
                                        local predictedPos = targetRoot.Position + (targetRoot.CFrame.LookVector * predictionValue)
                                        myRootNow.CFrame = CFrame.lookAt(myRootNow.Position, predictedPos)
                                    end
                                    task.wait()
                                end
                                if humanoid and humanoid.Parent then
                                    humanoid.AutoRotate = true
                                end
                            end)
                        end

                        for _, conn in ipairs(getconnections(punchBtn.MouseButton1Click)) do
                            pcall(function() conn:Fire() end)
                        end

                        if flingPunchOn then
                            hiddenfling = true
                            local targetHRP = root
                            task.spawn(function()
                                local start = tick()
                                while tick() - start < 1 do
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and targetHRP and targetHRP.Parent then
                                        local frontPos = targetHRP.Position + (targetHRP.CFrame.LookVector * 2)
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(frontPos, targetHRP.Position)
                                    end
                                    task.wait()
                                end
                                hiddenfling = false
                            end)
                        end

                        if customPunchEnabled and customPunchAnimId ~= "" then
                            playCustomAnim(customPunchAnimId, true)
                        end
                        break
                    end
                end
            end
        end
    end
end)

-- ===================== CUSTOM ANIMATION REPLACER =====================
local lastReplaceTime = { block = 0, punch = 0, charge = 0 }

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        local char = LocalPlayer.Character
        if not char then continue end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if not animator then continue end

        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local animId = tostring(track.Animation.AnimationId):match("%d+")

            if customBlockEnabled and customBlockAnimId ~= "" and table.find(blockAnimIds, animId) then
                if tick() - lastReplaceTime.block >= 3 then
                    lastReplaceTime.block = tick()
                    track:Stop()
                    local newAnim = Instance.new("Animation")
                    newAnim.AnimationId = "rbxassetid://" .. customBlockAnimId
                    local newTrack = animator:LoadAnimation(newAnim)
                    newTrack:Play()
                    break
                end
            end

            if customPunchEnabled and customPunchAnimId ~= "" and table.find(punchAnimIds, animId) then
                if tick() - lastReplaceTime.punch >= 3 then
                    lastReplaceTime.punch = tick()
                    track:Stop()
                    local newAnim = Instance.new("Animation")
                    newAnim.AnimationId = "rbxassetid://" .. customPunchAnimId
                    local newTrack = animator:LoadAnimation(newAnim)
                    newTrack:Play()
                    break
                end
            end

            if customChargeEnabled and customChargeAnimId ~= "" and table.find(chargeAnimIds, animId) then
                if tick() - lastReplaceTime.charge >= 3 then
                    lastReplaceTime.charge = tick()
                    track:Stop()
                    local newAnim = Instance.new("Animation")
                    newAnim.AnimationId = "rbxassetid://" .. customChargeAnimId
                    local newTrack = animator:LoadAnimation(newAnim)
                    newTrack:Play()
                    break
                end
            end
        end
    end
end)

-- ===================== HITBOX RIDE LOGIC =====================
RunService.Heartbeat:Connect(function()
    if not hitboxmodificationEnabled then return end
    if not HumanoidRootPart then return end

    local playing = false
    for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
        if table.find(AttackAnimations, track.Animation.AnimationId) and (track.TimePosition / track.Length < 0.75) then
            playing = true
            break
        end
    end
    if not playing then return end

    local Target
    local NearestDist = MaxRange

    local function scanGroup(group)
        for _, obj in ipairs(group) do
            if obj == Character or not obj:FindFirstChild("HumanoidRootPart") then continue end
            local dist = (obj.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            if dist < NearestDist then
                NearestDist = dist
                Target = obj
            end
        end
    end

    scanGroup(workspace.Players:GetDescendants())
    local npcs = workspace:FindFirstChild("Map", true) and workspace.Map:FindFirstChild("NPCs", true)
    if npcs then
        scanGroup(npcs:GetChildren())
    end

    if not Target then return end

    local ping = LocalPlayer:GetNetworkPing()
    local randomOffset = Vector3.new(RNG:NextNumber(-1.5, 1.5), 0, RNG:NextNumber(-1.5, 1.5))
    local predicted = Target.HumanoidRootPart.Position + randomOffset + (Target.HumanoidRootPart.Velocity * (ping * 1.25))
    local neededVelocity = (predicted - HumanoidRootPart.Position) / (ping * 2)

    local oldVelocity = HumanoidRootPart.Velocity
    HumanoidRootPart.Velocity = neededVelocity
    RunService.RenderStepped:Wait()
    HumanoidRootPart.Velocity = oldVelocity
end)

-- ===================== ANTI SLOW =====================
RunService.RenderStepped:Connect(function()
    if AntiSlow then
        checkAndSetSlowStatus()
        enforceMultipliers()
    end
end)

-- ===================== CHAT ENABLER =====================
RunService.Heartbeat:Connect(function()
    chatWindow.Enabled = true
end)

-- ===================== AUTO REJOIN =====================
if toggles.AutoRejoinOnKick and not Connections.AutoRejoin then
    Connections.AutoRejoin = GuiService.ErrorMessageChanged:Connect(function(msg)
        if msg and msg ~= "" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end
    end)
end

-- ===================== SHADOW STYLE MENU TOGGLE (FINAL FIX) =====================
task.spawn(function()
    -- Tunggu Fluent benar-benar siap
    repeat task.wait(0.5) until Window and Window.Root
    repeat task.wait(0.5) until Window.Root.Parent and Window.Root.Parent:IsA("ScreenGui")
    
    -- Dapatkan ScreenGui Fluent
    local fluentScreenGui = Window.Root.Parent
    if not fluentScreenGui or not fluentScreenGui:IsA("ScreenGui") then
        fluentScreenGui = game.CoreGui:FindFirstChildWhichIsA("ScreenGui")
        if not fluentScreenGui then
            warn("[Goonsaken] Gagal menemukan ScreenGui!")
            return
        end
    end
    
    -- Buat ScreenGui terpisah untuk tombol (agar tidak ikut tersembunyi)
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "GoonHubToggleGui"
    toggleGui.ResetOnSpawn = false
    toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleGui.Parent = game.CoreGui
    
    -- Buat tombol dengan Frame sebagai background
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ToggleFrame"
    buttonFrame.Size = UDim2.new(0, 70, 0, 70)
    buttonFrame.Position = UDim2.new(0, 20, 0, 100)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    buttonFrame.BackgroundTransparency = 0
    buttonFrame.BorderSizePixel = 0
    buttonFrame.ClipsDescendants = false
    buttonFrame.ZIndex = 9999
    buttonFrame.Parent = toggleGui
    
    -- Corner radius untuk frame
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 14)
    frameCorner.Parent = buttonFrame
    
    -- Shadow/glow effect
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    glow.BackgroundTransparency = 0.7
    glow.BorderSizePixel = 0
    glow.ZIndex = -1
    glow.Parent = buttonFrame
    Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 18)
    
    -- Tombol utama
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1, -10, 1, -10)
    toggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    toggleButton.BackgroundTransparency = 0
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "−"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 32
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.ZIndex = 9999
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = buttonFrame
    
    -- Corner untuk tombol
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = toggleButton
    
    -- Tooltip saat hover
    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 120, 0, 25)
    tooltip.Position = UDim2.new(0.5, -60, 1, 10)
    tooltip.AnchorPoint = Vector2.new(0.5, 0)
    tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    tooltip.BackgroundTransparency = 0.2
    tooltip.BorderSizePixel = 0
    tooltip.Text = "Toggle Menu ( - )"
    tooltip.TextColor3 = Color3.fromRGB(200, 200, 255)
    tooltip.TextSize = 12
    tooltip.Font = Enum.Font.GothamMedium
    tooltip.Visible = false
    tooltip.ZIndex = 9999
    tooltip.Parent = buttonFrame
    Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0, 6)
    
    -- Variabel state
    local menuVisible = true
    
    -- Fungsi toggle yang AMAN (hanya menyembunyikan menu Fluent)
    local function toggleMenu()
        menuVisible = not menuVisible
        
        -- HANYA target menu Fluent, BUKAN semua objek
        local success = pcall(function()
            -- Method 1: Set ScreenGui Enabled (paling aman)
            if fluentScreenGui and fluentScreenGui:IsA("ScreenGui") then
                fluentScreenGui.Enabled = menuVisible
            end
            
            -- Method 2: Set Root Visible
            if Window and Window.Root then
                Window.Root.Visible = menuVisible
            end
            
            -- Method 3: Set container jika ada
            if Window and Window.Container then
                Window.Container.Visible = menuVisible
            end
            if Window and Window._container then
                Window._container.Visible = menuVisible
            end
        end)
        
        if not success then
            -- Fallback: cari frame dengan Title
            for _, child in ipairs(fluentScreenGui:GetChildren()) do
                if child:IsA("Frame") and child:FindFirstChild("Title") then
                    child.Visible = menuVisible
                end
            end
        end
        
        -- Update tampilan tombol (TANPA menyembunyikan tombol itu sendiri)
        if menuVisible then
            toggleButton.Text = "−"
            buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
            glow.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
            glow.BackgroundTransparency = 0.7
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            tooltip.Text = "Toggle Menu ( - )"
        else
            toggleButton.Text = "+"
            buttonFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
            glow.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            glow.BackgroundTransparency = 0.6
            toggleButton.TextColor3 = Color3.fromRGB(255, 200, 200)
            tooltip.Text = "Show Menu ( + )"
        end
    end
    
    -- ==================== EVENT HANDLERS ====================
    
    -- Hover effect
    toggleButton.MouseEnter:Connect(function()
        tooltip.Visible = true
        if menuVisible then
            buttonFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
            glow.BackgroundTransparency = 0.4
        else
            buttonFrame.BackgroundColor3 = Color3.fromRGB(75, 35, 35)
            glow.BackgroundTransparency = 0.3
        end
    end)
    
    toggleButton.MouseLeave:Connect(function()
        tooltip.Visible = false
        if menuVisible then
            buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
            glow.BackgroundTransparency = 0.7
        else
            buttonFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
            glow.BackgroundTransparency = 0.6
        end
    end)
    
    -- Click
    toggleButton.MouseButton1Click:Connect(toggleMenu)
    
-- ==================== DRAG SYSTEM (FIXED - Lebih Responsif) ====================
local dragData = {
    dragging = false,
    dragStart = nil,
    startPos = nil,
    isDragging = false
}

-- Deteksi drag dari tombol (bukan frame)
toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = true
        dragData.dragStart = input.Position
        dragData.startPos = buttonFrame.Position
        dragData.isDragging = false
    end
end)

toggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = false
        -- Jika tidak ada pergerakan, berarti klik biasa
        task.wait(0.05)
        dragData.isDragging = false
    end
end)

-- Track mouse movement
local mouseConnection
mouseConnection = UserInputService.InputChanged:Connect(function(input)
    if dragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragData.dragStart
        -- Deteksi jika ada pergerakan (bukan klik)
        if delta.Magnitude > 5 then
            dragData.isDragging = true
        end
        
        if dragData.isDragging then
            -- Hitung posisi baru
            local newX = dragData.startPos.X.Offset + delta.X
            local newY = dragData.startPos.Y.Offset + delta.Y
            
            -- Batasi agar tidak keluar layar
            local screenSize = game:GetService("GuiService"):GetScreenSize()
            local maxX = screenSize.X - 70
            local maxY = screenSize.Y - 70
            
            newX = math.clamp(newX, 0, maxX)
            newY = math.clamp(newY, 0, maxY)
            
            -- Terapkan posisi baru
            buttonFrame.Position = UDim2.new(0, newX, 0, newY)
            
            -- Simpan posisi
            _G.GoonHubButtonPos = { X = newX, Y = newY }
        end
    end
end)

-- Cleanup saat tombol dihapus
toggleButton.AncestryChanged:Connect(function()
    if not toggleButton.Parent then
        if mouseConnection then
            mouseConnection:Disconnect()
            mouseConnection = nil
        end
    end
end)
    
    -- ==================== KEYBOARD SHORTCUT ====================
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.M then
            toggleMenu()
        end
    end)
    
    -- ==================== SIMPAN POSISI ====================
    -- Simpan posisi tombol (opsional)
    local function savePosition()
        local pos = buttonFrame.Position
        _G.GoonHubButtonPos = {
            X = pos.X.Offset,
            Y = pos.Y.Offset
        }
    end
    
    -- Load posisi tersimpan
    if _G.GoonHubButtonPos then
        buttonFrame.Position = UDim2.new(0, _G.GoonHubButtonPos.X, 0, _G.GoonHubButtonPos.Y)
    end
    
    -- Simpan posisi saat game ditutup
    game:BindToClose(savePosition)
    
    -- ==================== GLOBAL API ====================
    _G.GoonHubToggle = {
        Button = toggleButton,
        Frame = buttonFrame,
        Toggle = toggleMenu,
        Show = function()
            if not menuVisible then toggleMenu() end
        end,
        Hide = function()
            if menuVisible then toggleMenu() end
        end,
        IsVisible = function()
            return menuVisible
        end,
        SetPosition = function(x, y)
            buttonFrame.Position = UDim2.new(0, x or 20, 0, y or 100)
        end
    }
    
    print("[Goonsaken] ✅ Menu toggle berhasil!")
    print("💡 Klik tombol atau tekan '-' di keyboard")
    print("💡 Drag tombol untuk memindahkan")
    
    -- Notifikasi awal
    if Fluent and Fluent.Notify then
        pcall(function()
            Fluent:Notify({
                Title = "Goonsaken Hub v3.6",
                Content = "Klik '−' atau tekan '-' untuk toggle menu!",
                Duration = 3
            })
        end)
    end
end)