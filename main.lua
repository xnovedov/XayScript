-- Подключаем OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xnovedov/XayScript/refs/heads/main/source.lua"))()

-- ========== КОНФИГ ==========
local ESP_ENABLED = true
local SHOW_BOX = true
local SHOW_HEALTH = true
local SHOW_DISTANCE = true
local SHOW_TRACERS = true
local SHOW_NAME = true
local SHOW_ROLE = true
local MAX_DISTANCE = 2000

local BoxColor = Color3.fromRGB(0, 255, 0)
local HPColor = Color3.fromRGB(255, 0, 0)
local DistColor = Color3.fromRGB(255, 255, 255)
local TracerColor = Color3.fromRGB(255, 255, 255)
local NameColor = Color3.fromRGB(255, 255, 0)
local RoleColor = Color3.fromRGB(255, 170, 0)

local ConfigFolder = "XayScript/XayScriptUniversal"
local CurrentCFGName = "default"
local ConfigList = {}

if not isfolder("XayScript") then makefolder("XayScript") end
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

-- ========== CFG СИСТЕМА ==========
local HttpService = game:GetService("HttpService")

local function saveCFG(name)
    local data = {
        ESP_ENABLED = ESP_ENABLED,
        SHOW_BOX = SHOW_BOX,
        SHOW_HEALTH = SHOW_HEALTH,
        SHOW_DISTANCE = SHOW_DISTANCE,
        SHOW_TRACERS = SHOW_TRACERS,
        SHOW_NAME = SHOW_NAME,
        SHOW_ROLE = SHOW_ROLE,
        MAX_DISTANCE = MAX_DISTANCE,
        BoxColor = {BoxColor.R, BoxColor.G, BoxColor.B},
        HPColor = {HPColor.R, HPColor.G, HPColor.B},
        DistColor = {DistColor.R, DistColor.G, DistColor.B},
        TracerColor = {TracerColor.R, TracerColor.G, TracerColor.B},
        NameColor = {NameColor.R, NameColor.G, NameColor.B},
        RoleColor = {RoleColor.R, RoleColor.G, RoleColor.B},
    }
    writefile(ConfigFolder.."/"..name..".json", HttpService:JSONEncode(data))
end

local function loadCFG(name)
    local path = ConfigFolder.."/"..name..".json"
    if not isfile(path) then return end
    local data = HttpService:JSONDecode(readfile(path))

    ESP_ENABLED = data.ESP_ENABLED
    SHOW_BOX = data.SHOW_BOX
    SHOW_HEALTH = data.SHOW_HEALTH
    SHOW_DISTANCE = data.SHOW_DISTANCE
    SHOW_TRACERS = data.SHOW_TRACERS
    SHOW_NAME = data.SHOW_NAME
    SHOW_ROLE = data.SHOW_ROLE
    MAX_DISTANCE = data.MAX_DISTANCE
    BoxColor = Color3.new(unpack(data.BoxColor))
    HPColor = Color3.new(unpack(data.HPColor))
    DistColor = Color3.new(unpack(data.DistColor))
    TracerColor = Color3.new(unpack(data.TracerColor))
    NameColor = Color3.new(unpack(data.NameColor))
    RoleColor = Color3.new(unpack(data.RoleColor))

    -- Синхронизация с UI
    if UIRefs.ToggleESP then UIRefs.ToggleESP:Set(ESP_ENABLED) end
    if UIRefs.ToggleBox then UIRefs.ToggleBox:Set(SHOW_BOX) end
    if UIRefs.ToggleHP then UIRefs.ToggleHP:Set(SHOW_HEALTH) end
    if UIRefs.ToggleDist then UIRefs.ToggleDist:Set(SHOW_DISTANCE) end
    if UIRefs.ToggleTracers then UIRefs.ToggleTracers:Set(SHOW_TRACERS) end
    if UIRefs.ToggleName then UIRefs.ToggleName:Set(SHOW_NAME) end
    if UIRefs.ToggleRole then UIRefs.ToggleRole:Set(SHOW_ROLE) end

    if UIRefs.SliderDist then UIRefs.SliderDist:Set(MAX_DISTANCE) end

    if UIRefs.ColorBox then UIRefs.ColorBox:Set(BoxColor) end
    if UIRefs.ColorHP then UIRefs.ColorHP:Set(HPColor) end
    if UIRefs.ColorTracer then UIRefs.ColorTracer:Set(TracerColor) end
    if UIRefs.ColorDist then UIRefs.ColorDist:Set(DistColor) end
    if UIRefs.ColorName then UIRefs.ColorName:Set(NameColor) end
    if UIRefs.ColorRole then UIRefs.ColorRole:Set(RoleColor) end
