local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xnovedov/XayScript/refs/heads/main/source.lua"))()

local ESP_ENABLED = false
local SHOW_BOX = false
local SHOW_HEALTH = false
local SHOW_GRADIENT_HEALTH = false
local SHOW_DISTANCE = false
local SHOW_TRACERS = false
local SHOW_WEAPON = false
local SHOW_NAME = false
local SHOW_ROLE = false

local BoxColor = Color3.fromRGB(0, 255, 0)
local HPColor = Color3.fromRGB(0, 255, 0)
local HPGradStart = Color3.fromRGB(255, 0, 0)
local HPGradEnd = Color3.fromRGB(0, 255, 0)
local TracerColor = Color3.fromRGB(255, 255, 255)
local DistColor = Color3.fromRGB(255, 255, 255)
local WeaponColor = Color3.fromRGB(0,150,255)
local NameColor = Color3.fromRGB(255,255,255)
local RoleColor = Color3.fromRGB(200,200,50)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local espObjects, itemESP = {}, {}

local UPDATE_INTERVAL = 0.07
local MAX_DISTANCE = 2000
local lastUpdate = 0

local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

local function lerpColor(c1, c2, t)
    return Color3.new(c1.R + (c2.R - c1.R) * t, c1.G + (c2.G - c1.G) * t, c1.B + (c2.B - c1.B) * t)
end

local function addESP(player)
    if player == LocalPlayer or espObjects[player] then return end
    local objects = {
        Box = createDrawing("Square", {Thickness = 1, Filled = false, Visible = false}),
        Health = createDrawing("Square", {Thickness = 1, Filled = true, Visible = false}),
        HealthBG = createDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.fromRGB(40,40,40), Visible = false}),
        Info = createDrawing("Text", {Size = 16, Center = true, Outline = true, Visible = false}),
        Tracer = createDrawing("Line", {Thickness = 1, Visible = false}),
    }
    espObjects[player] = objects
end

local function removeESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do obj:Remove() end
        espObjects[player] = nil
    end
end

local function addItemESP(item)
    if itemESP[item] then return end
    local text = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = WeaponColor, Visible = false, Text = "Gun"})
    itemESP[item] = text
end

local function removeItemESP(item)
    if itemESP[item] then itemESP[item]:Remove() itemESP[item] = nil end
end

RunService.Heartbeat:Connect(function(dt)
    lastUpdate = lastUpdate + dt
    if lastUpdate < UPDATE_INTERVAL then return end
    lastUpdate = 0

    if not ESP_ENABLED then
        for _, objects in pairs(espObjects) do for _, obj in pairs(objects) do obj.Visible = false end end
        for _, obj in pairs(itemESP) do obj.Visible = false end
        return
    end

    for player, objects in pairs(espObjects) do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if hrp and humanoid and humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            local lchr = LocalPlayer.Character
            local dist = (lchr and lchr:FindFirstChild("HumanoidRootPart")) and (lchr.HumanoidRootPart.Position - hrp.Position).Magnitude or 0

            if vis and dist < MAX_DISTANCE then
                local scale = 2000 / pos.Z
                local width, height = 2 * scale, 3 * scale
                local x, y = pos.X - width/2, pos.Y - height/2

                objects.Box.Visible = SHOW_BOX
                if SHOW_BOX then
                    objects.Box.Size = Vector2.new(width, height)
                    objects.Box.Position = Vector2.new(x, y)
                    objects.Box.Color = BoxColor
                end

                objects.Health.Visible = SHOW_HEALTH
                objects.HealthBG.Visible = SHOW_HEALTH
                if SHOW_HEALTH then
                    local ratio = humanoid.Health / humanoid.MaxHealth
                    objects.HealthBG.Position = Vector2.new(x - 6, y)
                    objects.HealthBG.Size = Vector2.new(4, height)
                    objects.Health.Position = Vector2.new(x - 6, y + height * (1 - ratio))
                    objects.Health.Size = Vector2.new(4, height * ratio)
                    objects.Health.Color = SHOW_GRADIENT_HEALTH and lerpColor(HPGradStart, HPGradEnd, ratio) or HPColor
                end

                objects.Tracer.Visible = SHOW_TRACERS
                if SHOW_TRACERS then
                    objects.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    objects.Tracer.To = Vector2.new(pos.X, pos.Y)
                    objects.Tracer.Color = TracerColor
                end

                objects.Info.Visible = (SHOW_NAME or SHOW_ROLE or SHOW_DISTANCE)
                if objects.Info.Visible then
                    local info = {}
                    if SHOW_NAME then table.insert(info, player.Name) end
                    if SHOW_ROLE then table.insert(info, "["..(player.Team and player.Team.Name or "No Team").."]") end
                    if SHOW_DISTANCE then table.insert(info, "["..math.floor(dist).."m]") end
                    objects.Info.Text = table.concat(info, " ")
                    objects.Info.Position = Vector2.new(pos.X, y - 15)
                    objects.Info.Color = NameColor
                end
            else
                for _, obj in pairs(objects) do obj.Visible = false end
            end
        else
            for _, obj in pairs(objects) do obj.Visible = false end
        end
    end

    for item, text in pairs(itemESP) do
        if item and item.Parent then
            local pos, vis = Camera:WorldToViewportPoint(item.Position)
            if vis and SHOW_WEAPON then
                text.Position = Vector2.new(pos.X, pos.Y)
                text.Visible = true
                text.Color = WeaponColor
            else
                text.Visible = false
            end
        else
            removeItemESP(item)
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

workspace.DescendantAdded:Connect(function(obj) if obj.Name == "GunDrop" then addItemESP(obj) end end)
workspace.DescendantRemoving:Connect(function(obj) if itemESP[obj] then removeItemESP(obj) end end)

local Window = OrionLib:MakeWindow({Name = "XayScript Universal", HidePremium = true, SaveConfig = false, IntroEnabled = true})
local Tab = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})

