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
MainFrame.Size = UDim2.new(0, 140, 0, 50)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.Parent = MainFrame

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local BiteEvent = ReplicatedStorage:WaitForChild("ServerEvents"):WaitForChild("Bite")

local KillRange = 25
local isRunning = false  
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local function bitePlayer(targetCharacter)
    local humanoid = targetCharacter:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end  

    local bodyParts = {
        "HumanoidRootPart",  
        "Head",              
        "Torso",            
    }

    local legsFolder = targetCharacter:FindFirstChild("Legs")
    if legsFolder then
        for _, legPart in pairs(legsFolder:GetChildren()) do
            if legPart:IsA("Model") then
                for _, subPart in pairs(legPart:GetChildren()) do
                    if subPart:IsA("Part") then
                        table.insert(bodyParts, subPart.Name)
                    end
                end
            end
        end
    end

    for _, partName in ipairs(bodyParts) do
        local part = targetCharacter:FindFirstChild(partName)
        if part then
            local args = {
                [1] = "Bite",
                [2] = humanoid,
                [3] = part
            }
            BiteEvent:FireServer(unpack(args))
            print("Mordido en: " .. partName .. " de " .. targetCharacter.Name)
        end
    end
end

local function biteQueens()
    local chambersFolder = Workspace:FindFirstChild("Map"):FindFirstChild("Chambers")
    if not chambersFolder then return end
   
    local nations = {
        "Concrete Clan",
        "Fire Nation",
        "Golden Empire",
        "Leaf Kingdom"
    }

    for _, nationName in ipairs(nations) do
        local nation = chambersFolder:FindFirstChild(nationName)
        if nation then
            local queen = nation:FindFirstChild("Queen")
            if queen and queen:FindFirstChild("HumanoidRootPart") then
                local queenHumanoid = queen:FindFirstChild("Humanoid")
                local queenRootPart = queen:FindFirstChild("HumanoidRootPart")

                if queenHumanoid and queenRootPart then
                    local distance = (HumanoidRootPart.Position - queenRootPart.Position).Magnitude

                    if distance <= KillRange and queenHumanoid.Health > 0 then
                        local args = {
                            [1] = "Bite",
                            [2] = queenHumanoid,
                            [3] = queenRootPart
                        }
                        BiteEvent:FireServer(unpack(args))
                        print("Mordida la Reina de: " .. nationName)
                    end
                end
            end
        end
    end
end

local function startKillAura()
    isRunning = true  
    while isRunning do
      
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if player.Team ~= LocalPlayer.Team then
                    local targetRootPart = player.Character.HumanoidRootPart
                    local distance = (HumanoidRootPart.Position - targetRootPart.Position).Magnitude

                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 and distance <= KillRange then
                        bitePlayer(player.Character)
                    end
                end
            end
        end

        biteQueens() 
        wait(0.1) 
    end
end

local function stopKillAura()
    isRunning = false 
end

local function toggleKillAura()
    if isRunning then
        stopKillAura()  
    else
        startKillAura()  
    end
end

LocalPlayer.CharacterAdded:Connect(function()

    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

local function createButton(name, position)
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

        toggleKillAura()  
    end)
end

createButton("KillAura", 0.2)
