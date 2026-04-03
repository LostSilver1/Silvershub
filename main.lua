local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Silvers Hub | TC2 Elite",
   LoadingTitle = "Silvers Hub",
   LoadingSubtitle = "Universal & TC2 Optimized",
   ConfigurationSaving = { Enabled = false }
})

-- // Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().AimbotEnabled = false
getgenv().AimbotStyle = "Plain" -- Plain or Silent (Camera movement)
getgenv().SilentAim = false    -- Shoot Anywhere
getgenv().Prediction = false   -- Projectiles
getgenv().AutoBackstab = false
getgenv().InfCloak = false     -- TC2 Agent Only
getgenv().Bhop = false
getgenv().ESP = false
getgenv().HitboxSize = 2.5     -- Subtle enough to not be banned

-- // Tabs
local Combat = Window:CreateTab("Combat", 4483362458)
local TC2Tab = Window:CreateTab("TC2 Specials", 4483362458)
local Visuals = Window:CreateTab("Visuals", 4483362458)

-- // Combat
Combat:CreateToggle({Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) getgenv().AimbotEnabled = v end})
Combat:CreateDropdown({Name = "Aimbot Style", Options = {"Plain", "Silent"}, CurrentOption = {"Plain"}, Callback = function(v) getgenv().AimbotStyle = v[1] end})
Combat:CreateToggle({Name = "Silent Aim (Shoot Sky)", CurrentValue = false, Callback = function(v) getgenv().SilentAim = v end})
Combat:CreateToggle({Name = "Projectile Prediction", CurrentValue = false, Callback = function(v) getgenv().Prediction = v end})
Combat:CreateToggle({Name = "B-Hop", CurrentValue = false, Callback = function(v) getgenv().Bhop = v end})

-- // TC2 Specials
TC2Tab:CreateToggle({Name = "Auto-Backstab (Forced)", CurrentValue = false, Callback = function(v) getgenv().AutoBackstab = v end})
TC2Tab:CreateToggle({Name = "Infinite Cloak", CurrentValue = false, Callback = function(v) getgenv().InfCloak = v end})
TC2Tab:CreateSlider({Name = "Subtle Hitbox", Range = {2, 6}, Increment = 0.5, CurrentValue = 2.5, Callback = function(v) getgenv().HitboxSize = v end})

-- // Visuals
Visuals:CreateToggle({Name = "Player ESP", CurrentValue = false, Callback = function(v) getgenv().ESP = v end})

-- // Logic: Target Selector
local function GetTarget()
    local target, dist = nil, 1000
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Team ~= LocalPlayer.Team then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if vis and mag < dist then
                target, dist = v, mag
            end
        end
    end
    return target
end

-- // Logic: Silent Aim Hook (TC2 Specific)
local OldNC
OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if getgenv().SilentAim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local t = GetTarget()
        if t then
            local p = getgenv().Prediction and (t.Character.HumanoidRootPart.Position + (t.Character.HumanoidRootPart.Velocity * 0.15)) or t.Character.Head.Position
            if method == "Raycast" then args[2] = (p - args[1]).Unit * 1000 else args[1] = Ray.new(Camera.CFrame.Position, (p - Camera.CFrame.Position).Unit * 1000) end
            return OldNC(self, unpack(args))
        end
    end
    return OldNC(self, ...)
end)

-- // Main Loop
RunService.Heartbeat:Connect(function()
    local t = GetTarget()
    
    -- Hitbox & ESP Loop
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.Size = (getgenv().HitboxSize > 2) and Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize) or Vector3.new(2, 2, 1)
            v.Character.HumanoidRootPart.CanCollide = false
            
            -- Fixed ESP
            local high = v.Character:FindFirstChild("SilversESP")
            if getgenv().ESP and v.Team ~= LocalPlayer.Team then
                if not high then high = Instance.new("Highlight", v.Character) high.Name = "SilversESP" end
            elseif high then high:Destroy() end
        end
    end

    -- Auto Backstab (Revised TC2 Logic)
    if getgenv().AutoBackstab and t and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool.Name:lower():find("knife") and (t.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 15 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2.5)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, t.Character.HumanoidRootPart.Position)
        end
    end

    -- Infinite Cloak (TC2)
    if getgenv().InfCloak and LocalPlayer.Character:FindFirstChild("QueuedCharacterData") then
        -- TC2 stores cloak in a different folder, this attempts to lock the value
        local stats = LocalPlayer.Character:FindFirstChild("QueuedCharacterData")
        if stats:FindFirstChild("Cloak") then stats.Cloak.Value = 100 end
    end
end)
