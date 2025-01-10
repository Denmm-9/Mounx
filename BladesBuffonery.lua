local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.Position = UDim2.new(0.8, 0, 0.5, -100)
MainFrame.Size = UDim2.new(0, 140, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.Parent = MainFrame

local function createButton(name, position, onClickFunction)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = MainFrame
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BackgroundTransparency = 0.3
    button.Position = UDim2.new(0.1, 0, position, 0)
    button.Size = UDim2.new(0.8, 0, 0, 30)
    button.Font = Enum.Font.SourceSansBold
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.Parent = button

    local active = false
    button.MouseButton1Click:Connect(function()
        active = not active
        button.BackgroundColor3 = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)
        pcall(onClickFunction, active) 
    end)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().KillAuraEnabled = false
getgenv().HitAllPlayers = false
local killAuraRadius = 50 

local function findWeapon()
    local backpack = game:GetService("Players").LocalPlayer.Backpack
    for _, item in pairs(backpack:GetChildren()) do
        if item:FindFirstChild("Events") and item.Events:FindFirstChild("Hit") then
            return item
        end
    end
    return nil
end

local function hitAllPlayers()
    if not getgenv().HitAllPlayers then return end

    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    local weapon = findWeapon()

    if not weapon then
        warn("No se encontró un arma válida en la mochila.")
        return
    end

    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local args = {
                [1] = player.Character.Humanoid
            }
            weapon.Events.Hit:FireServer(unpack(args))
        end
    end
end

local function HitAllLoop()
    while true do
        if getgenv().HitAllPlayers then
            hitAllPlayers()
        end
        task.wait(0.1)
    end
end

task.spawn(HitAllLoop)

local function getPlayersInRadius(rootPart)
    local playersInRadius = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if distance <= killAuraRadius then
                table.insert(playersInRadius, player)
            end
        end
    end
    return playersInRadius
end

local function KillAuraLoop()
    while true do
        if getgenv().KillAuraEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = LocalPlayer.Character.HumanoidRootPart

            local playersInRadius = getPlayersInRadius(rootPart)
            for _, player in ipairs(playersInRadius) do
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    local args = {
                        [1] = player.Character.Humanoid
                    }
                    game:GetService("Players").LocalPlayer.Character.CharacterEvents.Hit:FireServer(unpack(args))
                end
            end
        end
        task.wait(0.1) 
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
end)

createButton("KillAura", 0.1, function(active)
    getgenv().KillAuraEnabled = active
end)

createButton("HitAll", 0.5, function(active)
    getgenv().HitAllPlayers = active
end)

task.spawn(KillAuraLoop)
