-- Загружаем OrionLib
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/darkkcontrol/Roblox-Orion-UI-Libary-OP-UI-LIBARY-/main/source"))()
end)

if not success or type(OrionLib) ~= "table" then
    warn("Не удалось загрузить OrionLib. Проверь ссылку или доступ к GitHub.")
    return
end

-- Настройки ESP
local ESPSettings = {
    Enabled = false,
    ShowBox = false,
    ShowHealth = false,
    GradientHealth = false,
    ShowDistance = false,
    ShowTracers = false,

    Colors = {
        Box = Color3.fromRGB(255, 255, 255),
        Tracer = Color3.fromRGB(255, 255, 255),
        Distance = Color3.fromRGB(255, 255, 255),
        HP = Color3.fromRGB(0, 255, 0),
        HPGradStart = Color3.fromRGB(0, 255, 0),
        HPGradEnd = Color3.fromRGB(255, 0, 0),
    }
}

-- Хелпер для установки значений только если ESP включён
local function SafeSet(condition, key, value)
    if ESPSettings.Enabled and condition then
        key = value
    end
end

-- Создаём окно
local Window = OrionLib:MakeWindow({
    Name = "ESP Menu",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "ESPMenu"
})

local Tab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ESP Toggle
Tab:AddToggle({
    Name = "ESP",
    Default = ESPSettings.Enabled,
    Callback = function(v)
        ESPSettings.Enabled = v
    end
})

-- Боксы
Tab:AddToggle({
    Name = "Боксы",
    Default = ESPSettings.ShowBox,
    Callback = function(v)
        ESPSettings.ShowBox = ESPSettings.Enabled and v or false
    end
})

Tab:AddColorpicker({
    Name = "Цвет боксов",
    Default = ESPSettings.Colors.Box,
    Callback = function(c)
        if ESPSettings.Enabled and ESPSettings.ShowBox then
            ESPSettings.Colors.Box = c
        end
    end
})

-- HP Бар
Tab:AddToggle({
    Name = "HP бар",
    Default = ESPSettings.ShowHealth,
    Callback = function(v)
        ESPSettings.ShowHealth = ESPSettings.Enabled and v or false
    end
})

Tab:AddToggle({
    Name = "Градиент HP",
    Default = ESPSettings.GradientHealth,
    Callback = function(v)
        ESPSettings.GradientHealth = (ESPSettings.Enabled and ESPSettings.ShowHealth) and v or false
    end
})

Tab:AddColorpicker({
    Name = "Цвет HP (обычный)",
    Default = ESPSettings.Colors.HP,
    Callback = function(c)
        if ESPSettings.Enabled and ESPSettings.ShowHealth and not ESPSettings.GradientHealth then
            ESPSettings.Colors.HP = c
        end
    end
})

Tab:AddColorpicker({
    Name = "HP Gradient Start",
    Default = ESPSettings.Colors.HPGradStart,
    Callback = function(c)
        if ESPSettings.Enabled and ESPSettings.ShowHealth and ESPSettings.GradientHealth then
            ESPSettings.Colors.HPGradStart = c
        end
    end
})

Tab:AddColorpicker({
    Name = "HP Gradient End",
    Default = ESPSettings.Colors.HPGradEnd,
    Callback = function(c)
        if ESPSettings.Enabled and ESPSettings.ShowHealth and ESPSettings.GradientHealth then
            ESPSettings.Colors.HPGradEnd = c
        end
    end
})

-- Дистанция
Tab:AddToggle({
    Name = "Дистанция",
    Default = ESPSettings.ShowDistance,
    Callback = function(v)
        ESPSettings.ShowDistance = ESPSettings.Enabled and v or false
    end
})

Tab:AddColorpicker({
    Name = "Цвет дистанции",
    Default = ESPSettings.Colors.Distance,
    Callback = function(c)
        if ESPSettings.Enabled and ESPSettings.ShowDistance then
            ESPSettings.Colors.Distance = c
        end
    end
})

-- Трейсеры
Tab:AddToggle({
    Name = "Трейсеры",
    Default = ESPSettings.ShowTracers,
    Callback = function(v)
        ESPSettings.ShowTracers = ESPSettings.Enabled and v or false
    end
})

Tab:AddColorpicker({
    Name = "Цвет трейсеров",
    Default = ESPSettings.Colors.Tracer,
    Callback = function(c)
        if ESPSettings.Enabled and ESPSettings.ShowTracers then
            ESPSettings.Colors.Tracer = c
        end
    end
})
