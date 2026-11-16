--[[
    ============================================================
    MMB HUB - CLEAN DEOBFUSCATED EDITION
    - Đã làm sạch 100% mã nguồn (loại bỏ toàn bộ VM & obfuscation)
    - Đầy đủ chức năng: ESP (Skeleton, Box, Health, Name, Distance,
      Tracer, Chams, Car, Radar, Preview), Aimbot, Silent Aim,
      Misc (FOV, Spin, Rainbow Car, Shift Boost, Saturation, Stretch,
      Info View), Skin Changer, Rainbow AK, AutoFarm, Configs & Lang
    - Dễ dàng đổi tên menu tại bảng MENU_CONFIG bên dưới
    ============================================================
--]]

local MENU_CONFIG = {
    Title = "MMB Hub",                         -- Tên menu chính
    ShortTitle = "MMB HUB",                    -- Tên hiển thị ở màn hình Loading & Chọn ngôn ngữ
    LogoId = "rbxassetid://101126075036384", -- ID ảnh logo
    ToggleKey = Enum.KeyCode.RightShift,       -- Phím ẩn/hiện menu
    AccentColor = Color3.fromRGB(255, 60, 60),
    LanguageFile = "MMBHubLanguage.json",
    ConfigFile = "MMBHubConfigs.json",
    DiscordInvite = "https://discord.gg/xpbadexya",
    Developer = "36 AI | MMB Hub",
}

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local InsertService = game:GetService("InsertService")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// State & Feature Settings
local Config = {
    Aimbot = {
        Enabled = false,
        WallCheck = false,
        ShowFOV = false,
        Smoothness = 50,
        FOV = 220,
        Macro = false,
        AntiZoom = false,
    },
    Silent = {
        Enabled = false,
        UseFOV = true,
        MaxDistance = 350,
        TeamCheck = true,
        WallCheck = false,
        Part = "Head",
        HitChance = 100,
        FOV = 130,
    },
    Skeleton = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.5,
        HeadScale = 0.7,
    },
    BoxESP = {
        Enabled = false,
        HealthBar = false,
        Name = false,
    },
    DetectESP = {
        Enabled = false,
    },
    RainbowAll = false,
    CarESP = {
        Enabled = false,
        TargetNames = { "CheapCar", "Challenger", "Cayen", "208" },
        FillColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.75,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 0,
    },
    ChamsESP = {
        Enabled = false,
        FillColor = Color3.fromRGB(255, 60, 60),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 0,
        Opacity = 0.5,
    },
    RadarESP = {
        Enabled = false,
        Size = 160,
        Range = 350,
    },
    SelfESP = {
        Enabled = false,
    },
    TracerESP = {
        Enabled = false,
    },
    DistanceESP = {
        Enabled = false,
    },
    Misc = {
        FOVChanger = { Enabled = false, FOV = 120 },
        SpinCharacter = { Enabled = false, Speed = 720 },
        RainbowCar = { Enabled = false },
        ShiftBoost = { Enabled = false, Multiplier = 2 },
        Saturation = { Enabled = false, Value = 1.8 },
        StretchGame = { Enabled = false, Value = 0.67 },
        InfoView = { Enabled = false },
    },
    Skin = {
        Enabled = false,
        CurrentSkin = "tungtung",
        RainbowAK = false,
    },
}

local SkinsData = {
    tungtung = {
        name = "Tung Tung Sahur",
        modelId = 79680201739222,
        scale = 0.6,
        offsetY = -1,
    },
}

--// Colors & Constants
local COLOR_GREEN = Color3.fromRGB(80, 255, 80)
local COLOR_RED = Color3.fromRGB(255, 60, 60)
local COLOR_SOFT_RED = Color3.fromRGB(255, 80, 80)
local DEFAULT_FOV = 90
local MACRO_INTERVAL = 0.05

--// Localization
local currentLang = "en"
local Locales = {
    fr = {
        selectLanguage = "Sélectionnez votre langue",
        language = "Langue",
        continueBtn = "Continuer",
        french = "Français",
        english = "Anglais",
        tabESP = "ESP",
        tabAimbot = "Aimbot",
        tabMisc = "Divers",
        tabAutoFarm = "AutoFarm",
        tabSettings = "Paramètres",
        tabCredit = "Crédits",
        playerESP = "ESP JOUEURS",
        rainbowAll = "Arc-en-ciel",
        skeletonESP = "Squelette ESP",
        boxESP = "Boîte ESP",
        healthBar = "Barre de vie",
        playerName = "Nom du joueur",
        selfESP = "Self ESP",
        tracerESP = "Traceur ESP",
        detectionFX = "DÉTECTION & EFFETS",
        distanceESP = "Distance ESP",
        detectESP = "Détection ESP",
        carESP = "Voiture ESP",
        chamsESP = "Chams ESP",
        chamsOpacity = "Opacité Chams : ",
        radarESP = "Radar ESP",
        previewESP = "Aperçu ESP",
        previewESPTitle = "Aperçu ESP",
        aimbotSection = "AIMBOT",
        aimbotRMB = "Aimbot (RMB)",
        wallCheck = "Wall Check",
        showFOV = "Show FOV",
        macroRMB = "Macro (RMB)",
        antiZoom = "Anti Zoom",
        settingsSection = "SETTINGS",
        smoothAim = "Smooth Aim : ",
        fovSize = "FOV : ",
        silentSection = "SILENT AIM",
        silentAim = "Silent Aim",
        silentUseFOV = "Use FOV",
        silentTeamCheck = "Team Check",
        silentWallCheck = "Wall Check",
        silentMaxDist = "Max Distance : ",
        silentHitChance = "Hit Chance : ",
        silentFOV = "Silent FOV : ",
        partHead = "Head",
        partHRP = "HRP",
        partUpper = "UpperTorso",
        silentExpand = "Show advanced settings",
        silentCollapse = "Hide advanced settings",
        miscSection = "MISC",
        fovChanger = "FOV Changer",
        spinCharacter = "Spin Character",
        rainbowCar = "Rainbow Car",
        infoView = "Info View",
        effectsSection = "EFFECTS",
        shiftBoost = "Shift Boost Car",
        saturation = "Saturation",
        saturationValue = "Saturation : ",
        stretchGame = "Stretch Game",
        stretchValue = "Stretch : ",
        skinChanger = "Skin Changer",
        skinSection = "SKIN",
        skinSelect = "Select a skin",
        rainbowAK = "Rainbow AK",
        autoFarmSection = "AUTO FARM",
        rysForce = "RysForce",
        ready = "Ready",
        loadAutoFarm = "Load Auto Farm Script",
        loading = "Loading...",
        loaded = "Loaded ✓",
        errorRetry = "Error - retry",
        freeKeyFor = "free key for chrismath",
        keyCopied = "Key copied!",
        savedConfigs = "SAVED CONFIGS",
        configName = "Config name...",
        save = "Save",
        noConfigsSaved = "No configs saved yet",
        shareConfig = "SHARE CONFIG (JSON)",
        copyJson = "Copy current config JSON",
        pasteJson = "PASTE JSON TO LOAD",
        pasteJsonHere = "Paste JSON here...",
        loadFromJson = "Load from JSON",
        jsonCopied = "JSON copied!",
        invalidJson = "Invalid JSON",
        enterConfigName = "Enter a config name!",
        configLoaded = "Loaded",
        configSaved = "Saved",
        developer = "Developer",
        footer = "RMB = Aimbot   |   R-Shift = Menu   |   Shift = Boost",
        autoFarmLoaded = "Auto Farm loaded!",
        loadFailed = "Load failed: ",
        fovConflict = "Pls stop fov changer in misc",
        selectLanguageTitle = "Language Selection",
        selectLanguageDesc = "Choose your preferred language",
        loadingText = "LOADING",
        loadingSub = "Initializing...",
        injected = "Injected",
    },
    en = {
        selectLanguage = "Select your language",
        language = "Language",
        continueBtn = "Continue",
        french = "French",
        english = "English",
        tabESP = "ESP",
        tabAimbot = "Aimbot",
        tabMisc = "Misc",
        tabAutoFarm = "AutoFarm",
        tabSettings = "Settings",
        tabCredit = "Credits",
        playerESP = "PLAYER ESP",
        rainbowAll = "Rainbow All",
        skeletonESP = "Skeleton ESP",
        boxESP = "Box ESP",
        healthBar = "Health Bar",
        playerName = "Player Name",
        selfESP = "Self ESP",
        tracerESP = "Tracer ESP",
        detectionFX = "DETECTION & FX",
        distanceESP = "Distance ESP",
        detectESP = "Detect ESP",
        carESP = "Car ESP",
        chamsESP = "Chams ESP",
        chamsOpacity = "Chams Opacity : ",
        radarESP = "Radar ESP",
        previewESP = "Preview ESP",
        previewESPTitle = "ESP Preview",
        aimbotSection = "AIMBOT",
        aimbotRMB = "Aimbot (RMB)",
        wallCheck = "Wall Check",
        showFOV = "Show FOV",
        macroRMB = "Macro (RMB)",
        antiZoom = "Anti Zoom",
        settingsSection = "SETTINGS",
        smoothAim = "Smooth Aim : ",
        fovSize = "FOV : ",
        silentSection = "SILENT AIM",
        silentAim = "Silent Aim",
        silentUseFOV = "Use FOV",
        silentTeamCheck = "Team Check",
        silentWallCheck = "Wall Check",
        silentMaxDist = "Max Distance : ",
        silentHitChance = "Hit Chance : ",
        silentFOV = "Silent FOV : ",
        partHead = "Head",
        partHRP = "HRP",
        partUpper = "UpperTorso",
        silentExpand = "Show advanced settings",
        silentCollapse = "Hide advanced settings",
        miscSection = "MISC",
        fovChanger = "FOV Changer",
        spinCharacter = "Spin Character",
        rainbowCar = "Rainbow Car",
        infoView = "Info View",
        effectsSection = "EFFECTS",
        shiftBoost = "Shift Boost Car",
        saturation = "Saturation",
        saturationValue = "Saturation : ",
        stretchGame = "Stretch Game",
        stretchValue = "Stretch : ",
        skinChanger = "Skin Changer",
        skinSection = "SKIN",
        skinSelect = "Select a skin",
        rainbowAK = "Rainbow AK",
        autoFarmSection = "AUTO FARM",
        rysForce = "RysForce",
        ready = "Ready",
        loadAutoFarm = "Load Auto Farm Script",
        loading = "Loading...",
        loaded = "Loaded ✓",
        errorRetry = "Error - retry",
        freeKeyFor = "free key for chrismath",
        keyCopied = "Key copied!",
        savedConfigs = "SAVED CONFIGS",
        configName = "Config name...",
        save = "Save",
        noConfigsSaved = "No configs saved yet",
        shareConfig = "SHARE CONFIG (JSON)",
        copyJson = "Copy current config JSON",
        pasteJson = "PASTE JSON TO LOAD",
        pasteJsonHere = "Paste JSON here...",
        loadFromJson = "Load from JSON",
        jsonCopied = "JSON copied!",
        invalidJson = "Invalid JSON",
        enterConfigName = "Enter a config name!",
        configLoaded = "Loaded",
        configSaved = "Saved",
        developer = "Developer",
        footer = "RMB = Aimbot   |   R-Shift = Menu   |   Shift = Boost",
        autoFarmLoaded = "Auto Farm loaded!",
        loadFailed = "Load failed: ",
        fovConflict = "Pls stop fov changer in misc",
        selectLanguageTitle = "Language Selection",
        selectLanguageDesc = "Choose your preferred language",
        loadingText = "LOADING",
        loadingSub = "Initializing...",
        injected = "Injected",
    },
}

local function T(key)
    local langTable = Locales[currentLang] or Locales.en
    return langTable[key] or Locales.en[key] or key
end

local function saveLanguage()
    if writefile then
        pcall(function()
            writefile(MENU_CONFIG.LanguageFile, HttpService:JSONEncode({ language = currentLang }))
        end)
    end
end

local function loadLanguage()
    if isfile and readfile then
        local exists = false
        pcall(function() exists = isfile(MENU_CONFIG.LanguageFile) end)
        if exists then
            local ok, raw = pcall(readfile, MENU_CONFIG.LanguageFile)
            if ok and raw then
                local ok2, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok2 and type(decoded) == "table" and (decoded.language == "fr" or decoded.language == "en") then
                    currentLang = decoded.language
                    return true
                end
            end
        end
    end
    return false
end

--// Runtime Variables
local rmbAimbotHeld = false
local aimbotCamActive = false
local prevCameraType = nil
local aimLerpPos = nil

local espDrawings = {}
local visCache = {}
local VIS_CACHE_TTL = 0.1

local carESPObjects = {}
local carESPActive = false
local carDescAddedConn = nil
local carDescRemovingConn = nil

local fovSaved = true
local savedOriginalFOV = DEFAULT_FOV

local spinAngle = 0
local spinActive = false

local rainbowCarActive = false
local rainbowCarTarget = nil
local rainbowCarParts = {}
local rainbowCarOrigColors = {}
local rainbowCarConn = nil

local shiftBoostHeld = false
local boostCarModel = nil
local boostPrimaryPart = nil
local boostSeats = {}
local boostIdleSpeed = 0
local boostTargetSpeed = 0

local chamsHighlights = {}
local radarDots = {}
local radarWasEnabled = false
local radarClosing = false
local radarSlideOffset = 0

local rmbMacroHeld = false
local fovConflictWarned = false
local notifyFn = nil
local guiVisible = true
local stretchConn = nil

local skinModel = nil
local skinTrackConn = nil
local skinHideConn = nil
local activeSkinName = nil
local prevSkinEnabled = false

local rainbowAKConn = nil
local rainbowAKHue = 0
local rainbowAKCache = {}

local silentHooked = false
local origNamecall = nil

local savedConfigsStore = { configs = {} }

--// Executor Name & Stats
local executorName = "Unknown"
pcall(function()
    if identifyexecutor then
        local name = identifyexecutor()
        if name then executorName = tostring(name) end
    elseif getexecutorname then
        executorName = tostring(getexecutorname())
    end
end)

local fpsData = { frames = 0, accum = 0, fps = 60 }
local pingValue = 0
local pingAccum = 0

--// Saturation Effect
local saturationEffect = Lighting:FindFirstChild("MMBHubSaturation")
if not saturationEffect then
    saturationEffect = Instance.new("ColorCorrectionEffect")
    saturationEffect.Name = "MMBHubSaturation"
    saturationEffect.Parent = Lighting
end
saturationEffect.Saturation = Config.Misc.Saturation.Value
saturationEffect.Enabled = Config.Misc.Saturation.Enabled

--// Bone Definitions
local R15_BONES = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" },
}

local R6_BONES = {
    { "Head", "Torso" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" },
}

--// Weapon Names for Rainbow AK
local WEAPON_NAMES = {
    ak = true, ak47 = true, m4 = true, m4a1 = true, m60 = true,
    uzi = true, mp5 = true, spas12 = true, sawedoff = true,
    compact = true, cayen = true, brassknuckle = true,
}

--// Helper Functions
local function getRainbowColor()
    return Color3.fromHSV((os.clock() * 0.35) % 1, 1, 1)
end

local function isAlive(player)
    if not player or not player.Parent then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not char:FindFirstChild("Head") then return false end
    return true
end

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end
    return true
end

local function shouldDrawPlayer(player)
    if player == LocalPlayer then
        return Config.SelfESP.Enabled
    end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end
    return true
end

local function getSeatedCar()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil end
    local cur = hum.SeatPart
    while cur and cur ~= workspace do
        if cur:IsA("Model") then
            for _, targetName in ipairs(Config.CarESP.TargetNames) do
                if cur.Name == targetName then
                    return cur
                end
            end
        end
        cur = cur.Parent
    end
    return nil
end

--// Raycast Visibility
local visRayParams = RaycastParams.new()
visRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function checkPlayerVisible(player)
    if player == LocalPlayer then return true end
    local char = player.Character
    if not char then return false end
    local head = char:FindFirstChild("Head")
    if not head then return false end
    visRayParams.FilterDescendantsInstances = { LocalPlayer.Character }
    local origin = Camera.CFrame.Position
    local hit = workspace:Raycast(origin, head.Position - origin, visRayParams)
    if not hit then return true end
    return hit.Instance:IsDescendantOf(char)
end

local function isPlayerVisibleCached(player)
    local now = tick()
    local cached = visCache[player]
    if cached and (now - cached.t) < VIS_CACHE_TTL then
        return cached.v
    end
    local visible = checkPlayerVisible(player)
    visCache[player] = { v = visible, t = now }
    return visible
end

local function getESPColor(visible)
    if Config.RainbowAll then
        return getRainbowColor()
    end
    if Config.DetectESP.Enabled then
        return visible and COLOR_GREEN or COLOR_RED
    end
    return Config.Skeleton.Color
end

local function getTargetPart(char, partName)
    if not char then return nil end
    if partName == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart")
    elseif partName == "UpperTorso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    end
    return char:FindFirstChild("Head")
end

local function isPartVisible(part, targetChar)
    if not Config.Silent.WallCheck then return true end
    local ignoreList = { LocalPlayer.Character }
    if targetChar then
        table.insert(ignoreList, targetChar)
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    local origin = Camera.CFrame.Position
    return workspace:Raycast(origin, part.Position - origin, params) == nil
end

--// Silent Aim
local function getSilentTarget()
    if not Config.Silent.Enabled then return nil end
    local hitChance = Config.Silent.HitChance or 100
    if hitChance < 100 and math.random(1, 100) > hitChance then
        return nil
    end
    local bestDist = Config.Silent.UseFOV and Config.Silent.FOV or math.huge
    local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    local camPos = Camera.CFrame.Position
    local maxDist = Config.Silent.MaxDistance or 350
    local bestPart = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not (Config.Silent.TeamCheck and plr.Team and plr.Team == LocalPlayer.Team) then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if char and hum and hum.Health > 0 then
                    local part = getTargetPart(char, Config.Silent.Part or "Head")
                    if part and (part.Position - camPos).Magnitude <= maxDist then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen and screenPos.Z > 0 then
                            local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if (not Config.Silent.UseFOV or fovDist <= Config.Silent.FOV) and fovDist < bestDist then
                                if isPartVisible(part, char) then
                                    bestDist = fovDist
                                    bestPart = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

local function initSilentHook()
    if silentHooked then return true end
    if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
        return false
    end
    local ok = pcall(function()
        origNamecall = hookmetamethod(Camera, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if (method == "ViewportPointToRay" or method == "ScreenPointToRay") and self == Camera and Config.Silent.Enabled then
                local okT, targetPart = pcall(getSilentTarget)
                if okT and targetPart and targetPart.Parent then
                    local origin = Camera.CFrame.Position
                    return Ray.new(origin, (targetPart.Position - origin).Unit * 1000)
                end
            end
            return origNamecall(self, ...)
        end)
    end)
    if ok then
        silentHooked = true
        return true
    end
    return false
end

--// FOV Circle Drawing
local fovCircle = nil
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Thickness = 1.5
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Transparency = 0.55
    fovCircle.Visible = false
end)

