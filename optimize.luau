-- FPS Counter (Draggable + Color)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSCounter"
pcall(function()
    ScreenGui.Parent = game.CoreGui
end)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 130, 0, 45)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1,0,1,0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "FPS: ..."
TextLabel.TextScaled = true
TextLabel.Font = Enum.Font.Code
TextLabel.TextColor3 = Color3.fromRGB(0,255,0)
TextLabel.Parent = Frame

-- FPS calc
local lastTime = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount += 1
    
    local now = tick()
    if now - lastTime >= 1 then
        local fps = frameCount
        frameCount = 0
        lastTime = now
        
        TextLabel.Text = "FPS: " .. fps
        
        -- đổi màu theo FPS
        if fps < 30 then
            TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        elseif fps < 60 then
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        else
            TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
end)

-- Drag system (mượt, không giật)
local dragging = false
local dragInput, dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

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
