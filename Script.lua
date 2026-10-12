-- env: Roblox, executor: Delta, target: Steal an Egg
-- kitafa hub: Anti Guard + красивый UI

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

-- UI
local PG = LP:WaitForChild("PlayerGui", 10)
if not PG then return end

local sg = Instance.new("ScreenGui")
sg.Name = "kH"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999
sg.Parent = PG

-- ═══════════════════════════════════════════
-- ГЛАВНАЯ ПАНЕЛЬ С ТЕНЬЮ И СВЕЧЕНИЕМ
-- ═══════════════════════════════════════════
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 240, 0, 68)
panel.Position = UDim2.new(0.5, -120, 0, 15)
panel.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = sg

local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 14)
pc.Parent = panel

-- Внешняя обводка (фиолетовая)
local outerStroke = Instance.new("UIStroke")
outerStroke.Color = Color3.fromRGB(140, 80, 220)
outerStroke.Thickness = 2
outerStroke.Transparency = 0.2
outerStroke.Parent = panel

-- Внутренняя обводка (светлая)
local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Color3.fromRGB(200, 160, 255)
innerStroke.Thickness = 1
innerStroke.Transparency = 0.6
innerStroke.Parent = panel

-- Тень под панелью
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 8, 1, 8)
shadow.Position = UDim2.new(0, -4, 0, -4)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.6
shadow.BorderSizePixel = 0
shadow.ZIndex = 0
shadow.Parent = sg

local shc = Instance.new("UICorner")
shc.CornerRadius = UDim.new(0, 16)
shc.Parent = shadow

-- Связываем тень с панелью
RUN.RenderStepped:Connect(function()
    shadow.Position = UDim2.new(0, panel.AbsolutePosition.X - 4, 0, panel.AbsolutePosition.Y + 8)
    shadow.Size = UDim2.new(0, panel.AbsoluteSize.X + 8, 0, panel.AbsoluteSize.Y + 8)
end)

-- ═══════════════════════════════════════════
-- АНИМИРОВАННОЕ СВЕЧЕНИЕ ВОКРУГ ПАНЕЛИ (RGB)
-- ═══════════════════════════════════════════
local hue = 0.75
local rgbConn
local function startRGB()
    if rgbConn then return end
    rgbConn = RUN.RenderStepped:Connect(function(dt)
        hue = (hue + dt * 0.3) % 1
        local c = Color3.fromHSV(hue, 0.7, 1)
        outerStroke.Color = c
        outerStroke.Transparency = 0.15 + 0.15 * math.sin(tick() * 2)
    end)
end
local function stopRGB()
    if rgbConn then rgbConn:Disconnect(); rgbConn = nil end
    outerStroke.Transparency = 1
end

-- ═══════════════════════════════════════════
-- ИКОНКА ЛУНЫ (с градиентом и свечением)
-- ═══════════════════════════════════════════
local iconBox = Instance.new("Frame")
iconBox.Size = UDim2.new(0, 50, 0, 50)
iconBox.Position = UDim2.new(0, 10, 0.5, -25)
iconBox.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
iconBox.BorderSizePixel = 0
iconBox.Parent = panel

local ibc = Instance.new("UICorner")
ibc.CornerRadius = UDim.new(0, 12)
ibc.Parent = iconBox

-- Внутренняя обводка иконки
local ibStroke = Instance.new("UIStroke")
ibStroke.Color = Color3.fromRGB(180, 120, 255)
ibStroke.Thickness = 1.5
ibStroke.Transparency = 0.2
ibStroke.Parent = iconBox

-- Градиент внутри иконки
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 25, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 12, 35)),
})
grad.Rotation = 45
grad.Parent = iconBox

-- Луна (белый круг)
local moonFull = Instance.new("Frame")
moonFull.Size = UDim2.new(0, 34, 0, 34)
moonFull.Position = UDim2.new(0.5, -17, 0.5, -17)
moonFull.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
moonFull.BorderSizePixel = 0
moonFull.Parent = iconBox

local mfc = Instance.new("UICorner")
mfc.CornerRadius = UDim.new(1, 0)
mfc.Parent = moonFull

-- Свечение вокруг луны
local moonGlow = Instance.new("UIStroke")
moonGlow.Color = Color3.fromRGB(220, 180, 255)
moonGlow.Thickness = 2
moonGlow.Transparency = 0.4
moonGlow.Parent = moonFull

-- Тень внутри луны (полумесяц)
local moonShadow = Instance.new("Frame")
moonShadow.Size = UDim2.new(0, 28, 0, 28)
moonShadow.Position = UDim2.new(0.5, -9, 0.5, -19)
moonShadow.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
moonShadow.BorderSizePixel = 0
moonShadow.Parent = iconBox

