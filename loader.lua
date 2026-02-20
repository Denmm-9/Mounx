--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║              KEY SYSTEM - SECURE LOADER v2.1                   ║
    ║              Para Mounx / ZekeHub                              ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    INSTRUCCIONES:
    1. Configura tu URL del panel en CONFIG.PANEL_URL
    2. Genera un API Secret en el Dashboard del panel
    3. Pon el secret en CONFIG.API_SECRET
    4. El usuario debe poner: script_key="SU-KEY-AQUI" antes de ejecutar
    
    CARACTERÍSTICAS:
    - Key formato: wLvyKjFHOCcgQpiJqhCdQhujCmCsAQQF (32 caracteres)
    - HWID vinculado al dispositivo
    - Executor vinculado (no puede cambiar de executor)
    - Ubicación detectada automáticamente
    - Notificaciones de error detalladas
    - Panel dinámico (auto-actualiza)
]]--

repeat task.wait(0.1) until game:IsLoaded()

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURACIÓN - EDITA SOLO ESTO
-- ═══════════════════════════════════════════════════════════════

local CONFIG = {
    -- URL de tu panel (SIN /api/ al final)
    -- Ejemplo: "https://tu-panel.vercel.app"
    PANEL_URL = "https://preview-chat-83ea5622-7795-4219-b50e-23f212104690.space.z.ai/",
    
    -- API Secret (GENERADO EN EL DASHBOARD) - OBLIGATORIO
    API_SECRET = "9yPZF_1Xwf49Brjm_pEiV-pXxV2OSqTt",
    
    -- Nombre del script
    SCRIPT_NAME = "Mounx",
    
    -- Discord para soporte
    DISCORD_INVITE = "discord.gg/rrY66GEgmK",
}

-- ═══════════════════════════════════════════════════════════════
-- VERIFICAR CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════════

local function showError(title, message, duration)
    duration = duration or 10
    local players = game:GetService("Players")
    local player = players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ErrorNotification"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, 0, 0.25, 0)
    frame.Position = UDim2.new(0.25, 0, 0.375, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(0, 12)
    corners.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 80, 80)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0.3, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "❌ " .. title
    titleLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
    titleLbl.TextScaled = true
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Parent = frame
    
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -20, 0.6, 0)
    msgLbl.Position = UDim2.new(0, 10, 0.35, 0)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    msgLbl.TextScaled = true
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextWrapped = true
    msgLbl.Parent = frame
    
    task.delay(duration, function()
        screenGui:Destroy()
    end)
end

if CONFIG.PANEL_URL == "AQUI_PON_TU_URL_DEL_PANEL" then
    showError(
        "⚠️ Configuración Requerida", 
        "Edita el loader y pon tu URL del panel\nen CONFIG.PANEL_URL\n\nDiscord: " .. CONFIG.DISCORD_INVITE,
        15
    )
    return
end

if CONFIG.API_SECRET == "" then
    showError(
        "⚠️ API Secret Requerido", 
        "Genera un API Secret en tu panel\ny ponlo en CONFIG.API_SECRET\n\nDiscord: " .. CONFIG.DISCORD_INVITE,
        15
    )
    return
end

-- ═══════════════════════════════════════════════════════════════
-- SERVICIOS
-- ═══════════════════════════════════════════════════════════════

local NotificationLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/AccountBurner/Utility/refs/heads/main/NotificationLib"))()
local UIS = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- DETECCIÓN DE DISPOSITIVO Y EXECUTOR
-- ═══════════════════════════════════════════════════════════════

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local deviceType = isMobile and "Mobile" or "PC"

local function getExecutor()
    if identifyexecutor then
        return identifyexecutor()
    elseif syn and syn.get_executor_name then
        return syn.get_executor_name()
    elseif getexecutorname then
        return getexecutorname()
    end
    return "Unknown"
end

local executor = getExecutor()

-- ═══════════════════════════════════════════════════════════════
-- OBTENER HWID (Hardware ID)
-- ═══════════════════════════════════════════════════════════════

local function getHWID()
    -- Intentar obtener HWID real del executor
    if syn and syn.gethwid then
        return syn.gethwid()
    end
    if gethwid then
        return gethwid()
    end
    if hwid then
        return hwid
    end
    if get_hwid then
        return get_hwid()
    end
    
    -- Fallback: generar HWID basado en información del usuario
    local hash = 0
    local str = Player.Name .. tostring(Player.UserId) .. game.JobId .. executor
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 2147483647
    end
    return string.format("GEN-%08X-%08X", hash, hash * 17 % 2147483647)
end

local hwid = getHWID()

