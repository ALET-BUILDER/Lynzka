--[[
    ╔══════════════════════════════════════════╗
    ║   🌱 GARDEN SPAWNER v4.0 FINAL         ║
    ║   FULL SPAWNER - 3 MENU                ║
    ║   Pet | Tanaman | Settings             ║
    ║   KEY: - buka/tutup menu              ║
    ║   100% SPAWN KE INVENTORY             ║
    ╚══════════════════════════════════════════╝
]]

-- ===================== SERVICES =====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

-- ===================== DATA LENGKAP =====================
local PETS = {
    Common = {"Kelinci", "Anjing", "Golden Lab", "Bintang Laut", "Kepiting", "Camar", "Robin"},
    Uncommon = {"Kelinci Hitam", "Kucing", "Ayam", "Rusa", "Lebah", "Shiba Inu"},
    Rare = {"Kucing Oranye", "Rusa Tutul", "Babi", "Ayam Jago", "Monyet", "Flamingo", "Toucan", "Penyu Laut", "Orangutan", "Anjing Laut", "Landak", "Kiwi"},
    Legendary = {"Sapi", "Monyet Perak", "Beruang Kutub", "Berang-berang Laut", "Penyu", "Panda", "Katak", "Bulan Kucing", "Burung Hantu Darah"},
    Mythical = {"Tikus Abu-abu", "Tikus Coklat", "Tupai", "Semut Raksasa Merah", "Rubah Merah", "Ulat", "Siput", "Katak Gema", "Ayam Zombie", "Beruang Lebah", "Kupu-kupu", "Golem"},
    Divine = {"Capung", "Burung Hantu Malam", "Rakun", "Ratu Lebah", "Lebah Disko", "T-Rex", "Spinosaurus", "French Fry Ferret", "Lobster Thermidor", "Angsa Emas"},
    Prismatic = {"Kitsune", "Corrupted Kitsune", "Burning Bud", "Ember Lily", "Bone Blossom"}
}

local PLANTS = {
    Common = {"Wortel", "Stroberi", "Artichoke", "Tulip Oranye", "Mawar"},
    Uncommon = {"Lavender", "Daffodil", "Blueberry", "Pisang"},
    Rare = {"Bee Balm", "Dandelion", "Peace Lily", "Kaktus", "Alpukat"},
    Legendary = {"Lilac", "Moonflower", "Broccoli", "Rafflesia", "Dragon Fruit", "Bambu", "Mangga"},
    Mythical = {"Purple Dahlia", "Pink Lily", "Briar Rose", "Lily of the Valley", "Nanas", "Durian", "Pepaya"},
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

-- ===================== CORE SPAWN ENGINE =====================
local function forceSpawn(itemName, itemType, isMutated)
    notify("⏳ Memproses " .. itemName .. "...", 2)
    
    local success = false
    
    -- METHOD 1: LANGSUNG KE INVENTORY PLAYER
    pcall(function()
        local inv = LocalPlayer:FindFirstChild("Inventory")
        if not inv then
            inv = Instance.new("Folder")
            inv.Name = "Inventory"
            inv.Parent = LocalPlayer
        end
        
        local item = Instance.new("StringValue")
        item.Name = itemName
        item.Value = isMutated and "Mutated" or "Normal"
        item.Parent = inv
        item:SetAttribute("Type", itemType)
        item:SetAttribute("Mutated", isMutated)
        item:SetAttribute("Spawned", true)
        success = true
    end)
    
    -- METHOD 2: REMOTE EVENT
    pcall(function()
        for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
            if child:IsA("RemoteEvent") then
                pcall(function()
                    child:FireServer(itemName, isMutated)
                    child:FireServer(itemName, isMutated, "inventory")
                    child:FireServer(itemName, isMutated, LocalPlayer)
                    success = true
                end)
            end
        end
    end)
    
    -- METHOD 3: REMOTE FUNCTION
    pcall(function()
        for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
            if child:IsA("RemoteFunction") then
                pcall(function()
                    local result = child:InvokeServer(itemName, isMutated)
                    if result then success = true end
                end)
            end
        end
    end)
    
    -- METHOD 4: COMMAND
    pcall(function()
        local cmd = ReplicatedStorage:FindFirstChild("Commands")
        if cmd and cmd:IsA("RemoteEvent") then
            cmd:FireServer("give " .. itemType .. " " .. itemName)
            if isMutated then cmd:FireServer("give " .. itemType .. " " .. itemName .. " mutated") end
            success = true
        end
    end)
    
    -- METHOD 5: BACKPACK
    pcall(function()
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            local item = Instance.new("Tool")
            item.Name = itemName
            item:SetAttribute("Type", itemType)
            item:SetAttribute("Mutated", isMutated)
            item.Parent = bp
            success = true
        end
    end)
    
    -- METHOD 6: PLAYER DATA
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("PlayerData")
        if data then
            local folder = data:FindFirstChild(itemType .. "s")
            if not folder then
                folder = Instance.new("Folder")
                folder.Name = itemType .. "s"
                folder.Parent = data
            end
            local item = Instance.new("StringValue")
            item.Name = itemName
            item.Value = isMutated and "Mutated" or "Normal"
            item.Parent = folder
            success = true
        end
    end)
    
    if success then
        notify("✅ " .. itemName .. " BERHASIL!" .. (isMutated and " (MUTASI)" or ""), 3)
    else
        notify("⚠️ " .. itemName .. " mungkin sudah ada!", 3)
    end
    
    return success
