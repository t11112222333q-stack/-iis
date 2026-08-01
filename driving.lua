-- ====================================================================
-- MEMAYBEO HUB v12.0 (MAIN SCRIPT + INDESTRUCTIBLE LOGO FIX)
-- ====================================================================

local t1 = {}
local v2 = unpack or table.unpack
function up61()
    local ok, result = pcall(gethwid)
    if ok then ok = result and result ~= "" end
    if ok then return result end
    return tostring(game:GetService("RbxAnalyticsService"):GetClientId()):gsub("-", "")
end

local function v3()
    for _, v in ipairs({
		function() return request end,
		function() return http_request end,
		function() local _http = http if _http then _http = http.request end return _http end,
		function() local _syn = syn if _syn then _syn = syn.request end return _syn end,
		function() local _fluxus = fluxus if _fluxus then _fluxus = fluxus.request end return _fluxus end,
		function() return (getgenv or function() return {} end)().request end
	}) do
        local ok, result = pcall(v)
        if ok then ok = type(result) == "function" end
        if ok then return result end
    end
    return nil
end

local HttpService = game:GetService("HttpService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- BYPASS
local t3 = { [1] = false }
t1[1] = function()
    local v75 = identifyexecutor()
    if v75 then v75 = string.lower(v75):find("velocity") ~= nil end
    t3[1] = v75
end
pcall(t1[1])
if t3[1] then
    function makefolder() end
    function isfolder() return false end
    function writefile() end
    function readfile() return "" end
    function isfile() return false end
end

task.spawn(function()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local u482 = ReplicatedStorage
        pcall(function()
            local Logger = require(u482:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Logger"))
            if Logger then
                for k, v in pairs(Logger) do
                    local v618 = k
                    if type(v) == "function" and v618 ~= "setLevel" then Logger[v618] = function() end end
                end
            end
        end)
        pcall(function()
            local FrameworkLogging = u482:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Framework"):FindFirstChild("FrameworkLogging")
            if FrameworkLogging then
                local lib = require(FrameworkLogging)
                if lib then
                    for k, v in pairs(lib) do if type(v) == "function" then lib[k] = function() end end end
                end
            end
        end)
        pcall(function()
            local HTTPServiceWrapper = u482:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Wrappers"):FindFirstChild("HTTPServiceWrapper")
            if HTTPServiceWrapper then
                local lib = require(HTTPServiceWrapper)
                if lib then
                    function lib.generateReport() return "" end
                    function lib.getRecords() return {} end
                end
            end
        end)
        pcall(function()
            local Modules = u482:FindFirstChild("Modules")
            if Modules then Modules = u482.Modules:FindFirstChild("Shared") end
            if Modules then Modules = Modules:FindFirstChild("ServerLog") end
            if Modules then
                local Client = Modules:FindFirstChild("Client")
                if Client then
                    local ok, result = pcall(require, Client)
                    if ok and result then
                        function result._Init() end
                        function result.Log() end
                    end
                end
            end
        end)
        local u483
        local t4 = { LogEvent = true, ClientLog = true, ServerLog = true, ClientFrameworkBootOutputLogs = true }
        function u483(p1)
            local u632 = p1
            pcall(function()
                if getconnections then
                    for _, v in ipairs(getconnections(u632.OnClientEvent)) do
                        local v657 = v
                        pcall(function() v657:Disable() end)
                    end
                end
            end)
        end
        pcall(function()
            for _, child in ipairs(u482:GetChildren()) do if t4[child.Name] then u483(child) end end
            u482.ChildAdded:Connect(function(child) if t4[child.Name] then task.wait(0.05) u483(child) end end)
        end)
        if getgenv().hookmetamethod then
            local u485
            u485 = hookmetamethod(game, "__namecall", function(p2, ...)
                local v634 = getnamecallmethod()
                local v635 = t4[p2.Name]
                if v635 then v635 = v634 == "FireServer" or v634 == "InvokeServer" end
                if v635 then return end
                return u485(p2, ...)
            end)
        end
    end)
end)

t3[2] = {
    Notify = function(self, args)
        pcall(function()
            game.StarterGui:SetCore("SendNotification", { Title = args.Title or "MEMAYBEO HUB", Text = args.Content or "", Duration = args.Duration or 5 })
        end)
    end
}

-- ====================================================================
-- LOAD GIAO DIỆN UICHILL TỪ GITHUB
-- ====================================================================
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/t11112222333q-stack/-iis/refs/heads/main/Uichill.lua"))()

-- ====================================================================
-- INDESTRUCTIBLE LOGO TOGGLE (FIXED DECAL BLACK SCREEN)
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LogoName = "AbsoluteUnkillableLogo"

-- Hàm tạo và bảo vệ Logo
local function CreateIndestructibleLogo()
    -- Xóa logo cũ nếu có
    if CoreGui:FindFirstChild(LogoName) then
        CoreGui[LogoName]:Destroy()
    end

    -- Tạo ScreenGui Độc Lập
    local LogoScreen = Instance.new("ScreenGui")
    LogoScreen.Name = LogoName
    LogoScreen.ResetOnSpawn = false
    LogoScreen.ZIndexBehavior = Enum.ZIndexBehavior.Global
    LogoScreen.DisplayOrder = 2147483647 -- Max ZIndex tuyệt đối để không bị che
    LogoScreen.Parent = CoreGui

    -- Khung hiển thị
    local LogoButton = Instance.new("ImageButton")
    LogoButton.Size = UDim2.new(0, 50, 0, 50)
    LogoButton.Position = UDim2.new(0.5, -25, 0, 20)
    LogoButton.BackgroundColor3 = Color3.fromRGB(15, 20, 18)
    
    -- ÉP LOAD ẢNH BẰNG RBXTHUMB ĐỂ VƯỢT LỖI DECAL ID ĐEN THUI
    LogoButton.Image = "rbxthumb://type=Asset&id=89771967787205&w=150&h=150" 
    
    LogoButton.ZIndex = 2147483647
    LogoButton.Parent = LogoScreen

    -- Chỉnh trang cho đẹp
    Instance.new("UICorner", LogoButton).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", LogoButton)
    stroke.Color = Color3.fromRGB(0, 255, 170)
    stroke.Thickness = 2.5

    -- Logic Kéo thả
    local isDragging = false
    local dragStartPos = nil
    local startPos = nil
    local menuVisible = true

    LogoButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPos = input.Position
            startPos = LogoButton.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPos
            LogoButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Logic Tắt Mở Main Menu (của Uichill)
    LogoButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            if dragStartPos and (input.Position - dragStartPos).Magnitude < 10 then
                -- Tìm Main Menu (MemaybeoPremiumUI)
                local targetUI = CoreGui:FindFirstChild("MemaybeoPremiumUI")
                if targetUI then
                    local wrapper = targetUI:FindFirstChild("Wrapper") 
                    if wrapper then
                        menuVisible = not menuVisible
                        local targetSize = menuVisible and UDim2.new(0, 650, 0, 420) or UDim2.new(0, 0, 0, 0)
                        TweenService:Create(wrapper, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize}):Play()
                    end
                end
            end
        end
    end)
    
    return LogoScreen
end

-- Khởi tạo Logo
local MyLogo = CreateIndestructibleLogo()

-- Vòng lặp bảo vệ (Tự động khôi phục nếu bị xóa)
task.spawn(function()
    while task.wait(1) do
        if not CoreGui:FindFirstChild(LogoName) then
            MyLogo = CreateIndestructibleLogo()
        end
    end
end)

-- ====================================================================
-- KHỞI TẠO MENU CHỨC NĂNG (DÁN VÀO UICHILL)
-- ====================================================================
local TabFarm = UI.CreateTab("Tự Động Cày")
local TabMisc = UI.CreateTab("Chức Năng Khác")

