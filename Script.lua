-- env: Roblox, executor: Delta, target: Steal an Egg
-- kitafa hub: Anti Guard 

print("[LM] start")

local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RUN = game:GetService("RunService")
local TS = game:GetService("TweenService")
local LP = P.LocalPlayer
local NET = RS:WaitForChild("Packages"):WaitForChild("Networking")

local SAFE = Vector3.new(529.44, 70.57, -366.58)
local HOLD = 2.0

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

-- Панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 60)
panel.Position = UDim2.new(0.5, -100, 0, 15)
panel.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = sg

local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 14)
pc.Parent = panel

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 22, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 14, 28)),
})
bgGrad.Rotation = 135
bgGrad.Parent = panel

local rgbStroke = Instance.new("UIStroke")
rgbStroke.Color = Color3.fromRGB(160, 100, 255)
rgbStroke.Thickness = 2
rgbStroke.Transparency = 0.1
rgbStroke.Parent = panel

local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Color3.fromRGB(255, 255, 255)
innerStroke.Thickness = 1
innerStroke.Transparency = 0.85
innerStroke.Parent = panel

-- RGB
local hue = 0.75
local rgbConn
local function startRGB()
    if rgbConn then return end
    rgbConn = RUN.RenderStepped:Connect(function(dt)
        hue = (hue + dt * 0.3) % 1
        rgbStroke.Color = Color3.fromHSV(hue, 0.8, 1)
    end)
end
local function stopRGB()
    if rgbConn then rgbConn:Disconnect(); rgbConn = nil end
    rgbStroke.Transparency = 1
end

-- Иконка
local iconBox = Instance.new("Frame")
iconBox.Size = UDim2.new(0, 46, 0, 46)
iconBox.Position = UDim2.new(0, 8, 0.5, -23)
iconBox.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
iconBox.BorderSizePixel = 0
iconBox.Parent = panel

local ibc = Instance.new("UICorner")
ibc.CornerRadius = UDim.new(0, 12)
ibc.Parent = iconBox

local iconGrad = Instance.new("UIGradient")
iconGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 40, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 50)),
})
iconGrad.Rotation = 135
iconGrad.Parent = iconBox

local ibStroke = Instance.new("UIStroke")
ibStroke.Color = Color3.fromRGB(190, 130, 255)
ibStroke.Thickness = 1.5
ibStroke.Transparency = 0.1
ibStroke.Parent = iconBox

local moonFull = Instance.new("Frame")
moonFull.Size = UDim2.new(0, 32, 0, 32)
moonFull.Position = UDim2.new(0.5, -16, 0.5, -16)
moonFull.BackgroundColor3 = Color3.fromRGB(255, 252, 245)
moonFull.BorderSizePixel = 0
moonFull.Parent = iconBox

local mfc = Instance.new("UICorner")
mfc.CornerRadius = UDim.new(1, 0)
mfc.Parent = moonFull

local moonGlow = Instance.new("UIStroke")
moonGlow.Color = Color3.fromRGB(220, 180, 255)
moonGlow.Thickness = 3
moonGlow.Transparency = 0.5
moonGlow.Parent = moonFull

local moonShadow = Instance.new("Frame")
moonShadow.Size = UDim2.new(0, 26, 0, 26)
moonShadow.Position = UDim2.new(0.5, -9, 0.5, -18)
moonShadow.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
moonShadow.BorderSizePixel = 0
moonShadow.Parent = iconBox

local msc = Instance.new("UICorner")
msc.CornerRadius = UDim.new(1, 0)
msc.Parent = moonShadow

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -130, 0, 18)
title.Position = UDim2.new(0, 60, 0, 12)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeTransparency = 0.3
title.TextStrokeColor3 = Color3.fromRGB(100, 50, 180)
title.Text = "kitafa hub"
title.Parent = panel

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -130, 0, 16)
sub.Position = UDim2.new(0, 60, 0, 30)
sub.BackgroundTransparency = 1
sub.TextColor3 = Color3.fromRGB(200, 160, 255)
sub.Font = Enum.Font.GothamMedium
sub.TextSize = 11
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.TextStrokeTransparency = 0.5
sub.TextStrokeColor3 = Color3.fromRGB(60, 30, 120)
sub.Text = "Anti Guard"
sub.Parent = panel

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 7, 0, 7)
dot.Position = UDim2.new(0, 62, 0, 47)
dot.BackgroundColor3 = Color3.fromRGB(80, 255, 150)
dot.BorderSizePixel = 0
dot.Parent = panel

