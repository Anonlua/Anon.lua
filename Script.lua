-- kitafa hub: Anti Guard 

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

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 220, 0, 60)
panel.Position = UDim2.new(0.5, -110, 0, 15)
panel.BackgroundColor3 = Color3.fromRGB(20, 18, 28)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = sg

local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 12)
pc.Parent = panel

local rgbStroke = Instance.new("UIStroke")
rgbStroke.Color = Color3.fromRGB(180, 100, 255)
rgbStroke.Thickness = 2
rgbStroke.Parent = panel

local hue = 0.75
local rgbConn
local function startRGB()
    if rgbConn then return end
    rgbConn = RUN.RenderStepped:Connect(function(dt)
        hue = (hue + dt * 0.5) % 1
        rgbStroke.Color = Color3.fromHSV(hue, 1, 1)
    end)
end
local function stopRGB()
    if rgbConn then rgbConn:Disconnect(); rgbConn = nil end
    rgbStroke.Transparency = 1
end

-- Луна
local ib = Instance.new("Frame")
ib.Size = UDim2.new(0, 44, 0, 44)
ib.Position = UDim2.new(0, 10, 0.5, -22)
ib.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
ib.BorderSizePixel = 0
ib.Parent = panel

local ibc = Instance.new("UICorner")
ibc.CornerRadius = UDim.new(0, 10)
ibc.Parent = ib

local moon = Instance.new("Frame")
moon.Size = UDim2.new(0, 30, 0, 30)
moon.Position = UDim2.new(0.5, -15, 0.5, -15)
moon.BackgroundColor3 = Color3.fromRGB(240, 230, 255)
moon.BorderSizePixel = 0
moon.Parent = ib

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(1, 0)
mc.Parent = moon

local ms = Instance.new("Frame")
ms.Size = UDim2.new(0, 25, 0, 25)
ms.Position = UDim2.new(0.5, -8, 0.5, -17)
ms.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
ms.BorderSizePixel = 0
ms.Parent = ib

local msc = Instance.new("UICorner")
msc.CornerRadius = UDim.new(1, 0)
msc.Parent = ms

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 0, 16)
title.Position = UDim2.new(0, 64, 0, 12)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(220, 180, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "kitafa hub"
title.Parent = panel

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -120, 0, 18)
sub.Position = UDim2.new(0, 64, 0, 32)
sub.BackgroundTransparency = 1
sub.TextColor3 = Color3.fromRGB(255, 255, 255)
sub.Font = Enum.Font.GothamBold
sub.TextSize = 13
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Text = "Anti Guard"
sub.Parent = panel

local tgl = Instance.new("TextButton")
tgl.Size = UDim2.new(0, 50, 0, 28)
tgl.Position = UDim2.new(1, -58, 0.5, -14)
tgl.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
tgl.Text = ""
tgl.AutoButtonColor = false
tgl.BorderSizePixel = 0
tgl.Parent = panel

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(1, 0)
tc.Parent = tgl

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 22, 0, 22)
knob.Position = UDim2.new(1, -24, 0.5, -11)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0
knob.Parent = tgl

local kc = Instance.new("UICorner")
kc.CornerRadius = UDim.new(1, 0)
kc.Parent = knob

local function upd()
    if ON then
        tgl.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
        knob.Position = UDim2.new(1, -24, 0.5, -11)
        startRGB()
    else
        tgl.BackgroundColor3 = Color3.fromRGB(60, 55, 70)
        knob.Position = UDim2.new(0, 2, 0.5, -11)
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

print("[LM] готово")
print("[LM] Safe Zone: 529.44, 70.57, -366.58")
