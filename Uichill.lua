-- ====================================================================
-- MEMAYBEO HUB v12.0 (APEX TIER - SETTINGS ONLY)
-- ====================================================================

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("MemaybeoPremiumUI") then
    CoreGui["MemaybeoPremiumUI"]:Destroy()
end

-- ====================================================================
-- 1. BASE GUI & MAC-OS STYLE WINDOW 
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MemaybeoPremiumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Wrapper = Instance.new("Frame")
Wrapper.Name = "Wrapper"
Wrapper.Size = UDim2.new(0, 0, 0, 0)
Wrapper.Position = UDim2.new(0.5, 0, 0.5, 0)
Wrapper.BackgroundTransparency = 1 
Wrapper.Active = true
Wrapper.Draggable = true
Wrapper.Parent = ScreenGui

local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 10)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 1
MainFrame.Parent = Wrapper

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 170)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2 

local StrokeGradient = Instance.new("UIGradient", MainStroke)
StrokeGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 170)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 40, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 170))
}
RunService.RenderStepped:Connect(function()
    StrokeGradient.Rotation = (StrokeGradient.Rotation + 1) % 360
end)

TweenService:Create(Wrapper, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 650, 0, 420),
    Position = UDim2.new(0.5, -325, 0.5, -210)
}):Play()

-- ====================================================================
-- 2. MAC-OS WINDOW CONTROLS
-- ====================================================================
local WindowControls = Instance.new("Frame")
WindowControls.Size = UDim2.new(0, 60, 0, 20)
WindowControls.Position = UDim2.new(0, 15, 0, 15)
WindowControls.BackgroundTransparency = 1
WindowControls.ZIndex = 10
WindowControls.Parent = MainFrame

local function CreateWindowButton(color, posX, action)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 13, 0, 13)
    Btn.Position = UDim2.new(0, posX, 0.5, -6.5)
    Btn.BackgroundColor3 = color
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    Btn.Parent = WindowControls

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(0, posX - 1, 0.5, -7.5)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 13, 0, 13), Position = UDim2.new(0, posX, 0.5, -6.5)}):Play()
    end)
    Btn.MouseButton1Click:Connect(action)
    return Btn
end

