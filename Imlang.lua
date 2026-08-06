--[[ memaybeo hub v12.4 (Custom Crosshair Aimbot + Health ESP + True No Fall + Stealth Speed) ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Check session webhook
local sessionKey = "MemaybeoHub_Executed_" .. tostring(LocalPlayer.UserId)
if getgenv()[sessionKey] then
    warn("[memaybeo hub]: Webhook already sent for this game session.")
else
    getgenv()[sessionKey] = true
    task.spawn(function()
        pcall(function()
            local requestFunc = syn and syn.request or request or http_request or (Fluxus and Fluxus.request)
            if requestFunc then
                requestFunc({
                    Url = "https://zann-hub-proxy.kazutotababi1.workers.dev",
                    Method = "POST"
                })
            end
        end)
    end)
end

if CoreGui:FindFirstChild("MemaybeoHub") then
    CoreGui.MemaybeoHub:Destroy()
end

local Config = {
    PlayerESP = false,
    MonsterESP = false,
    ItemESP = false,
    LocationESP = false,
    Fullbright = false,
    NoFog = false,
    
    InstantInteract = false,
    AimbotPlayers = false,
    AimbotMonsters = false,
    SpeedHack = false,
    WalkSpeed = 50,       
    JumpHack = false,
    JumpPower = 150,
    HitboxExpander = false,
    NoFallDamage = false,    
    
    ShowFOV = true,          
    FOVRadius = 120,         
    MaxAimDistance = 500,    
    WallCheck = true,        
    FixLag = false,          
    
    Filters = { Weapon = true, Ammo = true, Medical = true, Food = true, Battery = true, Other = true }
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MemaybeoHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- [QUAN TRỌNG] Tắt Inset để tọa độ FOV khớp với tọa độ 3D
pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
end)
if not ScreenGui.Parent then ScreenGui.Parent = CoreGui end

-- [MỚI] Hàm lấy tọa độ tâm súng (MenuGui.Notice)
local function getCrosshairCenter()
    local defaultCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return defaultCenter end
    
    local menuGui = playerGui:FindFirstChild("MenuGui")
    if menuGui then
        local notice = menuGui:FindFirstChild("Notice")
        if notice and notice:IsA("GuiObject") and notice.Visible then
            -- Tính tọa độ chính giữa của UI Notice
            return Vector2.new(
                notice.AbsolutePosition.X + (notice.AbsoluteSize.X / 2),
                notice.AbsolutePosition.Y + (notice.AbsoluteSize.Y / 2)
            )
        end
    end
    return defaultCenter -- Trả về giữa màn hình nếu không tìm thấy Notice
end

-- Vòng FOV UI chuẩn
local FOVCircleUI = Instance.new("Frame")
FOVCircleUI.Name = "FOVCircle"
FOVCircleUI.Parent = ScreenGui
FOVCircleUI.BackgroundTransparency = 1
FOVCircleUI.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleUI.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircleUI.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
FOVCircleUI.Visible = false

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = FOVCircleUI

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(0, 162, 255)
fovStroke.Thickness = 2
fovStroke.Parent = FOVCircleUI

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -175)
MainFrame.Size = UDim2.new(0, 220, 0, 420)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 162, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local MobileToggle = Instance.new("ImageButton")
MobileToggle.Name = "MobileToggle"
MobileToggle.Parent = ScreenGui
MobileToggle.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
MobileToggle.BorderSizePixel = 0
MobileToggle.Position = UDim2.new(0, 20, 0, 20)
MobileToggle.Size = UDim2.new(0, 40, 0, 40)
MobileToggle.Image = "rbxassetid://72109980565665"
MobileToggle.Active = true
MobileToggle.Draggable = true
Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(1, 0)
local MobileStroke = Instance.new("UIStroke", MobileToggle)
MobileStroke.Color = Color3.fromRGB(0, 162, 255)
MobileStroke.Thickness = 1.5

MobileToggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 33, 48)
TitleLabel.BorderSizePixel = 0
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "  memaybeo hub"
TitleLabel.TextColor3 = Color3.fromRGB(210, 240, 255)
TitleLabel.TextSize = 11
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TitleLabel).CornerRadius = UDim.new(0, 8)

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = TitleLabel
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, -8, 0, 0)
SubTitle.Size = UDim2.new(1, -10, 1, 0)
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.Text = "[RightShift]"
SubTitle.TextColor3 = Color3.fromRGB(110, 150, 190)
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Right

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Parent = MainFrame
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.Position = UDim2.new(0, 6, 0, 36)
ScrollContainer.Size = UDim2.new(1, -12, 1, -42)
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 850)
ScrollContainer.ScrollBarThickness = 3
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local toggleButtons = {}

