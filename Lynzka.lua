--[[
    ╔══════════════════════════════════════════╗
    ║      🔥 LYNZKA HUB v3.6.8 🔥           ║
    ║   Shadow Style - Perfect Toggle        ║
    ║   ESP & AIMBOT FIXED!                 ║
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
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Do1x1PopupsLoop = false
local AntiSlow = false
local hubLoaded = false
local timeforonegen = 2.5
local infinitestamina = false
local ChargeSpeedLoop = false
local GuestChargeSpeed = 2.833
local timeAhead = 0.2
local hitboxmodificationEnabled = false
local MaxRange = 120
local timebetweenpuzzles = 3

-- ===================== SHADOW STYLE VARIABLES =====================
local godModeActive = false
local godModeConnection = nil
local wallbangActive = false
local wallbangConnection = nil
local SpeedLoop = nil
local nameProtectActive = false
local originalName = ""
local soundActive = false
local currentSound = nil

-- ===================== NOCLIP =====================
local noclipActive = false
local noclipConnection = nil

local function ToggleNoclip(state)
    noclipActive = state
    
    if noclipActive then
        if noclipConnection then
            pcall(function() noclipConnection:Disconnect() end)
            noclipConnection = nil
        end
        
        noclipConnection = RunService.Heartbeat:Connect(function()
            if not noclipActive then
                if noclipConnection then
                    pcall(function() noclipConnection:Disconnect() end)
                    noclipConnection = nil
                end
                return
            end
            
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                if hrp.Position.Y < 2 then
                    hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, 5, hrp.Position.Z))
                end
                
                local head = char:FindFirstChild("Head")
                if head and head.Position.Y < 0 then
                    hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, 5, hrp.Position.Z))
                end
            end)
        end)
        notify("🚫 NOCLIP ON - Ga bakal masuk tanah!", 2)
    else
        if noclipConnection then
            pcall(function() noclipConnection:Disconnect() end)
            noclipConnection = nil
        end
        notify("🚫 NOCLIP OFF", 2)
    end
end

-- ===================== SPEED HACK =====================
local speedHackActive = false
local speedHackValue = 5

-- ===================== INFINITE STAMINA =====================
local staminaLoop = nil

-- ===================== NOTIFICATION =====================
local function notify(text, duration)
    duration = duration or 3
    pcall(function()
        if Fluent and Fluent.Notify then
            Fluent:Notify({
                Title = "LYNZKA HUB",
                Content = text,
                Duration = duration
            })
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
                pcall(function()
                    TweenService:Create(notification, TweenInfo.new(0.4), {
                        Position = UDim2.new(0.5, -150, 1, 10)
                    }):Play()
                    task.delay(0.5, function() pcall(function() notification:Destroy() end) end)
                end)
            end)
        end
    end)
end

-- ===================== NAMEPROTECT =====================
local function ToggleNameProtect(state)
    nameProtectActive = state
    
    pcall(function()
        if state then
            originalName = LocalPlayer.Name
            
            local success, err = pcall(function()
                LocalPlayer.Name = "???"
            end)
            
            if not success then
                notify("⚠️ Gagal mengganti nama: " .. tostring(err), 3)
            end
            
            if Connections.NameProtectListener then
                pcall(function()
                    Connections.NameProtectListener:Disconnect()
                end)
                Connections.NameProtectListener = nil
            end
            
            Connections.NameProtectListener = LocalPlayer:GetPropertyChangedSignal("Name"):Connect(function()
                pcall(function()
                    if nameProtectActive and LocalPlayer.Name ~= "???" then
                        LocalPlayer.Name = "???"
                    end
                end)
            end)
            
            notify("🛡️ NameProtect ON - Namamu disembunyikan!", 3)
        else
            if Connections.NameProtectListener then
                pcall(function()
                    Connections.NameProtectListener:Disconnect()
                end)
                Connections.NameProtectListener = nil
            end
            
            if originalName and originalName ~= "" then
                pcall(function()
                    LocalPlayer.Name = originalName
                end)
            end
            
            notify("🛡️ NameProtect OFF - Namamu kembali!", 2)
        end
    end)
end

-- ===================== PLAY SOUND =====================
local function PlaySoundByID(id)
    pcall(function()
        if currentSound then
            pcall(function() currentSound:Destroy() end)
            currentSound = nil
        end
        
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(id)
        sound.Volume = 1
        sound.PlaybackSpeed = 1
        sound.Looped = false
        sound.Parent = Workspace
        
        sound:Play()
        currentSound = sound
        
        task.delay(10, function()
            pcall(function()
                if currentSound then
                    currentSound:Destroy()
                    currentSound = nil
                end
            end)
        end)
        
        notify("🔊 Playing Sound ID: " .. tostring(id), 2)
    end)
