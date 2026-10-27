
```lua
-- ==========================================
-- ROBLOX CUSTOM COLOR ESP - DELTA READY (FINAL)
-- Версия: 1.1 (С Drag & Drop)
-- Совместимость: Delta Executor (Roblox)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- ==========================================
-- 1. КОНФИГУРАЦИЯ
-- ==========================================

-- Цвета ESP
local ESP_COLORS = {
    ["Red"] = Color3.fromRGB(255, 0, 0),
    ["Green"] = Color3.fromRGB(0, 255, 0),
    ["Blue"] = Color3.fromRGB(0, 100, 255),
    ["Yellow"] = Color3.fromRGB(255, 255, 0),
    ["Purple"] = Color3.fromRGB(160, 0, 255),
    ["Neon Pink"] = Color3.fromRGB(255, 0, 255),
    ["Cyan"] = Color3.fromRGB(0, 255, 255),
    ["White"] = Color3.fromRGB(255, 255, 255),
    ["Orange"] = Color3.fromRGB(255, 165, 0),
    ["Black"] = Color3.fromRGB(20, 20, 20)
}

-- Настройки меню
local MENU_CONFIG = {
    Title = "Custom ESP Menu",
    Width = 280,
    Height = 400,
    Position = UDim2.new(0.5, -140, 0.5, -200), -- Центр экрана
    ToggleKey = Enum.KeyCode.F9
}

-- Состояние читов
local ESP_STATE = {
    Enabled = false,
    CurrentColorName = "Red",
    MenuVisible = true, -- Меню открыто при старте
    HighlightObjects = {} -- Хранит ссылки на Highlight объекты
}

-- ==========================================
-- 2. ЛОГИКА ESP
-- ==========================================

--- Применяет текущие настройки цвета к объекту Highlight
local function apply_color_to_highlight(highlight)
    if not highlight then return end
    
    local color = ESP_COLORS[ESP_STATE.CurrentColorName] or ESP_COLORS["Red"]
    
    -- Настройки заполнения (тело)
    highlight.FillTransparency = 0.7 -- Прозрачность тела (чем выше, тем прозрачнее)
    highlight.FillColor = color
    
    -- Настройки рамки (Outline)
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.OutlineWidth = 3 -- Толщина рамки
    
    -- Режим отображения
    highlight.HighlightRadius = 0 -- Видит всех, независимо от расстояния
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

--- Создает или обновляет подсветку для игрока
local function setup_player_esp(player)
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- Если уже есть подсветка, удаляем старую
    if ESP_STATE.HighlightObjects[player] then
        ESP_STATE.HighlightObjects[player]:Destroy()
        ESP_STATE.HighlightObjects[player] = nil
    end
    
    if ESP_STATE.Enabled then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_" .. player.Name
        highlight.Adornee = character
        highlight.Parent = character
        
        -- Применяем текущий цвет
        apply_color_to_highlight(highlight)
        
        -- Сохраняем ссылку
        ESP_STATE.HighlightObjects[player] = highlight
    end
end

--- Обновляет все существующие подсветки (при смене цвета)
local function update_all_highlights()
    for player, highlight in pairs(ESP_STATE.HighlightObjects) do
        if highlight and highlight.Parent then
            apply_color_to_highlight(highlight)
        else
            -- Если персонаж умер/удалился, чистим таблицу
            ESP_STATE.HighlightObjects[player] = nil
        end
    end
end

--- Слушатель появления нового игрока
Players.PlayerAdded:Connect(function(player)
    -- Ждем загрузки персонажа
    player.CharacterAdded:Connect(function(character)
        setup_player_esp(player)
    end)
    
    -- Если персонаж уже загружен (редкий кейс, но бывает)
    if player.Character then
        setup_player_esp(player)
    end
end)

--- Инициализация для уже существующих игроков
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        setup_player_esp(player)
    end
end

-- ==========================================
-- 3. МЕНЮ UI + DRAG FUNCTIONALITY
-- ==========================================

-- Создаем Frame основного окна
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Menu_ScreenGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000
ScreenGui.IgnoreGuiInset = true

-- Убедимся, что GUI не конфликтует с другими
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "ESP_MainFrame"
MainFrame.Size = UDim2.new(0, MENU_CONFIG.Width, 0, MENU_CONFIG.Height)
MainFrame.Position = MENU_CONFIG.Position
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Заголовок (за него будем таскать)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = MENU_CONFIG.Title
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.Parent = Header

-- Кнопка закрытия (крестик)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    ESP_STATE.MenuVisible = not ESP_STATE.MenuVisible
    MainFrame.Visible = ESP_STATE.MenuVisible
end)

-- Область контента (скролл)
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -10, 1, -50)
ContentFrame.Position = UDim2.new(0, 5, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ContentFrame.Parent = MainFrame

-- Контейнер для элементов внутри меню
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, 0, 0, 0)
Container.BackgroundTransparency = 1
Container.Parent = ContentFrame

-- Helper: Создать кнопку
local function create_button(text, callback, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. text
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = Container
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- Helper: Создать Label
local function create_label(text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Lbl_" .. text
    lbl.Size = UDim2.new(1, -10, 0, 25)
    lbl.Position = UDim2.new(0, 5, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Parent = Container
    return lbl
end

-- ==========================================
-- 4. СОДЕРЖИМОЕ МЕНЮ
-- ==========================================

local current_y = 0

-- 1. Кнопка ВКЛ/ВЫКЛ
local toggle_btn = create_button("ESP: OFF", function()
    ESP_STATE.Enabled = not ESP_STATE.Enabled
    
    if ESP_STATE.Enabled then
        toggle_btn.Text = "ESP: ON"
        toggle_btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        -- Активируем для всех текущих игроков
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                setup_player_esp(player)
            end
        end
    else
        toggle_btn.Text = "ESP: OFF"
        toggle_btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        
        -- Удаляем все подсветки
        for player, highlight in pairs(ESP_STATE.HighlightObjects) do
            if highlight then
                highlight:Destroy()
            end
        end
        table.clear(ESP_STATE.HighlightObjects)
    end
end, current_y)
current_y = current_y + 45

-- Разделитель
local separator = Instance.new("Frame")
separator.Name = "Separator"
separator.Size = UDim2.new(1, -20, 0, 2)
separator.Position = UDim2.new(0, 10, 0, current_y)
separator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
separator.Parent = Container
current_y = current_y + 10

-- 2. Выбор цвета (Заголовок)
create_label("Select Color:", current_y)
current_y = current_y + 30

-- Список цветов
for color_name, color_obj in pairs(ESP_COLORS) do
    local btn = create_button(color_name, function()
        ESP_STATE.CurrentColorName = color_name
        
        -- Обновляем UI: подсвечиваем выбранный цвет
        -- (Упрощенно: просто меняем текст кнопки на жирный, 
        -- а остальные делаем обычными. Для простоты оставим так.)
        
        -- Обновляем все активные ESP
        update_all_highlights()
    end, current_y)
    
    -- Подсветка активной кнопки цветом
    if color_name == ESP_STATE.CurrentColorName then
        btn.BackgroundColor3 = color_obj
        btn.TextColor3 = (color_name == "Black" or color_name == "Blue") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
    end
    
    current_y = current_y + 45
end

-- Устанавливаем высоту контейнера под контент
Container.Size = UDim2.new(1, 0, 0, current_y)

-- Обновление размеров скролла
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, current_y)

-- ==========================================
-- 5. DRAG FUNCTIONALITY (ПЕРЕТАСКИВАНИЕ МЕНЮ)
-- ==========================================

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- ==========================================
-- 6. ОБРАБОТКА СОБЫТИЙ И ЗАПУСК
-- ==========================================

-- Горячая клавиша F9 для открытия/закрытия меню
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == MENU_CONFIG.ToggleKey then
        ESP_STATE.MenuVisible = not ESP_STATE.MenuVisible
        MainFrame.Visible = ESP_STATE.MenuVisible
    end
end)

print("✅ Custom ESP Loaded Successfully!")
print("🎮 Use F9 to toggle menu.")
print("🖱️ Drag the header to move the window.")
print("🎨 Select a color to change ESP style.")
```