repeat task.wait(0.1) until game:IsLoaded()

-- ═══════════════════════════════════════════════════════════════
-- DECODIFICADOR DE CONFIGURACIÓN OFUSCADA
-- ═══════════════════════════════════════════════════════════════

local function decode(data)
    local result = {}
    for i = 1, #data, 2 do
        local code = tonumber(data:sub(i, i + 1), 16)
        if code then
            table.insert(result, string.char(code))
        end
    end
    return table.concat(result)
end

local function xorDecode(data, key)
    local result = {}
    local keyLen = #key
    for i = 1, #data do
        local byte = string.byte(data, i)
        local keyByte = string.byte(key, ((i - 1) % keyLen) + 1)
        table.insert(result, string.char(bit32.bxor(byte, keyByte)))
    end
    return table.concat(result)
end

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURACIÓN OFUSCADA (EDITAR ESTO)
-- ═══════════════════════════════════════════════════════════════
-- Para ofuscar tu configuración:
-- 1. Convierte tu URL a hexadecimal
-- 2. Convierte tu API Secret a hexadecimal
-- Ejemplo: "https://example.com" -> "68747470733a2f2f6578616d706c652e636f6d"

local CONFIG_OBFUSCATED = {
    -- URL del panel (hex encoded) - REEMPLAZA CON TU URL
    -- Ejemplo: https://tu-panel.space.z.ai/api/verify
    _u = "ACTUALIZA_ESTO_CON_TU_URL_EN_HEX",
    
    -- URL para reset HWID (hex encoded)
    _r = "ACTUALIZA_ESTO_CON_TU_URL_RESET_EN_HEX",
    
    -- API Secret (hex encoded) - OBLIGATORIO si generaste uno en el panel
    _s = "",
    
    -- Clave XOR para extra seguridad (puedes cambiarla)
    _k = "5a454b4548554232303234",  
}

-- Decodificar configuración
local function getConfig()
    local key = decode(CONFIG_OBFUSCATED._k)
    
    local url = CONFIG_OBFUSCATED._u
    if url:find("ACTUALIZA") then
        url = ""  -- Sin configurar
    else
        url = decode(url)
    end
    
    local resetUrl = CONFIG_OBFUSCATED._r
    if resetUrl:find("ACTUALIZA") then
        resetUrl = ""
    else
        resetUrl = decode(resetUrl)
    end
    
    local secret = ""
    if CONFIG_OBFUSCATED._s ~= "" then
        secret = decode(CONFIG_OBFUSCATED._s)
    end
    
    return {
        API_URL = url,
        RESET_URL = resetUrl,
        API_SECRET = secret,
        SCRIPT_NAME = "Mounx",
        DISCORD_INVITE = "",
    }
end

-- ═══════════════════════════════════════════════════════════════
-- VERSIÓN SIMPLE (SI NO QUIERES OFUSCAR)
-- ═══════════════════════════════════════════════════════════════

local CONFIG_SIMPLE = {
    -- Tu URL del panel (obtenla del Preview Panel)
    API_URL = "https://preview-chat-83ea5622-7795-4219-b50e-23f212104690.space.z.ai/api/verify",
    RESET_URL = "https://preview-chat-83ea5622-7795-4219-b50e-23f212104690.space.z.ai/api/hwid",
    
    -- API Secret (IMPORTANTE: Pon el que generes en el panel Dashboard)
    API_SECRET = "",
    
    SCRIPT_NAME = "Mounx",
    DISCORD_INVITE = "",
}

-- USAR CONFIGURACIÓN SIMPLE (cambia a false para usar ofuscada)
local USE_OBFUSCATED = false

local CONFIG = USE_OBFUSCATED and getConfig() or CONFIG_SIMPLE

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
-- OBTENER HWID
-- ═══════════════════════════════════════════════════════════════

local function getHWID()
    -- Synapse X
    if syn and syn.gethwid then
        return syn.gethwid()
    end
    
    -- Script-Ware
    if gethwid then
        return gethwid()
    end
    
    -- Otros executors comunes
    if hwid then
        return hwid
    end
    
    if get_hwid then
        return get_hwid()
    end
    
    -- Fallback para executors sin HWID
    local hash = 0
    local str = Player.Name .. tostring(Player.UserId) .. game.JobId
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 2147483647
    end
    return string.format("GEN-%08X-%08X", hash, hash * 17 % 2147483647)
end

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
    
    -- Synapse X
    if syn and syn.request then
        return syn.request(options)
    end
    
    -- Script-Ware / Universal
    if request then
        return request(options)
    end
    
    -- HttpService estándar
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
-- VERIFICACIÓN DE KEY CON API SECRET
-- ═══════════════════════════════════════════════════════════════

