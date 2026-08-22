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
local parentContainer
if gethui then
    parentContainer = gethui()
else
    local success, core = pcall(function() return game:GetService("CoreGui") end)
    parentContainer = (success and core) or LocalPlayer:WaitForChild("PlayerGui")
end

-- Clean Up GUI Lama
local oldGui = parentContainer:FindFirstChild("FreecamSystemGui")
if oldGui then oldGui:Destroy() end

-- ScreenGui Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FreecamSystemGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentContainer

-- ==================== BAR INDIKATOR & TOMBOL + / - LENGKAP ====================
local Bar = Instance.new("Frame", ScreenGui)
Bar.Name = "Bar"
Bar.Size = UDim2.new(1, 0, 0, 40)
Bar.Position = UDim2.new(0, 0, 0.86, 0)
Bar.BackgroundTransparency = 1
Bar.Visible = false

-- Fungsi pembuat kotak kontrol + dan - yang rapi
local function createControlGroup(name, posScale, sizeW, labelTitle, defaultVal)
    local container = Instance.new("Frame", Bar)
    container.Name = name
    container.Size = UDim2.new(sizeW, 0, 1, 0)
    container.Position = UDim2.new(posScale, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BackgroundTransparency = 0.4
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", container)
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.Text = labelTitle .. ": " .. defaultVal

    local btnMinus = Instance.new("TextButton", container)
    btnMinus.Name = "Minus"
    btnMinus.Size = UDim2.new(0, 28, 0, 28)
    btnMinus.Position = UDim2.new(0, 4, 0.5, -14)
    btnMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btnMinus.Text = "-"
    btnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnMinus.Font = Enum.Font.GothamBold
    btnMinus.TextSize = 14
    Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 4)

    local btnPlus = Instance.new("TextButton", container)
    btnPlus.Name = "Plus"
    btnPlus.Size = UDim2.new(0, 28, 0, 28)
    btnPlus.Position = UDim2.new(1, -32, 0.5, -14)
    btnPlus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btnPlus.Text = "+"
    btnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPlus.Font = Enum.Font.GothamBold
    btnPlus.TextSize = 14
    Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 4)

    return container, lbl, btnMinus, btnPlus
end

-- Membuat Kontrol untuk Speed, FoV, dan Focus
local SpeedBox, SpeedLbl, SpeedMinus, SpeedPlus = createControlGroup("SpeedGroup", 0.02, 0.3, "Speed", "1.0")
local FoVBox, FoVLbl, FoVMinus, FoVPlus = createControlGroup("FoVGroup", 0.34, 0.3, "FoV", "70")
local FocusBox, FocusLbl, FocusMinus, FocusPlus = createControlGroup("FocusGroup", 0.66, 0.3, "Focus", "15")

-- Indikator Tombol Floating di Layar untuk Toggle Freecam
local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Name = "FreecamToggleBtn"
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FloatBtn.Text = "CAM"
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 11
FloatBtn.Draggable = true
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", FloatBtn)
BtnStroke.Color = Color3.fromRGB(0, 255, 150)
BtnStroke.Thickness = 2

-- ==================== MODUL SPRING ====================
local Spring = {}
Spring.__index = Spring
function Spring.new(freq, damping, mass, pos)
    local self = setmetatable({}, Spring)
    self.f = freq
    self.d = damping
    self.m = mass
    self.t = pos
    self.p = pos
    self.v = pos * 0
    return self
end
function Spring:Update(dt)
    local f = self.f * math.pi * 2
    local d = self.d
    local p0 = self.p
    local v0 = self.v
    local t = self.t
    local offset = p0 - t
    local decay = math.exp(-d * f * dt)
    local c1 = decay * (v0 + f * offset)
    local c2 = decay * (offset)
    self.p = t + c2 * math.cos(f * math.sqrt(math.max(0, 1 - d*d)) * dt) + c1 * math.sin(f * math.sqrt(math.max(0, 1 - d*d)) * dt)
    self.v = -f * decay * (v0 + f * offset) * math.sin(f * math.sqrt(math.max(0, 1 - d*d)) * dt) + decay * v0 * math.cos(f * math.sqrt(math.max(0, 1 - d*d)) * dt)
    return self.p
end

-- ==================== MODUL MAID ====================
local Maid = {}
Maid.__index = Maid
function Maid.new() return setmetatable({tasks = {}}, Maid) end
function Maid:Mark(task) table.insert(self.tasks, task) return task end
function Maid:Sweep()
    for _, task in ipairs(self.tasks) do
        if typeof(task) == "RBXScriptConnection" then task:Disconnect()
        elseif typeof(task) == "function" then task()
        elseif typeof(task) == "Instance" then task:Destroy() end
    end
    self.tasks = {}
