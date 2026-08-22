-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

-- Container GUI Aman
local parentContainer = (gethui and gethui()) or (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or LocalPlayer:WaitForChild("PlayerGui")
local oldGui = parentContainer:FindFirstChild("FreecamSystemGui")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui", parentContainer)
ScreenGui.Name = "FreecamSystemGui"
ScreenGui.ResetOnSpawn = false

-- ==================== UI KONTROL HP (PONDASI ASLI + UI TAMBAHAN) ====================
local Bar = Instance.new("Frame", ScreenGui)
Bar.Name = "Bar"
Bar.Size = UDim2.new(1, 0, 0, 42)
Bar.Position = UDim2.new(0, 0, 0.85, 0)
Bar.BackgroundTransparency = 1
Bar.Visible = false

local function createControlGroup(posScale, labelTitle, defaultVal)
    local container = Instance.new("Frame", Bar)
    container.Size = UDim2.new(0.3, 0, 1, 0)
    container.Position = UDim2.new(posScale, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    container.BackgroundTransparency = 0.3
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.Text = labelTitle .. ": " .. defaultVal

    local btnMinus = Instance.new("TextButton", container)
    btnMinus.Size = UDim2.new(0, 30, 0, 30)
    btnMinus.Position = UDim2.new(0, 5, 0.5, -15)
    btnMinus.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btnMinus.Text = "-"
    btnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnMinus.Font = Enum.Font.GothamBold
    btnMinus.TextSize = 14
    Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 6)

    local btnPlus = Instance.new("TextButton", container)
    btnPlus.Size = UDim2.new(0, 30, 0, 30)
    btnPlus.Position = UDim2.new(1, -35, 0.5, -15)
    btnPlus.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btnPlus.Text = "+"
    btnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPlus.Font = Enum.Font.GothamBold
    btnPlus.TextSize = 14
    Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 6)

    return lbl, btnMinus, btnPlus
end

local SpeedLbl, SpeedMinus, SpeedPlus = createControlGroup(0.02, "Speed", "1.0")
local FoVLbl, FoVMinus, FoVPlus = createControlGroup(0.34, "FoV", "70")
local FocusLbl, FocusMinus, FocusPlus = createControlGroup(0.66, "Focus", "15")

-- Tombol Floating Pengaktif Freecam
local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0.02, 0, 0.22, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FloatBtn.Text = "CAM"
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 12
FloatBtn.Draggable = true
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", FloatBtn)
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Thickness = 2

-- ==================== 90% KODE PONDASI ASLI FREECAM ====================
local Spring = {}
Spring.__index = Spring
function Spring.new(freq, damping, mass, pos)
    local self = setmetatable({}, Spring)
    self.f, self.d, self.m = freq, damping, mass
    self.t, self.p, self.v = pos, pos, pos * 0
    return self
end
function Spring:Update(dt)
    local f, d = self.f * math.pi * 2, self.d
    local p0, v0, t = self.p, self.v, self.t
    local offset = p0 - t
    local decay = math.exp(-d * f * dt)
    local c1 = decay * (v0 + f * offset)
    local c2 = decay * (offset)
    local root = math.sqrt(math.max(0, 1 - d * d))
    self.p = t + c2 * math.cos(f * root * dt) + c1 * math.sin(f * root * dt)
    self.v = -f * decay * (v0 + f * offset) * math.sin(f * root * dt) + decay * v0 * math.cos(f * root * dt)
    return self.p
end

local cameraActive = false
local camRotX, camRotY = 0, 0
local camSpeed = 1.0
local camFoV = 70
local targetFocus = 15

local springPos = Spring.new(0.77, 0.33, 1, Vector3.new())
local springRot = Spring.new(0.77, 0.33, 1, Vector2.new())
local springFoV = Spring.new(2, 0.33, 1, 70)