local function verificarKey()
    if not script_key then
        NotificationLib:Error(
            "Authentication Failed",
            "No key provided\nCheck your key and try again\n\nClick to copy Discord invite",
            10,
            Utilities.CopyDiscord
        )
        return false, "NO_KEY"
    end
    
    local hwid = getHWID()
    local playerName = Player.Name
    local playerId = tostring(Player.UserId)
    
    -- Construir payload con idUser (nombre de Roblox)
    local data = {
        key = script_key,
        idUser = playerName,          -- CAMBIADO: era robloxUser
        robloxUserId = playerId,
        hwid = hwid,
        executor = executor,
        deviceType = deviceType,
        secret = CONFIG.API_SECRET
    }
    
    local body = HttpService:JSONEncode(data)
    
    local authNotif = NotificationLib:Info("Authenticating", "Verifying license key...", 20)
    local response = httpRequest(CONFIG.API_URL, "POST", body)
    authNotif:Destroy()
    
    if not response or response.StatusCode ~= 200 then
        NotificationLib:Error(
            "Connection Error",
            "Could not connect to server\nTry again later\n\nClick to copy Discord invite",
            10,
            Utilities.CopyDiscord
        )
        return false, "CONNECTION_ERROR"
    end
    
    local result = HttpService:JSONDecode(response.Body)
    return result.success, result.code, result
end

local function solicitarResetHwid(reason)
    if not script_key then
        NotificationLib:Error("Error", "No key provided", 6)
        return false
    end
    
    local data = {
        key = script_key,
        reason = reason or "Requested from client",
        secret = CONFIG.API_SECRET
    }
    
    local body = HttpService:JSONEncode(data)
    local response = httpRequest(CONFIG.RESET_URL, "POST", body)
    
    if response and response.StatusCode == 200 then
        local result = HttpService:JSONDecode(response.Body)
        return result.success, result.message or result.error
    end
    
    return false, "Connection error"
end

-- ═══════════════════════════════════════════════════════════════
-- HANDLERS DE RESPUESTA
-- ═══════════════════════════════════════════════════════════════

local Handlers = {}

Handlers.KEY_VALID = function(data)
    local player = Player
    local timeLeft = Utilities.FormatDuration(data.auth_expire > 0 and (data.auth_expire - os.time()) or -1)
    
    local details = {
        "Executions: " .. tostring(data.total_executions),
        "Expires: " .. timeLeft,
        "Device: " .. deviceType,
        "Executor: " .. executor
    }
    
    if data.note and data.note ~= "" then
        table.insert(details, "Note: " .. data.note)
    end
    
    NotificationLib:Success(
        "Welcome, " .. player.DisplayName,
        table.concat(details, "\n"),
        8
    )
    
    return true
end

Handlers.KEY_HWID_LOCKED = function(data)
    NotificationLib:Warning(
        "HWID Mismatch",
        "This key is linked to another device\nReset via Dashboard or Discord bot\n\nClick to copy Discord invite",
        12,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.KEY_EXPIRED = function()
    NotificationLib:Error(
        "Subscription Expired",
        "Your key has expired\nRenew to continue using " .. CONFIG.SCRIPT_NAME .. "\n\nClick to copy Discord invite",
        12,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.KEY_BANNED = function()
    NotificationLib:Error(
        "Access Revoked",
        "This key has been blacklisted\nContact support if you believe this is an error\n\nClick to copy Discord invite",
        12,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.KEY_INCORRECT = function()
    Utilities.CopyDiscord()
    NotificationLib:Error(
        "Invalid Key",
        "Key not found in database\nDiscord invite copied to clipboard\n\nClick to copy again",
        12,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.HWID_REQUIRED = function()
    NotificationLib:Error(
        "HWID Required",
        "Could not detect your HWID\nTry using a different executor\n\nClick to copy Discord invite",
        12,
        Utilities.CopyDiscord
    )
    return false
end

Handlers.UNAUTHORIZED = function()
    NotificationLib:Error(
        "Unauthorized",
        "Invalid API Secret\nContact the developer\n\nClick to copy Discord invite",
        12,
        Utilities.CopyDiscord
    )
    return false
end

-- ═══════════════════════════════════════════════════════════════
-- GAME LIST Y CARGA DE SCRIPTS
-- ═══════════════════════════════════════════════════════════════

local ListURL = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/Game_list.lua"
local success, result = pcall(function()
    return loadstring(game:HttpGet(ListURL))()
end)

if not success then
    NotificationLib:Error("Error", "Game list failed to load", 6)
    return
end

local games = result
local loadedGame = false

local gameInfo = Utilities.GetGameInfo()

local isInList = false
for placeId in pairs(games) do
    if game.PlaceId == placeId then
        isInList = true
        break
    end
end

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
        
        -- ═════════════════════════════════════════════════════════
        -- CARGAR SCRIPT DEL JUEGO
        -- ═════════════════════════════════════════════════════════
        
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
            Title.Text = "Universal Loader"
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
            LoadButton.Text = "Load"
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
                Btn.Text = "Select " .. info.Name
                Btn.Font = Enum.Font.Gotham
                Btn.TextScaled = true
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

                Btn.MouseButton1Click:Connect(function()
                    SelectedScript = info
                    LastUpdate.Text = "Selected: " .. info.Name
                end)
            end

            LoadButton.MouseButton1Click:Connect(function()
                if not SelectedScript then
                    NotificationLib:Warning("No Script", "Select a script first", 4)
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
                "Authentication Error",
                "Code: " .. tostring(code) .. "\nDiscord invite copied to clipboard\n\nClick to copy again",
                12,
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
    gameInfo.Name,
    "Executor: " .. executor .. "\nDevice: " .. deviceType .. "\nLoading " .. CONFIG.SCRIPT_NAME .. "...",
    5
)

task.delay(0.6, Authenticate)
