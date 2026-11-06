local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("MMBHubCast") then PlayerGui.MMBHubCast:Destroy() end

-- ===== GAME MODULES =====
local ClientHitboxes
pcall(function()
    ClientHitboxes = require(ReplicatedStorage.Weapons.ClientHitboxes)
end)

-- ===== SETTINGS =====
local Settings = {
    -- Combat
    SilentAim = false,
    FOV = 200,
    TeamCheck = true,
    
    -- Movement & Speed
    SpeedEnabled = false,
    WalkSpeedValue = 32,

    -- Fix Lag & Performance
    FixLagEnabled = false,
    FPSBoost = false,
    
    -- ESP
    ESPEnabled = false,
    ESP_Box = false,
    ESP_Name = false,
    ESP_Distance = false,
    ESP_Health = false,
    ESP_Skeleton = false,
    ESP_Highlight = false,
    ESP_Tracker = false,
    ESP_RedDot = false,
    MaxESPDistance = 500,

    -- UI
    UI_Rainbow = false,
    AccentColor = Color3.fromRGB(255, 140, 0)
}

-- ===== AUTO CONFIG =====
local ConfigFile = "MMBHub_Config.json"

local function SaveConfig()
    if writefile then
        pcall(function()
            local saveData = {}
            for k, v in pairs(Settings) do
                if typeof(v) == "Color3" then saveData[k] = {v.R * 255, v.G * 255, v.B * 255}
                else saveData[k] = v end
            end
            writefile(ConfigFile, HttpService:JSONEncode(saveData))
        end)
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            for k, v in pairs(data) do
                if Settings[k] ~= nil then
                    if k == "AccentColor" and type(v) == "table" then
                        Settings[k] = Color3.fromRGB(v[1], v[2], v[3])
                    else
                        Settings[k] = v
                    end
                end
            end
        end)
    end
end
LoadConfig()

local Theme = {
    Primary = Settings.AccentColor,
    Background = Color3.fromRGB(12, 12, 15),
    TopBar = Color3.fromRGB(18, 18, 24),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(150, 150, 160),
    ElementBg = Color3.fromRGB(30, 30, 35),
    OffColor = Color3.fromRGB(60, 30, 30)
}

local RainbowUI = { Texts = {}, Toggles = {}, Sliders = {} }

-- ===== SPEED LOOP =====
local defaultWalkSpeed = 16
task.spawn(function()
    while true do
        task.wait(0.2)
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Settings.SpeedEnabled then
                humanoid.WalkSpeed = Settings.WalkSpeedValue
            else
                humanoid.WalkSpeed = defaultWalkSpeed
            end
        end
    end
end)

-- ===== FIX LAG LOGIC =====
local function ApplyFixLag(enable)
    if enable then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1

        for _, effect in ipairs(Lighting:GetDescendants()) do
            if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("BlurEffect") then
                effect.Enabled = false
            end
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end
    else
        Lighting.GlobalShadows = true
    end
end

-- ===== BODY PARTS & BONES =====
local bonesR15 = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}}
local bonesR6 = {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}

local ViewportSize = Camera.ViewportSize
local CenterPosition = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)

local Circle = Drawing.new("Circle")
Circle.Thickness = 1; Circle.Position = CenterPosition; Circle.Visible = false; Circle.Filled = false; Circle.NumSides = 64
Circle.Radius = Settings.FOV; Circle.Color = Settings.AccentColor; Circle.Transparency = 1

