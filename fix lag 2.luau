--// CLEAR MAP BẰNG TRANSPARENCY

local function makeTransparent(v)
    if v:IsA("BasePart") then
        v.LocalTransparencyModifier = 1
        v.CastShadow = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Enabled = false
    elseif v:IsA("Beam") then
        v.Enabled = false
    elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
        v.Enabled = false
    end
end

-- áp dụng toàn map
for _, v in pairs(workspace:GetDescendants()) do
    makeTransparent(v)
end

-- xử lý object spawn thêm
workspace.DescendantAdded:Connect(function(v)
    task.wait()
    makeTransparent(v)
end)

print("CLEAR MAP (TRANSPARENT) LOADED")
