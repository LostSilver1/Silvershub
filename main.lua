local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Silvers Hub | God Mode",
   LoadingTitle = "Silvers Hub",
   LoadingSubtitle = "Ultimate Mobile Edition",
   ConfigurationSaving = { Enabled = false }
})

-- // Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

getgenv().AimbotEnabled = false
getgenv().SilentAim = false
getgenv().ESPEnabled = false
getgenv().ReachEnabled = false
getgenv().InfAmmo = false
getgenv().Bhop = false
getgenv().AutoBackstab = false

-- // Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- // Combat Features
CombatTab:CreateToggle({
   Name = "Enable Aimbot (Lock-On)",
   CurrentValue = false,
   Callback = function(Value) getgenv().AimbotEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Silent Aim (Shoot Sky = Hit)",
   CurrentValue = false,
   Callback = function(Value) getgenv().SilentAim = Value end,
})

CombatTab:CreateToggle({
   Name = "Auto Backstab",
   CurrentValue = false,
   Callback = function(Value) getgenv().AutoBackstab = Value end,
})

CombatTab:CreateToggle({
   Name = "Melee Reach",
   CurrentValue = false,
   Callback = function(Value) getgenv().ReachEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Infinite Ammo",
   CurrentValue = false,
   Callback = function(Value) getgenv().InfAmmo = Value end,
})

-- // Movement Features
MovementTab:CreateToggle({
   Name = "B-Hop (Auto-Jump)",
   CurrentValue = false,
   Callback = function(Value) getgenv().Bhop = Value end,
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
    local Dist = 500
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Team ~= LocalPlayer.Team and v.Character.Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local ScreenDist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if ScreenDist < Dist then
                    Target = v
                    Dist = ScreenDist
                end
            end
        end
    end
    return Target
end

-- // Logic: Silent Aim (The "Shoot Anywhere" Hack)
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if getgenv().SilentAim and Method == "FindPartOnRayWithIgnoreList" then
        local Target = GetClosest()
        if Target then
            -- Redirects the ray to the target's head
            Args[1] = Ray.new(Camera.CFrame.Position, (Target.Character.Head.Position - Camera.CFrame.Position).Unit * 1000)
            return OldNamecall(Self, unpack(Args))
        end
    end
    return OldNamecall(Self, ...)
end)

-- // Main Loops
RunService.RenderStepped:Connect(function()
    local Target = GetClosest()
    
    -- Aimbot (Lock-on)
    if getgenv().AimbotEnabled and Target then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Character.HumanoidRootPart.Position), 0.1)
    end
    
    -- B-Hop
    if getgenv().Bhop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    -- Auto Backstab (Agent)
    if getgenv().AutoBackstab and Target then
        local Dist = (Target.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if Dist < 15 and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
            -- Moves you instantly behind them
            LocalPlayer.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
    
    -- Inf Ammo Loop
    if getgenv().InfAmmo then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and (tool:FindFirstChild("Ammo") or tool:FindFirstChild("Clip")) then
            if tool:FindFirstChild("Ammo") then tool.Ammo.Value = 999 end
            if tool:FindFirstChild("Clip") then tool.Clip.Value = 999 end
        end
    end
end)
