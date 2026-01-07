-- [[ minihack gui v32 ]]
local p = game.Players.LocalPlayer
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Удаление старых версий
if game.CoreGui:FindFirstChild("minihack") then game.CoreGui.minihack:Destroy() end

local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "minihack"

-- ГЛАВНОЕ ОКНО
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 380, 0, 280)
frame.Position = UDim2.new(0.5, -190, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true -- Включено для удобства

local header = Instance.new("TextLabel", frame)
header.Size = UDim2.new(1, 0, 0, 35)
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
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 5)

-- ПЕРЕМЕННЫЕ
local flyOn, ffOn = false, false
local flySpeed = 80

-- УМНЫЙ FLY-FLING (Включается только рядом с врагом, чтобы не кикало)
run.Stepped:Connect(function()
    if ffOn and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = p.Character.HumanoidRootPart
        local foundEnemy = false
        
        -- Проверка дистанции до ближайшего игрока
        for _, other in pairs(game.Players:GetPlayers()) do
            if other ~= p and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - other.Character.HumanoidRootPart.Position).Magnitude
                if dist < 15 then foundEnemy = true break end
            end
        end

        if foundEnemy then
            hrp.Velocity = Vector3.new(0, 5000, 0) -- Подброс для сервера
            hrp.RotVelocity = Vector3.new(0, 1000000, 0) -- Убийственное вращение
        else
            hrp.RotVelocity = Vector3.new(0, 0, 0) -- Спокойствие, если никого нет
        end

        for _, v in pairs(p.Character:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- ФУНКЦИЯ СОЗДАНИЯ КНОПОК
local function addBtn(txt, cb)
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(0.95, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = txt
    b.Font = Enum.Font.SourceSans
    b.TextSize = 16
    b.MouseButton1Click:Connect(cb)
    return b
end

-- КНОПКИ
addBtn("Fly (Fix: W/S/Space/Ctrl)", function()
    flyOn = not flyOn
    if flyOn and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = p.Character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        task.spawn(function()
            while flyOn and hrp.Parent do
                local cam = workspace.CurrentCamera
                local d = Vector3.new(0,0,0)
                -- Используем Enum.KeyCode как советовали в логах ошибок
                if uis:IsKeyDown(Enum.KeyCode.W) then d = d + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then d = d - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0, 1, 0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftControl) then d = d - Vector3.new(0, 1, 0) end
                bv.Velocity = d * flySpeed
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
                task.wait()
            end
            if bv then bv:Destroy() end
        end)
    end
end)

addBtn("FLY-FLING (Smart Attack)", function() ffOn = not ffOn end)
addBtn("Full Bright", function() game:GetService("Lighting").Brightness = 2 end) -- Исправлено на GetService
addBtn("Rejoin", function() game:GetService("TeleportService"):Teleport(game.PlaceId, p) end)

-- КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ (ВСЕГДА ВИДНА)
local openBtn = Instance.new("TextButton", sg)
openBtn.Size = UDim2.new(0, 80, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
openBtn.Text = "minihack"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.SourceSansBold
openBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)
