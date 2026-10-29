-- Загружаем библиотеку интерфейса Orion
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

-- Создаем главное окно
local Window = OrionLib:MakeWindow({
    Name = "Rake Hub | v0.1 test", 
    HidePremium = false, 
    SaveConfig = true,             
    ConfigFolder = "RakeHubConfig" 
})

-- ==========================================================
-- СОЗДАНИЕ КНОПКИ-ИКОНКИ С ТВОИМ ЛИЦОМ
-- ==========================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Получаем ссылку на аватарку твоей головы (Headshot) в высоком разрешении
local userId = LocalPlayer.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size150x150
local avatarUrl, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

-- Создаем экранный контейнер для кнопки
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "RakeHubToggleButton"
ToggleGui.Parent = CoreGui
ToggleGui.ResetOnSpawn = false

-- Создаем саму круглую кнопку
local ImageButton = Instance.new("ImageButton")
ImageButton.Name = "UserAvatarIcon"
ImageButton.Parent = ToggleGui
ImageButton.Size = UDim2.new(0, 65, 0, 65) -- Размер кнопки на экране
ImageButton.Position = UDim2.new(0, 15, 0, 15) -- Стартовая позиция (левый верхний угол)
ImageButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ImageButton.Image = avatarUrl -- Сюда вставляется твое лицо!
ImageButton.BorderSizePixel = 0

-- Делаем кнопку идеально круглой
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0) -- Полное скругление
UICorner.Parent = ImageButton

-- Добавляем красивую обводку кнопке
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 0) -- Зеленая обводка под цвет твоей банданы
UIStroke.Thickness = 2
UIStroke.Parent = ImageButton

-- Логика переключения меню (Открыть/Закрыть) при нажатии на лицо
local menuVisible = true
ImageButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    
    -- Ищем окно Orion в игре и меняем его видимость
    local orionGui = CoreGui:FindFirstChild("Orion")
    if orionGui then
        orionGui.Enabled = menuVisible
    end
end)

-- Скрипт, чтобы кнопку можно было перетаскивать по экрану пальцем/мышкой
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    ImageButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ImageButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ImageButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ImageButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- ==========================================================
-- ОСТАЛЬНОЙ НАСТРОЕННЫЙ КОД (ПЕРЕМЕННЫЕ И НАСТРОЙКИ)
-- ==========================================================
_G.WalkSpeedValue = 16
_G.HitboxSize = 2
_G.HitboxTransparency = 1
_G.Noclip = false
_G.Flying = false
_G.FlySpeed = 50

local RunService = game:GetService("RunService")

local function applyESP(object, color, nameTag)
    if not object:FindFirstChild("MyESP") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MyESP"
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.Parent = object
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Tag"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = object
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = color
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.Text = nameTag
        label.Parent = billboard
    end
end

task.spawn(function()
    while task.wait(1) do
        for _, obj in pairs(workspace:GetDescendants()) do
            if _G.RakeESP and obj:IsA("Model") and string.match(string.lower(obj.Name), "rake") and obj ~= LocalPlayer.Character then
                applyESP(obj, Color3.fromRGB(255, 0, 0), "👹 РЕЙК")
            elseif not _G.RakeESP and obj:FindFirstChild("MyESP") and string.match(string.lower(obj.Name), "rake") then
                obj.MyESP:Destroy()
                if obj:FindFirstChild("ESP_Tag") then obj.ESP_Tag:Destroy() end
            end

            if _G.NpcESP and obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) and not string.match(string.lower(obj.Name), "rake") then
                applyESP(obj, Color3.fromRGB(0, 255, 0), "👤 NPC: " .. obj.Name)
            elseif not _G.NpcESP and obj:FindFirstChild("MyESP") and obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) and not string.match(string.lower(obj.Name), "rake") then
                obj.MyESP:Destroy()
                if obj:FindFirstChild("ESP_Tag") then obj.ESP_Tag:Destroy() end
            end

            if _G.ItemESP and (obj:IsA("Tool") or obj:FindFirstChildOfClass("ClickDetector")) then
                local item = obj:IsA("Tool") and obj or obj.Parent
                if item:IsA("BasePart") or item:IsA("Model") then
                    applyESP(item, Color3.fromRGB(255, 255, 0), "📦 " .. item.Name)
                end
            end

            if obj:IsA("Model") and string.match(string.lower(obj.Name), "rake") then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if root then
                    root.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                    root.Transparency = _G.HitboxTransparency
                    root.CanCollide = false
                    root.CanTouch = false
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = _G.WalkSpeedValue
        end
    end)
end)

RunService.Stepped:Connect(function()
    pcall(function()
        if _G.Noclip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
RunService.RenderStepped:Connect(function()
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if _G.Flying and root and humanoid then
            BV.Parent = root
            local moveDir = humanoid.MoveDirection
            local velocity = moveDir * _G.FlySpeed
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, _G.FlySpeed, 0)
            end
            BV.Velocity = velocity == Vector3.new(0,0,0) and Vector3.new(0,0.1,0) or velocity
        else
            BV.Parent = nil
        end
    end)
end)

-- СОЗДАНИЕ ТВОИХ ВКЛАДОК
local Tab1 = Window:MakeTab({Name = "1) ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})
Tab1:AddToggle({Name = "Включить ESP на Рейка", Default = false, Callback = function(Value) _G.RakeESP = Value end})
Tab1:AddToggle({Name = "Включить ESP на NPC", Default = false, Callback = function(Value) _G.NpcESP = Value end})
Tab1:AddToggle({Name = "Включить ESP на Предметы", Default = false, Callback = function(Value) _G.ItemESP = Value end})

local Tab2 = Window:MakeTab({Name = "2) Hitbox", Icon = "rbxassetid://4483345998", PremiumOnly = false})
Tab2:AddSlider({Name = "Размер хитбокса Рейка", Min = 2, Max = 30, Default = 2, Color = Color3.fromRGB(255,0,0), Increment = 1, ValueName = "размер", Callback = function(Value) _G.HitboxSize = Value end})
Tab2:AddSlider({Name = "Видимость хитбокса (прозрачность)", Min = 0, Max = 1, Default = 1, Color = Color3.fromRGB(255,255,255), Increment = 0.1, ValueName = "transparency", Callback = function(Value) _G.HitboxTransparency = Value end})

local Tab3 = Window:MakeTab({Name = "3) Just", Icon = "rbxassetid://4483345998", PremiumOnly = false})
Tab3:AddSlider({Name = "Скорость бега (Speed)", Min = 16, Max = 150, Default = 16, Color = Color3.fromRGB(0,255,0), Increment = 1, ValueName = "скорость", Callback = function(Value) _G.WalkSpeedValue = Value end})
Tab3:AddToggle({Name = "Режим полета (Fly)", Default = false, Callback = function(Value) _G.Flying = Value end})
Tab3:AddSlider({Name = "Скорость полета", Min = 10, Max = 200, Default = 50, Color = Color3.fromRGB(0,255,255), Increment = 5, ValueName = "скорость fly", Callback = function(Value) _G.FlySpeed = Value end})