-- ==========================================
-- ===== SILENT AIM LOGIC ===================
-- ==========================================
local function target()
    if not ClientHitboxes or not ClientHitboxes.folders then return nil end
    
    local cam = Workspace.CurrentCamera
    local center = cam.ViewportSize / 2
    local bestPos, bestDist = nil, Settings.FOV
    
    for char, folder in pairs(ClientHitboxes.folders) do
        local head = folder.Parent and folder:FindFirstChild("Head")
        local hum = typeof(char) == "Instance" and char ~= LocalPlayer.Character and char:FindFirstChildOfClass("Humanoid")
        
        if head and hum and hum.Health > 0 and char:GetAttribute("Downed") ~= true then
            local isTeammate = false
            local plr = Players:GetPlayerFromCharacter(char)
            if Settings.TeamCheck and plr and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                isTeammate = true
            end
            
            if not isTeammate then
                local sp, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist < bestDist then
                        bestPos, bestDist = head.Position, dist
                    end
                end
            end
        end
    end
    return bestPos
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if not checkcaller() and getnamecallmethod() == "ViewportPointToRay" and rawequal(self, workspace.CurrentCamera) then
        local ray = oldNamecall(self, ...)
        if Settings.SilentAim then
            local ok, scr = pcall(getcallingscript)
            if ok and scr and scr.Name == "WeaponClient" then
                local ok2, pos = pcall(target)
                if ok2 and pos then
                    return Ray.new(ray.Origin, (pos - ray.Origin).Unit)
                end
            end
        end
        return ray
    end
    return oldNamecall(self, ...)
end))

-- ==========================================
-- ===== NUCLEAR FPS BOOSTER ================
-- ==========================================
local function ApplyNuclearFPSBoost(enable)
    if enable then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.Outlines = false
        Lighting.ShadowSoftness = 0

        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") or v:IsA("Sky") then
                v.Enabled = false
                pcall(function() v.Parent = nil end)
            end
        end

        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            pcall(function()
                terrain.WaterWaveSize = 0
                terrain.WaterTransparency = 1
                terrain.Decoration = false
            end)
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = false
            end
        end
    else
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.2
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
    end
end

-- ==========================================
-- ===== UI BUILD ===========================
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MMBHubCast"; ScreenGui.Parent = PlayerGui; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true; ScreenGui.DisplayOrder = 999

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui; ToggleBtn.Size = UDim2.new(0, 45, 0, 45); ToggleBtn.Position = UDim2.new(0, 20, 0, 200)
ToggleBtn.Text = "MMB"; ToggleBtn.TextColor3 = Settings.AccentColor; ToggleBtn.BackgroundColor3 = Theme.Background; ToggleBtn.Font = Enum.Font.GothamBold; ToggleBtn.TextSize = 18; ToggleBtn.BorderSizePixel = 0
local TCorner = Instance.new("UICorner"); TCorner.Parent = ToggleBtn; TCorner.CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke"); TStroke.Color = Settings.AccentColor; TStroke.Thickness = 2; TStroke.Parent = ToggleBtn

local Glow = Instance.new("Frame"); Glow.Parent = ScreenGui; Glow.Size = UDim2.new(0, 520, 0, 330); Glow.Position = UDim2.new(0.5, -260, 0.5, -165)
Glow.BackgroundColor3 = Settings.AccentColor; Glow.BackgroundTransparency = 0.85; Glow.BorderSizePixel = 0; Glow.ZIndex = 1; Glow.Visible = false
local GlowCorner = Instance.new("UICorner"); GlowCorner.CornerRadius = UDim.new(0, 16); GlowCorner.Parent = Glow

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui; MainFrame.Size = UDim2.new(0, 500, 0, 310); MainFrame.Position = UDim2.new(0.5, -250, 0.5, -155)
MainFrame.BackgroundColor3 = Theme.Background; MainFrame.BorderSizePixel = 0; MainFrame.Visible = false; MainFrame.Active = true; MainFrame.ZIndex = 2
local MCorner = Instance.new("UICorner"); MCorner.Parent = MainFrame; MCorner.CornerRadius = UDim.new(0, 10)
local MStroke = Instance.new("UIStroke"); MStroke.Color = Color3.fromRGB(45, 45, 55); MStroke.Thickness = 1.5; MStroke.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible; Glow.Visible = MainFrame.Visible end)

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 40); TopBar.BackgroundColor3 = Theme.TopBar; TopBar.BorderSizePixel = 0; TopBar.ZIndex = 10
local TopCorner = Instance.new("UICorner"); TopCorner.Parent = TopBar; TopCorner.CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar; TitleLabel.Size = UDim2.new(0, 150, 1, 0); TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "MMB HUB"; TitleLabel.TextColor3 = Settings.AccentColor; TitleLabel.BackgroundTransparency = 1; TitleLabel.Font = Enum.Font.GothamBlack; TitleLabel.TextSize = 14; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.ZIndex = 11
table.insert(RainbowUI.Texts, TitleLabel)

