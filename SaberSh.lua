-- Servicios
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LightsaberRemotes = ReplicatedStorage:WaitForChild("LightsaberRemotes")
local UpdateBlockDirection = LightsaberRemotes:WaitForChild("UpdateBlockDirection")

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

-- Expand Hitboxes
local expandHitboxesConnection

local function expandAllPlayerHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        pcall(function()
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Shape = Enum.PartType.Ball
                    hrp.Size = Vector3.new(8, 8, 8)
                    hrp.CanCollide = false
                    hrp.CanTouch = false
                    hrp.Transparency = 0.8
                    hrp.Color = Color3.fromRGB(255, 255, 255)
                end
-- Collide Part NEW         
                local collisionPart = player.Character:FindFirstChild("CollisionPart")
                if collisionPart then
                    collisionPart.CanCollide = false
                    collisionPart.CanTouch = false
                end
            end
        end)
    end
end

createButton("Expand Hitboxes", 0.1, function(active)
    if active then
        expandHitboxesConnection = RunService.Heartbeat:Connect(function()
            expandAllPlayerHitboxes()
        end)
    else
        if expandHitboxesConnection then
            expandHitboxesConnection:Disconnect()
            expandHitboxesConnection = nil
        end
    end
end)

-- AntiSlap
local SlappedModule = require(ReplicatedStorage.LightsaberModules.SharedBehavior.Slapped)
local originalSlapped = SlappedModule.Slapped

local function enableAntiSlap()
    SlappedModule.Slapped = function(u14, p15, p16, p17)
        if u14 and u14.Character and u14.Character == LocalPlayer.Character then
            task.spawn(function()
                if u14.anims then
                    if u14.anims.SlappedLegs then u14.anims.SlappedLegs:Stop() end
                    if u14.anims.SlappedArms then u14.anims.SlappedArms:Stop() end
                end
                if u14.slappedTrove then u14.slappedTrove:Clean() end
                if u14.downThread then task.cancel(u14.downThread) end
                local hrp = u14.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    if hrp:FindFirstChild("PhysicsAtt") then
                        local att = hrp.PhysicsAtt
                        if att:FindFirstChild("SlapVelocity") then
                            att.SlapVelocity.Enabled = false
                        end
                    end
                end
                if LightsaberRemotes:FindFirstChild("GetUp") then
                    LightsaberRemotes.GetUp:FireServer()
                end
            end)
            return
        end
        return originalSlapped(u14, p15, p16, p17)
    end
end

local function disableAntiSlap()
    SlappedModule.Slapped = originalSlapped
end

createButton("AntiSlap", 0.3, function(active)
    if active then
        enableAntiSlap()
    else
        disableAntiSlap()
    end
end)

-- AntiBounce
local bounceFunction = require(ReplicatedStorage.LightsaberModules.SharedBehavior.Bounce)
local PrimaryAction = require(ReplicatedStorage.LightsaberModules.SharedBehavior.PrimaryAction)
local oldBounceHook
local bounceHooked = false

local function enableAntiBounce()
    if bounceHooked then return end
    oldBounceHook = hookfunction(bounceFunction, function(u9, u10)
        u9.attacking = false
        u9.bouncing = false
        u9.recovering = false
        u9.airCombo = nil
        u9.comboIndex = 0
        u9.comboTimestamps = {}
        if u9.swingTrove then u9.swingTrove:Clean() end
        if u9.hitTrove then u9.hitTrove:Clean() end
        if u9.idleTrove then u9.idleTrove:Clean() end
        if u9.lastSwingAnim then pcall(function() u9.lastSwingAnim:Stop() u9.lastSwingAnim:Destroy() end) end
        u9.lastSwingAnim = nil
        if u9.mouseDown or true then PrimaryAction.Process(u9) end
    end)
    bounceHooked = true
end

createButton("AntiBounce", 0.5, function(active)
    if active then
        enableAntiBounce()
    else
        warn("[AntiBounce] No se puede desactivar tras activarlo.")
    end
end)

-- PerfectBlock
local perfectBlockConnection
local blockRange = 15