end

local function refreshCFGs(dropdown)
    ConfigList = {}
    for _, f in pairs(listfiles(ConfigFolder)) do
        local n = f:match("([^/\\]+)%.json$")
        if n then table.insert(ConfigList, n) end
    end
    if dropdown then dropdown:Refresh(ConfigList, CurrentCFGName) end
end

-- ========== ESP ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local espObjects = {}

local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

local function addESP(player)
    if player == LocalPlayer then return end
    espObjects[player] = {
        Box = createDrawing("Square", {Thickness = 1, Color = BoxColor, Filled = false, Visible = false}),
        Distance = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = DistColor, Visible = false}),
        HPText = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = HPColor, Visible = false}),
        Tracer = createDrawing("Line", {Thickness = 1, Color = TracerColor, Visible = false}),
        Name = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = NameColor, Visible = false}),
        Role = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = RoleColor, Visible = false}),
    }
end

local function removeESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do obj:Remove() end
        espObjects[player] = nil
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not ESP_ENABLED then
        for _, objects in pairs(espObjects) do
            for _, obj in pairs(objects) do obj.Visible = false end
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
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist <= MAX_DISTANCE then
                    local scale = 2000 / (pos.Z)
                    local width = 2 * scale
                    local height = 3 * scale
                    local x = pos.X - width / 2
                    local y = pos.Y - height / 2

                    objects.Box.Visible = SHOW_BOX
                    if SHOW_BOX then
                        objects.Box.Size = Vector2.new(width, height)
                        objects.Box.Position = Vector2.new(x, y)
                        objects.Box.Color = BoxColor
                    end

                    objects.Distance.Visible = SHOW_DISTANCE
                    if SHOW_DISTANCE then
                        objects.Distance.Position = Vector2.new(pos.X, y + height + 15)
                        objects.Distance.Text = string.format("[%dm]", math.floor(dist))
                        objects.Distance.Color = DistColor
                    end

                    objects.HPText.Visible = SHOW_HEALTH
                    if SHOW_HEALTH then
                        objects.HPText.Position = Vector2.new(pos.X, y + height + 30)
                        objects.HPText.Text = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                        objects.HPText.Color = HPColor
                    end

                    objects.Tracer.Visible = SHOW_TRACERS
                    if SHOW_TRACERS then
                        objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        objects.Tracer.To = Vector2.new(pos.X, pos.Y)
                        objects.Tracer.Color = TracerColor
                    end

                    objects.Name.Visible = SHOW_NAME
                    if SHOW_NAME then
                        objects.Name.Position = Vector2.new(pos.X, y - 15)
                        objects.Name.Text = player.Name
                        objects.Name.Color = NameColor
                    end

                    objects.Role.Visible = SHOW_ROLE
                    if SHOW_ROLE then
                        objects.Role.Position = Vector2.new(pos.X, y - 30)
                        objects.Role.Text = player.Team and player.Team.Name or "[No Team]"
                        objects.Role.Color = RoleColor
                    end
                else
                    for _, obj in pairs(objects) do obj.Visible = false end
                end
            else
                for _, obj in pairs(objects) do obj.Visible = false end
            end
        else
            for _, obj in pairs(objects) do obj.Visible = false end
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

-- ========== UI ==========
UIRefs = {}

