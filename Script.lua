-- env: Roblox, executor: Delta, target: Steal an Egg
-- kitafa hub: Anti Guard + премиум UI

print("[LM] start")

local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RUN = game:GetService("RunService")
local TS = game:GetService("TweenService")
local LP = P.LocalPlayer
local NET = RS:WaitForChild("Packages"):WaitForChild("Networking")

local SAFE = Vector3.new(529.44, 70.57, -366.58)
local HOLD = 1.5
local RETURN_SPEED = 1.5

local ON = true
local busy = false
local lastTP = 0

local PG = LP:WaitForChild("PlayerGui", 10)
if not PG then return end

local sg = Instance.new("ScreenGui")
sg.Name = "kH"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999
sg.Parent = PG

-- ═══════════════════════════════════════════
-- ГЛАВНАЯ ПАНЕЛЬ (стеклянный эффект)
-- ═══════════════════════════════════════════
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 260, 0, 78)
panel.Position = UDim2.new(0.5, -130, 0, 15)
panel.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = sg

local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 18)
pc.Parent = panel

-- Градиент фона (тёмно-фиолетовый сверху вниз)
local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 20, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 12, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 35)),
})
bgGrad.Rotation = 90
bgGrad.Parent = panel

-- Внешняя RGB-обводка
local rgbStroke = Instance.new("UIStroke")
rgbStroke.Color = Color3.fromRGB(160, 100, 255)
rgbStroke.Thickness = 2.5
rgbStroke.Transparency = 0.1
rgbStroke.Parent = panel

-- Внутренняя светлая обводка
local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Color3.fromRGB(255, 255, 255)
innerStroke.Thickness = 1
innerStroke.Transparency = 0.85
innerStroke.Parent = panel

-- Тень под панелью
local shadow = Instance.new("Frame")
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.ZIndex = 0
shadow.Parent = sg

local shc = Instance.new("UICorner")
shc.CornerRadius = UDim.new(0, 20)
shc.Parent = shadow

RUN.RenderStepped:Connect(function()
    local pos = panel.AbsolutePosition
    local size = panel.AbsoluteSize
    shadow.Position = UDim2.new(0, pos.X - 5, 0, pos.Y + 10)
    shadow.Size = UDim2.new(0, size.X + 10, 0, size.Y + 10)
end)

-- ═══════════════════════════════════════════
-- RGB СВЕЧЕНИЕ
-- ═══════════════════════════════════════════
local hue = 0.75
local rgbConn
local function startRGB()
    if rgbConn then return end
    rgbConn = RUN.RenderStepped:Connect(function(dt)
        hue = (hue + dt * 0.3) % 1
        local c = Color3.fromHSV(hue, 0.8, 1)
        rgbStroke.Color = c
        rgbStroke.Transparency = 0.1 + 0.15 * math.sin(tick() * 2)
    end)
end
local function stopRGB()
    if rgbConn then rgbConn:Disconnect(); rgbConn = nil end
    rgbStroke.Transparency = 1
end

-- ═══════════════════════════════════════════
-- ИКОНКА (луна в градиентном квадрате с glow)
-- ═══════════════════════════════════════════
local iconBox = Instance.new("Frame")
iconBox.Size = UDim2.new(0, 58, 0, 58)
iconBox.Position = UDim2.new(0, 10, 0.5, -29)
iconBox.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
iconBox.BorderSizePixel = 0
iconBox.Parent = panel

local ibc = Instance.new("UICorner")
ibc.CornerRadius = UDim.new(0, 14)
ibc.Parent = iconBox

-- Градиент внутри иконки
local iconGrad = Instance.new("UIGradient")
iconGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 35, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 50)),
})
iconGrad.Rotation = 135
iconGrad.Parent = iconBox

-- Обводка иконки
local ibStroke = Instance.new("UIStroke")
ibStroke.Color = Color3.fromRGB(180, 120, 255)
ibStroke.Thickness = 2
ibStroke.Transparency = 0.1
ibStroke.Parent = iconBox

-- Внутренняя тень иконки
local ibInner = Instance.new("UIStroke")
ibInner.Color = Color3.fromRGB(255, 255, 255)
ibInner.Thickness = 1
ibInner.Transparency = 0.85
ibInner.Parent = iconBox

-- Луна
local moonFull = Instance.new("Frame")
moonFull.Size = UDim2.new(0, 40, 0, 40)
moonFull.Position = UDim2.new(0.5, -20, 0.5, -20)
moonFull.BackgroundColor3 = Color3.fromRGB(255, 252, 245)
moonFull.BorderSizePixel = 0
moonFull.Parent = iconBox

