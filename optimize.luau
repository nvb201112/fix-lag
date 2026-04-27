--// ADVANCED BOOSTER + MEMORY CLEANER

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

-- =========================
-- SETTINGS
-- =========================
local SETTINGS = {
    FPS_CAP = 60,
    AUTO_OPTIMIZE = true,
    MEMORY_CLEAN_INTERVAL = 10, -- giây
    AGGRESSIVE_CLEAN = false -- bật nếu máy rất yếu
}

-- =========================
-- FPS CAP
-- =========================
pcall(function()
    setfpscap(SETTINGS.FPS_CAP)
end)

-- =========================
-- CLEAN LIGHTING EFFECTS
-- =========================
local function cleanLighting()
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("BlurEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("BloomEffect")
        or v:IsA("ColorCorrectionEffect") then
            v:Destroy()
        end
    end
end

cleanLighting()

-- =========================
-- CLEAR UNUSED EFFECTS
-- =========================
local function clearEffects()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Smoke")
        or v:IsA("Fire")
        or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
end

-- =========================
-- MEMORY CLEANER CORE
-- =========================
local function memoryCleaner()
    for _, v in pairs(workspace:GetDescendants()) do
        
        -- ❌ Xoá object vô dụng
        if v:IsA("Decal") or v:IsA("Texture") then
            if SETTINGS.AGGRESSIVE_CLEAN then
                v:Destroy()
            end
        end

        -- ❌ Sound không phát → xoá
        if v:IsA("Sound") and not v.IsPlaying then
            pcall(function()
                v:Destroy()
            end)
        end

        -- ❌ Particle không dùng
        if v:IsA("ParticleEmitter") and v.Enabled == false then
            if SETTINGS.AGGRESSIVE_CLEAN then
                v:Destroy()
            end
        end
    end

    -- 🧹 clear debris queue
    pcall(function()
        Debris.MaxItems = 0
    end)
end

-- =========================
-- LOW MATERIAL (giảm RAM + GPU)
-- =========================
local function lowMaterial()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end
    end
end

lowMaterial()
clearEffects()

-- =========================
-- FPS TRACKER
-- =========================
local fps = 0
local lastFPS = 60

RunService.Heartbeat:Connect(function()
    fps += 1
end)

-- =========================
-- AUTO OPTIMIZE SYSTEM
-- =========================
task.spawn(function()
    while task.wait(1) do
        lastFPS = fps
        fps = 0

        if SETTINGS.AUTO_OPTIMIZE then
            if lastFPS < 30 then
                clearEffects()
                memoryCleaner()
            elseif lastFPS < 50 then
                clearEffects()
            end
        end
    end
end)

-- =========================
-- PERIODIC MEMORY CLEAN
-- =========================
task.spawn(function()
    while task.wait(SETTINGS.MEMORY_CLEAN_INTERVAL) do
        memoryCleaner()
    end
end)

-- =========================
-- ANTI LAG SPIKE
-- =========================
RunService.Stepped:Connect(function()
    if lastFPS < 25 then
        task.wait()
    end
end)

print("🧹 Memory Cleaner + FPS Booster Loaded")
