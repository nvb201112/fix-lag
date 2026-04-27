--// UI SAFE FPS BOOSTER

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================
-- SETTINGS
-- =========================
local SETTINGS = {
    FPS_CAP = 60,
    KEEP_PLAYER_VISIBLE = true,
    AUTO_OPTIMIZE = true
}

pcall(function()
    setfpscap(SETTINGS.FPS_CAP)
end)

-- =========================
-- SAFE CHECK (KHÔNG ĐỤNG UI)
-- =========================
local function isUI(v)
    return v:IsDescendantOf(PlayerGui)
end

-- =========================
-- LIGHTING CLEAN
-- =========================
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 1

for _, v in pairs(Lighting:GetDescendants()) do
    if v:IsA("PostEffect") then
        v:Destroy()
    end
end

-- =========================
-- OPTIMIZE MAP (SAFE)
-- =========================
local function optimize(v)
    if isUI(v) then return end

    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
        v.CastShadow = false
    end

    if v:IsA("Decal") or v:IsA("Texture") then
        v:Destroy()
    end

    if v:IsA("ParticleEmitter")
    or v:IsA("Trail")
    or v:IsA("Smoke")
    or v:IsA("Fire")
    or v:IsA("Sparkles") then
        v.Enabled = false
    end
end

-- chạy lần đầu
for _, v in pairs(workspace:GetDescendants()) do
    optimize(v)
end

-- =========================
-- HANDLE OBJECT MỚI
-- =========================
workspace.DescendantAdded:Connect(function(v)
    task.spawn(function()
        optimize(v)
    end)
end)

-- =========================
-- MEMORY CLEAN (SAFE)
-- =========================
task.spawn(function()
    while task.wait(10) do
        for _, v in pairs(workspace:GetDescendants()) do
            if isUI(v) then continue end

            if v:IsA("Sound") and not v.IsPlaying then
                pcall(function()
                    v:Destroy()
                end)
            end
        end

        pcall(function()
            Debris.MaxItems = 0
        end)
    end
end)

-- =========================
-- FPS TRACK + AUTO BOOST
-- =========================
local fps = 0
local lastFPS = 60

RunService.Heartbeat:Connect(function()
    fps += 1
end)

task.spawn(function()
    while task.wait(1) do
        lastFPS = fps
        fps = 0

        if SETTINGS.AUTO_OPTIMIZE then
            if lastFPS < 30 then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Transparency = math.clamp(v.Transparency + 0.03, 0, 0.5)
                    end
                end
            end
        end
    end
end)

-- =========================
-- ANTI SPIKE
-- =========================
RunService.Stepped:Connect(function()
    if lastFPS < 25 then
        task.wait()
    end
end)

print("⚡ UI Safe Booster Loaded")