local function createHeader(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(80, 180, 255)
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = ScrollContainer
end

local function createToggle(name, configKey, isFilter, callback)
    local default = isFilter and Config.Filters[configKey] or Config[configKey]
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(24, 30, 42)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(235, 245, 255)
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = ScrollContainer
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 40, 1, 0)
    status.Position = UDim2.new(1, -45, 0, 0)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.GothamBold
    status.Text = default and "ON" or "OFF"
    status.TextColor3 = default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 130, 160)
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = btn

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local function updateState(newState)
        if isFilter then
            Config.Filters[configKey] = newState
        else
            Config[configKey] = newState
        end
        btn.BackgroundColor3 = newState and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(24, 30, 42)
        status.Text = newState and "ON" or "OFF"
        status.TextColor3 = newState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 130, 160)
        if callback then callback(newState) end
    end

    btn.MouseButton1Click:Connect(function()
        local currentVal = isFilter and Config.Filters[configKey] or Config[configKey]
        updateState(not currentVal)
    end)

    toggleButtons[configKey] = {button = btn, update = updateState}
end

-- ==================== MENU ====================
createHeader("--- VISUALS & ESP ---")
createToggle("Player ESP (+ Máu)", "PlayerESP", false)
createToggle("Monster ESP (+ Máu)", "MonsterESP", false)
createToggle("Items ESP", "ItemESP", false)
createToggle("Location ESP", "LocationESP", false)
createToggle("Fullbright", "Fullbright", false)
createToggle("No Fog", "NoFog", false, function(state)
    if state then
        Lighting.FogEnd = 100000
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then v:Destroy() end
        end
    end
end)

createHeader("--- AIMBOT & COMBAT ---")
createToggle("Aimbot Đầu Người [E]", "AimbotPlayers", false)
createToggle("Aimbot Đầu Quái [E]", "AimbotMonsters", false)
createToggle("Show FOV Circle", "ShowFOV", false)
createToggle("Aimbot Wall Check", "WallCheck", false)
createToggle("Hitbox Expander", "HitboxExpander", false)

createHeader("--- PLAYER MODS ---")
createToggle("No Fall Damage", "NoFallDamage", false)
createToggle("Instant Interact", "InstantInteract", false)
createToggle("Anti-Rubberband Speed", "SpeedHack", false)
createToggle("Jump Hack", "JumpHack", false)

createHeader("--- FOV ADJUSTMENT ---")
local fovBtn = Instance.new("TextButton")
fovBtn.Size = UDim2.new(1, 0, 0, 24)
fovBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
fovBtn.BorderSizePixel = 0
fovBtn.Font = Enum.Font.GothamSemibold
fovBtn.Text = "  FOV Size: [" .. Config.FOVRadius .. "] (Click to +30)"
fovBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
fovBtn.TextSize = 10
fovBtn.TextXAlignment = Enum.TextXAlignment.Left
fovBtn.Parent = ScrollContainer
Instance.new("UICorner", fovBtn).CornerRadius = UDim.new(0, 5)

fovBtn.MouseButton1Click:Connect(function()
    Config.FOVRadius = Config.FOVRadius + 30
    if Config.FOVRadius > 300 then Config.FOVRadius = 60 end
    fovBtn.Text = "  FOV Size: [" .. Config.FOVRadius .. "] (Click to +30)"
end)

createHeader("--- PERFORMANCE ---")
createToggle("Fix Lag / FPS Boost", "FixLag", false, function(state)
    if state then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
        end)
    else
        pcall(function() Lighting.GlobalShadows = true end)
    end
