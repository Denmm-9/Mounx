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

getgenv().KillAura = false

local function createRangeCircle(radius)
    local circle = Instance.new("Part")
    circle.Anchored = true
    circle.CanCollide = false
    circle.Shape = Enum.PartType.Ball
    circle.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
    circle.Color = Color3.fromRGB(255, 0, 0)
    circle.Material = Enum.Material.ForceField
    circle.Transparency = 0.7
    circle.Parent = workspace
    return circle
end

local rangeCircle = createRangeCircle(20) 

local function createButton(name, position, remoteFunction)
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

    local loop = nil

    button.MouseButton1Click:Connect(function()
        getgenv().KillAura = not getgenv().KillAura
        button.BackgroundColor3 = getgenv().KillAura and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)

        if getgenv().KillAura then
            loop = game:GetService("RunService").Heartbeat:Connect(remoteFunction)
            rangeCircle.Transparency = 0.3 
        else
            if loop then
                loop:Disconnect()
                loop = nil
            end
            rangeCircle.Transparency = 1
        end
    end)
end

local function killAuraLogic()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local dataRemoteEvent = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
    local killAuraRange = 20

    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

    if character and character:FindFirstChild("HumanoidRootPart") then
        rangeCircle.Position = character.HumanoidRootPart.Position
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            local tool = character:FindFirstChildOfClass("Tool")

            if distance < killAuraRange and tool then
                local toolName = tool.Name
                local args = {
                    [1] = {
                        [1] = {toolName .. "Hit"},
                        [2] = "\4",
                        [3] = {player.Character, toolName},
                        [4] = "\6"
                    }
                }
                dataRemoteEvent:FireServer(unpack(args))
            end
        end
    end
end

createButton("KillAura", 0.1, killAuraLogic)
