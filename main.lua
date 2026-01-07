-- [[ minihack gui v31 ]]
local p = game.Players.LocalPlayer
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")

if game.CoreGui:FindFirstChild("minihack") then game.CoreGui.minihack:Destroy() end

local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "minihack"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true

local header = Instance.new("TextLabel", frame)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
header.Text = "  minihack gui v31"
header.TextColor3 = Color3.new(1,1,1)
header.Font = Enum.Font.SourceSansBold
header.TextSize = 16
header.TextXAlignment = Enum.TextXAlignment.Left

local container = Instance.new("ScrollingFrame", frame)
container.Size = UDim2.new(1, -20, 1, -45)
container.Position = UDim2.new(0, 10, 0, 35)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 2
Instance.new("UIListLayout", container).Padding = UDim.new(0, 5)

local flyOn, ffOn = false, false
local flySpeed = 70

run.Heartbeat:Connect(function()
    if ffOn and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = p.Character.HumanoidRootPart
        hrp.Velocity = Vector3.new(1000, 1000, 1000)
        hrp.RotVelocity = Vector3.new(0, 1000000, 0)
        for _, v in pairs(p.Character:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

local function addBtn(txt, cb)
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(cb)
end

addBtn("Fly Mode (W/S/Space/Ctrl)", function()
    flyOn = not flyOn
    if flyOn then
        local bv = Instance.new("BodyVelocity", p.Character.HumanoidRootPart)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        spawn(function()
            while flyOn do
                local cam = workspace.CurrentCamera
                local d = Vector3.zero
                if uis:IsKeyDown("W") then d = d + cam.CFrame.LookVector end
                if uis:IsKeyDown("S") then d = d - cam.CFrame.LookVector end
                if uis:IsKeyDown("Space") then d = d + Vector3.new(0, 1, 0) end
                if uis:IsKeyDown("LeftControl") then d = d - Vector3.new(0, 1, 0) end
                bv.Velocity = d * flySpeed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

addBtn("FLY-FLING (Kill All)", function() ffOn = not ffOn end)
addBtn("Full Bright", function() game.Lighting.Brightness = 2 game.Lighting.GlobalShadows = false end)
addBtn("Rejoin", function() game:GetService("TeleportService"):Teleport(game.PlaceId, p) end)

print("minihack gui v31 LOADED")
