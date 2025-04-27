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

--  Expandir Hitboxes
local expandHitboxesConnection

local function expandAllPlayerHitboxes()
    local localPlayer = game.Players.LocalPlayer

    for _, player in ipairs(game.Players:GetPlayers()) do
        pcall(function()
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hitbox = player.Character:FindFirstChild("HumanoidRootPart")
                if hitbox then
                    hitbox.Size = Vector3.new(11, 11, 11)
                    hitbox.CanCollide = false
                    hitbox.Transparency = 0.9
                    hitbox.Color = Color3.fromRGB(255, 255, 255)
                end
            end
        end)
    end
end

createButton("Expand Hitboxes", 0.1, function(active)
    if active then
        expandHitboxesConnection = game:GetService("RunService").Heartbeat:Connect(function()
            expandAllPlayerHitboxes()
        end)
    else
        if expandHitboxesConnection then
            expandHitboxesConnection:Disconnect()
            expandHitboxesConnection = nil
        end
    end
end)

--  AntiSlap
local SlappedModule = require(game:GetService("ReplicatedStorage").LightsaberModules.SharedBehavior.Slapped)
local LightsaberRemotes = game:GetService("ReplicatedStorage").LightsaberRemotes

local originalSlapped = SlappedModule["Slapped"]

local function enableAntiSlap()
    SlappedModule["Slapped"] = function(u14, p15, p16, p17)
        if u14 and u14.Character and u14.Character == game.Players.LocalPlayer.Character then
            print("[HOOK] Slapped interceptado. Forzando GetUp.")

            task.spawn(function()
                if u14.anims then
                    if u14.anims.SlappedLegs then
                        u14.anims.SlappedLegs:Stop()
                    end
                    if u14.anims.SlappedArms then
                        u14.anims.SlappedArms:Stop()
                    end
                end

                if u14.slappedTrove then
                    u14.slappedTrove:Clean()
                end

                if u14.downThread then
                    task.cancel(u14.downThread)
                end

                if u14.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = u14.Character.HumanoidRootPart
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
    SlappedModule["Slapped"] = originalSlapped
end

createButton("AntiSlap", 0.3, function(active)
    if active then
        enableAntiSlap()
    else
        disableAntiSlap()
    end
end)

--  AntiBounce
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
        if u9.lastSwingAnim then
            pcall(function()
                u9.lastSwingAnim:Stop()
                u9.lastSwingAnim:Destroy()
            end)
        end
        u9.lastSwingAnim = nil

        if u9.mouseDown or true then 
            PrimaryAction.Process(u9)
        end
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
