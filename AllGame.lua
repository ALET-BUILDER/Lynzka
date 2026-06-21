-- ========== ROYZSTECU EVIL AI - FINAL (Fix Health + Remove Teleport + Fix Hitbox + Loading + Modern UI) ==========
local _P=game:GetService("Players") local _RS=game:GetService("RunService")
local _UI=game:GetService("UserInputService") local _Cam=workspace.CurrentCamera
local _LP=_P.LocalPlayer

-- ===== LOADING SCREEN =====
local function showLoading()
    local sg = Instance.new("ScreenGui")
    sg.Name = "LoadingScreen"
    sg.Parent = game.CoreGui
    sg.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    frame.Parent = sg
    frame.ZIndex = 999
    
    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 300, 0, 200)
    center.Position = UDim2.new(0.5, -150, 0.5, -100)
    center.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    center.BorderSizePixel = 0
    center.Parent = frame
    Instance.new("UICorner", center).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🎯 v2.5 |  Lynzka x Cheat"
    title.TextColor3 = Color3.fromRGB(150, 150, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = center
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0, 0, 0, 60)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Loading..."
    loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
    loadingText.TextSize = 14
    loadingText.Font = Enum.Font.Gotham
    loadingText.Parent = center
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.8, 0, 0, 8)
    barBg.Position = UDim2.new(0.1, 0, 0, 100)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    barBg.BorderSizePixel = 0
    barBg.Parent = center
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    bar.BorderSizePixel = 0
    bar.Parent = barBg
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
    
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, 0, 0, 20)
    progressText.Position = UDim2.new(0, 0, 0, 115)
    progressText.BackgroundTransparency = 1
    progressText.Text = "0%"
    progressText.TextColor3 = Color3.fromRGB(150, 150, 200)
    progressText.TextSize = 11
    progressText.Font = Enum.Font.Gotham
    progressText.Parent = center
    
    -- Animate loading
    local steps = 30
    for i = 1, steps do
        local progress = i / steps
        bar.Size = UDim2.new(progress, 0, 1, 0)
        progressText.Text = math.floor(progress * 100) .. "%"
        if i % 3 == 0 then
            local dots = ("."):rep((i % 6) + 1)
            loadingText.Text = "Loading" .. dots
        end
        task.wait(0.05)
    end
    
    loadingText.Text = "Loaded!"
    task.wait(0.3)
    sg:Destroy()
end

showLoading()

-- ===== VARIABLES =====
local _teleportCooldown = false
local _lastTeleportTime = 0
local _bypassEnabled = false
local _bypassActive = false
local _savedStates = {}
local _bypassTimer = nil
local _speedActive = false
local _speedValue = 0
local _antiSS = false

-- Config
local _cfg={
    e=false, n=false, h=false, tc=false, ae=false, fov=500, sf=false, 
    tk=true, hb="Head", cd=Color3.fromRGB(255,255,255), cf=Color3.fromRGB(255,255,255), 
    tr=false, spd=0, spdEn=false, dist=false, distColor=Color3.fromRGB(255,255,0), 
    distSize=11, holo=false, holoColor=Color3.fromRGB(0,255,0), holoNeon=false,
    -- Settings
    themeColor = Color3.fromRGB(100, 150, 255)
}
local _alias={
    ESP_Enabled="e", ESP_Names="n", ESP_Health="h", ESP_TeamColor="tc",
    Aim_Enabled="ae", Aim_FOV="fov", Aim_ShowFOV="sf", Aim_TeamCheck="tk",
    Aim_Hitbox="hb", Tracer="tr", Speed="spd", SpeedEnabled="spdEn",
    ESP_Distance="dist", DistColor="distColor", DistSize="distSize",
    Hologram="holo", HoloColor="holoColor", HoloNeon="holoNeon"
}
local function _get(k) return _cfg[_alias[k] or k] end
local function _set(k,v) _cfg[_alias[k] or k]=v end
local function _tog(k) _set(k, not _get(k)) end

-- ===== ANTI SS =====
local function applyAntiSS()
    local visible = not _antiSS
    for _, d in pairs(_pool) do
        pcall(function() d.Visible = visible end)
    end
    for _, line in pairs(_tracers) do
        pcall(function() line.Visible = visible end)
    end
    if _sg then _sg.Enabled = visible end
end

-- ===== EMERGENCY OFF =====
local function _emergencyOff()
    if _bypassActive then return end
    _savedStates = {
        e = _cfg.e, n = _cfg.n, h = _cfg.h, tc = _cfg.tc,
        ae = _cfg.ae, tr = _cfg.tr, spdEn = _cfg.spdEn
    }
    _cfg.e = false; _cfg.ae = false; _cfg.tr = false; _cfg.spdEn = false
    _cfg.n = false; _cfg.h = false; _cfg.tc = false
    _bypassActive = true
    if _G._refreshAllToggles then _G._refreshAllToggles() end
    if _bypassTimer then _bypassTimer:Disconnect() end
    _bypassTimer = _RS.Stepped:Connect(function()
        task.wait(60)
        if _bypassActive then
            _cfg.e = _savedStates.e; _cfg.n = _savedStates.n; _cfg.h = _savedStates.h; _cfg.tc = _savedStates.tc
            _cfg.ae = _savedStates.ae; _cfg.tr = _savedStates.tr; _cfg.spdEn = _savedStates.spdEn
            _bypassActive = false
            if _G._refreshAllToggles then _G._refreshAllToggles() end
            _tl.Text = "🎯 Bypass ended - Features restored"
            task.wait(2)
            _tl.Text = "🎯 v2.5 | Lynzka x Cheat"
        end
        _bypassTimer:Disconnect()
        _bypassTimer = nil
    end)
end

-- ===== ALL OFF =====
local function _allOff()
    _cfg.e = false; _cfg.n = false; _cfg.h = false; _cfg.tc = false
    _cfg.ae = false; _cfg.tr = false; _cfg.spdEn = false
    _cfg.spd = 0
    if _G._refreshAllToggles then _G._refreshAllToggles() end
    _tl.Text = "All cheats disabled. Toggle ON to reactivate"
    task.wait(2)
    _tl.Text = "🎯 v2.5 | Lynzka x Cheat"
end

-- ===== BASIC FUNCTIONS =====
local function _alive(p) local c=p.Character if not c then return false end local h=c:FindFirstChildOfClass("Humanoid") return h and h.Health>0 end
local function _hp(p) local c=p.Character if not c then return 0,100 end local h=c:FindFirstChildOfClass("Humanoid") if not h then return 0,100 end return math.floor(h.Health),math.floor(h.MaxHealth) end
local function _tc(p) if _get("ESP_TeamColor") and p.Team then return p.Team.TeamColor.Color end return Color3.fromRGB(255,255,255) end
local function _st(p) return _LP.Team and p.Team and _LP.Team==p.Team end
local function _w2s(pos) local s,on=_Cam:WorldToViewportPoint(pos) return Vector2.new(s.X,s.Y),on end

local function _bbox(char)
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head and not hrp then return nil end
    local topPart = head or hrp
    local bottomPart = hrp or head
    local topPos, topOn = _w2s(topPart.Position + Vector3.new(0, 1.2, 0))
    local bottomPos, bottomOn = _w2s(bottomPart.Position - Vector3.new(0, 2, 0))
    if not topOn and not bottomOn then return nil end
    local left = math.min(topPos.X, bottomPos.X)
    local right = math.max(topPos.X, bottomPos.X)
    local top = math.min(topPos.Y, bottomPos.Y)
    local bottom = math.max(topPos.Y, bottomPos.Y)
    local width = math.max(right - left, 30)
    local height = math.max(bottom - top, 40)
    return {x0 = left, y0 = top, x1 = left + width, y1 = top + height}
end

local _pool={} local _rc=nil local _ic={} local _pc={} local _esp={} local _tracers={}
local _holos={}
local function _nd(t,pr) local d=Drawing.new(t) for k,v in pairs(pr) do d[k]=v end d.Visible=false table.insert(_pool,d) return d end
local function _ri(c) table.insert(_ic,c) return c end

