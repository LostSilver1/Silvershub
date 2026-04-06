-- Educational Script: Silvers Hub (ESP + Mobile FPS Boost)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- 1. FPS BOOST CONFIGURATION (Mobile Optimized)
local function BoostFPS()
    -- Disable Heavy Lighting Effects
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostProcessEffect") then
            effect.Enabled = false
        end
    end

    -- Downgrade World Textures & Materials
    local settings = settings().Rendering
    settings.QualityLevel = 1
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

-- 2. ESP CONFIGURATION (No Menu)
local function CreateESP(Player)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "Edu_ESP"
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0
    Highlight.FillColor = Color3.fromRGB(0, 255, 150) -- Distinct color for visibility
    
    local function Update()
        if Player.Character and Player.Parent then
            -- Optional: Team Check (uncomment if needed)
            -- if Player.Team == LocalPlayer.Team then Highlight.Parent = nil return end
            Highlight.Parent = Player.Character
        else
            Highlight.Parent = nil
        end
    end
    
    RunService.RenderStepped:Connect(Update)
end

-- 3. EXECUTION
BoostFPS()

-- Setup ESP for current and future players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end
Players.PlayerAdded:Connect(CreateESP)

print("Silvers Hub: ESP and FPS Boost Loaded.")
