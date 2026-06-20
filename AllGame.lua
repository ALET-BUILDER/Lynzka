-- ========== ROYZSTECU EVIL AI - FINAL (Teleport Fix + Speed + All Off + Hide + AntiSS) ==========
local _P=game:GetService("Players") local _RS=game:GetService("RunService")
local _UI=game:GetService("UserInputService") local _Cam=workspace.CurrentCamera
local _LP=_P.LocalPlayer

-- Variabel teleport
local _teleportCooldown = false
local _lastTeleportTime = 0

-- Variabel bypass (emergency off)
local _bypassEnabled = false
local _bypassActive = false
local _savedStates = {}
local _bypassTimer = nil

-- Variabel speed hack
local _speedActive = false
local _speedValue = 0

-- Variabel anti screenshot
local _antiSS = false

-- Konfigurasi default (tambah speed)
local _cfg={e=false,n=false,h=false,tc=false,ae=false,fov=500,sf=false,tk=true,hb="Head",cd=Color3.fromRGB(255,255,255),cf=Color3.fromRGB(255,255,255),tr=false,tp=false,spd=0,spdEn=false,dist=false,distColor=Color3.fromRGB(255,255,0),distSize=11,holo=false,holoColor=Color3.fromRGB(0,255,0),holoNeon=false}
local _alias={ESP_Enabled="e",ESP_Names="n",ESP_Health="h",ESP_TeamColor="tc",Aim_Enabled="ae",Aim_FOV="fov",Aim_ShowFOV="sf",Aim_TeamCheck="tk",Aim_Hitbox="hb",Tracer="tr",Teleport="tp",Speed="spd",SpeedEnabled="spdEn",ESP_Distance="dist",DistColor="distColor",DistSize="distSize",Hologram="holo",HoloColor="holoColor",HoloNeon="holoNeon"}
local function _get(k) return _cfg[_alias[k] or k] end
local function _set(k,v) _cfg[_alias[k] or k]=v end
local function _tog(k) _set(k, not _get(k)) end

-- Fungsi untuk menyembunyikan/munculkan semua cheat (anti ss)
local function applyAntiSS()
    local visible = not _antiSS
    -- Sembunyikan/munculkan semua Drawing objects (ESP, tracer, FOV)
    for _, d in pairs(_pool) do
        pcall(function() d.Visible = visible end)
    end
    for _, line in pairs(_tracers) do
        pcall(function() line.Visible = visible end)
    end
    -- Sembunyikan/munculkan seluruh menu GUI
    if _sg then _sg.Enabled = visible end
    -- Jika menu sedang collapsed, mungkin perlu handle
end