end)

createHeader("--- ITEM FILTERS ---")
createToggle("Weapon", "Weapon", true)
createToggle("Ammo", "Ammo", true)
createToggle("Medical", "Medical", true)
createToggle("Food", "Food", true)
createToggle("Battery", "Battery", true)
createToggle("Other", "Other", true)
-- ===============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.E and not gameProcessed then
        if toggleButtons["AimbotPlayers"] then toggleButtons["AimbotPlayers"].update(not Config.AimbotPlayers) end
        if toggleButtons["AimbotMonsters"] then toggleButtons["AimbotMonsters"].update(not Config.AimbotMonsters) end
    end
end)

local ESPCache = {}
local function getDrawing(target, isEntity)
    if not Drawing or not Drawing.new then return nil end
    if not ESPCache[target] then
        local obj = {}
        local successTxt, txt = pcall(function()
            local t = Drawing.new("Text")
            t.Visible = false
            t.Center = true
            t.Outline = true
            t.OutlineColor = Color3.fromRGB(0, 0, 0)
            t.Font = 1
            t.Size = 13
            return t
        end)
        if successTxt then obj.Text = txt end
        
        if isEntity then
            local bg = Drawing.new("Square")
            bg.Visible = false
            bg.Filled = true
            bg.Color = Color3.fromRGB(0, 0, 0)
            bg.Thickness = 1
            obj.Bg = bg
            
            local bar = Drawing.new("Square")
            bar.Visible = false
            bar.Filled = true
            bar.Color = Color3.fromRGB(0, 255, 0)
            bar.Thickness = 1
            obj.Bar = bar
        end
        ESPCache[target] = obj
    end
    return ESPCache[target]
end

local function IsVisible(targetModel, targetPart)
    local char = LocalPlayer.Character
    if not char or not targetPart then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, targetModel} 
    params.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    return workspace:Raycast(origin, dir, params) == nil
end

local function getItemCategory(name)
    name = string.lower(name)
    if string.find(name, "battery") or string.find(name, "cell") or string.find(name, "power") then return "Battery"
    elseif string.find(name, "flare gun") or string.find(name, "gun") or string.find(name, "rifle") or string.find(name, "pistol") or string.find(name, "shotgun") or string.find(name, "smg") or string.find(name, "knife") or string.find(name, "sword") or string.find(name, "weapon") then return "Weapon"
    elseif string.find(name, "ammo") or string.find(name, "bullet") or string.find(name, "mag") or string.find(name, "round") or string.find(name, "shell") then return "Ammo"
    elseif string.find(name, "med") or string.find(name, "bandage") or string.find(name, "heal") or string.find(name, "kit") or string.find(name, "pill") then return "Medical"
    elseif string.find(name, "food") or string.find(name, "water") or string.find(name, "drink") or string.find(name, "can") then return "Food"
    else return "Other" end
end

local function isValidItemName(name)
    local low = string.lower(name)
    if string.find(low, "door") or string.find(low, "opener") or string.find(low, "gate") or string.find(low, "lever") or string.find(low, "house") or string.find(low, "building") then return false end
    return true
end

local locNames = {["BrokenHouseE"]=true, ["BuildingA"]=true, ["CabinA"]=true, ["HouseA"]=true, ["HouseB"]=true, ["HouseD"]=true, ["HouseE"]=true, ["HouseG"]=true, ["ShackA"]=true}
local scanTimer = 0
local cachedEntities = {}
local cachedItems = {}
local cachedLocations = {}
local isJumpingOrFalling = false

local function setupNoFallDamage(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    local lastHealth = hum.Health
    local wasFalling = false
    
    hum.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Freefall then
            wasFalling = true
        elseif state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Land then
            wasFalling = false
        end
    end)
    
    hum.HealthChanged:Connect(function(newHealth)
        if Config.NoFallDamage and wasFalling and newHealth < lastHealth then
            hum.Health = lastHealth
        else
            lastHealth = newHealth
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(setupNoFallDamage)
if LocalPlayer.Character then task.spawn(function() setupNoFallDamage(LocalPlayer.Character) end) end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") and Config.InstantInteract then obj.HoldDuration = 0 end
end)

