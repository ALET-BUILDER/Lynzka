--[[
    ╔══════════════════════════════════════════╗
    ║      🔥 LYNZKA HUB - DESYNC 🔥          ║
    ║   Fake Lag / Desync Effect              ║
    ║   Hanya untuk Setting + Desync          ║
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

local hubLoaded = false

-- ===================== DESYNC / FAKE LAG VARIABLES =====================
local desyncActive = false
local desyncConnection = nil
local desyncLoop = nil
local desyncMode = "Stutter" -- Stutter, Teleport, Float
local desyncIntensity = 2
local originalNetworkOwnership = nil

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

-- ===================== DESYNC / FAKE LAG CORE =====================
local function StartDesync()
    if desyncActive then return end
    desyncActive = true
    
    pcall(function()
        -- Matikan koneksi sebelumnya jika ada
        if desyncConnection then
            desyncConnection:Disconnect()
            desyncConnection = nil
        end
        if desyncLoop then
            task.cancel(desyncLoop)
            desyncLoop = nil
        end
        
        notify("🌀 Desync/Fake Lag ON - Mode: " .. desyncMode, 3)
        
        -- ===== METHOD 1: NETWORK OWNERSHIP MANIPULATION =====
        -- Ini membuat server mengira karakter kita di posisi berbeda
        desyncConnection = RunService.Heartbeat:Connect(function()
            if not desyncActive then
                if desyncConnection then
                    desyncConnection:Disconnect()
                    desyncConnection = nil
                end
                return
            end
            
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                if desyncMode == "Stutter" then
                    -- Stutter: Gerakan tersendat-sendat di mata orang lain
                    local randomOffset = Vector3.new(
                        math.random(-desyncIntensity, desyncIntensity) * 0.5,
                        0,
                        math.random(-desyncIntensity, desyncIntensity) * 0.5
                    )
                    
                    -- Kirim posisi yang sedikit berbeda ke server
                    -- Dengan mengubah CFrame secara cepat, server akan mendeteksi perubahan posisi yang tidak stabil
                    if math.random(1, 3) == 1 then
                        hrp.CFrame = hrp.CFrame + randomOffset
                    end
                    
                elseif desyncMode == "Teleport" then
                    -- Teleport: Karakter seperti teleport di mata orang lain
                    if math.random(1, 5) == 1 then
                        local teleportOffset = Vector3.new(
                            math.random(-desyncIntensity * 2, desyncIntensity * 2),
                            math.random(-1, 1) * 0.5,
                            math.random(-desyncIntensity * 2, desyncIntensity * 2)
                        )
                        hrp.CFrame = hrp.CFrame + teleportOffset
                    end
                    
                elseif desyncMode == "Float" then
                    -- Float: Karakter seperti melayang/terapung
                    local floatOffset = Vector3.new(
                        math.sin(tick() * 2) * desyncIntensity * 0.3,
                        math.sin(tick() * 1.5) * desyncIntensity * 0.2 + 0.5,
                        math.cos(tick() * 2) * desyncIntensity * 0.3
                    )
                    hrp.CFrame = hrp.CFrame + floatOffset
                end
            end)
        end)
        
        -- ===== METHOD 2: CONSTANT POSITION RESYNC =====
        -- Ini membuat server terus menerus mensync ulang posisi kita
        desyncLoop = task.spawn(function()
            local lastPos = nil
            while desyncActive do
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then 
                        task.wait(0.5)
                        return 
                    end
                    
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then 
                        task.wait(0.5)
                        return 
                    end
                    
                    -- Simpan posisi asli
                    local currentPos = hrp.Position
                    
                    -- Jika kita bergerak, kirim posisi yang sedikit berbeda ke server
                    if lastPos and (currentPos - lastPos).Magnitude > 0.5 then
                        -- Manipulasi posisi yang dilaporkan ke server
                        local fakePos = currentPos + Vector3.new(
                            math.random(-desyncIntensity, desyncIntensity) * 0.3,
                            math.random(-1, 1) * 0.2,
                            math.random(-desyncIntensity, desyncIntensity) * 0.3
                        )
                        
                        -- Set posisi sementara untuk membuat server bingung
                        hrp.CFrame = CFrame.new(fakePos, fakePos + hrp.CFrame.LookVector)
                    end
                    
                    lastPos = hrp.Position
                end)
                task.wait(0.05) -- Update sangat cepat untuk efek desync maksimal
            end
        end)
        
    end)
