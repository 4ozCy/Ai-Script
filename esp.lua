local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))()

local Notify = AkaliNotif.Notify

Notify({
    Description = "Thanks for using our script.",
    Title = "Welcome To Ai-Script",
    Duration = 5
})

local settings = {
    defaultcolor = Color3.fromRGB(255, 255, 255),
    teamcheck = false,
    teamcolor = true,
    espEnabled = true,
    cornerLength = 8
}

local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local userInputService = game:GetService("UserInputService")
local newVector2, newColor3, newDrawing = Vector2.new, Color3.new, Drawing and Drawing.new or function() error("Drawing API not supported") end
local tan, rad = math.tan, math.rad

local round = function(...)
    local a = {}
    for i, v in next, table.pack(...) do
        a[i] = math.round(v)
    end
    return unpack(a)
end

local wtvp = function(...)
    local a, b = camera.WorldToViewportPoint(camera, ...)
    return newVector2(a.X, a.Y), b, a.Z
end

local function getRoot(part)
    return part:IsA("Model") and part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart") or part
end

local espCache = {}

local function createEsp(player)
    if espCache[player] then return end

    local success, drawings = pcall(function()
        local d = {}

        d.topLeftHorizontal = newDrawing("Line")
        d.topLeftHorizontal.Thickness = 1.5
        d.topLeftHorizontal.Color = settings.defaultcolor
        d.topLeftHorizontal.Visible = false

        d.topLeftVertical = newDrawing("Line")
        d.topLeftVertical.Thickness = 1.5
        d.topLeftVertical.Color = settings.defaultcolor
        d.topLeftVertical.Visible = false

        d.topRightHorizontal = newDrawing("Line")
        d.topRightHorizontal.Thickness = 1.5
        d.topRightHorizontal.Color = settings.defaultcolor
        d.topRightHorizontal.Visible = false

        d.topRightVertical = newDrawing("Line")
        d.topRightVertical.Thickness = 1.5
        d.topRightVertical.Color = settings.defaultcolor
        d.topRightVertical.Visible = false

        d.bottomLeftHorizontal = newDrawing("Line")
        d.bottomLeftHorizontal.Thickness = 1.5
        d.bottomLeftHorizontal.Color = settings.defaultcolor
        d.bottomLeftHorizontal.Visible = false

        d.bottomLeftVertical = newDrawing("Line")
        d.bottomLeftVertical.Thickness = 1.5
        d.bottomLeftVertical.Color = settings.defaultcolor
        d.bottomLeftVertical.Visible = false

        d.bottomRightHorizontal = newDrawing("Line")
        d.bottomRightHorizontal.Thickness = 1.5
        d.bottomRightHorizontal.Color = settings.defaultcolor
        d.bottomRightHorizontal.Visible = false

        d.bottomRightVertical = newDrawing("Line")
        d.bottomRightVertical.Thickness = 1.5
        d.bottomRightVertical.Color = settings.defaultcolor
        d.bottomRightVertical.Visible = false

        d.healthbar = newDrawing("Square")
        d.healthbar.Thickness = 1
        d.healthbar.Filled = true
        d.healthbar.Color = Color3.new(0, 1, 0)
        d.healthbar.Visible = false

        d.distance = newDrawing("Text")
        d.distance.Size = 16
        d.distance.Center = true
        d.distance.Color = Color3.new(1, 1, 1)
        d.distance.Visible = false
        d.distance.Font = Drawing and Drawing.Fonts and Drawing.Fonts.UI or 3

        d.username = newDrawing("Text")
        d.username.Size = 16
        d.username.Center = true
        d.username.Color = Color3.new(1, 1, 1)
        d.username.Visible = false
        d.username.Font = Drawing and Drawing.Fonts and Drawing.Fonts.UI or 3

        d.healthPercent = newDrawing("Text")
        d.healthPercent.Size = 16
        d.healthPercent.Center = true
        d.healthPercent.Color = Color3.new(1, 1, 1)
        d.healthPercent.Visible = false
        d.healthPercent.Font = Drawing and Drawing.Fonts and Drawing.Fonts.UI or 3

        return d
    end)

    if success then
        espCache[player] = drawings
    else
        Notify({
            Description = "failed to create esp for" ..tostring(player.Name),
            Title = "Error",
            Duration = 5
        })
    end
