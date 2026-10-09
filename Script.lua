local ok, err = pcall(function()
    local Players           = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService        = game:GetService("RunService")
    local Lighting          = game:GetService("Lighting")
    local UserInputService  = game:GetService("UserInputService")
    local TweenService      = game:GetService("TweenService")
    local CoreGui           = game:GetService("CoreGui")
    local LocalPlayer       = Players.LocalPlayer
    local Camera            = workspace.CurrentCamera

    local C = {
        bg = Color3.fromRGB(6, 12, 26),
        panel = Color3.fromRGB(12, 22, 44),
        card = Color3.fromRGB(16, 28, 54),
        card_hover = Color3.fromRGB(24, 40, 78),
        card_inner = Color3.fromRGB(10, 18, 38),
        accent = Color3.fromRGB(70, 150, 255),
        accent_soft = Color3.fromRGB(110, 180, 255),
        accent_dim = Color3.fromRGB(30, 65, 130),
        text = Color3.fromRGB(235, 245, 255),
        text_dim = Color3.fromRGB(130, 160, 210),
        off = Color3.fromRGB(45, 60, 95),
        ok = Color3.fromRGB(80, 200, 130),
        danger = Color3.fromRGB(220, 80, 90),
        warn = Color3.fromRGB(220, 170, 70),
        info = Color3.fromRGB(90, 150, 255),
        murderer = Color3.fromRGB(255, 60, 60),
        sheriff = Color3.fromRGB(60, 140, 255),
        innocent = Color3.fromRGB(200, 200, 200),
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = "MM2_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local State = {
        connections = {},
        esp = {},
        running = true,
        fov_frame = nil,
        fly_bv = nil,
        original_sizes = {},
    }

    local CONFIG = {
        player_esp = true,
        role_esp = true,
        name_tags = false,
        distance_esp = false,
        silent_aim = false,
        silent_fov = 200,
        aimbot = false,
        aimbot_fov = 120,
        fov_circle = false,
        hitbox_expand = false,
        wallbang = false,
        hitbox_size = 12,
        anti_aim = false,
        god_mode = false,
        fast_run = false,
        speed_value = 40,
        no_clip = false,
        fly = false,
        fullbright = false,
        no_fog = false,
        rgb_lighting = false,
        time_changer = false,
    }

    local function glow(inst, color, thickness, transparency)
        local s = Instance.new("UIStroke")
        s.Color = color
        s.Thickness = thickness or 1
        s.Transparency = transparency or 0.3
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = inst
        return s
    end

    local function track(c)
        table.insert(State.connections, c)
        return c
    end

    local function get_char() return LocalPlayer.Character end
    local function get_hum()
        local c = get_char()
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function get_root()
        local c = get_char()
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    -- ============ УВЕДОМЛЕНИЯ ============
    local notif_holder = Instance.new("Frame")
    notif_holder.Size = UDim2.new(0, 220, 0, 300)
    notif_holder.Position = UDim2.new(1, -236, 0, 80)
    notif_holder.BackgroundTransparency = 1
    notif_holder.Parent = gui

    local nl = Instance.new("UIListLayout")
    nl.Padding = UDim.new(0, 5)
    nl.SortOrder = Enum.SortOrder.LayoutOrder
    nl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    nl.Parent = notif_holder

    local nid = 0
    local ncfg = { duration = 3, enabled = true }

    local function push_notification(kind, title, subtitle, status)
        if not ncfg.enabled then return end
        nid = nid + 1
        local col, gly = C.info, "◉"
        if kind == "hit" then col, gly = C.ok, "✓"
        elseif kind == "miss" then col, gly = C.danger, "✕"
        elseif kind == "kill" then col, gly = C.warn, "◎"
        elseif kind == "role" then col, gly = C.info, "◇"
        end

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 50)
        card.BackgroundColor3 = C.card
        card.BackgroundTransparency = 0.1
        card.BorderSizePixel = 0
        card.LayoutOrder = nid
        card.Parent = notif_holder
        local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 10); cc.Parent = card
        glow(card, col, 1, 0.55)

        local icon = Instance.new("Frame")
        icon.Size = UDim2.new(0, 32, 0, 32)
        icon.Position = UDim2.new(0, 10, 0.5, -16)
        icon.BackgroundColor3 = col
        icon.BackgroundTransparency = 0.75
        icon.BorderSizePixel = 0
        icon.Parent = card
        local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(0, 8); ic.Parent = icon
        glow(icon, col, 1, 0.3)

        local il = Instance.new("TextLabel")
        il.Size = UDim2.new(1, 0, 1, 0)
        il.BackgroundTransparency = 1
        il.Text = gly
        il.TextColor3 = col
        il.Font = Enum.Font.GothamBold
        il.TextSize = 16
        il.Parent = icon

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, -56, 0, 14)
        tl.Position = UDim2.new(0, 50, 0, 6)
        tl.BackgroundTransparency = 1
        tl.Text = title
        tl.TextColor3 = C.text
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 11
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Parent = card

        local sl = Instance.new("TextLabel")
        sl.Size = UDim2.new(1, -56, 0, 12)
        sl.Position = UDim2.new(0, 50, 0, 20)
        sl.BackgroundTransparency = 1
        sl.Text = subtitle or ""
        sl.TextColor3 = C.text_dim
        sl.Font = Enum.Font.Gotham
        sl.TextSize = 9
        sl.TextXAlignment = Enum.TextXAlignment.Left
        sl.Parent = card

        local stl = Instance.new("TextLabel")
        stl.Size = UDim2.new(1, -56, 0, 12)
        stl.Position = UDim2.new(0, 50, 0, 32)
        stl.BackgroundTransparency = 1
        stl.Text = status or ""
        stl.TextColor3 = col
        stl.Font = Enum.Font.GothamBold
        stl.TextSize = 9
        stl.TextXAlignment = Enum.TextXAlignment.Left
        stl.Parent = card

        card.Position = UDim2.new(1, 30, 0, 0)
        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        task.delay(ncfg.duration, function()
            if not card.Parent then return end
            local tw = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 40, 0, 0),
                BackgroundTransparency = 1
            })
            tw:Play()
            tw.Completed:Connect(function()
                pcall(function() card:Destroy() end)
            end)
        end)
    end

    -- ============ MM2 EVENTS ============
    local function get_remote(path)
        local cur = ReplicatedStorage
        for p in path:gmatch("[^%.]+") do
            cur = cur and cur:FindFirstChild(p)
        end
        return cur
    end

    local GunKill   = get_remote("Remotes.Gameplay.GunKill")
    local KnifeKill = get_remote("Remotes.Gameplay.KnifeKill")
    local KillEvent = get_remote("Remotes.Gameplay.KillEvent")
    local RoundStart = get_remote("Remotes.Gameplay.RoundStart")
    local GunFired  = get_remote("ClientServices.WeaponService.GunFired")
    local PlayerDC  = get_remote("Remotes.Gameplay.PlayerDataChanged")

    if GunKill then track(GunKill.Event:Connect(function()
        push_notification("kill", "Kill Notification", "Target eliminated", "ELIMINATED")
    end)) end
    if KnifeKill then track(KnifeKill.Event:Connect(function()
        push_notification("kill", "Kill Notification", "Target eliminated", "ELIMINATED")
    end)) end
    if KillEvent then track(KillEvent.OnClientEvent:Connect(function()
        push_notification("kill", "Kill Notification", "Target eliminated", "ELIMINATED")
    end)) end
    if RoundStart then track(RoundStart.OnClientEvent:Connect(function()
        push_notification("role", "Role Notification", "New round started", "MURDERER / SHERIFF")
    end)) end
    if PlayerDC then track(PlayerDC.OnClientEvent:Connect(function(plr, data)
        if plr == LocalPlayer and type(data) == "table" and data.Role then
            push_notification("role", "Role Notification", "Your role this round", tostring(data.Role):upper())
        end
    end)) end
    if GunFired then track(GunFired.OnClientEvent:Connect(function(...)
        local a = {...}
        local hit = false
        for _, v in ipairs(a) do if v == true then hit = true; break end end
        if hit then
            push_notification("hit", "Hit Notification", "Your shot landed", "HIT!")
        else
            push_notification("miss", "Miss Notification", "Your shot missed", "MISS!")
        end
    end)) end

    -- ============ ХИТБОКС ============
    local function apply_hitbox_temp()
        local touched = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not State.original_sizes[hrp] then
                        State.original_sizes[hrp] = {
                            size = hrp.Size,
                            can_collide = hrp.CanCollide,
                            massless = hrp.Massless,
                        }
                    end
                    pcall(function()
                        local s = CONFIG.hitbox_size
                        hrp.Size = Vector3.new(s, s, s)
                        hrp.CanCollide = false
                        hrp.Massless = true
                    end)
                    table.insert(touched, hrp)
                end
            end
        end
        return touched
    end

    local function restore_hitbox(touched)
        for _, hrp in ipairs(touched) do
            local saved = State.original_sizes[hrp]
            if saved and hrp.Parent then
                pcall(function()
                    hrp.Size = saved.size
                    hrp.CanCollide = saved.can_collide
                    hrp.Massless = saved.massless
                end)
            end
            State.original_sizes[hrp] = nil
        end
    end

    -- ============ SILENT AIM / WALLBANG ============
    if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
        local ok_hook, err_hook = pcall(function()
            local old_namecall
            old_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" and self and typeof(self) == "Instance" then
                    local n = tostring(self.Name):lower()
                    local is_weapon = n:find("gun") or n:find("revolver")
                        or n:find("weapon") or n:find("knife")
                        or n:find("sword") or n:find("tool")
                    if is_weapon then
                        local my_root = get_root()
                        local target = nil
                        if my_root then
                            local best, best_d = nil, CONFIG.silent_fov
                            for _, plr in ipairs(Players:GetPlayers()) do
                                if plr ~= LocalPlayer and plr.Character then
                                    local r = plr.Character:FindFirstChild("HumanoidRootPart")
                                    local h = plr.Character:FindFirstChildOfClass("Humanoid")
                                    if r and h and h.Health > 0 then
                                        local sp, on_screen = Camera:WorldToViewportPoint(r.Position)
                                        if on_screen then
                                            local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
                                            local d = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
                                            if d < best_d then best_d = d; best = r end
                                        end
                                    end
                                end
                            end
                            target = best
                        end

                        local touched = {}
                        if (CONFIG.hitbox_expand or CONFIG.wallbang or CONFIG.silent_aim) then
                            touched = apply_hitbox_temp()
                        end

                        if CONFIG.silent_aim and target then
                            local args = {...}
                            for i, v in ipairs(args) do
                                if typeof(v) == "Vector3" then
                                    args[i] = target.Position
                                    break
                                elseif typeof(v) == "Instance" and v:IsA("BasePart") then
                                    args[i] = target
                                    break
                                end
                            end
                            local ok_call, result = pcall(old_namecall, self, table.unpack(args))
                            if #touched > 0 then
                                task.delay(0.1, function() restore_hitbox(touched) end)
                            end
                            if ok_call then return result end
                        end

                        local result = old_namecall(self, ...)
                        if #touched > 0 then
                            task.delay(0.1, function() restore_hitbox(touched) end)
                        end
                        return result
                    end
                end
                return old_namecall(self, ...)
            end))
        end)
        if ok_hook then
            print("[MM2] silent aim hook installed")
        else
            warn("[MM2] hook failed:", tostring(err_hook))
        end
    else
        warn("[MM2] hookmetamethod unavailable")
    end

    -- ============ ANTI-AIM ============
    local aa_angle = 0
    track(RunService.RenderStepped:Connect(function(dt)
        if not CONFIG.anti_aim then return end
        aa_angle = aa_angle + dt * 15
        local root = get_root()
        if not root then return end
        local char = get_char()
        if char and char.PrimaryPart then
            pcall(function()
                char:SetPrimaryPartCFrame(CFrame.new(root.Position) * CFrame.Angles(0, math.rad(math.sin(aa_angle) * 180), 0))
            end)
        end
    end))

    -- ============ AIMBOT ============
    local function get_closest_in_fov(fov)
        local my_root = get_root()
        if not my_root then return nil end
        local best, best_d = nil, fov
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    local sp, on_screen = Camera:WorldToViewportPoint(root.Position)
                    if on_screen then
                        local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
                        local d = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
                        if d < best_d then best_d = d; best = root end
                    end
                end
            end
        end
        return best
    end

    track(RunService.RenderStepped:Connect(function()
        if CONFIG.aimbot then
            local target = get_closest_in_fov(CONFIG.aimbot_fov)
            if target then
                pcall(function()
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                end)
            end
        end
    end))

    track(RunService.RenderStepped:Connect(function()
        if CONFIG.fov_circle and not State.fov_frame then
            local f = Instance.new("Frame")
            f.Size = UDim2.new(0, CONFIG.aimbot_fov * 2, 0, CONFIG.aimbot_fov * 2)
            f.Position = UDim2.new(0.5, -CONFIG.aimbot_fov, 0.5, -CONFIG.aimbot_fov)
            f.BackgroundTransparency = 1
            f.Parent = gui
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = f
            glow(f, C.accent_soft, 1.5, 0.3)
            State.fov_frame = f
        elseif not CONFIG.fov_circle and State.fov_frame then
            pcall(function() State.fov_frame:Destroy() end)
            State.fov_frame = nil
        end
    end))

    -- ============ ESP ============
    local function detect_role(plr)
        local char = plr.Character
        if not char then return "Innocent" end
        local containers = { char, plr:FindFirstChildOfClass("Backpack") }
        for _, cont in ipairs(containers) do
            if cont then
                for _, it in ipairs(cont:GetChildren()) do
                    if it:IsA("Tool") then
                        local n = tostring(it.Name):lower()
                        if n == "knife" or (n:find("knife") and not n:find("throw") and not n:find("display")) then
                            return "Murderer"
                        end
                        if n == "gun" or n == "revolver" or (n:find("gun") and not n:find("display")) then
                            return "Sheriff"
                        end
                    end
                end
            end
        end
        return "Innocent"
    end

    local function clear_esp()
        for part, data in pairs(State.esp) do
            pcall(function() data.hl:Destroy() end)
            pcall(function() data.bb:Destroy() end)
            State.esp[part] = nil
        end
    end

    task.spawn(function()
        while State.running do
            task.wait(0.2)
            if not (CONFIG.player_esp or CONFIG.role_esp or CONFIG.name_tags or CONFIG.distance_esp) then
                clear_esp()
            else
                clear_esp()
                local my_root = get_root()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local root = plr.Character:FindFirstChild("HumanoidRootPart")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if root and hum and hum.Health > 0 then
                            local role = detect_role(plr)
                            local color = C.innocent
                            if CONFIG.role_esp and role then
                                if role == "Murderer" then color = C.murderer
                                elseif role == "Sheriff" then color = C.sheriff end
                            end
                            if CONFIG.player_esp then
                                local hl = Instance.new("Highlight")
                                hl.FillColor = color
                                hl.OutlineColor = Color3.new(1,1,1)
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = plr.Character

                                local bb = Instance.new("BillboardGui")
                                bb.Size = UDim2.new(0, 120, 0, 40)
                                bb.StudsOffset = Vector3.new(0, 3, 0)
                                bb.AlwaysOnTop = true
                                bb.Parent = root

                                local txt = ""
                                if CONFIG.name_tags then txt = plr.Name .. " " end
                                if CONFIG.distance_esp and my_root then
                                    txt = txt .. "[" .. math.floor((root.Position - my_root.Position).Magnitude) .. "m]"
                                end
                                if CONFIG.role_esp and role then txt = txt .. "\n" .. role:upper() end

                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = txt
                                label.TextColor3 = color
                                label.TextStrokeTransparency = 0
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 12
                                label.Parent = bb
                                State.esp[root] = { hl = hl, bb = bb }
                            end
                        end
                    end
                end
            end
        end
    end)

    -- ============ GOD MODE ============
    task.spawn(function()
        while State.running do
            task.wait(0.2)
            if CONFIG.god_mode then
                local hum = get_hum()
                if hum then pcall(function() hum.MaxHealth = 1e7; hum.Health = 1e7 end) end
            end
        end
    end)

    -- ============ SPEED ============
    task.spawn(function()
        while State.running do
            task.wait(0.2)
            local hum = get_hum()
            if hum then
                pcall(function()
                    if CONFIG.fast_run then hum.WalkSpeed = CONFIG.speed_value
                    else hum.WalkSpeed = 16 end
                end)
            end
        end
    end)

    -- ============ NOCLIP ============
    track(RunService.Stepped:Connect(function()
        if not CONFIG.no_clip then return end
        local c = get_char()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end
    end))

    -- ============ FLY ============
    track(RunService.RenderStepped:Connect(function()
        if not CONFIG.fly then
            if State.fly_bv then pcall(function() State.fly_bv:Destroy() end); State.fly_bv = nil end
            return
        end
        local root = get_root()
        if not root then
            if State.fly_bv then pcall(function() State.fly_bv:Destroy() end); State.fly_bv = nil end
            return
        end
        if not State.fly_bv or State.fly_bv.Parent ~= root then
            if State.fly_bv then pcall(function() State.fly_bv:Destroy() end) end
            State.fly_bv = Instance.new("BodyVelocity")
            State.fly_bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            State.fly_bv.Velocity = Vector3.zero
            State.fly_bv.Parent = root
        end
        local move = Vector3.zero
        local hum = get_hum()
        if hum and hum.MoveDirection.Magnitude > 0 then
            move = Camera.CFrame:VectorToWorldSpace(hum.MoveDirection) * 50
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,50,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,50,0) end
        State.fly_bv.Velocity = move
    end))

    -- ============ WORLD ============
    local orig_light = {
        ambient = Lighting.Ambient, brightness = Lighting.Brightness,
        outdoor = Lighting.OutdoorAmbient, fog_end = Lighting.FogEnd, clock = Lighting.ClockTime,
    }
    task.spawn(function()
        while State.running do
            task.wait(0.5)
            if CONFIG.fullbright then
                pcall(function()
                    Lighting.Ambient = Color3.fromRGB(255,255,255)
                    Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
                    Lighting.Brightness = 3
                end)
            else
                pcall(function()
                    Lighting.Ambient = orig_light.ambient
                    Lighting.OutdoorAmbient = orig_light.outdoor
                    Lighting.Brightness = orig_light.brightness
                end)
            end
            if CONFIG.no_fog then
                pcall(function() Lighting.FogEnd = 1e6 end)
            else
                pcall(function() Lighting.FogEnd = orig_light.fog_end end)
            end
            if CONFIG.rgb_lighting then
                local t = tick()
                pcall(function()
                    Lighting.Ambient = Color3.fromHSV((t*0.1)%1, 1, 1)
                    Lighting.OutdoorAmbient = Color3.fromHSV((t*0.1+0.5)%1, 1, 1)
                end)
            end
            if CONFIG.time_changer then
                pcall(function() Lighting.ClockTime = (tick()*0.5)%24 end)
            else
                pcall(function() Lighting.ClockTime = orig_light.clock end)
            end
        end
    end)

    -- ============ UI ============
    local WIN_W, WIN_H = 380, 250
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
    main.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2 + 20)
    main.BackgroundColor3 = C.bg
    main.BackgroundTransparency = 0.12
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    main.Visible = false
    main.Parent = gui
    local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 12); mc.Parent = main
    glow(main, C.accent, 1.5, 0.15)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 34)
    header.BackgroundColor3 = C.panel
    header.BackgroundTransparency = 0.25
    header.BorderSizePixel = 0
    header.ZIndex = 2
    header.Parent = main
    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0, 12); hc.Parent = header
    local hfix = Instance.new("Frame")
    hfix.Size = UDim2.new(1, 0, 0, 12)
    hfix.Position = UDim2.new(0, 0, 1, -12)
    hfix.BackgroundColor3 = C.panel
    hfix.BackgroundTransparency = 0.25
    hfix.BorderSizePixel = 0
    hfix.ZIndex = 2
    hfix.Parent = header

    local hline = Instance.new("Frame")
    hline.Size = UDim2.new(1, -20, 0, 1)
    hline.Position = UDim2.new(0, 10, 0, 34)
    hline.BackgroundColor3 = C.accent_dim
    hline.BackgroundTransparency = 0.4
    hline.BorderSizePixel = 0
    hline.ZIndex = 2
    hline.Parent = main

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 24, 0, 34)
    logo.Position = UDim2.new(0, 12, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "⟡"
    logo.TextColor3 = C.accent_soft
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 16
    logo.ZIndex = 3
    logo.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 250, 0, 16)
    title.Position = UDim2.new(0, 38, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "MM2 Interface"
    title.TextColor3 = C.text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 250, 0, 10)
    subtitle.Position = UDim2.new(0, 38, 0, 19)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "combat build"
    subtitle.TextColor3 = C.text_dim
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 9
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 3
    subtitle.Parent = header

    local dragging, drag_start, start_pos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; drag_start = input.Position; start_pos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - drag_start
            main.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + d.X, start_pos.Y.Scale, start_pos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 100, 1, -44)
    sidebar.Position = UDim2.new(0, 8, 0, 40)
    sidebar.BackgroundColor3 = C.panel
    sidebar.BackgroundTransparency = 0.35
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 2
    sidebar.Parent = main
    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 10); sc.Parent = sidebar
    local sb_list = Instance.new("UIListLayout")
    sb_list.Padding = UDim.new(0, 2)
    sb_list.SortOrder = Enum.SortOrder.LayoutOrder
    sb_list.Parent = sidebar
    local sb_pad = Instance.new("UIPadding")
    sb_pad.PaddingTop = UDim.new(0, 4)
    sb_pad.PaddingLeft = UDim.new(0, 4)
    sb_pad.PaddingRight = UDim.new(0, 4)
    sb_pad.Parent = sidebar

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -116, 1, -44)
    content.Position = UDim2.new(0, 116, 0, 40)
    content.BackgroundTransparency = 1
    content.ZIndex = 2
    content.Parent = main

    local page_title = Instance.new("TextLabel")
    page_title.Size = UDim2.new(1, 0, 0, 16)
    page_title.Position = UDim2.new(0, 4, 0, 0)
    page_title.BackgroundTransparency = 1
    page_title.Text = "「 Combat 」"
    page_title.TextColor3 = C.text
    page_title.Font = Enum.Font.GothamBold
    page_title.TextSize = 11
    page_title.TextXAlignment = Enum.TextXAlignment.Left
    page_title.ZIndex = 3
    page_title.Parent = content

    local pages = {}
    local function new_page(name)
        local p = Instance.new("ScrollingFrame")
        p.Name = name
        p.Size = UDim2.new(1, 0, 1, -22)
        p.Position = UDim2.new(0, 0, 0, 22)
        p.BackgroundTransparency = 1
        p.BorderSizePixel = 0
        p.ScrollBarThickness = 2
        p.ScrollBarImageColor3 = C.accent
        p.CanvasSize = UDim2.new(0, 0, 0, 0)
        p.AutomaticCanvasSize = Enum.AutomaticSize.Y
        p.Visible = false
        p.ZIndex = 3
        p.Parent = content
        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0.5, -3, 0, 40)
        grid.CellPadding = UDim2.new(0, 6, 0, 6)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = p
        pages[name] = p
        return p
    end

    local function show_page(name)
        for n, p in pairs(pages) do p.Visible = (n == name) end
        page_title.Text = "「 " .. name .. " 」"
    end

    local nav_buttons = {}
    local function add_nav(name, symbol)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = C.accent
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 3
        btn.Parent = sidebar
        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 7); bc.Parent = btn

        local sym = Instance.new("TextLabel")
        sym.Size = UDim2.new(0, 18, 1, 0)
        sym.Position = UDim2.new(0, 6, 0, 0)
        sym.BackgroundTransparency = 1
        sym.Text = symbol
        sym.TextColor3 = C.text_dim
        sym.Font = Enum.Font.GothamBold
        sym.TextSize = 13
        sym.ZIndex = 3
        sym.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -28, 1, 0)
        lbl.Position = UDim2.new(0, 26, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = C.text_dim
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 3
        lbl.Parent = btn

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 2, 0.55, 0)
        bar.Position = UDim2.new(0, 0, 0.225, 0)
        bar.BackgroundColor3 = C.accent_soft
        bar.BorderSizePixel = 0
        bar.Visible = false
        bar.ZIndex = 3
        bar.Parent = btn
        local brc = Instance.new("UICorner"); brc.CornerRadius = UDim.new(1, 0); brc.Parent = bar

        nav_buttons[name] = { btn = btn, lbl = lbl, sym = sym, bar = bar }

        btn.MouseButton1Click:Connect(function()
            show_page(name)
            for n, data in pairs(nav_buttons) do
                local active = (n == name)
                TweenService:Create(data.btn, TweenInfo.new(0.15), {
                    BackgroundTransparency = active and 0.65 or 1
                }):Play()
                data.lbl.TextColor3 = active and C.text or C.text_dim
                data.sym.TextColor3 = active and C.accent_soft or C.text_dim
                data.bar.Visible = active
            end
        end)
    end

    local function add_toggle(page, symbol, label, default, callback)
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0.5, -3, 0, 40)
        card.BackgroundColor3 = C.card
        card.BackgroundTransparency = 0.2
        card.Text = ""
        card.AutoButtonColor = false
        card.BorderSizePixel = 0
        card.ZIndex = 3
        card.Parent = pages[page]
        local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 8); cc.Parent = card
        local stroke = glow(card, C.accent_dim, 1, 0.45)

        local ico = Instance.new("Frame")
        ico.Size = UDim2.new(0, 24, 0, 24)
        ico.Position = UDim2.new(0, 6, 0.5, -12)
        ico.BackgroundColor3 = C.card_inner
        ico.BackgroundTransparency = 0.15
        ico.BorderSizePixel = 0
        ico.ZIndex = 3
        ico.Parent = card
        local icc = Instance.new("UICorner"); icc.CornerRadius = UDim.new(0, 6); icc.Parent = ico
        glow(ico, C.accent_dim, 1, 0.55)

        local ico_lbl = Instance.new("TextLabel")
        ico_lbl.Size = UDim2.new(1, 0, 1, 0)
        ico_lbl.BackgroundTransparency = 1
        ico_lbl.Text = symbol
        ico_lbl.TextColor3 = C.accent_soft
        ico_lbl.Font = Enum.Font.GothamBold
        ico_lbl.TextSize = 12
        ico_lbl.ZIndex = 3
        ico_lbl.Parent = ico

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -76, 1, 0)
        lbl.Position = UDim2.new(0, 36, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = C.text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 3
        lbl.Parent = card

        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 26, 0, 14)
        sw.Position = UDim2.new(1, -32, 0.5, -7)
        sw.BackgroundColor3 = default and C.accent or C.off
        sw.BorderSizePixel = 0
        sw.ZIndex = 3
        sw.Parent = card
        local swc = Instance.new("UICorner"); swc.CornerRadius = UDim.new(1, 0); swc.Parent = sw
        local sw_stroke = glow(sw, default and C.accent_soft or C.off, 1, default and 0.35 or 0.7)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.Position = default and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0
        knob.ZIndex = 3
        knob.Parent = sw
        local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

        local state = default
        local function render()
            TweenService:Create(sw, TweenInfo.new(0.18), {
                BackgroundColor3 = state and C.accent or C.off
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), {
                Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
            }):Play()
            sw_stroke.Color = state and C.accent_soft or C.off
            sw_stroke.Transparency = state and 0.35 or 0.7
            stroke.Color = state and C.accent or C.accent_dim
            stroke.Transparency = state and 0.2 or 0.45
        end

        card.MouseButton1Click:Connect(function()
            state = not state
            render()
            if callback then callback(state) end
        end)
    end

    local function add_button(page, symbol, label, cb)
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0.5, -3, 0, 40)
        card.BackgroundColor3 = C.card
        card.BackgroundTransparency = 0.2
        card.Text = ""
        card.AutoButtonColor = false
        card.BorderSizePixel = 0
        card.ZIndex = 3
        card.Parent = pages[page]
        local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 8); cc.Parent = card
        glow(card, C.accent_dim, 1, 0.45)

        local ico = Instance.new("Frame")
        ico.Size = UDim2.new(0, 24, 0, 24)
        ico.Position = UDim2.new(0, 6, 0.5, -12)
        ico.BackgroundColor3 = C.card_inner
        ico.BackgroundTransparency = 0.15
        ico.BorderSizePixel = 0
        ico.ZIndex = 3
        ico.Parent = card
        local icc = Instance.new("UICorner"); icc.CornerRadius = UDim.new(0, 6); icc.Parent = ico
        glow(ico, C.accent_dim, 1, 0.55)

        local ico_lbl = Instance.new("TextLabel")
        ico_lbl.Size = UDim2.new(1, 0, 1, 0)
        ico_lbl.BackgroundTransparency = 1
        ico_lbl.Text = symbol
        ico_lbl.TextColor3 = C.accent_soft
        ico_lbl.Font = Enum.Font.GothamBold
        ico_lbl.TextSize = 12
        ico_lbl.ZIndex = 3
        ico_lbl.Parent = ico

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -66, 1, 0)
        lbl.Position = UDim2.new(0, 36, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = C.text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 3
        lbl.Parent = card

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 14, 1, 0)
        arrow.Position = UDim2.new(1, -18, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "→"
        arrow.TextColor3 = C.accent_soft
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 12
        arrow.ZIndex = 3
        arrow.Parent = card

        card.MouseButton1Click:Connect(function()
            if cb then cb() end
        end)
    end

    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, -16, 0, 16)
    footer.Position = UDim2.new(0, 8, 1, -22)
    footer.BackgroundColor3 = C.panel
    footer.BackgroundTransparency = 0.4
    footer.BorderSizePixel = 0
    footer.ZIndex = 3
    footer.Parent = main
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 5); fc.Parent = footer

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.Position = UDim2.new(0, 6, 0.5, -2.5)
    dot.BackgroundColor3 = C.ok
    dot.BorderSizePixel = 0
    dot.ZIndex = 3
    dot.Parent = footer
    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = dot

    local ftxt = Instance.new("TextLabel")
    ftxt.Size = UDim2.new(1, -50, 1, 0)
    ftxt.Position = UDim2.new(0, 16, 0, 0)
    ftxt.BackgroundTransparency = 1
    ftxt.Text = "active  ┆  v1.0"
    ftxt.TextColor3 = C.text_dim
    ftxt.Font = Enum.Font.Gotham
    ftxt.TextSize = 9
    ftxt.TextXAlignment = Enum.TextXAlignment.Left
    ftxt.ZIndex = 3
    ftxt.Parent = footer

    new_page("Combat"); new_page("Player"); new_page("Visuals"); new_page("World"); new_page("Settings")
    add_nav("Combat",   "◈")
    add_nav("Player",   "⊙")
    add_nav("Visuals",  "◇")
    add_nav("World",    "⌘")
    add_nav("Settings", "⚙")

    add_toggle("Combat", "◎", "Silent Aim", CONFIG.silent_aim, function(v) CONFIG.silent_aim = v end)
    add_toggle("Combat", "◇", "Aimbot", CONFIG.aimbot, function(v) CONFIG.aimbot = v end)
    add_toggle("Combat", "◈", "FOV Circle", CONFIG.fov_circle, function(v) CONFIG.fov_circle = v end)
    add_toggle("Combat", "◆", "Wallbang", CONFIG.wallbang, function(v) CONFIG.wallbang = v end)
    add_toggle("Combat", "⊕", "Hitbox Expand", CONFIG.hitbox_expand, function(v) CONFIG.hitbox_expand = v end)
    add_toggle("Combat", "⟡", "Anti-Aim", CONFIG.anti_aim, function(v) CONFIG.anti_aim = v end)

    add_toggle("Player", "⟡", "God Mode", CONFIG.god_mode, function(v) CONFIG.god_mode = v end)
    add_toggle("Player", "⚡", "Fast Run", CONFIG.fast_run, function(v) CONFIG.fast_run = v end)
    add_toggle("Player", "◇", "No Clip", CONFIG.no_clip, function(v) CONFIG.no_clip = v end)
    add_toggle("Player", "⌘", "Fly", CONFIG.fly, function(v) CONFIG.fly = v end)

    add_toggle("Visuals", "◇", "Player ESP", CONFIG.player_esp, function(v) CONFIG.player_esp = v end)
    add_toggle("Visuals", "◈", "Role ESP", CONFIG.role_esp, function(v) CONFIG.role_esp = v end)
    add_toggle("Visuals", "◎", "Name Tags", CONFIG.name_tags, function(v) CONFIG.name_tags = v end)
    add_toggle("Visuals", "⊙", "Distance ESP", CONFIG.distance_esp, function(v) CONFIG.distance_esp = v end)

    add_toggle("World", "☀", "Fullbright", CONFIG.fullbright, function(v) CONFIG.fullbright = v end)
    add_toggle("World", "◇", "No Fog", CONFIG.no_fog, function(v) CONFIG.no_fog = v end)
    add_toggle("World", "◈", "RGB Lighting", CONFIG.rgb_lighting, function(v) CONFIG.rgb_lighting = v end)
    add_toggle("World", "◎", "Time Changer", CONFIG.time_changer, function(v) CONFIG.time_changer = v end)

    add_button("Settings", "⟢", "Save Config")
    add_button("Settings", "⟣", "Reset Config")
    add_button("Settings", "⌘", "Keybind Manager")
    add_button("Settings", "×", "Destroy UI", function()
        pcall(function() gui:Destroy() end)
    end)

    show_page("Combat")
    nav_buttons["Combat"].lbl.TextColor3 = C.text
    nav_buttons["Combat"].sym.TextColor3 = C.accent_soft
    nav_buttons["Combat"].bar.Visible = true
    nav_buttons["Combat"].btn.BackgroundTransparency = 0.65

    local function make_corner_button(symbol, position, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 30, 0, 30)
        b.Position = position
        b.BackgroundColor3 = C.panel
        b.BackgroundTransparency = 0.2
        b.Text = symbol
        b.TextColor3 = C.text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 16
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Parent = gui
        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 8); bc.Parent = b
        glow(b, C.accent, 1, 0.3)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    make_corner_button("≡", UDim2.new(0, 20, 0, 100), function()
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 0)
        main.Position = UDim2.new(0.5, 0, 0.5, 20)
        TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, WIN_W, 0, WIN_H),
            Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2 + 20)
        }):Play()
    end)

    make_corner_button("×", UDim2.new(0, 20, 0, 136), function()
        TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 20)
        }):Play()
        task.wait(0.2)
        main.Visible = false
    end)

    _G.MM2_STOP = function()
        State.running = false
        for _, c in ipairs(State.connections) do pcall(function() c:Disconnect() end) end
        clear_esp()
        pcall(function() gui:Destroy() end)
        print("[MM2] stopped")
    end

    print(">>> MM2 combat build ready")
    print(">>> menu: ≡   close: ×")
    print(">>> stop: _G.MM2_STOP()")
end)

if not ok then
    warn("[MM2] fatal:", tostring(err))
end
