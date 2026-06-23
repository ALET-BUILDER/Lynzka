--[[
    ╔══════════════════════════════════════════╗
    ║   🌱 GAG1 HUB v5.0 - Full Cheat        ║
    ║   + Pilih Benih Kustom                 ║
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
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TextChatService = game:GetService("TextChatService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- ===================== VARIABLES =====================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ===================== NOCLIP AUTO ON =====================
local noclipConnection = nil

local function StartNoclip()
    if noclipConnection then 
        noclipConnection:Disconnect() 
        noclipConnection = nil 
    end
    
    noclipConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end

StartNoclip()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    StartNoclip()
end)

-- ===================== NOTIFICATION =====================
local function notify(text, duration)
    duration = duration or 3
    pcall(function()
        if Fluent and Fluent.Notify then
            Fluent:Notify({
                Title = "🌱 GAG1 HUB",
                Content = text,
                Duration = duration
            })
        else
            local notification = Instance.new("TextLabel")
            notification.Size = UDim2.new(0, 350, 0, 40)
            notification.Position = UDim2.new(0.5, -175, 1, -50)
            notification.BackgroundColor3 = Color3.fromRGB(20, 35, 20)
            notification.BackgroundTransparency = 0
            notification.TextColor3 = Color3.fromRGB(100, 255, 150)
            notification.Font = Enum.Font.GothamBold
            notification.TextSize = 14
            notification.Text = "🌱 GAG1: " .. text
            notification.Parent = game.CoreGui
            Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 8)
            TweenService:Create(notification, TweenInfo.new(0.5), {
                Position = UDim2.new(0.5, -175, 1, -60)
            }):Play()
            task.delay(duration, function()
                pcall(function()
                    TweenService:Create(notification, TweenInfo.new(0.4), {
                        Position = UDim2.new(0.5, -175, 1, 10)
                    }):Play()
                    task.delay(0.5, function() pcall(function() notification:Destroy() end) end)
                end)
            end)
        end
    end)
end

-- ===================== DAFTAR BENIH GAG1 =====================
-- Ini daftar benih yang umum ada di Grow A Garden 1
local seedList = {
    "Wheat Seed",
    "Carrot Seed",
    "Tomato Seed",
    "Corn Seed",
    "Pumpkin Seed",
    "Sunflower Seed",
    "Rose Seed",
    "Tulip Seed",
    "Cactus Seed",
    "Watermelon Seed",
    "Strawberry Seed",
    "Blueberry Seed",
    "Apple Seed",
    "Orange Seed",
    "Lemon Seed",
    "Grape Seed",
    "Banana Seed",
    "Mango Seed",
    "Peach Seed",
    "Pear Seed",
    "Plum Seed",
    "Cherry Seed",
    "Coconut Seed",
    "Pineapple Seed",
    "Avocado Seed",
    "Potato Seed",
    "Onion Seed",
    "Garlic Seed",
    "Pepper Seed",
    "Chili Seed"
}

-- Benih yang dipilih (default: Wheat Seed)
local selectedSeed = "Wheat Seed"
local autoBuySeeds = false
local buyLoop = nil

-- ===================== AUTO BUY SEEDS DENGAN PILIHAN =====================
local function StartBuySeeds()
    if buyLoop then task.cancel(buyLoop) end
    buyLoop = task.spawn(function()
        while autoBuySeeds do
            pcall(function()
                local shop = workspace:FindFirstChild("Shop") or ReplicatedStorage:FindFirstChild("Shop") or workspace:FindFirstChild("Store") or workspace:FindFirstChild("Market")
                
                if shop then
                    for _, item in pairs(shop:GetChildren()) do
                        -- Cari item yang sesuai dengan benih yang dipilih
                        if item:IsA("Model") or item:IsA("Folder") or item:IsA("Frame") then
                            local seedName = item.Name
                            local isMatch = false
                            
                            -- Cek apakah nama item cocok dengan benih yang dipilih
                            if seedName:lower():find(selectedSeed:lower()) then
                                isMatch = true
                            end
                            
                            -- Cek juga di child "Seed" atau "Name"
                            local seedChild = item:FindFirstChild("Seed") or item:FindFirstChild("Name") or item:FindFirstChild("ItemName")
                            if seedChild and seedChild:IsA("StringValue") then
                                if seedChild.Value:lower():find(selectedSeed:lower()) then
                                    isMatch = true
                                end
                            end
                            
                            if isMatch then
                                local buyBtn = item:FindFirstChild("BuyButton") or item:FindFirstChild("Buy") or item:FindFirstChild("Purchase") or item:FindFirstChild("BuySeed")
                                if buyBtn and buyBtn:IsA("TextButton") then
                                    buyBtn:FireServer()
                                    notify("🛒 Membeli: " .. selectedSeed, 1)
                                end
                            end
                        end
                    end
                end
                
                -- Alternative: cari di ReplicatedStorage
                local buyRemote = ReplicatedStorage:FindFirstChild("BuySeed") or ReplicatedStorage:FindFirstChild("Purchase") or ReplicatedStorage:FindFirstChild("Shop")
                if buyRemote then
                    buyRemote:FireServer(selectedSeed)
                    notify("🛒 Membeli: " .. selectedSeed, 1)
                end
                
                -- Alternative: cari di PlayerGui (Shop GUI)
                local shopGui = PlayerGui:FindFirstChild("Shop") or PlayerGui:FindFirstChild("Store") or PlayerGui:FindFirstChild("Market")
                if shopGui then
                    for _, btn in pairs(shopGui:GetDescendants()) do
                        if btn:IsA("TextButton") and (btn.Name:lower():find("buy") or btn.Name:lower():find("purchase")) then
                            local parentName = btn.Parent and btn.Parent.Name or ""
                            if parentName:lower():find(selectedSeed:lower()) or (btn.Text and btn.Text:lower():find(selectedSeed:lower())) then
                                btn:FireServer()
                                notify("🛒 Membeli: " .. selectedSeed, 1)
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- ===================== CHEAT FUNCTIONS LAINNYA =====================

-- 1. AUTO FARM (Plant, Harvest, Water)
local autoPlant = false
local autoHarvest = false
local autoWater = false
local farmLoop = nil

local function StartFarm()
    if farmLoop then task.cancel(farmLoop) end
    farmLoop = task.spawn(function()
        while autoPlant or autoHarvest or autoWater do
            pcall(function()
                local garden = Workspace:FindFirstChild("Garden") or Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Farm")
                if garden then
                    for _, plot in pairs(garden:GetChildren()) do
                        if plot:IsA("Model") or plot:IsA("Folder") then
                            if autoHarvest then
                                local plant = plot:FindFirstChild("Plant") or plot:FindFirstChild("Crop") or plot:FindFirstChild("Growing")
                                if plant then
                                    local ready = plant:FindFirstChild("Ready") or plant:FindFirstChild("Harvestable") or plant:FindFirstChild("Grown")
                                    if ready and ready.Value == true then
                                        local prompt = plot:FindFirstChildOfClass("ProximityPrompt")
                                        if prompt then
                                            prompt:InputHoldBegin()
                                            task.wait(prompt.HoldDuration or 1)
                                            prompt:InputHoldEnd()
                                        end
                                    end
                                end
                            end
                            if autoWater then
                                local plant = plot:FindFirstChild("Plant") or plot:FindFirstChild("Crop")
                                if plant then
                                    local water = plant:FindFirstChild("Water") or plant:FindFirstChild("Hydration") or plant:FindFirstChild("Moisture")
                                    if water and water.Value < 100 then
                                        local prompt = plot:FindFirstChild("WaterPrompt") or plot:FindFirstChild("Water") or plot:FindFirstChild("Watering")
                                        if prompt and prompt:IsA("ProximityPrompt") then
                                            prompt:InputHoldBegin()
                                            task.wait(prompt.HoldDuration or 1)
                                            prompt:InputHoldEnd()
                                        end
                                    end
                                end
                            end
                            if autoPlant then
                                local empty = plot:FindFirstChild("IsEmpty") or plot:FindFirstChild("Empty") or plot:FindFirstChild("Available")
                                if empty and empty.Value == true then
                                    local seed = LocalPlayer.Backpack:FindFirstChild("Seed") or LocalPlayer.Character:FindFirstChild("Seed") or LocalPlayer.Backpack:FindFirstChild("Seeds")
                                    if seed then
                                        local prompt = plot:FindFirstChildOfClass("ProximityPrompt")
                                        if prompt then
                                            prompt:InputHoldBegin()
                                            task.wait(prompt.HoldDuration or 1)
                                            prompt:InputHoldEnd()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

-- 2. AUTO SELL
local autoSell = false
local sellLoop = nil

local function StartSell()
    if sellLoop then task.cancel(sellLoop) end
    sellLoop = task.spawn(function()
        while autoSell do
            pcall(function()
                local inventory = LocalPlayer:FindFirstChild("Inventory") or PlayerGui:FindFirstChild("Inventory")
                if inventory then
                    for _, item in pairs(inventory:GetChildren()) do
                        if item:IsA("Frame") or item:IsA("ImageLabel") or item:IsA("TextButton") then
                            local sellBtn = item:FindFirstChild("SellButton") or item:FindFirstChild("Sell") or item:FindFirstChild("SellAll")
                            if sellBtn and sellBtn:IsA("TextButton") then
                                sellBtn:FireServer()
                            end
                        end
                    end
                end
                local sellRemote = ReplicatedStorage:FindFirstChild("SellItem") or ReplicatedStorage:FindFirstChild("Sell") or ReplicatedStorage:FindFirstChild("SellAll")
                if sellRemote then
                    sellRemote:FireServer()
                end
            end)
            task.wait(1.5)
        end
    end)
end

-- 3. AUTO COLLECT GEMS
local autoCollectGems = false
local gemLoop = nil

local function StartCollectGems()
    if gemLoop then task.cancel(gemLoop) end
    gemLoop = task.spawn(function()
        while autoCollectGems do
            pcall(function()
                local gems = workspace:FindFirstChild("Gems") or workspace:FindFirstChild("Collectibles") or workspace:FindFirstChild("Resources") or workspace:FindFirstChild("Currency")
                if gems then
                    for _, gem in pairs(gems:GetChildren()) do
                        if gem:IsA("Model") or gem:IsA("BasePart") or gem:IsA("Folder") then
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local gemPos = gem:FindFirstChild("Position") or gem:FindFirstChild("CFrame")
                                if gemPos then
                                    local dist = (hrp.Position - gemPos.Position).Magnitude
                                    if dist < 30 then
                                        local prompt = gem:FindFirstChildOfClass("ProximityPrompt")
                                        if prompt then
                                            prompt:InputHoldBegin()
                                            task.wait(prompt.HoldDuration or 0.5)
                                            prompt:InputHoldEnd()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- 4. AUTO FERTILIZE
local autoFertilize = false
local fertilizeLoop = nil

local function StartFertilize()
    if fertilizeLoop then task.cancel(fertilizeLoop) end
    fertilizeLoop = task.spawn(function()
        while autoFertilize do
            pcall(function()
                local garden = Workspace:FindFirstChild("Garden") or Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Farm")
                if garden then
                    for _, plot in pairs(garden:GetChildren()) do
                        if plot:IsA("Model") and plot:FindFirstChild("Plant") then
                            local plant = plot.Plant
                            local fertilize = plant:FindFirstChild("Fertilize") or plant:FindFirstChild("Fertilizer") or plant:FindFirstChild("NeedsFertilizer")
                            if fertilize and fertilize.Value == true then
                                local prompt = plot:FindFirstChild("FertilizePrompt") or plot:FindFirstChild("Fertilizer") or plot:FindFirstChild("Fertilize")
                                if prompt and prompt:IsA("ProximityPrompt") then
                                    prompt:InputHoldBegin()
                                    task.wait(prompt.HoldDuration or 1)
                                    prompt:InputHoldEnd()
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- 5. AUTO PET COLLECT
local autoPetCollect = false
local petLoop = nil

local function StartPetCollect()
    if petLoop then task.cancel(petLoop) end
    petLoop = task.spawn(function()
        while autoPetCollect do
            pcall(function()
                local pets = workspace:FindFirstChild("Pets") or workspace:FindFirstChild("Pet") or workspace:FindFirstChild("Animals") or workspace:FindFirstChild("Creatures")
                if pets then
                    for _, pet in pairs(pets:GetChildren()) do
                        if pet:IsA("Model") then
                            local prompt = pet:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                prompt:InputHoldBegin()
                                task.wait(prompt.HoldDuration or 0.5)
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end
            end)
            task.wait(1.5)
        end
    end)
end

-- 6. AUTO EGG HATCH
local autoEggHatch = false
local hatchLoop = nil

local function StartEggHatch()
    if hatchLoop then task.cancel(hatchLoop) end
    hatchLoop = task.spawn(function()
        while autoEggHatch do
            pcall(function()
                local eggs = LocalPlayer.Backpack:FindFirstChild("Eggs") or LocalPlayer.Character:FindFirstChild("Egg") or LocalPlayer.Backpack:FindFirstChild("Egg")
                if eggs then
                    for _, egg in pairs(eggs:GetChildren()) do
                        if egg:IsA("Tool") or egg:IsA("Model") then
                            local hatchBtn = egg:FindFirstChild("Hatch") or egg:FindFirstChild("Incubate") or egg:FindFirstChild("Open")
                            if hatchBtn and hatchBtn:IsA("TextButton") then
                                hatchBtn:FireServer()
                            end
                        end
                    end
                end
                local hatchRemote = ReplicatedStorage:FindFirstChild("HatchEgg") or ReplicatedStorage:FindFirstChild("Incubate") or ReplicatedStorage:FindFirstChild("OpenEgg")
                if hatchRemote then
                    hatchRemote:FireServer()
                end
            end)
            task.wait(3)
        end
    end)
end

-- 7. AUTO TRADE
local autoTrade = false
local tradeLoop = nil

local function StartTrade()
    if tradeLoop then task.cancel(tradeLoop) end
    tradeLoop = task.spawn(function()
        while autoTrade do
            pcall(function()
                local tradeSystem = ReplicatedStorage:FindFirstChild("TradeSystem") or ReplicatedStorage:FindFirstChild("Trading") or ReplicatedStorage:FindFirstChild("Trade")
                if tradeSystem then
                    tradeSystem:FireServer("RequestTrade")
                end
            end)
            task.wait(5)
        end
    end)
end

-- 8. AUTO QUEST
local autoQuest = false
local questLoop = nil

local function StartQuest()
    if questLoop then task.cancel(questLoop) end
    questLoop = task.spawn(function()
        while autoQuest do
            pcall(function()
                local questSystem = ReplicatedStorage:FindFirstChild("QuestSystem") or ReplicatedStorage:FindFirstChild("Quests") or ReplicatedStorage:FindFirstChild("Quest")
                if questSystem then
                    questSystem:FireServer("AcceptQuest")
                    task.wait(1)
                    questSystem:FireServer("CompleteQuest")
                    task.wait(1)
                    questSystem:FireServer("ClaimReward")
                end
            end)
            task.wait(10)
        end
    end)
end

-- 9. AUTO SPIN
local autoSpin = false
local spinLoop = nil

local function StartSpin()
    if spinLoop then task.cancel(spinLoop) end
    spinLoop = task.spawn(function()
        while autoSpin do
            pcall(function()
                local spinSystem = workspace:FindFirstChild("SpinWheel") or workspace:FindFirstChild("Wheel") or ReplicatedStorage:FindFirstChild("Spin")
                if spinSystem then
                    local spinBtn = spinSystem:FindFirstChild("SpinButton") or spinSystem:FindFirstChild("Spin") or spinSystem:FindFirstChild("Start")
                    if spinBtn and spinBtn:IsA("TextButton") then
                        spinBtn:FireServer()
                    end
                end
                local spinRemote = ReplicatedStorage:FindFirstChild("SpinWheel") or ReplicatedStorage:FindFirstChild("LuckySpin")
                if spinRemote then
                    spinRemote:FireServer()
                end
            end)
            task.wait(5)
        end
    end)
end

-- 10. AUTO CLAIM REWARDS
local autoClaim = false
local claimLoop = nil

local function StartClaim()
    if claimLoop then task.cancel(claimLoop) end
    claimLoop = task.spawn(function()
        while autoClaim do
            pcall(function()
                local rewards = PlayerGui:FindFirstChild("Rewards") or PlayerGui:FindFirstChild("DailyRewards") or PlayerGui:FindFirstChild("Claim")
                if rewards then
                    for _, btn in pairs(rewards:GetChildren()) do
                        if btn:IsA("TextButton") and (btn.Name:lower():find("claim") or btn.Name:lower():find("collect") or btn.Name:lower():find("reward")) then
                            btn:FireServer()
                        end
                    end
                end
                local claimRemote = ReplicatedStorage:FindFirstChild("ClaimReward") or ReplicatedStorage:FindFirstChild("DailyReward")
                if claimRemote then
                    claimRemote:FireServer()
                end
            end)
            task.wait(2)
        end
    end)
end

-- 11. AUTO TREASURE / CHEST
local autoTreasure = false
local treasureLoop = nil

local function StartTreasure()
    if treasureLoop then task.cancel(treasureLoop) end
    treasureLoop = task.spawn(function()
        while autoTreasure do
            pcall(function()
                local treasures = workspace:FindFirstChild("Treasures") or workspace:FindFirstChild("Chests") or workspace:FindFirstChild("Loot")
                if treasures then
                    for _, chest in pairs(treasures:GetChildren()) do
                        if chest:IsA("Model") or chest:IsA("BasePart") then
                            local prompt = chest:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                prompt:InputHoldBegin()
                                task.wait(prompt.HoldDuration or 1)
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- 12. AUTO FISHING
local autoFish = false
local fishLoop = nil

local function StartFish()
    if fishLoop then task.cancel(fishLoop) end
    fishLoop = task.spawn(function()
        while autoFish do
            pcall(function()
                local fishing = workspace:FindFirstChild("Fishing") or workspace:FindFirstChild("Fish") or workspace:FindFirstChild("FishingSpot")
                if fishing then
                    local prompt = fishing:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration or 2)
                        prompt:InputHoldEnd()
                    end
                end
                local fishRemote = ReplicatedStorage:FindFirstChild("Fish") or ReplicatedStorage:FindFirstChild("CatchFish")
                if fishRemote then
                    fishRemote:FireServer()
                end
            end)
            task.wait(3)
        end
    end)
end

-- 13. AUTO MINING
local autoMine = false
local mineLoop = nil

local function StartMine()
    if mineLoop then task.cancel(mineLoop) end
    mineLoop = task.spawn(function()
        while autoMine do
            pcall(function()
                local mines = workspace:FindFirstChild("Mines") or workspace:FindFirstChild("Mining") or workspace:FindFirstChild("Ores")
                if mines then
                    for _, rock in pairs(mines:GetChildren()) do
                        if rock:IsA("Model") or rock:IsA("BasePart") then
                            local prompt = rock:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                prompt:InputHoldBegin()
                                task.wait(prompt.HoldDuration or 2)
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- 14. AUTO CRAFTING
local autoCraft = false
local craftLoop = nil

local function StartCraft()
    if craftLoop then task.cancel(craftLoop) end
    craftLoop = task.spawn(function()
        while autoCraft do
            pcall(function()
                local craftSystem = ReplicatedStorage:FindFirstChild("CraftSystem") or ReplicatedStorage:FindFirstChild("Crafting") or ReplicatedStorage:FindFirstChild("Craft")
                if craftSystem then
                    craftSystem:FireServer("Craft")
                end
            end)
            task.wait(5)
        end
    end)
end

-- 15. AUTO COOKING
local autoCook = false
local cookLoop = nil

local function StartCook()
    if cookLoop then task.cancel(cookLoop) end
    cookLoop = task.spawn(function()
        while autoCook do
            pcall(function()
                local cookSystem = ReplicatedStorage:FindFirstChild("CookSystem") or ReplicatedStorage:FindFirstChild("Cooking") or ReplicatedStorage:FindFirstChild("Cook")
                if cookSystem then
                    cookSystem:FireServer("Cook")
                end
            end)
            task.wait(5)
        end
    end)
end

-- 16. AUTO BREEDING
local autoBreed = false
local breedLoop = nil

local function StartBreed()
    if breedLoop then task.cancel(breedLoop) end
    breedLoop = task.spawn(function()
        while autoBreed do
            pcall(function()
                local breedSystem = ReplicatedStorage:FindFirstChild("BreedSystem") or ReplicatedStorage:FindFirstChild("Breeding") or ReplicatedStorage:FindFirstChild("Breed")
                if breedSystem then
                    breedSystem:FireServer("Breed")
                end
            end)
            task.wait(10)
        end
    end)
end

-- 17. AUTO BATTLE / COMBAT
local autoBattle = false
local battleLoop = nil

local function StartBattle()
    if battleLoop then task.cancel(battleLoop) end
    battleLoop = task.spawn(function()
        while autoBattle do
            pcall(function()
                local battleSystem = workspace:FindFirstChild("BattleSystem") or workspace:FindFirstChild("Battle") or workspace:FindFirstChild("Enemies")
                if battleSystem then
                    for _, enemy in pairs(battleSystem:GetChildren()) do
                        if enemy:IsA("Model") then
                            local prompt = enemy:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                prompt:InputHoldBegin()
                                task.wait(prompt.HoldDuration or 0.5)
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- 18. AUTO BOSS
local autoBoss = false
local bossLoop = nil

local function StartBoss()
    if bossLoop then task.cancel(bossLoop) end
    bossLoop = task.spawn(function()
        while autoBoss do
            pcall(function()
                local bossSystem = workspace:FindFirstChild("BossSystem") or workspace:FindFirstChild("Bosses") or workspace:FindFirstChild("Boss")
                if bossSystem then
                    for _, boss in pairs(bossSystem:GetChildren()) do
                        if boss:IsA("Model") then
                            local prompt = boss:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                prompt:InputHoldBegin()
                                task.wait(prompt.HoldDuration or 1)
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- 19. AUTO DUNGEON
local autoDungeon = false
local dungeonLoop = nil

local function StartDungeon()
    if dungeonLoop then task.cancel(dungeonLoop) end
    dungeonLoop = task.spawn(function()
        while autoDungeon do
            pcall(function()
                local dungeonSystem = ReplicatedStorage:FindFirstChild("DungeonSystem") or ReplicatedStorage:FindFirstChild("Dungeons") or ReplicatedStorage:FindFirstChild("Dungeon")
                if dungeonSystem then
                    dungeonSystem:FireServer("EnterDungeon")
                end
            end)
            task.wait(10)
        end
    end)
end

-- 20. AUTO RAID
local autoRaid = false
local raidLoop = nil

local function StartRaid()
    if raidLoop then task.cancel(raidLoop) end
    raidLoop = task.spawn(function()
        while autoRaid do
            pcall(function()
                local raidSystem = ReplicatedStorage:FindFirstChild("RaidSystem") or ReplicatedStorage:FindFirstChild("Raids") or ReplicatedStorage:FindFirstChild("Raid")
                if raidSystem then
                    raidSystem:FireServer("StartRaid")
                end
            end)
            task.wait(15)
        end
    end)
end

-- 21. AUTO EVENT
local autoEvent = false
local eventLoop = nil

local function StartEvent()
    if eventLoop then task.cancel(eventLoop) end
    eventLoop = task.spawn(function()
        while autoEvent do
            pcall(function()
                local eventSystem = workspace:FindFirstChild("EventSystem") or workspace:FindFirstChild("Events") or workspace:FindFirstChild("Event")
                if eventSystem then
                    for _, event in pairs(eventSystem:GetChildren()) do
                        if event:IsA("Model") or event:IsA("BasePart") then
                            local prompt = event:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                prompt:InputHoldBegin()
                                task.wait(prompt.HoldDuration or 1)
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- 22. AUTO TELEPORT TO GARDEN
local autoTeleport = false
local tpLoop = nil

local function StartTeleport()
    if tpLoop then task.cancel(tpLoop) end
    tpLoop = task.spawn(function()
        while autoTeleport do
            pcall(function()
                local garden = Workspace:FindFirstChild("Garden") or Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Farm")
                if garden then
                    local center = garden:FindFirstChild("Center") or garden:FindFirstChild("Spawn")
                    if center and center:IsA("BasePart") then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = center.CFrame + Vector3.new(0, 5, 0)
                        end
                    end
                end
            end)
            task.wait(10)
        end
    end)
end

-- 23. AUTO REJOIN
local autoRejoin = false
local rejoinConnection = nil

local function ToggleAutoRejoin(state)
    autoRejoin = state
    if rejoinConnection then 
        rejoinConnection:Disconnect() 
        rejoinConnection = nil 
    end
    if state then
        rejoinConnection = GuiService.ErrorMessageChanged:Connect(function(msg)
            if msg and msg ~= "" then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end
        end)
        notify("🔄 Auto Rejoin ON", 2)
    else
        notify("🔄 Auto Rejoin OFF", 2)
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

if FluentLoaded then
    Window = Fluent:CreateWindow({
        Title = "🌱 GAG1 HUB",
        SubTitle = "v5.0 - Pilih Benih",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 520),
        Theme = "Dark",
        MinimizeKeyBind = nil
    })

    Tabs = {
        Farm = Window:AddTab({ Title = "🌱 Farm", Icon = "lucide-sprout" }),
        Collect = Window:AddTab({ Title = "💰 Collect", Icon = "lucide-gem" }),
        Pets = Window:AddTab({ Title = "🐾 Pets", Icon = "lucide-dog" }),
        Battle = Window:AddTab({ Title = "⚔️ Battle", Icon = "lucide-swords" }),
        Misc = Window:AddTab({ Title = "🎮 Misc", Icon = "lucide-gamepad-2" }),
        Settings = Window:AddTab({ Title = "⚙️ Settings", Icon = "lucide-settings" })
    }

    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("GAG1Hub")
    SaveManager:SetFolder("GAG1Hub/Configs")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- ===================== FARM TAB =====================
    
    Tabs.Farm:AddToggle("AutoPlant", {
        Title = "🌱 Auto Plant",
        Description = "Tanam benih otomatis",
        Default = false,
        Callback = function(state)
            autoPlant = state
            if state then task.spawn(StartFarm) notify("🌱 Auto Plant ON", 2) else notify("🌱 Auto Plant OFF", 2) end
        end
    })

    Tabs.Farm:AddToggle("AutoHarvest", {
        Title = "🌾 Auto Harvest",
        Description = "Panen tanaman otomatis",
        Default = false,
        Callback = function(state)
            autoHarvest = state
            if state then task.spawn(StartFarm) notify("🌾 Auto Harvest ON", 2) else notify("🌾 Auto Harvest OFF", 2) end
        end
    })

    Tabs.Farm:AddToggle("AutoWater", {
        Title = "💧 Auto Water",
        Description = "Siram tanaman otomatis",
        Default = false,
        Callback = function(state)
            autoWater = state
            if state then task.spawn(StartFarm) notify("💧 Auto Water ON", 2) else notify("💧 Auto Water OFF", 2) end
        end
    })

    Tabs.Farm:AddToggle("AutoFertilize", {
        Title = "🧪 Auto Fertilize",
        Description = "Pupuk tanaman otomatis",
        Default = false,
        Callback = function(state)
            autoFertilize = state
            if state then task.spawn(StartFertilize) notify("🧪 Auto Fertilize ON", 2) else notify("🧪 Auto Fertilize OFF", 2) end
        end
    })

    Tabs.Farm:AddToggle("AutoSell", {
        Title = "💰 Auto Sell",
        Description = "Jual hasil panen otomatis",
        Default = false,
        Callback = function(state)
            autoSell = state
            if state then task.spawn(StartSell) notify("💰 Auto Sell ON", 2) else notify("💰 Auto Sell OFF", 2) end
        end
    })

    -- ===== AUTO BUY SEEDS DENGAN DROPDOWN PILIHAN =====
    Tabs.Farm:AddToggle("AutoBuySeeds", {
        Title = "🛒 Auto Buy Seeds",
        Description = "Beli benih pilihan otomatis",
        Default = false,
        Callback = function(state)
            autoBuySeeds = state
            if state then 
                task.spawn(StartBuySeeds) 
                notify("🛒 Auto Buy " .. selectedSeed .. " ON", 2) 
            else 
                notify("🛒 Auto Buy OFF", 2) 
            end
        end
    })

    -- DROPDOWN PILIH BENIH (seperti menu ORI)
    Tabs.Farm:AddDropdown("SeedSelector", {
        Title = "🌱 Pilih Benih",
        Description = "Pilih benih yang ingin dibeli",
        Values = seedList,
        Multi = false,
        Default = "Wheat Seed",
        Callback = function(value)
            selectedSeed = value
            notify("🌱 Benih dipilih: " .. value, 2)
        end
    })

    Tabs.Farm:AddToggle("AutoTeleport", {
        Title = "📍 Auto Teleport to Garden",
        Description = "Teleport ke kebun otomatis",
        Default = false,
        Callback = function(state)
            autoTeleport = state
            if state then task.spawn(StartTeleport) notify("📍 Auto Teleport ON", 2) else notify("📍 Auto Teleport OFF", 2) end
        end
    })

    -- ===================== COLLECT TAB =====================
    
    Tabs.Collect:AddToggle("AutoCollectGems", {
        Title = "💎 Auto Collect Gems",
        Description = "Kumpulkan permata otomatis",
        Default = false,
        Callback = function(state)
            autoCollectGems = state
            if state then task.spawn(StartCollectGems) notify("💎 Auto Collect Gems ON", 2) else notify("💎 Auto Collect Gems OFF", 2) end
        end
    })

    Tabs.Collect:AddToggle("AutoTreasure", {
        Title = "🎁 Auto Treasure/Chest",
        Description = "Buka harta karun otomatis",
        Default = false,
        Callback = function(state)
            autoTreasure = state
            if state then task.spawn(StartTreasure) notify("🎁 Auto Treasure ON", 2) else notify("🎁 Auto Treasure OFF", 2) end
        end
    })

    Tabs.Collect:AddToggle("AutoClaim", {
        Title = "🎯 Auto Claim Rewards",
        Description = "Klaim reward otomatis",
        Default = false,
        Callback = function(state)
            autoClaim = state
            if state then task.spawn(StartClaim) notify("🎯 Auto Claim ON", 2) else notify("🎯 Auto Claim OFF", 2) end
        end
    })

    Tabs.Collect:AddToggle("AutoSpin", {
        Title = "🎰 Auto Spin Wheel",
        Description = "Putar roda keberuntungan otomatis",
        Default = false,
        Callback = function(state)
            autoSpin = state
            if state then task.spawn(StartSpin) notify("🎰 Auto Spin ON", 2) else notify("🎰 Auto Spin OFF", 2) end
        end
    })

    -- ===================== PETS TAB =====================
    
    Tabs.Pets:AddToggle("AutoPetCollect", {
        Title = "🐾 Auto Pet Collect",
        Description = "Kumpulkan hewan peliharaan otomatis",
        Default = false,
        Callback = function(state)
            autoPetCollect = state
            if state then task.spawn(StartPetCollect) notify("🐾 Auto Pet Collect ON", 2) else notify("🐾 Auto Pet Collect OFF", 2) end
        end
    })

    Tabs.Pets:AddToggle("AutoEggHatch", {
        Title = "🥚 Auto Egg Hatch",
        Description = "Tetas telur otomatis",
        Default = false,
        Callback = function(state)
            autoEggHatch = state
            if state then task.spawn(StartEggHatch) notify("🥚 Auto Egg Hatch ON", 2) else notify("🥚 Auto Egg Hatch OFF", 2) end
        end
    })

    Tabs.Pets:AddToggle("AutoBreed", {
        Title = "🧬 Auto Breed",
        Description = "Breeding hewan otomatis",
        Default = false,
        Callback = function(state)
            autoBreed = state
            if state then task.spawn(StartBreed) notify("🧬 Auto Breed ON", 2) else notify("🧬 Auto Breed OFF", 2) end
        end
    })

    Tabs.Pets:AddToggle("AutoTrade", {
        Title = "🔄 Auto Trade",
        Description = "Trade otomatis dengan player lain",
        Default = false,
        Callback = function(state)
            autoTrade = state
            if state then task.spawn(StartTrade) notify("🔄 Auto Trade ON", 2) else notify("🔄 Auto Trade OFF", 2) end
        end
    })

    -- ===================== BATTLE TAB =====================
    
    Tabs.Battle:AddToggle("AutoBattle", {
        Title = "⚔️ Auto Battle",
        Description = "Serang musuh otomatis",
        Default = false,
        Callback = function(state)
            autoBattle = state
            if state then task.spawn(StartBattle) notify("⚔️ Auto Battle ON", 2) else notify("⚔️ Auto Battle OFF", 2) end
        end
    })

    Tabs.Battle:AddToggle("AutoBoss", {
        Title = "👹 Auto Boss",
        Description = "Serang boss otomatis",
        Default = false,
        Callback = function(state)
            autoBoss = state
            if state then task.spawn(StartBoss) notify("👹 Auto Boss ON", 2) else notify("👹 Auto Boss OFF", 2) end
        end
    })

    Tabs.Battle:AddToggle("AutoDungeon", {
        Title = "🏰 Auto Dungeon",
        Description = "Masuk dungeon otomatis",
        Default = false,
        Callback = function(state)
            autoDungeon = state
            if state then task.spawn(StartDungeon) notify("🏰 Auto Dungeon ON", 2) else notify("🏰 Auto Dungeon OFF", 2) end
        end
    })

    Tabs.Battle:AddToggle("AutoRaid", {
        Title = "⚡ Auto Raid",
        Description = "Mulai raid otomatis",
        Default = false,
        Callback = function(state)
            autoRaid = state
            if state then task.spawn(StartRaid) notify("⚡ Auto Raid ON", 2) else notify("⚡ Auto Raid OFF", 2) end
        end
    })

    -- ===================== MISC TAB =====================
    
    Tabs.Misc:AddToggle("AutoQuest", {
        Title = "📋 Auto Quest",
        Description = "Kerjakan quest otomatis",
        Default = false,
        Callback = function(state)
            autoQuest = state
            if state then task.spawn(StartQuest) notify("📋 Auto Quest ON", 2) else notify("📋 Auto Quest OFF", 2) end
        end
    })

    Tabs.Misc:AddToggle("AutoFish", {
        Title = "🎣 Auto Fish",
        Description = "Memancing otomatis",
        Default = false,
        Callback = function(state)
            autoFish = state
            if state then task.spawn(StartFish) notify("🎣 Auto Fish ON", 2) else notify("🎣 Auto Fish OFF", 2) end
        end
    })

    Tabs.Misc:AddToggle("AutoMine", {
        Title = "⛏️ Auto Mine",
        Description = "Menambang otomatis",
        Default = false,
        Callback = function(state)
            autoMine = state
            if state then task.spawn(StartMine) notify("⛏️ Auto Mine ON", 2) else notify("⛏️ Auto Mine OFF", 2) end
        end
    })

    Tabs.Misc:AddToggle("AutoCraft", {
        Title = "🔨 Auto Craft",
        Description = "Craft item otomatis",
        Default = false,
        Callback = function(state)
            autoCraft = state
            if state then task.spawn(StartCraft) notify("🔨 Auto Craft ON", 2) else notify("🔨 Auto Craft OFF", 2) end
        end
    })

    Tabs.Misc:AddToggle("AutoCook", {
        Title = "🍳 Auto Cook",
        Description = "Masak otomatis",
        Default = false,
        Callback = function(state)
            autoCook = state
            if state then task.spawn(StartCook) notify("🍳 Auto Cook ON", 2) else notify("🍳 Auto Cook OFF", 2) end
        end
    })

    Tabs.Misc:AddToggle("AutoEvent", {
        Title = "🎪 Auto Event",
        Description = "Ikuti event otomatis",
        Default = false,
        Callback = function(state)
            autoEvent = state
            if state then task.spawn(StartEvent) notify("🎪 Auto Event ON", 2) else notify("🎪 Auto Event OFF", 2) end
        end
    })

    -- ===================== SETTINGS TAB =====================
    
    Tabs.Settings:AddToggle("AutoRejoin", {
        Title = "🔄 Auto Rejoin on Kick",
        Description = "Otomatis join ulang saat di kick",
        Default = false,
        Callback = function(state)
            ToggleAutoRejoin(state)
        end
    })

    Tabs.Settings:AddButton({
        Title = "🔁 Rejoin",
        Description = "Join ulang ke server yang sama",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            notify("🔄 Rejoining...", 2)
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
        Title = "🚀 FPS Boost",
        Description = "Optimasi performa",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/NumanTF3/roblox-fpsboost-script/refs/heads/main/main.lua'))()
            notify("🚀 FPS Boost Applied!", 2)
        end
    })

    Tabs.Settings:AddButton({
        Title = "📐 Center GUI",
        Description = "Posisikan menu di tengah",
        Callback = function()
            if Window and Window.Root then
                Window.Root.Position = UDim2.new(0.5, -290, 0.5, -260)
                notify("📐 GUI Centered!", 2)
            end
        end
    })

    Tabs.Settings:AddParagraph({
        Title = "🚫 NOCLIP STATUS",
        Content = "Noclip AKTIF secara otomatis!\nTidak bisa dimatikan."
    })

    Window:SelectTab("Farm")
    notify("🌱 GAG1 HUB v5.0 Loaded! + Pilih Benih", 4)
end

-- ===================== TOMBOL MENU =====================
task.spawn(function()
    local waitCount = 0
    while not Window or not Window.Root and waitCount < 50 do
        task.wait(0.2)
        waitCount = waitCount + 1
    end
    
    if not Window or not Window.Root then
        print("[GAG1] Gagal menemukan Window.Root!")
        return
    end
    
    local oldGui = CoreGui:FindFirstChild("GAG1ToggleGui")
    if oldGui then oldGui:Destroy() end
    
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "GAG1ToggleGui"
    toggleGui.ResetOnSpawn = false
    toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleGui.Parent = CoreGui
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ToggleFrame"
    buttonFrame.Size = UDim2.new(0, 44, 0, 44)
    buttonFrame.Position = UDim2.new(0, 12, 0, 80)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 45, 25)
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
    glow.BackgroundColor3 = Color3.fromRGB(80, 255, 130)
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
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 55, 30)
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
    tooltip.BackgroundColor3 = Color3.fromRGB(20, 35, 20)
    tooltip.BackgroundTransparency = 0.3
    tooltip.BorderSizePixel = 0
    tooltip.Text = "GAG1"
    tooltip.TextColor3 = Color3.fromRGB(150, 255, 200)
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
            buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 45, 25)
            glow.BackgroundColor3 = Color3.fromRGB(80, 255, 130)
            glow.BackgroundTransparency = 0.7
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            tooltip.Text = "GAG1"
        else
            toggleButton.Text = "+"
            buttonFrame.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
            glow.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            glow.BackgroundTransparency = 0.6
            toggleButton.TextColor3 = Color3.fromRGB(255, 200, 200)
            tooltip.Text = "GAG1"
        end
    end
    
    local drag = { dragging = false, startPos = nil, startMouse = nil, isDragging = false }
    
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
                _G.GAG1ButtonPos = { X = newX, Y = newY }
            end
        end
    end)
    
    toggleButton.MouseEnter:Connect(function()
        tooltip.Visible = true
        if menuVisible then
            buttonFrame.BackgroundColor3 = Color3.fromRGB(45, 75, 45)
            glow.BackgroundTransparency = 0.4
        else
            buttonFrame.BackgroundColor3 = Color3.fromRGB(75, 35, 35)
            glow.BackgroundTransparency = 0.3
        end
    end)
    
    toggleButton.MouseLeave:Connect(function()
        tooltip.Visible = false
        if menuVisible then
            buttonFrame.BackgroundColor3 = Color3.fromRGB(25, 45, 25)
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
    
    if _G.GAG1ButtonPos then
        buttonFrame.Position = UDim2.new(0, _G.GAG1ButtonPos.X, 0, _G.GAG1ButtonPos.Y)
    end
    
    print("[GAG1 HUB] ✅ Tombol menu siap!")
end)

print("[GAG1 HUB v5.0] ✅ Loaded successfully!")
print("🌱 25+ Cheat Features + Pilih Benih")
print("🚫 NOCLIP AUTO ON")
print("💡 Klik '-' atau tekan '-' di keyboard untuk toggle menu")