--// Stretch Game
local function updateStretchGame()
    if Config.Misc.StretchGame.Enabled then
        if not stretchConn then
            stretchConn = RunService.RenderStepped:Connect(function()
                if not Config.Misc.StretchGame.Enabled then return end
                Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, Config.Misc.StretchGame.Value, 0, 0, 0, 1)
            end)
        end
    else
        if stretchConn then
            stretchConn:Disconnect()
            stretchConn = nil
        end
    end
end

--// Skin Changer
local function getPrimaryOrFirstPart(model)
    if model:IsA("BasePart") then return model end
    if model.PrimaryPart then return model.PrimaryPart end
    return model:FindFirstChildWhichIsA("BasePart", true)
end

local function clearSkin()
    if skinTrackConn then skinTrackConn:Disconnect(); skinTrackConn = nil end
    if skinHideConn then skinHideConn:Disconnect(); skinHideConn = nil end
    if skinModel and skinModel.Parent then
        pcall(function() skinModel:Destroy() end)
    end
    skinModel = nil
    activeSkinName = nil
    local char = LocalPlayer.Character
    if char then
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.LocalTransparencyModifier = 0
            elseif desc:IsA("Decal") or desc:IsA("Texture") then
                desc.Transparency = 0
            end
        end
    end
end

local function loadSkinAsset(modelId)
    local ok, objs = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(modelId))
    end)
    if ok and objs and #objs > 0 then
        local root = objs[1]
        for _, child in ipairs(root:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                return child
            end
        end
        return root
    end
    local ok2, asset = pcall(function()
        return InsertService:LoadAsset(modelId)
    end)
    if ok2 and asset then
        return asset
    end
    return nil
end

local function applySkin(skinKey)
    clearSkin()
    local info = SkinsData[skinKey]
    if not info then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.LocalTransparencyModifier = 1
        elseif desc:IsA("Decal") or desc:IsA("Texture") then
            desc.Transparency = 1
        end
    end

    skinHideConn = RunService.RenderStepped:Connect(function()
        if not char.Parent then
            if skinHideConn then skinHideConn:Disconnect(); skinHideConn = nil end
            return
        end
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BasePart") and desc.LocalTransparencyModifier < 1 then
                desc.LocalTransparencyModifier = 1
            end
        end
    end)

    local loaded = loadSkinAsset(info.modelId)
    if not loaded then return end
    if not loaded:IsA("Model") then
        local wrapper = Instance.new("Model")
        wrapper.Name = "LocalSkin"
        loaded.Parent = wrapper
        loaded = wrapper
    end
    loaded.Name = "LocalSkin_" .. LocalPlayer.Name
    loaded.Parent = workspace
    skinModel = loaded
    activeSkinName = skinKey

    local rootPart = getPrimaryOrFirstPart(loaded)
    if not rootPart then
        loaded:Destroy()
        skinModel = nil
        return
    end

    for _, desc in ipairs(loaded:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.CanCollide = false
            desc.CanQuery = false
            desc.CanTouch = false
            desc.Massless = true
            desc.Anchored = false
        end
    end

    local scale = info.scale or 1
    for _, desc in ipairs(loaded:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Size = desc.Size * scale
        end
    end

    for _, desc in ipairs(loaded:GetDescendants()) do
        if desc:IsA("BasePart") and desc ~= rootPart then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = rootPart
            weld.Part1 = desc
            weld.Parent = rootPart
        end
    end

    rootPart.Anchored = false
    local offsetY = info.offsetY or 0
    skinTrackConn = RunService.RenderStepped:Connect(function()
        if not rootPart or not rootPart.Parent or not hrp or not hrp.Parent then
            if skinTrackConn then skinTrackConn:Disconnect(); skinTrackConn = nil end
            return
        end
        rootPart.CFrame = hrp.CFrame * CFrame.new(0, offsetY, 0) * CFrame.Angles(0, math.rad(360), 0)
    end)

    hum.Died:Connect(function()
        clearSkin()
    end)
end

local function updateSkinState()
    if Config.Skin.Enabled then
        if activeSkinName ~= Config.Skin.CurrentSkin or not skinModel then
            applySkin(Config.Skin.CurrentSkin)
        end
    elseif skinModel or activeSkinName then
        clearSkin()
    end
end

--// Rainbow AK
local function isIgnoredWeaponPart(name)
    local lower = string.lower(name)
    return string.find(lower, "laser") ~= nil or string.find(lower, "light") ~= nil
end

local function collectWeaponParts(model)
    local parts = {}
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") and not isIgnoredWeaponPart(desc.Name) then
            table.insert(parts, desc)
            if desc:IsA("MeshPart") and desc.TextureID ~= "" then
                desc.TextureID = ""
            end
            for _, child in ipairs(desc:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    child:Destroy()
                end
            end
        end
    end
    return parts
end

local function stopRainbowAK()
    if rainbowAKConn then
        rainbowAKConn:Disconnect()
        rainbowAKConn = nil
    end
    rainbowAKCache = {}
end

local function startRainbowAK()
    if rainbowAKConn then return end
    task.spawn(function()
        local fxFolder = workspace:WaitForChild("FX", 10)
        if not fxFolder then return end
        rainbowAKConn = RunService.RenderStepped:Connect(function(dt)
            if not Config.Skin.RainbowAK then return end
            rainbowAKHue = (rainbowAKHue + dt * 0.5) % 1
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            for _, child in ipairs(fxFolder:GetChildren()) do
                if WEAPON_NAMES[string.lower(child.Name)] and child:IsA("Model") then
                    local handle = child:FindFirstChild("Handle") or child:FindFirstChild("Origin") or child.PrimaryPart
                    if handle and (hrp.Position - handle.Position).Magnitude < 7 then
                        if not rainbowAKCache[child] then
                            rainbowAKCache[child] = collectWeaponParts(child)
                        end
                        local parts = rainbowAKCache[child]
                        for idx, part in ipairs(parts) do
                            if part and part.Parent then
                                part.Color = Color3.fromHSV((rainbowAKHue + (idx / #parts) * 0.8) % 1, 1, 1)
                                part.Material = Enum.Material.SmoothPlastic
                            end
                        end
                    end
                end
            end

            for model, _ in pairs(rainbowAKCache) do
                local handle = model.Parent and (model:FindFirstChild("Handle") or model:FindFirstChild("Origin") or model.PrimaryPart)
                if not handle or (hrp.Position - handle.Position).Magnitude > 10 then
                    rainbowAKCache[model] = nil
                end
            end
        end)
    end)
end

local function updateRainbowAK()
    if Config.Skin.RainbowAK then
        startRainbowAK()
    else
        stopRainbowAK()
    end
end

--// Player ESP Cleanup & Creation
local function removePlayerESP(player)
    local data = espDrawings[player]
    if not data then return end
    for _, line in ipairs(data.lines) do pcall(function() line:Remove() end) end
    for _, line in ipairs(data.boxLines) do pcall(function() line:Remove() end) end
    if data.headCircle then pcall(function() data.headCircle:Remove() end) end
    if data.healthBarBack then pcall(function() data.healthBarBack:Remove() end) end
    if data.healthBarFill then pcall(function() data.healthBarFill:Remove() end) end
    if data.nameText then pcall(function() data.nameText:Remove() end) end
    if data.distText then pcall(function() data.distText:Remove() end) end
    if data.tracer then pcall(function() data.tracer:Remove() end) end
    espDrawings[player] = nil
end

local function hidePlayerESP(player)
    local data = espDrawings[player]
    if not data then return end
    for _, line in ipairs(data.lines) do line.Visible = false end
    for _, line in ipairs(data.boxLines) do line.Visible = false end
    if data.headCircle then data.headCircle.Visible = false end
    if data.healthBarBack then data.healthBarBack.Visible = false end
    if data.healthBarFill then data.healthBarFill.Visible = false end
    if data.nameText then data.nameText.Visible = false end
    if data.distText then data.distText.Visible = false end
    if data.tracer then data.tracer.Visible = false end
end

local function createPlayerESP(player, char)
    local bones = char:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
    local data = {
        bones = bones,
        lines = {},
        boxLines = {},
    }

    for i = 1, #bones do
        local line = Drawing.new("Line")
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = Config.Skeleton.Thickness
        line.Transparency = 1
        line.Visible = false
        data.lines[i] = line
    end

    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 1.2
        line.Transparency = 1
        line.Visible = false
        data.boxLines[i] = line
    end

    local headCircle = Drawing.new("Circle")
    headCircle.Color = Color3.fromRGB(255, 255, 255)
    headCircle.Thickness = 1.5
    headCircle.NumSides = 32
    headCircle.Radius = 10
    headCircle.Filled = false
    headCircle.Transparency = 1
    headCircle.Visible = false
    data.headCircle = headCircle

    local hbBack = Drawing.new("Line")
    hbBack.Thickness = 3
    hbBack.Transparency = 0.5
    hbBack.Color = Color3.fromRGB(0, 0, 0)
    hbBack.Visible = false
    data.healthBarBack = hbBack

    local hbFill = Drawing.new("Line")
    hbFill.Thickness = 2
    hbFill.Transparency = 1
    hbFill.Color = Color3.fromRGB(0, 255, 0)
    hbFill.Visible = false
    data.healthBarFill = hbFill

    local nameText = Drawing.new("Text")
    nameText.Size = 13
    nameText.Center = true
    nameText.Outline = true
    nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameText.Font = 2
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Visible = false
    data.nameText = nameText

    local distText = Drawing.new("Text")
    distText.Size = 12
    distText.Center = true
    distText.Outline = true
    distText.OutlineColor = Color3.fromRGB(0, 0, 0)
    distText.Font = 2
    distText.Color = Color3.fromRGB(200, 200, 200)
    distText.Visible = false
    data.distText = distText

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Transparency = 1
    tracer.Color = Color3.fromRGB(255, 255, 255)
    tracer.Visible = false
    data.tracer = tracer

    espDrawings[player] = data
end

local function updatePlayerESP(player, char)
    if not espDrawings[player] then
        createPlayerESP(player, char)
    end
    local data = espDrawings[player]
    local visible = isPlayerVisibleCached(player)
    local espColor = getESPColor(visible)

    -- Skeleton
    if Config.Skeleton.Enabled then
        for idx, bone in ipairs(data.bones) do
            local p1 = char:FindFirstChild(bone[1])
            local p2 = char:FindFirstChild(bone[2])
            local line = data.lines[idx]
            if p1 and p2 and line then
                local sp1, on1 = Camera:WorldToViewportPoint(p1.Position)
                local sp2, on2 = Camera:WorldToViewportPoint(p2.Position)
                if on1 and on2 and sp1.Z > 0 and sp2.Z > 0 then
                    line.From = Vector2.new(sp1.X, sp1.Y)
                    line.To = Vector2.new(sp2.X, sp2.Y)
                    line.Color = espColor
                    line.Visible = true
                else
                    line.Visible = false
                end
            elseif line then
                line.Visible = false
            end
        end

        local head = char:FindFirstChild("Head")
        if head then
            local topSP, onTop = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y / 2, 0))
            local botSP, onBot = Camera:WorldToViewportPoint(head.Position - Vector3.new(0, head.Size.Y / 2, 0))
            local midSP, onMid = Camera:WorldToViewportPoint(head.Position)
            if onTop and onBot and onMid and topSP.Z > 0 and botSP.Z > 0 and midSP.Z > 0 then
                data.headCircle.Position = Vector2.new(midSP.X, midSP.Y)
                data.headCircle.Radius = math.max((math.abs(topSP.Y - botSP.Y) / 2) * Config.Skeleton.HeadScale, 3)
                data.headCircle.Color = espColor
                data.headCircle.Visible = true
            else
                data.headCircle.Visible = false
            end
        else
            data.headCircle.Visible = false
        end
    else
        for _, line in ipairs(data.lines) do line.Visible = false end
        data.headCircle.Visible = false
    end

    -- Box / Health / Name / Distance / Tracer
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

    if root and head then
        local topPos = head.Position + Vector3.new(0, head.Size.Y / 2 + 0.5, 0)
        local botPos = root.Position - Vector3.new(0, 3, 0)
        local topSP, onTop = Camera:WorldToViewportPoint(topPos)
        local botSP, onBot = Camera:WorldToViewportPoint(botPos)

        if onTop and onBot and topSP.Z > 0 and botSP.Z > 0 then
            local boxH = math.abs(botSP.Y - topSP.Y)
            local boxW = boxH * 0.55
            local cx = (topSP.X + botSP.X) * 0.5
            local topY = math.min(topSP.Y, botSP.Y)
            local leftX = cx - boxW * 0.5
            local rightX = cx + boxW * 0.5
            local botY = topY + boxH

            if Config.BoxESP.Enabled then
                local b = data.boxLines
                b[1].From = Vector2.new(leftX, topY); b[1].To = Vector2.new(rightX, topY)
                b[2].From = Vector2.new(rightX, topY); b[2].To = Vector2.new(rightX, botY)
                b[3].From = Vector2.new(rightX, botY); b[3].To = Vector2.new(leftX, botY)
                b[4].From = Vector2.new(leftX, botY); b[4].To = Vector2.new(leftX, topY)
                for i = 1, 4 do
                    b[i].Color = espColor
                    b[i].Visible = true
                end
            else
                for i = 1, 4 do data.boxLines[i].Visible = false end
            end

            if Config.BoxESP.HealthBar and hum then
                local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                local barX = leftX - 6
                data.healthBarBack.From = Vector2.new(barX, topY)
                data.healthBarBack.To = Vector2.new(barX, botY)
                data.healthBarBack.Visible = true

                data.healthBarFill.From = Vector2.new(barX, botY)
                data.healthBarFill.To = Vector2.new(barX, botY - boxH * hpRatio)
                data.healthBarFill.Color = Color3.fromRGB(math.floor(255 * (1 - hpRatio)), math.floor(255 * hpRatio), 0)
                data.healthBarFill.Visible = true
            else
                data.healthBarBack.Visible = false
                data.healthBarFill.Visible = false
            end

            if Config.BoxESP.Name then
                data.nameText.Text = player.Name
                data.nameText.Position = Vector2.new(cx, topY - 16)
                data.nameText.Color = espColor
                data.nameText.Visible = true
            else
                data.nameText.Visible = false
            end

            if Config.DistanceESP.Enabled then
                local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                data.distText.Text = "[" .. tostring(dist) .. "m]"
                data.distText.Position = Vector2.new(cx, botY + 2)
                data.distText.Color = espColor
                data.distText.Visible = true
            else
                data.distText.Visible = false
            end

            if Config.TracerESP.Enabled then
                local vp = Camera.ViewportSize
                data.tracer.From = Vector2.new(vp.X * 0.5, vp.Y)
                data.tracer.To = Vector2.new(cx, botY)
                data.tracer.Color = espColor
                data.tracer.Visible = true
            else
                data.tracer.Visible = false
            end
        else
            for i = 1, 4 do data.boxLines[i].Visible = false end
            data.healthBarBack.Visible = false
            data.healthBarFill.Visible = false
            data.nameText.Visible = false
            data.distText.Visible = false
            data.tracer.Visible = false
        end
    end
end

--// Chams ESP
local function removeChams(player)
    if chamsHighlights[player] then
        pcall(function() chamsHighlights[player]:Destroy() end)
        chamsHighlights[player] = nil
    end
end

local function updateChams(player, char)
    if not Config.ChamsESP.Enabled or not char then
        removeChams(player)
        return
    end
    local hl = chamsHighlights[player]
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "MMBHubChams_" .. player.Name
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = Camera
        chamsHighlights[player] = hl
    end
    hl.Adornee = char
    if Config.RainbowAll then
        local c = getRainbowColor()
        hl.FillColor = c
        hl.OutlineColor = c
    else
        hl.FillColor = Config.ChamsESP.FillColor
        hl.OutlineColor = Config.ChamsESP.OutlineColor
    end
    hl.FillTransparency = 1 - Config.ChamsESP.Opacity
    hl.OutlineTransparency = Config.ChamsESP.OutlineTransparency
end

--// Car ESP
local function isTargetCar(obj)
    for _, name in ipairs(Config.CarESP.TargetNames) do
        if obj.Name == name then return true end
    end
    return false
end

local function isDescendantOfTargetCar(obj)
    local cur = obj.Parent
    while cur and cur ~= workspace do
        for _, name in ipairs(Config.CarESP.TargetNames) do
            if cur.Name == name then return true end
        end
        cur = cur.Parent
    end
    return false
end

local function addCarESP(obj)
    local hl = Instance.new("Highlight")
    hl.FillColor = Config.CarESP.FillColor
    hl.OutlineColor = Config.CarESP.OutlineColor
    hl.FillTransparency = Config.CarESP.FillTransparency
    hl.OutlineTransparency = Config.CarESP.OutlineTransparency
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = obj
    hl.Parent = obj

    local label = Drawing.new("Text")
    label.Size = 13
    label.Center = true
    label.Outline = true
    label.Color = Config.CarESP.OutlineColor
    label.OutlineColor = Color3.fromRGB(0, 0, 0)
    label.Font = 2
    label.Visible = false

    carESPObjects[obj] = { highlight = hl, label = label }
end

local function clearCarESP()
    for _, data in pairs(carESPObjects) do
        if data.highlight then pcall(function() data.highlight:Destroy() end) end
        if data.label then pcall(function() data.label:Remove() end) end
    end
    carESPObjects = {}
end

local function scanCars()
    for _, desc in ipairs(workspace:GetDescendants()) do
        if isTargetCar(desc) and (desc:IsA("BasePart") or desc:IsA("Model")) and not isDescendantOfTargetCar(desc) and not carESPObjects[desc] then
            addCarESP(desc)
        end
    end
end

local function toggleCarESP(enabled)
    if enabled == carESPActive then return end
    carESPActive = enabled
    if enabled then
        scanCars()
        carDescAddedConn = workspace.DescendantAdded:Connect(function(desc)
            if not Config.CarESP.Enabled then return end
            if isTargetCar(desc) and (desc:IsA("BasePart") or desc:IsA("Model")) then
                task.wait(0.05)
                if desc.Parent and not carESPObjects[desc] and not isDescendantOfTargetCar(desc) then
                    addCarESP(desc)
                end
            end
        end)
        carDescRemovingConn = workspace.DescendantRemoving:Connect(function(desc)
            local data = carESPObjects[desc]
            if data then
                if data.highlight then pcall(function() data.highlight:Destroy() end) end
                if data.label then pcall(function() data.label:Remove() end) end
                carESPObjects[desc] = nil
            end
        end)
    else
        if carDescAddedConn then carDescAddedConn:Disconnect(); carDescAddedConn = nil end
        if carDescRemovingConn then carDescRemovingConn:Disconnect(); carDescRemovingConn = nil end
        clearCarESP()
    end
end

local function updateCarESP()
    local rainbow = Config.RainbowAll and getRainbowColor() or nil
    for obj, data in pairs(carESPObjects) do
        if rainbow then
            if data.highlight then
                data.highlight.FillColor = rainbow
                data.highlight.OutlineColor = rainbow
            end
            if data.label then data.label.Color = rainbow end
        else
            if data.highlight then
                data.highlight.FillColor = Config.CarESP.FillColor
                data.highlight.OutlineColor = Config.CarESP.OutlineColor
            end
            if data.label then data.label.Color = Config.CarESP.OutlineColor end
        end

        if obj.Parent and data.label then
            local pos = nil
            if obj:IsA("BasePart") then
                pos = obj.Position + Vector3.new(0, obj.Size.Y / 2 + 1.5, 0)
            elseif obj:IsA("Model") then
                local ok, cf, size = pcall(function() return obj:GetBoundingBox() end)
                if ok and cf and size then
                    pos = cf.Position + Vector3.new(0, size.Y / 2 + 1.5, 0)
                end
            end
            if pos then
                local sp, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen and sp.Z > 0 then
                    data.label.Position = Vector2.new(sp.X, sp.Y)
                    data.label.Text = obj.Name
                    data.label.Visible = true
                else
                    data.label.Visible = false
                end
            else
                data.label.Visible = false
            end
        elseif data.label then
            data.label.Visible = false
        end
    end
end

--// Radar ESP Drawings
local radarBg, radarBorder, radarCenterDot, radarSweepLine
pcall(function()
    radarBg = Drawing.new("Circle")
    radarBg.NumSides = 64
    radarBg.Filled = true
    radarBg.Transparency = 0.75
    radarBg.Color = Color3.fromRGB(15, 15, 15)
    radarBg.Visible = false

    radarBorder = Drawing.new("Circle")
    radarBorder.NumSides = 64
    radarBorder.Filled = false
    radarBorder.Thickness = 1.5
    radarBorder.Transparency = 0.9
    radarBorder.Color = Color3.fromRGB(80, 80, 80)
    radarBorder.Visible = false

    radarCenterDot = Drawing.new("Circle")
    radarCenterDot.NumSides = 12
    radarCenterDot.Filled = true
    radarCenterDot.Radius = 3
    radarCenterDot.Color = Color3.fromRGB(80, 255, 80)
    radarCenterDot.Visible = false

    radarSweepLine = Drawing.new("Line")
    radarSweepLine.Thickness = 1.2
    radarSweepLine.Transparency = 0.5
    radarSweepLine.Color = Color3.fromRGB(255, 255, 255)
    radarSweepLine.Visible = false
end)

local function updateRadarESP()
    if not radarBg then return end
    if Config.RadarESP.Enabled ~= radarWasEnabled then
        if not Config.RadarESP.Enabled then
            radarClosing = true
            radarSlideOffset = 0
        else
            radarClosing = false
            radarSlideOffset = 0
        end
        radarWasEnabled = Config.RadarESP.Enabled
    end

    local vp = Camera.ViewportSize
    local size = Config.RadarESP.Size
    local radius = size / 2

    if not Config.RadarESP.Enabled then
        if radarClosing then
            radarSlideOffset = radarSlideOffset + (200 - radarSlideOffset) * 0.15
            local alpha = math.clamp(1 - math.abs(radarSlideOffset) / 200, 0, 1)
            if alpha <= 0.01 or math.abs(radarSlideOffset) > 190 then
                radarClosing = false
                radarBg.Visible = false
                radarBorder.Visible = false
                radarCenterDot.Visible = false
                radarSweepLine.Visible = false
                for _, dot in pairs(radarDots) do dot.Visible = false end
                return
            end
            local cx = vp.X - radius - 20
            local cy = vp.Y - radius - 20 + radarSlideOffset
            radarBg.Position = Vector2.new(cx, cy); radarBg.Radius = radius; radarBg.Transparency = 0.75 * alpha; radarBg.Visible = true
            radarBorder.Position = Vector2.new(cx, cy); radarBorder.Radius = radius; radarBorder.Transparency = 0.9 * alpha; radarBorder.Visible = true
            radarCenterDot.Position = Vector2.new(cx, cy); radarCenterDot.Transparency = alpha; radarCenterDot.Visible = true
            radarSweepLine.Visible = false
            for _, dot in pairs(radarDots) do dot.Visible = false end
            return
        end
        radarBg.Visible = false
        radarBorder.Visible = false
        radarCenterDot.Visible = false
        radarSweepLine.Visible = false
        for _, dot in pairs(radarDots) do dot.Visible = false end
        return
    end

    local cx = vp.X - radius - 20
    local cy = vp.Y - radius - 20
    radarBg.Position = Vector2.new(cx, cy); radarBg.Radius = radius; radarBg.Transparency = 0.75; radarBg.Visible = true
    radarBorder.Position = Vector2.new(cx, cy); radarBorder.Radius = radius; radarBorder.Transparency = 0.9; radarBorder.Visible = true
    radarCenterDot.Position = Vector2.new(cx, cy); radarCenterDot.Transparency = 1; radarCenterDot.Visible = true

    local angle = (os.clock() * 2) % (math.pi * 2)
    radarSweepLine.From = Vector2.new(cx, cy)
    radarSweepLine.To = Vector2.new(cx + math.cos(angle) * radius, cy + math.sin(angle) * radius)
    radarSweepLine.Visible = true

    local myChar = LocalPlayer.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso"))
    if not myRoot then
        for _, dot in pairs(radarDots) do dot.Visible = false end
        return
    end

    local myPos = myRoot.Position
    local look = myRoot.CFrame.LookVector
    local lookAngle = math.atan2(look.X, look.Z)
    local activePlayers = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and isAlive(plr) then
            local pChar = plr.Character
            local pRoot = pChar and (pChar:FindFirstChild("HumanoidRootPart") or pChar:FindFirstChild("Torso") or pChar:FindFirstChild("UpperTorso"))
            if pRoot then
                local delta = pRoot.Position - myPos
                local flatDist = Vector3.new(delta.X, 0, delta.Z).Magnitude
                if flatDist <= Config.RadarESP.Range then
                    local relAngle = math.atan2(delta.X, delta.Z) - lookAngle
                    local dot = radarDots[plr]
                    if not dot then
                        dot = Drawing.new("Circle")
                        dot.NumSides = 12
                        dot.Filled = true
                        dot.Radius = 3
                        dot.Color = COLOR_SOFT_RED
                        radarDots[plr] = dot
                    end
                    local scale = (flatDist / Config.RadarESP.Range) * radius
                    dot.Position = Vector2.new(cx + math.sin(relAngle) * scale, cy - math.cos(relAngle) * scale)
                    if Config.RainbowAll then
                        dot.Color = getRainbowColor()
                    else
                        dot.Color = isPlayerVisibleCached(plr) and COLOR_SOFT_RED or Color3.fromRGB(180, 40, 40)
                    end
                    dot.Visible = true
                    activePlayers[plr] = true
                end
            end
        end
    end

    for plr, dot in pairs(radarDots) do
        if not activePlayers[plr] then
            dot.Visible = false
        end
    end
end

--// Rainbow Car
local function stopRainbowCar()
    if not rainbowCarActive then return end
    rainbowCarActive = false
    if rainbowCarConn then
        rainbowCarConn:Disconnect()
        rainbowCarConn = nil
    end
    for idx, part in ipairs(rainbowCarParts) do
        if part and part.Parent and rainbowCarOrigColors[idx] then
            part.Color = rainbowCarOrigColors[idx]
        end
    end
    rainbowCarParts = {}
    rainbowCarOrigColors = {}
    rainbowCarTarget = nil
end

local function collectCarParts(model, out)
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(out, child)
        end
        if #child:GetChildren() > 0 then
            collectCarParts(child, out)
        end
    end
end

local function startRainbowCar(car)
    if rainbowCarActive then return end
    rainbowCarActive = true
    rainbowCarTarget = car
    rainbowCarParts = {}
    rainbowCarOrigColors = {}
    collectCarParts(car, rainbowCarParts)
    for idx, part in ipairs(rainbowCarParts) do
        rainbowCarOrigColors[idx] = part.Color
    end
    rainbowCarConn = RunService.RenderStepped:Connect(function()
        if not rainbowCarTarget or not rainbowCarTarget.Parent then
            stopRainbowCar()
            return
        end
        local col = Color3.fromHSV((os.clock() * 0.5) % 1, 1, 1)
        for _, part in ipairs(rainbowCarParts) do
            if part and part.Parent then
                part.Color = col
            end
        end
    end)
end

local function updateRainbowCar()
    if not Config.Misc.RainbowCar.Enabled then
        if rainbowCarActive then stopRainbowCar() end
        return
    end
    local car = getSeatedCar()
    if car then
        if rainbowCarTarget ~= car then
            stopRainbowCar()
            startRainbowCar(car)
        end
    elseif rainbowCarActive then
        stopRainbowCar()
    end
end

--// Shift Boost Car
local function applySeatBoost(active)
    for _, entry in ipairs(boostSeats) do
        if entry.seat and entry.seat.Parent then
            entry.seat.MaxSpeed = active and (entry.maxSpeed * Config.Misc.ShiftBoost.Multiplier) or entry.maxSpeed
            entry.seat.Torque = active and (entry.torque * Config.Misc.ShiftBoost.Multiplier) or entry.torque
        end
    end
end

local function clearShiftBoost()
    applySeatBoost(false)
    boostSeats = {}
    boostIdleSpeed = 0
    boostTargetSpeed = 0
    boostCarModel = nil
    boostPrimaryPart = nil
end

local function setupBoostCar(car)
    clearShiftBoost()
    boostCarModel = car
    boostPrimaryPart = car.PrimaryPart
    if not boostPrimaryPart then
        for _, desc in ipairs(car:GetDescendants()) do
            if desc:IsA("BasePart") then
                boostPrimaryPart = desc
                break
            end
        end
    end
    boostSeats = {}
    for _, desc in ipairs(car:GetDescendants()) do
        if desc:IsA("VehicleSeat") then
            table.insert(boostSeats, {
                seat = desc,
                maxSpeed = desc.MaxSpeed,
                torque = desc.Torque,
            })
        end
    end
end

local function updateShiftBoost(dt)
    if not Config.Misc.ShiftBoost.Enabled then
        if boostCarModel or boostTargetSpeed > 0 or #boostSeats > 0 then
            shiftBoostHeld = false
            clearShiftBoost()
        end
        return
    end

    local car = getSeatedCar()
    if car ~= boostCarModel then
        clearShiftBoost()
        if car then setupBoostCar(car) end
    end

    if not boostPrimaryPart or not boostPrimaryPart.Parent then return end

    if not shiftBoostHeld then
        local vel = boostPrimaryPart.AssemblyLinearVelocity
        boostIdleSpeed = math.max(boostIdleSpeed * (1 - dt * 0.2), Vector3.new(vel.X, 0, vel.Z).Magnitude)
        return
    end

    if boostTargetSpeed <= 0 then
        local vel = boostPrimaryPart.AssemblyLinearVelocity
        boostTargetSpeed = math.max(boostIdleSpeed, Vector3.new(vel.X, 0, vel.Z).Magnitude, 5)
        applySeatBoost(true)
    end

    local vel = boostPrimaryPart.AssemblyLinearVelocity
    local flatVel = Vector3.new(vel.X, 0, vel.Z)
    local curSpeed = flatVel.Magnitude
    local desiredSpeed = boostTargetSpeed * Config.Misc.ShiftBoost.Multiplier
    if curSpeed < desiredSpeed then
        local dir = (curSpeed > 0.5) and flatVel.Unit or boostPrimaryPart.CFrame.LookVector
        local add = math.min((desiredSpeed - curSpeed) * dt * 4, desiredSpeed - curSpeed)
        boostPrimaryPart.AssemblyLinearVelocity = Vector3.new(vel.X + dir.X * add, vel.Y, vel.Z + dir.Z * add)
    end
end

--// AntiZoom & Macro
local function enforceAntiZoom()
    if not Config.Aimbot.AntiZoom or Config.Misc.FOVChanger.Enabled then return end
    if Camera and Camera.FieldOfView ~= DEFAULT_FOV then
        Camera.FieldOfView = DEFAULT_FOV
    end
end
RunService.RenderStepped:Connect(enforceAntiZoom)
Camera:GetPropertyChangedSignal("FieldOfView"):Connect(enforceAntiZoom)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbMacroHeld = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbMacroHeld = false
    end
end)

RunService.Heartbeat:Connect(function()
    if not Config.Aimbot.Macro or not rmbMacroHeld then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Tool") then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
    task.wait(MACRO_INTERVAL)
end)

--// Aimbot (RMB)
local function getAimbotTarget()
    local center = Camera.ViewportSize * 0.5
    local bestDist = Config.Aimbot.FOV
    local bestPlr = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and isAlive(plr) then
            if not Config.Aimbot.WallCheck or isPlayerVisibleCached(plr) then
                local head = plr.Character.Head
                local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and sp.Z > 0 then
                    local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPlr = plr
                    end
                end
            end
        end
    end
    return bestPlr
end

local function restoreAimbotCamera()
    if aimbotCamActive then
        aimbotCamActive = false
        Camera.CameraType = prevCameraType or Enum.CameraType.Custom
    end
end

local function lockAimbotCamera()
    if not aimbotCamActive then
        prevCameraType = Camera.CameraType
        aimbotCamActive = true
    end
    if Camera.CameraType ~= Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Scriptable
    end
end

RunService:BindToRenderStep("MMBHubAim", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not (Config.Aimbot.Enabled and rmbAimbotHeld) then
        restoreAimbotCamera()
        return
    end
    local target = getAimbotTarget()
    if not target then
        restoreAimbotCamera()
        return
    end
    lockAimbotCamera()
    local targetPos = target.Character.Head.Position
    if not aimLerpPos or (aimLerpPos - targetPos).Magnitude > 30 then
        aimLerpPos = targetPos
    else
        local alpha = math.clamp(((1 - math.clamp(Config.Aimbot.Smoothness / 100, 0, 1)) * 30 + 0.3) * dt, 0.001, 1)
        aimLerpPos = aimLerpPos:Lerp(targetPos, alpha)
    end
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, aimLerpPos)
end)

--// Config Save / Load / Export
local function serializeConfig()
    return {
        Aimbot = {
            Enabled = Config.Aimbot.Enabled,
            WallCheck = Config.Aimbot.WallCheck,
            ShowFOV = Config.Aimbot.ShowFOV,
            Smoothness = Config.Aimbot.Smoothness,
            FOV = Config.Aimbot.FOV,
            Macro = Config.Aimbot.Macro,
            AntiZoom = Config.Aimbot.AntiZoom,
        },
        Silent = {
            Enabled = Config.Silent.Enabled,
            UseFOV = Config.Silent.UseFOV,
            MaxDistance = Config.Silent.MaxDistance,
            TeamCheck = Config.Silent.TeamCheck,
            WallCheck = Config.Silent.WallCheck,
            Part = Config.Silent.Part,
            HitChance = Config.Silent.HitChance,
            FOV = Config.Silent.FOV,
        },
        Skeleton = { Enabled = Config.Skeleton.Enabled },
        BoxESP = {
            Enabled = Config.BoxESP.Enabled,
            HealthBar = Config.BoxESP.HealthBar,
            Name = Config.BoxESP.Name,
        },
        DetectESP = { Enabled = Config.DetectESP.Enabled },
        RainbowAll = Config.RainbowAll,
        CarESP = { Enabled = Config.CarESP.Enabled },
        ChamsESP = { Enabled = Config.ChamsESP.Enabled, Opacity = Config.ChamsESP.Opacity },
        RadarESP = { Enabled = Config.RadarESP.Enabled },
        SelfESP = { Enabled = Config.SelfESP.Enabled },
        TracerESP = { Enabled = Config.TracerESP.Enabled },
        DistanceESP = { Enabled = Config.DistanceESP.Enabled },
        Skin = {
            Enabled = Config.Skin.Enabled,
            CurrentSkin = Config.Skin.CurrentSkin,
            RainbowAK = Config.Skin.RainbowAK,
        },
        Misc = {
            FOVChanger = { Enabled = Config.Misc.FOVChanger.Enabled, FOV = Config.Misc.FOVChanger.FOV },
            SpinCharacter = { Enabled = Config.Misc.SpinCharacter.Enabled, Speed = Config.Misc.SpinCharacter.Speed },
            RainbowCar = { Enabled = Config.Misc.RainbowCar.Enabled },
            ShiftBoost = { Enabled = Config.Misc.ShiftBoost.Enabled, Multiplier = Config.Misc.ShiftBoost.Multiplier },
            Saturation = { Enabled = Config.Misc.Saturation.Enabled, Value = Config.Misc.Saturation.Value },
            StretchGame = { Enabled = Config.Misc.StretchGame.Enabled, Value = Config.Misc.StretchGame.Value },
            InfoView = { Enabled = Config.Misc.InfoView.Enabled },
        },
    }
end

local function applyConfigData(data)
    if type(data) ~= "table" then return false end
    local function setBool(src, key, dst)
        if type(src[key]) == "boolean" then dst[key] = src[key] end
    end
    local function setNum(src, key, dst)
        if type(src[key]) == "number" then dst[key] = src[key] end
    end

    if type(data.Aimbot) == "table" then
        setBool(data.Aimbot, "Enabled", Config.Aimbot)
        setBool(data.Aimbot, "WallCheck", Config.Aimbot)
        setBool(data.Aimbot, "ShowFOV", Config.Aimbot)
        setBool(data.Aimbot, "Macro", Config.Aimbot)
        setBool(data.Aimbot, "AntiZoom", Config.Aimbot)
        setNum(data.Aimbot, "Smoothness", Config.Aimbot)
        setNum(data.Aimbot, "FOV", Config.Aimbot)
    end
    if type(data.Silent) == "table" then
        setBool(data.Silent, "Enabled", Config.Silent)
        setBool(data.Silent, "UseFOV", Config.Silent)
        setBool(data.Silent, "TeamCheck", Config.Silent)
        setBool(data.Silent, "WallCheck", Config.Silent)
        setNum(data.Silent, "MaxDistance", Config.Silent)
        setNum(data.Silent, "HitChance", Config.Silent)
        setNum(data.Silent, "FOV", Config.Silent)
        if type(data.Silent.Part) == "string" then
            Config.Silent.Part = data.Silent.Part
        end
    end
    if type(data.Skeleton) == "table" then setBool(data.Skeleton, "Enabled", Config.Skeleton) end
    if type(data.BoxESP) == "table" then
        setBool(data.BoxESP, "Enabled", Config.BoxESP)
        setBool(data.BoxESP, "HealthBar", Config.BoxESP)
        setBool(data.BoxESP, "Name", Config.BoxESP)
    end
    if type(data.DetectESP) == "table" then setBool(data.DetectESP, "Enabled", Config.DetectESP) end
    if type(data.RainbowAll) == "boolean" then Config.RainbowAll = data.RainbowAll end
    if type(data.CarESP) == "table" then setBool(data.CarESP, "Enabled", Config.CarESP) end
    if type(data.ChamsESP) == "table" then
        setBool(data.ChamsESP, "Enabled", Config.ChamsESP)
        setNum(data.ChamsESP, "Opacity", Config.ChamsESP)
    end
    if type(data.RadarESP) == "table" then setBool(data.RadarESP, "Enabled", Config.RadarESP) end
    if type(data.SelfESP) == "table" then setBool(data.SelfESP, "Enabled", Config.SelfESP) end
    if type(data.TracerESP) == "table" then setBool(data.TracerESP, "Enabled", Config.TracerESP) end
    if type(data.DistanceESP) == "table" then setBool(data.DistanceESP, "Enabled", Config.DistanceESP) end
    if type(data.Skin) == "table" then
        setBool(data.Skin, "Enabled", Config.Skin)
        setBool(data.Skin, "RainbowAK", Config.Skin)
        if type(data.Skin.CurrentSkin) == "string" and SkinsData[data.Skin.CurrentSkin] then
            Config.Skin.CurrentSkin = data.Skin.CurrentSkin
        end
    end
    if type(data.Misc) == "table" then
        local m = data.Misc
        if type(m.FOVChanger) == "table" then setBool(m.FOVChanger, "Enabled", Config.Misc.FOVChanger); setNum(m.FOVChanger, "FOV", Config.Misc.FOVChanger) end
        if type(m.SpinCharacter) == "table" then setBool(m.SpinCharacter, "Enabled", Config.Misc.SpinCharacter); setNum(m.SpinCharacter, "Speed", Config.Misc.SpinCharacter) end
        if type(m.RainbowCar) == "table" then setBool(m.RainbowCar, "Enabled", Config.Misc.RainbowCar) end
        if type(m.ShiftBoost) == "table" then setBool(m.ShiftBoost, "Enabled", Config.Misc.ShiftBoost); setNum(m.ShiftBoost, "Multiplier", Config.Misc.ShiftBoost) end
        if type(m.Saturation) == "table" then setBool(m.Saturation, "Enabled", Config.Misc.Saturation); setNum(m.Saturation, "Value", Config.Misc.Saturation) end
        if type(m.StretchGame) == "table" then setBool(m.StretchGame, "Enabled", Config.Misc.StretchGame); setNum(m.StretchGame, "Value", Config.Misc.StretchGame) end
        if type(m.InfoView) == "table" then setBool(m.InfoView, "Enabled", Config.Misc.InfoView) end
    end
    return true
end

local function saveConfigsToDisk()
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(savedConfigsStore.configs)
    end)
    if not ok then return false end
    if writefile then
        pcall(writefile, MENU_CONFIG.ConfigFile, encoded)
        return true
    end
    return false
end

local function loadConfigsFromDisk()
    if isfile and readfile then
        local exists = false
        pcall(function() exists = isfile(MENU_CONFIG.ConfigFile) end)
        if exists then
            local ok, raw = pcall(readfile, MENU_CONFIG.ConfigFile)
            if ok and raw then
                local ok2, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok2 and type(decoded) == "table" then
                    savedConfigsStore.configs = decoded
                end
            end
        end
    end
end
loadConfigsFromDisk()

--// Snow Effect
local snowGui, snowConn, snowFlakes = nil, nil, {}

local function stopSnow()
    if snowConn then snowConn:Disconnect(); snowConn = nil end
    for _, item in ipairs(snowFlakes) do
        if item.frame then item.frame:Destroy() end
    end
    snowFlakes = {}
    if snowGui then snowGui:Destroy(); snowGui = nil end
end

local function startSnow()
    if snowGui then return end
    snowGui = Instance.new("ScreenGui")
    snowGui.Name = "MMBHubSnow"
    snowGui.ResetOnSpawn = false
    snowGui.IgnoreGuiInset = true
    snowGui.DisplayOrder = -1
    if not pcall(function() snowGui.Parent = game:GetService("CoreGui") end) then
        snowGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    snowFlakes = {}
    snowConn = RunService.RenderStepped:Connect(function(dt)
        local vp = workspace.CurrentCamera.ViewportSize
        if math.random() < 0.15 then
            local sz = math.random(2, 5)
            local flake = Instance.new("Frame")
            flake.Size = UDim2.new(0, sz, 0, sz)
            flake.Position = UDim2.new(math.random(), 0, -0.05, 0)
            flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            flake.BackgroundTransparency = math.random(20, 60) / 100
            flake.BorderSizePixel = 0
            flake.ZIndex = 1
            local corner = Instance.new("UICorner", flake)
            corner.CornerRadius = UDim.new(1, 0)
            flake.Parent = snowGui
            table.insert(snowFlakes, {
                frame = flake,
                speedX = (math.random() - 0.5) * 30,
                speedY = math.random(100, 250),
                sway = math.random() * math.pi * 2,
                swaySpeed = math.random(1, 3),
            })
        end
        for i = #snowFlakes, 1, -1 do
            local item = snowFlakes[i]
            if not item.frame or not item.frame.Parent then
                table.remove(snowFlakes, i)
            else
                item.sway = item.sway + item.swaySpeed * dt
                local pos = item.frame.Position
                local nextY = pos.Y.Offset + item.speedY * dt
                item.frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + (item.speedX + math.sin(item.sway) * 15) * dt, pos.Y.Scale, nextY)
                if nextY > vp.Y + 20 then
                    item.frame:Destroy()
                    table.remove(snowFlakes, i)
                end
            end
        end
    end)
end

--// Loading Screen
local function showLoadingScreen(onComplete)
    local loadGui = Instance.new("ScreenGui")
    loadGui.Name = "MMBHubLoading"
    loadGui.ResetOnSpawn = false
    loadGui.IgnoreGuiInset = true
    loadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() loadGui.Parent = game:GetService("CoreGui") end) then
        loadGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local backdrop = Instance.new("Frame")
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.35
    backdrop.BorderSizePixel = 0
    backdrop.Parent = loadGui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 280, 0, 120)
    card.Position = UDim2.new(0.5, -140, 0.5, -40)
    card.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.Parent = loadGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(55, 55, 55)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 44, 0, 44)
    logo.Position = UDim2.new(0, 16, 0, 16)
    logo.BackgroundTransparency = 1
    logo.Image = MENU_CONFIG.LogoId
    logo.ScaleType = Enum.ScaleType.Crop
    logo.Parent = card
    Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 0, 20)
    title.Position = UDim2.new(0, 68, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = MENU_CONFIG.ShortTitle
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -80, 0, 16)
    sub.Position = UDim2.new(0, 68, 0, 38)
    sub.BackgroundTransparency = 1
    sub.Text = T("loadingSub")
    sub.TextColor3 = Color3.fromRGB(150, 150, 150)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = card

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -32, 0, 4)
    barBg.Position = UDim2.new(0, 16, 1, -22)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    barBg.BorderSizePixel = 0
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = MENU_CONFIG.AccentColor
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    local pctLabel = Instance.new("TextLabel")
    pctLabel.Size = UDim2.new(0, 40, 0, 14)
    pctLabel.Position = UDim2.new(1, -50, 1, -40)
    pctLabel.BackgroundTransparency = 1
    pctLabel.Text = "0%"
    pctLabel.TextColor3 = MENU_CONFIG.AccentColor
    pctLabel.Font = Enum.Font.GothamBold
    pctLabel.TextSize = 10
    pctLabel.TextXAlignment = Enum.TextXAlignment.Right
    pctLabel.Parent = card

    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -140, 0.5, -60),
        BackgroundTransparency = 0,
    }):Play()

    local pct = 0
    local steps = {
        { target = 25, delay = 0.15, text = "Loading modules..." },
        { target = 50, delay = 0.2,  text = "Injecting..." },
        { target = 75, delay = 0.25, text = "Preparing UI..." },
        { target = 100, delay = 0.3, text = T("injected") },
    }

    task.spawn(function()
        for _, step in ipairs(steps) do
            task.wait(step.delay)
            sub.Text = step.text
            while pct < step.target do
                task.wait(0.015)
                pct = math.min(pct + 2, step.target)
                barFill.Size = UDim2.new(pct / 100, 0, 1, 0)
                pctLabel.Text = math.floor(pct) .. "%"
            end
        end
        task.wait(0.2)
        TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -140, 0.5, -40),
            BackgroundTransparency = 1,
        }):Play()
        task.wait(0.35)
        loadGui:Destroy()
        if onComplete then onComplete() end
    end)
