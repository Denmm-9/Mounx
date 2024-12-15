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
MainFrame.Size = UDim2.new(0, 150, 0, 160)
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
    -- Obtener el jugador y su posición
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local closestSnowPart = nil
    local closestHitPart = nil
    local closestDistanceSnow = math.huge  -- Iniciamos con un valor muy alto
    local closestDistanceHit = math.huge   -- Iniciamos con un valor muy alto

    -- Iterar sobre las partes de Snow del 1 al 8 y encontrar la más cercana
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

    -- Iterar sobre las partes de HitParts del 1 al 8 y encontrar la más cercana
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

    -- Ahora ejecutamos la acción dependiendo de cuál esté más cerca del jugador
    if closestSnowPart then
        local args = {
            [1] = closestSnowPart,  -- La parte de nieve más cercana
            [2] = "Snow8",          -- Puedes ajustar esto según sea necesario
            [3] = "GoldenFlame"     -- El valor o tipo asociado al objeto
        }
        game:GetService("ReplicatedStorage").Events.e8eGb8RgRXFcug8q:FireServer(unpack(args))
    end

    if closestHitPart then
        local args = {
            [1] = closestHitPart,  -- La parte de HitPart más cercana
            [2] = "Hit8",          -- Puedes ajustar esto según sea necesario
            [3] = "GoldenFlame"    -- El valor o tipo asociado al objeto
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
    -- Obtener la posición del jugador local
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Iterar sobre todas las gemas en workspace.Gems.Gems
    for _, gem in pairs(workspace.Gems.Gems:GetChildren()) do
        if gem:IsA("BasePart") or gem:IsA("MeshPart") then
            -- Mover cada gema a la posición del jugador local
            gem.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 2, 0) -- Coloca la gema justo arriba del jugador
        end
    end
end)



