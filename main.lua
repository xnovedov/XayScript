-- Подключаем OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/darkkcontrol/Roblox-Orion-UI-Libary-OP-UI-LIBARY-/refs/heads/main/source"))()

-- ========== КОНФИГ ==========
local ESP_ENABLED = false
local SHOW_BOX = true
local SHOW_HEALTH = true
local SHOW_DISTANCE = true
local SHOW_TRACERS = true
local MAX_DISTANCE = 5000 -- максимальная дистанция отображения

-- Цвета ESP (можно менять в меню)
local BoxColor = Color3.fromRGB(0, 255, 0)
local TracerColor = Color3.fromRGB(255, 255, 255)
local DistColor = Color3.fromRGB(255, 255, 255)
-- ============================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local espObjects = {}

-- Функция для создания Drawing объектов
local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

-- Линейный градиент для HP-бара (от красного к зелёному)
local function healthGradient(ratio)
    if ratio <= 0.5 then
        return Color3.fromRGB(255, math.floor(ratio * 510), 0) -- красный -> жёлтый
    else
        return Color3.fromRGB(math.floor((1 - ratio) * 510), 255, 0) -- жёлтый -> зелёный
    end
end

-- Создание ESP
local function addESP(player)
    if player == LocalPlayer then return end
    local objects = {
        Box = createDrawing("Square", {Thickness = 1, Color = BoxColor, Filled = false, Visible = false}),
        Health = createDrawing("Line", {Thickness = 2, Color = Color3.fromRGB(255, 0, 0), Visible = false}),
        Distance = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = DistColor, Visible = false}),
        Tracer = createDrawing("Line", {Thickness = 1, Color = TracerColor, Visible = false})
    }
    espObjects[player] = objects
end

local function removeESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            obj:Remove()
        end
        espObjects[player] = nil
    end
end

-- Основной цикл ESP
game:GetService("RunService").RenderStepped:Connect(function()
    if not ESP_ENABLED then
        for _, objects in pairs(espObjects) do
            for _, obj in pairs(objects) do
                obj.Visible = false
            end
        end
        return
    end

    for player, objects in pairs(espObjects) do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if hrp and humanoid and humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if vis and distance <= MAX_DISTANCE then
                local scale = 2000 / (pos.Z)
                local width = 2 * scale
                local height = 3 * scale
                local x = pos.X - width / 2
                local y = pos.Y - height / 2

                -- Box
                objects.Box.Visible = SHOW_BOX
                if SHOW_BOX then
                    objects.Box.Size = Vector2.new(width, height)
                    objects.Box.Position = Vector2.new(x, y)
                    objects.Box.Color = BoxColor
                end

                -- HP bar
                objects.Health.Visible = SHOW_HEALTH
                if SHOW_HEALTH then
                    local ratio = humanoid.Health / humanoid.MaxHealth
                    objects.Health.From = Vector2.new(x - 5, y + height)
                    objects.Health.To = Vector2.new(x - 5, y + height * (1 - ratio))
                    objects.Health.Color = healthGradient(ratio)
                end

                -- Distance
                objects.Distance.Visible = SHOW_DISTANCE
                if SHOW_DISTANCE then
                    objects.Distance.Position = Vector2.new(pos.X, y + height + 15)
                    objects.Distance.Text = string.format("[%dm]", math.floor(distance))
                    objects.Distance.Color = DistColor
                end

                -- Tracer
                objects.Tracer.Visible = SHOW_TRACERS
                if SHOW_TRACERS then
                    objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    objects.Tracer.To = Vector2.new(pos.X, pos.Y)
                    objects.Tracer.Color = TracerColor
                end
            else
                for _, obj in pairs(objects) do
                    obj.Visible = false
                end
            end
        else
            for _, obj in pairs(objects) do
                obj.Visible = false
            end
        end
    end
end)

-- Игроки
for _, p in ipairs(Players:GetPlayers()) do
    addESP(p)
end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

-- ========== ЗАПУСК МЕНЮ ПОСЛЕ ИНИЦИАЛИЗАЦИИ ==========
task.wait(2) -- ждём загрузку ESP

local Window = OrionLib:MakeWindow({Name = "ESP Menu", HidePremium = false, SaveConfig = false, IntroEnabled = false})

local Tab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Переключатели
Tab:AddToggle({Name = "Включить ESP", Default = ESP_ENABLED, Callback = function(v) ESP_ENABLED = v end})
Tab:AddToggle({Name = "Боксы", Default = SHOW_BOX, Callback = function(v) SHOW_BOX = v end})
Tab:AddToggle({Name = "HP бар (градиент)", Default = SHOW_HEALTH, Callback = function(v) SHOW_HEALTH = v end})
Tab:AddToggle({Name = "Дистанция", Default = SHOW_DISTANCE, Callback = function(v) SHOW_DISTANCE = v end})
Tab:AddToggle({Name = "Трейсеры", Default = SHOW_TRACERS, Callback = function(v) SHOW_TRACERS = v end})

-- Настройка цветов
Tab:AddColorpicker({Name = "Цвет боксов", Default = BoxColor, Callback = function(c) BoxColor = c end})
Tab:AddColorpicker({Name = "Цвет трейсеров", Default = TracerColor, Callback = function(c) TracerColor = c end})
Tab:AddColorpicker({Name = "Цвет дистанции", Default = DistColor, Callback = function(c) DistColor = c end})

OrionLib:Init()