end

--// Forward Declare buildGUI
local buildGUI

--// Language Selector
local function showLanguageSelector()
    local langGui = Instance.new("ScreenGui")
    langGui.Name = "MMBHubLangSelector"
    langGui.ResetOnSpawn = false
    langGui.IgnoreGuiInset = true
    langGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() langGui.Parent = game:GetService("CoreGui") end) then
        langGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local dim = Instance.new("Frame")
    dim.Size = UDim2.new(1, 0, 1, 0)
    dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dim.BackgroundTransparency = 0.5
    dim.BorderSizePixel = 0
    dim.Parent = langGui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 320, 0, 320)
    card.Position = UDim2.new(0.5, -160, 0.5, -110)
    card.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.Parent = langGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(55, 55, 55)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 110, 0, 110)
    logo.Position = UDim2.new(0.5, -55, 0, 18)
    logo.BackgroundTransparency = 1
    logo.Image = MENU_CONFIG.LogoId
    logo.ScaleType = Enum.ScaleType.Crop
    logo.Parent = card
    Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 24)
    title.Position = UDim2.new(0, 0, 0, 138)
    title.BackgroundTransparency = 1
    title.Text = MENU_CONFIG.ShortTitle
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, 0, 0, 16)
    desc.Position = UDim2.new(0, 0, 0, 163)
    desc.BackgroundTransparency = 1
    desc.Text = T("selectLanguage")
    desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    desc.Font = Enum.Font.GothamMedium
    desc.TextSize = 12
    desc.Parent = card

    local btnHolder = Instance.new("Frame")
    btnHolder.Size = UDim2.new(1, -40, 0, 80)
    btnHolder.Position = UDim2.new(0, 20, 0, 190)
    btnHolder.BackgroundTransparency = 1
    btnHolder.Parent = card

    local chosen = currentLang

    local function makeLangBtn(posX, flagId, labelText, code)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, -5, 1, 0)
        btn.Position = UDim2.new(posX, posX == 0 and 0 or 5, 0, 0)
        btn.BackgroundColor3 = (chosen == code) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(18, 18, 18)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Parent = btnHolder
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        local st = Instance.new("UIStroke", btn)
        st.Color = (chosen == code) and MENU_CONFIG.AccentColor or Color3.fromRGB(55, 55, 55)
        st.Thickness = (chosen == code) and 1.5 or 1
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local flag = Instance.new("ImageLabel")
        flag.Size = UDim2.new(0, 32, 0, 24)
        flag.Position = UDim2.new(0.5, -16, 0, 12)
        flag.BackgroundTransparency = 1
        flag.Image = "rbxassetid://" .. flagId
        flag.ScaleType = Enum.ScaleType.Fit
        flag.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.Position = UDim2.new(0, 0, 0, 42)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = (chosen == code) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.Parent = btn

        return btn, st, lbl
    end

    local frBtn, frStroke, frLbl = makeLangBtn(0, "6103768192", "Français", "fr")
    local enBtn, enStroke, enLbl = makeLangBtn(0.5, "4530542408", "English", "en")

    local function refreshLangBtns()
        frBtn.BackgroundColor3 = (chosen == "fr") and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(18, 18, 18)
        frLbl.TextColor3 = (chosen == "fr") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
        frStroke.Color = (chosen == "fr") and MENU_CONFIG.AccentColor or Color3.fromRGB(55, 55, 55)
        frStroke.Thickness = (chosen == "fr") and 1.5 or 1

        enBtn.BackgroundColor3 = (chosen == "en") and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(18, 18, 18)
        enLbl.TextColor3 = (chosen == "en") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
        enStroke.Color = (chosen == "en") and MENU_CONFIG.AccentColor or Color3.fromRGB(55, 55, 55)
        enStroke.Thickness = (chosen == "en") and 1.5 or 1
    end

    frBtn.MouseButton1Click:Connect(function() chosen = "fr"; refreshLangBtns() end)
    enBtn.MouseButton1Click:Connect(function() chosen = "en"; refreshLangBtns() end)

    local contBtn = Instance.new("TextButton")
    contBtn.Size = UDim2.new(1, -40, 0, 36)
    contBtn.Position = UDim2.new(0, 20, 1, -50)
    contBtn.BackgroundColor3 = MENU_CONFIG.AccentColor
    contBtn.BorderSizePixel = 0
    contBtn.Text = T("continueBtn")
    contBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    contBtn.Font = Enum.Font.GothamBold
    contBtn.TextSize = 14
    contBtn.Parent = card
    Instance.new("UICorner", contBtn).CornerRadius = UDim.new(0, 8)

    local clicked = false
    contBtn.MouseButton1Click:Connect(function()
        if clicked then return end
        clicked = true
        currentLang = chosen
        saveLanguage()
        langGui:Destroy()
        showLoadingScreen(function()
            buildGUI()
        end)
    end)

    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0.5, -160),
        BackgroundTransparency = 0,
    }):Play()
