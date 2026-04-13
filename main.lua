local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "TC2 Project - Educational Only",
    LoadingTitle = "TC2 Script",
    LoadingSubtitle = "by AI Generator",
    ConfigurationSaving = { Enabled = false }
})

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Settings = {
    Aimbot = false,
    SilentAim = false,
    WallCheck = false,
    TeamCheck = true,
    Prediction = false,
    ESP = false,
    InfCloak = false,
    InfCharge = false,
    PredictionVelocity = 150 -- Average projectile speed
}

-- Functions
local function GetClosestPlayer()
    local Target = nil
    local Dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
            
            if Settings.WallCheck then
                local Ray = Ray.new(Camera.CFrame.Position, (v.Character.Head.Position - Camera.CFrame.Position).Unit * 500)
                local Hit = workspace:FindPartOnRayWithIgnoreList(Ray, {LocalPlayer.Character, v.Character})
                if Hit then continue end
            end

            local ScreenPoint = Camera:WorldToScreenPoint(v.Character.Head.Position)
            local VectorDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
            
            if VectorDist < Dist then
                Target = v
                Dist = VectorDist
            end
        end
    end
    return Target
end

-- Tabs
local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local MiscTab = Window:CreateTab("Misc")

-- Combat Features
CombatTab:CreateToggle({
    Name = "Plain Aimbot (Hard Lock)",
    CurrentValue = false,
    Callback = function(Value) Settings.Aimbot = Value end
})

CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(Value) Settings.SilentAim = Value end
})

CombatTab:CreateToggle({
    Name = "Projectile Prediction",
    CurrentValue = false,
    Callback = function(Value) Settings.Prediction = Value end
})

CombatTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Callback = function(Value) Settings.WallCheck = Value end
})

-- Visuals Features (ESP)
VisualsTab:CreateToggle({
    Name = "Team ESP",
    CurrentValue = false,
    Callback = function(Value)
        Settings.ESP = Value
        while Settings.ESP do
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character then
                    local Highlight = v.Character:FindFirstChild("Highlight") or Instance.new("Highlight", v.Character)
                    Highlight.FillTransparency = 0.5
                    Highlight.OutlineTransparency = 0
                    Highlight.FillColor = (v.Team.Name == "GRN" or v.Team.Name == "Green") and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                end
            end
            task.wait(1)
        end
        if not Value then
            for _, v in pairs(Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("Highlight") then v.Character.Highlight:Destroy() end
            end
        end
    end
})

-- Misc Features
MiscTab:CreateToggle({
    Name = "Infinite Cloak (Agent)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.InfCloak = Value
        RunService.RenderStepped:Connect(function()
            if Settings.InfCloak and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("status") then
                local cloak = LocalPlayer.Character.status:FindFirstChild("Cloak")
                if cloak then cloak.Value = 100 end
            end
        end)
    end
})

MiscTab:CreateToggle({
    Name = "Infinite Charge (Annihilator)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.InfCharge = Value
        RunService.RenderStepped:Connect(function()
            if Settings.InfCharge and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("status") then
                local charge = LocalPlayer.Character.status:FindFirstChild("Charge")
                if charge then charge.Value = 100 end
            end
        end)
    end
})

MiscTab:CreateButton({
    Name = "TeleStab (Closest Enemy)",
    Callback = function()
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
})

-- Main Logic Loop
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot then
        local Target = GetClosestPlayer()
        if Target and Target.Character then
            local Pos = Target.Character.Head.Position
            if Settings.Prediction then
                Pos = Pos + (Target.Character.Head.Velocity * (Pos - Camera.CFrame.Position).Magnitude / Settings.PredictionVelocity)
            end
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Pos)
        end
    end
end)

-- Silent Aim Hook
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    if Settings.SilentAim and Method == "FindPartOnRayWithIgnoreList" then
        local Target = GetClosestPlayer()
        if Target and Target.Character then
            Args[1] = Ray.new(Camera.CFrame.Position, (Target.Character.Head.Position - Camera.CFrame.Position).Unit * 1000)
            return OldNamecall(Self, unpack(Args))
        end
    end
    return OldNamecall(Self, ...)
end)