end

-- ===================== ESP SYSTEM - FIXED =====================
local EspObjects = {}
local TracerLines = {}
local DrawingPool = {}
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

-- CREATE DRAWING DENGAN AMAN
local function NewDrawing(type, props)
    local success, result = pcall(function()
        local d = Drawing.new(type)
        if d then
            for k, v in pairs(props) do
                d[k] = v
            end
            d.Visible = false
            table.insert(DrawingPool, d)
            return d
        end
        return nil
    end)
    if success then
        return result
    end
    return nil
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
    local success = pcall(function()
        local c = p.Character
        if not c then return 0, 100 end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h then return 0, 100 end
        return math.floor(h.Health), math.floor(h.MaxHealth)
    end)
    if success then
        return GetHealth(p)
    end
    return 0, 100
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
    local success = pcall(function()
        local c = p.Character
        if not c then return false end
        local h = c:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end)
    if success then
        return IsAlive(p)
    end
    return false
end

local function GetTeamColor(p)
    if espSettings.ShowTeamColor and p.Team then
        return p.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function CreateESP(player)
    pcall(function()
        EspObjects[player] = {
            top = NewDrawing("Line", {Thickness = 1, Color = Color3.fromRGB(255,255,255)}),
            bottom = NewDrawing("Line", {Thickness = 1, Color = Color3.fromRGB(255,255,255)}),
            left = NewDrawing("Line", {Thickness = 1, Color = Color3.fromRGB(255,255,255)}),
            right = NewDrawing("Line", {Thickness = 1, Color = Color3.fromRGB(255,255,255)}),
            name = NewDrawing("Text", {Size = 13, Center = true, Outline = true, Font = Drawing.Fonts.UI}),
            health = NewDrawing("Text", {Size = 12, Center = true, Outline = true, Font = Drawing.Fonts.UI}),
            distance = NewDrawing("Text", {Size = 11, Center = true, Outline = true, Font = Drawing.Fonts.UI}),
            healthBar = NewDrawing("Line", {Thickness = healthBarThickness, Color = Color3.fromRGB(0,255,0)})
        }
        TracerLines[player] = NewDrawing("Line", {Thickness = 2, Color = Color3.fromRGB(255, 0, 0)})
    end)
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
    if not obj then return end
    for _, d in pairs(obj) do
        if d then
            d.Visible = false
        end
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
    pcall(function()
        if player == LocalPlayer then
            if EspObjects[player] then HideESP(EspObjects[player]) end
            if TracerLines[player] then 
                pcall(function() TracerLines[player].Visible = false end)
            end
            return
        end
        
        if not EspObjects[player] then 
            CreateESP(player) 
        end
        
        local obj = EspObjects[player]
        if not obj then return end
        
        local tracer = TracerLines[player]
        
        if not espSettings.Enabled then
            HideESP(obj)
            if tracer then 
                pcall(function() tracer.Visible = false end)
            end
            return
        end
        
        local char = player.Character
        if not char then
            HideESP(obj)
            if tracer then 
                pcall(function() tracer.Visible = false end)
            end
            return
        end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            HideESP(obj)
            if tracer then 
                pcall(function() tracer.Visible = false end)
            end
            return
        end
        
        local bbox = GetBBox(char)
        if not bbox then
            HideESP(obj)
            if tracer then 
                pcall(function() tracer.Visible = false end)
            end
            return
        end
        
        local color = GetTeamColor(player)
        
        -- BOX
        if espSettings.ShowBox then
            pcall(function()
                if obj.top then
                    obj.top.From = Vector2.new(bbox.x0, bbox.y0)
                    obj.top.To = Vector2.new(bbox.x1, bbox.y0)
                    obj.top.Color = color
                    obj.top.Visible = true
                end
                if obj.bottom then
                    obj.bottom.From = Vector2.new(bbox.x0, bbox.y1)
                    obj.bottom.To = Vector2.new(bbox.x1, bbox.y1)
                    obj.bottom.Color = color
                    obj.bottom.Visible = true
                end
                if obj.left then
                    obj.left.From = Vector2.new(bbox.x0, bbox.y0)
                    obj.left.To = Vector2.new(bbox.x0, bbox.y1)
                    obj.left.Color = color
                    obj.left.Visible = true
                end
                if obj.right then
                    obj.right.From = Vector2.new(bbox.x1, bbox.y0)
                    obj.right.To = Vector2.new(bbox.x1, bbox.y1)
                    obj.right.Color = color
                    obj.right.Visible = true
                end
            end)
        else
            if obj.top then obj.top.Visible = false end
            if obj.bottom then obj.bottom.Visible = false end
            if obj.left then obj.left.Visible = false end
            if obj.right then obj.right.Visible = false end
        end
        
        -- NAMES
        if espSettings.ShowNames and obj.name then
            obj.name.Text = player.Name
            obj.name.Position = Vector2.new((bbox.x0 + bbox.x1) / 2, bbox.y0 - 15)
            obj.name.Color = color
            obj.name.Visible = true
        elseif obj.name then
            obj.name.Visible = false
        end
        
        -- HEALTH
        if espSettings.ShowHealth and obj.health then
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
        elseif obj.health then
            obj.health.Visible = false
        end
        
        -- HEALTH BAR
        if espSettings.ShowHealthBar and obj.healthBar then
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
        elseif obj.healthBar then
            obj.healthBar.Visible = false
        end
        
        -- DISTANCE
        if espSettings.ShowDistance and obj.distance then
            local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetPos = char:FindFirstChild("HumanoidRootPart")
            if myPos and targetPos then
                local distStuds = (myPos.Position - targetPos.Position).Magnitude
                local distMeters = distStuds * 0.28
                obj.distance.Text = string.format("%.1f m", distMeters)
                obj.distance.Position = Vector2.new((bbox.x0 + bbox.x1) / 2, bbox.y1 + 12)
                obj.distance.Color = Color3.fromRGB(255, 255, 0)
                obj.distance.Size = 11
                obj.distance.Visible = true
            else
                obj.distance.Visible = false
            end
        elseif obj.distance then
            obj.distance.Visible = false
        end
        
        -- TRACER
        if espSettings.ShowTracer and tracer and bbox then
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
    end)
