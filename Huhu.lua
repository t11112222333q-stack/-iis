--[[
	MEMAYBEO HUB - AUTO BUST ATM (VIP FAST FLY + SKY WAIT + ANTI-SEAT + AUTO EVADE)
	- BẢN CẬP NHẬT TỐI THƯỢNG: Bay siêu tốc trên trời cao (Tránh tòa nhà).
	- Đủ 10 ATM -> Bay về bãi VIP -> Đợi 3s -> Nhảy 1 cái chống lỗi -> Đi cày tiếp.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Config = {
    AutoBust = false,
    Fling = false,
    HoldDuration = 5.0,
    TargetFOV = 120,
    EvadePlayers = true,   
    EvadeRadius = 25.0,    
    AntiSeat = true,       
}

-- TỌA ĐỘ VIP
local TARGET_COORD = CFrame.new(-2543.30786, 12.3932114, 4030.31909, -0.976807475, 0, 0.214121059, 0, 1, 0, -0.214121059, 0, -0.976807475)

local BustedATMs = {}
local CurrentAimTarget = nil
local ATMsBustedCount = 0 -- BỘ ĐẾM ATM (Đủ 10 sẽ bay về VIP)

--// CỐ ĐỊNH FOV 120 & KHÓA CỨNG CAMERA VÀO NÚT E
RunService.RenderStepped:Connect(function()
    local cam = Workspace.CurrentCamera
    if cam then
        if cam.FieldOfView ~= Config.TargetFOV then
            cam.FieldOfView = Config.TargetFOV
        end
        if CurrentAimTarget and Config.AutoBust then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, CurrentAimTarget)
        end
    end
end)

--// CHỐNG NGỒI GHẾ (ANTI-SEAT) & ANTI-AFK
RunService.Stepped:Connect(function()
    if Config.AntiSeat or Config.AutoBust then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit then
                hum.Sit = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// KIỂM TRA XEM CÓ NGƯỜI CHƠI NÀO Ở GẦN KHÔNG
local function IsPlayerNearby()
    if not Config.EvadePlayers then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local myPos = hrp.Position
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local otherHum = player.Character:FindFirstChildOfClass("Humanoid")
            if otherHRP and otherHum and otherHum.Health > 0 then
                local dist = (myPos - otherHRP.Position).Magnitude
                if dist <= Config.EvadeRadius then
                    return true, player.Name, dist
                end
            end
        end
    end
    return false
end

--// LẤY TẤT CẢ ATM CHƯA PHÁ
local function GetAllATMs()
    local atms = {}
    local spawners = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Jobs") and Workspace.Game.Jobs:FindFirstChild("CriminalATMSpawners")
    if spawners then
        for _, child in pairs(spawners:GetChildren()) do
            local atm = child:FindFirstChild("CriminalATM") or child:FindFirstChild("CriminalATMWater")
            if atm and atm:IsA("Model") and not BustedATMs[atm] then 
                local prompt = atm:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Enabled then
                    table.insert(atms, atm) 
                end
            end
        end
    end
    return atms
end

--// LẤY VỊ TRÍ ATM
local function GetATMPosition(atm)
    local hrp = atm:FindFirstChild("HumanoidRootPart") or atm:FindFirstChildWhichIsA("BasePart", true)
    return hrp and hrp.Position or atm:GetPivot().Position
end

--// TÌM ATM GẦN NHẤT
local function GetNearestATM()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local pos = char.HumanoidRootPart.Position

    local atms = GetAllATMs()
    if #atms == 0 then 
        BustedATMs = {}
        atms = GetAllATMs()
        if #atms == 0 then return nil end
    end

    local nearest, nearestDist = nil, math.huge
    for _, atm in pairs(atms) do
        local d = (pos - GetATMPosition(atm)).Magnitude
        if d < nearestDist then nearestDist, nearest = d, atm end
    end

    return nearest
end

--// =================================================================
--// HỆ THỐNG BAY SIÊU TỐC TRÊN CAO (XUYÊN TƯỜNG + TRÁNH OBSTACLES)
--// =================================================================
local function FastFly(targetCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    CurrentAimTarget = nil
    local flySpeed = 700 -- Tốc độ bay (studs/s) - Cực nhanh
    local flyHeight = 400 -- Bay tuốt lên cao 400 studs để né mọi loại địa hình
    
    -- Bật noclip để không vướng tường khi cất/hạ cánh
    local noclipConnection = RunService.Stepped:Connect(function()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end)
    
    local function doTween(pos)
        local dist = (hrp.Position - pos).Magnitude
        local t = dist / flySpeed
        if t < 0.05 then t = 0.05 end -- Tránh lỗi chia 0
        local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
        tw:Play()
        tw.Completed:Wait()
    end
    
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    -- 1. Bốc đầu bay thẳng đứng lên trời
    doTween(Vector3.new(hrp.Position.X, flyHeight, hrp.Position.Z))
    
    -- 2. Bay ngang trên không tới phía trên mục tiêu
    doTween(Vector3.new(targetCFrame.X, flyHeight, targetCFrame.Z))
    
    -- 3. Đáp thẳng xuống mục tiêu (sử dụng CFrame gốc để lấy luôn góc quay)
    local finalDist = (hrp.Position - targetCFrame.Position).Magnitude
    local finalT = finalDist / flySpeed
    if finalT < 0.05 then finalT = 0.05 end
    local finalTw = TweenService:Create(hrp, TweenInfo.new(finalT, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    finalTw:Play()
    finalTw.Completed:Wait()
    
    hrp.AssemblyLinearVelocity = Vector3.zero
    noclipConnection:Disconnect() -- Tắt Noclip khi đã hạ cánh an toàn
end

--// BAY LÊN KHÔNG TRUNG ĐỂ CHỜ TRÁNH CẢNH SÁT (TWEEN MƯỢT)
local function FlyToSky()
    CurrentAimTarget = nil
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local tw = TweenService:Create(hrp, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {CFrame = CFrame.new(hrp.Position.X, 350, hrp.Position.Z)})
        tw:Play()
    end
end

--// CHẾ ĐỘ TUẦN TRA TRÊN TRỜI NẾU CÓ NGƯỜI
local function PatrolAroundMap()
    CurrentAimTarget = nil
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local timeSec = tick()
        local speed = 1.2 
        local mapRadiusX = 1000
        local mapRadiusZ = 1000
        local flyHeight = 350
        
        local x = math.cos(timeSec * speed) * mapRadiusX
        local z = math.sin(timeSec * speed) * mapRadiusZ
        
        hrp.CFrame = CFrame.new(x, flyHeight, z)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

--// TẠO UI
local function CreateUI()
    if CoreGui:FindFirstChild("ATMBuster_God") then CoreGui.ATMBuster_God:Destroy() end

    local SG = Instance.new("ScreenGui")
    SG.Name = "ATMBuster_God"
    SG.ResetOnSpawn = false
    SG.Parent = CoreGui

    local Frame = Instance.new("Frame", SG)
    Frame.Size = UDim2.new(0, 260, 0, 320)
    Frame.Position = UDim2.new(0.8, -130, 0.5, -160)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(255, 200, 50)
    Frame.Active = true
    Frame.Draggable = true

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "🏧 AUTO ATM (FAST FLY + JUMP)"
    Title.TextColor3 = Color3.fromRGB(255, 200, 50)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 11
    Title.BackgroundTransparency = 1

    local ATMCountLabel = Instance.new("TextLabel", Frame)
    ATMCountLabel.Size = UDim2.new(1, 0, 0, 14)
    ATMCountLabel.Position = UDim2.new(0, 0, 0, 26)
    ATMCountLabel.Text = "Đang tải ATM..."
    ATMCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ATMCountLabel.Font = Enum.Font.Gotham
    ATMCountLabel.TextSize = 10
    ATMCountLabel.BackgroundTransparency = 1

    local HoldLabel = Instance.new("TextLabel", Frame)
    HoldLabel.Size = UDim2.new(1, 0, 0, 14)
    HoldLabel.Position = UDim2.new(0, 0, 0, 42)
    HoldLabel.Text = "Thời gian giữ: " .. Config.HoldDuration .. "s"
    HoldLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    HoldLabel.Font = Enum.Font.Gotham
    HoldLabel.TextSize = 10
    HoldLabel.BackgroundTransparency = 1

    local SliderBg = Instance.new("Frame", Frame)
    SliderBg.Size = UDim2.new(0.85, 0, 0, 4)
    SliderBg.Position = UDim2.new(0.075, 0, 0.18, 0)
    SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

    local fillPercent = math.clamp((Config.HoldDuration - 0.5) / 4.5, 0, 1)
    local SliderFill = Instance.new("Frame", SliderBg)
    SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    local SliderDot = Instance.new("TextButton", SliderBg)
    SliderDot.Size = UDim2.new(0, 12, 0, 12)
    SliderDot.Position = UDim2.new(fillPercent, -6, 0.5, -6)
    SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderDot.Text = ""
    Instance.new("UICorner", SliderDot).CornerRadius = UDim.new(1, 0)

    local dragging1 = false
    SliderDot.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging1 = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging1 = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging1 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor((0.5 + rel * 4.5) * 10) / 10
            Config.HoldDuration = val
            HoldLabel.Text = "Thời gian giữ: " .. val .. "s"
            SliderFill.Size = UDim2.new(rel, 0, 1, 0)
            SliderDot.Position = UDim2.new(rel, -6, 0.5, -6)
        end
    end)

    local EvadeLabel = Instance.new("TextLabel", Frame)
    EvadeLabel.Size = UDim2.new(1, 0, 0, 14)
    EvadeLabel.Position = UDim2.new(0, 0, 0, 68)
    EvadeLabel.Text = "Bán kính né người: " .. math.floor(Config.EvadeRadius) .. " studs"
    EvadeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    EvadeLabel.Font = Enum.Font.Gotham
    EvadeLabel.TextSize = 10
    EvadeLabel.BackgroundTransparency = 1

    local SliderBg2 = Instance.new("Frame", Frame)
    SliderBg2.Size = UDim2.new(0.85, 0, 0, 4)
    SliderBg2.Position = UDim2.new(0.075, 0, 0.27, 0)
    SliderBg2.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", SliderBg2).CornerRadius = UDim.new(1, 0)

    local fillPercent2 = math.clamp((Config.EvadeRadius - 10) / 90, 0, 1)
    local SliderFill2 = Instance.new("Frame", SliderBg2)
    SliderFill2.Size = UDim2.new(fillPercent2, 0, 1, 0)
    SliderFill2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    Instance.new("UICorner", SliderFill2).CornerRadius = UDim.new(1, 0)

    local SliderDot2 = Instance.new("TextButton", SliderBg2)
    SliderDot2.Size = UDim2.new(0, 12, 0, 12)
    SliderDot2.Position = UDim2.new(fillPercent2, -6, 0.5, -6)
    SliderDot2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderDot2.Text = ""
    Instance.new("UICorner", SliderDot2).CornerRadius = UDim.new(1, 0)

    local dragging2 = false
    SliderDot2.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging2 = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging2 = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging2 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((input.Position.X - SliderBg2.AbsolutePosition.X) / SliderBg2.AbsoluteSize.X, 0, 1)
            local val = math.floor(10 + rel * 90)
            Config.EvadeRadius = val
            EvadeLabel.Text = "Bán kính né người: " .. val .. " studs"
            SliderFill2.Size = UDim2.new(rel, 0, 1, 0)
            SliderDot2.Position = UDim2.new(rel, -6, 0.5, -6)
        end
    end)

    local EvadeBtn = Instance.new("TextButton", Frame)
    EvadeBtn.Size = UDim2.new(0.85, 0, 0, 24)
    EvadeBtn.Position = UDim2.new(0.075, 0, 0.32, 0)
    EvadeBtn.Text = "🛡️ NÉ NGƯỜI LẠI GẦN: ON"
    EvadeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    EvadeBtn.Font = Enum.Font.GothamBold
    EvadeBtn.TextSize = 10
    EvadeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    Instance.new("UICorner", EvadeBtn).CornerRadius = UDim.new(0, 6)

    EvadeBtn.MouseButton1Click:Connect(function()
        Config.EvadePlayers = not Config.EvadePlayers
        EvadeBtn.Text = Config.EvadePlayers and "🛡️ NÉ NGƯỜI LẠI GẦN: ON" or "🛡️ NÉ NGƯỜI LẠI GẦN: OFF"
        EvadeBtn.BackgroundColor3 = Config.EvadePlayers and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(80, 80, 90)
    end)

    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0.85, 0, 0, 30)
    ToggleBtn.Position = UDim2.new(0.075, 0, 0.42, 0)
    ToggleBtn.Text = "🔴 BẬT AUTO"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 11
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

    local StatusLabel = Instance.new("TextLabel", Frame)
    StatusLabel.Size = UDim2.new(1, 0, 0, 18)
    StatusLabel.Position = UDim2.new(0, 0, 1, -18)
    StatusLabel.Text = "⏸️ Đã dừng"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 10
    StatusLabel.BackgroundTransparency = 1

    local TeleportBtn = Instance.new("TextButton", Frame)
    TeleportBtn.Size = UDim2.new(0.42, 0, 0, 24)
    TeleportBtn.Position = UDim2.new(0.075, 0, 0.54, 0)
    TeleportBtn.Text = "📍 Bay tới ATM"
    TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportBtn.Font = Enum.Font.GothamBold
    TeleportBtn.TextSize = 10
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    Instance.new("UICorner", TeleportBtn).CornerRadius = UDim.new(0, 6)

    local BustBtn = Instance.new("TextButton", Frame)
    BustBtn.Size = UDim2.new(0.42, 0, 0, 24)
    BustBtn.Position = UDim2.new(0.505, 0, 0.54, 0)
    BustBtn.Text = "💥 Phá Thử"
    BustBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BustBtn.Font = Enum.Font.GothamBold
    BustBtn.TextSize = 10
    BustBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Instance.new("UICorner", BustBtn).CornerRadius = UDim.new(0, 6)

    local TeleCoordBtn = Instance.new("TextButton", Frame)
    TeleCoordBtn.Size = UDim2.new(0.85, 0, 0, 24)
    TeleCoordBtn.Position = UDim2.new(0.075, 0, 0.64, 0)
    TeleCoordBtn.Text = "🎯 Bay Về Tọa Độ VIP"
    TeleCoordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleCoordBtn.Font = Enum.Font.GothamBold
    TeleCoordBtn.TextSize = 10
    TeleCoordBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
    Instance.new("UICorner", TeleCoordBtn).CornerRadius = UDim.new(0, 6)

    local FlingBtn = Instance.new("TextButton", Frame)
    FlingBtn.Size = UDim2.new(0.85, 0, 0, 24)
    FlingBtn.Position = UDim2.new(0.075, 0, 0.74, 0)
    FlingBtn.Text = "🚀 BẬT FLING: OFF"
    FlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlingBtn.Font = Enum.Font.GothamBold
    FlingBtn.TextSize = 10
    FlingBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    Instance.new("UICorner", FlingBtn).CornerRadius = UDim.new(0, 6)

    ToggleBtn.MouseButton1Click:Connect(function()
        Config.AutoBust = not Config.AutoBust
        if not Config.AutoBust then CurrentAimTarget = nil end
        ToggleBtn.Text = Config.AutoBust and "🟢 ĐANG CÀY NÁT ATM" or "🔴 BẬT AUTO"
        ToggleBtn.BackgroundColor3 = Config.AutoBust and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 50)
        StatusLabel.Text = Config.AutoBust and "🟢 Vui lòng bỏ tay ra..." or "⏸️ Đã dừng"
        StatusLabel.TextColor3 = Config.AutoBust and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(150, 150, 150)
    end)

    TeleportBtn.MouseButton1Click:Connect(function()
        local nearest = GetNearestATM()
        if nearest then 
            FastFly(CFrame.new(GetATMPosition(nearest) + Vector3.new(0, 2, 0)))
        end
    end)

    TeleCoordBtn.MouseButton1Click:Connect(function()
        StatusLabel.Text = "🚀 Đang cất cánh về VIP..."
        StatusLabel.TextColor3 = Color3.fromRGB(180, 100, 255)
        FastFly(TARGET_COORD)
        StatusLabel.Text = "📍 Đã bay tới tọa độ VIP!"
    end)

    FlingBtn.MouseButton1Click:Connect(function()
        Config.Fling = not Config.Fling
        FlingBtn.Text = Config.Fling and "🚀 BẬT FLING: ON" or "🚀 BẬT FLING: OFF"
        FlingBtn.BackgroundColor3 = Config.Fling and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(70, 70, 80)
    end)

    task.spawn(function()
        while task.wait(0.5) do
            if ATMCountLabel then
                ATMCountLabel.Text = string.format("ATM chưa phá: %d | Đã phá: %d/10", #GetAllATMs(), ATMsBustedCount)
            end
        end
    end)
end

CreateUI()

--// TOUCH FLING
task.spawn(function()
    local v21 = 0.1
    while true do
        RunService.Heartbeat:Wait()
        if Config.Fling then
            local v19 = LocalPlayer.Character
            local v20 = v19 and (v19:FindFirstChild('HumanoidRootPart') or v19:FindFirstChild('Torso') or v19:FindFirstChild('UpperTorso'))
            
            if v20 then
                local _Velocity = v20.Velocity
                v20.Velocity = _Velocity * 10000 + Vector3.new(0, 10000, 0)
                
                RunService.RenderStepped:Wait()
                if v19 and v19.Parent and (v20 and v20.Parent) then
                    v20.Velocity = _Velocity
                end
                
                RunService.Stepped:Wait()
                if v19 and v19.Parent and (v20 and v20.Parent) then
                    v20.Velocity = _Velocity + Vector3.new(0, v21, 0)
                    v21 = v21 * -1
                end
            end
        end
    end
end)

--// AUTO LOOP (FLY FAST + VIP 10 ATMs + JUMP LOGIC)
task.spawn(function()
    while task.wait(0.1) do
        if Config.AutoBust then
            local isNearby, pName, dist = IsPlayerNearby()
            
            if isNearby then
                CurrentAimTarget = nil
                PatrolAroundMap()
                task.wait(1)
            else
                local atm = GetNearestATM()
                if atm then
                    -- THAY VÌ TELEPORT, DÙNG HỆ THỐNG BAY CẤT CÁNH
                    FastFly(CFrame.new(GetATMPosition(atm) + Vector3.new(0, 2, 0)))
                    task.wait(0.1)

                    local prompt = atm:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        pcall(function()
                            prompt.MaxActivationDistance = 50
                            prompt.RequiresLineOfSight = false
                        end)

                        -- BẤM GIỮ NÚT E
                        pcall(function() prompt:InputHoldBegin() end)
                        
                        local timeHeld = 0
                        local interruptedByPlayer = false

                        while timeHeld < (Config.HoldDuration + 0.2) and Config.AutoBust do
                            task.wait(0.1)
                            timeHeld = timeHeld + 0.1

                            local hasPlayer = IsPlayerNearby()
                            if hasPlayer then
                                pcall(function() prompt:InputHoldEnd() end)
                                CurrentAimTarget = nil
                                BustedATMs[atm] = true
                                interruptedByPlayer = true
                                break
                            end
                        end
                        
                        if interruptedByPlayer then
                            FlyToSky()
                            task.wait(0.5)
                        else
                            -- ĐÃ PHÁ XONG THÀNH CÔNG
                            pcall(function() prompt:InputHoldEnd() end)
                            BustedATMs[atm] = true
                            ATMsBustedCount = ATMsBustedCount + 1 
                            
                            FlyToSky() -- Vừa bẻ khóa xong vọt thẳng lên 350 studs cho an toàn
                            
                            -- KIỂM TRA: NẾU ĐỦ 10 ATM THÌ BAY VỀ VIP
                            if ATMsBustedCount >= 10 then
                                -- Bốc đầu bay thẳng đến bãi VIP
                                FastFly(TARGET_COORD)
                                
                                local char = LocalPlayer.Character
                                local hum = char and char:FindFirstChildOfClass("Humanoid")
                                
                                if hum then
                                    -- Đợi 3 giây
                                    task.wait(3)
                                    
                                    -- Nhảy 1 cái chống lỗi tọa độ
                                    hum.Jump = true
                                    
                                    -- Xả đếm lại từ 0
                                    ATMsBustedCount = 0
                                    task.wait(0.5) 
                                end
                            else
                                -- NẾU CHƯA ĐỦ 10, TREO LƠ LỬNG 4S NÉ NGƯỜI NHƯ CŨ
                                local waitTime = 0
                                while waitTime < 4.0 and Config.AutoBust do
                                    task.wait(0.1)
                                    waitTime = waitTime + 0.1
                                    if IsPlayerNearby() then break end
                                end
                            end
                        end
                    else
                        CurrentAimTarget = nil
                        BustedATMs[atm] = true
                    end
                else
                    PatrolAroundMap()
                end
            end
        end
    end
end)

print("🔥 MEMAYBEO HUB - FAST FLY VIP LOGIC LOADED!")
