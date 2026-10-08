--[[
        ИНТЕГРАЦИЯ FAKELAG С ОПЦИЕЙ ОТОБРАЖЕНИЯ И ИСПРАВЛЕННЫМ HITBOX
        УДАЛЕНЫ ФУНКЦИИ: INFINITE JUMP, AIM REQUIRE WEAPON, TEAM CHECK
        ДОБАВЛЕНО: ПЛАВНОЕ УСКОРЕНИЕ (ОБХОД АНТИЧИТА НА СКОРОСТЬ)
        ИЗМЕНЕНИЯ: СКОРОСТЬ ЗАФИКСИРОВАНА НА 24, ПОЛЗУНОК УДАЛЕН
        ĐÃ XÓA THEO YÊU CẦU: SAFEZONE TOÀN MAP, BAY TRÊN ĐẦU / DƯỚI CHÂN ĐỊCH, AUTO FARM CFRAME
    CẬP NHẬT VER 10: SKIN SÚNG VER 8 (VIỀN SÁNG + SÓNG MÀU CHẢY) — KILL EFFECT VER 5 (14 KIỂU HÌNH TRÒN MƯỢT)
    CẬP NHẬT VER 10: AUTO HÚP BOX SIÊU TỐC (MỖI KHUNG HÌNH + HOLD 0s) — STREAM SAFE CHE QUAY MÀN HÌNH
    CẬP NHẬT MỚI: TÍCH HỢP INVISIBLE TOUCH FLING THEO YÊU CẦU CỦA BẠN & ANTI-FLING
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera

-- ЦВЕТОВАЯ ПАЛИТРА
local Colors = {
    MainBg = Color3.fromRGB(15, 15, 18),
    SidebarBg = Color3.fromRGB(22, 22, 26),
    TabActive = Color3.fromRGB(35, 35, 42),
    ElementBg = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(90, 130, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 150, 160),
    Outline = Color3.fromRGB(45, 45, 55),
    ToggleOff = Color3.fromRGB(40, 40, 50)
}

-- ЛОГИЧЕСКАЯ КОНФИГУРАЦИЯ
local Config = {
    ESP_Color = Color3.fromRGB(100, 255, 100), 
    Aimbot = false,
    HitboxExpander = false, 
    HitboxSize = 15,
    WallCheck = false,
    Smoothness = 0.5,
    Hitbox = "Head",
    FOV_Visible = false,
    FOV_Radius = 150,
    Crosshair = false,
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_Tracer = false,
    ESP_Name = false,
    ESP_HealthBar = false,
    ESP_Distance = false,
    ESP_Weapon = false,      
    ESP_HeadCircle = false,  
    ESP_SnapLines = false,   
    ESP_State = false,       
    ESP_Chams = false,       
    ESP_HealthText = false,  
    ESP_Box3D = false,       
    Speed = false,
    SpeedValue = 24, 
    SpeedAcceleration = 0.2, 
    AutoGetBox = false, 
    FakeLag = false,
    FlingAura = false,      -- BẬT/TẮT TOUCH FLING
    AntiFling = false,      -- BẬT/TẮT ANTI FLING
    CheQuayManHinh = false, -- ĐANG ẨN ESP/FOV để quay/chụp (STREAM SAFE)
    CheTuDongPhim  = true,  -- PC: tự ẩn khi bấm phím chụp (PrintScreen / F12)
    CheCuChi3Ngon  = true,  -- Mobile: chạm 3 ngón để ẩn/hiện nhanh
    CheAnLuonMenu  = false  -- ẩn luôn menu script khi đang che
}

local FakeLagData = {}

-- ФУНКЦИЯ ПОЛУЧЕНИЯ ЦЕНТРА ПРИЦЕЛА ИЗ ИГРЫ
local function GetAimCenter()
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    pcall(function()
        local crosshair = LocalPlayer.PlayerGui.GunGUI.Crosshair
        local inset = game:GetService("GuiService"):GetGuiInset()
        center = Vector2.new(crosshair.AbsolutePosition.X + (crosshair.AbsoluteSize.X / 2), crosshair.AbsolutePosition.Y + (crosshair.AbsoluteSize.Y / 2) + inset.Y)
    end)
    return center
end

-- ФУНКЦИЯ ПЛАВНОГО ПЕРЕТАСКИВАНИЯ UI
local function MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local Delta = input.Position - DragStart
        TweenService:Create(object, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        }):Play()
    end
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true DragStart = input.Position StartPos = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then Update(input) end
    end)
end


-- ДВИЖОК: ПОЛУЧЕНИЕ ИМЕНИ ЭКИПИРОВАННОГО ОРУЖИЯ
local function GetEquippedWeaponName(player)
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then return tool.Name end
        end
    end
    return "Hands"
end

-- ДВИЖОК: ПОЛУЧЕНИЕ СОСТОЯНИЯ ДЕЙСТВИЯ
local function GetCharacterState(humanoid)
    if not humanoid then return "Stand" end
    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping then return "Jump"
    elseif state == Enum.HumanoidStateType.Freefall then return "Fall"
    elseif humanoid.MoveDirection.Magnitude > 0 then return "Run"
    else return "Stand" end
end

local function GetHitbox(character)
    local part = nil
    if Config.Hitbox == "Head" then part = character:FindFirstChild("Head")
    elseif Config.Hitbox == "UpperBody" then part = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    elseif Config.Hitbox == "LowerBody" then part = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    end
    return part or character:FindFirstChild("HumanoidRootPart")
end

local function IsVisible(targetPart)
    if not Config.WallCheck then return true end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local rayResult = workspace:Raycast(origin, direction, rayParams)
    if rayResult then return rayResult.Instance:IsDescendantOf(targetPart.Parent) end
    return true
end

local function GetClosestPlayer()
    local target, targetPart = nil, nil
    local shortestDist = Config.FOV_Radius
    local center = GetAimCenter()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = GetHitbox(player.Character)
                if part and IsVisible(part) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist2D < shortestDist then
                            shortestDist = dist2D
                            target = player
                            targetPart = part
                        end
                    end
                end
            end
        end
    end
    return target, targetPart
end

-- ДВИЖОК: УВЕЛИЧЕНИЕ HITBOX
task.spawn(function()
    while task.wait(0.1) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
                    if torso then
                        if Config.HitboxExpander then
                            torso.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                            torso.Transparency = 0.6
                            torso.CanCollide = false
                            torso.Massless = true 
                        else
                            if torso.Size.X > 2.5 then 
                                torso.Size = Vector3.new(2, 2, 1) 
                                torso.Transparency = 0
                                torso.Massless = false
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- СОЗДАНИЕ ПЛАВАЮЩЕГО ОКНА FAKELAG
local FakeLagScreen = Instance.new("ScreenGui")
FakeLagScreen.Name = "FakeLagStandalone_Integ"
FakeLagScreen.ResetOnSpawn = false
FakeLagScreen.IgnoreGuiInset = true
FakeLagScreen.Enabled = false 
pcall(function() FakeLagScreen.Parent = CoreGui end)
if not FakeLagScreen.Parent then FakeLagScreen.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local FLMainFrame = Instance.new("Frame")
FLMainFrame.Size = UDim2.new(0, 200, 0, 100)
FLMainFrame.Position = UDim2.new(0.5, -100, 0.8, -50)
FLMainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
FLMainFrame.BorderSizePixel = 0
FLMainFrame.Parent = FakeLagScreen
Instance.new("UICorner", FLMainFrame).CornerRadius = UDim.new(0, 12)
local FLStroke = Instance.new("UIStroke", FLMainFrame)
FLStroke.Color = Color3.fromRGB(255, 50, 50)
FLStroke.Thickness = 2

local FLTitle = Instance.new("TextLabel")
FLTitle.Size = UDim2.new(1, 0, 0, 40)
FLTitle.Position = UDim2.new(0, 0, 0, 5)
FLTitle.BackgroundTransparency = 1
FLTitle.Text = "FAKE LAG"
FLTitle.Font = Enum.Font.GothamBlack
FLTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FLTitle.TextSize = 22
FLTitle.Parent = FLMainFrame

local FLToggleBg = Instance.new("Frame")
FLToggleBg.Size = UDim2.new(0, 70, 0, 30)
FLToggleBg.Position = UDim2.new(0.5, -35, 0.6, -5)
FLToggleBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FLToggleBg.BorderSizePixel = 0
FLToggleBg.Parent = FLMainFrame
Instance.new("UICorner", FLToggleBg).CornerRadius = UDim.new(1, 0)

local FLToggleCircle = Instance.new("Frame")
FLToggleCircle.Size = UDim2.new(0, 26, 0, 26)
FLToggleCircle.Position = UDim2.new(0, 2, 0.5, -13)
FLToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FLToggleCircle.BorderSizePixel = 0
FLToggleCircle.Parent = FLToggleBg
Instance.new("UICorner", FLToggleCircle).CornerRadius = UDim.new(1, 0)

local FLToggleBtn = Instance.new("TextButton")
FLToggleBtn.Size = UDim2.new(1, 0, 1, 0)
FLToggleBtn.BackgroundTransparency = 1
FLToggleBtn.Text = ""
FLToggleBtn.Parent = FLToggleBg

MakeDraggable(FLMainFrame, FLMainFrame)

local flGuiVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        flGuiVisible = not flGuiVisible
        FakeLagScreen.Enabled = flGuiVisible
    end
end)

local function SyncFakeLagState(state)
    Config.FakeLag = state
    if not state then FakeLagData = {} end
    local targetPos = state and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
    local targetColor = state and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(45, 45, 45)
    TweenService:Create(FLToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    TweenService:Create(FLToggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
end

FLToggleBtn.MouseButton1Click:Connect(function()
    SyncFakeLagState(not Config.FakeLag)
end)

-- БИБЛИОТЕКА UI (ГЛАВНОЕ МЕНЮ)
local Library = {}
function Library:CreateWindow(titleText)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Memaybeo_Ultra"
    ScreenGui.ResetOnSpawn = false
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local ToggleBtn = Instance.new("ImageButton", ScreenGui)
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
    ToggleBtn.BackgroundColor3 = Colors.SidebarBg
    ToggleBtn.Image = "rbxthumb://type=Asset&id=110461355830666&w=150&h=150"
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
    ToggleStroke.Color = Colors.Accent
    ToggleStroke.Thickness = 2.5
    MakeDraggable(ToggleBtn, ToggleBtn)

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 520, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
    MainFrame.BackgroundColor3 = Colors.MainBg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", MainFrame).Color = Colors.Outline

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BackgroundColor3 = Colors.SidebarBg
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
    
    local HideCorner = Instance.new("Frame", Sidebar)
    HideCorner.Size = UDim2.new(0, 10, 1, 0)
    HideCorner.Position = UDim2.new(1, -10, 0, 0)
    HideCorner.BackgroundColor3 = Colors.SidebarBg
    HideCorner.BorderSizePixel = 0
    
    local SidebarLine = Instance.new("Frame", Sidebar)
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.BackgroundColor3 = Colors.Outline
    SidebarLine.BorderSizePixel = 0

    MakeDraggable(Sidebar, MainFrame)
    
    local Title = Instance.new("TextLabel", Sidebar)
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Colors.Accent
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 16

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -130)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 6)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local ProfileFrame = Instance.new("Frame", Sidebar)
    ProfileFrame.Size = UDim2.new(1, 0, 0, 70)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -70)
    ProfileFrame.BackgroundColor3 = Colors.SidebarBg
    ProfileFrame.BorderSizePixel = 0

    local ProfileLine = Instance.new("Frame", ProfileFrame)
    ProfileLine.Size = UDim2.new(1, 0, 0, 1)
    ProfileLine.BackgroundColor3 = Colors.Outline
    ProfileLine.BorderSizePixel = 0

    local Avatar = Instance.new("ImageLabel", ProfileFrame)
    Avatar.Size = UDim2.new(0, 36, 0, 36)
    Avatar.Position = UDim2.new(0, 15, 0.5, -18)
    Avatar.BackgroundColor3 = Colors.ElementBg
    pcall(function() Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

    local PlayerName = Instance.new("TextLabel", ProfileFrame)
    PlayerName.Size = UDim2.new(1, -65, 0, 20)
    PlayerName.Position = UDim2.new(0, 60, 0.5, -10)
    PlayerName.BackgroundTransparency = 1
    PlayerName.Text = LocalPlayer.DisplayName
    PlayerName.TextColor3 = Colors.Text
    PlayerName.Font = Enum.Font.GothamBold
    PlayerName.TextSize = 13
    PlayerName.TextXAlignment = Enum.TextXAlignment.Left

    local ContentContainer = Instance.new("Frame", MainFrame)
    ContentContainer.Size = UDim2.new(1, -170, 1, 0)
    ContentContainer.Position = UDim2.new(0, 170, 0, 0)
    ContentContainer.BackgroundTransparency = 1

    local MenuOpen = true
    ToggleBtn.MouseButton1Click:Connect(function()
        MenuOpen = not MenuOpen
        if MenuOpen then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, 400), Position = UDim2.new(0.5, -260, 0.5, -200)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 520, 0, 0), Position = UDim2.new(0.5, -260, 0.5, 0)}):Play()
            task.delay(0.3, function() if not MenuOpen then MainFrame.Visible = false end end)
        end
    end)

    local Window = {Tabs = {}, CurrentTab = nil}

    function Window:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(0.85, 0, 0, 36)
        TabBtn.BackgroundColor3 = Colors.TabActive
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "   " .. tabName
        TabBtn.TextColor3 = Colors.SubText
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local Indicator = Instance.new("Frame", TabBtn)
        Indicator.Size = UDim2.new(0, 3, 0, 0)
        Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Indicator.AnchorPoint = Vector2.new(0, 0.5)
        Indicator.BackgroundColor3 = Colors.Accent
        Indicator.BorderSizePixel = 0
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

        local Page = Instance.new("ScrollingFrame", ContentContainer)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Colors.Outline
        Page.Visible = false
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 12)
        Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 20)
        Page.UIPadding.PaddingLeft = UDim.new(0, 20)
        Page.UIPadding.PaddingRight = UDim.new(0, 20)
        Page.UIPadding.PaddingBottom = UDim.new(0, 20)

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 40)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.SidebarBg, BackgroundTransparency = 1, TextColor3 = Colors.SubText}):Play()
                TweenService:Create(t.Indicator, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 0)}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.TabActive, BackgroundTransparency = 0, TextColor3 = Colors.Text}):Play()
            TweenService:Create(Indicator, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 20)}):Play()
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = Page
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Colors.Text
            Indicator.Size = UDim2.new(0, 3, 0, 20)
        end

        table.insert(Window.Tabs, {Btn = TabBtn, Page = Page, Indicator = Indicator})
        
        local Elements = {}
        
        function Elements:AddButton(text, callback)
            local BtnFrame = Instance.new("Frame", Page)
            BtnFrame.Size = UDim2.new(1, 0, 0, 44)
            BtnFrame.BackgroundColor3 = Colors.ElementBg
            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", BtnFrame).Color = Colors.Outline

            local Btn = Instance.new("TextButton", BtnFrame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = text
            Btn.TextColor3 = Colors.Text
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            
            Btn.MouseEnter:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ToggleOff}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementBg}):Play() end)
            
            Btn.MouseButton1Click:Connect(function()
                local oldText = Btn.Text
                Btn.Text = "Обработка..."
                Btn.TextColor3 = Colors.Accent
                pcall(callback)
                task.wait(0.2)
                Btn.Text = oldText
                Btn.TextColor3 = Colors.Text
            end)
        end
        
        function Elements:AddToggle(text, default, callback)
            local ToggleFrame = Instance.new("Frame", Page)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 44)
            ToggleFrame.BackgroundColor3 = Colors.ElementBg
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", ToggleFrame).Color = Colors.Outline

            local Label = Instance.new("TextLabel", ToggleFrame)
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 16, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Colors.Text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("TextButton", ToggleFrame)
            Switch.Size = UDim2.new(0, 42, 0, 22)
            Switch.Position = UDim2.new(1, -58, 0.5, -11)
            Switch.BackgroundColor3 = default and Colors.Accent or Colors.ToggleOff
            Switch.Text = ""
            Switch.AutoButtonColor = false
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame", Switch)
            Circle.Size = UDim2.new(0, 18, 0, 18)
            Circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local state = default
            local function SetState(newState)
                state = newState
                TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                }):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Colors.Accent or Colors.ToggleOff}):Play()
                callback(state)
            end

            Switch.MouseButton1Click:Connect(function() SetState(not state) end)
            
            return { SetState = SetState }
        end

        function Elements:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, 0, 0, 58)
            SliderFrame.BackgroundColor3 = Colors.ElementBg
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", SliderFrame).Color = Colors.Outline

            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Size = UDim2.new(1, -20, 0, 28)
            Label.Position = UDim2.new(0, 16, 0, 2)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Colors.Text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel", SliderFrame)
            ValueLabel.Size = UDim2.new(0, 50, 0, 28)
            ValueLabel.Position = UDim2.new(1, -66, 0, 2)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Colors.Accent
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local BarArea = Instance.new("TextButton", SliderFrame)
            BarArea.Size = UDim2.new(1, -32, 0, 6)
            BarArea.Position = UDim2.new(0, 16, 0, 38)
            BarArea.BackgroundColor3 = Colors.ToggleOff
            BarArea.Text = ""
            BarArea.AutoButtonColor = false
            Instance.new("UICorner", BarArea).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame", BarArea)
            local fillPercent = math.clamp((default - min) / (max - min), 0, 1)
            Fill.Size = UDim2.new(fillPercent, 0, 1, 0)
            Fill.BackgroundColor3 = Colors.Accent
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame", Fill)
            Circle.Size = UDim2.new(0, 12, 0, 12)
            Circle.Position = UDim2.new(1, -6, 0.5, -6)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local sliding = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - BarArea.AbsolutePosition.X) / BarArea.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(value)
                callback(value)
            end

            BarArea.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true UpdateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(input) end
            end)
        end
        
        function Elements:AddDropdown(text, options, default, callback)
            local DropdownFrame = Instance.new("Frame", Page)
            DropdownFrame.Size = UDim2.new(1, 0, 0, 48)
            DropdownFrame.BackgroundColor3 = Colors.ElementBg
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", DropdownFrame).Color = Colors.Outline

            local Label = Instance.new("TextLabel", DropdownFrame)
            Label.Size = UDim2.new(1, -10, 0, 48)
            Label.Position = UDim2.new(0, 16, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Colors.Text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local DropBtn = Instance.new("TextButton", DropdownFrame)
            DropBtn.Size = UDim2.new(0, 130, 0, 32)
            DropBtn.Position = UDim2.new(1, -146, 0.5, -16)
            DropBtn.BackgroundColor3 = Colors.ToggleOff
            DropBtn.Text = "  " .. default
            DropBtn.TextColor3 = Colors.Text
            DropBtn.Font = Enum.Font.Gotham
            DropBtn.TextSize = 12
            DropBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 6)
            
            local Arrow = Instance.new("TextLabel", DropBtn)
            Arrow.Size = UDim2.new(0, 30, 1, 0)
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Colors.SubText
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = 12
            
            local selected = default
            local isDropped = false
            
            DropBtn.MouseButton1Click:Connect(function()
                isDropped = not isDropped
                if isDropped then
                    Arrow.Text = "▲"
                    local menu = Instance.new("ScrollingFrame", DropdownFrame)
                    menu.Name = "DropMenu"
                    menu.Size = UDim2.new(0, 130, 0, math.min(#options * 32, 140))
                    menu.Position = UDim2.new(1, -146, 0, 42)
                    menu.BackgroundColor3 = Colors.ElementBg
                    menu.BorderSizePixel = 0
                    menu.ZIndex = 15
                    menu.ScrollBarThickness = 2
                    menu.ScrollBarImageColor3 = Colors.Accent
                    menu.CanvasSize = UDim2.new(0, 0, 0, #options * 32)
                    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)
                    Instance.new("UIStroke", menu).Color = Colors.Accent
                    
                    local layout = Instance.new("UIListLayout", menu)
                    
                    for _, opt in pairs(options) do
                        local btn = Instance.new("TextButton", menu)
                        btn.Size = UDim2.new(1, 0, 0, 32)
                        btn.BackgroundColor3 = Colors.ElementBg
                        btn.BackgroundTransparency = 1
                        btn.Text = "  " .. opt
                        btn.TextColor3 = Colors.SubText
                        btn.Font = Enum.Font.Gotham
                        btn.TextSize = 12
                        btn.TextXAlignment = Enum.TextXAlignment.Left
                        btn.AutoButtonColor = false
                        btn.ZIndex = 16
                        
                        btn.MouseEnter:Connect(function() btn.TextColor3 = Colors.Accent end)
                        btn.MouseLeave:Connect(function() btn.TextColor3 = Colors.SubText end)
                        
                        btn.MouseButton1Click:Connect(function()
                            selected = opt
                            DropBtn.Text = "  " .. opt
                            Arrow.Text = "▼"
                            isDropped = false
                            menu:Destroy()
                            callback(opt)
                        end)
                    end
                else
                    Arrow.Text = "▼"
                    if DropdownFrame:FindFirstChild("DropMenu") then DropdownFrame.DropMenu:Destroy() end
                end
            end)
        end
        return Elements
    end
    return Window
end

local Window = Library:CreateWindow("MEMAYBEO HUB v17.7")

local CombatTab = Window:CreateTab("Aimbot")
local EspTab = Window:CreateTab("Premium ESP")
local TeleportTab = Window:CreateTab("Teleport")
local MiscTab = Window:CreateTab("Misc")

-- GUI FOV & CROSSHAIR
local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "FOV_GUI"
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true
pcall(function() FOVGui.Parent = CoreGui end)
if not FOVGui.Parent then FOVGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local FOVFrame = Instance.new("Frame", FOVGui)
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
local FOVCorner = Instance.new("UICorner", FOVFrame)
FOVCorner.CornerRadius = UDim.new(1, 0)
local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Thickness = 1.5
FOVStroke.Color = Config.ESP_Color

local CrosshairX = Drawing.new("Line")
CrosshairX.Thickness = 1.5
CrosshairX.Color = Config.ESP_Color
CrosshairX.Visible = false
local CrosshairY = Drawing.new("Line")
CrosshairY.Thickness = 1.5
CrosshairY.Color = Config.ESP_Color
CrosshairY.Visible = false

-- ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ТЕЛЕПОРТА
local function TeleportTo(cf)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
    end
end

-- ОТОБРАЖЕНИЕ ESP 
local ESP_Drawings = {}
local function CreateESP(player)
    if not ESP_Drawings[player] then
        ESP_Drawings[player] = {
            BoxOutline = Drawing.new("Square"),
            Box = Drawing.new("Square"),
            HealthBg = Drawing.new("Square"),
            HealthBar = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            Skeleton = {},
            Weapon = Drawing.new("Text"),       
            HeadCircle = Drawing.new("Circle"), 
            SnapLine = Drawing.new("Line"),     
            State = Drawing.new("Text"),        
            HealthText = Drawing.new("Text"),   
            Box3D = {},                         
            ChamsHighlight = nil                
        }
        
        ESP_Drawings[player].BoxOutline.Thickness = 3
        ESP_Drawings[player].BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        ESP_Drawings[player].BoxOutline.Filled = false
        ESP_Drawings[player].Box.Thickness = 1
        ESP_Drawings[player].Box.Color = Config.ESP_Color
        ESP_Drawings[player].Box.Filled = false
        
        ESP_Drawings[player].HealthBg.Thickness = 1
        ESP_Drawings[player].HealthBg.Color = Color3.fromRGB(0, 0, 0)
        ESP_Drawings[player].HealthBg.Filled = false
        ESP_Drawings[player].HealthBar.Thickness = 1
        ESP_Drawings[player].HealthBar.Color = Color3.fromRGB(0, 255, 0)
        ESP_Drawings[player].HealthBar.Filled = true
        
        ESP_Drawings[player].Tracer.Thickness = 1
        ESP_Drawings[player].Tracer.Color = Config.ESP_Color
        
        ESP_Drawings[player].Name.Size = 14
        ESP_Drawings[player].Name.Color = Color3.fromRGB(255, 255, 255)
        ESP_Drawings[player].Name.Center = true
        ESP_Drawings[player].Name.Outline = true
        ESP_Drawings[player].Distance.Size = 13
        ESP_Drawings[player].Distance.Color = Color3.fromRGB(200, 200, 200)
        ESP_Drawings[player].Distance.Center = true
        ESP_Drawings[player].Distance.Outline = true
        
        ESP_Drawings[player].Weapon.Size = 13
        ESP_Drawings[player].Weapon.Color = Color3.fromRGB(255, 220, 100)
        ESP_Drawings[player].Weapon.Center = true
        ESP_Drawings[player].Weapon.Outline = true

        ESP_Drawings[player].HeadCircle.Thickness = 1.5
        ESP_Drawings[player].HeadCircle.Color = Config.ESP_Color
        ESP_Drawings[player].HeadCircle.Filled = false

        ESP_Drawings[player].SnapLine.Thickness = 1
        ESP_Drawings[player].SnapLine.Color = Config.ESP_Color

        ESP_Drawings[player].State.Size = 12
        ESP_Drawings[player].State.Color = Color3.fromRGB(150, 255, 200)
        ESP_Drawings[player].State.Center = true
        ESP_Drawings[player].State.Outline = true

        ESP_Drawings[player].HealthText.Size = 13
        ESP_Drawings[player].HealthText.Color = Color3.fromRGB(0, 255, 150)
        ESP_Drawings[player].HealthText.Center = true
        ESP_Drawings[player].HealthText.Outline = true

        for i = 1, 12 do
            ESP_Drawings[player].Box3D[i] = Drawing.new("Line")
            ESP_Drawings[player].Box3D[i].Thickness = 1
            ESP_Drawings[player].Box3D[i].Color = Config.ESP_Color
        end

        for i = 1, 15 do
            ESP_Drawings[player].Skeleton[i] = {
                Main = Drawing.new("Line")
            }
            ESP_Drawings[player].Skeleton[i].Main.Thickness = 1.8
            ESP_Drawings[player].Skeleton[i].Main.Color = Color3.fromRGB(255, 255, 255)
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(player)
    if ESP_Drawings[player] then
        ESP_Drawings[player].BoxOutline:Remove()
        ESP_Drawings[player].Box:Remove()
        ESP_Drawings[player].HealthBg:Remove()
        ESP_Drawings[player].HealthBar:Remove()
        ESP_Drawings[player].Tracer:Remove()
        ESP_Drawings[player].Name:Remove()
        ESP_Drawings[player].Distance:Remove()
        ESP_Drawings[player].Weapon:Remove()
        ESP_Drawings[player].HeadCircle:Remove()
        ESP_Drawings[player].SnapLine:Remove()
        ESP_Drawings[player].State:Remove()
        ESP_Drawings[player].HealthText:Remove()
        for i = 1, 12 do
            ESP_Drawings[player].Box3D[i]:Remove()
        end
        if ESP_Drawings[player].ChamsHighlight then
            ESP_Drawings[player].ChamsHighlight:Destroy()
        end
        for _, lineSet in pairs(ESP_Drawings[player].Skeleton) do 
            if lineSet.Main then lineSet.Main:Remove() end
        end
        ESP_Drawings[player] = nil
    end
    if FakeLagData[player] then
        FakeLagData[player] = nil
    end
end)

local R15_Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

-- ГЛАВНЫЙ ЦИКЛ RENDER STEPPED (ESP + AIMBOT + FAKELAG + SPEED BYPASS)
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    
    local aimCenter = GetAimCenter()
    local guiInset = game:GetService("GuiService"):GetGuiInset()

    if FOVFrame then
        FOVFrame.Visible = Config.FOV_Visible
        FOVFrame.Size = UDim2.new(0, Config.FOV_Radius * 2, 0, Config.FOV_Radius * 2)
        FOVFrame.Position = UDim2.new(0, aimCenter.X, 0, aimCenter.Y - guiInset.Y)
        FOVStroke.Color = Config.ESP_Color
    end

    if CrosshairX and CrosshairY then
        local drawY = aimCenter.Y - guiInset.Y
        CrosshairX.Visible = Config.Crosshair
        CrosshairY.Visible = Config.Crosshair
        CrosshairX.Color = Config.ESP_Color
        CrosshairY.Color = Config.ESP_Color
        if Config.Crosshair then
            CrosshairX.From = Vector2.new(aimCenter.X - 8, drawY)
            CrosshairX.To = Vector2.new(aimCenter.X + 8, drawY)
            CrosshairY.From = Vector2.new(aimCenter.X, drawY - 8)
            CrosshairY.To = Vector2.new(aimCenter.X, drawY + 8)
        end
    end

    if Config.Aimbot then
        local target, hitPart = GetClosestPlayer()
        if target and hitPart then
            local targetPos = hitPart.Position
            local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local offset2D = aimCenter - centerScreen
            
            local dist = (Camera.CFrame.Position - targetPos).Magnitude
            local vFov = math.rad(Camera.FieldOfView)
            local hHeight = dist * math.tan(vFov / 2)
            local hWidth = hHeight * (Camera.ViewportSize.X / Camera.ViewportSize.Y)
            
            local yWorldOffset = (offset2D.Y / (Camera.ViewportSize.Y / 2)) * hHeight
            local xWorldOffset = (offset2D.X / (Camera.ViewportSize.X / 2)) * hWidth
            
            local finalTargetPos = targetPos + (Camera.CFrame.UpVector * yWorldOffset) - (Camera.CFrame.RightVector * xWorldOffset)
            
            local newCF = CFrame.lookAt(Camera.CFrame.Position, finalTargetPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCF, Config.Smoothness)
        end
    end

    if Config.Speed then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed < Config.SpeedValue then
                humanoid.WalkSpeed = math.min(humanoid.WalkSpeed + Config.SpeedAcceleration, Config.SpeedValue)
            elseif humanoid.WalkSpeed > Config.SpeedValue then
                humanoid.WalkSpeed = Config.SpeedValue
            end
        end
    elseif not Config.Speed and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= 16 then 
            humanoid.WalkSpeed = 16 
        end
    end

    if Config.FakeLag then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                if not FakeLagData[p] then
                    FakeLagData[p] = hrp.CFrame
                end
                hrp.CFrame = FakeLagData[p]
            end
        end
    end

    for player, esp in pairs(ESP_Drawings) do
        local isVisible = false
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                local hrp = player.Character.HumanoidRootPart
                local head = player.Character:FindFirstChild("Head")
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen and head then
                    isVisible = true
                    
                    local topCFrame = hrp.CFrame * CFrame.new(0, 1 + (head.Size.Y/2) + 0.2, 0)
                    local botCFrame = hrp.CFrame * CFrame.new(0, -1 - 3, 0)
                    local topPos = Camera:WorldToViewportPoint(topCFrame.Position)
                    local botPos = Camera:WorldToViewportPoint(botCFrame.Position)
                    
                    local height = math.abs(topPos.Y - botPos.Y)
                    local width = height * 0.65
                    local boxX = hrpPos.X - width/2
                    local boxY = math.min(topPos.Y, botPos.Y)

                    esp.Box.Color = Config.ESP_Color
                    esp.Tracer.Color = Config.ESP_Color
                    esp.HeadCircle.Color = Config.ESP_Color
                    esp.SnapLine.Color = Config.ESP_Color

                    if Config.ESP_Box then
                        esp.BoxOutline.Visible = true
                        esp.BoxOutline.Size = Vector2.new(width, height)
                        esp.BoxOutline.Position = Vector2.new(boxX, boxY)
                        esp.Box.Visible = true
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(boxX, boxY)
                    else
                        esp.BoxOutline.Visible = false
                        esp.Box.Visible = false
                    end

                    if Config.ESP_HealthBar then
                        local maxHp = (humanoid.MaxHealth > 0) and humanoid.MaxHealth or 100
                        local hpPercent = math.clamp(humanoid.Health / maxHp, 0, 1)
                        local barColor = Color3.fromRGB(math.floor(255 * (1 - hpPercent)), math.floor(255 * hpPercent), 0)
                        
                        esp.HealthBg.Visible = true
                        esp.HealthBg.Size = Vector2.new(4, height + 2)
                        esp.HealthBg.Position = Vector2.new(boxX - 6, boxY - 1)
                        
                        local barHeight = math.max(2, math.floor(height * hpPercent))
                        esp.HealthBar.Visible = true
                        esp.HealthBar.Size = Vector2.new(2, barHeight)
                        esp.HealthBar.Position = Vector2.new(boxX - 5, boxY + height - barHeight)
                        esp.HealthBar.Color = barColor
                    else
                        esp.HealthBg.Visible = false
                        esp.HealthBar.Visible = false
                    end

                    local currentTopOffset = 18
                    if Config.ESP_Name then
                        esp.Name.Visible = true
                        esp.Name.Position = Vector2.new(hrpPos.X, boxY - currentTopOffset)
                        esp.Name.Text = player.DisplayName
                        currentTopOffset = currentTopOffset + 14
                    else
                        esp.Name.Visible = false
                    end

                    if Config.ESP_HealthText then
                        esp.HealthText.Visible = true
                        esp.HealthText.Position = Vector2.new(hrpPos.X, boxY - currentTopOffset)
                        esp.HealthText.Text = string.format("%d HP", math.floor(humanoid.Health))
                        currentTopOffset = currentTopOffset + 14
                    else
                        esp.HealthText.Visible = false
                    end
                    
                    local currentBottomOffset = 2
                    if Config.ESP_Distance then
                        esp.Distance.Visible = true
                        esp.Distance.Position = Vector2.new(hrpPos.X, boxY + height + currentBottomOffset)
                        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                        esp.Distance.Text = string.format("[%.0fm]", dist)
                        currentBottomOffset = currentBottomOffset + 14
                    else
                        esp.Distance.Visible = false
                    end

                    if Config.ESP_Weapon then
                        esp.Weapon.Visible = true
                        esp.Weapon.Position = Vector2.new(hrpPos.X, boxY + height + currentBottomOffset)
                        esp.Weapon.Text = GetEquippedWeaponName(player)
                        currentBottomOffset = currentBottomOffset + 14
                    else
                        esp.Weapon.Visible = false
                    end

                    if Config.ESP_State then
                        esp.State.Visible = true
                        esp.State.Position = Vector2.new(hrpPos.X, boxY + height + currentBottomOffset)
                        esp.State.Text = "[" .. GetCharacterState(humanoid) .. "]"
                    else
                        esp.State.Visible = false
                    end

                    if Config.ESP_HeadCircle then
                        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                        if headOnScreen then
                            esp.HeadCircle.Visible = true
                            esp.HeadCircle.Position = Vector2.new(headPos.X, headPos.Y)
                            esp.HeadCircle.Radius = math.clamp(height / 7, 4, 30)
                        else
                            esp.HeadCircle.Visible = false
                        end
                    else
                        esp.HeadCircle.Visible = false
                    end

                    if Config.ESP_SnapLines then
                        esp.SnapLine.Visible = true
                        local viewportSize = Camera.ViewportSize
                        esp.SnapLine.From = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                        esp.SnapLine.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    else
                        esp.SnapLine.Visible = false
                    end
                    
                    if Config.ESP_Tracer then
                        esp.Tracer.Visible = true
                        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        esp.Tracer.From = Vector2.new(center.X, 0) 
                        esp.Tracer.To = Vector2.new(hrpPos.X, boxY) 
                    else
                        esp.Tracer.Visible = false
                    end

                    if Config.ESP_Box3D then
                        local extents = Vector3.new(2, 3, 2)
                        local cf = hrp.CFrame
                        local corners3D = {
                            Camera:WorldToViewportPoint((cf * CFrame.new(-extents.X, extents.Y, -extents.Z)).Position),
                            Camera:WorldToViewportPoint((cf * CFrame.new(extents.X, extents.Y, -extents.Z)).Position),
                            Camera:WorldToViewportPoint((cf * CFrame.new(extents.X, extents.Y, extents.Z)).Position),
                            Camera:WorldToViewportPoint((cf * CFrame.new(-extents.X, extents.Y, extents.Z)).Position),
                            Camera:WorldToViewportPoint((cf * CFrame.new(-extents.X, -extents.Y, -extents.Z)).Position),
                            Camera:WorldToViewportPoint((cf * CFrame.new(extents.X, -extents.Y, -extents.Z)).Position),
                            Camera:WorldToViewportPoint((cf * CFrame.new(extents.X, -extents.Y, extents.Z)).Position),
                            Camera:WorldToViewportPoint((cf * CFrame.new(-extents.X, -extents.Y, extents.Z)).Position)
                        }

                        local linesIndices = {
                            {1,2}, {2,3}, {3,4}, {4,1},
                            {5,6}, {6,7}, {7,8}, {8,5},
                            {1,5}, {2,6}, {3,7}, {4,8}
                        }

                        for idx, edge in ipairs(linesIndices) do
                            local p1, p2 = corners3D[edge[1]], corners3D[edge[2]]
                            local lineDraw = esp.Box3D[idx]
                            if p1.Z > 0 and p2.Z > 0 then
                                lineDraw.Visible = true
                                lineDraw.Color = Config.ESP_Color
                                lineDraw.From = Vector2.new(p1.X, p1.Y)
                                lineDraw.To = Vector2.new(p2.X, p2.Y)
                            else
                                lineDraw.Visible = false
                            end
                        end
                    else
                        for i = 1, 12 do
                            esp.Box3D[i].Visible = false
                        end
                    end

                    if Config.ESP_Chams then
                        if not esp.ChamsHighlight then
                            local hl = Instance.new("Highlight")
                            hl.Name = "ESP_Chams_Highlight"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = player.Character
                            esp.ChamsHighlight = hl
                        end
                        esp.ChamsHighlight.Adornee = player.Character
                        esp.ChamsHighlight.FillColor = Config.ESP_Color
                        esp.ChamsHighlight.FillTransparency = 0.5
                        esp.ChamsHighlight.OutlineColor = Config.ESP_Color
                        esp.ChamsHighlight.OutlineTransparency = 0
                        esp.ChamsHighlight.Enabled = true
                    else
                        if esp.ChamsHighlight then
                            esp.ChamsHighlight.Enabled = false
                        end
                    end
                    
                    if Config.ESP_Skeleton then
                        local boneIndex = 1
                        local function DrawBone(pos1, pos2)
                            if boneIndex > 15 then return end
                            local p1, s1 = Camera:WorldToViewportPoint(pos1)
                            local p2, s2 = Camera:WorldToViewportPoint(pos2)
                            if s1 and s2 then
                                esp.Skeleton[boneIndex].Main.Visible = true
                                esp.Skeleton[boneIndex].Main.From = Vector2.new(p1.X, p1.Y)
                                esp.Skeleton[boneIndex].Main.To = Vector2.new(p2.X, p2.Y)
                                esp.Skeleton[boneIndex].Main.Color = Color3.fromRGB(255, 255, 255)
                            else
                                esp.Skeleton[boneIndex].Main.Visible = false
                            end
                            boneIndex = boneIndex + 1
                        end

                        local isR15 = player.Character:FindFirstChild("UpperTorso") ~= nil
                        if isR15 then
                            for _, joints in pairs(R15_Bones) do
                                local part1 = player.Character:FindFirstChild(joints[1])
                                local part2 = player.Character:FindFirstChild(joints[2])
                                if part1 and part2 then DrawBone(part1.Position, part2.Position) end
                            end
                        else
                            local torso = player.Character:FindFirstChild("Torso")
                            local lArm = player.Character:FindFirstChild("Left Arm")
                            local rArm = player.Character:FindFirstChild("Right Arm")
                            local lLeg = player.Character:FindFirstChild("Left Leg")
                            local rLeg = player.Character:FindFirstChild("Right Leg")
                            if head and torso and lArm and rArm and lLeg and rLeg then
                                local neck = (torso.CFrame * CFrame.new(0, 1, 0)).Position
                                local pelvis = (torso.CFrame * CFrame.new(0, -1, 0)).Position
                                local lShoulder = (torso.CFrame * CFrame.new(-1, 0.5, 0)).Position
                                local rShoulder = (torso.CFrame * CFrame.new(1, 0.5, 0)).Position
                                local lHip = (torso.CFrame * CFrame.new(-0.5, -1, 0)).Position
                                local rHip = (torso.CFrame * CFrame.new(0.5, -1, 0)).Position
                                local lArmBot = (lArm.CFrame * CFrame.new(0, -1, 0)).Position
                                local rArmBot = (rArm.CFrame * CFrame.new(0, -1, 0)).Position
                                local lLegBot = (lLeg.CFrame * CFrame.new(0, -1, 0)).Position
                                local rLegBot = (rLeg.CFrame * CFrame.new(0, -1, 0)).Position

                                DrawBone(head.Position, neck)
                                DrawBone(neck, pelvis)
                                DrawBone(neck, lShoulder)
                                DrawBone(neck, rShoulder)
                                DrawBone(lShoulder, lArmBot)
                                DrawBone(rShoulder, rArmBot)
                                DrawBone(pelvis, lHip)
                                DrawBone(pelvis, rHip)
                                DrawBone(lHip, lLegBot)
                                DrawBone(rHip, rLegBot)
                            end
                        end
                        for i = boneIndex, 15 do
                            esp.Skeleton[i].Main.Visible = false
                        end
                    else
                        for i = 1, 15 do 
                            esp.Skeleton[i].Main.Visible = false 
                        end
                    end
                end
            end
        end
        if not isVisible then
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.HealthBg.Visible = false
            esp.HealthBar.Visible = false
            esp.Tracer.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Weapon.Visible = false
            esp.HeadCircle.Visible = false
            esp.SnapLine.Visible = false
            esp.State.Visible = false
            esp.HealthText.Visible = false
            for i = 1, 12 do
                esp.Box3D[i].Visible = false
            end
            if esp.ChamsHighlight then
                esp.ChamsHighlight.Enabled = false
            end
            for i = 1, 15 do 
                esp.Skeleton[i].Main.Visible = false
            end
        end
    end
end)