end

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            UpdateESP(p)
        end
    end)
end)

-- ===================== AIMBOT - FIXED =====================
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
        Radius = aimbotFOV
    })
    if FOVCircle then
        FOVCircle.Visible = false
    end
end

local function GetBestTarget()
    if not aimbotEnabled then return nil end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestDist = nil, aimbotFOV
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        
        pcall(function()
            local char = p.Character
            if not char then return end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            
            if teamCheck and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then return end
            
            -- TARGET PARTS
            local targetParts = {}
            if hitboxMode == "Head" then
                local head = char:FindFirstChild("Head")
                if head then table.insert(targetParts, head) end
            elseif hitboxMode == "Neck" then
                local neck = char:FindFirstChild("Neck") or char:FindFirstChild("UpperTorso")
                if neck then table.insert(targetParts, neck) end
            elseif hitboxMode == "UpperTorso" then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
                if torso then table.insert(targetParts, torso) end
            elseif hitboxMode == "LowerTorso" then
                local torso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
                if torso then table.insert(targetParts, torso) end
            else
                local head = char:FindFirstChild("Head")
                if head then table.insert(targetParts, head) end
            end
            
            -- Jika tidak ada target parts, coba pake HumanoidRootPart
            if #targetParts == 0 then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then table.insert(targetParts, hrp) end
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
        end)
    end
    
    return best
end

local function EnableAimbot()
    if aimbotConnection then 
        pcall(function() aimbotConnection:Disconnect() end)
        aimbotConnection = nil
    end
    
    aimbotEnabled = true
    CreateFOVCircle()
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
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
    end)
    
    notify("🎯 Aimbot ON", 2)
end

local function DisableAimbot()
    aimbotEnabled = false
    
    if aimbotConnection then
        pcall(function() aimbotConnection:Disconnect() end)
        aimbotConnection = nil
    end
    
    if FOVCircle then
        pcall(function() 
            FOVCircle.Visible = false
            FOVCircle.Remove(FOVCircle)
        end)
        FOVCircle = nil
    end
    
    notify("🎯 Aimbot OFF", 2)
end

-- ===================== WALLBANG =====================
local wallbangState = false

local function ToggleWallbang()
    wallbangState = not wallbangState
    
    pcall(function()
        if wallbangState then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.CanCollide = false
                        end)
                    end
                end
            end
            
            if wallbangConnection then wallbangConnection:Disconnect() end
            wallbangConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if not wallbangState then
                        if wallbangConnection then
                            wallbangConnection:Disconnect()
                            wallbangConnection = nil
                        end
                        return
                    end
                    local char2 = LocalPlayer.Character
                    if not char2 then return end
                    for _, part in pairs(char2:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function()
                                part.CanCollide = false
                            end)
                        end
                    end
                end)
            end)
            notify("🧱 WALLBANG ON - Tembus dinding!", 3)
        else
            if wallbangConnection then
                wallbangConnection:Disconnect()
                wallbangConnection = nil
            end
            local char2 = LocalPlayer.Character
            if char2 then
                for _, part in pairs(char2:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.CanCollide = true
                        end)
                    end
                end
            end
            notify("🧱 WALLBANG OFF", 2)
        end
    end)
