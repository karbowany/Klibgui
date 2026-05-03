--[[
    KLib - Premium GUI Library v3.1 FIXED
    GitHub: https://raw.githubusercontent.com/karbowany/Klibgui/refs/heads/main/klib.lua
]]

local KLib = {}
KLib.__index = KLib

-- ===== THEMES =====
KLib.Themes = {
    Dark = {
        Primary = Color3.fromRGB(100, 149, 237),
        Secondary = Color3.fromRGB(45, 45, 48),
        Background = Color3.fromRGB(32, 32, 35),
        Surface = Color3.fromRGB(40, 40, 43),
        Text = Color3.fromRGB(230, 230, 230),
        TextDim = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(138, 43, 226),
        Success = Color3.fromRGB(34, 139, 34),
        Danger = Color3.fromRGB(220, 20, 60),
        Warning = Color3.fromRGB(255, 140, 0),
        Border = Color3.fromRGB(60, 60, 65),
    },
    
    Light = {
        Primary = Color3.fromRGB(70, 130, 200),
        Secondary = Color3.fromRGB(240, 240, 245),
        Background = Color3.fromRGB(250, 250, 252),
        Surface = Color3.fromRGB(245, 245, 250),
        Text = Color3.fromRGB(30, 30, 35),
        TextDim = Color3.fromRGB(100, 100, 110),
        Accent = Color3.fromRGB(138, 43, 226),
        Success = Color3.fromRGB(34, 139, 34),
        Danger = Color3.fromRGB(220, 20, 60),
        Warning = Color3.fromRGB(255, 140, 0),
        Border = Color3.fromRGB(200, 200, 210),
    },
    
    Discord = {
        Primary = Color3.fromRGB(88, 101, 242),
        Secondary = Color3.fromRGB(47, 49, 54),
        Background = Color3.fromRGB(54, 57, 63),
        Surface = Color3.fromRGB(40, 43, 48),
        Text = Color3.fromRGB(220, 221, 222),
        TextDim = Color3.fromRGB(160, 161, 162),
        Accent = Color3.fromRGB(88, 101, 242),
        Success = Color3.fromRGB(67, 181, 129),
        Danger = Color3.fromRGB(240, 71, 71),
        Warning = Color3.fromRGB(250, 160, 50),
        Border = Color3.fromRGB(72, 76, 84),
    },
    
    Nord = {
        Primary = Color3.fromRGB(136, 192, 208),
        Secondary = Color3.fromRGB(46, 52, 64),
        Background = Color3.fromRGB(36, 41, 51),
        Surface = Color3.fromRGB(43, 48, 59),
        Text = Color3.fromRGB(236, 239, 244),
        TextDim = Color3.fromRGB(216, 222, 233),
        Accent = Color3.fromRGB(191, 97, 106),
        Success = Color3.fromRGB(163, 190, 140),
        Danger = Color3.fromRGB(191, 97, 106),
        Warning = Color3.fromRGB(235, 203, 139),
        Border = Color3.fromRGB(76, 86, 106),
    },

    Dracula = {
        Primary = Color3.fromRGB(189, 147, 249),
        Secondary = Color3.fromRGB(40, 42, 54),
        Background = Color3.fromRGB(33, 34, 44),
        Surface = Color3.fromRGB(45, 48, 59),
        Text = Color3.fromRGB(248, 248, 242),
        TextDim = Color3.fromRGB(98, 114, 164),
        Accent = Color3.fromRGB(255, 121, 198),
        Success = Color3.fromRGB(80, 250, 123),
        Danger = Color3.fromRGB(255, 85, 85),
        Warning = Color3.fromRGB(241, 250, 140),
        Border = Color3.fromRGB(68, 71, 90),
    },
}

-- ===== CONFIG =====
KLib.Config = {
    Theme = "Dark",
    ShowWatermark = true,
    WatermarkText = "KLib",
    WindowCornerRadius = 12,
    ElementCornerRadius = 8,
    AnimationSpeed = 0.2,
    ScrollBarThickness = 6,
}

