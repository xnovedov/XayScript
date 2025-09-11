-- Подключаем OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xnovedov/XayScript/refs/heads/main/source"))()

-- ========== КОНФИГ ==========
local ESP_ENABLED = false
local SHOW_BOX = false
local SHOW_HEALTH = false
local SHOW_GRADIENT_HEALTH = false
local SHOW_DISTANCE = false
local SHOW_TRACERS = false
local SHOW_WEAPON = false
-- ============================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local espObjects = {}
local itemESP = {}

-- ========= ХЕЛПЕРЫ =========
local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

local function lerpColor(c1, c2, t)
    return Color3.new(
        c1.R + (c2.R - c1.R) * t,
        c1.G + (c2.G - c1.G) * t,
        c1.B + (c2.B - c1.B) * t
    )
end

-- ========= ESP ДЛЯ ИГРОКОВ =========
local function addESP(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end

    local objects = {
        Box = createDrawing("Square", {Thickness = 1, Color = Color3.fromRGB(0, 255, 0), Filled = false, Visible = false}),
        Health = createDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.fromRGB(0, 255, 0), Visible = false}),
        HealthBG = createDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.fromRGB(40, 40, 40), Visible = false}),
        Distance = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = Color3.fromRGB(255,255,255), Visible = false}),
        Tracer = createDrawing("Line", {Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Visible = false}),
        Role = createDrawing("Text", {Size = 14, Center = true, Outline = true, Color = Color3.fromRGB(255,255,0), Visible = false})
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

-- ========= ESP ДЛЯ ПРЕДМЕТОВ =========
local function addItemESP(item)
    if itemESP[item] then return end
    local text = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = Color3.fromRGB(0,150,255), Visible = false, Text = "Gun"})
    itemESP[item] = text
end

local function removeItemESP(item)
    if itemESP[item] then
        itemESP[item]:Remove()
        itemESP[item] = nil
    end
end

-- ========= РЕНДЕР =========
RunService.RenderStepped:Connect(function()
    -- Если ESP выключен — скрыть всё
    if not ESP_ENABLED then
        for _, objects in pairs(espObjects) do
            for _, obj in pairs(objects) do
                obj.Visible = false
            end
        end
        for _, obj in pairs(itemESP) do
            obj.Visible = false
        end
        return
    end

    -- Игроки
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
                objects.HealthBG.Visible = SHOW_HEALTH
                if SHOW_HEALTH then
                    local ratio = humanoid.Health / humanoid.MaxHealth
                    objects.HealthBG.Position = Vector2.new(x - 6, y)
                    objects.HealthBG.Size = Vector2.new(4, height)

                    objects.Health.Position = Vector2.new(x - 6, y + height * (1 - ratio))
                    objects.Health.Size = Vector2.new(4, height * ratio)

                    if SHOW_GRADIENT_HEALTH then
                        objects.Health.Color = lerpColor(Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), ratio)
                    else
                        objects.Health.Color = Color3.fromRGB(0,255,0)
                    end
                end

                -- Distance
                objects.Distance.Visible = SHOW_DISTANCE
                if SHOW_DISTANCE then
                    local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                        and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        or 0
                    objects.Distance.Position = Vector2.new(pos.X, y + height + 15)
                    objects.Distance.Text = string.format("[%dm]", math.floor(dist))
                end

                -- Tracer
                objects.Tracer.Visible = SHOW_TRACERS
                if SHOW_TRACERS then
                    objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    objects.Tracer.To = Vector2.new(pos.X, pos.Y)
                end

                -- Role (Sheriff / Hero / Murderer check через Tools)
                objects.Role.Visible = true
                if character:FindFirstChild("Knife") then
                    objects.Role.Text = "[Murderer]"
                    objects.Role.Color = Color3.fromRGB(255,0,0)
                elseif character:FindFirstChild("Revolver") then
                    objects.Role.Text = "[Sheriff]"
                    objects.Role.Color = Color3.fromRGB(0,150,255)
                elseif character:FindFirstChild("GunDrop") then
                    objects.Role.Text = "[Hero]"
                    objects.Role.Color = Color3.fromRGB(0,255,0)
                else
                    objects.Role.Text = "[Innocent]"
                    objects.Role.Color = Color3.fromRGB(255,255,255)
                end
                objects.Role.Position = Vector2.new(pos.X, y - 15)

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

    -- Оружие на земле
    for item, text in pairs(itemESP) do
        if item and item.Parent then
            local pos, vis = Camera:WorldToViewportPoint(item.Position)
            if vis and SHOW_WEAPON then
                text.Position = Vector2.new(pos.X, pos.Y)
                text.Visible = true
            else
                text.Visible = false
            end
        else
            removeItemESP(item)
        end
    end
end)

-- Подключение к игрокам
for _, p in ipairs(Players:GetPlayers()) do
    addESP(p)
end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

-- Подключение к оружию
workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "GunDrop" then
        addItemESP(obj)
    end
end)
workspace.DescendantRemoving:Connect(function(obj)
    if itemESP[obj] then
        removeItemESP(obj)
    end
end)

-- ========== МЕНЮ OrionLib ==========
local Window = OrionLib:MakeWindow({Name = "ESP Menu", HidePremium = false, SaveConfig = false, IntroEnabled = false})
local Tab = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})

Tab:AddToggle({Name = "Включить ESP", Default = ESP_ENABLED, Callback = function(v) ESP_ENABLED = v end})
Tab:AddToggle({Name = "Боксы", Default = SHOW_BOX, Callback = function(v) SHOW_BOX = v end})
Tab:AddToggle({Name = "HP бар", Default = SHOW_HEALTH, Callback = function(v) SHOW_HEALTH = v end})
Tab:AddToggle({Name = "Градиент HP", Default = SHOW_GRADIENT_HEALTH, Callback = function(v) SHOW_GRADIENT_HEALTH = v end})
Tab:AddToggle({Name = "Дистанция", Default = SHOW_DISTANCE, Callback = function(v) SHOW_DISTANCE = v end})
Tab:AddToggle({Name = "Трейсеры", Default = SHOW_TRACERS, Callback = function(v) SHOW_TRACERS = v end})
Tab:AddToggle({Name = "ESP оружия", Default = SHOW_WEAPON, Callback = function(v) SHOW_WEAPON = v end})

OrionLib:Init()
