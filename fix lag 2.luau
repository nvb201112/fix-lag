--// SERVICES
local RunService = game:GetService("RunService")

--// CLEAR MAP NGAY LẬP TỨC
local function clearMap()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = 1
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

clearMap()

-- chống game spawn lại
workspace.DescendantAdded:Connect(function(v)
    task.wait()
    if v:IsA("BasePart") then
        v.LocalTransparencyModifier = 1
        v.CastShadow = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Enabled = false
    end
end)

--// GUI FPS (OVERLAY TOP)
local gui = Instance.new("ScreenGui")
gui.Name = "FPS_OVERLAY"
gui.Parent = game.CoreGui

-- 🔥 luôn nằm trên UI khác
pcall(function()
    gui.DisplayOrder = 999999
end)

local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Size = UDim2.new(0, 170, 0, 50)
fpsLabel.Position = UDim2.new(0, 10, 0, 10)
fpsLabel.BackgroundTransparency = 0.3
fpsLabel.TextScaled = true

-- 🎮 font arcade
fpsLabel.Font = Enum.Font.Arcade

--// FPS COUNTER + RAINBOW
local last = tick()
local frames = 0
local hue = 0

RunService.RenderStepped:Connect(function()
    frames += 1
    hue += 0.01
    if hue > 1 then hue = 0 end

    fpsLabel.TextColor3 = Color3.fromHSV(hue,1,1)

    if tick() - last >= 1 then
        fpsLabel.Text = "FPS: " .. frames
        frames = 0
        last = tick()
    end
end)

print("AUTO CLEAR MAP + FPS OVERLAY LOADED")