-- ===== SAFE UTILITY FUNCTIONS =====
local function CreateInstance(className, properties)
    local ok, result = pcall(function()
        local instance = Instance.new(className)
        if properties then
            for prop, value in pairs(properties) do
                pcall(function()
                    instance[prop] = value
                end)
            end
        end
        return instance
    end)
    if ok then
        return result
    else
        print("[KLib Error] Nie można stworzyć " .. className)
        return nil
    end
end

local function AddCorner(gui, radius)
    if not gui then return nil end
    local corner = CreateInstance("UICorner")
    if corner then
        corner.CornerRadius = UDim.new(0, radius or 8)
        corner.Parent = gui
    end
    return corner
end

local function AddStroke(gui, color, thickness, transparency)
    if not gui then return nil end
    local stroke = CreateInstance("UIStroke")
    if stroke then
        stroke.Color = color or Color3.fromRGB(100, 149, 237)
        stroke.Thickness = thickness or 1
        stroke.Transparency = transparency or 0.5
        stroke.Parent = gui
    end
    return stroke
end

local function Tween(object, tweenInfo, properties)
    if not object then return nil end
    
    local tweenService = game:GetService("TweenService")
    if not tweenService then return nil end
    
    local ok, tween = pcall(function()
        return tweenService:Create(object, tweenInfo, properties)
    end)
    
    if ok and tween then
        tween:Play()
        return tween
    end
    return nil
end

local function GetTheme()
    local themeName = KLib.Config.Theme or "Dark"
    return KLib.Themes[themeName] or KLib.Themes.Dark
end

-- ===== WATERMARK =====
local function CreateWatermark(screenGui)
    if not KLib.Config.ShowWatermark then return end
    if not screenGui then return end
    
    local theme = GetTheme()
    
    local watermark = CreateInstance("TextLabel")
    if not watermark then return end
    
    watermark.Name = "Watermark"
    watermark.Parent = screenGui
    watermark.BackgroundTransparency = 0.1
    watermark.BackgroundColor3 = theme.Surface
    watermark.BorderSizePixel = 0
    watermark.Size = UDim2.new(0, 150, 0, 25)
    watermark.Position = UDim2.new(1, -160, 0, 10)
    watermark.TextColor3 = theme.Primary
    watermark.TextSize = 12
    watermark.Font = Enum.Font.GothamBold
    watermark.Text = "✦ " .. KLib.Config.WatermarkText
    watermark.TextXAlignment = Enum.TextXAlignment.Center
    watermark.TextYAlignment = Enum.TextYAlignment.Center
    watermark.ZIndex = 1000
    
    AddCorner(watermark, 6)
    AddStroke(watermark, theme.Primary, 1, 0.7)
    
    return watermark
end