-- Fungsi untuk mematikan semua cheat (emergency off, 60 detik)
local function _emergencyOff()
    if _bypassActive then return end
    _savedStates = {
        e = _cfg.e, n = _cfg.n, h = _cfg.h, tc = _cfg.tc,
        ae = _cfg.ae, tr = _cfg.tr, tp = _cfg.tp, spdEn = _cfg.spdEn
    }
    _cfg.e = false; _cfg.ae = false; _cfg.tr = false; _cfg.tp = false; _cfg.spdEn = false
    _cfg.n = false; _cfg.h = false; _cfg.tc = false
    _bypassActive = true
    if _G._refreshAllToggles then _G._refreshAllToggles() end
    if _bypassTimer then _bypassTimer:Disconnect() end
    _bypassTimer = _RS.Stepped:Connect(function()
        task.wait(60)
        if _bypassActive then
            _cfg.e = _savedStates.e; _cfg.n = _savedStates.n; _cfg.h = _savedStates.h; _cfg.tc = _savedStates.tc
            _cfg.ae = _savedStates.ae; _cfg.tr = _savedStates.tr; _cfg.tp = _savedStates.tp; _cfg.spdEn = _savedStates.spdEn
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

-- All Off: matikan semua cheat (tanpa timer)
local function _allOff()
    _cfg.e = false; _cfg.n = false; _cfg.h = false; _cfg.tc = false
    _cfg.ae = false; _cfg.tr = false; _cfg.tp = false; _cfg.spdEn = false
    _cfg.spd = 0
    if _G._refreshAllToggles then _G._refreshAllToggles() end
    _tl.Text = "All cheats disabled. Toggle ON to reactivate"
    task.wait(2)
    _tl.Text = "🎯 v2.5 | Lynzka x Cheat"
end

-- Fungsi-fungsi dasar (alive, hp, tc, st, w2s, bbox) - tidak berubah
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
local _holos={}  -- untuk menyimpan Highlight per player
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

-- Hologram (Highlight) management
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
    -- Jika neon aktif, warna akan diupdate di RenderStepped
end

local function _removeHologram(p)
    if _holos[p] then
        _holos[p]:Destroy()
        _holos[p]=nil
    end
end

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

-- Fungsi speed hack
-- Fungsi speed hack yang lebih kuat dengan loop pemulihan
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
    
    -- Ambil nilai speed dari config
    local val = _get("Speed")
    local ws = 16
    if val > 0 then ws = 16 + (val * 6)   -- 10 -> 76
    elseif val < 0 then ws = 16 + (val * 2.5) -- -10 -> -9, minimal 8
    end
    ws = math.clamp(ws, 8, 120) -- Maksimal 120 (lebih cepat)
    
    local hum = _LP.Character and _LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = ws
        -- Matikan loop yang sudah ada (jika ada)
        if speedLoopConnection then speedLoopConnection:Disconnect() end
        -- Buat loop pemulihan setiap 0.2 detik
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

-- Deteksi admin
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

-- RenderStepped
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
        local hp,mhp=_hp(p)
        o.hp.Text=hp.."/"..mhp o.hp.Position=Vector2.new((bx.x0+bx.x1)/2,bx.y0-27) o.hp.Color=Color3.fromRGB(math.floor(255*(1-hp/mhp)),math.floor(255*(hp/mhp)),0) o.hp.Visible=_get("ESP_Health")
        -- ESP Jarak (Distance)
-- ESP Jarak (Distance) dalam meter
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

-- Update hologram (Highlight) setiap frame untuk efek neon
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

-- GUI Menu
local _sg=Instance.new("ScreenGui") _sg.Name="__hud" _sg.ResetOnSpawn=false _sg.Parent=game.CoreGui
local _mf=Instance.new("Frame") _mf.Size=UDim2.new(0,300,0,36) _mf.AutomaticSize=Enum.AutomaticSize.Y _mf.Position=UDim2.new(0,20,0.5,-150) _mf.BackgroundColor3=Color3.fromRGB(18,18,24) _mf.BorderSizePixel=0 _mf.Active=true _mf.Draggable=true _mf.Parent=_sg
Instance.new("UICorner",_mf).CornerRadius=UDim.new(0,8)
local _tb=Instance.new("Frame") _tb.Size=UDim2.new(1,0,0,32) _tb.BackgroundColor3=Color3.fromRGB(30,30,40) _tb.BorderSizePixel=0 _tb.Parent=_mf
Instance.new("UICorner",_tb).CornerRadius=UDim.new(0,8)
local _tl=Instance.new("TextLabel") _tl.Size=UDim2.new(1,-40,1,0) _tl.Position=UDim2.new(0,10,0,0) _tl.BackgroundTransparency=1 _tl.Text="🎯 v2.5 | Lynzka x Cheat" _tl.TextColor3=Color3.fromRGB(220,220,255) _tl.TextSize=13 _tl.Font=Enum.Font.GothamBold _tl.TextXAlignment=Enum.TextXAlignment.Left _tl.Parent=_tb

-- Tombol header diganti dengan logo 🌐 bulat
local _hb=Instance.new("TextButton") 
_hb.Size=UDim2.new(0,30,0,30) 
_hb.Position=UDim2.new(1,-35,0,1) 
_hb.BackgroundColor3=Color3.fromRGB(60,60,90) 
_hb.Text="🌐" 
_hb.TextColor3=Color3.fromRGB(255,255,255) 
_hb.TextSize=20 
_hb.Font=Enum.Font.GothamBold 
_hb.BorderSizePixel=0 
_hb.Parent=_tb
Instance.new("UICorner",_hb).CornerRadius=UDim.new(0,15)  -- membuat bulat

local _sc=Instance.new("ScrollingFrame") _sc.Size=UDim2.new(1,0,0,280) _sc.Position=UDim2.new(0,0,0,36) _sc.BackgroundTransparency=1 _sc.BorderSizePixel=0 _sc.ScrollBarThickness=4 _sc.ScrollBarImageColor3=Color3.fromRGB(100,100,160) _sc.CanvasSize=UDim2.new(0,0,0,0) _sc.AutomaticCanvasSize=Enum.AutomaticSize.Y _sc.Parent=_mf
local _sl2=Instance.new("UIListLayout",_sc) _sl2.Padding=UDim.new(0,4) _sl2.SortOrder=Enum.SortOrder.LayoutOrder
local _sp=Instance.new("UIPadding",_sc) _sp.PaddingLeft=UDim.new(0,8) _sp.PaddingRight=UDim.new(0,8) _sp.PaddingTop=UDim.new(0,6) _sp.PaddingBottom=UDim.new(0,6)

local _ord=0
local _allToggleButtons = {}
local function _sec(nm)
    _ord=_ord+1
    local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,0,22) l.BackgroundColor3=Color3.fromRGB(35,35,50) l.Text="  "..nm l.TextColor3=Color3.fromRGB(160,160,220) l.TextSize=12 l.Font=Enum.Font.GothamBold l.TextXAlignment=Enum.TextXAlignment.Left l.BorderSizePixel=0 l.LayoutOrder=_ord l.Parent=_sc
    Instance.new("UICorner",l).CornerRadius=UDim.new(0,4)
end
local function _tgg(lbl,key,cb)
    _ord=_ord+1
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,28) row.BackgroundTransparency=1 row.LayoutOrder=_ord row.Parent=_sc
    local tx=Instance.new("TextLabel") tx.Size=UDim2.new(1,-50,1,0) tx.BackgroundTransparency=1 tx.Text=lbl tx.TextColor3=Color3.fromRGB(200,200,200) tx.TextSize=13 tx.Font=Enum.Font.Gotham tx.TextXAlignment=Enum.TextXAlignment.Left tx.Parent=row
    local bt=Instance.new("TextButton") bt.Size=UDim2.new(0,40,0,20) bt.Position=UDim2.new(1,-44,0.5,-10) bt.BorderSizePixel=0 bt.Font=Enum.Font.GothamBold bt.TextSize=11 bt.Parent=row
    Instance.new("UICorner",bt).CornerRadius=UDim.new(0,10)
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
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,40) row.BackgroundTransparency=1 row.LayoutOrder=_ord row.Parent=_sc
    local label=Instance.new("TextLabel") label.Size=UDim2.new(0.5,0,1,0) label.BackgroundTransparency=1 label.Text="FOV: ".._get("Aim_FOV") label.TextColor3=Color3.fromRGB(200,200,200) label.TextSize=13 label.Font=Enum.Font.Gotham label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=row
    local minus=Instance.new("TextButton") minus.Size=UDim2.new(0,40,0,30) minus.Position=UDim2.new(0.7,0,0.5,-15) minus.Text="-" minus.BackgroundColor3=Color3.fromRGB(180,50,50) minus.TextColor3=Color3.fromRGB(255,255,255) minus.Font=Enum.Font.GothamBold minus.TextSize=18 minus.Parent=row Instance.new("UICorner",minus).CornerRadius=UDim.new(0,6)
    local plus=Instance.new("TextButton") plus.Size=UDim2.new(0,40,0,30) plus.Position=UDim2.new(0.85,0,0.5,-15) plus.Text="+" plus.BackgroundColor3=Color3.fromRGB(50,180,90) plus.TextColor3=Color3.fromRGB(255,255,255) plus.Font=Enum.Font.GothamBold plus.TextSize=18 plus.Parent=row Instance.new("UICorner",plus).CornerRadius=UDim.new(0,6)
    local function upd(v) if _bypassActive then return end v=math.clamp(v,50,900) _set("Aim_FOV",v) label.Text="FOV: "..v end
    minus.MouseButton1Click:Connect(function() upd(_get("Aim_FOV")-10) end)
    plus.MouseButton1Click:Connect(function() upd(_get("Aim_FOV")+10) end)
