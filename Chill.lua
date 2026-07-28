-- ===================================================
-- AUTO FARM DELIVERY – BAY LÊN CAO + RESET + ANTI-AFK
-- ===================================================
-- HƯỚNG DẪN: Copy toàn bộ, dán vào Executor, chạy.
-- UI hiện ra góc trái, bấm "Bắt đầu" để chạy.
-- ===================================================

local plr = game:GetService("Players").LocalPlayer
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local char = plr.Character
if not char or not char.Parent then return end
local rootPart = char:FindFirstChild("HumanoidRootPart")
if not rootPart then return end

local remoteGiao = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DeliveryLocationInteracted")

-- ===== HÀM DI CHUYỂN BẰNG TWEEN =====
local function MoveTo(targetCFrame, speed)
    local distance = (targetCFrame.Position - rootPart.Position).Magnitude
    if distance < 0.5 then
        rootPart.CFrame = targetCFrame
        return
    end
    local duration = distance / speed
    local tween = tweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- ===== TÌM MŨI TÊN =====
local function GetArrowCFrame()
    local arrowModel = workspace:FindFirstChild("GuideArrowModel")
    if arrowModel then
        for _, child in ipairs(arrowModel:GetDescendants()) do
            if child:IsA("BasePart") then
                return child.CFrame
            end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(obj.Name, "Arrow") or string.find(obj.Name, "Guide")) then
            return obj.CFrame
        end
    end
    return nil
end

-- ===== KÍCH HOẠT PROMPT =====
local function ActivatePrompt()
    local promptGui = plr.PlayerGui:FindFirstChild("ProximityPrompts")
    if promptGui then
        local prompt = promptGui:FindFirstChild("Prompt")
        if prompt then
            pcall(function()
                if prompt:IsA("RemoteEvent") then
                    prompt:FireServer()
                elseif prompt:IsA("ProximityPrompt") then
                    prompt:InputHoldBegin()
                    wait(0.2)
                    prompt:InputHoldEnd()
                elseif prompt:IsA("BoolValue") then
                    prompt.Value = true
                else
                    prompt:Fire()
                end
            end)
            return true
        end
    end
    local remotePickup = game.ReplicatedStorage:FindFirstChild("AttemptDeliveryPickup", true)
    if remotePickup then
        pcall(function() remotePickup:FireServer() end)
        return true
    end
    return false
end

-- ===== LẤY DANH SÁCH ĐIỂM GIAO =====
local function GetDeliveryPoints()
    local points = {}
    local effects = workspace:FindFirstChild("DeliveryLocationEffects")
    if effects then
        for _, v in ipairs(effects:GetChildren()) do
            if v:IsA("BasePart") then
                table.insert(points, v)
            end
        end
    end
    return points
end

-- ===== LẤY BOX NHẬN HÀNG =====
local function GetPickupBoxes()
    local boxes = {}
    local locsParent = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Jobs") and workspace.Game.Jobs:FindFirstChild("Delivery") and workspace.Game.Jobs.Delivery:FindFirstChild("DeliveryLocations")
    if locsParent then
        for _, loc in ipairs(locsParent:GetChildren()) do
            local jobPad = loc:FindFirstChild("DeliveryJobPad")
            if jobPad then
                local box = jobPad:FindFirstChild("Boxes")
                if box and box:IsA("BasePart") then
                    table.insert(boxes, box)
                end
            end
        end
    end
    return boxes
end

-- ===== KIỂM TRA XE CÓ TRONG ZONE KHÔNG =====
local function IsInsideDeliveryZone()
    local effects = workspace:FindFirstChild("DeliveryLocationEffects")
    if not effects then return false end
    local pos = rootPart.Position
    for _, part in ipairs(effects:GetChildren()) do
        if part:IsA("BasePart") and (pos - part.Position).Magnitude < 15 then
            return true
        end
    end
    return false
end

-- ===== ANTI-AFK MẠNH (nhảy + di chuyển nhẹ) =====
local function AntiAFK()
    local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
    if humanoid then
        -- Nhảy
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        wait(0.1)
        -- Di chuyển nhẹ sang trái/phải để tạo tín hiệu
        local currentPos = rootPart.Position
        local targetPos = currentPos + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
        MoveTo(CFrame.new(targetPos), 100)
    end
end

