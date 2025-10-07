-- loader.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait(0.5)
end

local UserInputService = game:GetService("UserInputService")

local LIST_URL = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/Game_list.lua"

-- Soporte para múltiples scripts por dispositivo
local UNIVERSAL = {
    pc = {
        "https://raw.githubusercontent.com/Denmm-9/Universal/main/NonUniversal.lua",
        "https://raw.githubusercontent.com/Denmm-9/Universal/main/SilentAimV2.lua"
    },
    mobile = {
        "https://raw.githubusercontent.com/Denmm-9/Universal/main/MobileUniversal.lua"
    }
}

-- Detección del dispositivo
local function detectDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "mobile"
    end
    return "pc"
end

local device = detectDevice()
print("[Loader] Detected device:", device)

-- Función para obtener tabla de juegos remota
local function fetchGameList(url)
    local ok, resp = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil end
    local ok2, chunk = pcall(function() return loadstring(resp)() end)
    if not ok2 or type(chunk) ~= "table" then return nil end
    return chunk
end

local games = fetchGameList(LIST_URL)

-- Función para ejecutar scripts remotos
local function loadRemoteScript(url)
    local ok, resp = pcall(function() return game:HttpGet(url) end)
    if not ok then return warn("[Loader] Failed:", resp) end
    local ok2, err = pcall(function() loadstring(resp)() end)
    if not ok2 then warn("[Loader] Error:", err) end
end

-- Si hay coincidencia de juego
local function tryLoadFromList(gamesTable)
    if not gamesTable then return false end
    for placeId, data in pairs(gamesTable) do
        if tonumber(placeId) == tonumber(game.PlaceId) then
            local url = type(data) == "table" and data[device] or data
            if not url then
                warn("[Loader] No script for this device.")
                return false
            end
            print("[Loader] Loading game script:", url)
            loadRemoteScript(url)
            return true
        end
    end
    return false
end

local loaded = tryLoadFromList(games)

-- Si no hay script en lista, muestra GUI universal
if not loaded then
    local player = game:GetService("Players").LocalPlayer
    local parent = (game:GetService("RunService"):IsStudio() and player.PlayerGui) or game.CoreGui

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UniversalLoaderPrompt"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parent

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 320, 0, 180)
    frame.Position = UDim2.new(0.5, -160, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Universal Loader - Select Device"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextScaled = true

    local function createButton(text, pos, deviceType)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.44, 0, 0, 50)
        btn.Position = pos
        btn.Text = text
        btn.TextScaled = true
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.MouseButton1Click:Connect(function()
            screenGui:Destroy()
            local urls = UNIVERSAL[deviceType]
            if not urls then return warn("[Loader] No URLs for:", deviceType) end
            print("[Loader] Loading universal scripts for:", deviceType)
            for _, link in ipairs(urls) do
                loadRemoteScript(link)
            end
        end)
    end

    createButton("PC", UDim2.new(0.05, 0, 0.45, 0), "pc")
    createButton("Mobile", UDim2.new(0.51, 0, 0.45, 0), "mobile")

    local hint = Instance.new("TextLabel", frame)
    hint.Size = UDim2.new(1, -20, 0, 28)
    hint.Position = UDim2.new(0, 10, 0.82, 0)
    hint.BackgroundTransparency = 1
    hint.Text = "Choose which universal script to load."
    hint.TextColor3 = Color3.fromRGB(200,200,200)
    hint.TextScaled = true
end