local menuVisible = true
local function ToggleMenu()
    menuVisible = not menuVisible
    local targetSize = menuVisible and UDim2.new(0, 650, 0, 420) or UDim2.new(0, 0, 0, 0)
    TweenService:Create(Wrapper, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end

CreateWindowButton(Color3.fromRGB(255, 95, 86), 0, function()
    TweenService:Create(Wrapper, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.4)
    ScreenGui:Destroy()
end)
CreateWindowButton(Color3.fromRGB(255, 189, 46), 22, ToggleMenu)
CreateWindowButton(Color3.fromRGB(39, 201, 63), 44, function() end)

UserInputService.InputBegan:Connect(function(input, p)
    if input.KeyCode == Enum.KeyCode.RightControl and not p then ToggleMenu() end
end)

-- ====================================================================
-- 3. BACKGROUND MATRIX
-- ====================================================================
local MatrixContainer = Instance.new("Frame")
MatrixContainer.Size = UDim2.new(1, 0, 1, 0)
MatrixContainer.BackgroundTransparency = 1
MatrixContainer.ZIndex = 1
MatrixContainer.Parent = MainFrame

local chars = {"M", "A", "T", "R", "I", "X", "0", "1", "A", "P", "E", "X"}
local rng = Random.new()

task.spawn(function()
    while task.wait(0.08) do
        local drop = Instance.new("TextLabel")
        drop.Text = chars[rng:NextInteger(1, #chars)]
        drop.TextColor3 = Color3.fromRGB(0, 255, 170)
        drop.TextSize = rng:NextInteger(10, 16)
        drop.Font = Enum.Font.Code
        drop.BackgroundTransparency = 1
        drop.Position = UDim2.new(rng:NextNumber(), 0, -0.1, 0)
        drop.TextTransparency = 0.5
        drop.ZIndex = 1
        drop.Parent = MatrixContainer
        
        local tween = TweenService:Create(drop, TweenInfo.new(rng:NextNumber(3, 7), Enum.EasingStyle.Linear), {
            Position = UDim2.new(drop.Position.X.Scale, 0, 1.2, 0), TextTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function() drop:Destroy() end)
    end
end)

-- ====================================================================
-- 4. SIDEBAR & PROFILE
-- ====================================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Sidebar.BackgroundTransparency = 0.6
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
Sidebar.Parent = MainFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SidebarLine.BackgroundTransparency = 0.9
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 2
SidebarLine.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "MEMAYBEO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18 
Title.ZIndex = 2
Title.Parent = Sidebar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 15)
SubTitle.Position = UDim2.new(0, 0, 0, 70)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "APEX EDITION"
SubTitle.TextColor3 = Color3.fromRGB(0, 255, 170)
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = 10 
SubTitle.ZIndex = 2
SubTitle.Parent = Sidebar

local UserProfile = Instance.new("Frame")
UserProfile.Size = UDim2.new(1, -20, 0, 50)
UserProfile.Position = UDim2.new(0, 10, 1, -60)
UserProfile.BackgroundColor3 = Color3.fromRGB(20, 25, 22)
UserProfile.BackgroundTransparency = 0.5
Instance.new("UICorner", UserProfile).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", UserProfile).Color = Color3.fromRGB(255, 255, 255)
UserProfile.UIStroke.Transparency = 0.9
UserProfile.ZIndex = 3
UserProfile.Parent = Sidebar

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 34, 0, 34)
Avatar.Position = UDim2.new(0, 8, 0.5, -17)
Avatar.BackgroundColor3 = Color3.fromRGB(30, 35, 32)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
Avatar.ZIndex = 4
Avatar.Parent = UserProfile

local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(1, -60, 0, 20)
UserName.Position = UDim2.new(0, 50, 0, 8)
UserName.BackgroundTransparency = 1
UserName.Text = LocalPlayer.DisplayName
UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 13
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.TextTruncate = Enum.TextTruncate.AtEnd
UserName.ZIndex = 4
UserName.Parent = UserProfile

local UserID = Instance.new("TextLabel")
UserID.Size = UDim2.new(1, -60, 0, 15)
UserID.Position = UDim2.new(0, 50, 0, 26)
UserID.BackgroundTransparency = 1
UserID.Text = "@" .. LocalPlayer.Name
UserID.TextColor3 = Color3.fromRGB(150, 160, 150)
UserID.Font = Enum.Font.Gotham
UserID.TextSize = 10
UserID.TextXAlignment = Enum.TextXAlignment.Left
UserID.TextTruncate = Enum.TextTruncate.AtEnd
UserID.ZIndex = 4
UserID.Parent = UserProfile

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -170)
TabContainer.Position = UDim2.new(0, 10, 0, 100)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex = 2
TabContainer.Parent = Sidebar

local TabIndicator = Instance.new("Frame")
TabIndicator.Size = UDim2.new(0, 3, 0, 32)
TabIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
TabIndicator.BorderSizePixel = 0
TabIndicator.ZIndex = 4
Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(1, 0)
TabIndicator.Parent = TabContainer

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -190, 1, -20)
ContentArea.Position = UDim2.new(0, 180, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 2
ContentArea.Parent = MainFrame

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, 0, 0, 40)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "DASHBOARD"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.Font = Enum.Font.GothamBlack
HeaderLabel.TextSize = 24
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.ZIndex = 2
HeaderLabel.Parent = ContentArea

-- LIVE STATS
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(0, 150, 0, 40)
StatsLabel.Position = UDim2.new(1, -150, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: 60 | 00:00:00"
StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 13
StatsLabel.TextXAlignment = Enum.TextXAlignment.Right
StatsLabel.ZIndex = 2
StatsLabel.Parent = ContentArea

local lastTime = tick()
local frames = 0
RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastTime >= 1 then
        StatsLabel.Text = string.format("FPS: %d | %s", frames, os.date("%H:%M:%S"))
        frames = 0
        lastTime = tick()
    end
end)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 0, 45)
HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderLine.BackgroundTransparency = 0.9
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 2
HeaderLine.Parent = ContentArea

-- ====================================================================
-- 5. TOAST NOTIFICATION SYSTEM (SLIDE-IN + PROGRESS BAR)
-- ====================================================================
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 250, 1, -40)
NotifContainer.Position = UDim2.new(1, -20, 1, -20)
NotifContainer.AnchorPoint = Vector2.new(1, 1)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ZIndex = 100
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Padding = UDim.new(0, 10)
NotifLayout.Parent = NotifContainer