end

-- ===================== SPEED HACK =====================
local function ToggleSpeedHack(state)
    speedHackActive = state
    
    pcall(function()
        if speedHackActive then
            if SpeedLoop then SpeedLoop:Disconnect() end
            SpeedLoop = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if not speedHackActive then
                        if SpeedLoop then
                            SpeedLoop:Disconnect()
                            SpeedLoop = nil
                        end
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
    end)
end

-- ===================== INFINITE STAMINA =====================
local function toggleInfiniteStamina(state)
    infinitestamina = state
    pcall(function()
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
    end)
end

-- ===================== FUNCTIONS =====================
local Connections = {}

local function fireproximityprompt(Obj, Amount, Skip)
    pcall(function()
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
        end
    end)
end

local function generatorDoAll()
    pcall(function()
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
    end)
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
    pcall(function()
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
    end)
end

local function checkAndSetSlowStatus()
    pcall(function()
        if AntiSlow == false then return end
        local Character = LocalPlayer.Character
        if not Character then return end
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
    end)
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
        SubTitle = "v3.6.8 - ESP & Aimbot Fixed!",
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

    -- ===================== PLAYER TAB =====================
    
    Tabs.Player:AddToggle("Wallbang", {
        Title = "🧱 Wallbang",
        Description = "Tembus dinding",
        Default = false,
        Callback = function(state)
            pcall(function()
                if state ~= wallbangState then
                    ToggleWallbang()
                end
            end)
        end
    })

    Tabs.Player:AddToggle("Noclip", {
        Title = "🚫 Noclip (Anti Tanah)",
        Description = "CEGAH masuk tanah",
        Default = false,
        Callback = function(state)
            pcall(function()
                ToggleNoclip(state)
            end)
        end
    })

    Tabs.Player:AddToggle("SpeedHack", {
        Title = "💨 Speed Hack",
        Description = "Meningkatkan kecepatan jalan",
        Default = false,
        Callback = function(state)
            pcall(function()
                ToggleSpeedHack(state)
            end)
        end
    })

    Tabs.Player:AddSlider("SpeedHackValue", {
        Title = "Speed Hack Value",
        Description = "Atur kecepatan (1x - 20x)",
        Default = 5,
        Min = 1,
        Max = 20,
        Rounding = 0,
        Suffix = "x",
        Callback = function(value)
            pcall(function()
                speedHackValue = value
                if speedHackActive then
                    notify("💨 Speed: " .. value .. "x", 2)
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
            end)
        end
    })

    -- ===================== GAME TAB =====================
    Tabs.Game:AddToggle("InfiniteStamina", {
        Title = "♾️ Infinite Stamina",
        Description = "Stamina tidak akan habis",
        Default = false,
        Callback = function(state)
            pcall(function()
                toggleInfiniteStamina(state)
            end)
        end
    })

    Tabs.Game:AddToggle("AutoRejoinToggle", {
        Title = "🔄 Auto Rejoin on Kick",
        Description = "Otomatis join ulang saat di kick",
        Default = true,
        Callback = function(state)
            pcall(function()
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
            end)
        end
    })

    Tabs.Game:AddButton({
        Title = "🔁 Rejoin",
        Description = "Join ulang ke server yang sama",
        Callback = function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
                notify("🔄 Rejoining...", 2)
            end)
        end
    })

    -- ===================== ESP TAB - FIXED =====================
    Tabs.ESP:AddToggle("ESPToggle", {
        Title = "👁️ Enable ESP",
        Description = "Nyalakan ESP untuk melihat player",
        Default = false,
        Callback = function(state)
            pcall(function()
                espSettings.Enabled = state
                if not state then 
                    ClearDrawings() 
                end
                if state then
                    notify("👁️ ESP ON", 2)
                else
                    notify("👁️ ESP OFF", 2)
                end
            end)
        end
    })

    Tabs.ESP:AddToggle("ESPBox", {
        Title = "📦 Show Box",
        Description = "Tampilkan kotak di sekitar player",
        Default = true,
        Callback = function(state)
            pcall(function()
                espSettings.ShowBox = state
            end)
        end
    })

    Tabs.ESP:AddToggle("ESPNames", {
        Title = "📝 Show Names",
        Description = "Tampilkan nama player",
        Default = true,
        Callback = function(state)
            pcall(function()
                espSettings.ShowNames = state
            end)
        end
    })

    Tabs.ESP:AddToggle("ESPHealth", {
        Title = "❤️ Show Health",
        Description = "Tampilkan HP player",
        Default = true,
        Callback = function(state)
            pcall(function()
                espSettings.ShowHealth = state
            end)
        end
    })

    Tabs.ESP:AddToggle("ESPHealthBar", {
        Title = "📊 Show Health Bar",
        Description = "Tampilkan bar HP di samping player",
        Default = true,
        Callback = function(state)
            pcall(function()
                espSettings.ShowHealthBar = state
            end)
        end
    })

    Tabs.ESP:AddToggle("ESPDistance", {
        Title = "📏 Show Distance",
        Description = "Tampilkan jarak ke player",
        Default = true,
        Callback = function(state)
            pcall(function()
                espSettings.ShowDistance = state
            end)
        end
    })

    Tabs.ESP:AddToggle("ESPTracer", {
        Title = "〰️ Show Tracer",
        Description = "Tampilkan garis dari player ke bawah",
        Default = false,
        Callback = function(state)
            pcall(function()
                espSettings.ShowTracer = state
            end)
        end
    })

    Tabs.ESP:AddToggle("ESPTeamColor", {
        Title = "🎨 Team Colors",
        Description = "Warna ESP sesuai tim",
        Default = false,
        Callback = function(state)
            pcall(function()
                espSettings.ShowTeamColor = state
            end)
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
            pcall(function()
                UpdateHealthBarThickness(value)
                notify("📏 Health Bar: " .. value, 2)
            end)
        end
    })

    -- ===================== COMBAT TAB - FIXED =====================
    Tabs.Combat:AddToggle("AimbotToggle", {
        Title = "🎯 Aimbot",
        Description = "Auto aim ke musuh",
        Default = false,
        Callback = function(state)
            pcall(function()
                if state then 
                    EnableAimbot()
                else 
                    DisableAimbot()
                end
            end)
        end
    })

    Tabs.Combat:AddToggle("ShowFOV", {
        Title = "⭕ Show FOV",
        Description = "Tampilkan lingkaran FOV aimbot",
        Default = false,
        Callback = function(state)
            pcall(function()
                if FOVCircle then 
                    FOVCircle.Visible = state and aimbotEnabled
                    if state then
                        notify("⭕ FOV ON", 2)
                    else
                        notify("⭕ FOV OFF", 2)
                    end
                end
            end)
        end
    })

    Tabs.Combat:AddToggle("TeamCheck", {
        Title = "👥 Team Check",
        Description = "Tidak aim ke tim sendiri",
        Default = true,
        Callback = function(state)
            pcall(function()
                teamCheck = state
            end)
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
            pcall(function()
                aimbotFOV = value
                if FOVCircle then 
                    FOVCircle.Radius = value 
                end
                notify("🎯 FOV: " .. value, 2)
            end)
        end
    })

    Tabs.Combat:AddDropdown("HitboxMode", {
        Title = "🎯 Hitbox Mode",
        Description = "Pilih target body part",
        Values = {"Head", "Neck", "UpperTorso", "LowerTorso"},
        Multi = false,
        Default = "Head",
        Callback = function(value)
            pcall(function()
                hitboxMode = value
                notify("🎯 Hitbox: " .. value, 2)
            end)
        end
    })

    Tabs.Combat:AddToggle("ChanceAimbot", {
        Title = "🎲 Chance Aimbot",
        Description = "Aimbot dengan prediksi",
        Default = false,
        Callback = function(state)
            pcall(function()
                if state then
                    local aimbotConnection = RunService.Heartbeat:Connect(function()
                        pcall(function()
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
                    end)
                    Connections.ChanceAimbot = aimbotConnection
                    notify("🎲 Chance Aimbot ON", 2)
                else
                    if Connections.ChanceAimbot then
                        Connections.ChanceAimbot:Disconnect()
                        Connections.ChanceAimbot = nil
                        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then humanoid.AutoRotate = true end
                    end
                    notify("🎲 Chance Aimbot OFF", 2)
                end
            end)
        end
    })

    Tabs.Combat:AddSlider("ChanceAimbotPredictionValue", {
        Title = "🎲 Prediction",
        Description = "Nilai prediksi aimbot (0.1 - 2)",
        Default = 0.2,
        Min = 0.1,
        Max = 2,
        Rounding = 1,
        Callback = function(value)
            pcall(function()
                timeAhead = value
                notify("📊 Prediction: " .. value, 2)
            end)
        end
    })

    -- ===================== MISC TAB =====================
    Tabs.Misc:AddButton({
        Title = "⚡ Infinite Yield",
        Description = "Load admin command",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
                notify("⚡ Infinite Yield Loaded!", 2)
            end)
        end
    })

    Tabs.Misc:AddToggle("NameProtect", {
        Title = "🛡️ NameProtect",
        Description = "Sembunyikan NAMA KAMU sendiri",
        Default = false,
        Callback = function(state)
            pcall(function()
                ToggleNameProtect(state)
            end)
        end
    })

    Tabs.Misc:AddButton({
        Title = "🚀 FPS Boost",
        Description = "Optimasi performa",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/NumanTF3/roblox-fpsboost-script/refs/heads/main/main.lua'))()
                notify("🚀 FPS Boost Applied!", 2)
            end)
        end
    })

    Tabs.Misc:AddInput("PlaySoundByID", {
        Title = "🔊 Play Sound",
        Description = "Masukkan ID sound Roblox (Volume MAX)",
        Placeholder = "Enter Sound ID",
        Numeric = true,
        Callback = function(input)
            pcall(function()
                local id = tonumber(input)
                if id then
                    PlaySoundByID(id)
                else
                    notify("❌ Masukkan ID yang valid!", 2)
                end
            end)
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

    -- ===================== BLATANT TAB =====================
    Tabs.Blatant:AddButton({
        Title = "⚡ Do All Generators",
        Description = "Perbaiki semua generator",
        Callback = function()
            pcall(function()
                generatorDoAll()
                notify("⚡ Doing all generators!", 2)
            end)
        end
    })

    Tabs.Blatant:AddSlider("GenSpeedValue", {
        Title = "⚡ Generator Speed",
        Description = "Kecepatan generator (3 - 10)",
        Default = 3,
        Min = 3,
        Max = 10,
        Rounding = 1,
        Callback = function(value)
            pcall(function()
                timebetweenpuzzles = value
                notify("⚡ Gen Speed: " .. value, 2)
            end)
        end
    })

    -- ===================== GUEST SETTINGS TAB =====================
    Tabs.GuestSettings:AddParagraph({
        Title = "🍃 Guest 1337 Settings",
        Content = "Fitur khusus untuk Guest 1337"
    })

    Tabs.GuestSettings:AddToggle("ChargeSpeedToggle", {
        Title = "⚡ Custom Charge Speed",
        Description = "Aktifkan kecepatan charge kustom",
        Default = false,
        Callback = function(state)
            pcall(function()
                ChargeSpeedLoop = state
                if state then
                    notify("⚡ Charge Speed ON", 2)
                else
                    notify("⚡ Charge Speed OFF", 2)
                end
            end)
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
            pcall(function()
                GuestChargeSpeed = value
                notify("⚡ Charge: " .. value, 2)
            end)
        end
    })

    Tabs.GuestSettings:AddToggle("GuestSettingsToggle", {
        Title = "🛡️ Auto Block",
        Description = "Auto block otomatis",
        Default = false,
        Callback = function(value)
            pcall(function()
                GuestSettingsOn = value
                if value then
                    notify("🛡️ Auto Block ON", 2)
                else
                    notify("🛡️ Auto Block OFF", 2)
                end
            end)
        end
    })

    Tabs.GuestSettings:AddToggle("StrictRangeToggle", {
        Title = "🎯 Strict Range",
        Description = "Hanya block dalam range ketat",
        Default = false,
        Callback = function(value)
            pcall(function()
                strictRangeOn = value
            end)
        end
    })

    Tabs.GuestSettings:AddDropdown("FacingCheckDropdown", {
        Title = "👀 Facing Check",
        Description = "Loose atau Strict facing",
        Values = {"Loose", "Strict"},
        Multi = false,
        Default = "Loose",
        Callback = function(option)
            pcall(function()
                looseFacing = option == "Loose"
            end)
        end
    })

    Tabs.GuestSettings:AddInput("DetectionRangeInput", {
        Title = "📏 Detection Range",
        Description = "Jarak deteksi Guest",
        Placeholder = "18",
        Numeric = true,
        Callback = function(text)
            pcall(function()
                detectionRange = tonumber(text) or detectionRange
                notify("📏 Range: " .. (tonumber(text) or detectionRange), 2)
            end)
        end
    })

    Tabs.GuestSettings:AddToggle("BlockTPToggle", {
        Title = "📍 Block TP",
        Description = "Teleport saat block",
        Default = false,
        Callback = function(value)
            pcall(function()
                blockTPEnabled = value
            end)
        end
    })

    Tabs.GuestSettings:AddToggle("PredictiveBlockToggle", {
        Title = "🔮 Predictive Auto Block",
        Description = "Auto block prediktif",
        Default = false,
        Callback = function(value)
            pcall(function()
                predictiveBlockOn = value
            end)
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
            pcall(function()
                edgeKillerDelay = value
                notify("⏱️ Delay: " .. value, 2)
            end)
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
            pcall(function()
                flingPunchOn = value
            end)
        end
    })

    Tabs.GuestSettings:AddToggle("PunchAimbotToggle", {
        Title = "🎯 Punch Aimbot",
        Description = "Aimbot saat punch",
        Default = false,
        Callback = function(value)
            pcall(function()
                aimPunch = value
            end)
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
            pcall(function()
                predictionValue = value
                notify("📊 Prediction: " .. value, 2)
            end)
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
            pcall(function()
                flingPower = value
                notify("💥 Power: " .. value, 2)
            end)
        end
    })

    -- ===================== CUSTOM ANIMATIONS TAB =====================
    Tabs.CustomAnimations:AddInput("CustomBlockAnim", {
        Title = "🎭 Custom Block Animation",
        Description = "Masukkan ID animasi block",
        Placeholder = "AnimationId",
        Callback = function(text)
            pcall(function()
                if text and text ~= "" then
                    customBlockAnimId = text
                    notify("🎭 Block ID: " .. text, 2)
                end
            end)
        end
    })

    Tabs.CustomAnimations:AddToggle("EnableCustomBlockAnim", {
        Title = "🎭 Enable Custom Block",
        Description = "Aktifkan animasi block kustom",
        Default = false,
        Callback = function(value)
            pcall(function()
                customBlockEnabled = value
                if value and customBlockAnimId ~= "" then
                    notify("🎭 Custom Block ON - ID: " .. customBlockAnimId, 2)
                elseif value then
                    notify("⚠️ Masukkan ID animasi dulu!", 2)
                else
                    notify("🎭 Custom Block OFF", 2)
                end
            end)
        end
    })

    Tabs.CustomAnimations:AddInput("CustomPunchAnim", {
        Title = "🎭 Custom Punch Animation",
        Description = "Masukkan ID animasi punch",
        Placeholder = "AnimationId",
        Callback = function(text)
            pcall(function()
                if text and text ~= "" then
                    customPunchAnimId = text
                    notify("🎭 Punch ID: " .. text, 2)
                end
            end)
        end
    })

    Tabs.CustomAnimations:AddToggle("EnableCustomPunchAnim", {
        Title = "🎭 Enable Custom Punch",
        Description = "Aktifkan animasi punch kustom",
        Default = false,
        Callback = function(value)
            pcall(function()
                customPunchEnabled = value
                if value and customPunchAnimId ~= "" then
                    notify("🎭 Custom Punch ON - ID: " .. customPunchAnimId, 2)
                elseif value then
                    notify("⚠️ Masukkan ID animasi dulu!", 2)
                else
                    notify("🎭 Custom Punch OFF", 2)
                end
            end)
        end
    })

    Tabs.CustomAnimations:AddInput("ChargeAnimID", {
        Title = "🎭 Charge Animation ID",
        Description = "Masukkan ID animasi charge",
        Placeholder = "Animation ID",
        Callback = function(input)
            pcall(function()
                if input and input ~= "" then
                    customChargeAnimId = input
                    notify("🎭 Charge ID: " .. input, 2)
                end
            end)
        end
    })

    Tabs.CustomAnimations:AddToggle("EnableCustomChargeAnim", {
        Title = "🎭 Custom Charge Animation",
        Description = "Aktifkan animasi charge kustom",
        Default = false,
        Callback = function(value)
            pcall(function()
                customChargeEnabled = value
                if value and customChargeAnimId ~= "" then
                    notify("🎭 Custom Charge ON - ID: " .. customChargeAnimId, 2)
                elseif value then
                    notify("⚠️ Masukkan ID animasi dulu!", 2)
                else
                    notify("🎭 Custom Charge OFF", 2)
                end
            end)
        end
    })

    -- ===================== SETTINGS TAB =====================
    Tabs.Settings:AddButton({
        Title = "📐 Center GUI",
        Description = "Posisikan menu di tengah",
        Callback = function()
            pcall(function()
                if Window and Window.Root then
                    Window.Root.Position = UDim2.new(0.5, -290, 0.5, -230)
                    notify("📐 GUI Centered!", 2)
                end
            end)
        end
    })

    -- ===================== FINALIZE =====================
    Window:SelectTab("Player")
    notify("🔥 LYNZKA HUB v3.6.8 - ESP & Aimbot Fixed!", 4)

    hubLoaded = true
end

-- ===================== AUTO REJOIN =====================
local toggles = { AutoRejoinOnKick = true }
pcall(function()
    if toggles.AutoRejoinOnKick and not Connections.AutoRejoin then
        Connections.AutoRejoin = GuiService.ErrorMessageChanged:Connect(function(msg)
            if msg and msg ~= "" then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end
        end)
    end
end)

-- ===================== CHARGE SPEED LOOP =====================
RunService.Stepped:Connect(function()
    pcall(function()
        if ChargeSpeedLoop then
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local speedMultipliers = character:FindFirstChild("SpeedMultipliers")
            local mult = speedMultipliers and speedMultipliers:FindFirstChild("Guest1337Charge")
            if mult and GuestChargeSpeed ~= nil then
                mult.Value = GuestChargeSpeed
            end
        end
    end)
end)

-- ===================== ANTI SLOW =====================
RunService.RenderStepped:Connect(function()
    pcall(function()
        if AntiSlow then
            checkAndSetSlowStatus()
            enforceMultipliers()
        end
    end)
end)

-- ===================== CHAT ENABLER =====================
RunService.Heartbeat:Connect(function()
    pcall(function()
        chatWindow.Enabled = true
    end)
end)

-- ===================== TOMBOL MENU =====================
task.spawn(function()
    local waitCount = 0
    while not Window or not Window.Root and waitCount < 50 do
        task.wait(0.2)
        waitCount = waitCount + 1
    end
    
    if not Window or not Window.Root then
        print("[LYNZKA] Gagal menemukan Window.Root!")
        return
    end
    
    local oldGui = CoreGui:FindFirstChild("LYNZKAToggleGui")
    if oldGui then oldGui:Destroy() end
    
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "LYNZKAToggleGui"
    toggleGui.ResetOnSpawn = false
    toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleGui.Parent = CoreGui
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ToggleFrame"
    buttonFrame.Size = UDim2.new(0, 44, 0, 44)
    buttonFrame.Position = UDim2.new(0, 12, 0, 80)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    buttonFrame.BackgroundTransparency = 0
    buttonFrame.BorderSizePixel = 0
    buttonFrame.ClipsDescendants = false
    buttonFrame.ZIndex = 9999
    buttonFrame.Parent = toggleGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = buttonFrame
    
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    glow.BackgroundTransparency = 0.7
    glow.BorderSizePixel = 0
    glow.ZIndex = -1
    glow.Parent = buttonFrame
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 16)
    glowCorner.Parent = glow
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1.2, 0, 1.2, 0)
    toggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    toggleButton.BackgroundTransparency = 0
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "−"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 28
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.ZIndex = 9999
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = buttonFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = toggleButton
    
    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 80, 0, 20)
    tooltip.Position = UDim2.new(0.5, -40, 1, 6)
    tooltip.AnchorPoint = Vector2.new(0.5, 0)
    tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    tooltip.BackgroundTransparency = 0.3
    tooltip.BorderSizePixel = 0
    tooltip.Text = "Menu"
    tooltip.TextColor3 = Color3.fromRGB(200, 200, 255)
    tooltip.TextSize = 11
    tooltip.Font = Enum.Font.GothamMedium
    tooltip.Visible = false
    tooltip.ZIndex = 9999
    tooltip.Parent = buttonFrame
    local tooltipCorner = Instance.new("UICorner")
    tooltipCorner.CornerRadius = UDim.new(0, 4)
    tooltipCorner.Parent = tooltip
    
    local menuVisible = true
    
    local function toggleMenu()
        menuVisible = not menuVisible
        
        pcall(function()
            local fluentGui = Window.Root.Parent
            if fluentGui and fluentGui:IsA("ScreenGui") then
                fluentGui.Enabled = menuVisible
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
    
    local drag = {
        dragging = false,
        startPos = nil,
        startMouse = nil,
        isDragging = false
    }
    
    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag.dragging = true
            drag.startPos = buttonFrame.Position
            drag.startMouse = input.Position
            drag.isDragging = false
        end
    end)
    
    toggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag.dragging = false
            task.wait(0.05)
            drag.isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - drag.startMouse
            if delta.Magnitude > 3 then
                drag.isDragging = true
            end
            
            if drag.isDragging then
                local newX = drag.startPos.X.Offset + delta.X
                local newY = drag.startPos.Y.Offset + delta.Y
                
                local screenSize = GuiService:GetScreenSize()
                newX = math.clamp(newX, 0, screenSize.X - 44)
                newY = math.clamp(newY, 0, screenSize.Y - 44)
                
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
        if not drag.isDragging then
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
            buttonFrame.Position = UDim2.new(0, x or 12, 0, y or 80)
        end
    }
    
    print("[LYNZKA HUB] ✅ Tombol menu siap!")
end)

-- ===================== SAVE CONFIG =====================
if SaveManager then
    pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
end

print("[LYNZKA HUB v3.6.8] ✅ Loaded successfully!")
print("💡 Klik '-' atau tekan '-' di keyboard untuk toggle menu")
print("🎯 ESP & Aimbot FIXED!")