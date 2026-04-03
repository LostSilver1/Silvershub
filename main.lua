local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Silvers Hub | Elite TC2",
   LoadingTitle = "Silvers Hub",
   LoadingSubtitle = "Projectile & Stealth Tech",
   ConfigurationSaving = { Enabled = false }
})

-- // Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().SilentAim = false
getgenv().ProjectilePrediction = false
getgenv().AutoBackstab = false
getgenv().InfAmmo = false
getgenv().Reach = false
getgenv().ReachSize = 12

-- // Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- // Combat Features
CombatTab:CreateToggle({
   Name = "Silent Aim (Hit Sky = Kill)",
   CurrentValue = false,
   Callback = function(Value) getgenv().SilentAim = Value end,
})

CombatTab:CreateToggle({
   Name = "Projectile Prediction (Rockets)",
   CurrentValue = false,
   Callback = function(Value) getgenv().ProjectilePrediction = Value end,
})

CombatTab:CreateToggle({
   Name = "Force Auto-Backstab",
   CurrentValue = false,
   Callback = function(Value) getgenv().AutoBackstab = Value end,
})

CombatTab:CreateToggle({
   Name = "2x Ammo / Inf Clip",
   CurrentValue = false,
   Callback = function(Value) getgenv().InfAmmo = Value end,
})

-- // Logic: Get Target
local function GetTarget()
    local Closest = nil
    local Dist = 1000
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Team ~= LocalPlayer.Team and v.Character.Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local ScreenDist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if ScreenDist < Dist then
                    Closest = v
                    Dist = ScreenDist
                end
            end
        end
    end
    return Closest
end

-- // Logic: Projectile Prediction Math
local function PredictPos(target)
    local Velocity = target.Character.HumanoidRootPart.Velocity
    local Distance = (target.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local Time = Distance / 150 -- 150 is avg rocket speed, adjust if needed
    return target.Character.HumanoidRootPart.Position + (Velocity * Time)
end

-- // Logic: Silent Aim Hook
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if getgenv().SilentAim and Method == "FindPartOnRayWithIgnoreList" then
        local Target = GetTarget()
        if Target then
            local AimPos = getgenv().ProjectilePrediction and PredictPos(Target) or Target.Character.Head.Position
            Args[1] = Ray.new(Camera.CFrame.Position, (AimPos - Camera.CFrame.Position).Unit * 1000)
            return OldNamecall(self, unpack(Args))
        end
    end
    return OldNamecall(self, ...)
end)

-- // Main Combat Loop
RunService.Heartbeat:Connect(function()
    local Target = GetTarget()
    if not Target then return end
    
    -- Auto Backstab (Forced position)
    if getgenv().AutoBackstab then
        local Dist = (Target.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        -- Only triggers if holding a Melee weapon and close
        if Tool and Dist < 15 and (Tool.Name:lower():find("knife") or Tool.Name:lower():find("sword")) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, Target.Character.HumanoidRootPart.Position)
        end
    end
    
    -- Inf Ammo (TC2 Specific)
    if getgenv().InfAmmo then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("Clip")
            if ammo then ammo.Value = 200 end -- Set to 200 for "2x" feel/stability
        end
    end
end)
