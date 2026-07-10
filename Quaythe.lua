local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remotes")

-- Cấu hình giao diện
WindUI:AddTheme({
    Name = "ZyroTheme",
    Font = Font.fromName("GothamSSm", Enum.FontWeight.Medium),
    Background = WindUI:Gradient({ ["0"] = { Color = Color3.fromHex("#1a1a1a") }, ["100"] = { Color = Color3.fromHex("#1a1a1a") } }, { Rotation = 180 }),
    Accent = WindUI:Gradient({ ["0"] = { Color = Color3.fromHex("#2563eb") }, ["100"] = { Color = Color3.fromHex("#1d4ed8") } }, { Rotation = 90 })
})

local Window = WindUI:CreateWindow({
    Title = "MEMAYBEO HUB | ULTRA SMART v31",
    Icon = "shield-check",
    Size = UDim2.fromOffset(580, 450),
    Theme = "ZyroTheme",
    Resizable = true
})

-- Hàm click chuẩn
local function forceClick(button)
    if not button then return end
    pcall(function()
        button:Activate()
        if firesignal then
            firesignal(button.MouseButton1Click)
            firesignal(button.Activated)
        end
    end)
end

-- Hàm lấy vé Gacha
local function GetWishTicketCount()
    local success, count = pcall(function()
        local gachaMain = PlayerGui:FindFirstChild("Gacha") and PlayerGui.Gacha:FindFirstChild("Main")
        if gachaMain then
            local ticketFrame = gachaMain:FindFirstChild("TicketAmountFrame")
            local amountLabel = ticketFrame and ticketFrame:FindFirstChild("Amount")
            if amountLabel and amountLabel:IsA("TextLabel") then
                return tonumber(amountLabel.Text) or 0
            end
        end
        return 0
    end)
    return success and count or 0
end

local Tab = Window:Tab({ Title = "Tính năng chính", Icon = "zap" })

_G.AutoCollect = false
_G.AutoTournament = false
_G.AutoIdle = false
_G.AutoSeashells = false
_G.AutoSpin = false
_G.AutoGacha = false

Tab:Toggle({ Title = "Auto Thu Tiền (Tất cả Plots)", Callback = function(s) _G.AutoCollect = s end })
Tab:Toggle({ Title = "Auto Giải Đấu (v31 Treo Ngầm Không Mở UI)", Callback = function(s) _G.AutoTournament = s end })
Tab:Toggle({ Title = "Auto Hoạt Động Rảnh (Idle)", Callback = function(s) _G.AutoIdle = s end })
Tab:Toggle({ Title = "Auto Nhặt Sò", Callback = function(s) _G.AutoSeashells = s end })
Tab:Toggle({ Title = "Auto Vòng Quay (Chạy Ngầm Không Mở UI)", Callback = function(s) _G.AutoSpin = s end })
Tab:Toggle({ Title = "Auto Gacha", Callback = function(s) _G.AutoGacha = s end })