local function _nuke()
    if _rc then _rc:Disconnect() end
    for _,c in ipairs(_ic) do pcall(c.Disconnect,c) end
    for _,c in ipairs(_pc) do pcall(c.Disconnect,c) end
    for _,d in ipairs(_pool) do pcall(d.Remove,d) end
    _pool={}
    for _,line in pairs(_tracers) do pcall(line.Remove,line) end
    _tracers={}
    local g=game.CoreGui:FindFirstChild("__hud") if g then g:Destroy() end
end

local function _mkEsp(p)
    _esp[p]={t=_nd("Line",{Thickness=1,ZIndex=1}),b=_nd("Line",{Thickness=1,ZIndex=1}),l=_nd("Line",{Thickness=1,ZIndex=1}),r=_nd("Line",{Thickness=1,ZIndex=1}),nm=_nd("Text",{Size=13,Center=true,Outline=true,Font=Drawing.Fonts.UI,ZIndex=2}),hp=_nd("Text",{Size=12,Center=true,Outline=true,Font=Drawing.Fonts.UI,ZIndex=2}),dist=_nd("Text",{Size=11,Center=true,Outline=true,Font=Drawing.Fonts.UI,ZIndex=2})}
    _tracers[p]=_nd("Line",{Thickness=2,Color=Color3.fromRGB(255,0,0),ZIndex=3})
end
local function _rmEsp(p) 
    local o=_esp[p] if o then for _,d in pairs(o) do pcall(d.Remove,d) end end 
    _esp[p]=nil
    if _tracers[p] then pcall(_tracers[p].Remove,_tracers[p]) _tracers[p]=nil end
end
local function _hide(o) for _,d in pairs(o) do d.Visible=false end end

local _fc=_nd("Circle",{Thickness=1,Filled=false,Color=_cfg.cf,NumSides=64,ZIndex=10})

-- ===== HOLOGRAM =====
local function _updateHologram(p)
    if not _get("Hologram") or _bypassActive or _antiSS then
        if _holos[p] then
            _holos[p]:Destroy()
            _holos[p]=nil
        end
        return
    end
    local char = p.Character
    if not char then
        if _holos[p] then _holos[p]:Destroy() _holos[p]=nil end
        return
    end
    if not _holos[p] then
        local hl = Instance.new("Highlight")
        hl.Name = "ROYZ_HOLO"
        hl.Parent = char
        hl.Adornee = char
        hl.FillTransparency = 0.6
        hl.OutlineTransparency = 0.2
        _holos[p] = hl
    end
    local col = _get("HoloColor")
    _holos[p].FillColor = col
    _holos[p].OutlineColor = col
end

local function _removeHologram(p)
    if _holos[p] then
        _holos[p]:Destroy()
        _holos[p]=nil
    end
end

-- ===== AIMBOT (FIXED HITBOX) =====
local function _best()
    local ctr=Vector2.new(_Cam.ViewportSize.X/2,_Cam.ViewportSize.Y/2)
    local best,bd=nil,_get("Aim_FOV")
    local hitboxMode = _get("Aim_Hitbox")
    for _,p in ipairs(_P:GetPlayers()) do
        if p==_LP then continue end if not _alive(p) then continue end
        if _get("Aim_TeamCheck") and _st(p) then continue end
        local ch=p.Character if not ch then continue end
        local targetParts = {}
        if hitboxMode == "Head" then
            targetParts = {ch:FindFirstChild("Head")}
        elseif hitboxMode == "Neck" then
            targetParts = {ch:FindFirstChild("Neck") or ch:FindFirstChild("UpperTorso")}
        elseif hitboxMode == "UpperTorso" then
            targetParts = {ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("HumanoidRootPart")}
        elseif hitboxMode == "LowerTorso" then
            -- FIXED: Use LowerTorso or HumanoidRootPart
            targetParts = {ch:FindFirstChild("LowerTorso") or ch:FindFirstChild("HumanoidRootPart")}
        elseif hitboxMode == "All" then
            targetParts = {ch:FindFirstChild("Head"), ch:FindFirstChild("Neck"), ch:FindFirstChild("UpperTorso"), ch:FindFirstChild("LowerTorso"), ch:FindFirstChild("HumanoidRootPart")}
        else
            targetParts = {ch:FindFirstChild("Head")}
        end
        local bestPart = nil
        local bestDist = _get("Aim_FOV")
        for _, pt in ipairs(targetParts) do
            if pt then
                local s,on = _w2s(pt.Position)
                if on then
                    local d = (s-ctr).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestPart = pt
                    end
                end
            end
        end
        if bestPart then
            local d = bestDist
            if d < bd then
                bd = d
                best = bestPart
            end
        end
    end
    return best
end

-- ===== SPEED HACK =====
local speedLoopConnection = nil

local function applySpeed()
    if not _get("SpeedEnabled") or _bypassActive then
        if speedLoopConnection then
            speedLoopConnection:Disconnect()
            speedLoopConnection = nil
        end
        local hum = _LP.Character and _LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
        return
    end
    
    local val = _get("Speed")
    local ws = 16
    if val > 0 then ws = 16 + (val * 6)
    elseif val < 0 then ws = 16 + (val * 2.5)
    end
    ws = math.clamp(ws, 8, 120)
    
    local hum = _LP.Character and _LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = ws
        if speedLoopConnection then speedLoopConnection:Disconnect() end
        speedLoopConnection = _RS.Heartbeat:Connect(function()
            if _get("SpeedEnabled") and not _bypassActive and hum and hum.Parent then
                if hum.WalkSpeed ~= ws then
                    hum.WalkSpeed = ws
                end
            else
                if speedLoopConnection then speedLoopConnection:Disconnect() end
                speedLoopConnection = nil
            end
        end)
    end
end

-- ===== ADMIN DETECT =====
local function _checkAdmin()
    if not _bypassEnabled then return end
    for _, p in ipairs(_P:GetPlayers()) do
        if p ~= _LP then
            local name = p.Name:lower()
            if name:find("admin") or name:find("mod") or name:find("staff") or name:find("owner") then
                if not _bypassActive then
                    _emergencyOff()
                    _tl.Text = "⚠️ Admin detected! Bypass activated - All cheats disabled for 60s"
                end
                break
            end
        end
    end
end

_P.PlayerAdded:Connect(function(p) task.wait(1) _checkAdmin() end)
task.spawn(function() while true do task.wait(5) _checkAdmin() end end)

