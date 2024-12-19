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
MainFrame.Size = UDim2.new(0, 150, 0, 160)
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

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local closestSnowPart = nil
    local closestHitPart = nil
    local closestDistanceSnow = math.huge 
    local closestDistanceHit = math.huge   


    for i = 1, 8 do
        local snowPart = workspace.HitParts:FindFirstChild("Snow" .. i)
        if snowPart then
            local distance = (humanoidRootPart.Position - snowPart.Position).Magnitude
            if distance < closestDistanceSnow then
                closestDistanceSnow = distance
                closestSnowPart = snowPart
            end
        end
    end


    for i = 1, 8 do
        local hitPart = workspace.HitParts:FindFirstChild("HitPart" .. i)
        if hitPart then
            local distance = (humanoidRootPart.Position - hitPart.Position).Magnitude
            if distance < closestDistanceHit then
                closestDistanceHit = distance
                closestHitPart = hitPart
            end
        end
    end

    if closestSnowPart then
        local args = {
            [1] = closestSnowPart,  
            [2] = "Snow8",       
            [3] = "GoldenFlame"    
        }
        game:GetService("ReplicatedStorage").Events.e8eGb8RgRXFcug8q:FireServer(unpack(args))
    end

    if closestHitPart then
        local args = {
            [1] = closestHitPart,  
            [2] = "Hit8",        
            [3] = "GoldenFlame"   
        }
        game:GetService("ReplicatedStorage").Events.e8eGb8RgRXFcug8q:FireServer(unpack(args))
    end
end)


createButton("AutoBuy", 0.3, function()
    local args = {
        [1] = workspace.Eggs:FindFirstChild("Golden Jungle Egg")
    }
    game:GetService("ReplicatedStorage").EggSystemRemotes.HatchServer:InvokeServer(unpack(args))
end)

createButton("Inf Gems", 0.5, function()

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")


    for _, gem in pairs(workspace.Gems.Gems:GetChildren()) do
        if gem:IsA("BasePart") or gem:IsA("MeshPart") then
       
            gem.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 2, 0) 
        end
    end
end)