-- AUTO FARM CORE LOGIC
t1[2] = {} 
t1[8] = function() end
t1[7] = { Enabled = true, Anonymous = false, Callback = t1[8] }
t3[3] = t1[2]
t3[4] = game:GetService("Players")
t3[5] = game:GetService("ReplicatedStorage")
t1[5] = game:GetService("RunService")
t3[6] = game:GetService("TweenService")
t3[7] = "Outlaw"
t3[8] = "Security"
t3[9] = "Delivery Driver"
t1[4] = ipairs
local _game = game
for _, v14 in t1[4](_game:GetService("Teams"):GetTeams()) do
    if v14.Name:find("Security") then t3[8] = v14.Name break end
end
local Modules = t3[5]:WaitForChild("Modules")
t1[9] = function()
    local t5 = {}
    pcall(function()
        local Loot = workspace.Game.Heists.BankHeist.HeistAsset:FindFirstChild("Loot")
        if not Loot then return end
        for _, v in ipairs(Loot:GetChildren()) do
            local v490 = v.Name == "Diamond" or v.Name == "Cash" or v.Name == "Money"
            if v490 then
                local Primary = v:FindFirstChild("Primary")
                if Primary then
                    local ProximityPrompt = Primary:FindFirstChild("ProximityPrompt")
                    if ProximityPrompt and ProximityPrompt.Enabled and Primary.Position.Y >= 15 then
                        table.insert(t5, { part = Primary, prompt = ProximityPrompt, model = v, isDiamond = (v.Name == "Diamond") })
                    end
                end
            end
        end
    end)
    table.sort(t5, function(p3, p4)
        local v499 = math.floor(p3.part.Position.Y / 10)
        local v500 = math.floor(p4.part.Position.Y / 10)
        if v499 ~= v500 then return v500 < v499 end
        if p3.isDiamond and not p4.isDiamond then return true end
        if not p3.isDiamond and p4.isDiamond then return false end
        return p3.part.Position.Y > p4.part.Position.Y
    end)
    return t5
end
t1[4] = Modules:WaitForChild("Shared")
t3[10] = require(t1[4]:WaitForChild("Remotes"))
local _require = require
local WaitForChild = t1[4].WaitForChild
t1[10] = function()
    local ok, result = pcall(function()
        local BankMoneyPrintingFloor_STREAM = workspace:FindFirstChild("BankMoneyPrintingFloor_STREAM")
        if BankMoneyPrintingFloor_STREAM then BankMoneyPrintingFloor_STREAM = BankMoneyPrintingFloor_STREAM:FindFirstChild("IGNOREMoneyPrintingFloor") end
        if BankMoneyPrintingFloor_STREAM then BankMoneyPrintingFloor_STREAM = BankMoneyPrintingFloor_STREAM:FindFirstChild("IGNORE") end
        if BankMoneyPrintingFloor_STREAM then
            for _, v in ipairs(BankMoneyPrintingFloor_STREAM:GetChildren()) do
                local MainMachineNew = v:FindFirstChild("MainMachineNew")
                if MainMachineNew then return MainMachineNew end
            end
        end
        return nil
    end)
    return ok and result or nil
end
t3[11] = _require(WaitForChild(t1[4], "Jobs"):WaitForChild("JobsConstants"))
t3[12] = t3[4].LocalPlayer
local v18 = t3[5]
local WaitForChild2 = v18.WaitForChild
t1[11] = function()
    local Character = t3[12].Character
    if Character then Character = t3[12].Character:FindFirstChild("HumanoidRootPart") end
    if Character then t3[12].Character.HumanoidRootPart.CFrame = CFrame.new(-1121.92, 14.96, 2161.2) end
end
local v20 = WaitForChild2(v18, "Remotes")
t3[13] = v20:WaitForChild("RequestStartJobSession")
t3[14] = v20:WaitForChild("AttemptATMBustStart")
t3[15] = v20:WaitForChild("AttemptATMBustComplete")
t3[16] = v20:WaitForChild("AttemptCriminalJobComplete")
t1[12] = function()
    local ok, result = pcall(function()
        local BankHeist = workspace.Game.Heists:FindFirstChild("BankHeist")
        if BankHeist then return BankHeist:GetAttribute("HeistActive") == true end
        return false
    end)
    return ok and result
end
t3[17] = v20:WaitForChild("TryPurchaseProductYield")
t3[18] = false
t3[19] = false
t3[20] = "Highest Bounty"
t3[21] = 0
t3[22] = false
t3[23] = false
t3[24] = false
t3[25] = 300000
t3[26] = "Cashout"
t3[27] = 1200
t3[28] = nil
t3[29] = { true, true, false }
t3[30] = {}
t3[31] = false
t3[32] = 75000
t3[33] = false
t3[34] = {}
t3[35] = false
t3[36] = 300
t1[13] = function(p5)
    if p5 and p5.spawner then
        local pos = p5.pos
        return math.floor(pos.X) .. "," .. math.floor(pos.Y) .. "," .. math.floor(pos.Z)
    end
    return nil
end
t3[37] = 0
t3[38] = false
t3[39] = false
t3[40] = 5
t1[14] = function(p6)
    local n2 = 0
    while n2 < p6 do
        local Character = t3[12].Character
        if Character then Character = t3[12].Character:FindFirstChild("HumanoidRootPart") end
        if Character then
            local Humanoid = t3[12].Character:FindFirstChild("Humanoid")
            if Humanoid and Humanoid.Health > 0 then return true end
        end
        task.wait(0.2)
        n2 += 0.2
    end
    return false
end
t3[41] = "Tween"
t3[42] = 1200
t3[43] = false
t3[44] = false
t3[45] = 700
t3[46] = false
t3[47] = "Security"
t3[48] = game:GetService("VirtualUser")
t3[49] = false
t3[50] = "Notify"
t3[51] = 4999963
t1[15] = function()
    local ok, result = pcall(function() return workspace.Game.Heists.BankHeist.HeistAsset.PrerequisiteModels end)
    return ok and result or nil
end
t3[52] = { Mod = true, ["Senior Moderator"] = true, ["QA Alts"] = true, ["Voldex QA"] = true, Creative = true, Developer = true, LT = true, Admin = true, Owner = true }
t3[12].Idled:Connect(function()
    if t3[46] then
        pcall(function()
            t3[48]:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            t3[48]:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end)
local vector3 = Vector3.new(-18226.3, 32.9, -500.1)
t3[53] = nil
t3[54] = vector3
t3[55] = Vector3.new(-34534.5, 32.7, -32788.4)
t3[56] = workspace:WaitForChild("Game"):WaitForChild("Jobs"):WaitForChild("CriminalDropOffSpawners"):WaitForChild("CriminalDropOffSpawnerPermanent"):WaitForChild("CriminalDropOffPoint")
t3[57] = Vector3.new(-2543.3, 14.9, 4030.8)
t3[58] = game:GetService("TeleportService")
t3[59] = game:GetService("HttpService")
local function v22(p7)
    if not p7 then return nil end
    if p7:IsA("BasePart") then return p7.Position end
    if p7:IsA("Attachment") then return p7.WorldPosition end
    if p7:IsA("Model") then local Pivot = p7:GetPivot() return Vector3.new(Pivot.X, Pivot.Y, Pivot.Z) end
    return nil
end
t3[60] = function(p8)
    if not p8 then return end
    local Humanoid = p8:WaitForChild("Humanoid", 3)
    if not Humanoid then return end
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, not t3[22])
    if t3[22] then
        if Humanoid.SeatPart then
            Humanoid.Sit = false
            Humanoid.Jump = true
        end
        local HumanoidRootPart = p8:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            local SeatWeld = HumanoidRootPart:FindFirstChild("SeatWeld")
            if SeatWeld then SeatWeld:Destroy() end
        end
    end
end
t3[12].CharacterAdded:Connect(function(character) task.spawn(function() t3[60](character) end) end)
t1[5].Stepped:Connect(function()
    local v127 = t3[19]
    if v127 then v127 = t3[12].Character end
    if v127 then
        for _, descendant in ipairs(t3[12].Character:GetDescendants()) do
            if descendant:IsA("BasePart") then descendant.CanCollide = false end
        end
    end
    local v130 = t3[22]
    if v130 then v130 = t3[12].Character end
    if v130 then
        local Humanoid = t3[12].Character:FindFirstChild("Humanoid")
        local HumanoidRootPart = t3[12].Character:FindFirstChild("HumanoidRootPart")
        if Humanoid then Humanoid.Sit = false end
        if HumanoidRootPart then
            local SeatWeld = HumanoidRootPart:FindFirstChild("SeatWeld")
            if SeatWeld then SeatWeld:Destroy() end
        end
    end
end)
t3[61] = function(p9)
    if not t3[12].Character then return end
    local HumanoidRootPart = t3[12].Character:FindFirstChild("HumanoidRootPart")
    if HumanoidRootPart then HumanoidRootPart.Anchored = p9 end
