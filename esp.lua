-- Загружаем Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Загружаем наш ESP модуль
local ESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/yourusername/yourrepo/main/esp.lua'))()

-- Создаем окно GUI
local Window = Rayfield:CreateWindow({
    Name = "ESP Menu",
    LoadingTitle = "Загрузка ESP...",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ESPConfig",
        FileName = "Settings"
    }
})

-- Создаем вкладку для ESP
local ESPTab = Window:CreateTab("ESP Настройки", 4483362458)

-- Переключатель основного ESP
ESPTab:CreateToggle({
    Name = "Глобальный ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP:ToggleGlobalESP(Value)
    end,
})

-- Отдельные переключатели для каждого типа ESP
ESPTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = true,
    Callback = function(Value)
        ESP:ToggleESPType("Box", Value)
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Health",
    CurrentValue = true,
    Callback = function(Value)
        ESP:ToggleESPType("Health", Value)
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Distance",
    CurrentValue = true,
    Callback = function(Value)
        ESP:ToggleESPType("Distance", Value)
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Nick",
    CurrentValue = true,
    Callback = function(Value)
        ESP:ToggleESPType("Nick", Value)
    end,
})

-- Настройки цвета
ESPTab:CreateColorPicker({
    Name = "Цвет боксов",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        ESP:ChangeColor("Box", Color)
    end
})

ESPTab:CreateColorPicker({
    Name = "Цвет здоровья",
    Color = Color3.fromRGB(255, 100, 100),
    Callback = function(Color)
        ESP:ChangeColor("Health", Color)
    end
})

ESPTab:CreateColorPicker({
    Name = "Цвет дистанции",
    Color = Color3.fromRGB(200, 200, 255),
    Callback = function(Color)
        ESP:ChangeColor("Distance", Color)
    end
})

ESPTab:CreateColorPicker({
    Name = "Цвет ника",
    Color = Color3.fromRGB(255, 255, 255),
    Callback = function(Color)
        ESP:ChangeColor("Nick", Color)
    end
})

-- Слайдер для дистанции
ESPTab:CreateSlider({
    Name = "Макс. дистанция",
    Range = {0, 1000},
    Increment = 50,
    Suffix = "studs",
    CurrentValue = 500,
    Callback = function(Value)
        ESP:SetMaxDistance(Value)
    end
})

-- Кнопка для обновления ESP
ESPTab:CreateButton({
    Name = "Обновить ESP",
    Callback = function()
        ESP:RefreshAllESP()
    end,
})

-- Информационная секция
ESPTab:CreateSection("Информация")
ESPTab:CreateLabel("ESP загружен и готов к работе!")

-- Обновляем счетчик игроков
spawn(function()
    while task.wait(5) do
        ESPTab:CreateLabel("Игроков отслеживается: " .. ESP:GetTrackedPlayers())
    end
end)

print("ESP Menu loaded successfully!")
