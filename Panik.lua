local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
gui.Name = "ScannerGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 220)
frame.Position = UDim2.new(0, 20, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local killersChamsEnabled = false
local killersChams = {}
local scannersChams = {}
local escapeChams = {}
local currentScannerIndex = 1

local loadingPositions = {
    Vector3.new(-315.8553161621094, 4.224841117858887, -246.55284118652344),
    Vector3.new(-319.2973937988281, 4.224841117858887, -122.65361022949219),
    Vector3.new(-198.001220703125, 4.224841594696045, -138.60247802734375),
    Vector3.new(-305.36065673828125, 4.224841117858887, -308.7231140136719),
    Vector3.new(-74.84132385253906, 4.224841117858887, -228.63890075683594),
    Vector3.new(-99.1731948852539, 4.224841117858887, -170.9850311279297),
    Vector3.new(-168.90673828125, 4.224841117858887, -181.48699951171875),
    Vector3.new(-224.1953887939453, 4.224841117858887, -218.61647033691406),
    Vector3.new(-318.9734191894531, 3.9980251789093018, -295.3887939453125),
    Vector3.new(-244.40525817871094, 3.9980251789093018, -333.2596130371094),
}

local function createButton(name, order, callback)
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = UDim2.new(0.05, 0, 0, (order - 1) * 50 + 10)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Text = name
    Instance.new("UICorner", button)
    button.MouseButton1Click:Connect(callback)
    return button
end

local function getInventoryItems()
    local invGui = player.PlayerGui:WaitForChild("Main"):WaitForChild("BottomContainer"):WaitForChild("Bag"):WaitForChild("Inv")
    local items = {}
    for i = 1, 3 do
        local slot = invGui:FindFirstChild(tostring(i))
        if slot and slot:FindFirstChild("Inner") and slot.Inner:FindFirstChild("TextLabel") then
            local name = slot.Inner.TextLabel.Text
            items[name] = true
        end
    end
    return items
end

local function updateKillersChams(enable)
    local killersFolder = workspace:FindFirstChild("Killers")
    if not killersFolder then return end
    for _, h in pairs(killersChams) do h:Destroy() end
    killersChams = {}

    if enable then
        for _, killer in pairs(killersFolder:GetChildren()) do
            if killer:IsA("Model") and not killer:FindFirstChild("KillersChams") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "KillersChams"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.3
                highlight.OutlineTransparency = 0
                highlight.Adornee = killer
                highlight.Parent = killer
                table.insert(killersChams, highlight)
            end
        end
    end
end

local function toggleKillersChams()
    killersChamsEnabled = not killersChamsEnabled
    updateKillersChams(killersChamsEnabled)
end

local function updateScannerCham()
    for _, ch in pairs(scannersChams) do ch:Destroy() end
    scannersChams = {}

    local scannersFolder = workspace:FindFirstChild("Scanners")
    if not scannersFolder then return end
    local scanners = scannersFolder:GetChildren()
    table.sort(scanners, function(a, b) return a.Name < b.Name end)

    local scanner = scanners[currentScannerIndex]
    if not scanner then return end

    local model = scanner:FindFirstChild("Model")
    if model and not model:FindFirstChild("ScannerChams") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ScannerChams"
        highlight.FillColor = Color3.fromRGB(0, 170, 255)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.2
        highlight.OutlineTransparency = 0
        highlight.Adornee = model
        highlight.Parent = model
        table.insert(scannersChams, highlight)

        local tag = Instance.new("BillboardGui", model)
        tag.Name = "ScannerLabel"
        tag.Size = UDim2.new(0, 100, 0, 30)
        tag.Adornee = model
        tag.AlwaysOnTop = true

        local label = Instance.new("TextLabel", tag)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Text = "Scanner"
        label.Font = Enum.Font.SourceSansBold
    end
end

local function updateEscapeChams(enable)
    for _, ch in pairs(escapeChams) do ch:Destroy() end
    escapeChams = {}

    if not enable then return end

    local trapdoorsFolder = workspace:FindFirstChild("Trapdoors")
    if not trapdoorsFolder then return end

    for _, obj in pairs(trapdoorsFolder:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "EscapeHatch" and not obj:FindFirstChild("EscapeCham") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "EscapeCham"
            highlight.FillColor = Color3.fromRGB(255, 255, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.Adornee = obj
            highlight.Parent = obj
            table.insert(escapeChams, highlight)

            local tag = Instance.new("BillboardGui", obj)
            tag.Name = "EscapeLabel"
            tag.Size = UDim2.new(0, 120, 0, 30)
            tag.Adornee = obj
            tag.AlwaysOnTop = true

            local label = Instance.new("TextLabel", tag)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextStrokeTransparency = 0
            label.TextScaled = true
            label.Text = "Escape Hatch"
            label.Font = Enum.Font.SourceSansBold
        end
    end
end

local function teleportToEscapeHatch()
    local trapdoorsFolder = workspace:FindFirstChild("Trapdoors")
    if not trapdoorsFolder then
        warn("No hay carpeta 'Trapdoors'")
        return
    end

    for _, obj in pairs(trapdoorsFolder:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "EscapeHatch" then
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local pos
            if obj.PrimaryPart then
                pos = obj.PrimaryPart.Position
            else
                for _, part in pairs(obj:GetChildren()) do
                    if part:IsA("BasePart") then
                        pos = part.Position
                        break
                    end
                end
            end
            if pos then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
            return
        end
    end
end

local infoFrame
local function updateRequirementsList()
    if infoFrame then
        infoFrame:Destroy()
        infoFrame = nil
    end

    infoFrame = Instance.new("Frame", gui)
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(0, 320, 0, 280)
    infoFrame.Position = UDim2.new(0, 270, 0.5, -140)
    infoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    infoFrame.BackgroundTransparency = 0.1
    infoFrame.Active = true
    infoFrame.Draggable = true
    Instance.new("UICorner", infoFrame)

    local closeButton = Instance.new("TextButton", infoFrame)
    closeButton.Size = UDim2.new(0, 60, 0, 30)
    closeButton.Position = UDim2.new(1, -65, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Text = "Cerrar"
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 14
    Instance.new("UICorner", closeButton)
    closeButton.MouseButton1Click:Connect(function()
        if infoFrame then
            infoFrame:Destroy()
            infoFrame = nil
        end
    end)

    local title = Instance.new("TextLabel", infoFrame)
    title.Size = UDim2.new(1, -70, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Text = "Objetos Scanner " 
    title.TextXAlignment = Enum.TextXAlignment.Left

    local inventoryItems = getInventoryItems()
    local scannersFolder = workspace:FindFirstChild("Scanners")
    if not scannersFolder then return end
    local scanners = scannersFolder:GetChildren()
    table.sort(scanners, function(a,b) return a.Name < b.Name end)
    local scanner = scanners[currentScannerIndex]
    if not scanner then return end

    local setFolder = scanner:FindFirstChild("Scanner") and scanner.Scanner:FindFirstChild("Set")
    if not setFolder then return end

    local layout = Instance.new("UIListLayout", infoFrame)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local yPos = 40
    for _, obj in ipairs(setFolder:GetChildren()) do
        if obj:IsA("ObjectValue") and obj.Value then
            local name = obj.Value.Name
            local textLabel = Instance.new("TextLabel", infoFrame)
            textLabel.Size = UDim2.new(1, -20, 0, 25)
            textLabel.Position = UDim2.new(0, 10, 0, yPos)
            textLabel.BackgroundTransparency = 1
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextSize = 18
            textLabel.TextXAlignment = Enum.TextXAlignment.Left

            if inventoryItems[name] then
                textLabel.Text = "✔ " .. name
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                textLabel.Text = "✘ " .. name
                textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
            yPos = yPos + 30
        end
    end
end

local function setNoclip(enabled)
    local character = player.Character
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide ~= not enabled then
            part.CanCollide = not enabled
        end
    end
end

local function teleportToScannerItem()
    local scannersFolder = workspace:FindFirstChild("Scanners")
    local itemsFolder = workspace:FindFirstChild("Items")
    if not scannersFolder or not itemsFolder then
        warn("No se encontró 'Scanners' o 'Items'")
        return
    end

    local scanners = scannersFolder:GetChildren()
    table.sort(scanners, function(a, b) return a.Name < b.Name end)

    local scanner = scanners[currentScannerIndex]
    if not scanner then
        return
    end

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local inventoryItems = getInventoryItems()
    local setFolder = scanner:FindFirstChild("Scanner") and scanner.Scanner:FindFirstChild("Set")
    if not setFolder then
        return
    end

    setNoclip(true)

    for _, obj in ipairs(setFolder:GetChildren()) do
        if obj:IsA("ObjectValue") and obj.Value then
            local name = obj.Value.Name
            if not inventoryItems[name] then
                local foundItem = nil

                local item = itemsFolder:FindFirstChild(name)
                if item then
                    foundItem = item
                else
                    for _, pos in ipairs(loadingPositions) do
                        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                        wait(0.005) 

                        item = itemsFolder:FindFirstChild(name)
                        if item then
                            foundItem = item
                            break
                        end
                    end
                end

                if foundItem then
                    local pos
                    if foundItem:IsA("Model") and foundItem.PrimaryPart then
                        pos = foundItem.PrimaryPart.Position
                    elseif foundItem:IsA("BasePart") then
                        pos = foundItem.Position
                    end

                    if pos then
                        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 0, 0))
                        wait(0.2)

                        for _, descendant in pairs(foundItem:GetDescendants()) do
                            if descendant:IsA("ProximityPrompt") then
                                fireproximityprompt(descendant)
                                break
                            end
                        end

                        wait(1.5)
                    end
                end
            end
        end
    end

    setNoclip(false)

    updateScannerCham()
    updateRequirementsList()
end


createButton("Scanner (TP al item)", 1, function()
    teleportToScannerItem()
end)

createButton("Killers Chams", 2, function()
    toggleKillersChams()
end)

local escapeChamsEnabled = false
createButton("Escape Chams", 3, function()
    escapeChamsEnabled = not escapeChamsEnabled
    updateEscapeChams(escapeChamsEnabled)
end)

createButton("Teleport Escape Hatch", 4, function()
    teleportToEscapeHatch()
end)

updateScannerCham()
updateRequirementsList()
