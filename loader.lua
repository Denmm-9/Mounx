if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait(1)
end

local ListURl = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/Game_list.lua"
local games = loadstring(game:HttpGet(ListURl))()

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local deviceType = isMobile and "mobile" or "pc"
print("Device detected:", deviceType)

local success, errorMsg = pcall(function()
    for placeId, data in pairs(games) do
        if game.PlaceId == placeId then
            local scriptUrl = data[deviceType]
            if scriptUrl then
                print("Loading script:", scriptUrl)
                loadstring(game:HttpGet(scriptUrl))()
            else
                warn("No script found for this device type.")
            end
        end
    end
end)

if not success then
    warn(errorMsg)
end
