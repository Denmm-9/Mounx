if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait(0.5)
end

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LIST_URL = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/Game_list.lua"

-- Universal scripts
local UNIVERSAL = {
    pc = {
        "https://raw.githubusercontent.com/Denmm-9/Universal/main/NonUniversal.lua",
        "https://raw.githubusercontent.com/Denmm-9/Universal/main/SilentAimV2.lua",
    },
    mobile = "https://raw.githubusercontent.com/Denmm-9/Universal/main/MobileUniversal.lua"
}

-- Detectar dispositivo
local function detectDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "mobile"
    end
    return "pc"
end

local device = detectDevice()
print("[Loader] Device:", device)

-- Cargar tabla de juegos remota
local function fetchGameList(url)
    local ok, resp = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil end

    local ok2, chunk = pcall(function() return loadstring(resp)() end)
    if not ok2 or type(chunk) ~= "table" then
        return nil
    end
    return chunk
end

local games = fetchGameList(LIST_URL)

local function loadRemoteScript(url)
    if not url then return end
    local ok, resp = pcall(function() return game:HttpGet(url) end)
    if not ok then warn("Download failed:", resp) return end
    local ok2, err = pcall(function() loadstring(resp)() end)
    if not ok2 then warn("Error:", err) end
end

local function tryLoadFromList(gamesTable)
    if not gamesTable then return false end
    for placeId, data in pairs(gamesTable) do
        if tonumber(placeId) == tonumber(game.PlaceId) then
            if type(data) == "table" then
                local url = data[device]
                if url then
                    print("[Loader] Loading specific script:", url)
                    loadRemoteScript(url)
                    return true
                end
            elseif type(data) == "string" then
                loadRemoteScript(data)
                return true
            end
        end
    end
    return false
end

local loaded = tryLoadFromList(games)

-- Si no se encontró el juego
if not loaded then
    print("[Loader] Game not found in list")

    if device == "mobile" then
        -- Cargar universal móvil directamente
        loadRemoteScript(UNIVERSAL.mobile)
        return
    end

--UI
    local player = Players.LocalPlayer
    local parent = (RunService:IsStudio() and player.PlayerGui) or game.CoreGui

    local function new(Class, props)
        local inst = Instance.new(Class)
        for k,v in pairs(props) do inst[k] = v end
        return inst
    end

    local ui = new("ScreenGui", { Name="UniversalPC", Parent=parent })
    local frame = new("Frame", {
        Size = UDim2.new(0, 300, 0, 220),
        Position = UDim2.new(0.5, -150, 0.5, -110),
        BackgroundColor3 = Color3.fromRGB(16,16,16),
        BorderSizePixel = 0,
        Parent = ui
    })
    new("UICorner", { CornerRadius = UDim.new(0,6), Parent=frame })

    local title = new("TextLabel", {
        Size = UDim2.new(1,0,0,40),
        BackgroundColor3 = Color3.fromRGB(22,22,22),
        Text = "Universal Loader - PC",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextScaled = true,
        Parent = frame
    })
    new("UICorner", { CornerRadius = UDim.new(0,6), Parent=title })

    local scroll = new("ScrollingFrame", {
        Size = UDim2.new(1,-20,1,-80),
        Position = UDim2.new(0,10,0,50),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 6,
        BackgroundTransparency = 1,
        Parent = frame
    })

    local layout = new("UIListLayout", { Padding = UDim.new(0,6), Parent=scroll })
    local selected

    for i, url in ipairs(UNIVERSAL.pc) do
        local btn = new("TextButton", {
            Size = UDim2.new(1,0,0,40),
            BackgroundColor3 = Color3.fromRGB(30,30,30),
            Text = "Script "..i,
            TextColor3 = Color3.fromRGB(255,255,255),
            TextScaled = true,
            Parent = scroll
        })
        new("UICorner", { CornerRadius = UDim.new(0,4), Parent=btn })

        btn.MouseButton1Click:Connect(function()
            selected = url
            for _, b in ipairs(scroll:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        end)
    end

    local loadBtn = new("TextButton", {
        Size = UDim2.new(0.9,0,0,40),
        Position = UDim2.new(0.05,0,1,-45),
        BackgroundColor3 = Color3.fromRGB(24,24,24),
        Text = "Load Selected",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextScaled = true,
        Parent = frame
    })
    new("UICorner", { CornerRadius = UDim.new(0,4), Parent=loadBtn })

    loadBtn.MouseButton1Click:Connect(function()
        if not selected then
            loadBtn.Text = "Select a script first!"
            task.wait(1)
            loadBtn.Text = "Load Selected"
            return
        end
        ui:Destroy()
        loadRemoteScript(selected)
    end)
end