end

local function removeEsp(player)
    if rawget(espCache, player) then
        for _, drawing in next, espCache[player] do
            pcall(function()
                drawing.Visible = false
                drawing:Remove()
            end)
        end
        espCache[player] = nil
    end
end

local MAX_ESP_DISTANCE = 100000

local function updateEsp(player, esp)
    local success, err = pcall(function()
        local character = player and player.Character

        if not (character and settings.espEnabled) then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            return
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")

        if not (rootPart and humanoid and humanoid.Health > 0) then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            return
        end

        if settings.teamcheck and player.Team and localPlayer.Team and player.Team == localPlayer.Team then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            return
        end

        local lpChar = localPlayer.Character
        local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
        local distance = lpRoot and (rootPart.Position - lpRoot.Position).Magnitude or math.huge

        if distance > MAX_ESP_DISTANCE then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            return
        end

        local cframe = rootPart.CFrame
        local position, visible, depth = wtvp(cframe.Position)

        esp.topLeftHorizontal.Visible = visible
        esp.topLeftVertical.Visible = visible
        esp.topRightHorizontal.Visible = visible
        esp.topRightVertical.Visible = visible
        esp.bottomLeftHorizontal.Visible = visible
        esp.bottomLeftVertical.Visible = visible
        esp.bottomRightHorizontal.Visible = visible
        esp.bottomRightVertical.Visible = visible
        esp.healthbar.Visible = visible
        esp.distance.Visible = visible
        esp.username.Visible = visible
        esp.healthPercent.Visible = visible

        if visible then
            local scaleFactor = 1 / (depth * tan(rad(camera.FieldOfView / 2)) * 2) * 1000
            local width, height = round(3 * scaleFactor, 5 * scaleFactor)
            local x, y = round(position.X, position.Y)
            local boxX = round(x - width / 2)
            local boxY = round(y - height / 2)
            local color = settings.teamcolor and player.TeamColor and player.TeamColor.Color or settings.defaultcolor
            local cornerLen = settings.cornerLength

            esp.topLeftHorizontal.From = newVector2(boxX, boxY)
            esp.topLeftHorizontal.To = newVector2(boxX + cornerLen, boxY)
            esp.topLeftHorizontal.Color = color

            esp.topLeftVertical.From = newVector2(boxX, boxY)
            esp.topLeftVertical.To = newVector2(boxX, boxY + cornerLen)
            esp.topLeftVertical.Color = color

            esp.topRightHorizontal.From = newVector2(boxX + width, boxY)
            esp.topRightHorizontal.To = newVector2(boxX + width - cornerLen, boxY)
            esp.topRightHorizontal.Color = color

            esp.topRightVertical.From = newVector2(boxX + width, boxY)
            esp.topRightVertical.To = newVector2(boxX + width, boxY + cornerLen)
            esp.topRightVertical.Color = color

            esp.bottomLeftHorizontal.From = newVector2(boxX, boxY + height)
            esp.bottomLeftHorizontal.To = newVector2(boxX + cornerLen, boxY + height)
            esp.bottomLeftHorizontal.Color = color

            esp.bottomLeftVertical.From = newVector2(boxX, boxY + height)
            esp.bottomLeftVertical.To = newVector2(boxX, boxY + height - cornerLen)
            esp.bottomLeftVertical.Color = color

            esp.bottomRightHorizontal.From = newVector2(boxX + width, boxY + height)
            esp.bottomRightHorizontal.To = newVector2(boxX + width - cornerLen, boxY + height)
            esp.bottomRightHorizontal.Color = color

            esp.bottomRightVertical.From = newVector2(boxX + width, boxY + height)
            esp.bottomRightVertical.To = newVector2(boxX + width, boxY + height - cornerLen)
            esp.bottomRightVertical.Color = color

            local roundedHealth = math.floor(humanoid.Health + 0.5)
            local healthPercent = humanoid.MaxHealth > 0 and roundedHealth / humanoid.MaxHealth or 0

            esp.healthbar.Color = Color3.new(1 - healthPercent, healthPercent, 0)
            esp.healthbar.Size = newVector2(2, height * healthPercent)
            esp.healthbar.Position = newVector2(boxX - 6, boxY + (height * (1 - healthPercent)))

            local pos = math.floor(distance)
            esp.distance.Text = string.format("%d M", pos)
            esp.distance.Position = newVector2(boxX + width / 2, boxY + height + 2)

            esp.username.Text = player.DisplayName .. " | " .. player.Name
            esp.username.Position = newVector2(boxX + width / 2, boxY - 20)

            esp.healthPercent.Text = string.format("%.0f%%", healthPercent * 100)
            esp.healthPercent.Position = esp.healthbar.Position - newVector2(24, 0)
        end
    end)

    if not success then
        for _, drawing in pairs(esp) do
            pcall(function() drawing.Visible = false end)
        end
    end