local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Glow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X - 10, startPos.Y.Scale, startPos.Y.Offset + delta.Y - 10)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local TabContainer = Instance.new("Frame")
TabContainer.Parent = TopBar; TabContainer.Size = UDim2.new(0, 300, 1, 0); TabContainer.Position = UDim2.new(0, 150, 0, 0); TabContainer.BackgroundTransparency = 1; TabContainer.ZIndex = 11
local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabContainer; TabLayout.FillDirection = Enum.FillDirection.Horizontal; TabLayout.SortOrder = Enum.SortOrder.LayoutOrder; TabLayout.Padding = UDim.new(0, 15); TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function CreateTopTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Parent = TabContainer; btn.Size = UDim2.new(0, 50, 1, 0); btn.Text = name; btn.TextColor3 = Theme.SubText; btn.BackgroundTransparency = 1; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.LayoutOrder = order; btn.ZIndex = 12
    return btn
end

local TabCombat = CreateTopTab("Combat", 1)
local TabVisuals = CreateTopTab("Visuals", 2)
local TabSettings = CreateTopTab("Settings", 3)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar; CloseBtn.Size = UDim2.new(0, 40, 1, 0); CloseBtn.Position = UDim2.new(1, -40, 0, 0); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.BackgroundTransparency = 1; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14; CloseBtn.ZIndex = 12
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; Glow.Visible = false end)

local function CreateColumn(parent, xPos)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = parent; scroll.Size = UDim2.new(0.5, -15, 1, -15); scroll.Position = UDim2.new(0, xPos, 0, 10); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 2; scroll.ScrollBarImageColor3 = Settings.AccentColor; scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.ZIndex = 5
    local layout = Instance.new("UIListLayout"); layout.Parent = scroll; layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 8)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10) end)
    return scroll
end

local function CreateSectionLabel(parent, text)
    local lbl = Instance.new("TextLabel"); lbl.Parent = parent; lbl.Size = UDim2.new(1, 0, 0, 20); lbl.Text = text; lbl.TextColor3 = Settings.AccentColor; lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 6
    table.insert(RainbowUI.Texts, lbl)
    return lbl
end