end

local function StopDesync()
    if not desyncActive then return end
    desyncActive = false
    
    pcall(function()
        if desyncConnection then
            desyncConnection:Disconnect()
            desyncConnection = nil
        end
        if desyncLoop then
            task.cancel(desyncLoop)
            desyncLoop = nil
        end
        
        notify("🌀 Desync/Fake Lag OFF", 2)
    end)
end

local function ToggleDesync(state)
    if state then
        StartDesync()
    else
        StopDesync()
    end
end

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
        Title = "LYNZKA HUB - DESYNC",
        SubTitle = "Fake Lag Edition",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Theme = "Dark",
        MinimizeKeyBind = nil
    })

    Tabs = {
        Desync = Window:AddTab({ Title = "Desync/Fake Lag", Icon = "lucide-wifi" }),
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

    -- ===================== DESYNC TAB =====================
    Tabs.Desync:AddParagraph({
        Title = "🌀 Desync / Fake Lag",
        Content = "Buat karakter terlihat lag/desync di pandangan orang lain\nSementara di sisi Anda tetap normal!"
    })

    Tabs.Desync:AddToggle("DesyncToggle", {
        Title = "🌀 Desync / Fake Lag",
        Description = "Aktifkan efek desync (orang lain lihat kamu lag)",
        Default = false,
        Callback = function(state)
            pcall(function()
                ToggleDesync(state)
            end)
        end
    })

    Tabs.Desync:AddDropdown("DesyncMode", {
        Title = "🎯 Desync Mode",
        Description = "Pilih jenis efek desync",
        Values = {"Stutter", "Teleport", "Float"},
        Multi = false,
        Default = "Stutter",
        Callback = function(value)
            pcall(function()
                desyncMode = value
                if desyncActive then
                    -- Restart dengan mode baru
                    StopDesync()
                    task.wait(0.1)
                    StartDesync()
                end
                notify("🌀 Mode: " .. value, 2)
            end)
        end
    })

    Tabs.Desync:AddSlider("DesyncIntensity", {
        Title = "⚡ Desync Intensity",
        Description = "Seberapa kuat efek desync (1 - 10)",
        Default = 2,
        Min = 1,
        Max = 10,
        Rounding = 0,
        Callback = function(value)
            pcall(function()
                desyncIntensity = value
                if desyncActive then
                    -- Restart dengan intensity baru
                    StopDesync()
                    task.wait(0.1)
                    StartDesync()
                end
                notify("⚡ Intensity: " .. value, 2)
            end)
        end
    })

    Tabs.Desync:AddButton({
        Title = "🔄 Reset Desync",
        Description = "Matikan dan nyalakan ulang desync",
        Callback = function()
            pcall(function()
                if desyncActive then
                    StopDesync()
                    task.wait(0.3)
                    StartDesync()
                    notify("🔄 Desync Reset!", 2)
                else
                    notify("❌ Desync belum aktif!", 2)
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

    Tabs.Settings:AddButton({
        Title = "🔁 Rejoin",
        Description = "Join ulang ke server yang sama",
        Callback = function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
                notify("🔄 Rejoining...", 2)
            end)
        end
    })

    Tabs.Settings:AddButton({
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

    Tabs.Settings:AddButton({
        Title = "⚡ Infinite Yield",
        Description = "Load admin command",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
                notify("⚡ Infinite Yield Loaded!", 2)
            end)
        end
    })

    Tabs.Settings:AddButton({
        Title = "🚀 FPS Boost",
        Description = "Optimasi performa",
        Callback = function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/NumanTF3/roblox-fpsboost-script/refs/heads/main/main.lua'))()
                notify("🚀 FPS Boost Applied!", 2)
            end)
        end
    })

    -- ===================== FINALIZE =====================
    Window:SelectTab("Desync")
    notify("🔥 LYNZKA HUB - DESYNC EDITION LOADED!", 4)
    notify("🌀 Aktifkan Desync untuk efek fake lag!", 3)

    hubLoaded = true
end

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

print("[LYNZKA HUB - DESYNC] ✅ Loaded successfully!")
print("🌀 Aktifkan Desync untuk efek fake lag di pandangan orang lain!")
print("💡 Klik '-' atau tekan '-' di keyboard untuk toggle menu")