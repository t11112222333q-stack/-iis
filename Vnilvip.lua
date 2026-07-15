-- ============================================================================
-- ⚔️ MEMAYBEO HUB - VERSION V42 (MOBILE TOGGLE BUTTON INCLUDED)
-- ============================================================================

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

--// Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/t11112222333q-stack/-iis/refs/heads/main/Teaat.lua"))()

--// 🔑 HỆ THỐNG ONLINE FETCHING KEY DATABASE
local KEY_DATABASE_URL = "https://raw.githubusercontent.com/username/repository/main/keys.json"
getgenv().KeySystemDatabase = {}

local function FetchOnlineKeys()
    local success, response = pcall(function() return game:HttpGet(KEY_DATABASE_URL) end)
    if success and response then
        local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(response) end)
        if decodeSuccess and decodedData then
            getgenv().KeySystemDatabase = decodedData
            return true
        end
    end
    return false
end
FetchOnlineKeys()

-- CONFIG SPEED SAFE BYPASS
getgenv().CHEST_SPEED_TWEEN = 85 
getgenv().GRAB_SPEED_TWEEN = 70 

getgenv().HitBoxX = 8
getgenv().HitBoxY = 8
getgenv().HitBoxZ = 8

local HITBOX_SIZE_RED = Vector3.new(15, 15, 15)
local NGUONG_MAU_YEU = 95 
local AIMLOCK_RADIUS = 35 
local VNIL_VECTOR = Vector3.new(-240.144531, -143.0, -580.035645) 
local HOSPITAL_POSITION = Vector3.new(150, -145, 200)

getgenv().BypassVelocitySpeed = 60 

-- CONFIG PROFILE OVERRIDE
getgenv().NewName = "anhbathanhhoa"
getgenv().NewLevel = "20"
getgenv().NewRole = "ADMIN"
getgenv().RoleColorMode = "Đỏ"
_G.AutoOverride = false

local toolBoxes = {}
local folderESP = workspace:FindFirstChild("ESP") or Instance.new("Folder", workspace)
folderESP.Name = "ESP"
local weaponHistory = {} 

-- ============================================================================
-- 🎨 BẢNG MÀU THUẬN TIỆN & PHONG PHÚ CHO LATES LIB
-- ============================================================================
local Themes = {
	Dark = {
		Primary = Color3.fromRGB(30, 30, 30), Secondary = Color3.fromRGB(35, 35, 35),
		Component = Color3.fromRGB(40, 40, 40), Interactables = Color3.fromRGB(45, 45, 45),
		Tab = Color3.fromRGB(200, 200, 200), Title = Color3.fromRGB(240,240,240), Description = Color3.fromRGB(160,160,160),
		Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(40, 40, 40), Icon = Color3.fromRGB(220, 220, 220),
	},
	Void = {
		Primary = Color3.fromRGB(15, 15, 15), Secondary = Color3.fromRGB(20, 20, 20),
		Component = Color3.fromRGB(25, 25, 25), Interactables = Color3.fromRGB(30, 30, 30),
		Tab = Color3.fromRGB(200, 200, 200), Title = Color3.fromRGB(240,240,240), Description = Color3.fromRGB(160,160,160),
		Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(30, 30, 30), Icon = Color3.fromRGB(220, 220, 220),
	},
	Light = {
		Primary = Color3.fromRGB(232, 232, 232), Secondary = Color3.fromRGB(255, 255, 255),
		Component = Color3.fromRGB(245, 245, 245), Interactables = Color3.fromRGB(235, 235, 235),
		Tab = Color3.fromRGB(50, 50, 50), Title = Color3.fromRGB(0, 0, 0), Description = Color3.fromRGB(100, 100, 100),
		Shadow = Color3.fromRGB(255, 255, 255), Outline = Color3.fromRGB(210, 210, 210), Icon = Color3.fromRGB(100, 100, 100),
	},
	Amethyst = { -- Tím Thạch Anh
		Primary = Color3.fromRGB(28, 20, 38), Secondary = Color3.fromRGB(38, 28, 52),
		Component = Color3.fromRGB(50, 36, 68), Interactables = Color3.fromRGB(65, 45, 90),
		Tab = Color3.fromRGB(220, 180, 255), Title = Color3.fromRGB(245, 225, 255), Description = Color3.fromRGB(180, 150, 210),
		Shadow = Color3.fromRGB(10, 5, 15), Outline = Color3.fromRGB(80, 50, 110), Icon = Color3.fromRGB(220, 180, 255),
	},
	Emerald = { -- Xanh Lục Bảo
		Primary = Color3.fromRGB(15, 32, 25), Secondary = Color3.fromRGB(22, 42, 33),
		Component = Color3.fromRGB(30, 56, 44), Interactables = Color3.fromRGB(38, 72, 56),
		Tab = Color3.fromRGB(180, 255, 210), Title = Color3.fromRGB(220, 255, 235), Description = Color3.fromRGB(140, 200, 165),
		Shadow = Color3.fromRGB(5, 15, 10), Outline = Color3.fromRGB(45, 85, 65), Icon = Color3.fromRGB(180, 255, 210),
	},
	Sakura = { -- Hồng Anh Đào
		Primary = Color3.fromRGB(38, 22, 30), Secondary = Color3.fromRGB(50, 30, 40),
		Component = Color3.fromRGB(65, 38, 52), Interactables = Color3.fromRGB(85, 48, 68),
		Tab = Color3.fromRGB(255, 190, 220), Title = Color3.fromRGB(255, 230, 240), Description = Color3.fromRGB(210, 150, 180),
		Shadow = Color3.fromRGB(15, 5, 10), Outline = Color3.fromRGB(100, 55, 80), Icon = Color3.fromRGB(255, 190, 220),
	},
	Cyberpunk = { -- Vàng / Tím Cyber
		Primary = Color3.fromRGB(20, 20, 28), Secondary = Color3.fromRGB(30, 25, 42),
		Component = Color3.fromRGB(45, 35, 60), Interactables = Color3.fromRGB(255, 200, 0),
		Tab = Color3.fromRGB(0, 240, 255), Title = Color3.fromRGB(255, 230, 0), Description = Color3.fromRGB(0, 200, 220),
		Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(255, 0, 120), Icon = Color3.fromRGB(0, 240, 255),
	},
	Sunset = { -- Cam Hoàng Hôn
		Primary = Color3.fromRGB(35, 22, 18), Secondary = Color3.fromRGB(48, 30, 22),
		Component = Color3.fromRGB(62, 38, 28), Interactables = Color3.fromRGB(80, 48, 32),
		Tab = Color3.fromRGB(255, 180, 130), Title = Color3.fromRGB(255, 220, 190), Description = Color3.fromRGB(210, 140, 100),
		Shadow = Color3.fromRGB(15, 8, 5), Outline = Color3.fromRGB(100, 60, 40), Icon = Color3.fromRGB(255, 180, 130),
	}
}

