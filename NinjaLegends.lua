local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

-- Configuración del ScreenGui
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Configuración del MainFrame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.Position = UDim2.new(0.8, 0, 0.5, -100)
MainFrame.Size = UDim2.new(0, 160, 0, 230)
MainFrame.Active = true
MainFrame.Draggable = true

-- Bordes redondeados para el MainFrame
UICorner.Parent = MainFrame

-- Función para crear botones reutilizables
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

   -- Bordes redondeados para el botón
   local buttonCorner = Instance.new("UICorner")
   buttonCorner.Parent = button

   -- Estado y funcionalidad del botón
   local active = false
   local loop = nil

   button.MouseButton1Click:Connect(function()
       active = not active
       button.BackgroundColor3 = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)

       if active then
           loop = game:GetService("RunService").Heartbeat:Connect(function()
               pcall(remoteFunction) -- Ejecuta la función remota de forma segura
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

local args = {
    [1] = "swingKatana"
}

game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(unpack(args))
end)

createButton("AutoCoins", 0.3, function()

local player = game.Players.LocalPlayer
local playerBody = workspace:FindFirstChild(player.Name) -- Variable con tu cuerpo en Workspace

local spawnLocations = {
    workspace.coinSpawns.Valley,
    workspace.coinSpawns["Duel Arena"]
}

for _, location in pairs(spawnLocations) do
    for _, v in pairs(location:GetChildren()) do
        if v:IsA("BasePart") then -- Asegura que sea una parte física
            wait(0.2)
            firetouchinterest(v, playerBody.PrimaryPart, 1) -- Touch begin
            wait(0.1)
            firetouchinterest(v, playerBody.PrimaryPart, 0) -- Touch end
        end
    end
end
end)

createButton("AutoHoops", 0.5, function()

local args = {
    [1] = "useHoop",
    [2] = workspace.Hoops.Hoop
}
game:GetService("ReplicatedStorage").rEvents.hoopEvent:FireServer(unpack(args))
end)

createButton("UnlockAllIslands", 0.7, function()

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

for _,v in pairs(workspace.islandUnlockParts:GetChildren()) do
    firetouchinterest(player.character, v, 0)
    end
    end)

createButton("AllChest", 0.9, function()

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local touchedParts = {}

local function setupFireTouchForChests()
    for _, model in pairs(workspace:GetChildren()) do
        -- Filtra solo modelos con "Chest" en el nombre
        if model:IsA("Model") and string.find(model.Name, "Chest") then
            local circleInner = model:FindFirstChild("circleInner", true)
            if circleInner then
                if not touchedParts[circleInner] then
                    touchedParts[circleInner] = true
                    firetouchinterest(circleInner, character.PrimaryPart, 1) -- Touch begin
                    wait(0.1)
                    firetouchinterest(circleInner, character.PrimaryPart, 0) -- Touch end
                end
            end
        end
    end
end

if not character.PrimaryPart then
    character:GetPropertyChangedSignal("PrimaryPart"):Wait()
end

setupFireTouchForChests()
end)
