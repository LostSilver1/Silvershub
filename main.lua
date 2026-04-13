local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Project: Silvers Hub (Final Submission)",
   LoadingTitle = "Compiling Educational Assets...",
   LoadingSubtitle = "by Sirdiscalot0",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Mechanics", 4483362458)

-- Configuration Variables (All set to True for Demo)
local BhopEnabled = true
local HighlightEnabled = true
local ReachEnabled = true
local TrackingEnabled = true

local ReachSize = Vector3.new(15, 15, 15)
local Smoothness = 0.1 -- For Smooth Tracking

--- EDUCATIONAL HELPER FUNCTIONS
local function isRoundLive()
    local status = game.ReplicatedStorage:FindFirstChild("Status")
    return status and (status.Value ~= "Waiting for Players" and status.Value ~= "Intermission")
end

local function isVisible(targetPart)
    local origin = workspace.CurrentCamera.CFrame.Position
    local direction = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(origin, direction, params)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function getClosestVisibleEnemy()
    local closest = nil
    local dist = 500
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            -- Team Check: Don't track teammates
            if p.Team ~= game.Players.LocalPlayer.Team then
                if isVisible(p.Character.Head) then
                    local d = (workspace.CurrentCamera.CFrame.Position - p.Character.Head.Position).Magnitude
                    if d < dist then
                        dist = d
                        closest = p.Character.Head
                    end
                end
            end
        end
    end
    return closest
end

--- UI CONTROLS
MainTab:CreateToggle({Name = "Auto-Jump Logic (Bhop)", CurrentValue = true, Callback = function(V) BhopEnabled = V end})
MainTab:CreateToggle({Name = "Team-Based ESP", CurrentValue = true, Callback = function(V) HighlightEnabled = V end})
MainTab:CreateToggle({Name = "Fixed Extended Reach", CurrentValue = true, Callback = function(V) ReachEnabled = V end})
MainTab:CreateToggle({Name = "Smooth Camera Tracking", CurrentValue = true, Callback = function(V) TrackingEnabled = V end})

--- UNIFIED EXECUTION LOOP
game:GetService("RunService").RenderStepped:Connect(function()
    if not isRoundLive() then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if character then
        -- 1. Bhop Logic
        if BhopEnabled and character:FindFirstChild("Humanoid") and character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            character.Humanoid.Jump = true
        end
        
        -- 2. FIXED Reach Logic (Recursive Search + Physics Fix)
        local tool = character:FindFirstChildOfClass("Tool")
        if ReachEnabled and tool then
            for _, part in pairs(tool:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = ReachSize
                    part.CanCollide = false
                    part.Massless = true -- Prevents weight issues
                end
            end
        end
        
        -- 3. Smooth Camera Tracking
        if TrackingEnabled then
            local target = getClosestVisibleEnemy()
            if target then
                local camera = workspace.CurrentCamera
                local targetCFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, Smoothness)
            end
        end
    end

    -- 4. Team-Based Visuals (ESP)
    if HighlightEnabled then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = p.Character:FindFirstChild("ProjectHighlight") or Instance.new("Highlight")
                h.Name = "ProjectHighlight"
                h.Parent = p.Character
                
                if p.TeamColor == BrickColor.new("Bright red") or (p.Team and p.Team.Name == "RED") then
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                else
                    h.FillColor = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    end
end)

Rayfield:Notify({
   Title = "Project Complete",
   Content = "All logic modules integrated for Silvers Hub.",
   Duration = 5
})