-- ===== RENDER STEPPED =====
_rc=_RS.RenderStepped:Connect(function()
    local vp=_Cam.ViewportSize
    _fc.Position=Vector2.new(vp.X/2,vp.Y/2) _fc.Radius=_get("Aim_FOV") _fc.Visible=_get("Aim_Enabled") and _get("Aim_ShowFOV") and not _antiSS
    if _get("Aim_Enabled") and not _bypassActive and not _antiSS then
        local targetPart=_best()
        if targetPart then
            local cp=_Cam.CFrame.Position
            local dir=(targetPart.Position-cp).Unit
            _Cam.CFrame=CFrame.new(cp, cp+dir)
        end
    end
    applySpeed()
    for _,p in ipairs(_P:GetPlayers()) do
        _updateHologram(p)
        if p==_LP then 
            if _esp[p] then _hide(_esp[p]) end
            if _tracers[p] then _tracers[p].Visible=false end
            continue 
        end
        if not _esp[p] then _mkEsp(p) end
        local o=_esp[p]; local tracerLine=_tracers[p]
        if not _get("ESP_Enabled") or not _alive(p) or _bypassActive or _antiSS then 
            _hide(o); if tracerLine then tracerLine.Visible=false end
            continue 
        end
        local ch=p.Character if not ch then _hide(o); if tracerLine then tracerLine.Visible=false end continue end
        local bx=_bbox(ch) if not bx then _hide(o); if tracerLine then tracerLine.Visible=false end continue end
        local col=_tc(p)
        local function _sl(ln,x0,y0,x1,y1) ln.From=Vector2.new(x0,y0) ln.To=Vector2.new(x1,y1) ln.Color=col ln.Visible=true end
        _sl(o.t,bx.x0,bx.y0,bx.x1,bx.y0) _sl(o.b,bx.x0,bx.y1,bx.x1,bx.y1)
        _sl(o.l,bx.x0,bx.y0,bx.x0,bx.y1) _sl(o.r,bx.x1,bx.y0,bx.x1,bx.y1)
        o.nm.Text=p.Name o.nm.Position=Vector2.new((bx.x0+bx.x1)/2,bx.y0-15) o.nm.Color=col o.nm.Visible=_get("ESP_Names")
        
        -- FIXED: ESP Health - Always green, decreases when damaged
        local hp,mhp=_hp(p)
        local healthPercent = hp/mhp
        -- Green color that stays green but with slight variation
        local greenHealth = Color3.fromRGB(
            math.floor(255 * (1 - healthPercent * 0.3)),
            math.floor(255 * (0.6 + healthPercent * 0.4)),
            math.floor(100 * healthPercent + 50)
        )
        o.hp.Text=hp.."/"..mhp 
        o.hp.Position=Vector2.new((bx.x0+bx.x1)/2,bx.y0-27) 
        o.hp.Color=greenHealth
        o.hp.Visible=_get("ESP_Health")
        
        if _get("ESP_Distance") and not _bypassActive and not _antiSS then
            local myPos = _LP.Character and _LP.Character:FindFirstChild("HumanoidRootPart") and _LP.Character.HumanoidRootPart.Position
            local targetPos = ch:FindFirstChild("HumanoidRootPart") and ch.HumanoidRootPart.Position
            if myPos and targetPos then
                local distStuds = (myPos - targetPos).Magnitude
                local distMeters = distStuds * 0.28
                o.dist.Text = string.format("%.1f m", distMeters)
                o.dist.Position = Vector2.new((bx.x0+bx.x1)/2, bx.y1 + 12)
                o.dist.Color = _get("DistColor")
                o.dist.Size = _get("DistSize")
                o.dist.Visible = true
            else
                o.dist.Visible = false
            end
        else
            o.dist.Visible = false
        end
        if _get("Tracer") and not _bypassActive and not _antiSS and bx then
            local footPos=Vector2.new((bx.x0+bx.x1)/2, bx.y1)
            local bottomCenter=Vector2.new(vp.X/2, vp.Y)
            tracerLine.From=footPos; tracerLine.To=bottomCenter; tracerLine.Color=col; tracerLine.Visible=true
        elseif tracerLine then tracerLine.Visible=false end
    end
end)

-- ===== HOLOGRAM NEON =====
if _get("Hologram") and not _bypassActive and not _antiSS then
    if _get("HoloNeon") then
        local hue = (tick() * 0.5) % 1
        local neonCol = Color3.fromHSV(hue, 1, 1)
        _set("HoloColor", neonCol)
    end
    _updateHologram(p)
else
    _removeHologram(p)
end

table.insert(_pc,_P.PlayerAdded:Connect(_mkEsp))
table.insert(_pc,_P.PlayerRemoving:Connect(_rmEsp))

-- =============================================
-- ===== MODERN GUI MENU =====
-- =============================================

local _sg=Instance.new("ScreenGui") _sg.Name="__hud" _sg.ResetOnSpawn=false _sg.Parent=game.CoreGui

-- Main Frame
local _mf=Instance.new("Frame") 
_mf.Size=UDim2.new(0,320,0,0) 
_mf.AutomaticSize=Enum.AutomaticSize.Y 
_mf.Position=UDim2.new(0,20,0.5,-150) 
_mf.BackgroundColor3=Color3.fromRGB(14, 14, 28) 
_mf.BorderSizePixel=0 
_mf.Active=true 
_mf.Draggable=true 
_mf.Parent=_sg
Instance.new("UICorner",_mf).CornerRadius=UDim.new(0,10)

-- Shadow/Glow effect
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.Position = UDim2.new(0, 2, 0, 2)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.ZIndex = 0
shadow.Parent = _mf
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 10)

-- Header
local _tb=Instance.new("Frame") 
_tb.Size=UDim2.new(1,0,0,36) 
_tb.BackgroundColor3=Color3.fromRGB(24, 24, 44) 
_tb.BorderSizePixel=0 
_tb.Parent=_mf
Instance.new("UICorner",_tb).CornerRadius=UDim.new(0,10)

-- Title
local _tl=Instance.new("TextLabel") 
_tl.Size=UDim2.new(1,-120,1,0) 
_tl.Position=UDim2.new(0,10,0,0) 
_tl.BackgroundTransparency=1 
_tl.Text="🎯 v2.5 | Lynzka x Cheat" 
_tl.TextColor3=Color3.fromRGB(200, 200, 255) 
_tl.TextSize=12 
_tl.Font=Enum.Font.GothamBold 
_tl.TextXAlignment=Enum.TextXAlignment.Left 
_tl.Parent=_tb

-- Button: Minimize (-)
local _minBtn=Instance.new("TextButton") 
_minBtn.Size=UDim2.new(0,28,0,28) 
_minBtn.Position=UDim2.new(1,-96,0,4) 
_minBtn.BackgroundColor3=Color3.fromRGB(50, 50, 80) 
_minBtn.Text="−" 
_minBtn.TextColor3=Color3.fromRGB(255,255,255) 
_minBtn.TextSize=18 
_minBtn.Font=Enum.Font.GothamBold 
_minBtn.BorderSizePixel=0 
_minBtn.Parent=_tb
Instance.new("UICorner",_minBtn).CornerRadius=UDim.new(0,14)

-- Button: Info (i)
local _infoBtn=Instance.new("TextButton") 
_infoBtn.Size=UDim2.new(0,28,0,28) 
_infoBtn.Position=UDim2.new(1,-64,0,4) 
_infoBtn.BackgroundColor3=Color3.fromRGB(40, 60, 120) 
_infoBtn.Text="i" 
_infoBtn.TextColor3=Color3.fromRGB(255,255,255) 
_infoBtn.TextSize=14 
_infoBtn.Font=Enum.Font.GothamBold 
_infoBtn.BorderSizePixel=0 
_infoBtn.Parent=_tb
Instance.new("UICorner",_infoBtn).CornerRadius=UDim.new(0,14)

-- Button: Settings (⚙)
local _settingsBtn=Instance.new("TextButton") 
_settingsBtn.Size=UDim2.new(0,28,0,28) 
_settingsBtn.Position=UDim2.new(1,-32,0,4) 
_settingsBtn.BackgroundColor3=Color3.fromRGB(60, 60, 100) 
_settingsBtn.Text="⚙" 
_settingsBtn.TextColor3=Color3.fromRGB(255,255,255) 
_settingsBtn.TextSize=14 
_settingsBtn.Font=Enum.Font.GothamBold 
_settingsBtn.BorderSizePixel=0 
_settingsBtn.Parent=_tb
Instance.new("UICorner",_settingsBtn).CornerRadius=UDim.new(0,14)

-- Scrolling Frame (content)
local _sc=Instance.new("ScrollingFrame") 
_sc.Size=UDim2.new(1,0,0,320) 
_sc.Position=UDim2.new(0,0,0,36) 
_sc.BackgroundTransparency=1 
_sc.BorderSizePixel=0 
_sc.ScrollBarThickness=4 
_sc.ScrollBarImageColor3=Color3.fromRGB(80, 80, 140) 
_sc.CanvasSize=UDim2.new(0,0,0,0) 
_sc.AutomaticCanvasSize=Enum.AutomaticSize.Y 
_sc.Parent=_mf

local _sl2=Instance.new("UIListLayout",_sc) 
_sl2.Padding=UDim.new(0,4) 
_sl2.SortOrder=Enum.SortOrder.LayoutOrder
local _sp=Instance.new("UIPadding",_sc) 
_sp.PaddingLeft=UDim.new(0,8) 
_sp.PaddingRight=UDim.new(0,8) 
_sp.PaddingTop=UDim.new(0,6) 
_sp.PaddingBottom=UDim.new(0,6)