end

local function _hbpick()
    _ord=_ord+1
    local opts={"Head","Neck","UpperTorso","LowerTorso","All"}
    local displayNames = {"Kepala","Leher","Badan","Kaki","All Lock"}
    local ct=Instance.new("Frame") ct.Size=UDim2.new(1,0,0,0) ct.AutomaticSize=Enum.AutomaticSize.Y ct.BackgroundColor3=Color3.fromRGB(25,25,35) ct.BorderSizePixel=0 ct.LayoutOrder=_ord ct.Parent=_sc
    Instance.new("UICorner",ct).CornerRadius=UDim.new(0,6)
    local pd=Instance.new("UIPadding",ct) pd.PaddingLeft=UDim.new(0,6) pd.PaddingRight=UDim.new(0,6) pd.PaddingTop=UDim.new(0,6) pd.PaddingBottom=UDim.new(0,6)
    local gd=Instance.new("UIGridLayout",ct) gd.CellSize=UDim2.new(0.5,-4,0,26) gd.CellPadding=UDim2.new(0,4,0,4) gd.SortOrder=Enum.SortOrder.LayoutOrder
    local bs={}
    for i=1,#opts do
        local pn = opts[i]
        local dn = displayNames[i]
        local bt=Instance.new("TextButton") bt.Size=UDim2.new(1,0,1,0) bt.BackgroundColor3=Color3.fromRGB(50,50,75) bt.Text=dn bt.TextColor3=Color3.fromRGB(180,180,255) bt.TextSize=11 bt.Font=Enum.Font.Gotham bt.BorderSizePixel=0 bt.LayoutOrder=i bt.Parent=ct
        Instance.new("UICorner",bt).CornerRadius=UDim.new(0,4) bs[pn]=bt
        bt.MouseButton1Click:Connect(function()
            if _bypassActive then return end
            _set("Aim_Hitbox",pn)
            for _,b in pairs(bs) do b.BackgroundColor3=Color3.fromRGB(50,50,75) b.TextColor3=Color3.fromRGB(180,180,255) end
            bt.BackgroundColor3=Color3.fromRGB(90,130,255) bt.TextColor3=Color3.fromRGB(255,255,255)
        end)
    end
    local current = _get("Aim_Hitbox")
    if bs[current] then
        bs[current].BackgroundColor3=Color3.fromRGB(90,130,255)
        bs[current].TextColor3=Color3.fromRGB(255,255,255)
    end
end

