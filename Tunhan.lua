--[[
	MEMAYBEO HUB v14.7 - PRISON LIFE SPECIALIST
	- FIXED: Highly stable base code
	- REMOVED: Silent Aim (Theo yêu cầu)
	- ADDED: Perfect Circular Hitbox (Transparent fill, solid outline)
	- Smart Aimbot Engine & Premium UI
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
    ESP_Color = Color3.fromRGB(90, 130, 255),
    
    Aimbot = false,
    HitboxExpander = false, -- HITBOX HÌNH TRÒN
    HitboxSize = 15,
    AimbotRequireWeapon = false,
    
    WallCheck = false,
    Smoothness = 0.5,
    Hitbox = "Head",
    CheckTeam = true,
    
    FOV_Visible = false,
    FOV_Radius = 150,
    Crosshair = false,
    
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_Tracer = false,
    ESP_Name = false,
    ESP_HealthBar = false,
    ESP_Distance = false,
    
    Speed = false,
    SpeedValue = 50,
    InfiniteJump = false,
    
    SpoofShoot = false,
    SpoofKey = "F",
    SpoofOnlyAimTarget = true,
    SpoofCooldown = 0.15
}

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
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) and player.Character then
            if Config.AimbotRequireWeapon and not TargetHasValidWeapon(player) then continue end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = GetHitbox(player.Character)
                if part and IsVisible(part) then
                    local dist3D = (Camera.CFrame.Position - part.Position).Magnitude
                    if dist3D > 200 then continue end
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

--// ENGINE: MỞ RỘNG HITBOX HÌNH TRÒN CHUẨN
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
                    hrp.Transparency = 0.99 -- Chừa lại 1% để Highlight nhận diện
                    
                    local highlight = hrp:FindFirstChild("HitboxGlow")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "HitboxGlow"
                        highlight.Parent = hrp
                        highlight.Adornee = hrp
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    highlight.FillColor = Config.ESP_Color
                    highlight.FillTransparency = 0.75 -- Trong suốt ở giữa
                    highlight.OutlineColor = Config.ESP_Color
                    highlight.OutlineTransparency = 0 -- Viền ngoài rõ 100%
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

--================================================================================--
-- SYSTEM ENGINE (AIMBOT, ESP, TELEPORT, SPOOF)
--================================================================================--

local Window = Library:CreateWindow("MEMAYBEO HUB")

local CombatTab = Window:CreateTab("Aimbot")
local EspTab = Window:CreateTab("Premium ESP")
local SpoofTab = Window:CreateTab("Spoof Shoot")
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

local function GetNearestPlayer()
    local target, targetPart = nil, nil
    local nearestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) and player.Character then
            if Config.AimbotRequireWeapon and not TargetHasValidWeapon(player) then continue end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = GetHitbox(player.Character)
                if part then
                    local dist = (Camera.CFrame.Position - part.Position).Magnitude
                    if dist < nearestDist and dist <= 200 then
                        nearestDist = dist
                        target = player
                        targetPart = part
                    end
                end
            end
        end
    end
    return target, targetPart
end

local ShootEvent = nil
local LastSpoofTime = 0
local function GetShootEvent()
    if not ShootEvent then pcall(function() ShootEvent = ReplicatedStorage:WaitForChild("GunRemotes"):WaitForChild("ShootEvent") end) end
    return ShootEvent
end
local function GetWeaponHandle()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local handle = child:FindFirstChild("Handle")
            if handle then return handle end
        end
    end
    return nil
end
local function FireSpoof(targetPart)
    local shootEvent = GetShootEvent()
    if not shootEvent then return false end
    local handle = GetWeaponHandle()
    if not handle then return false end
    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local args = { [1] = { [1] = origin, [2] = targetPos, [3] = handle } }
    pcall(function() shootEvent:FireServer(unpack(args)) end)
    return true
end

local function SetSpeed(speed)
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = speed end
end

--// DRAWING ESP TỔNG
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
            Skeleton = {}
        }
        
        ESP_Drawings[player].BoxOutline.Thickness = 3
        ESP_Drawings[player].BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        ESP_Drawings[player].BoxOutline.Filled = false
        ESP_Drawings[player].Box.Thickness = 1
        ESP_Drawings[player].Box.Color = Config.ESP_Color
        ESP_Drawings[player].Box.Filled = false
        
        ESP_Drawings[player].HealthBg.Thickness = 1
        ESP_Drawings[player].HealthBg.Color = Color3.fromRGB(0, 0, 0)
        ESP_Drawings[player].HealthBg.Filled = true
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
        
        for i = 1, 15 do
            ESP_Drawings[player].Skeleton[i] = {
                Outline = Drawing.new("Line"),
                Main = Drawing.new("Line")
            }
            ESP_Drawings[player].Skeleton[i].Outline.Thickness = 3
            ESP_Drawings[player].Skeleton[i].Outline.Color = Color3.fromRGB(0, 0, 0)
            ESP_Drawings[player].Skeleton[i].Main.Thickness = 1
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
        for _, lineSet in pairs(ESP_Drawings[player].Skeleton) do 
            lineSet.Outline:Remove()
            lineSet.Main:Remove()
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

