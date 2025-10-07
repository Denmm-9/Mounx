-- loader.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait(0.5)
end

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- URL del game list (usa raw)
local LIST_URL = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/Game_list.lua"

-- URLs universales (modifícalas con tus scripts universales)
local UNIVERSAL = {
    pc = "https://raw.githubusercontent.com/Denmm-9/Universal/main/NonUniversal.lua",
        "https://raw.githubusercontent.com/Denmm-9/Universal/main/SilentAimV2.lua",
    mobile = "https://raw.githubusercontent.com/Denmm-9/Universal/main/MobileUniversal.lua",
}

-- Detectar dispositivo (bastante fiable para PC vs Mobile)
local function detectDevice()
    -- TouchEnabled sin teclado físico => mobile
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "mobile"
    end
    return "pc"
end

local device = detectDevice()
print("[Loader] Detected device:", device)

-- Cargar tabla de juegos remota de forma segura
local function fetchGameList(url)
    local ok, resp = pcall(function() return game:HttpGet(url) end)
    if not ok then
        warn("[Loader] HttpGet failed:", resp)
        return nil
    end

    local ok2, chunk = pcall(function() return loadstring(resp)() end)
    if not ok2 then
        warn("[Loader] loadstring failed:", chunk)
        return nil
    end

    if type(chunk) ~= "table" then
        warn("[Loader] Game list did not return a table")
        return nil
    end

    return chunk
end

local games = fetchGameList(LIST_URL)

-- Decide qué hacer: si games es nil o vacío mostramos prompt universal
local function isTableEmpty(t)
    if not t then return true end
    for _ in pairs(t) do return false end
    return true
end

local function loadRemoteScript(url)
    if not url then
        warn("[Loader] No url provided to load")
        return
    end
    local ok, resp = pcall(function() return game:HttpGet(url) end)
    if not ok then
        warn("[Loader] Failed to download script:", resp)
        return
    end
    local ok2, err = pcall(function() loadstring(resp)() end)
    if not ok2 then
        warn("[Loader] Error running script:", err)
    end
end

-- Si hay una coincidencia directa con PlaceId, cargarla
local function tryLoadFromList(gamesTable)
    if not gamesTable then return false end
    for placeId, data in pairs(gamesTable) do
        if tonumber(placeId) == tonumber(game.PlaceId) then
            -- si data es tabla -> data.pc / data.mobile
            if type(data) == "table" then
                local url = data[device]
                if url then
                    print("[Loader] Loading game script for device:", device)
                    loadRemoteScript(url)
                    return true
                else
                    warn("[Loader] Este juego no tiene script para este dispositivo.")
                    return false
                end
            elseif type(data) == "string" then
                print("[Loader] Loading single script for this place")
                loadRemoteScript(data)
                return true
            end
        end
    end
    return false
end

local loaded = tryLoadFromList(games)

-- Si no se cargó (no está en la lista o la lista está vacía), mostrar GUI universal
if not loaded then
    -- Si la lista está vacía o no existe mostramos prompt
    if isTableEmpty(games) then
        print("[Loader] Game list empty or unavailable. Showing universal prompt.")
    else
        print("[Loader] PlaceId not in list. Showing universal prompt.")
    end

    -- Simple GUI
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

    local pcBtn = Instance.new("TextButton", frame)
    pcBtn.Size = UDim2.new(0.44, 0, 0, 50)
    pcBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
    pcBtn.Text = "PC"
    pcBtn.TextScaled = true
    pcBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    pcBtn.TextColor3 = Color3.fromRGB(255,255,255)

    local mobBtn = Instance.new("TextButton", frame)
    mobBtn.Size = UDim2.new(0.44, 0, 0, 50)
    mobBtn.Position = UDim2.new(0.51, 0, 0.45, 0)
    mobBtn.Text = "Mobile"
    mobBtn.TextScaled = true
    mobBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    mobBtn.TextColor3 = Color3.fromRGB(255,255,255)

    local hint = Instance.new("TextLabel", frame)
    hint.Size = UDim2.new(1, -20, 0, 28)
    hint.Position = UDim2.new(0, 10, 0.82, 0)
    hint.BackgroundTransparency = 1
    hint.Text = "Choose which universal script to load."
    hint.TextColor3 = Color3.fromRGB(200,200,200)
    hint.TextScaled = true

    local function onChoice(selectedDevice)
        screenGui:Destroy()
        local url = UNIVERSAL[selectedDevice]
        if not url then
            warn("[Loader] No universal script URL configured for:", selectedDevice)
            return
        end
        print("[Loader] Loading universal script for:", selectedDevice)
        loadRemoteScript(url)
    end

    pcBtn.MouseButton1Click:Connect(function() onChoice("pc") end)
    mobBtn.MouseButton1Click:Connect(function() onChoice("mobile") end)
end
