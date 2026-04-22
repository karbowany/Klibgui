local Library = {}

-- Usługi
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

-- System Motywów Premium
local defaultTheme = {
    Background = Color3.fromRGB(15, 15, 15),
    Topbar = Color3.fromRGB(20, 20, 20),
    TabSection = Color3.fromRGB(20, 20, 20),
    ElementColor = Color3.fromRGB(25, 25, 25),
    ElementHover = Color3.fromRGB(35, 35, 35),
    ElementStroke = Color3.fromRGB(45, 45, 45),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(140, 140, 140),
    Accent = Color3.fromRGB(120, 80, 255), -- Główny fioletowo-niebieski
    Success = Color3.fromRGB(85, 255, 127),
    Error = Color3.fromRGB(255, 85, 85)
}

-- Opcje Animacji Premium
local TweenStyle = Enum.EasingStyle.Quart
local TweenDir = Enum.EasingDirection.Out

local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Tween(instance, properties, duration)
    local tweeninfo = TweenInfo.new(duration or 0.3, TweenStyle, TweenDir)
    local tween = TweenService:Create(instance, tweeninfo, properties)
    tween:Play()
    return tween
end

local function GetParent()
    if gethui then return gethui() end
    if syn and syn.protect_gui then 
        local gui = Create("ScreenGui", {})
        syn.protect_gui(gui)
        gui.Parent = CoreGui
        return gui
    end
    local success = pcall(function() return CoreGui.Name end)
    if success then return CoreGui end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function MakeDraggable(dragPart, mainPart)
    local dragging, dragInput, dragStart, startPos
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainPart.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(mainPart, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
end

-- ==========================================
-- GŁÓWNA INICJALIZACJA
-- ==========================================
function Library:CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "KLib Premium"
    local Theme = config.Theme or defaultTheme
    local WindowSize = config.Size or UDim2.new(0, 560, 0, 380)
    
    local WindowClass = {}
    WindowClass.CurrentTabString = ""
    WindowClass.Tabs = {}
    WindowClass.Theme = Theme
    WindowClass.Toggled = true
    WindowClass.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    local KGuiGui = Create("ScreenGui", {
        Name = "KLibGui_" .. game:GetService("HttpService"):GenerateGUID(false),
        ResetOnSpawn = false,
        DisplayOrder = 999,
        Parent = GetParent()
    })
    
    -- SYSTEM POWIADOMIEN (Z boku okna, prawy dolny ekran)
    local NotifyFolder = Create("Frame", {
        Name = "NotifContainer",
        Parent = KGuiGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 300, 1, 0)
    })
    local NotifyList = Create("UIListLayout", {
        Parent = NotifyFolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })
    
    -- FUNKCJA NOTIFY (Teraz widoczna wszedzie w Library)
    function Library:Notify(notifConfig)
        notifConfig = notifConfig or {}
        local title = notifConfig.Title or "Notification"
        local content = notifConfig.Content or ""
        local duration = notifConfig.Duration or 3
        
        local NotifFrame = Create("Frame", {
            Parent = NotifyFolder,
            BackgroundColor3 = Theme.Topbar,
            Size = UDim2.new(1, 0, 0, 0), -- Powiekszane automatycznie zaleznie od tekstu
            ClipsDescendants = true,
            BackgroundTransparency = 1 -- Zaczyna od przezroczystosci
        })
        Create("UICorner", {Parent = NotifFrame, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {Parent = NotifFrame, Color = Theme.ElementStroke, Thickness = 1})
        
        local TitleLbl = Create("TextLabel", {
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -30, 0, 15),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Accent,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1
        })
        
        local ContentLbl = Create("TextLabel", {
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 30),
            Size = UDim2.new(1, -30, 0, 15),
            Font = Enum.Font.GothamMedium,
            Text = content,
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextTransparency = 1
        })
        
        -- Kalkulacja wielkosci tekstu
        local bounds = TextService:GetTextSize(content, 13, Enum.Font.GothamMedium, Vector2.new(270, math.huge))
        local targetHeight = 40 + bounds.Y
        ContentLbl.Size = UDim2.new(1, -30, 0, bounds.Y)
        
        -- Animacja wejscia
        Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, targetHeight), BackgroundTransparency = 0}, 0.4)
        Tween(TitleLbl, {TextTransparency = 0}, 0.4)
        Tween(ContentLbl, {TextTransparency = 0}, 0.4)
        
        -- Czekanie
        task.delay(duration, function()
            -- Animacja wyjscia
            Tween(TitleLbl, {TextTransparency = 1}, 0.3)
            Tween(ContentLbl, {TextTransparency = 1}, 0.3)
            local t = Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            t.Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end)
    end

    -- RAMKA GŁÓWNA
    local Canvas = Create("Frame", {
        Name = "Canvas",
        Parent = KGuiGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })
    
    local MainFrame = Create("Frame", {
        Name = "Main",
        Parent = Canvas,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2),
        Size = WindowSize,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})
    Create("UIStroke", {Parent = MainFrame, Color = Theme.ElementStroke, Thickness = 2})
    
    -- Efekt Cienia (Opcjonalnie jak Image zaleza od dewelopera ale tu damy UIStroke jako zamiennik)

    -- TOPBAR
    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Topbar,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0
    })
    
    local TopbarDivider = Create("Frame", {
        Parent = Topbar,
        BackgroundColor3 = Theme.ElementStroke,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0
    })

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = TitleText,
        TextColor3 = Theme.Accent,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    MakeDraggable(Topbar, MainFrame)
    
    -- SIDEBAR (Lewy)
    local Sidebar = Create("ScrollingFrame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Active = true,
        BackgroundColor3 = Theme.TabSection,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(0, 150, 1, -46),
        ScrollBarThickness = 0
    })
    
    local SidebarList = Create("UIListLayout", {
        Parent = Sidebar,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    local SidebarPadding = Create("UIPadding", {
        Parent = Sidebar,
        PaddingTop = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15)
    })
    
    local Divider = Create("Frame", {
        Name = "Divider",
        Parent = MainFrame,
        BackgroundColor3 = Theme.ElementStroke,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 46),
        Size = UDim2.new(0, 1, 1, -46)
    })
    
    -- ZAWARTOŚĆ
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 152, 0, 46),
        Size = UDim2.new(1, -152, 1, -46)
    })

    -- Toggle Okna Pod Przyciskiem (np. Right Control / Right Shift)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == WindowClass.ToggleKey then
            WindowClass.Toggled = not WindowClass.Toggled
            if WindowClass.Toggled then
                Canvas.Visible = true
                Tween(MainFrame, {Size = WindowSize, BackgroundTransparency = 0}, 0.5)
                for _, obj in pairs(MainFrame:GetDescendants()) do
                    if obj:IsA("GuiObject") and obj.Name ~= "Main" then
                        Tween(obj, {BackgroundTransparency = obj:GetAttribute("OrigAlpha") or 0}, 0.5)
                        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                            Tween(obj, {TextTransparency = obj:GetAttribute("OrigTextAlpha") or 0}, 0.5)
                        end
                        if obj:IsA("UIStroke") then
                            Tween(obj, {Transparency = obj:GetAttribute("OrigStrokeAlpha") or 0}, 0.5)
                        end
                    end
                end
            else
                -- Efekt chowania
                local shrinkSize = UDim2.new(0, WindowSize.X.Offset, 0, 0)
                Tween(MainFrame, {Size = shrinkSize, BackgroundTransparency = 1}, 0.3)
                for _, obj in pairs(MainFrame:GetDescendants()) do
                    if obj:IsA("GuiObject") and obj.Name ~= "Main" then
                        if not obj:GetAttribute("SavedAlpha") then
                            obj:SetAttribute("OrigAlpha", obj.BackgroundTransparency)
                            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                                obj:SetAttribute("OrigTextAlpha", obj.TextTransparency)
                            end
                            if obj:IsA("UIStroke") then
                                obj:SetAttribute("OrigStrokeAlpha", obj.Transparency)
                            end
                            obj:SetAttribute("SavedAlpha", true)
                        end
                        Tween(obj, {BackgroundTransparency = 1}, 0.3)
                        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                            Tween(obj, {TextTransparency = 1}, 0.3)
                        end
                        if obj:IsA("UIStroke") then
                            Tween(obj, {Transparency = 1}, 0.3)
                        end
                    end
                end
                task.delay(0.3, function() if not WindowClass.Toggled then Canvas.Visible = false end end)
            end
        end
    end)


    -- ==========================================
    -- ZAKŁADKI (TABS)
    -- ==========================================
    function WindowClass:CreateTab(tabName, iconId)
        local Tab = {}
        WindowClass.Tabs[tabName] = Tab
        
        local TabBtn = Create("TextButton", {
            Name = tabName,
            Parent = Sidebar,
            BackgroundColor3 = Theme.ElementColor,
            Size = UDim2.new(1, 0, 0, 34),
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = Theme.SubText,
            TextSize = 13,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        local TabStroke = Create("UIStroke", {Parent = TabBtn, Color = Theme.ElementStroke, Thickness = 1})
        
        local TabContent = Create("ScrollingFrame", {
            Name = tabName.."_Content",
            Parent = ContentContainer,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false
        })
        
        local ContentList = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        local ContentPadding = Create("UIPadding", {
            Parent = TabContent,
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15)
        })
        
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
        end)
        SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 30)
        end)

        TabBtn.MouseEnter:Connect(function()
            if WindowClass.CurrentTabString ~= tabName then
                Tween(TabBtn, {BackgroundColor3 = Theme.ElementHover}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowClass.CurrentTabString ~= tabName then
                Tween(TabBtn, {BackgroundColor3 = Theme.ElementColor}, 0.2)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, content in pairs(ContentContainer:GetChildren()) do
                if content:IsA("ScrollingFrame") then
                    content.Visible = false
                end
            end
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {TextColor3 = Theme.SubText, BackgroundColor3 = Theme.ElementColor}, 0.3)
                    local st = btn:FindFirstChildOfClass("UIStroke")
                    if st then Tween(st, {Color = Theme.ElementStroke}, 0.3) end
                end
            end
            
            TabContent.Visible = true
            Tween(TabBtn, {TextColor3 = Theme.Text, BackgroundColor3 = Theme.Accent}, 0.3)
            Tween(TabStroke, {Color = Theme.Accent}, 0.3)
            WindowClass.CurrentTabString = tabName
            
            -- Bounce Effect Maly
            TabContent.Position = UDim2.new(0, 10, 0, 0)
            TabContent.GroupTransparency = 1
            Tween(TabContent, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
            -- Wymagałoby CanvasGroup zeby robic fading całego kontentu, uzyjemy tylko position dla wizuala
        end)

        if WindowClass.CurrentTabString == "" then
            TabBtn.MouseButton1Click:Fire()
        end

        -- ==========================================
        -- KOMPONENTY (ELEMENTS)
        -- ==========================================
        
        -- SECION / LABEL
        function Tab:CreateLabel(text)
            local LblSystem = {}
            local LabelFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20)
            })
            
            local TextObj = Create("TextLabel", {
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(1, -10, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.SubText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            function LblSystem:Set(newText)
                TextObj.Text = newText
            end
            return LblSystem
        end

        -- BUTTON
        function Tab:CreateButton(options)
            local btnText = options.Name or "Button"
            local callback = options.Callback or function() end
            
            local Button = Create("TextButton", {
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, 38),
                Font = Enum.Font.GothamMedium,
                Text = btnText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Button, Color = Theme.ElementStroke, Thickness = 1})
            
            -- Wzorzec Fali / Myszki (Hover)
            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.ElementHover}, 0.2)
            end)
            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.ElementColor}, 0.2)
            end)
            
            Button.MouseButton1Down:Connect(function()
                Tween(Button, {Size = UDim2.new(0.97, 0, 0, 34)}, 0.1)
            end)
            Button.MouseButton1Up:Connect(function()
                Tween(Button, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
                callback()
            end)
        end

        -- TOGGLE
        function Tab:CreateToggle(options)
            local toggleText = options.Name or "Toggle"
            local defaultVal = options.CurrentValue or false
            local callback = options.Callback or function() end
            
            local ToggleSystem = {Value = defaultVal}
            
            local ToggleFrame = Create("TextButton", {
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, 42),
                Font = Enum.Font.Gotham,
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = ToggleFrame, Color = Theme.ElementStroke, Thickness = 1})
            
            local TitleLabel = Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -70, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = toggleText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local CheckParent = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Theme.Topbar,
                Position = UDim2.new(1, -50, 0.5, -12),
                Size = UDim2.new(0, 40, 0, 24)
            })
            Create("UICorner", {Parent = CheckParent, CornerRadius = UDim.new(1, 0)})
            local CheckStroke = Create("UIStroke", {Parent = CheckParent, Color = Theme.ElementStroke, Thickness = 1})
            
            local Indicator = Create("Frame", {
                Parent = CheckParent,
                BackgroundColor3 = defaultVal and Theme.Text or Theme.SubText,
                Position = defaultVal and UDim2.new(1, -20, 0.5, -10) or UDim2.new(0, 4, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20)
            })
            Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
            -- Drop środek żeby byc kolkiem z borderem lub pelny wypelniony (dodajemy shadow)
            Create("UIStroke", {Parent = Indicator, Color = defaultVal and Theme.Text or Theme.SubText, Thickness = 1, Transparency=0.8})

            if defaultVal then
                CheckParent.BackgroundColor3 = Theme.Accent
                CheckStroke.Color = Theme.Accent
            end

            local function UpdateToggle(value)
                ToggleSystem.Value = value
                if value then
                    Tween(CheckParent, {BackgroundColor3 = Theme.Accent}, 0.3)
                    Tween(CheckStroke, {Color = Theme.Accent}, 0.3)
                    Tween(Indicator, {Position = UDim2.new(1, -22, 0.5, -10), BackgroundColor3 = Theme.Text}, 0.3)
                else
                    Tween(CheckParent, {BackgroundColor3 = Theme.Topbar}, 0.3)
                    Tween(CheckStroke, {Color = Theme.ElementStroke}, 0.3)
                    Tween(Indicator, {Position = UDim2.new(0, 2, 0.5, -10), BackgroundColor3 = Theme.SubText}, 0.3)
                end
                pcall(callback, value)
            end
            
            ToggleFrame.MouseEnter:Connect(function() Tween(ToggleFrame, {BackgroundColor3 = Theme.ElementHover}, 0.2) end)
            ToggleFrame.MouseLeave:Connect(function() Tween(ToggleFrame, {BackgroundColor3 = Theme.ElementColor}, 0.2) end)
            
            ToggleFrame.MouseButton1Click:Connect(function()
                UpdateToggle(not ToggleSystem.Value)
            end)
            
            function ToggleSystem:Set(newValue) UpdateToggle(newValue) end
            
            return ToggleSystem
        end

        -- SLIDER
        function Tab:CreateSlider(options)
            local sliderText = options.Name or "Slider"
            local minVal = options.Range[1] or 0
            local maxVal = options.Range[2] or 100
            local isInt = options.Increment == 1 or options.Increment == nil
            local defaultVal = options.CurrentValue or minVal
            local callback = options.Callback or function() end
            
            local SliderSystem = {Value = defaultVal}
            
            local SliderFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, 56)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = SliderFrame, Color = Theme.ElementStroke, Thickness = 1})
            
            local TitleLabel = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 8),
                Size = UDim2.new(1, -80, 0, 15),
                Font = Enum.Font.GothamMedium,
                Text = sliderText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValueBack = Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Theme.Topbar,
                Position = UDim2.new(1, -55, 0, 5),
                Size = UDim2.new(0, 40, 0, 20)
            })
            Create("UICorner", {Parent = ValueBack, CornerRadius = UDim.new(0, 4)})
            
            local ValueLabel = Create("TextLabel", {
                Parent = ValueBack,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = tostring(defaultVal),
                TextColor3 = Theme.Accent,
                TextSize = 12
            })
            
            local BarBG = Create("TextButton", {
                Parent = SliderFrame,
                BackgroundColor3 = Theme.Topbar,
                Position = UDim2.new(0, 15, 1, -16),
                Size = UDim2.new(1, -30, 0, 6),
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = BarBG, CornerRadius = UDim.new(1, 0)})
            Create("UIStroke", {Parent = BarBG, Color = Theme.ElementStroke, Thickness = 1})
            
            local BarFill = Create("Frame", {
                Parent = BarBG,
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
            })
            Create("UICorner", {Parent = BarFill, CornerRadius = UDim.new(1, 0)})
            
            local Dot = Create("Frame", {
                Parent = BarFill,
                BackgroundColor3 = Theme.Text,
                Position = UDim2.new(1, -4, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(1, 0)})
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                local v = minVal + ((maxVal - minVal) * pos)
                if isInt then v = math.floor(v + 0.5)
                else v = math.floor(v * 100) / 100 end
                
                if options.Increment and not isInt then
                   v = math.floor(v / options.Increment + 0.5) * options.Increment
                end
                v = math.clamp(v, minVal, maxVal)
                SliderSystem.Value = v
                
                ValueLabel.Text = tostring(v)
                Tween(BarFill, {Size = UDim2.new((v - minVal) / (maxVal - minVal), 0, 1, 0)}, 0.1)
                pcall(callback, v)
            end
            
            local Dragging = false
            BarBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    UpdateSlider(input)
                    Tween(Dot, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -6, 0.5, -10)}, 0.1)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                    Tween(Dot, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -4, 0.5, -8)}, 0.1)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            function SliderSystem:Set(newValue)
                newValue = math.clamp(newValue, minVal, maxVal)
                SliderSystem.Value = newValue
                ValueLabel.Text = tostring(newValue)
                Tween(BarFill, {Size = UDim2.new((newValue - minVal) / (maxVal - minVal), 0, 1, 0)}, 0.2)
                pcall(callback, newValue)
            end
            
            return SliderSystem
        end

        -- DROPDOWN
        function Tab:CreateDropdown(options)
            local dropText = options.Name or "Dropdown"
            local dropOptions = options.Options or {}
            local currentOpt = options.CurrentOption or ""
            local callback = options.Callback or function() end
            
            local DropdownSystem = {Value = currentOpt}
            local ClosedHeight = 42
            
            local DropdownFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, ClosedHeight),
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropdownFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = DropdownFrame, Color = Theme.ElementStroke, Thickness = 1})
            
            local ToggleBtn = Create("TextButton", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ClosedHeight),
                Text = "",
                AutoButtonColor = false
            })
            
            local TitleLabel = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -50, 0, ClosedHeight),
                Font = Enum.Font.GothamMedium,
                Text = dropText .. (currentOpt ~= "" and (" - " .. currentOpt) or ""),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Icon = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -35, 0, 0),
                Size = UDim2.new(0, 30, 0, ClosedHeight),
                Font = Enum.Font.GothamMedium,
                Text = "+",
                TextColor3 = Theme.Accent,
                TextSize = 22
            })
            
            local ScrollContainer = Create("ScrollingFrame", {
                Parent = DropdownFrame,
                BackgroundColor3 = Theme.Topbar,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, ClosedHeight + 5),
                Size = UDim2.new(1, -20, 1, -(ClosedHeight + 15)),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent
            })
            Create("UICorner", {Parent = ScrollContainer, CornerRadius = UDim.new(0, 4)})
            
            local ScrollList = Create("UIListLayout", {
                Parent = ScrollContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })
            
            local function RefreshSize()
                if ScrollContainer.Visible then
                    local items = #dropOptions
                    local scrollHeight = math.clamp(items * 30, 0, 120)
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, ClosedHeight + 20 + scrollHeight)}, 0.4)
                    Tween(Icon, {Rotation = 45}, 0.3)
                else
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, ClosedHeight)}, 0.4)
                    Tween(Icon, {Rotation = 0}, 0.3)
                end
            end
            
            ScrollContainer.Visible = false
            
            ToggleBtn.MouseButton1Click:Connect(function()
                ScrollContainer.Visible = not ScrollContainer.Visible
                RefreshSize()
            end)
            
            local function Populate(opts)
                dropOptions = opts or {}
                for _, v in pairs(ScrollContainer:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                
                for _, opt in pairs(dropOptions) do
                    local btn = Create("TextButton", {
                        Parent = ScrollContainer,
                        BackgroundColor3 = Theme.ElementColor,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = Enum.Font.GothamMedium,
                        Text = "  " .. opt,
                        TextColor3 = Theme.SubText,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false
                    })
                    
                    btn.MouseEnter:Connect(function()
                        Tween(btn, {TextColor3 = Theme.Text, BackgroundTransparency = 0.5}, 0.2)
                    end)
                    btn.MouseLeave:Connect(function()
                        if DropdownSystem.Value == opt then
                            Tween(btn, {TextColor3 = Theme.Accent, BackgroundTransparency=1}, 0.2)
                        else
                            Tween(btn, {TextColor3 = Theme.SubText, BackgroundTransparency=1}, 0.2)
                        end
                    end)
                    
                    btn.MouseButton1Click:Connect(function()
                        DropdownSystem:Set(opt)
                        ScrollContainer.Visible = false
                        RefreshSize()
                    end)
                end
                ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, #dropOptions * 30)
            end
            
            Populate(dropOptions)
            
            function DropdownSystem:Set(newOption)
                DropdownSystem.Value = newOption
                TitleLabel.Text = dropText .. " - " .. tostring(newOption)
                
                for _, btn in pairs(ScrollContainer:GetChildren()) do
                    if btn:IsA("TextButton") then
                        if btn.Text:match(newOption) then
                            btn.TextColor3 = Theme.Accent
                        else
                            btn.TextColor3 = Theme.SubText
                        end
                    end
                end
                pcall(callback, newOption)
            end
            
            function DropdownSystem:Refresh(newOptionsArray, newDefault)
                Populate(newOptionsArray)
                if newDefault then DropdownSystem:Set(newDefault) end
                if ScrollContainer.Visible then RefreshSize() end
            end
            
            if currentOpt ~= "" then DropdownSystem:Set(currentOpt) end
            
            return DropdownSystem
        end
        
        -- TEXTBOX (INPUT TEXTU)
        function Tab:CreateInput(options)
            local inputText = options.Name or "Input"
            local defaultPlaceholder = options.PlaceholderText or "Wpisz coś..."
            local callback = options.Callback or function() end
            
            local InputSystem = {}
            
            local InputFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, 42)
            })
            Create("UICorner", {Parent = InputFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = InputFrame, Color = Theme.ElementStroke, Thickness = 1})
            
            local TitleLabel = Create("TextLabel", {
                Parent = InputFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -150, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = inputText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local TextBoxObj = Create("TextBox", {
                Parent = InputFrame,
                BackgroundColor3 = Theme.Topbar,
                Position = UDim2.new(1, -145, 0.5, -12),
                Size = UDim2.new(0, 130, 0, 24),
                Font = Enum.Font.Gotham,
                Text = "",
                PlaceholderText = defaultPlaceholder,
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.SubText,
                TextSize = 13,
                ClearTextOnFocus = false
            })
            Create("UICorner", {Parent = TextBoxObj, CornerRadius = UDim.new(0, 4)})
            
            TextBoxObj.FocusLost:Connect(function(enterPressed)
                pcall(callback, TextBoxObj.Text)
            end)
            
            function InputSystem:Set(val)
                TextBoxObj.Text = tostring(val)
                pcall(callback, val)
            end
            
            return InputSystem
        end

        return Tab
    end

    function WindowClass:Destroy()
        KGuiGui:Destroy()
    end

    return WindowClass
end

return Library