-- ===== MENU BUILDING FUNCTIONS =====
local _ord=0
local _allToggleButtons = {}
local menuExpanded = true
local menuVisible = true

local function _sec(nm)
    _ord=_ord+1
    local l=Instance.new("TextLabel") 
    l.Size=UDim2.new(1,0,0,24) 
    l.BackgroundColor3=Color3.fromRGB(28, 28, 48) 
    l.Text="  "..nm 
    l.TextColor3=Color3.fromRGB(140, 140, 210) 
    l.TextSize=11 
    l.Font=Enum.Font.GothamBold 
    l.TextXAlignment=Enum.TextXAlignment.Left 
    l.BorderSizePixel=0 
    l.LayoutOrder=_ord 
    l.Parent=_sc
    Instance.new("UICorner",l).CornerRadius=UDim.new(0,6)
end

local function _tgg(lbl,key,cb)
    _ord=_ord+1
    local row=Instance.new("Frame") 
    row.Size=UDim2.new(1,0,0,26) 
    row.BackgroundTransparency=1 
    row.LayoutOrder=_ord 
    row.Parent=_sc
    
    local tx=Instance.new("TextLabel") 
    tx.Size=UDim2.new(1,-50,1,0) 
    tx.BackgroundTransparency=1 
    tx.Text=lbl 
    tx.TextColor3=Color3.fromRGB(200,200,200) 
    tx.TextSize=12 
    tx.Font=Enum.Font.Gotham 
    tx.TextXAlignment=Enum.TextXAlignment.Left 
    tx.Parent=row
    
    local bt=Instance.new("TextButton") 
    bt.Size=UDim2.new(0,38,0,18) 
    bt.Position=UDim2.new(1,-42,0.5,-9) 
    bt.BorderSizePixel=0 
    bt.Font=Enum.Font.GothamBold 
    bt.TextSize=10 
    bt.Parent=row
    Instance.new("UICorner",bt).CornerRadius=UDim.new(0,9)
    
    local function rf() 
        local on = _get(key)
        if _bypassActive then on = false end
        bt.Text=on and"ON"or"OFF"
        bt.BackgroundColor3=on and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50)
    end
    rf()
    _allToggleButtons[key] = bt
    bt.MouseButton1Click:Connect(function() 
        if _bypassActive then return end
        _tog(key); rf(); if cb then cb(_get(key)) end
    end)
end

local function _fovButtons()
    _ord=_ord+1
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,34) row.BackgroundTransparency=1 row.LayoutOrder=_ord row.Parent=_sc
    local label=Instance.new("TextLabel") label.Size=UDim2.new(0.5,0,1,0) label.BackgroundTransparency=1 label.Text="FOV: ".._get("Aim_FOV") label.TextColor3=Color3.fromRGB(200,200,200) label.TextSize=12 label.Font=Enum.Font.Gotham label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=row
    local minus=Instance.new("TextButton") minus.Size=UDim2.new(0,32,0,24) minus.Position=UDim2.new(0.7,0,0.5,-12) minus.Text="-" minus.BackgroundColor3=Color3.fromRGB(180,50,50) minus.TextColor3=Color3.fromRGB(255,255,255) minus.Font=Enum.Font.GothamBold minus.TextSize=16 minus.Parent=row Instance.new("UICorner",minus).CornerRadius=UDim.new(0,6)
    local plus=Instance.new("TextButton") plus.Size=UDim2.new(0,32,0,24) plus.Position=UDim2.new(0.85,0,0.5,-12) plus.Text="+" plus.BackgroundColor3=Color3.fromRGB(50,180,90) plus.TextColor3=Color3.fromRGB(255,255,255) plus.Font=Enum.Font.GothamBold plus.TextSize=16 plus.Parent=row Instance.new("UICorner",plus).CornerRadius=UDim.new(0,6)
    local function upd(v) if _bypassActive then return end v=math.clamp(v,50,900) _set("Aim_FOV",v) label.Text="FOV: "..v end
    minus.MouseButton1Click:Connect(function() upd(_get("Aim_FOV")-10) end)
    plus.MouseButton1Click:Connect(function() upd(_get("Aim_FOV")+10) end)
end

local function _hbpick()
    _ord=_ord+1
    local opts={"Head","Neck","UpperTorso","LowerTorso","All"}
    local displayNames = {"Kepala","Leher","Badan","Kaki","All Lock"}
    local ct=Instance.new("Frame") ct.Size=UDim2.new(1,0,0,0) ct.AutomaticSize=Enum.AutomaticSize.Y ct.BackgroundColor3=Color3.fromRGB(20,20,34) ct.BorderSizePixel=0 ct.LayoutOrder=_ord ct.Parent=_sc
    Instance.new("UICorner",ct).CornerRadius=UDim.new(0,6)
    local pd=Instance.new("UIPadding",ct) pd.PaddingLeft=UDim.new(0,6) pd.PaddingRight=UDim.new(0,6) pd.PaddingTop=UDim.new(0,6) pd.PaddingBottom=UDim.new(0,6)
    local gd=Instance.new("UIGridLayout",ct) gd.CellSize=UDim2.new(0.5,-4,0,24) gd.CellPadding=UDim2.new(0,4,0,4) gd.SortOrder=Enum.SortOrder.LayoutOrder
    local bs={}
    for i=1,#opts do
        local pn = opts[i]
        local dn = displayNames[i]
        local bt=Instance.new("TextButton") bt.Size=UDim2.new(1,0,1,0) bt.BackgroundColor3=Color3.fromRGB(45,45,70) bt.Text=dn bt.TextColor3=Color3.fromRGB(180,180,255) bt.TextSize=10 bt.Font=Enum.Font.Gotham bt.BorderSizePixel=0 bt.LayoutOrder=i bt.Parent=ct
        Instance.new("UICorner",bt).CornerRadius=UDim.new(0,4) bs[pn]=bt
        bt.MouseButton1Click:Connect(function()
            if _bypassActive then return end
            _set("Aim_Hitbox",pn)
            for _,b in pairs(bs) do b.BackgroundColor3=Color3.fromRGB(45,45,70) b.TextColor3=Color3.fromRGB(180,180,255) end
            bt.BackgroundColor3=Color3.fromRGB(90,130,255) bt.TextColor3=Color3.fromRGB(255,255,255)
        end)
    end
    local current = _get("Aim_Hitbox")
    if bs[current] then
        bs[current].BackgroundColor3=Color3.fromRGB(90,130,255)
        bs[current].TextColor3=Color3.fromRGB(255,255,255)
    end
end

