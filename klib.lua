local GuiLibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Kolory motywu
local Theme = {
    Background = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(35, 35, 50),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentHover = Color3.fromRGB(108, 121, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 190),
    Border = Color3.fromRGB(50, 50, 70),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69)
}

-- Utility funkcje
local function tween(object, properties, duration)
    duration = duration or 0.3
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Główna klasa Window
function GuiLibrary:CreateWindow(title)
    local Window = {}
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomGuiLibrary"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    addCorner(MainFrame, 12)
    addStroke(MainFrame, Theme.Border, 2)
    
    -- Shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://297694300"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(95, 95, 95, 95)
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Theme.Secondary
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    addCorner(TopBar, 12)
    
    -- Fix corner (żeby był tylko na górze)
    local CornerFix = Instance.new("Frame")
    CornerFix.Size = UDim2.new(1, 0, 0, 12)
    CornerFix.Position = UDim2.new(0, 0, 1, -12)
    CornerFix.BackgroundColor3 = Theme.Secondary
    CornerFix.BorderSizePixel = 0
    CornerFix.Parent = TopBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "GUI Library"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -40, 0.5, -17.5)
    CloseButton.BackgroundColor3 = Theme.Error
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Theme.Text
    CloseButton.TextSize = 24
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TopBar
    addCorner(CloseButton, 8)
    
    CloseButton.MouseButton1Click:Connect(function()
        tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)})
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 86, 89)})
    end)
    
    CloseButton.MouseLeave:Connect(function()
        tween(CloseButton, {BackgroundColor3 = Theme.Error})
    end)
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
    MinimizeButton.Position = UDim2.new(1, -80, 0.5, -17.5)
    MinimizeButton.BackgroundColor3 = Theme.Accent
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Theme.Text
    MinimizeButton.TextSize = 24
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = TopBar
    addCorner(MinimizeButton, 8)
    
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(MainFrame, {Size = UDim2.new(0, 550, 0, 45)})
        else
            tween(MainFrame, {Size = UDim2.new(0, 550, 0, 400)})
        end
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        tween(MinimizeButton, {BackgroundColor3 = Theme.AccentHover})
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        tween(MinimizeButton, {BackgroundColor3 = Theme.Accent})
    end)
    
    -- Container
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -20, 1, -65)
    Container.Position = UDim2.new(0, 10, 0, 55)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 4
    Container.ScrollBarImageColor3 = Theme.Accent
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = Container
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Animacja wejścia
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    tween(MainFrame, {Size = UDim2.new(0, 550, 0, 400)}, 0.5)
    
    -- Funkcje Window
    function Window:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.BackgroundColor3 = Theme.Secondary
        Button.Text = text
        Button.TextColor3 = Theme.Text
        Button.TextSize = 14
        Button.Font = Enum.Font.Gotham
        Button.BorderSizePixel = 0
        Button.Parent = Container
        addCorner(Button, 8)
        addStroke(Button, Theme.Border, 1)
        
        Button.MouseButton1Click:Connect(function()
            tween(Button, {BackgroundColor3 = Theme.Accent}, 0.1)
            wait(0.1)
            tween(Button, {BackgroundColor3 = Theme.Secondary}, 0.1)
            if callback then callback() end
        end)
        
        Button.MouseEnter:Connect(function()
            tween(Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)})
        end)
        
        Button.MouseLeave:Connect(function()
            tween(Button, {BackgroundColor3 = Theme.Secondary})
        end)
        
        return Button
    end
    
    function Window:AddToggle(text, default, callback)
        local toggled = default or false
        
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = "ToggleFrame"
        ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
        ToggleFrame.BackgroundColor3 = Theme.Secondary
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Container
        addCorner(ToggleFrame, 8)
        addStroke(ToggleFrame, Theme.Border, 1)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 45, 0, 24)
        ToggleButton.Position = UDim2.new(1, -55, 0.5, -12)
        ToggleButton.BackgroundColor3 = toggled and Theme.Success or Theme.Border
        ToggleButton.Text = ""
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = ToggleFrame
        addCorner(ToggleButton, 12)
        
        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 18, 0, 18)
        Circle.Position = toggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        Circle.BackgroundColor3 = Theme.Text
        Circle.BorderSizePixel = 0
        Circle.Parent = ToggleButton
        addCorner(Circle, 9)
        
        ToggleButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            
            tween(ToggleButton, {BackgroundColor3 = toggled and Theme.Success or Theme.Border})
            tween(Circle, {Position = toggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)})
            
            if callback then callback(toggled) end
        end)
        
        return ToggleFrame
    end
    
    function Window:AddSlider(text, min, max, default, callback)
        local value = default or min
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Size = UDim2.new(1, 0, 0, 55)
        SliderFrame.BackgroundColor3 = Theme.Secondary
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = Container
        addCorner(SliderFrame, 8)
        addStroke(SliderFrame, Theme.Border, 1)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -70, 0, 20)
        Label.Position = UDim2.new(0, 15, 0, 5)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 50, 0, 20)
        ValueLabel.Position = UDim2.new(1, -60, 0, 5)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(value)
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextSize = 14
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame
        
        local SliderBack = Instance.new("Frame")
        SliderBack.Size = UDim2.new(1, -30, 0, 6)
        SliderBack.Position = UDim2.new(0, 15, 1, -18)
        SliderBack.BackgroundColor3 = Theme.Border
        SliderBack.BorderSizePixel = 0
        SliderBack.Parent = SliderFrame
        addCorner(SliderBack, 3)
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        SliderFill.BackgroundColor3 = Theme.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBack
        addCorner(SliderFill, 3)
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Size = UDim2.new(1, 0, 1, 0)
        SliderButton.BackgroundTransparency = 1
        SliderButton.Text = ""
        SliderButton.Parent = SliderBack
        
        local dragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        SliderButton.MouseMoved:Connect(function(x)
            if dragging then
                local percentage = math.clamp((x - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * percentage)
                
                tween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
                ValueLabel.Text = tostring(value)
                
                if callback then callback(value) end
            end
        end)
        
        return SliderFrame
    end
    
    function Window:AddTextbox(text, placeholder, callback)
        local TextboxFrame = Instance.new("Frame")
        TextboxFrame.Name = "TextboxFrame"
        TextboxFrame.Size = UDim2.new(1, 0, 0, 40)
        TextboxFrame.BackgroundColor3 = Theme.Secondary
        TextboxFrame.BorderSizePixel = 0
        TextboxFrame.Parent = Container
        addCorner(TextboxFrame, 8)
        addStroke(TextboxFrame, Theme.Border, 1)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0, 100, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = TextboxFrame
        
        local Textbox = Instance.new("TextBox")
        Textbox.Size = UDim2.new(1, -130, 0, 28)
        Textbox.Position = UDim2.new(0, 110, 0.5, -14)
        Textbox.BackgroundColor3 = Theme.Background
        Textbox.PlaceholderText = placeholder or ""
        Textbox.PlaceholderColor3 = Theme.TextDark
        Textbox.Text = ""
        Textbox.TextColor3 = Theme.Text
        Textbox.TextSize = 13
        Textbox.Font = Enum.Font.Gotham
        Textbox.BorderSizePixel = 0
        Textbox.ClearTextOnFocus = false
        Textbox.Parent = TextboxFrame
        addCorner(Textbox, 6)
        
        Textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(Textbox.Text)
            end
        end)
        
        return Textbox
    end
    
    function Window:AddLabel(text)
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, 0, 0, 30)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.TextDark
        Label.TextSize = 13
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Container
        
        return Label
    end
    
    function Window:AddDropdown(text, options, callback)
        local selected = options[1] or "None"
        local opened = false
        
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = "DropdownFrame"
        DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
        DropdownFrame.BackgroundColor3 = Theme.Secondary
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.Parent = Container
        DropdownFrame.ClipsDescendants = true
        addCorner(DropdownFrame, 8)
        addStroke(DropdownFrame, Theme.Border, 1)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0, 150, 0, 40)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = DropdownFrame
        
        local SelectedLabel = Instance.new("TextLabel")
        SelectedLabel.Size = UDim2.new(1, -180, 0, 40)
        SelectedLabel.Position = UDim2.new(0, 160, 0, 0)
        SelectedLabel.BackgroundTransparency = 1
        SelectedLabel.Text = selected
        SelectedLabel.TextColor3 = Theme.Accent
        SelectedLabel.TextSize = 13
        SelectedLabel.Font = Enum.Font.GothamBold
        SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
        SelectedLabel.Parent = DropdownFrame
        
        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 20, 0, 40)
        Arrow.Position = UDim2.new(1, -30, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = Theme.Text
        Arrow.TextSize = 12
        Arrow.Font = Enum.Font.Gotham
        Arrow.Parent = DropdownFrame
        
        local DropButton = Instance.new("TextButton")
        DropButton.Size = UDim2.new(1, 0, 0, 40)
        DropButton.BackgroundTransparency = 1
        DropButton.Text = ""
        DropButton.Parent = DropdownFrame
        
        local OptionsFrame = Instance.new("Frame")
        OptionsFrame.Size = UDim2.new(1, 0, 0, #options * 35)
        OptionsFrame.Position = UDim2.new(0, 0, 0, 40)
        OptionsFrame.BackgroundTransparency = 1
        OptionsFrame.Parent = DropdownFrame
        
        local OptionsList = Instance.new("UIListLayout")
        OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsList.Padding = UDim.new(0, 2)
        OptionsList.Parent = OptionsFrame
        
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Size = UDim2.new(1, 0, 0, 33)
            OptionButton.BackgroundColor3 = Theme.Background
            OptionButton.Text = option
            OptionButton.TextColor3 = Theme.Text
            OptionButton.TextSize = 13
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.BorderSizePixel = 0
            OptionButton.Parent = OptionsFrame
            
            if i == #options then
                addCorner(OptionButton, 8)
            end
            
            OptionButton.MouseButton1Click:Connect(function()
                selected = option
                SelectedLabel.Text = selected
                
                opened = false
                tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)})
                tween(Arrow, {Rotation = 0})
                
                if callback then callback(selected) end
            end)
            
            OptionButton.MouseEnter:Connect(function()
                tween(OptionButton, {BackgroundColor3 = Theme.Secondary})
            end)
            
            OptionButton.MouseLeave:Connect(function()
                tween(OptionButton, {BackgroundColor3 = Theme.Background})
            end)
        end
        
        DropButton.MouseButton1Click:Connect(function()
            opened = not opened
            
            if opened then
                tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40 + #options * 35)})
                tween(Arrow, {Rotation = 180})
            else
                tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)})
                tween(Arrow, {Rotation = 0})
            end
        end)
        
        return DropdownFrame
    end
    
    return Window
end

return GuiLibrary