local function CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame"); frame.Parent = parent; frame.Size = UDim2.new(1, 0, 0, 32); frame.BackgroundTransparency = 1; frame.ZIndex = 6
    local label = Instance.new("TextLabel"); label.Parent = frame; label.Size = UDim2.new(0.7, 0, 1, 0); label.Text = text; label.TextColor3 = Theme.Text; label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamSemibold; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 6
    
    local btn = Instance.new("TextButton"); btn.Parent = frame; btn.Size = UDim2.new(0, 45, 0, 22); btn.Position = UDim2.new(1, -45, 0, 5); btn.Text = default and "ON" or "OFF"; btn.BackgroundColor3 = default and Settings.AccentColor or Theme.OffColor; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.BorderSizePixel = 0; btn.ZIndex = 7
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = btn
    
    table.insert(RainbowUI.Toggles, btn)
    local s = default
    btn.MouseButton1Click:Connect(function() 
        s = not s; btn.Text = s and "ON" or "OFF"
        if not Settings.UI_Rainbow then btn.BackgroundColor3 = s and Settings.AccentColor or Theme.OffColor end
        if callback then callback(s) end 
        SaveConfig()
    end)
    return frame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame"); frame.Parent = parent; frame.Size = UDim2.new(1, 0, 0, 42); frame.BackgroundTransparency = 1; frame.ZIndex = 6
    local label = Instance.new("TextLabel"); label.Parent = frame; label.Size = UDim2.new(1, 0, 0, 18); label.Text = text .. ": " .. tostring(default); label.TextColor3 = Theme.Text; label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamSemibold; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 6
    
    local bar = Instance.new("Frame"); bar.Parent = frame; bar.Size = UDim2.new(1, -5, 0, 6); bar.Position = UDim2.new(0, 0, 0, 26); bar.BackgroundColor3 = Theme.ElementBg; bar.BorderSizePixel = 0; bar.ZIndex = 6
    local barCorner = Instance.new("UICorner"); barCorner.CornerRadius = UDim.new(1, 0); barCorner.Parent = bar
    
    local fill = Instance.new("Frame"); fill.Parent = bar; fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Settings.AccentColor; fill.BorderSizePixel = 0; fill.ZIndex = 7
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(1, 0); fillCorner.Parent = fill
    
    table.insert(RainbowUI.Sliders, fill)
    local draggingSlider = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + ((max - min) * pos))
        fill.Size = UDim2.new(pos, 0, 1, 0); label.Text = text .. ": " .. tostring(val)
        if callback then callback(val) end
        SaveConfig()
    end
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = true; update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end end)
    UserInputService.InputChanged:Connect(function(input) if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
    return frame
end

local function CreateActionBtn(parent, text, callback)
    local btn = Instance.new("TextButton"); btn.Parent = parent; btn.Size = UDim2.new(1, 0, 0, 28); btn.Text = text
    btn.BackgroundColor3 = Theme.ElementBg; btn.TextColor3 = Settings.AccentColor; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.BorderSizePixel = 0; btn.ZIndex = 6
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = btn
    btn.MouseButton1Click:Connect(function() if callback then callback(btn) end end)
    return btn
end

local function CreateColorPalette(parent)
    local paletteFrame = Instance.new("Frame"); paletteFrame.Parent = parent; paletteFrame.Size = UDim2.new(1, 0, 0, 80); paletteFrame.BackgroundColor3 = Theme.ElementBg; paletteFrame.BorderSizePixel = 0; paletteFrame.ZIndex = 6
    local pCorner = Instance.new("UICorner"); pCorner.CornerRadius = UDim.new(0, 6); pCorner.Parent = paletteFrame
    local grid = Instance.new("UIGridLayout"); grid.Parent = paletteFrame; grid.CellSize = UDim2.new(0, 24, 0, 24); grid.CellPadding = UDim2.new(0, 6, 0, 6)

    local colors = {Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 140, 0), Color3.fromRGB(255, 220, 0), Color3.fromRGB(50, 255, 50), Color3.fromRGB(0, 150, 255), Color3.fromRGB(150, 0, 255), Color3.fromRGB(255, 50, 150), Color3.fromRGB(255, 255, 255)}

    for _, color in ipairs(colors) do
        local btn = Instance.new("TextButton"); btn.Parent = paletteFrame; btn.BackgroundColor3 = color; btn.BorderSizePixel = 0; btn.Text = ""; btn.ZIndex = 7
        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 4); corner.Parent = btn
        btn.MouseButton1Click:Connect(function() 
            Settings.UI_Rainbow = false; Settings.AccentColor = color
            ToggleBtn.TextColor3 = color; TStroke.Color = color; Glow.BackgroundColor3 = color
            for _, v in pairs(RainbowUI.Texts) do v.TextColor3 = color end
            for _, v in pairs(RainbowUI.Sliders) do v.BackgroundColor3 = color end
            SaveConfig()
        end)
    end
end

-- PAGES
local PageCombat = Instance.new("Frame"); PageCombat.Parent = MainFrame; PageCombat.Size = UDim2.new(1, -20, 1, -50); PageCombat.Position = UDim2.new(0, 10, 0, 45); PageCombat.BackgroundTransparency = 1; PageCombat.Visible = false
local PageVisuals = Instance.new("Frame"); PageVisuals.Parent = MainFrame; PageVisuals.Size = UDim2.new(1, -20, 1, -50); PageVisuals.Position = UDim2.new(0, 10, 0, 45); PageVisuals.BackgroundTransparency = 1; PageVisuals.Visible = false
local PageSettings = Instance.new("Frame"); PageSettings.Parent = MainFrame; PageSettings.Size = UDim2.new(1, -20, 1, -50); PageSettings.Position = UDim2.new(0, 10, 0, 45); PageSettings.BackgroundTransparency = 1; PageSettings.Visible = false

local Pages = { [TabCombat] = PageCombat, [TabVisuals] = PageVisuals, [TabSettings] = PageSettings }
local function SwitchTab(clickedTab)
    for _, page in pairs(Pages) do page.Visible = false end
    for tab, _ in pairs(Pages) do tab.TextColor3 = Theme.SubText end
    if Pages[clickedTab] then Pages[clickedTab].Visible = true; clickedTab.TextColor3 = Settings.AccentColor end
