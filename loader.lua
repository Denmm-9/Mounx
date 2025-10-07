if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait(1)
end

local UIS = game:GetService("UserInputService")
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local deviceType = isMobile and "mobile" or "pc"

local ListURL = "https://raw.githubusercontent.com/Denmm-9/Mounx/main/Game_list.lua"
local success, result = pcall(function()
    return loadstring(game:HttpGet(ListURL))()
end)

if not success then
    warn("❌ Error loading Game_list:", result)
    return
end

local games = result
local loadedGame = false

-- Buscar si el juego actual está en la lista
for placeId, data in pairs(games) do
    if game.PlaceId == placeId then
        local scriptUrl = nil
        if type(data) == "table" then
            scriptUrl = data[deviceType] or data.pc or data.mobile
        elseif type(data) == "string" then
            scriptUrl = data
        end

        if scriptUrl then
            print("🔹 Loading game-specific script for", deviceType, ":", game.PlaceId)
            loadstring(game:HttpGet(scriptUrl))()
            loadedGame = true
        end
        break
    end
end

-- Si no hay juego en la lista, cargar scripts universales
if not loadedGame then
    print("🌍 No game found in Game_list. Loading universal scripts for:", deviceType)

    if deviceType == "pc" then
        -- 🧠 Dos scripts universales para PC
        local universal1 = "https://raw.githubusercontent.com/Denmm-9/Universal/main/NonUniversal.lua"
        local universal2 = "https://raw.githubusercontent.com/Denmm-9/Universal/main/SilentAimV2.lua"

        loadstring(game:HttpGet(universal1))()
        task.wait(1)
        loadstring(game:HttpGet(universal2))()

    elseif deviceType == "mobile" then
        -- 📱 Un solo script universal para Mobile
        local universalMobile = "https://raw.githubusercontent.com/Denmm-9/Universal/main/MobileUniversal.lua"
        loadstring(game:HttpGet(universalMobile))()
    end
end
