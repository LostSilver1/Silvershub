local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Silvers Hub | TC2 & Universal",
   LoadingTitle = "Silvers Hub",
   LoadingSubtitle = "Mobile Combat Suite",
   ConfigurationSaving = { Enabled = false }
})

-- // Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().Aimbot = false
getgenv().TeleStab = false -- Agent Teleport
getgenv().InfAmmo = false  -- Fast Auto-Reload
getgenv().Reach = false
getgenv().ReachSize = 15

-- // Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local TC2Tab = Window:CreateTab("TC2 Specials", 4483362458)

-- // Combat Features
CombatTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value) getgenv().Aimbot = Value end,
})

CombatTab:CreateToggle({
   Name = "Melee Reach",
   CurrentValue = false,
   Callback = function(Value) getgenv().Reach = Value end,
})

-- // TC2 Specifics
TC2Tab:CreateToggle({
   Name = "Agent Tele-Stab",
   CurrentValue = false,
   Callback = function(Value) getgenv().TeleStab = Value end,
})

TC2Tab:CreateToggle({
   Name = "Infinite Ammo (Auto-Refill)",
   CurrentValue = false,
   Callback = function(Value) getgenv().InfAmmo = Value end,
})

-- // Logic: Tele-Stab (Agent)
-- This waits for you to click while holding a knife, then teleports you behind the nearest enemy
local function DoTeleStab()
    if not getgenv().TeleStab then return end
    local Target = nil
    local Dist = 20 -- Max teleport range
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Team ~= LocalPlayer.Team then
                local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if d < Dist then
                    Target = v
                    break
                end
            end
        end
    end
    
    if Target then
        -- Teleport 3 studs behind the target
        LocalPlayer.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end

-- Hook into Mouse/Touch for TeleStab
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if getgenv().TeleStab and LocalPlayer.Character:FindFirstChildOfClass("Tool"):FindFirstChild("Knife") then
            DoTeleStab()
        end
    end
end)

-- // Logic: Infinite Ammo Loop
RunService.Heartbeat:Connect(function()
    if getgenv().InfAmmo then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Ammo") then
            -- This tries to keep your current clip full
            tool.Ammo.Value = 100 
        end
    end
end)

-- // Logic: Melee Reach
RunService.Stepped:Connect(function()
    if getgenv().Reach then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if v.Team ~= LocalPlayer.Team then
                    v.Character.HumanoidRootPart.Size = Vector3.new(getgenv().ReachSize, getgenv().ReachSize, getgenv().ReachSize)
                end
            end
        end
    end
end)