-- НАСТРОЙКИ ГЛАВНОГО МЕНЮ
CombatTab:AddToggle("Bật Aimbot Khóa Góc Nhìn", false, function(state) Config.Aimbot = state end)
CombatTab:AddToggle("Mở Rộng Hitbox Địch (Hình Tròn)", false, function(state) Config.HitboxExpander = state end)
CombatTab:AddSlider("Kích Thước Hitbox", 2, 50, 15, function(value) Config.HitboxSize = value end)
CombatTab:AddDropdown("Chọn Hitbox (Điểm Ngắm)", {"Head", "UpperBody", "LowerBody"}, "Head", function(value) Config.Hitbox = value end)
CombatTab:AddSlider("Độ Mượt (Smoothness)", 1, 100, 50, function(value) Config.Smoothness = value / 100 end)
CombatTab:AddToggle("Kiểm Tra Vật Cản (Wall Check)", false, function(state) Config.WallCheck = state end)
CombatTab:AddToggle("Hiển Thị Tâm Ngắm Ảo (Crosshair)", false, function(state) Config.Crosshair = state end)
CombatTab:AddToggle("Hiển Thị Vòng FOV Giữa Màn Hình", false, function(state) Config.FOV_Visible = state end)
CombatTab:AddSlider("Độ Rộng Vòng FOV", 50, 800, 150, function(value) Config.FOV_Radius = value end)

local colorList = {
    "Xanh Dạ Quang", "Xanh Ngọc", "Đỏ", "Xanh Lá", "Xanh Dương", "Hồng", "Trắng", "Vàng", 
    "Tím", "Cam", "Lục Bảo", "Đỏ Rượu", "Vàng Chanh", "Đen"
}
EspTab:AddDropdown("Đổi Màu Tổng ESP (Khóa Xương Trắng)", colorList, "Xanh Dạ Quang", function(value)
    if value == "Xanh Dạ Quang" then Config.ESP_Color = Color3.fromRGB(100, 255, 100)
    elseif value == "Xanh Ngọc" then Config.ESP_Color = Color3.fromRGB(90, 130, 255)
    elseif value == "Đỏ" then Config.ESP_Color = Color3.fromRGB(255, 50, 50)
    elseif value == "Xanh Lá" then Config.ESP_Color = Color3.fromRGB(50, 255, 50)
    elseif value == "Xanh Dương" then Config.ESP_Color = Color3.fromRGB(50, 150, 255)
    elseif value == "Hồng" then Config.ESP_Color = Color3.fromRGB(255, 100, 200)
    elseif value == "Trắng" then Config.ESP_Color = Color3.fromRGB(255, 255, 255)
    elseif value == "Vàng" then Config.ESP_Color = Color3.fromRGB(255, 255, 50)
    elseif value == "Tím" then Config.ESP_Color = Color3.fromRGB(150, 50, 255)
    elseif value == "Cam" then Config.ESP_Color = Color3.fromRGB(255, 120, 0)
    elseif value == "Lục Bảo" then Config.ESP_Color = Color3.fromRGB(0, 180, 120)
    elseif value == "Đỏ Rượu" then Config.ESP_Color = Color3.fromRGB(130, 0, 30)
    elseif value == "Vàng Chanh" then Config.ESP_Color = Color3.fromRGB(200, 255, 0)
    elseif value == "Đen" then Config.ESP_Color = Color3.fromRGB(0, 0, 0)
    end
end)

EspTab:AddToggle("Khung Box Chuẩn (Có Đổ Bóng)", false, function(state) Config.ESP_Box = state end)
EspTab:AddToggle("Khung Box 3D (Độ Sâu)", false, function(state) Config.ESP_Box3D = state end)
EspTab:AddToggle("ESP Chams Xuyên Tường (Highlight)", false, function(state) Config.ESP_Chams = state end)
EspTab:AddToggle("Thanh Máu Dọc (Health Bar)", false, function(state) Config.ESP_HealthBar = state end)
EspTab:AddToggle("Số Máu Cụ Thể (Health Text)", false, function(state) Config.ESP_HealthText = state end)
EspTab:AddToggle("Vòng Tròn Quanh Đầu (Head Circle)", false, function(state) Config.ESP_HeadCircle = state end)
EspTab:AddToggle("Khung Xương Đổ Bóng (Skeleton)", false, function(state) Config.ESP_Skeleton = state end)
EspTab:AddToggle("Tên Người Chơi (Name)", false, function(state) Config.ESP_Name = state end)
EspTab:AddToggle("Tên Vũ Khí Đang Cầm (Weapon)", false, function(state) Config.ESP_Weapon = state end)
EspTab:AddToggle("Trạng Thái Di Chuyển (State)", false, function(state) Config.ESP_State = state end)
EspTab:AddToggle("Khoảng Cách (Distance)", false, function(state) Config.ESP_Distance = state end)
EspTab:AddToggle("Snap Lines (Kẻ Đến Tâm Màn Hình)", false, function(state) Config.ESP_SnapLines = state end)
EspTab:AddToggle("Tia Chỉ Đường Từ Đỉnh Màn Hình", false, function(state) Config.ESP_Tracer = state end)

--================================================
-- CHẾ ĐỘ CHE QUAY MÀN HÌNH (STREAM SAFE) — VIDEO KHÔNG THẤY ESP / FOV
--================================================
-- Khi quay/chụp màn hình mà KHÔNG muốn người xem thấy ESP, vòng FOV, tâm ngắm ảo,
-- chams... thì bật CHE: mọi cờ HIỂN THỊ được tạm gạt về 0 -> vòng lặp ESP tự ẩn
-- toàn bộ, nhưng MỌI CHỨC NĂNG vẫn chạy bình thường (aimbot / hitbox không hề đụng
-- tới các cờ này). Tắt che là mọi thứ hiện lại ĐÚNG NHƯ TRƯỚC. Kèm:
--   * CỬ CHỈ 3 NGÓN chạm màn hình -> ẩn/hiện ngay (mobile, không cần mở menu)
--   * Phím F8 ẩn/hiện nhanh + TỰ ĐỘNG ẨN khi bấm PrintScreen / F12 (PC)
--   * Tuỳ chọn ẨN LUÔN MENU SCRIPT để video sạch hoàn toàn
local CHE_LUU_CO = {}
local CHE_LAN_CHAM = 0

local CHE_DANH_SACH_CO = {
    "FOV_Visible", "Crosshair",
    "ESP_Box", "ESP_Box3D", "ESP_Chams", "ESP_HealthBar", "ESP_HealthText",
    "ESP_HeadCircle", "ESP_Skeleton", "ESP_Name", "ESP_Weapon", "ESP_State",
    "ESP_Distance", "ESP_SnapLines", "ESP_Tracer",
}

local function TimGuiMenu()
    local ok, gui = pcall(function()
        local g = CoreGui:FindFirstChild("Memaybeo_Ultra")
        if not g then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then g = pg:FindFirstChild("Memaybeo_Ultra") end
        end
        return g
    end)
    if ok then return gui end
    return nil
end

-- BẬT: lưu cờ gốc rồi gạt về 0 (ẩn sạch). TẮT: trả cờ gốc về (hiện lại như cũ)
local function CheBatTat(bat)
    bat = bat and true or false
    if bat == (Config.CheQuayManHinh and true or false) then return end
    if bat then
        CHE_LUU_CO = {}
        for _, ten in ipairs(CHE_DANH_SACH_CO) do
            CHE_LUU_CO[ten] = Config[ten]
            Config[ten] = false
        end
        Config.CheQuayManHinh = true
        if Config.CheAnLuonMenu then
            local gui = TimGuiMenu()
            if gui then gui.Enabled = false end
        end
    else
        for _, ten in ipairs(CHE_DANH_SACH_CO) do
            if CHE_LUU_CO[ten] ~= nil then
                Config[ten] = CHE_LUU_CO[ten]
            end
        end
        CHE_LUU_CO = {}
        Config.CheQuayManHinh = false
        if Config.CheAnLuonMenu then
            local gui = TimGuiMenu()
            if gui then gui.Enabled = true end
        end
    end
end

-- PHÍM PC: PrintScreen / F12 -> tự ẩn 1.5 giây rồi hiện lại; F8 -> bật/tắt nhanh
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local ma = input.KeyCode
    if ma == Enum.KeyCode.F8 then
        CheBatTat(not Config.CheQuayManHinh)
    elseif Config.CheTuDongPhim and (ma == Enum.KeyCode.Printscreen or ma == Enum.KeyCode.F12) then
        CheBatTat(true)
        task.delay(1.5, function()
            CheBatTat(false)
        end)
    end
end)

-- CỬ CHỈ 3 NGÓN (mobile): chạm 3 ngón bất kỳ -> ẩn/hiện ngay (chống nháy 2 lần)
UserInputService.TouchStarted:Connect(function(touches, gameProcessed)
    if gameProcessed then return end
    if #touches >= 3 and Config.CheCuChi3Ngon then
        if os.clock() - CHE_LAN_CHAM < 0.6 then return end
        CHE_LAN_CHAM = os.clock()
        CheBatTat(not Config.CheQuayManHinh)
    end
end)

EspTab:AddToggle("CHE QUAY MÀN HÌNH - Ẩn ESP/FOV Khỏi Video (STREAM SAFE)", false, function(state)
    CheBatTat(state)
end)

EspTab:AddToggle("Tự Ẩn Khi Bấm Phím Chụp (PC: PrintScreen/F12)", true, function(state)
    Config.CheTuDongPhim = state
end)

EspTab:AddToggle("Cử Chỉ 3 Ngón Ẩn/Hiện Nhanh (Mobile)", true, function(state)
    Config.CheCuChi3Ngon = state
end)

EspTab:AddToggle("Ẩn Cả Menu Script Khi Đang Che", false, function(state)
    Config.CheAnLuonMenu = state
    if Config.CheQuayManHinh then
        local gui = TimGuiMenu()
        if gui then gui.Enabled = not state end
    end
end)

local TeleportLocations = {
    ShopQuanAo    = CFrame.new(-1399.57532, 55.0899658, 60.6022339, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    XamMinh       = CFrame.new(-1215.15796, 53.846756, 528.432129, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ShopMatNa     = CFrame.new(-911.044189, 55.1183014, 385.557556, -0.819156051, 0, 0.573571265, 0, 1, 0, -0.573571265, 0, -0.819156051),
    BanDo         = CFrame.new(-832.749634, 54.4836578, 244.624451, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ShopKimCuong  = CFrame.new(-914.180542, 53.4179573, 125.539368, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CatToc        = CFrame.new(-1398.4248, 54.7690468, 551.300537, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    KhachSan      = CFrame.new(-1563.43677, 54.7924957, 152.345276, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ShopXe        = CFrame.new(-1269.9834, 55.4147263, 302.890533, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ShopMuaMu     = CFrame.new(-1840.89563, 54.3209229, 244.288025, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    Bank          = CFrame.new(-1805.74963, 52.4486008, 544.446655, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    MuaUSB        = CFrame.new(-1827.2168, 58.6606369, -13.2649536, 0, 1, 0, 0, 0, 1, 1, 0, 0),
    PhongUSB      = CFrame.new(-1367.70679, 52.4256973, -138.643616, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ShopSung      = CFrame.new(-1461.0011, 61.318985, 317.859375, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

TeleportTab:AddButton("Shop Quần Áo", function() TeleportTo(TeleportLocations.ShopQuanAo) end)
TeleportTab:AddButton("Tiệm Xăm Mình", function() TeleportTo(TeleportLocations.XamMinh) end)
TeleportTab:AddButton("Shop Mặt Nạ", function() TeleportTo(TeleportLocations.ShopMatNa) end)
TeleportTab:AddButton("Khu Bán Đồ", function() TeleportTo(TeleportLocations.BanDo) end)
TeleportTab:AddButton("Shop Kim Cương", function() TeleportTo(TeleportLocations.ShopKimCuong) end)
TeleportTab:AddButton("Tiệm Cắt Tóc", function() TeleportTo(TeleportLocations.CatToc) end)
TeleportTab:AddButton("Khách Sạn", function() TeleportTo(TeleportLocations.KhachSan) end)
TeleportTab:AddButton("Shop Mua Xe", function() TeleportTo(TeleportLocations.ShopXe) end)
TeleportTab:AddButton("Shop Mua Mũ", function() TeleportTo(TeleportLocations.ShopMuaMu) end)
TeleportTab:AddButton("Ngân Hàng (Bank)", function() TeleportTo(TeleportLocations.Bank) end)
TeleportTab:AddButton("Khu Mua USB", function() TeleportTo(TeleportLocations.MuaUSB) end)
TeleportTab:AddButton("Phòng USB", function() TeleportTo(TeleportLocations.PhongUSB) end)
TeleportTab:AddButton("Shop Súng", function() TeleportTo(TeleportLocations.ShopSung) end)


MiscTab:AddToggle("Tự Kích Hoạt Nút (Auto Húp Box — SIÊU TỐC)", false, function(state) Config.AutoGetBox = state end)

MiscTab:AddToggle("Tăng Tốc Di Chuyển (Speed Hack)", false, function(state) 
    Config.Speed = state 
end)


--================================================
-- TAB MISC BỔ SUNG: TOUCH FLING BẠN YÊU CẦU & ANTI FLING
--================================================

MiscTab:AddToggle("Bật Fling (Cứ chạm là bay)", false, function(state) 
    Config.FlingAura = state 
end)

MiscTab:AddToggle("Bật Anti-Fling (Chống bị văng)", false, function(state) 
    Config.AntiFling = state 
end)

--================================================

local FakeLagToggleInstance = MiscTab:AddToggle("Bật Fake Lag (Đóng băng địch Client-side)", false, function(state) 
    if Config.FakeLag ~= state then
        SyncFakeLagState(state)
    end
end)

MiscTab:AddToggle("Hiển thị UI Fake Lag", false, function(state) 
    FakeLagScreen.Enabled = state
end)


--================================================
-- AUTO HÚP BOX SIÊU TỐC — KÍCH HOẠT NHANH NHẤT CÓ THỂ
--================================================
-- * Chạy MỖI KHUNG HÌNH (Heartbeat ~60 lần/s) thay vì mỗi 0.2s như bản cũ
-- * CACHE prompt: quét toàn map mỗi 2s + BẮT ProximityPrompt MỚI ngay khi spawn
--   (DescendantAdded) -> không phải quét lại toàn bộ workspace từng khung hình
-- * HoldDuration = 0 -> prompt kích hoạt LIỀN TAY, không cần giữ nút
-- * Đang trong tầm -> bắn fireproximityprompt liên tục -> hộp lụm tức thì
--================================================
local DANH_SACH_PROMPT = {}
local DANG_QUET_PROMPT = false
local LAN_QUET_SACH = 0

local function QuetToanBoPrompt()
    DANG_QUET_PROMPT = true
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            table.insert(DANH_SACH_PROMPT, obj)
        end
    end
    DANG_QUET_PROMPT = false
end

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") and not DANG_QUET_PROMPT then
        table.insert(DANH_SACH_PROMPT, obj)
    end
end)

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Config.AutoGetBox then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local gio = os.clock()
                if gio - LAN_QUET_SACH >= 2 then
                    LAN_QUET_SACH = gio
                    DANH_SACH_PROMPT = {}
                    QuetToanBoPrompt()
                end
                for i = #DANH_SACH_PROMPT, 1, -1 do
                    local prompt = DANH_SACH_PROMPT[i]
                    local cha = prompt and prompt.Parent
                    if not prompt or not cha or not cha:IsA("BasePart") or prompt.Enabled == false then
                        table.remove(DANH_SACH_PROMPT, i)
                    elseif (cha.Position - hrp.Position).Magnitude <= prompt.MaxActivationDistance then
                        prompt.HoldDuration = 0
                        fireproximityprompt(prompt)
                    end
                end
            end)
        end
    end
end)

--================================================
-- LÔGIC INVISIBLE TOUCH FLING CHÍNH XÁC NHƯ BẠN MUỐN
--================================================
task.spawn(function()
    local v21 = 0.1
    while true do
        RunService.Heartbeat:Wait()
        if Config.FlingAura then
            local v19 = LocalPlayer.Character
            local v20 = v19 and (v19:FindFirstChild('HumanoidRootPart') or v19:FindFirstChild('Torso') or v19:FindFirstChild('UpperTorso'))
            
            if v20 then
                local _Velocity = v20.Velocity
                
                -- Tạo vận tốc ảo khổng lồ để hất văng bất cứ ai chạm vào
                v20.Velocity = _Velocity * 10000 + Vector3.new(0, 10000, 0)
                
                RunService.RenderStepped:Wait()
                if v20 and v20.Parent then
                    -- Reset lại vận tốc ngay trước khi game kịp render để bạn không bị bay đi
                    v20.Velocity = _Velocity
                end
                
                RunService.Stepped:Wait()
                if v20 and v20.Parent then
                    -- Duy trì một mô-men nhỏ để qua mặt hệ thống chống hack
                    v20.Velocity = _Velocity + Vector3.new(0, v21, 0)
                    v21 = v21 * -1
                end
            end
        end
    end
end)

--================================================
-- LÔGIC ANTI-FLING TUYỆT ĐỐI BẢO VỆ BẠN
--================================================
RunService.Stepped:Connect(function()
    if Config.AntiFling and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        -- 1. Biến tất cả người chơi khác thành "bóng ma" để họ đi xuyên qua bạn (Chống đâm)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        
        -- 2. Dừng khẩn cấp nếu nhân vật tự nhiên bị văng với lực lạ
        -- CHÚ Ý: Tính năng này chỉ hoạt động khi bạn ĐANG TẮT FLING, vì Fling cần vận tốc ảo để hoạt động
        if hrp and not Config.FlingAura then
            if hrp.Velocity.Magnitude > 250 or hrp.RotVelocity.Magnitude > 250 then
                hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

--================================================================
-- PHẦN BỔ SUNG MỚI - GIỮ NGUYÊN 100% CHỨC NĂNG GỐC, CHỈ THÊM:
--   1. SPINBOT V4 (xoay nhân vật, chống khóa hướng khi cầm súng)
--   2. ĐỔI MÀU ĐẠN (neon, mặc định ĐỎ, 8 màu chọn được)
--   3. KHỐI ĐẠN TO HƠN (slider chỉnh lần kích thước)
--   4. HIỆU ỨNG PHÁT SÁNG ĐẸP (neon glow + đèn cho đạn)
--   5. SKIN SÚNG VIP (16 skin + hạt bọc súng + GLOW/TRAIL/PULSE)
--   6. VÔ HẠN ĐẠN (thử nghiệm - ăn nếu game giữ đạn phía client)
--   7. THU NHỎ MENU (620x480 -> 520x400)
--================================================================

local ExtraConfig = {
    Spinbot          = false,                      -- BẬT/TẮT SPINBOT
    SpinbotAngular   = false,                      -- Thêm lực xoay vật lý (nếu vẫn bị khóa hướng)
    BulletColor      = false,                      -- BẬT/TẮT ĐỔI MÀU ĐẠN
    BulletColorValue = Color3.fromRGB(255, 0, 0),  -- Màu đạn: ĐỎ
    BulletBig        = false,                      -- BẬT/TẮT ĐẠN TO HƠN
    BulletScale      = 6,                          -- Đạn to gấp mấy lần
    BulletGlow       = false,                      -- BẬT/TẮT HIỆU ỨNG PHÁT SÁNG
    GunSkin          = false,                      -- BẬT/TẮT SKIN SÚNG VIP
    GunSkinName      = "Vàng Gold",                -- Skin đang chọn (16 loại)
    SkinVien         = true,                       -- Viền sáng Outline bao quanh súng (VER 9)
    SkinSongMau      = true,                       -- Sóng màu chảy trên thân súng (VER 9)
    SkinPhong        = true,                       -- VER 9: PHONG CÁCH RIÊNG theo từng skin (tắt để tăng FPS)
    GunSkinRainbow   = false,                      -- Đang ở skin Cầu Vòng?
    SkinGlow         = false,                      -- GLOW: ánh sáng tỏa quanh súng
    SkinTrail        = false,                      -- TRAIL: vệt sáng khi vung súng
    SkinPulse        = false,                      -- PULSE: súng phồng xẹp theo nhịp
    SkinParticle     = "TẮT",                      -- Hạt bọc súng: TẮT/SAO/LỬA/BỤI VÀNG/TÍM
    SkinTocDo        = 1,                          -- Tốc độ quay cầu vòng
    SkinVong         = true,                       -- VÒNG GYROSCOPE + HELIX quanh súng
    RongScale        = 1.2                         -- Kích thước Rồng Thiên Long VER 3
}

--================================================
-- 1) SPINBOT V4: XOAY NHÂN VẬT TỐC ĐỘ CAO
--================================================

MiscTab:AddToggle("Bật Spinbot (Xoay Người Tốc Độ Cao)", false, function(state)
    ExtraConfig.Spinbot = state
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = not state
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if ExtraConfig.Spinbot then
        hum.AutoRotate = false
    end
end)

-- Tốc độ xoay từng tầng (độ/frame) - chỉnh thoải mái
local SPIN_STEPPED   = 38
local SPIN_HEARTBEAT = 22
local SPIN_RENDER    = 15
local SPIN_MOTOR     = 25

-- Tìm khớp gốc nối HumanoidRootPart với thân người (R15: Root | R6: RootJoint)
local function GetRootMotor(char)
    if not char then return nil end
    local lowerTorso = char:FindFirstChild("LowerTorso")
    if lowerTorso then
        local m = lowerTorso:FindFirstChild("Root")
        if m and m:IsA("Motor6D") then return m end
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local m = hrp:FindFirstChild("RootJoint")
        if m and m:IsA("Motor6D") then return m end
    end
    return nil
end

-- TIÊU DIỆT lực khóa hướng: quét HRP + Thân + Súng đang cầm
local function KillLockForces(char)
    local hrp   = char and char:FindFirstChild("HumanoidRootPart")
    local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
    local tool  = char and char:FindFirstChildOfClass("Tool")
    for _, container in ipairs({hrp, torso, tool}) do
        if container then
            for _, obj in ipairs(container:GetChildren()) do
                if obj:IsA("BodyGyro") or obj:IsA("BodyAngularVelocity") then
                    obj:Destroy()
                elseif obj:IsA("AlignOrientation") then
                    obj.Enabled = false
                end
            end
        end
    end
end

local function SpinbotActive()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    return ExtraConfig.Spinbot and hrp and hum and hum.Health > 0 and not hum.Sit, hrp, hum, char
end

-- TẦNG 1: HEARTBEAT - xoay ngay SAU bước vật lý (thắng script súng reset hướng)
RunService.Heartbeat:Connect(function()
    local active, hrp = SpinbotActive()
    if active then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SPIN_HEARTBEAT), 0)
    end
end)

-- TẦNG 2: STEPPED - xoay TRƯỚC bước vật lý + tiêu diệt lực khóa hướng
RunService.Stepped:Connect(function()
    local active, hrp, hum, char = SpinbotActive()
    if active then
        if hum.AutoRotate then hum.AutoRotate = false end
        KillLockForces(char)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SPIN_STEPPED), 0)
        if ExtraConfig.SpinbotAngular then
            hrp.AssemblyAngularVelocity = Vector3.new(0, 55, 0)
        end
    end
end)

-- TẦNG 3: RENDERSTEP ưu tiên 7000 - xoay CUỐI CÙNG trước khi vẽ hình
pcall(function() RunService:UnbindFromRenderStep("SpinbotRender") end)
RunService:BindToRenderStep("SpinbotRender", Enum.RenderPriority.Last.Value + 5000, function()
    local active, hrp, hum, char = SpinbotActive()
    if active then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SPIN_RENDER), 0)
        -- Xoay thêm khớp gốc thân: thắng game neo THÂN NGƯỜI theo camera khi cầm súng
        local motor = GetRootMotor(char)
        if motor then
            motor.Transform = motor.Transform * CFrame.Angles(0, math.rad(SPIN_MOTOR), 0)
        end
    end
end)

--================================================
-- 2+3+4) ĐẠN ĐẸP: ĐỔI MÀU + ĐẠN TO + HIỆU ỨNG PHÁT SÁNG
--================================================

local BulletColors = {
    ["Đỏ"]    = Color3.fromRGB(255, 0, 0),
    ["Cam"]   = Color3.fromRGB(255, 130, 0),
    ["Vàng"]  = Color3.fromRGB(255, 255, 0),
    ["Lục"]   = Color3.fromRGB(0, 255, 60),
    ["Lam"]   = Color3.fromRGB(0, 150, 255),
    ["Tím"]   = Color3.fromRGB(170, 0, 255),
    ["Hồng"]  = Color3.fromRGB(255, 70, 180),
    ["Trắng"] = Color3.fromRGB(255, 255, 255)
}

local function IsBulletName(name)
    name = name:lower()
    return name:find("bullet") ~= nil or name:find("visual") ~= nil
end

-- Xử lý 1 object đạn/hiệu ứng mới xuất hiện
local function HandleNewBullet(obj)
    -- Đạn dạng vệt tia / tia sáng / hạt
    if obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("ParticleEmitter") then
        if ExtraConfig.BulletColor then
            obj.Color = ColorSequence.new(ExtraConfig.BulletColorValue)
        end
        if ExtraConfig.BulletGlow then
            pcall(function()
                obj.LightEmission = 1
                obj.LightInfluence = 0
            end)
        end
    elseif obj:IsA("BasePart") and IsBulletName(obj.Name) then
        -- Đạn dạng khối tròn/sợi
        if ExtraConfig.BulletColor then
            obj.Color = ExtraConfig.BulletColorValue
            obj.Material = Enum.Material.Neon
        end
        if ExtraConfig.BulletBig then
            local s = obj.Size
            local k = ExtraConfig.BulletScale
            obj.Size = Vector3.new(
                math.clamp(s.X * k, 0.05, 200),
                math.clamp(s.Y * k, 0.05, 200),
                math.clamp(s.Z * k, 0.05, 200)
            )
        end
        if ExtraConfig.BulletGlow then
            if not obj:FindFirstChildOfClass("PointLight") then
                local light = Instance.new("PointLight")
                light.Color = ExtraConfig.BulletColorValue
                light.Brightness = 3
                light.Range = 14
                light.Parent = obj
            end
        end
        -- Bắt luôn vệt/hạt con sinh ra sau part đạn
        obj.ChildAdded:Connect(function(child)
            pcall(HandleNewBullet, child)
        end)
    end
end

-- Tô lại đạn/hiệu ứng đã có sẵn khi vừa bật hoặc đổi màu
local function RescanBullets()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            HandleNewBullet(obj)
        end
    end)
end

workspace.DescendantAdded:Connect(function(obj)
    if ExtraConfig.BulletColor or ExtraConfig.BulletGlow or ExtraConfig.BulletBig then
        pcall(HandleNewBullet, obj)
    end
end)

MiscTab:AddToggle("Bật Đổi Màu Đạn (Hiệu Ứng Màu)", false, function(state)
    ExtraConfig.BulletColor = state
    if state then RescanBullets() end
end)

MiscTab:AddDropdown("Chọn Màu Đạn", {"Đỏ", "Cam", "Vàng", "Lục", "Lam", "Tím", "Hồng", "Trắng"}, "Đỏ", function(choice)
    ExtraConfig.BulletColorValue = BulletColors[choice] or BulletColors["Đỏ"]
    if ExtraConfig.BulletColor then RescanBullets() end
end)

MiscTab:AddToggle("Khối Đạn To Hơn (Đạn Lớn Xấu Ác)", false, function(state)
    ExtraConfig.BulletBig = state
    if state then RescanBullets() end
end)

MiscTab:AddSlider("Độ To Của Đạn (Lần Kích Thước)", 1, 20, 6, function(v)
    ExtraConfig.BulletScale = v
end)

MiscTab:AddToggle("Hiệu Ứng Phát Sáng Đẹp (Neon Glow)", false, function(state)
    ExtraConfig.BulletGlow = state
    if state then RescanBullets() end
end)

--================================================
-- 5) SKIN SÚNG VIP + HIỆU ỨNG (VER 9 - 38 SKIN MỖI SKIN MỘT PHONG CÁCH)
--    NÂNG CẤP VER 9 (SIÊU CHI TIẾT):
--    * RỒNG THIÊN LONG VER 4 (~100 part chi tiết): 16 đốt thân + 11 gai lưng
--                    + 11 vảy bụng; ĐẦU RỒNG FULL MẶT (sọ/trán/mõm/mũi/hàm/
--                    2 nanh + 2 răng/hốc mắt + ngươi sáng/gai lông mày/2 sừng
--                    3 đốt/2 sừng phụ/mào 7 lá/2 râu 2 đốt/vây mang);
--                    2 CÁNH MÀNG phe phẩy + 4 CHÂN đu đưa + đuôi 5 lá
--    * PHONG CÁCH RIÊNG THEO SKIN (15 bộ hiệu ứng + dán ảnh thật): máu chảy / dung nham nứt /
--                    tinh thể băng / kim loại loang ánh / tia sét giật /
--                    thánh quang / thiên hà / cầu vồng 7 sắc / kẹo pastel /
--                    mặt trời / mưa rừng / bão cát / sóng biển / bong bóng độc
--    * CẤT SÚNG    : RỒNG + AURA + VÒNG + PHONG CÁCH + VIỀN... BIẾN MẤT NGAY,
--                    rút súng lại -> tự hồi đầy đủ
--    * 3 TÔNG MÀU  : màu CHÍNH + màu NHẤN + VÂN TỐI -> súng có đường vân panel
--    * VÒNG GYROSCOPE + AURA TRAIL + HIỆU ỨNG KÉP + SÓNG MÀU + VIỀN SÁNG
--    Phủ TOÀN BỘ part thân súng + viewmodel góc nhìn thứ nhất
--    100% LOCAL - chỉ đổi hình ảnh trên máy mình -> KHÔNG KICK
--================================================