end
for tab, _ in pairs(Pages) do tab.MouseButton1Click:Connect(function() SwitchTab(tab) end) end
SwitchTab(TabCombat)

-- POPULATE COMBAT
local CombatCol1 = CreateColumn(PageCombat, 0)
CreateSectionLabel(CombatCol1, "SILENT AIM")
CreateToggle(CombatCol1, "Enable Silent Aim", Settings.SilentAim, function(v) Settings.SilentAim = v end)
CreateToggle(CombatCol1, "Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
CreateSlider(CombatCol1, "FOV", 50, 500, Settings.FOV, function(v) Settings.FOV = v; Circle.Radius = v end)

-- POPULATE VISUALS
local VisCol1 = CreateColumn(PageVisuals, 0)
local VisCol2 = CreateColumn(PageVisuals, 260)

CreateSectionLabel(VisCol1, "ESP TYPES")
CreateToggle(VisCol1, "Enable ESP", Settings.ESPEnabled, function(v) Settings.ESPEnabled = v end)
CreateToggle(VisCol1, "Box ESP", Settings.ESP_Box, function(v) Settings.ESP_Box = v end)
CreateToggle(VisCol1, "Health Bar", Settings.ESP_Health, function(v) Settings.ESP_Health = v end)
CreateToggle(VisCol1, "Skeleton ESP", Settings.ESP_Skeleton, function(v) Settings.ESP_Skeleton = v end)

CreateSectionLabel(VisCol2, "EXTRAS")
CreateToggle(VisCol2, "Name ESP", Settings.ESP_Name, function(v) Settings.ESP_Name = v end)
CreateToggle(VisCol2, "Distance ESP", Settings.ESP_Distance, function(v) Settings.ESP_Distance = v end)
CreateToggle(VisCol2, "Highlight ESP", Settings.ESP_Highlight, function(v) Settings.ESP_Highlight = v end)
CreateToggle(VisCol2, "Tracker Line", Settings.ESP_Tracker, function(v) Settings.ESP_Tracker = v end)
CreateToggle(VisCol2, "Red Dot", Settings.ESP_RedDot, function(v) Settings.ESP_RedDot = v end)
CreateSlider(VisCol2, "Max ESP Dist", 50, 2000, Settings.MaxESPDistance, function(v) Settings.MaxESPDistance = v end)

CreateSectionLabel(VisCol2, "PERFORMANCE")
CreateToggle(VisCol2, "Fix Lag Tối Đa", Settings.FixLagEnabled, function(v)
    Settings.FixLagEnabled = v
    ApplyFixLag(v)
end)
CreateToggle(VisCol2, "Nuclear FPS Boost", Settings.FPSBoost, function(v) 
    Settings.FPSBoost = v
    ApplyNuclearFPSBoost(v)
end)

-- POPULATE SETTINGS
local SettingsCol1 = CreateColumn(PageSettings, 0)
local SettingsCol2 = CreateColumn(PageSettings, 260)

CreateSectionLabel(SettingsCol1, "UI COLOR")
CreateColorPalette(SettingsCol1)
CreateToggle(SettingsCol1, "Rainbow UI", Settings.UI_Rainbow, function(v) Settings.UI_Rainbow = v end)

CreateSectionLabel(SettingsCol2, "MOVEMENT & SPEED")
CreateToggle(SettingsCol2, "Bật Speed", Settings.SpeedEnabled, function(v)
    Settings.SpeedEnabled = v
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)
CreateSlider(SettingsCol2, "Tốc độ chạy", 16, 150, Settings.WalkSpeedValue, function(v)
    Settings.WalkSpeedValue = v
    if Settings.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
    end
end)

CreateSectionLabel(SettingsCol2, "COMMUNITY")
CreateActionBtn(SettingsCol2, "Unload Hub", function() ScreenGui:Destroy() end)

-- ==========================================
-- ===== OPTIMIZED DRAWING ESP ==============
-- ==========================================
local espCache = {}
local function CreateESP(plr)
    if plr == LocalPlayer or espCache[plr] then return end
    local box = {}
    for i = 1, 4 do local l = Drawing.new("Line"); l.Thickness = 1; l.Visible = false; table.insert(box, l) end
    local skel = {}
    for i = 1, 15 do local l = Drawing.new("Line"); l.Thickness = 2; l.Visible = false; table.insert(skel, l) end
    local hbg = Drawing.new("Line"); hbg.Thickness = 2; hbg.Color = Color3.new(0,0,0); hbg.Visible = false
    local hbar = Drawing.new("Line"); hbar.Thickness = 2; hbar.Color = Color3.fromRGB(0,255,0); hbar.Visible = false
    local trk = Drawing.new("Line"); trk.Thickness = 1.5; trk.Visible = false
    local nm = Drawing.new("Text"); nm.Size = 14; nm.Center = true; nm.Outline = true; nm.Visible = false
    local dst = Drawing.new("Text"); dst.Size = 12; dst.Center = true; dst.Outline = true; dst.Visible = false
    local dot = Drawing.new("Circle"); dot.Radius = 4; dot.Filled = true; dot.Visible = false
    espCache[plr] = {Box = box, Skeleton = skel, HBg = hbg, HBar = hbar, Track = trk, Name = nm, Dist = dst, Dot = dot}
end

local function RemoveESP(plr)
    if espCache[plr] then
        for _, l in pairs(espCache[plr].Box) do l:Remove() end
        for _, l in pairs(espCache[plr].Skeleton) do l:Remove() end
        espCache[plr].HBg:Remove(); espCache[plr].HBar:Remove(); espCache[plr].Track:Remove()
        espCache[plr].Name:Remove(); espCache[plr].Dist:Remove(); espCache[plr].Dot:Remove()
        espCache[plr] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- FOV Circle Render
RunService.RenderStepped:Connect(function()
    if Circle then
        Circle.Position = Workspace.CurrentCamera.ViewportSize / 2
        Circle.Visible = Settings.SilentAim
    end
end)

-- ESP Render Loop
task.spawn(function()
    while task.wait(0.03) do 
        if not Settings.ESPEnabled then
            for plr, cache in pairs(espCache) do
                for _, l in pairs(cache.Box) do l.Visible = false end
                for _, l in pairs(cache.Skeleton) do l.Visible = false end
                cache.HBg.Visible = false; cache.HBar.Visible = false; cache.Track.Visible = false
                cache.Name.Visible = false; cache.Dist.Visible = false; cache.Dot.Visible = false
                if plr.Character and plr.Character:FindFirstChild("VodkaHighlight") then plr.Character.VodkaHighlight:Destroy() end
            end
            continue
        end

        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for plr, cache in pairs(espCache) do
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
            local head = char and char:FindFirstChild("Head")
            
            local skip = false
            
            if not char or not hum or hum.Health <= 0 or not hrp or not head then skip = true end
            if not skip then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                if dist > Settings.MaxESPDistance then skip = true end
            end

            if skip then
                for _, l in pairs(cache.Box) do l.Visible = false end
                for _, l in pairs(cache.Skeleton) do l.Visible = false end
                cache.HBg.Visible = false; cache.HBar.Visible = false; cache.Track.Visible = false
                cache.Name.Visible = false; cache.Dist.Visible = false; cache.Dot.Visible = false
                if char and char:FindFirstChild("VodkaHighlight") then char.VodkaHighlight:Destroy() end
                continue
            end

            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            local hPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local fPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            
            local espColor = Settings.AccentColor

            if onScreen then
                local height = math.abs(hPos.Y - fPos.Y)
                local width = height / 2

                if Settings.ESP_Box then
                    local tl = Vector2.new(hPos.X - width/2, hPos.Y)
                    local tr = Vector2.new(hPos.X + width/2, hPos.Y)
                    local bl = Vector2.new(hPos.X - width/2, fPos.Y)
                    local br = Vector2.new(hPos.X + width/2, fPos.Y)
                    cache.Box[1].From = tl; cache.Box[1].To = tr; cache.Box[1].Visible = true; cache.Box[1].Color = espColor
                    cache.Box[2].From = tr; cache.Box[2].To = br; cache.Box[2].Visible = true; cache.Box[2].Color = espColor
                    cache.Box[3].From = br; cache.Box[3].To = bl; cache.Box[3].Visible = true; cache.Box[3].Color = espColor
                    cache.Box[4].From = bl; cache.Box[4].To = tl; cache.Box[4].Visible = true; cache.Box[4].Color = espColor
                else for _, l in pairs(cache.Box) do l.Visible = false end end

                if Settings.ESP_Skeleton then
                    local useBones = (char:FindFirstChild("Torso") and not char:FindFirstChild("UpperTorso")) and bonesR6 or bonesR15
                    for i, bone in pairs(useBones) do
                        local p1 = char:FindFirstChild(bone[1])
                        local p2 = char:FindFirstChild(bone[2])
                        if p1 and p2 and cache.Skeleton[i] then
                            local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
                            local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                            if o1 and o2 then
                                cache.Skeleton[i].From = Vector2.new(s1.X, s1.Y); cache.Skeleton[i].To = Vector2.new(s2.X, s2.Y)
                                cache.Skeleton[i].Color = espColor; cache.Skeleton[i].Visible = true
                            else cache.Skeleton[i].Visible = false end
                        elseif cache.Skeleton[i] then cache.Skeleton[i].Visible = false end
                    end
                    for i = #useBones + 1, #cache.Skeleton do
                        if cache.Skeleton[i] then cache.Skeleton[i].Visible = false end
                    end
                else for _, l in pairs(cache.Skeleton) do l.Visible = false end end

                if Settings.ESP_Health then
                    local pct = hum.Health / hum.MaxHealth
                    local bx = hPos.X - (width/2) - 5
                    cache.HBg.From = Vector2.new(bx, hPos.Y); cache.HBg.To = Vector2.new(bx, fPos.Y); cache.HBg.Visible = true
                    cache.HBar.From = Vector2.new(bx, fPos.Y - (height * pct)); cache.HBar.To = Vector2.new(bx, fPos.Y); cache.HBar.Visible = true
                    cache.HBar.Color = Color3.fromRGB(255 * (1-pct), 255 * pct, 0)
                else cache.HBg.Visible = false; cache.HBar.Visible = false end

                if Settings.ESP_Name then
                    cache.Name.Text = plr.Name; cache.Name.Position = Vector2.new(hPos.X, hPos.Y - 20); cache.Name.Visible = true; cache.Name.Color = Color3.new(1,1,1)
                else cache.Name.Visible = false end

                if Settings.ESP_Distance then
                    cache.Dist.Text = math.floor(dist) .. "m"; cache.Dist.Position = Vector2.new(hPos.X, fPos.Y + 10); cache.Dist.Visible = true; cache.Dist.Color = espColor
                else cache.Dist.Visible = false end

                if Settings.ESP_Tracker then
                    cache.Track.From = center; cache.Track.To = Vector2.new(hPos.X, hPos.Y); cache.Track.Visible = true; cache.Track.Color = espColor
                else cache.Track.Visible = false end

                if Settings.ESP_RedDot then
                    cache.Dot.Position = Vector2.new(hPos.X, hPos.Y); cache.Dot.Visible = true; cache.Dot.Color = Color3.fromRGB(255, 0, 0)
                else cache.Dot.Visible = false end
            else
                for _, l in pairs(cache.Box) do l.Visible = false end
                for _, l in pairs(cache.Skeleton) do l.Visible = false end
                cache.HBg.Visible = false; cache.HBar.Visible = false; cache.Track.Visible = false
                cache.Name.Visible = false; cache.Dist.Visible = false; cache.Dot.Visible = false
            end

            if Settings.ESP_Highlight then
                local hl = char:FindFirstChild("VodkaHighlight")
                if not hl then
                    hl = Instance.new("Highlight"); hl.Name = "VodkaHighlight"; hl.Parent = char
                    hl.FillTransparency = 0.5; hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                hl.FillColor = espColor; hl.OutlineColor = espColor
            else
                local hl = char:FindFirstChild("VodkaHighlight")
                if hl then hl:Destroy() end
            end
        end
    end
end)

-- Rainbow UI Loop
task.spawn(function()
    while task.wait(0.1) do
        if Settings.UI_Rainbow then
            local hue = tick() % 5 / 5
            local color = Color3.fromHSV(hue, 1, 1)
            Settings.AccentColor = color
            
            ToggleBtn.TextColor3 = color
            TStroke.Color = color
            Glow.BackgroundColor3 = color
            
            for _, v in pairs(RainbowUI.Texts) do v.TextColor3 = color end
            for _, v in pairs(RainbowUI.Sliders) do v.BackgroundColor3 = color end
            for _, v in pairs(RainbowUI.Toggles) do if v.Text == "ON" then v.BackgroundColor3 = color end end
            if Circle then Circle.Color = color end
        end
    end
end)

-- ================================================
--  RAYFIELD UI
-- ================================================
local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

local Window = Rayfield:CreateWindow({
    Name                = "MMB HUB",
    LoadingTitle        = "MMB HUB",
    LoadingSubtitle     = "by null",
    ConfigurationSaving = { Enabled = false },
    KeySystem           = false,
})

-- ── AIMBOT TAB ──────────────────────────────────
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

AimbotTab:CreateToggle({
    Name         = "Aimbot",
    CurrentValue = Settings.AimbotEnabled or true,
    Flag         = "AimbotEnabled",
    Callback     = function(v) Settings.AimbotEnabled = v end,
})

AimbotTab:CreateSlider({
    Name         = "Smoothing",
    Range        = {0, 1},
    Increment    = 0.01,
    CurrentValue = 0.15,
    Flag         = "AimbotSmoothing",
    Callback     = function(v) Settings.AimbotSmoothing = v end,
})

AimbotTab:CreateSlider({
    Name         = "FOV Radius",
    Range        = {50, 800},
    Increment    = 10,
    CurrentValue = 200,
    Flag         = "AimbotFOV",
    Callback     = function(v)
        Settings.AimbotFOV = v
        if FOVCircle then FOVCircle.Radius = v end
    end,
})

AimbotTab:CreateDropdown({
    Name          = "Bone Target",
    Options       = {"Head", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Flag          = "AimbotBone",
    Callback      = function(v) Settings.AimbotBone = v[1] end,
})

-- ── ESP TAB ─────────────────────────────────────
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name         = "ESP",
    CurrentValue = true,
    Flag         = "ESPEnabledRayfield",
    Callback     = function(v) Settings.ESPEnabled = v end,
})