-- Pengaturan ESP Jarak
local function _distSettings()
    _ord = _ord + 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = Color3.fromRGB(25,25,35)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = _ord
    frame.Parent = _sc
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
    
    local padding = Instance.new("UIPadding", frame)
    padding.PaddingLeft = UDim.new(0,8)
    padding.PaddingRight = UDim.new(0,8)
    padding.PaddingTop = UDim.new(0,6)
    padding.PaddingBottom = UDim.new(0,6)
    
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0,4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Toggle Distance
    local rowToggle = Instance.new("Frame")
    rowToggle.Size = UDim2.new(1,0,0,28)
    rowToggle.BackgroundTransparency = 1
    rowToggle.Parent = frame
    
    local txToggle = Instance.new("TextLabel")
    txToggle.Size = UDim2.new(1,-50,1,0)
    txToggle.BackgroundTransparency = 1
    txToggle.Text = "ESP Jarak"
    txToggle.TextColor3 = Color3.fromRGB(200,200,200)
    txToggle.TextSize = 13
    txToggle.Font = Enum.Font.Gotham
    txToggle.TextXAlignment = Enum.TextXAlignment.Left
    txToggle.Parent = rowToggle
    
    local btToggle = Instance.new("TextButton")
    btToggle.Size = UDim2.new(0,40,0,20)
    btToggle.Position = UDim2.new(1,-44,0.5,-10)
    btToggle.BorderSizePixel = 0
    btToggle.Font = Enum.Font.GothamBold
    btToggle.TextSize = 11
    btToggle.Parent = rowToggle
    Instance.new("UICorner", btToggle).CornerRadius = UDim.new(0,10)
    
    local function rfToggle()
        local on = _get("ESP_Distance") and not _bypassActive
        btToggle.Text = on and "ON" or "OFF"
        btToggle.BackgroundColor3 = on and Color3.fromRGB(50,180,90) or Color3.fromRGB(180,50,50)
    end
    rfToggle()
    btToggle.MouseButton1Click:Connect(function()
        if _bypassActive then return end
        _tog("ESP_Distance")
        rfToggle()
    end)
    
    -- Ukuran teks (+/-)
    local sizeRow = Instance.new("Frame")
    sizeRow.Size = UDim2.new(1,0,0,30)
    sizeRow.BackgroundTransparency = 1
    sizeRow.Parent = frame
    
    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Size = UDim2.new(0.5,0,1,0)
    sizeLabel.BackgroundTransparency = 1
    sizeLabel.Text = "Ukuran: " .. _get("DistSize")
    sizeLabel.TextColor3 = Color3.fromRGB(200,200,200)
    sizeLabel.TextSize = 12
    sizeLabel.Font = Enum.Font.Gotham
    sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    sizeLabel.Parent = sizeRow
    
    local minusSize = Instance.new("TextButton")
    minusSize.Size = UDim2.new(0,30,0,24)
    minusSize.Position = UDim2.new(0.7,0,0.5,-12)
    minusSize.Text = "-"
    minusSize.BackgroundColor3 = Color3.fromRGB(180,50,50)
    minusSize.TextColor3 = Color3.fromRGB(255,255,255)
    minusSize.Font = Enum.Font.GothamBold
    minusSize.TextSize = 16
    minusSize.Parent = sizeRow
    Instance.new("UICorner", minusSize).CornerRadius = UDim.new(0,4)
    
    local plusSize = Instance.new("TextButton")
    plusSize.Size = UDim2.new(0,30,0,24)
    plusSize.Position = UDim2.new(0.85,0,0.5,-12)
    plusSize.Text = "+"
    plusSize.BackgroundColor3 = Color3.fromRGB(50,180,90)
    plusSize.TextColor3 = Color3.fromRGB(255,255,255)
    plusSize.Font = Enum.Font.GothamBold
    plusSize.TextSize = 16
    plusSize.Parent = sizeRow
    Instance.new("UICorner", plusSize).CornerRadius = UDim.new(0,4)
    
    minusSize.MouseButton1Click:Connect(function()
        local newSize = math.max(8, _get("DistSize") - 1)
        _set("DistSize", newSize)
        sizeLabel.Text = "Ukuran: " .. newSize
    end)
    plusSize.MouseButton1Click:Connect(function()
        local newSize = math.min(24, _get("DistSize") + 1)
        _set("DistSize", newSize)
        sizeLabel.Text = "Ukuran: " .. newSize
    end)
    
    -- Warna teks (3 tombol: Merah, Hijau, Biru)
    local colorRow = Instance.new("Frame")
    colorRow.Size = UDim2.new(1,0,0,30)
    colorRow.BackgroundTransparency = 1
    colorRow.Parent = frame
    
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0.3,0,1,0)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "Warna:"
    colorLabel.TextColor3 = Color3.fromRGB(200,200,200)
    colorLabel.TextSize = 12
    colorLabel.Font = Enum.Font.Gotham
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = colorRow
    
    local redBtn = Instance.new("TextButton")
    redBtn.Size = UDim2.new(0.2,0,0,24)
    redBtn.Position = UDim2.new(0.35,0,0.5,-12)
    redBtn.Text = "Merah"
    redBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
    redBtn.TextColor3 = Color3.fromRGB(255,255,255)
    redBtn.Font = Enum.Font.GothamBold
    redBtn.TextSize = 11
    redBtn.Parent = colorRow
    Instance.new("UICorner", redBtn).CornerRadius = UDim.new(0,4)
    
    local greenBtn = Instance.new("TextButton")
    greenBtn.Size = UDim2.new(0.2,0,0,24)
    greenBtn.Position = UDim2.new(0.6,0,0.5,-12)
    greenBtn.Text = "Hijau"
    greenBtn.BackgroundColor3 = Color3.fromRGB(50,180,90)
    greenBtn.TextColor3 = Color3.fromRGB(255,255,255)
    greenBtn.Font = Enum.Font.GothamBold
    greenBtn.TextSize = 11
    greenBtn.Parent = colorRow
    Instance.new("UICorner", greenBtn).CornerRadius = UDim.new(0,4)
    
    local blueBtn = Instance.new("TextButton")
    blueBtn.Size = UDim2.new(0.2,0,0,24)
    blueBtn.Position = UDim2.new(0.85,0,0.5,-12)
    blueBtn.Text = "Biru"
    blueBtn.BackgroundColor3 = Color3.fromRGB(50,50,180)
    blueBtn.TextColor3 = Color3.fromRGB(255,255,255)
    blueBtn.Font = Enum.Font.GothamBold
    blueBtn.TextSize = 11
    blueBtn.Parent = colorRow
    Instance.new("UICorner", blueBtn).CornerRadius = UDim.new(0,4)
    
    redBtn.MouseButton1Click:Connect(function()
        _set("DistColor", Color3.fromRGB(255,100,100))
    end)
    greenBtn.MouseButton1Click:Connect(function()
        _set("DistColor", Color3.fromRGB(100,255,100))
    end)
    blueBtn.MouseButton1Click:Connect(function()
        _set("DistColor", Color3.fromRGB(100,100,255))
    end)
end