-- KHỞI TẠO CỬA SỔ
local Window = Library:CreateWindow({
	Title = "MEMAYBEO HUB V42",
	Theme = "Dark",
	Size = UDim2.fromOffset(580, 440),
	Transparency = 0.15,
	Blurring = true,
	MinimizeKeybind = Enum.KeyCode.End,
})
Window:SetTheme(Themes.Dark)

-- ============================================================================
-- 📱 NÚT ẨN HIỆN MENU (MOBILE TOGGLE BUTTON)
-- ============================================================================
local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "MMBMobileToggleGui"
mobileGui.ResetOnSpawn = false
mobileGui.Parent = playerGui

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.fromOffset(50, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleBtn.Image = "rbxassetid://4483345998"
toggleBtn.Active = true
toggleBtn.Parent = mobileGui

local corner = Instance.new("UICorner", toggleBtn)
corner.CornerRadius = UDim.new(1, 0)

local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Color = Color3.fromRGB(225, 29, 72)
btnStroke.Thickness = 1.5

-- Kéo thả nút ẩn/hiện trên màn hình
local dragging, dragInput, dragStart, startPos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sự kiện ẩn/hiện menu khi ấn nút
toggleBtn.MouseButton1Click:Connect(function()
    if Window and type(Window.Toggle) == "function" then
        pcall(function() Window:Toggle() end)
    end
end)

-- ============================================================================
-- 📂 ĐỊNH NGHĨA CÁC SECTIONS VÀ TABS
-- ============================================================================
Window:AddTabSection({ Name = "Main Features", Order = 1 })
Window:AddTabSection({ Name = "Combat & Radar", Order = 2 })
Window:AddTabSection({ Name = "System & Visuals", Order = 3 })

local TabProfile = Window:AddTab({ Title = "Hồ Sơ", Section = "Main Features", Icon = "rbxassetid://11963373994" })
local TabFarm = Window:AddTab({ Title = "Farm", Section = "Main Features", Icon = "rbxassetid://11963373994" })
local TabPvP = Window:AddTab({ Title = "PvP", Section = "Combat & Radar", Icon = "rbxassetid://11963373994" })
local TabServer = Window:AddTab({ Title = "Server", Section = "System & Visuals", Icon = "rbxassetid://11293977610" })
local TabFixLag = Window:AddTab({ Title = "Fix Lag", Section = "System & Visuals", Icon = "rbxassetid://11293977610" })
local TabSettings = Window:AddTab({ Title = "Cài Đặt", Section = "System & Visuals", Icon = "rbxassetid://11293977610" })

-- ============================================================================
-- 👤 TAB 1: TÙY CHỈNH HỒ SƠ
-- ============================================================================
Window:AddSection({ Name = "Fake Profile Customization", Tab = TabProfile })

Window:AddInput({
	Title = "Đổi Tên Hiển Thị", Description = "Nhập tên muốn ghi đè", Tab = TabProfile,
	Callback = function(v) getgenv().NewName = v end,
})

Window:AddInput({
	Title = "Đổi Cấp Độ (Level)", Description = "Cấp độ ảo hiển thị", Tab = TabProfile,
	Callback = function(v) getgenv().NewLevel = v end,
})

Window:AddInput({
	Title = "Đổi Vai Trò (Role)", Description = "VIP, ADMIN, MOD, THÀNH VIÊN...", Tab = TabProfile,
	Callback = function(v) getgenv().NewRole = v end,
})

Window:AddDropdown({
	Title = "Màu Sắc Vai Trò", Description = "Chọn màu cho danh hiệu", Tab = TabProfile,
	Options = {
		["Màu Đỏ"] = "Đỏ", ["Màu Cam"] = "Cam", ["Màu Vàng"] = "Vàng", 
		["Màu Lục"] = "Lục", ["Màu Lam"] = "Lam", ["Màu Tím"] = "Tím", 
		["Màu Trắng"] = "Trắng", ["7 Màu Cầu Vồng"] = "7 Màu Cầu Vồng"
	},
	Callback = function(v) getgenv().RoleColorMode = v end
})

Window:AddToggle({
	Title = "Ghi Đè Liên Tục (Auto Override)", Description = "Quét liên tục các UI text trên màn hình", Tab = TabProfile,
	Callback = function(state) _G.AutoOverride = state end
})

local colorMap = {
    ["Đỏ"] = Color3.fromRGB(255, 0, 0), ["Cam"] = Color3.fromRGB(255, 127, 0),
    ["Vàng"] = Color3.fromRGB(255, 255, 0), ["Lục"] = Color3.fromRGB(0, 255, 0),
    ["Lam"] = Color3.fromRGB(0, 127, 255), ["Tím"] = Color3.fromRGB(139, 0, 255),
    ["Trắng"] = Color3.fromRGB(255, 255, 255)
}

local rainbowColor = Color3.fromRGB(255, 0, 0)
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            rainbowColor = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.3) 
        if _G.AutoOverride then
            pcall(function()
                local myUserName = string.lower(localPlayer.Name)
                local myDisplayName = string.lower(localPlayer.DisplayName)
                local finalColor = colorMap[getgenv().RoleColorMode] or rainbowColor
                if getgenv().RoleColorMode == "7 Màu Cầu Vồng" then finalColor = rainbowColor end

                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("TextLabel") then
                        local text = string.lower(obj.Text)
                        local name = string.lower(obj.Name)
                        if string.find(text, myUserName) or string.find(text, myDisplayName) or string.find(text, "anhbathanhhoa") or name == "namelabel" or name == "titlename" or name == "username" then obj.Text = getgenv().NewName end
                        if string.find(text, "cấp độ") or string.find(text, "level") or string.find(text, "lv") or name == "levellabel" then obj.Text = "Cấp độ: " .. getgenv().NewLevel end
                        if string.find(text, "khách") or string.find(text, "vip") or string.find(text, "admin") or string.find(text, "thành viên") or name == "rolelabel" or name == "ranklabel" or name == "grouplabel" then
                            obj.Text = getgenv().NewRole
                            obj.TextColor3 = finalColor
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================================
-- 🌾 TAB 2: FARM (JOB DELIVERY & CHEST)
-- ============================================================================
Window:AddSection({ Name = "Auto Job Delivery (Fly Mode V42)", Tab = TabFarm })

_G.AutoDeliveryRunning = false
Window:AddToggle({
	Title = "Bật Giao Hàng Bằng CFrame Step", Description = "Tự nhận & giao thùng hàng tự động", Tab = TabFarm,
	Callback = function(state) _G.AutoDeliveryRunning = state end
})

Window:AddSlider({
	Title = "Tốc Độ Di Chuyển Grab", Description = "Chỉnh tốc độ bay giao hàng (Mặc định: 70)", Tab = TabFarm, MaxValue = 150,
	Callback = function(v) getgenv().GRAB_SPEED_TWEEN = v end
})

Window:AddSection({ Name = "Auto Loot Chest (Bảo Vệ An Toàn V42)", Tab = TabFarm })

_G.AutoLoot = false
Window:AddToggle({
	Title = "Kích Hoạt Săn Rương Xịn (CFrame Instant Lock)", Description = "Tự nhặt rương rơi rải rác trên Map", Tab = TabFarm,
	Callback = function(state) _G.AutoLoot = state end
})

-- Teleport Engine & Job Loops
local function bypassTweenEngine(targetPos, speed, checkGlobalVariable, ignoreHeight)
    local char = localPlayer.Character local root = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 1 then return end
    local finalTargetPos = targetPos if not ignoreHeight then finalTargetPos = Vector3.new(targetPos.X, -137.5, targetPos.Z) end
    if (root.Position - finalTargetPos).Magnitude < 2 then return end 

    while (root.Position - finalTargetPos).Magnitude > 2 and _G[checkGlobalVariable] do
        if hum.Health <= 1 then break end
        local currentPos = root.Position local direction = (finalTargetPos - currentPos).Unit
        local nextStep = currentPos + (direction * (speed * RunService.Heartbeat:Wait()))
        root.AssemblyLinearVelocity = Vector3.zero root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = CFrame.new(nextStep)
    end
    if _G[checkGlobalVariable] and hum.Health > 1 then root.CFrame = CFrame.new(finalTargetPos) root.AssemblyLinearVelocity = Vector3.zero end
end

local function getActiveDeliveryArrow()
    local delieveryFolder = workspace:FindFirstChild("JobGame") and workspace.JobGame:FindFirstChild("Delievery")
    local arrowSpawn = delieveryFolder and delieveryFolder:FindFirstChild("ArrowSpawn")
    if not arrowSpawn then return nil end
    for _, folder in pairs(arrowSpawn:GetChildren()) do
        if string.find(folder.Name, localPlayer.Name) or string.find(folder.Name, "Grab") then
            local arrow = folder:FindFirstChild("Arrow") or folder:FindFirstChildWhichIsA("BasePart", true)
            if arrow and (arrow.Position - HOSPITAL_POSITION).Magnitude > 90 then return arrow end
        end
    end
    return nil
end

RunService.Stepped:Connect(function()
    if (_G.AutoDeliveryRunning or _G.AutoLoot or _G.FlyTopDown or _G.FlyOrbitAround) and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Running then hum:ChangeState(Enum.HumanoidStateType.Running) end
        for _, part in pairs(localPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01)
        if _G.AutoDeliveryRunning then
            pcall(function()
                local char = localPlayer.Character local root = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 1 then return end
                local grabBoxInChar = char:FindFirstChild("GrabBox") local grabBoxInBackpack = localPlayer.Backpack:FindFirstChild("GrabBox") local hasBox = grabBoxInChar or grabBoxInBackpack local delieveryFolder = workspace.JobGame.Delievery
                if grabBoxInChar then for _, p in pairs(grabBoxInChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
                if not hasBox then
                    if (root.Position - VNIL_VECTOR).Magnitude > 8 then bypassTweenEngine(VNIL_VECTOR, getgenv().GRAB_SPEED_TWEEN, "AutoDeliveryRunning", false) 
                    else
                        local npc = delieveryFolder:FindFirstChild("NpcGrab")
                        if npc then root.CFrame = npc:GetPivot() * CFrame.new(0, 0, 2) local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true) or npc:FindFirstChild("Nh\225\186\173n")
                            if prompt then prompt.MaxActivationDistance = 100 prompt.RequiresLineOfSight = false repeat fireproximityprompt(prompt) task.wait(0.2) until localPlayer.Backpack:FindFirstChild("GrabBox") or char:FindFirstChild("GrabBox") or not _G.AutoDeliveryRunning end 
                        end
                    end
                else
                    if grabBoxInBackpack and not grabBoxInChar then hum:EquipTool(grabBoxInBackpack) end
                    local activeArrow = getActiveDeliveryArrow()
                    if activeArrow then
                        bypassTweenEngine(activeArrow.Position, getgenv().GRAB_SPEED_TWEEN, "AutoDeliveryRunning", false)
                        local vitriFolder = delieveryFolder:FindFirstChild("Vitri") or delieveryFolder
                        for _, dest in pairs(vitriFolder:GetDescendants()) do
                            if dest:IsA("ProximityPrompt") or dest.Name:sub(1,14) == "DeliveryPrompt" then
                                local parentPart = dest.Parent
                                if parentPart and parentPart:IsA("BasePart") then
                                    if (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(parentPart.Position.X, 0, parentPart.Position.Z)).Magnitude < 22 then
                                        root.CFrame = parentPart:GetPivot() * CFrame.new(0, 1.5, 0) dest.MaxActivationDistance = 150 dest.RequiresLineOfSight = false
                                        repeat fireproximityprompt(dest) task.wait(0.15) until not char:FindFirstChild("GrabBox") and not localPlayer.Backpack:FindFirstChild("GrabBox") or not _G.AutoDeliveryRunning
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

local function findValidChestOnly()
    local jobGame = workspace:FindFirstChild("JobGame") local suKien = jobGame and jobGame:FindFirstChild("SuKien") local dropLoot = suKien and suKien:FindFirstChild("DropLoot")
    if dropLoot then for _, child in pairs(dropLoot:GetChildren()) do if (child:IsA("Model") or child:IsA("BasePart")) and not string.find(string.lower(child.Name), "drop") then return child end end end
    return nil
end

-- ============================================================================
-- ⚡ LẬP TRÌNH BAY NHANH NHƯ CHỚP & TỰ ĐỘNG THẮP PHANH KHI LẠI GẦN RƯƠNG
-- ============================================================================
task.spawn(function()
    while true do
        task.wait(0.01)
        if _G.AutoLoot then
            pcall(function()
                local char = localPlayer.Character local hum = char and char:FindFirstChildOfClass("Humanoid") local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root or not hum or hum.Health <= 15 then task.wait(0.3) return end
                local chest = findValidChestOnly()
                if chest and chest.Parent then
                    local originalCF = root.CFrame 
                    local chestPos = chest:GetPivot().Position 
                    local safeFloatingPos = CFrame.new(chestPos.X, chestPos.Y + 5.5, chestPos.Z)
                    
                    for _, p in ipairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    
                    local baseSpeed = getgenv().CHEST_SPEED_TWEEN or 85
                    
                    -- VÒNG LẶP DI CHUYỂN DYNAMIC SPEED (BAY NHƯ CHỚP RỒI GIẢM TỐC)
                    while (root.Position - safeFloatingPos.Position).Magnitude > 2.5 and _G.AutoLoot and chest.Parent do
                        local dist = (safeFloatingPos.Position - root.Position).Magnitude
                        local dir = (safeFloatingPos.Position - root.Position).Unit
                        
                        local currentSpeed = baseSpeed
                        if dist > 20 then
                            -- Ở xa: Nhân 3.5 lần tốc độ cơ bản (xé gió cực nhanh)
                            currentSpeed = math.max(baseSpeed * 3.5, dist * 6.5)
                        else
                            -- Ở gần (dưới 20 studs): Thắt phanh về tốc độ chuẩn để vào vị trí an toàn
                            currentSpeed = math.clamp(dist * 5, 25, baseSpeed)
                        end
                        
                        local delta = RunService.Heartbeat:Wait()
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                        root.CFrame = CFrame.new(root.Position + (dir * (currentSpeed * delta)))
                    end
                    
                    -- Khóa cứng vị trí chính xác trên rương
                    root.CFrame = safeFloatingPos 
                    root.AssemblyLinearVelocity = Vector3.zero 
                    root.AssemblyAngularVelocity = Vector3.zero
                    
                    local prompt = chest:FindFirstChild("Open") and chest.Open:FindFirstChild("2") and chest.Open["2"]:FindFirstChildWhichIsA("ProximityPrompt", true) or chest:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then 
                        prompt.MaxActivationDistance = 500 
                        prompt.RequiresLineOfSight = false 
                        local grabAttempts = 0
                        repeat 
                            if not _G.AutoLoot or not hum or hum.Health <= 30 or not chest.Parent then break end
                            root.CFrame = safeFloatingPos 
                            root.AssemblyLinearVelocity = Vector3.zero 
                            fireproximityprompt(prompt) 
                            task.wait(0.12) 
                            grabAttempts = grabAttempts + 1
                        until not chest.Parent or grabAttempts > 35
                    end
                    if hum and hum.Health > 30 and root and originalCF then 
                        root.CFrame = originalCF 
                        root.AssemblyLinearVelocity = Vector3.zero 
                        task.wait(0.15) 
                    end
                end
            end)
        end
    end
end)

-- ============================================================================
-- ⚔️ TAB 3: PVP & TARGET RADAR
-- ============================================================================
Window:AddSection({ Name = "🔑 Key Scanner System", Tab = TabPvP })

_G.KeyCheckESPState = false
Window:AddToggle({
	Title = "Hiển Thị Nhãn Key ESP On-Head", Description = "Bật nhãn xem ai sở hữu Key", Tab = TabPvP,
	Callback = function(state) _G.KeyCheckESPState = state end
})

local function TriggerGlobalServerScan()
    FetchOnlineKeys() local foundCount = 0 local logString = ""
    for _, p in ipairs(Players:GetPlayers()) do
        local keyData = getgenv().KeySystemDatabase[p.Name] or getgenv().KeySystemDatabase[string.lower(p.Name)]
        if keyData and keyData.Status == "Valid" then
            foundCount = foundCount + 1 logString = logString .. p.Name .. " (" .. (keyData.Role or "VIP") .. "), "
        end
    end
    Window:Notify({
        Title = "KẾT QUẢ QUÉT SERVER",
        Description = foundCount > 0 and "Phát hiện VIP Key: " .. logString or "Server an toàn! Không có Key VIP.",
        Duration = 6
    })
end

Window:AddButton({
	Title = "Quét Key Toàn Bộ Người Chơi", Description = "So sánh dữ liệu với GitHub Online Database", Tab = TabPvP,
	Callback = function() TriggerGlobalServerScan() end
})

Window:AddSection({ Name = "Face-Up Desync & Fake Lag", Tab = TabPvP })

_G.SmartDesyncState = false getgenv().DesyncHeightOffset = -4 local lastSafePos = nil
Window:AddToggle({
	Title = "Desync Nằm Ngửa MMB", Description = "Tránh bị đánh trúng góc cận chiến", Tab = TabPvP,
	Callback = function(state)
		_G.SmartDesyncState = state local char = localPlayer.Character
        if not state and char then local hum = char:FindFirstChildOfClass("Humanoid") local root = char:FindFirstChild("HumanoidRootPart") if hum then hum.CameraOffset = Vector3.zero end if root and lastSafePos then root.CFrame = lastSafePos root.AssemblyLinearVelocity = Vector3.zero end end
	end
})

Window:AddSlider({
	Title = "Khoảng Cách Đẩy Xác Desync", Description = "Mặc định: -4", Tab = TabPvP, MaxValue = 100,
	Callback = function(v) getgenv().DesyncHeightOffset = v end
})

_G.SmoothFakeLag = false getgenv().LagPower = 0.35
Window:AddToggle({
	Title = "Bật Fake Lag Server", Description = "Tạo độ trễ gói tin", Tab = TabPvP,
	Callback = function(state) _G.SmoothFakeLag = state end
})

Window:AddSlider({
	Title = "Mức Độ Giật Lag (Mô phỏng giây)", Description = "Điều chỉnh độ trễ gửi packet", Tab = TabPvP, MaxValue = 1, AllowDecimals = true,
	Callback = function(v) getgenv().LagPower = v end
})

Window:AddSection({ Name = "Hitbox Customization", Tab = TabPvP })

Window:AddInput({ Title = "Hitbox Size X", Tab = TabPvP, Callback = function(v) getgenv().HitBoxX = tonumber(v) or 8 end })
Window:AddInput({ Title = "Hitbox Size Y", Tab = TabPvP, Callback = function(v) getgenv().HitBoxY = tonumber(v) or 8 end })
Window:AddInput({ Title = "Hitbox Size Z", Tab = TabPvP, Callback = function(v) getgenv().HitBoxZ = tonumber(v) or 8 end })

Window:AddButton({
	Title = "Phóng To Hitbox Vũ Khí Đang Cầm", Tab = TabPvP,
	Callback = function()
		if localPlayer.Character then
            for _, tool in ipairs(localPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then for _, p in ipairs(tool:GetDescendants()) do if p:IsA("BasePart") then p.Size = Vector3.new(getgenv().HitBoxX, getgenv().HitBoxY, getgenv().HitBoxZ) p.Massless = true p.CanCollide = false end end end
            end
            Window:Notify({ Title = "Hitbox Updated", Description = "Đã tăng kích thước đòn đánh vũ khí!", Duration = 3 })
        end
	end
})

Window:AddSection({ Name = "Combat Helpers", Tab = TabPvP })

local autoToolState = false
Window:AddToggle({ Title = "Tự Động Đánh Liên Tục", Tab = TabPvP, Callback = function(state) autoToolState = state end })
task.spawn(function() while true do task.wait(0.01) if autoToolState and localPlayer.Character then local tool = localPlayer.Character:FindFirstChildOfClass("Tool") if tool and tool.Name ~= "Băng Gạc" and tool.Name ~= "Bandage" and tool.Name ~= "Medkit" and tool.Name ~= "GrabBox" then pcall(function() tool:Activate() end) end end end end)

_G.HitboxPvP = false
Window:AddToggle({ Title = "Mở Rộng Hitbox Địch (Hộp Đỏ MMB)", Tab = TabPvP, Callback = function(state) _G.HitboxPvP = state end })

_G.SpeedPvP = false
Window:AddToggle({ Title = "Bypass Speed Velocity (Anti-Kick)", Tab = TabPvP, Callback = function(state) _G.SpeedPvP = state end })

Window:AddSlider({ Title = "Vận Tốc Speed Velocity", Tab = TabPvP, MaxValue = 120, Callback = function(v) getgenv().BypassVelocitySpeed = v end })

_G.AutoHeal = false
Window:AddToggle({ Title = "Tự Động Băng Gạc (Hồi Ngầm)", Tab = TabPvP, Callback = function(state) _G.AutoHeal = state end })

task.spawn(function()
    while true do
        task.wait(0.18)
        if _G.AutoHeal and localPlayer.Character then
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and (humanoid.Health / humanoid.MaxHealth) * 100 <= NGUONG_MAU_YEU then
                pcall(function()
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            local n = obj.Name:lower()
                            if n:match("heal") or n:match("gac") or n:match("bang") or n:match("band") or n:match("med") or n:match("use") or n:match("item") then if obj:IsA("RemoteEvent") then obj:FireServer("Băng Gạc") obj:FireServer() else obj:InvokeServer("Băng Gạc") obj:InvokeServer() end end
                        end
                    end
                    local toolGac = localPlayer.Backpack:FindFirstChild("Băng Gạc") or localPlayer.Backpack:FindFirstChild("Bandage") or localPlayer.Backpack:FindFirstChild("Medkit") if toolGac then toolGac:Activate() end
                end)
            end
        end
    end
end)

local spinSpeed = 5 local spinConnection
Window:AddSlider({ Title = "Tốc Độ Spin", Tab = TabPvP, MaxValue = 1000, Callback = function(v) spinSpeed = v end })
Window:AddToggle({
	Title = "PvP Spin (Xoay Tròn)", Tab = TabPvP,
	Callback = function(state)
		if spinConnection then spinConnection:Disconnect() end
        if state then
            if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then localPlayer.Character.Humanoid.AutoRotate = false end
            spinConnection = RunService.Heartbeat:Connect(function() local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end end)
        else if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then localPlayer.Character.Humanoid.AutoRotate = true end end
	end
})

Window:AddSection({ Name = "Radar Scan & Advanced Fly Targets", Tab = TabPvP })

_G.AimlockPvP = false
Window:AddToggle({ Title = "Aimlock Theo Bán Kính Tự Động", Tab = TabPvP, Callback = function(state) _G.AimlockPvP = state end })

local aimPlayerState = false local currentTargetName = "None" local aimConnection local isTargetValidWeapon = false 

Window:AddParagraph({ Title = "[Radar Scanner]", Description = "Đang quét môi trường xung quanh...", Tab = TabPvP })

task.spawn(function()
    while true do
        task.wait(0.1)
        local now = tick() local localChar = localPlayer.Character local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character then
                local holdsWeapon = false
                for _, item in ipairs(p.Character:GetChildren()) do
                    if item:IsA("Tool") and item.Name ~= "Băng Gạc" and item.Name ~= "Bandage" and item.Name ~= "Medkit" and item.Name ~= "GrabBox" then holdsWeapon = true break end
                end
                if holdsWeapon then weaponHistory[p.Name] = now end
            end
        end
        local bestTarget = nil local closestDist = math.huge
        if localRoot then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 1 then
                        local dist = (localRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        local lastSeenWeaponTime = weaponHistory[p.Name] or 0
                        if now - lastSeenWeaponTime <= 30 then if dist < closestDist then closestDist = dist bestTarget = p.Name end end
                    end
                end
            end
        end
        if bestTarget then currentTargetName = bestTarget isTargetValidWeapon = true
        else currentTargetName = "None" isTargetValidWeapon = false end
    end
end)

Window:AddToggle({
	Title = "Khóa Tâm Nhìn (Look At Target)", Tab = TabPvP,
	Callback = function(state)
		aimPlayerState = state if aimConnection then aimConnection:Disconnect() end
        if state then
            aimConnection = RunService.RenderStepped:Connect(function()
                if currentTargetName ~= "None" and localPlayer.Character and not _G.FlyOrbitAround and not _G.FlyTopDown then
                    local target = Players:FindFirstChild(currentTargetName) local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if target and target.Character and target.Character:FindFirstChild("Head") and localRoot then
                        local head = target.Character.Head localRoot.CFrame = CFrame.new(localRoot.Position, Vector3.new(head.Position.X, localRoot.Position.Y, head.Position.Z))
                    end
                end
            end)
        end
	end
})

_G.FlyTopDown = false getgenv().TopDownHeight = 12.5
Window:AddToggle({
	Title = "1. Bay Trên Đầu & Aim Xuống (Top-Down)", Tab = TabPvP,
	Callback = function(state)
		_G.FlyTopDown = state if state and _G.FlyOrbitAround then _G.FlyOrbitAround = false end
	end
})
Window:AddSlider({ Title = "Độ Cao Bay Trên Đầu", Tab = TabPvP, MaxValue = 35, Callback = function(v) getgenv().TopDownHeight = v end })

_G.FlyOrbitAround = false getgenv().OrbitRadius = 6 getgenv().OrbitHeight = 0 getgenv().OrbitSpeed = 67 
Window:AddToggle({
	Title = "2. Bay Vòng Quanh Target (Orbit Mode)", Tab = TabPvP,
	Callback = function(state)
		_G.FlyOrbitAround = state if state and _G.FlyTopDown then _G.FlyTopDown = false end
	end
})
Window:AddSlider({ Title = "Bán Kính Vòng Xoay Orbit", Tab = TabPvP, MaxValue = 25, Callback = function(v) getgenv().OrbitRadius = v end })
Window:AddSlider({ Title = "Tốc Độ Bay Xoay Orbit", Tab = TabPvP, MaxValue = 150, Callback = function(v) getgenv().OrbitSpeed = v end })
Window:AddSlider({ Title = "Độ Cao Bay Xoay (0 = Ngang Người)", Tab = TabPvP, MaxValue = 20, Callback = function(v) getgenv().OrbitHeight = v end })

local orbitAngle = 0
RunService.Heartbeat:Connect(function()
    if (_G.FlyTopDown or _G.FlyOrbitAround) and currentTargetName ~= "None" and isTargetValidWeapon then
        pcall(function()
            local target = Players:FindFirstChild(currentTargetName) local char = localPlayer.Character local root = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 1 and target and target.Character then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart") local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
                if targetRoot and targetHum and targetHum.Health > 1 then
                    local targetRootPos = targetRoot.Position
                    for _, p in ipairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    root.AssemblyLinearVelocity = Vector3.zero root.AssemblyAngularVelocity = Vector3.zero
                    if _G.FlyTopDown then
                        local topPos = targetRootPos + Vector3.new(0, getgenv().TopDownHeight, 0) root.CFrame = CFrame.lookAt(topPos, targetRootPos)
                    elseif _G.FlyOrbitAround then
                        orbitAngle = orbitAngle + math.rad(getgenv().OrbitSpeed * 0.5)
                        local offsetX = math.cos(orbitAngle) * getgenv().OrbitRadius local offsetZ = math.sin(orbitAngle) * getgenv().OrbitRadius
                        local orbitPos = targetRootPos + Vector3.new(offsetX, getgenv().OrbitHeight, offsetZ) root.CFrame = CFrame.lookAt(orbitPos, targetRootPos)
                    end
                end
            end
        end)
    end
end)

Window:AddSection({ Name = "Visual Tracking ESP", Tab = TabPvP })

_G.ESPToggleState = false
Window:AddToggle({ Title = "Hiển Thị ESP Line & Tên", Tab = TabPvP, Callback = function(state) _G.ESPToggleState = state if not state then folderESP:ClearAllChildren() end end })

local toolHitboxESPState = false
Window:AddToggle({ Title = "Vòng Hitbox Vũ Khí Địch", Tab = TabPvP, Callback = function(state) toolHitboxESPState = state if not state then for tool, box in pairs(toolBoxes) do if box and box.Parent then box:Destroy() end end toolBoxes = {} end end })

local healthESPState = false
Window:AddToggle({ Title = "Thanh Máu Đối Thủ On-Head", Tab = TabPvP, Callback = function(state) healthESPState = state if not state then for _, p in ipairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("HealthESP") then p.Character.Head.HealthESP:Destroy() end end end end })

-- ESP Functions
local function createPlayerESP(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = targetPlayer.Character.HumanoidRootPart
    local billboard = Instance.new("BillboardGui", folderESP) billboard.Name = "NameESP_" .. targetPlayer.Name billboard.Size = UDim2.new(0, 200, 0, 50) billboard.Adornee = root billboard.AlwaysOnTop = true
    local label = Instance.new("TextLabel", billboard) label.Size = UDim2.new(1, 0, 0.5, 0) label.BackgroundTransparency = 0.5 label.BackgroundColor3 = Color3.new(0, 0, 0) label.Text = targetPlayer.Name label.TextColor3 = Color3.new(1, 1, 1) label.TextScaled = true label.Font = Enum.Font.SourceSansBold
    local keyLabel = Instance.new("TextLabel", billboard) keyLabel.Size = UDim2.new(1, 0, 0.5, 0) keyLabel.Position = UDim2.new(0, 0, 0.5, 0) keyLabel.BackgroundTransparency = 1 keyLabel.TextScaled = true keyLabel.Font = Enum.Font.SourceSansBold keyLabel.Text = ""
    local line = Drawing.new("Line") line.Visible = true line.Thickness = 2
    local connection; connection = RunService.RenderStepped:Connect(function()
        if not _G.ESPToggleState or not targetPlayer.Parent or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then line.Visible = false line:Delete() billboard:Destroy() connection:Disconnect() return end
        local cam = workspace.CurrentCamera local targetPos, onScreen1 = cam:WorldToViewportPoint(root.Position) local localPos, onScreen2 = cam:WorldToViewportPoint(localPlayer.Character.HumanoidRootPart.Position)
        if _G.KeyCheckESPState then
            local keyData = getgenv().KeySystemDatabase[targetPlayer.Name] or getgenv().KeySystemDatabase[string.lower(targetPlayer.Name)]
            if keyData and keyData.Status == "Valid" then keyLabel.Text = "[🔑 KEY VIP: " .. (keyData.Role or "User") .. "]" keyLabel.TextColor3 = Color3.fromRGB(0, 255, 0) line.Color = Color3.fromRGB(0, 255, 0)
            else keyLabel.Text = "[❌ NO KEY]" keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200) line.Color = Color3.fromRGB(255, 0, 0) end
        else keyLabel.Text = "" line.Color = Color3.fromRGB(255, 255, 255) end
        if onScreen1 and onScreen2 then line.From = Vector2.new(localPos.X, localPos.Y) line.To = Vector2.new(targetPos.X, targetPos.Y) line.Visible = true billboard.Enabled = true else line.Visible = false billboard.Enabled = false end
    end)
end

local function applyHealthESP(character)
    local head = character:FindFirstChild("Head") local hum = character:FindFirstChildOfClass("Humanoid")
    if head and hum and not head:FindFirstChild("HealthESP") then
        local billboard = Instance.new("BillboardGui", head) billboard.Name = "HealthESP" billboard.Size = UDim2.new(4, 0, 1.5, 0) billboard.StudsOffset = Vector3.new(0, 3, 0) billboard.AlwaysOnTop = true
        local bgFrame = Instance.new("Frame", billboard) bgFrame.Size = UDim2.new(1, 0, 0.2, 0) bgFrame.Position = UDim2.new(0, 0, 0.5, 0) bgFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        local bar = Instance.new("Frame", bgFrame) bar.Name = "HealthBar" bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0) bar.Size = UDim2.new(1, 0, 1, 0)
        local txt = Instance.new("TextLabel", billboard) txt.Name = "HPText" txt.Size = UDim2.new(1, 0, 0.5, 0) txt.Position = UDim2.new(0, 0, 0, -10) txt.BackgroundTransparency = 1 txt.TextColor3 = Color3.fromRGB(255, 255, 255) txt.Font = Enum.Font.SourceSansBold txt.TextScaled = true
    end
end

task.spawn(function() while true do task.wait(2) if _G.ESPToggleState then for _, p in ipairs(Players:GetPlayers()) do if p ~= localPlayer and not folderESP:FindFirstChild("NameESP_" .. p.Name) then createPlayerESP(p) end end end end end)

RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character local root = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChild("Humanoid")
    if not char or not root or not hum then return end
    if _G.SpeedPvP and hum.MoveDirection.Magnitude > 0 then local targetVelocity = hum.MoveDirection * getgenv().BypassVelocitySpeed root.AssemblyLinearVelocity = Vector3.new(targetVelocity.X, root.AssemblyLinearVelocity.Y, targetVelocity.Z) end
    if (_G.FlyTopDown or _G.FlyOrbitAround) and isTargetValidWeapon then root.AssemblyLinearVelocity = Vector3.zero end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                if _G.HitboxPvP then targetRoot.Size = HITBOX_SIZE_RED targetRoot.Transparency = 0.75 targetRoot.Color = Color3.fromRGB(244, 63, 94) targetRoot.CanCollide = true else if targetRoot.Size == HITBOX_SIZE_RED then targetRoot.Size = Vector3.new(2, 2, 1) targetRoot.Transparency = 1 targetRoot.CanCollide = true end end
            end
            if toolHitboxESPState then
                for _, child in ipairs(p.Character:GetChildren()) do
                    if child:IsA("Tool") then
                        local handle = child:FindFirstChild("Handle") or child:FindFirstChild("Hitbox")
                        if handle and not toolBoxes[child] then local sBox = Instance.new("SelectionBox", handle) sBox.Name = "GlobalToolHitbox" sBox.Adornee = handle sBox.LineThickness = 0.04 sBox.Color3 = Color3.fromRGB(0, 255, 0) sBox.SurfaceTransparency = 0.9 toolBoxes[child] = sBox end
                    end
                end
            end
            if healthESPState then
                applyHealthESP(p.Character) local tHum = p.Character:FindFirstChildOfClass("Humanoid") local tHead = p.Character:FindFirstChild("Head")
                if tHum and tHead and tHead:FindFirstChild("HealthESP") then
                    local esp = tHead.HealthESP local bar = esp.Frame.HealthBar local percentage = math.clamp(tHum.Health / tHum.MaxHealth, 0, 1)
                    bar.Size = UDim2.new(percentage, 0, 1, 0) bar.BackgroundColor3 = percentage > 0.6 and Color3.fromRGB(0, 255, 0) or (percentage > 0.3 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0)) esp.HPText.Text = math.floor(tHum.Health) .. "/" .. math.floor(tHum.MaxHealth)
                end
            end
        end
    end
end)

-- ============================================================================
-- 🌐 TAB 4: SERVER HOP
-- ============================================================================
Window:AddSection({ Name = "Quản Lý Máy Chủ (Server Hop)", Tab = TabServer })

local function HopServer(targetType)
    local placeId = game.PlaceId local currentJobId = game.JobId local cursor = "" local candidateServer = nil local bestCount = (targetType == "Fullest") and -1 or 999
    pcall(function()
        repeat
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/0?sortOrder=Desc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
            local req = request or http_request or (syn and syn.request) or (http and http.request)
            if not req then return end
            local res = req({ Url = url, Method = "GET" }) local body = HttpService:JSONDecode(res.Body)
            if body and body.data then
                for _, s in ipairs(body.data) do
                    if s.id ~= currentJobId and s.playing < s.maxPlayers and s.playing > 0 then
                        if targetType == "Fullest" then if s.playing > bestCount and s.playing < s.maxPlayers then bestCount = s.playing candidateServer = s.id end
                        elseif targetType == "Lowest" then if s.playing < bestCount then bestCount = s.playing candidateServer = s.id end end
                    end
                end
            end
            cursor = body and body.nextPageCursor or nil
        until not cursor or candidateServer ~= nil
    end)
    if candidateServer then TeleportService:TeleportToPlaceInstance(placeId, candidateServer, localPlayer) end
end

Window:AddButton({ Title = "Chuyển Tới Server Đông Nhất", Tab = TabServer, Callback = function() HopServer("Fullest") end })
Window:AddButton({ Title = "Chuyển Tới Server Ít Người Nhất", Tab = TabServer, Callback = function() HopServer("Lowest") end })
Window:AddButton({ Title = "Rejoin Server Hiện Tại", Tab = TabServer, Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer) end })

-- ============================================================================
-- ⚡ TAB 5: FIX LAG
-- ============================================================================
Window:AddSection({ Name = "Tối Ưu Đồ Họa & Tăng FPS", Tab = TabFixLag })

local hiddenPartsBackup = {}
local function toggleFPSBoost(state)
    if state then
        Lighting.GlobalShadows = false Lighting.FogEnd = 9e9 settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end end
    else Lighting.GlobalShadows = true settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end
end

local function reduceParts(percent, state)
    if state then
        local allParts = {}
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(localPlayer.Character) and not part.Parent:FindFirstChildOfClass("Humanoid") then table.insert(allParts, part) end
        end
        local countToHide = math.floor(#allParts * (percent / 100))
        for i = 1, countToHide do local p = allParts[i] if p and p.Parent then hiddenPartsBackup[p] = p.LocalTransparencyModifier p.LocalTransparencyModifier = 1 end end
    else
        for part, oldTrans in pairs(hiddenPartsBackup) do if part and part.Parent then part.LocalTransparencyModifier = oldTrans end end
        hiddenPartsBackup = {}
    end
end

Window:AddToggle({ Title = "FPS Boost Pro", Tab = TabFixLag, Callback = function(val) toggleFPSBoost(val) end })
Window:AddToggle({ Title = "Giảm 20% Chi Tiết Môi Trường", Tab = TabFixLag, Callback = function(val) reduceParts(20, val) end })
Window:AddToggle({ Title = "Giảm 40% Chi Tiết Môi Trường", Tab = TabFixLag, Callback = function(val) reduceParts(40, val) end })
Window:AddToggle({ Title = "Giảm 60% Chi Tiết Môi Trường", Tab = TabFixLag, Callback = function(val) reduceParts(60, val) end })
Window:AddToggle({ Title = "Giảm 100% Vật Thể Map", Tab = TabFixLag, Callback = function(val) reduceParts(100, val) end })

Window:AddButton({
	Title = "Xóa Sạch Hiệu Ứng Particle & Decal", Tab = TabFixLag,
	Callback = function()
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then obj:Destroy() end
		end
		Lighting:ClearAllChildren() Lighting.GlobalShadows = false Lighting.FogEnd = 9e9 settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		Window:Notify({ Title = "Fix Lag", Description = "Đã dọn dẹp toàn bộ hiệu ứng môi trường!", Duration = 3 })
	end
})

-- ============================================================================
-- ⚙️ TAB 6: CÀI ĐẶT & CHỨC NĂNG HỆ THỐNG (MỚI: ANTI-AFK & CASH TRACKER)
-- ============================================================================
Window:AddSection({ Name = "Cấu Hình Giao Diện & Theme Màu Đẹp", Tab = TabSettings })

Window:AddDropdown({
	Title = "Chọn Bảng Màu Menu Tùy Chỉnh",
	Description = "Lựa chọn các Theme màu cực sang cho Lates Lib",
	Tab = TabSettings,
	Options = {
		["Tối Chuẩn (Dark Mode)"] = "Dark",
		["Hố Đen Sâu (Void Dark)"] = "Void",
		["Sáng Hiện Đại (Light Mode)"] = "Light",
		["Tím Thạch Anh (Amethyst Purple)"] = "Amethyst",
		["Xanh Lục Bảo (Emerald Green)"] = "Emerald",
		["Hồng Anh Đào (Sakura Pink)"] = "Sakura",
		["Phong Cách Cyberpunk (Cyber)"] = "Cyberpunk",
		["Cam Hoàng Hôn (Sunset Orange)"] = "Sunset"
	},
	Callback = function(ThemeName)
		if Themes[ThemeName] then
			Window:SetTheme(Themes[ThemeName])
			Window:Notify({
				Title = "Đổi Theme Thành Công",
				Description = "Đã áp dụng Theme: " .. ThemeName,
				Duration = 3
			})
		end
	end
})

Window:AddToggle({
	Title = "Kích Hoạt Hiệu Ứng Blur Nền", Description = "Graphics Roblox phải lớn hơn mức 8", Tab = TabSettings,
	Default = true,
	Callback = function(state) Window:SetSetting("Blur", state) end
})

Window:AddSlider({
	Title = "Độ Trong Suốt Cửa Sổ (Transparency)", Tab = TabSettings,
	MaxValue = 1, AllowDecimals = true,
	Callback = function(v) Window:SetSetting("Transparency", v) end
})

Window:AddSection({ Name = "Hệ Thống Tiện Ích Treo Máy (Anti-AFK / Cash)", Tab = TabSettings })

-- CHỨC NĂNG 1: ANTI-AFK HOÀN CHỈNH
_G.AntiAFKState = true -- Mặc định bật
Window:AddToggle({
    Title = "Kích Hoạt Anti-AFK (Bypass Kick IDLE)",
    Description = "Ngăn chặn bị tự động đuổi khỏi máy chủ sau 20 phút treo máy",
    Tab = TabSettings,
    Default = true,
    Callback = function(state) _G.AntiAFKState = state end
})

task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    localPlayer.Idled:Connect(function()
        if _G.AntiAFKState then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
                Window:Notify({
                    Title = "ANTI-AFK SYSTEM",
                    Description = "Đã bypass bộ đếm thời gian treo máy thành công!",
                    Duration = 2
                })
            end)
        end
    end)
end)

