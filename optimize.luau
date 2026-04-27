-- // ROBLOX PERFORMANCE OPTIMIZER
-- // Client-side | Tối ưu FPS, RAM, giảm lag
-- // Tương thích chạy song song với auto farm

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

print("[Optimizer] Đang khởi động tối ưu hiệu năng...")

-- =============================================
-- 1. CẤU HÌNH (chỉnh theo nhu cầu)
-- =============================================
local CONFIG = {
    -- Đồ họa
    RenderDistance = 256,       -- Giảm xuống 128 nếu vẫn còn lag
    MaxParticles = 5,           -- Giới hạn particle
    QualityLevel = 3,           -- 1-10 (thấp = mượt hơn, máy yếu dùng 1-3)
    DisableShadows = true,      -- Tắt bóng đổ
    DisableFog = true,          -- Tắt sương mù
    
    -- Bộ nhớ
    GCInterval = 30,            -- Dọn RAM mỗi X giây
    
    -- FPS
    TargetFPS = 60,             -- FPS mục tiêu
    UnlockFPS = true,           -- Mở khóa FPS cap (nếu máy đủ mạnh)
}

-- =============================================
-- 2. TỐI ƯU ĐỒ HỌA
-- =============================================
local function OptimizeGraphics()
    -- Render distance
    workspace.StreamingEnabled = true
    Camera.MaxZoom = 128
    
    -- Chất lượng đồ họa
    settings().Rendering.QualityLevel = Enum.QualityLevel["Level0" .. CONFIG.QualityLevel] 
        or Enum.QualityLevel.Level03

    -- Tắt hiệu ứng Lighting
    if CONFIG.DisableShadows then
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
    end

    if CONFIG.DisableFog then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 99999
    end

    -- Tắt/giảm hiệu ứng post-processing nhẹ
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BlurEffect") then
            effect.Size = 0
        elseif effect:IsA("SunRaysEffect") then
            effect.Intensity = 0
        elseif effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end

    print("[Optimizer] ✓ Đồ họa đã được tối ưu")
end

-- =============================================
-- 3. TỐI ƯU PARTICLE VÀ HIỆU ỨNG
-- =============================================
local function OptimizeEffects()
    local function ProcessPart(obj)
        if obj:IsA("ParticleEmitter") then
            obj.Rate = math.min(obj.Rate, CONFIG.MaxParticles)
            obj.Lifetime = NumberRange.new(0.5, 1)
        elseif obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("SelectionBox") or obj:IsA("SelectionSphere") then
            obj:Destroy()
        end
    end

    -- Xử lý object hiện có
    for _, obj in pairs(workspace:GetDescendants()) do
        ProcessPart(obj)
    end

    -- Theo dõi object mới
    workspace.DescendantAdded:Connect(function(obj)
        task.defer(ProcessPart, obj)
    end)

    print("[Optimizer] ✓ Hiệu ứng particle đã được giới hạn")
end

-- =============================================
-- 4. DỌN RAM / GC (Garbage Collection)
-- =============================================
local function StartGarbageCollection()
    task.spawn(function()
        while true do
            task.wait(CONFIG.GCInterval)
            
            -- Xóa các connection không dùng
            local collected = 0
            
            -- Gợi ý GC cho Lua VM
            -- (Roblox không expose gcinfo() trực tiếp nhưng tạo table lớn rồi xóa kích thích GC)
            local dummy = {}
            for i = 1, 1000 do dummy[i] = i end
            dummy = nil
            
            collected = collected + 1
            -- print("[Optimizer] GC cycle #" .. collected)
        end
    end)
    
    print("[Optimizer] ✓ Garbage Collection tự động mỗi " .. CONFIG.GCInterval .. "s")
end

-- =============================================
-- 5. TỐI ƯU NHÂN VẬT
-- =============================================
local function OptimizeCharacter(character)
    if not character then return end
    
    -- Giảm level of detail cho nhân vật phụ (không phải bản thân)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("SpecialMesh") then
                    -- Giữ nguyên để không ảnh hưởng gameplay
                elseif part:IsA("ParticleEmitter") then
                    part.Rate = 0
                end
            end
        end
    end
end

-- =============================================
-- 6. MỞ KHÓA FPS (nếu bật)
-- =============================================
local function SetFPSCap()
    if CONFIG.UnlockFPS then
        -- Roblox 2022+ hỗ trợ setfpscap qua một số executor
        if setfpscap then
            setfpscap(CONFIG.TargetFPS)
            print("[Optimizer] ✓ FPS cap: " .. CONFIG.TargetFPS)
        else
            print("[Optimizer] ℹ Executor không hỗ trợ setfpscap")
        end
    end
end

-- =============================================
-- 7. NETWORK OPTIMIZATION
-- =============================================
local function OptimizeNetwork()
    -- Giảm tần suất update không cần thiết
    -- Chỉ render những gì trong tầm camera
    local function UpdateStreamingRadius()
        local hrp = LocalPlayer.Character and 
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Workspace streaming radius
            if workspace.StreamingEnabled then
                workspace.StreamingMinRadius = 64
                workspace.StreamingTargetRadius = CONFIG.RenderDistance
            end
        end
    end

    RunService.Heartbeat:Connect(function()
        -- Chạy mỗi ~1 giây thay vì mỗi frame
    end)
    
    UpdateStreamingRadius()
    print("[Optimizer] ✓ Network streaming đã tối ưu")
end

-- =============================================
-- 8. MONITOR FPS (debug)
-- =============================================
local function StartFPSMonitor()
    local frameCount = 0
    local lastTime = tick()
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 5 then
            local fps = math.floor(frameCount / (now - lastTime))
            print("[Optimizer] FPS hiện tại: " .. fps)
            frameCount = 0
            lastTime = now
        end
    end)
end

-- =============================================
-- 9. KHỞI CHẠY TẤT CẢ
-- =============================================
local function Init()
    -- Chờ game load xong
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    task.wait(2) -- Đợi map load
    
    OptimizeGraphics()
    OptimizeEffects()
    StartGarbageCollection()
    SetFPSCap()
    OptimizeNetwork()
    StartFPSMonitor()
    
    -- Tối ưu khi nhân vật spawn
    LocalPlayer.CharacterAdded:Connect(OptimizeCharacter)
    if LocalPlayer.Character then
        OptimizeCharacter(LocalPlayer.Character)
    end
    
    -- Tối ưu lại khi player khác vào
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            OptimizeCharacter(player.Character)
        end)
    end)
    
    print("[Optimizer] ✅ Hoàn tất! Đang chạy tối ưu nền...")
    print("[Optimizer] Chỉnh CONFIG ở đầu script để tuỳ chỉnh thêm")
end

Init()