-- ===== MAIN WINDOW =====
function KLib.CreateWindow(title, options)
    title = title or "KLib Window"
    options = options or {}
    
    local windowSize = options.Size or UDim2.new(0, 550, 0, 700)
    local windowPos = options.Position or UDim2.new(0.5, -275, 0.5, -350)
    
    -- Get PlayerGui
    local playerGui = nil
    pcall(function()
        playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui", 1)
    end)
    
    if not playerGui then
        print("[KLib] Błąd: Nie można znaleźć PlayerGui")
        return nil
    end
    
    -- Screen GUI
    local screenGui = CreateInstance("ScreenGui")
    if not screenGui then return nil end
    
    screenGui.Name = "KLib_" .. tostring(title)
    screenGui.ResetOnSpawn = options.ResetOnSpawn ~= false
    screenGui.DisplayOrder = options.DisplayOrder or 10
    screenGui.Parent = playerGui
    
    -- Create Watermark
    CreateWatermark(screenGui)
    
    local theme = GetTheme()
    
    -- Main Window Frame
    local window = CreateInstance("Frame")
    if not window then return nil end
    
    window.Name = "MainWindow"
    window.Parent = screenGui
    window.BackgroundColor3 = theme.Background
    window.BorderSizePixel = 0
    window.Size = windowSize
    window.Position = windowPos
    window.Active = true
    
    AddCorner(window, KLib.Config.WindowCornerRadius)
    AddStroke(window, theme.Border, 1, 0.3)
    
    -- Shadow effect
    local shadow = CreateInstance("Frame")
    if shadow then
        shadow.Name = "Shadow"
        shadow.Parent = screenGui
        shadow.BackgroundColor3 = Color3.new(0, 0, 0)
        shadow.BorderSizePixel = 0
        shadow.Size = windowSize
        shadow.Position = windowPos + UDim2.new(0, 3, 0, 3)
        shadow.ZIndex = 0
        shadow.BackgroundTransparency = 0.8
        AddCorner(shadow, KLib.Config.WindowCornerRadius)
    end
    
    -- Drag functionality
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart = nil
    local windowStart = nil
    
    if window then
        local success = pcall(function()
            window.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart = game:GetService("Mouse").Position
                    windowStart = window.Position
                    if shadow then shadow.Position = windowStart + UDim2.new(0, 3, 0, 3) end
                end
            end)
        end)
    end
    
    pcall(function()
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end)
    
    pcall(function()
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.Mouse and window then
                local mouse = game:GetService("Mouse")
                local delta = mouse.Position - dragStart
                window.Position = windowStart + UDim2.new(0, delta.X, 0, delta.Y)
                if shadow then shadow.Position = window.Position + UDim2.new(0, 3, 0, 3) end
            end
        end)
    end)
    
    -- ===== TITLE BAR =====
    local titleBar = CreateInstance("Frame")
    if not titleBar then return nil end
    
    titleBar.Name = "TitleBar"
    titleBar.Parent = window
    titleBar.BackgroundColor3 = theme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    
    AddCorner(titleBar, KLib.Config.WindowCornerRadius)
    
    -- Title Icon
    local titleIcon = CreateInstance("TextLabel")
    if titleIcon then
        titleIcon.Name = "Icon"
        titleIcon.Parent = titleBar
        titleIcon.BackgroundTransparency = 1
        titleIcon.BorderSizePixel = 0
        titleIcon.Size = UDim2.new(0, 45, 1, 0)
        titleIcon.Position = UDim2.new(0, 0, 0, 0)
        titleIcon.TextColor3 = theme.Primary
        titleIcon.TextSize = 20
        titleIcon.Font = Enum.Font.GothamBold
        titleIcon.Text = options.Icon or "⚙️"
        titleIcon.TextXAlignment = Enum.TextXAlignment.Center
        titleIcon.TextYAlignment = Enum.TextYAlignment.Center
    end
    
    -- Title Text
    local titleText = CreateInstance("TextLabel")
    if titleText then
        titleText.Name = "Title"
        titleText.Parent = titleBar
        titleText.BackgroundTransparency = 1
        titleText.BorderSizePixel = 0
        titleText.Size = UDim2.new(1, -90, 1, 0)
        titleText.Position = UDim2.new(0, 45, 0, 0)
        titleText.TextColor3 = theme.Text
        titleText.TextSize = 16
        titleText.Font = Enum.Font.GothamBold
        titleText.Text = title
        titleText.TextXAlignment = Enum.TextXAlignment.Left
        titleText.TextYAlignment = Enum.TextYAlignment.Center
    end
    
    -- Close Button
    local closeBtn = CreateInstance("TextButton")
    if closeBtn then
        closeBtn.Name = "CloseBtn"
        closeBtn.Parent = titleBar
        closeBtn.BackgroundColor3 = theme.Danger
        closeBtn.BorderSizePixel = 0
        closeBtn.Size = UDim2.new(0, 35, 0, 35)
        closeBtn.Position = UDim2.new(1, -40, 0.5, -17)
        closeBtn.TextColor3 = theme.Text
        closeBtn.TextSize = 18
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Text = "×"
        
        AddCorner(closeBtn, 6)
        
        closeBtn.MouseButton1Click:Connect(function()
            if screenGui then
                screenGui:Destroy()
            end
        end)
        
        closeBtn.MouseEnter:Connect(function()
            if closeBtn then
                closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            end
        end)
        
        closeBtn.MouseLeave:Connect(function()
            if closeBtn then
                closeBtn.BackgroundColor3 = theme.Danger
            end
        end)
    end
    
    -- ===== CONTENT AREA =====
    local content = CreateInstance("Frame")
    if not content then return nil end
    
    content.Name = "Content"
    content.Parent = window
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Size = UDim2.new(1, 0, 1, -55)
    content.Position = UDim2.new(0, 0, 0, 45)
    
    local scrollFrame = CreateInstance("ScrollingFrame")
    if not scrollFrame then return nil end
    
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Parent = content
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.ScrollBarThickness = KLib.Config.ScrollBarThickness
    scrollFrame.ScrollBarImageColor3 = theme.Primary
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local listLayout = CreateInstance("UIListLayout")
    if listLayout then
        listLayout.Parent = scrollFrame
        listLayout.Padding = UDim.new(0, 10)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.FillDirection = Enum.FillDirection.Vertical
        
        listLayout.Changed:Connect(function()
            if scrollFrame then
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 24)
            end
        end)
    end
    
    local padding = CreateInstance("UIPadding")
    if padding then
        padding.Parent = scrollFrame
        padding.PaddingTop = UDim.new(0, 12)
        padding.PaddingBottom = UDim.new(0, 12)
        padding.PaddingLeft = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)
    end
    
    -- ===== BUTTON =====
    local function CreateButton(text, callback, buttonOptions)
        if not scrollFrame then return nil end
        buttonOptions = buttonOptions or {}
        
        local theme = GetTheme()
        local buttonColor = buttonOptions.Color or theme.Primary
        
        local button = CreateInstance("TextButton")
        if not button then return nil end
        
        button.Name = "Button_" .. tostring(text or "")
        button.Parent = scrollFrame
        button.BackgroundColor3 = buttonColor
        button.BorderSizePixel = 0
        button.Size = UDim2.new(1, -24, 0, 45)
        button.Text = ""
        button.LayoutOrder = buttonOptions.LayoutOrder or 1
        
        AddCorner(button, KLib.Config.ElementCornerRadius)
        AddStroke(button, buttonColor, 1, 0.5)
        
        local btnText = CreateInstance("TextLabel")
        if btnText then
            btnText.Parent = button
            btnText.BackgroundTransparency = 1
            btnText.BorderSizePixel = 0
            btnText.Size = UDim2.new(1, 0, 1, 0)
            btnText.TextColor3 = theme.Text
            btnText.TextSize = 14
            btnText.Font = Enum.Font.GothamBold
            btnText.Text = text or "Button"
        end
        
        button.MouseButton1Click:Connect(function()
            if callback then
                pcall(callback)
            end
        end)
        
        button.MouseEnter:Connect(function()
            if button then
                button.BackgroundColor3 = buttonColor:Lerp(Color3.new(1, 1, 1), 0.2)
            end
        end)
        
        button.MouseLeave:Connect(function()
            if button then
                button.BackgroundColor3 = buttonColor
            end
        end)
        
        return button
    end
    
    -- ===== LABEL =====
    local function CreateLabel(text, labelOptions)
        if not scrollFrame then return nil end
        labelOptions = labelOptions or {}
        
        local theme = GetTheme()
        
        local label = CreateInstance("TextLabel")
        if not label then return nil end
        
        label.Name = "Label_" .. tostring(text and text:sub(1, 20) or "")
        label.Parent = scrollFrame
        label.BackgroundTransparency = 1
        label.BorderSizePixel = 0
        label.Size = UDim2.new(1, -24, 0, 30)
        label.Text = text or "Label"
        label.TextColor3 = labelOptions.Color or theme.Text
        label.TextSize = labelOptions.Size or 14
        label.Font = (labelOptions.Bold and Enum.Font.GothamBold) or Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.LayoutOrder = labelOptions.LayoutOrder or 1
        
        return label
    end
    
    -- ===== INPUT BOX =====
    local function CreateInput(placeholder, callback, inputOptions)
        if not scrollFrame then return nil end
        inputOptions = inputOptions or {}
        
        local theme = GetTheme()
        
        local inputBox = CreateInstance("TextBox")
        if not inputBox then return nil end
        
        inputBox.Name = "InputBox_" .. tostring(placeholder or "")
        inputBox.Parent = scrollFrame
        inputBox.BackgroundColor3 = theme.Surface
        inputBox.BorderSizePixel = 0
        inputBox.Size = UDim2.new(1, -24, 0, 42)
        inputBox.PlaceholderText = placeholder or "Wpisz coś..."
        inputBox.PlaceholderColor3 = theme.TextDim
        inputBox.TextColor3 = theme.Text
        inputBox.TextSize = 14
        inputBox.Font = Enum.Font.Gotham
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.TextYAlignment = Enum.TextYAlignment.Center
        inputBox.ClearTextOnFocus = false
        inputBox.LayoutOrder = inputOptions.LayoutOrder or 1
        
        local inputPadding = CreateInstance("UIPadding")
        if inputPadding then
            inputPadding.Parent = inputBox
            inputPadding.PaddingLeft = UDim.new(0, 12)
            inputPadding.PaddingRight = UDim.new(0, 12)
        end
        
        AddCorner(inputBox, KLib.Config.ElementCornerRadius)
        AddStroke(inputBox, theme.Primary, 1, 0.3)
        
        inputBox.FocusLost:Connect(function(enterPressed)
            if callback then
                pcall(function()
                    callback(inputBox.Text)
                end)
            end
        end)
        
        return inputBox
    end
    
    -- ===== TOGGLE =====
    local function CreateToggle(text, callback, toggleOptions)
        if not scrollFrame then return nil end
        toggleOptions = toggleOptions or {}
        local toggled = toggleOptions.Default or false
        
        local theme = GetTheme()
        
        local container = CreateInstance("Frame")
        if not container then return nil end
        
        container.Name = "Toggle_" .. tostring(text or "")
        container.Parent = scrollFrame
        container.BackgroundColor3 = theme.Surface
        container.BorderSizePixel = 0
        container.Size = UDim2.new(1, -24, 0, 45)
        container.LayoutOrder = toggleOptions.LayoutOrder or 1
        
        AddCorner(container, KLib.Config.ElementCornerRadius)
        AddStroke(container, theme.Border, 1, 0.3)
        
        local label = CreateInstance("TextLabel")
        if label then
            label.Parent = container
            label.BackgroundTransparency = 1
            label.BorderSizePixel = 0
            label.Size = UDim2.new(1, -65, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.Text = text or "Toggle"
            label.TextColor3 = theme.Text
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
        end
        
        local toggleBox = CreateInstance("Frame")
        if toggleBox then
            toggleBox.Name = "ToggleBox"
            toggleBox.Parent = container
            toggleBox.BackgroundColor3 = toggled and theme.Success or theme.Surface
            toggleBox.BorderSizePixel = 0
            toggleBox.Size = UDim2.new(0, 50, 0, 28)
            toggleBox.Position = UDim2.new(1, -58, 0.5, -14)
            
            AddCorner(toggleBox, 6)
            AddStroke(toggleBox, toggled and theme.Success or theme.Border, 1, 0.3)
            
            local toggleDot = CreateInstance("Frame")
            if toggleDot then
                toggleDot.Name = "Dot"
                toggleDot.Parent = toggleBox
                toggleDot.BackgroundColor3 = Color3.new(1, 1, 1)
                toggleDot.BorderSizePixel = 0
                toggleDot.Size = UDim2.new(0, 24, 0, 24)
                toggleDot.Position = toggled and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
                
                AddCorner(toggleDot, 4)
            end
            
            local clickBtn = CreateInstance("TextButton")
            if clickBtn then
                clickBtn.Parent = container
                clickBtn.BackgroundTransparency = 1
                clickBtn.BorderSizePixel = 0
                clickBtn.Size = UDim2.new(0, 60, 1, 0)
                clickBtn.Position = UDim2.new(1, -60, 0, 0)
                clickBtn.Text = ""
                
                clickBtn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    local newColor = toggled and theme.Success or theme.Surface
                    
                    if toggleBox then
                        toggleBox.BackgroundColor3 = newColor
                    end
                    
                    if toggleDot then
                        toggleDot.Position = toggled and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
                    end
                    
                    if callback then
                        pcall(function()
                            callback(toggled)
                        end)
                    end
                end)
            end
        end
        
        return container
    end
    
    -- ===== DROPDOWN =====
    local function CreateDropdown(dropdownOptions, callback, dropdownSettings)
        if not scrollFrame or not dropdownOptions then return nil end
        dropdownSettings = dropdownSettings or {}
        local selected = dropdownOptions[1] or "Select..."
        local dropdownOpen = false
        
        local theme = GetTheme()
        
        local container = CreateInstance("Frame")
        if not container then return nil end
        
        container.Name = "Dropdown"
        container.Parent = scrollFrame
        container.BackgroundColor3 = theme.Surface
        container.BorderSizePixel = 0
        container.Size = UDim2.new(1, -24, 0, 45)
        container.LayoutOrder = dropdownSettings.LayoutOrder or 1
        
        AddCorner(container, KLib.Config.ElementCornerRadius)
        AddStroke(container, theme.Border, 1, 0.3)
        
        local label = CreateInstance("TextLabel")
        if label then
            label.Parent = container
            label.BackgroundTransparency = 1
            label.BorderSizePixel = 0
            label.Size = UDim2.new(1, -50, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.Text = selected
            label.TextColor3 = theme.Text
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.ClipsDescendants = true
        end
        
        local arrow = CreateInstance("TextLabel")
        if arrow then
            arrow.Parent = container
            arrow.BackgroundTransparency = 1
            arrow.BorderSizePixel = 0
            arrow.Size = UDim2.new(0, 40, 1, 0)
            arrow.Position = UDim2.new(1, -40, 0, 0)
            arrow.Text = "▼"
            arrow.TextColor3 = theme.Primary
            arrow.TextSize = 11
            arrow.Font = Enum.Font.Gotham
            arrow.Rotation = 0
        end
        
        local dropdownButton = CreateInstance("TextButton")
        if dropdownButton then
            dropdownButton.Parent = container
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.BorderSizePixel = 0
            dropdownButton.Size = UDim2.new(1, 0, 1, 0)
            dropdownButton.Text = ""
        end
        
        local list = CreateInstance("Frame")
        if list then
            list.Name = "DropdownList"
            list.Parent = container
            list.BackgroundColor3 = theme.Secondary
            list.BorderSizePixel = 0
            list.Size = UDim2.new(1, 0, 0, 0)
            list.Position = UDim2.new(0, 0, 1, 5)
            list.ClipsDescendants = true
            list.Visible = false
            list.ZIndex = 100
            
            AddCorner(list, KLib.Config.ElementCornerRadius)
            AddStroke(list, theme.Border, 1, 0.3)
            
            local listLayout = CreateInstance("UIListLayout")
            if listLayout then
                listLayout.Parent = list
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Padding = UDim.new(0, 4)
            end
            
            local listPadding = CreateInstance("UIPadding")
            if listPadding then
                listPadding.Parent = list
                listPadding.PaddingTop = UDim.new(0, 6)
                listPadding.PaddingBottom = UDim.new(0, 6)
                listPadding.PaddingLeft = UDim.new(0, 8)
                listPadding.PaddingRight = UDim.new(0, 8)
            end
            
            for i, option in ipairs(dropdownOptions) do
                local button = CreateInstance("TextButton")
                if button then
                    button.Parent = list
                    button.BackgroundColor3 = theme.Surface
                    button.BorderSizePixel = 0
                    button.Size = UDim2.new(1, -16, 0, 32)
                    button.Text = option
                    button.TextColor3 = theme.Text
                    button.TextSize = 13
                    button.Font = Enum.Font.Gotham
                    button.LayoutOrder = i
                    
                    AddCorner(button, 4)
                    AddStroke(button, theme.Border, 1, 0.5)
                    
                    button.MouseButton1Click:Connect(function()
                        selected = option
                        if label then label.Text = selected end
                        dropdownOpen = false
                        
                        if list then
                            list.Visible = false
                            list.Size = UDim2.new(1, 0, 0, 0)
                        end
                        if arrow then arrow.Rotation = 0 end
                        
                        if callback then
                            pcall(function()
                                callback(selected)
                            end)
                        end
                    end)
                    
                    button.MouseEnter:Connect(function()
                        if button then
                            button.BackgroundColor3 = theme.Primary
                        end
                    end)
                    
                    button.MouseLeave:Connect(function()
                        if button then
                            button.BackgroundColor3 = theme.Surface
                        end
                    end)
                end
            end
            
            if dropdownButton then
                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownOpen = not dropdownOpen
                    if list then
                        list.Visible = dropdownOpen
                        if dropdownOpen then
                            list.Size = UDim2.new(1, 0, 0, #dropdownOptions * 36 + 12)
                            if arrow then arrow.Rotation = 180 end
                        else
                            list.Size = UDim2.new(1, 0, 0, 0)
                            if arrow then arrow.Rotation = 0 end
                        end
                    end
                end)
            end
        end
        
        return container
    end
    
    -- ===== SLIDER =====
    local function CreateSlider(min, max, callback, sliderOptions)
        if not scrollFrame then return nil end
        sliderOptions = sliderOptions or {}
        local currentValue = sliderOptions.Default or min
        
        local theme = GetTheme()
        
        local container = CreateInstance("Frame")
        if not container then return nil end
        
        container.Name = "Slider"
        container.Parent = scrollFrame
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.Size = UDim2.new(1, -24, 0, 60)
        container.LayoutOrder = sliderOptions.LayoutOrder or 1
        
        local label = CreateInstance("TextLabel")
        if label then
            label.Parent = container
            label.BackgroundTransparency = 1
            label.BorderSizePixel = 0
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Text = (sliderOptions.Label or "Value") .. ": " .. tostring(currentValue)
            label.TextColor3 = theme.Text
            label.TextSize = 13
            label.Font = Enum.Font.GothamBold
            label.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        local sliderBg = CreateInstance("Frame")
        if sliderBg then
            sliderBg.Name = "SliderBackground"
            sliderBg.Parent = container
            sliderBg.BackgroundColor3 = theme.Surface
            sliderBg.BorderSizePixel = 0
            sliderBg.Size = UDim2.new(1, 0, 0, 8)
            sliderBg.Position = UDim2.new(0, 0, 0, 30)
            
            AddCorner(sliderBg, 4)
            AddStroke(sliderBg, theme.Border, 1, 0.3)
            
            local sliderFill = CreateInstance("Frame")
            if sliderFill then
                sliderFill.Name = "SliderFill"
                sliderFill.Parent = sliderBg
                sliderFill.BackgroundColor3 = theme.Primary
                sliderFill.BorderSizePixel = 0
                sliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
                
                AddCorner(sliderFill, 4)
            end
            
            local sliderButton = CreateInstance("Frame")
            if sliderButton then
                sliderButton.Name = "SliderButton"
                sliderButton.Parent = sliderBg
                sliderButton.BackgroundColor3 = theme.Primary
                sliderButton.BorderSizePixel = 0
                sliderButton.Size = UDim2.new(0, 16, 1, 8)
                sliderButton.Position = UDim2.new((currentValue - min) / (max - min), -8, 0.5, -4)
                
                AddCorner(sliderButton, 8)
                AddStroke(sliderButton, theme.Text, 1, 0.5)
                
                local draggingSlider = false
                
                sliderButton.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                    end
                end)
                
                game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)
                
                game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.Mouse and sliderBg then
                        local mouse = game:GetService("Mouse")
                        local relativeX = math.clamp(
                            mouse.X - sliderBg.AbsolutePosition.X,
                            0,
                            sliderBg.AbsoluteSize.X
                        )
                        
                        local newValue = math.round(
                            min + (relativeX / sliderBg.AbsoluteSize.X) * (max - min)
                        )
                        
                        currentValue = math.clamp(newValue, min, max)
                        local ratio = (currentValue - min) / (max - min)
                        
                        if sliderFill then sliderFill.Size = UDim2.new(ratio, 0, 1, 0) end
                        if sliderButton then sliderButton.Position = UDim2.new(ratio, -8, 0.5, -4) end
                        if label then label.Text = (sliderOptions.Label or "Value") .. ": " .. tostring(currentValue) end
                        
                        if callback then
                            pcall(function()
                                callback(currentValue)
                            end)
                        end
                    end
                end)
            end
        end
        
        return container
    end
    
    -- ===== SEPARATOR =====
    local function CreateSeparator(separatorOptions)
        if not scrollFrame then return nil end
        separatorOptions = separatorOptions or {}
        
        local theme = GetTheme()
        
        local sep = CreateInstance("Frame")
        if sep then
            sep.Name = "Separator"
            sep.Parent = scrollFrame
            sep.BackgroundColor3 = theme.Border
            sep.BorderSizePixel = 0
            sep.Size = UDim2.new(1, -24, 0, 1)
            sep.LayoutOrder = separatorOptions.LayoutOrder or 1
        end
        
        return sep
    end
    
    -- ===== NOTIFICATION =====
    local function CreateNotification(message, notifType, duration)
        if not screenGui then return end
        notifType = notifType or "info"
        duration = duration or 3
        
        local theme = GetTheme()
        
        local colors = {
            info = theme.Primary,
            success = theme.Success,
            error = theme.Danger,
            warning = theme.Warning,
        }
        
        local notif = CreateInstance("Frame")
        if not notif then return end
        
        notif.Name = "Notification"
        notif.Parent = screenGui
        notif.BackgroundColor3 = colors[notifType] or colors.info
        notif.BorderSizePixel = 0
        notif.Size = UDim2.new(0, 320, 0, 55)
        notif.Position = UDim2.new(1, 20, 1, -75)
        notif.ZIndex = 999
        
        AddCorner(notif, 8)
        AddStroke(notif, colors[notifType], 1, 0.3)
        
        local notifText = CreateInstance("TextLabel")
        if notifText then
            notifText.Parent = notif
            notifText.BackgroundTransparency = 1
            notifText.BorderSizePixel = 0
            notifText.Size = UDim2.new(1, -20, 1, 0)
            notifText.Position = UDim2.new(0, 10, 0, 0)
            notifText.Text = message or "Notification"
            notifText.TextColor3 = theme.Text
            notifText.TextSize = 13
            notifText.Font = Enum.Font.Gotham
            notifText.TextWrapped = true
            notifText.TextYAlignment = Enum.TextYAlignment.Center
        end
        
        -- Tween in
        notif.Position = UDim2.new(1, 20, 1, -75)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween1 = Tween(notif, tweenInfo, {
            Position = UDim2.new(1, -330, 1, -75)
        })
        
        task.wait(duration)
        
        -- Tween out
        local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local tween2 = Tween(notif, tweenInfo2, {
            Position = UDim2.new(1, 20, 1, -75)
        })
        
        if tween2 then
            tween2.Completed:Connect(function()
                if notif then
                    notif:Destroy()
                end
            end)
        else
            task.wait(0.3)
            if notif then notif:Destroy() end
        end
    end
    
    -- Return all methods
    local gui = {
        Window = window,
        ScreenGui = screenGui,
        CreateButton = CreateButton,
        CreateLabel = CreateLabel,
        CreateInput = CreateInput,
        CreateToggle = CreateToggle,
        CreateDropdown = CreateDropdown,
        CreateSlider = CreateSlider,
        CreateSeparator = CreateSeparator,
        CreateNotification = CreateNotification,
        
        Destroy = function()
            if screenGui then
                screenGui:Destroy()
            end
        end,
        
        SetSize = function(newSize)
            if window then
                window.Size = newSize
            end
        end,
        
        SetPosition = function(newPos)
            if window then
                window.Position = newPos
            end
        end,
        
        SetTheme = function(themeName)
            if KLib.Themes[themeName] then
                KLib.Config.Theme = themeName
            end
        end,
    }
    
    return gui
end

-- ===== CONFIGURATION FUNCTIONS =====
function KLib.SetTheme(themeName)
    if KLib.Themes[themeName] then
        KLib.Config.Theme = themeName
        return true
    end
    return false
end

function KLib.SetWatermark(enabled, text)
    KLib.Config.ShowWatermark = enabled
    if text then
        KLib.Config.WatermarkText = text
    end
end

function KLib.GetAvailableThemes()
    local themes = {}
    for themeName, _ in pairs(KLib.Themes) do
        table.insert(themes, themeName)
    end
    return themes
end

print("[KLib] ✓ Załadowana pomyślnie!")
return KLib
