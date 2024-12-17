local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local BiteEvent = ReplicatedStorage:WaitForChild("ServerEvents"):WaitForChild("Bite") 
local KillRange = 26 

local function bitePlayer(targetCharacter)
    local humanoid = targetCharacter:FindFirstChild("Humanoid")
    
    local bodyParts = {
        "HumanoidRootPart",  
        "Head",              
        "Torso",             
    }

    
    local function addLegParts(legFolder)
        for _, legPart in pairs(legFolder:GetChildren()) do
            if legPart:IsA("Model") then
                for _, subPart in pairs(legPart:GetChildren()) do
                    if subPart:IsA("Part") then
                        table.insert(bodyParts, subPart.Name)
                    end
                end
            end
        end
    end

    local legsFolder = targetCharacter:FindFirstChild("Legs")
    if legsFolder then
        addLegParts(legsFolder.LeftBackLeg)
        addLegParts(legsFolder.LeftFrontLeg)
        addLegParts(legsFolder.LeftMiddleLeg)
        addLegParts(legsFolder.RightBackLeg)
        addLegParts(legsFolder.RightFrontLeg)
        addLegParts(legsFolder.RightMiddleLeg)
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
        end
    end
end

local function biteQueen(nationName)
    local nation = workspace.Map.Chambers:FindFirstChild(nationName)
    if nation then
        local queen = nation:FindFirstChild("Queen")
        if queen and queen:FindFirstChild("Humanoid") and queen:FindFirstChild("HumanoidRootPart") then
            local humanoid = queen.Humanoid
            local rootPart = queen.HumanoidRootPart
            local args = {
                [1] = "Bite",
                [2] = humanoid,
                [3] = rootPart
            }
            BiteEvent:FireServer(unpack(args))
        end
    end
end

RunService.Heartbeat:Connect(function()
    local nations = {"Concrete Clan", "Fire Nation", "Golden Empire", "Leaf Kingdom"}

    for _, nationName in ipairs(nations) do
        local nation = workspace.Map.Chambers:FindFirstChild(nationName)
        if nation then
            local queen = nation:FindFirstChild("Queen")
            if queen and queen:FindFirstChild("HumanoidRootPart") then
                local distanceToQueen = (HumanoidRootPart.Position - queen.HumanoidRootPart.Position).Magnitude
                if distanceToQueen <= KillRange then
                    biteQueen(nationName) 
                end
            end
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        wait(0.1)
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRootPart = player.Character.HumanoidRootPart
            local distance = (HumanoidRootPart.Position - targetRootPart.Position).Magnitude

            if distance <= KillRange then
                bitePlayer(player.Character)
            end
        end
    end
end)