RunService.RenderStepped:Connect(function(dt)
    -- [MỚI] Tự động cập nhật vị trí FOV theo UI Notice
    local currentCrosshairPos = getCrosshairCenter()
    
    if Config.ShowFOV then
        FOVCircleUI.Position = UDim2.new(0, currentCrosshairPos.X, 0, currentCrosshairPos.Y)
        FOVCircleUI.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
        FOVCircleUI.Visible = true
    else
        FOVCircleUI.Visible = false
    end

    if Config.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

    scanTimer = scanTimer + dt
    if scanTimer >= 1.0 then
        scanTimer = 0
        cachedEntities = {}
        cachedItems = {}
        cachedLocations = {}
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum then
                    local p = Players:GetPlayerFromCharacter(obj)
                    if p and p ~= LocalPlayer then
                        table.insert(cachedEntities, {type = "Player", model = obj, name = p.Name})
                    elseif not p then
                        local nLow = string.lower(obj.Name)
                        if nLow ~= "camera" and not string.find(nLow, "item") then
                            table.insert(cachedEntities, {type = "Monster", model = obj, name = obj.Name})
                        end
                    end
                end
                
                if locNames[obj.Name] then
                    local prim = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if prim then table.insert(cachedLocations, {part = prim, name = obj.Name}) end
                end
            elseif obj:IsA("ProximityPrompt") then
                if Config.InstantInteract then obj.HoldDuration = 0 end
                
                local itemParent = obj.Parent
                while itemParent and itemParent ~= Workspace do
                    if itemParent:IsA("Model") then
                        local realName = itemParent.Name
                        if isValidItemName(realName) then
                            local primary = itemParent.PrimaryPart or itemParent:FindFirstChildWhichIsA("BasePart")
                            if primary and realName ~= "Workspace" then
                                table.insert(cachedItems, {part = primary, name = realName, cat = getItemCategory(realName)})
                                break
                            end
                        end
                    end
                    itemParent = itemParent.Parent
                end
            end
        end
    end

    local closestTarget = nil
    local shortestDist = math.huge
    local activeDrawings = {}

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            if Config.NoFallDamage then
                local vel = hrp.AssemblyLinearVelocity
                if vel.Y < -30 then
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, -5, vel.Z)
                end
            end

            if Config.SpeedHack then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    local baseSpeed = hum.WalkSpeed
                    local extraSpeed = Config.WalkSpeed - baseSpeed
                    if extraSpeed > 0 then
                        hrp.CFrame = hrp.CFrame + (moveDir * (extraSpeed * dt))
                    end
                end
            end
            
            if Config.JumpHack then
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpPower
                if hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall then
                    isJumpingOrFalling = true
                elseif isJumpingOrFalling then
                    if hum.FloorMaterial ~= Enum.Material.Air then isJumpingOrFalling = false
                    else
                        local vel = hrp.AssemblyLinearVelocity
                        if vel.Y < -100 then hrp.AssemblyLinearVelocity = Vector3.new(vel.X, -50, vel.Z) end
                    end
                end
            end
        end
    end

    if Config.HitboxExpander then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local enemyHRP = p.Character.HumanoidRootPart
                    enemyHRP.Size = Vector3.new(5, 5, 5)
                    enemyHRP.Transparency = 0.8
                    enemyHRP.BrickColor = BrickColor.new("Really blue")
                    enemyHRP.Material = Enum.Material.Neon
                    enemyHRP.CanCollide = false
                end)
            end
        end
    end

    for _, entity in ipairs(cachedEntities) do
        local model = entity.model
        local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        local hum = model:FindFirstChildOfClass("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                local showPlr = (entity.type == "Player" and Config.PlayerESP)
                local showMon = (entity.type == "Monster" and Config.MonsterESP)

                if showPlr or showMon then
                    local esp = getDrawing(model, true)
                    if esp then
                        activeDrawings[model] = true
                        
                        if esp.Text then
                            esp.Text.Visible = true
                            esp.Text.Position = Vector2.new(pos.X, pos.Y - 15)
                            if entity.type == "Player" then
                                esp.Text.Text = string.format("[Player] %s [%dm]", entity.name, math.floor(dist))
                                esp.Text.Color = Color3.fromRGB(80, 200, 255)
                            else
                                esp.Text.Text = string.format("[Monster] %s [%dm]", entity.name, math.floor(dist))
                                esp.Text.Color = Color3.fromRGB(255, 50, 50)
                            end
                        end
                        
                        if esp.Bg and esp.Bar then
                            local scale = math.clamp(1000 / dist, 15, 60)
                            local barHeight = scale * 1.5
                            local barWidth = 3
                            local healthPct = 1
                            if hum.MaxHealth > 0 then healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1) end
                            
                            esp.Bg.Visible = true
                            esp.Bg.Size = Vector2.new(barWidth, barHeight)
                            esp.Bg.Position = Vector2.new(pos.X - (scale/2) - 10, pos.Y - barHeight/2)
                            
                            esp.Bar.Visible = true
                            esp.Bar.Size = Vector2.new(barWidth, barHeight * healthPct)
                            esp.Bar.Position = Vector2.new(pos.X - (scale/2) - 10, (pos.Y - barHeight/2) + (barHeight - (barHeight * healthPct)))
                            esp.Bar.Color = Color3.fromRGB(255 - (healthPct * 255), healthPct * 255, 0)
                        end
                    end

                    -- [MỚI] Aimbot tính toán khoảng cách dựa trên tâm Notice (Custom Crosshair)
                    local doAim = (Config.AimbotPlayers and entity.type == "Player") or (Config.AimbotMonsters and entity.type == "Monster")
                    if doAim then
                        local aimPart = model:FindFirstChild("Head") or hrp
                        local aimPos, aimOnScreen = Camera:WorldToViewportPoint(aimPart.Position)
                        
                        if aimOnScreen then
                            -- Dùng tọa độ của UI Notice làm tâm thay vì giữa màn hình
                            local d2Center = (Vector2.new(aimPos.X, aimPos.Y) - currentCrosshairPos).Magnitude
                            if d2Center <= Config.FOVRadius and dist <= Config.MaxAimDistance then
                                if not Config.WallCheck or IsVisible(model, aimPart) then
                                    if d2Center < shortestDist then
                                        shortestDist = d2Center
                                        closestTarget = aimPart
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if Config.LocationESP then
        for _, loc in ipairs(cachedLocations) do
            local pos, onScreen = Camera:WorldToViewportPoint(loc.part.Position)
            if onScreen then
                local dist = (Camera.CFrame.Position - loc.part.Position).Magnitude
                local esp = getDrawing(loc.part, false)
                if esp and esp.Text then
                    activeDrawings[loc.part] = true
                    esp.Text.Visible = true
                    esp.Text.Position = Vector2.new(pos.X, pos.Y)
                    esp.Text.Text = string.format("[Location] %s [%dm]", loc.name, math.floor(dist))
                    esp.Text.Color = Color3.fromRGB(255, 170, 0)
                end
            end
        end
    end

    if Config.ItemESP then
        for _, item in ipairs(cachedItems) do
            if Config.Filters[item.cat] then
                local pos, onScreen = Camera:WorldToViewportPoint(item.part.Position)
                if onScreen then
                    local dist = (Camera.CFrame.Position - item.part.Position).Magnitude
                    local esp = getDrawing(item.part, false)
                    if esp and esp.Text then
                        activeDrawings[item.part] = true
                        esp.Text.Visible = true
                        esp.Text.Position = Vector2.new(pos.X, pos.Y)
                        esp.Text.Text = string.format("[%s] %s [%dm]", item.cat, item.name, math.floor(dist))
                        esp.Text.Color = Color3.fromRGB(255, 220, 50)
                    end
                end
            end
        end
    end

    for target, esp in pairs(ESPCache) do
        if not activeDrawings[target] then
            if esp.Text then esp.Text.Visible = false end
            if esp.Bg then esp.Bg.Visible = false end
            if esp.Bar then esp.Bar.Visible = false end
        end
    end

    if (Config.AimbotPlayers or Config.AimbotMonsters) and closestTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
    end
end)

