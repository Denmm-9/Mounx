-- Servicios
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Combat Remotes
local PlayerAttack = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PlayerAttack")
local PetAttack = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat"):WaitForChild("PetDamage")

-- Pet y Mobs
local mobsFolder = workspace:WaitForChild("Mobs")
local pet = workspace:WaitForChild("Mobs"):WaitForChild("Sea Serpent")
local petAttackCircle = ReplicatedStorage:WaitForChild("Mobs"):WaitForChild("Sea Serpent"):WaitForChild("Attacks"):WaitForChild("Body Slam"):WaitForChild("Circle")

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

local getgev = false
createButton("KillAura", 0.1, function(enabled)
    getgev = enabled
end)

local attackDelay = 0.25
task.spawn(function()
    while true do
        if getgev then
            local mobList = {}

            for _, mob in ipairs(mobsFolder:GetChildren()) do
                if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") then
                    table.insert(mobList, mob)
                end
            end

            if #mobList > 0 then
                PlayerAttack:FireServer(unpack({ [1] = mobList }))
                task.wait(0.02)

                PetAttack:FireServer(unpack({
                    [1] = pet,
                    [2] = "Body Slam",
                    [3] = petAttackCircle,
                    [4] = mobList
                }))
            end

            task.wait(attackDelay)
        else
            task.wait(0.05)
        end
    end
end)