-- ===== UI =====
local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FarmUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = plr:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 250)
    mainFrame.Position = UDim2.new(0, 10, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundTransparency = 1
    title.Text = "🚀 Auto Farm Delivery"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0, 40)
    status.BackgroundTransparency = 1
    status.Text = "⏹ Đã dừng"
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = mainFrame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
    toggleBtn.Position = UDim2.new(0.1, 0, 0, 75)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
    toggleBtn.Text = "▶ Bắt đầu"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = mainFrame

    local moneyLabel = Instance.new("TextLabel")
    moneyLabel.Size = UDim2.new(1, 0, 0, 25)
    moneyLabel.Position = UDim2.new(0, 0, 0, 120)
    moneyLabel.BackgroundTransparency = 1
    moneyLabel.Text = "💰 0"
    moneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    moneyLabel.TextSize = 16
    moneyLabel.Font = Enum.Font.GothamBold
    moneyLabel.Parent = mainFrame

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, 0, 0, 20)
    timerLabel.Position = UDim2.new(0, 0, 0, 150)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "⏱ 00:00:00"
    timerLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timerLabel.TextSize = 12
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.Parent = mainFrame

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 20)
    distLabel.Position = UDim2.new(0, 0, 0, 175)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "📍 Chưa có điểm giao"
    distLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = mainFrame

    local resetLabel = Instance.new("TextLabel")
    resetLabel.Size = UDim2.new(1, 0, 0, 20)
    resetLabel.Position = UDim2.new(0, 0, 0, 200)
    resetLabel.BackgroundTransparency = 1
    resetLabel.Text = "🔄 Đợi reset..."
    resetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    resetLabel.TextSize = 12
    resetLabel.Font = Enum.Font.Gotham
    resetLabel.Visible = false
    resetLabel.Parent = mainFrame

    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        StatusLabel = status,
        ToggleBtn = toggleBtn,
        MoneyLabel = moneyLabel,
        TimerLabel = timerLabel,
        DistLabel = distLabel,
        ResetLabel = resetLabel
    }
end

local ui = CreateUI()

-- ===== BIẾN ĐIỀU KHIỂN =====
local isRunning = false
local farmCoroutine = nil
local startTime = nil

