repeat
    task.wait()
until game:IsLoaded()
task.wait(1)

local NotificationLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/AccountBurner/Utility/refs/heads/main/NotificationLib"))()
local UIS = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local deviceType = isMobile and "Mobile" or "PC"

local gameName = "Unknown Game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    gameName = info.Name
end)

local executor = identifyexecutor and identifyexecutor() or "Unknown Executor"

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

local isInList = false
for placeId in pairs(games) do
    if game.PlaceId == placeId then
        isInList = true
        break
    end
end

if isInList then
    NotificationLib:Success(gameName, "Executor: "..executor, 3)
else
    NotificationLib:Error(gameName, "Game not supported", 3)
end

task.delay(0.6, function()
    if isInList then
        NotificationLib:Success("Welcome "..Player.DisplayName, "Device: "..deviceType, 4)
    else
        NotificationLib:Info(
            "Unsupported Game - Welcome", 
            "Executor: " .. executor .. "\n" .. "Device: " .. deviceType, 
            4
        )
    end
end)


for placeId, data in pairs(games) do
    if game.PlaceId == placeId then
        local scriptUrl = nil
        if type(data) == "table" then
            scriptUrl = data[deviceType:lower()] or data.pc or data.mobile
        elseif type(data) == "string" then
            scriptUrl = data
        end

        if scriptUrl then
            loadstring(game:HttpGet(scriptUrl))()
            loadedGame = true
        end
        break
    end
end

if not loadedGame then
    task.wait(5)
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
