-- Servicios
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.Position = UDim2.new(0.8, 0, 0.5, -100)
MainFrame.Size = UDim2.new(0, 140, 0, 160)
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

createButton("Kill All Zombie", 0.1, function(state)
    getgenv().zombieAura = state

    if state then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local CastRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("CastRemote")
        local StageMonsters = workspace:WaitForChild("Stage_Monster")
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer

        local attackDelay = 0.05
        local attacksPerCycle = 10

        task.spawn(function()
            while getgenv().zombieAura do
                local character = workspace:FindFirstChild(localPlayer.Name)
                local count = 0

                for _, zombie in ipairs(StageMonsters:GetChildren()) do
                    if zombie:IsA("Model") and zombie:FindFirstChild("Head") and character then
                        count += 1
                        task.spawn(function()
                            local head = zombie.Head
                            local args = {
                                [1] = {
                                    ["CF"] = head.CFrame,
                                    ["Part"] = head,
                                    ["Owner"] = localPlayer,
                                    ["TargetHead"] = true,
                                    ["Character"] = character,
                                    ["Hit"] = head,
                                    ["Target"] = zombie,
                                    ["position"] = head.Position,
                                    ["normal"] = Vector3.new(0, 1, 0),
                                    ["Damage"] = 900
                                }
                            }
                            pcall(function()
                                CastRemote:FireServer(unpack(args))
                            end)
                        end)

                        if count >= attacksPerCycle then
                            break
                        end
                    end
                end

                task.wait(attackDelay)
            end
        end)
    end
end)
