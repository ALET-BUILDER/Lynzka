--[[
    ╔══════════════════════════════════════════╗
    ║   🌱 GARDEN SPAWNER v11.0 ULTIMATE     ║
    ║   REAL PETS + PLANTING SYSTEM          ║
    ║   KHUSUS Grow a Garden Roblox          ║
    ║   Pet | Plants | Settings             ║
    ║   KEY: - / + buka tutup               ║
    ╚══════════════════════════════════════════╝
]]

-- ===================== SERVICES =====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- ===================== DATA PET (LENGKAP DARI GAG) =====================
local PETS = {
    Common = {"Bunny", "Dog", "Golden Lab", "Starfish", "Crab", "Seagull", "Robin"},
    Uncommon = {"Black Bunny", "Cat", "Chicken", "Deer", "Bee", "Shiba Inu"},
    Rare = {"Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey", "Flamingo", "Toucan", "Sea Turtle", "Orangutan", "Seal", "Hedgehog", "Kiwi"},
    Legendary = {"Cow", "Silver Monkey", "Polar Bear", "Sea Otter", "Turtle", "Panda", "Frog", "Moon Cat", "Blood Owl"},
    Mythical = {"Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox", "Caterpillar", "Snail", "Echo Frog", "Chicken Zombie", "Bear Bee", "Butterfly", "Golem"},
    Divine = {"Dragonfly", "Night Owl", "Raccoon", "Queen Bee", "Disco Bee", "T-Rex", "Spinosaurus", "French Fry Ferret", "Lobster Thermidor", "Golden Goose"},
    Prismatic = {"Kitsune", "Corrupted Kitsune", "Burning Bud", "Ember Lily", "Bone Blossom"}
}

local PLANTS = {
    Common = {"Carrot", "Strawberry", "Artichoke", "Orange Tulip", "Rose"},
    Uncommon = {"Lavender", "Daffodil", "Blueberry", "Banana"},
    Rare = {"Bee Balm", "Dandelion", "Peace Lily", "Cactus", "Avocado"},
    Legendary = {"Lilac", "Moonflower", "Broccoli", "Rafflesia", "Dragon Fruit", "Bamboo", "Mango"},
    Mythical = {"Purple Dahlia", "Pink Lily", "Briar Rose", "Lily of the Valley", "Pineapple", "Durian", "Papaya"},
    Divine = {"Sunflower", "Cherry Blossom", "Lotus", "Moon Blossom", "Cherry"},
    Prismatic = {"Burning Bud", "Ember Lily", "Bone Blossom"}
}

-- ===================== NOTIFICATION =====================
local function notify(text, duration)
    duration = duration or 3
    pcall(function()
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 400, 0, 40)
        notification.Position = UDim2.new(0.5, -200, 1, -50)
        notification.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        notification.BackgroundTransparency = 0
        notification.TextColor3 = Color3.fromRGB(100, 255, 150)
        notification.Font = Enum.Font.GothamBold
        notification.TextSize = 14
        notification.Text = "🌱 " .. text
        notification.Parent = CoreGui
        Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 8)
        TweenService:Create(notification, TweenInfo.new(0.5), {
            Position = UDim2.new(0.5, -200, 1, -60)
        }):Play()
        task.delay(duration, function()
            pcall(function()
                TweenService:Create(notification, TweenInfo.new(0.4), {
                    Position = UDim2.new(0.5, -200, 1, 10)
                }):Play()
                task.delay(0.5, function() pcall(function() notification:Destroy() end) end)
            end)
        end)
    end)
end

-- ===================== DATA GERAKAN HEWAN =====================
local FLYING_PETS = {"Dragonfly", "Bee", "Queen Bee", "Disco Bee", "Bear Bee", "Butterfly", "Night Owl", "Robin", "Seagull", "Blood Owl", "Flamingo", "Toucan", "Pterodactyl", "Flying"}
local SWIMMING_PETS = {"Sea Turtle", "Sea Otter", "Starfish", "Crab", "Seal", "Lobster Thermidor"}

-- ===================== SPAWN VISUAL =====================
local spawnedObjects = {}
local petMovements = {}

local function isFlying(petName)
    for _, name in ipairs(FLYING_PETS) do
        if petName:lower():find(name:lower()) then
            return true
        end
    end
    return false
end

local function isSwimming(petName)
    for _, name in ipairs(SWIMMING_PETS) do
        if petName:lower():find(name:lower()) then
            return true
        end
    end
    return false
end

