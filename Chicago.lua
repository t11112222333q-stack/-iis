--[[
	MEMAYBEO HUB v17.3 - PRISON LIFE SPECIALIST
	- FIXED: Aimbot Offset. Aimbot now perfectly aligns with GunGUI.Crosshair.
	- TỐC ĐỘ: Nhanh hơn đi bộ gấp nhiều lần, an toàn tuyệt đối qua mặt Anti-Cheat.
	- FIXED: Triệt tiêu hoàn toàn lỗi khung xương đen & thanh máu bị khối đen che khuất.
	- UPDATED: Mặc định tất cả màu ESP là Xanh Dạ Quang (ngoại trừ Xương giữ màu Trắng).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera

--// BẢNG MÀU PREMIUM
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

--// CẤU HÌNH LOGIC
local Config = {
    ESP_Color = Color3.fromRGB(100, 255, 100), -- Mặc định Xanh Dạ Quang
    
    Aimbot = false,
    HitboxExpander = false, 
    HitboxSize = 15,
    AimbotRequireWeapon = false,
    
    WallCheck = false,
    Smoothness = 0.5,
    Hitbox = "Head",
    CheckTeam = true,
    
    FOV_Visible = false,
    FOV_Radius = 150,
    Crosshair = false,
    
    -- ESP MẶC ĐỊNH
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_Tracer = false,
    ESP_Name = false,
    ESP_HealthBar = false,
    ESP_Distance = false,
    
    -- ESP BỔ SUNG MỚI
    ESP_Weapon = false,      -- Tên súng (Dưới chân)
    ESP_HeadCircle = false,  -- Vòng tròn quanh đầu
    ESP_SnapLines = false,   -- Đường kẻ đến tâm màn hình
    ESP_State = false,       -- Trạng thái Stand/Run/Jump/Fall (Dưới chân)
    ESP_Chams = false,       -- Xuyên tường Highlight (Toàn thân)
    ESP_HealthText = false,  -- Hiện số HP cụ thể (Trên đầu)
    ESP_Box3D = false,       -- Khung hộp 3D (Bao quanh người)
    
    Speed = false,
    SpeedValue = 50,
    InfiniteJump = false,
    
    AutoGetBox = false, 
    AutoFarmLoop = false, 
    StepSize = 12
}

--// HÀM LẤY TÂM SÚNG CHUẨN TỪ CROSSHAIR CỦA GAME
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

--// HÀM KÉO THẢ MƯỢT
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

--// ENGINE: DI CHUYỂN CFRAME
local function FastStepMove(targetPos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local targetV3 = Vector3.new(targetPos.X, targetPos.Y, targetPos.Z)
    
    while Config.AutoFarmLoop do
        char = LocalPlayer.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if not hrp or not hum or hum.Health <= 0 then break end
        
        local currentPos = hrp.Position
        local diff = targetV3 - currentPos
        
        if diff.Magnitude < Config.StepSize then
            hrp.CFrame = CFrame.new(targetV3)
            break
        end
        
        hrp.CFrame = hrp.CFrame + (diff.Unit * Config.StepSize)
        task.wait(0.04) 
    end
end

--// ENGINE: CHECK VŨ KHÍ MỤC TIÊU
local function TargetHasValidWeapon(player)
    if not player then return false end
    local validWeapons = {}
    local itemsFolder = workspace:FindFirstChild("Prison_ITEMS")
    if itemsFolder then
        local giverFolder = itemsFolder:FindFirstChild("giver")
        if giverFolder then
            for _, item in pairs(giverFolder:GetChildren()) do validWeapons[item.Name] = true end
        end
    end
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") and validWeapons[tool.Name] then return true end
        end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and validWeapons[tool.Name] then return true end
        end
    end
    return false
end

--// ENGINE: LẤY TÊN VŨ KHÍ HIỆN TẠI
local function GetEquippedWeaponName(player)
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                return tool.Name
            end
        end
    end
    return "Hands"
end

--// ENGINE: LẤY TRẠNG THÁI HÀNH ĐỘNG
local function GetCharacterState(humanoid)
    if not humanoid then return "Stand" end
    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping then
        return "Jump"
    elseif state == Enum.HumanoidStateType.Freefall then
        return "Fall"
    elseif humanoid.MoveDirection.Magnitude > 0 then
        return "Run"
    else
        return "Stand"
    end
end

--// ENGINE: LẤY MỤC TIÊU (DÙNG CHO AIMBOT)
local function IsTeammate(player)
    if not Config.CheckTeam then return false end
    if LocalPlayer.Team and player.Team then return LocalPlayer.Team == player.Team end
    return false
end

local function GetHitbox(character)
    local part = nil
    if Config.Hitbox == "Head" then
        part = character:FindFirstChild("Head")
    elseif Config.Hitbox == "UpperBody" then
        part = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    elseif Config.Hitbox == "LowerBody" then
        part = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
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
        if player ~= LocalPlayer and not IsTeammate(player) and player.Character then
            if Config.AimbotRequireWeapon and not TargetHasValidWeapon(player) then continue end
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

--// ENGINE: MỞ RỘNG HITBOX
task.spawn(function()
    while task.wait(0.1) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local humanoid = player.Character:FindFirstChild("Humanoid")
                
                if Config.HitboxExpander and humanoid and humanoid.Health > 0 and not IsTeammate(player) then
                    hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    hrp.Shape = Enum.PartType.Ball
                    hrp.CanCollide = false
                    hrp.Transparency = 0.99 
                    
                    local highlight = hrp:FindFirstChild("HitboxGlow")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "HitboxGlow"
                        highlight.Parent = hrp
                        highlight.Adornee = hrp
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    highlight.FillColor = Config.ESP_Color
                    highlight.FillTransparency = 0.75 
                    highlight.OutlineColor = Config.ESP_Color
                    highlight.OutlineTransparency = 0 
                    highlight.Enabled = true
                else
                    if hrp.Size.X > 2.1 then 
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Shape = Enum.PartType.Block
                        hrp.Transparency = 1
                        local highlight = hrp:FindFirstChild("HitboxGlow")
                        if highlight then highlight.Enabled = false end
                    end
                end
            end
        end
    end
end)

--// THƯ VIỆN UI ULTRA PREMIUM
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
    MainFrame.Size = UDim2.new(0, 620, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -240)
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
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 620, 0, 480), Position = UDim2.new(0.5, -310, 0.5, -240)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 620, 0, 0), Position = UDim2.new(0.5, -310, 0.5, 0)}):Play()
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
                Btn.Text = "Đang xử lý..."
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
            Switch.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                }):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Colors.Accent or Colors.ToggleOff}):Play()
                callback(state)
            end)
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

