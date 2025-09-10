-- esp.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ESP = {
    Enabled = false,
    Objects = {}
}

function ESP:CreateESP(character, player)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Метка с именем
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = self.Enabled
    billboard.Parent = CoreGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextSize = 14
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.RobotoMono
    nameLabel.Parent = billboard

    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0, 20)
    healthLabel.Position = UDim2.new(0, 0, 0, 20)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.new(1, 0.5, 0.5)
    nameLabel.TextSize = 12
    healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
    healthLabel.Parent = billboard

    -- Бокс
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.Size = Vector3.new(4, 5, 2)
    box.Transparency = 0.6
    box.Color3 = Color3.new(1, 0, 0)
    box.Visible = self.Enabled
    box.Parent = CoreGui

    self.Objects[player] = {Billboard = billboard, Box = box, Character = character}
end

function ESP:RemoveESP(player)
    if self.Objects[player] then
        self.Objects[player].Billboard:Destroy()
        self.Objects[player].Box:Destroy()
        self.Objects[player] = nil
    end
end

function ESP:ToggleGlobalESP(state)
    self.Enabled = state
    self:RefreshAllESP()
end

function ESP:RefreshAllESP()
    for player in pairs(self.Objects) do
        self:RemoveESP(player)
    end
    
    if self.Enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                self:CreateESP(player.Character, player)
            end
        end
    end
end

-- Инициализация
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if ESP.Enabled then
            task.wait(1)
            ESP:CreateESP(character, player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    ESP:RemoveESP(player)
end)

-- Обновление здоровья
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then return end
    
    for player, data in pairs(ESP.Objects) do
        if data.Character and data.Character.Parent then
            local humanoid = data.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local healthLabel = data.Billboard:FindFirstChildWhichIsA("TextLabel", true)
                if healthLabel then
                    healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
                end
            end
        end
    end
end)

return ESP
