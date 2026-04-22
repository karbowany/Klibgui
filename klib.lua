local Library = {}

-- Usługi
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Ustawienia Domyślne Pamięci (Zapis i Odczyt)
local defaultTheme = {
    Background = Color3.fromRGB(20, 20, 20),
    Topbar = Color3.fromRGB(25, 25, 25),
    TabSection = Color3.fromRGB(25, 25, 25),
    ElementColor = Color3.fromRGB(30, 30, 30),
    ElementHover = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(85, 170, 255)
}

-- Funkcja pomocnicza: Tworzenie instancji z łatwym przypisywaniem właściwości
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

-- Funkcja pomocnicza: Tween (Animacja)
local function Tween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    duration = duration or 0.2
    local tweeninfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, tweeninfo, properties)
    tween:Play()
    return tween
end

-- Chronienie powłoki (zabezpieczenie UI, żeby nie było widoczne w zwykłym PlayerGui jeśli to możliwe)
local function GetParent()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local gui = Create("ScreenGui", {})
        syn.protect_gui(gui)
        gui.Parent = CoreGui
        return gui
    end
    -- Fallback do CoreGui
    local success = pcall(function() return CoreGui.Name end)
    if success then
        return CoreGui
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Funkcja przypinania przeciągania okna
local function MakeDraggable(topbarObject, object)
    local dragging, dragInput, dragStart, startPos

    topbarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
end