local Window = Library:CreateWindow("MEMAYBEO HUB v17.3")

local CombatTab = Window:CreateTab("Aimbot")
local EspTab = Window:CreateTab("Premium ESP")
local TeleportTab = Window:CreateTab("Teleport")
local MiscTab = Window:CreateTab("Misc")

--// GUI FOV & CROSSHAIR
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

--// HÀM BỔ TRỢ
local function TeleportTo(cf)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
    end
end

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function SetSpeed(speed)
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = speed end
end

--// DRAWING ESP TỔNG (ĐÃ FIX TRIỆT ĐỂ LỖI ĐEN NÉT/ĐEN NỀN)
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
        
        -- FIX MÁU: Nền mỏng không che đè
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

        -- KHUNG XƯƠNG: Giữ nguyên màu trắng độc lập, không bị đổi theo màu tổng ESP
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
end)

local R15_Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

--// RENDER STEPPED CHÍNH
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
        SetSpeed(Config.SpeedValue)
    elseif not Config.Speed and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= 16 then humanoid.WalkSpeed = 16 end
    end

    -- CẬP NHẬT TẤT CẢ ESP
    for player, esp in pairs(ESP_Drawings) do
        local isVisible = false
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 and not IsTeammate(player) then
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

                    -- 1. BOX 2D
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

                    -- 2. HEALTH BAR
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

                    -- 3. TÊN NGƯỜI CHƠI (TRÊN ĐẦU)
                    local currentTopOffset = 18
                    if Config.ESP_Name then
                        esp.Name.Visible = true
                        esp.Name.Position = Vector2.new(hrpPos.X, boxY - currentTopOffset)
                        esp.Name.Text = player.DisplayName
                        currentTopOffset = currentTopOffset + 14
                    else
                        esp.Name.Visible = false
                    end

                    -- 4. ESP SỐ MÁU (HIỆN SỐ HP TRÊN ĐẦU)
                    if Config.ESP_HealthText then
                        esp.HealthText.Visible = true
                        esp.HealthText.Position = Vector2.new(hrpPos.X, boxY - currentTopOffset)
                        esp.HealthText.Text = string.format("%d HP", math.floor(humanoid.Health))
                        currentTopOffset = currentTopOffset + 14
                    else
                        esp.HealthText.Visible = false
                    end
                    
                    -- 5. KHOẢNG CÁCH & TÊN VŨ KHÍ & TRẠNG THÁI (DƯỚI CHÂN)
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

                    -- ESP VŨ KHÍ (DƯỚI CHÂN)
                    if Config.ESP_Weapon then
                        esp.Weapon.Visible = true
                        esp.Weapon.Position = Vector2.new(hrpPos.X, boxY + height + currentBottomOffset)
                        esp.Weapon.Text = GetEquippedWeaponName(player)
                        currentBottomOffset = currentBottomOffset + 14
                    else
                        esp.Weapon.Visible = false
                    end

                    -- ESP TRẠNG THÁI (DƯỚI CHÂN)
                    if Config.ESP_State then
                        esp.State.Visible = true
                        esp.State.Position = Vector2.new(hrpPos.X, boxY + height + currentBottomOffset)
                        esp.State.Text = "[" .. GetCharacterState(humanoid) .. "]"
                    else
                        esp.State.Visible = false
                    end

                    -- 6. VÒNG TRÒN ĐẦU
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

                    -- 7. SNAP LINES (TỪ ĐỊCH TỚI TRUNG TÂM MÀN HÌNH)
                    if Config.ESP_SnapLines then
                        esp.SnapLine.Visible = true
                        local viewportSize = Camera.ViewportSize
                        esp.SnapLine.From = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                        esp.SnapLine.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    else
                        esp.SnapLine.Visible = false
                    end
                    
                    -- 8. TRACER (TỪ ĐỈNH MÀN HÌNH)
                    if Config.ESP_Tracer then
                        esp.Tracer.Visible = true
                        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        esp.Tracer.From = Vector2.new(center.X, 0) 
                        esp.Tracer.To = Vector2.new(hrpPos.X, boxY) 
                    else
                        esp.Tracer.Visible = false
                    end

                    -- 9. ESP BOX 3D (KHUNG HỘP CÓ ĐỘ SÂU)
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

                    -- 10. ESP CHAMS (HIGHLIGHT XUYÊN TƯỜNG)
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
                    
                    -- 11. SKELETON (LUÔN GIỮ MÀU TRẮNG SÁNG CỐ ĐỊNH)
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

