local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Mounx",
    Footer = "#xererecaprasempre",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local MainTab = Window:AddTab("Main Features", "user")
local SettingsTab = Window:AddTab("Config", "settings")
local KillAuraGroup = MainTab:AddLeftGroupbox("KillAura")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local KillRange = 25
local isRunning = false

local function isEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function attackPlayer(targetPlayer)
    if targetPlayer ~= LocalPlayer and isEnemy(targetPlayer) and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPart = targetPlayer.Character:FindFirstChild("Right Arm") or targetPlayer.Character:FindFirstChild("RightHand")
        if targetPart then
            local args = {
                [1] = "2", 
                [2] = targetPart,
            }
            LocalPlayer.Character.Bat.RemoteEvent:FireServer(unpack(args))
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if isRunning then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Bat") then
            for _, player in pairs(Players:GetPlayers()) do
                local distance = (player.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                if distance <= KillRange then
                    attackPlayer(player)
                end
            end
        end
    end
end)

KillAuraGroup:AddToggle("KillAura", {
    Text = "Enable KillAura",
    Default = false,
    Callback = function(state)
        isRunning = state
    end
})

KillAuraGroup:AddSlider("Kill Range", {
    Text = "Kill Range",
    Default = KillRange,
    Min = 10,
    Max = 50,
    Rounding = 0,
    Callback = function(value)
        KillRange = value
    end
})

local function ServerHop()
    local gameId = game.PlaceId
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Desc&limit=100"))
    
    for _, server in pairs(servers.data) do
        if server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
            return
        end
    end
end

local SettingsGroup = SettingsTab:AddLeftGroupbox("Menu")

SettingsGroup:AddDivider()
SettingsGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "Delete", NoUI = true, Text = "Menu keybind" })

Library.ToggleKeybind = Options.MenuKeybind 

Options.MenuKeybind:OnChanged(function()
    Library:Notify('Menu toggle key changed to [' .. Options.MenuKeybind.Value .. ']')
end)

SettingsGroup:AddButton("Server Hop", function()
    ServerHop()
end)

SettingsGroup:AddButton("Unload", function()
    isRunning = false
    Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:BuildConfigSection(SettingsTab)

ThemeManager:ApplyToTab(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)

SaveManager:LoadAutoloadConfig()

local DistFromCenter = 80
local TriangleHeight = 16
local TriangleWidth = 16
local TriangleFilled = true
local TriangleTransparency = 0
local TriangleThickness = 1
local TriangleColor = Color3.fromRGB(255, 255, 255)
local AntiAliasing = false

local Players = game:service("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RS = game:service("RunService")

local V3 = Vector3.new
local V2 = Vector2.new
local CF = CFrame.new
local COS = math.cos
local SIN = math.sin
local RAD = math.rad
local DRAWING = Drawing.new
local CWRAP = coroutine.wrap
local ROUND = math.round

local function GetRelative(pos, char)
    if not char then return V2(0,0) end

    local rootP = char.PrimaryPart.Position
    local camP = Camera.CFrame.Position
    local relative = CF(V3(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)

    return V2(relative.X, relative.Z)
end

local function RelativeToCenter(v)
    return Camera.ViewportSize/2 - v
end

local function RotateVect(v, a)
    a = RAD(a)
    local x = v.x * COS(a) - v.y * SIN(a)
    local y = v.x * SIN(a) + v.y * COS(a)

    return V2(x, y)
end

local function DrawTriangle(color)
    local l = DRAWING("Triangle")
    l.Visible = false
    l.Color = color
    l.Filled = TriangleFilled
    l.Thickness = TriangleThickness
    l.Transparency = 1-TriangleTransparency
    return l
end

local function AntiA(v)
    if (not AntiAliasing) then return v end
    return V2(ROUND(v.x), ROUND(v.y))
end

local arrows = {} 

local function ShowArrow(PLAYER)
    local Arrow = DrawTriangle(TriangleColor)

    local function Update()
        local c ; c = RS.RenderStepped:Connect(function()
            if PLAYER and PLAYER.Character then
                local CHAR = PLAYER.Character
                local HUM = CHAR:FindFirstChildOfClass("Humanoid")

                if HUM and CHAR.PrimaryPart ~= nil and HUM.Health > 0 then
                    local _,vis = Camera:WorldToViewportPoint(CHAR.PrimaryPart.Position)
                    if vis == false then
                        local rel = GetRelative(CHAR.PrimaryPart.Position, Player.Character)
                        local direction = rel.unit

                        local base  = direction * DistFromCenter
                        local sideLength = TriangleWidth/2
                        local baseL = base + RotateVect(direction, 90) * sideLength
                        local baseR = base + RotateVect(direction, -90) * sideLength

                        local tip = direction * (DistFromCenter + TriangleHeight)
                        
                        Arrow.PointA = AntiA(RelativeToCenter(baseL))
                        Arrow.PointB = AntiA(RelativeToCenter(baseR))

                        Arrow.PointC = AntiA(RelativeToCenter(tip))

                        Arrow.Visible = true

                    else Arrow.Visible = false end
                else Arrow.Visible = false end
            else 
                Arrow.Visible = false

                if not PLAYER or not PLAYER.Parent then
                    Arrow:Remove()
                    c:Disconnect()
                end
            end
        end)
    end

    CWRAP(Update)()
    table.insert(arrows, Arrow)
end

local ArrowsGroup = MainTab:AddLeftGroupbox("Arrows")

local arrowsActive = false 

ArrowsGroup:AddToggle("Enable Arrows", {
    Text = "Enable Arrows",
    Default = false,
    Callback = function(state)
        arrowsActive = state
        if arrowsActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Name ~= LocalPlayer.Name then
                    ShowArrow(player)
                end
            end
        else

            for _, arrow in ipairs(arrows) do
                arrow:Remove()
            end
            arrows = {} 
        end
    end
})