local animations = {
    [12625853257] = {8, 7, 6}, [12718500875] = {8, 7, 6}, [13569308951] = {8, 7, 6},
    [12734283312] = {8, 7, 6}, [13453385141] = {8, 7, 6}, [14167502905] = {8, 7, 6},
    [15563346027] = {8, 7, 6}, [17372038496] = {8, 7, 6}, [13306517941] = {8, 7, 6},
    [13781663786] = {8, 7, 6}, [13540431378] = {8, 7, 6}, [12734467243] = {8, 7, 6},
    [14329161930] = {8, 7, 6},

    [12625843823] = {8, 9, 10}, [12718483984] = {8, 9, 10}, [13568360345] = {8, 9, 10},
    [12734279804] = {8, 9, 10}, [13453387454] = {8, 9, 10}, [14167592684] = {8, 9, 10},
    [15563342470] = {8, 9, 10}, [17372037456] = {8, 9, 10}, [13304777249] = {8, 9, 10},
    [13781621647] = {8, 9, 10}, [13540933153] = {8, 9, 10}, [12734465074] = {8, 9, 10},
    [14355055371] = {8, 9, 10},

    [12625846167] = {11, 10}, [12718486016] = {11, 10}, [13568907848] = {11, 10},
    [12734282359] = {11, 10}, [13453382299] = {11, 10}, [14167590501] = {11, 10},
    [15564066873] = {11, 10}, [17372036678] = {11, 10}, [13304786458] = {11, 10},
    [13781667793] = {11, 10}, [13540923116] = {11, 10}, [12734466257] = {11, 10},
    [14329310837] = {11, 10},

    [12625841878] = {6, 5, 4}, [12718501806] = {6, 5, 4}, [13569466383] = {6, 5, 4},
    [12734284724] = {6, 5, 4}, [13453390619] = {6, 5, 4}, [14167591876] = {6, 5, 4},
    [15563343960] = {6, 5, 4}, [17372039079] = {6, 5, 4}, [13306520673] = {6, 5, 4},
    [13783497920] = {6, 5, 4}, [12734468200] = {6, 5, 4}, [14329312618] = {6, 5, 4},

    [12625848489] = {3, 2, 4}, [12718504431] = {3, 2, 4}, [13565725049] = {3, 2, 4},
    [12734288411] = {3, 2, 4}, [13453386109] = {3, 2, 4}, [14167584256] = {3, 2, 4},
    [15563344914] = {3, 2, 4}, [17566657634] = {3, 2, 4}, [13304781510] = {3, 2, 4},
    [13783395464] = {3, 2, 4}, [13540430226] = {3, 2, 4}, [12734471179] = {3, 2, 4},
    [14329308611] = {3, 2, 4},

    [12625839385] = {1, 2, 13}, [12718502938] = {1, 2, 13}, [13564880014] = {1, 2, 13},
    [12734285787] = {1, 2, 13}, [13453391958] = {1, 2, 13}, [14167593691] = {1, 2, 13},
    [15563343338] = {1, 2, 13}, [17372041039] = {1, 2, 13}, [13304774028] = {1, 2, 13},
    [13783202348] = {1, 2, 13}, [13540434005] = {1, 2, 13}, [12734468945] = {1, 2, 13},
    [14329314419] = {1, 2, 13},

    [12625851115] = {12, 13}, [12718503706] = {12, 13}, [13566518265] = {12, 13},
    [12734286808] = {12, 13}, [13453383921] = {12, 13}, [14167585544] = {12, 13},
    [15563346564] = {12, 13}, [17566667400] = {12, 13}, [13304788013] = {12, 13},
    [13783293417] = {12, 13}, [13540433400] = {12, 13}, [12734470075] = {12, 13},
    [14329160019] = {12, 13},
}

local function getEnemiesInRange()
    local enemies = {}
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return enemies end
    local myPos = myChar.HumanoidRootPart.Position
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist <= blockRange then
                table.insert(enemies, player.Character)
            end
        end
    end
    return enemies
end

local function getDirectionsFromAnimations(humanoid)
    local directionsSet = {}
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        if track.IsPlaying then
            local animIdStr = track.Animation.AnimationId
            local animId = tonumber(animIdStr:match("%d+"))
            if animations[animId] then
                for _, dir in ipairs(animations[animId]) do
                    directionsSet[dir] = true
                end
            end
        end
    end
    local directions = {}
    for dir in pairs(directionsSet) do
        table.insert(directions, dir)
    end
    return directions
end

createButton("PerfectBlock", 0.7, function(active)
    if active then
        perfectBlockConnection = RunService.Heartbeat:Connect(function()
            local enemies = getEnemiesInRange()
            local myChar = LocalPlayer.Character
            if not myChar then return end

            for _, enemyChar in ipairs(enemies) do
                local humanoid = enemyChar:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local directions = getDirectionsFromAnimations(humanoid)
                    if #directions > 0 then
                        for _, dir in ipairs(directions) do
                            UpdateBlockDirection:FireServer(dir)
                        end
                        task.wait(0.005)
                    end
                end
            end
        end)
    else
        if perfectBlockConnection then
            perfectBlockConnection:Disconnect()
            perfectBlockConnection = nil
        end
    end
end)
