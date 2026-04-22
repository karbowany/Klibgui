local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

local defaultTheme = {
    Background = Color3.fromRGB(15, 15, 15),
    Topbar = Color3.fromRGB(20, 20, 20),
    TabSection = Color3.fromRGB(22, 22, 22),
    ElementColor = Color3.fromRGB(28, 28, 28),
    ElementHover = Color3.fromRGB(35, 35, 35),
    ElementStroke = Color3.fromRGB(45, 45, 45),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(140, 140, 140),
    Accent = Color3.fromRGB(138, 43, 226), -- Piękny zaawansowany fiolet (Purple)
    Success = Color3.fromRGB(85, 255, 127),
    Error = Color3.fromRGB(255, 85, 85)
}

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

-- POPRAWIONE ZABEZPIECZANIE POWŁOKI BEZ BŁĘDU (ScreenGui in ScreenGui ERROR FIX)
local function ProtectAndSetParent(guiObject)
    if gethui then
        guiObject.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(guiObject)
        guiObject.Parent = CoreGui
    else
        local success = pcall(function() return CoreGui.Name end)
        guiObject.Parent = success and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
    end
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
-- EFEKTY PARTICLE W TLE! (Zaawansowane)
-- ==========================================
local function SpawnParticles(parentFrame, theme)
    local ParticleContainer = Create("Frame", {
        Name = "ParticleLayer",
        Parent = parentFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = -1,
        ClipsDescendants = true
    })
    
    task.spawn(function()
        while task.wait(0.6) do
            -- Tylko jesli okno jest widoczne
            if parentFrame.BackgroundTransparency < 1 then
                local size = math.random(4, 9)
                local p = Create("Frame", {
                    Parent = ParticleContainer,
                    BackgroundColor3 = theme.Accent,
                    Size = UDim2.new(0, size, 0, size),
                    Position = UDim2.new(math.random(10, 90)/100, 0, 1, 10),
                    BackgroundTransparency = math.random(6, 9)/10,
                    Rotation = math.random(0, 360)
                })
                Create("UICorner", {Parent = p, CornerRadius = UDim.new(1, 0)})
                
                local animTime = math.random(5, 10)
                local toX = p.Position.X.Scale + (math.random(-15, 15)/100)
                
                local twe = TweenService:Create(p, TweenInfo.new(animTime, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(toX, 0, -0.1, 0),
                    BackgroundTransparency = 1,
                    Rotation = p.Rotation + math.random(90, 360)
                })
                twe:Play()
                
                twe.Completed:Connect(function()
                    p:Destroy()
                end)
            end
        end
    end)
end