-- ===== ESP DISTANCE SETTINGS =====
local function _distSettings()
    _ord = _ord + 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = Color3.fromRGB(20,20,34)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = _ord
    frame.Parent = _sc
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
    
    local padding = Instance.new("UIPadding", frame)
    padding.PaddingLeft = UDim.new(0,6)
    padding.PaddingRight = UDim.new(0,6)
    padding.PaddingTop = UDim.new(0,4)
    padding.PaddingBottom = UDim.new(0,4)
    
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0,4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Toggle
    local rowToggle=Instance.new("Frame") rowToggle.Size=UDim2.new(1,0,0,24) rowToggle.BackgroundTransparency=1 rowToggle.Parent=frame
    local txToggle=Instance.new("TextLabel") txToggle.Size=UDim2.new(1,-45,1,0) txToggle.BackgroundTransparency=1 txToggle.Text="ESP Jarak" txToggle.TextColor3=Color3.fromRGB(200,200,200) txToggle.TextSize=12 txToggle.Font=Enum.Font.Gotham txToggle.TextXAlignment=Enum.TextXAlignment.Left txToggle.Parent=rowToggle
    local btToggle=Instance.new("TextButton") btToggle.Size=UDim2.new(0,35,0,16) btToggle.Position=UDim2.new(1,-39,0.5,-8) btToggle.BorderSizePixel=0 btToggle.Font=Enum.Font.GothamBold btToggle.TextSize=10 btToggle.Parent=rowToggle
    Instance.new("UICorner",btToggle).CornerRadius=UDim.new(0,8)
    local function rfToggle() local on = _get("ESP_Distance") and not _bypassActive btToggle.Text=on and"ON"or"OFF" btToggle.BackgroundColor3=on and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rfToggle()
    btToggle.MouseButton1Click:Connect(function() if _bypassActive then return end _tog("ESP_Distance") rfToggle() end)
    
    -- Size
    local sizeRow=Instance.new("Frame") sizeRow.Size=UDim2.new(1,0,0,28) sizeRow.BackgroundTransparency=1 sizeRow.Parent=frame
    local sizeLabel=Instance.new("TextLabel") sizeLabel.Size=UDim2.new(0.5,0,1,0) sizeLabel.BackgroundTransparency=1 sizeLabel.Text="Ukuran: ".._get("DistSize") sizeLabel.TextColor3=Color3.fromRGB(200,200,200) sizeLabel.TextSize=11 sizeLabel.Font=Enum.Font.Gotham sizeLabel.TextXAlignment=Enum.TextXAlignment.Left sizeLabel.Parent=sizeRow
    local minusSize=Instance.new("TextButton") minusSize.Size=UDim2.new(0,26,0,20) minusSize.Position=UDim2.new(0.7,0,0.5,-10) minusSize.Text="−" minusSize.BackgroundColor3=Color3.fromRGB(180,50,50) minusSize.TextColor3=Color3.fromRGB(255,255,255) minusSize.Font=Enum.Font.GothamBold minusSize.TextSize=14 minusSize.Parent=sizeRow Instance.new("UICorner",minusSize).CornerRadius=UDim.new(0,5)
    local plusSize=Instance.new("TextButton") plusSize.Size=UDim2.new(0,26,0,20) plusSize.Position=UDim2.new(0.85,0,0.5,-10) plusSize.Text="+" plusSize.BackgroundColor3=Color3.fromRGB(50,180,90) plusSize.TextColor3=Color3.fromRGB(255,255,255) plusSize.Font=Enum.Font.GothamBold plusSize.TextSize=14 plusSize.Parent=sizeRow Instance.new("UICorner",plusSize).CornerRadius=UDim.new(0,5)
    minusSize.MouseButton1Click:Connect(function() local newSize=math.max(8,_get("DistSize")-1) _set("DistSize",newSize) sizeLabel.Text="Ukuran: "..newSize end)
    plusSize.MouseButton1Click:Connect(function() local newSize=math.min(24,_get("DistSize")+1) _set("DistSize",newSize) sizeLabel.Text="Ukuran: "..newSize end)
    
    -- Color
    local colorRow=Instance.new("Frame") colorRow.Size=UDim2.new(1,0,0,26) colorRow.BackgroundTransparency=1 colorRow.Parent=frame
    local colorLabel=Instance.new("TextLabel") colorLabel.Size=UDim2.new(0.3,0,1,0) colorLabel.BackgroundTransparency=1 colorLabel.Text="Warna:" colorLabel.TextColor3=Color3.fromRGB(200,200,200) colorLabel.TextSize=11 colorLabel.Font=Enum.Font.Gotham colorLabel.TextXAlignment=Enum.TextXAlignment.Left colorLabel.Parent=colorRow
    local redBtn=Instance.new("TextButton") redBtn.Size=UDim2.new(0.18,0,0,20) redBtn.Position=UDim2.new(0.38,0,0.5,-10) redBtn.Text="🔴" redBtn.BackgroundColor3=Color3.fromRGB(60,30,30) redBtn.TextColor3=Color3.fromRGB(255,255,255) redBtn.Font=Enum.Font.GothamBold redBtn.TextSize=12 redBtn.Parent=colorRow Instance.new("UICorner",redBtn).CornerRadius=UDim.new(0,4)
    local greenBtn=Instance.new("TextButton") greenBtn.Size=UDim2.new(0.18,0,0,20) greenBtn.Position=UDim2.new(0.6,0,0.5,-10) greenBtn.Text="🟢" greenBtn.BackgroundColor3=Color3.fromRGB(30,60,30) greenBtn.TextColor3=Color3.fromRGB(255,255,255) greenBtn.Font=Enum.Font.GothamBold greenBtn.TextSize=12 greenBtn.Parent=colorRow Instance.new("UICorner",greenBtn).CornerRadius=UDim.new(0,4)
    local blueBtn=Instance.new("TextButton") blueBtn.Size=UDim2.new(0.18,0,0,20) blueBtn.Position=UDim2.new(0.82,0,0.5,-10) blueBtn.Text="🔵" blueBtn.BackgroundColor3=Color3.fromRGB(30,30,60) blueBtn.TextColor3=Color3.fromRGB(255,255,255) blueBtn.Font=Enum.Font.GothamBold blueBtn.TextSize=12 blueBtn.Parent=colorRow Instance.new("UICorner",blueBtn).CornerRadius=UDim.new(0,4)
    redBtn.MouseButton1Click:Connect(function() _set("DistColor",Color3.fromRGB(255,100,100)) end)
    greenBtn.MouseButton1Click:Connect(function() _set("DistColor",Color3.fromRGB(100,255,100)) end)
    blueBtn.MouseButton1Click:Connect(function() _set("DistColor",Color3.fromRGB(100,100,255)) end)
end