--// RENDER STEPPED (XỬ LÝ MỌI HOẠT ĐỘNG)
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if FOVFrame then
        FOVFrame.Visible = Config.FOV_Visible
        FOVFrame.Size = UDim2.new(0, Config.FOV_Radius * 2, 0, Config.FOV_Radius * 2)
        FOVFrame.Position = UDim2.new(0, center.X, 0, center.Y)
        FOVStroke.Color = Config.ESP_Color
    end

    if CrosshairX and CrosshairY then
        CrosshairX.Visible = Config.Crosshair
        CrosshairY.Visible = Config.Crosshair
        CrosshairX.Color = Config.ESP_Color
        CrosshairY.Color = Config.ESP_Color
        if Config.Crosshair then
            CrosshairX.From = Vector2.new(center.X - 8, center.Y)
            CrosshairX.To = Vector2.new(center.X + 8, center.Y)
            CrosshairY.From = Vector2.new(center.X, center.Y - 8)
            CrosshairY.To = Vector2.new(center.X, center.Y + 8)
        end
    end

    if Config.Aimbot then
        local target, hitPart = GetClosestPlayer()
        if target and hitPart then
            local targetPos = hitPart.Position
            local newCF = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCF, Config.Smoothness)
        end
    end

    if Config.SpoofShoot then
        local keyPressed = UserInputService:IsKeyDown(Enum.KeyCode[Config.SpoofKey]) or false
        if keyPressed and os.clock() - LastSpoofTime >= Config.SpoofCooldown then
            LastSpoofTime = os.clock()
            local target, hitPart = nil, nil
            if Config.SpoofOnlyAimTarget then
                target, hitPart = GetClosestPlayer()
            else
                target, hitPart = GetNearestPlayer()
            end
            if target and hitPart then FireSpoof(hitPart) end
        end
    end

    if Config.Speed then
        SetSpeed(Config.SpeedValue)
    elseif not Config.Speed and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= 16 then humanoid.WalkSpeed = 16 end
    end

    -- CẬP NHẬT ESP (Fix size box)
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
                    
                    -- Dùng khoảng cách tĩnh để vẽ Box không bị biến dạng khi mở rộng Hitbox
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
                        local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barColor = Color3.fromRGB(255 - (255 * hpPercent), 255 * hpPercent, 0)
                        esp.HealthBg.Visible = true
                        esp.HealthBg.Size = Vector2.new(4, height + 2)
                        esp.HealthBg.Position = Vector2.new(boxX - 6, boxY - 1)
                        esp.HealthBar.Visible = true
                        esp.HealthBar.Size = Vector2.new(2, height * hpPercent)
                        esp.HealthBar.Position = Vector2.new(boxX - 5, boxY + height - (height * hpPercent))
                        esp.HealthBar.Color = barColor
                    else
                        esp.HealthBg.Visible = false
                        esp.HealthBar.Visible = false
                    end

                    if Config.ESP_Name then
                        esp.Name.Visible = true
                        esp.Name.Position = Vector2.new(hrpPos.X, boxY - 18)
                        esp.Name.Text = player.DisplayName
                    else
                        esp.Name.Visible = false
                    end
                    
                    if Config.ESP_Distance then
                        esp.Distance.Visible = true
                        esp.Distance.Position = Vector2.new(hrpPos.X, boxY + height + 2)
                        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                        esp.Distance.Text = string.format("[%.0fm]", dist)
                    else
                        esp.Distance.Visible = false
                    end
                    
                    if Config.ESP_Tracer then
                        esp.Tracer.Visible = true
                        esp.Tracer.From = Vector2.new(center.X, 0) 
                        esp.Tracer.To = Vector2.new(hrpPos.X, boxY) 
                    else
                        esp.Tracer.Visible = false
                    end
                    
                    -- SKELETON
                    if Config.ESP_Skeleton then
                        local boneIndex = 1
                        local function DrawBone(pos1, pos2)
                            if boneIndex > 15 then return end
                            local p1, s1 = Camera:WorldToViewportPoint(pos1)
                            local p2, s2 = Camera:WorldToViewportPoint(pos2)
                            if s1 and s2 then
                                esp.Skeleton[boneIndex].Outline.Visible = true
                                esp.Skeleton[boneIndex].Outline.From = Vector2.new(p1.X, p1.Y)
                                esp.Skeleton[boneIndex].Outline.To = Vector2.new(p2.X, p2.Y)
                                esp.Skeleton[boneIndex].Main.Visible = true
                                esp.Skeleton[boneIndex].Main.From = Vector2.new(p1.X, p1.Y)
                                esp.Skeleton[boneIndex].Main.To = Vector2.new(p2.X, p2.Y)
                            else
                                esp.Skeleton[boneIndex].Outline.Visible = false
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
                            esp.Skeleton[i].Outline.Visible = false
                            esp.Skeleton[i].Main.Visible = false
                        end
                    else
                        for i = 1, 15 do 
                            esp.Skeleton[i].Outline.Visible = false 
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
            for i = 1, 15 do 
                esp.Skeleton[i].Outline.Visible = false
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
    "Xanh Ngọc", "Đỏ", "Xanh Lá", "Xanh Dương", "Hồng", "Trắng", "Vàng", 
    "Tím", "Cam", "Lục Bảo", "Đỏ Rượu", "Vàng Chanh", "Xanh Dạ Quang", "Đen"
}
EspTab:AddDropdown("Đổi Màu Tổng ESP (Khóa Xương Trắng)", colorList, "Xanh Ngọc", function(value)
    if value == "Xanh Ngọc" then Config.ESP_Color = Color3.fromRGB(90, 130, 255)
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
    elseif value == "Xanh Dạ Quang" then Config.ESP_Color = Color3.fromRGB(100, 255, 100)
    elseif value == "Đen" then Config.ESP_Color = Color3.fromRGB(0, 0, 0)
    end
end)
EspTab:AddToggle("Khung Box Chuẩn (Có Đổ Bóng)", false, function(state) Config.ESP_Box = state end)
EspTab:AddToggle("Thanh Máu Dọc (Health Bar)", false, function(state) Config.ESP_HealthBar = state end)
EspTab:AddToggle("Khung Xương Đổ Bóng (Skeleton)", false, function(state) Config.ESP_Skeleton = state end)
EspTab:AddToggle("Tên Người Chơi (Name)", false, function(state) Config.ESP_Name = state end)
EspTab:AddToggle("Khoảng Cách (Distance)", false, function(state) Config.ESP_Distance = state end)
EspTab:AddToggle("Tia Chỉ Đường Từ Đỉnh Màn Hình", false, function(state) Config.ESP_Tracer = state end)