end

--// Main GUI Builder
buildGUI = function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MMBHubGUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    startSnow()

    local WHITE = Color3.fromRGB(255, 255, 255)
    local GRAY = Color3.fromRGB(120, 120, 120)
    local DARK_BTN = Color3.fromRGB(45, 45, 45)
    local BG_MAIN = Color3.fromRGB(12, 12, 12)
    local BG_TOP = Color3.fromRGB(22, 22, 22)
    local BORDER = Color3.fromRGB(55, 55, 55)
    local ACCENT = MENU_CONFIG.AccentColor
    local TWEEN_FAST = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local MAIN_W, MAIN_X, SIDE_W, SIDE_GAP = 486, 90, 54, 10

    -- Main Window
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, MAIN_W, 0, 380)
    mainFrame.Position = UDim2.new(0, MAIN_X, 0, 20)
    mainFrame.BackgroundColor3 = BG_MAIN
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = BORDER
    mainStroke.Thickness = 1
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Left Sidebar
    local sideBar = Instance.new("Frame")
    sideBar.Size = UDim2.new(0, SIDE_W, 0, 380)
    sideBar.Position = UDim2.new(0, MAIN_X - SIDE_W - SIDE_GAP, 0, 20)
    sideBar.BackgroundColor3 = BG_MAIN
    sideBar.BorderSizePixel = 0
    sideBar.Parent = gui
    Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 12)
    local sideStroke = Instance.new("UIStroke", sideBar)
    sideStroke.Color = BORDER
    sideStroke.Thickness = 1
    sideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local sidePad = Instance.new("UIPadding", sideBar)
    sidePad.PaddingTop = UDim.new(0, 10)
    sidePad.PaddingLeft = UDim.new(0, 8)
    sidePad.PaddingRight = UDim.new(0, 8)
    local sideLayout = Instance.new("UIListLayout", sideBar)
    sideLayout.FillDirection = Enum.FillDirection.Vertical
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    sideLayout.Padding = UDim.new(0, 8)
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local animatingMenu = false
    mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
        if animatingMenu then return end
        local pos = mainFrame.Position
        sideBar.Position = UDim2.new(0, pos.X.Offset - SIDE_W - SIDE_GAP, pos.Y.Scale, pos.Y.Offset)
    end)

    -- Header Bar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = BG_TOP
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)
    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 20)
    topFix.Position = UDim2.new(0, 0, 1, -20)
    topFix.BackgroundColor3 = BG_TOP
    topFix.BorderSizePixel = 0
    topFix.Parent = topBar

    local topLogo = Instance.new("ImageLabel")
    topLogo.Size = UDim2.new(0, 32, 0, 32)
    topLogo.Position = UDim2.new(0, 9, 0.5, -16)
    topLogo.BackgroundTransparency = 1
    topLogo.Image = MENU_CONFIG.LogoId
    topLogo.ScaleType = Enum.ScaleType.Crop
    topLogo.Parent = topBar
    Instance.new("UICorner", topLogo).CornerRadius = UDim.new(0, 6)

    local topTitle = Instance.new("TextLabel")
    topTitle.Size = UDim2.new(1, -56, 1, 0)
    topTitle.Position = UDim2.new(0, 52, 0, 0)
    topTitle.BackgroundTransparency = 1
    topTitle.Text = MENU_CONFIG.Title
    topTitle.TextColor3 = WHITE
    topTitle.Font = Enum.Font.GothamBold
    topTitle.TextSize = 16
    topTitle.TextXAlignment = Enum.TextXAlignment.Left
    topTitle.Parent = topBar

    -- Language Button & Dropdown
    local langBtn = Instance.new("TextButton")
    langBtn.Size = UDim2.new(0, 30, 0, 30)
    langBtn.Position = UDim2.new(1, -40, 0.5, -15)
    langBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    langBtn.BorderSizePixel = 0
    langBtn.Text = ""
    langBtn.Parent = topBar
    Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 6)

    local langIcon = Instance.new("ImageLabel")
    langIcon.Size = UDim2.new(0, 20, 0, 20)
    langIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
    langIcon.BackgroundTransparency = 1
    langIcon.Image = "rbxassetid://87926987916881"
    langIcon.ImageColor3 = ACCENT
    langIcon.ScaleType = Enum.ScaleType.Fit
    langIcon.Parent = langBtn

    local langMenuH = 36 * 2 + 4 + 12
    local langMenu = Instance.new("Frame")
    langMenu.Size = UDim2.new(0, 170, 0, 0)
    langMenu.Position = UDim2.new(1, -200, 0, 48)
    langMenu.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    langMenu.BorderSizePixel = 0
    langMenu.ClipsDescendants = true
    langMenu.Visible = false
    langMenu.ZIndex = 20
    langMenu.Parent = mainFrame
    Instance.new("UICorner", langMenu).CornerRadius = UDim.new(0, 8)
    local lmStroke = Instance.new("UIStroke", langMenu)
    lmStroke.Color = BORDER
    lmStroke.Thickness = 1
    lmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local lmPad = Instance.new("UIPadding", langMenu)
    lmPad.PaddingTop = UDim.new(0, 6)
    lmPad.PaddingBottom = UDim.new(0, 6)
    lmPad.PaddingLeft = UDim.new(0, 6)
    lmPad.PaddingRight = UDim.new(0, 6)
    local lmLayout = Instance.new("UIListLayout", langMenu)
    lmLayout.FillDirection = Enum.FillDirection.Vertical
    lmLayout.Padding = UDim.new(0, 4)
    lmLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function addLangOption(flagId, label, code, order)
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, 0, 0, 36)
        opt.BackgroundColor3 = (currentLang == code) and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(24, 24, 24)
        opt.BorderSizePixel = 0
        opt.Text = ""
        opt.AutoButtonColor = false
        opt.LayoutOrder = order
        opt.ZIndex = 21
        opt.Parent = langMenu
        Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 6)

        local fl = Instance.new("ImageLabel")
        fl.Size = UDim2.new(0, 22, 0, 16)
        fl.Position = UDim2.new(0, 8, 0.5, -8)
        fl.BackgroundTransparency = 1
        fl.Image = "rbxassetid://" .. flagId
        fl.ScaleType = Enum.ScaleType.Fit
        fl.ZIndex = 22
        fl.Parent = opt

        local tx = Instance.new("TextLabel")
        tx.Size = UDim2.new(1, -40, 1, 0)
        tx.Position = UDim2.new(0, 36, 0, 0)
        tx.BackgroundTransparency = 1
        tx.Text = label
        tx.TextColor3 = (currentLang == code) and WHITE or GRAY
        tx.Font = Enum.Font.GothamBold
        tx.TextSize = 11
        tx.TextXAlignment = Enum.TextXAlignment.Left
        tx.ZIndex = 22
        tx.Parent = opt

        if currentLang == code then
            local chk = Instance.new("TextLabel")
            chk.Size = UDim2.new(0, 16, 0, 16)
            chk.Position = UDim2.new(1, -22, 0.5, -8)
            chk.BackgroundTransparency = 1
            chk.Text = "✓"
            chk.TextColor3 = ACCENT
            chk.Font = Enum.Font.GothamBold
            chk.TextSize = 12
            chk.ZIndex = 22
            chk.Parent = opt
        end

        opt.MouseButton1Click:Connect(function()
            if currentLang ~= code then
                currentLang = code
                saveLanguage()
                gui:Destroy()
                showLoadingScreen(function() buildGUI() end)
            end
        end)
    end
    addLangOption("6103768192", "Français", "fr", 1)
    addLangOption("4530542408", "English", "en", 2)

    local langOpen, langBusy = false, false
    langBtn.MouseButton1Click:Connect(function()
        if langBusy then return end
        langBusy = true
        if not langOpen then
            langMenu.Visible = true
            langMenu.Size = UDim2.new(0, 170, 0, 0)
            langIcon.ImageColor3 = Color3.fromRGB(255, 100, 100)
            TweenService:Create(langMenu, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 170, 0, langMenuH) }):Play()
            langOpen = true
            task.wait(0.25)
        else
            TweenService:Create(langMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 170, 0, 0) }):Play()
            langIcon.ImageColor3 = ACCENT
            task.wait(0.2)
            langMenu.Visible = false
            langOpen = false
        end
        langBusy = false
    end)

    -- Toast Notification
    notifyFn = function(msg, color)
        task.spawn(function()
            local toast = Instance.new("Frame")
            toast.Size = UDim2.new(0, 340, 0, 40)
            toast.Position = UDim2.new(0.5, -170, 0, -60)
            toast.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            toast.BorderSizePixel = 0
            toast.ZIndex = 50
            toast.Parent = gui
            Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)
            local st = Instance.new("UIStroke", toast)
            st.Color = color or COLOR_RED
            st.Thickness = 1.5
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -20, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = msg
            lbl.TextColor3 = WHITE
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Center
            lbl.ZIndex = 51
            lbl.Parent = toast

            local tIn = TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -170, 0, 16) })
            tIn:Play(); tIn.Completed:Wait()
            task.wait(1.5)
            local tOut = TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, -170, 0, -60) })
            tOut:Play(); tOut.Completed:Wait()
            toast:Destroy()
        end)
    end

    -- Info View Overlay
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(0, 210, 0, 90)
    infoFrame.Position = UDim2.new(1, -220, 0, 10)
    infoFrame.BackgroundColor3 = BG_MAIN
    infoFrame.BackgroundTransparency = 0.15
    infoFrame.BorderSizePixel = 0
    infoFrame.Visible = false
    infoFrame.Parent = gui
    Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 6)
    local infoStroke = Instance.new("UIStroke", infoFrame)
    infoStroke.Color = BORDER
    infoStroke.Thickness = 1

    local infoLabels = {}
    local infoItems = {
        { key = "executor", text = "Executor: " .. executorName },
        { key = "fps",      text = "FPS: 60" },
        { key = "user",     text = "User: " .. LocalPlayer.Name },
        { key = "ping",     text = "Ping: 0ms" },
    }
    for i, item in ipairs(infoItems) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 0, 18)
        lbl.Position = UDim2.new(0, 8, 0, 6 + (i - 1) * 20)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = (i == 1) and COLOR_RED or WHITE
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = item.text
        lbl.Parent = infoFrame
        infoLabels[item.key] = lbl
    end

    task.spawn(function()
        while gui.Parent do
            task.wait(0.2)
            if Config.Misc.InfoView.Enabled then
                infoFrame.Visible = true
                infoLabels.fps.Text = "FPS: " .. fpsData.fps
                infoLabels.ping.Text = "Ping: " .. pingValue .. "ms"
                infoLabels.user.Text = "User: " .. LocalPlayer.Name
                infoLabels.executor.Text = "Executor: " .. executorName
            else
                infoFrame.Visible = false
            end
        end
    end)

    -- ESP Preview Window
    local previewWin = Instance.new("Frame")
    previewWin.Size = UDim2.new(0, 240, 0, 340)
    previewWin.Position = UDim2.new(0, 600, 0, 20)
    previewWin.BackgroundColor3 = BG_MAIN
    previewWin.BorderSizePixel = 0
    previewWin.Visible = false
    previewWin.Active = true
    previewWin.Draggable = true
    previewWin.Parent = gui
    Instance.new("UICorner", previewWin).CornerRadius = UDim.new(0, 8)
    local pvStroke = Instance.new("UIStroke", previewWin)
    pvStroke.Color = BORDER
    pvStroke.Thickness = 1

    local pvTop = Instance.new("Frame")
    pvTop.Size = UDim2.new(1, 0, 0, 30)
    pvTop.BackgroundColor3 = BG_TOP
    pvTop.BorderSizePixel = 0
    pvTop.Parent = previewWin
    Instance.new("UICorner", pvTop).CornerRadius = UDim.new(0, 8)
    local pvFix = Instance.new("Frame")
    pvFix.Size = UDim2.new(1, 0, 0, 15)
    pvFix.Position = UDim2.new(0, 0, 1, -15)
    pvFix.BackgroundColor3 = BG_TOP
    pvFix.BorderSizePixel = 0
    pvFix.Parent = pvTop

    local pvTitle = Instance.new("TextLabel")
    pvTitle.Size = UDim2.new(1, -40, 1, 0)
    pvTitle.Position = UDim2.new(0, 10, 0, 0)
    pvTitle.BackgroundTransparency = 1
    pvTitle.Text = T("previewESPTitle")
    pvTitle.TextColor3 = WHITE
    pvTitle.Font = Enum.Font.GothamBold
    pvTitle.TextSize = 13
    pvTitle.TextXAlignment = Enum.TextXAlignment.Left
    pvTitle.Parent = pvTop

    local pvClose = Instance.new("TextButton")
    pvClose.Size = UDim2.new(0, 20, 0, 20)
    pvClose.Position = UDim2.new(1, -26, 0.5, -10)
    pvClose.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    pvClose.BorderSizePixel = 0
    pvClose.Text = "X"
    pvClose.TextColor3 = Color3.fromRGB(255, 120, 120)
    pvClose.Font = Enum.Font.GothamBold
    pvClose.TextSize = 10
    pvClose.Parent = pvTop
    Instance.new("UICorner", pvClose).CornerRadius = UDim.new(0, 4)
    pvClose.MouseButton1Click:Connect(function() previewWin.Visible = false end)

    local pvContainer = Instance.new("Frame")
    pvContainer.Size = UDim2.new(1, -20, 1, -50)
    pvContainer.Position = UDim2.new(0, 10, 0, 40)
    pvContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    pvContainer.BorderSizePixel = 0
    pvContainer.ClipsDescendants = true
    pvContainer.Parent = previewWin
    Instance.new("UICorner", pvContainer).CornerRadius = UDim.new(0, 6)

    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(1, 0, 1, 0)
    viewport.BackgroundTransparency = 1
    viewport.Ambient = Color3.fromRGB(200, 200, 200)
    viewport.LightColor = Color3.fromRGB(255, 255, 255)
    viewport.LightDirection = Vector3.new(-0.4, -1, -0.7).Unit
    viewport.ZIndex = 1
    viewport.Parent = pvContainer

    local pvCam = Instance.new("Camera")
    pvCam.FieldOfView = 40
    pvCam.Parent = viewport
    viewport.CurrentCamera = pvCam

    local pvOverlay = Instance.new("Frame")
    pvOverlay.Size = UDim2.new(1, 0, 1, 0)
    pvOverlay.BackgroundTransparency = 1
    pvOverlay.ZIndex = 5
    pvOverlay.Parent = pvContainer

    local function makeOverlayLine(parent, thickness, color)
        local ln = Instance.new("Frame")
        ln.Size = UDim2.new(0, 0, 0, thickness or 1.5)
        ln.AnchorPoint = Vector2.new(0.5, 0.5)
        ln.BackgroundColor3 = color or WHITE
        ln.BorderSizePixel = 0
        ln.ZIndex = 6
        ln.Visible = false
        ln.Parent = parent
        return ln
    end

    local pvBones = {}
    for i = 1, 14 do pvBones[i] = makeOverlayLine(pvOverlay, 1.5, WHITE) end

    local pvHeadCircle = Instance.new("Frame")
    pvHeadCircle.BackgroundTransparency = 1
    pvHeadCircle.Visible = false
    pvHeadCircle.ZIndex = 6
    pvHeadCircle.Parent = pvOverlay
    Instance.new("UICorner", pvHeadCircle).CornerRadius = UDim.new(1, 0)
    local pvHeadStroke = Instance.new("UIStroke", pvHeadCircle)
    pvHeadStroke.Color = WHITE
    pvHeadStroke.Thickness = 1.5

    local pvBox = Instance.new("Frame")
    pvBox.BackgroundTransparency = 1
    pvBox.Visible = false
    pvBox.ZIndex = 6
    pvBox.Parent = pvOverlay
    local pvBoxStroke = Instance.new("UIStroke", pvBox)
    pvBoxStroke.Color = WHITE
    pvBoxStroke.Thickness = 1.5

    local pvHBBack = Instance.new("Frame")
    pvHBBack.Size = UDim2.new(0, 2, 0, 0)
    pvHBBack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    pvHBBack.BackgroundTransparency = 0.4
    pvHBBack.BorderSizePixel = 0
    pvHBBack.Visible = false
    pvHBBack.ZIndex = 6
    pvHBBack.Parent = pvOverlay

    local pvHBFill = Instance.new("Frame")
    pvHBFill.Size = UDim2.new(1, 0, 1, 0)
    pvHBFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    pvHBFill.BorderSizePixel = 0
    pvHBFill.ZIndex = 7
    pvHBFill.Parent = pvHBBack

    local pvName = Instance.new("TextLabel")
    pvName.BackgroundTransparency = 1
    pvName.Text = LocalPlayer.Name
    pvName.TextColor3 = WHITE
    pvName.Font = Enum.Font.GothamBold
    pvName.TextSize = 11
    pvName.Visible = false
    pvName.ZIndex = 6
    pvName.Parent = pvOverlay

    local pvDist = Instance.new("TextLabel")
    pvDist.BackgroundTransparency = 1
    pvDist.Text = "[42m]"
    pvDist.TextColor3 = Color3.fromRGB(200, 200, 200)
    pvDist.Font = Enum.Font.Gotham
    pvDist.TextSize = 10
    pvDist.Visible = false
    pvDist.ZIndex = 6
    pvDist.Parent = pvOverlay

    local pvTracer = makeOverlayLine(pvOverlay, 1, WHITE)
    local pvModel = nil

    local function loadPreviewModel()
        for _, ch in ipairs(viewport:GetChildren()) do
            if ch:IsA("Model") then pcall(function() ch:Destroy() end) end
        end
        local model = nil
        local desc = Instance.new("HumanoidDescription")
        desc.HeadColor = Color3.fromRGB(234, 184, 146)
        desc.TorsoColor = Color3.fromRGB(234, 184, 146)
        desc.LeftArmColor = Color3.fromRGB(234, 184, 146)
        desc.RightArmColor = Color3.fromRGB(234, 184, 146)
        desc.LeftLegColor = Color3.fromRGB(234, 184, 146)
        desc.RightLegColor = Color3.fromRGB(234, 184, 146)
        local ok, m = pcall(function() return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15) end)
        if ok and m and m:FindFirstChild("UpperTorso") then
            model = m
        else
            if m then pcall(function() m:Destroy() end) end
            local ok2, m2 = pcall(function() return Players:CreateHumanoidModelFromUserId(1) end)
            if ok2 and m2 and m2:FindFirstChild("UpperTorso") then
                model = m2
            elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local ok3, m3 = pcall(function() return LocalPlayer.Character:Clone() end)
                if ok3 and m3 then model = m3 end
            end
        end
        if not model then return end
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BaseScript") then d:Destroy() end
        end
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
        if not root then model:Destroy(); return end
        local offset = root.Position
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then
                d.CFrame = d.CFrame - offset
                d.Anchored = true
                d.CanCollide = false
                d.CanTouch = false
                d.CanQuery = false
            end
        end
        model.Parent = viewport
        pvModel = model
        local okBB, cf, size = pcall(function() return model:GetBoundingBox() end)
        if okBB and cf and size then
            local dist = (size.Y / 2) / math.tan(math.rad(pvCam.FieldOfView) / 2) * 1.5
            pvCam.CFrame = CFrame.lookAt(cf.Position + Vector3.new(0, 0, -dist), cf.Position)
        else
            pvCam.CFrame = CFrame.lookAt(Vector3.new(0, 0, -12), Vector3.new(0, 0, 0))
        end
    end

    local function projectPreview(worldPos, vpSize)
        local obj = pvCam.CFrame:PointToObjectSpace(worldPos)
        if obj.Z >= -0.05 then return nil, false end
        local t = math.tan(math.rad(pvCam.FieldOfView) / 2)
        local sx = (obj.X / -obj.Z / (t * vpSize.X / vpSize.Y) * 0.5 + 0.5) * vpSize.X
        local sy = (-(obj.Y / -obj.Z / t) * 0.5 + 0.5) * vpSize.Y
        return Vector2.new(sx, sy), true
    end

    task.spawn(function()
        while gui.Parent do
            task.wait(0.05)
            if previewWin.Visible then
                if not pvModel then loadPreviewModel() end
                if pvModel then
                    local vpSize = pvContainer.AbsoluteSize
                    if vpSize.X < 1 or vpSize.Y < 1 then vpSize = Vector2.new(220, 290) end
                    local col = Config.RainbowAll and getRainbowColor() or WHITE
                    local bones = pvModel:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
                    for i = 1, 14 do
                        local ln = pvBones[i]
                        local bone = bones[i]
                        if Config.Skeleton.Enabled and bone then
                            local p1 = pvModel:FindFirstChild(bone[1])
                            local p2 = pvModel:FindFirstChild(bone[2])
                            if p1 and p2 then
                                local s1, o1 = projectPreview(p1.Position, vpSize)
                                local s2, o2 = projectPreview(p2.Position, vpSize)
                                if o1 and o2 then
                                    local dx, dy = s2.X - s1.X, s2.Y - s1.Y
                                    ln.Size = UDim2.new(0, math.sqrt(dx * dx + dy * dy), 0, 1.5)
                                    ln.Position = UDim2.new(0, (s1.X + s2.X) / 2, 0, (s1.Y + s2.Y) / 2)
                                    ln.Rotation = math.deg(math.atan2(dy, dx))
                                    ln.BackgroundColor3 = col
                                    ln.Visible = true
                                else
                                    ln.Visible = false
                                end
                            else
                                ln.Visible = false
                            end
                        else
                            ln.Visible = false
                        end
                    end

                    local head = pvModel:FindFirstChild("Head")
                    if Config.Skeleton.Enabled and head then
                        local mid, oM = projectPreview(head.Position, vpSize)
                        local top, oT = projectPreview(head.Position + Vector3.new(0, head.Size.Y / 2, 0), vpSize)
                        local bot, oB = projectPreview(head.Position - Vector3.new(0, head.Size.Y / 2, 0), vpSize)
                        if oM and oT and oB then
                            local r = (math.abs(top.Y - bot.Y) / 2) * Config.Skeleton.HeadScale
                            pvHeadCircle.Size = UDim2.new(0, r * 2, 0, r * 2)
                            pvHeadCircle.Position = UDim2.new(0, mid.X - r, 0, mid.Y - r)
                            pvHeadStroke.Color = col
                            pvHeadCircle.Visible = true
                        else
                            pvHeadCircle.Visible = false
                        end
                    else
                        pvHeadCircle.Visible = false
                    end

                    local okBB, cf, size = pcall(function() return pvModel:GetBoundingBox() end)
                    if okBB and cf and size then
                        local topP, oT = projectPreview(Vector3.new(cf.Position.X, cf.Position.Y + size.Y / 2, cf.Position.Z), vpSize)
                        local botP, oB = projectPreview(Vector3.new(cf.Position.X, cf.Position.Y - size.Y / 2, cf.Position.Z), vpSize)
                        if oT and oB then
                            local bh = math.abs(botP.Y - topP.Y)
                            local bw = bh * 0.5
                            local cx = (topP.X + botP.X) / 2
                            local ty = math.min(topP.Y, botP.Y)

                            if Config.BoxESP.Enabled then
                                pvBox.Size = UDim2.new(0, bw, 0, bh)
                                pvBox.Position = UDim2.new(0, cx - bw / 2, 0, ty)
                                pvBoxStroke.Color = col
                                pvBox.Visible = true
                            else
                                pvBox.Visible = false
                            end

                            if Config.BoxESP.HealthBar then
                                pvHBBack.Size = UDim2.new(0, 2, 0, bh)
                                pvHBBack.Position = UDim2.new(0, cx - bw / 2 - 6, 0, ty)
                                pvHBBack.Visible = true
                                pvHBFill.Visible = true
                            else
                                pvHBBack.Visible = false
                                pvHBFill.Visible = false
                            end

                            if Config.BoxESP.Name then
                                pvName.Size = UDim2.new(0, bw + 40, 0, 14)
                                pvName.Position = UDim2.new(0, cx - (bw + 40) / 2, 0, ty - 16)
                                pvName.TextColor3 = col
                                pvName.Visible = true
                            else
                                pvName.Visible = false
                            end

                            if Config.DistanceESP.Enabled then
                                pvDist.Size = UDim2.new(0, bw + 40, 0, 14)
                                pvDist.Position = UDim2.new(0, cx - (bw + 40) / 2, 0, math.max(topP.Y, botP.Y) + 2)
                                pvDist.TextColor3 = col
                                pvDist.Visible = true
                            else
                                pvDist.Visible = false
                            end

                            if Config.TracerESP.Enabled and head then
                                local hp, oH = projectPreview(head.Position, vpSize)
                                if oH then
                                    local dx = hp.X - vpSize.X / 2
                                    local dy = hp.Y - vpSize.Y
                                    pvTracer.Size = UDim2.new(0, math.sqrt(dx * dx + dy * dy), 0, 1)
                                    pvTracer.Position = UDim2.new(0, (hp.X + vpSize.X / 2) / 2, 0, (hp.Y + vpSize.Y) / 2)
                                    pvTracer.Rotation = math.deg(math.atan2(dy, dx))
                                    pvTracer.BackgroundColor3 = col
                                    pvTracer.Visible = true
                                else
                                    pvTracer.Visible = false
                                end
                            else
                                pvTracer.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Tab Container & Builder Helpers
    local tabHolder = Instance.new("Frame")
    tabHolder.Size = UDim2.new(1, -16, 1, -86)
    tabHolder.Position = UDim2.new(0, 8, 0, 46)
    tabHolder.BackgroundTransparency = 1
    tabHolder.Parent = mainFrame

    local tabs = {}
    local tabButtons = {}

    local function selectTab(id)
        for k, frame in pairs(tabs) do
            frame.Visible = (k == id)
        end
        for k, btn in pairs(tabButtons) do
            local active = (k == id)
            TweenService:Create(btn, TWEEN_FAST, {
                BackgroundColor3 = active and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(18, 18, 18),
            }):Play()
            local icon = btn:FindFirstChild("Icon")
            if icon then
                TweenService:Create(icon, TWEEN_FAST, {
                    ImageColor3 = active and ACCENT or Color3.fromRGB(140, 140, 140),
                }):Play()
            end
        end
    end

    local function createTabFrame(name)
        local f = Instance.new("Frame")
        f.Name = name .. "Tab"
        f.Size = UDim2.new(1, 0, 1, 0)
        f.BackgroundTransparency = 1
        f.Visible = false
        f.Parent = tabHolder
        return f
    end

    tabs.esp = createTabFrame("ESP")
    tabs.aimbot = createTabFrame("Aimbot")
    tabs.misc = createTabFrame("Misc")
    tabs.settings = createTabFrame("Settings")
    tabs.credit = createTabFrame("Credit")

    local toggleRefs = {}
    local sliderRefs = {}

    local function refreshAllControls()
        for _, item in ipairs(toggleRefs) do
            local val = item.getter()
            item.sw.BackgroundColor3 = val and ACCENT or DARK_BTN
            item.knob.Position = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            item.knob.BackgroundColor3 = val and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(200, 200, 200)
        end
        for _, item in ipairs(sliderRefs) do
            local val = item.getter()
            local ratio = math.clamp((val - item.minV) / (item.maxV - item.minV), 0, 1)
            item.fill.Size = UDim2.new(ratio, 0, 1, 0)
            item.knob.Position = UDim2.new(ratio, 0, 0.5, 0)
            item.sLabel.Text = item.text .. item.formatter(val)
        end
    end

    local function addSectionHeader(parent, text, y)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 0, 14)
        lbl.Position = UDim2.new(0, 4, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
    end

    local function addToggle(parent, text, y, getter, setter)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 28)
        row.Position = UDim2.new(0, 4, 0, y)
        row.BackgroundTransparency = 1
        row.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -56, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 38, 0, 20)
        sw.Position = UDim2.new(1, -38, 0.5, -10)
        sw.BackgroundColor3 = getter() and ACCENT or DARK_BTN
        sw.BorderSizePixel = 0
        sw.Parent = row
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = getter() and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = getter() and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(200, 200, 200)
        knob.BorderSizePixel = 0
        knob.Parent = sw
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local hit = Instance.new("TextButton")
        hit.Size = UDim2.new(1, 0, 1, 0)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.Parent = row

        hit.MouseButton1Click:Connect(function()
            local newState = not getter()
            setter(newState)
            TweenService:Create(sw, TWEEN_FAST, { BackgroundColor3 = newState and ACCENT or DARK_BTN }):Play()
            TweenService:Create(knob, TWEEN_FAST, {
                Position = newState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = newState and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(200, 200, 200),
            }):Play()
        end)

        table.insert(toggleRefs, { getter = getter, sw = sw, knob = knob })
        return row
    end

    local function addSlider(parent, text, y, minV, maxV, getter, setter, formatter)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 0, 16)
        lbl.Position = UDim2.new(0, 4, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text .. formatter(getter())
        lbl.TextColor3 = GRAY
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent

        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -8, 0, 18)
        holder.Position = UDim2.new(0, 4, 0, y + 19)
        holder.BackgroundTransparency = 1
        holder.Parent = parent

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -10, 0, 5)
        track.Position = UDim2.new(0, 5, 0.5, -2.5)
        track.BackgroundColor3 = DARK_BTN
        track.BorderSizePixel = 0
        track.Parent = holder
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local initRatio = math.clamp((getter() - minV) / (maxV - minV), 0, 1)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(initRatio, 0, 1, 0)
        fill.BackgroundColor3 = WHITE
        fill.BorderSizePixel = 0
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(initRatio, 0, 0.5, 0)
        knob.BackgroundColor3 = ACCENT
        knob.BorderSizePixel = 0
        knob.ZIndex = 3
        knob.Parent = holder
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local kStroke = Instance.new("UIStroke", knob)
        kStroke.Color = WHITE
        kStroke.Thickness = 1
        kStroke.Transparency = 0.5

        local dragging = false
        local function updateFromInput(input)
            local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            local val = minV + ratio * (maxV - minV)
            setter(val)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            knob.Position = UDim2.new(ratio, 0, 0.5, 0)
            lbl.Text = text .. formatter(val)
        end

        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; updateFromInput(inp) end
        end)
        track.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then updateFromInput(inp) end
        end)
        knob.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        knob.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then updateFromInput(inp) end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        table.insert(sliderRefs, {
            getter = getter, fill = fill, knob = knob, sLabel = lbl,
            minV = minV, maxV = maxV, formatter = formatter, text = text,
        })
        return lbl
    end

    local function makeColumn(parent, x, w)
        local col = Instance.new("Frame")
        col.Size = UDim2.new(0, w, 1, 0)
        col.Position = UDim2.new(0, x, 0, 0)
        col.BackgroundTransparency = 1
        col.Parent = parent
        return col
    end

    -- Sidebar Tab Buttons
    local tabDefs = {
        { id = "esp",      icon = "rbxassetid://78134819718605" },
        { id = "aimbot",   icon = "rbxassetid://6116845225" },
        { id = "misc",     icon = "rbxassetid://18749336354" },
        { id = "settings", icon = "rbxassetid://134515081025675" },
        { id = "credit",   icon = "rbxassetid://89821724131834" },
        { id = "discord",  icon = "rbxassetid://128935532505964" },
    }
    for order, def in ipairs(tabDefs) do
        local isDiscord = (def.id == "discord")
        local btn = Instance.new("TextButton")
        btn.Name = "Tab_" .. def.id
        btn.Size = UDim2.new(0, 38, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.Parent = sideBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        if isDiscord then
            local ds = Instance.new("UIStroke", btn)
            ds.Color = ACCENT
            ds.Thickness = 2
            ds.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.Position = UDim2.new(0.5, -12, 0.5, -12)
        icon.BackgroundTransparency = 1
        icon.Image = def.icon
        icon.ImageColor3 = isDiscord and ACCENT or Color3.fromRGB(140, 140, 140)
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = btn

        btn.MouseButton1Click:Connect(function()
            if isDiscord then
                if setclipboard then
                    pcall(setclipboard, MENU_CONFIG.DiscordInvite)
                    notifyFn("Discord copied!", COLOR_GREEN)
                end
                return
            end
            selectTab(def.id)
        end)

        if not isDiscord then
            tabButtons[def.id] = btn
        end
    end

    --// TAB 1: ESP
    local espCol1 = makeColumn(tabs.esp, 0, 228)
    local espCol2 = makeColumn(tabs.esp, 242, 228)
    addSectionHeader(espCol1, T("playerESP"), 0)
    addToggle(espCol1, T("rainbowAll"), 20, function() return Config.RainbowAll end, function(v) Config.RainbowAll = v end)
    addToggle(espCol1, T("skeletonESP"), 52, function() return Config.Skeleton.Enabled end, function(v) Config.Skeleton.Enabled = v end)
    addToggle(espCol1, T("boxESP"), 84, function() return Config.BoxESP.Enabled end, function(v) Config.BoxESP.Enabled = v end)
    addToggle(espCol1, T("healthBar"), 116, function() return Config.BoxESP.HealthBar end, function(v) Config.BoxESP.HealthBar = v end)
    addToggle(espCol1, T("playerName"), 148, function() return Config.BoxESP.Name end, function(v) Config.BoxESP.Name = v end)
    addToggle(espCol1, T("selfESP"), 180, function() return Config.SelfESP.Enabled end, function(v) Config.SelfESP.Enabled = v end)
    addToggle(espCol1, T("tracerESP"), 212, function() return Config.TracerESP.Enabled end, function(v) Config.TracerESP.Enabled = v end)

    addSectionHeader(espCol2, T("detectionFX"), 0)
    addToggle(espCol2, T("distanceESP"), 20, function() return Config.DistanceESP.Enabled end, function(v) Config.DistanceESP.Enabled = v end)
    addToggle(espCol2, T("detectESP"), 52, function() return Config.DetectESP.Enabled end, function(v) Config.DetectESP.Enabled = v end)
    addToggle(espCol2, T("carESP"), 84, function() return Config.CarESP.Enabled end, function(v) Config.CarESP.Enabled = v end)
    addToggle(espCol2, T("chamsESP"), 116, function() return Config.ChamsESP.Enabled end, function(v) Config.ChamsESP.Enabled = v end)
    addSlider(espCol2, T("chamsOpacity"), 150, 0, 1, function() return Config.ChamsESP.Opacity end, function(v) Config.ChamsESP.Opacity = v end, function(v) return " " .. math.floor(v * 100) .. "%" end)
    addToggle(espCol2, T("radarESP"), 196, function() return Config.RadarESP.Enabled end, function(v) Config.RadarESP.Enabled = v end)

    local previewBtn = Instance.new("TextButton")
    previewBtn.Size = UDim2.new(1, -8, 0, 26)
    previewBtn.Position = UDim2.new(0, 4, 0, 228)
    previewBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    previewBtn.BorderSizePixel = 0
    previewBtn.Text = T("previewESP")
    previewBtn.TextColor3 = ACCENT
    previewBtn.Font = Enum.Font.GothamBold
    previewBtn.TextSize = 12
    previewBtn.Parent = espCol2
    Instance.new("UICorner", previewBtn).CornerRadius = UDim.new(0, 6)
    local pvBtnStroke = Instance.new("UIStroke", previewBtn)
    pvBtnStroke.Color = ACCENT
    pvBtnStroke.Thickness = 1
    pvBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    previewBtn.MouseButton1Click:Connect(function()
        previewWin.Visible = not previewWin.Visible
        if previewWin.Visible then task.spawn(loadPreviewModel) end
    end)

    --// TAB 2: AIMBOT & SILENT AIM
    local aimScroll = Instance.new("ScrollingFrame")
    aimScroll.Size = UDim2.new(1, 0, 1, 0)
    aimScroll.BackgroundTransparency = 1
    aimScroll.BorderSizePixel = 0
    aimScroll.ScrollBarThickness = 4
    aimScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    aimScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    aimScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    aimScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    aimScroll.Parent = tabs.aimbot

    local aimTop = Instance.new("Frame")
    aimTop.Size = UDim2.new(1, 0, 0, 180)
    aimTop.BackgroundTransparency = 1
    aimTop.Parent = aimScroll

    local aimCol1 = makeColumn(aimTop, 0, 228)
    local aimCol2 = makeColumn(aimTop, 242, 228)
    addSectionHeader(aimCol1, T("aimbotSection"), 0)
    addToggle(aimCol1, T("aimbotRMB"), 20, function() return Config.Aimbot.Enabled end, function(v) Config.Aimbot.Enabled = v end)
    addToggle(aimCol1, T("wallCheck"), 52, function() return Config.Aimbot.WallCheck end, function(v) Config.Aimbot.WallCheck = v end)
    addToggle(aimCol1, T("showFOV"), 84, function() return Config.Aimbot.ShowFOV end, function(v) Config.Aimbot.ShowFOV = v end)
    addToggle(aimCol1, T("macroRMB"), 116, function() return Config.Aimbot.Macro end, function(v) Config.Aimbot.Macro = v end)
    addToggle(aimCol1, T("antiZoom"), 148, function() return Config.Aimbot.AntiZoom end, function(v) Config.Aimbot.AntiZoom = v end)

    addSectionHeader(aimCol2, T("settingsSection"), 0)
    addSlider(aimCol2, T("smoothAim"), 20, 1, 100, function() return Config.Aimbot.Smoothness end, function(v) Config.Aimbot.Smoothness = math.floor(v) end, function(v) return " " .. math.floor(v) .. "%" end)
    addSlider(aimCol2, T("fovSize"), 60, 50, 500, function() return Config.Aimbot.FOV end, function(v) Config.Aimbot.FOV = math.floor(v) end, function(v) return " " .. math.floor(v) .. " px" end)

    -- Silent Aim Expandable Panel
    local silentCard = Instance.new("Frame")
    silentCard.Size = UDim2.new(1, 0, 0, 30)
    silentCard.Position = UDim2.new(0, 0, 0, 190)
    silentCard.BackgroundTransparency = 1
    silentCard.Parent = aimScroll

    local silentHeaderBtn = Instance.new("TextButton")
    silentHeaderBtn.Size = UDim2.new(1, -8, 0, 24)
    silentHeaderBtn.Position = UDim2.new(0, 4, 0, 0)
    silentHeaderBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    silentHeaderBtn.BorderSizePixel = 0
    silentHeaderBtn.Text = ""
    silentHeaderBtn.AutoButtonColor = false
    silentHeaderBtn.Parent = silentCard
    Instance.new("UICorner", silentHeaderBtn).CornerRadius = UDim.new(0, 5)

    local silentHeaderLbl = Instance.new("TextLabel")
    silentHeaderLbl.Size = UDim2.new(1, -30, 1, 0)
    silentHeaderLbl.Position = UDim2.new(0, 10, 0, 0)
    silentHeaderLbl.BackgroundTransparency = 1
    silentHeaderLbl.Text = T("silentSection")
    silentHeaderLbl.TextColor3 = ACCENT
    silentHeaderLbl.Font = Enum.Font.GothamBold
    silentHeaderLbl.TextSize = 11
    silentHeaderLbl.TextXAlignment = Enum.TextXAlignment.Left
    silentHeaderLbl.Parent = silentHeaderBtn

    local silentArrow = Instance.new("TextLabel")
    silentArrow.Size = UDim2.new(0, 20, 1, 0)
    silentArrow.Position = UDim2.new(1, -22, 0, 0)
    silentArrow.BackgroundTransparency = 1
    silentArrow.Text = "▼"
    silentArrow.TextColor3 = ACCENT
    silentArrow.Font = Enum.Font.GothamBold
    silentArrow.TextSize = 10
    silentArrow.Parent = silentHeaderBtn

    local silentBody = Instance.new("Frame")
    silentBody.Size = UDim2.new(1, 0, 0, 0)
    silentBody.Position = UDim2.new(0, 0, 0, 28)
    silentBody.BackgroundTransparency = 1
    silentBody.ClipsDescendants = true
    silentBody.Parent = silentCard

    local sCol1 = makeColumn(silentBody, 0, 228)
    local sCol2 = makeColumn(silentBody, 242, 228)

    addToggle(sCol1, T("silentAim"), 0, function() return Config.Silent.Enabled end, function(v)
        Config.Silent.Enabled = v
        if v then initSilentHook() end
    end)
    addToggle(sCol1, T("silentUseFOV"), 32, function() return Config.Silent.UseFOV end, function(v) Config.Silent.UseFOV = v end)
    addToggle(sCol1, T("silentTeamCheck"), 64, function() return Config.Silent.TeamCheck end, function(v) Config.Silent.TeamCheck = v end)
    addToggle(sCol1, T("silentWallCheck"), 96, function() return Config.Silent.WallCheck end, function(v) Config.Silent.WallCheck = v end)

    addSlider(sCol2, T("silentFOV"), 0, 50, 800, function() return Config.Silent.FOV end, function(v) Config.Silent.FOV = math.floor(v) end, function(v) return " " .. math.floor(v) .. " px" end)
    addSlider(sCol2, T("silentMaxDist"), 48, 50, 1000, function() return Config.Silent.MaxDistance end, function(v) Config.Silent.MaxDistance = math.floor(v) end, function(v) return " " .. math.floor(v) .. " m" end)
    addSlider(sCol2, T("silentHitChance"), 96, 1, 100, function() return Config.Silent.HitChance end, function(v) Config.Silent.HitChance = math.floor(v) end, function(v) return " " .. math.floor(v) .. "%" end)

    local silentExpanded = false
    local SILENT_FULL_H = 140
    silentHeaderBtn.MouseButton1Click:Connect(function()
        silentExpanded = not silentExpanded
        if silentExpanded then
            silentArrow.Rotation = 180
            TweenService:Create(silentBody, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, SILENT_FULL_H) }):Play()
            TweenService:Create(silentCard, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, SILENT_FULL_H + 30) }):Play()
        else
            silentArrow.Rotation = 0
            TweenService:Create(silentBody, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(1, 0, 0, 0) }):Play()
            TweenService:Create(silentCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(1, 0, 0, 30) }):Play()
        end
    end)

    --// TAB 3: MISC + SKIN SIDE PANEL
    local miscCol1 = makeColumn(tabs.misc, 0, 228)
    local miscCol2 = makeColumn(tabs.misc, 242, 228)

    addSectionHeader(miscCol1, T("miscSection"), 0)
    addToggle(miscCol1, T("fovChanger"), 20, function() return Config.Misc.FOVChanger.Enabled end, function(v) Config.Misc.FOVChanger.Enabled = v end)
    addToggle(miscCol1, T("spinCharacter"), 52, function() return Config.Misc.SpinCharacter.Enabled end, function(v) Config.Misc.SpinCharacter.Enabled = v end)
    addToggle(miscCol1, T("rainbowCar"), 84, function() return Config.Misc.RainbowCar.Enabled end, function(v) Config.Misc.RainbowCar.Enabled = v end)
    addToggle(miscCol1, T("infoView"), 116, function() return Config.Misc.InfoView.Enabled end, function(v) Config.Misc.InfoView.Enabled = v end)
    addToggle(miscCol1, T("rainbowAK"), 148, function() return Config.Skin.RainbowAK end, function(v) Config.Skin.RainbowAK = v; updateRainbowAK() end)
    addToggle(miscCol1, T("skinChanger"), 180, function() return Config.Skin.Enabled end, function(v) Config.Skin.Enabled = v; updateSkinState() end)

    addSectionHeader(miscCol2, T("effectsSection"), 0)
    addToggle(miscCol2, T("shiftBoost"), 20, function() return Config.Misc.ShiftBoost.Enabled end, function(v) Config.Misc.ShiftBoost.Enabled = v end)
    addToggle(miscCol2, T("saturation"), 52, function() return Config.Misc.Saturation.Enabled end, function(v) Config.Misc.Saturation.Enabled = v end)
    addSlider(miscCol2, T("saturationValue"), 92, 0, 3, function() return Config.Misc.Saturation.Value end, function(v) Config.Misc.Saturation.Value = v end, function(v) return string.format("%.2f", v) end)
    addToggle(miscCol2, T("stretchGame"), 130, function() return Config.Misc.StretchGame.Enabled end, function(v) Config.Misc.StretchGame.Enabled = v; updateStretchGame() end)
    addSlider(miscCol2, T("stretchValue"), 165, 0.3, 1.5, function() return Config.Misc.StretchGame.Value end, function(v) Config.Misc.StretchGame.Value = v end, function(v) return string.format("%.2f", v) end)

    -- Skin Side Panel
    local skinPanel = Instance.new("Frame")
    skinPanel.Size = UDim2.new(0, 220, 0, 60)
    skinPanel.Position = UDim2.new(0, MAIN_X + MAIN_W + 20, 0, 20)
    skinPanel.BackgroundColor3 = BG_MAIN
    skinPanel.BorderSizePixel = 0
    skinPanel.Visible = Config.Skin.Enabled
    skinPanel.Parent = gui
    Instance.new("UICorner", skinPanel).CornerRadius = UDim.new(0, 8)
    local spStroke = Instance.new("UIStroke", skinPanel)
    spStroke.Color = BORDER
    spStroke.Thickness = 1

    local spHeader = Instance.new("Frame")
    spHeader.Size = UDim2.new(1, 0, 0, 26)
    spHeader.BackgroundColor3 = BG_TOP
    spHeader.BorderSizePixel = 0
    spHeader.Parent = skinPanel
    Instance.new("UICorner", spHeader).CornerRadius = UDim.new(0, 8)
    local spHeaderFix = Instance.new("Frame")
    spHeaderFix.Size = UDim2.new(1, 0, 0, 13)
    spHeaderFix.Position = UDim2.new(0, 0, 1, -13)
    spHeaderFix.BackgroundColor3 = BG_TOP
    spHeaderFix.BorderSizePixel = 0
    spHeaderFix.Parent = spHeader

    local spTitle = Instance.new("TextLabel")
    spTitle.Size = UDim2.new(1, -20, 1, 0)
    spTitle.Position = UDim2.new(0, 10, 0, 0)
    spTitle.BackgroundTransparency = 1
    spTitle.Text = T("skinSection")
    spTitle.TextColor3 = WHITE
    spTitle.Font = Enum.Font.GothamBold
    spTitle.TextSize = 11
    spTitle.TextXAlignment = Enum.TextXAlignment.Left
    spTitle.Parent = spHeader

    local skinDropBtn = Instance.new("TextButton")
    skinDropBtn.Size = UDim2.new(1, -12, 0, 26)
    skinDropBtn.Position = UDim2.new(0, 6, 0, 30)
    skinDropBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    skinDropBtn.BorderSizePixel = 0
    skinDropBtn.Text = ""
    skinDropBtn.AutoButtonColor = false
    skinDropBtn.Parent = skinPanel
    Instance.new("UICorner", skinDropBtn).CornerRadius = UDim.new(0, 6)
    local sdStroke = Instance.new("UIStroke", skinDropBtn)
    sdStroke.Color = BORDER
    sdStroke.Thickness = 1

    local skinCurLbl = Instance.new("TextLabel")
    skinCurLbl.Size = UDim2.new(1, -40, 1, 0)
    skinCurLbl.Position = UDim2.new(0, 10, 0, 0)
    skinCurLbl.BackgroundTransparency = 1
    skinCurLbl.Text = SkinsData[Config.Skin.CurrentSkin] and SkinsData[Config.Skin.CurrentSkin].name or Config.Skin.CurrentSkin
    skinCurLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    skinCurLbl.Font = Enum.Font.GothamMedium
    skinCurLbl.TextSize = 11
    skinCurLbl.TextXAlignment = Enum.TextXAlignment.Left
    skinCurLbl.Parent = skinDropBtn

    local skinArrow = Instance.new("TextLabel")
    skinArrow.Size = UDim2.new(0, 20, 1, 0)
    skinArrow.Position = UDim2.new(1, -24, 0, 0)
    skinArrow.BackgroundTransparency = 1
    skinArrow.Text = "▼"
    skinArrow.TextColor3 = ACCENT
    skinArrow.Font = Enum.Font.GothamBold
    skinArrow.TextSize = 10
    skinArrow.Parent = skinDropBtn

    local skinKeys = {}
    for k in pairs(SkinsData) do table.insert(skinKeys, k) end
    table.sort(skinKeys)
    local skinListH = #skinKeys * 30 + math.max(#skinKeys - 1, 0) * 3 + 10

    local skinListFrame = Instance.new("Frame")
    skinListFrame.Size = UDim2.new(1, -12, 0, 0)
    skinListFrame.Position = UDim2.new(0, 6, 0, 60)
    skinListFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    skinListFrame.BorderSizePixel = 0
    skinListFrame.ClipsDescendants = true
    skinListFrame.Visible = false
    skinListFrame.ZIndex = 20
    skinListFrame.Parent = skinPanel
    Instance.new("UICorner", skinListFrame).CornerRadius = UDim.new(0, 6)
    local slStroke = Instance.new("UIStroke", skinListFrame)
    slStroke.Color = BORDER
    slStroke.Thickness = 1
    local slPad = Instance.new("UIPadding", skinListFrame)
    slPad.PaddingTop = UDim.new(0, 5); slPad.PaddingBottom = UDim.new(0, 5)
    slPad.PaddingLeft = UDim.new(0, 5); slPad.PaddingRight = UDim.new(0, 5)
    local slLayout = Instance.new("UIListLayout", skinListFrame)
    slLayout.FillDirection = Enum.FillDirection.Vertical
    slLayout.Padding = UDim.new(0, 3)
    slLayout.SortOrder = Enum.SortOrder.LayoutOrder

    for idx, sk in ipairs(skinKeys) do
        local info = SkinsData[sk]
        local selected = (Config.Skin.CurrentSkin == sk)
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, 0, 0, 30)
        item.BackgroundColor3 = selected and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(24, 24, 24)
        item.BorderSizePixel = 0
        item.Text = ""
        item.AutoButtonColor = false
        item.LayoutOrder = idx
        item.ZIndex = 21
        item.Parent = skinListFrame
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)

        local nm = Instance.new("TextLabel")
        nm.Size = UDim2.new(1, -30, 1, 0)
        nm.Position = UDim2.new(0, 10, 0, 0)
        nm.BackgroundTransparency = 1
        nm.Text = info.name
        nm.TextColor3 = selected and WHITE or Color3.fromRGB(150, 150, 150)
        nm.Font = Enum.Font.GothamBold
        nm.TextSize = 11
        nm.TextXAlignment = Enum.TextXAlignment.Left
        nm.ZIndex = 22
        nm.Parent = item

        if selected then
            local chk = Instance.new("TextLabel")
            chk.Size = UDim2.new(0, 16, 0, 16)
            chk.Position = UDim2.new(1, -22, 0.5, -8)
            chk.BackgroundTransparency = 1
            chk.Text = "✓"
            chk.TextColor3 = ACCENT
            chk.Font = Enum.Font.GothamBold
            chk.TextSize = 12
            chk.ZIndex = 22
            chk.Parent = item
        end

        item.MouseButton1Click:Connect(function()
            Config.Skin.CurrentSkin = sk
            skinCurLbl.Text = info.name
            if Config.Skin.Enabled then applySkin(sk) end
            for _, child in ipairs(skinListFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    for _, sub in ipairs(child:GetChildren()) do
                        if sub:IsA("TextLabel") and sub.Text == "✓" then sub:Destroy() end
                    end
                    if child == item then
                        local chk = Instance.new("TextLabel")
                        chk.Size = UDim2.new(0, 16, 0, 16)
                        chk.Position = UDim2.new(1, -22, 0.5, -8)
                        chk.BackgroundTransparency = 1
                        chk.Text = "✓"
                        chk.TextColor3 = ACCENT
                        chk.Font = Enum.Font.GothamBold
                        chk.TextSize = 12
                        chk.ZIndex = 22
                        chk.Parent = child
                    end
                end
            end
        end)
    end

    local skinDropOpen, skinDropBusy = false, false
    skinDropBtn.MouseButton1Click:Connect(function()
        if skinDropBusy then return end
        skinDropBusy = true
        if not skinDropOpen then
            skinListFrame.Visible = true
            skinListFrame.Size = UDim2.new(1, -12, 0, 0)
            TweenService:Create(skinPanel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 220, 0, 60 + skinListH + 6) }):Play()
            TweenService:Create(skinListFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(1, -12, 0, skinListH) }):Play()
            TweenService:Create(skinArrow, TweenInfo.new(0.2), { Rotation = 180 }):Play()
            skinDropOpen = true
            task.wait(0.25)
        else
            TweenService:Create(skinListFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(1, -12, 0, 0) }):Play()
            TweenService:Create(skinArrow, TweenInfo.new(0.2), { Rotation = 0 }):Play()
            TweenService:Create(skinPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 220, 0, 60) }):Play()
            task.wait(0.2)
            skinListFrame.Visible = false
            skinDropOpen = false
        end
        skinDropBusy = false
    end)

    mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
        if animatingMenu then return end
        local p = mainFrame.Position
        skinPanel.Position = UDim2.new(0, p.X.Offset + MAIN_W + 20, p.Y.Scale, p.Y.Offset)
    end)

    task.spawn(function()
        while gui.Parent do
            task.wait(0.1)
            if Config.Skin.Enabled ~= prevSkinEnabled then
                prevSkinEnabled = Config.Skin.Enabled
                if Config.Skin.Enabled then
                    skinPanel.Visible = true
                    skinPanel.Size = UDim2.new(0, 220, 0, 0)
                    TweenService:Create(skinPanel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 220, 0, 60) }):Play()
                else
                    if skinDropOpen then
                        skinDropOpen = false
                        skinListFrame.Visible = false
                        skinArrow.Rotation = 0
                    end
                    TweenService:Create(skinPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 220, 0, 0) }):Play()
                    task.delay(0.2, function()
                        if not Config.Skin.Enabled then
                            skinPanel.Visible = false
                            skinPanel.Size = UDim2.new(0, 220, 0, 60)
                        end
                    end)
                end
            end
        end
    end)

    --// TAB 5: SETTINGS (CONFIGS)
    local setCol1 = makeColumn(tabs.settings, 0, 228)
    local setCol2 = makeColumn(tabs.settings, 242, 228)

    addSectionHeader(setCol1, T("savedConfigs"), 0)
    local cfgInput = Instance.new("TextBox")
    cfgInput.Size = UDim2.new(1, -70, 0, 26)
    cfgInput.Position = UDim2.new(0, 4, 0, 20)
    cfgInput.BackgroundColor3 = BG_TOP
    cfgInput.BorderSizePixel = 0
    cfgInput.PlaceholderText = T("configName")
    cfgInput.Text = ""
    cfgInput.TextColor3 = WHITE
    cfgInput.PlaceholderColor3 = GRAY
    cfgInput.Font = Enum.Font.Gotham
    cfgInput.TextSize = 12
    cfgInput.TextXAlignment = Enum.TextXAlignment.Left
    cfgInput.ClearTextOnFocus = false
    cfgInput.Parent = setCol1
    Instance.new("UICorner", cfgInput).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", cfgInput).PaddingLeft = UDim.new(0, 8)

    local saveCfgBtn = Instance.new("TextButton")
    saveCfgBtn.Size = UDim2.new(0, 60, 0, 26)
    saveCfgBtn.Position = UDim2.new(1, -66, 0, 20)
    saveCfgBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    saveCfgBtn.BorderSizePixel = 0
    saveCfgBtn.Text = T("save")
    saveCfgBtn.TextColor3 = WHITE
    saveCfgBtn.Font = Enum.Font.GothamBold
    saveCfgBtn.TextSize = 12
    saveCfgBtn.Parent = setCol1
    Instance.new("UICorner", saveCfgBtn).CornerRadius = UDim.new(0, 6)

    local cfgScroll = Instance.new("ScrollingFrame")
    cfgScroll.Size = UDim2.new(1, -8, 0, 175)
    cfgScroll.Position = UDim2.new(0, 4, 0, 54)
    cfgScroll.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    cfgScroll.BorderSizePixel = 0
    cfgScroll.ScrollBarThickness = 3
    cfgScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    cfgScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    cfgScroll.Parent = setCol1
    Instance.new("UICorner", cfgScroll).CornerRadius = UDim.new(0, 6)
    local csPad = Instance.new("UIPadding", cfgScroll)
    csPad.PaddingTop = UDim.new(0, 4); csPad.PaddingLeft = UDim.new(0, 4); csPad.PaddingRight = UDim.new(0, 4)
    local csLayout = Instance.new("UIListLayout", cfgScroll)
    csLayout.Padding = UDim.new(0, 4)
    csLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function rebuildConfigList()
        for _, ch in ipairs(cfgScroll:GetChildren()) do
            if ch:IsA("TextButton") or ch:IsA("TextLabel") then ch:Destroy() end
        end
        local names = {}
        for k in pairs(savedConfigsStore.configs) do table.insert(names, k) end
        table.sort(names)
        if #names == 0 then
            local emptyLbl = Instance.new("TextLabel")
            emptyLbl.Size = UDim2.new(1, -8, 0, 40)
            emptyLbl.BackgroundTransparency = 1
            emptyLbl.Text = T("noConfigsSaved")
            emptyLbl.TextColor3 = GRAY
            emptyLbl.Font = Enum.Font.Gotham
            emptyLbl.TextSize = 11
            emptyLbl.Parent = cfgScroll
            cfgScroll.CanvasSize = UDim2.new(0, 0, 0, 44)
            return
        end
        for idx, name in ipairs(names) do
            local cfgData = savedConfigsStore.configs[name]
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, -8, 0, 26)
            row.BackgroundColor3 = BG_TOP
            row.BorderSizePixel = 0
            row.Text = ""
            row.AutoButtonColor = false
            row.LayoutOrder = idx
            row.Parent = cfgScroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -50, 1, 0)
            lbl.Position = UDim2.new(0, 8, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = tostring(name)
            lbl.TextColor3 = WHITE
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local del = Instance.new("TextButton")
            del.Size = UDim2.new(0, 22, 0, 20)
            del.Position = UDim2.new(1, -26, 0.5, -10)
            del.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
            del.BorderSizePixel = 0
            del.Text = "X"
            del.TextColor3 = Color3.fromRGB(255, 120, 120)
            del.Font = Enum.Font.GothamBold
            del.TextSize = 11
            del.Parent = row
            Instance.new("UICorner", del).CornerRadius = UDim.new(0, 4)

            del.MouseButton1Click:Connect(function()
                savedConfigsStore.configs[name] = nil
                saveConfigsToDisk()
                rebuildConfigList()
            end)
            row.MouseButton1Click:Connect(function()
                applyConfigData(cfgData)
                task.wait(0.05)
                refreshAllControls()
                updateStretchGame()
                updateSkinState()
                updateRainbowAK()
                if Config.Silent.Enabled then initSilentHook() end
                if notifyFn then notifyFn(T("configLoaded") .. ": " .. tostring(name)) end
            end)
        end
        cfgScroll.CanvasSize = UDim2.new(0, 0, 0, #names * 30 + 4)
    end
    rebuildConfigList()

    saveCfgBtn.MouseButton1Click:Connect(function()
        local name = cfgInput.Text
        if name and name ~= "" then
            savedConfigsStore.configs[name] = serializeConfig()
            saveConfigsToDisk()
            rebuildConfigList()
            if notifyFn then notifyFn(T("configSaved") .. ": " .. name) end
            cfgInput.Text = ""
        elseif notifyFn then
            notifyFn(T("enterConfigName"))
        end
    end)

    addSectionHeader(setCol2, T("shareConfig"), 0)
    local copyJsonBtn = Instance.new("TextButton")
    copyJsonBtn.Size = UDim2.new(1, -8, 0, 28)
    copyJsonBtn.Position = UDim2.new(0, 4, 0, 20)
    copyJsonBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
    copyJsonBtn.BorderSizePixel = 0
    copyJsonBtn.Text = T("copyJson")
    copyJsonBtn.TextColor3 = WHITE
    copyJsonBtn.Font = Enum.Font.GothamBold
    copyJsonBtn.TextSize = 11
    copyJsonBtn.Parent = setCol2
    Instance.new("UICorner", copyJsonBtn).CornerRadius = UDim.new(0, 6)
    copyJsonBtn.MouseButton1Click:Connect(function()
        local ok, json = pcall(function() return HttpService:JSONEncode(serializeConfig()) end)
        if ok then
            if setclipboard then
                pcall(setclipboard, json)
                if notifyFn then notifyFn(T("jsonCopied")) end
            elseif notifyFn then
                notifyFn("Clipboard not available")
            end
        elseif notifyFn then
            notifyFn("Encode failed")
        end
    end)

    addSectionHeader(setCol2, T("pasteJson"), 60)
    local jsonBox = Instance.new("TextBox")
    jsonBox.Size = UDim2.new(1, -8, 0, 110)
    jsonBox.Position = UDim2.new(0, 4, 0, 78)
    jsonBox.BackgroundColor3 = BG_TOP
    jsonBox.BorderSizePixel = 0
    jsonBox.PlaceholderText = T("pasteJsonHere")
    jsonBox.Text = ""
    jsonBox.TextColor3 = WHITE
    jsonBox.PlaceholderColor3 = GRAY
    jsonBox.Font = Enum.Font.Code
    jsonBox.TextSize = 10
    jsonBox.TextWrapped = true
    jsonBox.TextXAlignment = Enum.TextXAlignment.Left
    jsonBox.TextYAlignment = Enum.TextYAlignment.Top
    jsonBox.ClearTextOnFocus = false
    jsonBox.MultiLine = true
    jsonBox.Parent = setCol2
    Instance.new("UICorner", jsonBox).CornerRadius = UDim.new(0, 6)
    local jbPad = Instance.new("UIPadding", jsonBox)
    jbPad.PaddingTop = UDim.new(0, 6); jbPad.PaddingBottom = UDim.new(0, 6)
    jbPad.PaddingLeft = UDim.new(0, 6); jbPad.PaddingRight = UDim.new(0, 6)

    local loadJsonBtn = Instance.new("TextButton")
    loadJsonBtn.Size = UDim2.new(1, -8, 0, 28)
    loadJsonBtn.Position = UDim2.new(0, 4, 0, 194)
    loadJsonBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    loadJsonBtn.BorderSizePixel = 0
    loadJsonBtn.Text = T("loadFromJson")
    loadJsonBtn.TextColor3 = WHITE
    loadJsonBtn.Font = Enum.Font.GothamBold
    loadJsonBtn.TextSize = 12
    loadJsonBtn.Parent = setCol2
    Instance.new("UICorner", loadJsonBtn).CornerRadius = UDim.new(0, 6)
    loadJsonBtn.MouseButton1Click:Connect(function()
        local raw = jsonBox.Text
        if not raw or raw == "" then
            if notifyFn then notifyFn("Paste a JSON first!") end
            return
        end
        local ok, parsed = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and type(parsed) == "table" then
            applyConfigData(parsed)
            task.wait(0.05)
            refreshAllControls()
            updateStretchGame()
            updateSkinState()
            updateRainbowAK()
            if Config.Silent.Enabled then initSilentHook() end
            if notifyFn then notifyFn("JSON config loaded!") end
        elseif notifyFn then
            notifyFn(T("invalidJson"))
        end
    end)

    --// TAB 6: CREDIT
    local credCard = Instance.new("Frame")
    credCard.Size = UDim2.new(0, 200, 0, 220)
    credCard.Position = UDim2.new(0, 10, 0, 15)
    credCard.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    credCard.BorderSizePixel = 0
    credCard.Parent = tabs.credit
    Instance.new("UICorner", credCard).CornerRadius = UDim.new(0, 10)
    local ccStroke = Instance.new("UIStroke", credCard)
    ccStroke.Color = BORDER
    ccStroke.Thickness = 1

    local avatarHolder = Instance.new("Frame")
    avatarHolder.Size = UDim2.new(0, 110, 0, 110)
    avatarHolder.Position = UDim2.new(0.5, -55, 0, 20)
    avatarHolder.BackgroundColor3 = WHITE
    avatarHolder.BorderSizePixel = 0
    avatarHolder.Parent = credCard
    Instance.new("UICorner", avatarHolder).CornerRadius = UDim.new(1, 0)

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(1, -4, 1, -4)
    avatarImg.Position = UDim2.new(0, 2, 0, 2)
    avatarImg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    avatarImg.BorderSizePixel = 0
    avatarImg.Image = "rbxassetid://135084883856081"
    avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.Parent = avatarHolder
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

    local devName = Instance.new("TextLabel")
    devName.Size = UDim2.new(1, 0, 0, 32)
    devName.Position = UDim2.new(0, 0, 0, 140)
    devName.BackgroundTransparency = 1
    devName.Text = MENU_CONFIG.Developer
    devName.TextColor3 = WHITE
    devName.Font = Enum.Font.GothamBold
    devName.TextSize = 20
    devName.Parent = credCard

    local devRole = Instance.new("TextLabel")
    devRole.Size = UDim2.new(1, 0, 0, 18)
    devRole.Position = UDim2.new(0, 0, 0, 175)
    devRole.BackgroundTransparency = 1
    devRole.Text = T("developer")
    devRole.TextColor3 = Color3.fromRGB(255, 60, 60)
    devRole.Font = Enum.Font.GothamMedium
    devRole.TextSize = 12
    devRole.Parent = credCard

    -- Footer
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -24, 0, 20)
    footer.Position = UDim2.new(0, 12, 1, -26)
    footer.BackgroundTransparency = 1
    footer.Text = T("footer")
    footer.TextColor3 = Color3.fromRGB(80, 80, 80)
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 10
    footer.TextXAlignment = Enum.TextXAlignment.Left
    footer.Parent = mainFrame

    -- Select Default Tab
    selectTab("esp")

    -- Toggle Menu Visibility (RightShift)
    local toggling = false
    local function toggleMenu()
        if toggling then return end
        toggling = true
        animatingMenu = true
        local yPos = mainFrame.Position.Y
        if guiVisible then
            local t1 = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Position = UDim2.new(0, -650, yPos.Scale, yPos.Offset) })
            local t2 = TweenService:Create(sideBar, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Position = UDim2.new(0, -720, yPos.Scale, yPos.Offset) })
            local t3 = TweenService:Create(skinPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Position = UDim2.new(0, -400, yPos.Scale, yPos.Offset) })
            t1:Play(); t2:Play(); t3:Play()
            t1.Completed:Wait()
            mainFrame.Visible = false
            sideBar.Visible = false
            previewWin.Visible = false
            skinPanel.Visible = false
            guiVisible = false
            stopSnow()
        else
            mainFrame.Visible = true
            sideBar.Visible = true
            skinPanel.Visible = Config.Skin.Enabled
            mainFrame.Position = UDim2.new(0, -650, yPos.Scale, yPos.Offset)
            sideBar.Position = UDim2.new(0, -720, yPos.Scale, yPos.Offset)
            skinPanel.Position = UDim2.new(0, -400, yPos.Scale, yPos.Offset)
            startSnow()
            local t1 = TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, MAIN_X, yPos.Scale, yPos.Offset) })
            local t2 = TweenService:Create(sideBar, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, MAIN_X - SIDE_W - SIDE_GAP, yPos.Scale, yPos.Offset) })
            local t3 = TweenService:Create(skinPanel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, MAIN_X + MAIN_W + 20, yPos.Scale, yPos.Offset) })
            t1:Play(); t2:Play(); t3:Play()
            t1.Completed:Wait()
            guiVisible = true
        end
        animatingMenu = false
        toggling = false
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == MENU_CONFIG.ToggleKey then
            toggleMenu()
        end
    end)