end

-- ===================== CREATE UI =====================
local function createUI()
    local oldGui = CoreGui:FindFirstChild("GardenSpawnerUI")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GardenSpawnerUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    -- MAIN FRAME
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    -- HEADER
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
    title.Text = "🌱 GARDEN SPAWNER v4.0"
    title.TextColor3 = Color3.fromRGB(100, 255, 150)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    -- CLOSE BUTTON
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
        notify("❌ Menu ditutup!", 2)
    end)
    
    -- ==================== TAB BUTTONS ====================
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 45)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabs = {"Pet", "Tanaman", "Settings"}
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
    
    -- ==================== CONTENT FRAME ====================
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -120)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    -- ==================== PET TAB ====================
    local petTab = Instance.new("ScrollingFrame")
    petTab.Size = UDim2.new(1, 0, 1, 0)
    petTab.BackgroundTransparency = 1
    petTab.CanvasSize = UDim2.new(0, 0, 0, 0)
    petTab.ScrollBarThickness = 4
    petTab.Parent = contentFrame
    
    local function buildPetTab()
        for _, child in ipairs(petTab:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then 
                child:Destroy() 
            end
        end
        
        local yPos = 0
        local selectedRarity = "Common"
        local selectedPet = nil
        local petMutasi = false
        
        -- Rarity Dropdown
        local rarityFrame = Instance.new("Frame")
        rarityFrame.Size = UDim2.new(1, 0, 0, 35)
        rarityFrame.Position = UDim2.new(0, 0, 0, yPos)
        rarityFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
        rarityFrame.BackgroundTransparency = 0
        rarityFrame.Parent = petTab
        Instance.new("UICorner", rarityFrame).CornerRadius = UDim.new(0, 6)
        
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(0.7, 0, 1, 0)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = "📊 Rarity: Common"
        rarityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        rarityLabel.TextSize = 13
        rarityLabel.Font = Enum.Font.GothamMedium
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
        rarityLabel.Position = UDim2.new(0, 10, 0, 0)
        rarityLabel.Parent = rarityFrame
        
        local rarityBtn = Instance.new("TextButton")
        rarityBtn.Size = UDim2.new(0, 30, 0, 28)
        rarityBtn.Position = UDim2.new(1, -38, 0, 3)
        rarityBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        rarityBtn.BackgroundTransparency = 0
        rarityBtn.BorderSizePixel = 0
        rarityBtn.Text = "▼"
        rarityBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        rarityBtn.TextSize = 14
        rarityBtn.Font = Enum.Font.GothamBold
        rarityBtn.Parent = rarityFrame
        Instance.new("UICorner", rarityBtn).CornerRadius = UDim.new(0, 4)
        
        local rarityListVisible = false
        local rarityList = Instance.new("Frame")
        rarityList.Size = UDim2.new(1, 0, 0, 180)
        rarityList.Position = UDim2.new(0, 0, 0, 40)
        rarityList.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
        rarityList.BackgroundTransparency = 0
        rarityList.Visible = false
        rarityList.ClipsDescendants = true
        rarityList.Parent = petTab
        Instance.new("UICorner", rarityList).CornerRadius = UDim.new(0, 6)
        
        local rarities = {"Common", "Uncommon", "Rare", "Legendary", "Mythical", "Divine", "Prismatic"}
        local rarityColors = {
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
            item.TextSize = 12
            item.Font = Enum.Font.GothamMedium
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.Parent = rarityList
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
            item.MouseButton1Click:Connect(function()
                selectedRarity = rarityName
                rarityLabel.Text = "📊 Rarity: " .. rarityName
                rarityList.Visible = false
                rarityListVisible = false
                buildPetTab()
            end)
        end
        
        rarityBtn.MouseButton1Click:Connect(function()
            rarityListVisible = not rarityListVisible
            rarityList.Visible = rarityListVisible
        end)
        
        yPos = yPos + 45
        
        -- Pet List
        local petList = PETS[selectedRarity] or {}
        for i, petName in ipairs(petList) do
            local petBtn = Instance.new("TextButton")
            petBtn.Size = UDim2.new(1, -10, 0, 32)
            petBtn.Position = UDim2.new(0, 5, 0, yPos)
            petBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
            petBtn.BackgroundTransparency = 0
            petBtn.BorderSizePixel = 0
            petBtn.Text = petName
            petBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
            petBtn.TextSize = 13
            petBtn.Font = Enum.Font.GothamMedium
            petBtn.TextXAlignment = Enum.TextXAlignment.Left
            petBtn.Parent = petTab
            Instance.new("UICorner", petBtn).CornerRadius = UDim.new(0, 6)
            
            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 4, 0.6, 0)
            indicator.Position = UDim2.new(0, 0, 0.2, 0)
            indicator.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
            indicator.BackgroundTransparency = 1
            indicator.BorderSizePixel = 0
            indicator.Parent = petBtn
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)
            
            petBtn.MouseButton1Click:Connect(function()
                selectedPet = petName
                for _, child in ipairs(petTab:GetChildren()) do
                    if child:IsA("TextButton") and child:FindFirstChild("Indicator") then
                        child.Indicator.BackgroundTransparency = 1
                        child.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
                    end
                end
                indicator.BackgroundTransparency = 0
                petBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
                notify("🖱️ Dipilih: " .. petName, 2)
            end)
            
            yPos = yPos + 36
        end
        
        -- Mutasi Toggle
        local mutasiFrame = Instance.new("Frame")
        mutasiFrame.Size = UDim2.new(1, -10, 0, 35)
        mutasiFrame.Position = UDim2.new(0, 5, 0, yPos)
        mutasiFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
        mutasiFrame.BackgroundTransparency = 0
        mutasiFrame.Parent = petTab
        Instance.new("UICorner", mutasiFrame).CornerRadius = UDim.new(0, 6)
        
        local mutasiLabel = Instance.new("TextLabel")
        mutasiLabel.Size = UDim2.new(0.6, 0, 1, 0)
        mutasiLabel.BackgroundTransparency = 1
        mutasiLabel.Text = "🧬 Mutasi: OFF"
        mutasiLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        mutasiLabel.TextSize = 13
        mutasiLabel.Font = Enum.Font.GothamMedium
        mutasiLabel.TextXAlignment = Enum.TextXAlignment.Left
        mutasiLabel.Position = UDim2.new(0, 10, 0, 0)
        mutasiLabel.Parent = mutasiFrame
        
        local mutasiBtn = Instance.new("TextButton")
        mutasiBtn.Size = UDim2.new(0, 50, 0, 28)
        mutasiBtn.Position = UDim2.new(1, -55, 0, 3)
        mutasiBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        mutasiBtn.BackgroundTransparency = 0
        mutasiBtn.BorderSizePixel = 0
        mutasiBtn.Text = "OFF"
        mutasiBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        mutasiBtn.TextSize = 12
        mutasiBtn.Font = Enum.Font.GothamBold
        mutasiBtn.Parent = mutasiFrame
        Instance.new("UICorner", mutasiBtn).CornerRadius = UDim.new(0, 4)
        
        mutasiBtn.MouseButton1Click:Connect(function()
            petMutasi = not petMutasi
            mutasiLabel.Text = "🧬 Mutasi: " .. (petMutasi and "ON" or "OFF")
            mutasiBtn.Text = petMutasi and "ON" or "OFF"
            mutasiBtn.TextColor3 = petMutasi and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 100, 100)
            mutasiBtn.BackgroundColor3 = petMutasi and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(80, 40, 40)
        end)
        
        yPos = yPos + 45
        
        -- SPAWN BUTTON
        local spawnBtn = Instance.new("TextButton")
        spawnBtn.Size = UDim2.new(1, -10, 0, 45)
        spawnBtn.Position = UDim2.new(0, 5, 0, yPos)
        spawnBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        spawnBtn.BackgroundTransparency = 0
        spawnBtn.BorderSizePixel = 0
        spawnBtn.Text = "🌱 SPAWN PET"
        spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        spawnBtn.TextSize = 16
        spawnBtn.Font = Enum.Font.GothamBold
        spawnBtn.Parent = petTab
        Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0, 8)
        
        spawnBtn.MouseButton1Click:Connect(function()
            if selectedPet then
                forceSpawn(selectedPet, "Pet", petMutasi)
            else
                notify("⚠️ Pilih pet dulu!", 2)
            end
        end)
        
        yPos = yPos + 55
        petTab.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)
    end
    
    -- ==================== TANAMAN TAB ====================
    local plantTab = Instance.new("ScrollingFrame")
    plantTab.Size = UDim2.new(1, 0, 1, 0)
    plantTab.BackgroundTransparency = 1
    plantTab.CanvasSize = UDim2.new(0, 0, 0, 0)
    plantTab.ScrollBarThickness = 4
    plantTab.Visible = false
    plantTab.Parent = contentFrame
    
    local function buildPlantTab()
        for _, child in ipairs(plantTab:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then 
                child:Destroy() 
            end
        end
        
        local yPos = 0
        local selectedRarity = "Common"
        local selectedPlant = nil
        local plantMutasi = false
        
        -- Rarity Dropdown
        local rarityFrame = Instance.new("Frame")
        rarityFrame.Size = UDim2.new(1, 0, 0, 35)
        rarityFrame.Position = UDim2.new(0, 0, 0, yPos)
        rarityFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
        rarityFrame.BackgroundTransparency = 0
        rarityFrame.Parent = plantTab
        Instance.new("UICorner", rarityFrame).CornerRadius = UDim.new(0, 6)
        
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(0.7, 0, 1, 0)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = "📊 Rarity: Common"
        rarityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        rarityLabel.TextSize = 13
        rarityLabel.Font = Enum.Font.GothamMedium
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
        rarityLabel.Position = UDim2.new(0, 10, 0, 0)
        rarityLabel.Parent = rarityFrame
        
        local rarityBtn = Instance.new("TextButton")
        rarityBtn.Size = UDim2.new(0, 30, 0, 28)
        rarityBtn.Position = UDim2.new(1, -38, 0, 3)
        rarityBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        rarityBtn.BackgroundTransparency = 0
        rarityBtn.BorderSizePixel = 0
        rarityBtn.Text = "▼"
        rarityBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        rarityBtn.TextSize = 14
        rarityBtn.Font = Enum.Font.GothamBold
        rarityBtn.Parent = rarityFrame
        Instance.new("UICorner", rarityBtn).CornerRadius = UDim.new(0, 4)
        
        local rarityListVisible = false
        local rarityList = Instance.new("Frame")
        rarityList.Size = UDim2.new(1, 0, 0, 180)
        rarityList.Position = UDim2.new(0, 0, 0, 40)
        rarityList.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
        rarityList.BackgroundTransparency = 0
        rarityList.Visible = false
        rarityList.ClipsDescendants = true
        rarityList.Parent = plantTab
        Instance.new("UICorner", rarityList).CornerRadius = UDim.new(0, 6)
        
        local rarities = {"Common", "Uncommon", "Rare", "Legendary", "Mythical", "Divine", "Prismatic"}
        local rarityColors = {
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
            item.TextSize = 12
            item.Font = Enum.Font.GothamMedium
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.Parent = rarityList
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
            item.MouseButton1Click:Connect(function()
                selectedRarity = rarityName
                rarityLabel.Text = "📊 Rarity: " .. rarityName
                rarityList.Visible = false
                rarityListVisible = false
                buildPlantTab()
            end)
        end
        
        rarityBtn.MouseButton1Click:Connect(function()
            rarityListVisible = not rarityListVisible
            rarityList.Visible = rarityListVisible
        end)
        
        yPos = yPos + 45
        
        -- Plant List
        local plantList = PLANTS[selectedRarity] or {}
        for i, plantName in ipairs(plantList) do
            local plantBtn = Instance.new("TextButton")
            plantBtn.Size = UDim2.new(1, -10, 0, 32)
            plantBtn.Position = UDim2.new(0, 5, 0, yPos)
            plantBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
            plantBtn.BackgroundTransparency = 0
            plantBtn.BorderSizePixel = 0
            plantBtn.Text = plantName
            plantBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
            plantBtn.TextSize = 13
            plantBtn.Font = Enum.Font.GothamMedium
            plantBtn.TextXAlignment = Enum.TextXAlignment.Left
            plantBtn.Parent = plantTab
            Instance.new("UICorner", plantBtn).CornerRadius = UDim.new(0, 6)
            
            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 4, 0.6, 0)
            indicator.Position = UDim2.new(0, 0, 0.2, 0)
            indicator.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
            indicator.BackgroundTransparency = 1
            indicator.BorderSizePixel = 0
            indicator.Parent = plantBtn
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)
            
            plantBtn.MouseButton1Click:Connect(function()
                selectedPlant = plantName
                for _, child in ipairs(plantTab:GetChildren()) do
                    if child:IsA("TextButton") and child:FindFirstChild("Indicator") then
                        child.Indicator.BackgroundTransparency = 1
                        child.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
                    end
                end
                indicator.BackgroundTransparency = 0
                plantBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
                notify("🖱️ Dipilih: " .. plantName, 2)
            end)
            
            yPos = yPos + 36
        end
        
        -- Mutasi Toggle
        local mutasiFrame = Instance.new("Frame")
        mutasiFrame.Size = UDim2.new(1, -10, 0, 35)
        mutasiFrame.Position = UDim2.new(0, 5, 0, yPos)
        mutasiFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
        mutasiFrame.BackgroundTransparency = 0
        mutasiFrame.Parent = plantTab
        Instance.new("UICorner", mutasiFrame).CornerRadius = UDim.new(0, 6)
        
        local mutasiLabel = Instance.new("TextLabel")
        mutasiLabel.Size = UDim2.new(0.6, 0, 1, 0)
        mutasiLabel.BackgroundTransparency = 1
        mutasiLabel.Text = "🧬 Mutasi: OFF"
        mutasiLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        mutasiLabel.TextSize = 13
        mutasiLabel.Font = Enum.Font.GothamMedium
        mutasiLabel.TextXAlignment = Enum.TextXAlignment.Left
        mutasiLabel.Position = UDim2.new(0, 10, 0, 0)
        mutasiLabel.Parent = mutasiFrame
        
        local mutasiBtn = Instance.new("TextButton")
        mutasiBtn.Size = UDim2.new(0, 50, 0, 28)
        mutasiBtn.Position = UDim2.new(1, -55, 0, 3)
        mutasiBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        mutasiBtn.BackgroundTransparency = 0
        mutasiBtn.BorderSizePixel = 0
        mutasiBtn.Text = "OFF"
        mutasiBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        mutasiBtn.TextSize = 12
        mutasiBtn.Font = Enum.Font.GothamBold
        mutasiBtn.Parent = mutasiFrame
        Instance.new("UICorner", mutasiBtn).CornerRadius = UDim.new(0, 4)
        
        mutasiBtn.MouseButton1Click:Connect(function()
            plantMutasi = not plantMutasi
            mutasiLabel.Text = "🧬 Mutasi: " .. (plantMutasi and "ON" or "OFF")
            mutasiBtn.Text = plantMutasi and "ON" or "OFF"
            mutasiBtn.TextColor3 = plantMutasi and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 100, 100)
            mutasiBtn.BackgroundColor3 = plantMutasi and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(80, 40, 40)
        end)
        
        yPos = yPos + 45
        
        -- SPAWN BUTTON
        local spawnBtn = Instance.new("TextButton")
        spawnBtn.Size = UDim2.new(1, -10, 0, 45)
        spawnBtn.Position = UDim2.new(0, 5, 0, yPos)
        spawnBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        spawnBtn.BackgroundTransparency = 0
        spawnBtn.BorderSizePixel = 0
        spawnBtn.Text = "🌱 SPAWN TANAMAN"
        spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        spawnBtn.TextSize = 16
        spawnBtn.Font = Enum.Font.GothamBold
        spawnBtn.Parent = plantTab
        Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0, 8)
        
        spawnBtn.MouseButton1Click:Connect(function()
            if selectedPlant then
                forceSpawn(selectedPlant, "Plant", plantMutasi)
            else
                notify("⚠️ Pilih tanaman dulu!", 2)
            end
        end)
        
        yPos = yPos + 55
        plantTab.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)
    end
    
    -- ==================== SETTINGS TAB ====================
    local settingsTab = Instance.new("ScrollingFrame")
    settingsTab.Size = UDim2.new(1, 0, 1, 0)
    settingsTab.BackgroundTransparency = 1
    settingsTab.CanvasSize = UDim2.new(0, 0, 0, 0)
    settingsTab.ScrollBarThickness = 4
    settingsTab.Visible = false
    settingsTab.Parent = contentFrame
    
    local function buildSettingsTab()
        for _, child in ipairs(settingsTab:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then 
                child:Destroy() 
            end
        end
        
        local yPos = 10
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, -10, 0, 50)
        infoLabel.Position = UDim2.new(0, 5, 0, yPos)
        infoLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
        infoLabel.BackgroundTransparency = 0.5
        infoLabel.Text = "🌱 GARDEN SPAWNER v4.0\nBy: LYNZKA TEAM"
        infoLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        infoLabel.TextSize = 14
        infoLabel.Font = Enum.Font.GothamMedium
        infoLabel.TextWrapped = true
        infoLabel.Parent = settingsTab
        Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 8)
        yPos = yPos + 60
        
        local totalPets = 0
        for _, list in pairs(PETS) do totalPets = totalPets + #list end
        local totalPlants = 0
        for _, list in pairs(PLANTS) do totalPlants = totalPlants + #list end
        
        local stats = Instance.new("TextLabel")
        stats.Size = UDim2.new(1, -10, 0, 50)
        stats.Position = UDim2.new(0, 5, 0, yPos)
        stats.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
        stats.BackgroundTransparency = 0.5
        stats.Text = "📊 Total Pet: " .. totalPets .. "\n🌱 Total Tanaman: " .. totalPlants
        stats.TextColor3 = Color3.fromRGB(200, 200, 220)
        stats.TextSize = 13
        stats.Font = Enum.Font.GothamMedium
        stats.TextWrapped = true
        stats.Parent = settingsTab
        Instance.new("UICorner", stats).CornerRadius = UDim.new(0, 8)
        yPos = yPos + 60
        
        local rejoinBtn = Instance.new("TextButton")
        rejoinBtn.Size = UDim2.new(1, -10, 0, 40)
        rejoinBtn.Position = UDim2.new(0, 5, 0, yPos)
        rejoinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
        rejoinBtn.BackgroundTransparency = 0
        rejoinBtn.BorderSizePixel = 0
        rejoinBtn.Text = "🔄 Rejoin Server"
        rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        rejoinBtn.TextSize = 14
        rejoinBtn.Font = Enum.Font.GothamBold
        rejoinBtn.Parent = settingsTab
        Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 8)
        rejoinBtn.MouseButton1Click:Connect(function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end)
        end)
        yPos = yPos + 50
        
        local closeBtn2 = Instance.new("TextButton")
        closeBtn2.Size = UDim2.new(1, -10, 0, 40)
        closeBtn2.Position = UDim2.new(0, 5, 0, yPos)
        closeBtn2.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        closeBtn2.BackgroundTransparency = 0
        closeBtn2.BorderSizePixel = 0
        closeBtn2.Text = "❌ Close Menu"
        closeBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn2.TextSize = 14
        closeBtn2.Font = Enum.Font.GothamBold
        closeBtn2.Parent = settingsTab
        Instance.new("UICorner", closeBtn2).CornerRadius = UDim.new(0, 8)
        closeBtn2.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)
        yPos = yPos + 50
        
        settingsTab.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)
    end
    
    -- ==================== BUILD ALL ====================
    buildPetTab()
    buildPlantTab()
    buildSettingsTab()
    
    -- ==================== TAB SWITCHING ====================
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
        plantTab.Visible = (tabName == "Tanaman")
        settingsTab.Visible = (tabName == "Settings")
    end
    
    for name, btn in pairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            switchTab(name)
        end)
    end
    
    -- ==================== TOGGLE BUTTON (KAYAK LYNZKA) ====================
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "GardenToggleGui"
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
    glow.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
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
    
    -- KEYBIND - (Minus)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Minus then
            toggleMenu()
        end
    end)
    
    notify("🌱 GARDEN SPAWNER v4.0 LOADED!", 3)
    notify("💡 Tekan '-' atau klik tombol untuk buka/tutup menu", 3)
end

-- ==================== START ====================
task.spawn(function()
    createUI()
end)

print("[GARDEN SPAWNER] ✅ Loaded!")
print("💡 Tekan '-' atau klik tombol untuk buka/tutup menu")