-- Подключаем меню через loadstring
local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/ТВОЙ_РЕПО/rayfield_menu.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPStore = {}

-- Вспомогательная функция для создания Billboard
local function createTextLabel(parent,text,yOffset,color)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = parent
    billboard.Size = UDim2.new(0,200,0,40)
    billboard.StudsOffset = Vector3.new(0,yOffset,0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.Parent = CoreGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,20)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextSize = 14
    label.Text = text
    label.Font = Enum.Font.RobotoMono
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.Parent = billboard

    return billboard
end

-- Skeleton для R15
local SkeletonConnections = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},
    {"LeftLowerArm","LeftHand"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},{"RightLowerLeg","RightFoot"}
}

-- Создание ESP для персонажа
local function setupCharacterESP(character, player)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    local espFolder = Instance.new("Folder")
    espFolder.Name = player.Name .. "_ESP"
    espFolder.Parent = CoreGui

    local box, nameTag, healthTag, distanceTag
    local skeletonParts = {}

    -- Box
    if Window.Flags.ESPBox.Value then
        box = Instance.new("BoxHandleAdornment")
        box.Adornee = hrp
        box.AlwaysOnTop = true
        box.Size = Vector3.new(4,5,2)
        box.Transparency = 0.6
        box.Color3 = Color3.fromRGB(255,0,0)
        box.ZIndex = 1
        box.Parent = espFolder
    end

    -- Name
    nameTag = createTextLabel(hrp, player.Name, 3.5, Color3.fromRGB(255,255,255))
    nameTag.Parent = espFolder

    -- Health
    if Window.Flags.ESPHealth.Value then
        healthTag = createTextLabel(hrp, "HP: "..math.floor(humanoid.Health), 3.0, Color3.fromRGB(255,100,100))
        healthTag.Parent = espFolder
    end

    -- Distance
    if Window.Flags.ESPDistance.Value then
        distanceTag = createTextLabel(hrp, "0m", 2.5, Color3.fromRGB(200,200,255))
        distanceTag.Parent = espFolder
    end

    -- Skeleton
    if Window.Flags.ESPSkeleton.Value then
        for _, connection in ipairs(SkeletonConnections) do
            local part1 = character:FindFirstChild(connection[1])
            local part2 = character:FindFirstChild(connection[2])
            if part1 and part2 then
                local att0 = Instance.new("Attachment", part1)
                local att1 = Instance.new("Attachment", part2)
                local beam = Instance.new("Beam")
                beam.Attachment0 = att0
                beam.Attachment1 = att1
                beam.Color = ColorSequence.new(Color3.fromRGB(0,255,0))
                beam.Width0 = 0.1
                beam.Width1 = 0.1
                beam.FaceCamera = true
                beam.Parent = espFolder
                table.insert(skeletonParts, {Beam=beam,Attachment0=att0,Attachment1=att1})
            end
        end
    end

    return {Folder=espFolder, Box=box, NameTag=nameTag, HealthTag=healthTag, DistanceTag=distanceTag, Skeleton=skeletonParts, Character=character, Humanoid=humanoid, Player=player}
end

-- Трекинг игроков
local function trackPlayer(player)
    if player==LocalPlayer then return end
    local function characterAdded(character)
        if ESPStore[player] then ESPStore[player].Folder:Destroy() ESPStore[player]=nil end
        task.wait(0.5)
        ESPStore[player] = setupCharacterESP(character, player)
    end
    player.CharacterAdded:Connect(characterAdded)
    if player.Character then characterAdded(player.Character) end
end

-- RenderStepped обновление
RunService.RenderStepped:Connect(function()
    for _, esp in pairs(ESPStore) do
        local char = esp.Character
        local humanoid = esp.Humanoid
        if char and humanoid then
            -- Health
            if esp.HealthTag then
                local label = esp.HealthTag:FindFirstChildWhichIsA("TextLabel")
                if label then label.Text = "HP: "..math.floor(humanoid.Health) end
                esp.HealthTag.Enabled = Window.Flags.ESPHealth.Value
            end
            -- Distance
            if esp.DistanceTag then
                local label = esp.DistanceTag:FindFirstChildWhichIsA("TextLabel")
                if label then
                    local dist = (char.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                    label.Text = string.format("%dm",math.floor(dist))
                end
                esp.DistanceTag.Enabled = Window.Flags.ESPDistance.Value
            end
            -- Box
            if esp.Box then
                esp.Box.Visible = Window.Flags.ESPBox.Value
            end
            -- Skeleton
            for _, s in pairs(esp.Skeleton) do
                if s.Beam then s.Beam.Enabled = Window.Flags.ESPSkeleton.Value end
            end
        end
    end
end)

-- Инициализация игроков
for _, p in pairs(Players:GetPlayers()) do
    if p~=LocalPlayer then trackPlayer(p) end
end

Players.PlayerAdded:Connect(function(p) if p~=LocalPlayer then trackPlayer(p) end end)
Players.PlayerRemoving:Connect(function(p) if ESPStore[p] then ESPStore[p].Folder:Destroy() ESPStore[p]=nil end end)