end

--// Main RenderStepped Loop
RunService.RenderStepped:Connect(function(dt)
    -- FPS & Ping
    fpsData.frames = fpsData.frames + 1
    fpsData.accum = fpsData.accum + dt
    if fpsData.accum >= 0.5 then
        fpsData.fps = math.floor(fpsData.frames / fpsData.accum)
        fpsData.frames = 0
        fpsData.accum = 0
    end
    pingAccum = pingAccum + dt
    if pingAccum >= 0.5 then
        pingAccum = 0
        pcall(function()
            local p = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            if type(p) == "number" then pingValue = math.floor(p) end
        end)
    end

    -- AntiZoom / FOV Changer conflict warning
    if Config.Aimbot.AntiZoom and Config.Misc.FOVChanger.Enabled then
        if not fovConflictWarned then
            fovConflictWarned = true
            if notifyFn then notifyFn(T("fovConflict"), COLOR_SOFT_RED) end
        end
    else
        fovConflictWarned = false
    end

    -- FOV Changer
    if Camera then
        if Config.Misc.FOVChanger.Enabled then
            if fovSaved then savedOriginalFOV = Camera.FieldOfView; fovSaved = false end
            if Camera.FieldOfView ~= Config.Misc.FOVChanger.FOV then
                Camera.FieldOfView = Config.Misc.FOVChanger.FOV
            end
        elseif Config.Aimbot.AntiZoom then
            if fovSaved then savedOriginalFOV = Camera.FieldOfView; fovSaved = false end
            if Camera.FieldOfView ~= DEFAULT_FOV then
                Camera.FieldOfView = DEFAULT_FOV
            end
        elseif not fovSaved then
            Camera.FieldOfView = savedOriginalFOV
            fovSaved = true
        end
    end

    -- Spin Character
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if Config.Misc.SpinCharacter.Enabled and hrp and hum then
        if not spinActive then
            spinActive = true
            hum.AutoRotate = false
            local _, ry, _ = hrp.CFrame:ToEulerAnglesYXZ()
            spinAngle = ry
        end
        spinAngle = spinAngle + math.rad(Config.Misc.SpinCharacter.Speed) * dt
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
    elseif spinActive then
        spinActive = false
        if hum then hum.AutoRotate = true end
        spinAngle = 0
    end

    -- Misc Loops
    updateRainbowCar()
    updateShiftBoost(dt)
    updateSkinState()
    updateRainbowAK()

    -- Saturation
    if saturationEffect then
        saturationEffect.Enabled = Config.Misc.Saturation.Enabled
        saturationEffect.Saturation = Config.Misc.Saturation.Value
    end

    -- FOV Circle
    if fovCircle then
        local showSilentFOV = Config.Silent.Enabled and Config.Silent.UseFOV
        local showAimFOV = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
        if showSilentFOV or showAimFOV then
            local radius = showSilentFOV and math.max(0, Config.Silent.FOV) or math.max(0, Config.Aimbot.FOV)
            fovCircle.Position = Camera.ViewportSize * 0.5
            fovCircle.Radius = radius
            fovCircle.Visible = true
            if Config.RainbowAll then
                fovCircle.Color = getRainbowColor()
            elseif showSilentFOV then
                fovCircle.Color = COLOR_SOFT_RED
            else
                fovCircle.Color = WHITE
            end
        else
            fovCircle.Visible = false
        end
    end

    -- Player ESP & Chams
    local anyPlayerESP = Config.Skeleton.Enabled or Config.BoxESP.Enabled or Config.BoxESP.HealthBar or Config.BoxESP.Name or Config.DistanceESP.Enabled or Config.TracerESP.Enabled
    if anyPlayerESP or Config.ChamsESP.Enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if shouldDrawPlayer(plr) and isAlive(plr) then
                if anyPlayerESP then
                    updatePlayerESP(plr, plr.Character)
                else
                    hidePlayerESP(plr)
                end
                if Config.ChamsESP.Enabled then
                    updateChams(plr, plr.Character)
                else
                    removeChams(plr)
                end
            else
                removePlayerESP(plr)
                removeChams(plr)
            end
        end
    else
        for plr, _ in pairs(espDrawings) do removePlayerESP(plr) end
        for plr, _ in pairs(chamsHighlights) do removeChams(plr) end
    end

    -- Car ESP
    if Config.CarESP.Enabled ~= carESPActive then
        toggleCarESP(Config.CarESP.Enabled)
    end
    if Config.CarESP.Enabled then
        updateCarESP()
    end

    -- Radar ESP
    updateRadarESP()
end)

--// Global Input Listeners
UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbAimbotHeld = true
    end
    if not processed and (input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift) then
        if Config.Misc.ShiftBoost.Enabled and not shiftBoostHeld then
            shiftBoostHeld = true
            boostTargetSpeed = 0
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbAimbotHeld = false
    end
    if not processed and (input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift) then
        if shiftBoostHeld then
            shiftBoostHeld = false
            applySeatBoost(false)
            boostTargetSpeed = 0
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    removePlayerESP(plr)
    removeChams(plr)
    if radarDots[plr] then
        pcall(function() radarDots[plr]:Remove() end)
        radarDots[plr] = nil
    end
    visCache[plr] = nil
end)

--// Initialize
pcall(initSilentHook)
if loadLanguage() then
    showLoadingScreen(function()
        buildGUI()
    end)
else
    showLanguageSelector()
end