-- Menu Hologram
local function _holoMenu()
    _ord = _ord + 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = Color3.fromRGB(25,25,35)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = _ord
    frame.Parent = _sc
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
    
    local padding = Instance.new("UIPadding", frame)
    padding.PaddingLeft = UDim.new(0,8)
    padding.PaddingRight = UDim.new(0,8)
    padding.PaddingTop = UDim.new(0,6)
    padding.PaddingBottom = UDim.new(0,6)
    
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0,4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Toggle Hologram
    local rowToggle = Instance.new("Frame")
    rowToggle.Size = UDim2.new(1,0,0,28)
    rowToggle.BackgroundTransparency = 1
    rowToggle.Parent = frame
    
    local txToggle = Instance.new("TextLabel")
    txToggle.Size = UDim2.new(1,-50,1,0)
    txToggle.BackgroundTransparency = 1
    txToggle.Text = "Hologram"
    txToggle.TextColor3 = Color3.fromRGB(200,200,200)
    txToggle.TextSize = 13
    txToggle.Font = Enum.Font.Gotham
    txToggle.TextXAlignment = Enum.TextXAlignment.Left
    txToggle.Parent = rowToggle
    
    local btToggle = Instance.new("TextButton")
    btToggle.Size = UDim2.new(0,40,0,20)
    btToggle.Position = UDim2.new(1,-44,0.5,-10)
    btToggle.BorderSizePixel = 0
    btToggle.Font = Enum.Font.GothamBold
    btToggle.TextSize = 11
    btToggle.Parent = rowToggle
    Instance.new("UICorner", btToggle).CornerRadius = UDim.new(0,10)
    
    local function rfToggle()
        local on = _get("Hologram") and not _bypassActive
        btToggle.Text = on and "ON" or "OFF"
        btToggle.BackgroundColor3 = on and Color3.fromRGB(50,180,90) or Color3.fromRGB(180,50,50)
    end
    rfToggle()
    btToggle.MouseButton1Click:Connect(function()
        if _bypassActive then return end
        _tog("Hologram")
        rfToggle()
        if not _get("Hologram") then
            -- hapus semua hologram
            for p,_ in pairs(_holos) do _removeHologram(p) end
        end
    end)
    
    -- Toggle Neon (kelap-kelip)
    local rowNeon = Instance.new("Frame")
    rowNeon.Size = UDim2.new(1,0,0,28)
    rowNeon.BackgroundTransparency = 1
    rowNeon.Parent = frame
    
    local txNeon = Instance.new("TextLabel")
    txNeon.Size = UDim2.new(1,-50,1,0)
    txNeon.BackgroundTransparency = 1
    txNeon.Text = "Neon (kelap-kelip)"
    txNeon.TextColor3 = Color3.fromRGB(200,200,200)
    txNeon.TextSize = 13
    txNeon.Font = Enum.Font.Gotham
    txNeon.TextXAlignment = Enum.TextXAlignment.Left
    txNeon.Parent = rowNeon
    
    local btNeon = Instance.new("TextButton")
    btNeon.Size = UDim2.new(0,40,0,20)
    btNeon.Position = UDim2.new(1,-44,0.5,-10)
    btNeon.BorderSizePixel = 0
    btNeon.Font = Enum.Font.GothamBold
    btNeon.TextSize = 11
    btNeon.Parent = rowNeon
    Instance.new("UICorner", btNeon).CornerRadius = UDim.new(0,10)
    
    local function rfNeon()
        local on = _get("HoloNeon")
        btNeon.Text = on and "ON" or "OFF"
        btNeon.BackgroundColor3 = on and Color3.fromRGB(50,180,90) or Color3.fromRGB(180,50,50)
    end
    rfNeon()
    btNeon.MouseButton1Click:Connect(function()
        if _bypassActive then return end
        _tog("HoloNeon")
        rfNeon()
    end)
    
    -- Warna (merah, hijau, biru)
    local colorRow = Instance.new("Frame")
    colorRow.Size = UDim2.new(1,0,0,30)
    colorRow.BackgroundTransparency = 1
    colorRow.Parent = frame
    
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0.3,0,1,0)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "Warna:"
    colorLabel.TextColor3 = Color3.fromRGB(200,200,200)
    colorLabel.TextSize = 12
    colorLabel.Font = Enum.Font.Gotham
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = colorRow
    
    local redBtn = Instance.new("TextButton")
    redBtn.Size = UDim2.new(0.2,0,0,24)
    redBtn.Position = UDim2.new(0.35,0,0.5,-12)
    redBtn.Text = "Merah"
    redBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
    redBtn.TextColor3 = Color3.fromRGB(255,255,255)
    redBtn.Font = Enum.Font.GothamBold
    redBtn.TextSize = 11
    redBtn.Parent = colorRow
    Instance.new("UICorner", redBtn).CornerRadius = UDim.new(0,4)
    
    local greenBtn = Instance.new("TextButton")
    greenBtn.Size = UDim2.new(0.2,0,0,24)
    greenBtn.Position = UDim2.new(0.6,0,0.5,-12)
    greenBtn.Text = "Hijau"
    greenBtn.BackgroundColor3 = Color3.fromRGB(50,180,90)
    greenBtn.TextColor3 = Color3.fromRGB(255,255,255)
    greenBtn.Font = Enum.Font.GothamBold
    greenBtn.TextSize = 11
    greenBtn.Parent = colorRow
    Instance.new("UICorner", greenBtn).CornerRadius = UDim.new(0,4)
    
    local blueBtn = Instance.new("TextButton")
    blueBtn.Size = UDim2.new(0.2,0,0,24)
    blueBtn.Position = UDim2.new(0.85,0,0.5,-12)
    blueBtn.Text = "Biru"
    blueBtn.BackgroundColor3 = Color3.fromRGB(50,50,180)
    blueBtn.TextColor3 = Color3.fromRGB(255,255,255)
    blueBtn.Font = Enum.Font.GothamBold
    blueBtn.TextSize = 11
    blueBtn.Parent = colorRow
    Instance.new("UICorner", blueBtn).CornerRadius = UDim.new(0,4)
    
    redBtn.MouseButton1Click:Connect(function()
        _set("HoloColor", Color3.fromRGB(255,100,100))
    end)
    greenBtn.MouseButton1Click:Connect(function()
        _set("HoloColor", Color3.fromRGB(100,255,100))
    end)
    blueBtn.MouseButton1Click:Connect(function()
        _set("HoloColor", Color3.fromRGB(100,100,255))
    end)
end

