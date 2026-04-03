local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Silvers Hub | Elite Edition",
   LoadingTitle = "Silvers Hub",
   LoadingSubtitle = "Universal & TC2 Combat",
   ConfigurationSaving = { Enabled = false }
})

-- // Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().AimbotMode = "Plain" -- Plain or Silent
getgenv().AimbotEnabled = false
getgenv().ESPEnabled = false
getgenv().ReachEnabled = false
getgenv().ReachSize = 10
getgenv().AutoBackstab = false

-- // Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- // Combat Features
CombatTab:CreateDropdown({
   Name = "Aimbot Type",
   Options = {"Plain", "Silent"},
   CurrentOption = {"Plain"},
   Callback = function(Option) getgenv().AimbotMode = Option[1] end,
})

CombatTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value) getgenv().AimbotEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Auto Backstab (Agent)",
   CurrentValue = false,
   Callback = function(Value) getgenv().AutoBackstab = Value end,
})

CombatTab:CreateToggle({
   Name = "Melee Reach",
   CurrentValue = false,
   Callback = function(Value) getgenv().ReachEnabled = Value end,
})

-- // Visuals Features
VisualsTab:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = false,
   Callback = function(Value) getgenv().ESPEnabled = Value end,
})

-- // Logic: Get Target
local function GetClosest()
    local Target = nil
    local Dist = 200 -- FOV Range
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Team ~= LocalPlayer.Team and v.Character.Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local ScreenDist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if OnScreen and ScreenDist < Dist then
                    Target = v
                    Dist = ScreenDist
                end
            end
        end
    end
    return Target
end

-- // Logic: ESP & Reach Loop
RunService.Heartbeat:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            -- ESP Logic
            local highlight = v.Character:FindFirstChild("SilversESP")
            if getgenv().ESPEnabled and v.Team ~= LocalPlayer.Team then
                if not highlight then
                    highlight = Instance.new("Highlight", v.Character)
                    highlight.Name = "SilversESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                end
            elseif highlight then
                highlight:Destroy()
            end
            
            -- Reach Logic (TC2 Fix)
            if getgenv().ReachEnabled and v.Team ~= LocalPlayer.Team then
                v.Character.HumanoidRootPart.Size = Vector3.new(getgenv().ReachSize, getgenv().ReachSize, getgenv().ReachSize)
                v.Character.HumanoidRootPart.CanCollide = false
            else
                v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            end
        end
    end
end)

-- // Logic: Aimbot & Auto-Backstab
RunService.RenderStepped:Connect(function()
    local Target = GetClosest()
    if not Target then return end

    -- Aimbot Logic
    if getgenv().AimbotEnabled then
        local Smoothness = (getgenv().AimbotMode == "Plain") and 0.15 or 0.04
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Character.HumanoidRootPart.Position), Smoothness)
    end

    -- Auto Backstab Logic
    if getgenv().AutoBackstab and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        local Dist = (Target.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if Dist < 12 then
            -- Moves you to their back smoothly (Not a TP, so it's safer)
            LocalPlayer.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)