end

-- Variabel Inti Freecam
local activeMaid = Maid.new()
local freecamActive = false
local savedGuiStates = {}

local camRotX = 0
local camRotY = 0
local camSpeed = 1
local camFoV = 70
local targetFocus = 15

local springPos = Spring.new(0.77, 0.33, 1, Vector3.new())
local springRot = Spring.new(0.77, 0.33, 1, Vector2.new())
local springFoV = Spring.new(2, 0.33, 1, 70)

-- Fungsi Sembunyikan/Munculkan CoreGui bawaan
local function ToggleCoreGui(hide)
    pcall(function()
        if hide then
            savedGuiStates.Health = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
            savedGuiStates.Backpack = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
            savedGuiStates.PlayerList = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
            savedGuiStates.Chat = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        else
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, savedGuiStates.Health or true)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, savedGuiStates.Backpack or true)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, savedGuiStates.PlayerList or true)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, savedGuiStates.Chat or true)
        end
    end)
end

-- Logika Update Pergerakan Freecam per Frame
local function UpdateFreecam(dt)
    local camCFrame = CurrentCamera.CFrame
    
    local moveX = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
    local moveY = (UserInputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.Q) and 1 or 0)
    local moveZ = (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
    
    local moveVec = Vector3.new(moveX, moveY, moveZ)
    if moveVec.Magnitude > 0 then
        moveVec = moveVec.Unit
    end
    
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

-- ==================== EVENT TOMBOL + / - DI SETIAP FITUR ====================
-- 1. Kontrol Kecepatan (Speed)
SpeedPlus.MouseButton1Click:Connect(function()
    camSpeed = math.clamp(camSpeed + 0.2, 0.1, 10)
    SpeedLbl.Text = "Speed: " .. string.format("%.1f", camSpeed)
end)
SpeedMinus.MouseButton1Click:Connect(function()
    camSpeed = math.clamp(camSpeed - 0.2, 0.1, 10)
    SpeedLbl.Text = "Speed: " .. string.format("%.1f", camSpeed)
end)

-- 2. Kontrol Bidang Pandang (FoV / Zoom)
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

-- 3. Kontrol Jarak Fokus Lensa (Depth of Field / Blur)
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

-- Masuk Freecam
local function EnterFreecam()
    if freecamActive then return end
    freecamActive = true
    Bar.Visible = true
    ToggleCoreGui(true)
    
    local dof = Instance.new("DepthOfFieldEffect")
    dof.Name = "FreecamDOF"
    dof.FarIntensity = 0.25
    dof.InFocusRadius = targetFocus
    dof.NearIntensity = 0.75
    dof.Parent = Lighting

    CurrentCamera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseIconEnabled = false

    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.Anchored = true end
        if humanoid then humanoid.WalkSpeed = 0 end
    end

    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FreecamSystemGui" then
            gui.Enabled = false
            activeMaid:Mark(function() gui.Enabled = true end)
        end
    end

    -- Kontrol Rotasi Kamera Sentuh / Layar HP
    activeMaid:Mark(UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            local conn
            conn = UserInputService.InputChanged:Connect(function(mouseInput)
                if mouseInput.UserInputType == Enum.UserInputType.MouseMovement or mouseInput.UserInputType == Enum.UserInputType.Touch then
                    springRot.t = Vector2.new(mouseInput.Delta.Y, mouseInput.Delta.X)
                end
            end)
            repeat task.wait() until UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) == false and input.UserInputState ~= Enum.UserInputState.End
            if conn then conn:Disconnect() end
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            springRot.t = Vector2.new(0, 0)
        end
    end))

    local lookVec = CurrentCamera.CFrame.LookVector
    camRotY = math.atan2(-lookVec.X, -lookVec.Z)
    camRotX = math.asin(math.clamp(lookVec.Y, -1, 1))

    RunService:BindToRenderStep("FreecamCore", Enum.RenderPriority.Camera.Value, UpdateFreecam)
end

-- Keluar Freecam
local function ExitFreecam()
    if not freecamActive then return end
    freecamActive = false
    Bar.Visible = false
    ToggleCoreGui(false)
    
    RunService:UnbindFromRenderStep("FreecamCore")
    activeMaid:Sweep()
    
    pcall(function() Lighting.FreecamDOF:Destroy() end)
    
    UserInputService.MouseIconEnabled = true
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.Anchored = false end
        if humanoid then humanoid.WalkSpeed = 16 end
    end
    
    CurrentCamera.FieldOfView = 70
    CurrentCamera.CameraType = Enum.CameraType.Custom
end

-- Event Tombol Floating Utama
FloatBtn.MouseButton1Click:Connect(function()
    if freecamActive then ExitFreecam() else EnterFreecam() end
end)
