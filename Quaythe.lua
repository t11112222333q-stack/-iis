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
    Title = "MEMAYBEO HUB | v32",
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
Tab:Toggle({ Title = "Auto Giải Đấu (v32 Sửa Lỗi Chạy Ngầm)", Callback = function(s) _G.AutoTournament = s end })
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

-- 2. Auto Giải Đấu (Bản v32: Tập trung quét text trực tiếp của nút bấm để ra quyết định chính xác)
local equippedThisRound = false

task.spawn(function()
    while task.wait(2) do
        if _G.AutoTournament then
            pcall(function()
                local tournamentUI = PlayerGui:FindFirstChild("Tournament")
                local isWaiting = false
                
                -- Định vị chính xác khu vực nút Join để đọc text trạng thái hàng đợi ngầm
                if tournamentUI then
                    local mainFrame = tournamentUI:FindFirstChild("Frame") and tournamentUI.Frame:FindFirstChild("Main")
                    if mainFrame then
                        local joinBtn = mainFrame:FindFirstChild("JoinButton", true) or mainFrame:FindFirstChild("Join", true)
                        if joinBtn then
                            -- Quét tất cả chữ nằm bên dưới nút Join này để xem có thông báo khóa không
                            for _, label in ipairs(joinBtn:GetDescendants()) do
                                if label:IsA("TextLabel") and label.Text and label.Text ~= "" then
                                    local btnText = string.lower(label.Text)
                                    -- Chỉ chặn khi chữ hiển thị đích danh là đang khóa hàng đợi
                                    if string.find(btnText, "hàng đợi") or string.find(btnText, "bị đóng") or string.find(btnText, "close") then
                                        isWaiting = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Khóa chặn gửi Remote nếu hệ thống xác nhận nút Join đang ở trạng thái bị đóng
                if isWaiting then
                    equippedThisRound = false
                    return
                end
                
                -- NẾU NÚT JOIN KHÔNG BỊ KHÓA (Giải đấu đang mở cửa, cho phép trả phí hoặc tham gia tự do):
                if RemoteFolder:FindFirstChild("Tournament") then
                    if not equippedThisRound then
                        RemoteFolder.Tournament:FireServer("equip_best")
                        equippedThisRound = true
                        task.wait(0.4)
                    end
                    
                    -- Thực hiện gửi yêu cầu tham gia ngầm lên server game
                    RemoteFolder.Tournament:FireServer("join")
                    RemoteFolder.Tournament:FireServer("join_tournament")
                end
                
                task.wait(5) -- Nghỉ 5 giây chờ hệ thống xử lý hàng đợi
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

WindUI:Notify({ Title = "MEMAYBEO HUB", Content = "Đã cập nhật bản v32 sửa lỗi treo ngầm chính xác!", Duration = 4 })