local KHO_SKIN = {
    -- ===== 16 SKIN GỐC — NÂNG CẤP 2 TÔNG MÀU + HIỆU ỨNG RIÊNG =====
    ["Máu Đỏ Blood"] = { phongCach = "mau",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(255, 20, 45), mauPhu = Color3.fromRGB(150, 0, 25), hat = "LỬA", hatMau = Color3.fromRGB(255, 60, 60), glow = true, trail = true, aura = true },
    ["Hồng Neon"] = { phongCach = "candy",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(255, 55, 170), mauPhu = Color3.fromRGB(255, 140, 215), hat = "TÍM", hatMau = Color3.fromRGB(255, 110, 200), glow = true, trail = true, aura = true },
    ["Cam Solar"] = { phongCach = "matroi",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(255, 125, 0), mauPhu = Color3.fromRGB(255, 200, 70), hat = "LỬA", hatMau = Color3.fromRGB(255, 170, 40), glow = true, trail = true, aura = true },
    ["Vàng Gold"] = { phongCach = "kim",  vatlieu = Enum.Material.Metal, mausac = Color3.fromRGB(255, 200, 35), mauPhu = Color3.fromRGB(190, 140, 10), phanChieu = 0.45, hat = "BỤI VÀNG", glow = true, trail = true, aura = true },
    ["Xanh Mint"] = { phongCach = "nuoc",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(0, 255, 155), mauPhu = Color3.fromRGB(0, 185, 120), hat = "SAO", hatMau = Color3.fromRGB(140, 255, 200), glow = true, trail = true },
    ["Xanh Electric"] = { phongCach = "electric",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(0, 155, 255), mauPhu = Color3.fromRGB(130, 220, 255), hat = "SÉT", hatMau = Color3.fromRGB(180, 240, 255), glow = true, trail = true, aura = true },
    ["Tím Galaxy"] = { phongCach = "galaxy",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(140, 60, 255), mauPhu = Color3.fromRGB(80, 0, 170), hat = "TÍM", hatMau = Color3.fromRGB(200, 130, 255), glow = true, trail = true, aura = true },
    ["Trắng Ngọc"] = { phongCach = "kim",  vatlieu = Enum.Material.ForceField, mausac = Color3.fromRGB(235, 245, 255), mauPhu = Color3.fromRGB(200, 225, 255), hat = "SAO", hatMau = Color3.fromRGB(255, 255, 255), glow = true },
    ["Cầu Vòng 7 Màu"] = { phongCach = "rainbow",  vatlieu = Enum.Material.Neon, rainbow = true, hat = "SAO", trail = true, aura = true },
    ["Holy White"] = { phongCach = "holy",  vatlieu = Enum.Material.ForceField, mausac = Color3.fromRGB(255, 255, 255), mauPhu = Color3.fromRGB(180, 215, 255), hat = "SAO", hatMau = Color3.fromRGB(255, 250, 220), glow = true, trail = true, aura = true },
    ["Holy Tím"] = { phongCach = "holy",  vatlieu = Enum.Material.ForceField, mausac = Color3.fromRGB(150, 80, 255), mauPhu = Color3.fromRGB(210, 170, 255), hat = "TÍM", hatMau = Color3.fromRGB(220, 180, 255), glow = true, trail = true, aura = true },
    ["Pha Lê Băng"] = { phongCach = "bang",  vatlieu = Enum.Material.Glass, mausac = Color3.fromRGB(95, 220, 255), trongSuot = 0.28, phanChieu = 0.3, mauPhu = Color3.fromRGB(200, 245, 255), hat = "BĂNG", glow = true, trail = true, aura = true },
    ["Vàng Kim Cương"] = { phongCach = "kim",  vatlieu = Enum.Material.Metal, mausac = Color3.fromRGB(255, 210, 55), phanChieu = 0.6, mauPhu = Color3.fromRGB(255, 245, 160), hat = "BỤI VÀNG", hatMau = Color3.fromRGB(255, 240, 130), glow = true, trail = true, aura = true },
    ["Thép Galvanized"] = { phongCach = "kim",  vatlieu = Enum.Material.DiamondPlate, mausac = Color3.fromRGB(185, 195, 210), mauPhu = Color3.fromRGB(110, 120, 135), hat = "BỤI VÀNG", hatMau = Color3.fromRGB(220, 230, 240), trail = true },
    ["Xanh Độc Toxic"] = { phongCach = "toxic",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(75, 255, 40), mauPhu = Color3.fromRGB(25, 140, 10), hat = "LỬA", hatMau = Color3.fromRGB(120, 255, 60), glow = true, trail = true, aura = true },
    ["Lava Địa Ngục"] = { phongCach = "lava",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(255, 60, 0), mauPhu = Color3.fromRGB(120, 10, 0), hat = "LỬA", hatMau = Color3.fromRGB(255, 120, 20), glow = true, trail = true, aura = true },
    -- ===== 16 SKIN CAO CẤP — HIỆU ỨNG KÉP (HẠT CHÍNH + HẠT PHỤ) =====
    ["Bão Băng Tuyết"] = { phongCach = "bang",  vatlieu = Enum.Material.Glass, mausac = Color3.fromRGB(145, 228, 255), trongSuot = 0.25, phanChieu = 0.25, mauPhu = Color3.fromRGB(235, 250, 255), hat = "BĂNG", hat2 = "SAO", glow = true, trail = true, aura = true },
    ["Sét Thiên Thần"] = { phongCach = "electric",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(255, 248, 130), mauPhu = Color3.fromRGB(255, 255, 235), hat = "SÉT", hat2 = "SAO", glow = true, trail = true, aura = true },
    ["Huyết Nguyệt"] = { phongCach = "mau",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(175, 0, 35), mauPhu = Color3.fromRGB(255, 45, 75), hat = "LỬA", hatMau = Color3.fromRGB(255, 40, 60), hat2 = "TÍM", hat2Mau = Color3.fromRGB(255, 60, 120), glow = true, trail = true, aura = true },
    ["Bầu Trời Sao Rơi"] = { phongCach = "galaxy",  vatlieu = Enum.Material.ForceField, mausac = Color3.fromRGB(85, 115, 255), mauPhu = Color3.fromRGB(170, 200, 255), hat = "SAO", hatMau = Color3.fromRGB(190, 210, 255), hat2 = "SÉT", hat2Mau = Color3.fromRGB(255, 255, 200), glow = true, trail = true, aura = true },
    ["Ánh Trăng Bạc"] = { phongCach = "kim",  vatlieu = Enum.Material.Metal, mausac = Color3.fromRGB(212, 226, 245), phanChieu = 0.5, mauPhu = Color3.fromRGB(255, 255, 255), hat = "SAO", hatMau = Color3.fromRGB(240, 248, 255), hat2 = "BỤI VÀNG", hat2Mau = Color3.fromRGB(200, 220, 255), glow = true, trail = true, aura = true },
    ["Rừng Mưa Nhiệt Đới"] = { phongCach = "muarung",  vatlieu = Enum.Material.SmoothPlastic, mausac = Color3.fromRGB(35, 195, 85), mauPhu = Color3.fromRGB(0, 115, 50), hat = "SAO", hatMau = Color3.fromRGB(120, 255, 150), hat2 = "BỤI VÀNG", hat2Mau = Color3.fromRGB(60, 200, 110), glow = true, trail = true },
    ["Bão Cát Sa Mạc"] = { phongCach = "cat",  vatlieu = Enum.Material.Slate, mausac = Color3.fromRGB(218, 185, 115), mauPhu = Color3.fromRGB(150, 120, 65), hat = "BỤI VÀNG", hat2 = "SAO", hat2Mau = Color3.fromRGB(255, 230, 160), glow = true, trail = true },
    ["Tím Neon Nhiệt Đới"] = { phongCach = "candy",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(205, 65, 255), mauPhu = Color3.fromRGB(255, 150, 250), hat = "TÍM", hat2 = "SÉT", hat2Mau = Color3.fromRGB(255, 180, 255), glow = true, trail = true, aura = true },
    ["Chaos Núi Lửa Đen"] = { phongCach = "lava",  vatlieu = Enum.Material.Slate, mausac = Color3.fromRGB(30, 26, 30), mauPhu = Color3.fromRGB(90, 20, 15), hat = "LỬA", hatMau = Color3.fromRGB(255, 90, 20), hat2 = "BỤI VÀNG", hat2Mau = Color3.fromRGB(120, 60, 30), glow = true, trail = true, aura = true },
    ["Kẹo Bông Ngọt Ngào"] = { phongCach = "candy",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(255, 145, 205), mauPhu = Color3.fromRGB(255, 230, 245), hat = "SAO", hatMau = Color3.fromRGB(255, 180, 220), hat2 = "SAO", hat2Mau = Color3.fromRGB(255, 255, 255), glow = true, trail = true, aura = true },
    ["Pha Lê Vũ Trụ"] = { phongCach = "galaxy",  vatlieu = Enum.Material.Glass, mausac = Color3.fromRGB(135, 70, 225), trongSuot = 0.27, phanChieu = 0.25, mauPhu = Color3.fromRGB(60, 20, 130), hat = "TÍM", hat2 = "SAO", hat2Mau = Color3.fromRGB(255, 255, 255), glow = true, trail = true, aura = true },
    ["Kính Bạc Lấp Lánh"] = { phongCach = "kim",  vatlieu = Enum.Material.Glass, mausac = Color3.fromRGB(222, 232, 242), trongSuot = 0.2, phanChieu = 0.7, mauPhu = Color3.fromRGB(255, 255, 255), hat = "SAO", hatMau = Color3.fromRGB(255, 255, 255), glow = true, trail = true, aura = true },
    ["Nọc Rắn Vàng Lục"] = { phongCach = "toxic",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(148, 255, 40), mauPhu = Color3.fromRGB(40, 150, 15), hat = "SÉT", hatMau = Color3.fromRGB(200, 255, 80), hat2 = "LỬA", hat2Mau = Color3.fromRGB(120, 255, 50), glow = true, trail = true, aura = true },
    ["Hải Vương Xanh Đậm"] = { phongCach = "nuoc",  vatlieu = Enum.Material.ForceField, mausac = Color3.fromRGB(20, 90, 235), mauPhu = Color3.fromRGB(80, 170, 255), hat = "BĂNG", hatMau = Color3.fromRGB(80, 170, 255), hat2 = "SAO", hat2Mau = Color3.fromRGB(180, 220, 255), glow = true, trail = true, aura = true },
    ["Cương Huyết Tím Đẫm"] = { phongCach = "mau",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(125, 10, 65), mauPhu = Color3.fromRGB(255, 60, 140), hat = "LỬA", hatMau = Color3.fromRGB(255, 60, 140), hat2 = "TÍM", hat2Mau = Color3.fromRGB(220, 90, 255), glow = true, trail = true, aura = true },
    ["Ánh Sáng Thiêng Liêng"] = { phongCach = "holy",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(255, 244, 200), mauPhu = Color3.fromRGB(255, 255, 255), hat = "SAO", hatMau = Color3.fromRGB(255, 240, 160), hat2 = "SÉT", hat2Mau = Color3.fromRGB(255, 255, 230), glow = true, trail = true, aura = true },
    -- ===== 6 SKIN RỒNG — RỒNG 3D VER 2 + AURA + HIỆU ỨNG KÉP, ĐẲNG CẤP NHẤT =====
    ["Rồng Lửa Đỏ"] = { phongCach = "rong",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(255, 55, 0), mauPhu = Color3.fromRGB(255, 150, 30), hat = "LỬA", hatMau = Color3.fromRGB(255, 90, 30), hat2 = "SAO", hat2Mau = Color3.fromRGB(255, 180, 80), glow = true, trail = true, aura = true, rong = true },
    ["Rồng Băng Lam"] = { phongCach = "rong",  vatlieu = Enum.Material.Glass, mausac = Color3.fromRGB(90, 205, 255), trongSuot = 0.24, phanChieu = 0.25, mauPhu = Color3.fromRGB(215, 245, 255), hat = "BĂNG", hatMau = Color3.fromRGB(120, 220, 255), hat2 = "SAO", hat2Mau = Color3.fromRGB(220, 245, 255), glow = true, trail = true, aura = true, rong = true },
    ["Rồng Vàng Hoàng Gia"] = { phongCach = "rong",  vatlieu = Enum.Material.Metal, mausac = Color3.fromRGB(255, 198, 40), phanChieu = 0.55, mauPhu = Color3.fromRGB(255, 240, 120), hat = "BỤI VÀNG", hatMau = Color3.fromRGB(255, 220, 90), hat2 = "SAO", hat2Mau = Color3.fromRGB(255, 245, 170), glow = true, trail = true, aura = true, rong = true },
    ["Rồng Tím Thần Bí"] = { phongCach = "rong",  vatlieu = Enum.Material.Neon, mausac = Color3.fromRGB(162, 42, 255), mauPhu = Color3.fromRGB(235, 140, 255), hat = "TÍM", hatMau = Color3.fromRGB(190, 90, 255), hat2 = "SAO", hat2Mau = Color3.fromRGB(230, 170, 255), glow = true, trail = true, aura = true, rong = true },
    ["Hắc Long Đen Vực"] = { phongCach = "rong",  vatlieu = Enum.Material.Slate, mausac = Color3.fromRGB(28, 24, 30), mauPhu = Color3.fromRGB(90, 15, 20), hat = "LỬA", hatMau = Color3.fromRGB(255, 40, 30), hat2 = "SÉT", hat2Mau = Color3.fromRGB(255, 90, 60), matMau = Color3.fromRGB(255, 50, 40), glow = true, trail = true, aura = true, rong = true },
    ["Rồng Ngọc Bảo Xanh"] = { phongCach = "rong",  vatlieu = Enum.Material.Glass, mausac = Color3.fromRGB(0, 232, 142), trongSuot = 0.22, phanChieu = 0.3, mauPhu = Color3.fromRGB(130, 255, 205), hat = "SAO", hatMau = Color3.fromRGB(60, 255, 170), hat2 = "BĂNG", hat2Mau = Color3.fromRGB(170, 255, 230), glow = true, trail = true, aura = true, rong = true },
    -- ===== SKIN ĐẶC BIỆT VER 10 — HELLO KITTY: DÁN ẢNH THẬT LÊN SÚNG (skin.anh) + HIỆU ỨNG RIÊNG =====
    ["Hello Kitty Pink"] = { phongCach = "hellokitty",  vatlieu = Enum.Material.SmoothPlastic, mausac = Color3.fromRGB(255, 208, 228), mauPhu = Color3.fromRGB(255, 82, 165), anh = "rbxassetid://113401407955058", anhCo = 1.6, hat = "SAO", hatMau = Color3.fromRGB(255, 150, 205), hat2 = "SAO", hat2Mau = Color3.fromRGB(255, 255, 255), glow = true, trail = true, aura = true },
}

-- VER 5: tự sinh màu TỐI (vân panel sẫm) từ màu chính từng skin
-- -> mỗi skin có 3 tông màu có chiều sâu: chính / nhấn / vân tối
for _, sk in pairs(KHO_SKIN) do
    local gocMau = sk.mausac or Color3.fromRGB(255, 255, 255)
    sk.mauToi = gocMau:Lerp(Color3.fromRGB(10, 10, 14), 0.42)
end