--// SETUP MENU UI TRỰC QUAN
-- Tab Aimbot
CombatTab:AddToggle("Bật Aimbot Khóa Góc Nhìn", false, function(state) Config.Aimbot = state end)
CombatTab:AddToggle("Mở Rộng Hitbox Địch (Hình Tròn)", false, function(state) Config.HitboxExpander = state end)
CombatTab:AddSlider("Kích Thước Hitbox", 2, 50, 15, function(value) Config.HitboxSize = value end)
CombatTab:AddToggle("Chỉ Aim Người Có Vũ Khí (Balo + Tay)", false, function(state) Config.AimbotRequireWeapon = state end)
CombatTab:AddToggle("Kiểm Tra Vật Cản (Wall Check)", false, function(state) Config.WallCheck = state end)
CombatTab:AddToggle("Bỏ Qua Đồng Đội (Check Team)", true, function(state) Config.CheckTeam = state end)
CombatTab:AddDropdown("Chọn Hitbox (Điểm Ngắm)", {"Head", "UpperBody", "LowerBody"}, "Head", function(value) Config.Hitbox = value end)
CombatTab:AddSlider("Độ Mượt (Smoothness)", 1, 100, 50, function(value) Config.Smoothness = value / 100 end)

CombatTab:AddToggle("Hiển Thị Tâm Ngắm Ảo (Crosshair)", false, function(state) Config.Crosshair = state end)
CombatTab:AddToggle("Hiển Thị Vòng FOV Giữa Màn Hình", false, function(state) Config.FOV_Visible = state end)
CombatTab:AddSlider("Độ Rộng Vòng FOV", 50, 800, 150, function(value) Config.FOV_Radius = value end)

-- Tab ESP
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

--========================================================================
-- TAB TELEPORT (DANH SÁCH TỌA ĐỘ)
--========================================================================

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

--========================================================================
-- TAB MISC / AUTO FARM CHÍNH
--========================================================================

local CustomCoord1 = Vector3.new(-1331.60803, 51.309124, -4.15756035)
local CustomCoord2 = Vector3.new(-1484.28308, 51.2921562, -50.5562782)

MiscTab:AddToggle("Auto Farm CFrame Tốc Độ Cao", false, function(state) 
    Config.AutoFarmLoop = state 
end)

MiscTab:AddSlider("Tốc Độ CFrame (Giảm nếu bị kick)", 5, 30, 12, function(value) 
    Config.StepSize = value 
end)

MiscTab:AddToggle("Tự Kích Hoạt Nút (Auto Húp Box)", false, function(state) 
    Config.AutoGetBox = state 
end)

MiscTab:AddToggle("Nhảy Vô Hạn (Infinite Jump)", false, function(state) Config.InfiniteJump = state end)
MiscTab:AddToggle("Tăng Tốc Di Chuyển (Speed Hack)", false, function(state) 
    Config.Speed = state 
    if not state then SetSpeed(16) end
end)
MiscTab:AddSlider("Mức Độ Tăng Tốc", 16, 100, 50, function(value) 
    Config.SpeedValue = value 
    if Config.Speed then SetSpeed(value) end
end)

--// LÕI XỬ LÝ AUTO FARM CFRAME TỪNG ĐOẠN NGẮN
task.spawn(function()
    while task.wait(0.2) do
        if Config.AutoFarmLoop then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                FastStepMove(CustomCoord1)
                task.wait(1.2) 
                
                FastStepMove(CustomCoord2)
                task.wait(1.2)
            end
        end
    end
end)

--// LÕI XỬ LÝ TỰ KÍCH HOẠT PROXIMITY PROMPT
task.spawn(function()
    while task.wait(0.2) do
        if Config.AutoGetBox or Config.AutoFarmLoop then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, prompt in pairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Parent:IsA("BasePart") then
                            if (prompt.Parent.Position - hrp.Position).Magnitude <= prompt.MaxActivationDistance then
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end)
        end
    end
end)
