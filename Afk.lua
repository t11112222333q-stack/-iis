-- ============================================================================
-- 🛡️ ANTI-AFK HUB WITH UI (FLUENT LIBRARY)
-- ============================================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UIS = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- KHỞI TẠO MENU FLUENT UI
local Window = Fluent:CreateWindow({
    Title = "MEMAYBEO HUB",
    SubTitle = "Anti-AFK System",
    TabWidth = 130,
    Size = UDim2.fromOffset(450, 320),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.End
})

local Tabs = {
    Main = Window:AddTab({ Title = "Chống AFK", Icon = "rbxassetid://4483345998" })
}

-- NÚT ẨN/HIỆN MENU DÀNH CHO MOBILE (KÉO THẢ TỰ DO)
if playerGui:FindFirstChild("AntiAFK_MobileToggle") then
    playerGui.AntiAFK_MobileToggle:Destroy()
end

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AntiAFK_MobileToggle"
screenGui.ResetOnSpawn = false

local toggleBtn = Instance.new("ImageButton", screenGui)
toggleBtn.Size = UDim2.fromOffset(50, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleBtn.Image = "rbxassetid://4483345998"
toggleBtn.Active = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Color = Color3.fromRGB(0, 255, 150)
btnStroke.Thickness = 2

-- Xử lý Kéo Thả nút Toggle trên Mobile
local dragging, dragInput, dragStart, startPos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = toggleBtn.Position
        input.Changed:Connect(function() 
            if input.UserInputState == Enum.UserInputState.End then dragging = false end 
        end)
    end
end)
toggleBtn.InputChanged:Connect(function(input) 
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
        dragInput = input 
    end 
end)
UIS.InputChanged:Connect(function(input) 
    if input == dragInput and dragging then 
        local delta = input.Position - dragStart 
        toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) 
    end 
end)

local menuVisible = true
toggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    if Window.Minimize then Window:Minimize(not menuVisible) end
end)

-- ============================================================================
-- ⚙️ LOGIC ANTI-AFK & UI INTERFACE
-- ============================================================================
local SectionAFK = Tabs.Main:AddSection("Cấu Hình Anti-AFK")

_G.AntiAFKState = true
local secondsAFK = 0

-- Nút Bật/Tắt Anti-AFK
local ToggleAFK = SectionAFK:AddToggle("AntiAFKToggle", {
    Title = "Kích Hoạt Anti-AFK (Chống Văng Game)",
    Default = true,
    Callback = function(state)
        _G.AntiAFKState = state
        if state then
            Fluent:Notify({ Title = "Anti-AFK", Content = "Đã BẬT chức năng Anti-AFK!", Duration = 3 })
        else
            Fluent:Notify({ Title = "Anti-AFK", Content = "Đã TẮT chức năng Anti-AFK!", Duration = 3 })
        end
    end
})

-- Hiển thị thời gian đã treo máy
local AFKParagraph = SectionAFK:AddParagraph({
    Title = "⏱️ Thời Gian Treo Máy:",
    Content = "0 giờ 0 phút 0 giây"
})

-- Đếm thời gian treo máy Realtime
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AntiAFKState then
            secondsAFK = secondsAFK + 1
            local hrs = math.floor(secondsAFK / 3600)
            local mins = math.floor((secondsAFK % 3600) / 60)
            local secs = secondsAFK % 60
            AFKParagraph:SetDesc(string.format("%d giờ %d phút %d giây", hrs, mins, secs))
        end
    end
end)

-- Bắt sự kiện Idled của Roblox (xảy ra khi không chạm phím quá lâu)
localPlayer.Idled:Connect(function()
    if _G.AntiAFKState then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        warn("[MEMAYBEO HUB] Anti-AFK đã kích hoạt để giữ kết nối!")
        Fluent:Notify({ 
            Title = "🛡️ Anti-AFK Protection", 
            Content = "Đã giả lập thao tác để tránh bị kick khỏi Server!", 
            Duration = 5 
        })
    end
end)

-- Chọn Mặc Định Tab 1
Tabs.Main:Select()

Fluent:Notify({ Title = "MEMAYBEO HUB", Content = "Giao diện Anti-AFK đã sẵn sàng!", Duration = 4 })