-- ═══════════════════════════════════════════════════════════════
-- HTTP REQUEST
-- ═══════════════════════════════════════════════════════════════

local function httpRequest(url, method, body)
    local options = {
        Url = url,
        Method = method,
        Headers = {["Content-Type"] = "application/json"},
        Body = body
    }
    
    if syn and syn.request then
        return syn.request(options)
    end
    if request then
        return request(options)
    end
    if method == "GET" then
        local success, result = pcall(function()
            return HttpService:GetAsync(url)
        end)
        return success and {Body = result, StatusCode = 200} or {Body = nil, StatusCode = 500}
    else
        local success, result = pcall(function()
            return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
        end)
        return success and {Body = result, StatusCode = 200} or {Body = nil, StatusCode = 500}
    end
end

-- ═══════════════════════════════════════════════════════════════
-- UTILIDADES
-- ═══════════════════════════════════════════════════════════════

local Utilities = {}

function Utilities.FormatDuration(seconds)
    if not seconds or seconds <= 0 then
        return "Lifetime"
    end
    
    local parts = {}
    local remaining = seconds
    local units = {
        {unit = "d", seconds = 86400},
        {unit = "h", seconds = 3600},
        {unit = "m", seconds = 60},
        {unit = "s", seconds = 1}
    }
    
    for _, data in ipairs(units) do
        local value = math.floor(remaining / data.seconds)
        if value > 0 then
            table.insert(parts, value .. data.unit)
            remaining = remaining % data.seconds
            if #parts >= 2 then break end
        end
    end
    
    return #parts > 0 and table.concat(parts, " ") or "0s"
end

function Utilities.GetGameInfo()
    local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
    return {
        Name = ok and info.Name or "Unknown Game",
        Creator = ok and info.Creator.Name or "Unknown"
    }
end

function Utilities.CopyDiscord()
    pcall(setclipboard, CONFIG.DISCORD_INVITE)
end

-- ═══════════════════════════════════════════════════════════════
-- VERIFICACIÓN DE KEY
-- ═══════════════════════════════════════════════════════════════

local function verificarKey()
    if not script_key then
        NotificationLib:Error(
            "❌ No Key Provided",
            "Set script_key=\"YOUR-KEY\" before loading\n\nKey format: 32 characters\nExample: wLvyKjFHOCcgQpiJqhCdQhujCmCsAQQF\n\nDiscord copiado al portapapeles",
            12,
            Utilities.CopyDiscord
        )
        return false, "NO_KEY", nil
    end
    
    local playerName = Player.Name
    local playerId = tostring(Player.UserId)
    
    local data = {
        key = script_key,
        idUser = playerName,
        robloxUserId = playerId,
        hwid = hwid,
        executor = executor,
        deviceType = deviceType,
        secret = CONFIG.API_SECRET
    }
    
    local body = HttpService:JSONEncode(data)
    local url = CONFIG.PANEL_URL .. "/api/verify"
    
    local authNotif = NotificationLib:Info("🔄 Authenticating", "Verifying license key...", 20)
    local response = httpRequest(url, "POST", body)
    authNotif:Destroy()
    
    if not response or response.StatusCode ~= 200 then
        NotificationLib:Error(
            "❌ Connection Error",
            "Could not connect to server\nStatus: " .. tostring(response and response.StatusCode or "unknown") .. "\n\nClick para copiar Discord",
            15,
            Utilities.CopyDiscord
        )
        return false, "CONNECTION_ERROR", nil
    end
    
    local result = HttpService:JSONDecode(response.Body)
    return result.success, result.code, result
end

-- ═══════════════════════════════════════════════════════════════
-- HANDLERS DE RESPUESTA CON MENSAJES DETALLADOS
-- ═══════════════════════════════════════════════════════════════

local Handlers = {}

Handlers.KEY_VALID = function(data)
    local player = Player
    local timeLeft = Utilities.FormatDuration(data.auth_expire > 0 and (data.auth_expire - os.time()) or -1)
    
    local details = {
        "✅ Executions: " .. tostring(data.total_executions),
        "⏰ Expires: " .. timeLeft,
        "📱 Device: " .. deviceType,
        "🎮 Executor: " .. executor,
        "🌍 Location: " .. (data.country or "Unknown") .. (data.city and (", " .. data.city) or "")
    }
    
    if data.note and data.note ~= "" then
        table.insert(details, "📝 User: " .. data.note)
    end
    
    NotificationLib:Success(
        "✅ Welcome, " .. player.DisplayName,
        table.concat(details, "\n"),
        8
    )
    
    return true
end

