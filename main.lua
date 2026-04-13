local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Project: Silvers Hub (Educational)",
   LoadingTitle = "Executing Default Configurations...",
   LoadingSubtitle = "by Sirdiscalot0",
   ConfigurationSaving = {
      Enabled = false
   }
})

local MainTab = Window:CreateTab("Mechanics", 4483362458)

-- All features set to true for the project demo
local BhopEnabled = true
local HighlightEnabled = true
local ReachEnabled = true
local ReachSize = Vector3.new(15, 15, 15)

--- UI CONTROLS
MainTab:CreateToggle({
   Name = "Auto-Jump Logic (Bhop)",
   CurrentValue = true,
   Callback = function(Value)
      BhopEnabled = Value
   end,
})

MainTab:CreateToggle({
   Name = "Team-Based Highlighting (ESP)",
   CurrentValue = true,
   Callback = function(Value)
      HighlightEnabled = Value
      if not Value then
         for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ProjectHighlight") then
               p.Character.ProjectHighlight:Destroy()
            end
         end
      end
   end,
})

MainTab:CreateToggle({
   Name = "Extended Interaction (Reach)",
   CurrentValue = true,
   Callback = function(Value)
      ReachEnabled = Value
   end,
})

--- UNIFIED EXECUTION LOOP
task.spawn(function()
    while true do
        local player = game.Players.LocalPlayer
        local character = player.Character
        
        -- Movement and Combat logic
        if character then
            if BhopEnabled and character:FindFirstChild("Humanoid") then
                if character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                    character.Humanoid.Jump = true
                end
            end
            
            local tool = character:FindFirstChildOfClass("Tool")
            if ReachEnabled and tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = ReachSize
                tool.Handle.CanCollide = false
            elseif tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Vector3.new(1, 1, 1)
            end
        end
        
        -- Team-Specific Visuals (RED vs GRN)
        if HighlightEnabled then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
                    local h = p.Character:FindFirstChild("ProjectHighlight") or Instance.new("Highlight")
                    h.Name = "ProjectHighlight"
                    h.Parent = p.Character
                    
                    -- Color Logic
                    if p.TeamColor == BrickColor.new("Bright red") or (p.Team and p.Team.Name == "RED") then
                        h.FillColor = Color3.fromRGB(255, 0, 0)
                    elseif p.TeamColor == BrickColor.new("Bright green") or (p.Team and p.Team.Name == "GRN") then
                        h.FillColor = Color3.fromRGB(0, 255, 0)
                    else
                        h.FillColor = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
        
        task.wait(0.05)
    end
end)

Rayfield:Notify({
   Title = "Project: Silvers Hub",
   Content = "All Educational Mechanics are now TRUE.",
   Duration = 5
})
