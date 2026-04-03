-- Silvers Hub | MOBILE ONLY Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Settings
local Settings = {
    Enabled = true,
    TeamCheck = true,
    AimPart = "HumanoidRootPart",
    FOV = 150,
    Smoothness = 0.1 -- Adjust for "sticky" feel (0.01 to 0.5)
}

-- // Create a Simple Mobile Toggle Button
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size = UDim2.new(0, 100, 0, 50)
Toggle.Position = UDim2.new(0, 10, 0.5, 0)
Toggle.Text = "Silvers Hub: ON"
Toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

Toggle.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    Toggle.Text = Settings.Enabled and "Silvers Hub: ON" or "Silvers Hub: OFF"
    Toggle.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- // FOV Circle for Mobile
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = true
FOVCircle.Radius = Settings.FOV

local function GetClosestPlayer()
    local Closest = nil
    local ShortestDistance = Settings.FOV

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if v.Character.Humanoid.Health <= 0 then continue end
            
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            local Distance = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude

            if OnScreen and Distance < ShortestDistance then
                Closest = v
                ShortestDistance = Distance
            end
        end
    end
    return Closest
end

-- // Mobile Camera Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if Settings.Enabled then
        local Target = GetClosestPlayer()
        if Target then
            local TargetPos = Target.Character[Settings.AimPart].Position
            -- Smoothly rotate camera toward target
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPos), Settings.Smoothness)
        end
    end
end)