-- ===================== CARI MODEL PET ASLI DARI GAME =====================
local function findPetModel(petName)
    local searchLocations = {Workspace, ReplicatedStorage, Lighting}
    
    -- Cari model yang namanya persis atau mengandung nama pet
    for _, location in ipairs(searchLocations) do
        for _, model in ipairs(location:GetDescendants()) do
            if model:IsA("Model") then
                local modelName = model.Name:lower()
                local petLower = petName:lower()
                
                -- Cek apakah nama model mengandung nama pet (case insensitive)
                if modelName:find(petLower) or petLower:find(modelName) then
                    return model
                end
            end
        end
    end
    
    -- Cari model yang mirip (fallback)
    for _, location in ipairs(searchLocations) do
        for _, model in ipairs(location:GetDescendants()) do
            if model:IsA("Model") then
                local modelName = model.Name:lower()
                -- Cek kata kunci umum
                if modelName:find("pet") or modelName:find("animal") or 
                   modelName:find("rabbit") or modelName:find("bunny") or
                   modelName:find("dog") or modelName:find("cat") or
                   modelName:find("cow") or modelName:find("fox") or
                   modelName:find("bear") or modelName:find("bird") or
                   modelName:find("turtle") or modelName:find("monkey") then
                    return model
                end
            end
        end
    end
    
    return nil
end

