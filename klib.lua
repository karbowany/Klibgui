--[[
    KLib - Premium GUI Library v3.0
    GitHub: https://raw.githubusercontent.com/karbowany/Klibgui/refs/heads/main/klib.lua
    
    Features:
    - Clean & Modern Design
    - Multiple Themes
    - Watermark System
    - Full Customization
    - Smooth Animations
    - Professional UI Elements
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

-- ===== UTILITY FUNCTIONS =====
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
    return ok and result or Instance.new(className)
end

local function AddCorner(gui, radius)
    if not gui then return end
    local corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    })
    if corner then corner.Parent = gui end
    return corner
end

local function AddStroke(gui, color, thickness, transparency)
    if not gui then return end
    local stroke = CreateInstance("UIStroke", {
        Color = color or KLib.Themes[KLib.Config.Theme].Primary,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
    })
    if stroke then stroke.Parent = gui end
    return stroke
end

local function Tween(object, tweenInfo, properties)
    if not object then return end
    local tweenService = game:GetService("TweenService")
    if not tweenService then return object end
    
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
    return KLib.Themes[KLib.Config.Theme] or KLib.Themes.Dark
end

-- ===== WATERMARK =====
local function CreateWatermark(screenGui)
    if not KLib.Config.ShowWatermark then return end
    if not screenGui then return end
    
    local watermark = CreateInstance("TextLabel", {
        Name = "Watermark",
        Parent = screenGui,
        BackgroundTransparency = 0.1,
        BackgroundColor3 = GetTheme().Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 150, 0, 25),
        Position = UDim2.new(1, -160, 0, 10),
        TextColor3 = GetTheme().Primary,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Text = "✦ " .. KLib.Config.WatermarkText,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 1000,
    })
    
    AddCorner(watermark, 6)
    AddStroke(watermark, GetTheme().Primary, 1, 0.7)
    
    -- Glassmorphism effect
    local gradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, GetTheme().Primary),
            ColorSequenceKeypoint.new(1, GetTheme().Accent),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 0.8),
        }),
    })
    if gradient then gradient.Parent = watermark end
    
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
    local ok = pcall(function()
        playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui", 2)
    end)
    
    if not playerGui then
        warn("[KLib] Nie można znaleźć PlayerGui!")
        return nil
    end
    
    -- Screen GUI
    local screenGui = CreateInstance("ScreenGui", {
        Name = "KLib_" .. title,
        ResetOnSpawn = options.ResetOnSpawn ~= false,
        DisplayOrder = options.DisplayOrder or 10,
    })
    
    if screenGui then
        screenGui.Parent = playerGui
    else
        return nil
    end
    
    -- Create Watermark
    CreateWatermark(screenGui)
    
    local theme = GetTheme()
    
    -- Main Window Frame
    local window = CreateInstance("Frame", {
        Name = "MainWindow",
        Parent = screenGui,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Size = windowSize,
        Position = windowPos,
        Active = true,
    })
    
    AddCorner(window, KLib.Config.WindowCornerRadius)
    AddStroke(window, theme.Border, 1, 0.3)
    
    -- Shadow effect (fake)
    local shadow = CreateInstance("Frame", {
        Name = "Shadow",
        Parent = screenGui,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Size = windowSize,
        Position = windowPos + UDim2.new(0, 3, 0, 3),
        ZIndex = 0,
    })
    AddCorner(shadow, KLib.Config.WindowCornerRadius)
    shadow.BackgroundTransparency = 0.8
    
    -- Drag functionality
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart = nil
    local windowStart = nil
    
    if window then
        window.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = game:GetService("Mouse").Position
                windowStart = window.Position
                shadow.Position = windowStart + UDim2.new(0, 3, 0, 3)
            end
        end)
    end
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Mouse and window then
            local mouse = game:GetService("Mouse")
            local delta = mouse.Position - dragStart
            window.Position = windowStart + UDim2.new(0, delta.X, 0, delta.Y)
            shadow.Position = window.Position + UDim2.new(0, 3, 0, 3)
        end
    end)
    
    -- ===== TITLE BAR =====
    local titleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = window,
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45),
        Position = UDim2.new(0, 0, 0, 0),
    })
    AddCorner(titleBar, KLib.Config.WindowCornerRadius)
    
    -- Title Icon
    local titleIcon = CreateInstance("TextLabel", {
        Name = "Icon",
        Parent = titleBar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 45, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        TextColor3 = theme.Primary,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Text = options.Icon or "⚙️",
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
    
    local titleText = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 45, 0, 0),
        TextColor3 = theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
    
    -- Close Button
    local closeBtn = CreateInstance("TextButton", {
        Name = "CloseBtn",
        Parent = titleBar,
        BackgroundColor3 = theme.Danger,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -40, 0.5, -17),
        TextColor3 = theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Text = "×",
    })
    AddCorner(closeBtn, 6)
    
    if closeBtn then
        closeBtn.MouseButton1Click:Connect(function()
            Tween(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = window.Position + UDim2.new(0, 0, -0.5, 0),
            }):Completed:Connect(function()
                screenGui:Destroy()
            end)
        end)
        
        closeBtn.MouseEnter:Connect(function()
            Tween(closeBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = theme.Danger:Lerp(Color3.new(1, 1, 1), 0.2),
            })
        end)
        
        closeBtn.MouseLeave:Connect(function()
            Tween(closeBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = theme.Danger,
            })
        end)
    end
    
    -- ===== CONTENT AREA =====
    local content = CreateInstance("Frame", {
        Name = "Content",
        Parent = window,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -55),
        Position = UDim2.new(0, 0, 0, 45),
    })
    
    local scrollFrame = CreateInstance("ScrollingFrame", {
        Name = "ScrollFrame",
        Parent = content,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = KLib.Config.ScrollBarThickness,
        ScrollBarImageColor3 = theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    
    local listLayout = CreateInstance("UIListLayout", {
        Parent = scrollFrame,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
    })
    
    local padding = CreateInstance("UIPadding", {
        Parent = scrollFrame,
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    })
    
    -- Update canvas size
    if listLayout then
        listLayout.Changed:Connect(function()
            if scrollFrame then
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 24)
            end
        end)
    end
    
    -- ===== BUTTON =====
    local function CreateButton(text, callback, buttonOptions)
        if not scrollFrame then return nil end
        buttonOptions = buttonOptions or {}
        
        local theme = GetTheme()
        local buttonColor = buttonOptions.Color or theme.Primary
        
        local button = CreateInstance("TextButton", {
            Name = "Button_" .. (text or ""),
            Parent = scrollFrame,
            BackgroundColor3 = buttonColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -24, 0, 45),
            Text = "",
            LayoutOrder = buttonOptions.LayoutOrder or 1,
        })
        
        if not button then return nil end
        
        AddCorner(button, KLib.Config.ElementCornerRadius)
        AddStroke(button, buttonColor, 1, 0.5)
        
        local btnText = CreateInstance("TextLabel", {
            Parent = button,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Text = text or "Button",
        })
        
        button.MouseButton1Click:Connect(function()
            if callback then
                pcall(callback)
            end
        end)
        
        button.MouseEnter:Connect(function()
            if button then
                Tween(button, TweenInfo.new(KLib.Config.AnimationSpeed), {
                    BackgroundColor3 = buttonColor:Lerp(Color3.new(1, 1, 1), 0.2),
                })
            end
        end)
        
        button.MouseLeave:Connect(function()
            if button then
                Tween(button, TweenInfo.new(KLib.Config.AnimationSpeed), {
                    BackgroundColor3 = buttonColor,
                })
            end
        end)
        
        return button
    end
    
    -- ===== LABEL =====
    local function CreateLabel(text, labelOptions)
        if not scrollFrame then return nil end
        labelOptions = labelOptions or {}
        
        local theme = GetTheme()
        
        local label = CreateInstance("TextLabel", {
            Name = "Label_" .. (text and text:sub(1, 20) or ""),
            Parent = scrollFrame,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -24, 0, 30),
            Text = text or "Label",
            TextColor3 = labelOptions.Color or theme.Text,
            TextSize = labelOptions.Size or 14,
            Font = labelOptions.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            LayoutOrder = labelOptions.LayoutOrder or 1,
        })
        
        return label
    end
    
    -- ===== INPUT BOX =====
    local function CreateInput(placeholder, callback, inputOptions)
        if not scrollFrame then return nil end
        inputOptions = inputOptions or {}
        
        local theme = GetTheme()
        
        local inputBox = CreateInstance("TextBox", {
            Name = "InputBox_" .. (placeholder or ""),
            Parent = scrollFrame,
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -24, 0, 42),
            PlaceholderText = placeholder or "Wpisz coś...",
            PlaceholderColor3 = theme.TextDim,
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ClearTextOnFocus = false,
            LayoutOrder = inputOptions.LayoutOrder or 1,
        })
        
        if not inputBox then return nil end
        
        local inputPadding = CreateInstance("UIPadding", {
            Parent = inputBox,
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        })
        
        AddCorner(inputBox, KLib.Config.ElementCornerRadius)
        AddStroke(inputBox, theme.Primary, 1, 0.3)
        
        inputBox.FocusLost:Connect(function(enterPressed)
            if callback then
                pcall(function()
                    callback(inputBox.Text)
                end)
            end
        end)
        
        inputBox.Focused:Connect(function()
            AddStroke(inputBox, theme.Primary, 2, 0.1)
        end)
        
        return inputBox
    end
    
    -- ===== TOGGLE =====
    local function CreateToggle(text, callback, toggleOptions)
        if not scrollFrame then return nil end
        toggleOptions = toggleOptions or {}
        local toggled = toggleOptions.Default or false
        
        local theme = GetTheme()
        
        local container = CreateInstance("Frame", {
            Name = "Toggle_" .. (text or ""),
            Parent = scrollFrame,
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -24, 0, 45),
            LayoutOrder = toggleOptions.LayoutOrder or 1,
        })
        
        if not container then return nil end
        
        AddCorner(container, KLib.Config.ElementCornerRadius)
        AddStroke(container, theme.Border, 1, 0.3)
        
        local label = CreateInstance("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -65, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            Text = text or "Toggle",
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
        
        local toggleBox = CreateInstance("Frame", {
            Name = "ToggleBox",
            Parent = container,
            BackgroundColor3 = toggled and theme.Success or theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 50, 0, 28),
            Position = UDim2.new(1, -58, 0.5, -14),
        })
        AddCorner(toggleBox, 6)
        AddStroke(toggleBox, toggled and theme.Success or theme.Border, 1, 0.3)
        
        local toggleDot = CreateInstance("Frame", {
            Name = "Dot",
            Parent = toggleBox,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 24, 0, 24),
            Position = toggled and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
        })
        AddCorner(toggleDot, 4)
        
        local clickBtn = CreateInstance("TextButton", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 60, 1, 0),
            Position = UDim2.new(1, -60, 0, 0),
            Text = "",
        })
        
        if clickBtn then
            clickBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                local newColor = toggled and theme.Success or theme.Surface
                
                Tween(toggleBox, TweenInfo.new(KLib.Config.AnimationSpeed), {
                    BackgroundColor3 = newColor,
                })
                
                Tween(toggleDot, TweenInfo.new(KLib.Config.AnimationSpeed), {
                    Position = toggled and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
                })
                
                if callback then
                    pcall(function()
                        callback(toggled)
                    end)
                end
            end)
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
        
        local container = CreateInstance("Frame", {
            Name = "Dropdown",
            Parent = scrollFrame,
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -24, 0, 45),
            LayoutOrder = dropdownSettings.LayoutOrder or 1,
        })
        
        if not container then return nil end
        
        AddCorner(container, KLib.Config.ElementCornerRadius)
        AddStroke(container, theme.Border, 1, 0.3)
        
        local label = CreateInstance("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            Text = selected,
            TextColor3 = theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ClipsDescendants = true,
        })
        
        local arrow = CreateInstance("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 40, 1, 0),
            Position = UDim2.new(1, -40, 0, 0),
            Text = "▼",
            TextColor3 = theme.Primary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            Rotation = 0,
        })
        
        local dropdownButton = CreateInstance("TextButton", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
        })
        
        local list = CreateInstance("Frame", {
            Name = "DropdownList",
            Parent = container,
            BackgroundColor3 = theme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 5),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 100,
        })
        AddCorner(list, KLib.Config.ElementCornerRadius)
        AddStroke(list, theme.Border, 1, 0.3)
        
        local listLayout = CreateInstance("UIListLayout", {
            Parent = list,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        })
        
        local listPadding = CreateInstance("UIPadding", {
            Parent = list,
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        })
        
        for i, option in ipairs(dropdownOptions) do
            local button = CreateInstance("TextButton", {
                Parent = list,
                BackgroundColor3 = theme.Surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -16, 0, 32),
                Text = option,
                TextColor3 = theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                LayoutOrder = i,
            })
            AddCorner(button, 4)
            AddStroke(button, theme.Border, 1, 0.5)
            
            if button then
                button.MouseButton1Click:Connect(function()
                    selected = option
                    if label then label.Text = selected end
                    dropdownOpen = false
                    
                    if list then
                        list.Visible = false
                        list.Size = UDim2.new(1, 0, 0, 0)
                    end
                    if arrow then
                        Tween(arrow, TweenInfo.new(KLib.Config.AnimationSpeed), {Rotation = 0})
                    end
                    
                    if callback then
                        pcall(function()
                            callback(selected)
                        end)
                    end
                end)
                
                button.MouseEnter:Connect(function()
                    if button then
                        Tween(button, TweenInfo.new(0.15), {
                            BackgroundColor3 = theme.Primary,
                        })
                    end
                end)
                
                button.MouseLeave:Connect(function()
                    if button then
                        Tween(button, TweenInfo.new(0.15), {
                            BackgroundColor3 = theme.Surface,
                        })
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
                        if arrow then
                            Tween(arrow, TweenInfo.new(KLib.Config.AnimationSpeed), {Rotation = 180})
                        end
                    else
                        list.Size = UDim2.new(1, 0, 0, 0)
                        if arrow then
                            Tween(arrow, TweenInfo.new(KLib.Config.AnimationSpeed), {Rotation = 0})
                        end
                    end
                end
            end)
        end
        
        return container
    end
    
    -- ===== SLIDER =====
    local function CreateSlider(min, max, callback, sliderOptions)
        if not scrollFrame then return nil end
        sliderOptions = sliderOptions or {}
        local currentValue = sliderOptions.Default or min
        
        local theme = GetTheme()
        
        local container = CreateInstance("Frame", {
            Name = "Slider",
            Parent = scrollFrame,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -24, 0, 60),
            LayoutOrder = sliderOptions.LayoutOrder or 1,
        })
        
        if not container then return nil end
        
        local label = CreateInstance("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 20),
            Text = (sliderOptions.Label or "Value") .. ": " .. currentValue,
            TextColor3 = theme.Text,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local sliderBg = CreateInstance("Frame", {
            Name = "SliderBackground",
            Parent = container,
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 8),
            Position = UDim2.new(0, 0, 0, 30),
        })
        AddCorner(sliderBg, 4)
        AddStroke(sliderBg, theme.Border, 1, 0.3)
        
        local sliderFill = CreateInstance("Frame", {
            Name = "SliderFill",
            Parent = sliderBg,
            BackgroundColor3 = theme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
        })
        AddCorner(sliderFill, 4)
        
        local sliderButton = CreateInstance("Frame", {
            Name = "SliderButton",
            Parent = sliderBg,
            BackgroundColor3 = theme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 16, 1, 8),
            Position = UDim2.new((currentValue - min) / (max - min), -8, 0.5, -4),
        })
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
                if label then label.Text = (sliderOptions.Label or "Value") .. ": " .. currentValue end
                
                if callback then
                    pcall(function()
                        callback(currentValue)
                    end)
                end
            end
        end)
        
        return container
    end
    
    -- ===== SEPARATOR =====
    local function CreateSeparator(separatorOptions)
        if not scrollFrame then return nil end
        separatorOptions = separatorOptions or {}
        
        local theme = GetTheme()
        
        local sep = CreateInstance("Frame", {
            Name = "Separator",
            Parent = scrollFrame,
            BackgroundColor3 = theme.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -24, 0, 1),
            LayoutOrder = separatorOptions.LayoutOrder or 1,
        })
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
        
        local notif = CreateInstance("Frame", {
            Name = "Notification",
            Parent = screenGui,
            BackgroundColor3 = colors[notifType] or colors.info,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 320, 0, 55),
            Position = UDim2.new(1, 20, 1, -75),
            ZIndex = 999,
        })
        
        if not notif then return end
        
        AddCorner(notif, 8)
        AddStroke(notif, colors[notifType], 1, 0.3)
        
        local notifText = CreateInstance("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Text = message or "Notification",
            TextColor3 = theme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
        
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
                if notif then notif:Destroy() end
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
    end
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

return KLib