ESPTab:CreateToggle({
    Name         = "Tracers",
    CurrentValue = true,
    Flag         = "ESPTracers",
    Callback     = function(v) Settings.ESP_Tracker = v end,
})

ESPTab:CreateToggle({
    Name         = "Distance",
    CurrentValue = true,
    Flag         = "ESPDistanceRayfield",
    Callback     = function(v) Settings.ESP_Distance = v end,
})

ESPTab:CreateSlider({
    Name         = "Max Distance",
    Range        = {100, 5000},
    Increment    = 100,
    CurrentValue = 2000,
    Flag         = "ESPMaxDist",
    Callback     = function(v) Settings.MaxESPDistance = v end,
})

-- ── MISC TAB ────────────────────────────────────
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateToggle({
    Name         = "Bật Speed",
    CurrentValue = Settings.SpeedEnabled,
    Flag         = "SpeedToggle",
    Callback     = function(v)
        Settings.SpeedEnabled = v
        if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end,
})

MiscTab:CreateSlider({
    Name         = "Tốc độ chạy",
    Range        = {16, 150},
    Increment    = 1,
    CurrentValue = Settings.WalkSpeedValue,
    Flag         = "WalkSpeedSlider",
    Callback     = function(v)
        Settings.WalkSpeedValue = v
        if Settings.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end,
})

MiscTab:CreateToggle({
    Name         = "Giảm Lag (Fix Lag)",
    CurrentValue = Settings.FixLagEnabled,
    Flag         = "FixLagToggle",
    Callback     = function(v)
        Settings.FixLagEnabled = v
        ApplyFixLag(v)
    end,
})

Rayfield:Notify({
    Title    = "MMB HUB loaded",
    Content  = "Insert key: Right Shift",
    Duration = 4,
})
