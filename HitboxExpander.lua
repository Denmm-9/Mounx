local Flux = loadstring(game:HttpGet("https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/main/Flux%20Lib/Flux%20Lib%20Source.lua"))()
 
 local Window = Flux:Window("Hitbox Expand", "xererecas", Color3.fromRGB(255, 110, 48), Enum.KeyCode.RightShift)
 
 local MainTab = Window:Tab("Main", "http://www.roblox.com/asset/?id=4483345998")
 
 local function expandNonPlayerHitbox()
     for _, npc in ipairs(game.Workspace:GetDescendants()) do
         pcall(function()
             if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                 if not game.Players:GetPlayerFromCharacter(npc) then
                     local hitbox = npc:FindFirstChild("Head")
                     if hitbox then
                         print("Npcs Hitbox Head done")
                         hitbox.Size = Vector3.new(5, 5, 5)
                         hitbox.CanCollide = false
                         hitbox.Transparency = 0.7
                         hitbox.Color = Color3.fromRGB(255, 255, 0)
                     end
                 end
             end
         end)
     end
 end
 
 local function expandPlayerHitbox()
     local localPlayer = game.Players.LocalPlayer
     for _, player in ipairs(game.Players:GetPlayers()) do
         pcall(function()
             if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                 local hitbox = player.Character:FindFirstChild("HumanoidRootPart")
                 if hitbox then
                     hitbox.Size = Vector3.new(20, 20, 20)
                     hitbox.CanCollide = false
                     hitbox.Transparency = 0.7
                     hitbox.Color = Color3.fromRGB(255, 255, 0)
                 end
             end
         end)
     end
 end
 
 local function expandAllPlayerHitboxes()
     local localPlayer = game.Players.LocalPlayer
     for _, player in ipairs(game.Players:GetPlayers()) do
         pcall(function()
             if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                 local hitbox = player.Character:FindFirstChild("HumanoidRootPart")
                 if hitbox then
                     hitbox.Size = Vector3.new(20, 20, 20)
                     hitbox.CanCollide = false
                     hitbox.Transparency = 0.7
                     hitbox.Color = Color3.fromRGB(255, 255, 0)
                 end
             end
         end)
     end
 end
 
 MainTab:Button("Auto Expand Non-Player Hitbox", "", function()
     spawn(function()
         while true do
             expandNonPlayerHitbox()
             wait(1) 
         end
     end)
 end)
 
 MainTab:Button("Auto Expand Player Hitbox (Team Check)", "", function()
     spawn(function()
         while true do
             expandPlayerHitbox()
             wait(1) 
         end
     end)
 end)
 
 MainTab:Button("Auto Expand All Player Hitboxes", "", function()
     spawn(function()
         while true do
             expandAllPlayerHitboxes()
             wait(1) 
         end
     end)
 end)