-- ===== FARM LOOP =====
local function FarmLoop()
    local lastAFKTime = 0
    local lastDeliveryTime = 0
    local insideZoneSince = 0

    while isRunning do
        -- === NHẬN HÀNG ===
        ui.StatusLabel.Text = "📦 Đang nhận hàng..."
        local pickupBoxes = GetPickupBoxes()
        if #pickupBoxes == 0 then
            ui.StatusLabel.Text = "⏳ Đợi Boxes..."
            wait(2)
        else
            for _, box in ipairs(pickupBoxes) do
                if not isRunning then break end
                rootPart.CFrame = box.CFrame + Vector3.new(0, 2, 0)
                wait(0.3)
                ActivatePrompt()
                wait(0.5)
            end
        end

        -- === BAY THEO MŨI TÊN KHI CHƯA CÓ ĐIỂM GIAO ===
        local deliveryPoints = GetDeliveryPoints()
        while #deliveryPoints == 0 and isRunning do
            local arrowCF = GetArrowCFrame()
            if arrowCF then
                local lookVec = arrowCF.LookVector
                local targetPos = arrowCF.Position + lookVec * 500
                local targetCF = CFrame.new(targetPos) + Vector3.new(0, 2, 0)
                local dist = (targetCF.Position - rootPart.Position).Magnitude
                ui.DistLabel.Text = "📍 Bay trượt theo mũi tên, còn " .. math.floor(dist) .. " stud"
                MoveTo(targetCF, 500)
            else
                ui.DistLabel.Text = "⚠️ Không tìm thấy mũi tên"
                wait(1)
            end
            deliveryPoints = GetDeliveryPoints()
            if tick() - lastAFKTime > 30 then
                AntiAFK()
                lastAFKTime = tick()
            end
            wait(0.2)
        end

        -- === GIAO HÀNG ===
        if #deliveryPoints > 0 and isRunning then
            if insideZoneSince == 0 then insideZoneSince = tick() end

            ui.StatusLabel.Text = "🚚 Đang giao (" .. #deliveryPoints .. " điểm)"
            for _, point in ipairs(deliveryPoints) do
                if not isRunning then break end
                local targetCF = point.CFrame + Vector3.new(0, 2, 0)
                local dist = (targetCF.Position - rootPart.Position).Magnitude
                ui.DistLabel.Text = "📍 Cách điểm giao " .. math.floor(dist) .. " stud"

                if dist > 1500 then
                    local arrowCF = GetArrowCFrame()
                    if arrowCF then
                        local lookVec = arrowCF.LookVector
                        local targetPos = arrowCF.Position + lookVec * 500
                        ui.StatusLabel.Text = "🧭 Xa quá, bay trượt theo mũi tên..."
                        MoveTo(CFrame.new(targetPos) + Vector3.new(0, 2, 0), 400)
                        wait(0.3)
                    end
                end

                -- BAY LÊN CAO TRƯỚC KHI VÀO ĐIỂM
                ui.StatusLabel.Text = "⬆️ Bay lên cao..."
                local highPos = rootPart.Position + Vector3.new(0, 50, 0)
                MoveTo(CFrame.new(highPos), 300)
                wait(0.3)

                -- BAY XUỐNG ĐIỂM GIAO
                ui.StatusLabel.Text = "🚀 Bay vào " .. point.Name
                MoveTo(targetCF, 300)

                local success, err = pcall(function()
                    remoteGiao:FireServer(point)
                end)
                if success then
                    ui.StatusLabel.Text = "✅ Giao tại " .. point.Name
                    lastDeliveryTime = tick()
                else
                    ui.StatusLabel.Text = "❌ Lỗi giao: " .. tostring(err)
                end
                wait(0.5)

                -- Anti-AFK mỗi 30 giây
                if tick() - lastAFKTime > 30 then
                    AntiAFK()
                    lastAFKTime = tick()
                end
            end

            -- === KIỂM TRA KẸT (5s) ===
            local timeSinceLastDelivery = tick() - lastDeliveryTime
            if timeSinceLastDelivery > 5 and IsInsideDeliveryZone() and #deliveryPoints > 0 then
                ui.ResetLabel.Visible = true
                ui.StatusLabel.Text = "🔄 Kẹt quá 5s, reset zone..."

                -- 1. Bay lên cao 200 stud
                local highPos = rootPart.Position + Vector3.new(0, 200, 0)
                MoveTo(CFrame.new(highPos), 300)
                wait(0.5)

                -- 2. Bay ra khỏi zone (theo trục X)
                local outPos = rootPart.Position + Vector3.new(200, 0, 0)
                MoveTo(CFrame.new(outPos), 400)
                wait(0.5)

                -- 3. Bay vào lại điểm đầu tiên
                local firstPoint = deliveryPoints[1]
                if firstPoint then
                    MoveTo(firstPoint.CFrame + Vector3.new(0, 2, 0), 400)
                else
                    MoveTo(CFrame.new(rootPart.Position + Vector3.new(-100, 0, 0)), 400)
                end
                wait(1)

                insideZoneSince = tick()
                lastDeliveryTime = tick()
                ui.ResetLabel.Visible = false
                ui.StatusLabel.Text = "🔄 Đã reset, tiếp tục..."
                wait(1)
            end
        end

        wait(1)
    end
end

-- ===== CẬP NHẬT TIỀN =====
spawn(function()
    while true do
        wait(2)
        local leaderstats = plr:FindFirstChild("leaderstats")
        if leaderstats then
            local cash = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Coins")
            if cash then
                ui.MoneyLabel.Text = "💰 " .. cash.Value
            end
        end
    end
end)

-- ===== CẬP NHẬT THỜI GIAN =====
spawn(function()
    while true do
        if isRunning and startTime then
            local elapsed = tick() - startTime
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = math.floor(elapsed % 60)
            ui.TimerLabel.Text = string.format("⏱ %02d:%02d:%02d", h, m, s)
        end
        wait(1)
    end
end)

-- ===== NÚT START/STOP =====
ui.ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ui.ToggleBtn.Text = "⏹ Dừng"
        ui.ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        ui.StatusLabel.Text = "▶ Đang chạy..."
        startTime = tick()
        farmCoroutine = coroutine.create(FarmLoop)
        coroutine.resume(farmCoroutine)
    else
        ui.ToggleBtn.Text = "▶ Bắt đầu"
        ui.ToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
        ui.StatusLabel.Text = "⏹ Đã dừng"
        startTime = nil
    end
end)

print("✅ Auto Farm đã sẵn sàng! (Bay lên cao + Anti-AFK mạnh)")
