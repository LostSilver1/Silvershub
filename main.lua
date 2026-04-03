-- SILVERS HUB: UNIVERSAL CORE
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- This function "finds" the enemy even if they don't have a standard Head
local function getTarget()
    local closest = nil
    local dist = 250 -- Your FOV Radius

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- Arsenal/TC2 often use "HumanoidRootPart" for the body center
            local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
            if root then
                local pos, visible = Camera:WorldToViewportPoint(root.Position)
                if visible then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mouseDist < dist then
                        dist = mouseDist
                        closest = root
                    end
                end
            end
        end
    end
    return closest
end

-- The "Easy Hit" Loop
game:GetService("RunService").RenderStepped:Connect(function()
    local target = getTarget()
    if target then
        -- Smoothing makes it look natural for your school demo
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 0.15)
    end
end)

game.StarterGui:SetCore("ChatMakeSystemMessage", {
    Text = "Executor is working! Checking link next...";
    Color = Color3.fromRGB(0, 255, 0);
})