end
t3[62] = function()
    if t3[28] then t3[28]:Destroy() end
    local v136 = not t3[12].Character
    if not v136 then v136 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
    if v136 then return end
    local HumanoidRootPart = t3[12].Character.HumanoidRootPart
    local Part = Instance.new("Part")
    Part.Size = Vector3.new(50, 1, 50)
    Part.Position = HumanoidRootPart.Position + Vector3.new(0, 200, 0)
    Part.Anchored = true
    Part.CanCollide = true
    Part.Transparency = 1
    Part.Parent = workspace
    t3[28] = Part
end
t3[63] = function()
    local v162 = not t3[12].Character
    if not v162 then v162 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
    if v162 then return false end
    local HumanoidRootPartPosition = t3[12].Character.HumanoidRootPart.Position
    for _, player in ipairs(t3[4]:GetPlayers()) do
        if player == t3[12] then continue end
        local v166 = not player.Team
        if not v166 then v166 = player.Team.Name ~= t3[8] end
        if v166 then continue end
        local v167 = not player.Character
        if not v167 then v167 = not player.Character:FindFirstChild("HumanoidRootPart") end
        if v167 then continue end
        local HumanoidRootPartPosition2 = player.Character.HumanoidRootPart.Position
        if Vector3.new(HumanoidRootPartPosition2.X - HumanoidRootPartPosition.X, 0, HumanoidRootPartPosition2.Z - HumanoidRootPartPosition.Z).Magnitude <= 30 then return true end
    end
    return false
end
t3[64] = function()
    if not t3[12].Character then return 0 end
    local CharacterBillboard = t3[12].Character:FindFirstChild("CharacterBillboard", true)
    if not CharacterBillboard then return 0 end
    for _, v in ipairs(CharacterBillboard:GetChildren()) do
        local v158 = v:IsA("TextLabel") and v.Name == "CriminalCharacterTextLabel"
        if not v158 then continue end
        local v159 = v.Text:match("%$([%d,%.]+)")
        if not v159 then
            local num = tonumber((v.Text:gsub("%$", ""):gsub(",", "")))
            if num then return num end
        else
            local num = tonumber((v159:gsub(",", "")))
            if num then return num end
        end
    end
    return 0
end
t3[65] = t3[5]:FindFirstChild("Stats")
t3[66] = function(p10)
    if not t3[65] then t3[65] = t3[5]:FindFirstChild("Stats") end
    if not t3[65] then return 0 end
    local v170 = t3[65]:FindFirstChild(p10.Name .. "'s Stats")
    if not v170 then return 0 end
    local Bounty = v170:FindFirstChild("Bounty")
    if not Bounty then return 0 end
    return tonumber(Bounty.Value) or 0
end
t3[67] = function(p11)
    if p11 == t3[12] then return false end
    local v173 = not p11.Team
    if not v173 then v173 = p11.Team.Name ~= t3[7] end
    if v173 then return false end
    local v174 = t3[66](p11)
    if v174 < t3[21] then return false end
    return true, v174
end
t3[68] = function(p12)
    local Character = p12.Character
    if Character then Character = p12.Character:FindFirstChild("HumanoidRootPart") ~= nil end
    return Character
end
t3[69] = function(p13, p14)
    local v108 = not p13
    if not v108 then v108 = typeof(p13) ~= "Vector3" end
    if v108 then return end
    local v109 = not t3[12].Character
    if not v109 then v109 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
    if v109 then return end
    local HumanoidRootPart = t3[12].Character.HumanoidRootPart
    local vector3_2 = Vector3.new(p13.X, p13.Y + 3, p13.Z)
    local v112 = (HumanoidRootPart.Position - vector3_2).Magnitude / p14
    t3[19] = true
    local v113 = t3[6]:Create(HumanoidRootPart, TweenInfo.new(v112, Enum.EasingStyle.Linear), { CFrame = CFrame.new(vector3_2) })
    v113:Play()
    v113.Completed:Wait()
    t3[53] = nil
    if not t3[22] then t3[19] = false end
end
t3[70] = function()
    if t3[53] then t3[53]:Cancel() t3[19] = false end
end
t3[71] = function()
    local Game = workspace:FindFirstChild("Game")
    if Game then Game = workspace.Game:FindFirstChild("Jobs") if Game then Game = workspace.Game.Jobs:FindFirstChild("CriminalATMSpawners") end end
    if not Game then return {} end
    local t6 = {}
    for _, v in ipairs(Game:GetChildren()) do table.insert(t6, v) end
    return t6
end
t3[72] = function(p15)
    local v140, v141, v142 = nil, nil, false
    local v143
    local v144, v145, v146 = ipairs({ "CriminalATMLegoSmall", "CriminalATMWater", "CriminalATM" })
    local g148, v149, ATM, v147
    repeat
        repeat
            v146, v147 = v144(v145, v146)
            if not v146 then g148 = true end
            if g148 then break end
            v149 = p15:FindFirstChild(v147, true)
        until v149
        if g148 then break end
        if not v143 then v143 = v149 end
        ATM = v149:FindFirstChild("ATM") or v149:FindFirstChild("PromptAttachment")
        local v151 = false
        if ATM and ATM:FindFirstChild("ATMIconBillboard") then v151 = true
        else
            local ProximityPrompt = v149:FindFirstChild("ProximityPrompt", true)
            if ProximityPrompt and ProximityPrompt.Enabled then v151 = true
            elseif v149:FindFirstChild("ATMIconBillboard", true) then v151 = true end
        end
    until v151
    if not g148 then v140 = v149 v141 = ATM or v149 v142 = v147 == "CriminalATMWater" end
    if not v140 and v143 then v140 = v143 v141 = v140:FindFirstChild("ATM") or (v140:FindFirstChild("PromptAttachment") or v140) v142 = v140.Name == "CriminalATMWater" end
    if not v141 then return nil end
    local v153 = v22(v141) or v22(p15)
    if not v153 then return nil end
    return { spawner = p15, model = v140, part = v141, pos = v153, isWater = v142 }
end
t3[73] = t1[13]
t3[74] = function(p16)
    local v124 = not p16
    if not v124 then v124 = not p16.model if not v124 then v124 = not p16.model.Parent end end
    if v124 then return false end
    if not p16.part then return false end
    if p16.part:FindFirstChild("ATMIconBillboard") then return true end
    local ProximityPrompt = p16.model:FindFirstChild("ProximityPrompt", true)
    if ProximityPrompt and ProximityPrompt.Enabled then return true end
    return p16.model:FindFirstChild("ATMIconBillboard", true) ~= nil
end
local function v23()
    local v199 = not t3[12].Character
    if not v199 then v199 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
    if v199 then return nil end
    local HumanoidRootPartPosition = t3[12].Character.HumanoidRootPart.Position
    local n3 = 1e999
    local v202
    for _, v in ipairs(t3[71]()) do
        local v205 = t3[72](v)
        if v205 and t3[74](v205) then
            local v206 = t3[73](v205)
            if (not v206 or not ((t3[30][v206] or 0) > 3)) and (not v205.isWater or t3[29][2]) then
                local v207 = not v205.isWater
                if v207 then v207 = not t3[29][1] and not t3[33] end
                if not v207 then
                    local Magnitude = (v205.pos - HumanoidRootPartPosition).Magnitude
                    if Magnitude < n3 then n3 = Magnitude v202 = v205 end
                end
            end
        end
    end
    return v202
end
t3[75] = function()
    t3[61](false)
    t3[69](t3[57], 500)
    task.wait(0.5)
    pcall(function() t3[16]:InvokeServer(t3[56]) end)