-- 1. Auto Thu Tiền (Tự động quét toàn bộ các Plot)
task.spawn(function()
    while task.wait(1) do
        if _G.AutoCollect then
            pcall(function()
                for _, plot in ipairs(workspace.Plots:GetChildren()) do
                    local slots = plot:FindFirstChild("Slots")
                    if slots then
                        for _, s in ipairs(slots:GetChildren()) do
                            if s:FindFirstChild("Cash") then 
                                RemoteFolder.CollectSlot:FireServer(s.Name) 
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Auto Giải Đấu (Bản v31: Đọc text ngầm trong hệ thống, UI đóng vẫn hoạt động chuẩn)
local equippedThisRound = false

task.spawn(function()
    while task.wait(2) do
        if _G.AutoTournament then
            pcall(function()
                local tournamentUI = PlayerGui:FindFirstChild("Tournament")
                local isWaiting = false
                
                -- Đọc ngầm dữ liệu text lưu trữ bên trong hệ thống bất chấp UI ẩn/hiện
                if tournamentUI then
                    -- Quét sâu vào toàn bộ hệ thống lưu chữ của bảng đấu để tìm thông tin thời gian thực
                    for _, obj in ipairs(tournamentUI:GetDescendants()) do
                        if obj:IsA("TextLabel") and obj.Text and obj.Text ~= "" then
                            local text = string.lower(obj.Text)
                            
                            -- Bộ lọc chặn: Nếu hệ thống đang chạy đếm ngược (dạng XX:XX) hoặc ghi chữ đóng/chờ bắt đầu
                            if string.match(text, "%d+:%d+") or string.find(text, "bắt đầu") or string.find(text, "đóng") or string.find(text, "hàng đợi bị") then
                                isWaiting = true
                                break
                            end
                        end
                    end
                end
                
                -- ĐIỀU KIỆN KHÓA SPAM: Nếu game đang ở trạng thái chờ/đếm ngược -> Dừng ngay lập tức, không gửi Remote
                if isWaiting then
                    equippedThisRound = false -- Reset để sẵn sàng mặc đồ cho vòng sau
                    return
                end
                
                -- NẾU HỆ THỐNG BÁO GIẢI ĐẤU ĐÃ MỞ (Hết đếm ngược hoàn toàn):
                if RemoteFolder:FindFirstChild("Tournament") then
                    -- Tự động trang bị đội hình mạnh nhất (chỉ gửi duy nhất 1 lần tránh spam)
                    if not equippedThisRound then
                        RemoteFolder.Tournament:FireServer("equip_best")
                        equippedThisRound = true
                        task.wait(0.5)
                    end
                    
                    -- Gửi Remote tham gia giải đấu ngầm trực tiếp lên Server game
                    RemoteFolder.Tournament:FireServer("join")
                    RemoteFolder.Tournament:FireServer("join_tournament")
                end
                
                task.wait(6) -- Giãn cách nghỉ hẳn 6 giây để Server phản hồi nhận hàng đợi, tuyệt đối không bị spam chat
            end)
        end
    end
end)

-- 3. Auto Idle
task.spawn(function()
    while task.wait(2) do
        if _G.AutoIdle then
            pcall(function()
                if RemoteFolder:FindFirstChild("IdleActivity") then
                    RemoteFolder.IdleActivity:FireServer()
                end
            end)
        end
    end
end)

-- 4. Auto Nhặt Sò
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoSeashells then
            pcall(function()
                for _, v in ipairs(workspace.LocalSeashells:GetChildren()) do
                    local p = v:FindFirstChildWhichIsA("ProximityPrompt")
                    if p then fireproximityprompt(p) end
                end
            end)
        end
    end
end)

-- 5. Auto Vòng Quay (CHẠY NGẦM HOÀN TOÀN)
task.spawn(function()
    while task.wait(1.5) do
        if _G.AutoSpin then
            pcall(function()
                if RemoteFolder:FindFirstChild("SpinWheel") then
                    RemoteFolder.SpinWheel:FireServer("spin")
                    
                    for _, cmd in ipairs({"claim_free", "claim", "free_spin", "spin_free"}) do
                        RemoteFolder.SpinWheel:FireServer(cmd)
                    end
                    
                    local spinUI = PlayerGui:FindFirstChild("SpinWheel")
                    local spinMain = spinUI and spinUI:FindFirstChild("Main") and spinUI.Main:FindFirstChild("Spin")
                    if spinMain then
                        local claimButton = spinMain:FindFirstChild("Claim") or spinMain:FindFirstChild("NextFreeSpin")
                        if claimButton and claimButton:IsA("GuiButton") and claimButton.Visible then
                            forceClick(claimButton)
                        end
                        local spinButton = spinMain:FindFirstChild("Spin")
                        if spinButton and spinButton:IsA("GuiButton") and spinButton.Visible then
                            forceClick(spinButton)
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. Auto Gacha
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoGacha then
            local ticketCount = GetWishTicketCount()
            if ticketCount > 0 then
                if RemoteFolder:FindFirstChild("PerformWish") then
                    local success, res = pcall(function() return RemoteFolder.PerformWish:InvokeServer() end)
                    if success and res and res.ok then task.wait(2.5) end
                end
            else
                _G.AutoGacha = false
                WindUI:Notify({ Title = "Gacha", Content = "Hết vé!", Duration = 5 })
            end
        end
    end
end)

WindUI:Notify({ Title = "MEMAYBEO HUB", Content = "Kích hoạt v31 Treo Giải Đấu Ngầm 100% không cần mở UI thành công!", Duration = 4 })
