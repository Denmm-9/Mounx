-- Servicios
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LightsaberRemotes = ReplicatedStorage:WaitForChild("LightsaberRemotes")
local UpdateBlockDirection = LightsaberRemotes:WaitForChild("UpdateBlockDirection")
local PrimaryAction = require(ReplicatedStorage.LightsaberModules.SharedBehavior.PrimaryAction)
local ServerState = require(ReplicatedStorage.LightsaberModules.ServerState)

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

-- Instant Hitbox V6 OP (Insta-Hit Server-Priority)
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Modules
local DuelModule = require(ReplicatedStorage.LightsaberModules.SharedBehavior.DuelRequest)
local HitboxCaster = require(ReplicatedStorage.LightsaberModules.RaycastHitbox.HitboxCaster)

----------------------------------------------------------------
-- Config
----------------------------------------------------------------
local MAX_DISTANCE = 6
local SCAN_INTERVAL = 0.01
local HIT_COOLDOWN = 0 
local lastHit = 0
local running = false
local playersCache = {}
local oldHitStart = HitboxCaster.HitStart

-- Detection Methods (solo cambiar nombre aquí)
local DetectionMethods = {
    ["UpperTorso"] = "UpperTorso",
    ["Head"] = "Head",
    ["RandomTorsoHead"] = "RandomTorsoHead"
}
local CurrentDetection = DetectionMethods.UpperTorso -- variable fácil de cambiar

----------------------------------------------------------------
-- Player Cache (actualiza justo antes de atacar)
----------------------------------------------------------------
local function updatePlayersCache()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local head = char and char:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                list[#list+1] = {player=plr, char=char, hum=hum, head=head}
            end
        end
    end
    playersCache = list
end

task.spawn(function()
    while true do
        if running then updatePlayersCache() end
        task.wait(SCAN_INTERVAL)
    end
end)

----------------------------------------------------------------
-- Duel Handler
----------------------------------------------------------------
local DuelTarget, duelConnTarget, duelConnLocal
local oldBeginDuel = DuelModule.BeginDuel

local function clear()
    if duelConnTarget then duelConnTarget:Disconnect() end
    DuelTarget, duelConnTarget = nil, nil
end

local function watchDeath(humanoid, cb)
    if not humanoid then return end
    local c; c = humanoid.Died:Connect(function()
        cb()
        c:Disconnect()
    end)
    return c
end

local function watchLocal()
    if duelConnLocal then duelConnLocal:Disconnect() end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then duelConnLocal = watchDeath(hum, clear) end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.05)
    watchLocal()
end)
watchLocal()

DuelModule.BeginDuel = function(self, opponent)
    local ok,res = pcall(function() return oldBeginDuel(self,opponent) end)
    task.defer(function()
        local plr = opponent and Players:GetPlayerFromCharacter(opponent)
        if not plr then return end
        clear()
        DuelTarget = plr
        local hum = opponent:FindFirstChildOfClass("Humanoid")
        if hum then duelConnTarget = watchDeath(hum, clear) end
    end)
    return ok and res
end

----------------------------------------------------------------
-- Wallcheck
----------------------------------------------------------------
local function canHit(fromPos, targetPart, ignore)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = ignore or {}
    local ray = Workspace:Raycast(fromPos, targetPart.Position-fromPos, params)
    return ray and ray.Instance and ray.Instance:IsDescendantOf(targetPart.Parent)
end

----------------------------------------------------------------
-- Target Selection
----------------------------------------------------------------
local function getTarget(hrp)
    if DuelTarget and DuelTarget.Character then
        local char = DuelTarget.Character
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if head and hum and hum.Health > 0 then
            if (hrp.Position-head.Position).Magnitude <= MAX_DISTANCE then
                return {player=DuelTarget,char=char,head=head,hum=hum}
            end
        end
    end
    local best,dist=nil,math.huge
    for _,e in ipairs(playersCache) do
        local d=(hrp.Position-e.head.Position).Magnitude
        if d<=MAX_DISTANCE and d<dist then best,dist=e,d end
    end
    return best
end

----------------------------------------------------------------
-- Hook OP Insta-Hit
----------------------------------------------------------------
local function enable()
    if running then return end
    running=true

    HitboxCaster.HitStart=function(self,duration)
        pcall(function() oldHitStart(self,duration) end)

        task.defer(function()
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if tick()-lastHit<HIT_COOLDOWN then return end
            updatePlayersCache()

            local enemy=getTarget(hrp)
            if not enemy then return end

            -- Determinar hitPart según DetectionMethod
            local hitPart
            if CurrentDetection=="UpperTorso" then
                hitPart=enemy.char:FindFirstChild("UpperTorso") or enemy.head
            elseif CurrentDetection=="Head" then
                hitPart=enemy.head
            elseif CurrentDetection=="RandomTorsoHead" then
                hitPart=(math.random()<0.5 and enemy.char:FindFirstChild("UpperTorso") or enemy.head)
            end
            if not hitPart then return end
            if not canHit(hrp.Position,hitPart,{char}) then return end

            lastHit=tick()
            self.OnHit:Fire(
                hitPart,
                enemy.hum,
                {Instance=hitPart,Position=hitPart.Position,Normal=Vector3.new(0,1,0)},
                "InstantHit"
            )
        end)
    end