-- Texture hạt dùng file CÓ SẴN trong Roblox (rbxasset://) nên không bao giờ lỗi ảnh
-- VER 4: hạt TO HƠN + ĐẬM HƠN + bay nhanh hơn bản cũ
local KHO_HAT = {
    ["SAO"]      = { texture = "rbxasset://textures/particles/sparkles_main.dds", mau = Color3.fromRGB(170, 225, 255), kichThuoc = 0.30, tocDo = 2.4, tuoiTho = 0.9,  tiLe = 22 },
    ["LỬA"]      = { texture = "rbxasset://textures/particles/fire_main.dds",     mau = Color3.fromRGB(255, 130, 30),  kichThuoc = 0.45, tocDo = 3.4, tuoiTho = 0.7,  tiLe = 30 },
    ["BỤI VÀNG"] = { texture = "rbxasset://textures/particles/smoke_main.dds",    mau = Color3.fromRGB(255, 205, 70),  kichThuoc = 0.24, tocDo = 1.4, tuoiTho = 1.3,  tiLe = 16 },
    ["TÍM"]      = { texture = "rbxasset://textures/particles/sparkles_main.dds", mau = Color3.fromRGB(195, 85, 255),  kichThuoc = 0.34, tocDo = 1.8, tuoiTho = 1.0,  tiLe = 18 },
    ["BĂNG"]     = { texture = "rbxasset://textures/particles/sparkles_main.dds", mau = Color3.fromRGB(150, 240, 255), kichThuoc = 0.26, tocDo = 1.6, tuoiTho = 1.3,  tiLe = 24 },
    ["SÉT"]      = { texture = "rbxasset://textures/particles/sparkles_main.dds", mau = Color3.fromRGB(255, 255, 130), kichThuoc = 0.22, tocDo = 4.5, tuoiTho = 0.45, tiLe = 34 },
}

-- ===== RỒNG THIÊN LONG VER 4 — SIÊU CHI TIẾT =====
-- NÂNG CẤP LỚN so với VER 3 (bị chê thiếu chi tiết):
-- * 16 đốt thân cầu tròn + 11 GAI LƯNG vàng + 11 VẢY BỤNG sáng xếp lớp dọc sống/bụng
-- * ĐẦU RỒNG FULL CHI TIẾT: sọ + 2 gờ trán + mõm + chóp mũi + hàm dưới
--   + 2 NANH TRÊN + 2 RĂNG DƯỚI + 2 HỐC MẮT + 2 NGƯƠI SÁNG + 2 GAI LÔNG MÀY
--   + 2 SỪNG CHÍNH 3 ĐỐT CONG + 2 SỪNG PHỤ + MÀO 7 LÁ + 2 RÂU 2 ĐỐT + 2 VÂY MANG
-- * 2 CÁNH MÀNG xòe PHE PHẨY theo nhịp bơi (khớp + màng wedge + chóp sáng)
-- * 4 CHÂN (2 trước bám đốt 4, 2 sau bám đốt 9) có đùi + bàn chân, đu đưa theo sóng
-- * ĐUÔI 5 LÁ quạt xòe + 2 gai đuôi + chóp cầu lấp lánh
-- * HƠI THỞ nguyên tố phun từ mõm + lấp lánh đầu/đuôi + đèn glowing theo đầu
local DANH_SACH_RONG = {}

local function XoaRong(handle)
    local rong = DANH_SACH_RONG[handle]
    if rong then
        for _, obj in ipairs(rong.phan) do
            pcall(function() obj:Destroy() end)
        end
        DANH_SACH_RONG[handle] = nil
    end
end

local function TaoRong(handle, skin)
    XoaRong(handle)
    if not handle or not handle.Parent then return end
    local mau = skin.mausac or Color3.fromRGB(255, 60, 0)
    local mauPhu = skin.mauPhu or mau
    local mauVang = Color3.fromRGB(255, 215, 70)
    local mauMat = skin.matMau or mauVang
    local mauToi = skin.mauToi or mau:Lerp(Color3.fromRGB(10, 10, 14), 0.42)
    local mauVay = mau:Lerp(Color3.fromRGB(255, 255, 255), 0.35)
    local mauRang = Color3.fromRGB(245, 245, 235)
    local sc = ExtraConfig.RongScale or 1.2
    local u = sc * 2
    local danhSach = {}

    local function gop(p)
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.CastShadow = false
        p.Parent = workspace
        table.insert(danhSach, p)
        return p
    end

    local function taoCau(ten, kichThuoc, mauP, vatLieu, trongSuot)
        local p = Instance.new("Part")
        p.Name = ten
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(kichThuoc, kichThuoc, kichThuoc)
        p.Material = vatLieu or Enum.Material.Neon
        p.Color = mauP
        if trongSuot then p.Transparency = trongSuot end
        return gop(p)
    end

    local function taoLap(ten, kichThuoc, mauP, vatLieu, trongSuot)
        local p = Instance.new("Part")
        p.Name = ten
        p.Size = kichThuoc
        p.Material = vatLieu or Enum.Material.Neon
        p.Color = mauP
        if trongSuot then p.Transparency = trongSuot end
        return gop(p)
    end

    local function taoTru(ten, cao, duongKinh, mauP, trongSuot)
        local p = Instance.new("Part")
        p.Name = ten
        p.Shape = Enum.PartType.Cylinder
        p.Size = Vector3.new(cao, duongKinh, duongKinh)
        p.Material = Enum.Material.Neon
        p.Color = mauP
        if trongSuot then p.Transparency = trongSuot end
        return gop(p)
    end

    local function taoWedge(ten, kichThuoc, mauP, trongSuot, vatLieu)
        local p = Instance.new("WedgePart")
        p.Name = ten
        p.Size = kichThuoc
        p.Material = vatLieu or Enum.Material.Neon
        p.Color = mauP
        if trongSuot then p.Transparency = trongSuot end
        return gop(p)
    end

    -- 16 đốt thân: nhỏ đầu -> to giữa -> nhỏ dần về đuôi, màu chảy dần
    local day = {0.14, 0.18, 0.215, 0.235, 0.245, 0.25, 0.248, 0.24, 0.226, 0.206, 0.184, 0.16, 0.136, 0.112, 0.092, 0.075}
    local rong = { phan = danhSach, than = {}, gai = {}, vayBung = {}, mao = {}, duoi = {}, chan = {}, canh = {}, scale = sc, day = day }

    for i = 1, 16 do
        local tyLe = (i - 1) / 15
        rong.than[i] = taoCau("SG_R4_Than" .. i, day[i] * u, mau:Lerp(mauPhu, tyLe))
    end

    -- 11 GAI LƯNG vàng (bám đốt 3..13) + 11 VẢY BỤNG sáng hơn (bám dưới đốt 3..13)
    for i = 1, 11 do
        rong.gai[i] = taoLap("SG_R4_Gai" .. i, Vector3.new(0.024, (0.14 - i * 0.006) * u, 0.095) * u, mauVang)
        rong.vayBung[i] = taoCau("SG_R4_VayBung" .. i, 0.085 * u, mauVay)
    end

    -- ===== ĐẦU RỒNG FULL CHI TIẾT =====
    rong.dau      = taoCau("SG_R4_Dau",    0.30 * u, mau)
    rong.tran1    = taoCau("SG_R4_Tran1",  0.07 * u, mauPhu)
    rong.tran2    = taoCau("SG_R4_Tran2",  0.07 * u, mauPhu)
    rong.mom      = taoCau("SG_R4_Mom",    0.135 * u, mauPhu)
    rong.mui      = taoCau("SG_R4_Mui",    0.06 * u, mauVang)
    rong.ham      = taoLap("SG_R4_Ham",    Vector3.new(0.11, 0.032, 0.16) * u, mau)
    rong.rangT1   = taoTru("SG_R4_RangT1", 0.09 * u, 0.024 * u, mauRang)
    rong.rangT2   = taoTru("SG_R4_RangT2", 0.09 * u, 0.024 * u, mauRang)
    rong.rangD1   = taoTru("SG_R4_RangD1", 0.065 * u, 0.02 * u, mauRang)
    rong.rangD2   = taoTru("SG_R4_RangD2", 0.065 * u, 0.02 * u, mauRang)
    rong.hoc1     = taoCau("SG_R4_Hoc1",   0.075 * u, mauToi, Enum.Material.SmoothPlastic)
    rong.hoc2     = taoCau("SG_R4_Hoc2",   0.075 * u, mauToi, Enum.Material.SmoothPlastic)
    rong.mat1     = taoCau("SG_R4_Mat1",   0.045 * u, mauMat)
    rong.mat2     = taoCau("SG_R4_Mat2",   0.045 * u, mauMat)
    rong.chamay1  = taoLap("SG_R4_Chamay1", Vector3.new(0.028, 0.09, 0.028) * u, mauVang)
    rong.chamay2  = taoLap("SG_R4_Chamay2", Vector3.new(0.028, 0.09, 0.028) * u, mauVang)
    rong.sung1a   = taoTru("SG_R4_Sung1a", 0.14 * u, 0.045 * u, mauVang)
    rong.sung1b   = taoTru("SG_R4_Sung1b", 0.12 * u, 0.038 * u, mauVang)
    rong.sung1c   = taoTru("SG_R4_Sung1c", 0.09 * u, 0.03 * u, mauVang)
    rong.sung2a   = taoTru("SG_R4_Sung2a", 0.14 * u, 0.045 * u, mauVang)
    rong.sung2b   = taoTru("SG_R4_Sung2b", 0.12 * u, 0.038 * u, mauVang)
    rong.sung2c   = taoTru("SG_R4_Sung2c", 0.09 * u, 0.03 * u, mauVang)
    rong.sungNho1 = taoTru("SG_R4_SungNho1", 0.07 * u, 0.024 * u, mauVang)
    rong.sungNho2 = taoTru("SG_R4_SungNho2", 0.07 * u, 0.024 * u, mauVang)
    for i = 1, 7 do
        rong.mao[i] = taoLap("SG_R4_Mao" .. i, Vector3.new(0.02, (0.19 - math.abs(i - 4) * 0.037) * u, 0.08) * u, mauVang)
    end
    rong.rau1a = taoLap("SG_R4_Rau1a", Vector3.new(0.015, 0.015, 0.13) * u, mauVang)
    rong.rau1b = taoLap("SG_R4_Rau1b", Vector3.new(0.012, 0.012, 0.11) * u, mauVang)
    rong.rau2a = taoLap("SG_R4_Rau2a", Vector3.new(0.015, 0.015, 0.13) * u, mauVang)
    rong.rau2b = taoLap("SG_R4_Rau2b", Vector3.new(0.012, 0.012, 0.11) * u, mauVang)
    rong.vayMang1 = taoWedge("SG_R4_VayMang1", Vector3.new(0.02, 0.13, 0.2) * u, mauPhu, 0.2)
    rong.vayMang2 = taoWedge("SG_R4_VayMang2", Vector3.new(0.02, 0.13, 0.2) * u, mauPhu, 0.2)

    -- ===== 2 CÁNH MÀNG (khớp + màng wedge + chóp sáng) =====
    for i = 1, 2 do
        local canh = {}
        canh.khop = taoCau("SG_R4_CanhKhop" .. i, 0.08 * u, mau)
        canh.mang = taoWedge("SG_R4_CanhMang" .. i, Vector3.new(0.018, 0.22, 0.46) * u, mauPhu, 0.25)
        canh.chop = taoCau("SG_R4_CanhChop" .. i, 0.05 * u, mauVang)
        rong.canh[i] = canh
    end

    -- ===== 4 CHÂN (2 trước bám đốt 4, 2 sau bám đốt 9): đùi + bàn chân =====
    for i = 1, 4 do
        local chan = {}
        chan.dui = taoCau("SG_R4_ChanDui" .. i, 0.088 * u, mauPhu)
        chan.ban = taoLap("SG_R4_ChanBan" .. i, Vector3.new(0.06, 0.032, 0.1) * u, mau)
        chan.ben = (i % 2 == 0) and 1 or -1
        chan.pha = i * 1.6
        rong.chan[i] = chan
    end

    -- ===== ĐUÔI: 5 lá quạt xòe + 2 gai đuôi + chóp cầu =====
    for i = 1, 5 do
        rong.duoi[i] = taoLap("SG_R4_Duoi" .. i, Vector3.new(0.02, (0.17 - i * 0.018) * u, 0.085) * u, mauPhu)
    end
    rong.gaiDuoi1 = taoLap("SG_R4_GaiDuoi1", Vector3.new(0.02, 0.09, 0.07) * u, mauVang)
    rong.gaiDuoi2 = taoLap("SG_R4_GaiDuoi2", Vector3.new(0.018, 0.07, 0.06) * u, mauVang)
    rong.cuoi = taoCau("SG_R4_Cuoi", 0.075 * u, mauVang)

    -- đèn glowing theo đầu rồng
    local den = Instance.new("PointLight")
    den.Name = "SG_Rong_Den"
    den.Color = mau
    den.Brightness = 1.8
    den.Range = 9 * sc
    den.Parent = rong.dau
    table.insert(danhSach, den)

    -- HƠI THỞ nguyên tố phun từ mõm
    local loaiHat = skin.hat and KHO_HAT[skin.hat]
    if loaiHat then
        local phun = Instance.new("ParticleEmitter")
        phun.Name = "SG_Rong_Phun"
        phun.Texture = loaiHat.texture
        phun.Color = ColorSequence.new(skin.hatMau or loaiHat.mau)
        phun.Rate = 42
        phun.Lifetime = NumberRange.new(0.35, 0.8)
        phun.Speed = NumberRange.new(2.5, 4.5)
        phun.SpreadAngle = Vector2.new(20, 20)
        phun.Size = NumberSequence.new(0.26, 0)
        phun.Transparency = NumberSequence.new(0.05, 1)
        phun.LightEmission = 1
        phun.LightInfluence = 0
        phun.EmissionDirection = Enum.NormalId.Front
        phun.Parent = rong.mom
        table.insert(danhSach, phun)
    end

    -- lấp lánh quanh đầu + vệt lấp lánh đuôi
    local loaiSao = KHO_HAT["SAO"]
    local sao = Instance.new("ParticleEmitter")
    sao.Name = "SG_Rong_Sao"
    sao.Texture = loaiSao.texture
    sao.Color = ColorSequence.new(skin.mauPhu or loaiSao.mau)
    sao.Rate = 16
    sao.Lifetime = NumberRange.new(0.3, 0.65)
    sao.Speed = NumberRange.new(0.4, 1.1)
    sao.SpreadAngle = Vector2.new(180, 180)
    sao.Size = NumberSequence.new(0.17, 0)
    sao.Transparency = NumberSequence.new(0.1, 1)
    sao.LightEmission = 1
    sao.LightInfluence = 0
    sao.Parent = rong.dau
    table.insert(danhSach, sao)

    local saoDuoi = Instance.new("ParticleEmitter")
    saoDuoi.Name = "SG_Rong_SaoDuoi"
    saoDuoi.Texture = loaiSao.texture
    saoDuoi.Color = ColorSequence.new(mauVang)
    saoDuoi.Rate = 10
    saoDuoi.Lifetime = NumberRange.new(0.3, 0.6)
    saoDuoi.Speed = NumberRange.new(0.2, 0.7)
    saoDuoi.SpreadAngle = Vector2.new(180, 180)
    saoDuoi.Size = NumberSequence.new(0.13, 0)
    saoDuoi.Transparency = NumberSequence.new(0.1, 1)
    saoDuoi.LightEmission = 1
    saoDuoi.LightInfluence = 0
    saoDuoi.Parent = rong.cuoi
    table.insert(danhSach, saoDuoi)

    DANH_SACH_RONG[handle] = rong
end

-- mỗi khung hình: toàn thân BƠI LỒN + đầu gật + cánh phe phẩy + chân đu đưa
local function CapNhatRong(handle, rong)
    if not handle or not handle.Parent then return end
    local cf = handle.CFrame
    local t = os.clock()
    local sc = rong.scale or 1.2
    local u = sc * 2
    local R = (0.62 + math.sin(t * 1.25) * 0.06) * sc
    local gocD = t * 2.1

    -- vị trí tương đối (trong hệ toạ độ súng) của đốt i (i = 0 là đầu)
    local function vt(i)
        local a = gocD - i * 0.34
        local r = R + math.sin(t * 2.3 + i * 0.45) * 0.05 * sc
        local y = math.sin(t * 2.7 - i * 0.52) * 0.17 * sc
        return Vector3.new(math.cos(a) * r, y, math.sin(a) * r)
    end

    -- đặt 16 đốt thân
    for i = 1, 16 do
        local p = rong.than[i]
        if p and p.Parent then
            p.CFrame = cf * CFrame.new(vt(i))
        end
    end

    -- CFrame world tại đốt i, mặt trước hướng theo chiều bơi
    local function cfTai(i)
        local p0 = (cf * CFrame.new(vt(i))).Position
        local p1 = (cf * CFrame.new(vt(i + 1))).Position
        local dir = p0 - p1
        if dir.Magnitude < 0.001 then dir = Vector3.new(0, 0, -1) end
        return CFrame.lookAt(p0, p0 + dir)
    end

    -- ĐẦU dẫn đường + GẬT NHẸ + toàn bộ chi tiết mặt
    local cfDau = cfTai(0) * CFrame.Angles(math.sin(t * 2.2) * 0.06, 0, 0)
    if rong.dau and rong.dau.Parent then rong.dau.CFrame = cfDau end
    if rong.tran1 and rong.tran1.Parent then rong.tran1.CFrame = cfDau * CFrame.new(-0.055 * u, 0.13 * u, -0.03 * u) end
    if rong.tran2 and rong.tran2.Parent then rong.tran2.CFrame = cfDau * CFrame.new(0.055 * u, 0.13 * u, -0.03 * u) end
    if rong.mom and rong.mom.Parent then rong.mom.CFrame = cfDau * CFrame.new(0, -0.03 * u, -0.2 * u) end
    if rong.mui and rong.mui.Parent then rong.mui.CFrame = cfDau * CFrame.new(0, -0.045 * u, -0.28 * u) end
    if rong.ham and rong.ham.Parent then rong.ham.CFrame = cfDau * CFrame.new(0, -0.12 * u, -0.15 * u) end
    -- 2 NANH TRÊN mọc từ mõm + 2 RĂNG DƯỚI trên hàm (cylinder dựng đứng nghiêng nhẹ)
    local nghieng = math.sin(t * 2.2) * 0.05
    if rong.rangT1 and rong.rangT1.Parent then rong.rangT1.CFrame = cfDau * CFrame.new(-0.06 * u, -0.075 * u, -0.22 * u) * CFrame.Angles(0.3 + nghieng, 0, 0.18 + math.pi / 2) end
    if rong.rangT2 and rong.rangT2.Parent then rong.rangT2.CFrame = cfDau * CFrame.new(0.06 * u, -0.075 * u, -0.22 * u) * CFrame.Angles(0.3 + nghieng, 0, -0.18 + math.pi / 2) end
    if rong.rangD1 and rong.rangD1.Parent then rong.rangD1.CFrame = cfDau * CFrame.new(-0.05 * u, -0.15 * u, -0.17 * u) * CFrame.Angles(-0.15 - nghieng, 0, 0.1 + math.pi / 2) end
    if rong.rangD2 and rong.rangD2.Parent then rong.rangD2.CFrame = cfDau * CFrame.new(0.05 * u, -0.15 * u, -0.17 * u) * CFrame.Angles(-0.15 - nghieng, 0, -0.1 + math.pi / 2) end
    -- HỐC MẮT (đục) + NGƯƠI SÁNG nhô ra trước trong hốc
    if rong.hoc1 and rong.hoc1.Parent then rong.hoc1.CFrame = cfDau * CFrame.new(-0.095 * u, 0.055 * u, -0.09 * u) end
    if rong.hoc2 and rong.hoc2.Parent then rong.hoc2.CFrame = cfDau * CFrame.new(0.095 * u, 0.055 * u, -0.09 * u) end
    if rong.mat1 and rong.mat1.Parent then rong.mat1.CFrame = cfDau * CFrame.new(-0.105 * u, 0.06 * u, -0.125 * u) end
    if rong.mat2 and rong.mat2.Parent then rong.mat2.CFrame = cfDau * CFrame.new(0.105 * u, 0.06 * u, -0.125 * u) end
    -- 2 GAI LÔNG MÀY dựng nghiêng
    if rong.chamay1 and rong.chamay1.Parent then rong.chamay1.CFrame = cfDau * CFrame.new(-0.14 * u, 0.115 * u, -0.05 * u) * CFrame.Angles(-0.3, 0, 0.55) end
    if rong.chamay2 and rong.chamay2.Parent then rong.chamay2.CFrame = cfDau * CFrame.new(0.14 * u, 0.115 * u, -0.05 * u) * CFrame.Angles(-0.3, 0, -0.55) end
    -- 2 SỪNG CHÍNH 3 ĐỐT CONG vươn lên + 2 SỪNG PHỤ vểnh ngang
    local songSung = math.sin(t * 2.2) * 0.04
    local sung1 = cfDau * CFrame.new(-0.07 * u, 0.15 * u, 0.04 * u) * CFrame.Angles(0.45 + songSung, 0, 0.32 + math.pi / 2)
    local sung2 = cfDau * CFrame.new(0.07 * u, 0.15 * u, 0.04 * u) * CFrame.Angles(0.45 + songSung, 0, -0.32 + math.pi / 2)
    if rong.sung1a and rong.sung1a.Parent then rong.sung1a.CFrame = sung1 end
    if rong.sung1b and rong.sung1b.Parent then rong.sung1b.CFrame = sung1 * CFrame.new(0, 0.115 * u, 0.01 * u) * CFrame.Angles(0.38, 0, 0.14) end
    if rong.sung1c and rong.sung1c.Parent then rong.sung1c.CFrame = sung1 * CFrame.new(0.02 * u, 0.215 * u, 0.03 * u) * CFrame.Angles(0.3, 0, 0.1) end
    if rong.sung2a and rong.sung2a.Parent then rong.sung2a.CFrame = sung2 end
    if rong.sung2b and rong.sung2b.Parent then rong.sung2b.CFrame = sung2 * CFrame.new(0, 0.115 * u, 0.01 * u) * CFrame.Angles(0.38, 0, -0.14) end
    if rong.sung2c and rong.sung2c.Parent then rong.sung2c.CFrame = sung2 * CFrame.new(-0.02 * u, 0.215 * u, 0.03 * u) * CFrame.Angles(0.3, 0, -0.1) end
    if rong.sungNho1 and rong.sungNho1.Parent then rong.sungNho1.CFrame = cfDau * CFrame.new(-0.13 * u, 0.1 * u, 0.06 * u) * CFrame.Angles(0.75, 0, 0.85 + math.pi / 2) end
    if rong.sungNho2 and rong.sungNho2.Parent then rong.sungNho2.CFrame = cfDau * CFrame.new(0.13 * u, 0.1 * u, 0.06 * u) * CFrame.Angles(0.75, 0, -0.85 + math.pi / 2) end
    -- MÀO 7 LÁ quạt sau gáy xòe rộng
    if rong.mao then
        for i = 1, 7 do
            local q = rong.mao[i]
            if q and q.Parent then
                local yaw = (i - 4) * 0.42
                local nghiengMao = 1.0 - math.abs(i - 4) * 0.14
                q.CFrame = cfDau * CFrame.Angles(0, yaw, 0) * CFrame.new(0, 0.14 * u, 0.14 * u) * CFrame.Angles(nghiengMao, 0, 0)
            end
        end
    end
    -- 2 RÂU 2 ĐỐT vươn trước, lượn theo nhịp
    local luonRau = math.sin(t * 3.1) * 0.12
    local rau1 = cfDau * CFrame.new(-0.055 * u, -0.05 * u, -0.24 * u) * CFrame.Angles(-0.6 + luonRau, 0, 0.3)
    local rau2 = cfDau * CFrame.new(0.055 * u, -0.05 * u, -0.24 * u) * CFrame.Angles(-0.6 - luonRau * 0.6, 0, -0.3)
    if rong.rau1a and rong.rau1a.Parent then rong.rau1a.CFrame = rau1 end
    if rong.rau1b and rong.rau1b.Parent then rong.rau1b.CFrame = rau1 * CFrame.new(0, 0, -0.115 * u) * CFrame.Angles(-0.25, 0, 0) end
    if rong.rau2a and rong.rau2a.Parent then rong.rau2a.CFrame = rau2 end
    if rong.rau2b and rong.rau2b.Parent then rong.rau2b.CFrame = rau2 * CFrame.new(0, 0, -0.115 * u) * CFrame.Angles(-0.25, 0, 0) end
    -- 2 VÂY MANG 2 bên sọ
    if rong.vayMang1 and rong.vayMang1.Parent then rong.vayMang1.CFrame = cfDau * CFrame.new(-0.16 * u, 0, 0.02 * u) * CFrame.Angles(0, 0.15, 0.5) end
    if rong.vayMang2 and rong.vayMang2.Parent then rong.vayMang2.CFrame = cfDau * CFrame.new(0.16 * u, 0, 0.02 * u) * CFrame.Angles(0, -0.15, -0.5) end

    -- 11 GAI LƯNG + 11 VẢY BỤNG bám đốt, gai nghiêng theo độ dốc sóng
    if rong.gai then
        for i = 1, 11 do
            local g = rong.gai[i]
            local v = rong.vayBung[i]
            local ci = i + 2
            if g and g.Parent then
                local cfG = cfTai(ci)
                local banKinhDot = rong.day[ci] * u * 0.5
                local caoFin = (0.14 - i * 0.006) * u
                local docSong = (vt(ci).Y - vt(ci + 1).Y) * 2.2
                if docSong > 0.7 then docSong = 0.7 elseif docSong < -0.7 then docSong = -0.7 end
                g.CFrame = cfG * CFrame.new(0, banKinhDot + caoFin * 0.35, 0) * CFrame.Angles(-docSong, 0, 0)
            end
            if v and v.Parent then
                local cfV = cfTai(ci)
                local banKinhDot = rong.day[ci] * u * 0.5
                v.CFrame = cfV * CFrame.new(0, -(banKinhDot - 0.015 * u), 0)
            end
        end
    end

    -- 2 CÁNH xòe phe phẩy theo nhịp bơi
    local flap = math.sin(t * 2.6) * 0.5
    local cfCanh = cfTai(5)
    if rong.canh then
        for i = 1, 2 do
            local c = rong.canh[i]
            if c and c.khop and c.khop.Parent then
                local s = (i == 1) and -1 or 1
                c.khop.CFrame = cfCanh * CFrame.new(s * 0.15 * u, 0.15 * u, 0)
                if c.mang and c.mang.Parent then
                    c.mang.CFrame = c.khop.CFrame * CFrame.new(s * 0.22 * u, 0.04 * u, 0.02 * u) * CFrame.Angles(0, s * 0.2, s * (0.25 + flap))
                end
                if c.chop and c.chop.Parent then
                    c.chop.CFrame = c.khop.CFrame * CFrame.new(s * 0.42 * u, 0.08 * u + flap * 0.08 * u, 0.04 * u)
                end
            end
        end
    end

    -- 4 CHÂN đu đưa theo sóng bơi
    if rong.chan then
        for i = 1, 4 do
            local c = rong.chan[i]
            if c and c.dui and c.dui.Parent then
                local cfDoc = cfTai((i <= 2) and 4 or 9)
                local dayXoay = math.sin(t * 2.7 - c.pha) * 0.18
                c.dui.CFrame = cfDoc * CFrame.new(c.ben * 0.13 * u, -0.13 * u, 0.02 * u) * CFrame.Angles(0, 0, dayXoay)
                if c.ban and c.ban.Parent then
                    c.ban.CFrame = c.dui.CFrame * CFrame.new(c.ben * 0.05 * u, -0.08 * u, 0.02 * u) * CFrame.Angles(0, 0, c.ben * 0.15)
                end
            end
        end
    end

    -- ĐUÔI: 5 lá quạt xòe + 2 gai đuôi + chóp cầu sáng
    local cfCuoi = cfTai(16)
    if rong.duoi then
        for i = 1, 5 do
            local q = rong.duoi[i]
            if q and q.Parent then
                q.CFrame = cfCuoi * CFrame.Angles(0, (i - 3) * 0.5, 0) * CFrame.new(0, 0.02 * u, -0.095 * u) * CFrame.Angles(0.5, 0, 0)
            end
        end
    end
    if rong.gaiDuoi1 and rong.gaiDuoi1.Parent then rong.gaiDuoi1.CFrame = cfTai(14) * CFrame.new(0, rong.day[14] * u * 0.5 + 0.03 * u, 0) * CFrame.Angles(-0.3, 0, 0) end
    if rong.gaiDuoi2 and rong.gaiDuoi2.Parent then rong.gaiDuoi2.CFrame = cfTai(13) * CFrame.new(0, rong.day[13] * u * 0.5 + 0.025 * u, 0) * CFrame.Angles(-0.35, 0, 0) end
    if rong.cuoi and rong.cuoi.Parent then rong.cuoi.CFrame = cfCuoi * CFrame.new(0, 0, -0.05 * u) end
end

-- ===== AURA VÒNG SÁNG XOAY QUANH SÚNG (VER 5 — CÓ VỆT TRAIL) =====
-- 8 cầu Neon vòng NGOÀI xoay thuận (mỗi cầu kéo 1 VỆT TRAIL sáng như sao chổi)
-- + 4 cầu vòng TRONG xoay ngược, phập phồng theo nhịp
local DANH_SACH_AURA = {}

local function XoaAura(handle)
    local aura = DANH_SACH_AURA[handle]
    if aura then
        for _, obj in ipairs(aura.ngoai) do
            pcall(function() obj:Destroy() end)
        end
        for _, obj in ipairs(aura.trong) do
            pcall(function() obj:Destroy() end)
        end
        DANH_SACH_AURA[handle] = nil
    end
end

local function taoCauAura(ten, kichThuoc, mau)
    local q = Instance.new("Part")
    q.Name = ten
    q.Size = Vector3.new(kichThuoc, kichThuoc, kichThuoc)
    q.Material = Enum.Material.Neon
    q.Color = mau
    q.Anchored = true
    q.CanCollide = false
    q.CanQuery = false
    q.CanTouch = false
    q.CastShadow = false
    q.Parent = workspace
    return q
end

local function TaoAura(handle, skin)
    XoaAura(handle)
    if not handle or not handle.Parent then return end
    local mauNgoai = skin.mauPhu or skin.mausac or Color3.fromRGB(255, 255, 255)
    local mauTrong = skin.mausac or mauNgoai
    local ngoai, trong, trails = {}, {}, {}
    for i = 1, 8 do
        ngoai[i] = taoCauAura("SG_Aura_Ngoai" .. i, 0.10, mauNgoai)
        -- VỆT TRAIL sao chổi: mỗi cầu aura kéo 1 vệt sáng khi xoay
        local a0 = Instance.new("Attachment")
        a0.Name = "SG_AT0"
        a0.Position = Vector3.new(0.05, 0, 0)
        a0.Parent = ngoai[i]
        local a1 = Instance.new("Attachment")
        a1.Name = "SG_AT1"
        a1.Position = Vector3.new(-0.05, 0, 0)
        a1.Parent = ngoai[i]
        local tl = Instance.new("Trail")
        tl.Name = "SG_Aura_Trail"
        tl.Attachment0 = a0
        tl.Attachment1 = a1
        tl.Lifetime = 0.28
        tl.LightEmission = 1
        tl.LightInfluence = 0
        tl.FaceCamera = true
        tl.Transparency = NumberSequence.new(0.2, 1)
        tl.WidthScale = NumberSequence.new(1, 0.1)
        tl.Color = ColorSequence.new(mauNgoai)
        tl.Parent = ngoai[i]
        trails[i] = tl
    end
    for i = 1, 4 do
        trong[i] = taoCauAura("SG_Aura_Trong" .. i, 0.07, mauTrong)
    end
    DANH_SACH_AURA[handle] = { ngoai = ngoai, trong = trong, trails = trails }
end

local function CapNhatAura(handle, aura)
    if not handle or not handle.Parent then return end
    local cf = handle.CFrame
    local t = os.clock()
    local banKinh = 0.78 + math.sin(t * 1.7) * 0.10
    for i, q in ipairs(aura.ngoai) do
        local goc = t * 1.9 + (i - 1) * (math.pi * 2 / #aura.ngoai)
        local cao = math.sin(t * 2.6 + i * 0.9) * 0.32
        local s = 0.07 + math.abs(math.sin(t * 4.2 + i * 1.3)) * 0.05
        q.Size = Vector3.new(s, s, s)
        q.CFrame = cf * CFrame.new(math.cos(goc) * banKinh, cao, math.sin(goc) * banKinh)
    end
    local banKinh2 = 0.45 + math.cos(t * 2.1) * 0.07
    for i, q in ipairs(aura.trong) do
        local goc = -t * 2.8 + (i - 1) * (math.pi / 2)
        local cao = math.sin(t * 3.4 + i * 1.7) * 0.22
        local s = 0.05 + math.abs(math.cos(t * 5 + i)) * 0.04
        q.Size = Vector3.new(s, s, s)
        q.CFrame = cf * CFrame.new(math.cos(goc) * banKinh2, cao, math.sin(goc) * banKinh2)
    end
end

-- ===== VÒNG NĂNG LƯỢNG GYROSCOPE + HELIX (VER 5 — MỚI HOÀN TOÀN) =====
-- * 2 ĐĨA NĂNG LƯỢNG dẹt (cylinder Neon mờ) xoay lồng nhau 2 trục nghiêng
--   như con quay hồi chuyển bọc quanh súng
-- * 3 CẦU HELIX bơi lên xuống xoáy quanh súng như chuỗi DNA năng lượng
local DANH_SACH_VONG = {}

local function XoaVong(handle)
    local vong = DANH_SACH_VONG[handle]
    if vong then
        for _, obj in ipairs(vong.cacPhan) do
            pcall(function() obj:Destroy() end)
        end
        DANH_SACH_VONG[handle] = nil
    end
end

local function TaoVong(handle, skin)
    XoaVong(handle)
    if not handle or not handle.Parent then return end
    local mau1 = skin.mausac or Color3.fromRGB(255, 255, 255)
    local mau2 = skin.mauPhu or mau1
    local cacPhan, dia, helix = {}, {}, {}

    for i = 1, 2 do
        local d = Instance.new("Part")
        d.Name = "SG_Vong_Dia" .. i
        d.Shape = Enum.PartType.Cylinder
        d.Size = Vector3.new(0.03, 1.3, 1.3)
        d.Material = Enum.Material.Neon
        d.Color = (i == 1) and mau2 or mau1
        d.Transparency = (i == 1) and 0.32 or 0.46
        d.Anchored = true
        d.CanCollide = false
        d.CanQuery = false
        d.CanTouch = false
        d.CastShadow = false
        d.Parent = workspace
        dia[i] = d
        table.insert(cacPhan, d)
    end

    for i = 1, 3 do
        local q = Instance.new("Part")
        q.Name = "SG_Vong_Helix" .. i
        q.Shape = Enum.PartType.Ball
        q.Size = Vector3.new(0.09, 0.09, 0.09)
        q.Material = Enum.Material.Neon
        q.Color = mau2
        q.Anchored = true
        q.CanCollide = false
        q.CanQuery = false
        q.CanTouch = false
        q.CastShadow = false
        q.Parent = workspace
        helix[i] = q
        table.insert(cacPhan, q)
    end

    DANH_SACH_VONG[handle] = { dia = dia, helix = helix, cacPhan = cacPhan }
end

local function CapNhatVong(handle, vong)
    if not handle or not handle.Parent then return end
    local cf = handle.CFrame
    local t = os.clock()
    local d1 = vong.dia[1]
    if d1 and d1.Parent then
        d1.CFrame = cf * CFrame.Angles(t * 1.35, 0, t * 0.85)
    end
    local d2 = vong.dia[2]
    if d2 and d2.Parent then
        d2.CFrame = cf * CFrame.Angles(0.9, t * 1.15, t * 0.7)
    end
    for i, q in ipairs(vong.helix) do
        if q and q.Parent then
            local goc = t * 2.3 + i * (math.pi * 2 / 3)
            local y = math.sin(t * 1.7 + i * 2.1) * 0.6
            local banKinh = 0.4 + math.abs(math.sin(t * 1.1 + i)) * 0.12
            local s = 0.07 + math.abs(math.sin(t * 5 + i * 2)) * 0.05
            q.Size = Vector3.new(s, s, s)
            q.CFrame = cf * CFrame.new(math.cos(goc) * banKinh, y, math.sin(goc) * banKinh)
        end
    end
end

local LUU_GOC  = setmetatable({}, {__mode = "k"})   -- [part] thuộc tính gốc để khôi phục
local HIEU_UNG = setmetatable({}, {__mode = "k"})   -- [handle] hiệu ứng đang gắn
local DANH_SACH_PART   = {}                         -- part thân súng + viewmodel (tô skin)
local DANH_SACH_HANDLE = {}                         -- Handle (neo hiệu ứng)
local SKIN_HIEN_TAI    = nil

local function LayHandleSung()
    local ketQua = {}
    local char = LocalPlayer.Character
    if not char then return ketQua end
    for _, con in ipairs(char:GetChildren()) do
        if con:IsA("Tool") then
            local handle = con:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                table.insert(ketQua, handle)
            end
        end
    end
    return ketQua
end

local function LayPartSung()
    local ketQua = {}
    local char = LocalPlayer.Character
    if not char then return ketQua end
    for _, con in ipairs(char:GetChildren()) do
        if con:IsA("Tool") then
            for _, p in ipairs(con:GetDescendants()) do
                if p:IsA("BasePart") then table.insert(ketQua, p) end
            end
        end
    end
    return ketQua
end

-- Lọc tay người (không tô tay viewmodel)
local function LaPartTay(p)
    local n = p.Name:lower()
    return n:find("arm", 1, true) ~= nil or n:find("hand", 1, true) ~= nil
        or n:find("finger", 1, true) ~= nil or n:find("sleeve", 1, true) ~= nil
end

local function CoHumanoid(obj, cam)
    local cur = obj
    while cur and cur ~= cam do
        if cur:FindFirstChildOfClass("Humanoid") then return true end
        cur = cur.Parent
    end
    return false
end

local function LayPartViewModel()
    local ketQua = {}
    local cam = workspace.CurrentCamera
    if not cam then return ketQua end
    for _, p in ipairs(cam:GetDescendants()) do
        if p:IsA("BasePart") and not LaPartTay(p) and not CoHumanoid(p, cam) then
            table.insert(ketQua, p)
        end
    end
    return ketQua
end

local function NoiDanhSach(danhSach, them)
    for _, moi in ipairs(them) do
        local daCo = false
        for _, cu in ipairs(danhSach) do
            if cu == moi then daCo = true break end
        end
        if not daCo then table.insert(danhSach, moi) end
    end
end

local function LayMauVertex(mau)
    return Vector3.new(mau.R, mau.G, mau.B)
end

local function LuuGocPart(p)
    if LUU_GOC[p] then return end
    local t = {
        Material = p.Material, Color = p.Color,
        Transparency = p.Transparency, Reflectance = p.Reflectance,
        KichThuoc = p.Size, Mesh = p:FindFirstChildOfClass("SpecialMesh"),
    }
    if p:IsA("MeshPart") then t.TextureID = p.TextureID end
    if t.Mesh then
        t.MeshTextureId = t.Mesh.TextureId
        t.VertexColor = t.Mesh.VertexColor
    end
    LUU_GOC[p] = t
end

local function ToMauPart(p, mau)
    p.Color = mau
    local goc = LUU_GOC[p]
    if goc and goc.Mesh then goc.Mesh.VertexColor = LayMauVertex(mau) end
end

-- Băm tên part -> quyết định part đó tô màu CHÍNH hay màu NHẤN
-- (ổn định giữa các lần quét lại: cùng 1 part luôn ra cùng 1 màu)
local function BamTenPart(p)
    local s = 0
    local ten = p.Name
    for i = 1, #ten do
        s = s + string.byte(ten, i) * (i + 3)
    end
    return s
end

-- ===== VER 9: PHONG CÁCH RIÊNG THEO TỪNG SKIN =====
-- KHÔNG CÒN dùng chung hiệu ứng: mỗi nhóm skin có BỘ HIỆU ỨNG + DÁNG RIÊNG:
--   mau     : giọt máu chảy rơi + sương đỏ (Blood / Huyết Nguyệt / Cương Huyết)
--   lava    : mảng đá nứt nẻ + khe dung nham sáng dập dềnh + tia lửa (Lava / Chaos)
--   bang    : tinh thể băng mọc quanh súng + tuyết rơi + hơi lạnh (Pha Lê Băng / Bão Băng)
--   kim     : kim loại LOANG ÁNH phản chiếu chạy + kim tuyến bay vòng (Gold / Kim Cương / Bạc...)
--   toxic   : bong bóng độc nổi lên + giọt nọc chảy giãn (Toxic / Nọc Rắn)
--   electric: tia sét GIẬT đổi hình 12 lần/giây quanh súng (Electric / Sét Thiên Thần)
--   holy    : vòng hào quang + cột tia sáng thiêng + lấp lánh (Holy / Thiêng Liêng)
--   galaxy  : sao xoay 2 tầng nghiêng + tinh vân + sao băng (Galaxy / Vũ Trụ / Sao Rơi)
--   rainbow : vòm cầu vồng 7 sắc chạy sáng tuần tự (Cầu Vòng 7 Màu)
--   candy   : kẹo viên pastel lơ lửng đổi màu + bong bóng kẹo (Hồng Neon / Kẹo Bông / Tím Neon)
--   matroi  : bánh xe tia nắng quay + lửa mặt trời (Cam Solar)
--   muarung : lá rừng lượn + mưa rơi + đom đóm (Rừng Mưa Nhiệt Đới)
--   cat     : bão cát cuộn 2 tầng ngược chiều + bụi cát (Bão Cát Sa Mạc)
--   nuoc    : gợn sóng biển dập dềnh + bọt nước + giọt rơi (Mint / Hải Vương)
--   hellokitty: 2 HUY HIỆU KITTY (ảnh thật 106052405898657 + 112971377761365) bay quanh súng + sao hồng lấp lánh (Hello Kitty Pink, VER 11)
--   rong    : RỒNG THIÊN LONG VER 4 (xử lý riêng ở TaoRong, không qua khối này)
local DANH_SACH_PHONG = {}

local XU_SPARK = "rbxasset://textures/particles/sparkles_main.dds"
local XU_LUA   = "rbxasset://textures/particles/fire_main.dds"
local XU_KHOI  = "rbxasset://textures/particles/smoke_main.dds"

local function phongGop(p)
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Parent = workspace
    return p
end

local function phongCau(ten, kichThuoc, mau, vatLieu, trongSuot)
    local p = Instance.new("Part")
    p.Name = ten
    p.Shape = Enum.PartType.Ball
    p.Size = Vector3.new(kichThuoc, kichThuoc, kichThuoc)
    p.Material = vatLieu or Enum.Material.Neon
    p.Color = mau
    if trongSuot then p.Transparency = trongSuot end
    return phongGop(p)
end

local function phongTru(ten, cao, duongKinh, mau, trongSuot, vatLieu)
    local p = Instance.new("Part")
    p.Name = ten
    p.Shape = Enum.PartType.Cylinder
    p.Size = Vector3.new(cao, duongKinh, duongKinh)
    p.Material = vatLieu or Enum.Material.Neon
    p.Color = mau
    if trongSuot then p.Transparency = trongSuot end
    return phongGop(p)
end

local function phongWedge(ten, kichThuoc, mau, trongSuot, vatLieu)
    local p = Instance.new("WedgePart")
    p.Name = ten
    p.Size = kichThuoc
    p.Material = vatLieu or Enum.Material.Neon
    p.Color = mau
    if trongSuot then p.Transparency = trongSuot end
    return phongGop(p)
end

local function phongHat(ten, cha, texture, mau, tuyChon)
    local e = Instance.new("ParticleEmitter")
    e.Name = ten
    e.Texture = texture
    e.Color = ColorSequence.new(mau)
    e.Rate = tuyChon.tiLe or 10
    e.Lifetime = NumberRange.new((tuyChon.tuoiTho or 1) * 0.6, tuyChon.tuoiTho or 1)
    e.Speed = NumberRange.new((tuyChon.tocDo or 1) * 0.5, tuyChon.tocDo or 1)
    e.SpreadAngle = tuyChon.phanTan and Vector2.new(tuyChon.phanTan, tuyChon.phanTan) or Vector2.new(180, 180)
    e.Size = NumberSequence.new(tuyChon.kichThuoc or 0.2, (tuyChon.kichThuoc or 0.2) * 0.4)
    e.Transparency = NumberSequence.new(tuyChon.dam or 0.15, 1)
    e.LightEmission = 1
    e.LightInfluence = 0
    e.Rotation = NumberRange.new(0, 360)
    e.RotSpeed = NumberRange.new(-90, 90)
    e.EmissionDirection = tuyChon.huong or Enum.NormalId.Top
    if tuyChon.giaToc then e.Acceleration = tuyChon.giaToc end
    e.Parent = cha
    return e
end

local function XoaPhong(handle)
    local phong = DANH_SACH_PHONG[handle]
    if phong then
        for _, obj in ipairs(phong.phan) do
            pcall(function() obj:Destroy() end)
        end
        DANH_SACH_PHONG[handle] = nil
    end
end

local KHO_PHONG = {}

-- ===== 1. MAU — GIỌT MÁU CHẢY RỊ + SƯƠNG ĐỎ =====
KHO_PHONG["mau"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mausac or Color3.fromRGB(180, 0, 30)
        local giot = {}
        for i = 1, 4 do
            local g = phongCau("SG_Phong_GiotMau" .. i, 0.055, mau, Enum.Material.Glass, 0.25)
            table.insert(phan, g)
            giot[i] = { p = g, ox = (i - 2.5) * 0.22, oz = (i % 2 == 0) and 0.12 or -0.14, pha = i * 0.27 }
        end
        local suong = phongHat("SG_Phong_SuongMau", handle, XU_KHOI, mau, { tiLe = 9, tuoiTho = 1.2, tocDo = 0.4, kichThuoc = 0.3, dam = 0.4 })
        table.insert(phan, suong)
        return { giot = giot }
    end,
    chay = function(handle, d, t, cf)
        for _, g in ipairs(d.giot) do
            if g.p and g.p.Parent then
                local tienDo = (t * 0.45 + g.pha) % 1
                g.p.CFrame = cf * CFrame.new(g.ox, -0.05 - tienDo * 0.55, g.oz)
                g.p.Transparency = 0.25 + tienDo * 0.65
                local s = 0.055 * (1 - tienDo * 0.5)
                g.p.Size = Vector3.new(s, s, s)
            end
        end
    end,
}

-- ===== 2. LAVA — MẢNG ĐÁ NỨT NẺ + KHE DUNG NHAM DẬP DỀNH =====
KHO_PHONG["lava"] = {
    tao = function(handle, skin, phan)
        local mauVang = skin.mausac or Color3.fromRGB(255, 90, 0)
        local mauDa = Color3.fromRGB(22, 16, 14)
        local da, khe = {}, {}
        for i = 1, 5 do
            local db = phongWedge("SG_Phong_DaLava" .. i, Vector3.new(0.06, 0.16, 0.26), mauDa, 0.1, Enum.Material.Slate)
            table.insert(phan, db)
            da[i] = db
            local kk = phongWedge("SG_Phong_KheLava" .. i, Vector3.new(0.02, 0.05, 0.12), mauVang)
            table.insert(phan, kk)
            khe[i] = kk
        end
        local lua = phongHat("SG_Phong_HatLava", handle, XU_LUA, mauVang, { tiLe = 14, tuoiTho = 0.7, tocDo = 2.6, kichThuoc = 0.22 })
        local khoi = phongHat("SG_Phong_KhoiLava", handle, XU_KHOI, Color3.fromRGB(40, 30, 28), { tiLe = 5, tuoiTho = 1.4, tocDo = 0.9, kichThuoc = 0.34, dam = 0.5 })
        table.insert(phan, lua)
        table.insert(phan, khoi)
        return { da = da, khe = khe, mauVang = mauVang }
    end,
    chay = function(handle, d, t, cf)
        for i = 1, 5 do
            local goc = i * (math.pi * 2 / 5) + t * 0.15
            local db = d.da[i]
            if db and db.Parent then
                db.CFrame = cf * CFrame.Angles(0, goc, 0) * CFrame.new(0.42, 0.05 + math.sin(t * 2 + i) * 0.03, 0) * CFrame.Angles(0, math.pi / 2, 0.4)
            end
            local kk = d.khe[i]
            if kk and kk.Parent then
                local song = 0.5 + 0.5 * math.sin(t * 3.2 + i * 1.3)
                kk.Color = Color3.fromRGB(255, 90, 0):Lerp(d.mauVang:Lerp(Color3.fromRGB(255, 220, 80), song), 0.5)
                kk.CFrame = cf * CFrame.Angles(0, goc + 0.3, 0) * CFrame.new(0.36, -0.02, 0) * CFrame.Angles(0, math.pi / 2, -0.2)
            end
        end
    end,
}

-- ===== 3. BANG — TINH THỂ BĂNG MỌC QUANH SÚNG + TUYẾT RƠI =====
KHO_PHONG["bang"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mausac or Color3.fromRGB(150, 230, 255)
        local tinhs, chops = {}, {}
        for i = 1, 5 do
            local c = phongTru("SG_Phong_TinhBang" .. i, 0.34, 0.05, mau, 0.2, Enum.Material.Glass)
            table.insert(phan, c)
            tinhs[i] = c
            local ch = phongCau("SG_Phong_ChopBang" .. i, 0.055, Color3.fromRGB(235, 250, 255))
            table.insert(phan, ch)
            chops[i] = ch
        end
        local tuyet = phongHat("SG_Phong_Tuyet", handle, XU_KHOI, Color3.fromRGB(240, 250, 255), { tiLe = 13, tuoiTho = 1.5, tocDo = 0.4, kichThuoc = 0.11, dam = 0.2, giaToc = Vector3.new(0, -3.2, 0) })
        local hoiLanh = phongHat("SG_Phong_HoiLanh", handle, XU_KHOI, mau, { tiLe = 4, tuoiTho = 1.1, tocDo = 0.3, kichThuoc = 0.3, dam = 0.55 })
        table.insert(phan, tuyet)
        table.insert(phan, hoiLanh)
        return { tinhs = tinhs, chops = chops }
    end,
    chay = function(handle, d, t, cf)
        for i = 1, 5 do
            local goc = i * (math.pi * 2 / 5) - t * 0.22
            local cao = ((i % 2 == 0) and 0.18 or -0.14) + math.sin(t * 1.8 + i) * 0.04
            local c = d.tinhs[i]
            if c and c.Parent then
                c.CFrame = cf * CFrame.Angles(0, goc, 0) * CFrame.new(0.44, cao, 0) * CFrame.Angles(0.35, 0, math.pi / 2 + i * 0.2)
                c.Reflectance = 0.2 + 0.25 * (0.5 + 0.5 * math.sin(t * 2.6 + i * 1.1))
            end
            local ch = d.chops[i]
            if ch and ch.Parent and c and c.Parent then
                ch.CFrame = c.CFrame * CFrame.new(0, 0.2, 0)
                ch.Transparency = 0.1 + 0.3 * (0.5 + 0.5 * math.sin(t * 3.4 + i))
            end
        end
    end,
}

-- ===== 4. KIM — KIM LOẠI LOANG ÁNH + KIM TUYẾN BAY VÒNG =====
KHO_PHONG["kim"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mauPhu or skin.mausac or Color3.fromRGB(255, 210, 70)
        local hat = {}
        for i = 1, 8 do
            local h = phongCau("SG_Phong_KimTuyen" .. i, 0.04, (i % 2 == 0) and mau or Color3.fromRGB(255, 255, 230))
            table.insert(phan, h)
            hat[i] = h
        end
        local spark = phongHat("SG_Phong_KimSpark", handle, XU_SPARK, mau, { tiLe = 11, tuoiTho = 0.6, tocDo = 1.6, kichThuoc = 0.14 })
        table.insert(phan, spark)
        return { hat = hat }
    end,
    chay = function(handle, d, t, cf)
        -- LOANG ÁNH: phản chiếu ánh sáng chạy trên toàn thân súng
        for _, p in ipairs(DANH_SACH_PART) do
            if p.Parent then
                p.Reflectance = 0.1 + 0.24 * (0.5 + 0.5 * math.sin(t * 2.8 + (BamTenPart(p) % 10)))
            end
        end
        for i, h in ipairs(d.hat) do
            if h and h.Parent then
                local goc = t * (1.6 + (i % 3) * 0.35) + i * (math.pi * 2 / 8)
                local banKinh = 0.5 + math.sin(t * 2.1 + i * 1.4) * 0.12
                local s = 0.03 + math.abs(math.sin(t * 4.4 + i * 2)) * 0.03
                h.Size = Vector3.new(s, s, s)
                h.CFrame = cf * CFrame.new(math.cos(goc) * banKinh, math.sin(t * 2.9 + i * 0.8) * 0.3, math.sin(goc) * banKinh)
            end
        end
    end,
}

-- ===== 5. TOXIC — BONG BÓNG ĐỘC NỔI LÊN + GIỌT NỌC CHẢY GIÃN =====
KHO_PHONG["toxic"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mausac or Color3.fromRGB(90, 255, 50)
        local giot = {}
        for i = 1, 3 do
            local g = phongTru("SG_Phong_GiotNoc" .. i, 0.09, 0.045, mau, 0.3, Enum.Material.Glass)
            table.insert(phan, g)
            giot[i] = { p = g, ox = (i - 2) * 0.25, pha = i * 2.1 }
        end
        local bong = phongHat("SG_Phong_BongDoc", handle, XU_KHOI, mau, { tiLe = 10, tuoiTho = 1.4, tocDo = 0.6, kichThuoc = 0.15, dam = 0.25, giaToc = Vector3.new(0, 2.4, 0) })
        local khoi = phongHat("SG_Phong_KhoiDoc", handle, XU_KHOI, mau:Lerp(Color3.fromRGB(20, 60, 10), 0.5), { tiLe = 5, tuoiTho = 1.3, tocDo = 0.5, kichThuoc = 0.3, dam = 0.55 })
        table.insert(phan, bong)
        table.insert(phan, khoi)
        return { giot = giot }
    end,
    chay = function(handle, d, t, cf)
        for _, g in ipairs(d.giot) do
            if g.p and g.p.Parent then
                local cao = 0.07 + math.max(0, math.sin(t * 2.2 + g.pha)) * 0.1
                g.p.Size = Vector3.new(cao, 0.045, 0.045)
                g.p.CFrame = cf * CFrame.new(g.ox, -0.22, 0.05) * CFrame.Angles(0, 0, math.pi / 2)
            end
        end
    end,
}

-- ===== 6. ELECTRIC — TIA SÉT GIẬT ĐỔI HÌNH LIÊN TỤC =====
KHO_PHONG["electric"] = {
    tao = function(handle, skin, phan)
        local doans = {}
        for i = 1, 4 do
            local s = phongTru("SG_Phong_TiaSet" .. i, 0.1, 0.02, Color3.fromRGB(230, 245, 255))
            table.insert(phan, s)
            doans[i] = s
        end
        local spark = phongHat("SG_Phong_SparkSet", handle, XU_SPARK, skin.mausac or Color3.fromRGB(120, 200, 255), { tiLe = 18, tuoiTho = 0.4, tocDo = 4.2, kichThuoc = 0.16 })
        table.insert(phan, spark)
        return { doans = doans, lanChot = 0, diem = {} }
    end,
    chay = function(handle, d, t, cf)
        if t - d.lanChot > 0.08 then
            d.lanChot = t
            for i = 1, 4 do
                local a1 = math.random() * math.pi * 2
                local a2 = math.random() * math.pi * 2
                local y1 = (math.random() - 0.5) * 0.8
                local y2 = (math.random() - 0.5) * 0.8
                local r1 = 0.45 + math.random() * 0.25
                local r2 = 0.45 + math.random() * 0.25
                d.diem[i * 2 - 1] = cf * CFrame.new(math.cos(a1) * r1, y1, math.sin(a1) * r1)
                d.diem[i * 2] = cf * CFrame.new(math.cos(a2) * r2, y2, math.sin(a2) * r2)
            end
        end
        for i = 1, 4 do
            local s = d.doans[i]
            local p1 = d.diem[i * 2 - 1]
            local p2 = d.diem[i * 2]
            if s and s.Parent and p1 and p2 then
                local giua = (p1.Position + p2.Position) * 0.5
                local dai = (p2.Position - p1.Position).Magnitude
                s.Size = Vector3.new(dai, 0.018, 0.018)
                s.CFrame = CFrame.lookAt(giua, p2.Position) * CFrame.Angles(0, math.pi / 2, 0)
                s.Transparency = 0.05 + math.random() * 0.35
            end
        end
    end,
}

-- ===== 7. HOLY — VÒNG HÀO QUANG + CỘT TIA SÁNG THIÊNG =====
KHO_PHONG["holy"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mausac or Color3.fromRGB(255, 245, 200)
        local vong = {}
        for i = 1, 8 do
            local q = phongCau("SG_Phong_HaoQuang" .. i, 0.045, Color3.fromRGB(255, 240, 170))
            table.insert(phan, q)
            vong[i] = q
        end
        local tia1 = phongTru("SG_Phong_TiaThien1", 1.15, 0.05, mau, 0.55, Enum.Material.Glass)
        local tia2 = phongTru("SG_Phong_TiaThien2", 1.15, 0.05, mau, 0.55, Enum.Material.Glass)
        table.insert(phan, tia1)
        table.insert(phan, tia2)
        local long = phongHat("SG_Phong_LongTrang", handle, XU_SPARK, Color3.fromRGB(255, 250, 220), { tiLe = 8, tuoiTho = 1.2, tocDo = 0.5, kichThuoc = 0.14, dam = 0.2 })
        table.insert(phan, long)
        return { vong = vong, tia1 = tia1, tia2 = tia2 }
    end,
    chay = function(handle, d, t, cf)
        for i, q in ipairs(d.vong) do
            if q and q.Parent then
                local goc = t * 1.1 + i * (math.pi * 2 / 8)
                q.CFrame = cf * CFrame.new(math.cos(goc) * 0.4, 0.5 + math.sin(t * 1.7 + i) * 0.04, math.sin(goc) * 0.4)
                q.Transparency = 0.1 + 0.25 * (0.5 + 0.5 * math.sin(t * 3 + i))
            end
        end
        local sway = math.sin(t * 0.9) * 0.12
        if d.tia1 and d.tia1.Parent then
            d.tia1.CFrame = cf * CFrame.new(-0.3, 0.1, 0) * CFrame.Angles(0, 0, 0.18 + sway + math.pi / 2)
        end
        if d.tia2 and d.tia2.Parent then
            d.tia2.CFrame = cf * CFrame.new(0.3, 0.1, 0) * CFrame.Angles(0, 0, -0.18 - sway + math.pi / 2)
        end
    end,
}

-- ===== 8. GALAXY — SAO XOAY 2 TẦNG NGHIÊNG + TINH VÂN + SAO BĂNG =====
KHO_PHONG["galaxy"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mausac or Color3.fromRGB(150, 80, 255)
        local mauPhu = skin.mauPhu or Color3.fromRGB(90, 130, 255)
        local sao = {}
        for i = 1, 6 do
            local s = phongCau("SG_Phong_SaoGalaxy" .. i, 0.05, (i % 2 == 0) and mauPhu or mau)
            table.insert(phan, s)
            sao[i] = s
        end
        local tinhVan = phongHat("SG_Phong_TinhVan", handle, XU_KHOI, mau, { tiLe = 9, tuoiTho = 1.6, tocDo = 0.3, kichThuoc = 0.36, dam = 0.55 })
        local saoBang = phongHat("SG_Phong_SaoBang", handle, XU_SPARK, Color3.fromRGB(255, 255, 255), { tiLe = 4, tuoiTho = 0.5, tocDo = 3.2, kichThuoc = 0.13 })
        table.insert(phan, tinhVan)
        table.insert(phan, saoBang)
        return { sao = sao }
    end,
    chay = function(handle, d, t, cf)
        for i, s in ipairs(d.sao) do
            if s and s.Parent then
                local goc = t * (i <= 3 and 1.4 or -1.05) + i * (math.pi / 3)
                local nghieng = (i <= 3) and 0.35 or -0.35
                local r = 0.55 + math.sin(t * 1.9 + i) * 0.07
                local x = math.cos(goc) * r
                local z = math.sin(goc) * r
                local y = math.sin(goc + nghieng) * 0.28
                local sz = 0.035 + math.abs(math.sin(t * 3.6 + i * 1.7)) * 0.04
                s.Size = Vector3.new(sz, sz, sz)
                s.CFrame = cf * CFrame.new(x, y, z)
            end
        end
    end,
}

-- ===== 9. RAINBOW — VÒM CẦU VỒNG 7 SẮC SÁNG CHẠY TUẦN TỰ =====
KHO_PHONG["rainbow"] = {
    tao = function(handle, skin, phan)
        local MAU7 = {
            Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 140, 40), Color3.fromRGB(255, 230, 50),
            Color3.fromRGB(90, 220, 80), Color3.fromRGB(70, 170, 255), Color3.fromRGB(130, 80, 255),
            Color3.fromRGB(220, 70, 255),
        }
        local vach = {}
        for i = 1, 7 do
            local v = phongTru("SG_Phong_VachCauVong" .. i, 0.5, 0.028, MAU7[i])
            table.insert(phan, v)
            vach[i] = v
        end
        local sao = phongHat("SG_Phong_SaoCauVong", handle, XU_SPARK, Color3.fromRGB(255, 255, 255), { tiLe = 7, tuoiTho = 0.7, tocDo = 1.2, kichThuoc = 0.13 })
        table.insert(phan, sao)
        return { vach = vach }
    end,
    chay = function(handle, d, t, cf)
        local chuyen = t * 0.5
        for i, v in ipairs(d.vach) do
            if v and v.Parent then
                local goc = math.pi + (i - 1) * (math.pi / 6) + chuyen
                local x = math.cos(goc) * 0.6
                local y = math.sin(goc) * 0.45 - 0.18
                v.CFrame = cf * CFrame.new(x, y, 0) * CFrame.Angles(0, 0, goc)
                v.Transparency = 0.08 + 0.3 * (0.5 + 0.5 * math.sin(t * 4 - i * 0.9))
            end
        end
    end,
}

-- ===== 10. CANDY — KẸO VIÊN LƠ LỬNG ĐỔI MÀU + BONG BÓNG KẸO =====
KHO_PHONG["candy"] = {
    tao = function(handle, skin, phan)
        local MAU_KEO = {
            Color3.fromRGB(255, 150, 200), Color3.fromRGB(255, 240, 250),
            Color3.fromRGB(160, 235, 210), Color3.fromRGB(255, 220, 130),
        }
        local keo = {}
        for i = 1, 4 do
            local k = phongCau("SG_Phong_Keo" .. i, 0.07, MAU_KEO[i], Enum.Material.SmoothPlastic)
            table.insert(phan, k)
            keo[i] = { p = k, goc = i * (math.pi / 2), pha = i * 1.4 }
        end
        local bong = phongHat("SG_Phong_BongKeo", handle, XU_KHOI, Color3.fromRGB(255, 170, 215), { tiLe = 9, tuoiTho = 1.3, tocDo = 0.5, kichThuoc = 0.14, dam = 0.25, giaToc = Vector3.new(0, 2.2, 0) })
        local ruoi = phongHat("SG_Phong_RuoiKeo", handle, XU_SPARK, Color3.fromRGB(255, 235, 245), { tiLe = 8, tuoiTho = 0.8, tocDo = 1.2, kichThuoc = 0.12 })
        table.insert(phan, bong)
        table.insert(phan, ruoi)
        return { keo = keo, MAU_KEO = MAU_KEO }
    end,
    chay = function(handle, d, t, cf)
        for i, k in ipairs(d.keo) do
            if k.p and k.p.Parent then
                local goc = k.goc + t * 0.7
                local x = math.cos(goc) * 0.5
                local z = math.sin(goc) * 0.5
                local y = math.sin(t * 2.4 + k.pha) * 0.22
                k.p.CFrame = cf * CFrame.new(x, y, z)
                local mau1 = d.MAU_KEO[i]
                local mau2 = d.MAU_KEO[(i % 4) + 1]
                k.p.Color = mau1:Lerp(mau2, 0.5 + 0.5 * math.sin(t * 1.2 + k.pha))
            end
        end
    end,
}

-- ===== 11. MATROI — BÁNH XE TIA NẮNG QUAY + LỬA MẶT TRỜI =====
KHO_PHONG["matroi"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mausac or Color3.fromRGB(255, 150, 40)
        local tia = {}
        for i = 1, 8 do
            local s = phongTru("SG_Phong_TiaNang" .. i, 0.45, 0.024, (i % 2 == 0) and mau or Color3.fromRGB(255, 210, 90))
            table.insert(phan, s)
            tia[i] = s
        end
        local lua = phongHat("SG_Phong_LuaNang", handle, XU_LUA, mau, { tiLe = 12, tuoiTho = 0.6, tocDo = 2.2, kichThuoc = 0.2 })
        table.insert(phan, lua)
        return { tia = tia }
    end,
    chay = function(handle, d, t, cf)
        for i, s in ipairs(d.tia) do
            if s and s.Parent then
                local goc = t * 1.5 + i * (math.pi * 2 / 8)
                s.CFrame = cf * CFrame.Angles(0.3, goc, 0) * CFrame.new(0, 0, -0.55) * CFrame.Angles(0, 0, math.pi / 2)
                s.Transparency = 0.15 + 0.4 * (0.5 + 0.5 * math.sin(t * 3.5 - i * 0.8))
            end
        end
    end,
}

-- ===== 12. MUARUNG — LÁ RỪNG LƯỢN + MƯA RƠI + ĐOM ĐÓM =====
KHO_PHONG["muarung"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mausac or Color3.fromRGB(60, 220, 110)
        local la = {}
        for i = 1, 4 do
            local l = phongWedge("SG_Phong_LaRung" .. i, Vector3.new(0.018, 0.09, 0.15), (i % 2 == 0) and mau or Color3.fromRGB(25, 130, 60), 0.1, Enum.Material.SmoothPlastic)
            table.insert(phan, l)
            la[i] = { p = l, goc = i * (math.pi / 2), pha = i * 1.9 }
        end
        local mua = phongHat("SG_Phong_GiotMua", handle, XU_SPARK, Color3.fromRGB(170, 230, 255), { tiLe = 16, tuoiTho = 0.8, tocDo = 0.8, kichThuoc = 0.08, dam = 0.25, giaToc = Vector3.new(0, -7, 0) })
        local dom = phongHat("SG_Phong_DomDem", handle, XU_LUA, mau, { tiLe = 5, tuoiTho = 1.1, tocDo = 0.35, kichThuoc = 0.1 })
        table.insert(phan, mua)
        table.insert(phan, dom)
        return { la = la }
    end,
    chay = function(handle, d, t, cf)
        for _, l in ipairs(d.la) do
            if l.p and l.p.Parent then
                local goc = l.goc + t * 0.45
                local x = math.cos(goc) * 0.5
                local z = math.sin(goc) * 0.5
                local y = math.sin(t * 1.8 + l.pha) * 0.3
                l.p.CFrame = cf * CFrame.new(x, y, z) * CFrame.Angles(math.sin(t * 1.5 + l.pha) * 0.8, goc + t * 0.8, math.cos(t * 1.9 + l.pha) * 0.6)
            end
        end
    end,
}

-- ===== 13. CAT — BÃO CÁT CUỘN 2 TẦNG NGƯỢC CHIỀU + BỤI CÁT =====
KHO_PHONG["cat"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mausac or Color3.fromRGB(220, 185, 120)
        local ngoai, trong = {}, {}
        for i = 1, 8 do
            local h = phongCau("SG_Phong_CatNgoai" .. i, 0.032, (i % 2 == 0) and mau or Color3.fromRGB(240, 210, 150))
            table.insert(phan, h)
            ngoai[i] = h
        end
        for i = 1, 5 do
            local h = phongCau("SG_Phong_CatTrong" .. i, 0.026, mau)
            table.insert(phan, h)
            trong[i] = h
        end
        local bui = phongHat("SG_Phong_BuiCat", handle, XU_KHOI, mau, { tiLe = 13, tuoiTho = 1.1, tocDo = 1.1, kichThuoc = 0.26, dam = 0.5 })
        table.insert(phan, bui)
        return { ngoai = ngoai, trong = trong }
    end,
    chay = function(handle, d, t, cf)
        for i, h in ipairs(d.ngoai) do
            if h and h.Parent then
                local goc = t * 2.2 + i * (math.pi * 2 / 8)
                h.CFrame = cf * CFrame.new(math.cos(goc) * 0.6, math.sin(t * 3.1 + i * 1.2) * 0.35, math.sin(goc) * 0.6)
            end
        end
        for i, h in ipairs(d.trong) do
            if h and h.Parent then
                local goc = -t * 1.5 + i * (math.pi * 2 / 5)
                h.CFrame = cf * CFrame.new(math.cos(goc) * 0.38, math.sin(t * 2.6 + i) * 0.24, math.sin(goc) * 0.38)
            end
        end
    end,
}

-- ===== 14. NUOC — GỢN SÓNG BIỂN DẬP DỀNH + BỌT NƯỚC + GIỌT RƠI =====
KHO_PHONG["nuoc"] = {
    tao = function(handle, skin, phan)
        local mau = skin.mausac or Color3.fromRGB(40, 130, 255)
        local song = {}
        for i = 1, 6 do
            local s = phongCau("SG_Phong_SongNuoc" .. i, 0.06, mau, Enum.Material.Glass, 0.3)
            table.insert(phan, s)
            song[i] = s
        end
        local bot = phongHat("SG_Phong_BotNuoc", handle, XU_SPARK, Color3.fromRGB(210, 240, 255), { tiLe = 10, tuoiTho = 0.7, tocDo = 1.4, kichThuoc = 0.12 })
        local giot = phongHat("SG_Phong_GiotNuoc", handle, XU_KHOI, mau, { tiLe = 6, tuoiTho = 0.9, tocDo = 0.6, kichThuoc = 0.14, dam = 0.35, giaToc = Vector3.new(0, -4.5, 0) })
        table.insert(phan, bot)
        table.insert(phan, giot)
        return { song = song }
    end,
    chay = function(handle, d, t, cf)
        for i, s in ipairs(d.song) do
            if s and s.Parent then
                local goc = t * 1.35 + i * (math.pi / 3)
                local r = 0.52 + math.sin(t * 2.1 + i * 1.05) * 0.06
                s.CFrame = cf * CFrame.new(math.cos(goc) * r, math.sin(t * 2.5 + i * 1.05) * 0.12, math.sin(goc) * r)
                s.Transparency = 0.25 + 0.35 * (0.5 + 0.5 * math.sin(t * 3.2 + i))
            end
        end
    end,
}

-- ===== 15. HELLO KITTY — 2 HUY HIỆU KITTY ẢNH THẬT BAY QUANH + LẤP LÁNH HỒNG =====
-- Dành riêng cho skin "Hello Kitty Pink" (VER 11): dùng đúng 2 ảnh người chơi cung cấp —
-- ảnh 1 rbxassetid 106052405898657 (kitty nơ hồng váy hồng), ảnh 2 rbxassetid 112971377761365
-- (kitty nơ đỏ yếm xanh); mỗi ảnh thành 1 huy hiệu tròn viền hồng (BillboardGui + ImageLabel
-- bo tròn) luôn hướng camera, 2 huy hiệu bay vòng quanh súng ngược chiều nhau dập dềnh theo
-- sóng; kèm sao hồng lấp lánh tỏa quanh thân súng. Cất súng là biến mất, rút ra tự hồi.
KHO_PHONG["hellokitty"] = {
    tao = function(handle, skin, phan)
        local HONG = skin.mauPhu or Color3.fromRGB(255, 82, 165)
        local ANH1 = "rbxassetid://106052405898657"
        local ANH2 = "rbxassetid://112971377761365"
        -- HUY HIỆU KITTY: part trong suốt làm mốc vị trí + BillboardGui ảnh tròn viền hồng
        local function taoHuyHieu(ten, anhId, kichCo)
            local moc = Instance.new("Part")
            moc.Name = ten
            moc.Size = Vector3.new(0.2, 0.2, 0.2)
            moc.Transparency = 1
            moc.Material = Enum.Material.SmoothPlastic
            moc.Color = Color3.new(1, 1, 1)
            phongGop(moc)
            local gui = Instance.new("BillboardGui")
            gui.Name = ten .. "_Anh"
            gui.Adornee = moc
            gui.Size = UDim2.new(kichCo, 0, kichCo, 0)
            gui.StudsOffset = Vector3.new(0, 0, 0)
            gui.AlwaysOnTop = false
            gui.LightInfluence = 0
            gui.Parent = moc
            local anh = Instance.new("ImageLabel")
            anh.Name = "Kitty"
            anh.BackgroundTransparency = 1
            anh.Image = anhId
            anh.Size = UDim2.new(1, 0, 1, 0)
            anh.ScaleType = Enum.ScaleType.Fit
            anh.Parent = gui
            local boGoc = Instance.new("UICorner")
            boGoc.CornerRadius = UDim.new(0.5, 0)
            boGoc.Parent = anh
            local vien = Instance.new("UIStroke")
            vien.Color = HONG
            vien.Thickness = math.max(2, math.floor(kichCo * 2.5))
            vien.Transparency = 0.15
            vien.Parent = anh
            table.insert(phan, moc)
            return moc
        end
        local kitty1 = taoHuyHieu("SG_Phong_KittyAnh1", ANH1, 1.05)
        local kitty2 = taoHuyHieu("SG_Phong_KittyAnh2", ANH2, 0.88)
        -- SAO HỒNG lấp lánh tỏa nhẹ quanh súng làm nền cho 2 huy hiệu
        local sao = phongHat("SG_Phong_KittySao", handle, XU_SPARK, Color3.fromRGB(255, 150, 205), { tiLe = 9, tuoiTho = 1.1, tocDo = 0.8, kichThuoc = 0.16, dam = 0.2 })
        table.insert(phan, sao)
        return { kitty1 = kitty1, kitty2 = kitty2 }
    end,
    chay = function(handle, d, t, cf)
        -- KITTY 1 (ảnh nơ hồng) bay vòng thuận chiều, dập dềnh theo sóng sin
        if d.kitty1 and d.kitty1.Parent then
            local goc = t * 1.15
            local pos = cf * Vector3.new(math.cos(goc) * 1.05, 0.3 + math.sin(t * 2.0) * 0.22, math.sin(goc) * 1.05)
            d.kitty1.CFrame = CFrame.new(pos)
        end
        -- KITTY 2 (ảnh nơ đỏ) bay vòng ngược chiều, lệch pha, cao thấp khác
        if d.kitty2 and d.kitty2.Parent then
            local goc = -t * 0.95 + 2.2
            local pos = cf * Vector3.new(math.cos(goc) * 0.8, 0.12 + math.sin(t * 1.55 + 1.3) * 0.26, math.sin(goc) * 0.8)
            d.kitty2.CFrame = CFrame.new(pos)
        end
    end,
}

-- Gắn / cập nhật / dọn phong cách riêng của skin
local function TaoPhong(handle, skin)
    XoaPhong(handle)
    if not handle or not handle.Parent then return end
    local loai = skin.phongCach
    if not loai or loai == "rong" then return end
    local bo = KHO_PHONG[loai]
    if not bo then return end
    local phan = {}
    local duLieu = bo.tao(handle, skin, phan)
    DANH_SACH_PHONG[handle] = { phan = phan, duLieu = duLieu, bo = bo }
end

local function CapNhatPhong(phong, handle, t)
    if phong and phong.bo and phong.bo.chay then
        pcall(phong.bo.chay, handle, phong.duLieu, t, handle.CFrame)
    end
end

local function XoaHieuUng(handle)
    for _, ten in ipairs({"SG_Glow", "SG_Trail", "SG_A0", "SG_A1", "SG_Particle", "SG_Particle2"}) do
        local o = handle:FindFirstChild(ten)
        if o then o:Destroy() end
    end
    HIEU_UNG[handle] = nil
end

local function TaoHieuUng(handle)
    XoaHieuUng(handle)
    local d = {}
    local skin = SKIN_HIEN_TAI
    local mauHienTai = (skin and skin.mausac) or Color3.fromRGB(0, 255, 200)

    local batGlow = ExtraConfig.SkinGlow or (skin and skin.glow) or false
    if batGlow then
        local den = Instance.new("PointLight")
        den.Name = "SG_Glow"
        den.Color = mauHienTai
        den.Brightness = 3
        den.Range = 16
        den.Parent = handle
        d.Light = den
    end

    local batTrail = ExtraConfig.SkinTrail or (skin and skin.trail) or false
    if batTrail then
        local a0 = Instance.new("Attachment")
        a0.Name = "SG_A0"
        a0.Position = Vector3.new(0, handle.Size.Y * 0.5, 0)
        a0.Parent = handle
        local a1 = Instance.new("Attachment")
        a1.Name = "SG_A1"
        a1.Position = Vector3.new(0, -handle.Size.Y * 0.5, 0)
        a1.Parent = handle
        local trail = Instance.new("Trail")
        trail.Name = "SG_Trail"
        trail.Attachment0 = a0
        trail.Attachment1 = a1
        trail.Lifetime = 0.35
        trail.LightEmission = 1
        trail.FaceCamera = true
        trail.Color = ColorSequence.new(mauHienTai)
        trail.Transparency = NumberSequence.new(0.1, 1)
        trail.WidthScale = NumberSequence.new(1, 0.15)
        trail.Parent = handle
        d.Trail = trail
    end

    -- HẠT CHÍNH: ưu tiên hạt chọn tay, không chọn thì dùng hạt RIÊNG của skin
    local tenHat = ExtraConfig.SkinParticle
    if (not tenHat or tenHat == "TẮT") and skin and skin.hat then
        tenHat = skin.hat
    end
    if tenHat and tenHat ~= "TẮT" and KHO_HAT[tenHat] then
        local pre = KHO_HAT[tenHat]
        local mauHat = pre.mau
        if skin and skin.hat and tenHat == skin.hat and skin.hatMau then
            mauHat = skin.hatMau
        end
        local hat = Instance.new("ParticleEmitter")
        hat.Name = "SG_Particle"
        hat.Texture = pre.texture
        hat.Color = ColorSequence.new(mauHat)
        hat.Rate = pre.tiLe
        hat.Lifetime = NumberRange.new(pre.tuoiTho * 0.6, pre.tuoiTho)
        hat.Speed = NumberRange.new(pre.tocDo * 0.5, pre.tocDo)
        hat.SpreadAngle = Vector2.new(180, 180)
        hat.Size = NumberSequence.new(pre.kichThuoc, 0)
        hat.Transparency = NumberSequence.new(0.15, 1)
        hat.LightEmission = 1
        hat.LightInfluence = 0
        hat.Rotation = NumberRange.new(0, 360)
        hat.RotSpeed = NumberRange.new(-120, 120)
        hat.EmissionDirection = Enum.NormalId.Top
        hat.Parent = handle
        d.Emitter = hat
    end

    -- HẠT PHỤ (HIỆU ỨNG KÉP): skin mạnh tự mang lớp hạt thứ 2
    if skin and skin.hat2 and KHO_HAT[skin.hat2] then
        local pre2 = KHO_HAT[skin.hat2]
        local hat2 = Instance.new("ParticleEmitter")
        hat2.Name = "SG_Particle2"
        hat2.Texture = pre2.texture
        hat2.Color = ColorSequence.new(skin.hat2Mau or pre2.mau)
        hat2.Rate = math.floor(pre2.tiLe * 0.5)
        hat2.Lifetime = NumberRange.new(pre2.tuoiTho * 0.5, pre2.tuoiTho * 0.8)
        hat2.Speed = NumberRange.new(pre2.tocDo * 0.8, pre2.tocDo * 1.6)
        hat2.SpreadAngle = Vector2.new(180, 180)
        hat2.Size = NumberSequence.new(pre2.kichThuoc * 0.6, 0)
        hat2.Transparency = NumberSequence.new(0.1, 1)
        hat2.LightEmission = 1
        hat2.LightInfluence = 0
        hat2.Rotation = NumberRange.new(0, 360)
        hat2.RotSpeed = NumberRange.new(-120, 120)
        hat2.EmissionDirection = Enum.NormalId.Top
        hat2.Parent = handle
        d.Emitter2 = hat2
    end

    HIEU_UNG[handle] = d
end

-- ===== VER 10: DÁN ẢNH SKIN THẬT LÊN THÂN SÚNG (Hello Kitty Pink) =====
-- skin.anh = rbxassetid ảnh (Hello Kitty 113401407955058) -> Texture dán 6 MẶT
-- mọi part thân súng + viewmodel góc nhìn 1; part vô hình bỏ qua;
-- đổi skin / tắt skin / khôi phục -> gỡ sạch texture SG_Anh
local function XoaAnhSkin()
    for _, p in ipairs(DANH_SACH_PART) do
        local anhCu = p:FindFirstChild("SG_Anh")
        if anhCu then anhCu:Destroy() end
    end
end

local function DatAnhSkin(p, skin)
    local anhCu = p:FindFirstChild("SG_Anh")
    if anhCu then anhCu:Destroy() end
    if not skin.anh then return end
    local goc = LUU_GOC[p]
    if goc and goc.Transparency >= 0.95 then return end
    local co = skin.anhCo or 1.5
    for _, mat in ipairs({Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right}) do
        local t = Instance.new("Texture")
        t.Name = "SG_Anh"
        t.Texture = skin.anh
        t.Face = mat
        t.StudsPerTileU = co
        t.StudsPerTileV = co
        t.Transparency = 0.05
        t.Parent = p
    end
end

local function ApVatLieuSkin(p, skin)
    LuuGocPart(p)
    p.Material = skin.vatlieu or Enum.Material.SmoothPlastic
    p.Reflectance = skin.phanChieu or 0
    local goc = LUU_GOC[p]
    if goc and goc.Transparency >= 0.95 then
        p.Transparency = goc.Transparency  -- grip vô hình giữ nguyên vô hình
    else
        p.Transparency = skin.trongSuot or 0
    end
    if not ExtraConfig.GunSkinRainbow then
        -- 3 TÔNG MÀU VER 5: ~14% vân TỐI + ~21% màu NHẤN + còn lại màu CHÍNH
        -- -> súng có đường vân panel như skin thiết kế thật, hết phẳng chát
        local bam = BamTenPart(p)
        if skin.mauToi and bam % 7 == 0 then
            ToMauPart(p, skin.mauToi)
        elseif skin.mauPhu and bam % 4 == 0 then
            ToMauPart(p, skin.mauPhu)
        else
            ToMauPart(p, skin.mausac or p.Color)
        end
    end
    DatAnhSkin(p, skin)
end

-- ===== VER 9: VIỀN SÁNG OUTLINE + SÓNG MÀU — SKIN ĐẸP BẰNG CHẤT TỰ THÂN =====
-- KHÔNG gắn phụ kiện nào lên súng nữa; skin đẹp bằng:
--   * VIỀN SÁNG: Highlight bao trùm nguyên khẩu súng màu skin, viền THỞ nhẹ theo nhịp
--   * SÓNG MÀU: màu chảy mềm dọc thân súng, GIỮ VÂN PANEL TỐI -> vẫn có khối, không phẳng
local DANH_SACH_VIEN = {}   -- [model] = Highlight đang gắn

local function XoaHetVien()
    for mo, hl in pairs(DANH_SACH_VIEN) do
        pcall(function() hl:Destroy() end)
        DANH_SACH_VIEN[mo] = nil
    end
end

local function CapNhatMotVien(mo, mau, mauPhu)
    local hl = DANH_SACH_VIEN[mo]
    if not hl or not hl.Parent then
        if hl then pcall(function() hl:Destroy() end) end
        hl = Instance.new("Highlight")
        hl.Name = "SG_Vien"
        hl.DepthMode = Enum.HighlightDepthMode.Occluded
        hl.Parent = mo
        DANH_SACH_VIEN[mo] = hl
    end
    hl.FillColor = mau
    hl.FillTransparency = 0.86
    hl.OutlineColor = mauPhu
    hl.OutlineTransparency = 0.12
end

local function CapNhatVienSung()
    -- dọn viền của model đã mất
    for mo, hl in pairs(DANH_SACH_VIEN) do
        if not mo.Parent then
            pcall(function() hl:Destroy() end)
            DANH_SACH_VIEN[mo] = nil
        end
    end
    if not (ExtraConfig.GunSkin and SKIN_HIEN_TAI) or ExtraConfig.SkinVien == false then
        XoaHetVien()
        return
    end
    local skin = SKIN_HIEN_TAI
    local mau    = skin.mausac or Color3.fromRGB(255, 200, 40)
    local mauPhu = skin.mauPhu or mau
    -- viền từng khẩu súng cầm tay (tool là Model con nên Highlight gắn thẳng)
    for _, handle in ipairs(DANH_SACH_HANDLE) do
        local cha = handle.Parent
        if cha and cha.Parent == LocalPlayer.Character then
            local mo = cha:IsA("Model") and cha or handle
            CapNhatMotVien(mo, mau, mauPhu)
        end
    end
    -- viền viewmodel góc nhìn 1 - khẩu súng mình NHÌN NHIỀU NHẤT
    local cam = workspace.CurrentCamera
    if cam then
        for _, con in ipairs(cam:GetChildren()) do
            if con:IsA("Model") then
                CapNhatMotVien(con, mau, mauPhu)
            end
        end
    end
end

local function ApSkinVip()
    if not ExtraConfig.GunSkin then return end
    local skin = KHO_SKIN[ExtraConfig.GunSkinName]
    if not skin then return end
    SKIN_HIEN_TAI = skin
    ExtraConfig.GunSkinRainbow = skin.rainbow and true or false

    DANH_SACH_HANDLE = LayHandleSung()
    DANH_SACH_PART = LayPartSung()
    NoiDanhSach(DANH_SACH_PART, LayPartViewModel())

    for _, handle in ipairs(DANH_SACH_HANDLE) do
        TaoHieuUng(handle)
        if skin.rong then
            TaoRong(handle, skin)      -- RỒNG THIÊN LONG VER 4 siêu chi tiết
        else
            XoaRong(handle)
        end
        if skin.aura and not skin.rong then
            TaoAura(handle, skin)      -- aura 2 vòng + vệt trail (skin rồng bỏ, rồng thay thế)
        else
            XoaAura(handle)
        end
        if skin.aura and not skin.rong and ExtraConfig.SkinVong ~= false then
            TaoVong(handle, skin)      -- vòng gyroscope + 3 cầu helix
        else
            XoaVong(handle)
        end
        -- VER 9: hiệu ứng phong cách RIÊNG của từng skin
        if skin.phongCach and skin.phongCach ~= "rong" and ExtraConfig.SkinPhong ~= false then
            TaoPhong(handle, skin)
        else
            XoaPhong(handle)
        end
    end
    for _, p in ipairs(DANH_SACH_PART) do
        ApVatLieuSkin(p, skin)
    end
    -- VER 8: viền sáng cập nhật theo skin mới
    CapNhatVienSung()
end

local function KhoiPhucSung()
    SKIN_HIEN_TAI = nil
    ExtraConfig.GunSkinRainbow = false
    for _, p in ipairs(DANH_SACH_PART) do
        local goc = LUU_GOC[p]
        if goc then
            pcall(function()
                p.Material = goc.Material
                p.Color = goc.Color
                p.Transparency = goc.Transparency
                p.Reflectance = goc.Reflectance
                if goc.KichThuoc then p.Size = goc.KichThuoc end
                if goc.TextureID and p:IsA("MeshPart") then p.TextureID = goc.TextureID end
                if goc.Mesh then
                    if goc.MeshTextureId then goc.Mesh.TextureId = goc.MeshTextureId end
                    if goc.VertexColor then goc.Mesh.VertexColor = goc.VertexColor end
                end
            end)
        end
    end
    for _, handle in ipairs(DANH_SACH_HANDLE) do
        XoaHieuUng(handle)
        XoaPhong(handle)
        XoaRong(handle)
        XoaAura(handle)
        XoaVong(handle)
    end
    XoaAnhSkin()
    XoaHetVien()
end

local function QuetVaApDung()
    pcall(function()
        -- Handle neo hiệu ứng
        for _, handle in ipairs(LayHandleSung()) do
            local daCo = false
            for _, h in ipairs(DANH_SACH_HANDLE) do
                if h == handle then daCo = true break end
            end
            if not daCo then
                table.insert(DANH_SACH_HANDLE, handle)
                if ExtraConfig.GunSkin and SKIN_HIEN_TAI then
                    TaoHieuUng(handle)
                    if SKIN_HIEN_TAI.rong then
                        TaoRong(handle, SKIN_HIEN_TAI)
                    end
                    if SKIN_HIEN_TAI.aura and not SKIN_HIEN_TAI.rong then
                        TaoAura(handle, SKIN_HIEN_TAI)
                    end
                    if SKIN_HIEN_TAI.aura and not SKIN_HIEN_TAI.rong and ExtraConfig.SkinVong ~= false then
                        TaoVong(handle, SKIN_HIEN_TAI)
                    end
                    if SKIN_HIEN_TAI.phongCach and SKIN_HIEN_TAI.phongCach ~= "rong" and ExtraConfig.SkinPhong ~= false then
                        TaoPhong(handle, SKIN_HIEN_TAI)
                    end
                end
            end
        end
        -- Part thân súng + viewmodel (tô skin)
        local moi = LayPartSung()
        NoiDanhSach(moi, LayPartViewModel())
        for _, p in ipairs(moi) do
            local daCo = false
            for _, q in ipairs(DANH_SACH_PART) do
                if q == p then daCo = true break end
            end
            if not daCo then
                table.insert(DANH_SACH_PART, p)
                if ExtraConfig.GunSkin and SKIN_HIEN_TAI then
                    ApVatLieuSkin(p, SKIN_HIEN_TAI)
                end
            end
        end
        -- VER 8: rút súng mới / viewmodel mới -> gắn viền sáng cho model thiếu
        CapNhatVienSung()
    end)
end

MiscTab:AddToggle("Skin Súng VIP + Hiệu Ứng (39 Skin VER 11)", false, function(state)
    ExtraConfig.GunSkin = state
    if state then
        ApSkinVip()
    else
        KhoiPhucSung()
    end
end)

MiscTab:AddDropdown("Chọn Skin Súng", {"Máu Đỏ Blood", "Hồng Neon", "Cam Solar", "Vàng Gold", "Xanh Mint", "Xanh Electric", "Tím Galaxy", "Trắng Ngọc", "Cầu Vòng 7 Màu", "Holy White", "Holy Tím", "Pha Lê Băng", "Vàng Kim Cương", "Thép Galvanized", "Xanh Độc Toxic", "Lava Địa Ngục", "Bão Băng Tuyết", "Sét Thiên Thần", "Huyết Nguyệt", "Bầu Trời Sao Rơi", "Ánh Trăng Bạc", "Rừng Mưa Nhiệt Đới", "Bão Cát Sa Mạc", "Tím Neon Nhiệt Đới", "Chaos Núi Lửa Đen", "Kẹo Bông Ngọt Ngào", "Pha Lê Vũ Trụ", "Kính Bạc Lấp Lánh", "Nọc Rắn Vàng Lục", "Hải Vương Xanh Đậm", "Cương Huyết Tím Đẫm", "Ánh Sáng Thiêng Liêng", "Rồng Lửa Đỏ", "Rồng Băng Lam", "Rồng Vàng Hoàng Gia", "Rồng Tím Thần Bí", "Hắc Long Đen Vực", "Rồng Ngọc Bảo Xanh", "Hello Kitty Pink"}, "Vàng Gold", function(choice)
    ExtraConfig.GunSkinName = choice
    if ExtraConfig.GunSkin then ApSkinVip() end
end)

MiscTab:AddDropdown("Hiệu Ứng Hạt Bọc Súng", {"TẮT", "SAO", "LỬA", "BỤI VÀNG", "TÍM", "BĂNG", "SÉT"}, "TẮT", function(choice)
    ExtraConfig.SkinParticle = choice
    if ExtraConfig.GunSkin then
        for _, handle in ipairs(DANH_SACH_HANDLE) do
            TaoHieuUng(handle)
        end
    end
end)

MiscTab:AddToggle("Glow - Ánh Sáng Tỏa Quanh Súng", false, function(state)
    ExtraConfig.SkinGlow = state
    if ExtraConfig.GunSkin then
        for _, handle in ipairs(DANH_SACH_HANDLE) do
            TaoHieuUng(handle)
        end
    end
end)

MiscTab:AddToggle("Trail - Vệt Sáng Khi Vung Súng", false, function(state)
    ExtraConfig.SkinTrail = state
    if ExtraConfig.GunSkin then
        for _, handle in ipairs(DANH_SACH_HANDLE) do
            TaoHieuUng(handle)
        end
    end
end)

MiscTab:AddToggle("Pulse - Súng Phồng Xẹp Theo Nhịp", false, function(state)
    ExtraConfig.SkinPulse = state
    if not state then
        for _, handle in ipairs(DANH_SACH_HANDLE) do
            local goc = LUU_GOC[handle]
            if goc and goc.KichThuoc then
                pcall(function() handle.Size = goc.KichThuoc end)
            end
        end
    end
end)

MiscTab:AddSlider("Tốc Độ Cầu Vòng (x0.1 - x3)", 1, 30, 10, function(v)
    ExtraConfig.SkinTocDo = v / 10
end)

MiscTab:AddToggle("Vòng Năng Lượng Gyroscope + Helix (VER 5)", true, function(state)
    ExtraConfig.SkinVong = state
    if ExtraConfig.GunSkin then ApSkinVip() end
end)

MiscTab:AddSlider("Kích Thước Rồng (x0.5 - x3)", 5, 30, 12, function(v)
    ExtraConfig.RongScale = v / 10
    if ExtraConfig.GunSkin and SKIN_HIEN_TAI and SKIN_HIEN_TAI.rong then
        for _, handle in ipairs(DANH_SACH_HANDLE) do
            TaoRong(handle, SKIN_HIEN_TAI)
        end
    end
end)

MiscTab:AddToggle("Viền Sáng Outline Bao Súng (VER 9)", true, function(state)
    ExtraConfig.SkinVien = state
    if ExtraConfig.GunSkin then
        if state then
            CapNhatVienSung()
        else
            XoaHetVien()
        end
    end
end)

MiscTab:AddToggle("Sóng Màu Chảy Trên Súng (VER 9)", true, function(state)
    ExtraConfig.SkinSongMau = state
    if ExtraConfig.GunSkin and SKIN_HIEN_TAI and not state then
        ApSkinVip()      -- tắt sóng màu -> tô lại màu tĩnh 3 tông
    end
end)

MiscTab:AddToggle("Phong Cách Riêng Mỗi Skin (VER 9)", true, function(state)
    ExtraConfig.SkinPhong = state
    if ExtraConfig.GunSkin then ApSkinVip() end
end)

-- Vòng lặp cầu vòng + SÓNG MÀU + viền thở + glow + pulse + rồng + phong cách (VER 9)
local MauCauVong = Color3.fromRGB(0, 255, 200)
local thoiGian = 0
RunService.Heartbeat:Connect(function(delta)
    thoiGian = thoiGian + (delta * ExtraConfig.SkinTocDo)
    local rainbow = ExtraConfig.GunSkinRainbow
    if rainbow then
        MauCauVong = Color3.fromHSV(thoiGian % 1, 1, 1)
    end
    local t = os.clock()

    -- VER 8: tô màu cầu vòng HOẶC SÓNG MÀU chảy mềm trên thân súng
    local skinDangAp = (ExtraConfig.GunSkin and SKIN_HIEN_TAI) or nil
    for i = #DANH_SACH_PART, 1, -1 do
        local p = DANH_SACH_PART[i]
        if not p.Parent then
            table.remove(DANH_SACH_PART, i)
        else
            if rainbow then
                ToMauPart(p, MauCauVong)
            elseif skinDangAp and skinDangAp.mausac and ExtraConfig.SkinSongMau ~= false and not skinDangAp.rainbow then
                local bam = BamTenPart(p)
                if skinDangAp.mauToi and bam % 7 == 0 then
                    -- giữ vân TỐI -> súng vẫn có khối panel, không phẳng chát
                elseif skinDangAp.mauPhu and bam % 4 == 0 then
                    ToMauPart(p, skinDangAp.mauPhu)
                else
                    local pha = (bam % 12) / 12
                    local song = 0.5 + 0.5 * math.sin(thoiGian * 1.7 - pha * 2.6)
                    ToMauPart(p, skinDangAp.mausac:Lerp(skinDangAp.mauPhu or skinDangAp.mausac, song * 0.6))
                end
            end
        end
    end

    -- hiệu ứng + pulse + rồng + aura gắn trên Handle
    for i = #DANH_SACH_HANDLE, 1, -1 do
        local handle = DANH_SACH_HANDLE[i]
        if not handle.Parent then
            XoaPhong(handle)
            XoaRong(handle)
            XoaAura(handle)
            XoaVong(handle)
            table.remove(DANH_SACH_HANDLE, i)
        else
            local toolCha = handle.Parent
            local daCam = toolCha and toolCha.Parent == LocalPlayer.Character
            if not daCam then
                -- VER 9: CẤT SÚNG -> TOÀN BỘ HIỆU ỨNG BIẾN MẤT NGAY
                if DANH_SACH_PHONG[handle] or DANH_SACH_RONG[handle] or DANH_SACH_AURA[handle] or DANH_SACH_VONG[handle] or HIEU_UNG[handle] then
                    XoaPhong(handle)
                    XoaRong(handle)
                    XoaAura(handle)
                    XoaVong(handle)
                    XoaHieuUng(handle)
                end
                local moCat = toolCha:IsA("Model") and toolCha or nil
                if moCat and DANH_SACH_VIEN[moCat] then
                    pcall(function() DANH_SACH_VIEN[moCat]:Destroy() end)
                    DANH_SACH_VIEN[moCat] = nil
                end
            else
                -- VER 9: RÚT SÚNG LẠI -> tự tạo lại hiệu ứng còn thiếu
                if not HIEU_UNG[handle] and ExtraConfig.GunSkin and SKIN_HIEN_TAI then
                    TaoHieuUng(handle)
                    if SKIN_HIEN_TAI.rong then TaoRong(handle, SKIN_HIEN_TAI) end
                    if SKIN_HIEN_TAI.aura and not SKIN_HIEN_TAI.rong then TaoAura(handle, SKIN_HIEN_TAI) end
                    if SKIN_HIEN_TAI.aura and not SKIN_HIEN_TAI.rong and ExtraConfig.SkinVong ~= false then TaoVong(handle, SKIN_HIEN_TAI) end
                    if SKIN_HIEN_TAI.phongCach and SKIN_HIEN_TAI.phongCach ~= "rong" and ExtraConfig.SkinPhong ~= false then TaoPhong(handle, SKIN_HIEN_TAI) end
                end
            local d = HIEU_UNG[handle]
            -- GLOW THỞ: sáng tối theo nhịp -> súng như đang "thở" ánh sáng
            if d and d.Light then
                d.Light.Brightness = 2.6 + math.sin(t * 5) * 1.2
                if rainbow then d.Light.Color = MauCauVong end
            end
            if d and rainbow then
                if d.Trail then d.Trail.Color = ColorSequence.new(MauCauVong) end
            end
            if ExtraConfig.SkinPulse then
                local goc = LUU_GOC[handle]
                if goc and goc.KichThuoc then
                    handle.Size = goc.KichThuoc * (1 + 0.05 * math.sin(thoiGian * 4))
                end
            end
            -- RỒNG THIÊN LONG VER 4 bay vòng quanh súng (skin rồng)
            local rong = DANH_SACH_RONG[handle]
            if rong then
                if rainbow then
                    for _, obj in ipairs(rong.phan) do
                        if obj:IsA("BasePart") then obj.Color = MauCauVong end
                    end
                end
                CapNhatRong(handle, rong)
            end
            -- AURA 2 vòng xoay quanh súng (VER 4)
            local aura = DANH_SACH_AURA[handle]
            if aura then
                if rainbow then
                    for _, obj in ipairs(aura.ngoai) do obj.Color = MauCauVong end
                    for _, obj in ipairs(aura.trong) do obj.Color = MauCauVong end
                    if aura.trails then
                        for _, tl in ipairs(aura.trails) do tl.Color = ColorSequence.new(MauCauVong) end
                    end
                end
                CapNhatAura(handle, aura)
            end
            -- VÒNG GYROSCOPE + HELIX VER 5 xoay quanh súng
            local vong = DANH_SACH_VONG[handle]
            if vong then
                if rainbow then
                    for _, obj in ipairs(vong.dia) do obj.Color = MauCauVong end
                    for _, obj in ipairs(vong.helix) do obj.Color = MauCauVong end
                end
                CapNhatVong(handle, vong)
            end
            -- VER 9: hiệu ứng phong cách riêng chạy theo khung hình
            local phong = DANH_SACH_PHONG[handle]
            if phong then
                CapNhatPhong(phong, handle, t)
            end
            end
        end
    end
    -- VER 8: viền sáng THỞ nhẹ theo nhịp + dọn viền model đã mất
    for mo, hl in pairs(DANH_SACH_VIEN) do
        if not mo.Parent or (mo:IsA("Tool") and mo.Parent ~= LocalPlayer.Character) then
            pcall(function() hl:Destroy() end)
            DANH_SACH_VIEN[mo] = nil
        else
            if rainbow then
                hl.OutlineColor = MauCauVong
                hl.FillColor = MauCauVong
            end
            hl.OutlineTransparency = 0.1 + 0.1 * (0.5 + 0.5 * math.sin(t * 2.4))
        end
    end
end)

-- Tự gắn lại skin khi rút súng mới / respawn / viewmodel mới
local function HookSkin(char)
    char.ChildAdded:Connect(function(con)
        if con:IsA("Tool") and ExtraConfig.GunSkin then
            task.delay(0.3, QuetVaApDung)
        end
    end)
end
if LocalPlayer.Character then
    HookSkin(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    DANH_SACH_HANDLE = {}
    DANH_SACH_PART = {}
    XoaHetVien()
    task.delay(1, function()
        QuetVaApDung()
        HookSkin(char)
    end)
end)

task.spawn(function()
    while task.wait(2) do
        if ExtraConfig.GunSkin then
            QuetVaApDung()
        end
    end
end)

local function HookCamera(cam)
    cam.DescendantAdded:Connect(function()
        if ExtraConfig.GunSkin then
            task.delay(0.25, QuetVaApDung)
        end
    end)
end
if workspace.CurrentCamera then
    HookCamera(workspace.CurrentCamera)
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then
        HookCamera(workspace.CurrentCamera)
    end
end)