-- ===== HOLOGRAM MENU =====
local function _holoMenu()
    _ord = _ord + 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = Color3.fromRGB(20,20,34)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = _ord
    frame.Parent = _sc
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
    
    local padding = Instance.new("UIPadding", frame)
    padding.PaddingLeft = UDim.new(0,6)
    padding.PaddingRight = UDim.new(0,6)
    padding.PaddingTop = UDim.new(0,4)
    padding.PaddingBottom = UDim.new(0,4)
    
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0,4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Toggle
    local rowToggle=Instance.new("Frame") rowToggle.Size=UDim2.new(1,0,0,24) rowToggle.BackgroundTransparency=1 rowToggle.Parent=frame
    local txToggle=Instance.new("TextLabel") txToggle.Size=UDim2.new(1,-45,1,0) txToggle.BackgroundTransparency=1 txToggle.Text="Hologram" txToggle.TextColor3=Color3.fromRGB(200,200,200) txToggle.TextSize=12 txToggle.Font=Enum.Font.Gotham txToggle.TextXAlignment=Enum.TextXAlignment.Left txToggle.Parent=rowToggle
    local btToggle=Instance.new("TextButton") btToggle.Size=UDim2.new(0,35,0,16) btToggle.Position=UDim2.new(1,-39,0.5,-8) btToggle.BorderSizePixel=0 btToggle.Font=Enum.Font.GothamBold btToggle.TextSize=10 btToggle.Parent=rowToggle
    Instance.new("UICorner",btToggle).CornerRadius=UDim.new(0,8)
    local function rfToggle() local on = _get("Hologram") and not _bypassActive btToggle.Text=on and"ON"or"OFF" btToggle.BackgroundColor3=on and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rfToggle()
    btToggle.MouseButton1Click:Connect(function() if _bypassActive then return end _tog("Hologram") rfToggle() if not _get("Hologram") then for p,_ in pairs(_holos) do _removeHologram(p) end end end)
    
    -- Neon
    local rowNeon=Instance.new("Frame") rowNeon.Size=UDim2.new(1,0,0,24) rowNeon.BackgroundTransparency=1 rowNeon.Parent=frame
    local txNeon=Instance.new("TextLabel") txNeon.Size=UDim2.new(1,-45,1,0) txNeon.BackgroundTransparency=1 txNeon.Text="Neon (kelap-kelip)" txNeon.TextColor3=Color3.fromRGB(200,200,200) txNeon.TextSize=12 txNeon.Font=Enum.Font.Gotham txNeon.TextXAlignment=Enum.TextXAlignment.Left txNeon.Parent=rowNeon
    local btNeon=Instance.new("TextButton") btNeon.Size=UDim2.new(0,35,0,16) btNeon.Position=UDim2.new(1,-39,0.5,-8) btNeon.BorderSizePixel=0 btNeon.Font=Enum.Font.GothamBold btNeon.TextSize=10 btNeon.Parent=rowNeon
    Instance.new("UICorner",btNeon).CornerRadius=UDim.new(0,8)
    local function rfNeon() local on = _get("HoloNeon") btNeon.Text=on and"ON"or"OFF" btNeon.BackgroundColor3=on and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rfNeon()
    btNeon.MouseButton1Click:Connect(function() if _bypassActive then return end _tog("HoloNeon") rfNeon() end)
    
    -- Color
    local colorRow=Instance.new("Frame") colorRow.Size=UDim2.new(1,0,0,26) colorRow.BackgroundTransparency=1 colorRow.Parent=frame
    local colorLabel=Instance.new("TextLabel") colorLabel.Size=UDim2.new(0.3,0,1,0) colorLabel.BackgroundTransparency=1 colorLabel.Text="Warna:" colorLabel.TextColor3=Color3.fromRGB(200,200,200) colorLabel.TextSize=11 colorLabel.Font=Enum.Font.Gotham colorLabel.TextXAlignment=Enum.TextXAlignment.Left colorLabel.Parent=colorRow
    local redBtn=Instance.new("TextButton") redBtn.Size=UDim2.new(0.18,0,0,20) redBtn.Position=UDim2.new(0.38,0,0.5,-10) redBtn.Text="🔴" redBtn.BackgroundColor3=Color3.fromRGB(60,30,30) redBtn.TextColor3=Color3.fromRGB(255,255,255) redBtn.Font=Enum.Font.GothamBold redBtn.TextSize=12 redBtn.Parent=colorRow Instance.new("UICorner",redBtn).CornerRadius=UDim.new(0,4)
    local greenBtn=Instance.new("TextButton") greenBtn.Size=UDim2.new(0.18,0,0,20) greenBtn.Position=UDim2.new(0.6,0,0.5,-10) greenBtn.Text="🟢" greenBtn.BackgroundColor3=Color3.fromRGB(30,60,30) greenBtn.TextColor3=Color3.fromRGB(255,255,255) greenBtn.Font=Enum.Font.GothamBold greenBtn.TextSize=12 greenBtn.Parent=colorRow Instance.new("UICorner",greenBtn).CornerRadius=UDim.new(0,4)
    local blueBtn=Instance.new("TextButton") blueBtn.Size=UDim2.new(0.18,0,0,20) blueBtn.Position=UDim2.new(0.82,0,0.5,-10) blueBtn.Text="🔵" blueBtn.BackgroundColor3=Color3.fromRGB(30,30,60) blueBtn.TextColor3=Color3.fromRGB(255,255,255) blueBtn.Font=Enum.Font.GothamBold blueBtn.TextSize=12 blueBtn.Parent=colorRow Instance.new("UICorner",blueBtn).CornerRadius=UDim.new(0,4)
    redBtn.MouseButton1Click:Connect(function() _set("HoloColor",Color3.fromRGB(255,100,100)) end)
    greenBtn.MouseButton1Click:Connect(function() _set("HoloColor",Color3.fromRGB(100,255,100)) end)
    blueBtn.MouseButton1Click:Connect(function() _set("HoloColor",Color3.fromRGB(100,100,255)) end)
end

-- ===== SPEED MENU =====
local function _speedMenu()
    _ord=_ord+1
    local rowToggle=Instance.new("Frame") rowToggle.Size=UDim2.new(1,0,0,24) rowToggle.BackgroundTransparency=1 rowToggle.LayoutOrder=_ord rowToggle.Parent=_sc
    local txToggle=Instance.new("TextLabel") txToggle.Size=UDim2.new(1,-45,1,0) txToggle.BackgroundTransparency=1 txToggle.Text="Speed Hack" txToggle.TextColor3=Color3.fromRGB(200,200,200) txToggle.TextSize=12 txToggle.Font=Enum.Font.Gotham txToggle.TextXAlignment=Enum.TextXAlignment.Left txToggle.Parent=rowToggle
    local btToggle=Instance.new("TextButton") btToggle.Size=UDim2.new(0,35,0,16) btToggle.Position=UDim2.new(1,-39,0.5,-8) btToggle.BorderSizePixel=0 btToggle.Font=Enum.Font.GothamBold btToggle.TextSize=10 btToggle.Parent=rowToggle
    Instance.new("UICorner",btToggle).CornerRadius=UDim.new(0,8)
    local function rfToggle() local on = _get("SpeedEnabled") and not _bypassActive btToggle.Text=on and"ON"or"OFF" btToggle.BackgroundColor3=on and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rfToggle()
    btToggle.MouseButton1Click:Connect(function() if _bypassActive then return end _tog("SpeedEnabled") rfToggle() end)
    
    local levelRow=Instance.new("Frame") levelRow.Size=UDim2.new(1,0,0,32) levelRow.BackgroundTransparency=1 levelRow.LayoutOrder=_ord+1 levelRow.Parent=_sc
    local low=Instance.new("TextButton") low.Size=UDim2.new(0.3,0,0,24) low.Position=UDim2.new(0.02,0,0.5,-12) low.Text="Low" low.BackgroundColor3=Color3.fromRGB(60,60,80) low.TextColor3=Color3.fromRGB(255,255,255) low.Font=Enum.Font.GothamBold low.TextSize=11 low.Parent=levelRow Instance.new("UICorner",low).CornerRadius=UDim.new(0,5)
    local norm=Instance.new("TextButton") norm.Size=UDim2.new(0.3,0,0,24) norm.Position=UDim2.new(0.35,0,0.5,-12) norm.Text="Normal" norm.BackgroundColor3=Color3.fromRGB(60,60,80) norm.TextColor3=Color3.fromRGB(255,255,255) norm.Font=Enum.Font.GothamBold norm.TextSize=11 norm.Parent=levelRow Instance.new("UICorner",norm).CornerRadius=UDim.new(0,5)
    local fast=Instance.new("TextButton") fast.Size=UDim2.new(0.3,0,0,24) fast.Position=UDim2.new(0.68,0,0.5,-12) fast.Text="Fast" fast.BackgroundColor3=Color3.fromRGB(60,60,80) fast.TextColor3=Color3.fromRGB(255,255,255) fast.Font=Enum.Font.GothamBold fast.TextSize=11 fast.Parent=levelRow Instance.new("UICorner",fast).CornerRadius=UDim.new(0,5)
    local function setSpeed(val) if _bypassActive then return end _set("Speed",val) _speedValue=val _speedSlider.Text=tostring(val) end
    low.MouseButton1Click:Connect(function() setSpeed(-5) end)
    norm.MouseButton1Click:Connect(function() setSpeed(0) end)
    fast.MouseButton1Click:Connect(function() setSpeed(8) end)
    
    local sliderRow=Instance.new("Frame") sliderRow.Size=UDim2.new(1,0,0,32) sliderRow.BackgroundTransparency=1 sliderRow.LayoutOrder=_ord+2 sliderRow.Parent=_sc
    local label=Instance.new("TextLabel") label.Size=UDim2.new(0.3,0,1,0) label.BackgroundTransparency=1 label.Text="Speed Val:" label.TextColor3=Color3.fromRGB(200,200,200) label.TextSize=11 label.Font=Enum.Font.Gotham label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=sliderRow
    local _speedSlider=Instance.new("TextBox") _speedSlider.Size=UDim2.new(0.2,0,0,24) _speedSlider.Position=UDim2.new(0.35,0,0.5,-12) _speedSlider.BackgroundColor3=Color3.fromRGB(45,45,65) _speedSlider.Text=tostring(_get("Speed")) _speedSlider.TextColor3=Color3.fromRGB(255,255,255) _speedSlider.Font=Enum.Font.Gotham _speedSlider.TextSize=13 _speedSlider.Parent=sliderRow Instance.new("UICorner",_speedSlider).CornerRadius=UDim.new(0,5)
    local setBtn=Instance.new("TextButton") setBtn.Size=UDim2.new(0.2,0,0,24) setBtn.Position=UDim2.new(0.6,0,0.5,-12) setBtn.Text="Set" setBtn.BackgroundColor3=Color3.fromRGB(90,130,255) setBtn.TextColor3=Color3.fromRGB(255,255,255) setBtn.Font=Enum.Font.GothamBold setBtn.TextSize=11 setBtn.Parent=sliderRow Instance.new("UICorner",setBtn).CornerRadius=UDim.new(0,5)
    local resetBtn=Instance.new("TextButton") resetBtn.Size=UDim2.new(0.15,0,0,24) resetBtn.Position=UDim2.new(0.83,0,0.5,-12) resetBtn.Text="Reset" resetBtn.BackgroundColor3=Color3.fromRGB(180,100,50) resetBtn.TextColor3=Color3.fromRGB(255,255,255) resetBtn.Font=Enum.Font.GothamBold resetBtn.TextSize=10 resetBtn.Parent=sliderRow Instance.new("UICorner",resetBtn).CornerRadius=UDim.new(0,5)
    setBtn.MouseButton1Click:Connect(function() local num=tonumber(_speedSlider.Text) if num then num=math.clamp(num,-10,10) _set("Speed",num) _speedSlider.Text=tostring(num) else _speedSlider.Text="0" _set("Speed",0) end end)
    resetBtn.MouseButton1Click:Connect(function() _set("Speed",0) _speedSlider.Text="0" end)
    _ord=_ord+2