-- TELEPORT MENU (DIPERBAIKI)
-- TELEPORT MENU (single klik, tanpa cooldown, highlight hijau)
local function _teleportMenu()
    _ord = _ord + 1
    local rowToggle=Instance.new("Frame") rowToggle.Size=UDim2.new(1,0,0,28) rowToggle.BackgroundTransparency=1 rowToggle.LayoutOrder=_ord rowToggle.Parent=_sc
    local txToggle=Instance.new("TextLabel") txToggle.Size=UDim2.new(1,-50,1,0) txToggle.BackgroundTransparency=1 txToggle.Text="Teleport" txToggle.TextColor3=Color3.fromRGB(200,200,200) txToggle.TextSize=13 txToggle.Font=Enum.Font.Gotham txToggle.TextXAlignment=Enum.TextXAlignment.Left txToggle.Parent=rowToggle
    local btToggle=Instance.new("TextButton") btToggle.Size=UDim2.new(0,40,0,20) btToggle.Position=UDim2.new(1,-44,0.5,-10) btToggle.BorderSizePixel=0 btToggle.Font=Enum.Font.GothamBold btToggle.TextSize=11 btToggle.Parent=rowToggle
    Instance.new("UICorner",btToggle).CornerRadius=UDim.new(0,10)
    local function rfToggle() local on = _get("Teleport") and not _bypassActive btToggle.Text=on and"ON"or"OFF" btToggle.BackgroundColor3=on and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rfToggle()
    btToggle.MouseButton1Click:Connect(function() if _bypassActive then return end _tog("Teleport") rfToggle() if _get("Teleport") then if _G._refreshTeleportList then _G._refreshTeleportList() end else if _G._tpFrame then _G._tpFrame.Visible=false end end end)
    
    local tpFrame=Instance.new("ScrollingFrame") tpFrame.Size=UDim2.new(1,0,0,120) tpFrame.BackgroundColor3=Color3.fromRGB(25,25,35) tpFrame.BorderSizePixel=0 tpFrame.ScrollBarThickness=4 tpFrame.CanvasSize=UDim2.new(0,0,0,0) tpFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y tpFrame.Visible=false tpFrame.LayoutOrder=_ord+1 tpFrame.Parent=_sc
    Instance.new("UICorner",tpFrame).CornerRadius=UDim.new(0,6)
    local tpListLayout=Instance.new("UIListLayout",tpFrame) tpListLayout.Padding=UDim.new(0,4) tpListLayout.SortOrder=Enum.SortOrder.LayoutOrder
    _G._tpFrame=tpFrame
    
    local selectedBtn = nil
    local function refreshList()
        if not _get("Teleport") or _bypassActive then if tpFrame then tpFrame.Visible=false end return end
        for _, child in pairs(tpFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, plr in ipairs(_P:GetPlayers()) do if plr~=_LP then
            local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,-10,0,30) btn.BackgroundColor3=Color3.fromRGB(50,50,70) btn.Text=plr.Name btn.TextColor3=Color3.fromRGB(255,255,255) btn.Font=Enum.Font.Gotham btn.TextSize=12 btn.Parent=tpFrame
            Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
            btn.MouseButton1Click:Connect(function()
                if _bypassActive then return end
                if selectedBtn then pcall(function() selectedBtn.BackgroundColor3 = Color3.fromRGB(50,50,70) end) end
                selectedBtn = btn
                btn.BackgroundColor3 = Color3.fromRGB(50,200,50)
                local targetChar = plr.Character
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                    local localChar = _LP.Character
                    if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                        localChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0,2.5,0)
                        _tl.Text = "Teleported to "..plr.Name
                    else _tl.Text = "Your character not ready" end
                else _tl.Text = "Target not found" end
            end)
        end end
        tpFrame.Visible=true
    end
    _G._refreshTeleportList=refreshList
    local refreshConn
    local function startRefresh() if refreshConn then refreshConn:Disconnect() end refreshConn=_RS.Heartbeat:Connect(function() if _get("Teleport") and not _bypassActive then refreshList() else if tpFrame then tpFrame.Visible=false end end end) end
    startRefresh()
    _ord=_ord+1
end