end

local function disable()
    running=false
    HitboxCaster.HitStart=oldHitStart
end

----------------------------------------------------------------
-- UI
----------------------------------------------------------------
createButton("Instant Hitbox V6",0.1,function(active)
    if active then enable() else disable() end
end)

-- AntiSlap 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SlappedModule = require(ReplicatedStorage:WaitForChild("LightsaberModules"):WaitForChild("SharedBehavior"):WaitForChild("Slapped"))
local originalSlapped = SlappedModule.Slapped
local function enableAntiSlap()
    SlappedModule.Slapped = function(u14, p15, p16, p17)

        if u14 and u14.Character and u14.Character == LocalPlayer.Character then
            task.spawn(function()

                if u14.anims then
                    if u14.anims.SlappedLegs then u14.anims.SlappedLegs:Stop() end
                    if u14.anims.SlappedArms then u14.anims.SlappedArms:Stop() end
                end

                if u14.downThread then
                    task.cancel(u14.downThread)
                    u14.downThread = nil
                end

                if u14.slappedTrove then
                    u14.slappedTrove:Clean()
                end

                local hrp = u14.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("PhysicsAtt") then
                    local physicsAtt = hrp.PhysicsAtt
                    local slapVel = physicsAtt:FindFirstChild("SlapVelocity")
                    if slapVel then
                        slapVel.VectorVelocity = (p15 + Vector3.new(0, p16, 0)).Unit * p17
                        slapVel.Enabled = true
                        task.delay(0.1, function()
                            slapVel.Enabled = false
                            hrp.AssemblyLinearVelocity = slapVel.VectorVelocity
                        end)
                    end
                end
                local remotes = ReplicatedStorage:WaitForChild("LightsaberRemotes")
                if remotes:FindFirstChild("GetUp") then
                    remotes.GetUp:FireServer()
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

-- Inf Combo
local oldGet = ServerState.Get
local comboHooked = false

local function enableMaxCombo()
    if comboHooked then return end
    ServerState.Get = function(character, key)
        if key == "MaxComboCount" then
            return 8
        else
            return oldGet(character, key)
        end
    end
    comboHooked = true
    print("[MaxCombo] Activado")
end

createButton("Max Combo", 0.5, function(active)
    if active then
        enableMaxCombo()
    else
        ServerState.Get = oldGet
        comboHooked = false
    end
end)

-- PerfectBlock
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local UpdateBlockDirection = ReplicatedStorage.LightsaberRemotes.UpdateBlockDirection

local DuelModule = require(ReplicatedStorage.LightsaberModules.SharedBehavior.DuelRequest)

-- DuelTag
local DuelTarget
local duelConnTarget, duelConnLocal
local oldBeginDuel = DuelModule.BeginDuel

local function clearDuel()
	if duelConnTarget then duelConnTarget:Disconnect() end
	DuelTarget, duelConnTarget = nil, nil
end

local function watchDeath(hum, cb)
	if not hum then return end
	local c
	c = hum.Died:Connect(function()
		c:Disconnect()
		cb()
	end)
	return c
end

local function watchLocal()
	if duelConnLocal then duelConnLocal:Disconnect() end
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then duelConnLocal = watchDeath(hum, function() clearDuel() end) end
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.05)
	watchLocal()
end)
watchLocal()

DuelModule.BeginDuel = function(self, opponent)
	local ok,res = pcall(function()
		return oldBeginDuel(self, opponent)
	end)

	task.defer(function()
		local plr = opponent and Players:GetPlayerFromCharacter(opponent)
		if not plr then return end

		clearDuel()
		DuelTarget = plr

		local hum = opponent:FindFirstChildOfClass("Humanoid")
		if hum then duelConnTarget = watchDeath(hum, function() clearDuel() end) end
	end)

	return ok and res
end

