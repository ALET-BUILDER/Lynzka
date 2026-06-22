--[[
    ╔══════════════════════════════════════════╗
    ║      🔥 LYNZKA HUB v3.6 🔥             ║
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

-- ===================== JUMP POWER VARIABLES =====================
local jumpPowerValue = 50
local jumpPowerActive = true
local jumpPowerLoop = nil

-- ===================== WALKSPEED VARIABLES =====================
local walkSpeedValue = 1
local walkSpeedActive = true
local walkSpeedLoop = nil

-- ===================== INFINITE STAMINA FIX =====================
local staminaActive = false
local staminaLoop = nil

-- ===================== STATS TRACKER =====================
local statsTrackerActive = false
local statsGui = nil

-- ===================== SPEED HACK VARIABLES =====================
local speedHackActive = false
local speedHackValue = 5

-- ===================== FLY VARIABLES =====================
local flyActive = false
local flyHeight = 10
local flyConnection = nil
local flyHeightOptions = {}
for i = 1, 30 do
    table.insert(flyHeightOptions, tostring(i) .. "m")
end

-- ===================== DRAG SYSTEM =====================
local catDragData = {
    dragging = false,
    startPos = nil,
    startMouse = nil
}

-- ===================== NOTIFICATION SYSTEM =====================
local function notify(text, duration)
    duration = duration or 3
    if Fluent and Fluent.Notify then
        pcall(function()
            Fluent:Notify({
                Title = "LYNZKA HUB",
                Content = text,
                Duration = duration
            })
        end)
    else
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 300, 0, 40)
        notification.Position = UDim2.new(0.5, -150, 1, -50)
        notification.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        notification.BackgroundTransparency = 0
        notification.TextColor3 = Color3.fromRGB(100, 180, 255)
        notification.Font = Enum.Font.GothamBold
        notification.TextSize = 14
        notification.Text = "LYNZKA HUB: " .. text
        notification.Parent = game.CoreGui
        Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 8)
        TweenService:Create(notification, TweenInfo.new(0.5), {
            Position = UDim2.new(0.5, -150, 1, -60)
        }):Play()
        task.delay(duration, function()
            TweenService:Create(notification, TweenInfo.new(0.4), {
                Position = UDim2.new(0.5, -150, 1, 10)
            }):Play()
            task.delay(0.5, function() notification:Destroy() end)
        end)
    end
end

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
    FOVCircle.Visible = false
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

-- ===================== INVISIBLE FIX (BENAR - MENUNGGU TOGGLE) =====================
local function ToggleInvisibleShadow()
    invisibleActive = not invisibleActive
    local char = LocalPlayer.Character
    if not char then
        notify("❌ Character not found!", 2)
        return
    end
    
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
                    part.Transparency = originalTransparency[part] or 0
                end
            end
        end
        originalTransparency = {}
        notify("👁 INVISIBLE OFF", 2)
    end
end

-- ===================== WALLBANG =====================
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
                    part.CanCollide = true
                end
            end
        end
        notify("🧱 WALLBANG OFF", 2)
    end
end

-- ===================== SPEED HACK =====================
local function ToggleSpeedHack(state)
    speedHackActive = state
    if speedHackActive then
        if SpeedLoop then SpeedLoop:Disconnect() end
        SpeedLoop = RunService.Heartbeat:Connect(function()
            if not speedHackActive then
                if SpeedLoop then SpeedLoop:Disconnect() end
                SpeedLoop = nil
                return
            end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local ws = 16 + (speedHackValue * 6)
                    ws = math.clamp(ws, 8, 120)
                    hum.WalkSpeed = ws
                end
            end
        end)
        notify("💨 Speed Hack ON - " .. speedHackValue .. "x", 2)
    else
        if SpeedLoop then
            SpeedLoop:Disconnect()
            SpeedLoop = nil
        end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end
        notify("💨 Speed Hack OFF", 2)
    end
end