-- ===================== SPAWN PET SESUAI DARI GAG =====================
local function spawnRealPet(itemName, itemType)
    notify("🐾 Spawning " .. itemName .. "...", 2)
    
    local char = LocalPlayer.Character
    if not char then 
        notify("❌ Character not found!", 2)
        return 
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        notify("❌ HumanoidRootPart not found!", 2)
        return 
    end
    
    local spawnPos = hrp.Position + Vector3.new(0, 0.5, 0) + hrp.CFrame.LookVector * 8 + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
    
    -- ========== CARI MODEL PET ASLI DARI GAME ==========
    local foundModel = findPetModel(itemName)
    
    local petObject
    
    if foundModel then
        -- CLONE MODEL ASLI DARI GAME
        petObject = foundModel:Clone()
        petObject.Parent = Workspace
        petObject:SetPrimaryPartCFrame(CFrame.new(spawnPos))
        
        -- HAPUS SCRIPT YANG BISA BIKIN ERROR
        for _, script in ipairs(petObject:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
                script:Destroy()
            end
        end
        
        -- Bersihin semua weld/anchor biar bisa digerakin
        for _, part in ipairs(petObject:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
                part.CanCollide = true
            end
            if part:IsA("Weld") or part:IsA("Motor6D") then
                part:Destroy()
            end
        end
        
        -- Cari atau buat HumanoidRootPart
        local rootPart = petObject:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            rootPart = Instance.new("Part")
            rootPart.Name = "HumanoidRootPart"
            rootPart.Size = Vector3.new(2, 1, 2)
            rootPart.Position = spawnPos
            rootPart.Anchored = false
            rootPart.CanCollide = true
            rootPart.Transparency = 1
            rootPart.Parent = petObject
        end
        
        -- Cari atau buat Humanoid
        local hum = petObject:FindFirstChildOfClass("Humanoid")
        if not hum then
            hum = Instance.new("Humanoid")
            hum.Name = "Humanoid"
            hum.Parent = petObject
            hum.MaxHealth = 100
            hum.Health = 100
            hum.WalkSpeed = 8
        end
        
        -- Set posisi awal
        petObject:SetPrimaryPartCFrame(CFrame.new(spawnPos))
        
        notify("✅ Found model: " .. foundModel.Name, 2)
        
    else
        notify("⚠️ Model not found for: " .. itemName .. ", creating fallback", 2)
        
        -- FALLBACK: BUAT 3D SEDERHANA JIKA MODEL TIDAK DITEMUKAN
        petObject = Instance.new("Model")
        petObject.Name = itemName
        petObject.Parent = Workspace
        
        local bodyColor = Color3.fromRGB(150, 120, 100)
        local headColor = Color3.fromRGB(180, 150, 130)
        local legColor = Color3.fromRGB(120, 90, 70)
        
        -- Body
        local body = Instance.new("Part")
        body.Name = "Body"
        body.Size = Vector3.new(2, 1.5, 3)
        body.Position = spawnPos
        body.Anchored = false
        body.CanCollide = true
        body.Color = bodyColor
        body.Parent = petObject
        
        -- Head
        local head = Instance.new("Part")
        head.Name = "Head"
        head.Size = Vector3.new(1.5, 1.2, 1.5)
        head.Position = spawnPos + Vector3.new(0, 1.5, 1.8)
        head.Anchored = false
        head.CanCollide = true
        head.Color = headColor
        head.Parent = petObject
        
        -- Humanoid
        local hum = Instance.new("Humanoid")
        hum.Name = "Humanoid"
        hum.Parent = petObject
        hum.MaxHealth = 100
        hum.Health = 100
        hum.WalkSpeed = 5
        
        local root = Instance.new("Part")
        root.Name = "HumanoidRootPart"
        root.Size = Vector3.new(2, 1, 2)
        root.Position = spawnPos
        root.Anchored = false
        root.CanCollide = true
        root.Transparency = 1
        root.Parent = petObject
    end
    
    -- ========== ANIMASI GERAK ==========
    local flying = isFlying(itemName)
    local swimming = isSwimming(itemName)
    
    local petInfo = {
        object = petObject,
        startPos = spawnPos,
        radius = 3 + math.random(0, 3),
        speed = 0.5 + math.random() * 1,
        angle = math.random() * 360,
        time = 0,
        isMoving = true,
        type = itemType,
        name = itemName,
        flying = flying,
        swimming = swimming,
        moveConnection = nil
    }
    
    table.insert(spawnedObjects, petObject)
    table.insert(petMovements, petInfo)
    
    -- MOVEMENT LOOP
    local moveConnection
    moveConnection = RunService.Heartbeat:Connect(function(dt)
        petInfo.time = petInfo.time + dt
        
        if petInfo.isMoving then
            petInfo.angle = petInfo.angle + dt * petInfo.speed * 30
            
            local rad = math.rad(petInfo.angle)
            local x = petInfo.startPos.X + math.cos(rad) * petInfo.radius
            local z = petInfo.startPos.Z + math.sin(rad) * petInfo.radius
            
            local y
            if petInfo.flying then
                y = petInfo.startPos.Y + 3 + math.sin(petInfo.time * 1.5) * 1.5
            elseif petInfo.swimming then
                y = petInfo.startPos.Y + 0.3 + math.sin(petInfo.time * 1.5) * 0.2
            else
                y = petInfo.startPos.Y + 0.3 + math.sin(petInfo.time * 3) * 0.1
            end
            
            local newPos = Vector3.new(x, y, z)
            local lookDir = Vector3.new(-math.sin(rad), 0, math.cos(rad))
            
            local rootPart = petObject:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(newPos, newPos + lookDir)
            else
                pcall(function()
                    petObject:SetPrimaryPartCFrame(CFrame.new(newPos, newPos + lookDir))
                end)
            end
        end
    end)
    petInfo.moveConnection = moveConnection
    
    -- ========== BILLBOARD NAMA ==========
    local adornee = petObject:FindFirstChild("Head") or petObject:FindFirstChild("HumanoidRootPart") or petObject:FindFirstChildOfClass("Part")
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 35)
    if adornee then
        billboard.Adornee = adornee
        billboard.Parent = adornee
    else
        billboard.Parent = petObject
    end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🐾 " .. itemName
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.3
    label.Parent = billboard
    
    -- ========== AUTO DELETE 120 DETIK ==========
    task.delay(120, function()
        pcall(function()
            moveConnection:Disconnect()
            petObject:Destroy()
            for i, obj in ipairs(spawnedObjects) do
                if obj == petObject then
                    table.remove(spawnedObjects, i)
                    break
                end
            end
            for i, info in ipairs(petMovements) do
                if info.object == petObject then
                    table.remove(petMovements, i)
                    break
                end
            end
        end)
    end)
    
    notify("✅ " .. itemName .. " spawned! (120s)", 3)
end

-- ===================== TANAMAN MENJADI BERBUAH =====================
local plantedPlants = {}

local function plantFruit(itemName)
    notify("🌱 Planting " .. itemName .. "...", 2)
    
    local char = LocalPlayer.Character
    if not char then 
        notify("❌ Character not found!", 2)
        return 
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        notify("❌ HumanoidRootPart not found!", 2)
        return 
    end
    
    local plantPos = hrp.Position + Vector3.new(0, 0, 0) + hrp.CFrame.LookVector * 5 + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
    
    local plant = Instance.new("Model")
    plant.Name = itemName .. "_Plant"
    plant.Parent = Workspace
    
    local stem = Instance.new("Part")
    stem.Name = "Stem"
    stem.Size = Vector3.new(0.2, 1.5, 0.2)
    stem.Position = plantPos + Vector3.new(0, 0.75, 0)
    stem.Anchored = true
    stem.CanCollide = false
    stem.Transparency = 0.1
    stem.Color = Color3.fromRGB(34, 139, 34)
    stem.Parent = plant
    Instance.new("UICorner", stem).CornerRadius = UDim.new(1, 0)
    
    for i = 1, 3 do
        local leaf = Instance.new("Part")
        leaf.Name = "Leaf"
        leaf.Size = Vector3.new(0.4, 0.1, 0.4)
        leaf.Position = plantPos + Vector3.new(math.random(-0.5, 0.5), 0.5 + i * 0.3, math.random(-0.5, 0.5))
        leaf.Anchored = true
        leaf.CanCollide = false
        leaf.Transparency = 0.1
        leaf.Color = Color3.fromRGB(50, 200, 50)
        leaf.Parent = plant
        Instance.new("UICorner", leaf).CornerRadius = UDim.new(1, 0)
        leaf.CFrame = leaf.CFrame * CFrame.Angles(0, math.rad(i * 120), math.rad(30))
    end
    
    task.delay(10, function()
        pcall(function()
            local fruit = Instance.new("Part")
            fruit.Name = "Fruit_" .. itemName
            fruit.Size = Vector3.new(0.8, 0.8, 0.8)
            fruit.Position = plantPos + Vector3.new(0, 2.2, 0)
            fruit.Anchored = true
            fruit.CanCollide = false
            fruit.Transparency = 0.2
            fruit.Color = Color3.fromRGB(255, 100, 50)
            fruit.Parent = plant
            Instance.new("UICorner", fruit).CornerRadius = UDim.new(1, 0)
            
            local fruitBillboard = Instance.new("BillboardGui")
            fruitBillboard.Size = UDim2.new(0, 100, 0, 30)
            fruitBillboard.Adornee = fruit
            fruitBillboard.Parent = fruit
            
            local fruitLabel = Instance.new("TextLabel")
            fruitLabel.Size = UDim2.new(1, 0, 1, 0)
            fruitLabel.BackgroundTransparency = 1
            fruitLabel.Text = "🍎 " .. itemName
            fruitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            fruitLabel.TextSize = 14
            fruitLabel.Font = Enum.Font.GothamBold
            fruitLabel.Parent = fruitBillboard
            
            TweenService:Create(fruit, TweenInfo.new(0.5), {
                Size = Vector3.new(1.2, 1.2, 1.2)
            }):Play()
            
            notify("🍎 " .. itemName .. " has grown fruit!", 2)
            
            task.delay(30, function()
                pcall(function()
                    TweenService:Create(fruit, TweenInfo.new(0.5), {
                        Transparency = 1
                    }):Play()
                    task.delay(0.5, function()
                        pcall(function() fruit:Destroy() end)
                    end)
                end)
            end)
        end)
    end)
    
    table.insert(plantedPlants, plant)
    
    task.delay(60, function()
        pcall(function()
            plant:Destroy()
            for i, obj in ipairs(plantedPlants) do
                if obj == plant then
                    table.remove(plantedPlants, i)
                    break
                end
            end
        end)
    end)
    
    notify("🌱 " .. itemName .. " planted! Fruit in 10s", 3)
end

-- ===================== CREATE UI =====================
local function createUI()
    local oldGui = CoreGui:FindFirstChild("GardenSpawnerUI")
    if oldGui then oldGui:Destroy() end
    
    local oldToggle = CoreGui:FindFirstChild("GardenToggleGui")
    if oldToggle then oldToggle:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GardenSpawnerUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 480, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -240, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    header.BackgroundTransparency = 0
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "🌱 GARDEN SPAWNER v11.0"
    title.TextColor3 = Color3.fromRGB(100, 255, 150)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    closeBtn.BackgroundTransparency = 0
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        local tg = CoreGui:FindFirstChild("GardenToggleGui")
        if tg then tg:Destroy() end
    end)
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 45)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabs = {"Pet", "Plants", "Settings"}
    local selectedTab = "Pet"
    local tabButtons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1/3, -4, 1, -6)
        btn.Position = UDim2.new((i-1)/3, 2, 0, 3)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 40, 80) or Color3.fromRGB(20, 20, 45)
        btn.BackgroundTransparency = 0
        btn.BorderSizePixel = 0
        btn.Text = tabName
        btn.TextColor3 = i == 1 and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(180, 180, 200)
        btn.TextSize = 15
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        tabButtons[tabName] = btn
    end
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -120)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    -- PET TAB
    local petTab = Instance.new("ScrollingFrame")
    petTab.Size = UDim2.new(1, 0, 1, 0)
    petTab.BackgroundTransparency = 1
    petTab.CanvasSize = UDim2.new(0, 0, 0, 0)
    petTab.ScrollBarThickness = 6
    petTab.Parent = contentFrame
    
    local selectedPet = nil
    local selectedPetRarity = "All"
    
    local function buildPetTab()
        for _, child in ipairs(petTab:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
        
        local yPos = 0
        local rarityListVisible = false
        
        local rarityFrame = Instance.new("Frame")
        rarityFrame.Size = UDim2.new(1, 0, 0, 40)
        rarityFrame.Position = UDim2.new(0, 0, 0, yPos)
        rarityFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
        rarityFrame.BackgroundTransparency = 0
        rarityFrame.Parent = petTab
        Instance.new("UICorner", rarityFrame).CornerRadius = UDim.new(0, 6)
        
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(0.7, 0, 1, 0)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = "📊 All Pets"
        rarityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        rarityLabel.TextSize = 14
        rarityLabel.Font = Enum.Font.GothamBold
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
        rarityLabel.Position = UDim2.new(0, 10, 0, 0)
        rarityLabel.Parent = rarityFrame
        
        local rarityBtn = Instance.new("TextButton")
        rarityBtn.Size = UDim2.new(0, 35, 0, 32)
        rarityBtn.Position = UDim2.new(1, -42, 0, 4)
        rarityBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        rarityBtn.BackgroundTransparency = 0
        rarityBtn.BorderSizePixel = 0
        rarityBtn.Text = "▼"
        rarityBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        rarityBtn.TextSize = 16
        rarityBtn.Font = Enum.Font.GothamBold
        rarityBtn.Parent = rarityFrame
        Instance.new("UICorner", rarityBtn).CornerRadius = UDim.new(0, 4)
        
        local rarityList = Instance.new("Frame")
        rarityList.Size = UDim2.new(1, 0, 0, 250)
        rarityList.Position = UDim2.new(0, 0, 0, 45)
        rarityList.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
        rarityList.BackgroundTransparency = 0
        rarityList.Visible = false
        rarityList.ClipsDescendants = true
        rarityList.Parent = petTab
        Instance.new("UICorner", rarityList).CornerRadius = UDim.new(0, 6)
        
        local rarities = {"All", "Common", "Uncommon", "Rare", "Legendary", "Mythical", "Divine", "Prismatic"}
        local rarityColors = {
            All = Color3.fromRGB(255, 255, 255),
            Common = Color3.fromRGB(200, 200, 200),
            Uncommon = Color3.fromRGB(100, 200, 100),
            Rare = Color3.fromRGB(100, 150, 255),
            Legendary = Color3.fromRGB(255, 150, 50),
            Mythical = Color3.fromRGB(200, 100, 255),
            Divine = Color3.fromRGB(255, 215, 0),
            Prismatic = Color3.fromRGB(255, 50, 150)
        }
        
        for i, rarityName in ipairs(rarities) do
            local item = Instance.new("TextButton")
            item.Size = UDim2.new(1, -10, 0, 30)
            item.Position = UDim2.new(0, 5, 0, (i-1) * 30)
            item.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
            item.BackgroundTransparency = 0
            item.BorderSizePixel = 0
            item.Text = rarityName
            item.TextColor3 = rarityColors[rarityName] or Color3.fromRGB(200, 200, 200)
            item.TextSize = 13
            item.Font = Enum.Font.GothamMedium
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.Parent = rarityList
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
            item.MouseButton1Click:Connect(function()
                selectedPetRarity = rarityName
                rarityLabel.Text = "📊 " .. rarityName
                rarityList.Visible = false
                rarityListVisible = false
                buildPetTab()
            end)
        end
        
        rarityBtn.MouseButton1Click:Connect(function()
            rarityListVisible = not rarityListVisible
            rarityList.Visible = rarityListVisible
        end)
        
        yPos = yPos + 50
        
        local filteredPets = {}
        if selectedPetRarity == "All" then
            for rarity, list in pairs(PETS) do
                for _, pet in ipairs(list) do
                    table.insert(filteredPets, {name = pet, rarity = rarity})
                end
            end
        else
            for _, pet in ipairs(PETS[selectedPetRarity] or {}) do
                table.insert(filteredPets, {name = pet, rarity = selectedPetRarity})
            end
        end
        
        for i, petData in ipairs(filteredPets) do
            local petBtn = Instance.new("TextButton")
            petBtn.Size = UDim2.new(1, -10, 0, 35)
            petBtn.Position = UDim2.new(0, 5, 0, yPos)
            petBtn.BackgroundColor3 = (selectedPet == petData.name) and Color3.fromRGB(45, 45, 75) or Color3.fromRGB(30, 30, 55)
            petBtn.BackgroundTransparency = 0
            petBtn.BorderSizePixel = 0
            petBtn.Text = petData.name
            petBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
            petBtn.TextSize = 14
            petBtn.Font = Enum.Font.GothamMedium
            petBtn.TextXAlignment = Enum.TextXAlignment.Left
            petBtn.Parent = petTab
            Instance.new("UICorner", petBtn).CornerRadius = UDim.new(0, 6)
            
            local selector = Instance.new("Frame")
            selector.Size = UDim2.new(0, 4, 0.6, 0)
            selector.Position = UDim2.new(0, 0, 0.2, 0)
            selector.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
            selector.BackgroundTransparency = (selectedPet == petData.name) and 0 or 1
            selector.BorderSizePixel = 0
            selector.Parent = petBtn
            Instance.new("UICorner", selector).CornerRadius = UDim.new(0, 2)
            
            local rarityTag = Instance.new("TextLabel")
            rarityTag.Size = UDim2.new(0, 80, 1, 0)
            rarityTag.Position = UDim2.new(1, -85, 0, 0)
            rarityTag.BackgroundTransparency = 1
            rarityTag.Text = petData.rarity
            rarityTag.TextColor3 = rarityColors[petData.rarity] or Color3.fromRGB(200, 200, 200)
            rarityTag.TextSize = 11
            rarityTag.Font = Enum.Font.GothamMedium
            rarityTag.TextXAlignment = Enum.TextXAlignment.Right
            rarityTag.Parent = petBtn
            
            petBtn.MouseButton1Click:Connect(function()
                selectedPet = petData.name
                buildPetTab()
                notify("🖱️ Selected: " .. petData.name, 2)
            end)
            yPos = yPos + 40
        end
        
        yPos = yPos + 10
        
        local spawnBtn = Instance.new("TextButton")
        spawnBtn.Size = UDim2.new(1, -10, 0, 50)
        spawnBtn.Position = UDim2.new(0, 5, 0, yPos)
        spawnBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        spawnBtn.BackgroundTransparency = 0
        spawnBtn.BorderSizePixel = 0
        spawnBtn.Text = "🐾 SPAWN PET"
        spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        spawnBtn.TextSize = 18
        spawnBtn.Font = Enum.Font.GothamBold
        spawnBtn.Parent = petTab
        Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0, 8)
        
        spawnBtn.MouseButton1Click:Connect(function()
            if selectedPet then
                spawnRealPet(selectedPet, "Pet")
            else
                notify("⚠️ Select a pet first!", 2)
            end
        end)
        
        yPos = yPos + 60
        petTab.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)
    end
    
    -- PLANTS TAB
    local plantTab = Instance.new("ScrollingFrame")
    plantTab.Size = UDim2.new(1, 0, 1, 0)
    plantTab.BackgroundTransparency = 1
    plantTab.CanvasSize = UDim2.new(0, 0, 0, 0)
    plantTab.ScrollBarThickness = 6
    plantTab.Visible = false
    plantTab.Parent = contentFrame
    
    local selectedPlant = nil
    local selectedPlantRarity = "All"
    
    local function buildPlantTab()
        for _, child in ipairs(plantTab:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
        
        local yPos = 0
        local rarityListVisible = false
        
        local rarityFrame = Instance.new("Frame")
        rarityFrame.Size = UDim2.new(1, 0, 0, 40)
        rarityFrame.Position = UDim2.new(0, 0, 0, yPos)
        rarityFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
        rarityFrame.BackgroundTransparency = 0
        rarityFrame.Parent = plantTab
        Instance.new("UICorner", rarityFrame).CornerRadius = UDim.new(0, 6)
        
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(0.7, 0, 1, 0)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = "📊 All Plants"
        rarityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        rarityLabel.TextSize = 14
        rarityLabel.Font = Enum.Font.GothamBold
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
        rarityLabel.Position = UDim2.new(0, 10, 0, 0)
        rarityLabel.Parent = rarityFrame
        
        local rarityBtn = Instance.new("TextButton")
        rarityBtn.Size = UDim2.new(0, 35, 0, 32)
        rarityBtn.Position = UDim2.new(1, -42, 0, 4)
        rarityBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        rarityBtn.BackgroundTransparency = 0
        rarityBtn.BorderSizePixel = 0
        rarityBtn.Text = "▼"
        rarityBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        rarityBtn.TextSize = 16
        rarityBtn.Font = Enum.Font.GothamBold
        rarityBtn.Parent = rarityFrame
        Instance.new("UICorner", rarityBtn).CornerRadius = UDim.new(0, 4)
        
        local rarityList = Instance.new("Frame")
        rarityList.Size = UDim2.new(1, 0, 0, 250)
        rarityList.Position = UDim2.new(0, 0, 0, 45)
        rarityList.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
        rarityList.BackgroundTransparency = 0
        rarityList.Visible = false
        rarityList.ClipsDescendants = true
        rarityList.Parent = plantTab
        Instance.new("UICorner", rarityList).CornerRadius = UDim.new(0, 6)
        
        local rarities = {"All", "Common", "Uncommon", "Rare", "Legendary", "Mythical", "Divine", "Prismatic"}
        local rarityColors = {
            All = Color3.fromRGB(255, 255, 255),
            Common = Color3.fromRGB(200, 200, 200),
            Uncommon = Color3.fromRGB(100, 200, 100),
            Rare = Color3.fromRGB(100, 150, 255),
            Legendary = Color3.fromRGB(255, 150, 50),
            Mythical = Color3.fromRGB(200, 100, 255),
            Divine = Color3.fromRGB(255, 215, 0),
            Prismatic = Color3.fromRGB(255, 50, 150)
        }
        
        for i, rarityName in ipairs(rarities) do
            local item = Instance.new("TextButton")
            item.Size = UDim2.new(1, -10, 0, 30)
            item.Position = UDim2.new(0, 5, 0, (i-1) * 30)
            item.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
            item.BackgroundTransparency = 0
            item.BorderSizePixel = 0
            item.Text = rarityName
            item.TextColor3 = rarityColors[rarityName] or Color3.fromRGB(200, 200, 200)
            item.TextSize = 13
            item.Font = Enum.Font.GothamMedium
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.Parent = rarityList
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
            item.MouseButton1Click:Connect(function()
                selectedPlantRarity = rarityName
                rarityLabel.Text = "📊 " .. rarityName
                rarityList.Visible = false
                rarityListVisible = false
                buildPlantTab()
            end)
        end
        
        rarityBtn.MouseButton1Click:Connect(function()
            rarityListVisible = not rarityListVisible
            rarityList.Visible = rarityListVisible
        end)
        
        yPos = yPos + 50
        
        local filteredPlants = {}
        if selectedPlantRarity == "All" then
            for rarity, list in pairs(PLANTS) do
                for _, plant in ipairs(list) do
                    table.insert(filteredPlants, {name = plant, rarity = rarity})
                end
            end
        else
            for _, plant in ipairs(PLANTS[selectedPlantRarity] or {}) do
                table.insert(filteredPlants, {name = plant, rarity = selectedPlantRarity})
            end
        end
        
        for i, plantData in ipairs(filteredPlants) do
            local plantBtn = Instance.new("TextButton")
            plantBtn.Size = UDim2.new(1, -10, 0, 35)
            plantBtn.Position = UDim2.new(0, 5, 0, yPos)
            plantBtn.BackgroundColor3 = (selectedPlant == plantData.name) and Color3.fromRGB(45, 45, 75) or Color3.fromRGB(30, 30, 55)
            plantBtn.BackgroundTransparency = 0
            plantBtn.BorderSizePixel = 0
            plantBtn.Text = plantData.name
            plantBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
            plantBtn.TextSize = 14
            plantBtn.Font = Enum.Font.GothamMedium
            plantBtn.TextXAlignment = Enum.TextXAlignment.Left
            plantBtn.Parent = plantTab
            Instance.new("UICorner", plantBtn).CornerRadius = UDim.new(0, 6)
            
            local selector = Instance.new("Frame")
            selector.Size = UDim2.new(0, 4, 0.6, 0)
            selector.Position = UDim2.new(0, 0, 0.2, 0)
            selector.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
            selector.BackgroundTransparency = (selectedPlant == plantData.name) and 0 or 1
            selector.BorderSizePixel = 0
            selector.Parent = plantBtn
            Instance.new("UICorner", selector).CornerRadius = UDim.new(0, 2)
            
            local rarityTag = Instance.new("TextLabel")
            rarityTag.Size = UDim2.new(0, 80, 1, 0)
            rarityTag.Position = UDim2.new(1, -85, 0, 0)
            rarityTag.BackgroundTransparency = 1
            rarityTag.Text = plantData.rarity
            rarityTag.TextColor3 = rarityColors[plantData.rarity] or Color3.fromRGB(200, 200, 200)
            rarityTag.TextSize = 11
            rarityTag.Font = Enum.Font.GothamMedium
            rarityTag.TextXAlignment = Enum.TextXAlignment.Right
            rarityTag.Parent = plantBtn
            
            plantBtn.MouseButton1Click:Connect(function()
                selectedPlant = plantData.name
                buildPlantTab()
                notify("🖱️ Selected: " .. plantData.name, 2)
            end)
            yPos = yPos + 40
        end
        
        yPos = yPos + 10
        
        local plantBtn2 = Instance.new("TextButton")
        plantBtn2.Size = UDim2.new(1, -10, 0, 50)
        plantBtn2.Position = UDim2.new(0, 5, 0, yPos)
        plantBtn2.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        plantBtn2.BackgroundTransparency = 0
        plantBtn2.BorderSizePixel = 0
        plantBtn2.Text = "🌱 PLANT & GROW FRUIT"
        plantBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
        plantBtn2.TextSize = 16
        plantBtn2.Font = Enum.Font.GothamBold
        plantBtn2.Parent = plantTab
        Instance.new("UICorner", plantBtn2).CornerRadius = UDim.new(0, 8)
        
        plantBtn2.MouseButton1Click:Connect(function()
            if selectedPlant then
                plantFruit(selectedPlant)
            else
                notify("⚠️ Select a plant first!", 2)
            end
        end)
        
        yPos = yPos + 60
        
        local spawnVisualBtn = Instance.new("TextButton")
        spawnVisualBtn.Size = UDim2.new(1, -10, 0, 40)
        spawnVisualBtn.Position = UDim2.new(0, 5, 0, yPos)
        spawnVisualBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
        spawnVisualBtn.BackgroundTransparency = 0
        spawnVisualBtn.BorderSizePixel = 0
        spawnVisualBtn.Text = "👁️ Spawn Visual Only"
        spawnVisualBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
        spawnVisualBtn.TextSize = 13
        spawnVisualBtn.Font = Enum.Font.GothamMedium
        spawnVisualBtn.Parent = plantTab
        Instance.new("UICorner", spawnVisualBtn).CornerRadius = UDim.new(0, 8)
        
        spawnVisualBtn.MouseButton1Click:Connect(function()
            if selectedPlant then
                spawnRealPet(selectedPlant, "Plant")
            else
                notify("⚠️ Select a plant first!", 2)
            end
        end)
        
        yPos = yPos + 50
        plantTab.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)
    end
    
    -- SETTINGS TAB
    local settingsTab = Instance.new("ScrollingFrame")
    settingsTab.Size = UDim2.new(1, 0, 1, 0)
    settingsTab.BackgroundTransparency = 1
    settingsTab.CanvasSize = UDim2.new(0, 0, 0, 0)
    settingsTab.ScrollBarThickness = 6
    settingsTab.Visible = false
    settingsTab.Parent = contentFrame
    
    local function buildSettingsTab()
        for _, child in ipairs(settingsTab:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
        end
        
        local yPos = 10
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, -10, 0, 60)
        infoLabel.Position = UDim2.new(0, 5, 0, yPos)
        infoLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
        infoLabel.BackgroundTransparency = 0.5
        infoLabel.Text = "🌱 GARDEN SPAWNER v11.0\nREAL PET FROM GAG - 120s DURATION"
        infoLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        infoLabel.TextSize = 14
        infoLabel.Font = Enum.Font.GothamMedium
        infoLabel.TextWrapped = true
        infoLabel.Parent = settingsTab
        Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 8)
        yPos = yPos + 70
        
        local totalPets = 0
        for _, list in pairs(PETS) do totalPets = totalPets + #list end
        local totalPlants = 0
        for _, list in pairs(PLANTS) do totalPlants = totalPlants + #list end
        
        local stats = Instance.new("TextLabel")
        stats.Size = UDim2.new(1, -10, 0, 60)
        stats.Position = UDim2.new(0, 5, 0, yPos)
        stats.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
        stats.BackgroundTransparency = 0.5
        stats.Text = "📊 Total Pets: " .. totalPets .. "\n🌱 Total Plants: " .. totalPlants .. "\n🐾 Real GAG Models - 120s Duration"
        stats.TextColor3 = Color3.fromRGB(200, 200, 220)
        stats.TextSize = 13
        stats.Font = Enum.Font.GothamMedium
        stats.TextWrapped = true
        stats.Parent = settingsTab
        Instance.new("UICorner", stats).CornerRadius = UDim.new(0, 8)
        yPos = yPos + 70
        
        local clearBtn = Instance.new("TextButton")
        clearBtn.Size = UDim2.new(1, -10, 0, 45)
        clearBtn.Position = UDim2.new(0, 5, 0, yPos)
        clearBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
        clearBtn.BackgroundTransparency = 0
        clearBtn.BorderSizePixel = 0
        clearBtn.Text = "🗑️ Clear All Visuals"
        clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        clearBtn.TextSize = 15
        clearBtn.Font = Enum.Font.GothamBold
        clearBtn.Parent = settingsTab
        Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8)
        clearBtn.MouseButton1Click:Connect(function()
            for _, obj in ipairs(spawnedObjects) do
                pcall(function() obj:Destroy() end)
            end
            for _, info in ipairs(petMovements) do
                pcall(function() info.moveConnection:Disconnect() end)
                pcall(function() info.object:Destroy() end)
            end
            for _, obj in ipairs(plantedPlants) do
                pcall(function() obj:Destroy() end)
            end
            spawnedObjects = {}
            petMovements = {}
            plantedPlants = {}
            notify("🗑️ All visuals cleared!", 2)
        end)
        yPos = yPos + 55
        
        local closeBtn2 = Instance.new("TextButton")
        closeBtn2.Size = UDim2.new(1, -10, 0, 45)
        closeBtn2.Position = UDim2.new(0, 5, 0, yPos)
        closeBtn2.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        closeBtn2.BackgroundTransparency = 0
        closeBtn2.BorderSizePixel = 0
        closeBtn2.Text = "❌ Close Menu"
        closeBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn2.TextSize = 15
        closeBtn2.Font = Enum.Font.GothamBold
        closeBtn2.Parent = settingsTab
        Instance.new("UICorner", closeBtn2).CornerRadius = UDim.new(0, 8)
        closeBtn2.MouseButton1Click:Connect(function()
            screenGui:Destroy()
            local tg = CoreGui:FindFirstChild("GardenToggleGui")
            if tg then tg:Destroy() end
        end)
        yPos = yPos + 55
        
        settingsTab.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)
    end
    
    buildPetTab()
    buildPlantTab()
    buildSettingsTab()
    
    local function switchTab(tabName)
        selectedTab = tabName
        for name, btn in pairs(tabButtons) do
            if name == tabName then
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
                btn.TextColor3 = Color3.fromRGB(100, 255, 150)
            else
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
                btn.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
        end
        petTab.Visible = (tabName == "Pet")
        plantTab.Visible = (tabName == "Plants")
        settingsTab.Visible = (tabName == "Settings")
    end
    
    for name, btn in pairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            switchTab(name)
        end)
    end
    
    -- TOGGLE BUTTON
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "GardenToggleGui"
    toggleGui.ResetOnSpawn = false
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
    Instance.new("UICorner", buttonFrame).CornerRadius = UDim.new(0, 12)
    
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
    glow.BackgroundTransparency = 0.7
    glow.BorderSizePixel = 0
    glow.ZIndex = -1
    glow.Parent = buttonFrame
    Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 16)
    
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
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 10)
    
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
    Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0, 4)
    
    local menuVisible = true
    local dragData = { dragging = false, startPos = nil, startMouse = nil, isDragging = false }
    
    local function toggleMenu()
        menuVisible = not menuVisible
        screenGui.Enabled = menuVisible
        
        if menuVisible then
            toggleButton.Text = "−"
            buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
            glow.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
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
    
    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.dragging = true
            dragData.startPos = buttonFrame.Position
            dragData.startMouse = input.Position
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
            local delta = input.Position - dragData.startMouse
            if delta.Magnitude > 3 then
                dragData.isDragging = true
            end
            if dragData.isDragging then
                local newX = dragData.startPos.X.Offset + delta.X
                local newY = dragData.startPos.Y.Offset + delta.Y
                local screenSize = GuiService:GetScreenSize()
                newX = math.clamp(newX, 0, screenSize.X - 44)
                newY = math.clamp(newY, 0, screenSize.Y - 44)
                buttonFrame.Position = UDim2.new(0, newX, 0, newY)
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
        if input.KeyCode == Enum.KeyCode.Minus then
            toggleMenu()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Equals then
            toggleMenu()
        end
    end)
    
    notify("🌱 GARDEN SPAWNER v11.0 LOADED!", 3)
    notify("🐾 REAL GAG PET MODELS!", 3)
end

task.spawn(function()
    createUI()
end)

print("[GARDEN SPAWNER] ✅ v11.0 LOADED!")
print("🐾 Using REAL GAG Pet Models!")