end
t3[76] = t1[12]
t3[77] = t1[11]
t3[78] = function()
    local ok, result, v105 = pcall(function()
        local HeistCashUIHolder = t3[12].PlayerGui:FindFirstChild("HeistCashUIHolder")
        if HeistCashUIHolder then HeistCashUIHolder = HeistCashUIHolder:FindFirstChild("HeistCashUI") end
        local v509 = not HeistCashUIHolder
        if not v509 then v509 = HeistCashUIHolder:IsA("GuiObject") and not HeistCashUIHolder.Visible end
        if v509 then return 0, 0 end
        local t7 = {}
        for v513 in HeistCashUIHolder.Holder.Holder.CashAmount.Text:gsub("<[^>]+>", ""):gsub(",", ""):gmatch("%d+") do
            table.insert(t7, (tonumber(v513)))
        end
        if #t7 >= 2 then
            local v514 = t7[#t7]
            return t7[#t7 - 1], v514
        end
        return 0, 0
    end)
    if ok then return result, v105 end
    return 0, 0
end
t3[79] = t1[9]
t3[80] = function(p17)
    local v89 = not p17
    if not v89 then v89 = not p17:IsA("ProximityPrompt") end
    if v89 then return end
    p17.MaxActivationDistance = 50
    p17.RequiresLineOfSight = false
    task.spawn(function()
        pcall(function() if fireproximityprompt then fireproximityprompt(p17) end end)
    end)
    pcall(function()
        p17:InputHoldBegin()
        local v507 = p17.HoldDuration or 0.25
        task.wait(v507 + 0.15)
        p17:InputHoldEnd()
    end)
end
t3[81] = function(p18)
    local v115 = not t3[12].Character
    if not v115 then v115 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
    if v115 then return end
    local HumanoidRootPart = t3[12].Character.HumanoidRootPart
    if (HumanoidRootPart.Position - p18.Position).Magnitude > 15 then
        HumanoidRootPart.Anchored = false
        task.wait(0.1)
    end
    t3[19] = true
    HumanoidRootPart.Anchored = false
    HumanoidRootPart.CFrame = CFrame.new(p18.Position)
    task.wait(0.1)
    HumanoidRootPart.Anchored = true
end
t3[82] = t1[15]
t3[83] = t1[10]
t3[84] = function()
    local v231 = t3[82]()
    if not v231 then return true end
    local t8 = {}
    for v235, v236 in ipairs(v231:GetChildren()) do
        local Prerequisites = v236:FindFirstChild("Prerequisites")
        if Prerequisites then
            for _, v in ipairs(Prerequisites:GetChildren()) do
                if v.Name == "TriggerBox" and v:FindFirstChild("Eletrical Box") then table.insert(t8, v) end
            end
        end
    end
    if #t8 == 0 then return true end
    local v242 = false
    while t3[22] and not v242 do
        v242 = true
        for v245, v246 in ipairs(t8) do
            local Primary = v246:FindFirstChild("Primary")
            if Primary then
                local Attachment = Primary:FindFirstChild("Attachment")
                local v249 = (Attachment and Attachment:FindFirstChild("ProximityPrompt")) or Primary:FindFirstChild("ProximityPrompt")
                if v249 and v249.Enabled then
                    t3[81](Primary)
                    v242 = false
                    task.wait(0.1)
                    t3[80](v249)
                end
            end
        end
        if not v242 then task.wait(0.2) end
    end
    return true
end
t3[85] = function()
    local v250 = t3[82]()
    if not v250 then return true end
    local CodeSnippet, g256, Prerequisites
    for _, v255 in ipairs(v250:GetChildren()) do
        Prerequisites = v255:FindFirstChild("Prerequisites")
        if Prerequisites then CodeSnippet = Prerequisites:FindFirstChild("CodeSnippet") end
        if CodeSnippet then break end
    end
    if not CodeSnippet then return true end
    local Primary = CodeSnippet:FindFirstChild("Primary")
    if Primary then
        local SurfaceGui = Primary:FindFirstChild("SurfaceGui")
        local v260 = SurfaceGui and SurfaceGui:FindFirstChild("TextLabel")
        if v260 and v260.Text ~= "" then
            local v262 = v260.Text:match("%d+")
            if v262 then
                local v263 = t3[83]()
                if v263 then t3[81](v263) task.wait(0.2) end
                pcall(function()
                    local HeistCodeEntered = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("HeistCodeEntered")
                    HeistCodeEntered:FireServer(unpack({ v262 }))
                end)
                task.wait(1)
            end
        end
    end
    return true
end
t3[86] = function()
    local v212 = t3[82]()
    if not v212 then return true end
    local t11 = {}
    for _, v218 in ipairs(v212:GetChildren()) do
        local Prerequisites = v218:FindFirstChild("Prerequisites")
        if Prerequisites then
            for _, v in ipairs(Prerequisites:GetChildren()) do
                if v.Name == "TriggerBox" and v:FindFirstChild("Detonator") then table.insert(t11, v) end
            end
        end
    end
    if #t11 == 0 then return true end
    local v224 = false
    while t3[22] and not v224 do
        v224 = true
        for _, v228 in ipairs(t11) do
            local Primary = v228:FindFirstChild("Primary")
            if Primary then
                local Attachment = Primary:FindFirstChild("Attachment")
                local p = (Attachment and Attachment:FindFirstChild("ProximityPrompt")) or Primary:FindFirstChild("ProximityPrompt")
                if p and p.Enabled then
                    v224 = false
                    t3[81](Primary)
                    task.wait(0.1)
                    t3[80](p)
                end
            end
        end
        if not v224 then task.wait(0.2) end
    end
    return true
end
t3[87] = function()
    if not t3[22] or not t3[29][3] then return false end
    if t3[64]() > 0 then
        if not (t3[64]() >= t3[32]) then
            if t3[29][1] or t3[29][2] then return false end
            local Character = t3[12].Character
            if Character then Character = t3[12].Character:FindFirstChild("Humanoid") end
            if Character then t3[12].Character.Humanoid.Health = 0 end
            task.wait(6)
            return false
        end
        t3[75]()
        task.wait(1)
    end
    t3[61](true)
    t3[77]()
    task.wait(3)
    if not t3[22] then t3[61](false) return false end
    t3[84]()
    if not t3[22] then return false end
    t3[85]()
    if not t3[22] then return false end
    t3[86]()
    if not t3[22] then return false end
    t3[61](true)
    local n4 = 0
    local v266
    while true do
        if not (t3[22] and n4 < 300) then break end
        n4 += 1
        if not t3[76]() then break end
        local v268, v269 = t3[78]()
        if v269 > 0 and v269 <= v268 then break end
        local v271 = t3[79]()
        if #v271 == 0 then break end
        for _, v in ipairs(v271) do
            if not t3[22] then break end
            local v274 = math.floor(v.part.Position.Y / 10)
            if v266 and v266 ~= v274 then t3[61](false) task.wait(0.5) end
            local v275, v276 = t3[78]()
            v266 = v274
            if (v276 > 0 and v276 <= v275) or not t3[76]() then break end
            t3[81](v.part)
            task.wait(0.2)
            t3[80](v.prompt)
            task.wait(0.5)
        end
        task.wait(0.2)
    end
    t3[31] = true
    t3[61](false)
    t3[33] = true
    local Character = t3[12].Character
    if Character then Character = t3[12].Character:FindFirstChild("HumanoidRootPart") end
    if Character then t3[12].Character.HumanoidRootPart.CFrame = CFrame.new(-1056.83, 146.82, 2294.9) end
    task.wait(1)
    return true
end
t3[88] = function()
    t3[61](false)
    t3[70]()
    if t3[26] == "Cashout" and t3[64]() >= 80000 and not t3[33] then t3[75]() return end
    local Character = t3[12].Character
    if Character then Character = t3[12].Character:FindFirstChild("HumanoidRootPart") end
    if Character then t3[12].Character.HumanoidRootPart.CFrame = CFrame.new(t3[54].X, t3[54].Y + 3, t3[54].Z) end
end
t3[89] = function(p19, p20, ...)
    local u92, u93 = nil, false
    local t12 = { ... }
    task.spawn(function()
        pcall(function() u92 = p19:InvokeServer(unpack(t12)) end)
        u93 = true
    end)
    local n5 = 0
    while not u93 and n5 < p20 do task.wait(0.1) n5 += 0.1 end
    return u93, u92
end
t1[18] = function(p21)
    local v282 = false
    if not t3[74](p21) then return false end
    t3[89](t3[14], 5, p21.model)
    local n6 = 0
    local g284 = false
    repeat
        if n6 >= 4.5 then g284 = true break end
        task.wait(0.2)
        n6 += 0.2
        if t3[23] and t3[63]() then t3[88]() v282 = true g284 = true break end
        if not t3[22] then v282 = true g284 = true break end
        local v285 = not t3[12].Character
        if not v285 then v285 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
        if v285 then v282 = true g284 = true break end
        local Humanoid = t3[12].Character:FindFirstChild("Humanoid")
        if Humanoid and Humanoid.Health <= 0 then g284 = true break end
    until g284
    if not v282 then
        t3[89](t3[15], 5, p21.model)
        task.wait(0.5)
        if t3[74](p21) then return false end
        t3[33] = false
    end
    return not v282
end
t3[90] = t1[14]
t3[91] = t1[18]

-- NỐI CÁC TOGGLE CỦA TOOL VÀO MENU UICHILL
local SecArrest = TabFarm:AddSection("Tự Động Bắt Giam")
SecArrest:AddToggle("Tự động bắt giam", false, function(p22)
    t3[18] = p22
    if t3[18] then
        local v288 = not t3[12].Team
        if not v288 then v288 = t3[12].Team.Name ~= t3[8] end
        if v288 then pcall(function() t3[13]:FireServer("Security", "jobPad") end) end
    end
end)

local SecRob = TabFarm:AddSection("Tự Động Cướp Bóc")
SecRob:AddToggle("Tự động cướp", false, function(p23)
    t3[22] = p23
    t3[19] = p23
    if t3[22] then
        local v290 = not t3[12].Team
        if not v290 then v290 = t3[12].Team.Name ~= t3[7] end
        if v290 then pcall(function() t3[13]:FireServer("Criminal", "jobPad") end) end
        t3[62]()
    else
        t3[61](false)
        t3[33] = false
        t3[31] = false
        if t3[28] then t3[28]:Destroy() end
        t3[70]()
    end
    t3[60](t3[12].Character)
end)
SecRob:AddToggle("Tránh Bảo vệ", true, function(p24) t3[23] = p24 end)
SecRob:AddToggle("Tự động Rửa tiền", true, function(p25) t3[24] = p25 end)
SecRob:AddToggle("Cách thức: Rửa tiền (Tắt=Tránh)", true, function(s) t3[26] = s and "Cashout" or "Avoid" end)
SecRob:AddSlider("Mức tiền Rửa", 80000, 1000000, 300000, function(p27) t3[25] = tonumber(p27) or 300000 end)
SecRob:AddToggle("Tắt Laser Ngân hàng", false, function(p28) t3[38] = p28 end)
SecRob:AddToggle("Cướp ATM", true, function(s) t3[29][1] = s end)
SecRob:AddToggle("Cướp ATM Nước", true, function(s) t3[29][2] = s end)
SecRob:AddToggle("Cướp Ngân Hàng (Beta)", false, function(s) t3[29][3] = s end)
SecRob:AddButton("Rửa tiền Ngay", function() t3[75]() end)

local SecDrive = TabFarm:AddSection("Tự Động Lái Xe")
SecDrive:AddToggle("Tự động lái xe", false, function(p31) t3[43] = p31 end)
SecDrive:AddToggle("Tự động lái Trực thăng", false, function(p32) t3[44] = p32 end)
SecDrive:AddSlider("Tốc độ Lái", 100, 750, 750, function(p33) t3[45] = tonumber(p33) or 750 end)

local SecDel = TabFarm:AddSection("Tự Động Giao Hàng")
SecDel:AddToggle("Tự động giao hàng", false, function(p34)
    t3[39] = p34
    if t3[39] then
        local v306 = not t3[12].Team
        if not v306 then v306 = t3[12].Team.Name ~= t3[9] end
        if v306 then pcall(function() t3[13]:FireServer("Delivery", "jobPad") end) end
    end
end)
SecDel:AddSlider("Độ trễ Giao hàng", 2, 60, 5, function(p35) t3[40] = tonumber(p35) or 5 end)
SecDel:AddToggle("Cách thức: Lướt (Tắt=Dịch chuyển)", true, function(s) t3[41] = s and "Tween" or "Teleport" end)
SecDel:AddSlider("Tốc độ Lướt", 100, 2000, 1200, function(p37) t3[42] = tonumber(p37) or 1200 end)

local SecMisc = TabMisc:AddSection("Các Chức Năng Khác")
SecMisc:AddButton("Vào Nhóm (Từ mục chọn bên dưới)", function()
    pcall(function()
        local v524 = t3[47] ~= "Outlaw" and (t3[47] ~= "Delivery Driver" and "Security" or "Delivery") or "Criminal"
        t3[13]:FireServer(v524, "jobPad")
    end)
end)
SecMisc:AddToggle("Chọn Nhóm: Bảo Vệ", true, function(s) if s then t3[47] = "Security" end end)
SecMisc:AddToggle("Chọn Nhóm: Tội Phạm", false, function(s) if s then t3[47] = "Outlaw" end end)
SecMisc:AddToggle("Chọn Nhóm: Giao Hàng", false, function(s) if s then t3[47] = "Delivery Driver" end end)

SecMisc:AddButton("Mua 10 Hộp Phụ Tùng", function()
    pcall(function()
        local t15 = { "TenTuningKits", "Cash", { Category_0 = "Crates", ShopTab = "Cash", Source = "Shop", DoNotifySuccess = false, PurchaseId = "CD481A2B-B41C-4EC5-A236-65E1562A3F33", Category_1 = "TuningKits" } }
        t3[17]:InvokeServer(v2(t15))
    end)
end)
SecMisc:AddButton("Mở tất cả Hộp Phụ Tùng", function()
    pcall(function()
        local num = tonumber((game:GetService("Players").LocalPlayer.PlayerGui.PartsInventory.GenericInventory.MainFrame.Menus.LootboxInventoryUI.Holder.View.Items.Container.Pack_Parts_Store.Holder.Container.Quantity.TextLabel.Text:gsub("%D", "")))
        if not num or num <= 0 then return end
        local t17 = { "Pack_Parts_Store", { Amount = num } }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("OpenGacha"):InvokeServer(unpack(t17))
    end)
end)

SecMisc:AddToggle("Chống Kích AFK", false, function(p39) t3[46] = p39 end)

t3[93] = function(p40)
    local u317 = false
    pcall(function()
        local VoldexAdmin = game:GetService("ReplicatedStorage"):FindFirstChild("VoldexAdmin")
        if VoldexAdmin then
            local VoldexAdmins = VoldexAdmin:FindFirstChild("VoldexAdmins")
            if VoldexAdmins and VoldexAdmins:IsA("ModuleScript") then
                local lib = require(VoldexAdmins)
                if type(lib) == "table" and lib[p40.UserId] then u317 = true end
            end
        end
    end)
    if u317 then return true, "Module Staff" end
    local ok, result = pcall(function() return p40:GetRoleInGroup(t3[51]) end)
    if ok and result and t3[52][result] then return true, result end
    return false, nil
end

t3[94] = function(p41, p42)
    if not t3[49] then return end
    if t3[50] == "Serverhop" then
        task.wait(1)
        task.spawn(function()
            local n7 = 0
            while true do
                local ok, result = pcall(function()
                    return t3[59]:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                end)
                if ok and result and result.data then
                    local JobId = game.JobId
                    local t19 = {}
                    for _, v557 in ipairs(result.data) do
                        if JobId ~= v557.id and v557.playing < v557.maxPlayers and not t3[34][v557.id] then table.insert(t19, v557) end
                    end
                    if #t19 == 0 then
                        t3[34] = { [JobId] = true }
                        for _, v in ipairs(result.data) do
                            if JobId ~= v.id and v.playing < v.maxPlayers then table.insert(t19, v) end
                        end
                    end
                    if #t19 > 0 then
                        local v562 = t19[math.random(1, #t19)]
                        t3[34][v562.id] = true
                        t3[34][JobId] = true
                        t3[58]:TeleportToPlaceInstance(game.PlaceId, v562.id, t3[12])
                        return
                    end
                end
                n7 += 1
                task.wait(5)
            end
        end)
        return
    end
end

SecMisc:AddToggle("Chống Admin (An Toàn)", false, function(p43)
    t3[49] = p43
    if t3[49] then
        task.spawn(function()
            for _, player in ipairs(t3[4]:GetPlayers()) do
                if player == t3[12] then continue end
                local v565, v566 = t3[93](player)
                if v565 then t3[94](player, v566) return end
            end
        end)
    end
end)

SecMisc:AddToggle("Cách chống: Đổi Server (Tắt=Thông báo)", false, function(s) t3[50] = s and "Serverhop" or "Notify" end)

t3[4].PlayerAdded:Connect(function(player)
    if not t3[49] then return end
    task.spawn(function()
        local t20, v568 = t3[93](player)
        if t20 then t3[94](player, v568) end
    end)
end)

local SecHop = TabMisc:AddSection("Đổi Máy Chủ (Server Hop)")
SecHop:AddButton("Đổi Server Ngay", function()
    task.spawn(function()
        local n8 = 0
        while true do
            local ok, result = pcall(function()
                return t3[59]:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            end)
            if ok and result and result.data then
                local JobId = game.JobId
                local t22 = {}
                for _, v577 in ipairs(result.data) do
                    if JobId ~= v577.id and v577.playing < v577.maxPlayers and not t3[34][v577.id] then table.insert(t22, v577) end
                end
                if #t22 == 0 then
                    t3[34] = { [JobId] = true }
                    for _, v in ipairs(result.data) do
                        if JobId ~= v.id and v.playing < v.maxPlayers then table.insert(t22, v) end
                    end
                end
                if #t22 > 0 then
                    local v582 = t22[math.random(1, #t22)]
                    t3[34][v582.id] = true
                    t3[34][JobId] = true
                    t3[58]:TeleportToPlaceInstance(game.PlaceId, v582.id, t3[12])
                    return
                end
            end
            n8 += 1
            task.wait(5)
        end
    end)
end)

SecHop:AddToggle("Tự động Đổi Server", false, function(p46)
    t3[35] = p46
    if p46 then t3[37] = tick() end
end)
SecHop:AddSlider("Thời gian chờ Đổi Server", 10, 600, 20, function(p47) t3[36] = tonumber(p47) or 20 end)

-- KẾT THÚC KHỐI UI, TIẾP TỤC LOGIC CỐT LÕI

t3[100] = 1
local vector3_3 = Vector3.new(4000, 150, 4000)
local vector3_4 = Vector3.new(-4000, 150, 4000)
local vector3_5 = Vector3.new(4000, 150, -4000)
local vector3_6 = Vector3.new(-4000, 150, -4000)
local vector3_7 = Vector3.new(0, 150, 0)
local vector3_8 = Vector3.new(2000, 150, 0)
local vector3_9 = Vector3.new(-2000, 150, 0)
local vector3_10 = Vector3.new(0, 150, 2000)
t1[35] = Vector3.new
t3[101] = { vector3_3, vector3_4, vector3_5, vector3_6, vector3_7, vector3_8, vector3_9, vector3_10, t1[35](0, 150, -2000) }
t3[102] = tick()
t3[103] = 0
t3[104] = 3
t3[105] = 120
t3[106] = nil
t3[106] = function()
    local t26 = {}
    for _, player in ipairs(t3[4]:GetPlayers()) do
        local v355, v356 = t3[67](player)
        if v355 then table.insert(t26, { player = player, bounty = v356 }) end
    end
    return t26
end
t3[107] = function()
    local v357 = t3[106]()
    if #v357 == 0 then return {} end
    if t3[20] == "Highest Bounty" then
        table.sort(v357, function(p51, p52) return p51.bounty > p52.bounty end)
        return v357
    end
    if t3[20] == "Closest" then
        local v358 = not t3[12].Character
        if not v358 then v358 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
        if v358 then return v357 end
        local HumanoidRootPartPosition = t3[12].Character.HumanoidRootPart.Position
        table.sort(v357, function(p53, p54)
            local u590 = p53
            local ok, result = pcall(function()
                local Character = u590.player.Character
                if Character then
                    Character = u590.player.Character:FindFirstChild("HumanoidRootPart")
                    if Character then Character = u590.player.Character.HumanoidRootPart.Position end
                end
                return Character
            end)
            local ok3, result3 = pcall(function()
                local Character = p54.player.Character
                if Character then
                    Character = p54.player.Character:FindFirstChild("HumanoidRootPart")
                    if Character then Character = p54.player.Character.HumanoidRootPart.Position end
                end
                return Character
            end)
            local v595 = ok and result
            if v595 then v595 = (result - HumanoidRootPartPosition).Magnitude end
            if not v595 then v595 = 1e999 end
            local v596 = ok3 and result3
            if v596 then v596 = (result3 - HumanoidRootPartPosition).Magnitude end
            if not v596 then v596 = 1e999 end
            return v595 < v596
        end)
        return v357
    end
    return v357
end
t3[108] = function(p55)
    local u349 = p55
    local ok, _ = pcall(function() t3[10].fireServer(t3[11].Remotes.RequestArrestCriminal, u349) end)
    return ok
end
task.spawn(function()
    while true do
        task.wait(0.5)
        if t3[38] then
            pcall(function()
                local Lasers = workspace.Game.Heists.BankHeist.HeistAsset:FindFirstChild("Lasers")
                if Lasers then Lasers:Destroy() end
            end)
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(1)
        if t3[18] then
            local v360 = not t3[12].Team
            if not v360 then v360 = t3[12].Team.Name ~= t3[8] end
            if v360 then
                pcall(function() t3[13]:FireServer("Security", "jobPad") end)
                task.wait(1)
            else
                local v361 = t3[107]()
                if #v361 ~= 0 then
                    for _, v in ipairs(v361) do
                        if not t3[18] then break end
                        t3[108](v.player)
                        if #v361 > 1 then task.wait(0.1) end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while true do
        while true do
            while true do
                while true do
                    while true do
                        while true do
                            task.wait(0.1)
                            if t3[22] then break end
                            t3[103] = 0
                        end
                        if tick() - t3[102] > 15 then
                            for k, v in pairs(t3[30]) do
                                if v > 0 then t3[30][k] = math.max(0, v - 2) end
                            end
                            t3[102] = tick()
                        end
                        local v366 = not t3[12].Character
                        if not v366 then v366 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
                        if not v366 then break end
                        t3[61](false)
                        if t3[90](10) then t3[19] = true t3[62]() t3[60](t3[12].Character) task.wait(0.5) end
                    end
                    local Humanoid = t3[12].Character:FindFirstChild("Humanoid")
                    if not Humanoid or not (Humanoid.Health <= 0) then break end
                    t3[61](false)
                    t3[90](10)
                    t3[19] = true
                    t3[62]()
                    t3[60](t3[12].Character)
                    task.wait(0.5)
                end
                local v368 = t3[24]
                if v368 then v368 = t3[64]() >= t3[25] and not t3[33] end
                if not v368 then break end
                t3[61](false)
                t3[75]()
                task.wait(0.5)
            end
            if not t3[23] or not t3[63]() then break end
            t3[88]()
            task.wait(1)
        end
        local v369 = t3[31]
        if v369 then v369 = not t3[76]() end
        if v369 then t3[31] = false end
        local v370 = t3[29][3]
        if v370 then v370 = t3[76]() and not t3[31] end
        if v370 then
            t3[61](false)
            if t3[87]() then task.wait(1) continue end
        end
        local v371 = t3[29][1]
        if not v371 then v371 = t3[29][2] or t3[33] end
        if v371 then
            local v372 = v23()
            if not v372 then
                t3[103] = t3[103] + 1
                if t3[103] >= t3[104] then t3[30] = {} t3[103] = 0 end
                for k, v in pairs(t3[30]) do t3[30][k] = math.floor(v / 2) end
                local u375
                t3[61](false)
                local u376 = true
                local timestamp = tick()
                task.spawn(function()
                    while u376 and t3[22] do
                        task.wait(0.5)
                        local v598 = v23()
                        if v598 then u375 = v598 t3[70]() return end
                        local v599 = t3[29][3]
                        if v599 then v599 = t3[76]() and not t3[31] end
                        if v599 then t3[70]() return end
                        if not (tick() - timestamp > t3[105]) then continue end
                        t3[30] = {}
                        t3[103] = 0
                        local v600 = v23()
                        if v600 then u375 = v600 t3[70]() return end
                        timestamp = tick()
                    end
                end)
                while t3[22] and not u375 do
                    local v378 = t3[24]
                    if v378 then v378 = t3[64]() >= t3[25] and not t3[33] end
                    if v378 or t3[23] and t3[63]() then break end
                    local v379 = t3[29][3]
                    if v379 then v379 = t3[76]() and not t3[31] end
                    if v379 then break end
                    local v380 = not t3[12].Character
                    if not v380 then v380 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
                    if v380 then break end
                    if tick() - timestamp > t3[105] then t3[30] = {} t3[103] = 0 break end
                    t3[61](false)
                    t3[100] = t3[100] + 1
                    if t3[100] > #t3[101] then t3[100] = 1 end
                    local v381 = t3[69]
                    local v382 = t3[100]
                    v381(t3[101][v382], t3[27])
                end
                u376 = false
                v372 = u375
            else
                t3[103] = 0
            end
            if v372 and t3[22] then
                local v383 = t3[24]
                if v383 then v383 = t3[64]() >= t3[25] and not t3[33] end
                if not v383 then
                    if t3[23] and t3[63]() then
                        t3[88]()
                        task.wait(1)
                    elseif t3[74](v372) then
                        local isWater = v372.isWater
                        local _Vector3 = Vector3
                        local v386 = not isWater and 1 or 15
                        local v387 = _Vector3.new(v372.pos.X, v372.pos.Y + v386, v372.pos.Z)
                        t3[61](false)
                        t3[69](v387, t3[27])
                        if t3[22] then
                            local v388 = not t3[12].Character
                            if not v388 then v388 = not t3[12].Character:FindFirstChild("HumanoidRootPart") end
                            if not v388 then
                                if t3[23] and t3[63]() then
                                    t3[88]()
                                    local v389 = t3[73](v372)
                                    if v389 then t3[30][v389] = (t3[30][v389] or 0) + 10 end
                                    task.wait(1)
                                elseif t3[74](v372) then
                                    local Character = t3[12].Character
                                    if Character then Character = t3[12].Character:FindFirstChild("HumanoidRootPart") end
                                    if Character then t3[12].Character.HumanoidRootPart.CFrame = CFrame.new(v387) end
                                    t3[61](true)
                                    task.wait(0.1)
                                    local v391 = t3[91](v372)
                                    local v392 = t3[73](v372)
                                    if t3[74](v372) then
                                        if v392 then t3[30][v392] = (t3[30][v392] or 0) + 1 end
                                    else
                                        t3[61](false)
                                        if v392 then t3[30][v392] = 0 end
                                    end
                                    local v393 = not v391
                                    if v393 then v393 = t3[23] and t3[63]() end
                                    if v393 then
                                        t3[61](false)
                                        if v392 then t3[30][v392] = (t3[30][v392] or 0) + 10 end
                                        t3[88]()
                                    end
                                    t3[61](false)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
        else
            task.wait(1)
        end
    end
end)
t3[109] = function()
    local Character = t3[12].Character
    if not Character then return nil end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or not Humanoid.SeatPart then return nil end
    return (Humanoid.SeatPart:FindFirstAncestorOfClass("Model"))
end
t3[110] = nil
t3[110] = function(p56, p57, p58)
    local PrimaryPart = p56.PrimaryPart
    if not PrimaryPart then PrimaryPart = p56:FindFirstChildOfClass("BasePart") end
    if not PrimaryPart then return end
    local cFrame = CFrame.lookAt(PrimaryPart.Position, Vector3.new(p57.X, PrimaryPart.Position.Y, p57.Z))
    pcall(function() p56:PivotTo(cFrame) end)
    local Attachment = Instance.new("Attachment", PrimaryPart)
    local LinearVelocity = Instance.new("LinearVelocity", PrimaryPart)
    LinearVelocity.Attachment0 = Attachment
    LinearVelocity.VectorVelocity = cFrame.LookVector * p58
    LinearVelocity.MaxForce = 1e999
    LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    local AlignOrientation = Instance.new("AlignOrientation", PrimaryPart)
    AlignOrientation.Attachment0 = Attachment
    AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    AlignOrientation.CFrame = cFrame
    AlignOrientation.MaxTorque = 1e999
    local v402 = (PrimaryPart.Position - p57).Magnitude / p58
    local timestamp = tick()
    while true do
        local v404 = v402 > tick() - timestamp
        if v404 then v404 = t3[43] or t3[44] end
        if not v404 then break end
        local v405 = not t3[12].Character
        if not v405 then
            v405 = not t3[12].Character:FindFirstChild("Humanoid")
            if not v405 then v405 = not t3[12].Character.Humanoid.SeatPart end
        end
        if v405 then break end
        task.wait(0.05)
    end
    LinearVelocity:Destroy()
    AlignOrientation:Destroy()
    Attachment:Destroy()
    PrimaryPart.AssemblyLinearVelocity = Vector3.zero
    PrimaryPart.AssemblyAngularVelocity = Vector3.zero
end
t3[111] = function(p59)
    while true do
        task.wait(0.1)
        if p59 and not t3[44] or not p59 and not t3[43] then break end
        local v409 = t3[109]()
        if v409 then
            local PrimaryPart = v409.PrimaryPart
            if not PrimaryPart then PrimaryPart = v409:FindFirstChildOfClass("BasePart") end
            if not PrimaryPart then task.wait(1) continue end
            local u411 = t3[54]
            local v412 = t3[55]
            if p59 then
                u411 += Vector3.new(0, 50, 0)
                v412 += Vector3.new(0, 50, 0)
            end
            pcall(function() v409:PivotTo(CFrame.new(u411)) end)
            task.wait(0.2)
            if (not p59 or t3[44]) and (p59 or t3[43]) then t3[110](v409, v412, t3[45]) continue end
            return
        end
        task.wait(1)
    end
end
task.spawn(function()
    local v413 = false
    local v414 = false
    while true do
        task.wait(0.2)
        if t3[43] and not v413 then
            v413 = true
            task.spawn(function() t3[111](false) end)
        elseif not t3[43] then
            v413 = false
        end
        if t3[44] and not v414 then
            v414 = true
            task.spawn(function() t3[111](true) end)
        elseif not t3[44] then
            v414 = false
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(5)
        if t3[35] and tick() - t3[37] >= t3[36] then
            t3[37] = tick()
            task.spawn(function()
                local n9 = 0
                while true do
                    local ok, result = pcall(function()
                        local v651 = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                        local v652 = t3[59]
                        local t27 = { game:HttpGet(v651) }
                        return v652:JSONDecode(v2(t27))
                    end)
                    if ok then ok = result and result.data end
                    if ok then
                        local JobId = game.JobId
                        local t28 = {}
                        for v608, v609 in ipairs(result.data) do
                            local v610 = JobId ~= v609.id
                            if v610 then
                                v610 = v609.playing < v609.maxPlayers
                                if v610 then v610 = not t3[34][v609.id] end
                            end
                            if v610 then table.insert(t28, v609) end
                        end
                        if #t28 == 0 then
                            t3[34] = {}
                            t3[34][JobId] = true
                            for _, v in ipairs(result.data) do
                                local v613 = JobId ~= v.id
                                if v613 then v613 = v.playing < v.maxPlayers end
                                if v613 then table.insert(t28, v) end
                            end
                        end
                        if #t28 > 0 then
                            local v614 = t28[math.random(1, #t28)]
                            t3[34][v614.id] = true
                            t3[34][JobId] = true
                            t3[58]:TeleportToPlaceInstance(game.PlaceId, v614.id, t3[12])
                            return
                        end
                    end
                    n9 += 1
                    task.wait(5)
                end
            end)
        end
    end
end)
t3[112] = v20:WaitForChild("DeliveryLocationInteracted")
t3[113] = 10
t3[114] = 25
t3[115] = 4
t3[116] = 1
t3[117] = function()
    local t29 = {}
    local Game = workspace:FindFirstChild("Game")
    if Game then Game = Game:FindFirstChild("Jobs") end
    local v417 = Game and Game:FindFirstChild("Delivery")
    if v417 then v417 = v417:FindFirstChild("DeliveryLocations") end
    if v417 then
        local GetChildren = v417.GetChildren
        for _, v in ipairs(GetChildren(v417)) do table.insert(t29, v) end
    end
    return t29
end
local function v49()
    local t30 = {}
    local DeliveryPickupItems_DeliveryLocation = workspace:FindFirstChild("DeliveryPickupItems_DeliveryLocation")
    if DeliveryPickupItems_DeliveryLocation then
        for _, child in ipairs(DeliveryPickupItems_DeliveryLocation:GetChildren()) do table.insert(t30, child) end
    end
    return t30
end
t3[118] = t1[30]
local function v50(p60)
    local Character = t3[12].Character
    if Character then Character = Character:FindFirstChild("HumanoidRootPart") end
    if not Character then return false end
    local v450 = t3[118](p60)
    if not v450 then return false end
    if t3[41] == "Tween" then
        t3[69](v450, t3[42])
    else
        Character.CFrame = CFrame.new(v450 + Vector3.new(0, 3, 0))
    end
    return true
end
t3[119] = function(p61)
    for _, v in ipairs(p61) do
        local v311 = v
        pcall(function()
            for _, descendant in ipairs(v311:GetDescendants()) do
                local v522 = descendant
                local v523 = v522:IsA("ProximityPrompt")
                if v523 then v523 = v522.Enabled end
                if v523 then
                    v522.MaxActivationDistance = 50
                    v522.RequiresLineOfSight = false
                    if fireproximityprompt then
                        fireproximityprompt(v522)
                    else
                        task.spawn(function()
                            v522:InputHoldBegin()
                            task.wait((v522.HoldDuration or 0) + 0.15)
                            v522:InputHoldEnd()
                        end)
                    end
                end
            end
        end)
    end
end
t3[120] = function(p62, p63)
    local v427
    local n10 = 1e999
    for _, v in ipairs(p62) do
        local v431 = t3[118](v)
        if v431 then
            local Magnitude = (p63 - v431).Magnitude
            if Magnitude < n10 then
                n10 = Magnitude
                v427 = v
            end
        end
    end
    return v427
end
t3[121] = function(p64, p65, p66)
    for _, v in ipairs(p64) do
        local v456 = t3[118](v)
        if v456 then v456 = p66 >= (p65 - v456).Magnitude end
        if v456 then return true end
    end
    return false
end
t3[122] = function()
    local DeliveryLocationEffects = workspace:FindFirstChild("DeliveryLocationEffects")
    local v434 = DeliveryLocationEffects
    if DeliveryLocationEffects then v434 = DeliveryLocationEffects:FindFirstChild("Ring") end
    local v435 = v434 and t3[118](v434)
    local v436 = DeliveryLocationEffects and DeliveryLocationEffects:FindFirstChild("RingGlow")
    local v437 = v436 and t3[118](v436)
    local DeliveryTargetAnchor = workspace:FindFirstChild("DeliveryTargetAnchor", true)
    local v439, v440
    local v441 = DeliveryTargetAnchor and t3[118](DeliveryTargetAnchor)
    if v435 then v440 = v435 v439 = v434
    elseif v437 then v439 = v436 v440 = v437
    elseif v441 then v440 = v441 v439 = DeliveryTargetAnchor end
    if not v440 then return nil, nil end
    local v442
    local n11 = 1e999
    for _, v in ipairs(t3[117]()) do
        local v446 = t3[118](v)
        if v446 then
            local Magnitude = (v446 - v440).Magnitude
            if Magnitude < n11 then v442 = v n11 = Magnitude end
        end
    end
    return v442, v439
end
t3[123] = function()
    if workspace:FindFirstChild("DeliveryTargetAnchor", true) then return true end
    local DeliveryLocationEffects = workspace:FindFirstChild("DeliveryLocationEffects")
    if not DeliveryLocationEffects then return false end
    local RingGlow = DeliveryLocationEffects:FindFirstChild("RingGlow")
    if not RingGlow then return false end
    if RingGlow:IsA("BasePart") then return RingGlow.Transparency < 1 end
    for _, descendant in ipairs(RingGlow:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Transparency < 1 then return true end
    end
    return false
end
t3[124] = function()
    local v467 = t3[117]()
    if #v467 == 0 then return end
    local n12 = 0
    while t3[39] and n12 < #v467 * 2 and (not (#v49() > 0) and not t3[123]()) do
        n12 += 1
        t3[116] = t3[116] % #v467 + 1
        local v469 = v467[t3[116]]
        if v50(v469) then
            task.wait(0.5)
            pcall(function() t3[112]:FireServer(v469) end)
            task.wait(0.5)
        end
    end
end
t3[125] = function()
    local v457 = 0
    local Character = t3[12].Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    local timestamp = tick()
    local v460 = #v49()
    while t3[39] do
        local v461 = v49()
        if #v461 == 0 or tick() - timestamp > t3[114] then return end
        local Character2 = t3[12].Character
        if Character2 then Character2 = Character2:FindFirstChild("HumanoidRootPart") end
        if not Character2 then return end
        if not t3[121](v461, Character2.Position, t3[113]) then
            v50(t3[120](v461, Character2.Position) or v461[1])
            task.wait(0.5)
        end
        t3[119](v461)
        task.wait(0.5)
        local v463 = #v49()
        if v460 <= v463 then
            local v464 = t3[115]
            v457 += 1
            if v464 <= v457 then
                local Character3 = t3[12].Character
                if Character3 then Character3 = t3[12].Character:FindFirstChild("HumanoidRootPart") end
                if Character3 then
                    Character3.CFrame = Character3.CFrame * CFrame.new(50, 0, 0)
                    task.wait(0.5)
                    local v466 = v49()
                    if #v466 > 0 then v50(t3[120](v466, Character3.Position) or v466[1]) task.wait(0.5) end
                end
            end
        else
            v460 = v463
        end
    end
end
t3[126] = false
t3[127] = nil
task.spawn(function()
    while true do
        task.wait(0.1)
        if t3[39] then
            local v470 = not t3[12].Team
            if not v470 then v470 = t3[12].Team.Name ~= t3[9] end
            if v470 then
                pcall(function() t3[13]:FireServer("Delivery", "jobPad") end)
                task.wait(1)
            elseif #v49() > 0 then
                t3[126] = false
                t3[127] = nil
                t3[125]()
            elseif t3[123]() then
                local v471, v472 = t3[122]()
                local v473 = v471
                local v474 = v472
                if v473 and v474 then
                    if v473 ~= t3[127] then t3[126] = false t3[127] = v473 end
                    if not t3[126] then
                        local timestamp = tick()
                        while tick() - timestamp < t3[40] and t3[39] do task.wait(0.1) end
                        t3[126] = true
                    end
                    if not pcall(function() v50(v474) end) then pcall(function() v50(v473) end) end
                    local timestamp = tick()
                    while tick() - timestamp < 0.5 do task.wait(0.1) end
                    pcall(function() t3[112]:FireServer(v473) end)
                    local timestamp2 = tick()
                    while tick() - timestamp2 < 0.5 do task.wait(0.1) end
                end
            else
                t3[126] = false
                t3[127] = nil
                t3[124]()
            end
        end
    end
end)