-- ==========================================
-- GŁÓWNA INICJALIZACJA
-- ==========================================
function Library:CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "KLib Ultra Premium"
    local Theme = config.Theme or defaultTheme
    local WindowSize = config.Size or UDim2.new(0, 650, 0, 420)
    
    local WindowClass = {}
    WindowClass.CurrentTabString = ""
    WindowClass.Tabs = {}
    WindowClass.Theme = Theme
    WindowClass.Toggled = true
    WindowClass.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    local strId = ""
    for i=1,5 do strId=strId..string.char(math.random(97,122)) end

    local KGuiGui = Create("ScreenGui", {
        Name = "KLib_" .. strId,
        ResetOnSpawn = false,
        DisplayOrder = 999
    })
    ProtectAndSetParent(KGuiGui)
    
    -- SYSTEM POWIADOMIEN
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
    
    function Library:Notify(notifConfig)
        notifConfig = notifConfig or {}
        local title = notifConfig.Title or "Syste,"
        local content = notifConfig.Content or ""
        local duration = notifConfig.Duration or 3
        
        local NotifFrame = Create("Frame", {
            Parent = NotifyFolder,
            BackgroundColor3 = Theme.Topbar,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            BackgroundTransparency = 1
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
        
        local bounds = TextService:GetTextSize(content, 13, Enum.Font.GothamMedium, Vector2.new(270, math.huge))
        local targetHeight = 45 + bounds.Y
        ContentLbl.Size = UDim2.new(1, -30, 0, bounds.Y)
        
        Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, targetHeight), BackgroundTransparency = 0}, 0.3)
        Tween(TitleLbl, {TextTransparency = 0}, 0.4)
        Tween(ContentLbl, {TextTransparency = 0}, 0.4)
        
        task.delay(duration, function()
            Tween(TitleLbl, {TextTransparency = 1}, 0.3)
            Tween(ContentLbl, {TextTransparency = 1}, 0.3)
            local t = Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            t.Completed:Connect(function() NotifFrame:Destroy() end)
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
        ClipsDescendants = false -- False do Glow effectow, true robimy na content
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})
    Create("UIStroke", {Parent = MainFrame, Color = Theme.ElementStroke, Thickness = 2})
    
    -- Cien Glow pod oknem (Fake Shadow in Roblox)
    local Glow = Create("ImageLabel", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -30, 0, -30),
        Size = UDim2.new(1, 60, 1, 60),
        Image = "rbxassetid://6015897843",
        ImageColor3 = Theme.Background,
        ImageTransparency = 0.5,
        ZIndex = -2,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(32, 32, 224, 224)
    })
    
    -- Odpalamy Particle na Glownym Oknie
    SpawnParticles(MainFrame, Theme)

    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Topbar,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Topbar, CornerRadius = UDim.new(0, 10)})
    local TopbarFix = Create("Frame", {
        Parent = Topbar,
        BackgroundColor3 = Theme.Topbar,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
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
    
    local Sidebar = Create("ScrollingFrame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(0, 160, 1, -46),
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
        Position = UDim2.new(0, 160, 0, 46),
        Size = UDim2.new(0, 1, 1, -46)
    })
    
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 162, 0, 46),
        Size = UDim2.new(1, -162, 1, -46),
        ClipsDescendants = true
    })

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == WindowClass.ToggleKey then
            WindowClass.Toggled = not WindowClass.Toggled
            if WindowClass.Toggled then
                Canvas.Visible = true
                Tween(MainFrame, {Size = WindowSize, BackgroundTransparency = 0}, 0.5)
                Tween(Glow, {ImageTransparency = 0.5}, 0.5)
                for _, obj in pairs(MainFrame:GetDescendants()) do
                    if obj:IsA("GuiObject") and obj.Name ~= "Main" and obj ~= Glow and obj.Name~="ParticleLayer" then
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
                local shrinkSize = UDim2.new(0, WindowSize.X.Offset, 0, 0)
                Tween(MainFrame, {Size = shrinkSize, BackgroundTransparency = 1}, 0.3)
                Tween(Glow, {ImageTransparency = 1}, 0.3)
                for _, obj in pairs(MainFrame:GetDescendants()) do
                    if obj:IsA("GuiObject") and obj.Name ~= "Main" and obj~= Glow and obj.Name~="ParticleLayer" then
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
    function WindowClass:CreateTab(tabName)
        local Tab = {}
        WindowClass.Tabs[tabName] = Tab
        
        local TabBtn = Create("TextButton", {
            Name = tabName,
            Parent = Sidebar,
            BackgroundColor3 = Theme.ElementColor,
            Size = UDim2.new(1, 0, 0, 36),
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
            Padding = UDim.new(0, 12)
        })
        local ContentPadding = Create("UIPadding", {
            Parent = TabContent,
            PaddingTop = UDim.new(0, 20),
            PaddingBottom = UDim.new(0, 20),
            PaddingLeft = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20)
        })
        
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 40)
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

        local function SelectTab()
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
            
            TabContent.Position = UDim2.new(0, -10, 0, 0)
            Tween(TabContent, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)

        if WindowClass.CurrentTabString == "" then 
            SelectTab() 
        end

        -- ==========================================
        -- KOMPONENTY (ELEMENTS)
        -- ==========================================
        
        function Tab:CreateLabel(text)
            local LabelFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20)
            })
            Create("TextLabel", {
                Parent = LabelFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(1, -10, 1, 0), Font = Enum.Font.GothamMedium, Text = text,
                TextColor3 = Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function Tab:CreateButton(options)
            local title = options.Name or "Button"
            local cb = options.Callback or function() end
            local Button = Create("TextButton", {
                Parent = TabContent, BackgroundColor3 = Theme.ElementColor, Size = UDim2.new(1, 0, 0, 38),
                Font = Enum.Font.GothamMedium, Text = title, TextColor3 = Theme.Text, TextSize = 14, AutoButtonColor = false
            })
            Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Button, Color = Theme.ElementStroke, Thickness = 1})
            
            Button.MouseEnter:Connect(function() Tween(Button, {BackgroundColor3 = Theme.ElementHover}, 0.2) end)
            Button.MouseLeave:Connect(function() Tween(Button, {BackgroundColor3 = Theme.ElementColor}, 0.2) end)
            Button.MouseButton1Down:Connect(function() Tween(Button, {Size = UDim2.new(0.97, 0, 0, 34)}, 0.1) end)
            Button.MouseButton1Up:Connect(function() Tween(Button, {Size = UDim2.new(1, 0, 0, 38)}, 0.2); cb() end)
        end

        function Tab:CreateToggle(options)
            local toggleText = options.Name or "Toggle"
            local defaultVal = options.CurrentValue or false
            local callback = options.Callback or function() end
            local ToggleSystem = {Value = defaultVal}
            
            local TF = Create("TextButton", {
                Parent = TabContent, BackgroundColor3 = Theme.ElementColor, Size = UDim2.new(1, 0, 0, 42),
                Text = "", AutoButtonColor = false
            })
            Create("UICorner", {Parent = TF, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = TF, Color = Theme.ElementStroke, Thickness = 1})
            Create("TextLabel", {
                Parent = TF, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.GothamMedium, Text = toggleText, TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
            local CP = Create("Frame", {
                Parent = TF, BackgroundColor3 = defaultVal and Theme.Accent or Theme.Topbar, Position = UDim2.new(1, -50, 0.5, -12), Size = UDim2.new(0, 40, 0, 24)
            })
            Create("UICorner", {Parent = CP, CornerRadius = UDim.new(1, 0)})
            local CS = Create("UIStroke", {Parent = CP, Color = defaultVal and Theme.Accent or Theme.ElementStroke, Thickness = 1})
            local Ind = Create("Frame", {
                Parent = CP, BackgroundColor3 = defaultVal and Theme.Text or Theme.SubText, Position = defaultVal and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10), Size = UDim2.new(0, 20, 0, 20)
            })
            Create("UICorner", {Parent = Ind, CornerRadius = UDim.new(1, 0)})

            local function Update(value)
                ToggleSystem.Value = value
                if value then
                    Tween(CP, {BackgroundColor3 = Theme.Accent}, 0.3)
                    Tween(CS, {Color = Theme.Accent}, 0.3)
                    Tween(Ind, {Position = UDim2.new(1, -22, 0.5, -10), BackgroundColor3 = Theme.Text}, 0.3)
                else
                    Tween(CP, {BackgroundColor3 = Theme.Topbar}, 0.3)
                    Tween(CS, {Color = Theme.ElementStroke}, 0.3)
                    Tween(Ind, {Position = UDim2.new(0, 2, 0.5, -10), BackgroundColor3 = Theme.SubText}, 0.3)
                end
                pcall(callback, value)
            end
            
            TF.MouseEnter:Connect(function() Tween(TF, {BackgroundColor3 = Theme.ElementHover}, 0.2) end)
            TF.MouseLeave:Connect(function() Tween(TF, {BackgroundColor3 = Theme.ElementColor}, 0.2) end)
            TF.MouseButton1Click:Connect(function() Update(not ToggleSystem.Value) end)
            function ToggleSystem:Set(nv) Update(nv) end
            
            return ToggleSystem
        end

        function Tab:CreateSlider(options)
            local sliderText = options.Name or "Slider"
            local minVal = options.Range[1] or 0
            local maxVal = options.Range[2] or 100
            local isInt = options.Increment == 1 or options.Increment == nil
            local defaultVal = options.CurrentValue or minVal
            local callback = options.Callback or function() end
            local SliderSystem = {Value = defaultVal}
            
            local SF = Create("Frame", {
                Parent = TabContent, BackgroundColor3 = Theme.ElementColor, Size = UDim2.new(1, 0, 0, 60)
            })
            Create("UICorner", {Parent = SF, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = SF, Color = Theme.ElementStroke, Thickness = 1})
            
            Create("TextLabel", {
                Parent = SF, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -80, 0, 15), Font = Enum.Font.GothamMedium, Text = sliderText, TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
            local VB = Create("Frame", {
                Parent = SF, BackgroundColor3 = Theme.Topbar, Position = UDim2.new(1, -60, 0, 8), Size = UDim2.new(0, 45, 0, 22)
            })
            Create("UICorner", {Parent = VB, CornerRadius = UDim.new(0, 4)})
            local VL = Create("TextLabel", {
                Parent = VB, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBold, Text = tostring(defaultVal), TextColor3 = Theme.Accent, TextSize = 12
            })
            local BB = Create("TextButton", {
                Parent = SF, BackgroundColor3 = Theme.Topbar, Position = UDim2.new(0, 15, 1, -15), Size = UDim2.new(1, -30, 0, 6), Text = "", AutoButtonColor = false
            })
            Create("UICorner", {Parent = BB, CornerRadius = UDim.new(1, 0)})
            Create("UIStroke", {Parent = BB, Color = Theme.ElementStroke, Thickness = 1})
            local BF = Create("Frame", {
                Parent = BB, BackgroundColor3 = Theme.Accent, Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
            })
            Create("UICorner", {Parent = BF, CornerRadius = UDim.new(1, 0)})
            local Dot = Create("Frame", {
                Parent = BF, BackgroundColor3 = Theme.Text, Position = UDim2.new(1, -4, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(1, 0)})
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - BB.AbsolutePosition.X) / BB.AbsoluteSize.X, 0, 1)
                local v = minVal + ((maxVal - minVal) * pos)
                if isInt then v = math.floor(v + 0.5)
                else v = math.floor(v * 100) / 100 end
                if options.Increment and not isInt then v = math.floor(v / options.Increment + 0.5) * options.Increment end
                v = math.clamp(v, minVal, maxVal)
                SliderSystem.Value = v
                VL.Text = tostring(v)
                Tween(BF, {Size = UDim2.new((v - minVal) / (maxVal - minVal), 0, 1, 0)}, 0.1)
                pcall(callback, v)
            end
            
            local Drag = false
            BB.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Drag = true; UpdateSlider(input)
                    Tween(Dot, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -6, 0.5, -10)}, 0.1)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Drag = false
                    Tween(Dot, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -4, 0.5, -8)}, 0.1)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if Drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(input) end
            end)
            return SliderSystem
        end

        function Tab:CreateInput(options)
            local inputText = options.Name or "Input"
            local defaultPlaceholder = options.PlaceholderText or "Wpisz coś..."
            local callback = options.Callback or function() end
            local InputSystem = {}
            
            local IFF = Create("Frame", {
                Parent = TabContent, BackgroundColor3 = Theme.ElementColor, Size = UDim2.new(1, 0, 0, 42)
            })
            Create("UICorner", {Parent = IFF, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = IFF, Color = Theme.ElementStroke, Thickness = 1})
            Create("TextLabel", {
                Parent = IFF, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -150, 1, 0),
                Font = Enum.Font.GothamMedium, Text = inputText, TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
            local TB = Create("TextBox", {
                Parent = IFF, BackgroundColor3 = Theme.Topbar, Position = UDim2.new(1, -145, 0.5, -14), Size = UDim2.new(0, 130, 0, 28),
                Font = Enum.Font.Gotham, Text = "", PlaceholderText = defaultPlaceholder, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText, TextSize = 13, ClearTextOnFocus = false
            })
            Create("UICorner", {Parent = TB, CornerRadius = UDim.new(0, 4)})
            
            TB.FocusLost:Connect(function() pcall(callback, TB.Text) end)
            function InputSystem:Set(val) TB.Text = tostring(val); pcall(callback, val) end
            return InputSystem
        end

        function Tab:CreateDropdown(options)
            local dropText = options.Name or "Dropdown"
            local dropOptions = options.Options or {}
            local currentOpt = options.CurrentOption or ""
            local callback = options.Callback or function() end
            
            local DropdownSystem = {Value = currentOpt}
            local ClosedHeight = 42
            
            local DropdownFrame = Create("Frame", {
                Parent = TabContent, BackgroundColor3 = Theme.ElementColor, Size = UDim2.new(1, 0, 0, ClosedHeight), ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropdownFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = DropdownFrame, Color = Theme.ElementStroke, Thickness = 1})
            
            local ToggleBtn = Create("TextButton", {
                Parent = DropdownFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, ClosedHeight), Text = "", AutoButtonColor = false
            })
            local TitleLabel = Create("TextLabel", {
                Parent = DropdownFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -50, 0, ClosedHeight),
                Font = Enum.Font.GothamMedium, Text = dropText .. (currentOpt ~= "" and (" - " .. currentOpt) or ""),
                TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
            local Icon = Create("TextLabel", {
                Parent = DropdownFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -35, 0, 0), Size = UDim2.new(0, 30, 0, ClosedHeight),
                Font = Enum.Font.GothamMedium, Text = "+", TextColor3 = Theme.Accent, TextSize = 22
            })
            
            local ScrollContainer = Create("ScrollingFrame", {
                Parent = DropdownFrame, BackgroundColor3 = Theme.Topbar, BorderSizePixel = 0, Position = UDim2.new(0, 10, 0, ClosedHeight + 5),
                Size = UDim2.new(1, -20, 1, -(ClosedHeight + 15)), ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent
            })
            Create("UICorner", {Parent = ScrollContainer, CornerRadius = UDim.new(0, 4)})
            local ScrollList = Create("UIListLayout", {Parent = ScrollContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
            
            local function RefreshSize()
                if ScrollContainer.Visible then
                    local scrollHeight = math.clamp(#dropOptions * 30, 0, 120)
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, ClosedHeight + 20 + scrollHeight)}, 0.4)
                    Tween(Icon, {Rotation = 45}, 0.3)
                else
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, ClosedHeight)}, 0.4)
                    Tween(Icon, {Rotation = 0}, 0.3)
                end
            end
            ScrollContainer.Visible = false
            ToggleBtn.MouseButton1Click:Connect(function() ScrollContainer.Visible = not ScrollContainer.Visible; RefreshSize() end)
            
            local function Populate(opts)
                dropOptions = opts or {}
                for _, v in pairs(ScrollContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(dropOptions) do
                    local btn = Create("TextButton", {
                        Parent = ScrollContainer, BackgroundColor3 = Theme.ElementColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 28), Font = Enum.Font.GothamMedium, Text = "  " .. opt,
                        TextColor3 = Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
                    })
                    btn.MouseEnter:Connect(function() Tween(btn, {TextColor3 = Theme.Text, BackgroundTransparency = 0.5}, 0.2) end)
                    btn.MouseLeave:Connect(function()
                        Tween(btn, {TextColor3 = DropdownSystem.Value == opt and Theme.Accent or Theme.SubText, BackgroundTransparency=1}, 0.2)
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
                    if btn:IsA("TextButton") then btn.TextColor3 = btn.Text:match(newOption) and Theme.Accent or Theme.SubText end
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

        function Tab:CreateKeybind(options)
            local kbText = options.Name or "Keybind"
            local defaultKb = options.CurrentKeybind or "E"
            local holdMode = options.HoldToInteract or false
            local callback = options.Callback or function() end
            
            local KeybindSystem = {Key = defaultKb}
            local KbFrame = Create("Frame", {Parent = TabContent, BackgroundColor3 = Theme.ElementColor, Size = UDim2.new(1, 0, 0, 42)})
            Create("UICorner", {Parent = KbFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = KbFrame, Color = Theme.ElementStroke, Thickness = 1})
            
            Create("TextLabel", {
                Parent = KbFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -100, 1, 0),
                Font = Enum.Font.GothamMedium, Text = kbText, TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
            local BindBtn = Create("TextButton", {
                Parent = KbFrame, BackgroundColor3 = Theme.Topbar, Position = UDim2.new(1, -75, 0.5, -14), Size = UDim2.new(0, 60, 0, 28),
                Font = Enum.Font.GothamBold, Text = tostring(defaultKb), TextColor3 = Theme.Accent, TextSize = 12, AutoButtonColor = false
            })
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
            
            local Listening = false
            BindBtn.MouseButton1Click:Connect(function()
                if not Listening then
                    Listening = true; BindBtn.Text = "..."
                    Tween(BindBtn, {TextColor3 = Theme.SubText}, 0.1)
                end
            end)
            
            UserInputService.InputBegan:Connect(function(input, gp)
                if Listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode.Name
                        Listening = false; KeybindSystem.Key = key; BindBtn.Text = key
                        Tween(BindBtn, {TextColor3 = Theme.Accent}, 0.1)
                    end
                elseif not gp and not Listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == KeybindSystem.Key then
                        if not holdMode then
                            Tween(BindBtn, {Size = UDim2.new(0, 56, 0, 24)}, 0.1)
                            pcall(callback, true)
                            task.wait(0.1)
                            Tween(BindBtn, {Size = UDim2.new(0, 60, 0, 28)}, 0.1)
                        else
                            pcall(callback, true)
                        end
                    end
                end
            end)
            UserInputService.InputEnded:Connect(function(input, gp)
                if not gp and holdMode and not Listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == KeybindSystem.Key then
                        pcall(callback, false)
                    end
                end
            end)
            return KeybindSystem
        end

        return Tab
    end

    function WindowClass:Destroy()
        KGuiGui:Destroy()
    end

    return WindowClass
end

-- ==========================================
-- CUSTOM ZAAWANSOWANY SYSTEM CELOWNIKA (Crosshair)
-- Wywolywany bez okna: Library:CreateCrosshair()
-- ==========================================
function Library:CreateCrosshair(options)
    local chSystem = {}
    chSystem.Enabled = true
    chSystem.Color = options.Color or Color3.fromRGB(0, 255, 0)
    chSystem.Size = options.Size or 12
    chSystem.Gap = options.Gap or 14
    chSystem.Thickness = options.Thickness or 2
    chSystem.FollowMouse = options.FollowMouse or false

    local CHGui = Create("ScreenGui", {Name="KLibCrosshair", ResetOnSpawn=false, DisplayOrder=1000})
    ProtectAndSetParent(CHGui)
    
    local Center = Create("Frame", {
        Parent = CHGui, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0,0,0,0)
    })
    
    local TLine = Create("Frame", {Parent=Center, BorderSizePixel=0})
    local BLine = Create("Frame", {Parent=Center, BorderSizePixel=0})
    local LLine = Create("Frame", {Parent=Center, BorderSizePixel=0})
    local RLine = Create("Frame", {Parent=Center, BorderSizePixel=0})
    
    local mouse = Players.LocalPlayer:GetMouse()
    local renderConn
    
    renderConn = RunService.RenderStepped:Connect(function()
        if not chSystem.Enabled then
            Center.Visible = false
            return
        end
        Center.Visible = true
        
        if chSystem.FollowMouse then
            local pos = UserInputService:GetMouseLocation()
            Center.Position = UDim2.new(0, pos.X, 0, pos.Y)
        else
            Center.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
        
        local c = chSystem.Color
        local s = chSystem.Size
        local g = chSystem.Gap
        local t = chSystem.Thickness
        
        TLine.BackgroundColor3 = c
        BLine.BackgroundColor3 = c
        LLine.BackgroundColor3 = c
        RLine.BackgroundColor3 = c
        
        TLine.Size = UDim2.new(0, t, 0, s)
        TLine.Position = UDim2.new(0.5, -(t/2), 0.5, -g-s)
        
        BLine.Size = UDim2.new(0, t, 0, s)
        BLine.Position = UDim2.new(0.5, -(t/2), 0.5, g)
        
        LLine.Size = UDim2.new(0, s, 0, t)
        LLine.Position = UDim2.new(0.5, -g-s, 0.5, -(t/2))
        
        RLine.Size = UDim2.new(0, s, 0, t)
        RLine.Position = UDim2.new(0.5, g, 0.5, -(t/2))
    end)
    
    function chSystem:Destroy()
        renderConn:Disconnect()
        CHGui:Destroy()
    end
    
    return chSystem
end


return Library
