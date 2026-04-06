-- SILVERS HUB: TC2 MAX PERFORMANCE EDITION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- 1. AGGRESSIVE MOBILE FPS BOOST (Max Optimization)
local function MaximizeFPS()
    -- Global Engine Settings
    settings().Rendering.QualityLevel = 1
    settings().Physics.PhysicsEnvironmentalThrottle = 1
    
    -- Lighting Cleanup
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostProcessEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") then
            effect.Enabled = false
        end
    end

    -- World Optimization (Remove Textures & High-Poly Materials)
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") then
            v.Enabled = false
        end
    end
end

-- 2. TC2 TEAM-SPECIFIC ESP
local function CreateESP(Player)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "TC2_Project_ESP"
    Highlight.FillTransparency = 0.4
    Highlight.OutlineTransparency = 0
    
    local function Update()
        if Player.Character and Player.Parent and LocalPlayer.Team then
            -- ONLY show if they are on the ENEMY team
            if Player.Team ~= LocalPlayer.Team then
                Highlight.Parent = Player.Character
                
                -- Dynamic Team Coloring (TC2 Specific)
                if Player.Team.Name == "RED" or Player.Team.Name == "Red" then
                    Highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                elseif Player.Team.Name == "GRN" or Player.Team.Name == "Green" then
                    Highlight.FillColor = Color3.fromRGB(50, 255, 50)
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                Highlight.Parent = nil -- Hide Teammates
            end
        else
            Highlight.Parent = nil
        end
    end
    
    RunService.RenderStepped:Connect(Update)
end

-- 3. EXECUTION
MaximizeFPS()

-- Setup for all players
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)

print("Silvers Hub: Max FPS & TC2 ESP Loaded.")