-- SPEED MENU
local function _speedMenu()
    _ord=_ord+1
    local rowToggle=Instance.new("Frame") rowToggle.Size=UDim2.new(1,0,0,28) rowToggle.BackgroundTransparency=1 rowToggle.LayoutOrder=_ord rowToggle.Parent=_sc
    local txToggle=Instance.new("TextLabel") txToggle.Size=UDim2.new(1,-50,1,0) txToggle.BackgroundTransparency=1 txToggle.Text="Speed Hack" txToggle.TextColor3=Color3.fromRGB(200,200,200) txToggle.TextSize=13 txToggle.Font=Enum.Font.Gotham txToggle.TextXAlignment=Enum.TextXAlignment.Left txToggle.Parent=rowToggle
    local btToggle=Instance.new("TextButton") btToggle.Size=UDim2.new(0,40,0,20) btToggle.Position=UDim2.new(1,-44,0.5,-10) btToggle.BorderSizePixel=0 btToggle.Font=Enum.Font.GothamBold btToggle.TextSize=11 btToggle.Parent=rowToggle
    Instance.new("UICorner",btToggle).CornerRadius=UDim.new(0,10)
    local function rfToggle() local on = _get("SpeedEnabled") and not _bypassActive btToggle.Text=on and"ON"or"OFF" btToggle.BackgroundColor3=on and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rfToggle()
    btToggle.MouseButton1Click:Connect(function() if _bypassActive then return end _tog("SpeedEnabled") rfToggle() end)
    
    local levelRow=Instance.new("Frame") levelRow.Size=UDim2.new(1,0,0,40) levelRow.BackgroundTransparency=1 levelRow.LayoutOrder=_ord+1 levelRow.Parent=_sc
    local low=Instance.new("TextButton") low.Size=UDim2.new(0.3,0,0,30) low.Position=UDim2.new(0.02,0,0.5,-15) low.Text="Low" low.BackgroundColor3=Color3.fromRGB(70,70,90) low.TextColor3=Color3.fromRGB(255,255,255) low.Font=Enum.Font.GothamBold low.TextSize=12 low.Parent=levelRow Instance.new("UICorner",low).CornerRadius=UDim.new(0,6)
    local norm=Instance.new("TextButton") norm.Size=UDim2.new(0.3,0,0,30) norm.Position=UDim2.new(0.35,0,0.5,-15) norm.Text="Normal" norm.BackgroundColor3=Color3.fromRGB(70,70,90) norm.TextColor3=Color3.fromRGB(255,255,255) norm.Font=Enum.Font.GothamBold norm.TextSize=12 norm.Parent=levelRow Instance.new("UICorner",norm).CornerRadius=UDim.new(0,6)
    local fast=Instance.new("TextButton") fast.Size=UDim2.new(0.3,0,0,30) fast.Position=UDim2.new(0.68,0,0.5,-15) fast.Text="Fast" fast.BackgroundColor3=Color3.fromRGB(70,70,90) fast.TextColor3=Color3.fromRGB(255,255,255) fast.Font=Enum.Font.GothamBold fast.TextSize=12 fast.Parent=levelRow Instance.new("UICorner",fast).CornerRadius=UDim.new(0,6)
    local function setSpeed(val) if _bypassActive then return end _set("Speed",val) _speedValue=val _speedSlider.Text=tostring(val) end
    low.MouseButton1Click:Connect(function() setSpeed(-5) end)
    norm.MouseButton1Click:Connect(function() setSpeed(0) end)
    fast.MouseButton1Click:Connect(function() setSpeed(8) end)
    
    local sliderRow=Instance.new("Frame") sliderRow.Size=UDim2.new(1,0,0,40) sliderRow.BackgroundTransparency=1 sliderRow.LayoutOrder=_ord+2 sliderRow.Parent=_sc
    local label=Instance.new("TextLabel") label.Size=UDim2.new(0.3,0,1,0) label.BackgroundTransparency=1 label.Text="Speed Val:" label.TextColor3=Color3.fromRGB(200,200,200) label.TextSize=13 label.Font=Enum.Font.Gotham label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=sliderRow
    local _speedSlider=Instance.new("TextBox") _speedSlider.Size=UDim2.new(0.2,0,0,30) _speedSlider.Position=UDim2.new(0.35,0,0.5,-15) _speedSlider.BackgroundColor3=Color3.fromRGB(50,50,70) _speedSlider.Text=tostring(_get("Speed")) _speedSlider.TextColor3=Color3.fromRGB(255,255,255) _speedSlider.Font=Enum.Font.Gotham _speedSlider.TextSize=14 _speedSlider.Parent=sliderRow Instance.new("UICorner",_speedSlider).CornerRadius=UDim.new(0,6)
    local setBtn=Instance.new("TextButton") setBtn.Size=UDim2.new(0.2,0,0,30) setBtn.Position=UDim2.new(0.6,0,0.5,-15) setBtn.Text="Set" setBtn.BackgroundColor3=Color3.fromRGB(90,130,255) setBtn.TextColor3=Color3.fromRGB(255,255,255) setBtn.Font=Enum.Font.GothamBold setBtn.TextSize=12 setBtn.Parent=sliderRow Instance.new("UICorner",setBtn).CornerRadius=UDim.new(0,6)
    local resetBtn=Instance.new("TextButton") resetBtn.Size=UDim2.new(0.15,0,0,30) resetBtn.Position=UDim2.new(0.83,0,0.5,-15) resetBtn.Text="Reset" resetBtn.BackgroundColor3=Color3.fromRGB(180,100,50) resetBtn.TextColor3=Color3.fromRGB(255,255,255) resetBtn.Font=Enum.Font.GothamBold resetBtn.TextSize=12 resetBtn.Parent=sliderRow Instance.new("UICorner",resetBtn).CornerRadius=UDim.new(0,6)
    setBtn.MouseButton1Click:Connect(function() local num=tonumber(_speedSlider.Text) if num then num=math.clamp(num,-10,10) _set("Speed",num) _speedSlider.Text=tostring(num) else _speedSlider.Text="0" _set("Speed",0) end end)
    resetBtn.MouseButton1Click:Connect(function() _set("Speed",0) _speedSlider.Text="0" end)
    _ord=_ord+2
end

-- BYPASS MENU
local function _bypassMenu()
    _ord=_ord+1
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,28) row.BackgroundTransparency=1 row.LayoutOrder=_ord row.Parent=_sc
    local tx=Instance.new("TextLabel") tx.Size=UDim2.new(1,-50,1,0) tx.BackgroundTransparency=1 tx.Text="Bypass Mode (Auto off on admin)" tx.TextColor3=Color3.fromRGB(200,200,200) tx.TextSize=13 tx.Font=Enum.Font.Gotham tx.TextXAlignment=Enum.TextXAlignment.Left tx.Parent=row
    local bt=Instance.new("TextButton") bt.Size=UDim2.new(0,40,0,20) bt.Position=UDim2.new(1,-44,0.5,-10) bt.BorderSizePixel=0 bt.Font=Enum.Font.GothamBold bt.TextSize=11 bt.Parent=row
    Instance.new("UICorner",bt).CornerRadius=UDim.new(0,10)
    local function rf() bt.Text=_bypassEnabled and"ON"or"OFF" bt.BackgroundColor3=_bypassEnabled and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rf()
    bt.MouseButton1Click:Connect(function() _bypassEnabled = not _bypassEnabled rf() _tl.Text = _bypassEnabled and "⚠️ Bypass ENABLED " or "Bypass DISABLED" task.wait(2) _tl.Text = "🎯 v2.5 | Lynzka x Cheat" end)
end

