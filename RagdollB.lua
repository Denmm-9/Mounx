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

   local active = false
   local loop = nil

   button.MouseButton1Click:Connect(function()
       active = not active
       button.BackgroundColor3 = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)

       if active then
           loop = game:GetService("RunService").Heartbeat:Connect(function()
               pcall(remoteFunction) 
           end)
       else
           if loop then
               loop:Disconnect()
               loop = nil
           end
       end
   end)
end

createButton("Farm", 0.1, function()

getgenv().KillAura = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local dataRemoteEvent = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
local killAuraRange = 27 

local function executeKillAura(targetPlayer, tool)
    local toolName = tool.Name  
    local args = {
        [1] = {
            [1] = {toolName .. "Hit"}, 
            [2] = "\4",  
            [3] = {
                [1] = targetPlayer.Character,
                [2] = toolName  
            },
            [4] = "\6" 
        }
    }

    dataRemoteEvent:FireServer(unpack(args))
end

while true do
    if getgenv().KillAura then 
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if player == game.Players.LocalPlayer then
                    continue
                end

                local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

                local character = game.Players.LocalPlayer.Character
                local tool = character:FindFirstChildOfClass("Tool")

                if distance < killAuraRange and tool then
                    executeKillAura(player, tool) 
                end
            end
        end
    end
    wait(0.1)
end
end)
