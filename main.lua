-- Educational Script: Silvers Hub Core (No Menu)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration
local Config = {
    EspEnabled = true,
    AimbotEnabled = true,
    TeamCheck = true,
    AimPart = "Head",
    Smoothness = 0.5 -- 0 to 1 scale
}

-- Simple ESP Function
local function CreateESP(Player)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "EducationalESP"
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0
    
    local function Update()
        if Player.Character and Config.EspEnabled then
            if Config.TeamCheck and Player.Team == LocalPlayer.Team then
                Highlight.Parent = nil
            else
                Highlight.Parent = Player.Character
                Highlight.FillColor = Color3.fromRGB(255, 0, 0)
            end
        else
            Highlight.Parent = nil
        end
    end
    
    RunService.RenderStepped:Connect(Update)
end

-- Simple Aim-Assist Logic
local function GetClosestPlayer()
    local MaximumDistance = math.huge
    local Target = nil

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Config.AimPart) then
            if Config.TeamCheck and v.Team == LocalPlayer.Team then continue end
            
            local ScreenPoint = Camera:WorldToScreenPoint(v.Character[Config.AimPart].Position)
            local VectorDistance = (Vector2.new(ScreenPoint.X, ScreenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
            
            if VectorDistance < MaximumDistance then
                Target = v
                MaximumDistance = VectorDistance
            end
        end
    end
    return Target
end

-- Execution Loop
RunService.RenderStepped:Connect(function()
    if Config.AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character then
            local TargetPos = Target.Character[Config.AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPos), Config.Smoothness)
        end
    end
end)

-- Initialize for existing and new players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end
Players.PlayerAdded:Connect(CreateESP)