--================================================
-- 7) HIỆU ỨNG KHI HẠ GỤC ĐỊCH (KILL EFFECT VER 5 — HÌNH TRÒN MƯỢT CAO CẤP)
--    VER 5: XÓA SẠCH HÌNH VUÔNG — sét/vệt chém dùng BEAM tròn mượt, gai dart trụ tròn + chóp cầu,
--    mảnh vụn cầu tròn, cột lửa trụ tròn — toàn bộ chỉ còn hình tròn/cầu/trụ
--    VER 4 nâng cấp mạnh so với VER 3:
--    * CHỚP MÀN HÌNH điện ảnh khi nổ (ScreenGui local — an toàn, tắt được trong UI)
--    * GAI NĂNG LƯỢNG bắn tỏa 360° — vụ nổ có "gai" sắc như game AAA, hết nhìn tròn chán
--    * HẠT HÚT NGƯỢC VÀO TÂM trước khi nổ — tụ năng lượng thật sự
--    * XOAY TIN: vòng năng lượng xoay lăn tăn thay vì đứng im chết
--    * 14 HIỆU ỨNG = 8 hiệu ứng cũ nâng cấp + 6 HIỆU ỨNG MỚI HOÀN TOÀN:
--       Song Kiếm Chém Chớp / Sao Băng Tán Loạn / Băng Tinh Phong Ấn /
--       Hoa Anh Đào Nở Rộ / Lốc Xoáy Hư Không / Đoạt Hồn Lưu Ly
--    DÒ KILL: tag creator chuẩn + ObjectValue + attribute Killer/LastAttacker...
--    Âm thanh dùng file CÓ SẴN trong Roblox -> không bao giờ lỗi.
--================================================