-- Tab Misc
local BaseCanhSat = CFrame.new(796.100159, 95.9900055, 2298.94995, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local BaseToiPham = CFrame.new(-975.09613, 105.223694, 2057.90454, -4.37113883e-08, 0, -1, 0, 1, 0, 1, 0, -4.37113883e-08)

MiscTab:AddButton("Teleport Base Cảnh Sát", function() TeleportTo(BaseCanhSat) end)
MiscTab:AddButton("Teleport Base Tội Phạm", function() TeleportTo(BaseToiPham) end)

MiscTab:AddToggle("Nhảy Vô Hạn (Infinite Jump)", false, function(state) Config.InfiniteJump = state end)
MiscTab:AddToggle("Tăng Tốc Di Chuyển (Speed Hack)", false, function(state) 
    Config.Speed = state 
    if not state then SetSpeed(16) end
end)
MiscTab:AddSlider("Mức Độ Tăng Tốc", 16, 100, 50, function(value) 
    Config.SpeedValue = value 
    if Config.Speed then SetSpeed(value) end
end)

-- Tab Spoof
SpoofTab:AddToggle("Bắn Xuyên Tường (Spoof Remote)", false, function(state) Config.SpoofShoot = state end)
SpoofTab:AddDropdown("Phím Kích Hoạt Bắn Spoof", {"F", "Q", "E", "R", "X", "C", "V", "B"}, "F", function(value) Config.SpoofKey = value end)
SpoofTab:AddToggle("Spoof: Chỉ Bắn Kẻ Đang Bị Aim", true, function(state) Config.SpoofOnlyAimTarget = state end)
SpoofTab:AddSlider("Spoof Cooldown Bắn (ms)", 50, 500, 150, function(value) Config.SpoofCooldown = value / 1000 end)