local function Notify(title, text, duration)
    duration = duration or 3 -- Mặc định hiện 3 giây
    
    -- Khung bảo vệ (Đứng im trong Layout)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 60)
    Holder.BackgroundTransparency = 1
    Holder.Parent = NotifContainer

    -- Khung Toast (Sẽ trượt từ ngoài vào trong Holder)
    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 0, 1, 0)
    Toast.Position = UDim2.new(1, 60, 0, 0) -- Bắt đầu ở bên phải ngoài màn hình
    Toast.BackgroundColor3 = Color3.fromRGB(15, 20, 18)
    Toast.BackgroundTransparency = 0.1
    Toast.ClipsDescendants = true
    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 8)
    Toast.Parent = Holder
    
    local NStroke = Instance.new("UIStroke", Toast)
    NStroke.Color = Color3.fromRGB(0, 255, 170)
    NStroke.Thickness = 1
    NStroke.Transparency = 0.5

    -- Icon viền trái
    local NIcon = Instance.new("Frame")
    NIcon.Size = UDim2.new(0, 4, 1, -20)
    NIcon.Position = UDim2.new(0, 10, 0, 10)
    NIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
    Instance.new("UICorner", NIcon).CornerRadius = UDim.new(1, 0)
    NIcon.Parent = Toast

    -- Thanh chạy thời gian (Progress Bar) ở đáy
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(1, 0, 0, 3)
    ProgressBar.Position = UDim2.new(0, 0, 1, -3)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = Toast

    local NTitle = Instance.new("TextLabel", Toast)
    NTitle.Size = UDim2.new(1, -30, 0, 20)
    NTitle.Position = UDim2.new(0, 25, 0, 10)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextSize = 13
    NTitle.TextXAlignment = Enum.TextXAlignment.Left

    local NDesc = Instance.new("TextLabel", Toast)
    NDesc.Size = UDim2.new(1, -30, 0, 20)
    NDesc.Position = UDim2.new(0, 25, 0, 28)
    NDesc.BackgroundTransparency = 1
    NDesc.Text = text
    NDesc.TextColor3 = Color3.fromRGB(180, 200, 190)
    NDesc.Font = Enum.Font.Gotham
    NDesc.TextSize = 11
    NDesc.TextXAlignment = Enum.TextXAlignment.Left

    -- TRƯỢT VÀO
    TweenService:Create(Toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    -- THANH TIẾN ĐỘ CHẠY LÙI
    TweenService:Create(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()

    -- TRƯỢT RA SAU KHI HẾT GIỜ
    task.delay(duration, function()
        local tweenOut = TweenService:Create(Toast, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 1})
        tweenOut:Play()
        tweenOut.Completed:Connect(function() Holder:Destroy() end)
    end)
end

-- ====================================================================
-- 6. TAB SYSTEM & SECTIONS (PERFECT SHRINK WRAP)
-- ====================================================================
local Tabs = {}
local tabOffset = 0

local function CreateTab(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -8, 0, 32)
    TabButton.Position = UDim2.new(0, 8, 0, tabOffset)
    TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = "      " .. tabName
    TabButton.TextColor3 = Color3.fromRGB(150, 160, 150)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 13 
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.ZIndex = 3
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)
    TabButton.Parent = TabContainer

    local currentOffset = tabOffset
    tabOffset = tabOffset + 38 

    TabButton.MouseEnter:Connect(function()
        if TabButton.BackgroundTransparency > 0.8 then
            TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 255, 220), BackgroundTransparency = 0.95}):Play()
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if TabButton.BackgroundTransparency > 0.8 then
            TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 160, 150), BackgroundTransparency = 1}):Play()
        end
    end)

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1, 0, 1, -55)
    TabPage.Position = UDim2.new(0, 0, 0, 55)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 1
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
    TabPage.Visible = false
    TabPage.ZIndex = 3
    TabPage.Parent = ContentArea

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10) 
    PageLayout.Parent = TabPage

    local function UpdateCanvas()
        TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
    end
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            TweenService:Create(tab.Button, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 160, 150)}):Play()
            tab.Page.Visible = false
        end
        TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.9, TextColor3 = Color3.fromRGB(0, 255, 170)}):Play()
        TweenService:Create(TabIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, currentOffset)}):Play()
        TabPage.Visible = true
        HeaderLabel.TextTransparency = 1
        HeaderLabel.Text = string.upper(tabName)
        TweenService:Create(HeaderLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    end)

    local tabData = {Button = TabButton, Page = TabPage}
    table.insert(Tabs, tabData)

    if #Tabs == 1 then
        TabButton.BackgroundTransparency = 0.9
        TabButton.TextColor3 = Color3.fromRGB(0, 255, 170)
        TabPage.Visible = true
        HeaderLabel.Text = string.upper(tabName)
        TabIndicator.Position = UDim2.new(0, 0, 0, currentOffset)
    end

    function tabData:AddSection(sectionName)
        local SecFrame = Instance.new("Frame")
        SecFrame.Size = UDim2.new(1, -10, 0, 30)
        SecFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SecFrame.BackgroundTransparency = 0.97
        Instance.new("UICorner", SecFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", SecFrame).Color = Color3.fromRGB(255, 255, 255)
        SecFrame.UIStroke.Transparency = 0.9
        SecFrame.Parent = TabPage

        -- TÁCH TIÊU ĐỀ
        local SecTitle = Instance.new("TextLabel")
        SecTitle.Size = UDim2.new(1, -20, 0, 30)
        SecTitle.Position = UDim2.new(0, 10, 0, 0)
        SecTitle.BackgroundTransparency = 1
        SecTitle.Text = sectionName
        SecTitle.TextColor3 = Color3.fromRGB(0, 255, 170)
        SecTitle.Font = Enum.Font.GothamBold
        SecTitle.TextSize = 13 
        SecTitle.TextXAlignment = Enum.TextXAlignment.Left
        SecTitle.Parent = SecFrame

        local SecLine = Instance.new("Frame")
        SecLine.Size = UDim2.new(1, -20, 0, 1)
        SecLine.Position = UDim2.new(0, 10, 0, 30)
        SecLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SecLine.BackgroundTransparency = 0.9
        SecLine.BorderSizePixel = 0
        SecLine.Parent = SecFrame

        -- HỘP CHỨA NÚT
        local ItemContainer = Instance.new("Frame")
        ItemContainer.Size = UDim2.new(1, 0, 1, -31)
        ItemContainer.Position = UDim2.new(0, 0, 0, 31)
        ItemContainer.BackgroundTransparency = 1
        ItemContainer.Parent = SecFrame

        local SecLayout = Instance.new("UIListLayout")
        SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SecLayout.Padding = UDim.new(0, 6) 
        SecLayout.Parent = ItemContainer

        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 8) 
        Padding.PaddingBottom = UDim.new(0, 8) 
        Padding.PaddingLeft = UDim.new(0, 12)
        Padding.PaddingRight = UDim.new(0, 12)
        Padding.Parent = ItemContainer

        SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SecFrame.Size = UDim2.new(1, -10, 0, SecLayout.AbsoluteContentSize.Y + 47) 
            UpdateCanvas()
        end)

        local secData = {}

        -- [ LABEL ]
        function secData:AddLabel(textStr)
            local LblFrame = Instance.new("TextLabel")
            LblFrame.Size = UDim2.new(1, 0, 0, 20) 
            LblFrame.BackgroundTransparency = 1
            LblFrame.Text = textStr
            LblFrame.TextColor3 = Color3.fromRGB(150, 160, 150)
            LblFrame.Font = Enum.Font.Gotham
            LblFrame.TextSize = 13 
            LblFrame.TextXAlignment = Enum.TextXAlignment.Center
            LblFrame.Parent = ItemContainer
        end

        -- [ BUTTON ]
        function secData:AddButton(btnName, callback)
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 32)
            BtnFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
            BtnFrame.BackgroundTransparency = 0.9
            BtnFrame.Text = btnName
            BtnFrame.TextColor3 = Color3.fromRGB(0, 255, 170)
            BtnFrame.Font = Enum.Font.GothamBold
            BtnFrame.TextSize = 13 
            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", BtnFrame).Color = Color3.fromRGB(0, 255, 170)
            BtnFrame.UIStroke.Transparency = 0.7
            BtnFrame.Parent = ItemContainer

            BtnFrame.MouseEnter:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play() end)
            BtnFrame.MouseLeave:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play() end)
            
            BtnFrame.MouseButton1Click:Connect(function()
                pcall(callback)
                Notify("Đã Bấm Nút", btnName, 2)
            end)
        end

        -- [ TOGGLE ]
        function secData:AddToggle(toggleName, defaultState, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 32) 
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            ToggleFrame.BackgroundTransparency = 0.6
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
            ToggleFrame.Parent = ItemContainer

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = toggleName
            ToggleLabel.TextColor3 = Color3.fromRGB(230, 240, 230)
            ToggleLabel.Font = Enum.Font.GothamMedium
            ToggleLabel.TextSize = 13 
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame

            local SwitchBtn = Instance.new("TextButton")
            SwitchBtn.Size = UDim2.new(0, 44, 0, 22) 
            SwitchBtn.Position = UDim2.new(1, -44, 0.5, -11)
            SwitchBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(40, 50, 45)
            SwitchBtn.Text = ""
            Instance.new("UICorner", SwitchBtn).CornerRadius = UDim.new(1, 0)
            SwitchBtn.Parent = ToggleFrame

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 18, 0, 18) 
            Circle.Position = defaultState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
            Circle.Parent = SwitchBtn

            local toggled = defaultState
            SwitchBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                local targetPos = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                local targetBg = toggled and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(40, 50, 45)
                TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = targetPos}):Play()
                TweenService:Create(SwitchBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
                
                if toggled then 
                    Notify("Chức năng đã bật", toggleName, 3) 
                else 
                    Notify("Chức năng đã tắt", toggleName, 3) 
                end
                
                pcall(callback, toggled)
            end)
        end

        -- [ SLIDER ]
        function secData:AddSlider(sliderName, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 42)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            SliderFrame.BackgroundTransparency = 0.6
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
            SliderFrame.Parent = ItemContainer

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(1, -50, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 2)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = sliderName
            SliderLabel.TextColor3 = Color3.fromRGB(230, 240, 230)
            SliderLabel.Font = Enum.Font.GothamMedium
            SliderLabel.TextSize = 13 
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 50, 0, 20)
            ValLabel.Position = UDim2.new(1, -50, 0, 2)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(default)
            ValLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 13 
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = SliderFrame

            local BarBg = Instance.new("Frame")
            BarBg.Size = UDim2.new(1, -20, 0, 6)
            BarBg.Position = UDim2.new(0, 10, 0, 26)
            BarBg.BackgroundColor3 = Color3.fromRGB(40, 50, 45)
            Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
            BarBg.Parent = SliderFrame

            local startPercent = (default - min) / (max - min)
            local BarFill = Instance.new("Frame")
            BarFill.Size = UDim2.new(startPercent, 0, 1, 0)
            BarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
            Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
            BarFill.Parent = BarBg

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.Position = UDim2.new(1, -7, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
            Knob.Parent = BarFill

            local SliderButton = Instance.new("TextButton")
            SliderButton.Size = UDim2.new(1, 0, 1, 20)
            SliderButton.Position = UDim2.new(0, 0, 0, -10)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.Parent = BarBg

            local dragging = false
            SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local mousePos = UserInputService:GetMouseLocation().X
                    local barPos = BarBg.AbsolutePosition.X
                    local barSize = BarBg.AbsoluteSize.X
                    local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    local value = math.floor(min + ((max - min) * percent))
                    ValLabel.Text = tostring(value)
                    TweenService:Create(BarFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    pcall(callback, value)
                end
            end)
        end

        -- [ DROPDOWN ]
        function secData:AddDropdown(dropName, options, default, callback)
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 32) 
            DropFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            DropFrame.BackgroundTransparency = 0.6
            DropFrame.ClipsDescendants = true
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)
            DropFrame.Parent = ItemContainer

            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(1, 0, 0, 32) 
            DropBtn.BackgroundTransparency = 1
            DropBtn.Text = ""
            DropBtn.Parent = DropFrame

            local DropLabel = Instance.new("TextLabel")
            DropLabel.Size = UDim2.new(1, -30, 1, 0)
            DropLabel.Position = UDim2.new(0, 10, 0, 0)
            DropLabel.BackgroundTransparency = 1
            DropLabel.Text = dropName .. " : " .. default
            DropLabel.TextColor3 = Color3.fromRGB(230, 240, 230)
            DropLabel.Font = Enum.Font.GothamMedium
            DropLabel.TextSize = 13 
            DropLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropLabel.Parent = DropBtn

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Position = UDim2.new(1, -25, 0.5, -10)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Color3.fromRGB(0, 255, 170)
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 10
            Arrow.Parent = DropBtn

            local OptionContainer = Instance.new("Frame")
            OptionContainer.Size = UDim2.new(1, -16, 0, #options * 24)
            OptionContainer.Position = UDim2.new(0, 8, 0, 36)
            OptionContainer.BackgroundTransparency = 1
            OptionContainer.Parent = DropFrame

            local OptLayout = Instance.new("UIListLayout")
            OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptLayout.Padding = UDim.new(0, 2)
            OptLayout.Parent = OptionContainer

            local isOpen = false
            DropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local targetSize = isOpen and UDim2.new(1, 0, 0, 42 + (#options * 24)) or UDim2.new(1, 0, 0, 32)
                TweenService:Create(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = isOpen and 180 or 0}):Play()
                UpdateCanvas()
            end)

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 22)
                OptBtn.BackgroundColor3 = Color3.fromRGB(15, 25, 20)
                OptBtn.Text = opt
                OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 12 
                Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)
                OptBtn.Parent = OptionContainer

                OptBtn.MouseButton1Click:Connect(function()
                    DropLabel.Text = dropName .. " : " .. opt
                    isOpen = false
                    TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 32)}):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    Notify("Đã Chọn", dropName .. " -> " .. opt, 2)
                    pcall(callback, opt)
                    UpdateCanvas()
                end)
            end
        end

        -- [ KEYBIND ]
        function secData:AddKeybind(bindName, defaultKey, callback)
            local BindFrame = Instance.new("Frame")
            BindFrame.Size = UDim2.new(1, 0, 0, 32)
            BindFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            BindFrame.BackgroundTransparency = 0.6
            Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0, 6)
            BindFrame.Parent = ItemContainer

            local BindLabel = Instance.new("TextLabel")
            BindLabel.Size = UDim2.new(1, -90, 1, 0)
            BindLabel.Position = UDim2.new(0, 10, 0, 0)
            BindLabel.BackgroundTransparency = 1
            BindLabel.Text = bindName
            BindLabel.TextColor3 = Color3.fromRGB(230, 240, 230)
            BindLabel.Font = Enum.Font.GothamMedium
            BindLabel.TextSize = 13 
            BindLabel.TextXAlignment = Enum.TextXAlignment.Left
            BindLabel.Parent = BindFrame

            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 75, 0, 22) 
            BindBtn.Position = UDim2.new(1, -80, 0.5, -11)
            BindBtn.BackgroundColor3 = Color3.fromRGB(15, 30, 20)
            BindBtn.Text = defaultKey.Name
            BindBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
            BindBtn.Font = Enum.Font.GothamBold
            BindBtn.TextSize = 13 
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
            BindBtn.Parent = BindFrame

            local key = defaultKey
            local isBinding = false

            BindBtn.MouseButton1Click:Connect(function()
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                isBinding = true
                Notify("Gán Phím", "Đang chờ phím mới cho: " .. bindName, 2)
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if isBinding and not processed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        BindBtn.Text = key.Name
                        BindBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
                        isBinding = false
                        Notify("Đã Gán Phím", "[" .. key.Name .. "] -> " .. bindName, 3)
                    end
                elseif input.KeyCode == key and not isBinding and not processed then
                    pcall(callback)
                end
            end)
        end

        return secData
    end

    return tabData
end

-- ====================================================================
-- 7. KHỞI TẠO TÍNH NĂNG CHÍNH
-- ====================================================================

local TabSettings = CreateTab("Settings")

local SecMenu = TabSettings:AddSection("Menu Config")
SecMenu:AddKeybind("Toggle UI Key", Enum.KeyCode.RightControl, function() ToggleMenu() end)
SecMenu:AddButton("Panic Button (Close)", function() 
    Notify("Tắt Menu", "Đang đóng giao diện...", 2)
    task.wait(1)
    ScreenGui:Destroy() 
end)

task.wait(1)
Notify("Memaybeo Premium", "Welcome, " .. LocalPlayer.DisplayName .. "!\nMenu loaded successfully.", 4)

