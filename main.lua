-- [[ minihack gui v32 — slider + fixes ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local p = Players.LocalPlayer

-- Safety: wait for player object
if not p then
    repeat task.wait() until Players.LocalPlayer
    p = Players.LocalPlayer
end

-- Удаление старых версий
if game.CoreGui:FindFirstChild("minihack") then
    game.CoreGui.minihack:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "minihack"
sg.Parent = game.CoreGui

-- ГЛАВНОЕ ОКНО
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 380, 0, 320)
frame.Position = UDim2.new(0.5, -190, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true

local header = Instance.new("TextLabel", frame)
header.Size = UDim2.new(1, 0, 0, 35)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
header.Text = "  minihack gui v32"
header.TextColor3 = Color3.new(1,1,1)
header.Font = Enum.Font.SourceSansBold
header.TextSize = 18
header.TextXAlignment = Enum.TextXAlignment.Left

local container = Instance.new("ScrollingFrame", frame)
container.Size = UDim2.new(1, -10, 1, -45)
container.Position = UDim2.new(0, 5, 0, 40)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0,0,1.5,0)
container.ScrollBarThickness = 6
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ПЕРЕМЕННЫЕ
local flyOn, ffOn = false, false
local flySpeed = 80 -- default
local bv -- BodyVelocity reference
local flyConn -- Heartbeat connection
local originalLighting = {
    Brightness = Lighting and Lighting.Brightness or 1
}

-- Вспомогательные функции
local function getHRP()
    if p and p.Character then
        return p.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function enableFly()
    if flyConn then return end
    local hrp = getHRP()
    if not hrp then return end

    if bv and bv.Parent ~= hrp then
        bv:Destroy()
        bv = nil
    end

    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5) * 10
        bv.P = 1250
        bv.Parent = hrp
    end

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyOn or not hrp or not hrp.Parent then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        local direction = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end

        if direction.Magnitude > 0 then
            bv.Velocity = direction.Unit * flySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end

        -- Выравнивание взгляда по камере
        if cam and hrp and hrp.Parent then
            local look = cam.CFrame.LookVector
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + look)
        end
    end)
end

local function disableFly()
    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
    if bv then
        bv:Destroy()
        bv = nil
    end
end

-- FLING: аккуратный режим
local function runSmartFling()
    local hrp = getHRP()
    if not hrp then return end

    local foundEnemy = false
    for _, other in pairs(Players:GetPlayers()) do
        if other ~= p and other.Character and other.Character:FindFirstChild("HumanoidRootPart") and other.Character:FindFirstChildOfClass("Humanoid") then
            local otherHRP = other.Character.HumanoidRootPart
            local dist = (hrp.Position - otherHRP.Position).Magnitude
            if dist < 15 then
                foundEnemy = true
                break
            end
        end
    end

    if foundEnemy then
        -- контролируемое подбрасывание
        hrp.Velocity = hrp.Velocity + Vector3.new(0, 200, 0)
        hrp.RotVelocity = Vector3.new(0, 20, 0)
        for _, part in pairs(p.Character:GetChildren()) do
            if part:IsA("BasePart") and part ~= hrp then
                part.CanCollide = false
            end
        end
    else
        hrp.RotVelocity = Vector3.new(0, 0, 0)
    end
end

RunService.Stepped:Connect(function()
    if ffOn and p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        runSmartFling()
    end
end)

-- ФУНКЦИЯ СОЗДАНИЯ КНОПОК
local function addBtn(txt, cb)
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(0.98, 0, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = txt
    b.Font = Enum.Font.SourceSans
    b.TextSize = 16
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    b.MouseButton1Click:Connect(cb)
    return b
end

-- ФУНКЦИЯ СОЗДАНИЯ ПОЛЗУНКА
local function addSlider(labelText, min, max, default, onChange)
    local wrapper = Instance.new("Frame", container)
    wrapper.Size = UDim2.new(0.98, 0, 0, 56)
    wrapper.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", wrapper)
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", wrapper)
    valueLabel.Size = UDim2.new(0.4, -6, 0, 20)
    valueLabel.Position = UDim2.new(0.6, 6, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.new(1,1,1)
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- Slider bar (TextButton to receive clicks)
    local bar = Instance.new("TextButton", wrapper)
    bar.Size = UDim2.new(1, 0, 0, 18)
    bar.Position = UDim2.new(0, 0, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    bar.AutoButtonColor = false
    bar.Text = ""
    bar.BorderSizePixel = 0

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new( (default - min) / math.max(1, (max - min)), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    fill.BorderSizePixel = 0

    local knob = Instance.new("ImageButton", bar)
    knob.Size = UDim2.new(0, 12, 0, 18)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0, 0)
    knob.BackgroundTransparency = 1
    knob.Image = ""
    knob.AutoButtonColor = false

    local dragging = false

    local function setFromRelative(rel)
        rel = math.clamp(rel, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0, 0)
        local value = math.floor(min + rel * (max - min) + 0.5)
        valueLabel.Text = tostring(value)
        if onChange then
            onChange(value)
        end
    end

    -- Click on bar to set value
    bar.MouseButton1Down:Connect(function(x, y)
        local absPos = bar.AbsolutePosition
        local absSize = bar.AbsoluteSize
        local rel = (x - absPos.X) / absSize.X
        setFromRelative(rel)
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local barPos = bar.AbsolutePosition.X
            local barSize = bar.AbsoluteSize.X
            local rel = (mouseX - barPos) / math.max(1, barSize)
            setFromRelative(rel)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- initialize
    setFromRelative((default - min) / math.max(1, (max - min)))

    return wrapper
end

-- КНОПКИ И ПОЛЗУНОК
addSlider("Fly Speed", 10, 300, flySpeed, function(value)
    flySpeed = value
end)

addBtn("Fly (Fix: W/A/S/D/Space/Ctrl)", function()
    flyOn = not flyOn
    if flyOn then
        enableFly()
    else
        disableFly()
    end
end)

addBtn("FLY-FLING (Smart Attack)", function()
    ffOn = not ffOn
end)

addBtn("Full Bright (Toggle)", function()
    if Lighting.Brightness ~= 2 then
        Lighting.Brightness = 2
    else
        Lighting.Brightness = originalLighting.Brightness or 1
    end
end)

addBtn("Rejoin", function()
    if p then
        TeleportService:Teleport(game.PlaceId, p)
    end
end)

-- КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ (ВСЕГДА ВИДНА)
local openBtn = Instance.new("TextButton", sg)
openBtn.Size = UDim2.new(0, 80, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
openBtn.Text = "minihack"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.SourceSansBold
openBtn.Parent = sg
openBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Обработка респавна: чистка ресурсов и восстановление связей
p.CharacterAdded:Connect(function()
    task.wait(0.1)
    if flyOn then
        disableFly()
        enableFly()
    end
end)

p.CharacterRemoving:Connect(function()
    if bv then
        bv:Destroy()
        bv = nil
    end
end)

-- Очистка при удалении GUI
sg.AncestryChanged:Connect(function()
    if not sg:IsDescendantOf(game) then
        disableFly()
    end
end)
