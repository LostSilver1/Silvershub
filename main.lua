local function getClosest()
    local target = nil
    local dist = math.huge
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= game:GetService("Players").LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            -- Distance check logic
            local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if visible then
                local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude
                if mag < dist and mag < 200 then -- 200 is your FOV size
                    dist = mag
                    target = v
                end
            end
        end
    end
    return target
end