-- ===================== FLY SYSTEM (BENAR - MENUNGGU TOGGLE) =====================
local function ToggleFly(state)
    flyActive = state
    
    if flyActive then
        if flyConnection then flyConnection:Disconnect() end
        
        -- Pertama kali aktif, langsung naik ke ketinggian yang dipilih
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local targetPos = hrp.Position + Vector3.new(0, flyHeight, 0)
            hrp.CFrame = CFrame.new(targetPos)
        end
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyActive then
                if flyConnection then flyConnection:Disconnect() end
                flyConnection = nil
                return
            end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum then
                -- Matikan gravitasi
                hum.PlatformStand = true
                hum.Sit = false
                hum.AutoRotate = false
                
                -- Pertahankan ketinggian
                local currentPos = hrp.Position
                local targetPos = Vector3.new(currentPos.X, flyHeight, currentPos.Z)
                
                -- Jika terlalu rendah, naikkan perlahan
                if currentPos.Y < flyHeight - 0.5 then
                    hrp.CFrame = CFrame.new(currentPos + Vector3.new(0, 0.5, 0))
                elseif currentPos.Y > flyHeight + 0.5 then
                    hrp.CFrame = CFrame.new(currentPos - Vector3.new(0, 0.5, 0))
                end
                
                -- Aktifkan noclip saat terbang
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        notify("✈️ FLY ON - Height: " .. flyHeight .. "m", 3)
    else
        -- Matikan fly, kembali ke tanah
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
            
            -- Turun ke tanah
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local ray = Ray.new(hrp.Position, Vector3.new(0, -100, 0))
                local hit, pos = Workspace:FindPartOnRay(ray, char)
                if pos then
                    hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, pos.Y + 2, hrp.Position.Z))
                else
                    hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, 2, hrp.Position.Z))
                end
            end
        end
        notify("✈️ FLY OFF - Landing...", 2)
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
local GuestSettingsTriggerAnims = {
    "126830014841198", "126355327951215", "121086746534252", "18885909645",
    "98456918873918", "105458270463374", "83829782357897", "125403313786645",
    "118298475669935", "82113744478546", "70371667919898", "99135633258223",
    "97167027849946", "109230267448394", "139835501033932", "126896426760253",
    "109667959938617", "126681776859538", "129976080405072", "121293883585738",
    "81639435858902", "137314737492715", "92173139187970", "106847695270773"
}

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

