local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/ArowixExploits/RayfieldUILibrary/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "Debug Menu",
    LoadingTitle = "My Game",
    LoadingSubtitle = "Debug Mode",
    ConfigurationSaving = {Enabled = true, FolderName = nil, FileName = "DebugConfig"}
})

Window:CreateToggle({Name="ESP Box", Flag="ESPBox", CurrentValue=true})
Window:CreateToggle({Name="ESP Health", Flag="ESPHealth", CurrentValue=true})
Window:CreateToggle({Name="ESP Distance", Flag="ESPDistance", CurrentValue=true})
Window:CreateToggle({Name="ESP Skeleton", Flag="ESPSkeleton", CurrentValue=true})

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

return Window
