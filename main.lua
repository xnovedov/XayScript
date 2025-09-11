-- Подключаем OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/darkkcontrol/Roblox-Orion-UI-Libary-OP-UI-LIBARY-/refs/heads/main/source"))()

-- ========== КОНФИГ ==========
local ESP_ENABLED = true
local SHOW_BOX = true
local SHOW_HEALTH = true
local SHOW_DISTANCE = true
local SHOW_TRACERS = true
-- ============================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local espObjects = {}

-- ========== ESP ФУНКЦИИ ==========
local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

local function addESP(player)
    if player == LocalPlayer then return end
    local objects = {
        Box = createDrawing("Square", {Thickness = 1, Color = Color3.fromRGB(0, 255, 0), Filled = false, Visible = false}),
        Health = createDrawing("Line", {Thickness = 2, Color = Color3.fromRGB(255, 0, 0), Visible = false}),
        Distance = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = Color3.fromRGB(255,255,255), Visible = false}),
        Tracer = createDrawing("Line", {Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Visible = false})
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
            if vis then
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
                end

                -- Health
                objects.Health.Visible = SHOW_HEALTH
                if SHOW_HEALTH then
                    local ratio = humanoid.Health / humanoid.MaxHealth
                    objects.Health.From = Vector2.new(x - 5, y + height)
                    objects.Health.To = Vector2.new(x - 5, y + height * (1 - ratio))
                    objects.Health.Color = Color3.fromRGB(255 - 255 * ratio, 255 * ratio, 0)
                end

                -- Distance
                objects.Distance.Visible = SHOW_DISTANCE
                if SHOW_DISTANCE then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    objects.Distance.Position = Vector2.new(pos.X, y + height + 15)
                    objects.Distance.Text = string.format("[%dm]", math.floor(dist))
                end

                -- Tracer
                objects.Tracer.Visible = SHOW_TRACERS
                if SHOW_TRACERS then
                    objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    objects.Tracer.To = Vector2.new(pos.X, pos.Y)
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

for _, p in ipairs(Players:GetPlayers()) do
    addESP(p)
end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

-- ========== МЕНЮ OrionLib ==========
local Window = OrionLib:MakeWindow({Name = "ESP Menu", HidePremium = false, SaveConfig = false, IntroEnabled = false})

local Tab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddToggle({
    Name = "Включить ESP",
    Default = ESP_ENABLED,
    Callback = function(v) ESP_ENABLED = v end
})

Tab:AddToggle({
    Name = "Боксы",
    Default = SHOW_BOX,
    Callback = function(v) SHOW_BOX = v end
})

Tab:AddToggle({
    Name = "HP бар",
    Default = SHOW_HEALTH,
    Callback = function(v) SHOW_HEALTH = v end
})

Tab:AddToggle({
    Name = "Дистанция",
    Default = SHOW_DISTANCE,
    Callback = function(v) SHOW_DISTANCE = v end
})

Tab:AddToggle({
    Name = "Трейсеры",
    Default = SHOW_TRACERS,
    Callback = function(v) SHOW_TRACERS = v end
})

OrionLib:Init()