Handlers.KEY_HWID_LOCKED = function(data)
    NotificationLib:Warning(
        "⚠️ HWID Mismatch",
        "This key is linked to another device!\n\nYour HWID: " .. hwid:sub(1, 16) .. "...\n\nContact admin to reset HWID\nDiscord copiado al portapapeles",
        15,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.EXECUTOR_MISMATCH = function(data)
    NotificationLib:Error(
        "❌ Wrong Executor",
        "This key is linked to: " .. (data.linkedExecutor or "Unknown") .. "\n\nYou are using: " .. executor .. "\n\nYou cannot change executors!\nDiscord copiado al portapapeles",
        15,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.KEY_EXPIRED = function()
    NotificationLib:Error(
        "❌ Subscription Expired",
        "Your key has expired!\n\nRenew your subscription to continue\nDiscord copiado al portapapeles",
        15,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.KEY_BANNED = function()
    NotificationLib:Error(
        "🚫 Access Revoked",
        "This key has been disabled!\n\nContact support for help\nDiscord copiado al portapapeles",
        15,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.KEY_INCORRECT = function()
    Utilities.CopyDiscord()
    NotificationLib:Error(
        "❌ Invalid Key",
        "Key not found in database!\n\nKey format: 32 characters\nExample: wLvyKjFHOCcgQpiJqhCdQhujCmCsAQQF\n\nDiscord: " .. CONFIG.DISCORD_INVITE,
        15,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.HWID_REQUIRED = function()
    NotificationLib:Error(
        "❌ HWID Required",
        "Could not detect your HWID!\n\nTry a different executor\nDiscord copiado al portapapeles",
        15,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.UNAUTHORIZED = function()
    NotificationLib:Error(
        "🔒 Unauthorized",
        "Invalid API Secret!\n\nThis loader is not authorized\nContact the developer\nDiscord copiado al portapapeles",
        15,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.USER_MISMATCH = function(data)
    NotificationLib:Error(
        "❌ Wrong User",
        "This key is linked to: " .. (data.linkedUser or "Unknown") .. "\n\nYou are: " .. Player.Name .. "\nDiscord copiado al portapapeles",
        15,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.USAGE_LIMIT = function()
    NotificationLib:Error(
        "❌ Usage Limit",
        "This key has reached its usage limit!\n\nContact support for help\nDiscord copiado al portapapeles",
        15,
        Utilities.CopyDiscord
    )
    return false
end

-- ═══════════════════════════════════════════════════════════════
-- GAME LIST Y CARGA DE SCRIPTS (MOUNX)
-- ═══════════════════════════════════════════════════════════════

local ListURL = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/Game_list.lua"
local success, result = pcall(function()
    return loadstring(game:HttpGet(ListURL))()
end)

if not success then
    NotificationLib:Error("❌ Error", "Game list failed to load\nCheck your connection", 8)
    return
end

local games = result
local loadedGame = false

local gameInfo = Utilities.GetGameInfo()

-- ═══════════════════════════════════════════════════════════════
-- AUTENTICACIÓN PRINCIPAL
-- ═══════════════════════════════════════════════════════════════

local function Authenticate()
    local success, code, data = verificarKey()
    
    if success then
        local handler = Handlers["KEY_VALID"]
        if handler then
            handler(data.data or data)
        end
        
        -- CARGAR SCRIPT DEL JUEGO
        for placeId, gameData in pairs(games) do
            if game.PlaceId == placeId then
                local scriptUrl = nil
                if type(gameData) == "table" then
                    scriptUrl = gameData[deviceType:lower()] or gameData.pc or gameData.mobile
                elseif type(gameData) == "string" then
                    scriptUrl = gameData
                end

                if scriptUrl then
                    loadstring(game:HttpGet(scriptUrl))()
                    loadedGame = true
                end
                break
            end
        end
        
        -- Universal scripts si no está en la lista
        if not loadedGame then
            task.wait(2)
            local universalScripts = {}
            if deviceType == "PC" then
                universalScripts = {
                    { Name = "NonUniversal.lua", URL = "https://raw.githubusercontent.com/Denmm-9/Universal/main/NonUniversal.lua" },
                    { Name = "SilentAimV2.lua", URL = "https://raw.githubusercontent.com/Denmm-9/Universal/main/SilentAimV2.lua" },
                    { Name = "HitboxExpander.lua", URL = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/HitboxExpander.lua" },
                }
            else
                universalScripts = {
                    { Name = "MobileUniversal.lua", URL = "https://raw.githubusercontent.com/Denmm-9/Universal/main/MobileUniversal.lua" },
                    { Name = "HitboxExpander.lua", URL = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/HitboxExpander.lua" },
                }
            end

            -- GUI de selección universal
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "UniversalSelector"
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ScreenGui.ResetOnSpawn = false
            ScreenGui.IgnoreGuiInset = true
            ScreenGui.Parent = PlayerGui

            local Holder = Instance.new("Frame")
            Holder.Parent = ScreenGui
            Holder.Size = UDim2.new(0.27, 0, 0.45, 0)
            Holder.Position = UDim2.new(0.365, 0, 0.27, 0)
            Holder.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
            Holder.BorderSizePixel = 0

            local Top = Instance.new("Frame")
            Top.Parent = Holder
            Top.Size = UDim2.new(1, 0, 0.12, 0)
            Top.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            Top.BorderSizePixel = 0

            local Title = Instance.new("TextLabel")
            Title.Parent = Top
            Title.Size = UDim2.new(1, 0, 1, 0)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamBold
            Title.Text = "🎮 Universal Loader"
            Title.TextScaled = true
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)

            local Gradient = Instance.new("UIGradient")
            Gradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
            }
            Gradient.Parent = Title

            local Bottom = Instance.new("Frame")
            Bottom.Parent = Holder
            Bottom.Size = UDim2.new(1, 0, 0.12, 0)
            Bottom.Position = UDim2.new(0, 0, 0.88, 0)
            Bottom.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            Bottom.BorderSizePixel = 0

            local LastUpdate = Instance.new("TextLabel")
            LastUpdate.Parent = Bottom
            LastUpdate.Size = UDim2.new(0.55, 0, 0.7, 0)
            LastUpdate.Position = UDim2.new(0.03, 0, 0.15, 0)
            LastUpdate.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            LastUpdate.Text = "Select a script to load."
            LastUpdate.TextScaled = true
            LastUpdate.TextColor3 = Color3.fromRGB(255, 255, 255)
            LastUpdate.Font = Enum.Font.Gotham
            LastUpdate.BorderSizePixel = 0

            local LoadButton = Instance.new("TextButton")
            LoadButton.Parent = Bottom
            LoadButton.Size = UDim2.new(0.36, 0, 0.7, 0)
            LoadButton.Position = UDim2.new(0.61, 0, 0.15, 0)
            LoadButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            LoadButton.Text = "▶ Load"
            LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            LoadButton.TextScaled = true
            LoadButton.Font = Enum.Font.GothamBold
            LoadButton.BorderSizePixel = 0

            local SelectedScript = nil

            local ScrollingFrame = Instance.new("ScrollingFrame")
            ScrollingFrame.Parent = Holder
            ScrollingFrame.Position = UDim2.new(0, 0, 0.13, 0)
            ScrollingFrame.Size = UDim2.new(1, 0, 0.75, 0)
            ScrollingFrame.BackgroundTransparency = 1
            ScrollingFrame.ScrollBarThickness = 8
            ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(31, 31, 31)
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

            local UIGridLayout = Instance.new("UIGridLayout")
            UIGridLayout.Parent = ScrollingFrame
            UIGridLayout.CellSize = UDim2.new(0.9, 0, 0.18, 0)
            UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            for _, info in ipairs(universalScripts) do
                local Template = Instance.new("Frame")
                Template.Parent = ScrollingFrame
                Template.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                Template.BorderSizePixel = 0

                local Btn = Instance.new("TextButton")
                Btn.Parent = Template
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundTransparency = 1
                Btn.Text = "▶ " .. info.Name
                Btn.Font = Enum.Font.Gotham
                Btn.TextScaled = true
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

                Btn.MouseButton1Click:Connect(function()
                    SelectedScript = info
                    LastUpdate.Text = "✓ " .. info.Name
                end)
            end

            LoadButton.MouseButton1Click:Connect(function()
                if not SelectedScript then
                    NotificationLib:Warning("⚠️ No Script", "Select a script first", 4)
                    return
                end
                loadstring(game:HttpGet(SelectedScript.URL))()
                ScreenGui:Destroy()
            end)
        end
        
        return true
    else
        local handler = Handlers[code]
        if handler then
            handler(data)
        else
            NotificationLib:Error(
                "❌ Authentication Error",
                "Error code: " .. tostring(code) .. "\n\nDiscord: " .. CONFIG.DISCORD_INVITE,
                15,
                Utilities.CopyDiscord
            )
        end
        return false
    end
end

-- ═══════════════════════════════════════════════════════════════
-- INICIO
-- ═══════════════════════════════════════════════════════════════

NotificationLib:Info(
    "🎮 " .. gameInfo.Name,
    "Executor: " .. executor .. "\nDevice: " .. deviceType .. "\nHWID: " .. hwid:sub(1, 16) .. "...\nLoading " .. CONFIG.SCRIPT_NAME .. "...",
    5
)

task.delay(0.6, Authenticate)