-- CHỨC NĂNG 2: CẬP NHẬT SỐ TIỀN CASH LIÊN TỤC
local cashParagraph = Window:AddParagraph({ 
    Title = "💵 Tài Sản Hiện Tại", 
    Description = "Đang tải ví tiền...", 
    Tab = TabSettings 
})

local function FormatNumber(value)
    return tostring(value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function SetupCashTracker()
    pcall(function()
        local leaderstats = localPlayer:WaitForChild("leaderstats", 15)
        if leaderstats then
            local cashValue = leaderstats:WaitForChild("Cash", 10)
            if cashValue and cashValue:IsA("ValueBase") then
                local function UpdateVisuals()
                    local rawAmount = cashValue.Value
                    local displayStr = "Số dư ví: " .. FormatNumber(rawAmount) .. " $"
                    
                    -- Cập nhật vào ô thông tin trong cài đặt
                    cashParagraph:SetTitle("💵 Tài Sản Hiện Tại")
                    cashParagraph:SetDescription(displayStr)
                    
                    -- Cập nhật động lên tiêu đề cửa sổ chính của Menu
                    pcall(function()
                        Window:SetTitle("MEMAYBEO HUB V42 | Money: " .. FormatNumber(rawAmount) .. " $")
                    end)
                end
                
                cashValue.Changed:Connect(UpdateVisuals)
                UpdateVisuals()
            else
                cashParagraph:SetDescription("Không tìm thấy giá trị Cash trong Leaderstats!")
            end
        else
            cashParagraph:SetDescription("Không tìm thấy thư mục leaderstats!")
        end
    end)
end
task.spawn(SetupCashTracker)

-- Thông báo khi tải thành công
Window:Notify({
	Title = "MEMAYBEO HUB V42 Loaded!",
	Description = "Nhấn phím [END] trên bàn phím để Ẩn / Hiện Menu!",
	Duration = 7
})