-- Anims
local animations = {
    [12625853257]={8,7,6},[12718500875]={8,7,6},[13569308951]={8,7,6},
    [12734283312]={8,7,6},[13453385141]={8,7,6},[14167502905]={8,7,6},
    [15563346027]={8,7,6},[17372038496]={8,7,6},[13306517941]={8,7,6},
    [13781663786]={8,7,6},[13540431378]={8,7,6},[12734467243]={8,7,6},
    [14329161930]={8,7,6},

    [12625843823]={8,9,10},[12718483984]={8,9,10},[13568360345]={8,9,10},
    [12734279804]={8,9,10},[13453387454]={8,9,10},[14167592684]={8,9,10},
    [15563342470]={8,9,10},[17372037456]={8,9,10},[13304777249]={8,9,10},
    [13781621647]={8,9,10},[13540933153]={8,9,10},[12734465074]={8,9,10},
    [14355055371]={8,9,10},

    [12625846167]={11,10},[12718486016]={11,10},[13568907848]={11,10},
    [12734282359]={11,10},[13453382299]={11,10},[14167590501]={11,10},
    [15564066873]={11,10},[17372036678]={11,10},[13304786458]={11,10},
    [13781667793]={11,10},[13540923116]={11,10},[12734466257]={11,10},
    [14329310837]={11,10},

    [12625841878]={6,5,4},[12718501806]={6,5,4},[13569466383]={6,5,4},
    [12734284724]={6,5,4},[13453390619]={6,5,4},[14167591876]={6,5,4},
    [15563343960]={6,5,4},[17372039079]={6,5,4},[13306520673]={6,5,4},
    [13783497920]={6,5,4},[12734468200]={6,5,4},[14329312618]={6,5,4},

    [12625848489]={3,2,4},[12718504431]={3,2,4},[13565725049]={3,2,4},
    [12734288411]={3,2,4},[13453386109]={3,2,4},[14167584256]={3,2,4},
    [15563344914]={3,2,4},[17566657634]={3,2,4},[13304781510]={3,2,4},
    [13783395464]={3,2,4},[13540430226]={3,2,4},[12734471179]={3,2,4},
    [14329308611]={3,2,4},

    [12625839385]={1,2,13},[12718502938]={1,2,13},[13564880014]={1,2,13},
    [12734285787]={1,2,13},[13453391958]={1,2,13},[14167593691]={1,2,13},
    [15563343338]={1,2,13},[17372041039]={1,2,13},[13304774028]={1,2,13},
    [13783202348]={1,2,13},[13540434005]={1,2,13},[12734468945]={1,2,13},
    [14329314419]={1,2,13},

    [12625851115]={12,13},[12718503706]={12,13},[13566518265]={12,13},
    [12734286808]={12,13},[13453383921]={12,13},[14167585544]={12,13},
    [15563346564]={12,13},[17566667400]={12,13},[13304788013]={12,13},
    [13783293417]={12,13},[13540433400]={12,13},[12734470075]={12,13},
    [14329160019]={12,13},
}

-- getDir
local function getDirectionsFromAnimations(hum)
	local dirSet = {}
	for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
		if track.IsPlaying then
			local id = tonumber(track.Animation.AnimationId:match("%d+"))
			if animations[id] then
				for _,d in ipairs(animations[id]) do
					dirSet[d] = true
				end
			end
		end
	end

	local result = {}
	for d in pairs(dirSet) do
		table.insert(result, d)
	end
	return result
end

local blockRange = 15

local function getTarget()
	local myChar = LocalPlayer.Character
	if not myChar then return nil end
	local root = myChar:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	-- prioridad: DuelTarget
	if DuelTarget and DuelTarget.Character then
		local char = DuelTarget.Character
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root2 = char:FindFirstChild("HumanoidRootPart")
		if hum and root2 and hum.Health > 0 then
			local dist = (root2.Position - root.Position).Magnitude
			if dist <= blockRange then
				return char
			end
		end
	end

	-- fallback nearest
	local best, d = nil, math.huge
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local char = plr.Character
			local hum = char:FindFirstChildOfClass("Humanoid")
			local r = char:FindFirstChild("HumanoidRootPart")
			if hum and r and hum.Health > 0 then
				local dist = (r.Position - root.Position).Magnitude
				if dist <= blockRange and dist < d then
					best, d = char, dist
				end
			end
		end
	end

	return best
end

local perfectBlockConnection

createButton("PerfectBlock", 0.7, function(active)
	if active then
		perfectBlockConnection = RunService.Heartbeat:Connect(function()
			local enemy = getTarget()
			if not enemy then return end

			local hum = enemy:FindFirstChildOfClass("Humanoid")
			if not hum then return end

			local dirs = getDirectionsFromAnimations(hum)
			if #dirs == 0 then return end

			for _,dir in ipairs(dirs) do
				UpdateBlockDirection:FireServer(dir)
			end

			task.wait(0.004)
		end)

	else
		if perfectBlockConnection then
			perfectBlockConnection:Disconnect()
			perfectBlockConnection = nil
		end
	end
end)
