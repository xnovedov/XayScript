local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xnovedov/XayScript/refs/heads/main/source.lua"))()

local ESP_ENABLED = false
local SHOW_BOX = false
local SHOW_HEALTH = false
local GRADIENT_HEALTH = false
local SHOW_DISTANCE = false
local SHOW_TRACERS = false

local BoxColor = Color3.fromRGB(0,255,0)
local TracerColor = Color3.fromRGB(255,255,255)
local DistColor = Color3.fromRGB(255,255,255)
local HealthColor = Color3.fromRGB(0,255,0)
local HealthGradientLow = Color3.fromRGB(255,0,0)
local HealthGradientHigh = Color3.fromRGB(0,255,0)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local espObjects = {}

local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for i,v in pairs(props) do obj[i] = v end
    return obj
end

local function lerpColor(c1, c2, t)
    return Color3.new(
        c1.R + (c2.R - c1.R) * t,
        c1.G + (c2.G - c1.G) * t,
        c1.B + (c2.B - c1.B) * t
    )
end

local function addESP(player)
    if player == LocalPlayer then return end
    local objects = {
        Box = createDrawing("Square",{Thickness=1,Color=BoxColor,Filled=false,Visible=false}),
        Health = createDrawing("Line",{Thickness=2,Color=HealthColor,Visible=false}),
        Distance = createDrawing("Text",{Size=16,Center=true,Outline=true,Color=DistColor,Visible=false}),
        Tracer = createDrawing("Line",{Thickness=1,Color=TracerColor,Visible=false})
    }
    espObjects[player] = objects
end

local function removeESP(player)
    if espObjects[player] then
        for _,obj in pairs(espObjects[player]) do obj:Remove() end
        espObjects[player] = nil
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not ESP_ENABLED then
        for _,objects in pairs(espObjects) do
            for _,obj in pairs(objects) do obj.Visible=false end
        end
        return
    end
    for player,objects in pairs(espObjects) do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if hrp and humanoid and humanoid.Health>0 then
            local pos,vis = Camera:WorldToViewportPoint(hrp.Position)
            if vis then
                local scale = 2000/(pos.Z)
                local width = 2*scale
                local height = 3*scale
                local x = pos.X - width/2
                local y = pos.Y - height/2

                objects.Box.Visible = SHOW_BOX
                if SHOW_BOX then
                    objects.Box.Size = Vector2.new(width,height)
                    objects.Box.Position = Vector2.new(x,y)
                    objects.Box.Color = BoxColor
                end

                objects.Health.Visible = SHOW_HEALTH
                if SHOW_HEALTH then
                    local ratio = humanoid.Health/humanoid.MaxHealth
                    objects.Health.From = Vector2.new(x-5,y+height)
                    objects.Health.To = Vector2.new(x-5,y+height*(1-ratio))
                    if GRADIENT_HEALTH then
                        objects.Health.Color = lerpColor(HealthGradientLow,HealthGradientHigh,ratio)
                    else
                        objects.Health.Color = HealthColor
                    end
                end

                objects.Distance.Visible = SHOW_DISTANCE
                if SHOW_DISTANCE then
                    local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0
                    objects.Distance.Position = Vector2.new(pos.X,y+height+15)
                    objects.Distance.Text = string.format("[%dm]",math.floor(dist))
                    objects.Distance.Color = DistColor
                end

                objects.Tracer.Visible = SHOW_TRACERS
                if SHOW_TRACERS then
                    objects.Tracer.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                    objects.Tracer.To = Vector2.new(pos.X,pos.Y)
                    objects.Tracer.Color = TracerColor
                end
            else
                for _,obj in pairs(objects) do obj.Visible=false end
            end
        else
            for _,obj in pairs(objects) do obj.Visible=false end
        end
    end
end)

for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

local Window = OrionLib:MakeWindow({Name="ESP Menu",HidePremium=false,SaveConfig=false,IntroEnabled=false})
local Tab = Window:MakeTab({Name="ESP",Icon="rbxassetid://4483345998",PremiumOnly=false})

local espToggle = Tab:AddToggle({Name="ESP",Default=ESP_ENABLED,Callback=function(v)
    ESP_ENABLED=v
    boxToggle.Visible=v
    hpToggle.Visible=v
    distToggle.Visible=v
    tracerToggle.Visible=v
end})

boxToggle = Tab:AddToggle({Name="Боксы",Default=SHOW_BOX,Callback=function(v)
    SHOW_BOX=v
    boxColorPicker.Visible=v
end})
boxToggle.Visible=false

boxColorPicker = Tab:AddColorpicker({Name="Цвет боксов",Default=BoxColor,Callback=function(c) BoxColor=c end})
boxColorPicker.Visible=false

hpToggle = Tab:AddToggle({Name="HP бар",Default=SHOW_HEALTH,Callback=function(v)
    SHOW_HEALTH=v
    hpGradientToggle.Visible=v
    hpColorPicker.Visible=v and not GRADIENT_HEALTH
    hpLowColor.Visible=v and GRADIENT_HEALTH
    hpHighColor.Visible=v and GRADIENT_HEALTH
end})
hpToggle.Visible=false

hpGradientToggle = Tab:AddToggle({Name="Градиент HP",Default=GRADIENT_HEALTH,Callback=function(v)
    GRADIENT_HEALTH=v
    hpColorPicker.Visible=not v
    hpLowColor.Visible=v
    hpHighColor.Visible=v
end})
hpGradientToggle.Visible=false

hpColorPicker = Tab:AddColorpicker({Name="Цвет HP",Default=HealthColor,Callback=function(c) HealthColor=c end})
hpColorPicker.Visible=false

hpLowColor = Tab:AddColorpicker({Name="HP Min",Default=HealthGradientLow,Callback=function(c) HealthGradientLow=c end})
hpLowColor.Visible=false

hpHighColor = Tab:AddColorpicker({Name="HP Max",Default=HealthGradientHigh,Callback=function(c) HealthGradientHigh=c end})
hpHighColor.Visible=false

distToggle = Tab:AddToggle({Name="Дистанция",Default=SHOW_DISTANCE,Callback=function(v)
    SHOW_DISTANCE=v
    distColorPicker.Visible=v
end})
distToggle.Visible=false

distColorPicker = Tab:AddColorpicker({Name="Цвет дистанции",Default=DistColor,Callback=function(c) DistColor=c end})
distColorPicker.Visible=false

tracerToggle = Tab:AddToggle({Name="Трейсеры",Default=SHOW_TRACERS,Callback=function(v)
    SHOW_TRACERS=v
    tracerColorPicker.Visible=v
end})
tracerToggle.Visible=false

tracerColorPicker = Tab:AddColorpicker({Name="Цвет трейсеров",Default=TracerColor,Callback=function(c) TracerColor=c end})
tracerColorPicker.Visible=false

OrionLib:Init()
