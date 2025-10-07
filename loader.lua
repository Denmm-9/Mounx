if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait(1)
end

local ListURl = "https://raw.githubusercontent.com/Denmm-9/Mounx/refs/heads/main/Game_list.lua"
local games = loadstring(game:HttpGet(ListURl))()

local success, errorMsg = pcall(function()
    for placeId, scriptUrl in pairs(games) do
        if game.PlaceId == placeId then
            loadstring(game:HttpGet(scriptUrl))()
        end
    end
end)

if not success then
    warn(errorMsg)
end