end

for _, player in next, players:GetPlayers() do
    if player ~= localPlayer then
        createEsp(player)
    end
end

players.PlayerAdded:Connect(function(player)
    createEsp(player)
end)

players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

runService.Heartbeat:Connect(function()
    if not settings.espEnabled then
        for _, drawings in pairs(espCache) do
            for _, drawing in pairs(drawings) do
                pcall(function() drawing.Visible = false end)
            end
        end
        return
    end

    for player, drawings in pairs(espCache) do
        if player ~= localPlayer then
            updateEsp(player, drawings)
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 50, 0, 50)
MainFrame.Position = UDim2.new(0.9, 0, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 10
MainFrame.Active = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 255, 150)
UIStroke.Thickness = 2

local ToggleButton = Instance.new("TextButton", MainFrame)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Position = UDim2.new(0, 0, 0, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = ""
ToggleButton.ZIndex = 11

local InnerCircle = Instance.new("Frame", MainFrame)
InnerCircle.Size = UDim2.new(0, 30, 0, 30)
InnerCircle.Position = UDim2.new(0.5, -15, 0.5, -15)
InnerCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
InnerCircle.BorderSizePixel = 0
InnerCircle.ZIndex = 11

local InnerCorner = Instance.new("UICorner", InnerCircle)
InnerCorner.CornerRadius = UDim.new(1, 0)

local UIGradient = Instance.new("UIGradient", InnerCircle)
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 100))
}
UIGradient.Rotation = 45

local Checkmark = Instance.new("TextLabel", InnerCircle)
Checkmark.Size = UDim2.new(0.8, 0, 0.8, 0)
Checkmark.Position = UDim2.new(0.1, 0, 0.1, 0)
Checkmark.BackgroundTransparency = 1

Checkmark.TextScaled = true
Checkmark.Font = Enum.Font.GothamBold
Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
Checkmark.ZIndex = 12
local isDragging = true
local dragInput, mousePos, framePos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

userInputService.InputChanged:Connect(function(input)
    if input == dragInput and isDragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale, framePos.X.Offset + delta.X,
            framePos.Y.Scale, framePos.Y.Offset + delta.Y
        )
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    settings.espEnabled = not settings.espEnabled

    if settings.espEnabled then
        InnerCircle.Visible = true
        UIStroke.Color = Color3.fromRGB(0, 255, 150)
    else
        InnerCircle.Visible = false
        UIStroke.Color = Color3.fromRGB(255, 50, 50)
    end
end)

local executor = (syn and "Synapse") or (Krnl and "KRNL") or (identifyexecutor and identifyexecutor()) or "Unknown"

Notify({
    Description = "You're using " ..executor,
    Title = "Executor Detected",
    Duration = 5
})

local function cleanup()
    pcall(function()
        runService:UnbindFromRenderStep("esp")
        for player, drawings in pairs(espCache) do
            removeEsp(player)
        end
        ScreenGui:Destroy()
    end)
end