ExtraConfig.KillEffect        = false                  -- BẬT/TẮT hiệu ứng hạ gục
ExtraConfig.KillEffectName    = "Nổ Lõi Hủy Diệt"      -- kiểu hiệu ứng đang chọn
ExtraConfig.KillEffectChiMinh = true                   -- CHỈ nổ khi MÌNH hạ nó
ExtraConfig.KillEffectAmThanh = true                   -- có âm thanh kèm theo
ExtraConfig.KillEffectFlash   = true                   -- chớp màn hình điện ảnh

local Debris = game:GetService("Debris")

-- Texture hạt CÓ SẴN trong Roblox — không tải gì cả
local TEX_SAO  = "rbxasset://textures/particles/sparkles_main.dds"
local TEX_LUA  = "rbxasset://textures/particles/fire_main.dds"
local TEX_KHOI = "rbxasset://textures/particles/smoke_main.dds"

-- Âm thanh dùng file CÓ SẴN trong Roblox — không cần tải, không bao giờ lỗi
local KHO_AM_THANH = {
    ["boom"]  = "rbxasset://sounds/bass.wav",
    ["ping"]  = "rbxasset://sounds/electronicpingshort.wav",
    ["snap"]  = "rbxasset://sounds/snap.mp3",
    ["shing"] = "rbxasset://sounds/unsheath.wav",
    ["oof"]   = "rbxasset://sounds/uuhhh.mp3",
}

-- Part hiệu ứng: tự hủy sau vài giây, không đụng chạm gì
local function taoPartHU(ten, kichThuoc, mau, vatLieu, trongSuot, viTri)
    local p = Instance.new("Part")
    p.Name = ten
    p.Size = kichThuoc
    p.CFrame = CFrame.new(viTri)
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Material = vatLieu or Enum.Material.Neon
    p.Color = mau or Color3.fromRGB(255, 255, 255)
    p.Transparency = trongSuot or 0
    p.Parent = workspace
    Debris:AddItem(p, 6)
    return p
end

-- Phát âm thanh 3D tại vị trí hạ gục
local function PhatAmThanh(ten, viTri, tocDo)
    if not ExtraConfig.KillEffectAmThanh then return end
    local duongDan = KHO_AM_THANH[ten]
    if not duongDan then return end
    pcall(function()
        local neo = taoPartHU("HU_AmThanh", Vector3.new(0.2, 0.2, 0.2), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, 1, viTri)
        local s = Instance.new("Sound")
        s.SoundId = duongDan
        s.Volume = 2
        s.PlaybackSpeed = tocDo or 1
        s.Parent = neo
        s:Play()
    end)
end

-- RUNG MÀN HÌNH: giật camera nhẹ dần rồi về 0 (dùng Humanoid.CameraOffset — an toàn)
local function LacManHinh(doManh)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or doManh <= 0 then return end
    task.spawn(function()
        local t0 = os.clock()
        local thoiLuong = 0.38
        while os.clock() - t0 < thoiLuong do
            local giam = (1 - (os.clock() - t0) / thoiLuong) * doManh
            if not hum.Parent then break end
            hum.CameraOffset = Vector3.new((math.random() - 0.5) * giam, (math.random() - 0.5) * giam, (math.random() - 0.5) * giam)
            RunService.Heartbeat:Wait()
        end
        pcall(function() hum.CameraOffset = Vector3.new(0, 0, 0) end)
    end)
end

-- CHỚP MÀN HÌNH (MỚI VER 4): phủ 1 lớp màu toàn màn hình rồi tan trong 0.3s — điện ảnh
local guiChopDang = nil
local function ChopManHinh(mau, doDam)
    if not ExtraConfig.KillEffectFlash then return end
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        if guiChopDang and guiChopDang.Parent then guiChopDang:Destroy() end
        local gui = Instance.new("ScreenGui")
        gui.Name = "HU_ChopManHinh"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 999
        local khung = Instance.new("Frame")
        khung.Size = UDim2.new(1, 0, 1, 0)
        khung.BackgroundColor3 = mau
        khung.BackgroundTransparency = doDam or 0.6
        khung.BorderSizePixel = 0
        khung.Parent = gui
        gui.Parent = pg
        guiChopDang = gui
        TweenService:Create(khung, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}):Play()
        task.delay(0.35, function()
            pcall(function() gui:Destroy() end)
            if guiChopDang == gui then guiChopDang = nil end
        end)
    end)
end

-- Emitter burst 1 lần (nổ rồi thôi, không xả liên tục)
local function taoBurst(part, texture, mau, tocDoMin, tocDoMax, tuoiMin, tuoiMax, kichThuoc, trongLuc)
    local pe = Instance.new("ParticleEmitter")
    pe.Name = "HU_Burst"
    pe.Texture = texture
    pe.Color = ColorSequence.new(mau)
    pe.Rate = 0
    pe.Speed = NumberRange.new(tocDoMin, tocDoMax)
    pe.Lifetime = NumberRange.new(tuoiMin, tuoiMax)
    pe.SpreadAngle = Vector2.new(180, 180)
    pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, kichThuoc), NumberSequenceKeypoint.new(1, 0)})
    pe.Transparency = NumberSequence.new(0.05, 1)
    pe.LightEmission = 1
    pe.LightInfluence = 0
    pe.Rotation = NumberRange.new(0, 360)
    pe.RotSpeed = NumberRange.new(-150, 150)
    if trongLuc then pe.Acceleration = trongLuc end
    pe.Parent = part
    return pe
end

-- Đèn chớp sáng rồi tắt dần
local function taoDenChop(cha, mau, doSang, tamVuong)
    local den = Instance.new("PointLight")
    den.Color = mau
    den.Brightness = doSang
    den.Range = tamVuong
    den.Parent = cha
    TweenService:Create(den, TweenInfo.new(0.6), {Brightness = 0}):Play()
    return den
end

-- Cầu sáng nở to rồi tắt (xương sống của mọi vụ nổ)
local function cauNo(viTri, mau, kichMax, thoiGian)
    local cau = taoPartHU("HU_CauNo", Vector3.new(0.6, 0.6, 0.6), mau, Enum.Material.Neon, 0.05, viTri)
    cau.Shape = Enum.PartType.Ball
    TweenService:Create(cau, TweenInfo.new(thoiGian or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = Vector3.new(kichMax, kichMax, kichMax), Transparency = 1}):Play()
    taoDenChop(cau, mau, 8, kichMax * 2)
    return cau
end

-- Vòng sóng đĩa dẹt lan ra mặt đất (có trễ để nhiều vòng lệch pha)
local function vongSong(dat, mau, kichMax, thoiGian, tre)
    local vong = taoPartHU("HU_Vong", Vector3.new(0.35, 2, 2), mau, Enum.Material.Neon, 0.25, dat)
    vong.Shape = Enum.PartType.Cylinder
    vong.CFrame = CFrame.new(dat) * CFrame.Angles(0, 0, math.rad(90))
    task.delay(tre or 0, function()
        if vong.Parent then
            TweenService:Create(vong, TweenInfo.new(thoiGian, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = Vector3.new(0.35, kichMax, kichMax), Transparency = 1,
                 CFrame = CFrame.new(dat + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))}):Play()
        end
    end)
end

-- VÀNH ĐỨNG DỌC: vòng tròn thẳng đứng nở ra như vòm năng lượng lan tỏa (trả part để xoay)
local function vongDung(viTri, mau, kichMax, thoiGian, quay)
    local vong = taoPartHU("HU_VongDung", Vector3.new(0.25, 2, 2), mau, Enum.Material.Neon, 0.2, viTri)
    vong.Shape = Enum.PartType.Cylinder
    vong.CFrame = CFrame.new(viTri) * CFrame.Angles(0, quay or 0, 0)
    TweenService:Create(vong, TweenInfo.new(thoiGian, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = Vector3.new(0.25, kichMax, kichMax), Transparency = 1}):Play()
    return vong
end

-- BEAM NĂNG LƯỢNG (MỚI VER 5): vệt sáng TRÒN MƯỢT nối 2 điểm + lõi trắng trong — thay block vuông
local function taoBeam(p0, p1, mau, day, tuoi, mauLoi)
    local neo = taoPartHU("HU_BeamNeo", Vector3.new(0.15, 0.15, 0.15), mau, Enum.Material.Neon, 1, p0)
    local a0 = Instance.new("Attachment")
    a0.Parent = neo
    local a1 = Instance.new("Attachment")
    a1.Position = p1 - p0
    a1.Parent = neo
    tuoi = tuoi or 0.4
    local danhSach = {}
    local beam = Instance.new("Beam")
    beam.Name = "HU_Beam"
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.FaceCamera = true
    beam.Segments = 1
    beam.Width0 = day
    beam.Width1 = day * 0.6
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Color = ColorSequence.new(mau)
    beam.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.8, 0.5), NumberSequenceKeypoint.new(1, 1)})
    beam.Parent = neo
    table.insert(danhSach, beam)
    if mauLoi then
        local loi = Instance.new("Beam")
        loi.Name = "HU_BeamLoi"
        loi.Attachment0 = a0
        loi.Attachment1 = a1
        loi.FaceCamera = true
        loi.Segments = 1
        loi.Width0 = day * 0.42
        loi.Width1 = day * 0.22
        loi.LightEmission = 1
        loi.LightInfluence = 0
        loi.Color = ColorSequence.new(mauLoi)
        loi.Transparency = NumberSequence.new(0, 0.65)
        loi.Parent = neo
        table.insert(danhSach, loi)
    end
    -- co nhỏ dần rồi biến mất (fade mượt)
    task.delay(tuoi * 0.45, function()
        for _, b in ipairs(danhSach) do
            if b.Parent then
                TweenService:Create(b, TweenInfo.new(tuoi * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Width0 = 0, Width1 = 0}):Play()
            end
        end
    end)
    Debris:AddItem(neo, tuoi + 0.4)
    return neo
