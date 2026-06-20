-- ========== ROYZSTECU KEY SYSTEM + AUTO LOADER (Hardcoded Key) ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Key yang valid (hardcoded)
local VALID_KEY = "Lynzka x Cheat"

-- Fungsi verifikasi key sederhana
local function verifyKey(key)
    if key == "" then
        return false, "Key tidak boleh kosong."
    end
    if key == VALID_KEY then
        return true, "Akses diberikan."
    else
        return false, "Key salah! Masukkan key yang benar."
    end
end

-- Fungsi load cheat utama (dari GitHub)
local function loadCheat()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/GALAXY-IP/Cheat/main/AllGame.lua"))()
    end)
    if not success then
        warn(result)
        return false
    end
    return true
end

-- GUI login (sama persis, tidak ada perubahan)
local function createLoginGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RoyzLoginUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 260)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundTransparency = 0.08
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(Color3.fromRGB(35, 35, 55), Color3.fromRGB(18, 18, 28))
    gradient.Parent = MainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Lynzka x Cheat ⚡"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = MainFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Masukkan Key Premium"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 220)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 14
    subtitle.Parent = MainFrame

    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(0.8, 0, 0, 45)
    KeyBox.Position = UDim2.new(0.1, 0, 0, 100)
    KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.TextSize = 16
    KeyBox.PlaceholderText = "Masukkan key di sini"
    KeyBox.Text = ""
    KeyBox.Parent = MainFrame
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 12)

    local loginButton = Instance.new("TextButton")
    loginButton.Size = UDim2.new(0.8, 0, 0, 45)
    loginButton.Position = UDim2.new(0.1, 0, 0, 160)
    loginButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    loginButton.Text = "🔓 LOGIN"
    loginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginButton.Font = Enum.Font.GothamBold
    loginButton.TextSize = 18
    loginButton.Parent = MainFrame
    Instance.new("UICorner", loginButton).CornerRadius = UDim.new(0, 12)

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(0.9, 0, 0, 40)
    MessageLabel.Position = UDim2.new(0.05, 0, 0, 215)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = "Menunggu input key..."
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 12
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = MainFrame

    loginButton.MouseButton1Click:Connect(function()
        local key = KeyBox.Text
        if key == "" then
            MessageLabel.Text = "⚠️ Key tidak boleh kosong!"
            return
        end
        MessageLabel.Text = "⏳ Memverifikasi key..."
        MessageLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        loginButton.Visible = false

        local valid, msg = verifyKey(key)
        if valid then
            MessageLabel.Text = "✅ " .. msg
            MessageLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            task.wait(0.5)
            MessageLabel.Text = "🚀 Memuat cheat..."
            task.wait(0.3)
            ScreenGui:Destroy()
            local loaded = loadCheat()
            if not loaded then
                warn("Gagal memuat cheat!")
            end
        else
            MessageLabel.Text = "❌ " .. msg
            MessageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            loginButton.Visible = true
        end
    end)
end

createLoginGUI()