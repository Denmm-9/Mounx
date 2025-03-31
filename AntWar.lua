local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true 

-- Create the main UI
local Window = Library:CreateWindow({
    Title = "Mounx",
    Footer = "..",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local MainTab = Window:AddTab("Main Features", "user")
local SettingsTab = Window:AddTab("Config", "settings")
local KillAuraGroup = MainTab:AddLeftGroupbox("KillAura")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local BiteEvent = ReplicatedStorage:WaitForChild("ServerEvents"):WaitForChild("Bite")
local KillRange = 25
local isRunning = false

local MiscGroup = MainTab:AddLeftGroupbox('Misc')
local Chams = {}
local ChamsActive = false
local chamsColor = Color3.fromRGB(255, 105, 180)

local function createChams(player)
    if player == LocalPlayer or player.Team == LocalPlayer.Team then return end

    local function applyChams(character)
        if not character or character:FindFirstChild("Humanoid") == nil then return end
        
        if Chams[player] then
            Chams[player].Adornee = character
            return
        end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = chamsColor
        highlight.OutlineColor = Color3.fromRGB(255, 105, 180)
        highlight.FillTransparency = 0.7
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Parent = game:GetService("CoreGui") 
        Chams[player] = highlight
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.HealthChanged:Connect(function(health)
                if health <= 0 then
                    removeChams(player)
                end
            end)
        end
    end

    if player.Character then
        applyChams(player.Character)
    end

    -- Volver a aplicar cuando reaparezca
    player.CharacterAdded:Connect(function(character)
        if ChamsActive then
            task.wait(0.1) 
            applyChams(character)
        end
    end)
end

local function removeChams(player)
    if Chams[player] then
        Chams[player]:Destroy()
        Chams[player] = nil
    end
end

local function updateAllChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Chams[player] then
                Chams[player].FillColor = chamsColor
            end
        end
    end
end

MiscGroup:AddToggle('ChamsToggle', {
    Text = 'Chams',
    Default = false,
    Callback = function(Value)
        ChamsActive = Value
        if ChamsActive then
            for _, player in ipairs(Players:GetPlayers()) do
                createChams(player)
            end
        else
            for player, _ in pairs(Chams) do
                removeChams(player)
            end
        end
    end
}):AddColorPicker('ChamsColorPicker', {
    Default = chamsColor,
    Title = 'Select Chams Color',
    Transparency = 0.5,
    Callback = function(value)
        chamsColor = value
        updateAllChams()
    end
})

Players.PlayerAdded:Connect(function(player)
    if ChamsActive and player ~= LocalPlayer then
        createChams(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeChams(player)
end)

local originalUnload = UnloadScript
UnloadScript = function()
    for player, _ in pairs(Chams) do
        removeChams(player)
    end
    if originalUnload then
        originalUnload()
    end
end
 
local function bitePlayer(targetCharacter)
    local humanoid = targetCharacter:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end  

    for _, partName in ipairs({"HumanoidRootPart", "Head", "Torso"}) do
        local part = targetCharacter:FindFirstChild(partName)
        if part then
            BiteEvent:FireServer("Bite", humanoid, part)
        end
    end
end

local function biteQueens()
    local chambersFolder = Workspace:FindFirstChild("Map"):FindFirstChild("Chambers")
    if not chambersFolder then return end
    
    for _, nationName in ipairs({"Concrete Clan", "Fire Nation", "Golden Empire", "Leaf Kingdom"}) do
        local nation = chambersFolder:FindFirstChild(nationName)
        if nation then
            local queen = nation:FindFirstChild("Queen")
            if queen and queen:FindFirstChild("HumanoidRootPart") then
                local queenHumanoid = queen:FindFirstChild("Humanoid")
                if queenHumanoid and queenHumanoid.Health > 0 then
                    BiteEvent:FireServer("Bite", queenHumanoid, queen:FindFirstChild("HumanoidRootPart"))
                end
            end
        end
    end
end

local function startKillAura()
    isRunning = true
    task.spawn(function()
        while isRunning do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if player.Team ~= LocalPlayer.Team then
                        local targetRootPart = player.Character.HumanoidRootPart
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetRootPart.Position).Magnitude

                        if distance <= KillRange then
                            bitePlayer(player.Character)
                        end
                    end
                end
            end
            biteQueens()
            task.wait(0.1)
        end
    end)
end

KillAuraGroup:AddToggle("KillAura", {
    Text = "Enable KillAura",
    Default = false,
    Callback = function(state)
        isRunning = state
        if isRunning then
            startKillAura()
        end
    end
})

KillAuraGroup:AddSlider("Kill Range", {
    Text = "Kill Range",
    Default = KillRange,
    Min = 10,
    Max = 30,
    Rounding = 0,
    Callback = function(value)
        KillRange = value
    end
})

local SettingsGroup = SettingsTab:AddLeftGroupbox("Menu")

SettingsGroup:AddDivider()
SettingsGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "Delete", NoUI = true, Text = "Menu keybind" })

Library.ToggleKeybind = Options.MenuKeybind 

Options.MenuKeybind:OnChanged(function()
    Library:Notify('Menu toggle key changed to [' .. Options.MenuKeybind.Value .. ']')
end)

local function UnloadScript()
    isRunning = false
    
    Library:Unload()
end

SettingsGroup:AddButton("Unload", function()
    UnloadScript()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:BuildConfigSection(SettingsTab)

ThemeManager:ApplyToTab(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)

SaveManager:LoadAutoloadConfig()