-- ANTI SS MENU
local function _antiSSMenu()
    _ord=_ord+1
    local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,28) row.BackgroundTransparency=1 row.LayoutOrder=_ord row.Parent=_sc
    local tx=Instance.new("TextLabel") tx.Size=UDim2.new(1,-50,1,0) tx.BackgroundTransparency=1 tx.Text="Anti Screenshot" tx.TextColor3=Color3.fromRGB(200,200,200) tx.TextSize=13 tx.Font=Enum.Font.Gotham tx.TextXAlignment=Enum.TextXAlignment.Left tx.Parent=row
    local bt=Instance.new("TextButton") bt.Size=UDim2.new(0,40,0,20) bt.Position=UDim2.new(1,-44,0.5,-10) bt.BorderSizePixel=0 bt.Font=Enum.Font.GothamBold bt.TextSize=11 bt.Parent=row
    Instance.new("UICorner",bt).CornerRadius=UDim.new(0,10)
    local function rf() bt.Text=_antiSS and"ON"or"OFF" bt.BackgroundColor3=_antiSS and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) end
    rf()
    bt.MouseButton1Click:Connect(function()
        _antiSS = not _antiSS
        rf()
        applyAntiSS()
        _tl.Text = _antiSS and "🔒 Anti-SS ON - Cheats hidden from screenshots" or "🔓 Anti-SS OFF - Cheats visible"
        task.wait(2)
        _tl.Text = "🎯 v2.5 | Lynzxzka"
    end)
end

-- Buat menu utama
_sec("──── ESP ───────────────")
_tgg("ESP", "ESP_Enabled")
_tgg("Names", "ESP_Names")
_tgg("HP", "ESP_Health")
_tgg("Team Color", "ESP_TeamColor")
_distSettings()   -- <-- Tambahkan baris ini
_sec("──── HOLOGRAM ──────────")
_holoMenu()
_sec("──── AIMBOT ────────────")
_tgg("Aimbot", "Aim_Enabled")
_tgg("Show FOV", "Aim_ShowFOV")
_tgg("Team Check", "Aim_TeamCheck")
_fovButtons()
_sec("──── HITBOX ────────────")
_hbpick()
_sec("──── ANTENA ────────────")
_tgg("Antena", "Tracer")
_sec("──── TELEPORT ──────────")
_teleportMenu()
_sec("──── SPEED HACK ────────")
_speedMenu()
_sec("──── BYPASS ────────────")
_bypassMenu()
_sec("──── ANTI SS ───────────")
_antiSSMenu()
_sec("───────────────────────")

-- Tombol All Off
local allOffBtn = Instance.new("TextButton")
allOffBtn.Size = UDim2.new(0.9,0,0,30)
allOffBtn.Position = UDim2.new(0.05,0,0,0)
allOffBtn.BackgroundColor3 = Color3.fromRGB(180,100,100)
allOffBtn.Text = "🔴 ALL OFF"
allOffBtn.TextColor3 = Color3.fromRGB(255,255,255)
allOffBtn.Font = Enum.Font.GothamBold
allOffBtn.TextSize = 14
allOffBtn.Parent = _sc
Instance.new("UICorner",allOffBtn).CornerRadius = UDim.new(0,8)
allOffBtn.LayoutOrder = _ord+1
allOffBtn.MouseButton1Click:Connect(_allOff)

-- Tombol Emergency OFF (60 detik)
local emergencyBtn = Instance.new("TextButton")
emergencyBtn.Size = UDim2.new(0.9,0,0,30)
emergencyBtn.Position = UDim2.new(0.05,0,0,0)
emergencyBtn.BackgroundColor3 = Color3.fromRGB(200,80,80)
emergencyBtn.Text = "⚠️ EMERGENCY OFF (60s)"
emergencyBtn.TextColor3 = Color3.fromRGB(255,255,255)
emergencyBtn.Font = Enum.Font.GothamBold
emergencyBtn.TextSize = 12
emergencyBtn.Parent = _sc
Instance.new("UICorner",emergencyBtn).CornerRadius = UDim.new(0,8)
emergencyBtn.LayoutOrder = _ord+2
emergencyBtn.MouseButton1Click:Connect(function()
    if _bypassActive then _tl.Text = "Already in bypass mode, wait..." return end
    _emergencyOff()
    _tl.Text = "⚠️ Emergency OFF - All cheats disabled for 60s"
end)

-- Fungsi refresh toggle
_G._refreshAllToggles = function()
    for key, btn in pairs(_allToggleButtons) do
        local on = _get(key) and not _bypassActive
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(50,180,90) or Color3.fromRGB(180,50,50)
    end
    if _G._tpFrame then
        if _get("Teleport") and not _bypassActive then _G._refreshTeleportList() else _G._tpFrame.Visible = false end
    end
end

-- Triple tap untuk hide/show menu (sama seperti sebelumnya, tapi tombol header sudah diganti)
local tapCount = 0
local tapTimeout = nil
local menuVisible = true
local function onTap(pos)
    if pos.X < 200 and pos.Y > _mf.AbsoluteSize.Y - 100 then
        tapCount = tapCount + 1
        if tapTimeout then tapTimeout:Disconnect() end
        tapTimeout = game:GetService("RunService").Stepped:Connect(function()
            task.wait(0.5)
            if tapCount >= 3 then
                menuVisible = not menuVisible
                _mf.Visible = menuVisible
                tapCount = 0
            else
                tapCount = 0
            end
            tapTimeout:Disconnect()
            tapTimeout = nil
        end)
    end
end
_UI.TouchTap:Connect(onTap)
_UI.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        onTap(_UI:GetMouseLocation())
    end
end)

-- Fungsi tombol 🌐 untuk collapse/munculkan menu (toggle _sc.Visible)
local menuExpanded = true
_hb.MouseButton1Click:Connect(function()
    menuExpanded = not menuExpanded
    _sc.Visible = menuExpanded
    _hb.Text = menuExpanded and "🌐" or "🌐"  -- sama, tidak berubah
    if not menuExpanded then
        _mf.Size = UDim2.new(0,300,0,36)
    else
        _mf.AutomaticSize = Enum.AutomaticSize.Y
    end
end)

-- Tombol Insert untuk toggle seluruh menu (seperti sebelumnya)
_ri(_UI.InputBegan:Connect(function(i,gp)
    if not gp and i.KeyCode==Enum.KeyCode.Insert then _mf.Visible=not _mf.Visible end
end))

print("✅ ROYZSTECU EVIL AI LOADED | Insert toggles menu | Triple tap left-bottom to hide/show | Delete to unload")