end

-- ===== BYPASS MENU =====
local function _bypassMenu()
    _ord=_ord+1
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,24) row.BackgroundTransparency=1 row.LayoutOrder=_ord row.Parent=_sc
    local tx=Instance.new("TextLabel") tx.Size=UDim2.new(1,-45,1,0) tx.BackgroundTransparency=1 tx.Text="Bypass Mode" tx.TextColor3=Color3.fromRGB(200,200,200) tx.TextSize=12 tx.Font=Enum.Font.Gotham tx.TextXAlignment=Enum.TextXAlignment.Left tx.Parent=row
    local bt=Instance.new("TextButton") bt.Size=UDim2.new(0,35,0,16) bt.Position=UDim2.new(1,-39,0.5,-8) bt.BorderSizePixel=0 bt.Font=Enum.Font.GothamBold bt.TextSize=10 bt.Parent=row
    Instance.new("UICorner",bt).CornerRadius=UDim.new(0,8)
    local function rf() bt.Text=_bypassEnabled and"ON"or"OFF" bt.BackgroundColor3=_bypassEnabled and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rf()
    bt.MouseButton1Click:Connect(function() _bypassEnabled = not _bypassEnabled rf() _tl.Text = _bypassEnabled and "⚠️ Bypass ENABLED" or "Bypass DISABLED" task.wait(2) _tl.Text = "🎯 v2.5 | Lynzka x Cheat" end)
end

-- ===== ANTI SS MENU =====
local function _antiSSMenu()
    _ord=_ord+1
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,24) row.BackgroundTransparency=1 row.LayoutOrder=_ord row.Parent=_sc
    local tx=Instance.new("TextLabel") tx.Size=UDim2.new(1,-45,1,0) tx.BackgroundTransparency=1 tx.Text="Anti Screenshot" tx.TextColor3=Color3.fromRGB(200,200,200) tx.TextSize=12 tx.Font=Enum.Font.Gotham tx.TextXAlignment=Enum.TextXAlignment.Left tx.Parent=row
    local bt=Instance.new("TextButton") bt.Size=UDim2.new(0,35,0,16) bt.Position=UDim2.new(1,-39,0.5,-8) bt.BorderSizePixel=0 bt.Font=Enum.Font.GothamBold bt.TextSize=10 bt.Parent=row
    Instance.new("UICorner",bt).CornerRadius=UDim.new(0,8)
    local function rf() bt.Text=_antiSS and"ON"or"OFF" bt.BackgroundColor3=_antiSS and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rf()
    bt.MouseButton1Click:Connect(function()
        _antiSS = not _antiSS
        rf()
        applyAntiSS()
        _tl.Text = _antiSS and "🔒 Anti-SS ON" or "🔓 Anti-SS OFF"
        task.wait(2)
        _tl.Text = "🎯 v2.5 | Lynzka x Cheat"
    end)
end

-- ===== BUILD MENU =====
_sec("───── ESP ──────────────")
_tgg("ESP", "ESP_Enabled")
_tgg("Names", "ESP_Names")
_tgg("HP", "ESP_Health")
_tgg("Team Color", "ESP_TeamColor")
_distSettings()
_sec("───── HOLOGRAM ─────────")
_holoMenu()
_sec("───── AIMBOT ───────────")
_tgg("Aimbot", "Aim_Enabled")
_tgg("Show FOV", "Aim_ShowFOV")
_tgg("Team Check", "Aim_TeamCheck")
_fovButtons()
_sec("───── HITBOX ───────────")
_hbpick()
_sec("───── ANTENA ───────────")
_tgg("Antena", "Tracer")
_sec("───── SPEED HACK ───────")
_speedMenu()
_sec("───── BYPASS ───────────")
_bypassMenu()
_sec("───── ANTI SS ──────────")
_antiSSMenu()
_sec("────────────────────────")

-- ALL OFF Button
local allOffBtn = Instance.new("TextButton")
allOffBtn.Size = UDim2.new(0.9,0,0,28)
allOffBtn.Position = UDim2.new(0.05,0,0,0)
allOffBtn.BackgroundColor3 = Color3.fromRGB(180,80,80)
allOffBtn.Text = "🔴 ALL OFF"
allOffBtn.TextColor3 = Color3.fromRGB(255,255,255)
allOffBtn.Font = Enum.Font.GothamBold
allOffBtn.TextSize = 13
allOffBtn.Parent = _sc
Instance.new("UICorner",allOffBtn).CornerRadius = UDim.new(0,8)
allOffBtn.LayoutOrder = _ord+1
allOffBtn.MouseButton1Click:Connect(_allOff)

-- EMERGENCY OFF Button
local emergencyBtn = Instance.new("TextButton")
emergencyBtn.Size = UDim2.new(0.9,0,0,28)
emergencyBtn.Position = UDim2.new(0.05,0,0,0)
emergencyBtn.BackgroundColor3 = Color3.fromRGB(200,70,70)
emergencyBtn.Text = "⚠️ EMERGENCY OFF (60s)"
emergencyBtn.TextColor3 = Color3.fromRGB(255,255,255)
emergencyBtn.Font = Enum.Font.GothamBold
emergencyBtn.TextSize = 11
emergencyBtn.Parent = _sc
Instance.new("UICorner",emergencyBtn).CornerRadius = UDim.new(0,8)
emergencyBtn.LayoutOrder = _ord+2
emergencyBtn.MouseButton1Click:Connect(function()
    if _bypassActive then _tl.Text = "Already in bypass mode..." return end
    _emergencyOff()
    _tl.Text = "⚠️ Emergency OFF - 60s"
end)

-- ===== REFRESH TOGGLES =====
_G._refreshAllToggles = function()
    for key, btn in pairs(_allToggleButtons) do
        local on = _get(key) and not _bypassActive
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(50,180,90) or Color3.fromRGB(180,50,50)
    end
end

-- ===== BUTTON FUNCTIONS =====

-- Minimize (-): Toggle menu expansion (show/hide content)
local function toggleMenuExpand()
    menuExpanded = not menuExpanded
    _sc.Visible = menuExpanded
    if not menuExpanded then
        _mf.Size = UDim2.new(0,320,0,36)
        _minBtn.Text = "+"
    else
        _mf.Size = UDim2.new(0,320,0,0)
        _mf.AutomaticSize = Enum.AutomaticSize.Y
        _minBtn.Text = "−"
    end
