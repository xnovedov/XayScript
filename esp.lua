-- esp.lua
-- Подключаем меню
local Window = loadstring(game:HttpGet("https://github.com/xnovedov/XayScript/blob/main/rayfield_menu.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPStore = {}

local SkeletonConnections = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},
    {"LeftLowerArm","LeftHand"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},{"RightLowerLeg","RightFoot"}
}

local function createTextLabel(parent, text, yOffset, color)
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

local function setupCharacterESP(character, player)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    local espFolder = Instance.new("Folder")
    espFolder.Name = player.Name.."_ESP"
    espFolder.Parent = CoreGui

    local box, healthTag, distanceTag, skeletonParts = nil, nil, nil, {}

    if Window.Flags.ESPBox.Value then
        box = Instance.new("BoxHandleAdornment")
        box.Adornee = hrp
        box.Size = Vector3.new(4,5,2)
        box.AlwaysOnTop = true
        box.Transparency = 0.6
        box.Color3 = Color3.fromRGB(255,0,0)
        box.Parent = espFolder
    end

    if Window.Flags.ESPHealth.Value then
        healthTag = createTextLabel(hrp, "HP:"..math.floor(humanoid.Health), 3, Color3.fromRGB(255,100,100))
        healthTag.Parent = espFolder
    end

    if Window.Flags.ESPDistance.Value then
        distanceTag = createTextLabel(hrp, "0m", 2.5, Color3.fromRGB(200,200,255))
        distanceTag.Parent = espFolder
    end

    if Window.Flags.ESPSkeleton.Value then
        for _, conn in pairs(SkeletonConnections) do
            local p1 = character:FindFirstChild(conn[1])
            local p2 = character:FindFirstChild(conn[2])
            if p1 and p2 then
                local att0 = Instance.new("Attachment", p1)
                local att1 = Instance.new("Attachment", p2)
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

    return {Folder=espFolder, Box=box, HealthTag=healthTag, DistanceTag=distanceTag, Skeleton=skeletonParts, Character=character, Humanoid=humanoid}
end

local function trackPlayer(player)
    if player == LocalPlayer then return end
    local function charAdded(character)
        if ESPStore[player] then ESPStore[player].Folder:Destroy() ESPStore[player]=nil end
        task.wait(0.5)
        ESPStore[player] = setupCharacterESP(character, player)
    end
    player.CharacterAdded:Connect(charAdded)
    if player.Character then charAdded(player.Character) end
end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then trackPlayer(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then trackPlayer(p) end end)
Players.PlayerRemoving:Connect(function(p) if ESPStore[p] then ESPStore[p].Folder:Destroy() ESPStore[p]=nil end end)

RunService.RenderStepped:Connect(function()
    for _, esp in pairs(ESPStore) do
        if esp.HealthTag then esp.HealthTag.Enabled = Window.Flags.ESPHealth.Value end
        if esp.DistanceTag then esp.DistanceTag.Enabled = Window.Flags.ESPDistance.Value end
        if esp.Box then esp.Box.Visible = Window.Flags.ESPBox.Value end
        for _, s in pairs(esp.Skeleton) do
            if s.Beam then s.Beam.Enabled = Window.Flags.ESPSkeleton.Value end
        end
    end
end)