Tab:AddToggle({Name = "Включить ESP", Default = ESP_ENABLED, Callback = function(v) ESP_ENABLED = v end})
Tab:AddToggle({Name = "Боксы", Default = SHOW_BOX, Callback = function(v) SHOW_BOX = v end})
Tab:AddColorpicker({Name = "Цвет боксов", Default = BoxColor, Callback = function(c) BoxColor = c end})
Tab:AddToggle({Name = "HP бар", Default = SHOW_HEALTH, Callback = function(v) SHOW_HEALTH = v end})
Tab:AddToggle({Name = "Градиент HP", Default = SHOW_GRADIENT_HEALTH, Callback = function(v) SHOW_GRADIENT_HEALTH = v end})
Tab:AddColorpicker({Name = "Цвет HP", Default = HPColor, Callback = function(c) HPColor = c end})
Tab:AddColorpicker({Name = "HP Gradient Start", Default = HPGradStart, Callback = function(c) HPGradStart = c end})
Tab:AddColorpicker({Name = "HP Gradient End", Default = HPGradEnd, Callback = function(c) HPGradEnd = c end})
Tab:AddToggle({Name = "Дистанция", Default = SHOW_DISTANCE, Callback = function(v) SHOW_DISTANCE = v end})
Tab:AddColorpicker({Name = "Цвет дистанции", Default = DistColor, Callback = function(c) DistColor = c end})
Tab:AddToggle({Name = "Трейсеры", Default = SHOW_TRACERS, Callback = function(v) SHOW_TRACERS = v end})
Tab:AddColorpicker({Name = "Цвет трейсеров", Default = TracerColor, Callback = function(c) TracerColor = c end})
Tab:AddToggle({Name = "Ники", Default = SHOW_NAME, Callback = function(v) SHOW_NAME = v end})
Tab:AddColorpicker({Name = "Цвет ников", Default = NameColor, Callback = function(c) NameColor = c end})
Tab:AddToggle({Name = "Роли", Default = SHOW_ROLE, Callback = function(v) SHOW_ROLE = v end})
Tab:AddColorpicker({Name = "Цвет ролей", Default = RoleColor, Callback = function(c) RoleColor = c end})
Tab:AddToggle({Name = "ESP оружия", Default = SHOW_WEAPON, Callback = function(v) SHOW_WEAPON = v end})
Tab:AddColorpicker({Name = "Цвет оружия", Default = WeaponColor, Callback = function(c) WeaponColor = c end})

local About = Window:MakeTab({Name = "About", Icon = "rbxassetid://4483345998", PremiumOnly = false})
About:AddLabel("Version 0.4 Optimized")
About:AddLabel("Developer: XayoriNovedov")
About:AddLabel("t.me/XayNovTeam")

OrionLib:Init()
