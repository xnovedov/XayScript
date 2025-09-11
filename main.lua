-- OrionLib
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/darkkcontrol/Roblox-Orion-UI-Libary-OP-UI-LIBARY-/main/source"))()
end)

if not success or type(OrionLib) ~= "table" then
    warn("Не удалось загрузить OrionLib")
    return
end

-- Настройки ESP
local ESPSettings = {
    Enabled = false,
    ShowBox = false,
    ShowHealth = false,
    GradientHealth = false,
    ShowDistance = false,
    ShowTracers = false,

    Colors = {
        Box = Color3.fromRGB(255,255,255),
        Tracer = Color3.fromRGB(255,255,255),
        Distance = Color3.fromRGB(255,255,255),
        HP = Color3.fromRGB(0,255,0),
        HPGradStart = Color3.fromRGB(0,255,0),
        HPGradEnd = Color3.fromRGB(255,0,0),
    },
    MaxDistance = 500
}

-- Хелпер: интерполяция градиента HP
local function LerpColor(c1,c2,t)
    return Color3.new(
        c1.R + (c2.R-c1.R)*t,
        c1.G + (c2.G-c1.G)*t,
        c1.B + (c2.B-c1.B)*t
    )
end

-- UI
local Window = OrionLib:MakeWindow({Name="ESP Menu",HidePremium=false,SaveConfig=false,ConfigFolder="ESPMenu"})
local Tab = Window:MakeTab({Name="ESP",Icon="rbxassetid://4483345998",PremiumOnly=false})

Tab:AddToggle({Name="ESP",Default=false,Callback=function(v) ESPSettings.Enabled=v end})
Tab:AddToggle({Name="Боксы",Default=false,Callback=function(v) ESPSettings.ShowBox=ESPSettings.Enabled and v or false end})
Tab:AddColorpicker({Name="Цвет боксов",Default=ESPSettings.Colors.Box,Callback=function(c) if ESPSettings.Enabled and ESPSettings.ShowBox then ESPSettings.Colors.Box=c end end})
Tab:AddToggle({Name="HP бар",Default=false,Callback=function(v) ESPSettings.ShowHealth=ESPSettings.Enabled and v or false end})
Tab:AddToggle({Name="Градиент HP",Default=false,Callback=function(v) ESPSettings.GradientHealth=(ESPSettings.Enabled and ESPSettings.ShowHealth) and v or false end})
Tab:AddColorpicker({Name="HP Цвет",Default=ESPSettings.Colors.HP,Callback=function(c) if ESPSettings.Enabled and ESPSettings.ShowHealth and not ESPSettings.GradientHealth then ESPSettings.Colors.HP=c end end})
Tab:AddColorpicker({Name="HP Gradient Start",Default=ESPSettings.Colors.HPGradStart,Callback=function(c) if ESPSettings.Enabled and ESPSettings.GradientHealth then ESPSettings.Colors.HPGradStart=c end end})
Tab:AddColorpicker({Name="HP Gradient End",Default=ESPSettings.Colors.HPGradEnd,Callback=function(c) if ESPSettings.Enabled and ESPSettings.GradientHealth then ESPSettings.Colors.HPGradEnd=c end end})
Tab:AddToggle({Name="Дистанция",Default=false,Callback=function(v) ESPSettings.ShowDistance=ESPSettings.Enabled and v or false end})
Tab:AddColorpicker({Name="Цвет дистанции",Default=ESPSettings.Colors.Distance,Callback=function(c) if ESPSettings.Enabled and ESPSettings.ShowDistance then ESPSettings.Colors.Distance=c end end})
Tab:AddToggle({Name="Трейсеры",Default=false,Callback=function(v) ESPSettings.ShowTracers=ESPSettings.Enabled and v or false end})
Tab:AddColorpicker({Name="Цвет трейсеров",Default=ESPSettings.Colors.Tracer,Callback=function(c) if ESPSettings.Enabled and ESPSettings.ShowTracers then ESPSettings.Colors.Tracer=c end end})

-- ESP рендер
local camera = workspace.CurrentCamera
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")

-- Таблица объектов
local drawings = {}

local function createESP(player)
    if player == localPlayer then return end
    if drawings[player] then return end

    drawings[player] = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        HPBar = Drawing.new("Square"),
        HPBG = Drawing.new("Square")
    }

    for _,obj in pairs(drawings[player]) do
        obj.Visible = false
        obj.ZIndex = 1
    end

    drawings[player].Name.Center = true
    drawings[player].Name.Size = 13
    drawings[player].Name.Outline = true
end

local function removeESP(player)
    if drawings[player] then
        for _,obj in pairs(drawings[player]) do
            obj:Remove()
        end
        drawings[player] = nil
    end
end

players.PlayerAdded:Connect(createESP)
players.PlayerRemoving:Connect(removeESP)
for _,p in pairs(players:GetPlayers()) do createESP(p) end

runService.RenderStepped:Connect(function()
    for player,objs in pairs(drawings) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if ESPSettings.Enabled and hrp and hum and hum.Health>0 then
            local pos,vis = camera:WorldToViewportPoint(hrp.Position)
            local dist = (localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and (hrp.Position - localPlayer.Character.HumanoidRootPart.Position).magnitude) or 0
            if vis and dist <= ESPSettings.MaxDistance then
                local scale = math.clamp(1000/dist,2,5)
                local size = Vector2.new(35*scale,50*scale)
                local topLeft = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)

                -- Box
                objs.Box.Visible = ESPSettings.ShowBox
                if objs.Box.Visible then
                    objs.Box.Position = topLeft
                    objs.Box.Size = size
                    objs.Box.Color = ESPSettings.Colors.Box
                    objs.Box.Thickness = 1
                end

                -- HP
                objs.HPBar.Visible = ESPSettings.ShowHealth
                objs.HPBG.Visible = ESPSettings.ShowHealth
                if ESPSettings.ShowHealth then
                    local hpPercent = hum.Health/hum.MaxHealth
                    local barHeight = size.Y * hpPercent
                    objs.HPBG.Position = Vector2.new(topLeft.X - 6, topLeft.Y)
                    objs.HPBG.Size = Vector2.new(4, size.Y)
                    objs.HPBG.Color = Color3.fromRGB(50,50,50)

                    objs.HPBar.Position = Vector2.new(topLeft.X - 6, topLeft.Y + (size.Y - barHeight))
                    objs.HPBar.Size = Vector2.new(4, barHeight)
                    objs.HPBar.Color = ESPSettings.GradientHealth
                        and LerpColor(ESPSettings.Colors.HPGradEnd, ESPSettings.Colors.HPGradStart, hpPercent)
                        or ESPSettings.Colors.HP
                end

                -- Distance
                objs.Name.Visible = ESPSettings.ShowDistance
                if ESPSettings.ShowDistance then
                    objs.Name.Text = string.format("[%dm]", math.floor(dist))
                    objs.Name.Position = Vector2.new(pos.X, pos.Y + size.Y/2 + 12)
                    objs.Name.Color = ESPSettings.Colors.Distance
                end

                -- Tracers
                objs.Tracer.Visible = ESPSettings.ShowTracers
                if ESPSettings.ShowTracers then
                    objs.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                    objs.Tracer.To = Vector2.new(pos.X, pos.Y)
                    objs.Tracer.Color = ESPSettings.Colors.Tracer
                    objs.Tracer.Thickness = 1
                end

            else
                for _,o in pairs(objs) do o.Visible=false end
            end
        else
            for _,o in pairs(objs) do o.Visible=false end
        end
    end
end)
