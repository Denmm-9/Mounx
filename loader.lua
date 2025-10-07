if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait(1)
end

local UIS = game:GetService("UserInputService")
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local deviceType = isMobile and "mobile" or "pc"

local ListURL = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/Game_list.lua"

local success, result = pcall(function()
    return loadstring(game:HttpGet(ListURL))()
end)

if not success then
    warn("❌ Error loading Game_list:", result)
    return
end

local games = result
local loadedGame = false

for placeId, data in pairs(games) do
    if game.PlaceId == placeId then
        local scriptUrl = nil
        if type(data) == "table" then
            scriptUrl = data[deviceType] or data.pc or data.mobile
        elseif type(data) == "string" then
            scriptUrl = data
        end

        if scriptUrl then
            print("🔹 Loading game-specific script for", deviceType, ":", game.PlaceId)
            loadstring(game:HttpGet(scriptUrl))()
            loadedGame = true
        end
        break
    end
end

if not loadedGame then
    print("🌍 No game found in Game_list. Showing universal script selector for:", deviceType)

    local universalScripts = {}
    if deviceType == "pc" then
        universalScripts = {
            { Name = "NonUniversal.lua", URL = "https://raw.githubusercontent.com/Denmm-9/Universal/main/NonUniversal.lua" },
            { Name = "SilentAimV2.lua", URL = "https://raw.githubusercontent.com/Denmm-9/Universal/main/SilentAimV2.lua" },
        }
    elseif deviceType == "mobile" then
        universalScripts = {
            { Name = "MobileUniversal.lua", URL = "https://raw.githubusercontent.com/Denmm-9/Universal/main/MobileUniversal.lua" },
        }
    end

    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")

    ScreenGui.Name = "UniversalSelector"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")

    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 300, 0, 150 + (#universalScripts * 50))
    Frame.Position = UDim2.new(0.5, -150, 0.5, -Frame.Size.Y.Offset/2)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BorderSizePixel = 0
    Frame.BackgroundTransparency = 0.1
    Frame.ClipsDescendants = true
    Frame.Active = true

    Title.Parent = Frame
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Title.Text = "🌐 Universal Script Selector"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Frame
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)

    for i, scriptInfo in ipairs(universalScripts) do
        local Button = Instance.new("TextButton")
        Button.Parent = Frame
        Button.Size = UDim2.new(0.8, 0, 0, 40)
        Button.Position = UDim2.new(0.1, 0, 0, 50 * i)
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        Button.Text = "▶️ " .. scriptInfo.Name
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.AutoButtonColor = true
        Button.BackgroundTransparency = 0.05
        Button.BorderSizePixel = 0

        Button.MouseEnter:Connect(function()
            Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end)
        Button.MouseLeave:Connect(function()
            Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end)

        Button.MouseButton1Click:Connect(function()
            print("⚡ Loading universal script:", scriptInfo.Name)
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet(scriptInfo.URL))()
                end)
            end)
            ScreenGui:Destroy()
        end)
    end
end