local Window = OrionLib:MakeWindow({Name = "XayScript Universal", HidePremium = true, SaveConfig = false, IntroEnabled = true})

local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
MainTab:AddParagraph("⚠️ Рекомендация / Recommendation",
"РУС: понижайте графику и дистанцию ESP. Большое скопление игроков с функциями текста (например дистанция или роль) вызывает лаги. А также вызывают лаги множественные инжекты скрипта.\n\nENG: Lower graphics and ESP distance. Many players with text features (like distance or role) cause heavy lag. Multiple script injections also cause lags.")

local ESP = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})

UIRefs.ToggleESP = ESP:AddToggle({Name = "Включить ESP", Default = ESP_ENABLED, Callback = function(v) ESP_ENABLED = v end})
UIRefs.ToggleBox = ESP:AddToggle({Name = "Боксы", Default = SHOW_BOX, Callback = function(v) SHOW_BOX = v end})
UIRefs.ColorBox = ESP:AddColorpicker({Name = "Цвет боксов", Default = BoxColor, Callback = function(c) BoxColor = c end})

UIRefs.ToggleHP = ESP:AddToggle({Name = "HP текст", Default = SHOW_HEALTH, Callback = function(v) SHOW_HEALTH = v end})
UIRefs.ColorHP = ESP:AddColorpicker({Name = "Цвет HP", Default = HPColor, Callback = function(c) HPColor = c end})

UIRefs.ToggleDist = ESP:AddToggle({Name = "Дистанция", Default = SHOW_DISTANCE, Callback = function(v) SHOW_DISTANCE = v end})
UIRefs.ColorDist = ESP:AddColorpicker({Name = "Цвет дистанции", Default = DistColor, Callback = function(c) DistColor = c end})
UIRefs.SliderDist = ESP:AddSlider({Name = "Макс дистанция ESP", Min = 100, Max = 5000, Default = MAX_DISTANCE, Increment = 50, Callback = function(v) MAX_DISTANCE = v end})

UIRefs.ToggleTracers = ESP:AddToggle({Name = "Трейсеры", Default = SHOW_TRACERS, Callback = function(v) SHOW_TRACERS = v end})
UIRefs.ColorTracer = ESP:AddColorpicker({Name = "Цвет трейсеров", Default = TracerColor, Callback = function(c) TracerColor = c end})

UIRefs.ToggleName = ESP:AddToggle({Name = "Ники", Default = SHOW_NAME, Callback = function(v) SHOW_NAME = v end})
UIRefs.ColorName = ESP:AddColorpicker({Name = "Цвет ников", Default = NameColor, Callback = function(c) NameColor = c end})

UIRefs.ToggleRole = ESP:AddToggle({Name = "Роли", Default = SHOW_ROLE, Callback = function(v) SHOW_ROLE = v end})
UIRefs.ColorRole = ESP:AddColorpicker({Name = "Цвет ролей", Default = RoleColor, Callback = function(c) RoleColor = c end})

local Configs = Window:MakeTab({Name = "Configs", Icon = "rbxassetid://4483345998", PremiumOnly = false})
Configs:AddTextbox({Name = "Config name", Default = "default", TextDisappear = false, Callback = function(value) CurrentCFGName = value end})
local DropdownCFG = Configs:AddDropdown({Name = "Select config", Default = "default", Options = ConfigList, Callback = function(value) loadCFG(value) end})

Configs:AddButton({Name = "💾 Save", Callback = function() saveCFG(CurrentCFGName) refreshCFGs(DropdownCFG) end})
Configs:AddButton({Name = "🔄 Refresh", Callback = function() refreshCFGs(DropdownCFG) end})

local About = Window:MakeTab({Name = "About", Icon = "rbxassetid://4483345998", PremiumOnly = false})
About:AddLabel("Version 0.9 | Optimized with CFG")
About:AddLabel("Developer: XayoriNovedov")
About:AddLabel("t.me/XayNovTeam")
a
refreshCFGs(DropdownCFG)
OrionLib:Init()
