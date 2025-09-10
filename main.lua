-- main.lua
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/ArowixExploits/RayfieldUILibrary/refs/heads/main/source'))()

-- Загружаем ESP модуль
local ESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/yourusername/roblox-esp/main/esp.lua'))()

-- Создаем GUI
local Window = Rayfield:CreateWindow({
    Name = "🔥 ESP Menu",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by Script",
    ConfigurationSaving = {Enabled = true, FolderName = "ESPConfig", FileName = "Settings"}
})

local ESPTab = Window:CreateTab("ESP Настройки", 4483362458)

-- Переключатель ESP
ESPTab:CreateToggle({
    Name = "Включить ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP:ToggleGlobalESP(Value)
    end,
})

-- Кнопка обновления
ESPTab:CreateButton({
    Name = "Обновить ESP",
    Callback = function()
        ESP:RefreshAllESP()
    end,
})

print("✅ ESP Menu loaded!")