-- ===================== BUILD FLUENT UI =====================
if FluentLoaded then
    Window = Fluent:CreateWindow({
        Title = "LYNZKA HUB",
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
    InterfaceManager:SetFolder("LYNZKAHub")
    SaveManager:SetFolder("LYNZKAHub/Configs")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- ===================== PLAYER TAB (HANYA: Wallbang, Invisible, Speed Hack, Fly) =====================
    
    -- WALLBANG
    Tabs.Player:AddToggle("Wallbang", {
        Title = "🧱 Wallbang",
        Description = "Tembus semua benda/dinding",
        Default = false,
        Callback = function(state)
            toggles.Wallbang = state
            ToggleWallbang()
        end
    })

    -- INVISIBLE (FIXED - MENUNGGU TOGGLE)
    Tabs.Player:AddToggle("InvisibleShadow", {
        Title = "👻 Invisible",
        Description = "Tubuh menjadi transparan (HANYA saat di-toggle ON)",
        Default = false,
        Callback = function(state)
            toggles.Invisible = state
            ToggleInvisibleShadow()
        end
    })

    -- SPEED HACK
    Tabs.Player:AddToggle("SpeedHack", {
        Title = "💨 Speed Hack",
        Description = "Meningkatkan kecepatan jalan",
        Default = false,
        Callback = function(state)
            ToggleSpeedHack(state)
        end
    })

    -- SPEED HACK VALUE (SLIDER DENGAN -/+)
    Tabs.Player:AddSlider("SpeedHackValue", {
        Title = "Speed Hack Value",
        Description = "Atur kecepatan (1x - 20x)",
        Default = 5,
        Min = 1,
        Max = 20,
        Rounding = 0,
        Suffix = "x",
        Callback = function(value)
            speedHackValue = value
            if speedHackActive then
                notify("💨 Speed Hack: " .. value .. "x", 2)
                -- Update kecepatan langsung
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local ws = 16 + (value * 6)
                        ws = math.clamp(ws, 8, 120)
                        hum.WalkSpeed = ws
                    end
                end
            end
        end
    })

    -- FLY TOGGLE
    Tabs.Player:AddToggle("Fly", {
        Title = "✈️ Fly",
        Description = "Terbang dengan ketinggian yang diatur",
        Default = false,
        Callback = function(state)
            ToggleFly(state)
        end
    })

    -- FLY HEIGHT SELECTOR (SEPERTI HITBOX MODE)
    local flyHeightOptions = {}
    for i = 1, 30 do
        table.insert(flyHeightOptions, tostring(i) .. "m")
    end
    
    Tabs.Player:AddDropdown("FlyHeight", {
        Title = "Fly Height",
        Description = "Pilih ketinggian terbang (1m - 30m)",
        Values = flyHeightOptions,
        Multi = false,
        Default = 1,
        Callback = function(value)
            -- Extract angka dari "Xm"
            local height = tonumber(value:match("(%d+)"))
            if height then
                flyHeight = height
                notify("✈️ Fly Height: " .. height .. "m", 2)
                
                -- Jika sedang terbang, update ketinggian
                if flyActive then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        local currentPos = hrp.Position
                        hrp.CFrame = CFrame.new(Vector3.new(currentPos.X, height, currentPos.Z))
                    end
                end
            end
        end
    })

    -- ===================== GAME TAB (HANYA: Infinite Stamina, Auto Rejoin, Rejoin) =====================
    
    -- INFINITE STAMINA
    local function toggleInfiniteStamina(state)
        infinitestamina = state
        if state then
            if staminaLoop then task.cancel(staminaLoop) end
            staminaLoop = task.spawn(function()
                while infinitestamina do
                    pcall(function()
                        local Sprinting = ReplicatedStorage.Systems.Character.Game.Sprinting
                        local stamina = require(Sprinting)
                        stamina.StaminaLossDisabled = true
                    end)
                    task.wait(0.5)
                end
            end)
            notify("♾️ Infinite Stamina ON", 2)
        else
            if staminaLoop then
                task.cancel(staminaLoop)
                staminaLoop = nil
            end
            pcall(function()
                local Sprinting = ReplicatedStorage.Systems.Character.Game.Sprinting
                local stamina = require(Sprinting)
                stamina.StaminaLossDisabled = false
            end)
            notify("♾️ Infinite Stamina OFF", 2)
        end
    end

    Tabs.Game:AddToggle("InfiniteStamina", {
        Title = "♾️ Infinite Stamina",
        Description = "Stamina tidak akan habis",
        Default = false,
        Callback = function(state)
            toggleInfiniteStamina(state)
        end
    })

    -- AUTO REJOIN
    Tabs.Game:AddToggle("AutoRejoinToggle", {
        Title = "🔄 Auto Rejoin on Kick",
        Description = "Otomatis join ulang saat di kick",
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
                notify("🔄 Auto Rejoin ON", 2)
            else
                if Connections.AutoRejoin then
                    Connections.AutoRejoin:Disconnect()
                    Connections.AutoRejoin = nil
                end
                notify("🔄 Auto Rejoin OFF", 2)
            end
        end
    })

    -- REJOIN
    Tabs.Game:AddButton({
        Title = "🔁 Rejoin",
        Description = "Join ulang ke server yang sama",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            notify("🔄 Rejoining...", 2)
        end
    })

    -- ===================== ESP TAB (BIARKAN SEMUA) =====================
    Tabs.ESP:AddToggle("ESPToggle", {
        Title = "👁️ Enable ESP",
        Description = "Nyalakan ESP untuk melihat player",
        Default = false,
        Callback = function(state)
            espSettings.Enabled = state
            if not state then ClearDrawings() end
            if state then
                notify("👁️ ESP ON", 2)
            else
                notify("👁️ ESP OFF", 2)
            end
        end
    })

    Tabs.ESP:AddToggle("ESPBox", {
        Title = "📦 Show Box",
        Description = "Tampilkan kotak di sekitar player",
        Default = true,
        Callback = function(state)
            espSettings.ShowBox = state
        end
    })

    Tabs.ESP:AddToggle("ESPNames", {
        Title = "📝 Show Names",
        Description = "Tampilkan nama player",
        Default = true,
        Callback = function(state)
            espSettings.ShowNames = state
        end
    })

    Tabs.ESP:AddToggle("ESPHealth", {
        Title = "❤️ Show Health",
        Description = "Tampilkan HP player",
        Default = true,
        Callback = function(state)
            espSettings.ShowHealth = state
        end
    })

    Tabs.ESP:AddToggle("ESPHealthBar", {
        Title = "📊 Show Health Bar",
        Description = "Tampilkan bar HP di samping player",
        Default = true,
        Callback = function(state)
            espSettings.ShowHealthBar = state
        end
    })

    Tabs.ESP:AddToggle("ESPDistance", {
        Title = "📏 Show Distance",
        Description = "Tampilkan jarak ke player",
        Default = true,
        Callback = function(state)
            espSettings.ShowDistance = state
        end
    })

    Tabs.ESP:AddToggle("ESPTracer", {
        Title = "〰️ Show Tracer",
        Description = "Tampilkan garis dari player ke bawah",
        Default = false,
        Callback = function(state)
            espSettings.ShowTracer = state
        end
    })

    Tabs.ESP:AddToggle("ESPTeamColor", {
        Title = "🎨 Team Colors",
        Description = "Warna ESP sesuai tim",
        Default = false,
        Callback = function(state)
            espSettings.ShowTeamColor = state
        end
    })

    Tabs.ESP:AddSlider("HealthBarThickness", {
        Title = "📊 Health Bar Thickness",
        Description = "Ketebalan bar HP (5 - 20)",
        Default = 10,
        Min = 5,
        Max = 20,
        Rounding = 0,
        Callback = function(value)
            UpdateHealthBarThickness(value)
            notify("📏 Health Bar Thickness: " .. value, 2)
        end
    })

    -- ===================== COMBAT TAB (BIARKAN SEMUA) =====================
    Tabs.Combat:AddToggle("AimbotToggle", {
        Title = "🎯 Aimbot",
        Description = "Auto aim ke musuh",
        Default = false,
        Callback = function(state)
            if state then 
                EnableAimbot()
                notify("🎯 Aimbot ON", 2)
            else 
                DisableAimbot()
                notify("🎯 Aimbot OFF", 2)
            end
        end
    })

    Tabs.Combat:AddToggle("ShowFOV", {
        Title = "⭕ Show FOV",
        Description = "Tampilkan lingkaran FOV aimbot",
        Default = false,
        Callback = function(state)
            if FOVCircle then 
                FOVCircle.Visible = state and aimbotEnabled
            end
        end
    })

    Tabs.Combat:AddToggle("TeamCheck", {
        Title = "👥 Team Check",
        Description = "Tidak aim ke tim sendiri",
        Default = true,
        Callback = function(state)
            teamCheck = state
        end
    })

    Tabs.Combat:AddSlider("AimbotFOV", {
        Title = "🎯 Aimbot FOV",
        Description = "Jarak deteksi aimbot (50 - 900)",
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
        Title = "🎯 Hitbox Mode",
        Description = "Pilih target body part",
        Values = {"Head", "Neck", "UpperTorso", "LowerTorso", "All"},
        Multi = false,
        Default = "Head",
        Callback = function(value)
            hitboxMode = value
        end
    })

    Tabs.Combat:AddToggle("ChanceAimbot", {
        Title = "🎲 Chance Aimbot",
        Description = "Aimbot legacy dengan prediksi",
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
                notify("🎯 Chance Aimbot ON", 2)
            else
                if Connections.ChanceAimbot then
                    Connections.ChanceAimbot:Disconnect()
                    Connections.ChanceAimbot = nil
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.AutoRotate = true end
                end
                notify("🎯 Chance Aimbot OFF", 2)
            end
        end
    })

    Tabs.Combat:AddSlider("ChanceAimbotPredictionValue", {
        Title = "🎲 Chance Aimbot Prediction",
        Description = "Nilai prediksi aimbot (0.1 - 2)",
        Default = 0.2,
        Min = 0.1,
        Max = 2,
        Rounding = 1,
        Callback = function(value)
            timeAhead = value
        end
    })

    -- ===================== MISC TAB (BIARKAN SEMUA) =====================
    Tabs.Misc:AddButton({
        Title = "⚡ Infinite Yield",
        Description = "Load admin command Infinite Yield",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            notify("⚡ Infinite Yield Loaded!", 2)
        end
    })

    Tabs.Misc:AddToggle("NameProtect", {
        Title = "🛡️ NameProtect",
        Description = "Sembunyikan nama player di UI",
        Default = false,
        Callback = function(state)
            task.spawn(function() 
                while state do
                    wait()
                    local gui = LocalPlayer.PlayerGui
                    if not gui then return end
                    -- NameProtect logic here
                end
            end)
            if state then
                notify("🛡️ NameProtect ON", 2)
            else
                notify("🛡️ NameProtect OFF", 2)
            end
        end
    })

    Tabs.Misc:AddButton({
        Title = "🚀 FPS Boost",
        Description = "Optimasi performa game",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/NumanTF3/roblox-fpsboost-script/refs/heads/main/main.lua'))()
            notify("🚀 FPS Boost Applied!", 2)
        end
    })

    Tabs.Misc:AddInput("PlaySoundByID", {
        Title = "🔊 Play Sound by ID",
        Description = "Masukkan ID sound Roblox",
        Placeholder = "Enter Roblox Sound ID",
        Numeric = true,
        Callback = function(input)
            local id = tonumber(input)
            if id then
                local soundPlayer = Instance.new("Sound")
                soundPlayer.SoundId = "rbxassetid://" .. id
                soundPlayer.Parent = Workspace
                soundPlayer:Play()
                task.delay(5, function() soundPlayer:Destroy() end)
                notify("🔊 Playing Sound ID: " .. id, 2)
            end
        end
    })

    Tabs.Misc:AddButton({
        Title = "🔀 Server Hop",
        Description = "Pindah ke server lain",
        Callback = function()
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
            notify("🔀 Server Hopping...", 2)
        end
    })

    -- ===================== BLATANT TAB (BIARKAN SEMUA) =====================
    Tabs.Blatant:AddButton({
        Title = "⚡ Do All Generators",
        Description = "Perbaiki semua generator sekaligus",
        Callback = function()
            generatorDoAll()
            notify("⚡ Doing all generators!", 2)
        end
    })

    Tabs.Blatant:AddSlider("GenSpeedValue", {
        Title = "⚡ Generator Speed",
        Description = "Kecepatan semua generator (3 - 10)",
        Default = 3,
        Min = 3,
        Max = 10,
        Rounding = 1,
        Callback = function(value)
            timebetweenpuzzles = value
        end
    })

    -- ===================== GUEST SETTINGS TAB (BIARKAN SEMUA) =====================
    Tabs.GuestSettings:AddParagraph({
        Title = "🍃 Guest 1337 Settings",
        Content = "Fitur khusus untuk Guest 1337"
    })

    Tabs.GuestSettings:AddToggle("ChargeSpeedToggle", {
        Title = "⚡ Custom Charge Speed",
        Description = "Aktifkan kecepatan charge kustom",
        Default = false,
        Callback = function(state)
            ChargeSpeedLoop = state
            if state then
                notify("⚡ Custom Charge Speed ON", 2)
            else
                notify("⚡ Custom Charge Speed OFF", 2)
            end
        end
    })

    Tabs.GuestSettings:AddSlider("GuestChargeSpeed", {
        Title = "⚡ Charge Speed",
        Description = "Nilai kecepatan charge (2.833 - 15)",
        Default = 2.833,
        Min = 2.833,
        Max = 15,
        Rounding = 1,
        Callback = function(value)
            GuestChargeSpeed = value
        end
    })

    Tabs.GuestSettings:AddToggle("GuestSettingsToggle", {
        Title = "🛡️ Auto Block",
        Description = "Auto block otomatis dari Guest",
        Default = false,
        Callback = function(value)
            GuestSettingsOn = value
            if value then
                notify("🛡️ Auto Block ON", 2)
            else
                notify("🛡️ Auto Block OFF", 2)
            end
        end
    })

    Tabs.GuestSettings:AddToggle("StrictRangeToggle", {
        Title = "🎯 Strict Range",
        Description = "Hanya block dalam range ketat",
        Default = false,
        Callback = function(value)
            strictRangeOn = value
        end
    })

    Tabs.GuestSettings:AddDropdown("FacingCheckDropdown", {
        Title = "👀 Facing Check",
        Description = "Loose atau Strict facing check",
        Values = {"Loose", "Strict"},
        Multi = false,
        Default = "Loose",
        Callback = function(option)
            looseFacing = option == "Loose"
        end
    })

    Tabs.GuestSettings:AddInput("DetectionRangeInput", {
        Title = "📏 Detection Range",
        Description = "Jarak deteksi Guest",
        Placeholder = "18",
        Numeric = true,
        Callback = function(text)
            detectionRange = tonumber(text) or detectionRange
        end
    })

    Tabs.GuestSettings:AddToggle("BlockTPToggle", {
        Title = "📍 Block TP",
        Description = "Teleport saat block",
        Default = false,
        Callback = function(value)
            blockTPEnabled = value
        end
    })

    Tabs.GuestSettings:AddToggle("PredictiveBlockToggle", {
        Title = "🔮 Predictive Auto Block",
        Description = "Auto block prediktif",
        Default = false,
        Callback = function(value)
            predictiveBlockOn = value
        end
    })

    Tabs.GuestSettings:AddInput("PredictiveDetectionRange", {
        Title = "📏 Predictive Detection Range",
        Description = "Jarak deteksi prediktif",
        Placeholder = "10",
        Numeric = true,
        Callback = function(text)
            local num = tonumber(text)
            if num then detectionRange = num end
        end
    })

    Tabs.GuestSettings:AddSlider("EdgeKillerSlider", {
        Title = "⏱️ Edge Killer Delay",
        Description = "Delay auto block (0 - 7)",
        Default = 3,
        Min = 0,
        Max = 7,
        Rounding = 1,
        Callback = function(value)
            edgeKillerDelay = value
        end
    })

    Tabs.GuestSettings:AddButton({
        Title = "🎭 Load Fake Block",
        Description = "Load fake block GUI",
        Callback = function()
            pcall(function()
                local fakeGui = PlayerGui:FindFirstChild("FakeBlockGui")
                if not fakeGui then
                    loadstring(game:HttpGet("https://pastebin.com/raw/ztnYv27k"))()
                else
                    fakeGui.Enabled = true
                end
                notify("🎭 Fake Block Loaded!", 2)
            end)
        end
    })

    Tabs.GuestSettings:AddToggle("FlingPunchToggle", {
        Title = "💥 Fling Punch",
        Description = "Fling saat punch",
        Default = false,
        Callback = function(value)
            flingPunchOn = value
        end
    })

    Tabs.GuestSettings:AddToggle("PunchAimbotToggle", {
        Title = "🎯 Punch Aimbot",
        Description = "Aimbot saat punch",
        Default = false,
        Callback = function(value)
            aimPunch = value
        end
    })

    Tabs.GuestSettings:AddSlider("AimPredictionSlider", {
        Title = "📊 Aim Prediction",
        Description = "Nilai prediksi aim (0 - 10)",
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
        Title = "💥 Fling Power",
        Description = "Kekuatan fling",
        Default = 10000,
        Min = 5000,
        Max = 50000000000000,
        Rounding = 0,
        Callback = function(value)
            flingPower = value
        end
    })

    -- ===================== CUSTOM ANIMATIONS TAB (BIARKAN SEMUA) =====================
    Tabs.CustomAnimations:AddInput("CustomBlockAnim", {
        Title = "🎭 Custom Block Animation",
        Description = "Masukkan ID animasi block",
        Placeholder = "AnimationId",
        Callback = function(text)
            customBlockAnimId = text
        end
    })

    Tabs.CustomAnimations:AddToggle("EnableCustomBlockAnim", {
        Title = "🎭 Enable Custom Block",
        Description = "Aktifkan animasi block kustom",
        Default = false,
        Callback = function(value)
            customBlockEnabled = value
        end
    })

    Tabs.CustomAnimations:AddInput("CustomPunchAnim", {
        Title = "🎭 Custom Punch Animation",
        Description = "Masukkan ID animasi punch",
        Placeholder = "AnimationId",
        Callback = function(text)
            customPunchAnimId = text
        end
    })

    Tabs.CustomAnimations:AddToggle("EnableCustomPunchAnim", {
        Title = "🎭 Enable Custom Punch",
        Description = "Aktifkan animasi punch kustom",
        Default = false,
        Callback = function(value)
            customPunchEnabled = value
        end
    })

    Tabs.CustomAnimations:AddInput("ChargeAnimID", {
        Title = "🎭 Charge Animation ID",
        Description = "Masukkan ID animasi charge",
        Placeholder = "Animation ID",
        Callback = function(input)
            customChargeAnimId = input
        end
    })

    Tabs.CustomAnimations:AddToggle("EnableCustomChargeAnim", {
        Title = "🎭 Custom Charge Animation",
        Description = "Aktifkan animasi charge kustom",
        Default = false,
        Callback = function(value)
            customChargeEnabled = value
        end
    })

    -- ===================== DISCORD TAB =====================
    Tabs.Discord:AddButton({
        Title = "📋 Copy Discord Invite Link",
        Description = "Copy link Discord LYNZKA",
        Callback = function()
            setclipboard("https://discord.gg/aXNagEYb2f")
            notify("📋 Discord link copied!", 2)
        end
    })

    -- ===================== SETTINGS TAB =====================
    Tabs.Settings:AddButton({
        Title = "📐 Center GUI",
        Description = "Posisikan menu di tengah",
        Callback = function()
            if Window and Window.Root then
                Window.Root.Position = UDim2.new(0.5, -290, 0.5, -230)
                notify("📐 GUI Centered!", 2)
            end
        end
    })

    -- ===================== FINALIZE =====================
    Window:SelectTab("Player")
    notify("🔥 LYNZKA HUB v3.6 Loaded! - Shadow Style Perfect!", 4)

    hubLoaded = true
end

-- ===================== FLY LOOP (KEEP FLYING) =====================
RunService.Heartbeat:Connect(function()
    if flyActive then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum then
                hum.PlatformStand = true
                hum.Sit = false
                hum.AutoRotate = false
                
                -- Pertahankan ketinggian
                local currentPos = hrp.Position
                if math.abs(currentPos.Y - flyHeight) > 0.5 then
                    hrp.CFrame = CFrame.new(Vector3.new(currentPos.X, flyHeight, currentPos.Z))
                end
                
                -- Noclip saat terbang
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

-- ===================== CHARGE SPEED LOOP =====================
RunService.Stepped:Connect(function()
    if ChargeSpeedLoop then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local speedMultipliers = character:FindFirstChild("SpeedMultipliers")
        local mult = speedMultipliers and speedMultipliers:FindFirstChild("Guest1337Charge")
        if mult and GuestChargeSpeed ~= nil then
            mult.Value = GuestChargeSpeed
        end
    end
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

-- ===================== SHADOW STYLE MENU TOGGLE (FIXED) =====================
task.spawn(function()
    repeat task.wait(0.3) until Window and Window.Root
    repeat task.wait(0.3) until Window.Root.Parent and Window.Root.Parent:IsA("ScreenGui")
    
    local fluentScreenGui = Window.Root.Parent
    
    local oldGui = game.CoreGui:FindFirstChild("LYNZKAToggleGui")
    if oldGui then oldGui:Destroy() end
    
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "LYNZKAToggleGui"
    toggleGui.ResetOnSpawn = false
    toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleGui.Parent = game.CoreGui
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ToggleFrame"
    buttonFrame.Size = UDim2.new(0, 40, 0, 40)
    buttonFrame.Position = UDim2.new(0, 15, 0, 80)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    buttonFrame.BackgroundTransparency = 0
    buttonFrame.BorderSizePixel = 0
    buttonFrame.ClipsDescendants = false
    buttonFrame.ZIndex = 9999
    buttonFrame.Parent = toggleGui
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = buttonFrame
    
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    glow.BackgroundTransparency = 0.7
    glow.BorderSizePixel = 0
    glow.ZIndex = -1
    glow.Parent = buttonFrame
    Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 14)
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1.3, 0, 1.3, 0)
    toggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    toggleButton.BackgroundTransparency = 0
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "−"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 24
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.ZIndex = 9999
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = buttonFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = toggleButton
    
    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 80, 0, 18)
    tooltip.Position = UDim2.new(0.5, -40, 1, 6)
    tooltip.AnchorPoint = Vector2.new(0.5, 0)
    tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    tooltip.BackgroundTransparency = 0.3
    tooltip.BorderSizePixel = 0
    tooltip.Text = "Menu"
    tooltip.TextColor3 = Color3.fromRGB(200, 200, 255)
    tooltip.TextSize = 10
    tooltip.Font = Enum.Font.GothamMedium
    tooltip.Visible = false
    tooltip.ZIndex = 9999
    tooltip.Parent = buttonFrame
    Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0, 4)
    
    local menuVisible = true
    
    local function toggleMenu()
        menuVisible = not menuVisible
        
        pcall(function()
            if fluentScreenGui and fluentScreenGui:IsA("ScreenGui") then
                fluentScreenGui.Enabled = menuVisible
            end
            if Window and Window.Root then
                Window.Root.Visible = menuVisible
            end
        end)
        
        if menuVisible then
            toggleButton.Text = "−"
            buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
            glow.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
            glow.BackgroundTransparency = 0.7
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            tooltip.Text = "Menu"
        else
            toggleButton.Text = "+"
            buttonFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
            glow.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            glow.BackgroundTransparency = 0.6
            toggleButton.TextColor3 = Color3.fromRGB(255, 200, 200)
            tooltip.Text = "Menu"
        end
    end
    
    -- DRAG SYSTEM
    local dragData = {
        dragging = false,
        dragStart = nil,
        startPos = nil,
        isDragging = false
    }
    
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
            task.wait(0.05)
            dragData.isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragData.dragStart
            if delta.Magnitude > 3 then
                dragData.isDragging = true
            end
            
            if dragData.isDragging then
                local newX = dragData.startPos.X.Offset + delta.X
                local newY = dragData.startPos.Y.Offset + delta.Y
                
                local screenSize = game:GetService("GuiService"):GetScreenSize()
                local maxX = screenSize.X - 40
                local maxY = screenSize.Y - 40
                
                newX = math.clamp(newX, 0, maxX)
                newY = math.clamp(newY, 0, maxY)
                
                buttonFrame.Position = UDim2.new(0, newX, 0, newY)
                _G.LYNZKAButtonPos = { X = newX, Y = newY }
            end
        end
    end)
    
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
    
    toggleButton.MouseButton1Click:Connect(function()
        if not dragData.isDragging then
            toggleMenu()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.M then
            toggleMenu()
        end
    end)
    
    if _G.LYNZKAButtonPos then
        buttonFrame.Position = UDim2.new(0, _G.LYNZKAButtonPos.X, 0, _G.LYNZKAButtonPos.Y)
    end
    
    _G.LYNZKAToggle = {
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
            buttonFrame.Position = UDim2.new(0, x or 15, 0, y or 80)
        end
    }
    
    print("[LYNZKA HUB v3.6] ✅ Menu toggle siap!")
    print("💡 Klik tombol atau tekan '-' untuk toggle menu")
    print("💡 Drag tombol untuk memindahkan")
end)

-- ===================== SAVE CONFIG =====================
SaveManager:LoadAutoloadConfig()

print("[LYNZKA HUB v3.6] Loaded successfully!")
print("Click '-' to toggle menu (Shadow Style - Perfect!)")
print("Drag the '-' button to move it anywhere!")