-- Główna inicjalizacja okna
function Library:CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "KGuiLib"
    local Theme = config.Theme or defaultTheme
    local WindowSize = config.Size or UDim2.new(0, 500, 0, 350)
    
    local Window = {}
    Window.CurrentTabString = ""
    Window.Tabs = {}
    Window.Theme = Theme

    -- ScreenGui
    local KGuiGui = Create("ScreenGui", {
        Name = "KGuiLib" .. tostring(math.random(1, 100)),
        ResetOnSpawn = false,
        DisplayOrder = 99
    })
    
    -- Synapse protect_gui jeśli jesteśmy w surowym gethui i chcemy dodatkowo maskoawć nazwy, tu po prostu ładujemy do GetParent()
    KGuiGui.Parent = GetParent()

    -- Frame Główny
    local MainFrame = Create("Frame", {
        Name = "Main",
        Parent = KGuiGui,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2),
        Size = WindowSize,
        ClipsDescendants = false
    })
    
    Create("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Topbar (Belka tytułowa)
    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Topbar,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1 -- używamy tylko jako hitbox drag, można dać widoczny
    })
    
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = TitleText,
        TextColor3 = Theme.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    MakeDraggable(Topbar, MainFrame)
    
    -- Kontener boczny na zakładki
    local Sidebar = Create("ScrollingFrame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Active = true,
        BackgroundColor3 = Theme.TabSection,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 130, 1, -35),
        ScrollBarThickness = 0
    })
    
    Create("UICorner", {
        Parent = Sidebar,
        CornerRadius = UDim.new(0, 8)
    })
    
    local SidebarList = Create("UIListLayout", {
        Parent = Sidebar,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    local SidebarPadding = Create("UIPadding", {
        Parent = Sidebar,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    local Divider = Create("Frame", {
        Name = "Divider",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 131, 0, 45),
        Size = UDim2.new(0, 1, 1, -55),
        BackgroundTransparency = 0.5
    })
    
    -- Główny kontener na elementy z zakładek
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, 35),
        Size = UDim2.new(1, -150, 1, -45)
    })

    function Window:CreateTab(tabName)
        local Tab = {}
        Window.Tabs[tabName] = Tab
        
        -- Guzik w Pasku Bocznym
        local TabBtn = Create("TextButton", {
            Name = tabName,
            Parent = Sidebar,
            BackgroundColor3 = Theme.ElementColor,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamSemibold,
            Text = tabName,
            TextColor3 = Theme.SubText,
            TextSize = 14,
            AutoButtonColor = false
        })
        
        Create("UICorner", {
            Parent = TabBtn,
            CornerRadius = UDim.new(0, 6)
        })
        
        -- Miejsce na elementy zakładki
        local TabContent = Create("ScrollingFrame", {
            Name = tabName.."_Content",
            Parent = ContentContainer,
            Active = true,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false -- Domyślnie schowane
        })
        
        local ContentList = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        local ContentPadding = Create("UIPadding", {
            Parent = TabContent,
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        })
        
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
        end)
        
        SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 20)
        end)

        -- Przełączanie kart
        TabBtn.MouseButton1Click:Connect(function()
            for _, content in pairs(ContentContainer:GetChildren()) do
                if content:IsA("ScrollingFrame") then
                    content.Visible = false
                end
            end
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {TextColor3 = Theme.SubText, BackgroundColor3 = Theme.ElementColor}, 0.2)
                end
            end
            
            TabContent.Visible = true
            Tween(TabBtn, {TextColor3 = Theme.Text, BackgroundColor3 = Theme.Accent}, 0.2)
            Window.CurrentTabString = tabName
        end)

        -- Ustawiamy pierwszą kartę jako domyślną
        if Window.CurrentTabString == "" then
            TabBtn.MouseButton1Click:Fire()
        end

        ---------------------------------------------------------
        -- ELEMENTY W ZAKŁADCE
        ---------------------------------------------------------
        
        -- Label
        function Tab:CreateLabel(text)
            local LabelFuncs = {}
            local LabelFrame = Create("Frame", {
                Name = "Label",
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, 30)
            })
            
            Create("UICorner", {
                Parent = LabelFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            local TextObj = Create("TextLabel", {
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            function LabelFuncs:Set(newText)
                TextObj.Text = newText
            end
            
            return LabelFuncs
        end

        -- Button
        function Tab:CreateButton(options)
            local btnText = options.Name or "Button"
            local callback = options.Callback or function() end
            
            local Button = Create("TextButton", {
                Name = "Button",
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, 35),
                Font = Enum.Font.Gotham,
                Text = btnText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                AutoButtonColor = false
            })
            
            Create("UICorner", {
                Parent = Button,
                CornerRadius = UDim.new(0, 6)
            })
            
            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.ElementHover}, 0.2)
            end)
            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.ElementColor}, 0.2)
            end)
            
            Button.MouseButton1Down:Connect(function()
                Tween(Button, {Size = UDim2.new(0.98, 0, 0, 33)}, 0.1)
            end)
            
            Button.MouseButton1Up:Connect(function()
                Tween(Button, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
                callback()
            end)
        end

        -- Toggle
        function Tab:CreateToggle(options)
            local toggleText = options.Name or "Toggle"
            local defaultVal = options.CurrentValue or false
            local callback = options.Callback or function() end
            
            local ToggleSystem = {
                Value = defaultVal
            }
            
            local ToggleFrame = Create("TextButton", {
                Name = "Toggle",
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, 35),
                Font = Enum.Font.Gotham,
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 6)})
            
            local TitleLabel = Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.Gotham,
                Text = toggleText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local CheckParent = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Theme.Background,
                Position = UDim2.new(1, -45, 0.5, -10),
                Size = UDim2.new(0, 35, 0, 20)
            })
            Create("UICorner", {Parent = CheckParent, CornerRadius = UDim.new(1, 0)}) -- Pill shape
            
            local Indicator = Create("Frame", {
                Parent = CheckParent,
                BackgroundColor3 = defaultVal and Theme.Accent or Theme.SubText,
                Position = defaultVal and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
            
            local function UpdateToggle(value)
                ToggleSystem.Value = value
                if value then
                    Tween(Indicator, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Accent}, 0.2)
                else
                    Tween(Indicator, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.SubText}, 0.2)
                end
                callback(value)
            end
            
            ToggleFrame.MouseButton1Click:Connect(function()
                UpdateToggle(not ToggleSystem.Value)
            end)
            
            function ToggleSystem:Set(newValue)
                UpdateToggle(newValue)
            end
            
            -- Wymuszamy callback startowy (albo nie - zależy od decyzji, na razie wywołamy go dla pierwszego stanu)
            spawn(function()
                callback(ToggleSystem.Value)
            end)
            
            return ToggleSystem
        end

        -- Slider
        function Tab:CreateSlider(options)
            local sliderText = options.Name or "Slider"
            local minVal = options.Range[1] or 0
            local maxVal = options.Range[2] or 100
            local isInt = options.Increment == 1 or options.Increment == nil
            local defaultVal = options.CurrentValue or minVal
            local callback = options.Callback or function() end
            
            local SliderSystem = {
                Value = defaultVal
            }
            
            local SliderFrame = Create("Frame", {
                Name = "Slider",
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, 50)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 6)})
            
            local TitleLabel = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 15),
                Font = Enum.Font.Gotham,
                Text = sliderText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 5),
                Size = UDim2.new(0, 40, 0, 15),
                Font = Enum.Font.Gotham,
                Text = tostring(defaultVal),
                TextColor3 = Theme.SubText,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local BarBG = Create("TextButton", {
                Parent = SliderFrame,
                BackgroundColor3 = Theme.Background,
                Position = UDim2.new(0, 10, 1, -15),
                Size = UDim2.new(1, -20, 0, 6),
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = BarBG, CornerRadius = UDim.new(1, 0)})
            
            local BarFill = Create("Frame", {
                Parent = BarBG,
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
            })
            Create("UICorner", {Parent = BarFill, CornerRadius = UDim.new(1, 0)})
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                local v = minVal + ((maxVal - minVal) * pos)
                if isInt then
                    v = math.floor(v + 0.5)
                else
                    v = math.floor(v * 100) / 100 -- zaokrąglenie do 2 miejsc
                end
                
                -- jeśli precyzyjny Increment:
                if options.Increment and not isInt then
                   v = math.floor(v / options.Increment + 0.5) * options.Increment
                end

                v = math.clamp(v, minVal, maxVal)
                SliderSystem.Value = v
                
                ValueLabel.Text = tostring(v)
                Tween(BarFill, {Size = UDim2.new((v - minVal) / (maxVal - minVal), 0, 1, 0)}, 0.1)
                callback(v)
            end
            
            local Dragging = false
            BarBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
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
                Tween(BarFill, {Size = UDim2.new((newValue - minVal) / (maxVal - minVal), 0, 1, 0)}, 0.1)
                callback(newValue)
            end
            
            -- Wymuszamy domyślny callback startowy po zainicjalizowaniu
            spawn(function()
                callback(SliderSystem.Value)
            end)

            return SliderSystem
        end

        -- Dropdown
        function Tab:CreateDropdown(options)
            local dropText = options.Name or "Dropdown"
            local dropOptions = options.Options or {}
            local currentOpt = options.CurrentOption or ""
            local callback = options.Callback or function() end
            
            local DropdownSystem = {
                Value = currentOpt
            }
            
            local ClosedSize = 35
            
            local DropdownFrame = Create("Frame", {
                Name = "Dropdown",
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, ClosedSize),
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropdownFrame, CornerRadius = UDim.new(0, 6)})
            
            local ToggleBtn = Create("TextButton", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ClosedSize),
                Text = "",
                AutoButtonColor = false
            })
            
            local TopLabel = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 0, ClosedSize),
                Font = Enum.Font.Gotham,
                Text = dropText .. " - " .. currentOpt,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Icon = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 0),
                Size = UDim2.new(0, 30, 0, ClosedSize),
                Font = Enum.Font.Gotham,
                Text = "+",
                TextColor3 = Theme.Text,
                TextSize = 20
            })
            
            local ScrollContainer = Create("ScrollingFrame", {
                Parent = DropdownFrame,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 5, 0, ClosedSize + 5),
                Size = UDim2.new(1, -10, 1, -(ClosedSize + 10)),
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
                    local scrollHeight = math.clamp(items * 27, 0, 100)
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, ClosedSize + 10 + scrollHeight)}, 0.2)
                    Tween(Icon, {Rotation = 45}, 0.2)
                else
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, ClosedSize)}, 0.2)
                    Tween(Icon, {Rotation = 0}, 0.2)
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
                        Size = UDim2.new(1, 0, 0, 25),
                        Font = Enum.Font.Gotham,
                        Text = opt,
                        TextColor3 = Theme.SubText,
                        TextSize = 13,
                        AutoButtonColor = false
                    })
                    
                    btn.MouseEnter:Connect(function()
                        Tween(btn, {TextColor3 = Theme.Accent}, 0.1)
                    end)
                    btn.MouseLeave:Connect(function()
                        if DropdownSystem.Value == opt then
                            Tween(btn, {TextColor3 = Theme.Text}, 0.1)
                        else
                            Tween(btn, {TextColor3 = Theme.SubText}, 0.1)
                        end
                    end)
                    
                    btn.MouseButton1Click:Connect(function()
                        DropdownSystem:Set(opt)
                        ScrollContainer.Visible = false
                        RefreshSize()
                    end)
                end
                
                ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, #dropOptions * 27)
            end
            
            Populate(dropOptions)
            
            function DropdownSystem:Set(newOption)
                DropdownSystem.Value = newOption
                TopLabel.Text = dropText .. " - " .. tostring(newOption)
                
                for _, btn in pairs(ScrollContainer:GetChildren()) do
                    if btn:IsA("TextButton") then
                        if btn.Text == newOption then
                            Tween(btn, {TextColor3 = Theme.Text}, 0.1)
                        else
                            Tween(btn, {TextColor3 = Theme.SubText}, 0.1)
                        end
                    end
                end
                
                callback(newOption)
            end
            
            function DropdownSystem:Refresh(newOptionsArray, newDefault)
                Populate(newOptionsArray)
                if newDefault then
                    DropdownSystem:Set(newDefault)
                end
                if ScrollContainer.Visible then
                    RefreshSize()
                end
            end
            
            return DropdownSystem
        end
        
        -- Keybind
        function Tab:CreateKeybind(options)
            local kbText = options.Name or "Keybind"
            local defaultKb = options.CurrentKeybind or "E"
            local holdMode = options.HoldToInteract or false
            local callback = options.Callback or function() end
            
            local KeybindSystem = {
                Key = defaultKb
            }
            
            local KbFrame = Create("Frame", {
                Name = "Keybind",
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementColor,
                Size = UDim2.new(1, 0, 0, 35)
            })
            Create("UICorner", {Parent = KbFrame, CornerRadius = UDim.new(0, 6)})
            
            local Label = Create("TextLabel", {
                Parent = KbFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -100, 1, 0),
                Font = Enum.Font.Gotham,
                Text = kbText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local BindBtn = Create("TextButton", {
                Parent = KbFrame,
                BackgroundColor3 = Theme.Background,
                Position = UDim2.new(1, -70, 0.5, -12),
                Size = UDim2.new(0, 60, 0, 24),
                Font = Enum.Font.GothamBold,
                Text = tostring(defaultKb),
                TextColor3 = Theme.Accent,
                TextSize = 12,
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
            
            local Listening = false
            
            BindBtn.MouseButton1Click:Connect(function()
                if not Listening then
                    Listening = true
                    BindBtn.Text = "..."
                    Tween(BindBtn, {TextColor3 = Theme.SubText}, 0.1)
                end
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if Listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode.Name
                        Listening = false
                        KeybindSystem.Key = key
                        BindBtn.Text = key
                        Tween(BindBtn, {TextColor3 = Theme.Accent}, 0.1)
                    end
                elseif not gameProcessed and not Listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == KeybindSystem.Key then
                        if not holdMode then
                            Tween(BindBtn, {Size = UDim2.new(0, 56, 0, 20)}, 0.1)
                            callback(true)
                            wait(0.1)
                            Tween(BindBtn, {Size = UDim2.new(0, 60, 0, 24)}, 0.1)
                        else
                            callback(true) -- Wciśnięto i trzymanie
                        end
                    end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input, gameProcessed)
                if not gameProcessed and holdMode and not Listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == KeybindSystem.Key then
                        callback(false) -- Puszczono
                    end
                end
            end)
            
            return KeybindSystem
        end

        return Tab
    end

    -- Zamknięcie okna z kodu w razie potrzeby
    function Window:Destroy()
        KGuiGui:Destroy()
    end

    return Window
end

return Library
