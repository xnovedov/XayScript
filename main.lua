local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xnovedov/XayScript/refs/heads/main/source.lua"))()

local ESP_ENABLED = false
local SHOW_BOX = false
local SHOW_HEALTH = false
local SHOW_DISTANCE = false
local SHOW_TRACERS = false
local SHOW_NAME = false
local SHOW_ROLE = false
local MAX_DISTANCE = 2000

local AIMBOT_ENABLED = false
local AIMBOT_SMOOTH = 5
local AIMBOT_FOV = 200
local AIMBOT_USE_FOV = false
local AIMBOT_MODE = "Mouse"
local AIMBOT_KEY = Enum.UserInputType.MouseButton2
local AIMBOT_HITBOXES = {"Head"}

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
        AIMBOT_ENABLED = AIMBOT_ENABLED,
        AIMBOT_SMOOTH = AIMBOT_SMOOTH,
        AIMBOT_FOV = AIMBOT_FOV,
        AIMBOT_USE_FOV = AIMBOT_USE_FOV,
        AIMBOT_MODE = AIMBOT_MODE,
        AIMBOT_KEY = AIMBOT_KEY.Name,
        AIMBOT_HITBOXES = AIMBOT_HITBOXES,
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
    AIMBOT_ENABLED = data.AIMBOT_ENABLED
    AIMBOT_SMOOTH = data.AIMBOT_SMOOTH
    AIMBOT_FOV = data.AIMBOT_FOV
    AIMBOT_USE_FOV = data.AIMBOT_USE_FOV
    AIMBOT_MODE = data.AIMBOT_MODE
    AIMBOT_KEY = Enum.UserInputType[data.AIMBOT_KEY] or Enum.UserInputType.MouseButton2
    AIMBOT_HITBOXES = data.AIMBOT_HITBOXES
    BoxColor = Color3.new(unpack(data.BoxColor))
    HPColor = Color3.new(unpack(data.HPColor))
    DistColor = Color3.new(unpack(data.DistColor))
    TracerColor = Color3.new(unpack(data.TracerColor))
    NameColor = Color3.new(unpack(data.NameColor))
    RoleColor = Color3.new(unpack(data.RoleColor))
end

local function refreshCFGs(dropdown)
    ConfigList = {}
    for _, f in pairs(listfiles(ConfigFolder)) do
        local n = f:match("([^/\\]+)%.json$")
        if n then table.insert(ConfigList, n) end
    end
    if dropdown then dropdown:Refresh(ConfigList, CurrentCFGName) end
end

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
    else
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
    end

    if AIMBOT_ENABLED then
        local closest, targetPart, shortest = nil, nil, math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    for _, partName in ipairs(AIMBOT_HITBOXES) do
                        local part = player.Character:FindFirstChild(partName)
                        if part then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                                if (not AIMBOT_USE_FOV or dist <= AIMBOT_FOV) and dist < shortest then
                                    closest, targetPart, shortest = player, part, dist
                                end
                            end
                        end
                    end
                end
            end
        end
        if closest and targetPart then
            local targetPos = targetPart.Position
            if AIMBOT_MODE == "Mouse" then
                local mousePos = UserInputService:GetMouseLocation()
                local targetScreen = Camera:WorldToViewportPoint(targetPos)
                local move = (Vector2.new(targetScreen.X, targetScreen.Y) - mousePos) / AIMBOT_SMOOTH
                mousemoverel(move.X, move.Y)
            elseif AIMBOT_MODE == "Camera" then
                local direction = (targetPos - Camera.CFrame.Position).Unit
                local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 1/AIMBOT_SMOOTH)
            end
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == AIMBOT_KEY then
        AIMBOT_ENABLED = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gpe)
    if not gpe and input.UserInputType == AIMBOT_KEY then
        AIMBOT_ENABLED = false
    end
end)

UIRefs = {}

local Window = OrionLib:MakeWindow({Name = "XayScript Universal", HidePremium = true, SaveConfig = false, IntroEnabled = true})

local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
MainTab:AddParagraph("⚠️ Рекомендация / Recommendation",
"РУС: понижайте графику и дистанцию ESP. Большое скопление игроков с функциями текста (например дистанция или роль) вызывает лаги.\n\nENG: Lower graphics and ESP distance. Many players with text features (like distance or role) cause heavy lag.")
MainTab:AddParagraph("AimBot / АимБот",
"На данный момент Аимбот не робит.\n\nENG: At the moment, the aimbot is not working.")

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

local AimbotTab = Window:MakeTab({Name = "Aimbot", Icon = "rbxassetid://4483345998", PremiumOnly = false})
AimbotTab:AddToggle({Name = "Включить Aimbot", Default = AIMBOT_ENABLED, Callback = function(v) AIMBOT_ENABLED = v end})
AimbotTab:AddSlider({Name = "Smooth", Min = 1, Max = 20, Default = AIMBOT_SMOOTH, Increment = 1, Callback = function(v) AIMBOT_SMOOTH = v end})
AimbotTab:AddSlider({Name = "FOV", Min = 50, Max = 1000, Default = AIMBOT_FOV, Increment = 10, Callback = function(v) AIMBOT_FOV = v end})
AimbotTab:AddToggle({Name = "Использовать FOV", Default = AIMBOT_USE_FOV, Callback = function(v) AIMBOT_USE_FOV = v end})
AimbotTab:AddDropdown({Name = "Режим", Default = AIMBOT_MODE, Options = {"Mouse", "Camera"}, Callback = function(v) AIMBOT_MODE = v end})
AimbotTab:AddTextbox({Name = "Hitboxes через ,", Default = table.concat(AIMBOT_HITBOXES, ","), TextDisappear = false, Callback = function(v)
    AIMBOT_HITBOXES = {}
    for hit in string.gmatch(v, "[^,%s]+") do table.insert(AIMBOT_HITBOXES, hit) end
end})

local Configs = Window:MakeTab({Name = "Configs", Icon = "rbxassetid://4483345998", PremiumOnly = false})
Configs:AddTextbox({Name = "Config name", Default = "default", TextDisappear = false, Callback = function(value) CurrentCFGName = value end})
local DropdownCFG = Configs:AddDropdown({Name = "Select config", Default = "default", Options = ConfigList, Callback = function(value) loadCFG(value) end})

Configs:AddButton({Name = "💾 Save", Callback = function() saveCFG(CurrentCFGName) refreshCFGs(DropdownCFG) end})
Configs:AddButton({Name = "🔄 Refresh", Callback = function() refreshCFGs(DropdownCFG) end})

local About = Window:MakeTab({Name = "About", Icon = "rbxassetid://4483345998", PremiumOnly = false})
About:AddLabel("Version 0.9 | Optimized with CFG")
About:AddLabel("Developer: XayoriNovedov")
About:AddLabel("t.me/XayNovTeam")

refreshCFGs(DropdownCFG)
OrionLib:Init()
