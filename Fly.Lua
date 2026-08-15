local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("FlyGuiSystem")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyGuiSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 180, 0, 70)
MainContainer.Position = UDim2.new(0.5, -90, 0.15, 0)
MainContainer.BackgroundTransparency = 1
MainContainer.Active = true
MainContainer.Draggable = true

local FlyPanel = Instance.new("Frame", MainContainer)
FlyPanel.Name = "FlyPanel"
FlyPanel.Size = UDim2.new(1, 0, 1, 0)
FlyPanel.BackgroundTransparency = 1
FlyPanel.Visible = true

local MinimizeBtn = Instance.new("TextButton", MainContainer)
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -25, 0, -30)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local MinimizeStroke = Instance.new("UIStroke", MinimizeBtn)
MinimizeStroke.Color = Color3.fromRGB(255, 255, 255)
MinimizeStroke.Thickness = 1

local Watermark = Instance.new("TextLabel", FlyPanel)
Watermark.Size = UDim2.new(0, 80, 0, 35)
Watermark.Position = UDim2.new(0, 100, 0, 0)
Watermark.BackgroundColor3 = Color3.fromRGB(0, 230, 230)
Watermark.Text = "By.VELxz"
Watermark.TextColor3 = Color3.fromRGB(0, 0, 0)
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 12

local ToggleBtn = Instance.new("TextButton", FlyPanel)
ToggleBtn.Size = UDim2.new(0, 80, 0, 35)
ToggleBtn.Position = UDim2.new(0, 100, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 230, 230)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16

local UpBtn = Instance.new("TextButton", FlyPanel)
UpBtn.Size = UDim2.new(0, 30, 0, 35)
UpBtn.Position = UDim2.new(0, 70, 0, 0)
UpBtn.BackgroundColor3 = Color3.fromRGB(255, 235, 0)
UpBtn.Text = "↑"
UpBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
UpBtn.Font = Enum.Font.GothamBold
UpBtn.TextSize = 16

local DownBtn = Instance.new("TextButton", FlyPanel)
DownBtn.Size = UDim2.new(0, 30, 0, 35)
DownBtn.Position = UDim2.new(0, 70, 0, 35)
DownBtn.BackgroundColor3 = Color3.fromRGB(255, 235, 0)
DownBtn.Text = "↓"
DownBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
DownBtn.Font = Enum.Font.GothamBold
DownBtn.TextSize = 16

local SpeedDisplay = Instance.new("TextLabel", FlyPanel)
SpeedDisplay.Size = UDim2.new(0, 70, 0, 35)
SpeedDisplay.Position = UDim2.new(0, 0, 0, 0)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(255, 0, 220)
SpeedDisplay.Text = "0"
SpeedDisplay.TextColor3 = Color3.fromRGB(0, 0, 0)
SpeedDisplay.Font = Enum.Font.GothamBold
SpeedDisplay.TextSize = 16

local MinusBtn = Instance.new("TextButton", FlyPanel)
MinusBtn.Size = UDim2.new(0, 35, 0, 35)
MinusBtn.Position = UDim2.new(0, 0, 0, 35)
MinusBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.TextSize = 20

local PlusBtn = Instance.new("TextButton", FlyPanel)
PlusBtn.Size = UDim2.new(0, 35, 0, 35)
PlusBtn.Position = UDim2.new(0, 35, 0, 35)
PlusBtn.BackgroundColor3 = Color3.fromRGB(0, 230, 0)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.TextSize = 20

local isFlying = false
local flySpeed = 0
local upPressed = false
local downPressed = false

local bodyVel = nil
local bodyGyro = nil
local flyConnection = nil

local isMinimized = false

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    FlyPanel.Visible = not isMinimized
    MinimizeBtn.Text = isMinimized and "+" or "-"
end)

local function updateSpeedDisplay()
    SpeedDisplay.Text = tostring(flySpeed)
end

PlusBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 1
    updateSpeedDisplay()
end)

MinusBtn.MouseButton1Click:Connect(function()
    if flySpeed > 0 then
        flySpeed = flySpeed - 1
        updateSpeedDisplay()
    end
end)

UpBtn.MouseButton1Down:Connect(function() upPressed = true end)
UpBtn.MouseButton1Up:Connect(function() upPressed = false end)

DownBtn.MouseButton1Down:Connect(function() downPressed = true end)
DownBtn.MouseButton1Up:Connect(function() downPressed = false end)

local function startFlying()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    hum.PlatformStand = true

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        if not isFlying or not root then return end
        
        local camCF = workspace.CurrentCamera.CFrame
        local moveDir = hum.MoveDirection
        
        local vel = Vector3.zero
        
        if moveDir.Magnitude > 0 then
            vel = camCF:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z)) * flySpeed
        end
        
        if upPressed then
            vel = vel + Vector3.new(0, flySpeed, 0)
        elseif downPressed then
            vel = vel - Vector3.new(0, flySpeed, 0)
        end
        
        bodyVel.Velocity = vel
        bodyGyro.CFrame = camCF
    end)
end

local function stopFlying()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if bodyVel then bodyVel:Destroy() bodyVel = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    ToggleBtn.Text = isFlying and "ON" or "OFF"
    
    if isFlying then
        startFlying()
    else
        stopFlying()
    end
end)