local function UpdateFreecam(dt)
    local camCFrame = CurrentCamera.CFrame
    
    -- Membaca input pergerakan (mendukung keyboard/gamepad, aman untuk HP jika tidak ditekan)
    local moveX = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
    local moveY = (UserInputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.Q) and 1 or 0)
    local moveZ = (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
    
    local moveVec = Vector3.new(moveX, moveY, moveZ)
    if moveVec.Magnitude > 0 then moveVec = moveVec.Unit end
    
    springPos.t = moveVec * camSpeed
    local updatedPos = springPos:Update(dt) * Vector3.new(1, 0.75, 1)
    local updatedRot = springRot:Update(dt)
    
    camRotX = math.clamp(camRotX - updatedRot.x * 0.003, -1.5, 1.5)
    camRotY = camRotY - updatedRot.y * 0.003
    springRot.t = Vector2.new(0, 0)
    
    local newCFrame = CFrame.new(camCFrame.p) * CFrame.Angles(0, camRotY, 0) * CFrame.Angles(camRotX, 0, 0) * CFrame.new(updatedPos)
    CurrentCamera.CFrame = newCFrame
    CurrentCamera.Focus = newCFrame * CFrame.new(0, 0, -16)
    
    camFoV = springFoV:Update(dt)
    CurrentCamera.FieldOfView = camFoV
end

-- ==================== KONEKSI TOMBOL + / - PADA UI ====================
SpeedPlus.MouseButton1Click:Connect(function()
    camSpeed = math.clamp(camSpeed + 0.2, 0.1, 10)
    SpeedLbl.Text = "Speed: " .. string.format("%.1f", camSpeed)
end)
SpeedMinus.MouseButton1Click:Connect(function()
    camSpeed = math.clamp(camSpeed - 0.2, 0.1, 10)
    SpeedLbl.Text = "Speed: " .. string.format("%.1f", camSpeed)
end)

FoVPlus.MouseButton1Click:Connect(function()
    camFoV = math.clamp(camFoV + 5, 5, 120)
    springFoV.t = camFoV
    FoVLbl.Text = "FoV: " .. math.floor(camFoV)
end)
FoVMinus.MouseButton1Click:Connect(function()
    camFoV = math.clamp(camFoV - 5, 5, 120)
    springFoV.t = camFoV
    FoVLbl.Text = "FoV: " .. math.floor(camFoV)
end)

FocusPlus.MouseButton1Click:Connect(function()
    targetFocus = math.clamp(targetFocus + 5, 1, 150)
    pcall(function() Lighting.FreecamDOF.InFocusRadius = targetFocus end)
    FocusLbl.Text = "Focus: " .. math.floor(targetFocus)
end)
FocusMinus.MouseButton1Click:Connect(function()
    targetFocus = math.clamp(targetFocus - 5, 1, 150)
    pcall(function() Lighting.FreecamDOF.InFocusRadius = targetFocus end)
    FocusLbl.Text = "Focus: " .. math.floor(targetFocus)
end)

-- Fungsi Aktif / Nonaktif Freecam
local function StartFreecam()
    if cameraActive then return end
    cameraActive = true
    Bar.Visible = true
    
    -- Buat Efek DOF Asli
    local dof = Instance.new("DepthOfFieldEffect", Lighting)
    dof.Name = "FreecamDOF"
    dof.InFocusRadius = targetFocus
    dof.FarIntensity = 0.25
    dof.NearIntensity = 0.75

    CurrentCamera.CameraType = Enum.CameraType.Scriptable
    
    -- Bekukan karakter pemain
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp then hrp.Anchored = true end
        if hum then hum.WalkSpeed = 0 end
    end

    -- Sentuhan Layar HP untuk Geser Kamera (Touch)
    local activeTouch, lastPos = nil, Vector2.new()
    UserInputService.TouchStarted:Connect(function(touch)
        if cameraActive and touch.Position.Y < (CurrentCamera.ViewportSize.Y * 0.8) and not activeTouch then
            activeTouch = touch
            lastPos = touch.Position
        end
    end)
    UserInputService.TouchMoved:Connect(function(touch)
        if touch == activeTouch then
            local delta = touch.Position - lastPos
            lastPos = touch.Position
            springRot.t = Vector2.new(delta.Y, delta.X)
        end
    end)
    UserInputService.TouchEnded:Connect(function(touch)
        if touch == activeTouch then
            activeTouch = nil
            springRot.t = Vector2.new(0, 0)
        end
    end)

    local lookVec = CurrentCamera.CFrame.LookVector
    camRotY = math.atan2(-lookVec.X, -lookVec.Z)
    camRotX = math.asin(math.clamp(lookVec.Y, -1, 1))
    springFoV.t = camFoV

    RunService:BindToRenderStep("FreecamCore", Enum.RenderPriority.Camera.Value, UpdateFreecam)
end

local function StopFreecam()
    if not cameraActive then return end
    cameraActive = false
    Bar.Visible = false
    
    RunService:UnbindFromRenderStep("FreecamCore")
    pcall(function() Lighting.FreecamDOF:Destroy() end)
    
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp then hrp.Anchored = false end
        if hum then hum.WalkSpeed = 16 end
    end
    
    CurrentCamera.FieldOfView = 70
    CurrentCamera.CameraType = Enum.CameraType.Custom
end

FloatBtn.MouseButton1Click:Connect(function()
    if cameraActive then StopFreecam() else StartFreecam() end
end)
