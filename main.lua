local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Silvers Hub | Mobile Edition",
   LoadingTitle = "Silvers Hub",
   LoadingSubtitle = "Universal Mobile Script",
   ConfigurationSaving = { Enabled = false }
})

-- // Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().Aimbot = false
getgenv().ESP = false
getgenv().TeamCheck = true
getgenv().AimPart = "HumanoidRootPart"
getgenv().Smoothing = 0.05
getgenv().FOVRadius = 150
getgenv().ShowFOV = false

-- // FOV Circle Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Visible = false

-- // Tabs
local MainTab = Window:CreateTab("Main", 4483362458) 
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- // Main Features
MainTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value) getgenv().Aimbot = Value end,
})

MainTab:CreateSlider({
   Name = "Aimbot Smoothing",
   Range = {0.01, 0.5},
   Increment = 0.01,
   CurrentValue = 0.05,
   Callback = function(Value) getgenv().Smoothing = Value end,
})

MainTab:CreateDropdown({
   Name = "Aim Part",
   Options = {"HumanoidRootPart", "Head"},
   CurrentOption = {"HumanoidRootPart"},
   Callback = function(Option) getgenv().AimPart = Option[1] end,
})

-- // Visual Features
VisualsTab:CreateToggle({
   Name = "Enable Box ESP",
   CurrentValue = false,
   Callback = function(Value) getgenv().ESP = Value end,
})

VisualsTab:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = false,
   Callback = function(Value) 
       getgenv().ShowFOV = Value 
       FOVCircle.Visible = Value
   end,
})

VisualsTab:CreateSlider({
   Name = "FOV Radius",
   Range = {50, 500},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(Value) getgenv().FOVRadius = Value end,
})

-- // Logic Functions
local function GetClosest()
    local Target = nil
    local Dist = getgenv().FOVRadius
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(getgenv().AimPart) then
            if getgenv().TeamCheck and v.Team == LocalPlayer.Team then continue end
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character[getgenv().AimPart].Position)
            local ScreenDist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if OnScreen and ScreenDist < Dist then
                Target = v
                Dist = ScreenDist
            end
        end
    end
    return Target
end

-- // ESP Simple Highlight
local function ApplyESP(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "SilversESP"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    local function update()
        if getgenv().ESP and player.Character and player ~= LocalPlayer then
            if getgenv().TeamCheck and player.Team == LocalPlayer.Team then
                highlight.Parent = nil
            else
                highlight.Parent = player.Character
            end
        else
            highlight.Parent = nil
        end
    end
    RunService.RenderStepped:Connect(update)
end

for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)

-- // Main Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = getgenv().FOVRadius
    
    if getgenv().Aimbot then
        local Target = GetClosest()
        if Target then
            local TargetPos = Target.Character[getgenv().AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPos), getgenv().Smoothing)
        end
    end
end)
