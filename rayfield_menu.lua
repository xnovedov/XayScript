debugX = true

local Rayfield = loadstring(game:HttpGet('https://github.com/xnovedov/XayScript/blob/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Debug Menu",
   Icon = 0,
   LoadingTitle = "Debug Menu",
   LoadingSubtitle = "ESP & Debug",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "DebugConfig" },
   Discord = { Enabled = false, Invite = "", RememberJoins = true },
   KeySystem = false
})

local ESPTab = Window:CreateTab("ESP", 4483362458)
local ESPSection = ESPTab:CreateSection("Visuals")

ESPSection:CreateToggle({Name="ESP Box", Flag="ESPBox", CurrentValue=true})
ESPSection:CreateToggle({Name="ESP Health", Flag="ESPHealth", CurrentValue=true})
ESPSection:CreateToggle({Name="ESP Distance", Flag="ESPDistance", CurrentValue=true})
ESPSection:CreateToggle({Name="ESP Skeleton", Flag="ESPSkeleton", CurrentValue=true})

Window:CreateKeybind({
    Name = "Toggle Menu",
    CurrentKey = Enum.KeyCode.RightShift,
    HoldToInteract = false,
    Flag = "ToggleMenu",
    Callback = function()
        local MainFrame = Window.MainFrame
        if MainFrame then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
})

Rayfield:LoadConfiguration()

return Window