local msc = Instance.new("UICorner")
msc.CornerRadius = UDim.new(1, 0)
msc.Parent = moonShadow

-- ═══════════════════════════════════════════
-- ТЕКСТ (с тенями)
-- ═══════════════════════════════════════════
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -140, 0, 20)
title.Position = UDim2.new(0, 68, 0, 14)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeTransparency = 0.5
title.TextStrokeColor3 = Color3.fromRGB(100, 50, 180)
title.Text = "kitafa hub"
title.Parent = panel

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -140, 0, 18)
sub.Position = UDim2.new(0, 68, 0, 36)
sub.BackgroundTransparency = 1
sub.TextColor3 = Color3.fromRGB(200, 160, 255)
sub.Font = Enum.Font.Gotham
sub.TextSize = 12
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.TextStrokeTransparency = 0.6
sub.TextStrokeColor3 = Color3.fromRGB(60, 30, 120)
sub.Text = "Anti Guard"
sub.Parent = panel

-- Индикатор статуса (точка)
local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(0, 68, 0, 56)
dot.BackgroundColor3 = Color3.fromRGB(80, 255, 150)
dot.BorderSizePixel = 0
dot.Parent = panel

local dotc = Instance.new("UICorner")
dotc.CornerRadius = UDim.new(1, 0)
dotc.Parent = dot

-- Свечение точки
local dotGlow = Instance.new("UIStroke")
dotGlow.Color = Color3.fromRGB(80, 255, 150)
dotGlow.Thickness = 4
dotGlow.Transparency = 0.6
dotGlow.Parent = dot

-- Пульсация точки
task.spawn(function()
    while true do
        task.wait(0.05)
        if ON then
            local p = (math.sin(tick() * 4) + 1) / 2
            dotGlow.Transparency = 0.3 + p * 0.5
            dotGlow.Thickness = 3 + p * 3
        end
    end
end)

-- Статус-текст справа
local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(0, 80, 0, 12)
statusLbl.Position = UDim2.new(0, 80, 0, 54)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 10
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Text = "Active"
statusLbl.Parent = panel

-- ═══════════════════════════════════════════
-- КРАСИВЫЙ ТУМБЛЕР (как на скрине)
-- ═══════════════════════════════════════════
local tgl = Instance.new("TextButton")
tgl.Size = UDim2.new(0, 52, 0, 30)
tgl.Position = UDim2.new(1, -62, 0.5, -15)
tgl.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
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
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 60, 220)),
})
tglGrad.Rotation = 90
tglGrad.Parent = tgl

-- Свечение тумблера
local tglGlow = Instance.new("UIStroke")
tglGlow.Color = Color3.fromRGB(220, 180, 255)
tglGlow.Thickness = 2
tglGlow.Transparency = 0.3
tglGlow.Parent = tgl

-- Кружок (с тенью и градиентом)
local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 24, 0, 24)
knob.Position = UDim2.new(1, -26, 0.5, -12)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0
knob.Parent = tgl

local kc = Instance.new("UICorner")
kc.CornerRadius = UDim.new(1, 0)
kc.Parent = knob

-- Тень кружка
local knobShadow = Instance.new("UIStroke")
knobShadow.Color = Color3.fromRGB(0, 0, 0)
knobShadow.Thickness = 1
knobShadow.Transparency = 0.7
knobShadow.Parent = knob

-- Обновление UI
local function upd()
    if ON then
        TS:Create(tgl, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(180, 100, 255)
        }):Play()
        TS:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -26, 0.5, -12)
        }):Play()
        TS:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(80, 255, 150)
        }):Play()
        TS:Create(dotGlow, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(80, 255, 150)
        }):Play()
        TS:Create(sub, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(200, 160, 255)
        }):Play()
        statusLbl.Text = "Active"
        statusLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
        startRGB()
    else
        TS:Create(tgl, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(60, 55, 70)
        }):Play()
        TS:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 2, 0.5, -12)
        }):Play()
        TS:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        }):Play()
        TS:Create(dotGlow, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(200, 60, 60)
        }):Play()
        TS:Create(sub, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(120, 120, 130)
        }):Play()
        statusLbl.Text = "Disabled"
        statusLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
        stopRGB()
    end
end

tgl.MouseButton1Click:Connect(function()
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

-- ============================================================
-- ДЕТЕКТ
-- ============================================================
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

print("[LM] готово. Красивый UI + Anti Guard.")
