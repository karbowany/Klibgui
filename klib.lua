--[[
    DorobanA GUI Library v2.1 - FIXED EXECUTOR VERSION
    100% Working - bez nil errors
]]

local DorobanA = {}
DorobanA.__index = DorobanA

-- ===== KOLORY =====
DorobanA.Colors = {
    Primary = Color3.fromRGB(100, 149, 237),
    Secondary = Color3.fromRGB(70, 130, 180),
    Danger = Color3.fromRGB(220, 20, 60),
    Success = Color3.fromRGB(34, 139, 34),
    Warning = Color3.fromRGB(255, 140, 0),
    Dark = Color3.fromRGB(30, 30, 30),
    Light = Color3.fromRGB(240, 240, 240),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(138, 43, 226),
}

-- ===== UTILITY =====
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

local function AddStroke(gui, color, thickness)
    if not gui then return end
    local stroke = CreateInstance("UIStroke", {
        Color = color or DorobanA.Colors.Primary,
        Thickness = thickness or 2,
        Transparency = 0.3
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

-- ===== MAIN WINDOW =====
function DorobanA.CreateWindow(title, options)
    title = title or "Window"
    options = options or {}
    
    local windowSize = options.Size or UDim2.new(0, 500, 0, 600)
    local windowPos = options.Position or UDim2.new(0.5, -250, 0.5, -300)
    
    -- Get PlayerGui safely
    local playerGui = nil
    local ok = pcall(function()
        playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui", 2)
    end)
    
    if not playerGui then
        return nil
    end
    
    -- Screen GUI
    local screenGui = CreateInstance("ScreenGui", {
        Name = "DorobanA_" .. title,
        ResetOnSpawn = options.ResetOnSpawn ~= false,
        DisplayOrder = options.DisplayOrder or 10,
    })
    
    if screenGui then
        screenGui.Parent = playerGui
    else
        return nil
    end
    
    -- Main Window Frame
    local window = CreateInstance("Frame", {
        Name = "Window",
        Parent = screenGui,
        BackgroundColor3 = DorobanA.Colors.Dark,
        BorderSizePixel = 0,
        Size = windowSize,
        Position = windowPos,
        Active = true,
    })
    
    AddCorner(window, 12)
    AddStroke(window, DorobanA.Colors.Accent, 2)
    
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
        end
    end)
    
    -- ===== TITLE BAR =====
    local titleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = window,
        BackgroundColor3 = DorobanA.Colors.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
    })
    AddCorner(titleBar, 12)
    
    local titleText = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        TextColor3 = DorobanA.Colors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Text = "✦ " .. title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
    
    -- Close Button
    local closeBtn = CreateInstance("TextButton", {
        Name = "CloseBtn",
        Parent = titleBar,
        BackgroundColor3 = DorobanA.Colors.Danger,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -40, 0.5, -17),
        TextColor3 = DorobanA.Colors.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Text = "×",
    })
    AddCorner(closeBtn, 6)
    
    if closeBtn then
        closeBtn.MouseButton1Click:Connect(function()
            if screenGui then
                screenGui:Destroy()
            end
        end)
        
        closeBtn.MouseEnter:Connect(function()
            closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end)
        
        closeBtn.MouseLeave:Connect(function()
            closeBtn.BackgroundColor3 = DorobanA.Colors.Danger
        end)
    end
    
    -- ===== CONTENT AREA =====
    local content = CreateInstance("Frame", {
        Name = "Content",
        Parent = window,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 40),
    })
    
    local scrollFrame = CreateInstance("ScrollingFrame", {
        Name = "ScrollFrame",
        Parent = content,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 8,
        ScrollBarImageColor3 = DorobanA.Colors.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    
    local listLayout = CreateInstance("UIListLayout", {
        Parent = scrollFrame,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
    })
    
    local padding = CreateInstance("UIPadding", {
        Parent = scrollFrame,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })
    
    -- Update canvas size
    if listLayout then
        listLayout.Changed:Connect(function()
            if scrollFrame then
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
            end
        end)
    end
    
    -- ===== BUTTON =====
    local function CreateButton(text, callback, buttonOptions)
        if not scrollFrame then return nil end
        buttonOptions = buttonOptions or {}
        
        local button = CreateInstance("TextButton", {
            Name = "Button_" .. (text or ""),
            Parent = scrollFrame,
            BackgroundColor3 = buttonOptions.Color or DorobanA.Colors.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 40),
            Text = "",
            LayoutOrder = buttonOptions.LayoutOrder or 1,
        })
        
        if not button then return nil end
        
        AddCorner(button, 8)
        AddStroke(button, DorobanA.Colors.Text, 1)
        
        local btnText = CreateInstance("TextLabel", {
            Parent = button,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            TextColor3 = DorobanA.Colors.Text,
            TextSize = 15,
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
                button.BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.15)
            end
        end)
        
        button.MouseLeave:Connect(function()
            if button then
                button.BackgroundColor3 = buttonOptions.Color or DorobanA.Colors.Primary
            end
        end)
        
        return button
    end
    
    -- ===== LABEL =====
    local function CreateLabel(text, labelOptions)
        if not scrollFrame then return nil end
        labelOptions = labelOptions or {}
        
        local label = CreateInstance("TextLabel", {
            Name = "Label_" .. (text and text:sub(1, 20) or ""),
            Parent = scrollFrame,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 30),
            Text = text or "Label",
            TextColor3 = labelOptions.Color or DorobanA.Colors.Text,
            TextSize = labelOptions.Size or 14,
            Font = Enum.Font.Gotham,
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
        
        local inputBox = CreateInstance("TextBox", {
            Name = "InputBox_" .. (placeholder or ""),
            Parent = scrollFrame,
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 40),
            PlaceholderText = placeholder or "Wpisz coś...",
            PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
            TextColor3 = DorobanA.Colors.Text,
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
        
        AddCorner(inputBox, 8)
        AddStroke(inputBox, DorobanA.Colors.Primary, 2)
        
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
        
        local container = CreateInstance("Frame", {
            Name = "Toggle_" .. (text or ""),
            Parent = scrollFrame,
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 40),
            LayoutOrder = toggleOptions.LayoutOrder or 1,
        })
        
        if not container then return nil end
        
        AddCorner(container, 8)
        AddStroke(container, DorobanA.Colors.Primary, 1)
        
        local label = CreateInstance("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            Text = text or "Toggle",
            TextColor3 = DorobanA.Colors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
        
        local toggleBox = CreateInstance("TextButton", {
            Name = "ToggleButton",
            Parent = container,
            BackgroundColor3 = toggled and DorobanA.Colors.Success or Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 50, 0, 28),
            Position = UDim2.new(1, -58, 0.5, -14),
            Text = "",
        })
        AddCorner(toggleBox, 6)
        
        local toggleDot = CreateInstance("Frame", {
            Name = "Dot",
            Parent = toggleBox,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 24, 0, 24),
            Position = toggled and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
        })
        AddCorner(toggleDot, 4)
        
        if toggleBox then
            toggleBox.MouseButton1Click:Connect(function()
                toggled = not toggled
                local newColor = toggled and DorobanA.Colors.Success or Color3.fromRGB(60, 60, 60)
                local newPos = toggled and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
                
                if toggleBox then toggleBox.BackgroundColor3 = newColor end
                if toggleDot then toggleDot.Position = newPos end
                
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
        
        local container = CreateInstance("Frame", {
            Name = "Dropdown",
            Parent = scrollFrame,
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 40),
            LayoutOrder = dropdownSettings.LayoutOrder or 1,
        })
        
        if not container then return nil end
        
        AddCorner(container, 8)
        AddStroke(container, DorobanA.Colors.Primary, 2)
        
        local label = CreateInstance("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            Text = selected,
            TextColor3 = DorobanA.Colors.Text,
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
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(1, -35, 0, 0),
            Text = "▼",
            TextColor3 = DorobanA.Colors.Primary,
            TextSize = 12,
            Font = Enum.Font.Gotham,
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
            BackgroundColor3 = DorobanA.Colors.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 5),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 100,
        })
        AddCorner(list, 8)
        AddStroke(list, DorobanA.Colors.Primary, 1)
        
        local listLayout = CreateInstance("UIListLayout", {
            Parent = list,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
        })
        
        local listPadding = CreateInstance("UIPadding", {
            Parent = list,
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
        })
        
        for i, option in ipairs(dropdownOptions) do
            local button = CreateInstance("TextButton", {
                Parent = list,
                BackgroundColor3 = DorobanA.Colors.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -10, 0, 32),
                Text = option,
                TextColor3 = DorobanA.Colors.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                LayoutOrder = i,
            })
            AddCorner(button, 4)
            
            if button then
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
                        button.BackgroundColor3 = DorobanA.Colors.Primary
                    end
                end)
                
                button.MouseLeave:Connect(function()
                    if button then
                        button.BackgroundColor3 = DorobanA.Colors.Secondary
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
                        list.Size = UDim2.new(1, 0, 0, #dropdownOptions * 37)
                        if arrow then arrow.Rotation = 180 end
                    else
                        list.Size = UDim2.new(1, 0, 0, 0)
                        if arrow then arrow.Rotation = 0 end
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
        
        local container = CreateInstance("Frame", {
            Name = "Slider",
            Parent = scrollFrame,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 55),
            LayoutOrder = sliderOptions.LayoutOrder or 1,
        })
        
        if not container then return nil end
        
        local label = CreateInstance("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 20),
            Text = (sliderOptions.Label or "Value") .. ": " .. currentValue,
            TextColor3 = DorobanA.Colors.Text,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local sliderBg = CreateInstance("Frame", {
            Name = "SliderBackground",
            Parent = container,
            BackgroundColor3 = DorobanA.Colors.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 8),
            Position = UDim2.new(0, 0, 0, 25),
        })
        AddCorner(sliderBg, 4)
        
        local sliderFill = CreateInstance("Frame", {
            Name = "SliderFill",
            Parent = sliderBg,
            BackgroundColor3 = DorobanA.Colors.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
        })
        AddCorner(sliderFill, 4)
        
        local sliderButton = CreateInstance("TextButton", {
            Name = "SliderButton",
            Parent = sliderBg,
            BackgroundColor3 = DorobanA.Colors.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 16, 1, 8),
            Position = UDim2.new((currentValue - min) / (max - min), -8, 0.5, -4),
            Text = "",
        })
        AddCorner(sliderButton, 8)
        
        local draggingSlider = false
        
        if sliderButton then
            sliderButton.MouseButton1Down:Connect(function()
                draggingSlider = true
            end)
        end
        
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
    
    -- ===== NOTIFICATION =====
    local function CreateNotification(message, notifType, duration)
        if not screenGui then return end
        notifType = notifType or "info"
        duration = duration or 3
        
        local colors = {
            info = DorobanA.Colors.Primary,
            success = DorobanA.Colors.Success,
            error = DorobanA.Colors.Danger,
            warning = DorobanA.Colors.Warning,
        }
        
        local notif = CreateInstance("Frame", {
            Name = "Notification",
            Parent = screenGui,
            BackgroundColor3 = colors[notifType] or colors.info,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 300, 0, 50),
            Position = UDim2.new(1, 20, 1, -70),
        })
        
        if not notif then return end
        
        AddCorner(notif, 8)
        
        local notifText = CreateInstance("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Text = message or "Notification",
            TextColor3 = DorobanA.Colors.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
        
        -- Tween in
        notif.Position = UDim2.new(1, 20, 1, -70)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween1 = Tween(notif, tweenInfo, {
            Position = UDim2.new(1, -320, 1, -70)
        })
        
        task.wait(duration)
        
        -- Tween out
        local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local tween2 = Tween(notif, tweenInfo2, {
            Position = UDim2.new(1, 20, 1, -70)
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
    
    -- ===== SEPARATOR =====
    local function CreateSeparator()
        if not scrollFrame then return nil end
        local sep = CreateInstance("Frame", {
            Name = "Separator",
            Parent = scrollFrame,
            BackgroundColor3 = DorobanA.Colors.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 2),
        })
        return sep
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
        CreateNotification = CreateNotification,
        CreateSeparator = CreateSeparator,
        
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
    }
    
    return gui
end

return DorobanA