local dotc = Instance.new("UICorner")
dotc.CornerRadius = UDim.new(1, 0)
dotc.Parent = dot

local dotGlow = Instance.new("UIStroke")
dotGlow.Color = Color3.fromRGB(80, 255, 150)
dotGlow.Thickness = 3
dotGlow.Transparency = 0.5
dotGlow.Parent = dot

task.spawn(function()
    while true do
        task.wait(0.05)
        if ON then
            local p = (math.sin(tick() * 4) + 1) / 2
            dotGlow.Transparency = 0.3 + p * 0.5
        end
    end
end)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(0, 70, 0, 12)
statusLbl.Position = UDim2.new(0, 73, 0, 45)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
statusLbl.Font = Enum.Font.GothamMedium
statusLbl.TextSize = 10
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Text = "Active"
statusLbl.Parent = panel

local tgl = Instance.new("TextButton")
tgl.Size = UDim2.new(0, 48, 0, 26)
tgl.Position = UDim2.new(1, -56, 0.5, -13)
tgl.BackgroundColor3 = Color3.fromRGB(160, 80, 255)
tgl.Text = ""
tgl.AutoButtonColor = false
tgl.BorderSizePixel = 0
tgl.Parent = panel

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(1, 0)
tc.Parent = tgl

local tglGrad = Instance.new("UIGradient")
tglGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 200)),
})
tglGrad.Rotation = 90
tglGrad.Parent = tgl

local tglGlow = Instance.new("UIStroke")
tglGlow.Color = Color3.fromRGB(220, 180, 255)
tglGlow.Thickness = 2
tglGlow.Transparency = 0.2
tglGlow.Parent = tgl

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(1, -22, 0.5, -10)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0
knob.Parent = tgl

local kc = Instance.new("UICorner")
kc.CornerRadius = UDim.new(1, 0)
kc.Parent = knob

local knobShadow = Instance.new("UIStroke")
knobShadow.Color = Color3.fromRGB(0, 0, 0)
knobShadow.Thickness = 1
knobShadow.Transparency = 0.5
knobShadow.Parent = knob

local function upd()
    if ON then
        TS:Create(tgl, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(160, 80, 255)
        }):Play()
        TS:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, -22, 0.5, -10)
        }):Play()
        statusLbl.Text = "Active"
        statusLbl.TextColor3 = Color3.fromRGB(160, 255, 180)
        startRGB()
    else
        TS:Create(tgl, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(55, 50, 65)
        }):Play()
        TS:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, 2, 0.5, -10)
        }):Play()
        statusLbl.Text = "Disabled"
        statusLbl.TextColor3 = Color3.fromRGB(180, 120, 120)
        stopRGB()
    end
end

tgl.MouseButton1Click:Connect(function()
    ON = not ON
    upd()
end)

upd()

-- ============================================================
-- МГНОВЕННЫЙ ТП (туда и обратно — БЕЗ Fly)
-- ============================================================
local function instantTP(pos)
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local hum = LP.Character:FindFirstChildOfClass("Humanoid")
    
    if hum then hum.PlatformStand = true end
    
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
    r.CFrame = CFrame.new(pos)
    
    task.wait(0.03)
    
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
    r.CFrame = CFrame.new(pos)
    
    task.wait(0.03)
    
    if hum then hum.PlatformStand = false end
end

local function doTeleport(biome)
    if busy then return end
    if tick() - lastTP < 0.5 then return end
    lastTP = tick()

    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not r then return end

    busy = true
    local lastPos = r.Position
    print("[LM] " .. (biome or "?") .. " → Safe")

    -- ⚡ Мгновенно в Safe
    instantTP(SAFE)

    task.wait(HOLD)

    -- ⚡ Мгновенно обратно (без Fly)
    instantTP(lastPos)

    task.wait(0.05)
    busy = false
    print("[LM] вернулся")
end

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

print("[LM] готово. Без Fly — мгновенно туда и обратно.")