local mfc = Instance.new("UICorner")
mfc.CornerRadius = UDim.new(1, 0)
mfc.Parent = moonFull

-- Свечение вокруг луны (двойное)
local moonGlowOuter = Instance.new("UIStroke")
moonGlowOuter.Color = Color3.fromRGB(220, 180, 255)
moonGlowOuter.Thickness = 4
moonGlowOuter.Transparency = 0.6
moonGlowOuter.Parent = moonFull

local moonGlowInner = Instance.new("UIStroke")
moonGlowInner.Color = Color3.fromRGB(255, 255, 255)
moonGlowInner.Thickness = 1.5
moonGlowInner.Transparency = 0.4
moonGlowInner.Parent = moonFull

-- Тень внутри луны (делает серп)
local moonShadow = Instance.new("Frame")
moonShadow.Size = UDim2.new(0, 32, 0, 32)
moonShadow.Position = UDim2.new(0.5, -10, 0.5, -22)
moonShadow.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
moonShadow.BorderSizePixel = 0
moonShadow.Parent = iconBox

local msc = Instance.new("UICorner")
msc.CornerRadius = UDim.new(1, 0)
msc.Parent = moonShadow

-- Пульсация луны
task.spawn(function()
    while true do
        task.wait(0.05)
        local p = (math.sin(tick() * 2) + 1) / 2
        moonGlowOuter.Transparency = 0.4 + p * 0.3
        moonGlowOuter.Thickness = 3 + p * 2
    end
end)

-- ═══════════════════════════════════════════
-- ТЕКСТ (с обводкой и glow)
-- ═══════════════════════════════════════════
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -160, 0, 22)
title.Position = UDim2.new(0, 78, 0, 14)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeTransparency = 0.3
title.TextStrokeColor3 = Color3.fromRGB(100, 50, 180)
title.Text = "kitafa hub"
title.Parent = panel

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 180, 255)),
})
titleGrad.Parent = title

-- Подзаголовок
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -160, 0, 20)
sub.Position = UDim2.new(0, 78, 0, 38)
sub.BackgroundTransparency = 1
sub.TextColor3 = Color3.fromRGB(200, 160, 255)
sub.Font = Enum.Font.GothamMedium
sub.TextSize = 13
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.TextStrokeTransparency = 0.5
sub.TextStrokeColor3 = Color3.fromRGB(60, 30, 120)
sub.Text = "Anti Guard"
sub.Parent = panel

-- ═══════════════════════════════════════════
-- СТАТУС-ИНДИКАТОР (с glow)
-- ═══════════════════════════════════════════
local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 9, 0, 9)
dot.Position = UDim2.new(0, 80, 0, 63)
dot.BackgroundColor3 = Color3.fromRGB(80, 255, 150)
dot.BorderSizePixel = 0
dot.Parent = panel

local dotc = Instance.new("UICorner")
dotc.CornerRadius = UDim.new(1, 0)
dotc.Parent = dot

local dotGlow = Instance.new("UIStroke")
dotGlow.Color = Color3.fromRGB(80, 255, 150)
dotGlow.Thickness = 4
dotGlow.Transparency = 0.5
dotGlow.Parent = dot

task.spawn(function()
    while true do
        task.wait(0.03)
        if ON then
            local p = (math.sin(tick() * 5) + 1) / 2
            dotGlow.Transparency = 0.2 + p * 0.6
            dotGlow.Thickness = 3 + p * 4
        end
    end
end)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(0, 90, 0, 14)
statusLbl.Position = UDim2.new(0, 94, 0, 60)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
statusLbl.Font = Enum.Font.GothamMedium
statusLbl.TextSize = 11
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Text = "Active"
statusLbl.Parent = panel

-- ═══════════════════════════════════════════
-- ТУМБЛЕР (премиум)
-- ═══════════════════════════════════════════
local tgl = Instance.new("TextButton")
tgl.Size = UDim2.new(0, 58, 0, 32)
tgl.Position = UDim2.new(1, -68, 0.5, -16)
tgl.BackgroundColor3 = Color3.fromRGB(160, 80, 255)
tgl.Text = ""
tgl.AutoButtonColor = false
tgl.BorderSizePixel = 0
tgl.Parent = panel

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(1, 0)
tc.Parent = tgl

-- Градиент тумблера
local tglGrad = Instance.new("UIGradient")
tglGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 200)),
})
tglGrad.Rotation = 90
tglGrad.Parent = tgl

-- Двойная обводка тумблера
local tglGlow = Instance.new("UIStroke")
tglGlow.Color = Color3.fromRGB(220, 180, 255)
tglGlow.Thickness = 2
tglGlow.Transparency = 0.2
tglGlow.Parent = tgl