end

-- XOAY TIN (MỚI VER 4): cho part xoay liên tục mỗi khung hình — vòng năng lượng hết đứng im
local function xoayTin(part, tx, ty, tz)
    local ketNoi
    ketNoi = RunService.Heartbeat:Connect(function()
        if not part.Parent then
            ketNoi:Disconnect()
            return
        end
        part.CFrame = part.CFrame * CFrame.Angles(tx, ty, tz)
    end)
end

-- Mảnh vụn Neon bắn ra có VẬT LÝ THẬT: bay theo trọng lực, xoay tròn, để vệt sáng
-- coLua = true: mảnh vụn tự BỐC LỬA khi bay (mảnh mang theo đuôi lửa)
local function manhVun(viTri, mau, soLuong, tocDo, batVet, coLua)
    for i = 1, soLuong do
        local kich = 0.14 + math.random() * 0.18
        local p = Instance.new("Part")
        p.Name = "HU_Vun" .. i
        p.Size = Vector3.new(kich, kich, kich)
        p.Shape = Enum.PartType.Ball
        p.Material = Enum.Material.Neon
        p.Color = mau
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.CastShadow = false
        p.CFrame = CFrame.new(viTri) * CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
        p.Parent = workspace
        local huong = Vector3.new(math.random() - 0.5, math.random() * 0.8 + 0.25, math.random() - 0.5)
        if huong.Magnitude > 0.01 then
            p.AssemblyLinearVelocity = huong.Unit * tocDo * (0.5 + math.random() * 0.9)
        end
        p.AssemblyAngularVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 22
        if batVet then
            local a0 = Instance.new("Attachment")
            a0.Parent = p
            local a1 = Instance.new("Attachment")
            a1.Position = Vector3.new(0, kich * 1.3, 0)
            a1.Parent = p
            local vet = Instance.new("Trail")
            vet.Attachment0 = a0
            vet.Attachment1 = a1
            vet.Lifetime = 0.25
            vet.LightEmission = 1
            vet.FaceCamera = true
            vet.Color = ColorSequence.new(mau)
            vet.Transparency = NumberSequence.new(0.2, 1)
            vet.WidthScale = NumberSequence.new(1, 0)
            vet.Parent = p
        end
        if coLua then
            local fl = Instance.new("ParticleEmitter")
            fl.Name = "HU_Vun_Lua"
            fl.Texture = TEX_LUA
            fl.Color = ColorSequence.new(Color3.fromRGB(255, 150, 40), Color3.fromRGB(255, 225, 110))
            fl.Rate = 28
            fl.Lifetime = NumberRange.new(0.22, 0.42)
            fl.Speed = NumberRange.new(0.5, 1.5)
            fl.Size = NumberSequence.new(0.3, 0)
            fl.Transparency = NumberSequence.new(0.1, 1)
            fl.LightEmission = 1
            fl.LightInfluence = 0
            fl.Parent = p
        end
        Debris:AddItem(p, 2.2)
    end
end

-- TÀN LỬA BỐC LÊN: hạt lấp lánh lơ lửng bay lên chậm sau vụ nổ (hậu kỳ)
local function hatBay(viTri, mau, thoiLuong, tiLe)
    local o = taoPartHU("HU_Bay", Vector3.new(0.2, 0.2, 0.2), mau, Enum.Material.Neon, 1, viTri)
    local e = taoBurst(o, TEX_SAO, mau, 0.6, 2, 0.8, 1.6, 0.17, Vector3.new(0, 3.5, 0))
    e.Rate = tiLe or 22
    e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)})
    task.delay(thoiLuong, function()
        pcall(function() e.Rate = 0 end)
    end)
end

-- NỔ PHỤ: vụ nổ nhỏ thứ cấp lệch vị trí + trễ -> cảm giác CHUỖI NỔ liên hoàn
local function noPhu(viTriGoc, mau, banKinh, tre)
    task.delay(tre, function()
        local viTri = viTriGoc + Vector3.new(math.random(-3, 3), math.random(0, 2.5), math.random(-3, 3))
        cauNo(viTri, mau, banKinh, 0.35)
        local khu = taoPartHU("HU_NoPhu", Vector3.new(0.2, 0.2, 0.2), mau, Enum.Material.Neon, 1, viTri)
        local e = taoBurst(khu, TEX_SAO, mau, 10, 20, 0.35, 0.8, 0.26, Vector3.new(0, -14, 0))
        e:Emit(38)
        PhatAmThanh("boom", viTri, 1.15 + math.random() * 0.2)
    end)
end

-- GAI DART TRÒN (VER 5): thân TRỤ TRÒN + chóp CẦU — hết gai vuông xấu
local function gaiNo(viTri, mau, soGai, doDai, doDay)
    doDay = doDay or 0.2
    for i = 1, soGai do
        local huong = Vector3.new(math.random() - 0.5, math.random() * 0.85 + 0.15, math.random() - 0.5)
        if huong.Magnitude < 0.05 then huong = Vector3.new(0, 1, 0) end
        huong = huong.Unit
        local day = doDai * (0.55 + math.random() * 0.7)
        -- thân TRỤ TRÒN mọc ra theo hướng (cylinder xoay cho trục trùng hướng bay)
        local p = taoPartHU("HU_Gai" .. i, Vector3.new(0.5, doDay, doDay), mau, Enum.Material.Neon, 0, viTri)
        p.Shape = Enum.PartType.Cylinder
        p.CFrame = CFrame.lookAt(viTri, viTri + huong) * CFrame.Angles(0, math.rad(90), 0)
        TweenService:Create(p, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = Vector3.new(day, doDay, doDay), CFrame = p.CFrame * CFrame.new(day / 2, 0, 0)}):Play()
        -- chóp CẦU sáng chạy tới đầu gai
        local chop = taoPartHU("HU_GaiChop" .. i, Vector3.new(doDay * 1.4, doDay * 1.4, doDay * 1.4), mau, Enum.Material.Neon, 0, viTri)
        chop.Shape = Enum.PartType.Ball
        TweenService:Create(chop, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {CFrame = CFrame.new(viTri + huong * day)}):Play()
        task.delay(0.15, function()
            if p.Parent then
                TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Transparency = 1, Size = Vector3.new(day * 1.1, 0.02, 0.02)}):Play()
            end
            if chop.Parent then
                TweenService:Create(chop, TweenInfo.new(0.35), {Transparency = 1, Size = Vector3.new(0.05, 0.05, 0.05)}):Play()
            end
        end)
    end
end

-- HẠT HÚT NGƯỢC (MỚI VER 4): các hạt bay TỪ XA VÀO điểm chết — tụ năng lượng thật sự
local function hatHut(viTri, mau, soLuong, banKinh, thoiGian)
    for i = 1, soLuong do
        local goc = math.random() * 6.283
        local cao = (math.random() - 0.3) * 5
        local dau = viTri + Vector3.new(math.cos(goc) * banKinh, cao, math.sin(goc) * banKinh)
        local m = taoPartHU("HU_Hut" .. i, Vector3.new(0.24, 0.24, 0.24), mau, Enum.Material.Neon, 0.05, dau)
        m.Shape = Enum.PartType.Ball
        TweenService:Create(m, TweenInfo.new(thoiGian, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = Vector3.new(0.05, 0.05, 0.05), CFrame = CFrame.new(viTri), Transparency = 0.95}):Play()
    end
end

-- ===== 1. NỔ LÕI HỦY DIỆT — HÚT HẠT VÀO TÂM + SIÊU NOVA 3 LỚP + GAI VÀNG + 3 NỔ PHỤ =====
local function HU_NoLoi(viTri)
    local trang = Color3.fromRGB(255, 255, 235)
    local vang = Color3.fromRGB(255, 230, 120)
    local cam = Color3.fromRGB(255, 120, 20)
    -- GIAI ĐOẠN 0: hạt bay TỪ XA VÀO TÂM + lóe trắng co cụm (0.12s)
    hatHut(viTri, vang, 12, 8, 0.13)
    local gom = taoPartHU("HU_Gom", Vector3.new(6, 6, 6), trang, Enum.Material.Neon, 0.15, viTri)
    gom.Shape = Enum.PartType.Ball
    TweenService:Create(gom, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = Vector3.new(0.4, 0.4, 0.4), Transparency = 0}):Play()
    PhatAmThanh("shing", viTri, 1.5)
    LacManHinh(1.8)
    task.delay(0.13, function()
        -- GIAI ĐOẠN 1: NỔ CHÍNH — 3 lớp cầu + 3 vòng + gai vàng + hạt 3 lớp
        if gom.Parent then gom:Destroy() end
        cauNo(viTri, trang, 24, 0.45)
        cauNo(viTri + Vector3.new(0, 0.6, 0), vang, 16, 0.6)
        cauNo(viTri + Vector3.new(0, 1.2, 0), cam, 10, 0.8)
        local dat = Vector3.new(viTri.X, viTri.Y - 2.3, viTri.Z)
        vongSong(dat, vang, 34, 0.85, 0.02)
        vongSong(dat, cam, 24, 0.7, 0.16)
        local vD = vongDung(viTri, trang, 20, 0.5, 0)
        if vD then xoayTin(vD, 1.9, 1.4, 0) end
        gaiNo(viTri, vang, 12, 8.5, 0.2)
        local khu = taoPartHU("HU_NoLoi_Khu", Vector3.new(0.2, 0.2, 0.2), cam, Enum.Material.Neon, 1, viTri)
        local e1 = taoBurst(khu, TEX_SAO, trang, 20, 36, 0.4, 0.9, 0.3, Vector3.new(0, -18, 0))
        e1:Emit(70)
        local e2 = taoBurst(khu, TEX_SAO, vang, 14, 28, 0.5, 1.1, 0.36, Vector3.new(0, -18, 0))
        e2:Emit(60)
        local e3 = taoBurst(khu, TEX_KHOI, Color3.fromRGB(60, 52, 50), 3, 9, 0.9, 1.7, 1, Vector3.new(0, 5, 0))
        e3.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1)})
        e3:Emit(30)
        manhVun(viTri, cam, 12, 30, true, true)
        hatBay(viTri, vang, 1.4, 26)
        PhatAmThanh("boom", viTri, 0.75)
        PhatAmThanh("ping", viTri, 1.3)
        ChopManHinh(trang, 0.62)
        -- GIAI ĐOẠN 2: 3 NỔ PHỤ chuỗi lệch vị trí
        noPhu(viTri, vang, 8, 0.28)
        noPhu(viTri, cam, 6, 0.52)
        noPhu(viTri, trang, 7, 0.74)
    end)
end

-- ===== 2. SÉT THIÊN PHẠT — TỤ ĐIỆN + TIA ZIGZAG 10 KHÚC + 6 TIA MINI PHỤ =====
local function HU_Set(viTri)
    local trangXanh = Color3.fromRGB(235, 248, 255)
    local xanhDien = Color3.fromRGB(130, 215, 255)
    -- GIAI ĐOẠN 0: cầu điện TỤ TRÊN TRỜI phồng to 0.26s
    local diemTroi = viTri + Vector3.new(math.random(-3, 3), 27, math.random(-3, 3))
    local tu = taoPartHU("HU_Set_Tu", Vector3.new(1.8, 1.8, 1.8), xanhDien, Enum.Material.Neon, 0.3, diemTroi)
    tu.Shape = Enum.PartType.Ball
    TweenService:Create(tu, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = Vector3.new(4.4, 4.4, 4.4), Transparency = 0}):Play()
    PhatAmThanh("ping", viTri, 0.55)
    LacManHinh(2.2)
    task.delay(0.27, function()
        if tu.Parent then tu:Destroy() end
        -- GIAI ĐOẠN 1: TIA CHÍNH ZIGZAG 10 KHÚC x 2 LỚP (gấp khúc thật hơn)
        local truoc = diemTroi
        for i = 1, 10 do
            local muc = viTri + Vector3.new(math.random(-2.2, 2.2), 27 - i * 2.7, math.random(-2.2, 2.2))
            local doDai = (muc - truoc).Magnitude
            if doDai > 0.5 then
                taoBeam(truoc, muc, xanhDien, 0.55, 0.4, trangXanh)
            end
            if i == 4 or i == 5 or i == 6 then
                for _ = 1, 2 do
                    local gocNh = math.random() * 6.28
                    local cuoi = muc + Vector3.new(math.cos(gocNh) * (2.5 + math.random() * 2.5), -0.6 - math.random() * 1.8, math.sin(gocNh) * (2.5 + math.random() * 2.5))
                    local daiN = (cuoi - muc).Magnitude
                    if daiN > 0.5 then
                        taoBeam(muc, cuoi, trangXanh, 0.2, 0.3)
                    end
                end
            end
            truoc = muc
        end
        -- chớp trúng + GAI ĐIỆN bắn tỏa tại chỗ chết + chớp màn hình xanh
        cauNo(viTri + Vector3.new(0, 1.5, 0), trangXanh, 15, 0.4)
        gaiNo(viTri + Vector3.new(0, 1, 0), xanhDien, 10, 6, 0.14)
        ChopManHinh(trangXanh, 0.7)
        -- vết cháy đen trên đất mờ dần
        local dat = Vector3.new(viTri.X, viTri.Y - 2.4, viTri.Z)
        local vet = taoPartHU("HU_Set_Vet", Vector3.new(0.3, 7, 7), Color3.fromRGB(35, 30, 35), Enum.Material.Slate, 0.1, dat)
        vet.Shape = Enum.PartType.Cylinder
        vet.CFrame = CFrame.new(dat) * CFrame.Angles(0, 0, math.rad(90))
        task.delay(0.9, function()
            if vet.Parent then
                TweenService:Create(vet, TweenInfo.new(1.2), {Transparency = 1}):Play()
            end
        end)
        -- điện ken két chạy trên đất
        local khu = taoPartHU("HU_Set_Khu", Vector3.new(0.2, 0.2, 0.2), xanhDien, Enum.Material.Neon, 1, viTri)
        local e1 = taoBurst(khu, TEX_SAO, Color3.fromRGB(255, 255, 220), 18, 32, 0.3, 0.7, 0.3, Vector3.new(0, -20, 0))
        e1:Emit(60)
        hatBay(viTri, xanhDien, 1.1, 18)
        PhatAmThanh("snap", viTri, 1)
        PhatAmThanh("boom", viTri, 0.85)
        -- GIAI ĐOẠN 2: 6 TIA MINI phụ giáng quanh xác 0.3s sau
        task.delay(0.3, function()
            for i = 1, 6 do
                local gocQ = (i / 6) * 6.28 + math.random() * 0.5
                local chan = viTri + Vector3.new(math.cos(gocQ) * (3 + math.random() * 2.5), 0.5, math.sin(gocQ) * (3 + math.random() * 2.5))
                local dau = chan + Vector3.new(math.random(-1.5, 1.5), 22 + math.random() * 5, math.random(-1.5, 1.5))
                local dai = (dau - chan).Magnitude
                if dai > 1 then
                    taoBeam(dau, chan, xanhDien, 0.22, 0.42, trangXanh)
                    cauNo(chan, xanhDien, 4, 0.3)
                end
            end
            PhatAmThanh("snap", viTri, 1.3)
        end)
    end)
end

-- ===== 3. HỐ ĐEN TỰ HỦY — HÚT HẠT NGƯỢC + 3 VÒNG XOAY + NỔ NGƯỢC GAI TÍM =====
local function HU_HoDen(viTri)
    local mauDen = Color3.fromRGB(15, 8, 22)
    local mauTim = Color3.fromRGB(180, 70, 255)
    local tam = viTri + Vector3.new(0, 1.5, 0)
    -- VER 4: HẠT BỊ HÚT NGƯỢC VÀO TÂM ngay khi mở hố (vật chất bị nuốt)
    hatHut(tam, mauTim, 14, 9, 0.75)
    -- lõi đen phồng + quầng tím bọc ngoài
    local loi = taoPartHU("HU_HoDen_Loi", Vector3.new(1, 1, 1), mauDen, Enum.Material.Slate, 0, tam)
    loi.Shape = Enum.PartType.Ball
    TweenService:Create(loi, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = Vector3.new(5.5, 5.5, 5.5)}):Play()
    local quanh = taoPartHU("HU_HoDen_Quanh", Vector3.new(1.3, 1.3, 1.3), mauTim, Enum.Material.Neon, 0.65, tam)
    quanh.Shape = Enum.PartType.Ball
    TweenService:Create(quanh, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = Vector3.new(6.4, 6.4, 6.4), Transparency = 0.85}):Play()
    taoDenChop(loi, mauTim, 6, 20)
    -- 3 VÒNG XOAY quanh hố đen ( heartbeat riêng, ngắt khi lõi mất )
    local vong = {}
    for i = 1, 3 do
        vong[i] = taoPartHU("HU_HoDen_Vong", Vector3.new(0.12, 6.5, 6.5), mauTim, Enum.Material.Neon, 0.4, tam)
        vong[i].Shape = Enum.PartType.Cylinder
    end
    local ketNoi
    ketNoi = RunService.Heartbeat:Connect(function()
        if not loi.Parent or not vong[1].Parent then
            ketNoi:Disconnect()
            return
        end
        local t = os.clock()
        for i = 1, 3 do
            local goc = t * (2.2 + i * 0.7)
            vong[i].CFrame = CFrame.new(tam) * CFrame.Angles(goc, i * 2.1, goc * 0.7)
        end
    end)
    -- 16 mảnh sáng bị HÚT vào tâm
    for i = 1, 16 do
        local goc = (i / 16) * math.pi * 2 + math.random() * 0.3
        local batDau = viTri + Vector3.new(math.cos(goc) * 8.5, 1.5 + (math.random() - 0.5) * 5, math.sin(goc) * 8.5)
        local m = taoPartHU("HU_HoDen_M", Vector3.new(0.3, 0.3, 0.3), mauTim, Enum.Material.Neon, 0, batDau)
        m.Shape = Enum.PartType.Ball
        TweenService:Create(m, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = Vector3.new(0.04, 0.04, 0.04), CFrame = CFrame.new(tam), Transparency = 0.9}):Play()
    end
    PhatAmThanh("ping", viTri, 0.6)
    LacManHinh(2.4)
    task.delay(0.92, function()
        if loi.Parent then loi:Destroy() end
        if quanh.Parent then quanh:Destroy() end
        -- NỔ NGƯỢC tím đậm + gai tím + chớp màn hình tím
        cauNo(tam, mauTim, 16, 0.5)
        local vD = vongDung(tam, Color3.fromRGB(230, 160, 255), 18, 0.55, 0)
        if vD then xoayTin(vD, 1.6, 1.2, 0) end
        gaiNo(tam, mauTim, 10, 7, 0.16)
        ChopManHinh(mauTim, 0.7)
        local khu = taoPartHU("HU_HoDen_Khu", Vector3.new(0.2, 0.2, 0.2), mauTim, Enum.Material.Neon, 1, tam)
        local e1 = taoBurst(khu, TEX_SAO, mauTim, 20, 34, 0.5, 1, 0.32, Vector3.new(0, -14, 0))
        e1:Emit(75)
        local e2 = taoBurst(khu, TEX_SAO, Color3.fromRGB(255, 255, 255), 24, 40, 0.3, 0.6, 0.2, Vector3.new(0, -14, 0))
        e2:Emit(45)
        manhVun(tam, mauTim, 9, 30, true, false)
        hatBay(tam, Color3.fromRGB(220, 140, 255), 1.5, 22)
        PhatAmThanh("boom", viTri, 1.1)
        PhatAmThanh("shing", viTri, 0.7)
        noPhu(tam, mauTim, 6, 0.45)
    end)
end

-- ===== 4. MẢNH VỤN BÙNG NỔ — GAI LỬA + 18 MẢNH MANG LỬA + CHUỖI NỔ PHỤ =====
local function HU_ManhVun(viTri)
    local cam = Color3.fromRGB(255, 150, 40)
    cauNo(viTri, Color3.fromRGB(255, 200, 80), 10, 0.4)
    gaiNo(viTri, cam, 10, 7, 0.16)
    manhVun(viTri, cam, 18, 36, true, true)
    local khu = taoPartHU("HU_ManhVun_Khu", Vector3.new(0.2, 0.2, 0.2), cam, Enum.Material.Neon, 1, viTri)
    local e1 = taoBurst(khu, TEX_SAO, Color3.fromRGB(255, 220, 120), 14, 26, 0.4, 0.9, 0.3, Vector3.new(0, -16, 0))
    e1:Emit(55)
    local e2 = taoBurst(khu, TEX_KHOI, Color3.fromRGB(60, 55, 55), 2, 6, 1, 1.7, 0.8, Vector3.new(0, 4, 0))
    e2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1)})
    e2:Emit(22)
    hatBay(viTri, cam, 1.2, 16)
    ChopManHinh(Color3.fromRGB(255, 210, 120), 0.72)
    PhatAmThanh("boom", viTri, 1.05)
    LacManHinh(1.5)
    noPhu(viTri, cam, 6, 0.3)
    noPhu(viTri, Color3.fromRGB(255, 200, 80), 5, 0.55)
end

-- ===== 5. XÁC CHÁY THÀNH TRO — BÙNG GAI LỬA + LỬA 2 MÀU + CHỚP ĐÈN + VẾT CHÁY =====
local function HU_XacChay(viTri)
    local mauLua = Color3.fromRGB(255, 110, 25)
    local o = taoPartHU("HU_Chay_Khu", Vector3.new(0.3, 0.3, 0.3), mauLua, Enum.Material.Neon, 1, viTri)
    -- VER 4: BÙNG LÊN ngay — gai lửa + vệt lóe một phát
    gaiNo(viTri + Vector3.new(0, 1, 0), mauLua, 8, 5, 0.14)
    local eNo = taoBurst(o, TEX_LUA, Color3.fromRGB(255, 220, 120), 10, 20, 0.3, 0.6, 0.5)
    eNo:Emit(45)
    -- lửa cam ngoài
    local lua = Instance.new("ParticleEmitter")
    lua.Name = "HU_Chay_Lua"
    lua.Texture = TEX_LUA
    lua.Color = ColorSequence.new(mauLua, Color3.fromRGB(255, 220, 90))
    lua.Rate = 62
    lua.Speed = NumberRange.new(4, 9)
    lua.Lifetime = NumberRange.new(0.5, 1)
    lua.SpreadAngle = Vector2.new(35, 35)
    lua.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0)})
    lua.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1)})
    lua.LightEmission = 1
    lua.LightInfluence = 0
    lua.Acceleration = Vector3.new(0, 6, 0)
    lua.EmissionDirection = Enum.NormalId.Top
    lua.Parent = o
    -- lõi lửa TRẮNG-XANH trong cùng (nóng hơn)
    local loiTrang = Instance.new("ParticleEmitter")
    loiTrang.Name = "HU_Chay_Loi"
    loiTrang.Texture = TEX_LUA
    loiTrang.Color = ColorSequence.new(Color3.fromRGB(180, 235, 255), Color3.fromRGB(255, 255, 255))
    loiTrang.Rate = 34
    loiTrang.Speed = NumberRange.new(2, 5)
    loiTrang.Lifetime = NumberRange.new(0.3, 0.6)
    loiTrang.SpreadAngle = Vector2.new(22, 22)
    loiTrang.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0)})
    loiTrang.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)})
    loiTrang.LightEmission = 1
    loiTrang.LightInfluence = 0
    loiTrang.Acceleration = Vector3.new(0, 8, 0)
    loiTrang.EmissionDirection = Enum.NormalId.Top
    loiTrang.Parent = o
    local khoi = taoBurst(o, TEX_KHOI, Color3.fromRGB(40, 35, 35), 2, 4, 1.2, 1.9, 1, Vector3.new(0, 3, 0))
    khoi.Rate = 18
    khoi.SpreadAngle = Vector2.new(20, 20)
    khoi.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
    local tan = taoBurst(o, TEX_SAO, Color3.fromRGB(255, 180, 60), 5, 10, 0.6, 1.2, 0.22, Vector3.new(0, -6, 0))
    tan.Rate = 14
    local den = Instance.new("PointLight")
    den.Color = mauLua
    den.Brightness = 5
    den.Range = 24
    den.Parent = o
    -- vết cháy đất
    local dat = Vector3.new(viTri.X, viTri.Y - 2.4, viTri.Z)
    local vet = taoPartHU("HU_Chay_Vet", Vector3.new(0.3, 5.5, 5.5), Color3.fromRGB(30, 26, 26), Enum.Material.Slate, 0.2, dat)
    vet.Shape = Enum.PartType.Cylinder
    vet.CFrame = CFrame.new(dat) * CFrame.Angles(0, 0, math.rad(90))
    -- đèn CHỚP liên tục như lửa thật
    task.spawn(function()
        for _ = 1, 10 do
            if not den.Parent then break end
            den.Brightness = 4 + math.random() * 3
            task.wait(0.18)
        end
    end)
    -- cháy 2.4 giây rồi ngừng phát, vết cháy mờ dần
    task.delay(2.4, function()
        pcall(function()
            lua.Rate = 0
            loiTrang.Rate = 0
            khoi.Rate = 0
            tan.Rate = 0
        end)
        if den.Parent then
            TweenService:Create(den, TweenInfo.new(1), {Brightness = 0}):Play()
        end
        if vet.Parent then
            TweenService:Create(vet, TweenInfo.new(1.4), {Transparency = 1}):Play()
        end
    end)
    LacManHinh(1.2)
    PhatAmThanh("boom", viTri, 0.55)
    PhatAmThanh("snap", viTri, 0.75)
end

-- ===== 6. VÒNG SÓNG XUNG KÍCH — 4 VÒNG ĐẤT + 3 VÀNH ĐỨNG XOAY + GAI XANH =====
local function HU_SongXungKich(viTri)
    local xanh = Color3.fromRGB(80, 210, 255)
    local trang = Color3.fromRGB(235, 250, 255)
    local dat = Vector3.new(viTri.X, viTri.Y - 2.3, viTri.Z)
    -- 4 vòng đất lan lệch pha
    vongSong(dat, xanh, 34, 0.8, 0)
    vongSong(dat + Vector3.new(0, 2.2, 0), trang, 26, 0.7, 0.1)
    vongSong(dat + Vector3.new(0, 4.4, 0), xanh, 20, 0.6, 0.2)
    vongSong(dat, trang, 14, 0.5, 0.32)
    -- 3 VÀNH ĐỨNG DỌC nở chéo nhau (vành đầu XOAY lăn tăn)
    local v1 = vongDung(viTri + Vector3.new(0, 0.5, 0), xanh, 22, 0.6, 0)
    if v1 then xoayTin(v1, 1.5, 1.1, 0) end
    vongDung(viTri + Vector3.new(0, 0.5, 0), trang, 16, 0.55, math.rad(90))
    vongDung(viTri + Vector3.new(0, 0.5, 0), xanh, 12, 0.5, math.rad(45))
    gaiNo(viTri, xanh, 10, 7, 0.15)
    local khu = taoPartHU("HU_Vong_Khu", Vector3.new(0.2, 0.2, 0.2), xanh, Enum.Material.Neon, 1, viTri)
    local e1 = taoBurst(khu, TEX_SAO, Color3.fromRGB(150, 240, 255), 12, 24, 0.4, 0.9, 0.3, Vector3.new(0, -16, 0))
    e1:Emit(60)
    manhVun(viTri, xanh, 8, 24, true, false)
    hatBay(viTri, trang, 1, 14)
    ChopManHinh(trang, 0.68)
    local den = taoPartHU("HU_Vong_Den", Vector3.new(0.2, 0.2, 0.2), xanh, Enum.Material.Neon, 1, dat + Vector3.new(0, 1, 0))
    taoDenChop(den, xanh, 7, 26)
    LacManHinh(2)
    PhatAmThanh("boom", viTri, 1.3)
    PhatAmThanh("ping", viTri, 1.7)
end

-- ===== 7. CỘT LỬA ĐỊA NGỤC — VẠCH PHÁT SÁNG + CỘT DÂNG + NỔ ĐỈNH GAI LỬA =====
local function HU_CotLua(viTri)
    local cam = Color3.fromRGB(255, 100, 15)
    -- GIAI ĐOẠN 0: vạch tròn phát sáng trên đất co lại (cảnh báo 0.18s)
    local dat = Vector3.new(viTri.X, viTri.Y - 2.35, viTri.Z)
    local vach = taoPartHU("HU_CotLua_Vach", Vector3.new(0.25, 9, 9), Color3.fromRGB(255, 200, 80), Enum.Material.Neon, 0.15, dat)
    vach.Shape = Enum.PartType.Cylinder
    vach.CFrame = CFrame.new(dat) * CFrame.Angles(0, 0, math.rad(90))
    TweenService:Create(vach, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = Vector3.new(0.25, 2.5, 2.5), Transparency = 0}):Play()
    PhatAmThanh("shing", viTri, 1.3)
    task.delay(0.19, function()
        if vach.Parent then vach:Destroy() end
        -- GIAI ĐOẠN 1: CỘT LỬA DÂNG LÊN thần tốc
        local cot = taoPartHU("HU_CotLua", Vector3.new(2, 1.5, 1.5), cam, Enum.Material.Neon, 0.25, viTri + Vector3.new(0, 1, 0))
        cot.Shape = Enum.PartType.Cylinder
        cot.CFrame = CFrame.new(viTri + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.rad(90))
        TweenService:Create(cot, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = Vector3.new(42, 5, 5), CFrame = CFrame.new(viTri + Vector3.new(0, 21, 0)) * CFrame.Angles(0, 0, math.rad(90))}):Play()
        task.delay(0.35, function()
            if cot.Parent then
                TweenService:Create(cot, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Size = Vector3.new(42, 1.2, 1.2), Transparency = 1}):Play()
            end
        end)
        -- vạch sáng TRỤ TRÒN chạy dọc cột lửa (VER 5)
        taoBeam(viTri, viTri + Vector3.new(0, 40, 0), Color3.fromRGB(255, 200, 80), 1.2, 0.55, Color3.fromRGB(255, 245, 200))
        -- lửa xoáy mạnh + lõi trắng
        local khu = taoPartHU("HU_CotLua_Khu", Vector3.new(0.3, 0.3, 0.3), cam, Enum.Material.Neon, 1, viTri)
        local lua = Instance.new("ParticleEmitter")
        lua.Name = "HU_CotLua_Lua"
        lua.Texture = TEX_LUA
        lua.Color = ColorSequence.new(cam, Color3.fromRGB(255, 230, 110))
        lua.Rate = 85
        lua.Speed = NumberRange.new(8, 14)
        lua.Lifetime = NumberRange.new(0.5, 0.9)
        lua.SpreadAngle = Vector2.new(18, 18)
        lua.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(1, 0)})
        lua.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)})
        lua.LightEmission = 1
        lua.LightInfluence = 0
        lua.Acceleration = Vector3.new(0, 10, 0)
        lua.EmissionDirection = Enum.NormalId.Top
        lua.Parent = khu
        local loi = taoBurst(khu, TEX_LUA, Color3.fromRGB(255, 245, 200), 6, 12, 0.3, 0.6, 0.4, Vector3.new(0, 12, 0))
        loi.Rate = 40
        loi.SpreadAngle = Vector2.new(10, 10)
        local tan = taoBurst(khu, TEX_SAO, Color3.fromRGB(255, 210, 90), 10, 18, 0.5, 1.1, 0.25, Vector3.new(0, -10, 0))
        tan.Rate = 22
        vongSong(dat, cam, 28, 0.7, 0)
        vongSong(dat, Color3.fromRGB(255, 200, 80), 18, 0.55, 0.12)
        manhVun(viTri, cam, 8, 26, true, true)
        local den = Instance.new("PointLight")
        den.Color = cam
        den.Brightness = 7
        den.Range = 30
        den.Parent = khu
        task.delay(1.5, function()
            pcall(function()
                lua.Rate = 0
                loi.Rate = 0
                tan.Rate = 0
            end)
            if den.Parent then
                TweenService:Create(den, TweenInfo.new(0.9), {Brightness = 0}):Play()
            end
        end)
        hatBay(viTri + Vector3.new(0, 6, 0), Color3.fromRGB(255, 200, 90), 1.4, 20)
        LacManHinh(2.2)
        PhatAmThanh("boom", viTri, 0.7)
        PhatAmThanh("shing", viTri, 1.2)
        ChopManHinh(cam, 0.72)
        -- GIAI ĐOẠN 2: NỔ ĐỈNH CỘT + gai lửa trên cao 0.5s sau
        task.delay(0.5, function()
            gaiNo(viTri + Vector3.new(0, 20, 0), Color3.fromRGB(255, 180, 60), 8, 7, 0.15)
            noPhu(viTri + Vector3.new(0, 20, 0), Color3.fromRGB(255, 180, 60), 9, 0)
        end)
    end)
