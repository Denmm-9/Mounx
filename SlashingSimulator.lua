local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "Mounx | SSimulator",
	Footer = "#xererecaforever",
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local MainTab = Window:AddTab("Main Features", "user")
local SettingsTab = Window:AddTab("Config", "settings")
local FarmGroup = MainTab:AddLeftGroupbox("Farm")
local MenuGroup = SettingsTab:AddLeftGroupbox("Menu")

local isFarming = false
local autoSell = false
local runService = game:GetService("RunService")
local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("Subtract")
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local maxDistance = 20
local gui = player:WaitForChild("PlayerGui"):WaitForChild("Menus"):WaitForChild("Sell")

local slicableObjects = {}
for i = 1, 4 do
	local world = workspace:FindFirstChild("WORLDS") and workspace.WORLDS:FindFirstChild("World"..i)
	if world then
		local gameplay = world:FindFirstChild("Gameplay")
		if gameplay and gameplay:FindFirstChild("SlicableObjects") then
			table.insert(slicableObjects, gameplay.SlicableObjects)
		end
	end
end

local function findTargetPart(model)
	local origin = model:FindFirstChild("ModelOriginPart", true)
	if origin and origin:IsA("BasePart") then
		return origin
	end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

local function getArgs(targetPart)
	local pos = targetPart.Position
	local dir = (pos - hrp.Position).Unit
	local sliceStart = pos + Vector3.new(-5, -1, 5)
	local sliceEnd = pos + Vector3.new(5, 1, -5)
	local sliceCFrame = CFrame.new(pos, pos + dir)

	return {
		targetPart,
		{
			["sliceStartPoint"] = sliceStart,
			["Dir"] = dir,
			["Size"] = Vector3.new(100, 100, 100),
			["CFrame"] = sliceCFrame,
			["sliceEndPoint"] = sliceEnd,
			["N"] = 1
		}
	}
end

local function getClosestTarget()
	local closest, shortest = nil, maxDistance

	for _, folder in pairs(slicableObjects) do
		for _, group in pairs(folder:GetChildren()) do
			if group:IsA("Folder") then
				for _, model in pairs(group:GetChildren()) do
					local part = findTargetPart(model)
					if part then
						local distance = (part.Position - hrp.Position).Magnitude
						if distance <= shortest then
							closest = part
							shortest = distance
						end
					end
				end
			end
		end
	end

	return closest
end

local function findAllSellRings()
	local sellRings = {}
	local worlds = workspace:FindFirstChild("WORLDS")
	if not worlds then return sellRings end

	for _, world in pairs(worlds:GetChildren()) do
		local mapAssets = world:FindFirstChild("MapAssets")
		if mapAssets then
			for _, folder in pairs(mapAssets:GetChildren()) do
				if folder:IsA("Folder") then
					for _, part in pairs(folder:GetChildren()) do
						if part.Name == "SellRing" and part:IsA("BasePart") then
							table.insert(sellRings, part)
						end
					end
				end
			end
		end
	end
	return sellRings
end

task.spawn(function()
	while true do
		if isFarming then
			local target = getClosestTarget()
			if target then
				remote:FireServer(unpack(getArgs(target)))
			end
		end
		task.wait()
	end
end)

task.spawn(function()
	local lastPosition = nil
	local sellRings = findAllSellRings()

	while true do
		if autoSell and gui.Visible then
			for _, ring in ipairs(sellRings) do
				if ring and ring:IsA("BasePart") then
					lastPosition = hrp.Position
					hrp.Anchored = true
					hrp.CFrame = ring.CFrame + Vector3.new(0, 3, 0)
					task.wait()
					hrp.Anchored = false
					task.wait(0.1)
					if lastPosition then
						hrp.CFrame = CFrame.new(lastPosition)
					end
					break
				end
			end
		end
		task.wait(0.1)
	end
end)

-- Interfaz
MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", {
		Default = "Delete",
		NoUI = true,
		Text = "Menu keybind"
	})
MenuGroup:AddButton("Unload", function()
	isFarming = false
	autoSell = false
	Library:Notify("Unloading...")
	wait(0.6)
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

FarmGroup:AddToggle("AutoFarm", {
	Text = "AutoClicker",
	Default = false,
	Callback = function(state)
		isFarming = state
	end
})
FarmGroup:AddToggle("AutoSell", {
	Text = "AutoSell",
	Default = false,
	Callback = function(state)
		autoSell = state
	end
})

FarmGroup:AddButton({
	Text = "Unlock all weapons",
	DoubleClick = true,
	Func = function()
		Library:Notify("Buying all weapons...")

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Players = game:GetService("Players")
		local Player = Players.LocalPlayer

		local PurchaseRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Market"):WaitForChild("AttemptPurchase")
		local KnifeContent = Player:WaitForChild("PlayerGui")
			:WaitForChild("Shop")
			:WaitForChild("Knives")
			:WaitForChild("List")
			:WaitForChild("Content")

		for _, item in ipairs(KnifeContent:GetChildren()) do
			if item:IsA("GuiButton") or item:IsA("Frame") then
				local knifeName = item.Name
				pcall(function()
					PurchaseRemote:InvokeServer(knifeName)
				end)
				task.wait(0.1)
			end
		end

		Library:Notify("All weapons unlocked!")
	end
})


FarmGroup:AddButton({
	Text = "Unlock all maps",
	DoubleClick = true,
	Func = function()
		Library:Notify("Unlocking all maps...")

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local UnlockRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("UnlockArea")
		local worldsFolder = workspace:FindFirstChild("WORLDS")

		if not worldsFolder then return end

		for i = 1, 4 do
			local world = worldsFolder:FindFirstChild("World" .. i)
			if world then
				local regionBarriers = world:FindFirstChild("Gameplay") and world.Gameplay:FindFirstChild("RegionBariers")
				if regionBarriers then
					for _, region in ipairs(regionBarriers:GetChildren()) do
						if region:IsA("BasePart") or region:IsA("Model") then
							pcall(function()
								UnlockRemote:InvokeServer(region)
							end)
							task.wait(0.1)
						end
					end
				end
			end
		end

		Library:Notify("All maps unlocked!")
	end
})