local tglInner = Instance.new("UIStroke")
tglInner.Color = Color3.fromRGB(255, 255, 255)
tglInner.Thickness = 1
tglInner.Transparency = 0.85
tglInner.Parent = tgl

-- Кружок
local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 26, 0, 26)
knob.Position = UDim2.new(1, -28, 0.5, -13)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0
knob.Parent = tgl

local kc = Instance.new("UICorner")
kc.CornerRadius = UDim.new(1, 0)
kc.Parent = knob

-- Градиент кружка
local knobGrad = Instance.new("UIGradient")
knobGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 240)),
})
knobGrad.Rotation = 90
knobGrad.Parent = knob

-- Тень кружка
local knobShadow = Instance.new("UIStroke")
knobShadow.Color = Color3.fromRGB(0, 0, 0)
knobShadow.Thickness = 1.5
knobShadow.Transparency = 0.6
knobShadow.Parent = knob

-- Свечение кружка
local knobGlow = Instance.new("UIStroke")
knobGlow.Color = Color3.fromRGB(255, 255, 255)
knobGlow.Thickness = 1
knobGlow.Transparency = 0.5
knobGlow.Parent = knob

-- Анимация нажатия (сжатие)
local function pulseBtn(btn)
    local origSize = btn.Size
    local smallSize = UDim2.new(0, origSize.X.Offset - 4, 0, origSize.Y.Offset - 4)
    local origPos = btn.Position
    local newPos = UDim2.new(
        origPos.X.Scale, origPos.X.Offset + 2,
        origPos.Y.Scale, origPos.Y.Offset + 2
    )
    TS:Create(btn, TweenInfo.new(0.08), {Size = smallSize, Position = newPos}):Play()
    task.wait(0.08)
    TS:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Size = origSize, Position = origPos}):Play()
end

local function upd()
    if ON then
        TS:Create(tgl, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(160, 80, 255)
        }):Play()
        TS:Create(knob, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, -28, 0.5, -13)
        }):Play()
        TS:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(80, 255, 150)
        }):Play()
        TS:Create(dotGlow, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(80, 255, 150)
        }):Play()
        statusLbl.Text = "Active"
        statusLbl.TextColor3 = Color3.fromRGB(160, 255, 180)
        startRGB()
    else
        TS:Create(tgl, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(55, 50, 65)
        }):Play()
        TS:Create(knob, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, 2, 0.5, -13)
        }):Play()
        TS:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        }):Play()
        TS:Create(dotGlow, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(200, 60, 60)
        }):Play()
        statusLbl.Text = "Disabled"
        statusLbl.TextColor3 = Color3.fromRGB(180, 120, 120)
        stopRGB()
    end
end

tgl.MouseButton1Click:Connect(function()
    pulseBtn(tgl)
    ON = not ON
    upd()
    print("[LM] режим:", ON and "ON" or "OFF")
end)

upd()

-- ============================================================
-- ТП
-- ============================================================
local function instantTP(pos)
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not r then return end
    r.CFrame = CFrame.new(pos)
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
end

local function smoothTP(pos)
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local target = CFrame.new(pos + Vector3.new(0, 3, 0))
    local tween = TS:Create(
        r,
        TweenInfo.new(RETURN_SPEED, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {CFrame = target}
    )
    tween:Play()
    tween.Completed:Wait()
end

local function doTeleport(biome)
    if busy then return end
    if tick() - lastTP < 1 then return end
    lastTP = tick()

    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not r then return end

    busy = true
    local lastPos = r.Position
    print("[LM] " .. (biome or "?") .. " → Safe")

    instantTP(SAFE)
    task.wait(HOLD)
    smoothTP(lastPos)

    task.wait(0.1)
    busy = false
    print("[LM] вернулся")
end

-- ДЕТЕКТ
local carryEv = NET:FindFirstChild("RE/EggWorld/FieldEggCarry")
if carryEv then
    carryEv.OnClientEvent:Connect(function(data)
        if not ON or busy then return end
        if type(data) ~= "table" then return end
        if data.IsCarrying == true then
            doTeleport(data.AreaId)
        end
    end)
    print("[LM] ✅ FieldEggCarry")
end

local shiftEv = NET:FindFirstChild("RE/EggWorld/FieldEggShifted")
if shiftEv then
    shiftEv.OnClientEvent:Connect(function(data)
        if not ON or busy then return end
        if type(data) ~= "table" then return end
        if data.State == "Carried" and data.CarrierUserId == LP.UserId then
            doTeleport(data.AreaId)
        end
    end)
    print("[LM] ✅ FieldEggShifted")
end

print("[LM] готово. Премиум UI + Anti Guard.")