end

-- ===== 8. NỔ MÁU HUYẾT — BẮN 3 HƯỚNG + VŨNG MÁU + NHỎ GIỌT + CHỚP ĐỎ =====
local function HU_Mau(viTri)
    local doSang = Color3.fromRGB(255, 40, 40)
    local doDam = Color3.fromRGB(185, 0, 22)
    cauNo(viTri, doSang, 9, 0.4)
    local khu = taoPartHU("HU_Mau_Khu", Vector3.new(0.2, 0.2, 0.2), doDam, Enum.Material.Neon, 1, viTri)
    -- máu bắn 3 hướng: toả tròn + 2 cột nghiêng
    local mauB = taoBurst(khu, TEX_KHOI, doDam, 10, 22, 0.9, 1.4, 0.55, Vector3.new(0, -45, 0))
    mauB.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
    mauB:Emit(80)
    local cot1 = taoBurst(khu, TEX_KHOI, doSang, 8, 16, 0.7, 1.1, 0.4, Vector3.new(0, -40, 0))
    cot1.SpreadAngle = Vector2.new(35, 8)
    cot1:Emit(30)
    local cot2 = taoBurst(khu, TEX_KHOI, doDam, 8, 16, 0.7, 1.1, 0.4, Vector3.new(0, -40, 0))
    cot2.SpreadAngle = Vector2.new(8, 35)
    cot2:Emit(30)
    local gio = taoBurst(khu, TEX_SAO, Color3.fromRGB(130, 0, 15), 12, 26, 0.7, 1.2, 0.28, Vector3.new(0, -50, 0))
    gio:Emit(45)
    -- máu nhỏ giọt rơi chậm sau phun (2 lớp: nhỏ + li ti)
    local giot = taoBurst(khu, TEX_KHOI, Color3.fromRGB(140, 0, 18), 2, 5, 1, 1.6, 0.22, Vector3.new(0, -28, 0))
    giot.Rate = 14
    task.delay(1.4, function() pcall(function() giot.Rate = 0 end) end)
    local giotNho = taoBurst(khu, TEX_SAO, doSang, 1, 3, 0.8, 1.4, 0.12, Vector3.new(0, -30, 0))
    giotNho.Rate = 18
    task.delay(1.3, function() pcall(function() giotNho.Rate = 0 end) end)
    -- vũng máu loang trên đất rồi thấm dần
    local dat = Vector3.new(viTri.X, viTri.Y - 2.45, viTri.Z)
    local vung = taoPartHU("HU_VungMau", Vector3.new(0.25, 3, 3), Color3.fromRGB(120, 0, 12), Enum.Material.SmoothPlastic, 0.15, dat)
    vung.Shape = Enum.PartType.Cylinder
    vung.CFrame = CFrame.new(dat) * CFrame.Angles(0, 0, math.rad(90))
    TweenService:Create(vung, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = Vector3.new(0.25, 10, 10)}):Play()
    task.delay(2.2, function()
        if vung.Parent then
            TweenService:Create(vung, TweenInfo.new(1.2), {Transparency = 1}):Play()
        end
    end)
    taoDenChop(khu, doDam, 6, 20)
    ChopManHinh(doSang, 0.8)
    LacManHinh(1.4)
    PhatAmThanh("boom", viTri, 0.72)
    PhatAmThanh("oof", viTri, 1)
end

-- ===== 9. SONG KIẾM CHÉM CHỚP (MỚI) — 4 LÁ CHÉM CHỮ X CẮT XÁC LÀM ĐÔI =====
local function HU_SongKiem(viTri)
    local trang = Color3.fromRGB(255, 255, 255)
    local ngoc = Color3.fromRGB(120, 255, 200)
    ChopManHinh(trang, 0.7)
    PhatAmThanh("shing", viTri, 1.7)
    for lan = 1, 2 do
        task.delay((lan - 1) * 0.17, function()
            -- mỗi đợt chém 2 lá chéo chữ X: lớp ngoài ngọc to + lõi trắng mảnh
            local gocDay = math.rad(lan * 58 + 20)
            -- 2 vệt chém BEAM TRÒN MƯỢT chéo chữ X (ngọc ngoài + lõi trắng) — hết lá vuông
            for goc = 1, 2 do
                local a = gocDay + ((goc == 1) and 0 or math.rad(90))
                local nghieng = (goc == 1) and math.rad(38) or math.rad(-38)
                local phang = Vector3.new(math.cos(a), 0, math.sin(a))
                local huong = (phang * math.cos(nghieng) + Vector3.new(0, math.sin(nghieng), 0)).Unit
                local nua = (goc == 1) and 17 or 15.5
                taoBeam(viTri + huong * nua, viTri - huong * nua, ngoc, 1.5, 0.55, trang)
            end
            cauNo(viTri, trang, 5, 0.25)
            -- tia lửa theo vệt chém
            local khu = taoPartHU("HU_Kiem_Khu" .. lan, Vector3.new(0.2, 0.2, 0.2), ngoc, Enum.Material.Neon, 1, viTri)
            local e = taoBurst(khu, TEX_SAO, trang, 16, 30, 0.25, 0.6, 0.26, Vector3.new(0, -12, 0))
            e:Emit(40)
            PhatAmThanh("shing", viTri, 1.2 + math.random() * 0.3)
            LacManHinh(1.6)
        end)
    end
    -- xác vỡ đôi: cầu nổ + gai ngọc + mảnh + vòng sóng
    task.delay(0.34, function()
        cauNo(viTri, ngoc, 12, 0.4)
        gaiNo(viTri, ngoc, 12, 8, 0.15)
        manhVun(viTri, ngoc, 12, 28, true, false)
        vongSong(Vector3.new(viTri.X, viTri.Y - 2.3, viTri.Z), ngoc, 20, 0.55, 0)
        hatBay(viTri, trang, 1.1, 18)
        PhatAmThanh("boom", viTri, 1.1)
        noPhu(viTri, ngoc, 6, 0.3)
    end)
end

-- ===== 10. SAO BĂNG TÁN LOẠN (MỚI) — 6 THIÊN THẠCH RƠI ĐỐT + VIÊN CHÍNH NỔ TO =====
local function HU_SaoBang(viTri)
    local cam = Color3.fromRGB(255, 140, 30)
    local vang = Color3.fromRGB(255, 220, 100)
    local dat = Vector3.new(viTri.X, viTri.Y - 2.35, viTri.Z)
    -- vạch cảnh báo tròn phát sáng trên đất
    local vach = taoPartHU("HU_SaoBang_Vach", Vector3.new(0.25, 14, 14), vang, Enum.Material.Neon, 0.4, dat)
    vach.Shape = Enum.PartType.Cylinder
    vach.CFrame = CFrame.new(dat) * CFrame.Angles(0, 0, math.rad(90))
    PhatAmThanh("shing", viTri, 1.1)
    LacManHinh(1.4)
    -- 5 thiên thạch rơi quanh xác, mỗi viên chạm đất nổ nhỏ + vòng sóng
    for i = 1, 5 do
        task.delay(0.08 + i * 0.1, function()
            local chan = viTri + Vector3.new(math.random(-7, 7), 0, math.random(-7, 7))
            local dau = chan + Vector3.new(math.random(-5, 5), 30, math.random(-5, 5))
            local da = taoPartHU("HU_SaoBang_Da" .. i, Vector3.new(2.4, 2.4, 2.4), cam, Enum.Material.Neon, 0.05, dau)
            da.Shape = Enum.PartType.Ball
            local duoi = Instance.new("ParticleEmitter")
            duoi.Name = "HU_SaoBang_Duoi"
            duoi.Texture = TEX_LUA
            duoi.Color = ColorSequence.new(vang, cam)
            duoi.Rate = 80
            duoi.Lifetime = NumberRange.new(0.25, 0.5)
            duoi.Speed = NumberRange.new(0, 2)
            duoi.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.7), NumberSequenceKeypoint.new(1, 0)})
            duoi.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)})
            duoi.LightEmission = 1
            duoi.LightInfluence = 0
            duoi.Parent = da
            TweenService:Create(da, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {CFrame = CFrame.new(chan + Vector3.new(0, 1, 0))}):Play()
            task.delay(0.31, function()
                if da.Parent then da:Destroy() end
                cauNo(chan, vang, 8, 0.3)
                local khuN = taoPartHU("HU_SaoBang_Khu" .. i, Vector3.new(0.2, 0.2, 0.2), cam, Enum.Material.Neon, 1, chan)
                local e = taoBurst(khuN, TEX_SAO, vang, 10, 20, 0.3, 0.7, 0.26, Vector3.new(0, -16, 0))
                e:Emit(32)
                vongSong(Vector3.new(chan.X, dat.Y, chan.Z), cam, 11, 0.4, 0)
                PhatAmThanh("boom", chan, 1.25)
            end)
        end)
    end
    -- VIÊN CHÍNH trúng tâm 0.62s sau: nổ lớn + gai vàng + chuỗi nổ phụ
    task.delay(0.62, function()
        local dauC = viTri + Vector3.new(math.random(-2, 2), 32, math.random(-2, 2))
        local daC = taoPartHU("HU_SaoBang_Chit", Vector3.new(3.6, 3.6, 3.6), vang, Enum.Material.Neon, 0.02, dauC)
        daC.Shape = Enum.PartType.Ball
        local duoiC = Instance.new("ParticleEmitter")
        duoiC.Name = "HU_SaoBang_DuoiC"
        duoiC.Texture = TEX_LUA
        duoiC.Color = ColorSequence.new(Color3.fromRGB(255, 240, 160), cam)
        duoiC.Rate = 120
        duoiC.Lifetime = NumberRange.new(0.3, 0.55)
        duoiC.Speed = NumberRange.new(0, 2)
        duoiC.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2.2), NumberSequenceKeypoint.new(1, 0)})
        duoiC.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 1)})
        duoiC.LightEmission = 1
        duoiC.LightInfluence = 0
        duoiC.Parent = daC
        TweenService:Create(daC, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {CFrame = CFrame.new(viTri + Vector3.new(0, 1, 0))}):Play()
        task.delay(0.23, function()
            if daC.Parent then daC:Destroy() end
            if vach.Parent then
                TweenService:Create(vach, TweenInfo.new(0.25), {Transparency = 1}):Play()
            end
            cauNo(viTri, vang, 16, 0.45)
            cauNo(viTri + Vector3.new(0, 1, 0), cam, 11, 0.6)
            gaiNo(viTri, vang, 10, 9, 0.2)
            local khuC = taoPartHU("HU_SaoBang_KhuC", Vector3.new(0.2, 0.2, 0.2), cam, Enum.Material.Neon, 1, viTri)
            local e1 = taoBurst(khuC, TEX_SAO, vang, 16, 30, 0.35, 0.8, 0.3, Vector3.new(0, -18, 0))
            e1:Emit(55)
            manhVun(viTri, cam, 10, 30, true, true)
            hatBay(viTri, vang, 1.3, 22)
            vongSong(dat, cam, 26, 0.65, 0)
            ChopManHinh(vang, 0.66)
            LacManHinh(2.2)
            PhatAmThanh("boom", viTri, 0.7)
            noPhu(viTri, cam, 7, 0.3)
            noPhu(viTri, cam, 6, 0.55)
        end)
    end)
end

-- ===== 11. BĂNG TINH PHONG ẤN (MỚI) — ĐÓNG BĂNG 0.55s RỒI VỠ TANH MẢNH PHA LÊ =====
local function HU_BangTinh(viTri)
    local xanhBang = Color3.fromRGB(150, 225, 255)
    local trangBang = Color3.fromRGB(235, 250, 255)
    local tam = viTri + Vector3.new(0, 1, 0)
    -- cầu BĂNG bọc xác trong mờ nở ra
    local bong = taoPartHU("HU_Bang_Bong", Vector3.new(1, 1, 1), xanhBang, Enum.Material.Ice, 0.5, tam)
    bong.Shape = Enum.PartType.Ball
    TweenService:Create(bong, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = Vector3.new(7.5, 7.5, 7.5)}):Play()
    -- 8 gai băng mọc quanh cầu
    for i = 1, 8 do
        local goc = (i / 8) * 6.283
        local huong = Vector3.new(math.cos(goc), (math.random() - 0.2) * 0.9, math.sin(goc))
        if huong.Magnitude < 0.05 then huong = Vector3.new(0, 1, 0) end
        huong = huong.Unit
        local doDaiG = 3 + math.random() * 1.5
        local gai = taoPartHU("HU_Bang_Gai" .. i, Vector3.new(0.5, 0.34, 0.34), trangBang, Enum.Material.Ice, 0.25, tam)
        gai.Shape = Enum.PartType.Cylinder
        gai.CFrame = CFrame.lookAt(tam, tam + huong) * CFrame.Angles(0, math.rad(90), 0)
        TweenService:Create(gai, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = Vector3.new(doDaiG, 0.34, 0.34), CFrame = gai.CFrame * CFrame.new(doDaiG / 2, 0, 0)}):Play()
    end
    -- bụi lạnh lơ lửng
    local khu = taoPartHU("HU_Bang_Khu", Vector3.new(0.2, 0.2, 0.2), xanhBang, Enum.Material.Neon, 1, tam)
    local buiLanh = taoBurst(khu, TEX_SAO, trangBang, 0.5, 1.5, 0.8, 1.5, 0.2)
    buiLanh.Rate = 24
    PhatAmThanh("ping", viTri, 1.6)
    LacManHinh(1)
    -- GIỮ BĂNG 0.55s rồi VỠ TANH
    task.delay(0.88, function()
        if bong.Parent then bong:Destroy() end
        ChopManHinh(trangBang, 0.72)
        PhatAmThanh("snap", viTri, 1.45)
        -- 10 mảnh pha lê to VẬT LÝ THẬT văng ra xoay tròn
        for i = 1, 10 do
            local m = Instance.new("Part")
            m.Name = "HU_Bang_M" .. i
            m.Size = Vector3.new(1.4, 0.3, 0.3)
            m.Shape = Enum.PartType.Cylinder
            m.CFrame = CFrame.new(tam) * CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
            m.Material = Enum.Material.Ice
            m.Color = trangBang
            m.CanCollide = false
            m.CanQuery = false
            m.CanTouch = false
            m.CastShadow = false
            m.Parent = workspace
            local huong = Vector3.new(math.random() - 0.5, math.random() * 0.9 + 0.2, math.random() - 0.5)
            if huong.Magnitude > 0.05 then
                m.AssemblyLinearVelocity = huong.Unit * (18 + math.random() * 16)
            end
            m.AssemblyAngularVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 18
            TweenService:Create(m, TweenInfo.new(0.7), {Transparency = 1}):Play()
            Debris:AddItem(m, 1.6)
        end
        manhVun(tam, trangBang, 10, 26, true, false)
        gaiNo(tam, xanhBang, 10, 7, 0.14)
        -- trụ băng TRỤ TRÒN vọt lên khi vỡ (VER 5)
        taoBeam(tam, tam + Vector3.new(0, 11, 0), xanhBang, 0.7, 0.5, trangBang)
        vongSong(Vector3.new(viTri.X, viTri.Y - 2.3, viTri.Z), xanhBang, 22, 0.6, 0)
        local vB = vongDung(tam, trangBang, 16, 0.5, 0)
        if vB then xoayTin(vB, 1.6, 1.2, 0) end
        hatBay(tam, xanhBang, 1.3, 20)
        LacManHinh(1.8)
        PhatAmThanh("boom", viTri, 1.15)
        noPhu(tam, xanhBang, 5, 0.35)
    end)
end

-- ===== 12. HOA ANH ĐÀO NỞ RỘ (MỚI) — 120 CÁNH HOA TỎA RỒI RƠI XUỐNG NHƯ TUYẾT HỒNG =====
local function HU_AnDao(viTri)
    local hong = Color3.fromRGB(255, 150, 190)
    local hongDam = Color3.fromRGB(255, 105, 160)
    local vangNuy = Color3.fromRGB(255, 230, 140)
    local tam = viTri + Vector3.new(0, 1.2, 0)
    -- nhụy vàng nở giữa bông
    local nuy = taoPartHU("HU_AnDao_Nuy", Vector3.new(0.6, 0.6, 0.6), vangNuy, Enum.Material.Neon, 0.1, tam)
    nuy.Shape = Enum.PartType.Ball
    TweenService:Create(nuy, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = Vector3.new(3.4, 3.4, 3.4)}):Play()
    task.delay(0.7, function()
        if nuy.Parent then
            TweenService:Create(nuy, TweenInfo.new(0.9), {Transparency = 1}):Play()
        end
    end)
    -- 2 vòng hương hồng nở chậm + 1 vòng đứng
    local dat = Vector3.new(viTri.X, viTri.Y - 2.3, viTri.Z)
    vongSong(dat, hong, 17, 1.1, 0)
    vongSong(dat, Color3.fromRGB(255, 240, 245), 24, 1.35, 0.2)
    vongDung(tam, hong, 13, 1, 0)
    -- CÁNH HOA TỎA RỘI: xoay bay rồi RƠI XUỐNG (trọng lực âm) như cánh hoa thật
    local khu = taoPartHU("HU_AnDao_Khu", Vector3.new(0.2, 0.2, 0.2), hong, Enum.Material.Neon, 1, tam)
    local canh = Instance.new("ParticleEmitter")
    canh.Name = "HU_AnDao_Canh"
    canh.Texture = TEX_SAO
    canh.Color = ColorSequence.new(hong, hongDam)
    canh.Rate = 0
    canh.Speed = NumberRange.new(9, 17)
    canh.Lifetime = NumberRange.new(1.3, 2.1)
    canh.SpreadAngle = Vector2.new(180, 180)
    canh.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.7, 0.34), NumberSequenceKeypoint.new(1, 0.08)})
    canh.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.75, 0.35), NumberSequenceKeypoint.new(1, 1)})
    canh.LightEmission = 0.8
    canh.LightInfluence = 0
    canh.Rotation = NumberRange.new(0, 360)
    canh.RotSpeed = NumberRange.new(-240, 240)
    canh.Acceleration = Vector3.new(0, -7, 0)
    canh.Drag = 1.6
    canh.Parent = khu
    canh:Emit(120)
    -- bụi vàng lấp lánh
    local sao = taoBurst(khu, TEX_SAO, vangNuy, 4, 10, 0.8, 1.5, 0.2)
    sao:Emit(40)
    PhatAmThanh("ping", viTri, 1.1)
    PhatAmThanh("shing", viTri, 1.35)
    -- cánh hoa tiếp tục rơi nhẹ rồi ngừng
    task.delay(1, function()
        pcall(function() canh.Rate = 22 end)
    end)
    task.delay(2.3, function()
        pcall(function() canh.Rate = 0 end)
    end)
end

-- ===== 13. LỐC XOÁY HƯ KHÔNG (MỚI) — 4 VÒNG WOBBLE + 10 CẦU XOÁN LÊN RỒI TAN THÀNH NỔ =====
local function HU_LocXoay(viTri)
    local tim = Color3.fromRGB(170, 110, 255)
    local xanh = Color3.fromRGB(110, 200, 255)
    local tam = viTri + Vector3.new(0, 2, 0)
    -- 4 đĩa nghiêng xoay wobble (xoay nhìn thấy được)
    local dia = {}
    for i = 1, 4 do
        local kich = 8.5 - i * 1.5
        dia[i] = taoPartHU("HU_Loc_Dia" .. i, Vector3.new(0.16, kich, kich), (i % 2 == 0) and tim or xanh, Enum.Material.Neon, 0.4, tam + Vector3.new(0, i * 3 - 1.5, 0))
        dia[i].Shape = Enum.PartType.Cylinder
        dia[i].CFrame = CFrame.new(dia[i].Position) * CFrame.Angles(0, 0, math.rad(90))
    end
    -- 10 cầu xoán ốc lên cao có vệt sáng
    local cau = {}
    for i = 1, 10 do
        local c = taoPartHU("HU_Loc_Cau" .. i, Vector3.new(0.3, 0.3, 0.3), (i % 2 == 0) and xanh or tim, Enum.Material.Neon, 0, tam)
        c.Shape = Enum.PartType.Ball
        local a0 = Instance.new("Attachment")
        a0.Parent = c
        local a1 = Instance.new("Attachment")
        a1.Position = Vector3.new(0, 0.35, 0)
        a1.Parent = c
        local vet = Instance.new("Trail")
        vet.Name = "HU_Loc_Vet"
        vet.Attachment0 = a0
        vet.Attachment1 = a1
        vet.Lifetime = 0.3
        vet.LightEmission = 1
        vet.FaceCamera = true
        vet.Color = ColorSequence.new(c.Color)
        vet.Transparency = NumberSequence.new(0.3, 1)
        vet.WidthScale = NumberSequence.new(1, 0)
        vet.Parent = c
        cau[i] = c
    end
    hatHut(tam, tim, 10, 6, 0.5)
    PhatAmThanh("shing", viTri, 0.9)
    LacManHinh(1.3)
    local t0 = os.clock()
    local ketNoi
    ketNoi = RunService.Heartbeat:Connect(function()
        if not dia[1].Parent or not cau[1].Parent then
            ketNoi:Disconnect()
            return
        end
        local t = os.clock() - t0
        for i = 1, 4 do
            local goc = t * (5.5 - i * 0.6)
            dia[i].CFrame = CFrame.new(dia[i].Position) * CFrame.Angles(math.cos(t * 2.4 + i) * 0.24, goc, math.sin(t * 1.8 + i) * 0.24) * CFrame.Angles(0, 0, math.rad(90))
        end
        for i = 1, 10 do
            local a = t * 4.6 + i * 0.628
            local h = ((t * 5.2 + i * 0.7) % 6.5) - 1
            local r = 4.6 - h * 0.55
            if r < 0.3 then r = 0.3 end
            cau[i].CFrame = CFrame.new(tam + Vector3.new(math.cos(a) * r, h, math.sin(a) * r))
        end
    end)
    -- sau 1.05s lốc XOÁY TAN THÀNH NỔ
    task.delay(1.05, function()
        for i = 1, 4 do if dia[i].Parent then dia[i]:Destroy() end end
        for i = 1, 10 do if cau[i].Parent then cau[i]:Destroy() end end
        cauNo(tam, tim, 15, 0.45)
        cauNo(tam + Vector3.new(0, 1, 0), xanh, 10, 0.6)
        gaiNo(tam, tim, 12, 8, 0.16)
        vongDung(tam, xanh, 18, 0.55, 0)
        local khu = taoPartHU("HU_Loc_Khu", Vector3.new(0.2, 0.2, 0.2), tim, Enum.Material.Neon, 1, tam)
        local e1 = taoBurst(khu, TEX_SAO, tim, 18, 32, 0.4, 0.9, 0.3, Vector3.new(0, -16, 0))
        e1:Emit(60)
        manhVun(tam, tim, 9, 28, true, false)
        hatBay(tam, xanh, 1.4, 20)
        vongSong(Vector3.new(viTri.X, viTri.Y - 2.3, viTri.Z), tim, 22, 0.6, 0)
        ChopManHinh(tim, 0.72)
        LacManHinh(2)
        PhatAmThanh("boom", viTri, 0.95)
        noPhu(tam, xanh, 6, 0.3)
        noPhu(tam, tim, 6, 0.55)
    end)
end

-- ===== 14. ĐOẠT HỒN LƯU LY (MỚI) — 7 HỒN LỬA XOÁN BỐC LÊN + ÁNH LẠNH TỎA RỘI =====
local function HU_DoatHon(viTri)
    local xanhSoi = Color3.fromRGB(120, 220, 255)
    local trangSoi = Color3.fromRGB(220, 245, 255)
    local tam = viTri + Vector3.new(0, 1, 0)
    -- 7 hồn lửa bốc lên xoán tròn, vệt sáng dài như vong hồn
    for i = 1, 7 do
        local hon = taoPartHU("HU_Hon" .. i, Vector3.new(0.55, 0.55, 0.55), (i % 2 == 0) and trangSoi or xanhSoi, Enum.Material.Neon, 0.08, tam)
        hon.Shape = Enum.PartType.Ball
        local a0 = Instance.new("Attachment")
        a0.Parent = hon
        local a1 = Instance.new("Attachment")
        a1.Position = Vector3.new(0, 0.42, 0)
        a1.Parent = hon
        local vet = Instance.new("Trail")
        vet.Name = "HU_Hon_Vet"
        vet.Attachment0 = a0
        vet.Attachment1 = a1
        vet.Lifetime = 0.42
        vet.LightEmission = 1
        vet.FaceCamera = true
        vet.Color = ColorSequence.new(hon.Color)
        vet.Transparency = NumberSequence.new(0.25, 1)
        vet.WidthScale = NumberSequence.new(1, 0)
        vet.Parent = hon
        local gocDau = (i / 7) * 6.283
        local tocXoan = 2.1 + math.random() * 1.2
        local banKinh = 1.3 + math.random() * 1.7
        local caoDau = math.random() * 1.4
        local t0 = os.clock()
        local ketNoi
        ketNoi = RunService.Heartbeat:Connect(function()
            if not hon.Parent then
                ketNoi:Disconnect()
                return
            end
            local t = os.clock() - t0
            local h = caoDau + t * (2.7 + i * 0.13)
            local r = banKinh * math.max(0.12, 1 - t * 0.5)
            hon.CFrame = CFrame.new(tam + Vector3.new(math.cos(gocDau + t * tocXoan) * r, h, math.sin(gocDau + t * tocXoan) * r))
        end)
        TweenService:Create(hon, TweenInfo.new(1.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1)}):Play()
    end
    -- hơi lạnh tỏa + vầng sáng xanh dưới đất + vòng đứng xoay
    local khu = taoPartHU("HU_DoatHon_Khu", Vector3.new(0.2, 0.2, 0.2), xanhSoi, Enum.Material.Neon, 1, tam)
    local lanh = taoBurst(khu, TEX_KHOI, xanhSoi, 0.8, 2.2, 1, 1.8, 0.85)
    lanh.Rate = 15
    lanh.SpreadAngle = Vector2.new(25, 25)
    lanh.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.72), NumberSequenceKeypoint.new(1, 1)})
    hatBay(tam, xanhSoi, 1.7, 20)
    vongSong(Vector3.new(viTri.X, viTri.Y - 2.3, viTri.Z), xanhSoi, 14, 1.25, 0)
    local vD = vongDung(tam, trangSoi, 10, 0.9, 0)
    if vD then xoayTin(vD, 1.2, 0.9, 0) end
    PhatAmThanh("ping", viTri, 0.8)
    PhatAmThanh("shing", viTri, 0.72)
    -- hồn tan xong: chớp xanh dịu + quả cầu sáng nở
    task.delay(1.45, function()
        ChopManHinh(xanhSoi, 0.82)
        cauNo(tam, trangSoi, 8, 0.55)
        -- dòng hồn TRỤ TRÒN bay lên trời (VER 5)
        taoBeam(tam, tam + Vector3.new(0, 14, 0), xanhSoi, 0.8, 0.8, trangSoi)
        PhatAmThanh("ping", viTri, 1.25)
    end)
end

local KIEU_HA_GUC = {
    ["Nổ Lõi Hủy Diệt"]     = HU_NoLoi,
    ["Sét Thiên Phạt"]      = HU_Set,
    ["Hố Đen Tự Hủy"]       = HU_HoDen,
    ["Mảnh Vụn Bùng Nổ"]    = HU_ManhVun,
    ["Xác Cháy Thành Tro"]  = HU_XacChay,
    ["Vòng Sóng Xung Kích"] = HU_SongXungKich,
    ["Cột Lửa Địa Ngục"]    = HU_CotLua,
    ["Nổ Máu Huyết"]        = HU_Mau,
    ["Song Kiếm Chém Chớp"] = HU_SongKiem,
    ["Sao Băng Tán Loạn"]   = HU_SaoBang,
    ["Băng Tinh Phong Ấn"]  = HU_BangTinh,
    ["Hoa Anh Đào Nở Rộ"]   = HU_AnDao,
    ["Lốc Xoáy Hư Không"]   = HU_LocXoay,
    ["Đoạt Hồn Lưu Ly"]     = HU_DoatHon,
}

local LAN_CHAY_CUOI = 0
local function ChayHieuUngHaGuc(viTri)
    if os.clock() - LAN_CHAY_CUOI < 0.15 then return end
    LAN_CHAY_CUOI = os.clock()
    local ten = ExtraConfig.KillEffectName
    if ten == "Ngẫu Nhiên Mỗi Lần Hạ" or not KIEU_HA_GUC[ten] then
        local danhSachTen = {}
        for k in pairs(KIEU_HA_GUC) do table.insert(danhSachTen, k) end
        ten = danhSachTen[math.random(#danhSachTen)]
    end
    local ham = KIEU_HA_GUC[ten]
    if ham then pcall(ham, viTri) end
end

-- ===== DÒ AI LÀ NGƯỜI HẠ GỤC NÓ =====
local function LaNguoiHaGuc(hum, char)
    -- 1) tag "creator" chuẩn Roblox
    local creator = hum:FindFirstChild("creator")
    if creator and creator:IsA("ObjectValue") then
        local v = creator.Value
        if v == LocalPlayer then return true end
        if typeof(v) == "Instance" and v.Name == LocalPlayer.Name then return true end
    end
    -- 2) mọi ObjectValue khác trong humanoid (game tự đặt tên riêng)
    for _, obj in ipairs(hum:GetChildren()) do
        if obj:IsA("ObjectValue") then
            local v = obj.Value
            if v == LocalPlayer then return true end
            if typeof(v) == "Instance" and v.Name == LocalPlayer.Name then return true end
        end
    end
    -- 3) attribute phổ biến game hay ghi
    local tenAttrs = {"creator", "Creator", "Killer", "killer", "LastAttacker", "lastAttacker", "Attacker", "attacker", "KilledBy", "killedBy"}
    for _, holder in ipairs({hum, char}) do
        for _, tenA in ipairs(tenAttrs) do
            local v = holder:GetAttribute(tenA)
            if v == LocalPlayer or v == LocalPlayer.Name then return true end
        end
    end
    return false
end

local function XuLyChet(char, hum)
    if not ExtraConfig.KillEffect then return end
    if not char or char == LocalPlayer.Character then return end
    local hrp = char:FindFirstChild("HumanoidRootPart") or hum.RootPart or char:FindFirstChildWhichIsA("BasePart")
    if not hrp then return end
    local viTri = hrp.Position
    if ExtraConfig.KillEffectChiMinh then
        if not LaNguoiHaGuc(hum, char) then return end
    else
        -- chế độ tính mọi địch chết: giới hạn gần mình để không nổ loãng cả map
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHrp and (myHrp.Position - viTri).Magnitude > 300 then return end
    end
    ChayHieuUngHaGuc(viTri)
end

-- ===== THEO DÕI TẤT CẢ NGƯỜI CHƠI KHÁC =====
local DA_THEO_DOI = setmetatable({}, {__mode = "k"})

local function TheoDoiNguoiChoi(player)
    if player == LocalPlayer then return end
    if DA_THEO_DOI[player] then return end
    DA_THEO_DOI[player] = true
    local function batChar(char)
        task.spawn(function()
            local hum = char:WaitForChild("Humanoid", 15)
            if hum then
                hum.Died:Connect(function()
                    XuLyChet(char, hum)
                end)
            end
        end)
    end
    if player.Character then batChar(player.Character) end
    player.CharacterAdded:Connect(batChar)
end

for _, pl in ipairs(Players:GetPlayers()) do
    TheoDoiNguoiChoi(pl)
end
Players.PlayerAdded:Connect(TheoDoiNguoiChoi)

-- ===== UI =====
MiscTab:AddToggle("Hiệu Ứng Khi Hạ Gục Địch (Kill Effect)", false, function(state)
    ExtraConfig.KillEffect = state
end)

MiscTab:AddDropdown("Kiểu Hiệu Ứng Hạ Gục", {"Nổ Lõi Hủy Diệt", "Sét Thiên Phạt", "Hố Đen Tự Hủy", "Mảnh Vụn Bùng Nổ", "Xác Cháy Thành Tro", "Vòng Sóng Xung Kích", "Cột Lửa Địa Ngục", "Nổ Máu Huyết", "Song Kiếm Chém Chớp", "Sao Băng Tán Loạn", "Băng Tinh Phong Ấn", "Hoa Anh Đào Nở Rộ", "Lốc Xoáy Hư Không", "Đoạt Hồn Lưu Ly", "Ngẫu Nhiên Mỗi Lần Hạ"}, "Nổ Lõi Hủy Diệt", function(choice)
    ExtraConfig.KillEffectName = choice
end)

MiscTab:AddToggle("Chỉ Tính Địch MÌNH Hạ Gục (Tắt = Mọi Địch Chết Gần Cũng Nổ)", true, function(state)
    ExtraConfig.KillEffectChiMinh = state
end)

MiscTab:AddToggle("Âm Thanh Khi Hạ Gục", true, function(state)
    ExtraConfig.KillEffectAmThanh = state
end)

MiscTab:AddToggle("Chớp Màn Hình Điện Ảnh Khi Hạ Gục (Tắt Nếu Chói Mắt)", true, function(state)
    ExtraConfig.KillEffectFlash = state
end)

MiscTab:AddButton("TEST HIỆU ỨNG HẠ GỤC — Xem Thử Ngay Tại Chỗ", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        ChayHieuUngHaGuc(hrp.Position + Vector3.new(0, 1, 0))
    end
end)
