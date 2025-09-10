
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/ArowixExploits/RayfieldUILibrary/refs/heads/main/source'))()


local ESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/yourusername/roblox-esp/main/esp.lua'))()


local Window = Rayfield:CreateWindow({
    Name = "🔥 ESP Menu",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by Script",
    ConfigurationSaving = {Enabled = true, FolderName = "ESPConfig", FileName = "Settings"}
})

local ESPTab = Window:CreateTab("ESP Настройки", 4483362458)


ESPTab:CreateToggle({
    Name = "Включить ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP:ToggleGlobalESP(Value)
    end,
})


ESPTab:CreateButton({
    Name = "Обновить ESP",
    Callback = function()
        ESP:RefreshAllESP()
    end,
})

print("✅ ESP Menu loaded!")