end
_minBtn.MouseButton1Click:Connect(toggleMenuExpand)

-- Info button: Show script info
local infoFrame = nil
_infoBtn.MouseButton1Click:Connect(function()
    if infoFrame and infoFrame.Parent then
        infoFrame:Destroy()
        infoFrame = nil
        return
    end
    
    infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(0,280,0,150)
    infoFrame.Position = UDim2.new(0.5,-140,0.5,-75)
    infoFrame.BackgroundColor3 = Color3.fromRGB(14,14,28)
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = _sg
    Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0,10)
    infoFrame.ZIndex = 10
    
    local shadow2 = Instance.new("Frame")
    shadow2.Size = UDim2.new(1,0,1,0)
    shadow2.Position = UDim2.new(0,2,0,2)
    shadow2.BackgroundColor3 = Color3.fromRGB(0,0,0)
    shadow2.BackgroundTransparency = 0.5
    shadow2.BorderSizePixel = 0
    shadow2.ZIndex = 0
    shadow2.Parent = infoFrame
    Instance.new("UICorner", shadow2).CornerRadius = UDim.new(0,10)
    
    local titleInfo = Instance.new("TextLabel")
    titleInfo.Size = UDim2.new(1,0,0,30)
    titleInfo.Position = UDim2.new(0,0,0,5)
    titleInfo.BackgroundTransparency = 1
    titleInfo.Text = "📋 Script Info"
    titleInfo.TextColor3 = Color3.fromRGB(150,150,255)
    titleInfo.TextSize = 16
    titleInfo.Font = Enum.Font.GothamBold
    titleInfo.Parent = infoFrame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,-20,0,100)
    text.Position = UDim2.new(0,10,0,40)
    text.BackgroundTransparency = 1
    text.Text = "Lynzka x Cheat v2.5\n\nCreator: Lynzka\n\nFeatures: ESP, Aimbot, Speed Hack,\nHologram, Tracer, Anti-SS, Bypass"
    text.TextColor3 = Color3.fromRGB(200,200,200)
    text.TextSize = 12
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.LineHeight = 1.2
    text.Parent = infoFrame
    
    local closeInfo = Instance.new("TextButton")
    closeInfo.Size = UDim2.new(0,60,0,24)
    closeInfo.Position = UDim2.new(0.5,-30,1,-34)
    closeInfo.BackgroundColor3 = Color3.fromRGB(80,80,140)
    closeInfo.Text = "Close"
    closeInfo.TextColor3 = Color3.fromRGB(255,255,255)
    closeInfo.Font = Enum.Font.GothamBold
    closeInfo.TextSize = 12
    closeInfo.Parent = infoFrame
    Instance.new("UICorner", closeInfo).CornerRadius = UDim.new(0,6)
    closeInfo.MouseButton1Click:Connect(function()
        if infoFrame then infoFrame:Destroy() infoFrame = nil end
    end)
end)

-- Settings button: Show settings popup
local settingsFrame = nil
_settingsBtn.MouseButton1Click:Connect(function()
    if settingsFrame and settingsFrame.Parent then
        settingsFrame:Destroy()
        settingsFrame = nil
        return
    end
    
    settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(0,280,0,200)
    settingsFrame.Position = UDim2.new(0.5,-140,0.5,-100)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(14,14,28)
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Parent = _sg
    Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0,10)
    settingsFrame.ZIndex = 10
    
    local shadow3 = Instance.new("Frame")
    shadow3.Size = UDim2.new(1,0,1,0)
    shadow3.Position = UDim2.new(0,2,0,2)
    shadow3.BackgroundColor3 = Color3.fromRGB(0,0,0)
    shadow3.BackgroundTransparency = 0.5
    shadow3.BorderSizePixel = 0
    shadow3.ZIndex = 0
    shadow3.Parent = settingsFrame
    Instance.new("UICorner", shadow3).CornerRadius = UDim.new(0,10)
    
    local titleSet = Instance.new("TextLabel")
    titleSet.Size = UDim2.new(1,0,0,30)
    titleSet.Position = UDim2.new(0,0,0,5)
    titleSet.BackgroundTransparency = 1
    titleSet.Text = "⚙ Settings"
    titleSet.TextColor3 = Color3.fromRGB(150,150,255)
    titleSet.TextSize = 16
    titleSet.Font = Enum.Font.GothamBold
    titleSet.Parent = settingsFrame
    
    -- Color theme picker (3 buttons)
    local colorSetLabel = Instance.new("TextLabel")
    colorSetLabel.Size = UDim2.new(0.3,0,0,24)
    colorSetLabel.Position = UDim2.new(0,10,0,40)
    colorSetLabel.BackgroundTransparency = 1
    colorSetLabel.Text = "Theme Color:"
    colorSetLabel.TextColor3 = Color3.fromRGB(200,200,200)
    colorSetLabel.TextSize = 12
    colorSetLabel.Font = Enum.Font.Gotham
    colorSetLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorSetLabel.Parent = settingsFrame
    
    local colorButtons = {}
    local colors = {
        {Color3.fromRGB(100,150,255), "🔵"},
        {Color3.fromRGB(255,100,100), "🔴"},
        {Color3.fromRGB(100,255,100), "🟢"},
        {Color3.fromRGB(255,200,50), "🟡"},
        {Color3.fromRGB(200,100,255), "🟣"}
    }
    
    for i, c in ipairs(colors) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,36,0,28)
        btn.Position = UDim2.new(0.35 + (i-1) * 0.12, 0, 0.22, 0)
        btn.BackgroundColor3 = c[1]
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = settingsFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        btn.MouseButton1Click:Connect(function()
            _cfg.themeColor = c[1]
            _tb.BackgroundColor3 = Color3.fromRGB(
                c[1].R * 0.15,
                c[1].G * 0.15,
                c[1].B * 0.15
            )
            _mf.BackgroundColor3 = Color3.fromRGB(
                c[1].R * 0.08,
                c[1].G * 0.08,
                c[1].B * 0.08
            )
            _tl.TextColor3 = Color3.fromRGB(
                200 + c[1].R * 0.2,
                200 + c[1].G * 0.2,
                200 + c[1].B * 0.2
            )
            for _, b in pairs(colorButtons) do
                b.Size = UDim2.new(0,36,0,28)
            end
            btn.Size = UDim2.new(0,40,0,32)
        end)
        table.insert(colorButtons, btn)
    end
    
    local closeSet = Instance.new("TextButton")
    closeSet.Size = UDim2.new(0,60,0,24)
    closeSet.Position = UDim2.new(0.5,-30,1,-34)
    closeSet.BackgroundColor3 = Color3.fromRGB(80,80,140)
    closeSet.Text = "Close"
    closeSet.TextColor3 = Color3.fromRGB(255,255,255)
    closeSet.Font = Enum.Font.GothamBold
    closeSet.TextSize = 12
    closeSet.Parent = settingsFrame
    Instance.new("UICorner", closeSet).CornerRadius = UDim.new(0,6)
    closeSet.MouseButton1Click:Connect(function()
        if settingsFrame then settingsFrame:Destroy() settingsFrame = nil end
    end)
end)

-- ===== HIDE/SHOW MENU (Insert) =====
_ri(_UI.InputBegan:Connect(function(i,gp)
    if not gp and i.KeyCode==Enum.KeyCode.Insert then 
        menuVisible = not menuVisible
        _mf.Visible = menuVisible
    end
end))

-- ===== CLOSE BUTTON (X) - HIDE MENU PERMANENTLY UNTIL INSERT =====
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,28,0,28)
closeBtn.Position = UDim2.new(1,-28,0,4)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = _tb
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,14)
closeBtn.MouseButton1Click:Connect(function()
    menuVisible = false
    _mf.Visible = false
    _tl.Text = "Menu hidden - Press Insert to show"
    task.wait(2)
    _tl.Text = "🎯 v2.5 | Lynzka x Cheat"
end)

print("✅ ROYZSTECU EVIL AI LOADED | Insert toggles menu | - to collapse | X to close | i for info | ⚙ for settings")